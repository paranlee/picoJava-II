/****************************************************************
 ***
 ***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
 ***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
 ***    The contents of this file are subject to the current
 ***    version of the Sun Community Source License, picoJava-II
 ***    Core ("the License").  You may not use this file except
 ***    in compliance with the License.  You may obtain a copy
 ***    of the License by searching for "Sun Community Source
 ***    License" on the World Wide Web at http://www.sun.com.
 ***    See the License for the rights, obligations, and
 ***    limitations governing use of the contents of this file.
 ***
 ***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 ***
 *****************************************************************/




static char *sccsid = "@(#)object_ops.c 1.5 Last modified 04/30/97 12:22:47 SMI";

/* object_ops.c: handles *all* instructions related to object refs */

#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>

#include "dsv.h"
#include "sim_config.h"
#include "decaf.h"
#include "traps.h"
#include "cm.h"
#include "opcodes.h"
#include "array_ops.h"
#include "iam.h"
#include "javamem.h"
#include "global_regs.h"
#include "dprint.h"
#include "profiler.h"
#include "object_ops.h"

/* temporary variables, file scope */
static int nargs;
static int objref_tmp;
static int value;
static int offset;
static int index, index1, index2;
static int mv_base_addr;
static struct decafMethod *method_desc;
static decafClass *current_class, *super_class, *class;
static struct decafObjectHint *objhint;
static decafString *class_name, *method_name, *method_sig;
static struct decafField *fb;
   
void *waddr;

static unsigned int unsigned_tmp;
static double double_tmp;

/* helper functions, file scope */
static unsigned int printDecafString (decafString *str, char *buf, unsigned int buf_length);
static int gcTrap (unsigned int objref, unsigned int store_data);
static void setupMethodCall (struct decafMethod *method_desc, 
                               unsigned int nargs);
#ifdef INLINE_STATS
static void computeInlineStats ();
#endif

/*__________________________ HELPER FUNCS _______________________________*/

/* return the full name of the method specified by the given 
   method descriptor in the form class.method:sig in buf.

   returns a 0-terminated string (truncated if doesn't fit) in buf.
   buf_length is max. length of the buf
*/
void getMethodNameAndSig (struct decafMethod *method_desc, 
                                 char *buf, uint buf_length)

{
    unsigned int buf_ptr = 0;
    buf_length--;
    if (buf_length < 0)
        return;
    /* zero the last byte, to be safe */
    buf[buf_length] = 0;

    waddr = (&method_desc->methodField.class);
	READ_WORD (waddr, 'G', class);
    /* Class is a pointer to an object. Need to add 4 for 
       structure compatible with decafClass - FY 09/22/97 */
    class = (decafClass *)((int)class + 4);
	waddr = &(class->name);
	READ_WORD (waddr, 'G', class_name);
	buf_ptr += printDecafString (class_name, buf+buf_ptr, buf_length-buf_ptr);

    if (buf_ptr >= buf_length)
        return;
	buf[buf_ptr++] = '.';

    waddr = (&method_desc->methodField.name);
	READ_WORD (waddr, 'G', method_name); 
	buf_ptr += printDecafString (method_name, buf+buf_ptr, buf_length-buf_ptr);

    waddr = (&method_desc->methodField.signature);
	READ_WORD (waddr, 'G', method_sig); 

    if (buf_ptr >= buf_length)
        return;
	buf_ptr += printDecafString (method_sig, buf+buf_ptr, buf_length-buf_ptr);
    if (buf_ptr >= buf_length)
        return;
    buf[buf_ptr] = '\0';
}

/* returns the no. of chars printed
   prints string to the buf, max of buf_length bytes are written
   does not print trailing 0 for a string (if any)
*/
static unsigned int printDecafString (decafString *str, 
                              char *buf, unsigned int buf_length)

{
    char c;
    unsigned int i, str_length;
    unsigned int waddr = (unsigned int) &(str->key);
    char *str_addr = (char *) &(str->cp);

    /* read the key and extract the length of the string from there */
    READ_WORD (waddr, 'G', str_length);
    str_length = str_length >> 16;

    for (i = 0 ; i < str_length && i < buf_length ; i++)
    {
        READ_BYTE ((unsigned int) str_addr, 'G', c);
        sprintf (buf+i, "%c", c);
        ++str_addr;
    }
    return i;
}

/* returns 1 if a trap shd be generated, 0 otherwise */

static int gc_trap (unsigned int objref, unsigned int store_data)

