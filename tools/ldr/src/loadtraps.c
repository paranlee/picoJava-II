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

 ***   Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 *****************************************************************/




static char *sccsid = "@(#)loadtraps.c 1.3 Last modified 10/07/98 14:29:01 SMI";

#include "cm.h"
#include "traptypes.h"
#include "loadtraps.h"

void loadTrapHandlers()
{
    extern int maincheck;

    maincheck = 0;

    /* Basic System Classes: These classes are loaded into the system
    class table */
    if (loadClassFile("java/lang/Class.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load java/lang/Class.class\n");
    }
    else
     printf("class java/lang/Class loaded\n");
    
    if (loadClassFile("java/lang/Field.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load java/lang/Field.class\n");
    }
    else
     printf("class java/lang/Field loaded\n");

    if (loadClassFile("java/lang/Method.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load java/lang/Method.class\n");
    }
    else
     printf("class java/lang/Method loaded\n");

    if (loadClassFile("java/lang/ExceptionBlock.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load java/lang/ExceptionBlock.class\n");
    }
    else
     printf("class java/lang/ExceptionBlock loaded\n");

    /* This file does not need any special fixup, just needs to be loaded 
    */
    if (loadClassFile("java/lang/DecafString.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load java/lang/DecafString.class\n");
    }
    else
     printf("class java/lang/DecafString loaded\n");


    /* Reset code and Emulation Traps: These are loaded into the system as
    regular class files, but the main handler code is also extracted and 
    placed at the trap address specified in the traptable. The CP used for
    the traptable entry is the same as the CP for the class loaded into the
    system. */
    
    /* Template: 
    if (loadClassFile("xxx.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load xxx.class\n");
    }
    else {
     if (loadClassFileMethod("xxx.class", 0, xxx) == DSV_FAIL) {
      printf("Warning : Cannot load xxx handler\n");
     }
     else
     printf("xxx class and handler loaded\n");
    }
    */

    /* reset */
    if (loadClassFile("reset.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load reset.class\n");
    }
    else {
     /* Load the reset handler which is the simulation environment */
     if (loadClassFileMethod("reset.class", 0, RESET_ADDRESS) == DSV_FAIL) {
      printf("ERROR : Cannot load the reset handler\n");
      exit(-1);
     }
     printf("reset class and handler loaded\n");
    }

    /* invokestatic */
    if (loadClassFile("invokestatic.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load invokestatic.class\n");
    }
    else {
     if (loadClassFileMethod("invokestatic.class", 0, INVOKESTATIC) == DSV_FAIL) {
      printf("Warning : Cannot load invokestatic handler\n");
     }
     else
     printf("invokestatic class and handler loaded\n");
    }


    /* getstatic */
    if (loadClassFile("getstatic.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load getstatic.class\n");
    }
    else {
     if (loadClassFileMethod("getstatic.class", 0, GETSTATIC) == DSV_FAIL) {
      printf("Warning : Cannot load getstatic handler\n");
     }
     else
     printf("getstatic class and handler loaded\n");
    }

    /* putstatic */
    if (loadClassFile("putstatic.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load putstatic.class\n");
    }
    else {
     if (loadClassFileMethod("putstatic.class", 0, PUTSTATIC) == DSV_FAIL) {
      printf("Warning : Cannot load putstatic handler\n");
     }
     else
     printf("putstatic class and handler loaded\n");
    }

    /* ldc */
    if (loadClassFile("ldc.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load ldc.class\n");
    }
    else {

     if (loadClassFileMethod("ldc.class", 0, LDC) == DSV_FAIL) {
      printf("Warning : Cannot load ldc handler\n");
     }
     else
     printf("ldc class and handler loaded\n");
    }

    /* ldc_w */
    if (loadClassFile("ldc_w.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load ldc_w.class\n");
    }
    else {
     if (loadClassFileMethod("ldc_w.class", 0, LDC_W) == DSV_FAIL) {
      printf("Warning : Cannot load ldc_w handler\n");
     }
     else
     printf("ldc_w class and handler loaded\n");
    }

    /* ldc2_w */
    if (loadClassFile("ldc2_w.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load ldc2_w.class\n");
    }
    else {
     if (loadClassFileMethod("ldc2_w.class", 0, LDC2_W) == DSV_FAIL) {
      printf("Warning : Cannot load ldc2_w handler\n");
     }
     else
     printf("ldc2_w class and handler loaded\n");
    }

    /* invokeinterface */
    if (loadClassFile("invokeinterface.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load invokeinterface.class\n");
    }
    else {
     if (loadClassFileMethod("invokeinterface.class", 0, INVOKEINTERFACE) == DSV_FAIL) {
      printf("Warning : Cannot load invokeinterface handler\n");
     }
     else
     printf("invokeinterface class and handler loaded\n");
    }

    /* invokevirtual */
    if (loadClassFile("invokevirtual.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load invokevirtual.class\n");
    }
    else {
     if (loadClassFileMethod("invokevirtual.class", 0, INVOKEVIRTUAL) == DSV_FAIL) {
      printf("Warning : Cannot load invokevirtual handler\n");
     }
     else
     printf("invokevirtual class and handler loaded\n");
    }

    /* new */
    if (loadClassFile("new.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load new.class\n");
    }
    else {
     if (loadClassFileMethod("new.class", 0, NEW) == DSV_FAIL) {
      printf("Warning : Cannot load new handler\n");
     }
     else
     printf("new class and handler loaded\n");
    }

    /* newarray */
    if (loadClassFile("newarray.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load newarray.class\n");
    }
    else {
     if (loadClassFileMethod("newarray.class", 0, NEWARRAY) == DSV_FAIL) {
      printf("Warning : Cannot load newarray handler\n");
     }
     else
     printf("newarray class and handler loaded\n");
    }

    /* getfield */
    if (loadClassFile("getfield.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load getfield.class\n");
    }
    else {
     if (loadClassFileMethod("getfield.class", 0, GETFIELD) == DSV_FAIL) {
      printf("Warning : Cannot load getfield handler\n");
     }
     else
     printf("getfield class and handler loaded\n");
    }

    /* putfield */
    if (loadClassFile("putfield.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load putfield.class\n");
    }
    else {
     if (loadClassFileMethod("putfield.class", 0, PUTFIELD) == DSV_FAIL) {
      printf("Warning : Cannot load putfield handler\n");
     }
     else
     printf("putfield class and handler loaded\n");
    }

    /* invokespecial */
    if (loadClassFile("invokespecial.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load invokespecial.class\n");
    }
    else {
     if (loadClassFileMethod("invokespecial.class", 0, INVOKESPECIAL) == DSV_FAIL) {
      printf("Warning : Cannot load invokespecial handler\n");
     }
     else
     printf("invokespecial class and handler loaded\n");
    }

    /* aastore */
    if (loadClassFile("aastore.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load aastore.class\n");
    }
    else {
     if (loadClassFileMethod("aastore.class", 0, AASTORE) == DSV_FAIL) {
      printf("Warning : Cannot load aastore handler\n");
     }
     else
     printf("aastore class and handler loaded\n");
    }

    /* anewarray */
    if (loadClassFile("anewarray.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load anewarray.class\n");
    }
    else {
     if (loadClassFileMethod("anewarray.class", 0, ANEWARRAY) == DSV_FAIL) {
      printf("Warning : Cannot load anewarray handler\n");
     }
     else
     printf("anewarray class and handler loaded\n");
    }

    /* getfield_quick_w */
    if (loadClassFile("getfield_quick_w.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load getfield_quick_w.class\n");
    }
    else {
     if (loadClassFileMethod("getfield_quick_w.class", 0, GETFIELD_QUICK_W) == DSV_FAIL) {
      printf("Warning : Cannot load getfield_quick_w handler\n");
     }
     else
     printf("getfield_quick_w class and handler loaded\n");
    }

    /* putfield_quick_w */
    if (loadClassFile("putfield_quick_w.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load putfield_quick_w.class\n");
    }
    else {
     if (loadClassFileMethod("putfield_quick_w.class", 0, PUTFIELD_QUICK_W) == DSV_FAIL) {
      printf("Warning : Cannot load putfield_quick_w handler\n");
     }
     else
     printf("putfield_quick_w class and handler loaded\n");
     }

    /* lookupswitch */
    if (loadClassFile("lookupswitch.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load lookupswitch.class\n");
    }
    else {
     if (loadClassFileMethod("lookupswitch.class", 0, LOOKUPSWITCH) == DSV_FAIL) {
      printf("Warning : Cannot load lookupswitch handler\n");
     }
     else
     printf("lookupswitch class and handler loaded\n");
     }

    /* multianewarray */
    if (loadClassFile("multianewarray.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load multianewarray.class\n");
    }
    else {
     if (loadClassFileMethod("multianewarray.class", 0, MULTIANEWARRAY) == DSV_FAIL) {
      printf("Warning : Cannot load multianewarray handler\n");
     }
     else
     printf("multianewarray class and handler loaded\n");
    }

    /* checkcast */
    if (loadClassFile("checkcast.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load checkcast.class\n");
    }
    else {
     if (loadClassFileMethod("checkcast.class", 0, CHECKCAST) == DSV_FAIL) {
      printf("Warning : Cannot load checkcast handler\n");
     }
     else
     printf("checkcast class and handler loaded\n");
    }

    /* instanceof */
    if (loadClassFile("instanceof.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load instanceof.class\n");
    }
    else {
     if (loadClassFileMethod("instanceof.class", 0, INSTANCEOF) == DSV_FAIL) {
      printf("Warning : Cannot load instanceof handler\n");
     }
     else
     printf("instanceof class and handler loaded\n");
    }

    /* athrow */
    if (loadClassFile("athrow.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load athrow.class\n");
    }
    else {
     if (loadClassFileMethod("athrow.class", 0, ATHROW) == DSV_FAIL) {
      printf("Warning : Cannot load athrow handler\n");
     }
     else
     printf("athrow class and handler loaded\n");
    }

    /* new_quick */
    if (loadClassFile("new_quick.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load new_quick.class\n");
    }
    else {
     if (loadClassFileMethod("new_quick.class", 0, NEW_QUICK) == DSV_FAIL) {
      printf("Warning : Cannot load new_quick handler\n");
     }
     else
     printf("new_quick class and handler loaded\n");
    }

    /* anewarray_quick */
    if (loadClassFile("anewarray_quick.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load anewarray_quick.class\n");
    }
    else {
     if (loadClassFileMethod("anewarray_quick.class", 0, ANEWARRAY_QUICK) == DSV_FAIL) {
      printf("Warning : Cannot load anewarray_quick handler\n");
     }
     else
     printf("anewarray_quick class and handler loaded\n");
    }

    /* checkcast_quick */
    if (loadClassFile("checkcast_quick.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load checkcast_quick.class\n");
    }
    else {
     if (loadClassFileMethod("checkcast_quick.class", 0, CHECKCAST_QUICK) == DSV_FAIL) {
      printf("Warning : Cannot load checkcast_quick handler\n");
     }
     else
     printf("checkcast_quick class and handler loaded\n");
    }

    /* instanceof_quick */
    if (loadClassFile("instanceof_quick.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load instanceof_quick.class\n");
    }
    else {
     if (loadClassFileMethod("instanceof_quick.class", 0, INSTANCEOF_QUICK) == DSV_FAIL) {
      printf("Warning : Cannot load instanceof_quick handler\n");
     }
     else
     printf("instanceof_quick class and handler loaded\n");
    }

    /* multianewarray_quick */
    if (loadClassFile("multianewarray_quick.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load multianewarray_quick.class\n");
    }
    else {
     if (loadClassFileMethod("multianewarray_quick.class", 0, MULTIANEWARRAY_QUICK) == DSV_FAIL) {
      printf("Warning : Cannot load multianewarray_quick handler\n");
     }
     else
     printf("multianewarray_quick class and handler loaded\n");
    }

    /* invokeinterface_quick */
    if (loadClassFile("invokeinterface_quick.class", 0) == DSV_FAIL) {
     printf("Warning : Cannot load invokeinterface_quick.class\n");
    }
    else {
     if (loadClassFileMethod("invokeinterface_quick.class", 0, INVOKEINTERFACE_QUICK) == DSV_FAIL) {
      printf("Warning : Cannot load invokeinterface_quick handler\n");
     }
     else
     printf("invokeinterface_quick class and handler loaded\n");
    }


    /* Hardware Exceptions & other Traps: These classes are not loaded into 
    the system & may only contain one method defining the exception handler 
    or trap code to be extracted. The cp for the handler class is placed 
    at the traptable entry of the handler after the address of the handler 
    code. */

     if (loadClassFileMethod("soft_trap.class", 0, SOFT_TRAP) == DSV_FAIL) {
      printf("Warning : Cannot load soft_trap handler\n");
     }

     if (loadClassFileMethod("break.class", 0, BREAKPOINT) == DSV_FAIL) {
      printf("Warning : Cannot load break handler\n");
     }

    if (loadClassFileMethod("data_access_mem_error.class", 0, DATA_ACCESS_MEM_ERROR) == DSV_FAIL) {
     printf("Warning : Cannot load data_access_mem_error handler\n");
    }

    if (loadClassFileMethod("instruction_access_mem_error.class", 0, INSTRUCTION_ACCESS_MEM_ERROR) == DSV_FAIL) {
     printf("Warning : Cannot load instruction_access_mem_error handler\n");
    }

    if (loadClassFileMethod("privileged_instruction.class", 0, PRIVILEGED_INSTRUCTION) == DSV_FAIL) {
     printf("Warning : Cannot load privileged_instruction handler\n");
    }

    if (loadClassFileMethod("illegal_instruction.class", 0, ILLEGAL_INSTRUCTION) == DSV_FAIL) {
     printf("Warning : Cannot load illegal_instruction handler\n");
    }

    if (loadClassFileMethod("breakpoint1.class", 0, BREAKPOINT1) == DSV_FAIL) {
     printf("Warning : Cannot load breakpoint1 handler\n");
    }

    if (loadClassFileMethod("breakpoint2.class", 0, BREAKPOINT2) == DSV_FAIL) {
     printf("Warning : Cannot load breakpoint2 handler\n");
    }

    if (loadClassFileMethod("mem_address_not_aligned.class", 0, MEM_ADDRESS_NOT_ALIGNED) == DSV_FAIL) {
     printf("Warning : Cannot load mem_address_not_aligned handler\n");
    }

    if (loadClassFileMethod("data_access_io_error.class", 0, DATA_ACCESS_IO_ERROR) == DSV_FAIL) {
     printf("Warning : Cannot load data_access_io_error handler\n");
    }

    if (loadClassFileMethod("oplim.class", 0, OPLIM_TRAP) == DSV_FAIL) {
     printf("Warning : Cannot load oplim handler\n");
    }

    if (loadClassFileMethod("runtime_arithmetic.class", 0, RUNTIME_ARITHMETIC) == DSV_FAIL) {
     printf("Warning : Cannot load runtime_arithmetic handler\n");
    }

    if (loadClassFileMethod("runtime_indexoutofbnds.class", 0, RUNTIME_INDEXOUTOFBNDS) == DSV_FAIL) {
     printf("Warning : Cannot load runtime_indexoutofbnds handler\n");
    }

    if (loadClassFileMethod("runtime_nullptr.class", 0, RUNTIME_NULLPTR) == DSV_FAIL) {
     printf("Warning : Cannot load runtime_nullptr handler\n");
    }

    if (loadClassFileMethod("lockcountoverflow.class", 0, LOCKCOUNTOVERFLOW) == DSV_FAIL) {
     printf("Warning : Cannot load lockcountoverflow handler\n");
    }

    if (loadClassFileMethod("lockentermiss.class", 0, LOCKENTERMISSTRAP) == DSV_FAIL) {
     printf("Warning : Cannot load lockentermiss handler\n");
    }

    if (loadClassFileMethod("lockrelease.class", 0, LOCKRELEASETRAP) == DSV_FAIL) {
     printf("Warning : Cannot load lockrelease handler\n");
    }

    if (loadClassFileMethod("lockexitmiss.class", 0, LOCKEXITMISSTRAP) == DSV_FAIL) {
     printf("Warning : Cannot load lockexitmiss handler\n");
    }

    if (loadClassFileMethod("lockrelease.class", 0, LOCKRELEASETRAP) == DSV_FAIL) {
     printf("Warning : Cannot load lockrelease handler\n");
    }

    if (loadClassFileMethod("gc_notify.class", 0, GC_NOTIFY) == DSV_FAIL) {
     printf("Warning : Cannot load gc_notify handler\n");
    }
/*
    if (loadClassFileMethod("gc_tag.class", 0, GC_TAG_TRAP) == DSV_FAIL) {
     printf("Warning : Cannot load gc_tag handler\n");
    }
*/

    if (loadClassFileMethod("zeroline.class", 0, ZEROLINETRAP) == DSV_FAIL) {
     printf("Warning : Cannot load zeroline handler\n");
    }

    if (loadClassFileMethod("nmi.class", 0, NMI) == DSV_FAIL) {
     printf("Warning : Cannot load nmi handler\n");
    }
    if (loadClassFileMethod("irl_1.class", 0, IRL1) == DSV_FAIL) {
     printf("Warning : Cannot load irl_1 handler\n");
    }
    if (loadClassFileMethod("irl_2.class", 0, IRL2) == DSV_FAIL) {
     printf("Warning : Cannot load irl_2 handler\n");
    }
    if (loadClassFileMethod("irl_3.class", 0, IRL3) == DSV_FAIL) {
     printf("Warning : Cannot load irl_3 handler\n");
    }
    if (loadClassFileMethod("irl_4.class", 0, IRL4) == DSV_FAIL) {
     printf("Warning : Cannot load irl_4 handler\n");
    }
    if (loadClassFileMethod("irl_5.class", 0, IRL5) == DSV_FAIL) {
     printf("Warning : Cannot load irl_5 handler\n");
    }
    if (loadClassFileMethod("irl_6.class", 0, IRL6) == DSV_FAIL) {
     printf("Warning : Cannot load irl_6 handler\n");
    }
    if (loadClassFileMethod("irl_7.class", 0, IRL7) == DSV_FAIL) {
     printf("Warning : Cannot load irl_7 handler\n");
    }
    if (loadClassFileMethod("irl_8.class", 0, IRL8) == DSV_FAIL) {
     printf("Warning : Cannot load irl_8 handler\n");
    }
    if (loadClassFileMethod("irl_9.class", 0, IRL9) == DSV_FAIL) {
     printf("Warning : Cannot load irl_9 handler\n");
    }
    if (loadClassFileMethod("irl_a.class", 0, IRL10) == DSV_FAIL) {
     printf("Warning : Cannot load irl_a handler\n");
    }
    if (loadClassFileMethod("irl_b.class", 0, IRL11) == DSV_FAIL) {
     printf("Warning : Cannot load irl_b handler\n");
    }
    if (loadClassFileMethod("irl_c.class", 0, IRL12) == DSV_FAIL) {
     printf("Warning : Cannot load irl_c handler\n");
    }
    if (loadClassFileMethod("irl_d.class", 0, IRL13) == DSV_FAIL) {
     printf("Warning : Cannot load irl_d handler\n");
    }
    if (loadClassFileMethod("irl_e.class", 0, IRL14) == DSV_FAIL) {
     printf("Warning : Cannot load irl_e handler\n");
    }
    if (loadClassFileMethod("irl_f.class", 0, IRL15) == DSV_FAIL) {
     printf("Warning : Cannot load irl_f handler\n");
    }
    if (loadClassFileMethod("ldiv.class", 0, LDIV) == DSV_FAIL) {
     printf("Warning : Cannot load ldiv handler\n");
    }
    if (loadClassFileMethod("lmul.class", 0, LMUL) == DSV_FAIL) {
     printf("Warning : Cannot load lmul handler\n");
    }
    if (loadClassFileMethod("lrem.class", 0, LREM) == DSV_FAIL) {
     printf("Warning : Cannot load lrem handler\n");
    }
    if (loadClassFileMethod("fadd.class", 0, FADD) == DSV_FAIL) {
     printf("Warning : Cannot load fadd handler\n");
    }
    if (loadClassFileMethod("dadd.class", 0, DADD) == DSV_FAIL) {
     printf("Warning : Cannot load dadd handler\n");
    }
    if (loadClassFileMethod("fsub.class", 0, FSUB) == DSV_FAIL) {
     printf("Warning : Cannot load fsub handler\n");
    }
    if (loadClassFileMethod("dsub.class", 0, DSUB) == DSV_FAIL) {
     printf("Warning : Cannot load dsub handler\n");
    }
    if (loadClassFileMethod("fmul.class", 0, FMUL) == DSV_FAIL) {
     printf("Warning : Cannot load fmul handler\n");
    }
    if (loadClassFileMethod("dmul.class", 0, DMUL) == DSV_FAIL) {
     printf("Warning : Cannot load dmul handler\n");
    }
    if (loadClassFileMethod("fdiv.class", 0, FDIV) == DSV_FAIL) {
     printf("Warning : Cannot load fdiv handler\n");
    }
    if (loadClassFileMethod("ddiv.class", 0, DDIV) == DSV_FAIL) {
     printf("Warning : Cannot load ddiv handler\n");
    }
    if (loadClassFileMethod("frem.class", 0, FREM) == DSV_FAIL) {
     printf("Warning : Cannot load frem handler\n");
    }
    if (loadClassFileMethod("drem.class", 0, DREM_) == DSV_FAIL) {
     printf("Warning : Cannot load drem handler\n");
    }
    if (loadClassFileMethod("i2f.class", 0, I2F) == DSV_FAIL) {
     printf("Warning : Cannot load i2f handler\n");
    }

    if (loadClassFileMethod("l2f.class", 0, L2F) == DSV_FAIL) {
     printf("Warning : Cannot load l2f handler\n");
    }
    if (loadClassFileMethod("l2d.class", 0, L2D) == DSV_FAIL) {
     printf("Warning : Cannot load l2d handler\n");
    }
    if (loadClassFileMethod("i2d.class", 0, I2D) == DSV_FAIL) {
     printf("Warning : Cannot load i2d handler\n");
    }
    if (loadClassFileMethod("f2i.class", 0, F2I) == DSV_FAIL) {
     printf("Warning : Cannot load f2i handler\n");
    }
    if (loadClassFileMethod("f2l.class", 0, F2L) == DSV_FAIL) {
     printf("Warning : Cannot load f2l handler\n");
    }
    if (loadClassFileMethod("d2i.class", 0, D2I) == DSV_FAIL) {
     printf("Warning : Cannot load d2i handler\n");
    }
    if (loadClassFileMethod("f2d.class", 0, F2D) == DSV_FAIL) {
     printf("Warning : Cannot load f2d handler\n");
    }
    if (loadClassFileMethod("d2l.class", 0, D2L) == DSV_FAIL) {
     printf("Warning : Cannot load d2l handler\n");
    }
    if (loadClassFileMethod("d2f.class", 0, D2F) == DSV_FAIL) {
     printf("Warning : Cannot load d2f handler\n");
    }
    if (loadClassFileMethod("fcmpl.class", 0, FCMPL) == DSV_FAIL) {
     printf("Warning : Cannot load fcmpl handler\n");
    }
    if (loadClassFileMethod("fcmpg.class", 0, FCMPG) == DSV_FAIL) {
     printf("Warning : Cannot load fcmpg handler\n");
    }
    if (loadClassFileMethod("dcmpl.class", 0, DCMPL) == DSV_FAIL) {
     printf("Warning : Cannot load dcmpl handler\n");
    }
    if (loadClassFileMethod("dcmpg.class", 0, DCMPG) == DSV_FAIL) {
     printf("Warning : Cannot load dcmpg handler\n");
    }
    if (loadClassFileMethod("wide.class", 0, WIDE) == DSV_FAIL) {
     printf("Warning : Cannot load wide handler\n");
    }

 /* 0xba, 0xdb and 0xdc are opcodes not impl. */
    if (loadClassFileMethod("unimplemented_instr_0xba.class", 0, UNIMPLEMENTED_INSTR_0) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xba handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xdb.class", 0, UNIMPLEMENTED_INSTR_1) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xdb handler\n");
    }
    if (proc_type != pico2dot1) 
    {
       if (loadClassFileMethod("unimplemented_instr_0xdc.class", 0, UNIMPLEMENTED_INSTR_2) == DSV_FAIL) {
           printf("Warning : Cannot load unimplemented_instr_0xdc handler\n");
       }
    }

    if (proc_type == pico)
    { /* picoJava-II enabled opcodes */
    if (loadClassFileMethod("unimplemented_instr_0xee.class", 0, UNIMPLEMENTED_INSTR_3) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xee handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xef.class", 0, UNIMPLEMENTED_INSTR_4) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xef handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf0.class", 0, UNIMPLEMENTED_INSTR_5) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf0 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf1.class", 0, UNIMPLEMENTED_INSTR_6) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf1 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf2.class", 0, UNIMPLEMENTED_INSTR_7) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf2 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf3.class", 0, UNIMPLEMENTED_INSTR_8) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf3 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf4.class", 0, UNIMPLEMENTED_INSTR_9) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf4 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf5.class", 0, UNIMPLEMENTED_INSTR_10) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf5 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf6.class", 0, UNIMPLEMENTED_INSTR_11) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf6 handler\n");
    }
    } /* end picoJava-II enabled opcodes */
    if (loadClassFileMethod("unimplemented_instr_0xf7.class", 0, UNIMPLEMENTED_INSTR_12) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf7 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf8.class", 0, UNIMPLEMENTED_INSTR_13) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf8 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xf9.class", 0, UNIMPLEMENTED_INSTR_14) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xf9 handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xfa.class", 0, UNIMPLEMENTED_INSTR_15) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xfa handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xfb.class", 0, UNIMPLEMENTED_INSTR_16) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xfb handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xfc.class", 0, UNIMPLEMENTED_INSTR_17) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xfc handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xfd.class", 0, UNIMPLEMENTED_INSTR_18) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xfd handler\n");
    }
    if (loadClassFileMethod("unimplemented_instr_0xfe.class", 0, UNIMPLEMENTED_INSTR_19) == DSV_FAIL) {
     printf("Warning : Cannot load unimplemented_instr_0xfe handler\n");
    }
    if (loadClassFileMethod("asynchronous_error.class", 0, ASYNC_ERROR) == DSV_FAIL) {
     printf("Warning : Cannot load asynchronous_error handler\n");
    }
   
    if (proc_type != pico)
    {
    if (loadClassFileMethod("mem_protection_error.class", 0, MEM_PROTECTION_ERROR) == DSV_FAIL) {
     printf("Warning : Cannot load mem_protection_error handler\n");
    }
    }
    maincheck = 1;

    return;
}

