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




static char *sccsid = "@(#)profiler.c 1.7 Last modified 10/06/98 11:37:02 SMI";

#include <stdio.h>
#include <string.h>

#include "dsv.h"
#include "sim_config.h"
#include "decaf.h"
#include "oobj.h"
#include "typedefs_md.h"
#include "global_regs.h"
#include "javamem.h"
#include "object_ops.h"
#include "dprint.h"
#include "profiler.h"

profile_t *current_profile = NULL;
int current_profile_id = -1;

#ifdef PROFILING 

static entry_point_t *insert_into_hashtable (hashtable_t *h, char *name);
static int compute_hash_val (int x);
static boolean is_sane_profile_id (uint profile_id);
static boolean is_usable_profile_id (int profile_id);
static boolean is_in_range (uint current_pc, profile_stackentry_t *sentry);
static void mark_block_exit_raw (profile_t *profile, 
       boolean warn_if_stack_depth_below_0, boolean warn_if_return_not_in_caller);
static void arrangeList (ep_list_node_t **entry, entry_point_t *ep);
static void print_full_profile (FILE *fp, profile_t *p, uint nEntries, entry_point_t *all_eps[]);
static void print_callee_dist (FILE *fp, uint nEntries, entry_point_t *all_eps[]);
static void print_caller_dist (FILE *fp, uint nEntries, entry_point_t *all_eps[]);

static profile_t *profiles[PROFILER_N_PROFILES];

#define MONITOR_STUFF
#ifdef MONITOR_STUFF
static int nLocks = 16;
static uint ext_monitor_cache[16];
static int64_t ext_monitor_cache_hits[16];
#endif

void profile_reset (int profile_id)

{
    int i;
    
    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

    /* now reset this profile */

    /* free hashtable */
    profiles[profile_id]->hashtable.nEntries = 0;
    profiles[profile_id]->hashtable.nNonEmptyBuckets = 0;
    for (i = 0 ; i < PROFILER_HASHTABLE_SIZE ; i++)
    {
	entry_point_t *ep;
	for (ep = profiles[profile_id]->hashtable.buckets[i] ;
	     ep != NULL ;
	     )
	{
	     entry_point_t *last = ep; 
	     ep = ep->next;
	     free (last);
	}
	profiles[profile_id]->hashtable.buckets[i] = NULL;
    }

    /* throw away all stack entries, except 1 */
    profiles[profile_id]->profile_stack.stack_ptr = 1;
    profiles[profile_id]->profile_stack.stack_entries[0].begin_icount = 0;
    profiles[profile_id]->profile_stack.stack_entries[0].cur_self_icount = 0;
    profiles[profile_id]->profile_stack.stack_entries[0].begin_self_icount = 0;
    profiles[profile_id]->profile_stack.stack_entries[0].is_athrow = FALSE;
    profiles[profile_id]->profile_stack.stack_entries[0].is_inv_if = FALSE;
    profiles[profile_id]->profile_stack.stack_entries[0].correction_icount = 0LL;
    profiles[profile_id]->profile_stack.stack_entries[0].next_stack_frame_this_ep = -1;
    profiles[profile_id]->profile_stack.stack_entries[0].ep = 
        insert_into_hashtable (&(profiles[profile_id]->hashtable), "Program");

    profiles[profile_id]->profile_icount = 0LL;
    profiles[profile_id]->max_call_depth_seen = 1;

    profiles[profile_id]->is_frozen = TRUE;
    profiles[profile_id]->is_enabled = FALSE;
}

void profile_freeze (int profile_id, boolean freeze)

{
    boolean last;

    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

    last = profiles[profile_id]->is_frozen;

    if (freeze)
        profiles[profile_id]->is_frozen = TRUE;
    else
        profiles[profile_id]->is_frozen = FALSE;

    printf ("profile %d is %s %s\n", profile_id,
            (last == freeze) ? "already" : "now",
            freeze ? "frozen" : "unfrozen");

}

/* control counting in profile profile_id */

void profile_enable (int profile_id, boolean on)

