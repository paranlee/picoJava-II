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




#ifndef _GLOBAL_REGS_H_
#define _GLOBAL_REGS_H_

#pragma ident "@(#)global_regs.h 1.16 Last modified 10/07/98 14:29:49 SMI"

#include <stdio.h>

#include "typedefs_md.h" /* reqd for int64_t */
#include "dsv.h"         /* reqd for cpitemtype, etc */
#include "decaf.h"       /* reqd for cpitemtype, etc */
#include "statistics.h" 
#include "checkpoint_types.h"
#include "tracing.h"

#define	CHK_PSR_DCE ((psr >> 10) & 0x1)
#define CHK_PSR_ICE ((psr >> 9) & 0x1)

#define	SET_PSR_S	 { vUpdateGR (GR_psr, psr | 0x20); }
#define	RESET_PSR_IE { vUpdateGR (GR_psr, psr &= 0xffffffef); } 

/* not that we ever use stack_item, don't know why it's there */

typedef union stack_item {
    /* Non pointer items */
    int            i;
    float          f;
    void          *p;
    unsigned char *addr;
} stack_item;

struct brk12c_t {
unsigned halt : 1;
unsigned brkm2 : 7;
unsigned res0 : 1;
unsigned brkm1 : 7;
unsigned res1 : 4;
unsigned subrk2 : 1;
unsigned srcbk2 : 2;
unsigned brken2 : 1;
unsigned res2 : 4;
unsigned subrk1 : 1;
unsigned srcbk1 : 2;
unsigned brken1 : 1;
};

struct hcr_t {
unsigned res0 : 2;
unsigned dcl  : 3;
unsigned icl  : 3;
unsigned dcs  : 3;
unsigned ics  : 3;
unsigned fpp  : 1;
unsigned res1 : 9;
unsigned srn  : 8;
};

#define NUMREG 25

/* PicoJava Registers */
extern unsigned char     *pc;
extern stack_item    *vars ;
extern stack_item    *frame;
extern stack_item     *optop ;
extern unsigned int    oplim;
extern decafCpItemType    *const_pool;
extern int        psr;
extern int        trapbase;
extern unsigned int    lockCount[2], lockAddr[2];
extern unsigned int    userrange1, userrange2;
extern unsigned int    gcConfig;
extern unsigned int    brk1a, brk2a;
extern struct brk12c_t brk12c;
extern unsigned int    versionId;
extern struct hcr_t hcr;
extern stack_item *scBottom; /* this is always a relative address */
extern unsigned int    global0, global1, global2, global3;

/* end picojava registers */

extern unsigned int bPowerDownState, bResetState, bNMIState, uIRLState;
/* these keep track of min and max values of sc_bottom when PSR.DRE
   is on */
extern unsigned int sc_bottom_max, sc_bottom_min;

extern unsigned int program_exit_code;
extern unsigned int exit_on_warning;    /* if set, treat warnings as fatal */

extern unsigned int flag_pico_write_brkpt_pending;
extern unsigned int flag_sim_read_brkpt_pending, flag_sim_write_brkpt_pending;

extern unsigned int flag_setting_up_trap_frame;
extern unsigned int flag_fast_monitors;

/* flag_return_opcode is updated at the beginning of each instruction 
with either 1 or 0 (1 if the instruction about to be executed is 
a JVM *return instruction, or a C return0/1/2, 0 otherwise) */
unsigned int flag_return_opcode;

/* statistics stuff */
extern unsigned int instr_since_last_intr;
extern unsigned int instr_since_last_trap;

extern StatisticsObject InterruptStatistics;
extern StatisticsObject AllTrapsStatistics;

extern int64_t icount, next_sched_intr_icount;
extern int64_t checkcast_quick_insns, checkcast_quick_traps;
extern int64_t instanceof_quick_insns, instanceof_quick_traps;
extern int64_t monitorenter_insns, monitorenter_misses;
extern int64_t monitorenter_overflows;
extern int64_t monitorexit_insns, monitorexit_misses;
extern int64_t monitorexit_overflows, monitorexit_releases;
extern int64_t dcache_reads, dcache_writes;
extern int64_t dcache_read_misses, dcache_write_misses;
extern int64_t dcache_read_misses_causing_wb, dcache_write_misses_causing_wb;
extern int64_t acmp_branches, icmp_branches;
extern int64_t lock_enter_hits[2], lock_exit_hits[2];
extern int64_t fast_monitors_saved_the_day;

typedef enum {INV_iv_q = 0, INV_inv_q, 
                  INV_is_q, INV_isuper_q, INV_iv_q_w} invokeType;
typedef enum {INLINE_iv_q = 0, INLINE_inv_q, INLINE_is_q,
                  INLINE_getf_q, INLINE_putf_q,
                  INLINE_gets_q, INLINE_puts_q,
                  INLINE_return} inlineType;

/* dimension of inlineStats must be #invokeTypes * #inlineTypes */

extern int64_t inlineStats[5][8];

insn_trace_record_t insn_trace_record; 

extern const GR_optop;
extern const GR_sc_bottom;
extern const GR_psr;
extern const GR_oplim;

void vUpdateGR (unsigned int GR_num, unsigned int value);
int global_regs_checkpoint (CPR_REQUEST_T req, FILE *fp);

#endif /* _GLOBAL_REGS_H_ */
