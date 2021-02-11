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




static char *sccsid = "@(#)res.c 1.9 Last modified 10/07/98 14:29:03 SMI";

#include <stdio.h>

#include "dsv.h"
#include "decaf.h"

#include "oobj.h"
#include "tree.h"
#include "opcodes.h"
#include "cm.h"
#include "res.h"

#define SIZE(size) pc += size; i += size; continue
#define GET_INDEX(ptr) (((int)((ptr)[0]) << 8) | (ptr)[1])

char *
getFieldSignature(cp_item_type *constant_pool, unsigned index)
{
   unsigned char *type_table;
   unsigned type;
   unsigned key;
   unsigned classIndex;
   unsigned nameTypeIndex;
   unsigned nameIndex;
   unsigned typeIndex;

   type_table = constant_pool[CONSTANT_POOL_TYPE_TABLE_INDEX].p;

   if (!CONSTANT_POOL_TYPE_TABLE_IS_RESOLVED(type_table, index)) {
    type = CONSTANT_POOL_TYPE_TABLE_GET_TYPE(type_table, index);
    switch(type) {
     case CONSTANT_Fieldref:
      key = constant_pool[index].i;
      classIndex = key >> 16;
      nameTypeIndex = key & 0xFFFF;

      key = constant_pool[nameTypeIndex].i;
      nameIndex = key >> 16;
      typeIndex = key & 0xFFFF;

      return(constant_pool[typeIndex].cp);
     default:
      printf("Error: cp[%d] is not a fieldref\n", index);
      return(NULL);
    }
   }
   return(NULL);
}