{
    boolean last;

    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

    last = profiles[profile_id]->is_enabled;

    if (on)
        profiles[profile_id]->is_enabled = TRUE;
    else
        profiles[profile_id]->is_enabled = FALSE;

    printf ("profile %d is %s %s\n", profile_id,
            (last == on) ? "already" : "now",
            on ? "enabled" : "disabled");
}

/* create a new profile, profile_id, and initialise it */

void profile_create (int profile_id)

{
    if (!is_sane_profile_id (profile_id))
	return;
    
    if (profiles[profile_id] == NULL)
    {    
 	/* profile does not exist, create one
           make sure calloc because we want the hashtable entries
           to be NULL */
        profile_t *p = (profile_t *) calloc (1, sizeof (profile_t));
        profiles[profile_id] = p;
	profile_reset (profile_id);
	/* new profile created, init'ed, and inserted into table */
    }
    else
        fprintf (stderr, "Warning: profile %d already exists, command ignored (at pc = 0x%x)", profile_id, (uint) pc);
}

/* switch to a different profile */

void profile_switch (int profile_id)

{
    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

    current_profile_id = profile_id;
    current_profile = profiles[profile_id];
    printf ("switched to profile %d\n", profile_id);
}

/* close a profile, popping all entries */

void profile_close (int profile_id)

{
    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

    while (profiles[profile_id]->profile_stack.stack_ptr != 1)
    {
	/* this call has to be mark_block_exit_raw and not
           just mark_block_exit, because we want to blindly
           pop off all frames, w/o special handling for
           frames like inf_if and athrow which may still be on
           the call stack */
        mark_block_exit_raw (profiles[profile_id], TRUE, FALSE);
    }

    /* after we have popped all entries, do one more to get rid of 
       the "program" frame. can't do this by testing for stack_ptr
       to go to 0, since it never does (it's always at least 1) */

    mark_block_exit_raw (profiles[profile_id], FALSE, FALSE);
}

/* write out profiler stats for profile_t object p, to file fp */

void profile_print (int profile_id, FILE *fp)

{
    entry_point_t *ep;
    int i, j;
    profile_t *p;
    profile_stack_t *s;
    hashtable_t *h;
    int64_t profile_icount;
    entry_point_t **all_eps;
    int ep_count;

    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

#ifdef MONITOR_STUFF

    {   
    int i, sum = 0;
    for (i = 0 ; i < nLocks ; i++)
    {
        sum += ext_monitor_cache_hits[i];
        fprintf (fp, "lockaddr misses reduced with %d lock regs: %d\n", i+1, sum);
    }
    }
#endif
    p = profiles[profile_id];
    h = &(p->hashtable);
    s = &(p->profile_stack);

    all_eps = (entry_point_t **) calloc (h->nEntries, sizeof (entry_point_t *));
    ep_count = 0;
    for (i = 0 ; i < PROFILER_HASHTABLE_SIZE ; i++)
         for (ep = h->buckets[i]; ep != NULL ; ep = ep->next)
             all_eps[ep_count++] = ep;
    /* sort alleps descending according to total_icount 
       dumb sorter, doesn't matter */
    for (i = 0 ; i < h->nEntries ; i++)
        for (j = i ; j < h->nEntries ; j++)
            if (getSum (&(all_eps[j]->total_icount)) > 
                getSum (&(all_eps[i]->total_icount)))
            {
                entry_point_t *tmp = all_eps[i];
                all_eps[i] = all_eps[j]; 
                all_eps[j] = tmp;
            }

    fprintf (fp, "Profiler hashtable: %d function entry points registered, "
                 " %d non-empty buckets\n", h->nEntries, h->nNonEmptyBuckets);

    fprintf (fp, "entries still on call stack: %d\n", 
                 s->stack_ptr);
    fprintf (fp, "max call stack depth seen: %d\n", 
                 p->max_call_depth_seen);

    fprintf (fp, "Total number of instructions: %lld\n", p->profile_icount);

    print_full_profile (fp, p, h->nEntries, all_eps);

    fprintf (fp, "\n%s\n\n", "********************************************************************************");
    print_callee_dist (fp, h->nEntries, all_eps);
    fprintf (fp, "\n%s\n\n", "********************************************************************************");
    print_caller_dist (fp, h->nEntries, all_eps);
    free (all_eps);
}

