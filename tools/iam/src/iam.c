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
 
 
 

static char *sccsid = "@(#)iam.c 1.34 Last modified 02/28/99 16:52:08 SMI";

#include <sys/types.h>
#include <string.h> 
#include <stdarg.h> 
#include <stdlib.h>
#include <signal.h>

#include "dsv.h"
#include "cm.h"
#include "decaf.h"
#include "iam.h"
#include "sim_config.h"
#include "opcodes.h"
#include "traps.h"
#include "typedefs.h"
#include "jmath.h"
#include "javamem.h"
#include "dprint.h"
#include "jvm_ops.h"
#include "ext_ops.h"
#include "statistics.h"
#include "global_regs.h"
#include "gdb_interface.h"
#include "tracing.h"
#include "breakpoints.h"
#include "profiler.h"
#include "commands.h"
#include "iam.h"

/* various simulation control parameters */
int ias_scache = 1, ias_dcache_size = 5, ias_icache_size = 5, ias_fpu_present = 1, ias_trace = 0, ias_boot8 = 0;
int breakpoint_hit = 0;
int end_of_simulation = 0;

/* if wide_prefix is 1, indicates the current instruction had a wide prefix */
int wide_prefix;

/* these init'sations are 1-time only, and do not get re-executed on a reset */
static unsigned char bInstructionLimit = 1;
static int64_t nMaxInstructions = 5000000LL; /* 5M instructions */

static int opc_first_unused_index;

/* statistics */
int instr_cnt[256];
int ext_hw_instr_cnt[256];

void (*prev_SIGINT_disp)(int); /* note this is not part of checkpointed state */
int simulation_interrupted = 0;    /* goes to 0 if control-C is pressed */

static void sim_ctrl_c (int i)
{
    printf ("Ctrl-C detected, simulation interrupted\n");
    simulation_interrupted = 1;
}

/* no. of steps to execute, -1 if no limit
   sim_continue = 1 if continue executing from current PC
   sim_continue = 0 if continue executing from 0 */

void executeBytecode (int numOfSteps, int sim_continue)

