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
 *****************************************************************/




static char *sccsid = "@(#)javamem.c 1.14 Last modified 02/28/99 12:03:59 SMI";

#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
 
#include    "dsv.h"
#include    "decaf.h"
#include    "cm.h"
#include    "sim_config.h"
#include    "cache.h"
#include    "traps.h"
#include    "object_ops.h"
#include    "iam.h"
#include    "typedefs.h"
#include    "jmath.h"
#include    "dprint.h"
#include    "scache.h"
#include    "global_regs.h"
#include    "exception.h"
#include    "tracing.h"
#include    "breakpoints.h"
#include    "javamem.h"

#define pj_type_c_ifetch           0
#define pj_type_nc_ifetch          2
#define pj_type_iu_c_load          4
#define pj_type_iu_writeback       5
#define pj_type_iu_nc_load         6
#define pj_type_iu_nc_store        7
#define pj_type_dribbler_c_load    0xc
#define pj_type_dribbler_writeback 0xd
#define pj_type_dribbler_nc_load   0xe
#define pj_type_dribbler_nc_store  0xf

/**** LOCAL MACROS, visible to this file only *****/

/* if any of the exception flags is raised, do nothing and return
   immediately */
#define RETURN_IF_EXCEPTIONS_PENDING { if (bAnyExceptionPending ()) {\
printf ("pjsim warning: ignoring memory operation due to pending exception\n"); return;} }

/* CHECK_EXCEPTION: performs the function passed as the first argument, and
if it returns fail, sets up an exception of type 'exception'. used basically
for bad memory read/writes */

#define CHECK_EXCEPTION(function, exception) { \
if (function == DSV_FAIL) { printf ("pjsim: Taking an exception\n"); vSetupException (exception); } }

/* CHECK_EXCEPTION_IF_AEM_OFF is exactly the same as CHECK_EXCEPTION except
that it ensures that the PSR.AEM bit is 0. if the bit is 1, the function
is simply done without checking for exceptions. used only for suppressing
NMI's on data stores which return error acks */

#define CHECK_EXCEPTION_IF_AEM_OFF(function, exception) {    \
if (psr & 0x100) { function; } else                          \
if (function == DSV_FAIL)                                    \
{ printf ("pjsim: Taking an exception\n");            \
  vSetupException (exception); } }

/************************************************************************/

/* return 1 if an access with the given address and access type 
causes a mem_protection_error, 0 if not */

int causes_mem_prot_error (unsigned int address, char acc_type)

{
    address &= 0x3FFFFFFF;                      

    if (!(psr & 0x2000))   /* return if ace off */
       return 0;

	if (((address < ((userrange1 & 0x0000FFFF) << 14 ))  ||              
	     (address >= ((userrange1 & 0xFFFF0000) >> 2))) &&              
	    ((address < ((userrange2 & 0x0000FFFF) << 14 ))  ||            
	     (address >= ((userrange2 & 0xFFFF0000) >> 2))))              
    {                                                                     
        /* addr out of range */
        /* if maya and psr.cac access type doesn't matter */
        if (((proc_type != pico) && (psr & 0x400000)) || 
            (acc_type == 'A') ||
            (acc_type == 'N') ||
            (acc_type == 'Z'))
        {
            return 1;
        }        
    }
    return 0;
}

/* javaMemRead puts the 32b word present in address addr into the word
   pointed to by pData (which must be word-aligned).
   addr is actually a byte address, but javaMemRead always returns
   a word, aligned at the word address which covers the byte address.
   the precise address and the size are required only for implementing
   data breakpoints.
*/

void javaMemRead (unsigned int addr, unsigned int *pData,
                  unsigned int size, char c)