/* prints out profile summary info */

void profiler_print_summary ()

{
    int i;

    printf ("Available profiles: (currently active profile marked with *)\n");
    for (i = 0 ; i < PROFILER_N_PROFILES ; i++)
    {
        if (profiles[i] != NULL)
        {
	    printf ("%s%d %s, %s, %d entry points, "
		    "call stack depth: %d, total icount: %lld, "
                    "max call stack depth seen: %d\n",
		 (current_profile_id == i) ? " * " : "   ",
		 i,
		 profiles[i]->is_frozen ? "  Frozen" : "Unfrozen",
		 profiles[i]->is_enabled ? " Enabled" : "Disabled",
		 profiles[i]->hashtable.nEntries,
		 profiles[i]->profile_stack.stack_ptr,
		 profiles[i]->profile_icount,
                 profiles[i]->max_call_depth_seen);
	}
    }
}

void profiler_init ()

{
    int i;

    for (i = 0 ; i < PROFILER_N_PROFILES ; i++)
         profiles[i] = NULL;
    current_profile = NULL;
    current_profile_id = -1;
}


void profiler_print_all (FILE *fp)

{
    int i;
    for (i = 0 ; i < PROFILER_N_PROFILES ; i++)
         if (profiles[i] != NULL)
	 {
             fprintf (fp, "Profile %d\n", i);
             profile_print (i, fp);
	 }
}

/* mark the entry of this block in the given profile.
   if profile is frozen, no action taken.
   is_inv_if = true if we are entering an invoke_interface/_q trap.
   is_athrow = true if we are entering an athrow trap.
   if name is specified, it is used, else it is assumed that the stack
   is set up for a method entry - then we chase the method desc and
   get the name of the function. 
   memory for *name, if any, is reclaimable by caller
 */

void mark_block_enter (int profile_id, char *name,
                       boolean is_inv_if, boolean is_athrow)

{
    profile_stack_t *stack;
    hashtable_t *hashtable;
    entry_point_t *ep;
    profile_stackentry_t *sentry;
    profile_t *profile;

    if (!is_sane_profile_id (profile_id) || !is_usable_profile_id (profile_id))
	return;

    profile = profiles[profile_id];

    if ((profile == NULL) || profile->is_frozen)
        return;

    stack = &(profile->profile_stack);
    hashtable = &(profile->hashtable);

    DPRINTF (PROFILE_DBG_LVL, ("entering block, stack depth = %d\n", profile->profile_stack.stack_ptr+1));

#ifdef MONITOR_STUFF
    if (name != NULL)
        if (!strcmp (name, "lock_enter_miss_trap") ||
            !strcmp (name, "lock_exit_miss_trap"))
        {
            uint objref, i;
            int j;
            READ_WORD (OPTOP_OFFSET(5), 'G', objref);
            MASK_OBJREF(objref);
            for (i = 0 ; i < nLocks ; i++)
            {
                if (objref == ext_monitor_cache[i])
                {
                    ext_monitor_cache_hits[i]++;
                    break;
                }
            }
            for (j = i-1; j >= 0 ; j--)
            {
                 if (j < nLocks-1)
                     ext_monitor_cache[j+1] = ext_monitor_cache[j];
            }
            ext_monitor_cache[0] = objref;
        }
#endif 
    ep = insert_into_hashtable (hashtable, name);

    /* update self count for previous entry */
    sentry = &(stack->stack_entries[stack->stack_ptr-1]);
    sentry->cur_self_icount = 
    ll_add(sentry->cur_self_icount,ll_sub(profile->profile_icount,sentry->begin_self_icount));

    /* push a new entry on stack */
    stack->stack_entries[stack->stack_ptr].ep = ep;
    stack->stack_entries[stack->stack_ptr].begin_self_icount = profile->profile_icount;
    stack->stack_entries[stack->stack_ptr].cur_self_icount = 0LL;
    stack->stack_entries[stack->stack_ptr].begin_icount = profile->profile_icount;

    stack->stack_entries[stack->stack_ptr].is_inv_if = is_inv_if;
    stack->stack_entries[stack->stack_ptr].is_athrow = is_athrow;
    stack->stack_entries[stack->stack_ptr].correction_icount = 0LL;

    if (ep->first_stack_frame_index != -1)
    {   /* recursive call, look for stack frame below with same ep */
        int j;
        for (j = stack->stack_ptr-1 ; j >= 0 ; j--)
            if (stack->stack_entries[j].ep == ep)
                break;
        if (j < 0)
            printf ("Warning: profiler found a function incorrectly marked present on stack\n");
        stack->stack_entries[stack->stack_ptr].next_stack_frame_this_ep = j;
    }
    else
    {   /* non recursive, initialise next entry link to -1 */
        stack->stack_entries[stack->stack_ptr].next_stack_frame_this_ep = -1;
        ep->first_stack_frame_index = stack->stack_ptr;
    }

    stack->stack_ptr++;

    if (stack->stack_ptr > profile->max_call_depth_seen)
        profile->max_call_depth_seen = stack->stack_ptr;

    if (stack->stack_ptr > PROFILER_MAX_CALL_STACK_DEPTH)
    {
        fprintf (stderr, "Warning: profiler call stack depth tried to exceed max (%d)!\n"
                         "\nprofile data may be unreliable!\n", 
                         PROFILER_MAX_CALL_STACK_DEPTH);
        stack->stack_ptr = PROFILER_MAX_CALL_STACK_DEPTH;
    }
}

