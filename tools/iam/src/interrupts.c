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




static char *sccsid = "@(#)interrupts.c 1.6 Last modified 10/06/98 11:36:52 SMI";

#include <stdio.h>

#include "global_regs.h"
#include "iam.h"
#include "dprint.h"
#include "interrupts.h"

/* last_intr_set is the id# of the last used element in the intrs array */

static int last_intr_set = -1, next_intr_id = -1;
static interrupt_t intrs[MAX_INTRS];

void intr_init_module ()

{
    next_intr_id = -1;
    next_sched_intr_icount = -1;
    last_intr_set = -1;
}

void intr_add (int64_t count, int irl, int is_repeating)

{
    int i, this_intr;

    if (irl < 0 || irl > 15)
    {
        INFO_WARN (("IRL level should be between 0 and 15 inclusive, no action taken\n"));
        return;
    }
        
    if (ll_ltz (count))
    {
        INFO_WARN (("count should be > 0, no action taken\n"));
        return;
    }
    
    if ((ll_eqz (count)) && is_repeating)
    {
        INFO_WARN (("cannot schedule repeating interrupts with a period of 0, no action taken\n"));
        return;
    }

    /* we can reuse existing slots for this interrupt if there is 
       a disabled, non-repeating interrupt */

    this_intr = -1;
    for (i = 0 ; i <= last_intr_set ; i++) 
    { 
        if (!intrs[i].is_enabled && !intrs[i].is_repeating)
	{
            this_intr = i;
            break;
	}
    }

    if (this_intr == -1)
    {   /* need to find a new slot for this interrupt */
	if (last_intr_set >= MAX_INTRS)
	{  
	    INFO_WARN (("Maximum no. of interrupts (%d) already exist, cannot set any new interrupts\nNo action taken\n", MAX_INTRS));
	    return;
	}
	else
	{
	    this_intr = last_intr_set+1;
            last_intr_set++;
	}
    }

    intrs[this_intr].irl = irl;
    intrs[this_intr].is_enabled = 1;
    intrs[this_intr].is_repeating = is_repeating;
    intrs[this_intr].next_intr_at = ll_add (icount, count);
    intrs[this_intr].repeat_count = count;

    /* might have caused a change to scheduling, so reschedule */
    intr_schedule_next ();
}

void intr_dispatch ()

{
    int i;

    INTR_PRINTF (("Dispatching interrupt #%d, ", next_intr_id));
    if (intrs[next_intr_id].irl == 0)
    {
        INTR_PRINTF (("NMI, "));
    }
    else
    {
        INTR_PRINTF (("IRL %d, ", intrs[next_intr_id].irl));
    }

    INTR_PRINTF (("at instruction count %lld\n", icount));

    fflush (stdout);

    vSetInterrupt (0, intrs[next_intr_id].irl);

    /* disable all other interrupts at this icount */

    for (i = 0 ; i <= last_intr_set ; i++)
        if (intrs[i].is_enabled)
        {
            if (ll_eq (intrs[i].next_intr_at, icount))
            {
                if (intrs[i].is_repeating)
                {
                    intrs[i].next_intr_at = 
                        ll_add (icount, intrs[i].repeat_count);
                }
                else
                {
                    intrs[i].is_enabled = 0;
                    break;
                }
            }
        }
}

void intr_schedule_next ()

{
    int i;
    
    next_intr_id = -1;

    for (i = 0 ; i <= last_intr_set ; i++)
        if (intrs[i].is_enabled)
        {
            if (next_intr_id == -1)
            {
                next_intr_id = i; 
            }
            else if (ll_lt (intrs[i].next_intr_at, intrs[next_intr_id].next_intr_at))
            {
                next_intr_id = i;
            }
            else 
            if (ll_eq (intrs[i].next_intr_at, intrs[next_intr_id].next_intr_at))
            {   
                /* ETA of both interrupts is same, compare irl priority */
                if (intrs[i].irl < intrs[next_intr_id].irl)
                    next_intr_id = i;
            }
        }

    /* if no interrupts are are set, next_intr_icount is at -1 */
    next_sched_intr_icount = (next_intr_id == -1) ? -1LL :
                             intrs[next_intr_id].next_intr_at;
}

void intr_disable (int intr_id)

{
    if (intrs[intr_id].is_enabled == 0)
    {
        INFO_WARN (("Interrupt# %d is already disabled, no action taken\n", intr_id)); 
    }

    intrs[intr_id].is_enabled = 0;

    /* this might have caused a change in the scheduling, so reschedule */
    intr_schedule_next ();
}

void intr_list ()

{
    int i;

    /* reschedule first, so that the intrs array contains the latest
       countdown */

    intr_schedule_next ();

    INTR_PRINTF (("Intr#  Enabled    Next Intr at    IRL     Repeating   Repeat-frequency\n")); 

    if (next_intr_id == -1)
    {
        INTR_PRINTF (("No interrupts scheduled\n"));
        return;
    }

    for (i = 0 ; i <= last_intr_set ; i++)
    {
        INTR_PRINTF (("%d        ", i));

        if (intrs[i].is_enabled == 0)
        {
            INTR_PRINTF (("No\n"));
        }
        else
        {
            INTR_PRINTF (("Yes   %12lld", intrs[i].next_intr_at));
            if (intrs[i].irl == 0)
            {
                INTR_PRINTF (("%10s", "NMI"));
            }
            else
            {
                INTR_PRINTF (("%9d ", intrs[i].irl));
            }
             
            if (intrs[i].is_repeating == 0)
            {
                INTR_PRINTF (("%12s", "No\n"));
            }
            else
            {
                 INTR_PRINTF (("%11s   %12lld\n", "Yes", intrs[i].repeat_count));
            }
        }
    }

    INTR_PRINTF (("Current instruction count is %lld\nNext interrupt event (#%d) is scheduled at instruction count %lld\n", icount, next_intr_id, next_sched_intr_icount));
}

/* checkpointing of the interrupts mechanism.
format written into the checkpoint file:
last_intr_set, next_intr_id, MAX_INTRS, the entire intrs array */

int intr_checkpoint (CPR_REQUEST_T req, FILE *fp)

{
    unsigned int i;

    switch (req)
    {
      case CPR_QUERY:
        break;

      case CPR_CHECKPOINT:
        CHECKING_FWRITE (&last_intr_set, sizeof (last_intr_set), 1, fp)
        CHECKING_FWRITE (&next_intr_id, sizeof (next_intr_id), 1, fp)

        i = MAX_INTRS;
        CHECKING_FWRITE (&i, sizeof (i), 1, fp)

        CHECKING_FWRITE (intrs, sizeof (interrupt_t), MAX_INTRS, fp)
        break;

      case CPR_RESTART:
        CHECKING_FREAD (&last_intr_set, sizeof (last_intr_set), 1, fp)
        CHECKING_FREAD (&next_intr_id, sizeof (next_intr_id), 1, fp)

        CHECKING_FREAD (&i, sizeof (i), 1, fp)

        if (i != MAX_INTRS)
            return 1;

        CHECKING_FREAD (intrs, sizeof (interrupt_t), MAX_INTRS, fp)
        break;
    }

    return 0;
}

