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



#ifndef _IAM_H_
#define _IAM_H_

#pragma ident "@(#)iam.h 1.16 Last modified 02/28/99 12:03:58 SMI"

#include <stdio.h>

#include "dsv.h"
#include "oobj.h"
#include "checkpoint_types.h"
#include "exception.h"

#define JAVAWORDSIZE 4
#define OPTOP_OFFSET(offset) (&(optop[(offset)]))
#define VARS_OFFSET(offset) (&(vars[(offset)]))
#define FRAME_OFFSET(offset) (&(frame[(offset)]))
#define CP_OFFSET(offset) (&(const_pool[(offset)]))

/* important to maintain order of optop and PC update - update optop
could cause an oplim trap, in which case we need to maintain the 
old PC */
#define SIZE_AND_STACK_RETURN(size, stack) { vUpdateGR (GR_optop, ((int) optop) - (stack) * JAVAWORDSIZE); pc += (size); return; }


#define LOW_PRIORITY_TRAP(trap_type) { if (!bAnyExceptionPending ()) invoke_trap(trap_type);}
/* Flag to mark end of one program. execution continues if executeBytecode
   is called again, even with this variable set */
extern int end_of_simulation; 

/* Flag to mark when executeBytecode returns due to a debugger (gdb) breakpoint. 
   reset everytime executeBytecode is entered */
extern int breakpoint_hit; 

/*
 * 1. All the arguments are relative values to the simulator
 * 2. If classPtr is NULL, the methodPtr points to the code
 * 3. If classPtr is not NULL, the metodPtr points to a method block
 */

extern int ias_cache, ias_scache, ias_fpu_present, ias_boot8;
extern int ias_trace;
extern int wide_prefix;
/* statistics */
int instr_cnt[256];
int ext_hw_instr_cnt[256];

/* executeBytecode: no. of steps to execute, -1 if no limit
   sim_continue = 1 if continue executing from current PC
   sim_continue = 0 if continue executing from 0 */
void executeBytecode (int numOfSteps, int sim_continue);

/* initPico shd be the first thing called in the backend, except for
cache commands. it does all reqd setups, including init'ing caches.
shd be called only AFTER cmInit has been called */

void initPico ();

/* 
   vSetInterrupt is called whenever the state of the IRL pins changes to
   a value other than 0.
   command is left undefined for now.
   irl is the current (new) interrupt level
   irl = 0 signals that the NMI pin is active
   the real IRL pins going to 0 is signalled by a different mechanism - 
   an ncwrite to a prespecified location - currently 0xfff8.
*/

void vSetInterrupt (int command, unsigned int irl);

/* the following 3 routines read a signed byte/short/word respectively 
   in big-endian format from the Istream at addr 
   NB: all 3 routines return signed quantities to the user - 
   it is the user's responsibility to convert to unsigned if the number
   is to be interpreted as unsigned!!! */

char IstreamReadByte (unsigned char *addr);
short IstreamReadShort (unsigned char *addr);
int IstreamReadWord (unsigned char *addr);

/* 
  pico_breakpoint_match returns 1 if the given type of address matches 
     the breakpoint register specified, 0 otherwise. this is for the pico 
     h/w breakpoint mechanism, not the simulator breakpoint mechanism, which 
     is handled separately.

  breakpoint_reg_no is either 1 or 2 (brk1a or brk2a)
  address is the addr to use
  data_brkpt is 1 if we are looking for data breakpoints, 0 for code brkpts
  rnotw 1 is 1 if user is checking a match for a data read on the address, 
    0 if matching a data write, don't care for code brkpts
*/
int pico_breakpoint_match (int breakpoint_reg_no, int address, int data_brkpt, int rnotw);

/* this macro shd not do a return  on an align error becos the same access
may cause higher priority exceptions like mem prot violation. hence allow insn 
to continue and resolve between all exceptions at the end */

#define CHECK_ADDRESS_ALIGNMENT(addr,data_size) {                           \
if ((addr) & ((1<<(data_size)) - 1)){                                       \
    fprintf(stdout,"IAS warning: Address 0x%x not aligned, size %d\n", (addr), (data_size));        \
    vSetupException (UNALIGNED_EXCEPTION); }}

/* if PSR.ACE = 1, and the address lies outside bounds indicated
by USERRANGE, generate a trap */


#define IS_LE_ADDRESS(address) (((address) & 0x40000000) ? 1 : 0)
#define IS_NC_ADDRESS(address) ((((address) & 0x30000000) == 0x30000000) ? 1:0)

#define   BYTE_MASK0     0x000000FF
#define   BYTE_MASK1     0x0000FF00
#define   BYTE_MASK2     0x00FF0000
#define   SHORT_MASK0    0x0000FFFF
#define   SHORT_MASK1    0xFFFF0000

/*** WARNING: arguments to SWAP_SHORT and SWAP_WORD shd be
unsigned, otherwise (shifting >> 24) etc can have unexpected
results. 
*****/
#define SWAP_SHORT(ext_value1) {\
int ext_value2 = ((unsigned short)ext_value1 & BYTE_MASK0); \
ext_value1 = (((unsigned short)ext_value1>>8) | ((unsigned short)ext_value2<<8)); \
}

#define SWAP_WORD(value) { \
value = ((value>>24) | ((value & BYTE_MASK0) << 24) | \
		 ((value & BYTE_MASK1) << 8) | ((value & BYTE_MASK2) >> 8)); \
}

int iam_checkpoint (CPR_REQUEST_T req, FILE *fp);

#endif /* _IAM_H_ */