/* mark the event of leaving the last block entered
   even if profile is frozen.
   shd only be called from mark_block_exit (in which case 
   profile is not frozen), or when we are closing the profile,
   print_warning shd be true if caller wants a warning printed out
   in case stack depth tries to go below 0.
*/
static void mark_block_exit_raw (profile_t *profile, 
boolean warn_if_stack_depth_below_0, boolean warn_if_return_not_in_caller)

{
    uint start_pc, len;
    int64_t my_icount, my_corrected_icount;

    profile_stack_t *stack = &(profile->profile_stack);
    hashtable_t *hashtable = &(profile->hashtable);

    profile_stackentry_t *stackentry = &(stack->stack_entries[stack->stack_ptr-1]);
    entry_point_t *ep = stackentry->ep;

    DPRINTF (PROFILE_DBG_LVL, ("exiting block, stack depth = %d\n", profile->profile_stack.stack_ptr-1));
    /* update self and total icounts for entry we are popping */

    stackentry->cur_self_icount = ll_add(stackentry->cur_self_icount,ll_sub(profile->profile_icount,stackentry->begin_self_icount));

    my_icount = ll_sub(profile->profile_icount,stackentry->begin_icount);
    my_corrected_icount = ll_sub(my_icount, stackentry->correction_icount);

    /* my_corrected_icount is what is going to be entered for the current
       function. however, the correction applied to the next instance
       of the function in the stack is my_icount (total no. of insns 
       between start and end of this instance), not my_corrected_icount */

    if (stackentry->next_stack_frame_this_ep != -1)
    {
        profile_stackentry_t *s = 
          &(stack->stack_entries[stackentry->next_stack_frame_this_ep]);
        s->correction_icount = ll_add (s->correction_icount, my_icount);
    }

    vNewSample (&(ep->total_icount), ll2double(my_corrected_icount));
    vNewSample (&(ep->self_icount), ll2double(stackentry->cur_self_icount));

    if (stack->stack_ptr >= 2)
    {
        /* put this caller at the head of the caller list */
        arrangeList (&(ep->caller_list), stack->stack_entries[stack->stack_ptr-2].ep);
        /* increment count for ep_list_node_t at head of caller list */
        vNewSample (&(ep->caller_list->stats), my_corrected_icount);

        /* put this callee at the head of the callee list */
        arrangeList (&(stack->stack_entries[stack->stack_ptr-2].ep->callee_list), ep);
        /* increment count for ep_list_node_t at head of callee list */
        vNewSample (&(stack->stack_entries[stack->stack_ptr-2].ep->callee_list->stats), 
                    my_corrected_icount);
    }

    if (ep->first_stack_frame_index == (stack->stack_ptr-1))
        ep->first_stack_frame_index = -1;

    /* pop the entry */
    stack->stack_ptr--;

    if (stack->stack_ptr <= 0)
    {
/* it's valid to come here when closing a profile, so not necessarily 
   an error mesg  */
        if (warn_if_stack_depth_below_0)
            fprintf (stderr, "Warning: profiler call stack depth tried to go below "
                         "0 (pc is now 0x%x)!\nprofile data may be unreliable!\n", 
                         (uint) pc);
    
        stack->stack_ptr = 1;
       /* reset the begin count of sentry[0] so that even if depth goes to < 0
          multiple times, the overall insn count for sentry[0] is 
          the same as the total # of insns. basically behave as
          as if we had made an new call to sentry[0]. */
        stack->stack_entries[0].begin_icount = profile->profile_icount;
    }

    /* if we can tell the method and it's length, check that we are not
       returning to an unexpected point */
    start_pc = (stack->stack_entries[stack->stack_ptr-1]).ep->start_pc;
    len = (stack->stack_entries[stack->stack_ptr-1]).ep->len;

    /* using is_in_range wont work here because it doesn't match if 
       len == 0. also if the entry being popped is an inv i/f, don't emit
       message because this is ok for all inv_i/f's */
    if ((len != 0) && 
        ((((uint) pc) < start_pc) || (((uint) pc) >= start_pc + len)) &&
        (!stack->stack_entries[stack->stack_ptr].is_inv_if) &&
        (warn_if_return_not_in_caller))
    {
        fprintf (stderr, "Warning: function returned to a point not in it's caller (pc is now 0x%x), start_pc = 0x%x, len = 0x%x\n", (uint) pc, (uint) start_pc, (uint) len);
    }
  
    /* begin self icounting for caller we are returning to */
    stack->stack_entries[stack->stack_ptr-1].begin_self_icount = profile->profile_icount;
}

