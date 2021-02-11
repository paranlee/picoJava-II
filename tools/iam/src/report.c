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




static char *sccsid = "@(#)report.c 1.16 Last modified 06/10/97 13:40:01 SMI";

#include <stdio.h>
#include "dsv.h"
#include "sim_config.h"
#include "object_ops.h"
#include "statistics.h"
#include "global_regs.h"
#include "iam.h"
#include "opcode_names.h"
#include "opcodes.h"
#include "statistics.h"
#include "ext_ops.h"
#include "report.h"

failure_t pico_failures [] = {
{0x00000001, "INITIAL VALUE"},
{0x00000002, "Program completed with return code 2"},
{0x00000003, "LOOP FOREVER"},
{0x00000004, "DETECTED LAST INSTRUCTION"},
{0x00000005, "RANDOM TEST RETURN. "},

/* trap codes */
{0x00020071, "UNRESOLVED CLASS"},
{0x00020072, "CLASS NOT LOADED"},
{0x00020080, "ABSTRACT METHOD"},
{0x00020081, "NO SUCH FIELD"},
{0x00020082, "NO SUCH METHOD"},
{0x00020083, "INSTANCE METHOD"},
{0x00020084, "STATIC METHOD"},
{0x00020085, "INSTANCE FIELD"},
{0x00020086, "STATIC FIELD"},
{0x00020087, "NO SUCH CLASS"},
{0x00020088, "NOT A PUBLIC METHOD"},
{0x0002008A, "MEMORY NOT AVAILABLE"},
{0x00020090, "ILLEGAL ACCESS"},
{0x00020091, "INCOMPATIBLE CLASS CHANGE"},
{0x000200A0, "INVALID CONSTANT CP0"},
{0x000200A1, "NO SUCH METHOD IN SUPER CLASS"},
{0x000200A2, "METHOD BLOCK PTR DO NOT MATCH"},
{0x000200A3, "METHOD INDEX TOO BIG"},
{0x000200A4, "INVALID METHOD TYPE"},
{0x000200A5, "UNRESOLVED FIELD BY FIELD Q W"},
{0x000200C0, "NULL POINTER"},
{0x000200C1, "INVALID ARRAY TYPE"},
{0x000200C2, "ARRAY INDEX OUT OF BOUNDS"},
{0x000200C3, "ARRAY STORE"},
{0x000200C4, "NOT AN ARRAY REFERENCE"},
{0x000200C5, "ATHROW RETURNS"},
{0x000200C6, "MISSING ARRAY ELEM TYPE"},
{0x000200C7, "NEGATIVE ARRAY SIZE SPEC"},
{0x000200C8, "No Handler for a thrown exception of type "},
{0x000200C9, "GC_NOTIFY TRAP"},

/* fatal exceptions */
{0x00030001, "Fatal exception - unaligned memory access"},

{0, ""}  /* MUST BE THE LAST ENTRY - DO NOT ADD BELOW THIS LINE !!!! */
};
 
#ifdef INLINE_STATS
static void printInlineStats (FILE *fp);
#endif /* INLINE_STATS */

static printPercent (FILE *fp, int64_t x, int64_t y)

{
    double d1 = ll2double (x);
    double d2 = ll2double (y);

    if (y != 0)
        fprintf (fp, "(%.4f%%)", (float) (d1*100)/d2);
}

static int64_t totalAndPrintInlineRow (FILE *fp, inlineType i)

{
    int j;
    int64_t total_instances = 0LL;
    int64_t total_insns = 0LL;

    for (j = 0 ; j < 5 ; j++)
    {
        fprintf (fp, "%10lld ", inlineStats[j][i]);
        total_instances = ll_add(total_instances, inlineStats[j][i]);
    }
    if (i == INLINE_putf_q)
        total_insns = ll_mul(total_instances, 4);
    else if ((i == INLINE_gets_q) || (i == INLINE_is_q) || (i == INLINE_return))
        total_insns = ll_mul(total_instances, 2);
    else  /* saving for all other is 3 insns */
        total_insns = ll_mul(total_instances, 3);

    fprintf (fp, "%10lld %10lld\n", total_instances, total_insns);

    return total_insns;
}


void printStats (char* filename)

