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




#ifndef _EXCEPTION_H_
#define _EXCEPTION_H_

#pragma ident "@(#)exception.h 1.6 Last modified 10/06/98 11:36:44 SMI"

#include "global_regs.h"

typedef enum { 
NO_EXCEPTION = 0, 
ASYNC_EXCEPTION = 2,
MEM_PROT_EXCEPTION = 3,
OPLIM_EXCEPTION = 4,
DBR1_EXCEPTION = 5,       /* data breakpoint read - 1 and 2 */
DBR2_EXCEPTION = 6, /* above data_acc exception cos detected earlier by RTL */
INSTR_ACC_EXCEPTION = 7,
ILLEGAL_INSTR_EXCEPTION = 8,
PRIV_INSTR_EXCEPTION = 9,
UNALIGNED_EXCEPTION = 10,
DATA_ACC_EXCEPTION = 11,
IO_ACC_EXCEPTION = 12,
}
ExceptionId;

/* removed oplim from the saved state because we do *not* want it
restored in case of a trap (we have reset the oplim enable bit and
restoring oplim causes it to try to setup an exception again (though
it does no harm) - no reason to save oplim in machine state anyway 
because the only modifications to oplim can be made by write_oplim
(handled correctly by global_regs.c if there is an immediate trap) 
and by an oplim trap occurring. */

typedef struct {
ExceptionId id;
unsigned char     *pc;
stack_item    *vars ;
stack_item    *frame;
stack_item     *optop ;
decafCpItemType    *const_pool;
int        psr;
int        trapbase;
int    userrange1;
int    userrange2;
stack_item *scBottom; 
} ExceptionObject;

/* interface functions */
void vClearAllExceptions ();
int bAnyExceptionPending ();
void vSetupException (ExceptionId eid);
void vDespatchPendingException ();

#endif /* _EXCEPTION_H_ */
