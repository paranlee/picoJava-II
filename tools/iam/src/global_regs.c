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



 
static char *sccsid = "@(#)global_regs.c 1.18 Last modified 10/07/98 14:29:48 SMI";

#include <assert.h>

#include "dsv.h"
#include "decaf.h"
#include "global_regs.h"
#include "exception.h" 
#include "iam.h"

/* writes "value" into the global register with index GR_num 
   currently, only OPTOP supported */

const GR_optop = 0;
const GR_sc_bottom = 1;
const GR_psr = 2;
const GR_oplim = 4;

/* PicoJava Registers */
unsigned char *pc;
stack_item    *vars ;
stack_item    *frame;
stack_item    *optop ;
unsigned int  oplim;

decafCpItemType *const_pool;
/* psr: dbl = dbh = bm8 = ace = gce = fpe = dce = 
		ice = aem = re = fle = ie = pil = 0, SU = 1 */
int        psr = 0x00000020;
int        trapbase;
unsigned int    lockCount[2], lockAddr[2];
unsigned int    userrange1, userrange2;
unsigned int    gcConfig;
unsigned int    brk1a, brk2a; 
struct brk12c_t brk12c;
unsigned int    versionId;
stack_item      *scBottom;
unsigned int    global0, global1, global2, global3;

struct hcr_t hcr;

/* other global state */
unsigned int bPowerDownState, bResetState, bNMIState, uIRLState;
unsigned int sc_bottom_min, sc_bottom_max;
unsigned int program_exit_code;  /* register set to the program exit code */
unsigned int exit_on_warning = 0;    /* if 1, treat warnings as fatal */

/* flag_return_opcode is updated at the beginning of each instruction 
with either 1 or 0 (1 if the instruction about to be executed is 
a JVM *return instruction, or a C return0/1/2, 0 otherwise) */
unsigned int flag_return_opcode; 

/* is set to 1 during setting up of a trap frame */
unsigned int flag_setting_up_trap_frame = 0;

/* is usually 0, goes to 1 if bkpt1 is hit, 2 if bkpt2 is hit */
unsigned flag_pico_write_brkpt_pending = 0; 

unsigned flag_sim_read_brkpt_pending = 0, flag_sim_write_brkpt_pending = 0;
unsigned int flag_fast_monitors = 0;

/* statistics stuff */
unsigned int instr_since_last_intr = 0;
unsigned int instr_since_last_trap = 0;

StatisticsObject InterruptStatistics;
StatisticsObject AllTrapsStatistics;

int64_t icount = 0, next_sched_intr_icount = -1;
int64_t checkcast_quick_insns = 0, checkcast_quick_traps = 0;
int64_t instanceof_quick_insns = 0, instanceof_quick_traps = 0;
int64_t monitorenter_insns = 0, monitorenter_misses = 0;
int64_t monitorenter_overflows = 0;
int64_t monitorexit_insns = 0, monitorexit_misses = 0;
int64_t monitorexit_overflows = 0, monitorexit_releases = 0;
int64_t dcache_reads = 0, dcache_writes = 0;
int64_t dcache_read_misses = 0, dcache_write_misses = 0;
int64_t dcache_read_misses_causing_wb = 0, dcache_write_misses_causing_wb = 0;
int64_t acmp_branches, icmp_branches;
int64_t lock_enter_hits[2], lock_exit_hits[2];
int64_t fast_monitors_saved_the_day = 0;

int64_t inlineStats[5][8];

/* insn_trace_record has to be globally visible, so declared here */
insn_trace_record_t insn_trace_record; 

/* end picojava registers */

extern int ias_scache; /* ?? i hate declaring things like this, but there is 
						  option, right now */
void vUpdateGR (unsigned int GR_num, unsigned int value)