{
     FILE *fp1;
     int64_t icmp_insns_count, acmp_insns_count;

     int i, j, sort_array[256];
     fp1 = (filename == NULL) ? stdout : fopen(filename, "w");
     if (fp1 == NULL)
     {
         fprintf (stderr, "Error: unable to open file %s for writing\n", 
                  filename);
         return;
     }

     fprintf(fp1, "Total number of instructions %lld\n", icount);
     fprintf(fp1, "Total number of traps: %d\n", getnSamples (&AllTrapsStatistics));
     fprintf(fp1, "Total number of interrupts: %d\n", getnSamples (&InterruptStatistics));

     fprintf (fp1, "\n%6s %25s %11s %6s\n", "Opcode", "Instruction", "Frequency", "Pct.");
     fprintf(fp1, "// Begin Frequency table\n");

     /* v. simple sort, suffices */
     for (i = 0 ; i < 256 ; i++)
         sort_array[i] = i;
     for (i = 0 ; i < 256 ; i++)
         for (j = i+1 ; j < 256 ; j++)
             if (instr_cnt[sort_array[i]] < instr_cnt[sort_array[j]])
             {
                 int tmp = sort_array[i];
                 sort_array[i] = sort_array[j];
                 sort_array[j] = tmp;
             }
                 
     for (i = 0; i < 256; i++) {
          if (instr_cnt[sort_array[i]] != 0)
          {
              fprintf (fp1, "%6x %25s %11d ", sort_array[i], opcode_names[sort_array[i]], instr_cnt[sort_array[i]]);
              printPercent (fp1, instr_cnt[sort_array[i]], icount);
              fprintf (fp1, "\n");
          }
     }

     for (i = 0 ; i < 128 ; i++)
         sort_array[i] = i;
     for (i = 0 ; i < 128 ; i++)
         for (j = i+1 ; j < 128 ; j++)
             if (ext_hw_instr_cnt[sort_array[i]] < ext_hw_instr_cnt[sort_array[j]])
             {
                 int tmp = sort_array[i];
                 sort_array[i] = sort_array[j];
                 sort_array[j] = tmp;
             }

     for (i = 0 ; i < 128 ; i++) {
          if (ext_hw_instr_cnt[sort_array[i]] != 0)
          {
              fprintf(fp1, "ff:%3x %25s %11d ", sort_array[i], ext_hw_opcode_names[sort_array[i]],  ext_hw_instr_cnt[sort_array[i]]);
              printPercent (fp1, ext_hw_instr_cnt[sort_array[i]], icount);
              fprintf(fp1, "\n");
          }
     }
     fprintf(fp1, "// End Frequency table\n");

    fprintf (fp1, "\nD$ reads: %lld, misses: %lld", 
            dcache_reads, dcache_read_misses);
    printPercent (fp1, dcache_read_misses, dcache_reads);
    fprintf (fp1, ", misses causing writeback: %lld", dcache_read_misses_causing_wb);
    printPercent (fp1, dcache_read_misses_causing_wb, dcache_read_misses);
    fprintf (fp1, "\n");

    fprintf (fp1, "D$ writes: %lld, misses: %lld", 
            dcache_writes, dcache_write_misses);
    printPercent (fp1, dcache_write_misses, dcache_writes);
    fprintf (fp1, ", misses causing writeback: %lld", dcache_write_misses_causing_wb);
    printPercent (fp1, dcache_write_misses_causing_wb, dcache_write_misses);
    fprintf (fp1, "\n");

    icmp_insns_count = 0LL;
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_ifge]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_ifgt]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_ifle]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_iflt]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_ifeq]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_ifne]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_if_icmpge]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_if_icmpgt]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_if_icmple]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_if_icmplt]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_if_icmpeq]);
    icmp_insns_count = ll_add (icmp_insns_count, instr_cnt[opc_if_icmpne]);

    fprintf (fp1, "\nTaken branches on integer comparison: %lld/%lld", icmp_branches, icmp_insns_count);
              
    printPercent (fp1, icmp_branches, icmp_insns_count);
    fprintf (fp1, "\n");

    acmp_insns_count = 0LL;
    acmp_insns_count = ll_add (acmp_insns_count, instr_cnt[opc_if_acmpeq]);
    acmp_insns_count = ll_add (acmp_insns_count, instr_cnt[opc_if_acmpne]);
    acmp_insns_count = ll_add (acmp_insns_count, instr_cnt[opc_ifnull]);
    acmp_insns_count = ll_add (acmp_insns_count, instr_cnt[opc_ifnonnull]);

    fprintf (fp1, "Taken branches on object comparison : %lld/%lld", acmp_branches, acmp_insns_count);
              
    printPercent (fp1, acmp_branches, acmp_insns_count);
    fprintf (fp1, "\n");

    fprintf (fp1, "\ncheckcast_quick traps: %lld/%lld", checkcast_quick_traps, checkcast_quick_insns);
    printPercent (fp1, checkcast_quick_traps, checkcast_quick_insns);
    fprintf (fp1, "\n");

    fprintf (fp1, "instanceof_quick traps: %lld/%lld", instanceof_quick_traps, instanceof_quick_insns);
    printPercent (fp1, instanceof_quick_traps, instanceof_quick_insns);
    fprintf (fp1, "\n");

    fprintf (fp1, "\nmonitorenters: %lld, misses: %lld", 
            monitorenter_insns, monitorenter_misses);
    printPercent (fp1, monitorenter_misses, monitorenter_insns);
    fprintf (fp1, ", overflows: %lld", monitorenter_overflows);
    printPercent (fp1, monitorenter_overflows, monitorenter_insns);
    fprintf (fp1, "\n");

    fprintf (fp1, "monitorexits: %lld, misses: %lld", 
            monitorexit_insns, monitorexit_misses);
    printPercent (fp1, monitorexit_misses, monitorexit_insns);
    fprintf (fp1, ", overflows: %lld", monitorexit_overflows);
    printPercent (fp1, monitorexit_overflows, monitorexit_insns);
    fprintf (fp1, ", releases: %lld", monitorexit_releases);
    printPercent (fp1, monitorexit_releases, monitorexit_insns);
    fprintf (fp1, "\n");

    if (flag_fast_monitors)
    {
        fprintf (fp1, "fast monitors saved %lld monitorenter traps", 
                 fast_monitors_saved_the_day);
        printPercent (fp1, fast_monitors_saved_the_day, monitorenter_misses);
        fprintf (fp1, "\n");
    }

    fprintf (fp1, "lockaddr[0]: monitorenter hits: %lld/%d", 
            lock_enter_hits[0], instr_cnt[opc_monitorenter]);
    printPercent (fp1, lock_enter_hits[0], instr_cnt[opc_monitorenter]);
    fprintf (fp1, ", monitorexit hits: %lld/%d",
            lock_exit_hits[0], instr_cnt[opc_monitorexit]);
    printPercent (fp1, lock_exit_hits[0], instr_cnt[opc_monitorexit]);
    fprintf (fp1, "\n");

    fprintf (fp1, "lockaddr[1]: monitorenter hits: %lld/%d", 
            lock_enter_hits[1], instr_cnt[opc_monitorenter]);
    printPercent (fp1, lock_enter_hits[1], instr_cnt[opc_monitorenter]);
    fprintf (fp1, ", monitorexit hits: %lld/%d",
            lock_exit_hits[1], instr_cnt[opc_monitorexit]);
    printPercent (fp1, lock_exit_hits[1], instr_cnt[opc_monitorexit]);
    fprintf (fp1, "\n");