void
changeOpcodeToQuick(ClassClass *cb) 
{
    int count;
    unsigned char  *pc;
    unsigned char  opcode;
    int i;
    int j;
    char *signature;
    int findex;
    struct fieldblock *fb;
    int res_dbg;
    char *cptr;

   cptr = (char *)getenv("DSV_DBG");
   if ((cptr != NULL) && (strcmp(cptr, "RES_DBG")==0)) {
    res_dbg = 1;
   }
   else {
    res_dbg = 0;
   }
   for (j=0; j < cb->methods_count; j++) {
    count = cb->methods[j].code_length;
    pc = cb->methods[j].code;
    i=0;

    while (i < count) {

	opcode = *pc;
	switch (opcode) { 

	case opc_nop:
	    SIZE(1);

	case opc_aload:
	case opc_iload:
        case opc_fload:
	    SIZE(2);
	      
	case opc_lload:
	case opc_dload:
	    SIZE(2);

#define OPC_DO_LOAD_n(num)                                              \
	case opc_iload_##num:                                           \
	case opc_aload_##num:                                           \
	case opc_fload_##num:                                           \
	    SIZE(1);					\
        case opc_lload_##num:                                         	\
	case opc_dload_##num:	                                        \
	    SIZE(1);

	OPC_DO_LOAD_n(0)
	OPC_DO_LOAD_n(1)
	OPC_DO_LOAD_n(2)
	OPC_DO_LOAD_n(3)

	      /* store a local variable onto the stack. */
	case opc_istore:
	case opc_astore:
	case opc_fstore:
	    SIZE(2);

	case opc_lstore:
	case opc_dstore:
	    SIZE(2);

#define OPC_DO_STORE_n(num)                                             \
	case opc_istore_##num:				        	\
	case opc_astore_##num: 						\
	case opc_fstore_##num: 						\
	    SIZE(1);                                      \
	case opc_lstore_##num: 						\
	case opc_dstore_##num: 						\
	    SIZE(1);

	OPC_DO_STORE_n(0)
	OPC_DO_STORE_n(1)
	OPC_DO_STORE_n(2)
	OPC_DO_STORE_n(3)

	case opc_areturn:
	case opc_ireturn:
	case opc_freturn:
	    SIZE(1);
	      
	case opc_lreturn:
	case opc_dreturn:
	    SIZE(1);

	case opc_return:
	    SIZE(1);

	case opc_i2f:		/* Convert top of stack int to float */
	    SIZE(1);

	case opc_i2l:		/* Convert top of stack int to long */
	    SIZE(1);

	case opc_i2d:
	    SIZE(1);
	      
	case opc_f2i:		/* Convert top of stack float to int */
	    SIZE(1);

	case opc_f2l:		/* convert top of stack float to long */
	    SIZE(1);
	      
	case opc_f2d:		/* convert top of stack float to double */
	    SIZE(1);

	case opc_l2i:		/* convert top of stack long to int */
	    SIZE(1);
	      
	case opc_l2f:		/* convert top of stack long to float */
	    SIZE(1);

	case opc_l2d:		/* convert top of stack long to double */
	    SIZE(1);

	case opc_d2i:
	    SIZE(1);
	      
	case opc_d2f:
	    SIZE(1);

	case opc_d2l:
	    SIZE(1);

	case opc_int2byte:
	    SIZE(1);
	      
	case opc_int2char:
	    SIZE(1);

	case opc_int2short:
	    SIZE(1);

        case opc_fcmpl:
        case opc_fcmpg:
	    SIZE(1);

	case opc_lcmp:
	    SIZE(1);

	case opc_dcmpl: 
	case opc_dcmpg:
	    SIZE(1);
	      
	case opc_bipush:	
	    SIZE(2);

	case opc_sipush:	
	    SIZE(3);

	case opc_ldc:
	    SIZE(2);

	case opc_ldc_quick:
	    SIZE(2);

	case opc_ldc_w:
	    SIZE(3);

	case opc_ldc_w_quick:
	    SIZE(3);

	case opc_ldc2_w:	/* load a two word constant */
	    SIZE(3);

	case opc_ldc2_w_quick:
	    SIZE(3);

#define CONSTANT_OP(opcode) 				\
	case opcode: 							\
	    SIZE(1);
	  
	    /* Push miscellaneous constants onto the stack. */
	CONSTANT_OP(opc_aconst_null)
	CONSTANT_OP(opc_iconst_m1)
	CONSTANT_OP(opc_iconst_0)
	CONSTANT_OP(opc_iconst_1)
	CONSTANT_OP(opc_iconst_2)
	CONSTANT_OP(opc_iconst_3)
	CONSTANT_OP(opc_iconst_4)
	CONSTANT_OP(opc_iconst_5)
	CONSTANT_OP(opc_fconst_0)
	CONSTANT_OP(opc_fconst_1)
	CONSTANT_OP(opc_fconst_2)

	case opc_dconst_0:
	    SIZE(1);

	case opc_dconst_1:
	    SIZE(1);

	case opc_lconst_0:
	    SIZE(1);

	case opc_lconst_1:
	    SIZE(1);

#define BINARY_INT_OP(name)                               \
	case opc_i##name:                                          	\
	    SIZE(1);                                    	\
	case opc_l##name:                                             	\
	    SIZE(1);

	BINARY_INT_OP(add) 
	BINARY_INT_OP(sub)
	BINARY_INT_OP(mul)
	BINARY_INT_OP(and)
	BINARY_INT_OP(or)
	BINARY_INT_OP(xor)
	BINARY_INT_OP(div)
	BINARY_INT_OP(rem)

#define BINARY_SHIFT_OP(name)                               	\
	case opc_i##name:                                          	\
	    SIZE(1);                                    	\
	case opc_l##name:                                             	\
	    SIZE(1);

	BINARY_SHIFT_OP(shl)
	BINARY_SHIFT_OP(shr)

	case opc_iushr:
	    SIZE(1);
	case opc_lushr:
	    SIZE(1); 

	      /* Unary negation */
	case opc_ineg:
	    SIZE(1);

	case opc_lneg:
	    SIZE(1);
	    
	    /* Add a small constant to a local variable */
	case opc_iinc:
	    SIZE(3);


#define BINARY_FLOAT_OP(name) 					\
	case opc_f##name: 						\
	    SIZE(1); 					\
	case opc_d##name: 						\
	    SIZE(1);

	BINARY_FLOAT_OP(add)
	BINARY_FLOAT_OP(sub)
	BINARY_FLOAT_OP(mul)
	BINARY_FLOAT_OP(div)

	case opc_frem: 
	    SIZE(1);
	      
	case opc_drem: 
	    SIZE(1);

	case opc_fneg:
	    SIZE(1);

	case opc_dneg:
	    SIZE(1);

	    /* Unconditional goto.  Maybe save return address in register. */
	case opc_jsr:
	    SIZE(3);

	case opc_goto:
	    SIZE(3);

	case opc_jsr_w:
	    SIZE(5);

	case opc_goto_w:
	    SIZE(5);

	    /* Return from subroutine.  June to address in register. */
	case opc_ret:
	    SIZE(2);

#define COMPARISON_OP(name)                             \
	case opc_if_icmp##name: 			\
	    SIZE(3);					\
	case opc_if##name: 				\
	    SIZE(3);
            
#define COMPARISON_OP2(name, nullname)                  \
        COMPARISON_OP(name)                             \
	case opc_if_acmp##name: 			\
	    SIZE(3);					\
	case opc_if##nullname: 				\
	    SIZE(3);


	COMPARISON_OP2(eq, null)	/* also generate acmp_eq and acmp_ne */
	COMPARISON_OP2(ne, nonnull)
	COMPARISON_OP(lt)
	COMPARISON_OP(gt)
	COMPARISON_OP(le)
	COMPARISON_OP(ge)


	    /* Discard the top item on the stack */
	case opc_pop:
	    SIZE(1);

	    /* Discard the top item on the stack */
	case opc_pop2:
	    SIZE(1);

	    /* Duplicate the top item on the stack */
	case opc_dup:
	    SIZE(1);

	case opc_dup2:		/* Duplicate the top two items on the stack */
	    SIZE(1);

	case opc_dup_x1:	/* insert S_INFO(-1) on stack past 1 */
	    SIZE(1);
	      
	case opc_dup_x2:	/* insert S_INFO(-1) on stack past 2*/
	    SIZE(1);

	case opc_dup2_x1:	/* insert S_INFO(-1,-2) on stack past 1 */
	    SIZE(1);
	      
	case opc_dup2_x2:	/* insert S_INFO(-1,2) on stack past 2 */
	    SIZE(1);
	      
	case opc_swap:         /* swap top two elements on the stack */
	    SIZE(1);

	    /* Find the length of an array */
	case opc_arraylength:
	    SIZE(1);

	    /* Goto one of a sequence of targets. */
	case opc_tableswitch: {
            long *lpc = (long *) UCALIGN(pc + 1);
            SIZE((int)((unsigned char *)lpc - pc) +12+lpc[2]-lpc[1]+1);
	}
	      
	    /* Goto one of a sequence of targets */
	case opc_lookupswitch: {
	    long *lpc = (long *) UCALIGN(pc + 1);
	    int npairs = lpc[1];
            SIZE((int)((unsigned char *)lpc - pc) + 8 + npairs*8);
	}

	    /* Throw to a given value */
	case opc_athrow:
            SIZE(1);
	    
	case opc_getfield:
	case opc_putfield: 
            SIZE(3);

	case opc_getstatic:
            findex = GET_INDEX(pc+1);
            /* change it to quick */
	    if (res_dbg) {
             printf("Debug : getstatic is replaced by ");
	    }
            signature = getFieldSignature(cb->constantpool, findex);
            if ((signature[0] == SIGNATURE_LONG) || 
                (signature[0] == SIGNATURE_DOUBLE)) {
             *pc = opc_getstatic2_quick;
	     if (res_dbg) {
              printf("getstatic2_quick.\n");
	     }
            }
            else {
             *pc = opc_getstatic_quick;
	     if (res_dbg) {
              printf("getstatic_quick.\n");
	     }
            }
            SIZE(3);
	case opc_putstatic:
            findex = GET_INDEX(pc+1);
            /* change it to quick */
            signature = getFieldSignature(cb->constantpool, findex);
	    if (res_dbg) {
             printf("Debug : putstatic is replaced by ");
	    }
            if ((signature[0] == SIGNATURE_LONG) || 
                (signature[0] == SIGNATURE_DOUBLE)) {
             *pc = opc_putstatic2_quick;
	    if (res_dbg) {
             printf("putstatic2_quick.\n");
	    }
            }
            else {
             *pc = opc_putstatic_quick;
	    if (res_dbg) {
             printf("putstatic_quick.\n");
	    }
            }
            SIZE(3);

	case opc_invokevirtual:
	case opc_invokenonvirtual:
	case opc_invokestatic:
            SIZE(3);

	case opc_invokeinterface:
            SIZE(5);

	case opc_putfield_quick:
	    SIZE(3);

	case opc_getfield_quick:
	    SIZE(3);
	    
	case opc_putfield2_quick:
	    SIZE(3);

	case opc_getfield2_quick:
	    SIZE(3);


	case opc_putstatic_quick:   
	    SIZE(3);

	case opc_getstatic_quick:
	    SIZE(3);

	case opc_putstatic2_quick:
	    SIZE(3);

	case opc_putfield_quick_w:
	    SIZE(3);

	case opc_getstatic2_quick:
	    SIZE(3);

	case opc_getfield_quick_w:
	    SIZE(3);

	case opc_invokenonvirtual_quick:
	    SIZE(3);

	case opc_invokesuper_quick:
	    SIZE(3);

	case opc_invokevirtual_quick_w:
	    SIZE(3);

	case opc_invokestatic_quick:
	    SIZE(3);

	case opc_invokeinterface_quick:
	    SIZE(5);

	case opc_invokevirtual_quick:
	    SIZE(3);

	case opc_instanceof:
	    SIZE(3);

	case opc_instanceof_quick:
	    SIZE(3);
	
	case opc_checkcast:
	    SIZE(3);

	case opc_checkcast_quick:
	    SIZE(3);

	case opc_new:
	    SIZE(3);

	case opc_new_quick:
	    SIZE(3);

	case opc_anewarray:
	    SIZE(3);

	case opc_anewarray_quick:
	    SIZE(3);

	case opc_multianewarray:
	    SIZE(4);

	case opc_multianewarray_quick:
	    SIZE(4);

	case opc_newarray:
	    SIZE(2);

	case opc_iaload:
	    SIZE(1);
	    
	case opc_laload:
	    SIZE(1);

	case opc_faload:
	    SIZE(1);

	case opc_daload:
	    SIZE(1);

	case opc_aaload:
	    SIZE(1);

	case opc_baload:
	    SIZE(1);
	    
	case opc_caload:
	    SIZE(1);

	case opc_saload:
	    SIZE(1);

	case opc_iastore:
	    SIZE(1);

	case opc_lastore:
	    SIZE(1);

	case opc_fastore:
	    SIZE(1);

	case opc_dastore:
	    SIZE(1);

	case opc_bastore:
	    SIZE(1);

	case opc_castore:
	    SIZE(1);

	case opc_sastore:
	    SIZE(1);

	case opc_aastore:
	    SIZE(1);

	case opc_monitorenter:
	    SIZE(1);

	case opc_monitorexit:
	    SIZE(1);

	case opc_breakpoint:
	    SIZE(1);	/* treat as opc_nop */

	case opc_wide:

	    switch(pc[1]) { 
	        case opc_aload:
	        case opc_iload:
	        case opc_fload: 
		    SIZE(4);
	        case opc_lload:
	        case opc_dload: 
		    SIZE(4);
	        case opc_istore:
	        case opc_astore:
	        case opc_fstore:
		    SIZE(4);
	        case opc_lstore:
	        case opc_dstore: 
		    SIZE(4);
	        case opc_iinc:
		    SIZE(6);
	        case opc_ret: 
		    SIZE(2);
	        default:
		    printf("Warning: undefined opcode\n");
		    SIZE(2);
	    }

	case opc_priv:
	case opc_nonpriv:
	    SIZE(2);
	default:
	    printf("Warning: undefined opcode\n");
	    SIZE(1);
	    
	} /* end of switch */

    }
   }
}