{
    int index = ((objref & 0xC0000000) >> 28) | 
				((store_data & 0xC0000000) >> 30);

    if (gcConfig & (1 << index))
		return (1);

    if (psr & 0x1000) /* gce on */
	{
	    int masked_region1 = ((objref & 0x1FFC0000) >> 18) & 
		                     ((gcConfig & 0xFFE00000) >> 21);
	    int masked_region2 = ((store_data & 0x1FFC0000) >> 18) & 
		                     ((gcConfig & 0xFFE00000) >> 21);

	    int masked_car1 = ((objref & 0x0003E000) >> 13) & 
		                  ((gcConfig & 0x001F0000) >> 16);
	    int masked_car2 = ((store_data & 0x0003E000) >> 13) & 
		                  ((gcConfig & 0x001F0000) >> 16);

		 if ((masked_region1 == masked_region2) &&
		     (masked_car1 != masked_car2))
		 {
			 return (1);
		 }
    }
	return (0);
}

/* setupMethodCall: sets up a call to the method pointed to by method_desc, 
including setting up the stack, and pc/optop/vars/frame/const_pool

nargs for the method_desc has to be passed by the caller. this is because
the mechanism of getting nargs is different depending on the caller - for 
some it is part of the instruction stream, for others it has to be read
from the method descriptor block ... better to let the caller do this as
it wants and pass it to us.
nargs is in bytes, not words.

if setting up method call would cause an oplim trap, this function returns
without causing any change.

*/ 

static void setupMethodCall (struct decafMethod *method_desc, 
                               unsigned int nargs)

{
    unsigned int i, nlocals, new_frame, new_vars;
    unsigned int new_optop, old_optop, new_cp, new_pc, old_pc;
    const int BUF_SIZE = 128;
    char buf[128];

    old_pc = (unsigned int) pc;

    waddr = &(method_desc->code);
    READ_WORD (waddr, 'B', new_pc);
  
    waddr = &(method_desc->nlocals);
    READ_WORD (waddr, 'B', nlocals);
    
    new_frame = (int) optop - nlocals; 
    new_vars = (int) optop + nargs;   
    old_optop = (unsigned int) optop;
    new_optop = (int) new_frame - 20;

    /* first update the optop to the new value. see if this
       causes an oplim trap. (check bAnyExceptionPending ())
       if it does cause oplim, then we know that optop will
       not have been updated. simply return from this procedure,
       at the end of the instruction, the oplim trap will be
       detected and the oplim trap frame set up with the original
       values for all the registers, as if this insn had never happened.
       this is exactly how the h/w does it */ 

    vUpdateGR (GR_optop, (unsigned int) new_optop);
    if (bAnyExceptionPending ())
        return;

    /* good, no oplim trap. revert to old optop */
    vUpdateGR (GR_optop, (unsigned int) old_optop);

    waddr = &(method_desc->methodField.constpool);
    READ_WORD (waddr, 'B', new_cp);
  
    /* Set up frame and change registers. */

    unsigned_tmp = 0;
    for (i = 0; i < (nlocals/4); i++)
    { 
        vUpdateGR (GR_optop, (unsigned int)optop - 4);
    }
  
    unsigned_tmp = (unsigned int)(pc+3);
    WRITE_WORD (OPTOP_OFFSET (0), 'O', unsigned_tmp);    

    unsigned_tmp = (unsigned int) vars;
    WRITE_WORD (OPTOP_OFFSET (-1), 'O', unsigned_tmp);

    unsigned_tmp = (unsigned int) frame;            
    WRITE_WORD (OPTOP_OFFSET (-2), 'O', unsigned_tmp);

    unsigned_tmp = (unsigned int) const_pool;        
    WRITE_WORD (OPTOP_OFFSET (-3), 'O', unsigned_tmp);

    WRITE_WORD (OPTOP_OFFSET (-4), 'O', method_desc);

    if (ias_trace >= JSR_DBG_LVL)
    {


        /* these addresses shd be of type 'G' so as not to perturb the cache */
	    printf ("TRACE(%d):invoke_*_quick at 0x%x, to method ", JSR_DBG_LVL, pc);

        getMethodNameAndSig (method_desc, buf, BUF_SIZE);
        
		printf ("%s at 0x%x\n", buf, new_pc);
	}

    const_pool = (decafCpItemType *) new_cp;
    pc = (unsigned char*) (new_pc);
    vars =  (stack_item*) (new_vars);
    frame = (stack_item*) (new_frame);
    vUpdateGR (GR_optop,(unsigned int) new_optop);

#ifdef PROFILING
    mark_block_enter (current_profile_id, NULL, FALSE, FALSE);
#endif PROFILING

#ifdef INLINE_STATS
    computeInlineStats (old_pc);
#endif INLINE_STATS
}