void mark_block_exit (int profile_id)

{
    profile_t *profile;
    profile_stack_t *stack;

    if ((!is_sane_profile_id (profile_id)) || (!is_usable_profile_id (profile_id)))
	return;

    profile = profiles[profile_id];

    if ((profile == NULL) || (profile->is_frozen))
        return;

    stack = &(profile->profile_stack);

    /* first pop off this block. then check if the block we just
       popped is a special (inv_if or athrow) frame 
       don't warn if not returning to caller if we are popping an
       athrow frame */
    mark_block_exit_raw (profile, TRUE, 
    stack->stack_entries[stack->stack_ptr-1].is_athrow ? FALSE : TRUE);

    if (stack->stack_entries[stack->stack_ptr].is_inv_if)
    {
       mark_block_enter (profile_id, NULL, FALSE, FALSE);
    }
    else if (stack->stack_entries[stack->stack_ptr].is_athrow)
    {   /* look downward in the stack, pop frames till we find a method 
           whose range the current pc is in */

        while (stack->stack_ptr > 1)
        {
            if (is_in_range ((uint) pc, 
                            &(stack->stack_entries[stack->stack_ptr-1])))
	    {
                break;
	    }
            else
                mark_block_exit_raw (profile, TRUE, FALSE);
        }

	/* did not hit any of the entries above 1, check if it at
           least hits the 0'th entry. if it doesn't, nothing we can do
           except emit an error message */

        if (stack->stack_ptr == 1)
	{   
            /* we know we didn't check is_in_range 
               for this stackentry (0) earlier */
            if (!is_in_range ((uint) pc,
		      &(profile->profile_stack.stack_entries[0])))
	    {
                fprintf (stderr, 
                  "Warning: an athrow returned to a location not in "
                  "the call stack!\nprofile data may be unreliable!\n");
	    }
	}
    }
}

