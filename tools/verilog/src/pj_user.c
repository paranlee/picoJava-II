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


#include "veriuser.h"
#include "vxl_veriuser.h"

/* #include "vericov.h" */

extern decaf_cm_load();
extern decaf_cm_read();
extern decaf_cm_write();
extern decaf_cm_dump();
extern decaf_cm_direct_dump();
extern decaf_cm_load_method();
extern decaf_cosim();
extern decaf_cosim_cntl();
extern decaf_disasm();
extern decaf_cosim_compare_memory_at_end();
extern decaf_load_traphandlers();
extern decaf_tam_start();
extern decaf_tam_memread();
extern decaf_tam_memwrite();
extern decaf_tam_exit();
extern decaf_tam_poll();
extern decaf_tam_intr();
extern decaf_load_bmem_file();
extern decaf_load_tmem_file();

char *veriuser_version_str =
  "picoJava-II common memory/cosim/disasm\n";

/* extern int record_check(), record_call(), record_misc(); */

int (*endofcompile_routines[])() = 
{
    /*** my_eoc_routine, ***/
    0 /*** final entry must be 0 ***/
};

bool err_intercept(level,facility,code)
int level; char *facility; char *code;
{ return(true); }

s_tfcell veriusertfs[] =
{

/* $decaf_cm_load(classFileArg, needRes) */
   {usertask, 0, 0, 0, decaf_cm_load,0,"$decaf_cm_load", 1},

/* $decaf_cm_read(addr, data, size) */
   {usertask, 0, 0, 0, decaf_cm_read, 0, "$decaf_cm_read", 1},

/* $decaf_cm_write(addr, data, size) */
   {usertask, 0, 0, 0, decaf_cm_write,0,"$decaf_cm_write", 1},

/* dump routines */
   {usertask, 0, 0, 0, decaf_cm_dump,0,"$decaf_cm_dump", 1},
   {usertask, 0, 0, 0, decaf_cm_direct_dump,0,"$decaf_cm_direct_dump", 1},

/* $decaf_cm_load_method(classFile, index, location) */
   {usertask, 0, 0, 0, decaf_cm_load_method,0,"$decaf_cm_load_method", 1},

/* cosimulation */
   {usertask, 0, 0, 0, decaf_cosim,0,"$decaf_cosim", 1},
   {usertask, 0, 0, 0, decaf_cosim_cntl,0,"$decaf_cosim_cntl", 1},
   
/* disasm */
   {usertask, 0, 0, 0, decaf_disasm,0,"$decaf_disasm", 1},

/* compare memory at the end */
   {usertask, 0, 0, 0, decaf_cosim_compare_memory_at_end,0,"$decaf_cosim_compare_memory_at_end", 1},

/* trap handlers loader */
   {usertask, 0, 0, 0, decaf_load_traphandlers ,0,"$decaf_load_traphandlers", 1},

/* tam stuff */
   {usertask, 0, 0, 0, decaf_tam_start ,0,"$decaf_tam_start", 1},
   {usertask, 0, 0, 0, decaf_tam_memread ,0,"$decaf_tam_memread", 1},
   {usertask, 0, 0, 0, decaf_tam_memwrite ,0,"$decaf_tam_memwrite", 1},
   {usertask, 0, 0, 0, decaf_tam_exit ,0,"$decaf_tam_exit", 1},
   {usertask, 0, 0, 0, decaf_tam_poll ,0,"$decaf_tam_poll", 1},
   {usertask, 0, 0, 0, decaf_tam_intr ,0,"$decaf_tam_intr", 1},
   {usertask, 0, 0, 0, decaf_load_bmem_file ,0,"$decaf_load_bmem_file", 1},
   {usertask, 0, 0, 0, decaf_load_tmem_file ,0,"$decaf_load_tmem_file", 1},


/* #include "sscan.c" */

/* #include "vericov.c" */

    {0} /*** final entry must be 0 ***/
};

