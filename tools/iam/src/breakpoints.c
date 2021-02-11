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




static char *sccsid = "@(#)breakpoints.c 1.7 Last modified 10/06/98 11:36:35 SMI";

#include "iam.h"
#include "dprint.h"
#include "sim_config.h"
#include "breakpoints.h"

#ifdef SIM_BREAKPOINTS 

/* brkpts are stored in the static array brkpts of size MAX_BRKPTS - 
currently 1000, which should be more than what we need. overhead is
not too much for a large number since each entry is only 4 words = 16K
for the whole array. this number can be reduced if required.

as breakpoints are added, they are simply stored sequentially into the brkpts
array. when checking for a breakpoint match, the brkpts array is searched 
sequentially. i know a hashtable on the address would be 
faster but there is no strong motivation right now to go to the trouble
of implementing or getting a hashtable module. the common case of no
breakpoints set results in near-0 overhead anyway. also, any alternative
implementation needs to be able to maintain the order in which breakpoints 
were set since it would be nice for break_list to list breakpoints in the 
order they were set.

since this is a semi-temporary implementation of breakpoints, soon to be
superceded by the JWS frontend, i am keeping it simple.

usage details for these routines parallels the documentation in the user 
reference manual for pjsim.

*/

static breakpoint_t brkpts[MAX_BRKPTS];
static int nbrkpts_set = 0, nbrkpts_enabled = 0;

/* a brkpt id is the index of the breakpoint into the brkpts array */

/* has to be called to initialise the entire breakpoint module */

void brkpt_init_module ()

{
    nbrkpts_set = nbrkpts_enabled = 0;
}

/* returns the brkpt id of the brkpt matching brk_addr, brk_type,
   -1 if no match 
 */

int brkpt_match (unsigned int addr, unsigned int size, BRKPT_ACCESS_T access_type)

{
    int i;
    int addr_begin, addr_end;

    /* speed up the common case of no breakpoints enabled */
    if (nbrkpts_enabled == 0)
        return -1;

    addr_begin = addr;
    addr_end = addr + ((size == 0) ? 1 : ((size == 1) ? 2 : 4));

    for (i = 0 ; i < nbrkpts_set ; i++)
    {
	/* brkpt match checking returns a match when the
           address range covered by the access includes
           the address on a set breakpoint */
           
         if ((brkpts[i].is_enabled) &&
             (brkpts[i].brkpt_addr >= addr_begin) &&
             (brkpts[i].brkpt_addr < addr_end) &&
             (brkpts[i].brkpt_type == access_type))
         {
             if (brkpts[i].ignore_count == 0)
                 return i;
             else
                 --brkpts[i].ignore_count;
         }
    }

    return -1;
}

/* adds a new brkpt at addr brk_addr of type access_type */

void brkpt_add (unsigned int brk_addr, BRKPT_ACCESS_T access_type)

{
    int brk_id;

    if ((brk_id = brkpt_match (brk_addr, 0, access_type)) != -1)
    {
        INFO_WARN (("breakpoint already exists as breakpoint #%d, no action taken\n", brk_id));
        return;
    }

    if ((brk_id = brkpt_match (brk_addr, 0, access_type)) != -1)
    {
        INFO_WARN (("breakpoint already exists as breakpoint #%d, no action taken\n", brk_id));
        return;
    }

    if (nbrkpts_enabled >= MAX_BRKPTS)
    {
        INFO_WARN (("Maximum no. of breakpoints (%d) already exist, cannot set any new breakpoints\nNo action taken\n", MAX_BRKPTS));
        return;
    }

    nbrkpts_enabled++;

    brkpts[nbrkpts_set].brkpt_addr = brk_addr;
    brkpts[nbrkpts_set].brkpt_type = access_type;
    brkpts[nbrkpts_set].is_enabled = 1;
    brkpts[nbrkpts_set].ignore_count = 0;
    nbrkpts_set++;
}

/* prints out a list of all brkpts currently known */

void brkpt_list ()

{
    int i;

    BRKPT_PRINTF (("Brkpt#      Address     Type    Enabled    Ignore count\n"));
    for (i = 0 ; i < nbrkpts_set ; i++)
    {
         BRKPT_PRINTF ((" %2d       0x%08x   %5s     %3s           %d\n", 
                 i, brkpts[i].brkpt_addr, 
                 (brkpts[i].brkpt_type == BRKPT_EXEC) ? "Code" :
                 (brkpts[i].brkpt_type == BRKPT_READ) ? "Read" : "Write",
                 brkpts[i].is_enabled ? "Yes" : "No",
                 brkpts[i].ignore_count));
    }
}

