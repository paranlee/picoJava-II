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




static char *sccsid = "@(#)dis.c 1.14 Last modified 10/07/98 17:52:07 SMI";

#include <stdio.h>

#include "dsv.h"
#include "decaf.h"

#include "oobj.h"
#include "tree.h"
#include "opcodes.h"
#include "cm.h"
#include "res.h"

#define SIZE(size) pc += size; i += size; code += size; continue
#define GET_INDEX(ptr) (((int)((ptr)[0]) << 8) | (ptr)[1])

void
disAssembly(unsigned char *code, int len, FILE *fp) 
{
    short offset;
    int offset4;
    unsigned char *cptr;
    unsigned char  *abs;
    int count;
    unsigned char  *pc;
    unsigned char  opcode;
    int i;
    int j;
    char *signature;
    int findex;
    struct fieldblock *fb;
    int res_dbg;
    unsigned int addr;
    char *s;

    count = len;

    /* do the checking before entering the loop */
    addr = (unsigned int)code;
    for (i=0; i < len; i=i+4) {
     if (addr > CM_SIZE) {
      if ((addr >= SCRATCH_START) && (addr < SCRATCH_START + SCRATCH_SIZE)) {
       if (((addr >= BAD_MEMORY_START) &&
            (addr < (unsigned int)BAD_MEMORY_START + (unsigned int)BAD_SIZE)) ||
           ((addr >= BAD_IO_START) &&
            (addr < (unsigned int)BAD_IO_START + (unsigned int)BAD_SIZE))) {
        printf("Warning: addr 0x%x is not valid\n", addr);
        return ;
       }
      }
      else {
       printf("Warning: addr 0x%x is not valid\n", addr);
       return ;
      }
     }
     addr += 4;
    }

    addr = (unsigned int)code;
    for (i=0; i < len; i=i+4) {
     if (addr > CM_SIZE) {
	 printf ("Warning: cannot disassemble instructions at PC 0x%x, \
which is > CM_SIZE=0x%x\n\
*** this is purely a temporary disassembly display problem, the \
processor will behave correctly***\n", addr, CM_SIZE);
      return;
	 }
     addr += 4;
	}

    pc = (unsigned char *)getAbsAddr(code);
    i=0;

#if 0
    printf("pc =%08x, code = %08x\n", pc, code);
    fflush(stdout);
#endif

    while (i < count) {

	opcode = *pc;
	switch (opcode) { 

	case opc_nop:
	    fprintf(fp, "0x%08x %02x		nop\n", code, *pc);
	    SIZE(1);

	case opc_nonnull_quick:
	    fprintf(fp, "0x%08x %02x		nonnull_quick\n", code, *pc);
	    SIZE(1);

	case opc_aload:
	    fprintf(fp, "0x%08x %02x%02x		aload %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	case opc_iload:
	    fprintf(fp, "0x%08x %02x%02x		iload %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
        case opc_fload:
	    fprintf(fp, "0x%08x %02x%02x		fload %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	      
	case opc_lload:
	    fprintf(fp, "0x%08x %02x%02x		lload %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	case opc_dload:
	    fprintf(fp, "0x%08x %02x%02x		dload %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_iload_0:
	    fprintf(fp, "0x%08x %02x		iload_0\n", code, *pc);
	    SIZE(1);
	case opc_aload_0:
	    fprintf(fp, "0x%08x %02x		aload_0\n", code, *pc);
	    SIZE(1);
	case opc_fload_0:
	    fprintf(fp, "0x%08x %02x		fload_0\n", code, *pc);
	    SIZE(1);
        case opc_lload_0:
	    fprintf(fp, "0x%08x %02x		lload_0\n", code, *pc);
	    SIZE(1);
	case opc_dload_0:
	    fprintf(fp, "0x%08x %02x		dload_0\n", code, *pc);
	    SIZE(1);

	case opc_iload_1:
	    fprintf(fp, "0x%08x %02x		iload_1\n", code, *pc);
	    SIZE(1);
	case opc_aload_1:
	    fprintf(fp, "0x%08x %02x		aload_1\n", code, *pc);
	    SIZE(1);
	case opc_fload_1:
	    fprintf(fp, "0x%08x %02x		fload_1\n", code, *pc);
	    SIZE(1);
        case opc_lload_1:
	    fprintf(fp, "0x%08x %02x		lload_1\n", code, *pc);
	    SIZE(1);
	case opc_dload_1:
	    fprintf(fp, "0x%08x %02x		dload_1\n", code, *pc);
	    SIZE(1);

	case opc_iload_2:
	    fprintf(fp, "0x%08x %02x		iload_2\n", code, *pc);
	    SIZE(1);
	case opc_aload_2:
	    fprintf(fp, "0x%08x %02x		aload_2\n", code, *pc);
	    SIZE(1);
	case opc_fload_2:
	    fprintf(fp, "0x%08x %02x		fload_2\n", code, *pc);
	    SIZE(1);
        case opc_lload_2:
	    fprintf(fp, "0x%08x %02x		lload_2\n", code, *pc);
	    SIZE(1);
	case opc_dload_2:
	    fprintf(fp, "0x%08x %02x		dload_2\n", code, *pc);
	    SIZE(1);

	case opc_iload_3:
	    fprintf(fp, "0x%08x %02x		iload_3\n", code, *pc);
	    SIZE(1);
	case opc_aload_3:
	    fprintf(fp, "0x%08x %02x		aload_3\n", code, *pc);
	    SIZE(1);
	case opc_fload_3:
	    fprintf(fp, "0x%08x %02x		fload_3\n", code, *pc);
	    SIZE(1);
        case opc_lload_3:
	    fprintf(fp, "0x%08x %02x		lload_3\n", code, *pc);
	    SIZE(1);
	case opc_dload_3:
	    fprintf(fp, "0x%08x %02x		dload_3\n", code, *pc);
	    SIZE(1);

	      /* store a local variable onto the stack. */
	case opc_istore:
	    fprintf(fp, "0x%08x %02x%02x		istore %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	case opc_astore:
	    fprintf(fp, "0x%08x %02x%02x		astore %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	case opc_fstore:
	    fprintf(fp, "0x%08x %02x%02x		fstore %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_lstore:
	    fprintf(fp, "0x%08x %02x%02x		lstore %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	case opc_dstore:
	    fprintf(fp, "0x%08x %02x%02x		dstore %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_istore_0:
	    fprintf(fp, "0x%08x %02x		istore_0\n", code, *pc);
	    SIZE(1);
	case opc_astore_0:
	    fprintf(fp, "0x%08x %02x		astore_0\n", code, *pc);
	    SIZE(1);
	case opc_fstore_0:
	    fprintf(fp, "0x%08x %02x		fstore_0\n", code, *pc);
	    SIZE(1);
	case opc_lstore_0:
	    fprintf(fp, "0x%08x %02x		lstore_0\n", code, *pc);
	    SIZE(1);
	case opc_dstore_0:
	    fprintf(fp, "0x%08x %02x		dstore_0\n", code, *pc);
	    SIZE(1);

	case opc_istore_1:
	    fprintf(fp, "0x%08x %02x		istore_1\n", code, *pc);
	    SIZE(1);
	case opc_astore_1:
	    fprintf(fp, "0x%08x %02x		astore_1\n", code, *pc);
	    SIZE(1);
	case opc_fstore_1:
	    fprintf(fp, "0x%08x %02x		fstore_1\n", code, *pc);
	    SIZE(1);
	case opc_lstore_1:
	    fprintf(fp, "0x%08x %02x		lstore_1\n", code, *pc);
	    SIZE(1);
	case opc_dstore_1:
	    fprintf(fp, "0x%08x %02x		dstore_1\n", code, *pc);
	    SIZE(1);

	case opc_istore_2:
	    fprintf(fp, "0x%08x %02x		istore_2\n", code, *pc);
	    SIZE(1);
	case opc_astore_2:
	    fprintf(fp, "0x%08x %02x		astore_2\n", code, *pc);
	    SIZE(1);
	case opc_fstore_2:
	    fprintf(fp, "0x%08x %02x		fstore_2\n", code, *pc);
	    SIZE(1);
	case opc_lstore_2:
	    fprintf(fp, "0x%08x %02x		lstore_2\n", code, *pc);
	    SIZE(1);
	case opc_dstore_2:
	    fprintf(fp, "0x%08x %02x		dstore_2\n", code, *pc);
	    SIZE(1);

	case opc_istore_3:
	    fprintf(fp, "0x%08x %02x		istore_3\n", code, *pc);
	    SIZE(1);
	case opc_astore_3:
	    fprintf(fp, "0x%08x %02x		astore_3\n", code, *pc);
	    SIZE(1);
	case opc_fstore_3:
	    fprintf(fp, "0x%08x %02x		fstore_3\n", code, *pc);
	    SIZE(1);
	case opc_lstore_3:
	    fprintf(fp, "0x%08x %02x		lstore_3\n", code, *pc);
	    SIZE(1);
	case opc_dstore_3:
	    fprintf(fp, "0x%08x %02x		dstore_3\n", code, *pc);
	    SIZE(1);

	case opc_areturn:
	    fprintf(fp, "0x%08x %02x		areturn\n", code, *pc);
	    SIZE(1);
	case opc_ireturn:
	    fprintf(fp, "0x%08x %02x		ireturn\n", code, *pc);
	    SIZE(1);
	case opc_freturn:
	    fprintf(fp, "0x%08x %02x		freturn\n", code, *pc);
	    SIZE(1);
	      
	case opc_lreturn:
	    fprintf(fp, "0x%08x %02x		lreturn\n", code, *pc);
	    SIZE(1);
	case opc_dreturn:
	    fprintf(fp, "0x%08x %02x		dreturn\n", code, *pc);
	    SIZE(1);

	case opc_return:
	    fprintf(fp, "0x%08x %02x		return\n", code, *pc);
	    SIZE(1);

	case opc_i2f:		/* Convert top of stack int to float */
	    fprintf(fp, "0x%08x %02x		i2f\n", code, *pc);
	    SIZE(1);

	case opc_i2l:		/* Convert top of stack int to long */
	    fprintf(fp, "0x%08x %02x		i2l\n", code, *pc);
	    SIZE(1);

	case opc_i2d:
	    fprintf(fp, "0x%08x %02x		i2d\n", code, *pc);
	    SIZE(1);
	      
	case opc_f2i:		/* Convert top of stack float to int */
	    fprintf(fp, "0x%08x %02x		f2i\n", code, *pc);
	    SIZE(1);

	case opc_f2l:		/* convert top of stack float to long */
	    fprintf(fp, "0x%08x %02x		f2l\n", code, *pc);
	    SIZE(1);
	      
	case opc_f2d:		/* convert top of stack float to double */
	    fprintf(fp, "0x%08x %02x		f2d\n", code, *pc);
	    SIZE(1);

	case opc_l2i:		/* convert top of stack long to int */
	    fprintf(fp, "0x%08x %02x		l2i\n", code, *pc);
	    SIZE(1);
	      
	case opc_l2f:		/* convert top of stack long to float */
	    fprintf(fp, "0x%08x %02x		l2f\n", code, *pc);
	    SIZE(1);

	case opc_l2d:		/* convert top of stack long to double */
	    fprintf(fp, "0x%08x %02x		l2d\n", code, *pc);
	    SIZE(1);

	case opc_d2i:
	    fprintf(fp, "0x%08x %02x		d2i\n", code, *pc);
	    SIZE(1);
	      
	case opc_d2f:
	    fprintf(fp, "0x%08x %02x		d2f\n", code, *pc);
	    SIZE(1);

	case opc_d2l:
	    fprintf(fp, "0x%08x %02x		d2l\n", code, *pc);
	    SIZE(1);

	case opc_int2byte:
	    fprintf(fp, "0x%08x %02x		i2b\n", code, *pc);
	    SIZE(1);
	      
	case opc_int2char:
	    fprintf(fp, "0x%08x %02x		i2c\n", code, *pc);
	    SIZE(1);

	case opc_int2short:
	    fprintf(fp, "0x%08x %02x		i2s\n", code, *pc);
	    SIZE(1);

        case opc_fcmpl:
	    fprintf(fp, "0x%08x %02x		fcmpl\n", code, *pc);
	    SIZE(1);
        case opc_fcmpg:
	    fprintf(fp, "0x%08x %02x		fcmpg\n", code, *pc);
	    SIZE(1);

	case opc_lcmp:
	    fprintf(fp, "0x%08x %02x		lcmp\n", code, *pc);
	    SIZE(1);

	case opc_dcmpl: 
	    fprintf(fp, "0x%08x %02x		dcmpl\n", code, *pc);
	    SIZE(1);
	case opc_dcmpg:
	    fprintf(fp, "0x%08x %02x		dcmpg\n", code, *pc);
	    SIZE(1);
	      
	case opc_bipush:	
	    fprintf(fp, "0x%08x %02x%02x		bipush %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_aldc_quick:	
	    fprintf(fp, "0x%08x %02x%02x		aldc_quick %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);
	case opc_sipush:	
	    fprintf(fp, "0x%08x %02x%02x%02x		sipush %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_aldc_w_quick:	
	    fprintf(fp, "0x%08x %02x%02x%02x		aldc_w_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_agetfield_quick:	
	    fprintf(fp, "0x%08x %02x%02x%02x		agetfield_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_aputfield_quick:	
	    fprintf(fp, "0x%08x %02x%02x%02x		aputfield_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_agetstatic_quick:	
	    fprintf(fp, "0x%08x %02x%02x%02x		agetstatic_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_aputstatic_quick:	
	    fprintf(fp, "0x%08x %02x%02x%02x		aputstatic_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_ldc:
	    fprintf(fp, "0x%08x %02x%02x		ldc %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_ldc_quick:
	    fprintf(fp, "0x%08x %02x%02x		ldc_quick %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_ldc_w:
	    fprintf(fp, "0x%08x %02x%02x%02x		ldc_w %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_ldc_w_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		ldc_w_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_ldc2_w:	/* load a two word constant */
	    fprintf(fp, "0x%08x %02x%02x%02x		ldc2_w %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_ldc2_w_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		ldc2_w_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_aconst_null:
	    fprintf(fp, "0x%08x %02x		aconst_null\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_m1:
	    fprintf(fp, "0x%08x %02x		iconst_m1\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_0:
	    fprintf(fp, "0x%08x %02x		iconst_0\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_1:
	    fprintf(fp, "0x%08x %02x		iconst_1\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_2:
	    fprintf(fp, "0x%08x %02x		iconst_2\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_3:
	    fprintf(fp, "0x%08x %02x		iconst_3\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_4:
	    fprintf(fp, "0x%08x %02x		iconst_4\n", code, *pc);
	    SIZE(1);
	  
	case opc_iconst_5:
	    fprintf(fp, "0x%08x %02x		iconst_5\n", code, *pc);
	    SIZE(1);
	  
	case opc_fconst_0:
	    fprintf(fp, "0x%08x %02x		fconst_0\n", code, *pc);
	    SIZE(1);
	  
	case opc_fconst_1:
	    fprintf(fp, "0x%08x %02x		fconst_1\n", code, *pc);
	    SIZE(1);
	  
	case opc_fconst_2:
	    fprintf(fp, "0x%08x %02x		fconst_2\n", code, *pc);
	    SIZE(1);
	  
	case opc_dconst_0:
	    fprintf(fp, "0x%08x %02x		dconst_0\n", code, *pc);
	    SIZE(1);

	case opc_dconst_1:
	    fprintf(fp, "0x%08x %02x		dconst_1\n", code, *pc);
	    SIZE(1);

	case opc_lconst_0:
	    fprintf(fp, "0x%08x %02x		lconst_0\n", code, *pc);
	    SIZE(1);

	case opc_lconst_1:
	    fprintf(fp, "0x%08x %02x		lconst_1\n", code, *pc);
	    SIZE(1);

	case opc_iadd:
	    fprintf(fp, "0x%08x %02x		iadd\n", code, *pc);
	    SIZE(1);
	case opc_ladd:
	    fprintf(fp, "0x%08x %02x		ladd\n", code, *pc);
	    SIZE(1);

	case opc_isub:
	    fprintf(fp, "0x%08x %02x		isub\n", code, *pc);
	    SIZE(1);
	case opc_lsub:
	    fprintf(fp, "0x%08x %02x		lsub\n", code, *pc);
	    SIZE(1);

	case opc_imul:
	    fprintf(fp, "0x%08x %02x		imul\n", code, *pc);
	    SIZE(1);
	case opc_lmul:
	    fprintf(fp, "0x%08x %02x		lmul\n", code, *pc);
	    SIZE(1);

	case opc_iand:
	    fprintf(fp, "0x%08x %02x		iand\n", code, *pc);
	    SIZE(1);
	case opc_land:
	    fprintf(fp, "0x%08x %02x		land\n", code, *pc);
	    SIZE(1);

	case opc_ior:
	    fprintf(fp, "0x%08x %02x		ior\n", code, *pc);
	    SIZE(1);
	case opc_lor:
	    fprintf(fp, "0x%08x %02x		lor\n", code, *pc);
	    SIZE(1);

	case opc_ixor:
	    fprintf(fp, "0x%08x %02x		ixor\n", code, *pc);
	    SIZE(1);
	case opc_lxor:
	    fprintf(fp, "0x%08x %02x		lxor\n", code, *pc);
	    SIZE(1);

	case opc_idiv:
	    fprintf(fp, "0x%08x %02x		idiv\n", code, *pc);
	    SIZE(1);
	case opc_ldiv:
	    fprintf(fp, "0x%08x %02x		ldiv\n", code, *pc);
	    SIZE(1);

	case opc_irem:
	    fprintf(fp, "0x%08x %02x		irem\n", code, *pc);
	    SIZE(1);
	case opc_lrem:
	    fprintf(fp, "0x%08x %02x		lrem\n", code, *pc);
	    SIZE(1);

	case opc_ishl:
	    fprintf(fp, "0x%08x %02x		ishl\n", code, *pc);
	    SIZE(1);
	case opc_ishr:
	    fprintf(fp, "0x%08x %02x		ishr\n", code, *pc);
	    SIZE(1);
	case opc_lshl:
	    fprintf(fp, "0x%08x %02x		lshl\n", code, *pc);
	    SIZE(1);
	case opc_lshr:
	    fprintf(fp, "0x%08x %02x		lshr\n", code, *pc);
	    SIZE(1);

	case opc_iushr:
	    fprintf(fp, "0x%08x %02x		iushr\n", code, *pc);
	    SIZE(1);
	case opc_lushr:
	    fprintf(fp, "0x%08x %02x		lushr\n", code, *pc);
	    SIZE(1); 

	      /* Unary negation */
	case opc_ineg:
	    fprintf(fp, "0x%08x %02x		ineg\n", code, *pc);
	    SIZE(1);

	case opc_lneg:
	    fprintf(fp, "0x%08x %02x		lneg\n", code, *pc);
	    SIZE(1);
	    
	    /* Add a small constant to a local variable */
	case opc_iinc:
	    fprintf(fp, "0x%08x %02x%02x%02x		iinc %02x %02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_fadd:
	    fprintf(fp, "0x%08x %02x		fadd\n", code, *pc);
	    SIZE(1);
	case opc_dadd:
	    fprintf(fp, "0x%08x %02x		dadd\n", code, *pc);
	    SIZE(1);

	case opc_fmul:
	    fprintf(fp, "0x%08x %02x		fmul\n", code, *pc);
	    SIZE(1);
	case opc_dmul:
	    fprintf(fp, "0x%08x %02x		dmul\n", code, *pc);
	    SIZE(1);

	case opc_fsub:
	    fprintf(fp, "0x%08x %02x		fsub\n", code, *pc);
	    SIZE(1);
	case opc_dsub:
	    fprintf(fp, "0x%08x %02x		dsub\n", code, *pc);
	    SIZE(1);

	case opc_fdiv:
	    fprintf(fp, "0x%08x %02x		fdiv\n", code, *pc);
	    SIZE(1);
	case opc_ddiv:
	    fprintf(fp, "0x%08x %02x		ddiv\n", code, *pc);
	    SIZE(1);

	case opc_frem: 
	    fprintf(fp, "0x%08x %02x		frem\n", code, *pc);
	    SIZE(1);
	      
	case opc_drem: 
	    fprintf(fp, "0x%08x %02x		drem\n", code, *pc);
	    SIZE(1);

	case opc_fneg:
	    fprintf(fp, "0x%08x %02x		fneg\n", code, *pc);
	    SIZE(1);

	case opc_dneg:
	    fprintf(fp, "0x%08x %02x		dneg\n", code, *pc);
	    SIZE(1);

	    /* Unconditional goto.  Maybe save return address in register. */
	case opc_jsr:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		jsr %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_goto:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		goto %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_jsr_w:
	    cptr = (unsigned char *)&offset4;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    *(cptr+2) = *(pc+3);
	    *(cptr+3) = *(pc+4);
	    abs = code + offset4;
	    fprintf(fp, "0x%08x %02x%02x%02x%02x%02x	jsr_w %08x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+4), abs);
	    SIZE(5);

	case opc_goto_w:
	    cptr = (unsigned char *)&offset4;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    *(cptr+2) = *(pc+3);
	    *(cptr+3) = *(pc+4);
	    abs = code + offset4;
	    fprintf(fp, "0x%08x %02x%02x%02x%02x%02x	goto_w %08x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+4), abs);
	    SIZE(5);

	    /* Return from subroutine.  June to address in register. */
	case opc_ret:
	    fprintf(fp, "0x%08x %02x%02x		ret %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_if_icmplt:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_icmplt %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_iflt:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		iflt %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_if_icmpgt:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_icmpgt %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifgt:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifgt %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_if_icmple:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_icmple %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifle:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifle %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_if_icmpge:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_icmpge %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifge:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifge %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_if_icmpeq:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_icmpeq %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifeq:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifeq %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_if_acmpeq:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_acmpeq %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifnull:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifnull %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	case opc_if_icmpne:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_icmpne %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifne:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifne %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_if_acmpne:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		if_acmpne %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);
	case opc_ifnonnull:
	    cptr = (unsigned char *)&offset;
	    *cptr = *(pc+1);
	    *(cptr+1) = *(pc+2);
	    abs = code + offset;
	    fprintf(fp, "0x%08x %02x%02x%02x		ifnonnull %08x\n", code, *pc, *(pc+1), *(pc+2), abs);
	    SIZE(3);

	    /* Discard the top item on the stack */
	case opc_pop:
	    fprintf(fp, "0x%08x %02x		pop\n", code, *pc);
	    SIZE(1);

	    /* Discard the top item on the stack */
	case opc_pop2:
	    fprintf(fp, "0x%08x %02x		pop2\n", code, *pc);
	    SIZE(1);

	    /* Duplicate the top item on the stack */
	case opc_dup:
	    fprintf(fp, "0x%08x %02x		dup\n", code, *pc);
	    SIZE(1);

	case opc_dup2:		/* Duplicate the top two items on the stack */
	    fprintf(fp, "0x%08x %02x		dup2\n", code, *pc);
	    SIZE(1);

	case opc_dup_x1:	/* insert S_INFO(-1) on stack past 1 */
	    fprintf(fp, "0x%08x %02x		dup_x1\n", code, *pc);
	    SIZE(1);
	      
	case opc_dup_x2:	/* insert S_INFO(-1) on stack past 2*/
	    fprintf(fp, "0x%08x %02x		dup_x2\n", code, *pc);
	    SIZE(1);

	case opc_dup2_x1:	/* insert S_INFO(-1,-2) on stack past 1 */
	    fprintf(fp, "0x%08x %02x		dup2_x1\n", code, *pc);
	    SIZE(1);
	      
	case opc_dup2_x2:	/* insert S_INFO(-1,2) on stack past 2 */
	    fprintf(fp, "0x%08x %02x		dup2_x2\n", code, *pc);
	    SIZE(1);
	      
	case opc_swap:         /* swap top two elements on the stack */
	    fprintf(fp, "0x%08x %02x		swap\n", code, *pc);
	    SIZE(1);

	    /* Find the length of an array */
	case opc_arraylength:
	    fprintf(fp, "0x%08x %02x		arraylength\n", code, *pc);
	    SIZE(1);

	    /* Goto one of a sequence of targets. */
	case opc_tableswitch: {
            long *lpc = (long *) UCALIGN(pc + 1);


	    fprintf(fp, "0x%08x %02x", code, *pc);
	    cptr = pc+1;
	    while (cptr < (unsigned char *)lpc) {
	     fprintf(fp, "%02x", *cptr++);
	    }
	    fprintf(fp, "	tableswitch\n");
	    fprintf(fp, "         default : %08x\n", lpc[0]);
	    fprintf(fp, "         low    : %08x\n", lpc[1]);
	    fprintf(fp, "         high   : %08x\n", lpc[2]);
	    if (lpc[1] > lpc[2]) {
	     fprintf(fp, "low %08x is greater than high %08x\n", lpc[1], lpc[2]);
    	     fflush(fp);
	     return;
	    }
	    for (j=0; j < lpc[2] - lpc[1] + 1; j = j+1) {
	    fprintf(fp, "         offset : %08x\n", lpc[j+3]);
	    }

/*
	    fprintf(fp, "0x%08x %02x		tableswitch\n", code, *pc);
*/
	    j = (int)((unsigned char *)lpc - pc) +12+(lpc[2]-lpc[1]+1)*4;
            SIZE(j);
	}
	      
	    /* Goto one of a sequence of targets */
	case opc_lookupswitch: {
	    long *lpc = (long *) UCALIGN(pc + 1);
	    int npairs = lpc[1];
	    fprintf(fp, "0x%08x %02x", code, *pc);
	    cptr = pc+1;
	    while (cptr < (unsigned char *)lpc) {
	     fprintf(fp, "%02x", *cptr++);
	    }
	    fprintf(fp, "	lookupswitch\n");
	    fprintf(fp, "           default : %08x\n", lpc[0]);
	    fprintf(fp, "           npairs  : %08x\n", lpc[1]);
	    for (j=0; j < npairs; j = j++) {
	     fprintf(fp, "           pair %d  : %08x %08x\n", j, lpc[j*2+2], lpc[j*2+3]);
	    }
/*
	    fprintf(fp, "0x%08x %02x%02x%02x		lookupswitch\n", code, *pc);
*/
	    j = (int)((unsigned char *)lpc - pc) + 8 + npairs*8;
	    SIZE(j);
	}

	    /* Throw to a given value */
	case opc_athrow:
	    fprintf(fp, "0x%08x %02x		athrow\n", code, *pc);
            SIZE(1);
	    
	case opc_getfield:
	    fprintf(fp, "0x%08x %02x%02x%02x		getfield %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
            SIZE(3);
	case opc_putfield: 
	    fprintf(fp, "0x%08x %02x%02x%02x		putfield %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
            SIZE(3);

	case opc_getstatic:
	    fprintf(fp, "0x%08x %02x%02x%02x		getstatic %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
            SIZE(3);
	case opc_putstatic:
	    fprintf(fp, "0x%08x %02x%02x%02x		putstatic %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
            SIZE(3);

	case opc_invokevirtual:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokevirtual %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);
	case opc_invokenonvirtual:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokespecial %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);
	case opc_invokestatic:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokestatic %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
            SIZE(3);

	case opc_invokeinterface:
	    fprintf(fp, "0x%08x %02x%02x%02x%02x%02x	invokeinterface %02x%02x %02x %02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+4), *(pc+1), *(pc+2), *(pc+3), *(pc+4));
            SIZE(5);

	case opc_putfield_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		putfield_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_getfield_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		getfield_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);
	    
	case opc_putfield2_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		putfield2_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_getfield2_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		getfield2_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);


	case opc_putstatic_quick:   
	    fprintf(fp, "0x%08x %02x%02x%02x		putstatic_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_getstatic_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		getstatic_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_putstatic2_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		putstatic2_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_putfield_quick_w:
	    fprintf(fp, "0x%08x %02x%02x%02x		putfield_quick_w %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_getstatic2_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		getstatic2_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_getfield_quick_w:
	    fprintf(fp, "0x%08x %02x%02x%02x		getfield_quick_w %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_invokenonvirtual_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokenonvirtual_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_invokesuper_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokesuper_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_invokevirtual_quick_w:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokevirtual_quick_w %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_invokestatic_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokestatic_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_invokeinterface_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x%02x%02x	invokeinterface_quick %02x%02x %02x %02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+4), *(pc+1), *(pc+2), *(pc+3), *(pc+4));
	    SIZE(5);

	case opc_invokevirtual_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		invokevirtual_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_instanceof:
	    fprintf(fp, "0x%08x %02x%02x%02x		instanceof %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_instanceof_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		instanceof_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);
	
	case opc_checkcast:
	    fprintf(fp, "0x%08x %02x%02x%02x		checkcast %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_checkcast_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		checkcast_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_new:
	    fprintf(fp, "0x%08x %02x%02x%02x		new %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_new_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		new_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_anewarray:
	    fprintf(fp, "0x%08x %02x%02x%02x		anewarray %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_anewarray_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x		anewarray_quick %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);

	case opc_multianewarray:
	    fprintf(fp, "0x%08x %02x%02x%02x%02x	multianewarray %02x%02x %02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+1), *(pc+2), *(pc+3));
	    SIZE(4);

	case opc_multianewarray_quick:
	    fprintf(fp, "0x%08x %02x%02x%02x%02x	multianewarray_quick %02x%02x %02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+1), *(pc+2), *(pc+3));
	    SIZE(4);

	case opc_newarray:
	    fprintf(fp, "0x%08x %02x%02x		newarray %02x\n", code, *pc, *(pc+1), *(pc+1));
	    SIZE(2);

	case opc_iaload:
	    fprintf(fp, "0x%08x %02x              iaload\n", code, *pc);
	    SIZE(1);
	    
	case opc_laload:
	    fprintf(fp, "0x%08x %02x              laload\n", code, *pc);
	    SIZE(1);

	case opc_faload:
	    fprintf(fp, "0x%08x %02x              faload\n", code, *pc);
	    SIZE(1);

	case opc_daload:
	    fprintf(fp, "0x%08x %02x              daload\n", code, *pc);
	    SIZE(1);

	case opc_aaload:
	    fprintf(fp, "0x%08x %02x              aaload\n", code, *pc);
	    SIZE(1);

	case opc_baload:
	    fprintf(fp, "0x%08x %02x		baload\n", code, *pc);
	    SIZE(1);
	    
	case opc_caload:
	    fprintf(fp, "0x%08x %02x		caload\n", code, *pc);
	    SIZE(1);

	case opc_saload:
	    fprintf(fp, "0x%08x %02x		saload\n", code, *pc);
	    SIZE(1);

	case opc_iastore:
	    fprintf(fp, "0x%08x %02x		iastore\n", code, *pc);
	    SIZE(1);

	case opc_lastore:
	    fprintf(fp, "0x%08x %02x		lastore\n", code, *pc);
	    SIZE(1);

	case opc_fastore:
	    fprintf(fp, "0x%08x %02x		fastore\n", code, *pc);
	    SIZE(1);

	case opc_dastore:
	    fprintf(fp, "0x%08x %02x		dastore\n", code, *pc);
	    SIZE(1);

	case opc_bastore:
	    fprintf(fp, "0x%08x %02x		bastore\n", code, *pc);
	    SIZE(1);

	case opc_castore:
	    fprintf(fp, "0x%08x %02x		castore\n", code, *pc);
	    SIZE(1);

	case opc_sastore:
	    fprintf(fp, "0x%08x %02x		sastore\n", code, *pc);
	    SIZE(1);

	case opc_aastore:
	    fprintf(fp, "0x%08x %02x		aastore\n", code, *pc);
	    SIZE(1);

	case opc_aastore_quick:
	    fprintf(fp, "0x%08x %02x		aastore_quick\n", code, *pc);
	    SIZE(1);

	case opc_monitorenter:
	    fprintf(fp, "0x%08x %02x		monitorenter\n", code, *pc);
	    SIZE(1);

	case opc_monitorexit:
	    fprintf(fp, "0x%08x %02x		monitorexit\n", code, *pc);
	    SIZE(1);
	case exit_sync_method:	
	    fprintf(fp, "0x%08x %02x		exit_sync_method\n", code, *pc);
	    SIZE(1);

	case opc_sethi:	
	    fprintf(fp, "0x%08x %02x%02x%02x\t\tsethi %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+1), *(pc+2));
	    SIZE(3);
	case opc_breakpoint:
	    fprintf(fp, "0x%08x %02x		breakpoint\n", code, *pc);
	    SIZE(1);	/* treat as opc_nop */

        case opc_load_word_index:
          s = "load_word_index"; 
          goto disasm_index_ld_st;

        case opc_load_short_index:
          s = "load_short_index"; 
          goto disasm_index_ld_st;

        case opc_load_char_index:
          s = "load_char_index"; 
          goto disasm_index_ld_st;

        case opc_load_byte_index:
          s = "load_byte_index"; 
          goto disasm_index_ld_st;

        case opc_load_ubyte_index:
          s = "load_ubyte_index"; 
          goto disasm_index_ld_st;

        case opc_store_word_index:
          s = "store_word_index"; 
          goto disasm_index_ld_st;

        case opc_store_short_index:
          s = "store_short_index"; 
          goto disasm_index_ld_st;

        case opc_store_byte_index:
          s = "store_byte_index"; 
          goto disasm_index_ld_st;

        case opc_nastore_word_index:
          s = "nastore_word_index"; 
          goto disasm_index_ld_st;

disasm_index_ld_st:

          if (proc_type != pico)
          {
              fprintf (fp, "0x%08x %02x%02x%02x                 %s %02x %02x\n", code, *pc, *(pc+1), *(pc+2), s, *(pc+1), *(pc+2));
          }
          else
          {
	      fprintf(fp, "Warning: undefined opcode %02x%02x\n", *pc, *(pc+1));
          }
          SIZE (3);
          break;

	case opc_wide:

	    switch(pc[1]) { 
	        case opc_aload:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide aload %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_iload:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide iload %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_fload: 
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide fload %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_lload:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide lload %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_dload: 
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide dload %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_istore:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide istore %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_astore:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide astore %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_fstore:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide fstore %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_lstore:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide lstore %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_dstore: 
	            fprintf(fp, "0x%08x %02x%02x%02x%02x	wide dstore %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+2), *(pc+3));
		    SIZE(4);
	        case opc_iinc:
	            fprintf(fp, "0x%08x %02x%02x%02x%02x%02x%02x	wide iinc %02x%02x %02x%02x\n", code, *pc, *(pc+1), *(pc+2), *(pc+3), *(pc+4), *(pc+5), *(pc+2), *(pc+3), *(pc+4), *(pc+5));
		    SIZE(6);
	        case opc_ret: 
		    fprintf(fp, "0x%08x %02x%02x%02x%02x		wide ret\n", code, *pc, *(pc+1), *(pc+2), *(pc+3));
		    SIZE(4);
	        default:
		    fprintf(fp,"Warning: undefined opcode %02x\n", *pc);
		    SIZE(2);
	    }

	case opc_nonpriv:
	    fprintf(fp,"Warning: undefined opcode %02x%02x\n", *pc, *(pc+1));
	    SIZE(2);
	case opc_priv:
	    switch (*(pc+1)) {
	     case ncstore_byte:
		fprintf(fp, "0x%08x %02x%02x		ncstore_byte\n", code, *pc, *(pc+1));
		break;
	     case store_byte:
		fprintf(fp, "0x%08x %02x%02x		store_byte\n", code, *pc, *(pc+1));
		break;
	     case read_pc:
		fprintf(fp, "0x%08x %02x%02x		read_pc\n", code, *pc, *(pc+1));
		break;
	     case read_vars:
		fprintf(fp, "0x%08x %02x%02x		read_vars\n", code, *pc, *(pc+1));
		break;
	     case read_frame:
		fprintf(fp, "0x%08x %02x%02x		read_frame\n", code, *pc, *(pc+1));
		break;
	     case read_optop:
		fprintf(fp, "0x%08x %02x%02x		read_optop\n", code, *pc, *(pc+1));
		break;
	     case priv_read_oplim:
		fprintf(fp, "0x%08x %02x%02x		priv_read_oplim\n", code, *pc, *(pc+1));
		break;
	     case read_constpool:
		fprintf(fp, "0x%08x %02x%02x		read_const_pool\n", code, *pc, *(pc+1));
		break;
	     case priv_read_psr:
		fprintf(fp, "0x%08x %02x%02x		priv_read_psr\n", code, *pc, *(pc+1));
		break;
	     case write_pc:
		fprintf(fp, "0x%08x %02x%02x		write_pc (ret_from_sub)\n", code, *pc, *(pc+1));
		break;
	     case write_vars:
		fprintf(fp, "0x%08x %02x%02x		write_vars\n", code, *pc, *(pc+1));
		break;
	     case write_frame:
		fprintf(fp, "0x%08x %02x%02x		write_frame\n", code, *pc, *(pc+1));
		break;
	     case write_optop:
		fprintf(fp, "0x%08x %02x%02x		write_optop\n", code, *pc, *(pc+1));
		break;
	     case priv_write_oplim:
		fprintf(fp, "0x%08x %02x%02x		priv_write_oplim\n", code, *pc, *(pc+1));
		break;
	     case write_constpool:
		fprintf(fp, "0x%08x %02x%02x		write_const_pool\n", code, *pc, *(pc+1));
		break;
	     case priv_write_psr:
		fprintf(fp, "0x%08x %02x%02x		priv_write_psr\n", code, *pc, *(pc+1));
		break;
	     case priv_write_trapbase:
		fprintf(fp, "0x%08x %02x%02x		priv_write_trapbase\n", code, *pc, *(pc+1));
		break;
	     case load_ubyte:
		fprintf(fp, "0x%08x %02x%02x		load_ubyte\n", code, *pc, *(pc+1));
		break;
	     case load_byte:
		fprintf(fp, "0x%08x %02x%02x		load_byte\n", code, *pc, *(pc+1));
		break;
	     case load_char:
		fprintf(fp, "0x%08x %02x%02x		load_char\n", code, *pc, *(pc+1));
		break;
	     case load_short:
		fprintf(fp, "0x%08x %02x%02x		load_short\n", code, *pc, *(pc+1));
		break;
	     case load_word:
		fprintf(fp, "0x%08x %02x%02x		load_word\n", code, *pc, *(pc+1));
		break;
	     case priv_ret_from_trap:
		fprintf(fp, "0x%08x %02x%02x		priv_ret_from_trap\n", code, *pc, *(pc+1));
		break;
	     case priv_read_dcache_tag:
		fprintf(fp, "0x%08x %02x%02x		priv_read_dcache_tag\n", code, *pc, *(pc+1));
		break;
	     case priv_read_dcache_data:
		fprintf(fp, "0x%08x %02x%02x		priv_read_dcache_data\n", code, *pc, *(pc+1));
		break;
	     case load_char_oe:
		fprintf(fp, "0x%08x %02x%02x		load_char_oe\n", code, *pc, *(pc+1));
		break;
	     case load_short_oe:
		fprintf(fp, "0x%08x %02x%02x		load_short_oe\n", code, *pc, *(pc+1));
		break;
	     case load_word_oe:
		fprintf(fp, "0x%08x %02x%02x		load_word_oe\n", code, *pc, *(pc+1));
		break;
	     case return0:
		fprintf(fp, "0x%08x %02x%02x		return0\n", code, *pc, *(pc+1));
		break;
	     case priv_read_icache_tag:
		fprintf(fp, "0x%08x %02x%02x		priv_read_icache_tag\n", code, *pc, *(pc+1));
		break;
	     case priv_read_icache_data:
		fprintf(fp, "0x%08x %02x%02x		priv_read_icache_data\n", code, *pc, *(pc+1));
		break;
	     case ncload_ubyte:
		fprintf(fp, "0x%08x %02x%02x		ncload_ubyte\n", code, *pc, *(pc+1));
		break;
	     case ncload_byte:
		fprintf(fp, "0x%08x %02x%02x		ncload_byte\n", code, *pc, *(pc+1));
		break;
	     case ncload_char:
		fprintf(fp, "0x%08x %02x%02x		ncload_char\n", code, *pc, *(pc+1));
		break;
	     case ncload_short:
		fprintf(fp, "0x%08x %02x%02x		ncload_short\n", code, *pc, *(pc+1));
		break;
	     case ncload_word:
		fprintf(fp, "0x%08x %02x%02x		ncload_word\n", code, *pc, *(pc+1));
		break;
	     case priv_powerdown:
		fprintf(fp, "0x%08x %02x%02x		priv_powerdown\n", code, *pc, *(pc+1));
		break;
	     case cache_invalidate:
		fprintf(fp, "0x%08x %02x%02x		cache_invalidate\n", code, *pc, *(pc+1));
		break;
	     case ncload_char_oe:
		fprintf(fp, "0x%08x %02x%02x		ncload_char_oe\n", code, *pc, *(pc+1));
		break;
	     case ncload_short_oe:
		fprintf(fp, "0x%08x %02x%02x		ncload_short_oe\n", code, *pc, *(pc+1));
		break;
	     case ncload_word_oe:
		fprintf(fp, "0x%08x %02x%02x		ncload_word_oe\n", code, *pc, *(pc+1));
		break;
	     case return1:
		fprintf(fp, "0x%08x %02x%02x		return1\n", code, *pc, *(pc+1));
		break;
	     case cache_flush:
		fprintf(fp, "0x%08x %02x%02x		cache_flush\n", code, *pc, *(pc+1));
		break;
	     case cache_index_flush:
		fprintf(fp, "0x%08x %02x%02x		cache_index_flush\n", code, *pc, *(pc+1));
		break;
	     case store_short:
		fprintf(fp, "0x%08x %02x%02x		store_short\n", code, *pc, *(pc+1));
		break;
	     case store_word:
		fprintf(fp, "0x%08x %02x%02x		store_word\n", code, *pc, *(pc+1));
		break;
	     case soft_trap:
		fprintf(fp, "0x%08x %02x%02x		soft_trap\n", code, *pc, *(pc+1));
		break;
	     case priv_write_dcache_tag:
		fprintf(fp, "0x%08x %02x%02x		priv_write_dcache_tag\n", code, *pc, *(pc+1));
		break;
	     case priv_write_dcache_data:
		fprintf(fp, "0x%08x %02x%02x		priv_write_dcache_data\n", code, *pc, *(pc+1));
		break;
	     case store_short_oe:
		fprintf(fp, "0x%08x %02x%02x		store_short_oe\n", code, *pc, *(pc+1));
		break;
	     case store_word_oe:
		fprintf(fp, "0x%08x %02x%02x		store_word_oe\n", code, *pc, *(pc+1));
		break;
	     case return2:
		fprintf(fp, "0x%08x %02x%02x		return2\n", code, *pc, *(pc+1));
		break;
	     case priv_write_icache_tag:
		fprintf(fp, "0x%08x %02x%02x		priv_write_icache_tag\n", code, *pc, *(pc+1));
		break;
	     case priv_write_icache_data:
		fprintf(fp, "0x%08x %02x%02x		priv_write_icache_data\n", code, *pc, *(pc+1));
		break;
	     case ncstore_short:
		fprintf(fp, "0x%08x %02x%02x		ncstore_short\n", code, *pc, *(pc+1));
		break;
	     case ncstore_word:
		fprintf(fp, "0x%08x %02x%02x		ncstore_word\n", code, *pc, *(pc+1));
		break;
	     case priv_reset:
		fprintf(fp, "0x%08x %02x%02x		priv_reset\n", code, *pc, *(pc+1));
		break;
	     case get_current_class:
		fprintf(fp, "0x%08x %02x%02x		get_current_class\n", code, *pc, *(pc+1));
		break;
	     case ncstore_short_oe:
		fprintf(fp, "0x%08x %02x%02x		ncstore_short_oe\n", code, *pc, *(pc+1));
		break;
	     case ncstore_word_oe:
		fprintf(fp, "0x%08x %02x%02x		ncstore_word_oe\n", code, *pc, *(pc+1));
		break;
	     case call:
		fprintf(fp, "0x%08x %02x%02x		call\n", code, *pc, *(pc+1));
		break;
	     case zero_line:
		fprintf(fp, "0x%08x %02x%02x		zero_line\n", code, *pc, *(pc+1));
		break;
	     case priv_update_optop:
		fprintf(fp, "0x%08x %02x%02x		priv_update_optop\n", code, *pc, *(pc+1));
		break;
	     case priv_read_trapbase:
		fprintf(fp, "0x%08x %02x%02x		priv_read_trapbase\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockcount0:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockcount0\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockcount1:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockcount1\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockcount2:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockcount2\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockcount3:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockcount3\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockaddr0:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockaddr0\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockaddr1:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockaddr1\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockaddr2:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockaddr2\n", code, *pc, *(pc+1));
		break;
	     case priv_read_lockaddr3:
		fprintf(fp, "0x%08x %02x%02x		priv_read_lockaddr3\n", code, *pc, *(pc+1));
		break;
	     case priv_read_userrange1:
		fprintf(fp, "0x%08x %02x%02x		priv_read_userrange1\n", code, *pc, *(pc+1));
		break;
	     case priv_read_userrange2:
		fprintf(fp, "0x%08x %02x%02x		priv_read_userrange2\n", code, *pc, *(pc+1));
		break;
	     case priv_read_gc_config:
		fprintf(fp, "0x%08x %02x%02x		priv_read_gc_config\n", code, *pc, *(pc+1));
		break;
	     case priv_read_sc_bottom:
		fprintf(fp, "0x%08x %02x%02x		priv_read_sc_bottom\n", code, *pc, *(pc+1));
		break;
	     case priv_read_global0:
		fprintf(fp, "0x%08x %02x%02x		read_global0\n", code, *pc, *(pc+1));
		break;
	     case priv_read_global1:
		fprintf(fp, "0x%08x %02x%02x		read_global1\n", code, *pc, *(pc+1));
		break;
	     case priv_read_global2:
		fprintf(fp, "0x%08x %02x%02x		read_global2\n", code, *pc, *(pc+1));
		break;
	     case priv_read_global3:
		fprintf(fp, "0x%08x %02x%02x		read_global3\n", code, *pc, *(pc+1));
		break;
	     case priv_read_brk1a:
		fprintf(fp, "0x%08x %02x%02x		priv_read_brk1a\n", code, *pc, *(pc+1));
		break;
	     case priv_read_brk2a:
		fprintf(fp, "0x%08x %02x%02x		priv_read_brk2a\n", code, *pc, *(pc+1));
		break;
	     case priv_read_brk12c:
		fprintf(fp, "0x%08x %02x%02x		priv_read_brk12c\n", code, *pc, *(pc+1));
		break;
	     case priv_read_versionid:
		fprintf(fp, "0x%08x %02x%02x		priv_read_versionid\n", code, *pc, *(pc+1));
		break;
	     case priv_read_hcr:
		fprintf(fp, "0x%08x %02x%02x		priv_read_hcr\n", code, *pc, *(pc+1));
		break;

	     case priv_write_lockcount0:
		fprintf(fp, "0x%08x %02x%02x		priv_write_lockcount0\n", code, *pc, *(pc+1));
		break;
	     case priv_write_lockcount1:
		fprintf(fp, "0x%08x %02x%02x		priv_write_lockcount1\n", code, *pc, *(pc+1));
		break;
	     case priv_write_lockaddr0:
		fprintf(fp, "0x%08x %02x%02x		priv_write_lockaddr0\n", code, *pc, *(pc+1));
		break;
	     case priv_write_lockaddr1:
		fprintf(fp, "0x%08x %02x%02x		priv_write_lockaddr1\n", code, *pc, *(pc+1));
		break;
	     case priv_write_userrange1:
		fprintf(fp, "0x%08x %02x%02x		priv_write_userrange1\n", code, *pc, *(pc+1));
		break;
	     case priv_write_userrange2:
		fprintf(fp, "0x%08x %02x%02x		priv_write_userrange2\n", code, *pc, *(pc+1));
		break;
	     case priv_write_gc_config:
		fprintf(fp, "0x%08x %02x%02x		priv_write_gc_config\n", code, *pc, *(pc+1));
		break;
	     case priv_write_sc_bottom:
		fprintf(fp, "0x%08x %02x%02x		priv_write_sc_bottom\n", code, *pc, *(pc+1));
		break;
	     case priv_write_global0:
		fprintf(fp, "0x%08x %02x%02x		write_global0\n", code, *pc, *(pc+1));
		break;
	     case priv_write_global1:
		fprintf(fp, "0x%08x %02x%02x		write_global1\n", code, *pc, *(pc+1));
		break;
	     case priv_write_global2:
		fprintf(fp, "0x%08x %02x%02x		write_global2\n", code, *pc, *(pc+1));
		break;
	     case priv_write_global3:
		fprintf(fp, "0x%08x %02x%02x		write_global3\n", code, *pc, *(pc+1));
		break;
	     case priv_write_brk1a:
		fprintf(fp, "0x%08x %02x%02x		priv_write_brk1a\n", code, *pc, *(pc+1));
		break;
	     case priv_write_brk2a:
		fprintf(fp, "0x%08x %02x%02x		priv_write_brk2a\n", code, *pc, *(pc+1));
		break;
	     case priv_write_brk12c:
		fprintf(fp, "0x%08x %02x%02x		priv_write_brk12c\n", code, *pc, *(pc+1));
		break;

        case opc_iucmp:
          if (proc_type != pico)
          {
		      fprintf(fp, "0x%08x %02x%02x		iucmp\n", code, *pc, *(pc+1));
              break;
          }

     default:
	fprintf(fp,"Warning: undefined opcode %02x%02x\n", *pc, *(pc+1));
	break;
    } /* end of ext_opcode switch */
    SIZE(2);
    break;

default:
    fprintf(fp,"Warning: undefined opcode %02x\n", *pc);
    SIZE(1);
	    
} /* end of opcode switch */

    }
    fflush(fp);
}