#ifdef INLINE_STATS
    printInlineStats (fp1);
#endif /* INLINE_STATS */

#ifdef PROFILING
    profiler_print_all (fp1);
#endif /* PROFILING */

    if ((fp1 != stdout) && (fp1 != stderr))
       fclose (fp1);
}

#ifdef INLINE_STATS
static void printInlineStats (FILE* fp)

{
    invokeType i;
    inlineType j;
    int64_t total_savings = 0LL;

    fprintf (fp, "\nInlining statistics (instances):\n");
    fprintf (fp, "Caller   ---->       inv_v_q   inv_nv_q inv_static  inv_super  inv_v_q_w      total  #insns saved\n");

    fprintf (fp, "Field getter:     ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_getf_q));

    fprintf (fp, "Field setter:     ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_putf_q));

    fprintf (fp, "Static getter:    ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_gets_q));

    fprintf (fp, "Static setter:    ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_puts_q));

    fprintf (fp, "passthru inv_s:   ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_is_q));

    fprintf (fp, "passthru inv_v_q: ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_iv_q));

    fprintf (fp, "passthru inv_nv_q:"); 
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_inv_q));

    fprintf (fp, "empty return:     ");
    total_savings = ll_add(total_savings, totalAndPrintInlineRow (fp, INLINE_return));

    fprintf (fp, "\ntotal reduction in insn count due to inlining of simple methods: %lld ", 
             total_savings);

    printPercent (fp, total_savings, icount);
    fprintf (fp, "\n");
}
#endif /* INLINE_STATS */

void reportStatus (unsigned int return_code)

{
    int i, n;

    if (return_code == 0)
        printf ("IAS: Test PASSED");
    else
	{
	    /* don't print out failed for random */
	    if (return_code == 5)
		    printf  ("IAS: Test completed : ");
		else
		    printf ("IAS: Test FAILED : ");

		for (i = 0 ; pico_failures[i].failure_code != 0 ; i++)
        {
            if (return_code == pico_failures[i].failure_code)
			{
				printf ("Reason - %s", pico_failures[i].failure_string);
				if (return_code == 0x200C8) /* no athrow handler */
				{ 
					reportAthrowObjectType ();
				}
				break;
            }
		}
		if (pico_failures[i].failure_code == 0)
			printf ("(Unknown exit code - 0x%x)", return_code);
    }

	printf (", %lld instructions, %d interrupts taken, %d total traps\n", icount, getnSamples (&InterruptStatistics), getnSamples (&AllTrapsStatistics));

    fflush (stdout);

    printf ("\n");

#if 0
	if ((n = getnSamples (InterruptStatistics)) > 0)
	{
        printf ("Interrupts taken (#, instructions between - "
		         "min, avg, max): %d %d %.2g %.d, ", 
		         n, (int) getMinSample (InterruptStatistics), 
				 getAverage (InterruptStatistics),
				 (int) getMaxSample (InterruptStatistics));
    }
    else
        printf ("No interrupts taken, ");

    if ((n = getnSamples (AllTrapsStatistics)) > 0)
    {
        printf ("All traps taken (#, instructions between - "
                 "min, avg, max): %d %d %.2g %d ",
                 n, (int) getMinSample (AllTrapsStatistics), 
                 getAverage (AllTrapsStatistics),
                 (int) getMaxSample (AllTrapsStatistics));
    }
    else
        printf ("No traps taken\n");
#endif
}
