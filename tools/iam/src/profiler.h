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




#ifndef _PROFILER_H_
#define _PROFILER_H_

#pragma ident "@(#)profiler.h 1.5 Last modified 10/06/98 11:37:03 SMI"

#define PROFILER_HASHTABLE_SIZE 1024
#define PROFILER_MAX_NAME_LEN 256
#define PROFILER_MAX_CALL_STACK_DEPTH 4096
#define PROFILER_N_PROFILES 32

#define TRUE 1
#define FALSE 0

#define PROFILE_CREATE_CMD 1
#define PROFILE_RESET_CMD 2
#define PROFILE_FREEZE_CMD 3
#define PROFILE_UNFREEZE_CMD 4
#define PROFILE_ENABLE_CMD 5
#define PROFILE_DISABLE_CMD 6
#define PROFILE_SWITCH_CMD 7
#define PROFILE_PRINT_CMD 8
#define PROFILE_CLOSE_CMD 9

#define PROFILE_MARK_BLOCK_ENTER_CMD 20
#define PROFILE_MARK_BLOCK_EXIT_CMD 21

typedef unsigned char boolean;

/* struct ep_list_node; */

typedef struct ep {
char name[PROFILER_MAX_NAME_LEN]; /* keep this an array, not a ptr, 
                                      to simplify checkpointing */
int64_t current_self_icount;
StatisticsObject total_icount;
StatisticsObject self_icount;

uint start_pc;
uint len;

int first_stack_frame_index; /* whenever this ep is on stack, this variable =
                                index of the first stack entry which points to
                                this ep. there may be multiple entries
                                on the stack which point to this ep (for recursive functions)
                                if this ep is currently not on stack, this variable is -1 */
struct ep *next;

/* linked lists of callers and callees.
  implemented as a simple list right now, lists maintained in a way that
  the most recent caller/callee is at the head of the list.
  shd work ok since most functions will be largely partial towards 
  the same caller and callees. if it doesn't, consider replacing
  w/hashtables
*/
struct ep_list_node *caller_list;  
struct ep_list_node *callee_list;  
} entry_point_t;

typedef struct ep_list_node {
entry_point_t *ep;
StatisticsObject stats;
struct ep_list_node *next;
} ep_list_node_t;

typedef struct {
entry_point_t *buckets[PROFILER_HASHTABLE_SIZE];
uint nEntries;
uint nNonEmptyBuckets;
} hashtable_t;

typedef struct {
int64_t begin_icount;      /* icount at begin of this block */
int64_t cur_self_icount;   /* current total of all self icounts */
int64_t begin_self_icount; /* icount at last begin of self insns */
int64_t correction_icount;   /* for recursive functions, we don't want to increment the accumulated
                                icount multiple times when the function is present multiple times
                                in the stack. correction icount for a stack entry is the icount which 
                                is due to the same function (in instances above it on the call stack) 
                                and has to be subtracted from this entry's icount when it is popped 
                                */
boolean is_inv_if, is_athrow; /* flag if inv_if_q or athrow, 
                                   need special processing */
int next_stack_frame_this_ep;  /* pointer to next entry (below this one) in the stack
                                  which has the same ep - reqd for recursive calls */
entry_point_t *ep;
} profile_stackentry_t;

/* stack_ptr points to first available entry
   stack grows from lower index (0->1->2...) to higher index
*/
typedef struct {
profile_stackentry_t stack_entries[PROFILER_MAX_CALL_STACK_DEPTH];
uint stack_ptr;
} profile_stack_t;

typedef struct {
hashtable_t hashtable;
profile_stack_t profile_stack;
boolean is_enabled, is_frozen;
int64_t profile_icount;
uint max_call_depth_seen;
} profile_t;

/* we need both current profile id and a ptr to the current profile
because id's are easier to use, but for performance reasons,
we want to increment the counter in the current profile
directly in the main loop. everywhere else we use the id.
*/
extern profile_t *current_profile;
extern int current_profile_id;

extern void mark_block_enter (int profile_id, char *name, 
                              boolean is_inv_if, boolean is_athrow);
extern void mark_block_exit (int profile_id);

extern void profiler_init ();
extern void profiler_print_summary ();
extern void profiler_print_all (FILE *fp);

extern void profile_reset (int profile_num);
extern void profile_create (int profile_num);
extern void profile_freeze (int profile_num, boolean freeze);
extern void profile_enable (int profile_num, boolean on);
extern void profile_switch (int profile_num);
extern void profile_print (int profile_num, FILE *fp);

#endif /* _PROFILER_H_ */