/*
 * replace field and class index by data structure
 * This function works for cm only
 * The function walks through all the methods
 */
void
resolveConstantPool(ClassClass *cb)
{
}

void
resolveFields(ClassClass *cb, ClassClass *super)
{

    int slot;
    int numOfInstVars;
    struct fieldblock *fb;
    int cnt;
    int scnt;
    char *signature;
    int size;
    int i;
    int j;

    if (cb == super) {
     /* This one is the root */
     slot = 0;
     numOfInstVars = 0;
    }
    else {
     slot = super->slottbl_size;
     numOfInstVars = super->numOfInstVars;
    }

    fb = cb->fields;

    for (cnt=0; cnt < cb->fields_count; cnt++, fb++) {
     if (fb->access & ACC_STATIC) {
      /* static variables */
      continue;
     }
     signature = fb->signature;

#if 0
     for (scnt=0; scnt < super->slottbl_size; scnt++) {
      if ((super->slottable[scnt] != NULL) &&
          (strcmp(fb->name, super->slottable[scnt]->name)==0) &&
          (strcmp(signature, super->slottable[scnt]->signature)==0)) {
       /* for override the same variables */
       fb->u.offset = super->slottable[scnt]->u.offset;
       break;
      }
     }
     if (scnt != super->slottbl_size) continue;
#endif

     fb->u.offset = slot;
     size = (((signature[0] == SIGNATURE_LONG ||
               signature[0] == SIGNATURE_DOUBLE)) ? 2 : 1);
     slot += size;
     numOfInstVars++;
    }

    cb->slottbl_size = slot;
    cb->numOfInstVars = numOfInstVars;
    cb->instance_size = slot*sizeof(decafObject);

    if (slot == 0) {
     cb->slottable = NULL;
     return;
    }

    /* build instance variables */
    cb->slottable = (struct fieldblock **)malloc(slot*sizeof(struct fieldblock *));
    memset((void *)cb->slottable, 0, slot*sizeof(struct fieldblock *));

    if (cb != super) {
     i = super->slottbl_size;
     /* copy over from the super class */
     for (j=0; j < i; j++) {
      cb->slottable[j] = super->slottable[j];
     }
    }
    else {
     i = 0;
    }
    
    fb = cb->fields;
    for (cnt=0; cnt < cb->fields_count; cnt++, fb++) {
     if (fb->access & ACC_STATIC) {
      /* static variables */
      continue;
     }
     signature = fb->signature;

#if 0
     for (scnt=0; scnt < super->slottbl_size; scnt++) {
      if ((super->slottable[scnt] != NULL) &&
          (strcmp(fb->name, super->slottable[scnt]->name)==0) &&
          (strcmp(signature, super->slottable[scnt]->signature)==0)) {
       /* for override the same variables */
       cb->slottable[scnt] = fb;
       break;
      }
     }

     if (scnt != super->slottbl_size) continue;
#endif

     cb->slottable[i] = fb;
     size = (((signature[0] == SIGNATURE_LONG ||
               signature[0] == SIGNATURE_DOUBLE)) ? 2 : 1);
     i += size;
    }
}