{
    decafMethod *absMethodPtr;
    unsigned char opcode, ext_opcode;
    char *code;
    unsigned int method_code_addr, unsigned_tmp;

    /* when set suppresses code brkpts in 1st instr of run */
    int first_instruction_in_run; 

    int brkpt_id;
    insn_trace_record_t insn_trace_record;

    if (!sim_continue)
        pc = (unsigned char *) 0;

    /* reset the 3 exit conditions */
    simulation_interrupted = 0;
    breakpoint_hit = 0;
    end_of_simulation = 0;

    first_instruction_in_run = 1;
    flag_sim_read_brkpt_pending = flag_sim_write_brkpt_pending = 0;

    /* install our signal handler */
    prev_SIGINT_disp = signal(SIGINT, sim_ctrl_c); 

    /******* Main interpreter loop   *******/
    /****  warning: do not return from inside loop without
      resetting SIGINT handler ****/

    while (!end_of_simulation && !simulation_interrupted)
    {
        if (numOfSteps == 0)
        {
            breakpoint_hit = 1;
            break;
        }
        else if (numOfSteps != -1)
                numOfSteps--;

        if (bInstructionLimit &&
            (ll_ge (icount, nMaxInstructions)))
        {
            fprintf (stderr, "IAS: Test FAILED : ias has crossed execution \
limit of %lld instructions, aborting simulation\n", nMaxInstructions);
            exit (1);
        }

        vClearAllExceptions ();

#ifdef SIM_BREAKPOINTS 
        /* check pending data brkpts first, then code brkpts */

        if (flag_sim_read_brkpt_pending || flag_sim_write_brkpt_pending)
        {
             breakpoint_hit = 1;
             break;
        }

        if ((!first_instruction_in_run) &&
            ((brkpt_id = brkpt_match ((unsigned int) pc, 0, BRKPT_EXEC)) != -1))
        {
             breakpoint_hit = 1;
             BRKPT_PRINTF (("Code breakpoint hit at address 0x%x\n", (unsigned int) pc));
             break;
        }

        first_instruction_in_run = 0;
#endif

#ifdef PICO_INTERRUPTS
        if (ll_eq (icount, next_sched_intr_icount))
        {
            intr_dispatch ();
            intr_schedule_next ();
        }

        /* take an interrupt if psr.ie enabled and NMI or current irl 
           is greater than psr.pil */

        if (psr & 0x10)
        {
	    if (bNMIState)
	    {
		vNewSample (&InterruptStatistics, instr_since_last_intr);
		instr_since_last_intr = 0;
		bPowerDownState = 0;
		invoke_trap (nmi);
                continue;
	    }

            if (uIRLState > (psr & 0xf)) 
            {
                vNewSample (&InterruptStatistics, instr_since_last_intr);
                instr_since_last_intr = 0;
                bPowerDownState = 0;
                invoke_trap (interrupt_level_tt_base + uIRLState - 1);
                continue;
            }
        }

        /* if we're in powerdown, we will behave like a nop */
        if (bPowerDownState)
            continue;
#endif  /* PICO_INTERRUPTS */

#ifdef PICO_BREAKPOINTS
        if (pico_breakpoint_match (1, (unsigned int) pc, 0, 0))
        { 
             vSetupException (DBR1_EXCEPTION);
             goto CheckExceptions;
        }

        if (pico_breakpoint_match (2, (unsigned int) pc, 0, 0))
        { 
             vSetupException (DBR2_EXCEPTION);
             goto CheckExceptions;
        }
#endif

        wide_prefix = 0; /* wide always traps now */
        opcode = IstreamReadByte (pc);

#ifdef TRACING
        /* initialise the trace structure */
        insn_trace_record.begin_pc = (unsigned int) pc;
        insn_trace_record.insnbyte0 = opcode;
        insn_trace_record.begin_optop = (unsigned int) optop;
        insn_trace_record.begin_vars = (unsigned int) vars;
        insn_trace_record.trap_taken = 0;
        {
            unsigned int top0, top1, top2, top3;
            READ_WORD (OPTOP_OFFSET (1), 'O', top0);
            READ_WORD (OPTOP_OFFSET (2), 'O', top1);
            READ_WORD (OPTOP_OFFSET (3), 'O', top2);
            READ_WORD (OPTOP_OFFSET (4), 'O', top3);
            insn_trace_record.top0 = top0;
            insn_trace_record.top1 = top1;
            insn_trace_record.top2 = top2;
            insn_trace_record.top3 = top3;
        }
#endif TRACING

/* check exceptions here to see if we got a bad opcode byte. if we did,
   don't even attempt to execute the instruction (though instr_acc_err
   is highest priority after breakpoints,) it *may* break something (though
   it probably shdn't) since we might dispatch any arbitrary instruction 
   also applies to 2nd byte of extended opcodes */
   
        if (bAnyExceptionPending ())
            goto CheckExceptions;

        DPRINTF (REGDUMP_DBG_LVL, ("PC=%08x PSR=%08x Optop=%08x Vars=%08x Frame=%08x Constpool=%08X Trapbase=%08x\n", pc, psr, optop, vars, frame, const_pool, trapbase))
        
        if (ias_trace >= INSTR_TRACE_DBG_LVL)
            disAssembly (pc, 1, stdout);

#ifdef PROFILING
        if ((current_profile != NULL) && 
            (!current_profile->is_frozen) && (current_profile->is_enabled))
        {
             current_profile->profile_icount = 
                 ll_add(current_profile->profile_icount, 1LL);
        }
#endif PROFILING

        if (opcode != opc_hardware) 
        {
            instr_cnt[opcode]++;

            /* mark if it is a return so S$ will know to discard, not save
               on underflow */ 
            flag_return_opcode = 
                ((opcode == opc_areturn) || (opcode == opc_ireturn) || 
                 (opcode == opc_freturn) || (opcode == opc_dreturn) || 
                 (opcode == opc_lreturn) || (opcode == opc_return)) ? 1 : 0;

            if ((opcode == opc_breakpoint) && (running_under_gdb))
            {
                breakpoint_hit = 1;
                break;
            }

            /* trap on unimpl. bytecodes */
            if ((opcode == opc_invokevirtualobject_quick) ||
                (opcode == 0xba) ||
                ((opcode >= opc_first_unused_index) && (opcode < opc_hardware)))
            {
                LOW_PRIORITY_TRAP (opcode);
                goto CheckExceptions;
            }
            else if (((proc_type == pico) || (proc_type == maya)) &&
                     (opcode == opc_aastore_quick))
            {
                LOW_PRIORITY_TRAP (opcode);
                goto CheckExceptions;
            }
            else
            {
#ifdef TRACING
                insn_trace_record.opcode = opcode;
#endif
                vDoJVMOp (opcode);
            }
        }
        else
        {
            ext_opcode = IstreamReadByte (pc+1);

#ifdef TRACING
        insn_trace_record.insnbyte1 = ext_opcode;
#endif

            /* see comments above */
            if (bAnyExceptionPending ())
                goto CheckExceptions;

            ext_hw_instr_cnt[ext_opcode]++;

            flag_return_opcode = 
            ((ext_opcode == opc_return0) || (ext_opcode == opc_return1) || 
             (ext_opcode == opc_return2)) ? 1 : 0;

#ifdef TRACING
                insn_trace_record.ext_opcode = ext_opcode;
                insn_trace_record.opcode = 255;
#endif
            vDoExtOp (ext_opcode);
        }

CheckExceptions:
        if (bAnyExceptionPending ())
            vDespatchPendingException ();

#if 0  /* this was the pico way of handling it, the maya way is much cleaner */

        if (bAnyExceptionPending ())
        {
            vDespatchPendingException ();
/* do it twice - for the special case that setting up the first frame may
   have caused an oplim trap - the return PC in the oplim trap frame 
   is the first instr of the handler for the first trap - pc has been
   already updated when the foll. check is done, so this gets implemented
   automatically */

            if (bAnyExceptionPending ())
                vDespatchPendingException ();
        }
#endif 
 
#ifdef TRACING
        insn_trace_record.end_pc = (unsigned int) pc;
        insn_trace_record.end_optop = (unsigned int) optop;
        insn_trace_record.end_vars = (unsigned int) vars;
        if (p_pjsim_trace_emit_insn_record)
            (p_pjsim_trace_emit_insn_record) (insn_trace_record);
#endif
        icount = ll_add (icount, 1LL);
        instr_since_last_intr++;
        instr_since_last_trap++;
    }
    /* restore original Ctrl-C handler */
    signal (SIGINT, prev_SIGINT_disp); 
}

