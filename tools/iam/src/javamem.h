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




#ifndef _JAVAMEM_H_
#define _JAVAMEM_H_

#pragma ident "@(#)javamem.h 1.5 Last modified 10/06/98 11:36:54 SMI"


/* javaMemRead and javaMemWrite should be the primary interface
   routines into memory for this simulator. these routines control
   whether memory requests made by the program go through the various
   caches. the size parameter for javaMemWrite indicates 8/16/32 bit
   write for size = 0,1,2 resply. 

   note that pData is a pointer for both rd/wr

   the char 'c' represents the type of the access - access types are defined
   below with the READ_WRITE macros 
*/

void javaMemRead (unsigned int addr, unsigned int *pData, unsigned int size, char c);
void javaMemWrite (unsigned int addr, void *pData, unsigned int size, char c);

/* read a single byte from the i-stream */
unsigned char get_new_instr(int addr);

/* return 1 if an access with the given address and access type
causes a mem_protection_error, 0 if not */
int causes_mem_protection_error (unsigned int address, char acc_type);


/* READ_WRITE_WORD/DWORD/BYTE/SHORT are the macros to be used for all 
data memory accesses from this simulator. the parameters are:

addr: an address in pJava memory space, (the RelAddr kind, not the AbsAddr kind)

acc_type: used as a one byte parameter for identifying the kind of access 
being done - e.g. an optop-indexed access, a local variable access, 
non-cacheable ld/st, etc. instruction fetches go directly thru the
I$ interface, they never use this interface.

'O' - optop offset (shd never miss S$ - goes to D$ if S$ miss but prints a 
					warning - shd never happen unless dribbler is off)
'V' - vars offset  (lookup in S$, may miss S$)
'F' - frame offset (same as 'V')
'N' - noncacheable access (from ncload/store ops - 
						   directly to memory, no lookup in D$/S$)
'Z' - cacheable access to absolute memory addresses (lookup in D$, not in S$)
'M' - array reference  (lookup in D$, not in S$)
'B' - object reference/microcode access (lookup in D$, not in S$)
'H' - access to an object handle
'D' - dribbler spill/fill/overflow/underflow access (goes to D$/memory) 
'G' - debug access - goes thru S$ and D$ (if enabled), does not cause
	  breakpoint traps or change in D$ state etc
'T' - trap access, goes thru even if an exception is pending. all other
      types (except 'G') abort if an exception is pending, so as to 
	  not change the state of the machine amap. the 'T' access is used
	  ONLY for accesses which set up the trap frame.
'A' - non-allocating write - implies D$ is looked up, but if it misses
      in D$, the write is sent out to memory without fetching the
      line into D$
'X' - is the type of access for a fetch of the trap vector address while
setting up a trap frame.

behaviour of each of these:
'M', 'B', 'Z', 'H', 'D', 'X' are functionally equivalent (kept separate for possible
profiling info generation). the only difference for 'D' is that it sets pj_type 
differently (dribbler access). 
scache is not looked up, dcache is looked up.

'V' and 'F' are functionally equivalent.
scache is looked up, then Dcache.
'G' is functionally equivalent to these, except that it does not
cause exceptions, or disturb cache state.

'O', 'T': optop offset access, should ALWAYS hit in S$ 

'N': neither scache or dcache is looked up, directly to mem

'A': scache not looked up, dcache looked up, no allocation on miss.

var: an lvalue representing the variable from/into which the memory
data will be read/written.

*/

/* the access to READ_WORD may not be aligned if the actual request
is coming from READ_BYTE or READ_SHORT. the full address is passed
into READ_WORD so that javaMemRead can do a breakpoint check (the
full address is reqd for that). javaMemRead needs to internally
word align the addr for all other purposes. javaMemRead semantically
supports only word reads */

#define READ_WORD(addr, acc_type, var) {                 \
  unsigned int READ_WORD_i;                              \
  READ_WORD_i = (unsigned int) addr;                     \
  javaMemRead (READ_WORD_i, (unsigned int *) &(var), 2, (acc_type));    \
}

#define WRITE_WORD(addr, acc_type, var) {                  \
  unsigned int WRITE_WORD_i;                               \
  WRITE_WORD_i = (unsigned int) (addr);                    \
  javaMemWrite (WRITE_WORD_i, (unsigned int *) &(var), 2, (acc_type)); \
}

/* byte ordering machine dependence in the next 2 macros */
#define READ_DWORD(addr, acc_type, var) {                         \
  unsigned int READ_DWORD_i;                                      \
  unsigned char *READ_DWORD_p;                                    \
  READ_DWORD_i = (unsigned int) (addr);                           \
  READ_DWORD_p = (unsigned char *) &(var);                        \
 /* Reading MS 32b's first, assuming big endian host */           \
  javaMemRead (READ_DWORD_i-4, (unsigned int *) READ_DWORD_p, 2, (acc_type));    \
  READ_DWORD_p += 4;                                              \
  javaMemRead (READ_DWORD_i, (unsigned int *) READ_DWORD_p, 2, (acc_type));      \
}

#define WRITE_DWORD(addr, acc_type, var) {                           \
  unsigned int WRITE_DWORD_i;                                        \
  unsigned char *WRITE_DWORD_p;                                      \
  WRITE_DWORD_i = (unsigned int) (addr);                             \
  WRITE_DWORD_p = (unsigned char *) &(var);                          \
  javaMemWrite (WRITE_DWORD_i-4, (unsigned int *) WRITE_DWORD_p, 2, (acc_type)); \
  WRITE_DWORD_p += 4;                                                \
  javaMemWrite (WRITE_DWORD_i, (unsigned int *) WRITE_DWORD_p, 2, (acc_type));   \
}

/* specifically big endian dependence here! */
#define READ_BYTE(addr, acc_type, var) {                           \
unsigned int READ_BYTE_tmp_data;                                   \
javaMemRead (addr, &READ_BYTE_tmp_data, 0, acc_type);              \
var = (signed char) ((READ_BYTE_tmp_data >> ((3-((unsigned int) addr & 3)) * 8)) & 0xFF);\
}

/* specifically big endian dependence here! */
#define READ_SHORT(addr, acc_type, var) {                           \
unsigned int READ_SHORT_tmp_data;                                   \
javaMemRead (addr, &READ_SHORT_tmp_data, 1, acc_type);              \
var = (signed short) (READ_SHORT_tmp_data >> ((2-(addr & 2)) * 8)); \
}

#define WRITE_BYTE(addr, acc_type, var) {                               \
  unsigned int WRITE_BYTE_i;                                            \
  WRITE_BYTE_i = (unsigned int) (addr);                                 \
  javaMemWrite (WRITE_BYTE_i, (unsigned char *) &(var), 0, (acc_type)); \
}

#define WRITE_SHORT(addr, acc_type, var) {                                \
  unsigned int WRITE_SHORT_i;                                             \
  WRITE_SHORT_i = (unsigned int) ((addr));                                \
  javaMemWrite (WRITE_SHORT_i, (unsigned short *) &(var), 1, (acc_type)); \
}

#endif /* _JAVAMEM_H_ */

