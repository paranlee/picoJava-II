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




static char *sccsid = "@(#)jvm_ops.c 1.22 Last modified 10/07/98 17:50:28 SMI";

#include <stdio.h>
#include <math.h>

#include "cm.h"
#include "sim_config.h"
#include "opcodes.h"
#include "cache.h"
#include "traps.h"
#include "object_ops.h"
#include "array_ops.h"
#include "global_regs.h"
#include "jmath_md.h"
#include "iam.h"
#include "javamem.h"
#include "profiler.h"
#include "dprint.h"
#include "jvm_ops.h"

/* hint: be very careful with interpretation of signed/unsigned data, 
   esp with wide */

/* the following bit patterns are used for float/double INans
   declared as int/long long, but used as float/double 
   assuming alignment restrictions for long long and double
   will be the same */

static int INanPattern = 0x7fff0000;
static long long DINanPattern = 0x7fffe00000000000LL;

/** F/D_RESET_SIGN_IF_NAN simply check their float/double operand, and
if it is a Nan, reset the sign bit. pj Nan impl is such that a Nan
never has the sign bit set. actually can collapse these 2 macros
into one, but that would make it big-endian specific) */

#define F_RESET_SIGN_IF_NAN(f) { \
int *p = (int *) &(f); if (isnan (*(float *) p)) *p &= 0x7FFFFFFF;}

/* big endian dependence here! */
#define D_RESET_SIGN_IF_NAN(d) { \
int *p = (int *) &(d); if (isnan (*(double *) p)) *p &= 0x7FFFFFFF;}

void vDoJVMOp (unsigned char opcode)