static int compute_hash_val (int x)

{
    /* arbitrary hash function */
    return (x >> 3) % PROFILER_HASHTABLE_SIZE;
}

/*
   memory for *name, if any, is reclaimable by caller
   looks up hashtable, if not found, creates a new entry with current pc, etc.
*/
static entry_point_t *insert_into_hashtable (hashtable_t *h, char *name)

{
    int hash_val = compute_hash_val ((uint) pc); 
    entry_point_t *ep;
    const int BUF_SIZE = 128;
    char method_name[128];
    uint method_len;
    decafMethod *method_desc;

    for (ep = h->buckets[hash_val] ; ep != NULL ; ep=ep->next)
         if (ep->start_pc == (uint) pc)
             break;

    if (ep == NULL)
    {
        h->nEntries++;
        if (h->buckets[hash_val] == NULL)
            h->nNonEmptyBuckets++;

	/* printf ("creating new block with name %s, pc = 0x%x, len = %d\n", name, pc, len); */

        method_len = 0;
        if (name == NULL)
        {
            uint lenAddr;

            /* read the method desc from ToS */
            READ_WORD (OPTOP_OFFSET (1), 'G', method_desc);
            /* get name and length of method */
            getMethodNameAndSig (method_desc, method_name, BUF_SIZE);
            lenAddr = (uint) &(method_desc->codeLength);
            READ_WORD (lenAddr, 'G', method_len);
        }

        ep = (entry_point_t *) calloc (1, sizeof (entry_point_t)); 
        ep->start_pc = (uint) pc;
        ep->len = (uint) method_len;
        ep->first_stack_frame_index = -1;
        ep->callee_list = NULL;
        ep->caller_list = NULL;

	/* null out last byte for safety in case name is too long */
        ep->name[PROFILER_MAX_NAME_LEN-1] = '\0';
        strncpy (ep->name, (name != NULL) ? name : method_name, PROFILER_MAX_NAME_LEN-2);

        vInitStatistics (&(ep->total_icount));
        vInitStatistics (&(ep->self_icount));
        ep->next = NULL;

       /* insert into list at the head */
       ep->next = h->buckets[hash_val];
       h->buckets[hash_val] = ep;
    }

    return ep;
}

/* returns 0 if invalid profile num, 1 otherwise */

static boolean is_sane_profile_id (uint profile_id)

{
    if ((profile_id < 0) || (profile_id >= PROFILER_N_PROFILES))
    {
/* dont print a message if profile_id = -1 because that may happen
   even when profiling is off */
        if (profile_id != -1)
            fprintf (stderr, "Warning: Invalid profile number %d "
                         "(at pc = 0x%x), ignored\n", 
                          profile_id, (uint) pc);
        return 0;
    }
    return 1;
}

/* returns 0 if profile has not yet been created, 1 otherwise */

static boolean is_usable_profile_id (int profile_id)

{
    if (profiles[profile_id] == NULL)
    {
        fprintf (stderr, "Warning: profile number %d does not exist, "
                         "command ignored (at pc = 0x%x)\n", 
                         profile_id, (uint) pc);
        return 0;
    }
    return 1;
}

static boolean is_in_range (uint current_pc, 
                            profile_stackentry_t *sentry)

{
    if ((sentry->ep->len != 0) && 
        (current_pc >= sentry->ep->start_pc) &&
        (current_pc < sentry->ep->start_pc + sentry->ep->len))
    {
         return TRUE;
    }
         
    return FALSE;
}

/* taking the list of ep_list_node's pointed to by *entry, 
   inserts an ep_list_node based on ep into the head of this list.
   if the ep_list_node does not already exist in the list, it is 
   created. *entry could point to either a callee or a caller list */
static void arrangeList (ep_list_node_t **entry, entry_point_t *ep)

