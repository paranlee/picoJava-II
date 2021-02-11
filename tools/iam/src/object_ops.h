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




#ifndef _OBJECT_OPS_H_
#define _OBJECT_OPS_H_

#pragma ident "@(#)object_ops.h 1.7 Last modified 10/07/98 14:29:41 SMI"

#include "dsv.h"
#include "decaf.h"

/* is a handle reference if lsb is 1 */
#define IS_HANDLE(objref) (((objref) & 1) == 1)

/* is a null reference if bits 31-0 match 0 */
#define IS_NULL_OBJREF(objref) ((objref) == 0)

#define TRAP_IF_OBJREF_NULL(objref) { if (IS_NULL_OBJREF((objref))) { invoke_trap (nullptr_excep); return; } }

/* define the masking to be done on getting a method vector base
pointer *from an objref* (not from objhintblock or elsewhere.
currently lower 3 bits are masked off because they may be used
for GC. higher 2 address bits also masked */

#define MASK_MV_PTR(mv_ptr) { (mv_ptr) &= 0x3FFFFFF8; }

/* define the masking to be done on *any* use of an objref */
#define MASK_OBJREF(objref) { (objref) &= 0x3FFFFFFC; }

/* returns the address of the next word boundary after the argument */
#define NEXT_ALIGNED_WORD(addr) ((((unsigned int) addr) & 0xFFFFFFFC) + 4)

/* all of these routines simply implement the corresponding instruction.
   PC and OPTOP are already adjusted when they return */

/* 25 object functions - 24 JVM defined op, 1 extended op */
void doInvokevirtual_quick ();
void doInvokestatic_quick ();
void doInvokenonvirtual_quick ();
void doInvokenonvirtual_quick_w ();
void doInvokesuper_quick ();
void doPutfield_quick ();
void doAPutfield_quick ();
void doPutfield2_quick ();
void doGetfield_quick ();
void doAGetfield_quick ();
void doGetfield2_quick ();
void doAPutstatic_quick ();
void doPutstatic_quick ();
void doPutstatic2_quick ();
void doGetstatic_quick ();
void doGetstatic2_quick ();
void doLdc_quick ();
void doLdc_w_quick ();
void doLdc2_w_quick ();
void doTableSwitch ();
void doCheckCast_quick ();
void doInstanceOf_quick ();
void doNonnull_quick ();
void doMonitorEnter ();
void doMonitorExit ();

/* sole extended object-related op */
void doGetCurrentClass ();

/* prints out the name of the object at vars offset 0 */
void reportAthrowObjectType ();

void getMethodNameAndSig (struct decafMethod *method_desc, 
                         char *buf, unsigned int buf_length);
#endif /* _OBJECT_OPS_H_ */
