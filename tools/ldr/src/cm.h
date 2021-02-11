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




#ifndef _CM_H_
#define _CM_H_

#pragma ident "@(#)cm.h 1.21 Last modified 02/28/99 16:57:42 SMI"

#include <stdio.h>

#include "dsv.h"
#include "checkpoint_types.h"
#include "decaf.h"

/* common memory layout */
/*

0x00000000  run-time start-up code
0x0000ffd0  location for reporting cp address in case of some failure codes
0x0000ffd4  location for reporting cp index in case of some failure codes
0x0000fff8  intr ack location
0x0000fffc  end location
0x0000ffcf  syscall magic location
0x00010000  trap table
0x000?????  trap handler           
0x00020000  class table
0x000?????  classes
0x00100000  heap
0x00400000  initial stack pointer

0x2fff0000  scratch area starting address
0x2fffbad0  bad memory start
0x2fffbadf  bad memory end
0x3000bad0  bad i/o start
0x3000badf  bad i/o end
0x30010000  scratch area ending address
0x2f0000c0  Console read/write address 
0x2f0000e0  Debugger serial port read/write address 
(the debugger serial port address is used in ias/pjsim to simulate the 
serial port the debug monitor uses to connect to the debugger host.
reads/writes to this address simulate byte reads/writes by pico to the 
serial port)

*/

/* define the scratch memory */
#define SCRATCH_START 0x2fff0000
#define SCRATCH_SIZE 0x20000
#define SYSCALL_MAGIC_ADDR 0xffe8 /* byte address */
#define BAD_MEMORY_START 0x2fffbad0
#define BAD_IO_START 0x3000bad0
#define BAD_SIZE 16
#define CONSOLE_ADDR 0x2f0000c0 
#define DEBUGGER_SERIAL_PORT_ADDRESS 0x2f0000e0 

/* this has to be consistent with the definitions in sys.h */

#define PROFILER_CMD_ADDR      0xffc0
#define PROFILER_DATA_ADDR     0xffc4
#define PERF_COUNTER_ADDRESS   0xffdc

#define getScratchAbsAddr(addr) ((char *)(addr) + ((int)scratchMemory - SCRATCH_START))
#define getScratchRelAddr(addr) ((char *)(addr) - ((int)scratchMemory - SCRATCH_START))

/* define the common memory */

EXTERN unsigned int CM_SIZE;/* not hard-coded any more, but a variable in cm.c,
                               default 16M */

#define RESET_ADDRESS 0x0
#define TRAP_ADDRESS  0x00010000
#define CLASS_ADDRESS 0x00020000
#define FLUSH_LOCATION 0x0000fff0
#define TRAP_USE_LOCATION 0x0000ffec
#define WATERMARK_LOCATION 0x0000ffec
#define ERROR_CP_LOCATION 0x0000ffd0
#define ERROR_CPINDEX_LOCATION 0x0000ffd4

#define getAbsAddr(addr) ((char *)(addr) + (int)commonMemory)
#define getRelAddr(addr) ((char *)(addr) - (int)commonMemory)
 
/* pj_types for various kinds of transactions */

#define ICACHE_LOAD             0
#define ICACHE_NC_LOAD          2
#define DCACHE_LOAD             4
#define WRITE_BACK              5
#define DCACHE_NC_LOAD          6
#define DCACHE_NC_STORE 	7

typedef enum {pico, maya, pico2dot1} proc_type_t;

EXTERN proc_type_t proc_type;

EXTERN char *commonMemory;
EXTERN char *currentAddress;
EXTERN char *scratchMemory;
 
/* The size defined here is for verification */
#define decafClassTableSize 2048*SIZEB_OF_OBJREF
#define decafClassHashTblSize 259*SIZEB_OF_OBJREF 
#define CLASS_HASHTABLE_ADDR (CLASS_ADDRESS + decafClassTableSize + (ARRAY_HEADER+1)*SIZEB_OF_INT)


EXTERN cmInit(char *startAddr);
EXTERN char *cmCalloc(int, int);
EXTERN char *cmMalloc(int);
EXTERN void cmSetClassTable(decafClass_for_classLoader *classPtr, int m);
EXTERN decafClass_for_classLoader *cmFindClass(char *name);
EXTERN decafMethod_for_classLoader *cmFindMethod(decafClass_for_classLoader *cls, char *name);
EXTERN void dumpOneMethod(decafMethod_for_classLoader *m, FILE *fp);
EXTERN disAsmMethod(decafMethod_for_classLoader *m, FILE *fp);
EXTERN addressCheck(unsigned int addr);
EXTERN void cmSetPJType(int type);

int cm_checkpoint (CPR_REQUEST_T req, FILE *fp);

#endif /* _CM_H_ */