{
    ep_list_node_t *ptr, *prev = NULL;

    for (ptr = *entry ; ptr != NULL ; ptr = ptr->next)
    {
        if (ptr->ep == ep)
            break;   /* break if we find a node with this ep already exists */
        prev = ptr;
    }

    if (ptr == NULL)
    {
        /* create new ep_list_node for this ep */
        ptr = (ep_list_node_t *) calloc (1, sizeof (ep_list_node_t));
        ptr->ep = ep;
        vInitStatistics (&(ptr->stats));
        /* insert at head of list */
        ptr->next = *entry;
        *entry = ptr;
    }
    else if (prev != NULL)
    {
        prev->next = ptr->next;
        ptr->next = *entry;
        *entry = ptr;
    }
    /* if prev == NULL, and ptr != NULL (common case), then the node is already 
       at head of list, don't need to do anything */
}

static void print_full_profile (FILE *fp, profile_t *p, uint nEntries, entry_point_t *all_eps[])

{
    int i;

    fprintf (fp, "%60s\n%60s\n", "Instruction counts", "------------------");
    fprintf (fp, "%s\n%10s %5s %10s %10s %6s  %10s %10s %10s %10s %6s  %10s %10s %10s\n", 
                  "Name", "PC", "Code", "#Calls", 
                  "Self+", "Pct.", "Avg.", "Max", "Min",
                  "Self", "Pct.", "Avg.", "Max", "Min");
    fprintf (fp, "%10s %5s %10s %10s\n", "", "Len", "", "children");

    for (i = 0 ; i < nEntries ; i++)
    {
         char len_buf[30];
         entry_point_t *ep = all_eps[i];

         if (ep->len == 0)
             sprintf (len_buf, "?");
         else
             sprintf (len_buf, "%d", ep->len);

         fprintf (fp, "%s\n0x%08x %5s %10u %10lld %6.2f%% %10lld %10lld "
			   "%10lld %10lld %6.2f%% %10lld %10lld %10lld\n",
		       ep->name, ep->start_pc, len_buf,
                       getnSamples (&(ep->total_icount)),
		       double2ll(getSum (&(ep->total_icount))),
                       (float) (100.0 * getSum (&(ep->total_icount))/p->profile_icount),
		       double2ll(getAverage (&(ep->total_icount))),
		       double2ll(getMaxSample (&(ep->total_icount))),
		       double2ll(getMinSample (&(ep->total_icount))),
		       double2ll(getSum (&(ep->self_icount))),
                       (float) (100.0 * getSum (&(ep->self_icount))/p->profile_icount),
		       double2ll(getAverage (&(ep->self_icount))),
		       double2ll(getMaxSample (&(ep->self_icount))),
		       double2ll(getMinSample (&(ep->self_icount))));
    }
}

static void print_callee_dist (FILE *fp, uint nEntries, entry_point_t *all_eps[])

{
    int i;

    fprintf (fp, "Callee distribution:\n\n");

    fprintf (fp, "%s\n%10s %5s %10s %10s %10s\n", 
                  "Name", "PC", "Code", "#Calls", 
                  "Self+", "Self");
    fprintf (fp, "%10s %5s %10s %10s\n", "", "Len", "", "children");
    for (i = 0 ; i < nEntries ; i++)
    {
         char len_buf[30];
         ep_list_node_t *ptr;
         entry_point_t *ep = all_eps[i];
  
         if (ep->callee_list == NULL)
             continue;

         if (ep->len == 0)
             sprintf (len_buf, "?");
         else
             sprintf (len_buf, "%d", ep->len);

         fprintf (fp, "%s\n%08x %5s %10u %10lld %10lld\n",  
		       ep->name, ep->start_pc, len_buf,
                       getnSamples (&(ep->total_icount)),
		       double2ll(getSum (&(ep->total_icount))),
		       double2ll(getSum (&(ep->self_icount))));

         fprintf (fp, "  Callee:\n    %8s %5s %10s %10s %6s  %10s %10s %10s\n", 
                  "PC", "Len", "#Calls", "Insns", "Pct.", "Avg.", "Max", "Min");
         for (ptr = ep->callee_list ; ptr != NULL ; ptr = ptr->next)
         {
             if (ptr->ep->len == 0)
                 sprintf (len_buf, "?");
             else
                 sprintf (len_buf, "%d", ptr->ep->len);

             fprintf (fp, "  %s\n  0x%08x %5s %10u %10lld %6.2f%% %10lld %10lld %10lld\n",
                      ptr->ep->name, ptr->ep->start_pc, len_buf,
                      getnSamples (&(ptr->stats)),
		      double2ll(getSum (&(ptr->stats))),
		      (float) (100.0 * double2ll(getSum (&(ptr->stats)))/getSum(&(ep->total_icount))),
		      double2ll(getAverage (&(ptr->stats))),
		      double2ll(getMaxSample (&(ptr->stats))),
		      double2ll(getMinSample (&(ptr->stats))));
         }
         fprintf (fp, "\n");
    }
}