void
resolveMethods(ClassClass *cb, ClassClass *super)
{
   struct methodblock *mb;
   struct methodblock *smb;
   int mslot;
   int size;
   int super_methods_count;
   int cnt;
   int scnt;
   int i;
   int j;
   char *signature;


   if (cb == super) {
    /* This is the root */
    mslot = 0;
   }
   else {
    mslot = super->methodtable_size;
   }

   /* calculate the offsets */
   mb = cb->methods;
   for (cnt = 0; cnt < cb->methods_count; cnt++, mb++) {
    if (mb->fb.access & ACC_STATIC) continue;
    if (strcmp(mb->fb.name, "<init>") == 0) continue;

    signature = mb->fb.signature;
    for (scnt=0; scnt < super->methodtable_size; scnt++) {
     smb = (super->methodtable)->methods[scnt];
     if ((smb != NULL) &&
         (strcmp(mb->fb.name, smb->fb.name)==0) &&
         (strcmp(signature, smb->fb.signature)==0)) {
      /* for override the same method */
      mb->fb.u.offset = scnt;
      break;
     }
    }

    if (scnt != super->methodtable_size) continue;

    mb->fb.u.offset = mslot;
    mslot++;
   }

   cb->methodtable_size = mslot;

   /* making the instance method table */
   cb->methodtable = (struct methodtable *)malloc(sizeof(struct ClassClass *)+mslot*sizeof(struct methodblock *));
   memset((void *)cb->methodtable, 0, sizeof(struct ClassClass *)+mslot*sizeof(struct methodblock *));

   cb->methodtable->classdescriptor = cb;

   if (cb != super) {
    i = super->methodtable_size;
    /* copy over from the super class */
    for (j=0; j < i; j++) {
     (cb->methodtable)->methods[j] = (super->methodtable)->methods[j];
    }
   }
   else {
    i = 0;
   }
    
   mb = cb->methods;
   for (cnt=0; cnt < cb->methods_count; cnt++, mb++) {
    if (mb->fb.access & ACC_STATIC) continue;
    if (strcmp(mb->fb.name, "<init>") == 0) continue;

    signature = mb->fb.signature;
    for (scnt=0; scnt < super->methodtable_size; scnt++) {
     smb = (super->methodtable)->methods[scnt];
     if ((smb != NULL) &&
         (strcmp(mb->fb.name, smb->fb.name)==0) &&
         (strcmp(signature, smb->fb.signature)==0)) {
      /* for override the same variables */
      (cb->methodtable)->methods[scnt] = mb;
      break;
     }
    }

    if (scnt != super->methodtable_size) continue;

    (cb->methodtable)->methods[i] = mb;
    i++;
   }

}