void reportAthrowObjectType ()

{
    char c;
#define BUF_SIZE 128
    char buf[128];

    READ_WORD (VARS_OFFSET(0), 'V', objref_tmp);
	MASK_OBJREF (objref_tmp);

    READ_WORD (objref_tmp, 'B', mv_base_addr);
	MASK_MV_PTR (mv_base_addr);

    READ_WORD (mv_base_addr-8, 'B', current_class);
	waddr = &(current_class->name);
	READ_WORD (waddr, 'B', class_name);

	printDecafString (class_name, buf, BUF_SIZE);
    buf[BUF_SIZE-1] = '\0';
    printf ("%s", buf);
}

/*__________________________ OBJECT OPS FUNCS _______________________________*/

void doLdc_quick ()

{
    index = (unsigned char) IstreamReadByte (pc+1);

    READ_WORD (CP_OFFSET (index), 'C', unsigned_tmp);
    WRITE_WORD (OPTOP_OFFSET (0), 'O', unsigned_tmp);
    SIZE_AND_STACK_RETURN (2, 1);
}

void doLdc_w_quick ()

{
    index = (unsigned short) IstreamReadShort (pc+1);

    READ_WORD (CP_OFFSET (index), 'C', unsigned_tmp);
    WRITE_WORD (OPTOP_OFFSET (0), 'O', unsigned_tmp);
    SIZE_AND_STACK_RETURN (3, 1);
}

void doLdc2_w_quick ()

{
    index = (unsigned short) IstreamReadShort (pc+1);

    READ_DWORD (CP_OFFSET (index+1), 'C', double_tmp);
    WRITE_DWORD (OPTOP_OFFSET (0), 'O', double_tmp);
    SIZE_AND_STACK_RETURN (3, 2);
}

void doGetstatic_quick() 

{
    index = (unsigned short) IstreamReadShort (pc+1);
    READ_WORD (CP_OFFSET (index), 'C', fb);

    waddr = &(fb->object);
    READ_WORD (waddr, 'B', unsigned_tmp);
    WRITE_WORD (OPTOP_OFFSET (0), 'O', unsigned_tmp);
 
    SIZE_AND_STACK_RETURN(3, 1);
}


void doPutstatic_quick() 

{
    index = (unsigned short) IstreamReadShort (pc+1);
    READ_WORD (CP_OFFSET (index), 'C', fb);

    waddr = &(fb->object);
    READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
    WRITE_WORD (waddr, 'B', unsigned_tmp);
 
    SIZE_AND_STACK_RETURN(3, -1);
        
}

void doAPutstatic_quick() 

{
    unsigned int fb_ptr;

    index = (unsigned short) IstreamReadShort (pc+1);
    READ_WORD (CP_OFFSET (index), 'C', fb_ptr);
    
    READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

    if (gc_trap (fb_ptr, unsigned_tmp))
	{
		LOW_PRIORITY_TRAP (gc_notify);
		return;
    }
	  
    MASK_OBJREF (fb_ptr); /* do same masking on field block as for normal objrefs */

	fb = (decafField *) fb_ptr;

    waddr = &(fb->object);
    WRITE_WORD (waddr, 'B', unsigned_tmp);
 
    SIZE_AND_STACK_RETURN(3, -1);
}

void doGetstatic2_quick() 

{
    index = (unsigned short) IstreamReadShort (pc+1);
    READ_WORD (CP_OFFSET (index), 'C', unsigned_tmp);
	unsigned_tmp &= 0xFFFFFFFE; /* reset lsb, used by traps */

    READ_DWORD (unsigned_tmp+4, 'B', double_tmp);
    WRITE_DWORD (OPTOP_OFFSET (0), 'O', double_tmp);

    SIZE_AND_STACK_RETURN(3, 2);
}

void doPutstatic2_quick()

{
    index = (unsigned short) IstreamReadShort (pc+1);
    READ_WORD (CP_OFFSET (index), 'C', unsigned_tmp);
	unsigned_tmp &= 0xFFFFFFFE; /* reset lsb, used by traps */

    READ_DWORD (OPTOP_OFFSET (2), 'O', double_tmp);
    WRITE_DWORD (unsigned_tmp+4, 'B', double_tmp);

    SIZE_AND_STACK_RETURN(3, -2);
}

