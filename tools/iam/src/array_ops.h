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




#ifndef _ARRAY_OPS_H_
#define _ARRAY_OPS_H_

#pragma ident "@(#)array_ops.h 1.6 Last modified 10/06/98 11:36:34 SMI"


#include "cm.h"          /* for proc_type */
#include "traps.h"       /* for defn. of nullptr and outofbounds exceptions */
#include "object_ops.h"   /* IS_HANDLE, IS_NULL_OBJREF */
#include "javamem.h"     /* for READ_WORD etc */
#include "global_regs.h" /* for pc value */

/*_________________________HELPER MACROS_________________________________*/

/* masks off bits which shd be ignored in the array ref */

#define MASK_ARRAYREF(arrayRef) { (arrayRef) &= 0x3FFFFFFC; }

/* masks off the array length word to get at the actual array length.
   right now, masks off the top byte. the actual array length has to fit in 
   24 bits */

#define MASK_ARRAY_LENGTH(arrayLen) { (arrayLen) &= ((proc_type == pico) ? 0xFFFFFF : 0xFFFFFFFF); }

/* GET_ARRAY_STORAGE_ADDR:
given an array reference arrayRef, puts the address of the actual storage
for the array in arrayStorage (starting with the length word), going 
thru an object handle if necessary.
basically, all it does is add 4 to the arrayRef if not a handle, or
get the value stored at objref+4 if a handle.
*/

/* unsafe macro! */
#define GET_ARRAY_STORAGE_ADDR(arrayRef, arrayStorage) { \
if (IS_HANDLE(arrayRef))                                 \
{ MASK_ARRAYREF(arrayRef); READ_WORD ((arrayRef)+4, 'H', (arrayStorage)); } \
else { MASK_ARRAYREF(arrayRef); arrayStorage = arrayRef+4; } }

/* checks if array ref is null - if so sets up null ptr trap and 
   causes a return from function 
   same null check for arrayrefs as for objrefs */

#define TRAP_IF_ARRAYREF_NULL(arrayref) { \
if (IS_NULL_OBJREF((arrayref))) { invoke_trap (nullptr_excep); return; } }

/* CHECK_ARRAY_REF checks if the arrayRef is of the array type (bit 1 should
be set to 1). prints a warning message if it is not */

#define CHECK_ARRAY_REF(addr) { \
unsigned i; i = (addr);         \
if ((i & 2) == 0) { fprintf (stdout, "IAS Warning: encountered array reference without bit 1 set, pc = 0x%x, array ref = 0x%x", pc, i); return; } }

/* checks array bounds -- if violated, sets up bounds trap and causes
   a return from function. arrayStorage is the address of actual 
   array storage (thru handle, if necessary) */

#define CHECK_ARRAY_BOUNDS(arrayStorage,index) { \
int i = (index), arrayLen;                       \
READ_WORD (arrayStorage, 'M', arrayLen);         \
MASK_ARRAY_LENGTH (arrayLen);                    \
if ((i < 0) || (i >= arrayLen))                  \
{ invoke_trap (indexoutofbnds_excep); return; } }

/*_____________________________PROTOS____________________________________*/

/* 11 distinct ops (sastore = castore ?) */

void doArrayLength ();
void do32bArrayLoad ();
void do32bArrayStore ();
void do64bArrayLoad ();
void do32bArrayStore ();
void doBaload ();
void doBastore ();
void doSaload ();
void doSastore ();
void doCaload ();
void doCastore ();

#endif  /* _ARRAY_OPS_H_ */