/* inits the chip */

void initPico ()

{
    unsigned int i;
    char *s;
    int64_t ll;
    static int once_inited = 0;

    /* once_inited is a static flag which goes to 1 when initPico
       has been called once during one run of ias. need to protect
       some things like hcr value, and not reset them when the call
       to initPico comes other than the first time. (e.g. on 
       a priv_reset execution, we don't want to change the cache size
       back to the default if the user had changed it earlier)
       similarly some of the DLLs may require not have their init routines
       called twice. */

    /* power on values for global registers and state */

    bPowerDownState = 0;
    bNMIState = 0;
    uIRLState = 0;
    sc_bottom_min = 0xffffffff; /* max unsigned */
    sc_bottom_max = 0;

    if (!once_inited)
    {
    /* the code was already non-portable across 32 bit machines, so might
       as well put in a check, and refuse to run ... ideally check if big-endian 
       machine also */
    
        if (sizeof(int) != 4 || sizeof(short) != 2 || sizeof(char) != 1)
        {
            fprintf (stderr, "IAS cannot run on this machine, since it depends \
    heavily on the size of integers, shorts and chars being 4, 2, 1 \
    respectively\n");
            exit (1);
        }
        /* big-endian check */
        {
            int p = 0x11223344;
            char *c = (char *) &p;
            if ((*c) != 0x11)
            { 
                fprintf (stderr, "IAS cannot run on this machine, since it does not appear to be big-endian...\n");
                exit (1);
            }
        }
    
        hcr.dcl = 2;
        hcr.icl = (proc_type == pico) ? 1 : 2;

        /* init caches only if they haven't explicitly been init'ed before */
        /* default ics and dcs for pico-1: 8K, 16K
               default ics and dcs for pico-2: 16K, 16K 
         */
        if (!flag_icache_once_inited)
        {
            hcr.ics = (proc_type == pico) ? 3 : 5;
            icacheInit (hcr.ics);
        }
        if (!flag_dcache_once_inited)
        {
            hcr.dcs = (proc_type == pico) ? 4 : 5;
            dcacheInit (hcr.dcs);
        }

        vSCacheInit ();
        vInitStatistics (&InterruptStatistics);
        vInitStatistics (&AllTrapsStatistics);

        /* initialise dynamic plug-ins  */
        init_trace_lib ();

        hcr.fpp = (ias_fpu_present) ? 1 : 0;
        hcr.res1 = hcr.res0 = 0;
        intr_init_module ();
        brkpt_init_module ();
        vClearAllExceptions ();
        if ((s = getenv ("IAS_MAX_INSTRUCTIONS")) != NULL)
        {
            ll = strtoll (s, (char **) NULL, 0);
    
            if (ll_ltz (ll))      /* if set to a value < 0, no insn limit */
            {
                bInstructionLimit = 0;
                printf ("IAS_MAX_INSTRUCTIONS < 0, no instruction limit for simulator\n");
            }
            else
            {
                nMaxInstructions = ll;
                printf ("IAS_MAX_INSTRUCTIONS set to %lld\n", nMaxInstructions);
            }
        }
    
/* there is a little bit of difference between "maya" and the "real"
pico-2. Maya is in reality an early version of pico-2 which did not
have a (very) few picoJava enhancements like aastore_q and fast monitor
instructions. Maya's HCR.SRN field reads 2.0, for the real pico-2 it 
reads 2.1. Microjava-701 is based on "maya" not the official version of pico-2 
*/

        if ((s = getenv ("PJSIM_EXIT_ON_WARNING")) != NULL)
        {
             exit_on_warning = 1;
        }
        if ((proc_type != pico) && (proc_type != maya))
        {
             flag_fast_monitors = 1;
        }
    }

    vars = (stack_item *) (0x3ffffc);
    oplim = 0;
    trapbase = (int) (0x0);
    frame = (stack_item *) (0x0);
    const_pool = (decafCpItemType *) (0x0); 
    versionId = 0xffffffff;
    pc = (unsigned char *) 0;
    gcConfig = 0;

    *((int *) &brk12c) = 0;

    vUpdateGR (GR_psr, 0x20);
    if (ias_boot8 == 1)
        vUpdateGR (GR_psr, psr | 0x00004000);

    vUpdateGR (GR_optop, 0x3ffffc);
    vUpdateGR (GR_sc_bottom, (unsigned int) optop);

    ias_scache = 1; /* by default */

    opc_first_unused_index = (proc_type == pico) ? 238 : 247;
    if (proc_type == pico)
        hcr.srn = 0x10;
    else if (proc_type == maya)
        hcr.srn = 0x20;
    else 
        hcr.srn = 0x21;

    once_inited = 1;
}