void doGetfield_quick () 

{
    offset = (unsigned char) IstreamReadByte (pc+1);
    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    if (IS_HANDLE (objref_tmp))
    {
		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp + 4, 'H', objref_tmp);
    }
    else
	{
		MASK_OBJREF (objref_tmp);
        objref_tmp += 4;
    }

    waddr = (void *) (objref_tmp + (offset * 4));  /* Get instance var value */

    READ_WORD (waddr, 'B', unsigned_tmp);
    WRITE_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

    SIZE_AND_STACK_RETURN (3, 0);
}

void doAGetfield_quick () 

{
    offset = (unsigned short) IstreamReadShort (pc+1);
    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    if (IS_HANDLE (objref_tmp))
    {
		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp + 4, 'H', objref_tmp);
    }
    else
	{
		MASK_OBJREF (objref_tmp);
        objref_tmp += 4;
    }

    waddr = (void *) (objref_tmp + (offset * 4));  /* Get instance var value */

    READ_WORD (waddr, 'B', unsigned_tmp);
    WRITE_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

    SIZE_AND_STACK_RETURN (3, 0);
}

void doGetfield2_quick () 

{
    offset = (unsigned char) IstreamReadByte (pc+1);

    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    if (IS_HANDLE (objref_tmp))
    {
		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp + 4, 'H', objref_tmp);
    }
    else
	{
		MASK_OBJREF (objref_tmp);
        objref_tmp += 4;
    }

    waddr = (void *) (objref_tmp + (offset * 4) + 4);

    READ_DWORD (waddr, 'B', double_tmp);
    WRITE_DWORD (OPTOP_OFFSET (1), 'O', double_tmp); 
  
    SIZE_AND_STACK_RETURN (3, 1);
}

void doAPutfield_quick () 

{
    offset = (unsigned short) IstreamReadShort (pc+1);

    READ_WORD (OPTOP_OFFSET (2), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

	if (gc_trap (objref_tmp, unsigned_tmp))
	{
		LOW_PRIORITY_TRAP (gc_notify);
		return;
    }

    if (IS_HANDLE (objref_tmp))
    {
		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp + 4, 'H', objref_tmp);
    }
    else
	{
		MASK_OBJREF (objref_tmp);
        objref_tmp += 4;
    }

    waddr = (void *) (objref_tmp + (offset * 4));

    WRITE_WORD (waddr, 'B', unsigned_tmp);

    SIZE_AND_STACK_RETURN (3, -2);
}

void doPutfield_quick () 

{
    offset = (unsigned char) IstreamReadByte (pc+1);

    READ_WORD (OPTOP_OFFSET (2), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    if (IS_HANDLE (objref_tmp))
    {
		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp + 4, 'H', objref_tmp);
    }
    else
	{
		MASK_OBJREF (objref_tmp);
        objref_tmp += 4;
    }

    waddr = (void *) (objref_tmp + (offset * 4));

    READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
    WRITE_WORD (waddr, 'B', unsigned_tmp);

    SIZE_AND_STACK_RETURN (3, -2);
}

void doPutfield2_quick () 

{
    offset = (unsigned char) IstreamReadByte (pc+1);

    READ_WORD (OPTOP_OFFSET (3), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    if (IS_HANDLE (objref_tmp))
    {
		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp + 4, 'H', objref_tmp);
    }
    else
	{
		MASK_OBJREF (objref_tmp);
        objref_tmp += 4;
    }

    waddr = (void *) (objref_tmp + (offset*4) + 4);

    READ_DWORD (OPTOP_OFFSET (2), 'O', double_tmp);
    WRITE_DWORD (waddr, 'B', double_tmp);

    SIZE_AND_STACK_RETURN (3, -3);
}

void doInvokevirtual_quick()