{
    int trap_frame_access = 0;
    int full_addr = addr;
    int brkpt_id;

    /* addr is the word aligned version of full_addr */
    addr &= 0xFFFFFFFC;
    
    if (addr & 0xC0000000) 
    {
        WARN (("address received by javaMemRead without \
2 msb's reset: 0x%08x\n", addr));
    }

    DPRINTF (MEM_DBG_LVL, ("Java mem read at 0x%x, type '%c' ... ", full_addr, c));

#ifdef TRACING
{
    mem_trace_record_t mem_trace_record;

    mem_trace_record.addr = addr;
    mem_trace_record.rnotw = 1;
    mem_trace_record.size = 2;
    mem_trace_record.tag = c;
    if (p_pjsim_trace_emit_mem_record)
        (*p_pjsim_trace_emit_mem_record) (mem_trace_record);
}
#endif /* TRACING */

#ifdef SIM_BREAKPOINTS 
    if ((c != 'G') && ((brkpt_id = brkpt_match (full_addr, size, BRKPT_READ)) != -1))
    { 
        BRKPT_PRINTF (("Data read breakpoint# %d hit at PC 0x%x\n", brkpt_id, (unsigned int) pc));
        flag_sim_read_brkpt_pending = 1;
    }
#endif /* SIM_BREAKPOINTS */

    /* c has been overloaded, unload it a bit first */
    if (c == 'T') 
    {
        c = 'O'; /* it was originally an 'O' access */
        trap_frame_access = 1;
    }

    /* check if a vars access is to an address <= optop - if so,
       print a warning */
    if (((c == 'V') || (c == 'F')) && (addr <= (unsigned int) optop))
    {
        WARN (("vars read to an address <= optop, pc = 0x%x, vars = 0x%x, address read = 0x%x, optop = 0x%x\n", (unsigned int) pc, (unsigned int) vars, addr, (unsigned int) optop));
    }

    /* if stack access - optop/vars/frame offset - look in S$ first */

    /* only for reads - c = G implies a debug read, and also goes thru S$ */

    if (ias_scache && 
        ((c == 'O' || c == 'V' || c == 'F') || (c == 'G')))
    {
        /* warning here (not assert) because debug accesses not be aligned */
        if ((addr & 3) != 0)
        {
            WARN (("stack access to 0x%x is not word-aligned, converting to 0x%x\n", addr, addr & 0xFFFFFFFC));
        }

        /* S$ hit is if the address is in the interval
           [scbottom, scbottom-64)
         */
        if ((addr <= (unsigned int) scBottom) && 
            (addr > (unsigned int) scBottom - 64 * JAVAWORDSIZE))

        {   /* S$ hit */
            DPRINTF (MEM_DBG_LVL, ("S$ hit ... ")); 
            vSCacheRead ((addr >> 2) % SCACHE_SIZE, pData);
            goto returnPoint;
        }

        DPRINTF (MEM_DBG_LVL, ("S$ miss ... ")); 
        /* else S$ miss, fall thru to regular Dcache processing */
        if (c == 'O')
        {
             WARN (("attempting optop-offset read at 0x%x which is a S$ miss!\noptop = 0x%x, pc = 0x%x\n", addr, optop, pc));
         }
    }

/* memprot check before breakpoint check */
#ifdef MEM_PROTECTION_CHECK
    /* S$ miss, do a bounds check - but not for debug accesses! */
    if ((c != 'G') && causes_mem_prot_error (addr, c))
    {
         vSetupException (MEM_PROT_EXCEPTION);
         goto returnPoint;
    }
#endif /* MEM_PROTECTION_CHECK */

#ifdef PICO_BREAKPOINTS
    /* S$ miss, do a breakpoint check - but not for debug accesses! */
    if ((c != 'G') && 
        pico_breakpoint_match (1, full_addr, 1, 1))
    { 
         vSetupException (DBR1_EXCEPTION);
         goto returnPoint;
    }

    if ((c != 'G') &&
        pico_breakpoint_match (2, full_addr, 1, 1))
    { 
         vSetupException (DBR2_EXCEPTION);
         goto returnPoint;
    }
#endif

    /* check for dangerous accesses to areas near the S$ */
    if ((c != 'D') && (c != 'G') && (c != 'V') && (c != 'F') &&
        (addr > (unsigned int) optop) && 
        (addr <= (((unsigned int) optop) + SCACHE_SIZE*JAVAWORDSIZE)))
    {
        WARN (("potentially dangerous non-stack read to stack region\noptop = 0x%x, sc_bottom = 0x%x, read to 0x%x\n", (unsigned int) optop, (unsigned int) scBottom, addr))
    }

    if ((hcr.dcs != 0) && (CHK_PSR_DCE) && (c != 'N'))
    {   /* go thru Dcache */
        if (c == 'G')  /* if debug access, do non-intrusive read on D$ */
            debug_dCacheRead (addr, pData);
        else
        {
            cmSetPJType ((c == 'D') ? pj_type_dribbler_c_load 
                                    : pj_type_iu_c_load);
            if (c == 'D')
            {   /* generate async error if there is error on a dribble */
                CHECK_EXCEPTION ((dCacheRead (addr, pData)), ASYNC_EXCEPTION)
            }
            if ((addr >= BAD_IO_START) && (addr <= (BAD_IO_START + BAD_SIZE)))
            {
                CHECK_EXCEPTION ((dCacheRead (addr, pData)), IO_ACC_EXCEPTION)
            }
            else
            {
                CHECK_EXCEPTION ((dCacheRead (addr, pData)), DATA_ACC_EXCEPTION)
            }
        }
    }
    else 
    {   /* nc access, don't go thru D$ */
        cmSetPJType ((c == 'D') ? pj_type_dribbler_nc_load 
                                : pj_type_iu_nc_load);
        if ((addr >= BAD_IO_START) && (addr <= (BAD_IO_START + BAD_SIZE)))
        {
            CHECK_EXCEPTION ((cmMemoryRead (addr, pData, 2)), IO_ACC_EXCEPTION)
        }
        else
        {
            CHECK_EXCEPTION ((cmMemoryRead (addr, pData, 2)), DATA_ACC_EXCEPTION)
        }
    }

returnPoint:
    DPRINTF (MEM_DBG_LVL, ("data = 0x%x\n", *pData));
}