/* enables brkpt# brkpt_id */

void brkpt_enable (int brkpt_id)

{
    if (brkpt_id >= nbrkpts_set)
    {
        INFO_WARN (("invalid breakpoint: %d, no action taken\n", brkpt_id));
        return;
    }

    brkpts[brkpt_id].is_enabled = 1;
    nbrkpts_enabled++;
}

/* disables brkpt# brkpt_id */

void brkpt_disable (int brkpt_id)

{
    if (brkpt_id >= nbrkpts_set)
    {
        INFO_WARN (("invalid breakpoint: %d, no action taken\n", brkpt_id));
        return;
    }

    brkpts[brkpt_id].is_enabled = 0;
    nbrkpts_enabled--;
}

/* disables all brkpts which match this byte address and type 
   return the brkpt id of the last brkpt which matches this spec,
   -1 if no match.
*/

int brkpt_disable_addr (unsigned int brk_addr, BRKPT_ACCESS_T access_type)

{
    int i;
    int last_match = -1;

    for (i = 0 ; i < nbrkpts_set ; i++)
    {
	/* check all brkpts entries for this addr/type */
           
         if ((brkpts[i].is_enabled) &&
             (brkpts[i].brkpt_addr == brk_addr) &&
             (brkpts[i].brkpt_type == access_type))
         {
             brkpt_disable (i);
             last_match = i;
         }
    }
 
    return last_match;
}

/* sets the ignore count of brkpt# brkpt_id to count */

void brkpt_set_ignore_count (int brkpt_id, int count)

{
    if (brkpt_id >= nbrkpts_set)
    {
        INFO_WARN (("invalid breakpoint: %d, no action taken\n", brkpt_id));
        return;
    }

    if (count < 0)
    {
        INFO_WARN (("ignore count must be >= 0, no action taken\n"));
        return;
    }
      
    brkpts[brkpt_id].ignore_count = count;
}

/* checkpointing of the breakpoint mechanism.
format written into the checkpoint file:
nbrkpts_set, nbrkpts_enabled, MAX_BRKPTS, the entire brkpts array */

int brkpt_checkpoint (CPR_REQUEST_T req, FILE *fp)

{
    unsigned int i;

    switch (req)
    {
      case CPR_QUERY:
        break;

      case CPR_CHECKPOINT:
        CHECKING_FWRITE (&nbrkpts_set, sizeof (nbrkpts_set), 1, fp)
        CHECKING_FWRITE (&nbrkpts_enabled, sizeof (nbrkpts_enabled), 1, fp)

        i = MAX_BRKPTS;
        CHECKING_FWRITE (&i, sizeof (i), 1, fp)

        CHECKING_FWRITE (brkpts, sizeof (breakpoint_t), MAX_BRKPTS, fp)
        break;

      case CPR_RESTART:
        CHECKING_FREAD (&nbrkpts_set, sizeof (nbrkpts_set), 1, fp)
        CHECKING_FREAD (&nbrkpts_enabled, sizeof (nbrkpts_enabled), 1, fp)

        CHECKING_FREAD (&i, sizeof (i), 1, fp)

        if (i != MAX_BRKPTS)
            return 1;

        CHECKING_FREAD (brkpts, sizeof (breakpoint_t), MAX_BRKPTS, fp)
        break;
    }

    return 0;
}

#else

/* for the build with SIM_BREAKPOINTS turned off, define these
dummy functions, which issue a warning if the user tries to
do anything with breakpoints.
*/

#define JUST_WARN { \
    INFO_WARN (("Simulator breakpoints are not available in this version of the simulator\n")); \
} 

void brkpt_init_module () JUST_WARN
void brkpt_add (unsigned int brk_addr, BRKPT_ACCESS_T access_type) JUST_WARN
void brkpt_list () JUST_WARN
void brkpt_enable (int brkpt_id) JUST_WARN
void brkpt_disable (int brkpt_id) JUST_WARN
int brkpt_disable_addr (unsigned int brk_addr, BRKPT_ACCESS_T access_type) JUST_WARN
void brkpt_set_ignore_count (int brkpt_id, int count) JUST_WARN
int brkpt_match (unsigned int addr, unsigned int size, BRKPT_ACCESS_T access_type) JUST_WARN
int brkpt_checkpoint (CPR_REQUEST_T req, FILE *fp) { return 0; }

#endif