void update_psr ()
 
{
    if (ias_boot8 == 1)
        vUpdateGR (GR_psr, psr | 0x00004000);
}

/* 
   vSetInterrupt is called whenever the state of the IRL pins changes to
   a value other than 0.
   command is left undefined for now.
   irl is the current (new) interrupt level
   irl = 0 signals that the NMI pin is active
   the real IRL pins going to 0 is signalled by a different mechanism - 
   an ncwrite to a prespecified location - currently 0xfff8.
   ?? - need to support first argument in this function
*/

void vSetInterrupt (int command, unsigned int irl)

{
    DPRINTF (IRL_CHANGE_LVL, ("IAS setting interrupt level to %d (0 = NMI)\n", irl))

    if (irl > 0)
        uIRLState = irl;
    else
        bNMIState = 1;
}

void vReset ()

{
    initPico ();
}

/* Reads a byte from the I-stream at addr */

char IstreamReadByte (unsigned char *addr)

{
    return (get_new_instr ((unsigned int) addr));
}

/* Reads a short (in big-endian format) from the Istream at addr */

short IstreamReadShort (unsigned char *addr)

{
    unsigned char byte0, byte1;

    byte0 = IstreamReadByte (addr);
    byte1 = IstreamReadByte (addr+1);
    return( (((signed char )(byte0)) << 8) | byte1);
}

/* Reads a word (in big-endian format) from the Istream at addr */

int IstreamReadWord (unsigned char *addr)

{
    unsigned char byte0, byte1, byte2, byte3;

    byte0 = IstreamReadByte (addr);
    byte1 = IstreamReadByte (addr+1);
    byte2 = IstreamReadByte (addr+2);
    byte3 = IstreamReadByte (addr+3);
    return ((((signed char)(byte0)) << 24) | (byte1 << 16) | (byte2 << 8) 
                          | byte3);
}

unsigned int readProgMem (unsigned int addr)

{
    unsigned int data;

    READ_WORD (addr, 'G', data);
    return (data);
}

/* 
  returns 1 if the given type of address matches the breakpoint reg 
  specified, 0 otherwise

  breakpoint_reg_no is either 1 or 2 (brk1a or brk2a)
  address is the addr to use
  data_brkpt is 1 if we are looking for data breakpoints, 0 for code brkpts
  rnotw 1 is 1 if user is checking a match for a data read on the address, 
    0 if matching a data write, don't care for code brkpts
*/
int pico_breakpoint_match (int breakpoint_reg_no, int address, int data_brkpt, int rnotw)