{
    unsigned int oldOptop;

    switch (GR_num)
	{
	  case 0:
        oldOptop = (unsigned int) optop;

/* what to do on an oplim trap depends on whether this optop update
   was caused by trying to set up a trap frame. if setting up trap frame,
   allow the optop to be updated no matter what and check for oplim exception
   at the end. if any other kind of write to optop, check for oplim
   first, don't allow the update to optop if oplim overflow is detected
*/

        if (flag_setting_up_trap_frame)
		{
            optop = (stack_item *) value;
		}
		else
		{
		    if ((oplim & 0x80000000) &&
			    ((oplim & 0x7FFFFFFC) > (unsigned int) value))
		    {
			    vSetupException (OPLIM_EXCEPTION);
			    oplim &= 0x7FFFFFFF; /* oplim enable = 0 */
                return;   
            }

            optop = (stack_item *) value;
		}

        if (ias_scache && (psr & 0x80))
			vUpdateSCache (oldOptop);
		break;

      case 1:
		scBottom = (stack_item *) value;

		if ((psr & 0x80) && ((unsigned int) scBottom > sc_bottom_max))
		    sc_bottom_max = (unsigned int) scBottom;
        else if ((psr & 0x80) && ((unsigned int) scBottom < sc_bottom_min))
			sc_bottom_min = (unsigned int) scBottom;

		break;
      case 2:
		psr = value & 0x007FFFFF;
		break;
      case 4:
		/* update oplim first, then flag an exception if needed */
		oplim = value & 0xFFFFFFFC;
		if ((oplim & 0x80000000) &&
			((oplim & 0x7FFFFFFC) > (unsigned int) optop))
		{
			vSetupException (OPLIM_EXCEPTION);
			oplim &= 0x7FFFFFFF; /* oplim enable = 0 */
        }
        break;
      default: assert (0);
    }
}

#define WRITE_REG(reg) CHECKING_FWRITE (&reg, sizeof(reg), 1, fp)
#define READ_REG(reg) CHECKING_FREAD (&reg, sizeof(reg), 1, fp)

int global_regs_checkpoint (CPR_REQUEST_T req, FILE *fp)

