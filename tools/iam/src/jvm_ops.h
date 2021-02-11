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




#ifndef _JVM_OPS_H_
#define _JVM_OPS_H_

#pragma ident "@(#)jvm_ops.h 1.5 Last modified 10/06/98 11:36:57 SMI"

#include "dsv.h"
#include "iam.h"
#include "javamem.h"

#define JUMP_AND_STACK(offset, stack) { pc += offset; vUpdateGR (GR_optop, ((int) optop) - (stack * JAVAWORDSIZE)); return; }


/* FP instructions generate a trap if either of psr.fpe and hcr.fpp 
are on. trap type is same as opcode. */

#define TRAP_IF_FPU_OFF {                 \
if (!((hcr.fpp == 1) && (psr & 0x800)))  \
{ invoke_trap (opcode); return; } }

/* Get a constant pool index, from a pc */
#define GET_INDEX(ptr) (((int)((ptr)[0]) << 8) | (ptr)[1])

/* COPY_STACK_ITEM copies one stack word from SRC to DEST - both SRC and DEST
should be lvalues. SRC_TYPE and DEST_TYPE refer to the manner in which the
memory read/write requests were made - e.g. referenced from OPTOP, VARS, etc. 
- and is ignored for now
*/

#define COPY_STACK_ITEM(DEST,SRC,DEST_TYPE,SRC_TYPE) { \
unsigned int tmp, dest_addr, src_addr; \
READ_WORD ((SRC), (SRC_TYPE), tmp); \
WRITE_WORD ((DEST), (DEST_TYPE), tmp); }

void vDoJVMOp (unsigned char opcode);

#endif /* _JVM_OPS_H_ */