{
    unsigned int unsigned_tmp;

    switch (opcode)
    {

/*__________________________ REGULAR OPS _______________________________*/

      case opc_nop:
        SIZE_AND_STACK_RETURN(1, 0);

        /* Load local variables with offsets up to 255 */
      case opc_aload:
      case opc_iload:
      case opc_fload: 
      {
        unsigned int offset;
        offset = (unsigned int) 
				 (wide_prefix ? (unsigned short) IstreamReadShort (pc+2): 
                                (unsigned char) IstreamReadByte (pc+1));
        COPY_STACK_ITEM (OPTOP_OFFSET (0), VARS_OFFSET (-offset), 'O', 'V')
        if (wide_prefix)
			SIZE_AND_STACK_RETURN(4, 1)
        else
			SIZE_AND_STACK_RETURN(2, 1)
		 
      }
      case opc_lload:
      case opc_dload: 
      {
        unsigned int offset;
        offset = (unsigned int) 
				 (wide_prefix ? (unsigned short) IstreamReadShort (pc+2) : 
                                (unsigned char) IstreamReadByte (pc+1));
        COPY_STACK_ITEM (OPTOP_OFFSET (0), VARS_OFFSET (-offset), 'O', 'V')
        COPY_STACK_ITEM (OPTOP_OFFSET (-1), VARS_OFFSET (-offset-1), 'O', 'V')
		if (wide_prefix) 
            SIZE_AND_STACK_RETURN(4, 2)
		else
            SIZE_AND_STACK_RETURN(2, 2)
      }

      /* specific opcodes for loading local variables with offsets 0-3 */
#define OPC_DO_LOAD_n(num)                                               \
         case opc_iload_##num:                                           \
         case opc_aload_##num:                                           \
         case opc_fload_##num:                                           \
           COPY_STACK_ITEM (OPTOP_OFFSET (0), VARS_OFFSET (-num), 'O', 'V') \
           SIZE_AND_STACK_RETURN(1, 1);                                         \
         case opc_lload_##num:                                           \
         case opc_dload_##num:                                           \
           COPY_STACK_ITEM (OPTOP_OFFSET (0), VARS_OFFSET (-num), 'O', 'V') \
           COPY_STACK_ITEM (OPTOP_OFFSET (-1), VARS_OFFSET (-num-1), 'O', 'V')\
           SIZE_AND_STACK_RETURN(1, 2);
           
 
      OPC_DO_LOAD_n(0)
      OPC_DO_LOAD_n(1)
      OPC_DO_LOAD_n(2)
      OPC_DO_LOAD_n(3)    
    
      /* Store local variables with offsets up to 255 */
      case opc_istore:
      case opc_astore:
      case opc_fstore: 
      {
        unsigned int offset;
        offset = (unsigned int) 
	             (wide_prefix ? (unsigned short) IstreamReadShort (pc+2): 
                                (unsigned char) IstreamReadByte (pc+1));
        COPY_STACK_ITEM (VARS_OFFSET (-offset), OPTOP_OFFSET(1), 'V', 'O')
        if (wide_prefix)
			SIZE_AND_STACK_RETURN(4, -1)
        else
			SIZE_AND_STACK_RETURN(2, -1)
      }

      case opc_lstore:
      case opc_dstore: 
      {
        unsigned int offset;
        offset = (unsigned int) 
				 (wide_prefix ? (unsigned short) IstreamReadShort (pc+2): 
                                (unsigned char)  IstreamReadByte (pc+1));
        COPY_STACK_ITEM (VARS_OFFSET (-offset), OPTOP_OFFSET(2), 'V', 'O')
        COPY_STACK_ITEM (VARS_OFFSET (-offset-1), OPTOP_OFFSET (1), 'V', 'O')
		if (wide_prefix)
            SIZE_AND_STACK_RETURN(4, -2)
        else
            SIZE_AND_STACK_RETURN(2, -2);
      }

     /* specific opcodes for storing local variables with offsets 0-3 */
#define OPC_DO_STORE_n(num)                            \
     case opc_istore_##num:                            \
     case opc_astore_##num:                            \
     case opc_fstore_##num:                            \
           COPY_STACK_ITEM (VARS_OFFSET (-num), OPTOP_OFFSET (1), 'V', 'O') \
           SIZE_AND_STACK_RETURN(1, -1);                      \
    case opc_lstore_##num:                             \
    case opc_dstore_##num:                             \
           COPY_STACK_ITEM (VARS_OFFSET (-num), OPTOP_OFFSET (2), 'V', 'O')   \
           COPY_STACK_ITEM (VARS_OFFSET (-num-1), OPTOP_OFFSET (1), 'V', 'O') \
           SIZE_AND_STACK_RETURN(1, -2);

      OPC_DO_STORE_n(0)
      OPC_DO_STORE_n(1)
      OPC_DO_STORE_n(2)
      OPC_DO_STORE_n(3)


       /* function returns */

      case opc_areturn:
      case opc_ireturn:
      case opc_freturn: 
      {
        stack_item *vars_tmp;
        unsigned char *oldpc;
        unsigned int optop_tmp;

        oldpc = pc;

        READ_WORD (FRAME_OFFSET (0), 'F', unsigned_tmp);
        pc = (unsigned char *) unsigned_tmp;
        DPRINTF (JSR_DBG_LVL, ("return from function at 0x%x, branching to 0x%x\n", oldpc, pc));

        READ_WORD (FRAME_OFFSET (-1), 'F', unsigned_tmp);
        vars_tmp = (stack_item *) unsigned_tmp;
        COPY_STACK_ITEM (VARS_OFFSET (0), OPTOP_OFFSET (1), 'V', 'O')
        optop_tmp = ((int) vars) - JAVAWORDSIZE;

        READ_WORD (FRAME_OFFSET (-3), 'F', unsigned_tmp);
        const_pool = (decafCpItemType *) unsigned_tmp;
        READ_WORD (FRAME_OFFSET (-2), 'F', unsigned_tmp);
        frame = (stack_item *) (unsigned_tmp);
        vUpdateGR (GR_optop, optop_tmp);
        vars = vars_tmp;
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif 
        return;
      }

      case opc_lreturn:
      case opc_dreturn: 
	  {
        stack_item *vars_tmp;
        unsigned char *oldpc;
        unsigned int optop_tmp;

        oldpc = pc;
        READ_WORD (FRAME_OFFSET (0), 'F', unsigned_tmp);
        pc = (unsigned char *) unsigned_tmp;
        DPRINTF (JSR_DBG_LVL, ("return from function at 0x%x, branching to 0x%x\n", oldpc, pc));

        READ_WORD (FRAME_OFFSET (-1), 'F', unsigned_tmp);
        vars_tmp = (stack_item *) unsigned_tmp;
        COPY_STACK_ITEM (VARS_OFFSET (0), OPTOP_OFFSET (2), 'V', 'O')
        COPY_STACK_ITEM (VARS_OFFSET (-1), OPTOP_OFFSET (1), 'V', 'O')
        optop_tmp =  ((int) vars) - 2 * JAVAWORDSIZE;
        vars = vars_tmp;

        READ_WORD (FRAME_OFFSET (-3), 'F', unsigned_tmp);
        const_pool = (decafCpItemType *) unsigned_tmp;
        READ_WORD (FRAME_OFFSET (-2), 'F', unsigned_tmp);
        frame = (stack_item *) (unsigned_tmp);
        vUpdateGR (GR_optop, optop_tmp);
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif 
        return;
      }
      
      case opc_return: 
	  {
            stack_item *vars_tmp;
            unsigned char *oldpc;
            unsigned int optop_tmp;

            oldpc = pc;
            READ_WORD (FRAME_OFFSET (0), 'F', unsigned_tmp);
            pc = (unsigned char *) unsigned_tmp;
            DPRINTF (JSR_DBG_LVL, ("return from function at 0x%x, branching to address 0x%x\n", oldpc, pc));
            READ_WORD (FRAME_OFFSET (-1), 'F', unsigned_tmp);

            vars_tmp = (stack_item *) unsigned_tmp;
            optop_tmp =  (unsigned int) vars;

            READ_WORD (FRAME_OFFSET (-3), 'F', unsigned_tmp);
            const_pool = (decafCpItemType *) unsigned_tmp;
            READ_WORD (FRAME_OFFSET (-2), 'F', unsigned_tmp);
            frame = (stack_item *) (unsigned_tmp);
            vars = vars_tmp;
            vUpdateGR (GR_optop, optop_tmp);
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif 
            return;
      }

        /* type conversions on top of stack */
      case opc_i2l:       /* Convert top of stack int to long */
      {
             int i;
             int64_t ll;
  
             READ_WORD (OPTOP_OFFSET (1), 'O', i);
             ll = int2ll(i);
             WRITE_DWORD (OPTOP_OFFSET (1), 'O', ll);
      }
      SIZE_AND_STACK_RETURN(1, 1);

      case opc_l2i:       /* convert top of stack long to int */
      {
             int i;
             int64_t ll;
  
             READ_DWORD (OPTOP_OFFSET (2), 'O', ll);
             i = ll2int(ll);
             WRITE_WORD (OPTOP_OFFSET (2), 'O', i);
      }
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_i2f:       /* Convert top of stack int to float */
      {
        int i;
        float f;
 
        TRAP_IF_FPU_OFF;
        READ_WORD (OPTOP_OFFSET (1), 'O', i);
        f = (float) i;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', f);
      }
      SIZE_AND_STACK_RETURN(1, 0);

      case opc_i2d:
      {
        int i;
        double d;
  
        TRAP_IF_FPU_OFF;
        READ_WORD (OPTOP_OFFSET (1), 'O', i);
        d = (double) i;
        WRITE_DWORD (OPTOP_OFFSET (1), 'O', d);
      }
      SIZE_AND_STACK_RETURN(1, 1);

      case opc_l2f:       /* convert top of stack long to float */
      {
        float f;
        int64_t ll;
 
        TRAP_IF_FPU_OFF;
        READ_DWORD (OPTOP_OFFSET (2), 'O', ll);
        f = ll2float(ll);
        WRITE_WORD (OPTOP_OFFSET (2), 'O', f);
      }
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_l2d:       /* convert top of stack long to double */
      {
        double d;
        int64_t ll;
  
        TRAP_IF_FPU_OFF;
        READ_DWORD (OPTOP_OFFSET (2), 'O', ll);
        d = ll2double(ll);
        WRITE_DWORD (OPTOP_OFFSET (2), 'O', d);
      }
      SIZE_AND_STACK_RETURN(1, 0);

/* f2l, d2l, f2i, d2i needed special checking if the operand was
   a Nan, since JVM requires that a Nan should get converted to a 
   0 integer, but the converters we were using (C casts and the *2ll
   functions did not support this. hence there is an explicit check
   for Nan */ 
    
      case opc_f2i:       /* Convert top of stack float to int */
      {
        int i;
        float f;
 
        TRAP_IF_FPU_OFF;
        READ_WORD (OPTOP_OFFSET (1), 'O', f);
        i = (isnan (f)) ? 0 : (int) f;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', i);
      }
      SIZE_AND_STACK_RETURN(1, 0);

      case opc_f2l:       /* convert top of stack float to long */
      {
        float f;
        int64_t ll;
 
        TRAP_IF_FPU_OFF;
        READ_WORD (OPTOP_OFFSET (1), 'O', f);
        ll = (isnan (f)) ? 0LL : float2ll(f);
        WRITE_DWORD (OPTOP_OFFSET (1), 'O', ll);
      }
      SIZE_AND_STACK_RETURN(1, 1);

      case opc_d2i:
      {
        double d;
        int i;

        TRAP_IF_FPU_OFF;
        READ_DWORD (OPTOP_OFFSET (2), 'O', d);
        i = (isnan (d)) ? 0 : (int) d;
        WRITE_WORD (OPTOP_OFFSET (2), 'O', i);
      }
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_d2l:
      {
        double d;
        int64_t ll;

        TRAP_IF_FPU_OFF;
        READ_DWORD (OPTOP_OFFSET (2), 'O', d);
        ll = (isnan (d)) ? ll = 0LL : double2ll (d);
        WRITE_DWORD (OPTOP_OFFSET (2), 'O', ll);
      }
      SIZE_AND_STACK_RETURN(1, 0);

      case opc_f2d:       /* convert top of stack float to double */
      {
        float f;
        double d;

        TRAP_IF_FPU_OFF;
        READ_WORD (OPTOP_OFFSET (1), 'O', f);
        if (isnan (f))
        {
		    long long bits22_to_0 = (*(int *)&f) & 0x007FFFFF;
  		    long long tmp = 0x7ff0000000000000LL | (bits22_to_0 << 29);

		    d = *((double *) (&tmp));
		}
	    else
		    d = (float) f;

        WRITE_DWORD (OPTOP_OFFSET (1), 'O', d);
      }
      SIZE_AND_STACK_RETURN(1, 1);

      case opc_d2f:
      {
        double d;
        float f;
  
        TRAP_IF_FPU_OFF;
        READ_DWORD (OPTOP_OFFSET (2), 'O', d);
	    f = isnan (d) ? *((float *) (&INanPattern)) : (float) d;
        WRITE_WORD (OPTOP_OFFSET (2), 'O', f);
      }
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_int2byte:
      {
        int i, j;
 
        READ_WORD (OPTOP_OFFSET (1), 'O', i);
        j = (signed char) i;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', j);
      }
      SIZE_AND_STACK_RETURN(1, 0);

      case opc_int2char:
      {
        int i, j;
 
        READ_WORD (OPTOP_OFFSET (1), 'O', i);
        j = i & 0xFFFF;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', j);
      }
      SIZE_AND_STACK_RETURN(1, 0);

      case opc_int2short:
      {
        int i, j;
        float f;

        READ_WORD (OPTOP_OFFSET (1), 'O', i);
        j = (signed short) i;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', j);
      }
      SIZE_AND_STACK_RETURN(1, 0);

      /* FP and long compares */
      case opc_fcmpl:
      case opc_fcmpg: 
	  {
        float l, r; 
        int value;

        TRAP_IF_FPU_OFF;
        READ_WORD (OPTOP_OFFSET (2), 'O', l);
        READ_WORD (OPTOP_OFFSET (1), 'O', r);
        value =   (l < r) ? -1 : (l > r) ? 1 : (l == r ) ?  0
                   /* must be a NaN */
                   : (opcode == opc_fcmpl) ? -1
                   : (opcode == opc_fcmpg) ? 1
                   : 0;
        WRITE_WORD (OPTOP_OFFSET (2), 'O', value);
      }
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_lcmp: 
	  {
        int64_t l, r; 
        int value;

        READ_DWORD (OPTOP_OFFSET (4), 'O', l);
        READ_DWORD (OPTOP_OFFSET (2), 'O', r);
        value = (ll_lt(l, r)) ? -1 : (ll_gt(l, r)) ? 1 : 0;
        WRITE_WORD (OPTOP_OFFSET (4), 'O', value);
      }
      SIZE_AND_STACK_RETURN(1, -3);

      case opc_dcmpl:
      case opc_dcmpg: 
      {
        double l, r;
        int value;

        TRAP_IF_FPU_OFF;
        READ_DWORD (OPTOP_OFFSET (4), 'O', l);
        READ_DWORD (OPTOP_OFFSET (2), 'O', r);
        value = (l < r) ? -1 : (l > r) ? 1 : (l == r ) ?  0
                /* Beyond here, must be NaN. */
                : (opcode == opc_dcmpl) ? -1
                : (opcode == opc_dcmpg) ? 1
                : 0;
        WRITE_WORD (OPTOP_OFFSET (4), 'O', value);
      }
      SIZE_AND_STACK_RETURN(1, -3);

      /* push immediate 1-byte and 2-byte operand onto stack */
      case opc_bipush:
      {
        unsigned char  opc;
        int value;
       
	    opc = get_new_instr((unsigned int) pc+1);
        value = (int) (signed char)(opc);
        WRITE_WORD (OPTOP_OFFSET (0), 'O', value);
      }
      SIZE_AND_STACK_RETURN(2, 1);

      /* Push a 2-byte signed integer constant onto the stack */
      case opc_sipush:
      {
        int value = IstreamReadShort(pc+1);

        WRITE_WORD (OPTOP_OFFSET (0), 'O', value);
      }
      SIZE_AND_STACK_RETURN(3, 1);

#define CONSTANT_OP(opcode, this_type, value)             \
      case opcode:                                        \
         { this_type tmp;                                 \
           tmp = (value);                                 \
           WRITE_WORD (OPTOP_OFFSET (0), 'O', tmp);       \
         }                                                \
         SIZE_AND_STACK_RETURN(1, 1);

         /* Push miscellaneous constants onto the stack. */
      CONSTANT_OP(opc_aconst_null, unsigned int, 0)
      CONSTANT_OP(opc_iconst_m1,   int,       -1)
      CONSTANT_OP(opc_iconst_0,    int,        0)
      CONSTANT_OP(opc_iconst_1,    int,        1)
      CONSTANT_OP(opc_iconst_2,    int,        2)
      CONSTANT_OP(opc_iconst_3,    int,        3)
      CONSTANT_OP(opc_iconst_4,    int,        4)
      CONSTANT_OP(opc_iconst_5,    int,        5)
      CONSTANT_OP(opc_fconst_0,    float,      0.0)
      CONSTANT_OP(opc_fconst_1,    float,      1.0)
      CONSTANT_OP(opc_fconst_2,    float,      2.0)

      case opc_dconst_0:
      { 
 	    double d = 0.0;

        WRITE_DWORD (OPTOP_OFFSET (0), 'O', d);
      }
      SIZE_AND_STACK_RETURN(1, 2);

      case opc_dconst_1:
      { 
	    double d = 1.0;

        WRITE_DWORD (OPTOP_OFFSET (0), 'O', d);
      }
      SIZE_AND_STACK_RETURN(1, 2);

      case opc_lconst_0:
      { 
	    int64_t ll = (int64_t) 0;

        WRITE_DWORD (OPTOP_OFFSET (0), 'O', ll);
      }
      SIZE_AND_STACK_RETURN(1, 2);

      case opc_lconst_1:
      { 
		int64_t ll = (int64_t) 1;

        WRITE_DWORD (OPTOP_OFFSET (0), 'O', ll);
      }
      SIZE_AND_STACK_RETURN(1, 2);

      /* binary integer and long operations */

#define BINARY_INT_OP(name, op, test)                      \
     case opc_i##name:                                     \
       { int i1, i2;                                       \
         READ_WORD (OPTOP_OFFSET (1), 'O', i1);            \
         if ((test) && i1 == 0)                            \
         {                                                 \
             LOW_PRIORITY_TRAP (arithmetic_excep);         \
             return;                                       \
         }                                                 \
         else                                              \
         {                                                 \
         READ_WORD (OPTOP_OFFSET (2), 'O', i2);            \
         i2 = i2 op i1;                                    \
         WRITE_WORD (OPTOP_OFFSET (2), 'O', i2);           \
         }                                                 \
       }                                                   \
         SIZE_AND_STACK_RETURN(1, -1);                     \
     case opc_l##name:                                     \
       { int64_t ll1, ll2;                                 \
         READ_DWORD (OPTOP_OFFSET (2), 'O', ll1);          \
         if ((opc_l##name == opc_lrem) ||                  \
             (opc_l##name == opc_ldiv) ||                  \
             (opc_l##name == opc_lmul))                    \
         {                                                 \
             LOW_PRIORITY_TRAP (opc_l##name);              \
             return;                                       \
         }                                                 \
         if ((test) && ll_eqz(ll1))                        \
         {                                                 \
             LOW_PRIORITY_TRAP (arithmetic_excep);         \
             return;                                       \
         }                                                 \
         else                                              \
         {                                                 \
         READ_DWORD (OPTOP_OFFSET (4), 'O', ll2);          \
         ll2 = ll_##name(ll2, ll1);                        \
         WRITE_DWORD (OPTOP_OFFSET (4), 'O', ll2);         \
         }                                                 \
       }                                                   \
       SIZE_AND_STACK_RETURN(1, -2);          
 
#if 0
/* ?? - when will emulation traps be available  ?? */
/*  put this code after case opc_l##name:
   when emulation traps for these are available  */
#endif

     /* various binary integer operations */
     BINARY_INT_OP(add, +, 0)
     BINARY_INT_OP(sub, -, 0)
     BINARY_INT_OP(mul, *, 0)
     BINARY_INT_OP(and, &, 0)
     BINARY_INT_OP(or,  |, 0)
     BINARY_INT_OP(xor, ^, 0)
     BINARY_INT_OP(div, /, 1)
     BINARY_INT_OP(rem, %, 1)

/* binary integer and long shift operations */

#define BINARY_SHIFT_OP(name, op)                          \
     case opc_i##name:                                     \
       { int i1, i2;                                       \
         READ_WORD (OPTOP_OFFSET (1), 'O', i1);            \
         READ_WORD (OPTOP_OFFSET (2), 'O', i2);            \
         i2 = i2 op (i1 & 0x1F);                           \
         WRITE_WORD (OPTOP_OFFSET (2), 'O', i2);           \
       }                                                   \
       SIZE_AND_STACK_RETURN(1, -1);                       \
     case opc_l##name:                                     \
       { int i1;                                           \
         int64_t ll;                                       \
         READ_WORD (OPTOP_OFFSET (1), 'O', i1);            \
         READ_DWORD (OPTOP_OFFSET (3), 'O', ll);           \
         ll = (int64_t) ll_##name(ll, i1 & 0x3F);          \
         WRITE_DWORD (OPTOP_OFFSET (3), 'O', ll);          \
       }                                                   \
       SIZE_AND_STACK_RETURN(1, -1);                       \

     BINARY_SHIFT_OP(shl, <<)
     BINARY_SHIFT_OP(shr, >>)

/* arithmetic shift for int and long, other misc. operations */
      case opc_iushr:
      { 
		int i1, i2;                                      

        READ_WORD (OPTOP_OFFSET (1), 'O', i1);           
        READ_WORD (OPTOP_OFFSET (2), 'O', i2);           
        i2 = ((unsigned int)i2) >> (i1 & 0x1F);          
        WRITE_WORD (OPTOP_OFFSET (2), 'O', i2);          
      }      
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_lushr:
      { 
		int i1;                                  
        int64_t ll;                           

        READ_WORD (OPTOP_OFFSET (1), 'O', i1);
        READ_DWORD (OPTOP_OFFSET (3), 'O', ll);
        ll = ll_ushr (ll, (i1 & 0x3F));
        WRITE_DWORD (OPTOP_OFFSET (3), 'O', ll);
      }                                        
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_ineg:
      { 
		int i1;            

        READ_WORD (OPTOP_OFFSET (1), 'O', i1);           
        i1 = -i1;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', i1);          
      }      
      SIZE_AND_STACK_RETURN(1, 0);
 
      case opc_lneg:
      { 
		int i1;            
        int64_t ll;

        READ_DWORD (OPTOP_OFFSET (2), 'O', ll);           
        ll = ll_neg (ll);
        WRITE_DWORD (OPTOP_OFFSET (2), 'O', ll);          
      }      
      SIZE_AND_STACK_RETURN(1, 0);

      /* Add a single byte signed constant to a local variable */
      case opc_iinc:
      { 
        unsigned int offset, i;
        int inc; /* this shd be signed */

        offset = (unsigned int) 
				 (wide_prefix ? (unsigned short) IstreamReadShort (pc+2): 
                                (unsigned char) IstreamReadByte (pc+1));
        inc = (wide_prefix ? IstreamReadShort (pc+4) : 
                             IstreamReadByte (pc+2));
        READ_WORD (VARS_OFFSET (-offset), 'V', i);
        i += inc;
        WRITE_WORD (VARS_OFFSET (-offset), 'V', i);
	    if (wide_prefix)
            SIZE_AND_STACK_RETURN(6, 0)
        else
            SIZE_AND_STACK_RETURN(3, 0)
      }    
          

/* binary FP operations 
   Nan handling - if the first operand is a Nan, copy the exact same
   bit pattern to the result, resetting the sign bit, else if the 
   second operand is a Nan, copy the exact same bit pattern to the result, 
   resetting the sign bit, else if this operation causes a Nan, make the 
   output bit pattern that of an INan. this will emulate pico exactly */

#define BINARY_FLOAT_OP(name, op)                 \
     case opc_f##name:                            \
       {                                          \
         float f1, f2, f;                         \
         TRAP_IF_FPU_OFF;                         \
         READ_WORD (OPTOP_OFFSET (1), 'O', f1);   \
         READ_WORD (OPTOP_OFFSET (2), 'O', f2);   \
		 if (isnan (f2)) f = f2;                  \
		 else if (isnan (f1)) f = f1;             \
		 else                                     \
		 {                                        \
			 f = f2 op f1;                        \
			 if (isnan (f))                       \
			     f = *((float *) (&INanPattern)); \
         }                                        \
		 F_RESET_SIGN_IF_NAN (f)                  \
         WRITE_WORD (OPTOP_OFFSET (2), 'O', f);   \
       }                                          \
       SIZE_AND_STACK_RETURN(1, -1);              \
     case opc_d##name:                            \
       {                                          \
         double d1, d2, d;                        \
         TRAP_IF_FPU_OFF;                         \
         READ_DWORD (OPTOP_OFFSET (2), 'O', d1);  \
         READ_DWORD (OPTOP_OFFSET (4), 'O', d2);  \
		 if (isnan (d2)) d = d2;                  \
		 else if (isnan (d1)) d = d1;             \
		 else                                     \
		 {                                        \
			 d = d2 op d1;                        \
			 if (isnan (d))                       \
			     d = *((double *) (&DINanPattern));\
         }                                        \
		 D_RESET_SIGN_IF_NAN (d)                  \
         WRITE_DWORD (OPTOP_OFFSET (4), 'O', d);  \
       }                                          \
       SIZE_AND_STACK_RETURN(1, -2);

      BINARY_FLOAT_OP(add, +)
      BINARY_FLOAT_OP(sub, -)
      BINARY_FLOAT_OP(mul, *)
      BINARY_FLOAT_OP(div, /)

/* misc. FP operations */
      case opc_frem:
      {                                         
        float f1, f2, f;
        TRAP_IF_FPU_OFF; 
        READ_WORD (OPTOP_OFFSET (1), 'O', f1);  
        READ_WORD (OPTOP_OFFSET (2), 'O', f2);  
        if (isnan (f2))
            f = f2;
        else if (isnan (f1)) 
            f = f1;
        else
	    {
            f = DREMAINDER (f2, f1);
	        if (isnan (f))
                f = *((float *) (&INanPattern));
	    }

		F_RESET_SIGN_IF_NAN (f) 

        WRITE_WORD (OPTOP_OFFSET (2), 'O', f); 
      }                                         
      SIZE_AND_STACK_RETURN(1, -1);

      case opc_drem:
      {        
        double d1, d2, d;

        TRAP_IF_FPU_OFF; 

		if (psr & 0x8000) /* DREM traps */
		{
			LOW_PRIORITY_TRAP (opc_drem);
			return;
        }

        READ_DWORD (OPTOP_OFFSET (2), 'O', d1);
        READ_DWORD (OPTOP_OFFSET (4), 'O', d2);
        if (isnan (d2))
            d = d2;
        else if (isnan (d1)) 
            d = d1;
        else
	    {
            d = DREMAINDER (d2, d1);
            if (isnan (d))
          	    d = *((double *) (&DINanPattern));
	    }

		D_RESET_SIGN_IF_NAN (d)

        WRITE_DWORD (OPTOP_OFFSET (4), 'O', d);
      }            

      SIZE_AND_STACK_RETURN(1, -2);

      /* fneg, dneg are done in the IU, so no FP trap even 
  		 if FPU is absent - simply flip the msb */
      case opc_fneg:
      {                                         
        int i;
        READ_WORD (OPTOP_OFFSET (1), 'O', i);  
        i ^= 0x80000000;
        WRITE_WORD (OPTOP_OFFSET (1), 'O', i);
      }                                         
      SIZE_AND_STACK_RETURN(1, 0);

      case opc_dneg:
      {
        long long ll;
        READ_DWORD (OPTOP_OFFSET (2), 'O', ll);
        ll = ll_xor (ll, 0x8000000000000000LL);
        WRITE_DWORD (OPTOP_OFFSET (2), 'O', ll);
      }            
      SIZE_AND_STACK_RETURN(1, 0);
        
/* Unconditional goto instructions. Maybe save return address in register. */
      case opc_jsr:
      { 
		unsigned int x = (unsigned int) (pc + 3);
        int skip = (signed short) IstreamReadShort(pc+1);

        DPRINTF (JSR_DBG_LVL, ("jsr at 0x%x, branching to 0x%x\n", (unsigned int) pc, (unsigned int) pc + skip));

        WRITE_WORD (OPTOP_OFFSET (0), 'O', x);
        SIZE_AND_STACK_RETURN (skip, 1);
      }

      case opc_goto: 
	  {
        int skip = IstreamReadShort(pc+1);

        JUMP_AND_STACK(skip, 0);
      }

      case opc_jsr_w:
      { 
		unsigned int x = (unsigned int) (pc + 5);
        int skip = (signed) IstreamReadWord(pc+1);

        DPRINTF (JSR_DBG_LVL, ("jsr_w at 0x%x, branching to 0x%x\n", (unsigned int) pc, (unsigned int) pc + skip));

        WRITE_WORD (OPTOP_OFFSET (0), 'O', x);
        SIZE_AND_STACK_RETURN (skip, 1);
      }

      case opc_goto_w: 
	  {
        int skip = IstreamReadWord(pc+1);
        JUMP_AND_STACK(skip, 0);
      }

      /* the ret (not return) instruction */
      case opc_ret:
      { 
        unsigned int i;
        unsigned int offset;
        offset = (unsigned int) 
				 (wide_prefix ? (unsigned short) IstreamReadShort (pc+2) : 
                                (unsigned char) IstreamReadByte (pc+1));
        READ_WORD (VARS_OFFSET(-offset), 'V', unsigned_tmp);
        pc = (unsigned char *) unsigned_tmp;
      }
      SIZE_AND_STACK_RETURN(0, 0);

/* comparison op */

#define COMPARISON_OP(name, comparison)                           \
     case opc_if_icmp##name: {                                    \
            int i1, i2, skip;                                     \
            READ_WORD (OPTOP_OFFSET (1), 'O', i1);                \
            READ_WORD (OPTOP_OFFSET (2), 'O', i2);                \
            if (i2 comparison i1)                                 \
            {                                                     \
                skip = IstreamReadShort(pc+1);                    \
                icmp_branches = ll_add(icmp_branches, 1LL);       \
            } else                                                \
              skip = 3;                                           \
            JUMP_AND_STACK(skip, -2);                             \
        }                                                         \
        case opc_if##name: {                                      \
            int i1, skip;                                         \
            READ_WORD (OPTOP_OFFSET (1), 'O', i1);                \
            if (i1 comparison 0)                                  \
            {                                                     \
                skip = IstreamReadShort(pc+1);                    \
                icmp_branches = ll_add(icmp_branches, 1LL);       \
            } else                                                \
              skip = 3;                                           \
            JUMP_AND_STACK(skip, -1);                             \
        }

#define COMPARISON_OP2(name, nullname, comparison)                \
        COMPARISON_OP(name, comparison)                           \
     case opc_if_acmp##name: {                                    \
            unsigned int a1, a2;                                  \
            int skip;                                             \
            READ_WORD (OPTOP_OFFSET (1), 'O', a1);               \
            READ_WORD (OPTOP_OFFSET (2), 'O', a2);               \
            MASK_OBJREF (a1);                                    \
            MASK_OBJREF (a2);                                    \
            if (a1 comparison a2)                               \
            { skip = IstreamReadShort(pc+1);                    \
              acmp_branches = ll_add(acmp_branches, 1LL);       \
            } else                                              \
              skip = 3;                                         \
            JUMP_AND_STACK(skip, -2);                             \
        }                                                         \
        case opc_if##nullname: {                                  \
            void *pV1;                                            \
            int skip;                                             \
            READ_WORD (OPTOP_OFFSET (1), 'O', pV1);               \
            if (pV1 comparison NULL)                              \
            { skip = IstreamReadShort(pc+1);                    \
              acmp_branches = ll_add(acmp_branches, 1LL);       \
            } else                                              \
              skip = 3;                                         \
            JUMP_AND_STACK(skip, -1);                             \
        }                                                         

     COMPARISON_OP2(eq, null, ==)   /*also generate acmp_eq and acmp_ne */
     COMPARISON_OP2(ne, nonnull, !=)
     COMPARISON_OP(lt, <)
     COMPARISON_OP(gt, >)
     COMPARISON_OP(le, <=)
     COMPARISON_OP(ge, >=)    

       /* stack manipulation instructions */
        case opc_pop:
                 SIZE_AND_STACK_RETURN(1, -1);

        case opc_pop2:
                 SIZE_AND_STACK_RETURN(1, -2);

        case opc_dup:
                 COPY_STACK_ITEM (OPTOP_OFFSET(0), OPTOP_OFFSET(1), 'O', 'O')
                 SIZE_AND_STACK_RETURN(1, 1);

        case opc_dup2:      /* Duplicate the top two items on the stack */
                 COPY_STACK_ITEM (OPTOP_OFFSET(0), OPTOP_OFFSET(2), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(-1), OPTOP_OFFSET(1), 'O', 'O')
                 SIZE_AND_STACK_RETURN(1, 2);

        case opc_dup_x1:    /* insert OPTOP_OFFSET(1) on stack past 1 */
                 /* first update optop, so that if it causes an oplim 
                    trap, no state on existing stack is modified */
                 vUpdateGR (GR_optop, ((int) optop) - 4);

                 COPY_STACK_ITEM (OPTOP_OFFSET(1), OPTOP_OFFSET(2), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(2), OPTOP_OFFSET(3), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(3), OPTOP_OFFSET(1), 'O', 'O')
                 SIZE_AND_STACK_RETURN(1, 0);

        case opc_dup_x2:    /* insert OPTOP_OFFSET(1) on stack past 2 */
                 /* first update optop, so that if it causes an oplim 
                    trap, no state on existing stack is modified */
                 vUpdateGR (GR_optop, ((int) optop) - 4);

                 COPY_STACK_ITEM (OPTOP_OFFSET(1), OPTOP_OFFSET(2), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(2), OPTOP_OFFSET(3), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(3), OPTOP_OFFSET(4), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(4), OPTOP_OFFSET(1), 'O', 'O')
                 SIZE_AND_STACK_RETURN(1, 0);

        case opc_dup2_x1:   /* insert OPTOP_OFFSET(1,-2) on stack past 1 */
                 /* first adjust optop, so that if it causes an oplim 
                    trap, no state on existing stack is modified */
                 vUpdateGR (GR_optop, ((int) optop) - 8);

                 COPY_STACK_ITEM (OPTOP_OFFSET(1), OPTOP_OFFSET(3), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(2), OPTOP_OFFSET(4), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(3), OPTOP_OFFSET(5), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(4), OPTOP_OFFSET(1), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(5), OPTOP_OFFSET(2), 'O', 'O')
                 SIZE_AND_STACK_RETURN(1, 0);

        case opc_dup2_x2:   /* insert OPTOP_OFFSET(1,2) on stack past 2 */
                 /* first update optop, so that if it causes an oplim 
                    trap, no state on existing stack is modified */
                 vUpdateGR (GR_optop, ((int) optop) - 8);

                 COPY_STACK_ITEM (OPTOP_OFFSET(1), OPTOP_OFFSET(3), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(2), OPTOP_OFFSET(4), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(3), OPTOP_OFFSET(5), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(4), OPTOP_OFFSET(6), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(5), OPTOP_OFFSET(1), 'O', 'O')
                 COPY_STACK_ITEM (OPTOP_OFFSET(6), OPTOP_OFFSET(2), 'O', 'O')
                 SIZE_AND_STACK_RETURN(1, 0);

        case opc_swap: {        /* swap top two elements on the stack */
                 int i;
                 READ_WORD (OPTOP_OFFSET(1), 'O', i);
                 COPY_STACK_ITEM (OPTOP_OFFSET(1), OPTOP_OFFSET(2), 'O', 'O')
                 WRITE_WORD (OPTOP_OFFSET(2), 'O', i);
                 SIZE_AND_STACK_RETURN(1, 0);
         }

	  case opc_exit_sync_method:
		READ_WORD (FRAME_OFFSET (-5), 'F', unsigned_tmp);
		pc = (unsigned char *) unsigned_tmp;
		SIZE_AND_STACK_RETURN (0, 0);

      case opc_sethi:
      { 
        unsigned int hi16b, unsigned_tmp;
       
        hi16b = (unsigned int) IstreamReadShort (pc+1);

        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        unsigned_tmp = (unsigned_tmp & 0x0000FFFF) | (hi16b << 16);
        WRITE_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
      }
      SIZE_AND_STACK_RETURN (3, 0);


/*__________________________ TRAP OPS _______________________________*/

      case    opc_ldc:
      case    opc_ldc_w:
      case    opc_ldc2_w:
      case    opc_getstatic:
      case    opc_putstatic:
      case    opc_getfield:
      case    opc_putfield:
      case    opc_new:
      case    opc_newarray:
      case    opc_anewarray:
      case    opc_checkcast:
      case    opc_instanceof:
      case    opc_multianewarray:

      case    opc_invokevirtual:
      case    opc_invokespecial:
      case    opc_invokestatic:
      case    opc_invokeinterface:
      case    opc_aastore:
      case    opc_athrow:
      case    opc_breakpoint:
      case    opc_lookupswitch:

      case    opc_new_quick:
      case    opc_anewarray_quick:
      case    opc_multianewarray_quick:
      case    opc_invokeinterface_quick:
      case    opc_getfield_quick_w:
      case    opc_putfield_quick_w:
      case    opc_wide:

        LOW_PRIORITY_TRAP (opcode);
        return;  
   
/*__________________________ OBJECT OPS _______________________________*/

      case opc_invokestatic_quick:
        doInvokestatic_quick();
        return;  

      case opc_invokenonvirtual_quick: 
        doInvokenonvirtual_quick();
        return;  

      case opc_agetstatic_quick: 
      case opc_getstatic_quick: 
        doGetstatic_quick();
        return;  

      case opc_aputstatic_quick:
		doAPutstatic_quick ();
		return;

      case opc_putstatic_quick:
        doPutstatic_quick();
        return;  

      case opc_getstatic2_quick: 
        doGetstatic2_quick();
        return;  

      case opc_putstatic2_quick:
        doPutstatic2_quick();
        return;  
          
      case opc_invokevirtual_quick:
        doInvokevirtual_quick();
        return;  
              
      case opc_invokevirtual_quick_w:
        doInvokevirtual_quick_w ();
        return;  
              
      case opc_putfield_quick:
        doPutfield_quick ();
        return;  

      case opc_aputfield_quick:
        doAPutfield_quick ();
        return;  

      case opc_putfield2_quick:
        doPutfield2_quick ();
        return;  

      case opc_agetfield_quick:
        doAGetfield_quick ();
        return;  

      case opc_getfield_quick:
        doGetfield_quick ();
        return;  

      case opc_getfield2_quick:
        doGetfield2_quick ();
        return;  

      case opc_aldc_quick:
      case opc_ldc_quick:
        doLdc_quick ();
        return;  

      case opc_aldc_w_quick:
      case opc_ldc_w_quick:
        doLdc_w_quick ();
        return;  

      case opc_ldc2_w_quick:
        doLdc2_w_quick ();         
        return;  

      case opc_invokesuper_quick:
        doInvokesuper_quick();
        return;  

      case opc_tableswitch:
        doTableSwitch ();
        return;

      case opc_checkcast_quick:
        doCheckCast_quick ();
        return;

      case opc_instanceof_quick:
        doInstanceOf_quick ();
        return;

      case opc_nonnull_quick:
        doNonnull_quick ();
		return;

      case opc_monitorenter:
		doMonitorEnter ();
		return;
	  
      case opc_monitorexit:
	    doMonitorExit ();
		return;

/*__________________________ ARRAY OPS _______________________________*/

      case opc_arraylength:
        doArrayLength ();
        return;
      case opc_aaload:
      case opc_iaload:
      case opc_faload:
        do32bArrayLoad ();
		return;
		
      case opc_aastore_quick:
           {
                if ((proc_type != pico) && (proc_type != maya))
                {
                    doAastore_quick ();
                }
                else
                    LOW_PRIORITY_TRAP (opcode);

                return;
           }
    
 
      case opc_iastore:
      case opc_fastore:
		do32bArrayStore ();
		return;

      case opc_laload:
      case opc_daload:
        do64bArrayLoad ();
		return;
        
      case opc_lastore:
      case opc_dastore:
		do64bArrayStore ();
		return;

      case opc_baload:
        doBaload ();
		return;

      case opc_bastore:
        doBastore ();
		return;

      case opc_saload:
		doSaload ();
		return;

      case opc_sastore:
		doSastore ();
		return;
        
      case opc_caload:
		doCaload ();
		return;

      case opc_castore:
		doCastore ();
		return;

      }

      if (proc_type != pico)
      {
         switch (opcode)
         {
           case opc_load_word_index:
           {
             int lvar, offset, base_addr;
             int little_endian, non_cacheable;
             unsigned int unsigned_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset * 4);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);

             CHECK_ADDRESS_ALIGNMENT (base_addr, 0x2);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_WORD (base_addr, non_cacheable ? 'N' : 'Z', unsigned_tmp);

             if (little_endian)
                 SWAP_WORD (unsigned_tmp);

             WRITE_WORD (OPTOP_OFFSET (0), 'O', unsigned_tmp);
         
             SIZE_AND_STACK_RETURN (3, 1);
           }

           case opc_load_short_index:
           {
             int lvar, offset, base_addr, tmp;
             int little_endian, non_cacheable;
             unsigned short ushort_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset * 2);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);

             CHECK_ADDRESS_ALIGNMENT (base_addr, 0x1);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_SHORT (base_addr, non_cacheable ? 'N' : 'Z', ushort_tmp);

             if (little_endian)
                 SWAP_SHORT (ushort_tmp);

             tmp = (signed short) ushort_tmp;
             WRITE_WORD (OPTOP_OFFSET (0), 'O', tmp);
         
             SIZE_AND_STACK_RETURN (3, 1);
           }

           case opc_load_char_index:
           {
             int lvar, offset, base_addr, tmp;
             int little_endian, non_cacheable;
             unsigned short ushort_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset * 2);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);

             CHECK_ADDRESS_ALIGNMENT (base_addr, 0x1);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_SHORT (base_addr, non_cacheable ? 'N' : 'Z', ushort_tmp);

             if (little_endian)
                 SWAP_SHORT (ushort_tmp);

             tmp = (unsigned short) ushort_tmp;
             WRITE_WORD (OPTOP_OFFSET (0), 'O', tmp);
         
             SIZE_AND_STACK_RETURN (3, 1);
           }


           case opc_load_byte_index:
           {
             int lvar, offset, base_addr, tmp;
             int little_endian, non_cacheable;
             unsigned char ubyte_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);


             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_BYTE (base_addr, non_cacheable ? 'N' : 'Z', ubyte_tmp);

             tmp = (signed char) ubyte_tmp;
             WRITE_WORD (OPTOP_OFFSET (0), 'O', tmp);
         
             SIZE_AND_STACK_RETURN (3, 1);
           }

           case opc_load_ubyte_index:
           {
             int lvar, offset, base_addr, tmp;
             int little_endian, non_cacheable;
             unsigned char ubyte_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);


             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_BYTE (base_addr, non_cacheable ? 'N' : 'Z', ubyte_tmp);

             tmp = (unsigned char) ubyte_tmp;
             WRITE_WORD (OPTOP_OFFSET (0), 'O', tmp);
         
             SIZE_AND_STACK_RETURN (3, 1);
           }

           case opc_store_word_index:
           {
             int lvar, offset, base_addr, value;
             int little_endian, non_cacheable;
             unsigned int unsigned_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset * 4);

             CHECK_ADDRESS_ALIGNMENT(base_addr, 0x2);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

             if (little_endian)
                 SWAP_WORD (unsigned_tmp);

             WRITE_WORD (base_addr, non_cacheable ? 'N' : 'Z', unsigned_tmp);
         
             SIZE_AND_STACK_RETURN (3, -1);
           }

           case opc_store_short_index:
           {
             int lvar, offset, base_addr, tmp;
             int little_endian, non_cacheable;
             unsigned short ushort_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset * 2);

             CHECK_ADDRESS_ALIGNMENT(base_addr, 0x1);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_WORD (OPTOP_OFFSET (1), 'O', tmp);
             ushort_tmp = (short) tmp;

             if (little_endian)
                 SWAP_SHORT (ushort_tmp);

             WRITE_SHORT (base_addr, non_cacheable ? 'N' : 'Z', ushort_tmp);
         
             SIZE_AND_STACK_RETURN (3, -1);
           }

           case opc_store_byte_index:
           {
             int lvar, offset, base_addr, tmp;
             int non_cacheable;
             unsigned char ubyte_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset);

             non_cacheable = IS_NC_ADDRESS (base_addr);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_WORD (OPTOP_OFFSET (1), 'O', tmp);
             ubyte_tmp = (char) tmp;
             WRITE_BYTE (base_addr, (non_cacheable) ? 'N' : 'Z', ubyte_tmp);
         
             SIZE_AND_STACK_RETURN (3, -1);
           }
  
           case opc_nastore_word_index:
           {
             int lvar, offset, base_addr, value;
             int little_endian, non_cacheable;
             unsigned int unsigned_tmp;

             lvar = (unsigned char) IstreamReadByte (pc+1);
             offset = (signed char) IstreamReadByte (pc+2);

             READ_WORD (VARS_OFFSET (-lvar), 'V', base_addr);
             base_addr += (offset * 4);

             CHECK_ADDRESS_ALIGNMENT(base_addr, 0x2);

             little_endian = IS_LE_ADDRESS (base_addr);
             non_cacheable = IS_NC_ADDRESS (base_addr);

             /* zero the top 2 bits of the address */
             base_addr &= 0x3FFFFFFF;

             READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

             if (little_endian)
                 SWAP_WORD (unsigned_tmp);

             WRITE_WORD (base_addr, non_cacheable ? 'N' : 'A', unsigned_tmp);
         
             SIZE_AND_STACK_RETURN (3, -1);
           }
         }
      }
      printf("IAS taking illegal instruction trap, opcode = 0x%x\n", (unsigned int) opcode);
      vSetupException (ILLEGAL_INSTR_EXCEPTION);
      return;
}