/* the second argument is a pointer even though it is not written
 * because we want to pass an arbitrary bit pattern worth a word for
 * the 2nd argument. if we declare the datum directly, passing a var
 * of a different type would cause a type conversion
 */
void javaMemWrite (unsigned int addr, void *pData, unsigned int size, char c)

{
    unsigned int iData; /* uint version of *pData */
    char *debug_s;
    int trap_frame_access = 0;
    int brkpt_id;

    if (addr & 0xC0000000) 
    {
        WARN (("address received by javaMemWrite \
without 2 msb's reset: 0x%08x\n", addr));
    }

    switch (size)
    {
      case 0:
        debug_s = "byte";
        iData = *(unsigned char *) pData;
        break;   
      case 1:
        debug_s = "short";
        iData = *(unsigned short *) pData;
        break;   
      case 2:
        debug_s = "word";
        iData = *(unsigned int *) pData;
        break;   
    }

    DPRINTF (MEM_DBG_LVL, ("Java mem write (%s) at 0x%x, type '%c' with data 0x%x ... ", debug_s, addr, c, iData)) 

#ifdef TRACING
{
    mem_trace_record_t mem_trace_record;

    mem_trace_record.addr = addr;
    mem_trace_record.data = iData;
    mem_trace_record.rnotw = 0;
    mem_trace_record.size = size;
    mem_trace_record.tag = c;
    if (p_pjsim_trace_emit_mem_record)
        (*p_pjsim_trace_emit_mem_record) (mem_trace_record);
}
#endif /* TRACING */

#ifdef SIM_BREAKPOINTS 
    if ((c != 'G') && ((brkpt_id = brkpt_match (addr, size, BRKPT_WRITE)) != -1))
    { 
        BRKPT_PRINTF (("Data write breakpoint# %d hit at PC 0x%x\n", brkpt_id, (unsigned int) pc));
        flag_sim_write_brkpt_pending = 1;
    }
#endif /* SIM_BREAKPOINTS */

    /* c has been overloaded, unload it a bit first */
    if (c == 'T') 
    {
        c = 'O'; /* it was originally an 'O' access */
        trap_frame_access = 1;
    }

    /* if we've met any exceptions so far, don't allow the write to happen
       but still check for further exceptions. */

    if ((!trap_frame_access) && (c != 'G'))
        if (bAnyExceptionPending ())
            goto checkMoreExceptions;

    /* check if a vars access is to an address <= optop - if so,
       print a warning */
    if (((c == 'V') || (c == 'F')) && (addr <= (unsigned int) optop))
    {
        WARN (("vars write to an address <= optop, pc = 0x%x, vars = 0x%x, address written = 0x%x, optop = 0x%x\n", (unsigned int) pc, (unsigned int) vars, addr, (unsigned int) optop));
    }


    if (ias_scache && 
        (c == 'O' || c == 'V' || c == 'F' || c == 'G'))
    {
        /* warning here (not assert) because debug accesses mayn't be aligned */
        if (((addr & 3) != 0) && (c != 'G'))
        {
            WARN (("stack access to 0x%x is not word-aligned, converting to 0x%x\n", addr, addr & 0xFFFFFFFC));
        }

        /* S$ hit is if the address is in the interval
           (scbottom, scbottom-64]
        */
        DPRINTF (MEM_DBG_LVL, ("addr = 0x%x optop = 0x%x scBottom = 0x%x ... ", addr, optop, scBottom));
        if ((addr <= (unsigned int) scBottom) && 
            (addr > ((unsigned int) scBottom - 64 * JAVAWORDSIZE)))
        {   /* S$ hit */
            DPRINTF (MEM_DBG_LVL, ("S$ hit\n")); 
            vSCacheWrite ((addr >> 2) % SCACHE_SIZE, &iData);
            goto returnPoint;
        }

        DPRINTF (MEM_DBG_LVL, ("S$ miss\n")); 
        /* else S$ miss, fall thru to regular Dcache processing */
        if (c == 'O')
        {
              WARN (("attempting optop-offset write at 0x%x which is a S$ miss!\noptop = 0x%x, pc = 0x%x\n", addr, optop, pc));
        }
    }

checkMoreExceptions:
#ifdef MEM_PROTECTION_CHECK
    /* S$ miss, do a bounds check - but not for debug accesses! */
    if ((c != 'G') && causes_mem_prot_error (addr, c))
    {
         vSetupException (MEM_PROT_EXCEPTION);
         goto returnPoint;
    }
#endif /* MEM_PROTECTION_CHECK */

#ifdef PICO_BREAKPOINTS
    /* not a S$ hit, do a breakpoint check, if not a debug access */
    if ((c != 'G') &&
        pico_breakpoint_match (1, addr, 1, 0))
    { 
         vSetupException (DBR1_EXCEPTION);
         goto returnPoint;
    }

    if ((c != 'G') &&
        pico_breakpoint_match (2, addr, 1, 0))
    {
         vSetupException (DBR2_EXCEPTION);
         goto returnPoint;
    }
#endif /* PICO_BREAKPOINTS */

    /* if we've met any exceptions so far, just abort the write and
       go back from here. note that a stack write was ok if there was
       an exceptions since stack addresses are not explicity checked
       for brkpts, misaligned addresses etc, but D$ writes shd not
       be allowed to happen if there is an exception pending. */

    if ((!trap_frame_access) && (c != 'G'))
        RETURN_IF_EXCEPTIONS_PENDING;

    /* check for dangerous accesses to areas near the S$ */
    if ((c != 'D') && (c != 'G') && (c != 'V') && (c != 'F') &&
        (addr > (unsigned int) optop) && 
        (addr <= (((unsigned int) optop) + SCACHE_SIZE*JAVAWORDSIZE)))
    {
        WARN (("potentially dangerous non-stack write to stack region\noptop = 0x%x, sc_bottom = 0x%x, write to 0x%x\n", (unsigned int) optop, (unsigned int) scBottom, addr))
    }

    if ((hcr.dcs != 0) && (CHK_PSR_DCE) && (c != 'N'))
    {
       switch (size)
       {
           /* no need of setting pj_type here, because that write
              is never going out on the bus, unless it is a NA write
              in which case we set the type */
           case 0: 
             CHECK_EXCEPTION_IF_AEM_OFF ((dCacheWrite (addr, *(char *) pData, size)), ASYNC_EXCEPTION)
             break;
           case 1: 
             CHECK_EXCEPTION_IF_AEM_OFF ((dCacheWrite (addr, *(short *) pData, size)), ASYNC_EXCEPTION)
             break;
           case 2: 
             if (c == 'A') 
             {
                 cmSetPJType (pj_type_iu_nc_store);
                 CHECK_EXCEPTION_IF_AEM_OFF ((dCacheNAWrite (addr, *(unsigned int *) pData, size)), ASYNC_EXCEPTION)
             }
             else
             {
                 CHECK_EXCEPTION_IF_AEM_OFF ((dCacheWrite (addr, *(unsigned int *) pData, size)), ASYNC_EXCEPTION)
             }
             break; 
       }
    }
    else 
    {
        unsigned int tmp = 0;
        switch (size)
        {
            case 0:
              ((char *) &(tmp))[addr & 3] = *(char *) pData;
              break;
            case 1:
              ((short *) &(tmp))[(addr & 2) >> 1] = *(short *) pData;
              break;
            case 2:
              tmp = *(int *) pData;
              break;
        }
        cmSetPJType ((c == 'D') ? pj_type_dribbler_nc_store
                                : pj_type_iu_nc_store);
        CHECK_EXCEPTION_IF_AEM_OFF ((cmMemoryWrite (addr, tmp, size)), ASYNC_EXCEPTION)
    }
    returnPoint: ;
}

/* weirdness with these cmread/write routines. sigh ... */

unsigned char get_new_instr(int addr)

{
    unsigned int data;
    unsigned char  *pc_ibuf;

    RETURN_IF_EXCEPTIONS_PENDING;

    if ((hcr.ics != 0) && CHK_PSR_ICE) 
    {
        cmSetPJType (pj_type_c_ifetch);
        CHECK_EXCEPTION (iCacheRead(addr, &data), INSTR_ACC_EXCEPTION);
    }   
    else
    {
        cmSetPJType (pj_type_nc_ifetch);
#if 0
        if (psr & 0x4000) /* boot8 set */
#endif
            CHECK_EXCEPTION ((cmMemoryRead (addr, &data, 0)), INSTR_ACC_EXCEPTION)
#if 0
        else
            CHECK_EXCEPTION ((cmMemoryRead (addr, &data, 2)), INSTR_ACC_EXCEPTION)
#endif
    }
    pc_ibuf = (unsigned char *) &data;
    pc_ibuf += (addr & 0x3);
    return(*pc_ibuf);
}