{
    index = (unsigned char) IstreamReadByte (pc+1);
    nargs = (unsigned char) IstreamReadByte (pc+2);

    /* the following cannot be an 'O' type access since it's not necessary
       that it will hit in the S$. an 'O' type access must always hit in the
       S$ */

    READ_WORD (OPTOP_OFFSET (nargs), 'V', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

	MASK_OBJREF (objref_tmp);
    READ_WORD (objref_tmp, 'B', mv_base_addr);
	MASK_MV_PTR (mv_base_addr);
    READ_WORD (mv_base_addr + index * 4, 'B', method_desc);

    setupMethodCall (method_desc, nargs * 4);
}


void doInvokevirtual_quick_w ()

{
    unsigned int method_index;

    index = (unsigned short) IstreamReadShort (pc+1);

	/* the nargs argument in the method desc table contains
	   a pointer to a method descriptor */
    READ_WORD (CP_OFFSET (index), 'C', method_desc);
	waddr = &(method_desc->argsSize);
	READ_WORD (waddr, 'B', nargs);

    method_index = (nargs & 0xFFFF0000) >> 16;
    nargs &= 0xFFFF;
	nargs >>= 2;  /* convert from bytes to words */

    /* the following cannot be an 'O' type access since it's not necessary
       that it will hit in the S$. 'O' type access must always hit in the
       S$ */

    READ_WORD (OPTOP_OFFSET (nargs), 'V', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

	MASK_OBJREF (objref_tmp);
    READ_WORD (objref_tmp, 'B', mv_base_addr);
	MASK_MV_PTR (mv_base_addr);
    READ_WORD (mv_base_addr + method_index * 4, 'B', method_desc);

    setupMethodCall (method_desc, nargs*4);
}

void doInvokenonvirtual_quick() 

{
    index = (unsigned short) IstreamReadShort (pc+1);
 
    READ_WORD (CP_OFFSET (index), 'C', method_desc);
    waddr = &(((decafMethod *)method_desc)->argsSize);
    READ_WORD (waddr, 'B', nargs);
	nargs &= 0xFFFF; /* mask off higher 16b since it's used for MVT index */
	nargs >>= 2; /* convert to words from bytes */
 
    /* the following cannot be an 'O' type access since it's not necessary
       that it will hit in the S$. an 'O' type access must always hit in the
       S$ */

    READ_WORD (OPTOP_OFFSET (nargs), 'V', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    setupMethodCall (method_desc, nargs*4);
}

void doInvokesuper_quick()

{
    index = (unsigned short) IstreamReadShort (pc+1);

    /* get addr of current method. desc and then chase up the pointers */
    waddr = (void *) (((unsigned int) frame) - 16);  
    READ_WORD (waddr, 'V', method_desc);
  
    waddr = &(method_desc->methodField.class);
    READ_WORD (waddr, 'B', current_class);
#if 1 /* MRM Added, Java object to C conversion */
    current_class = (decafClass *)((int)current_class + 4);
#endif
    
    waddr = &(current_class->superClass);
    READ_WORD (waddr, 'B', super_class);
#if 1 /* MRM Added, Java object to C conversion */
    super_class = (decafClass *)((int)super_class + 4);
#endif
  
    waddr = &(super_class->objHintBlk);
    READ_WORD (waddr, 'B', objhint);
  
#if 1 /* MRM Added, point to the beginning of the Method table */
    objhint = (decafObjectHint *)((int)objhint + 8);
#endif

#if 1  /* MRM - Change due to decafObjectHint structure change */
    waddr = &(objhint->methods);
#else
    waddr = &(objhint->instMethods[0]);
#endif

    /* waddr is the starting of the MVT array, 
       use index to go deeper into it */

    waddr = (void *) ((unsigned int) waddr + (index << 2));
    READ_WORD (waddr, 'B', method_desc);
  
    waddr = &(method_desc->argsSize); /* Get nargs */
    READ_WORD (waddr, 'B', nargs);
	nargs &= 0xFFFF; /* mask off higher 16b since it's used for MVT index */
	nargs >>= 2;    /* convert to words from bytes */

    /* the following cannot be an 'O' type access since it's not necessary
       that it will hit in the S$. an 'O' type access must always hit in the
       S$ */

    READ_WORD (OPTOP_OFFSET (nargs), 'V', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    setupMethodCall (method_desc, nargs*4);
}

void doInvokestatic_quick() 

{
    index = (unsigned short) IstreamReadShort (pc+1);
    
    READ_WORD (CP_OFFSET (index), 'C', method_desc);
    waddr = &(method_desc->argsSize);
    READ_WORD (waddr, 'M', nargs);
	nargs &= 0xFFFF;  /* mask off higher 16b */
 
    setupMethodCall (method_desc, nargs);
}

void doTableSwitch ()

{
    /* note that all data accesses go as type 'Z' accesses since if they cause an
       exception, we want to take a data access error not an insn access error */

    /* all signed int's */
    int index, offset, LowIndex, HighIndex, DefaultOffset; 
    unsigned int aligned_pc;

    aligned_pc = (unsigned int) (NEXT_ALIGNED_WORD (pc));

    READ_WORD ((unsigned char *) aligned_pc, 'Z', DefaultOffset);
    READ_WORD ((unsigned char *) (aligned_pc + 4), 'Z', LowIndex);
    READ_WORD ((unsigned char *) (aligned_pc + 8), 'Z', HighIndex);

    if (LowIndex > HighIndex)
    {
        printf ("pjsim Warning: tableswitch at 0x%x, low index > high index\n",        (unsigned int) pc);
    }

    READ_WORD (OPTOP_OFFSET (1), 'O', index);

    if ((index < LowIndex) || (index > HighIndex))
        offset = DefaultOffset;
    else
        READ_WORD ((unsigned char *) aligned_pc + 12 + ((index - LowIndex) * 4), 'Z', offset);

    pc += offset;

    SIZE_AND_STACK_RETURN (0, -1);
}

void doCheckCast_quick ()

{
    decafClass *other_class;

    index = (unsigned short) IstreamReadShort (pc+1);
    checkcast_quick_insns = ll_add(checkcast_quick_insns, 1LL);

    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    /* processing is same, whether or not handles are used */

    if (!IS_NULL_OBJREF (objref_tmp))
    {
        READ_WORD (CP_OFFSET (index), 'C', other_class);

		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp, 'B', mv_base_addr);

	    MASK_MV_PTR (mv_base_addr);
        READ_WORD (mv_base_addr-8, 'B', current_class);

        if (other_class == current_class)
            SIZE_AND_STACK_RETURN (3, 0)
        else
		{
            LOW_PRIORITY_TRAP (opc_checkcast_quick); 
            checkcast_quick_traps = ll_add(checkcast_quick_traps, 1LL);
			return;
        }
    }
    else
        SIZE_AND_STACK_RETURN (3, 0);
}

void doInstanceOf_quick ()

{
    decafClass *other_class;
    int one = 1, zero = 0; /* for writing 1/0 onto the stack if reqd */

    instanceof_quick_insns = ll_add(instanceof_quick_insns, 1LL);
    index = (unsigned short) IstreamReadShort (pc+1);

    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    /* processing is same, whether or not handles are used */

    if (!IS_NULL_OBJREF (objref_tmp))
    {
        READ_WORD (CP_OFFSET (index), 'C', other_class);

		MASK_OBJREF (objref_tmp);
        READ_WORD (objref_tmp, 'B', mv_base_addr);

	    MASK_MV_PTR (mv_base_addr);
        READ_WORD (mv_base_addr-8, 'B', current_class);

        if (other_class == current_class)
        {
            WRITE_WORD (OPTOP_OFFSET (1), 'O', one);
            SIZE_AND_STACK_RETURN (3, 0);
        }
        else
		{
            LOW_PRIORITY_TRAP (opc_instanceof_quick); 
            instanceof_quick_traps = ll_add(instanceof_quick_traps, 1LL);
			return;
        }
    }
    else
    {
        WRITE_WORD (OPTOP_OFFSET (1), 'O', zero);
        SIZE_AND_STACK_RETURN (3, 0);
    }
}


void doNonnull_quick ()

{ 
    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    SIZE_AND_STACK_RETURN (1, -1);
}

void doMonitorEnter ()

{
    unsigned int i, j;
    unsigned int lock_hit = 0, take_lock_count_overflow_trap = 0;

    monitorenter_insns = ll_add(monitorenter_insns, 1LL);
    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

	MASK_OBJREF (objref_tmp);

    for (i = 0 ; i < 2 ; i++)
    {
		int k = lockAddr[i];
		MASK_OBJREF (k);

        if (k == objref_tmp)
        {
            lock_hit = 1;
            j = (lockCount[i] & 0xff) + 1;
            lockCount[i] = (lockCount[i] & 0xFFFFFF00) | (j & 0xff);
     
            lock_enter_hits[i] = ll_add(lock_enter_hits[i], 1LL);

            if ((lockCount[i] & 0xff) == 0)
                take_lock_count_overflow_trap = 1;
        }
    }

    if (flag_fast_monitors && !lock_hit)
    {   
        int locked;
            /* look for an empty lock reg and replace in h/w */
        for (i = 0 ; i < 2 ; i++)
            if (lockAddr[i] == 0) 
                break;

        if (i < 2)
        {
            /* lock flag for obj stored in lsb of MVT */
            READ_WORD (objref_tmp, 'B', locked);
            if (!(locked & 1)) /* if obj not already locked */
            {
                lock_hit = 1;
                lockAddr[i] = objref_tmp;
                lockCount[i] = 0x8001; /* set bit 15 to 1 */
                fast_monitors_saved_the_day = 
                ll_add(fast_monitors_saved_the_day, 1LL);
            }
        }
    }
         
    if (take_lock_count_overflow_trap)
    {
        LOW_PRIORITY_TRAP (lock_count_overflow_trap);
        monitorenter_overflows = ll_add(monitorenter_overflows, 1LL);
        return;
    }
    else if (!lock_hit)
    {
        monitorenter_misses = ll_add(monitorenter_misses, 1LL);
        LOW_PRIORITY_TRAP (lock_enter_miss_trap);
		return;
    }
    else
    {
        SIZE_AND_STACK_RETURN (1, -1); /* only regular exit pt */
    }
}

void doAastore_quick ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;

    READ_WORD (OPTOP_OFFSET (3), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    MASK_ARRAYREF (arrayRef); 
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);

    READ_WORD (OPTOP_OFFSET (2), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (OPTOP_OFFSET(1), 'O', tmp); 

    if (gc_trap (arrayRef, tmp))
    {
	LOW_PRIORITY_TRAP (gc_notify);
	return;
    }

    WRITE_WORD (arrayStorage + (index+1)*4, 'M', tmp);

    SIZE_AND_STACK_RETURN (1, -3);
}

void doMonitorExit ()

{
    unsigned int i, j;
    unsigned int lock_hit = 0, take_lock_count_overflow_trap = 0, take_lock_release_trap = 0;

    monitorexit_insns = ll_add(monitorexit_insns, 1LL);
    READ_WORD (OPTOP_OFFSET (1), 'O', objref_tmp);

    TRAP_IF_OBJREF_NULL (objref_tmp);

    MASK_OBJREF (objref_tmp);

    for (i = 0 ; i < 2 ; i++)
    {
		int k = lockAddr[i];
		MASK_OBJREF (k);

        if (k == objref_tmp)
        {
            lock_hit = 1;

            j = (lockCount[i] & 0xff) - 1;
            lockCount[i] = (lockCount[i] & 0xFFFFFF00) | (j & 0xff);

            lock_exit_hits[i] = ll_add(lock_exit_hits[i], 1LL);

            if (((lockCount[i] & 0xff) == 0) && (lockCount[i] & 0x4000))
                take_lock_release_trap = 1;
            if (flag_fast_monitors &&
                ((lockCount[i] & 0xff) == 0) && (!(lockCount[i] & 0x4000))
                                             && (lockCount[i] & 0x8000))
            {
                lockAddr[i] = 0;
                lockCount[i] = 0;
            }
            else if ((lockCount[i] & 0xff) == 0xff)
                take_lock_count_overflow_trap = 1;
        }
    }

    if (take_lock_count_overflow_trap)
    {
        monitorexit_overflows = ll_add(monitorexit_overflows, 1LL);
        LOW_PRIORITY_TRAP (lock_count_overflow_trap);
        return;
    }
    else if (take_lock_release_trap)
	{
        monitorexit_releases = ll_add(monitorexit_releases, 1LL);
        LOW_PRIORITY_TRAP (lock_release_trap);
        return;
    }
    else if (!lock_hit)
    {
        monitorexit_misses = ll_add(monitorexit_misses, 1LL);
        LOW_PRIORITY_TRAP (lock_exit_miss_trap);
        return;
    }
    else
    {
        SIZE_AND_STACK_RETURN (1, -1); /* only regular exit pt */
    }
}

void doGetCurrentClass ()

{
    /* get addr of current method. desc and then get the current class */
    waddr = (void *) (((unsigned int) frame) - 16);  
    READ_WORD (waddr, 'V', method_desc);
  
    waddr = &(method_desc->methodField.class);
    READ_WORD (waddr, 'B', current_class);
  
    WRITE_WORD (OPTOP_OFFSET (0), 'O', current_class);
    SIZE_AND_STACK_RETURN (2, 1);
}


#ifdef INLINE_STATS

/** computes inlining stats, by examining the body of the
method at the current PC. shd be called just after a method
is invoked, but before any insn in it has started executing.
old_pc shd be the pc of the insn which caused this invoke
to happen.
there are currently 8 types of target functions we identify
*/

static void computeInlineStats (unsigned char *old_pc)

{
    unsigned char *target_pc = (unsigned char *) getAbsAddr (pc);
    unsigned char invoke_insn = *(unsigned char *) getAbsAddr (old_pc);
    int64_t *invoker;

    switch (invoke_insn)
    {
      case opc_invokevirtual_quick:
        invoker = &(inlineStats[INV_iv_q][0]);
        break;
      case opc_invokenonvirtual_quick:
        invoker = &(inlineStats[INV_inv_q][0]);
        break;
      case opc_invokestatic_quick:
        invoker = &(inlineStats[INV_is_q][0]);
        break;
      case opc_invokesuper_quick:
        invoker = &(inlineStats[INV_isuper_q][0]);
        break;
      case opc_invokevirtual_quick_w:
        invoker = &(inlineStats[INV_iv_q_w][0]);
        break;
      default:
        fprintf (stderr, 
    "Amazing! performing an invoke without an invoke_*_quick instruction, opcode = 0x%x!...\n", invoke_insn);
        fprintf (stderr, "Internal error, aborting!!");
        exit (1);
    }

#define ll_incr(a) (a) = ll_add((a), 1LL)
    if ((*target_pc == opc_aload_0) &&
        ((*(target_pc+4) == opc_return) ||
         (*(target_pc+4) == opc_ireturn) ||
         (*(target_pc+4) == opc_areturn) ||
         (*(target_pc+4) == opc_freturn) ||
         (*(target_pc+4) == opc_lreturn) ||
         (*(target_pc+4) == opc_dreturn)))
    {
        switch (*(target_pc+1))
        {
          case opc_invokevirtual_quick:
            ll_incr(invoker[INLINE_iv_q]);
            break;
          case opc_invokenonvirtual_quick:
            ll_incr(invoker[INLINE_inv_q]);
            break;
          case opc_getfield_quick:
          case opc_getfield2_quick:
            ll_incr(invoker[INLINE_getf_q]);
            break;
        }
        return;
    }
    else
    if ((*target_pc == opc_aload_0) &&

        ((*(target_pc+1) == opc_aload_1) ||
         (*(target_pc+1) == opc_iload_1) ||
         (*(target_pc+1) == opc_fload_1) ||
         (*(target_pc+1) == opc_dload_1) ||
         (*(target_pc+1) == opc_lload_1)) &&

        ((*(target_pc+2) == opc_putfield_quick) ||
         (*(target_pc+2) == opc_putfield2_quick)) &&
/* no putfield_q_w here because it is a trap */

        ((*(target_pc+5) == opc_return) ||
         (*(target_pc+5) == opc_ireturn) ||
         (*(target_pc+5) == opc_areturn) ||
         (*(target_pc+5) == opc_freturn) ||
         (*(target_pc+5) == opc_lreturn) ||
         (*(target_pc+5) == opc_dreturn)))
    {
         ll_incr(invoker[INLINE_putf_q]);
    }

    else if ((*(target_pc+3) == opc_return) ||
         (*(target_pc+3) == opc_ireturn) ||
         (*(target_pc+3) == opc_areturn) ||
         (*(target_pc+3) == opc_freturn) ||
         (*(target_pc+3) == opc_lreturn) ||
         (*(target_pc+3) == opc_dreturn))
    {
        switch (*target_pc)
        {
          case opc_getstatic_quick:
          case opc_getstatic2_quick:
            ll_incr(invoker[INLINE_gets_q]);
            break;

          case opc_invokestatic_quick:
            ll_incr(invoker[INLINE_is_q]);
            break;
        }
    }
    else 
    if (((*(target_pc) == opc_aload_0) ||
         (*(target_pc) == opc_iload_0) ||
         (*(target_pc) == opc_fload_0) ||
         (*(target_pc) == opc_dload_0) ||
         (*(target_pc) == opc_lload_0)) &&

        ((*(target_pc+1) == opc_putstatic_quick) ||
         (*(target_pc+1) == opc_putstatic2_quick)) &&

        ((*(target_pc+4) == opc_return) ||
         (*(target_pc+4) == opc_ireturn) ||
         (*(target_pc+4) == opc_areturn) ||
         (*(target_pc+4) == opc_freturn) ||
         (*(target_pc+4) == opc_lreturn) ||
         (*(target_pc+4) == opc_dreturn)))
    {
        ll_incr(invoker[INLINE_puts_q]);
    }

    else if (*target_pc == opc_return)
        ll_incr(invoker[INLINE_return]);
}
#endif /* INLINE_STATS */