{
    int match;
    int addr_mask, brkaddr, brken, subrk, srcbrk;

    brken = (breakpoint_reg_no == 1) ? brk12c.brken1 : brk12c.brken2;
    if (brken == 0)
        return 0;  /* common case of this brkpt not enabled, return 0 quickly */

    subrk = (breakpoint_reg_no == 1) ? brk12c.subrk1 : brk12c.subrk2;
    if (subrk && (psr & 0x20)) /* if subrk set and in SU mode, ignore */
        return 0;

    srcbrk = (breakpoint_reg_no == 1) ? brk12c.srcbk1 : brk12c.srcbk2;
    if ((srcbrk == 3) && (data_brkpt))
         return 0;   /* srcbrk = 3 => code brkpt */
    else if ((srcbrk == 0) && !(data_brkpt && rnotw)) 
        return 0;
    else if ((srcbrk == 1) && !(data_brkpt && !rnotw)) 
        return 0;
    else if (srcbrk == 2)
        return 0; /* this is for safety, srcbrk = 2 is undefined */

    if ((proc_type == pico) || 
        ((proc_type != pico) && !data_brkpt)) /* maya - databrk enable on fle */
    {
        if (psr & 0x40)          /* folding on, don't match */
           return 0;
    }

    /* ias behaviour on brk12c.halt set is to just continue */
    if (brk12c.halt)
        return 0; 

    addr_mask = (breakpoint_reg_no == 1) ? brk12c.brkm1 : brk12c.brkm2;
    brkaddr = (breakpoint_reg_no == 1) ? brk1a : brk2a;

    match = 
    (
     ((!(addr_mask & 1)) || 
      ((addr_mask & 1) && ((address & 1) == (brkaddr & 1)))) &&
     ((!(addr_mask & 2)) || 
      ((addr_mask & 2) && ((address & 2) == (brkaddr & 2)))) &&
     ((!(addr_mask & 4)) || 
      ((addr_mask & 4) && ((address & 4) == (brkaddr & 4)))) &&
     ((!(addr_mask & 8)) || 
      ((addr_mask & 8) && ((address & 8) == (brkaddr & 8)))) &&
     ((!(addr_mask & 0x10)) || 
      ((addr_mask & 0x10) && ((address & 0xFF0) == (brkaddr & 0xFF0)))) &&
     ((!(addr_mask & 0x20)) || 
      ((addr_mask & 0x20) && ((address & 0x1000) == (brkaddr & 0x1000)))) &&
     ((!(addr_mask & 0x40)) || 
      ((addr_mask & 0x40) && ((address & 0xFFFFE000) == (brkaddr & 0xFFFFE000))))
    );

    return match;
}

int iam_checkpoint (CPR_REQUEST_T req, FILE *fp)

{
int ias_cache = 0; /* temporary, not used */
    switch (req)
    {
      case CPR_QUERY:
        break;
      case CPR_CHECKPOINT:
      {
#define CHECKING_FWRITE_ELEMENT(a) CHECKING_FWRITE (&a, sizeof(a), 1, fp)
        CHECKING_FWRITE (&ias_trace, sizeof (ias_trace), 1, fp)
        CHECKING_FWRITE (&ias_scache, sizeof (ias_scache), 1, fp)
        CHECKING_FWRITE (&ias_cache, sizeof (ias_cache), 1, fp)
        CHECKING_FWRITE (&sc_bottom_min, sizeof (sc_bottom_min), 1, fp)
        CHECKING_FWRITE (&sc_bottom_max, sizeof (sc_bottom_max), 1, fp)
        break;
      }
      case CPR_RESTART:
      {
#define CHECKING_FREAD_ELEMENT(a) CHECKING_FREAD (&a, sizeof(a), 1, fp)
        CHECKING_FREAD (&ias_trace, sizeof (ias_trace), 1, fp)
        CHECKING_FREAD (&ias_scache, sizeof (ias_scache), 1, fp)
        CHECKING_FREAD (&ias_cache, sizeof (ias_cache), 1, fp)
        CHECKING_FREAD (&sc_bottom_min, sizeof (sc_bottom_min), 1, fp)
        CHECKING_FREAD (&sc_bottom_max, sizeof (sc_bottom_max), 1, fp)
        break;
      }
    } 

    return 0;
}
