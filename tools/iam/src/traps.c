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




static char *sccsid = "@(#)traps.c 1.8 Last modified 10/06/98 11:37:14 SMI";

#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>

#include "dsv.h"
#include "decaf.h"
#include "sim_config.h"
#include "opcodes.h"
#include "iam.h"
#include "dprint.h"
#include "profiler.h"
#include "javamem.h"
#include "global_regs.h"
#include "statistics.h"
#include "opcode_names.h"
#include "traps.h"

/* we init these trap name table for these entries, other entries
   guaranteed to be NULL. 
   if the trap name is null, it must be a trapping instruction
   look at opcode_names instead
*/
char *trap_names[256] = {
        "reset",
	"async_err",
	"mem_prot_err",
	"data_acc_mem_err",
	"instr_acc_mem_err",
	"priv_instr",
	"illegal_instr",
	"breakpoint1",
	"breakpoint2",
	"mem_addr_not_aligned",
	"data_acc_io_err",
        "unknown",
	"oplim_trap",
        "soft_trap",
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
	"arithmetic_excep",
        NULL,
        NULL,
	"indexoutofbnds_excep",
        NULL,
	"nullptr_excep",
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
	"lock_count_overflow_trap",
	"lock_enter_miss_trap",
	"lock_release_trap",
	"lock_exit_miss_trap",
	"gc_notify",
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
	"ZeroLineEmulationTrap",
	"nmi",
	"irl1",
	"irl2",
	"irl3",
	"irl4",
	"irl5",
	"irl6",
	"irl7",
	"irl8",
	"irl9",
	"irl10",
	"irl11",
	"irl12",
	"irl13",
	"irl14",
	"irl15"
};

void invoke_trap (int tt)

{
    unsigned char *oldpc = pc, *newpc;
	uint unsigned_tmp;

#ifdef TRACING
    insn_trace_record.trap_taken = 1;
	insn_trace_record.trap_type = tt;
#endif TRACING

    vNewSample (&AllTrapsStatistics, instr_since_last_trap);
	instr_since_last_trap = 0;

	flag_setting_up_trap_frame = 1;

    if ((tt != oplim_trap) &&
        ((((uint) optop) - 4*4) < (((uint) oplim) & 0x7FFFFFFF)) &&
        (oplim & 0x80000000))
    {
       /* if setting up the trap frame would cause an oplim trap, which we need to take,
          screw the original trap type and take an oplim trap instead */
        tt = oplim_trap;
        /* reset oplim.enable so updating optop does not create any problems */
        oplim &= 0x7fffffff; 
    }

    trapbase = (int) ((((int)trapbase) & 0xfffff800) | (tt<<3));
	READ_WORD (trapbase, 'X', unsigned_tmp);  /* lookup in D$, not in S$ */
	newpc = (unsigned char *) unsigned_tmp;

    DPRINTF (TRAP_DBG_LVL, ("IAS entering trap at 0x%x, type = 0x%x (%s), branching to 0x%x\n", oldpc, tt, (trap_names[tt] != NULL) ? trap_names[tt] : opcode_names[tt], newpc));

    vUpdateGR (GR_optop, ((int) optop) - 4 * 4);

    unsigned_tmp = psr;
 	WRITE_WORD (OPTOP_OFFSET (4), 'T', unsigned_tmp);
    unsigned_tmp = (uint) oldpc;
	WRITE_WORD (OPTOP_OFFSET (3), 'T', unsigned_tmp);
    unsigned_tmp = (uint) vars;
	WRITE_WORD (OPTOP_OFFSET (2), 'T', unsigned_tmp);
    unsigned_tmp = (uint) frame;
	WRITE_WORD (OPTOP_OFFSET (1), 'T', unsigned_tmp);

   	pc = newpc;
    frame = optop + 3;       /* new frame points to return pc */
    SET_PSR_S;
	RESET_PSR_IE;

#ifdef PROFILING
/*  currently both invokeinterface and invokeinterface_q launch into a new 
    methodframe... if ever invokeinterface_q alone will be doing that,
    change this call to include only inv_if_q */

    mark_block_enter (current_profile_id, 
                     trap_names[tt] != NULL ? trap_names[tt] : opcode_names[tt],
               ((tt == (uint) opc_invokeinterface_quick) || 
                (tt == opc_invokeinterface)) ? TRUE : FALSE, 
                (tt == opc_athrow) ? TRUE : FALSE);
#endif /* PROFILING */
	flag_setting_up_trap_frame = 0;
}