static void print_caller_dist (FILE *fp, uint nEntries, entry_point_t *all_eps[])

{
    int i;

    fprintf (fp, "Caller distribution:\n\n");
    fprintf (fp, "%s\n%10s %5s %10s %10s %10s\n", 
                  "Name", "PC", "Code", "#Calls", 
                  "Self+", "Self");
    fprintf (fp, "%10s %5s %10s %10s\n", "", "Len", "", "children");
    for (i = 0 ; i < nEntries ; i++)
    {
         char len_buf[30];
         ep_list_node_t *ptr;
         entry_point_t *ep = all_eps[i];
  
         if (ep->caller_list == NULL)
             continue;

         if (ep->len == 0)
             sprintf (len_buf, "?");
         else
             sprintf (len_buf, "%d", ep->len);

         fprintf (fp, "%s\n%08x %5s %10u %10lld %10lld\n",  
		       ep->name, ep->start_pc, len_buf,
                       getnSamples (&(ep->total_icount)),
		       double2ll(getSum (&(ep->total_icount))),
		       double2ll(getSum (&(ep->self_icount))));

         fprintf (fp, "  Caller:\n    %8s %5s %10s %10s %6s  %10s %10s %10s\n", 
                  "PC", "Len", "#Calls", "Insns", "Pct.", "Avg.", "Max", "Min");
         for (ptr = ep->caller_list ; ptr != NULL ; ptr = ptr->next)
         {
             if (ptr->ep->len == 0)
                 sprintf (len_buf, "?");
             else
                 sprintf (len_buf, "%d", ptr->ep->len);

             fprintf (fp, "  %s\n  0x%08x %5s %10u %10lld %6.2f%% %10lld %10lld %10lld\n",
                      ptr->ep->name, ptr->ep->start_pc, len_buf,
                      getnSamples (&(ptr->stats)),
		      double2ll(getSum (&(ptr->stats))),
		      (float) (100.0 * double2ll(getSum (&(ptr->stats)))/getSum(&(ep->total_icount))),
		      double2ll(getAverage (&(ptr->stats))),
		      double2ll(getMaxSample (&(ptr->stats))),
		      double2ll(getMinSample (&(ptr->stats))));
         }
         fprintf (fp, "\n");
         fflush (fp);
    }
}

#else

/* for the build with PROFILING turned off, define these
dummy functions, which issue a warning if the user tries to
do anything with profiles
*/

#define JUST_WARN { \
    INFO_WARN (("Profiling functionality not available in this version of the simulator\n")); \
} 

extern void mark_block_enter (int profile_id, char *name, 
                              boolean is_inv_if, boolean is_athrow) JUST_WARN
extern void mark_block_exit (int profile_id) JUST_WARN

extern void profiler_init (profile_t *profile) JUST_WARN
extern void profiler_print_summary () JUST_WARN
extern void profiler_print_all (FILE *fp) JUST_WARN

extern void profile_reset (int profile_id) JUST_WARN
extern void profile_create (int profile_id) JUST_WARN
extern void profile_freeze (int profile_id, boolean freeze) JUST_WARN
extern void profile_enable (int profile_id, boolean on) JUST_WARN
extern void profile_switch (int profile_id) JUST_WARN
extern void profile_print (int profile_id, FILE *fp) JUST_WARN
extern void profile_close (int profile_id) JUST_WARN

#endif
