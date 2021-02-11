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




static char *sccsid = "@(#)exception.c 1.6 Last modified 10/06/98 11:36:43 SMI";

#include <stdio.h>

#include "exception.h"
#include "traps.h"

static ExceptionObject CurrentException;
static ExceptionObject *pCurrentException = &CurrentException;

/* internal implementation functions */
static ExceptionId getExceptionType (ExceptionObject *pe);
static void vSetExceptionType (ExceptionObject *pe, ExceptionId Id);
static void vSaveCPUState (ExceptionObject *pe);

void vClearAllExceptions ()

{
    vSetExceptionType (pCurrentException, NO_EXCEPTION);
}

int bAnyExceptionPending ()

{
    if (getExceptionType (pCurrentException) != NO_EXCEPTION)
	    return 1;
    else
        return 0;
}

void vSetupException (ExceptionId eid)

{
    ExceptionId current_eid;

    if ((current_eid = getExceptionType (pCurrentException)) != NO_EXCEPTION)
	{
        if (eid < current_eid)
		{
		   fprintf (stdout, "IAS warning: overriding pending exception with "
					"priority %d, new exception's priority is %d\n", 
					current_eid, eid);
		   vSetExceptionType (pCurrentException, eid);
        }
		else if (eid == current_eid)
		{
			fprintf (stdout, "IAS warning: priority of pending exception "
					 "is %d, ignored request for raising another exception "
					 "with the same priority\n", current_eid);
	    }
		else
		{
			fprintf (stdout, "IAS warning: priority of pending exception "
					 "is %d, ignored request for raising an exception with "
					 "priority %d\n", current_eid, eid);
	    }
	}
	else
	{
		fprintf (stdout, "IAS: setting up an exception with priority %d\n",
				 eid);
		vSaveCPUState (pCurrentException);
	    vSetExceptionType (pCurrentException, eid);
	}
}

/* despatches pending exceptions, if any. resets all exceptions at the end */

void vDespatchPendingException ()

{
    ExceptionId eid;
	
	if ((eid = getExceptionType (pCurrentException)) == NO_EXCEPTION)
	    return;

    pc = CurrentException.pc;
    vars = CurrentException.vars;
    frame = CurrentException.frame;
	/* raw update to optop, not thru vUpdateGR because we don't want 
	   to cause dribbles */
    optop = CurrentException.optop;
    const_pool = CurrentException.const_pool;
	psr = CurrentException.psr;
    trapbase = CurrentException.trapbase;
    userrange1 = CurrentException.userrange1;
    userrange2 = CurrentException.userrange2;
	scBottom = CurrentException.scBottom;

    eid =  getExceptionType (pCurrentException);

	/* reset the exception type now, in order to allow further
	   exceptions (specifically oplim) to happen during setting
	   up of the trap frame. caller has to repeat this call
	   if s/he is worried that oplim may be caused here */

	vClearAllExceptions ();

	switch (eid) 
	{
      case ASYNC_EXCEPTION:
		invoke_trap (async_err);
		break;
      case MEM_PROT_EXCEPTION:
		invoke_trap (mem_prot_err);
		break;
      case INSTR_ACC_EXCEPTION:
		invoke_trap (instr_acc_mem_err);
		break;
      case ILLEGAL_INSTR_EXCEPTION:
		invoke_trap (illegal_instr);
		break;
      case PRIV_INSTR_EXCEPTION:
		invoke_trap (priv_instr);
		break;
      case OPLIM_EXCEPTION:
		invoke_trap (oplim_trap);
		break;
      case UNALIGNED_EXCEPTION:
		invoke_trap (mem_addr_not_aligned);
		break;
	  case DATA_ACC_EXCEPTION:
		invoke_trap (data_acc_mem_err);
		break;
      case IO_ACC_EXCEPTION:
		invoke_trap (data_acc_io_err);
		break;
      case DBR1_EXCEPTION:
		invoke_trap (breakpoint1);
		break;
      case DBR2_EXCEPTION:
		invoke_trap (breakpoint2);
		break;
	  default: 
		break;
	}
}

static ExceptionId getExceptionType (ExceptionObject *pe)

{
    return (pe->id);
}

static void vSetExceptionType (ExceptionObject *pe, ExceptionId eid)

{
    pe->id = eid;
}

static void vSaveCPUState (ExceptionObject *pe)

{
    pe->pc = pc;
    pe->vars = vars;
    pe->frame = frame;
    pe->optop = optop;
    pe->const_pool = const_pool;
	pe->psr = psr;
    pe->trapbase = trapbase;
    pe->userrange1 = userrange1;
    pe->userrange2 = userrange2;
	pe->scBottom = scBottom;
}