{

    switch (req)
    {
      case CPR_QUERY:
      {
        /* always ready to checkpoint */
        break;
      }
      case CPR_CHECKPOINT:
      {

#define CHECKING_FWRITE_ELEMENT(a) CHECKING_FWRITE (&a, sizeof(a), 1, fp)

        CHECKING_FWRITE_ELEMENT (icount)
        CHECKING_FWRITE_ELEMENT (checkcast_quick_insns)
        CHECKING_FWRITE_ELEMENT (checkcast_quick_traps)
        CHECKING_FWRITE_ELEMENT (instanceof_quick_insns) 
        CHECKING_FWRITE_ELEMENT (instanceof_quick_traps)
        CHECKING_FWRITE_ELEMENT (monitorenter_insns)
        CHECKING_FWRITE_ELEMENT (monitorenter_misses)
        CHECKING_FWRITE_ELEMENT (monitorenter_overflows)
        CHECKING_FWRITE_ELEMENT (monitorexit_insns)
        CHECKING_FWRITE_ELEMENT (monitorexit_misses)
        CHECKING_FWRITE_ELEMENT (monitorexit_overflows) 
        CHECKING_FWRITE_ELEMENT (monitorexit_releases)
        CHECKING_FWRITE_ELEMENT (dcache_reads) 
        CHECKING_FWRITE_ELEMENT (dcache_writes)
        CHECKING_FWRITE_ELEMENT (dcache_read_misses) 
        CHECKING_FWRITE_ELEMENT (dcache_write_misses)
        CHECKING_FWRITE_ELEMENT (dcache_read_misses_causing_wb)
        CHECKING_FWRITE_ELEMENT (dcache_write_misses_causing_wb)
        CHECKING_FWRITE_ELEMENT (acmp_branches)
        CHECKING_FWRITE_ELEMENT (icmp_branches)
        CHECKING_FWRITE_ELEMENT (inlineStats)

#undef CHECKING_FWRITE_ELEMENT

	/* start writing out all reg values */
        WRITE_REG (pc)
        WRITE_REG (vars)
        WRITE_REG (frame)
        WRITE_REG (optop)
        WRITE_REG (oplim)
        WRITE_REG (const_pool)
        WRITE_REG (psr)
        WRITE_REG (trapbase)
        WRITE_REG (lockCount[0])
        WRITE_REG (lockCount[1])
        WRITE_REG (lockAddr[0])
        WRITE_REG (lockAddr[1])
        WRITE_REG (userrange1)        
        WRITE_REG (userrange2)
        WRITE_REG (gcConfig)
        WRITE_REG (brk1a)
        WRITE_REG (brk2a)
        WRITE_REG (brk12c)
        WRITE_REG (versionId)
        WRITE_REG (hcr)
        WRITE_REG (scBottom)
        WRITE_REG (global0)
        WRITE_REG (global1)
        WRITE_REG (global2)
        WRITE_REG (global3)
   
        CHECKING_FWRITE (&InterruptStatistics, sizeof (InterruptStatistics), 1, fp)
        CHECKING_FWRITE (&AllTrapsStatistics, sizeof (AllTrapsStatistics), 1, fp)

        break;
      }

      case CPR_RESTART:
      {

#define CHECKING_FREAD_ELEMENT(a) CHECKING_FREAD (&a, sizeof(a), 1, fp)

        CHECKING_FREAD_ELEMENT (icount)
        CHECKING_FREAD_ELEMENT (checkcast_quick_insns)
        CHECKING_FREAD_ELEMENT (checkcast_quick_traps)
        CHECKING_FREAD_ELEMENT (instanceof_quick_insns) 
        CHECKING_FREAD_ELEMENT (instanceof_quick_traps)
        CHECKING_FREAD_ELEMENT (monitorenter_insns)
        CHECKING_FREAD_ELEMENT (monitorenter_misses)
        CHECKING_FREAD_ELEMENT (monitorenter_overflows)
        CHECKING_FREAD_ELEMENT (monitorexit_insns)
        CHECKING_FREAD_ELEMENT (monitorexit_misses)
        CHECKING_FREAD_ELEMENT (monitorexit_overflows) 
        CHECKING_FREAD_ELEMENT (monitorexit_releases)
        CHECKING_FREAD_ELEMENT (dcache_reads) 
        CHECKING_FREAD_ELEMENT (dcache_writes)
        CHECKING_FREAD_ELEMENT (dcache_read_misses) 
        CHECKING_FREAD_ELEMENT (dcache_write_misses)
        CHECKING_FREAD_ELEMENT (dcache_read_misses_causing_wb)
        CHECKING_FREAD_ELEMENT (dcache_write_misses_causing_wb)
        CHECKING_FREAD_ELEMENT (acmp_branches)
        CHECKING_FREAD_ELEMENT (icmp_branches)
        CHECKING_FREAD_ELEMENT (inlineStats)

#undef CHECKING_FREAD_ELEMENT
	/* read in all reg values */
        READ_REG (pc)
        READ_REG (vars)
        READ_REG (frame)
        READ_REG (optop)
        READ_REG (oplim)
        READ_REG (const_pool)
        READ_REG (psr)
        READ_REG (trapbase)
        READ_REG (lockCount[0])
        READ_REG (lockCount[1])
        READ_REG (lockAddr[0])
        READ_REG (lockAddr[1])
        READ_REG (userrange1)        
        READ_REG (userrange2)
        READ_REG (gcConfig)
        READ_REG (brk1a)
        READ_REG (brk2a)
        READ_REG (brk12c)
        READ_REG (versionId)
        READ_REG (hcr)
        READ_REG (scBottom)
        READ_REG (global0)
        READ_REG (global1)
        READ_REG (global2)
        READ_REG (global3)

        CHECKING_FREAD (&InterruptStatistics, sizeof (InterruptStatistics), 1, fp)
        CHECKING_FREAD (&AllTrapsStatistics, sizeof (AllTrapsStatistics), 1, fp)
        break;
      }
    }

    return (0);
}

