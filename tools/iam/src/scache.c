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



 
static char *sccsid = "@(#)scache.c 1.6 Last modified 10/06/98 11:37:07 SMI";

#include <sys/types.h>
#include <string.h>
#include <stdarg.h>
#include <assert.h>

#include "dsv.h"
#include "decaf.h"
#include "javamem.h"
#include "global_regs.h"
#include "scache.h"

/* routines to implement the stack cache */

static stack_item sCacheMem[SCACHE_SIZE];
extern int ias_scache;

void vSCacheInit ()

{
    int i;
	unsigned int deadbeef = SCACHE_INIT_VALUE;

	for (i = 0 ; i < SCACHE_SIZE ; i++)
		vSCacheWrite (i, &deadbeef);

}

/* flushes scache contents to D$/memory */

void vSCacheFlush ()

{
    int nValidEntries = 
	((int) ((unsigned int) scBottom - (unsigned int) optop))/JAVAWORDSIZE;

    unsigned int dribble_address = ((unsigned int) optop) + JAVAWORDSIZE;;

    for ( ; nValidEntries > 0 ; --nValidEntries)
    {
        WRITE_WORD ((unsigned int) dribble_address, 'D', 
                    sCacheMem[((unsigned int) dribble_address >> 2) % SCACHE_SIZE]);
        dribble_address += JAVAWORDSIZE;
    }
}
    

/* performs a read from scache */

void vSCacheRead (const unsigned int stack_offset, unsigned int *pData)

{
    memcpy (pData, &(sCacheMem[stack_offset]), JAVAWORDSIZE);
}

/* performs a write into scache */

void vSCacheWrite (const unsigned int stack_offset, unsigned int *pData)

{
    memcpy (&(sCacheMem[stack_offset]), pData, JAVAWORDSIZE);
}


/* 

update_SCache:
Simulates dribble, overflow and underflow operation of stack cache
should be called *every* time optop is updated (unless restarting
from a checkpoint)
     
optop is the new value of optop, optop_old is the value just before it
was updated 
SCBottom may be updated by this routine (due to a dribble, underflow or 
overflow operation - in fact this is the only way SCBottom can be updated)

semantics - word at address = sc_bottom is in scache.

*/

void vUpdateSCache (stack_item *old_optop)

{
    unsigned int i, fill_mark, spill_mark, javaMemAddr;
    int nValidEntries, nValidOldStackEntries;
    stack_item data;

    if (!(psr & 0x80))  /* if dribbler enable is off, do nothing and return */
		return;

    fill_mark = ((psr & 0x70000) >> 16) * 8; 
	assert (fill_mark > 0);
    spill_mark = ((psr & 0x380000) >> 19) * 8;

   /* the casts are important because nValidentries could be -ve */
    nValidEntries = 
	((int) ((unsigned int) scBottom - (unsigned int) optop))/JAVAWORDSIZE;

	/*
	if (nValidEntries > SCACHE_SIZE) { printf ("nvalidentries = %d, scbot = 0x%x, optop = 0x%x\n", nValidEntries, scBottom, optop); exit (1); }
    */

    if (nValidEntries > SCACHE_SIZE || nValidEntries < 0)
    {   /* overflow or underflow condition exists - the only
           difference between the two is that for overflow the old
           stack contents are written to memory, while they are
           discarded for underflow. underflow has to be qualified with
		   flag_return_opcode = 1, which means the current instruction
		   is a return instruction and it's ok to discard the contents
		   on underflow */

        if ((nValidEntries > SCACHE_SIZE) || 
			((nValidEntries < 0) && !flag_return_opcode))
        {   /* overflow - flush old stack cache */
	        nValidOldStackEntries = 
    		((unsigned int) scBottom - (unsigned int) old_optop)/JAVAWORDSIZE;

            assert (nValidOldStackEntries >= 0);
        	assert (nValidOldStackEntries <= SCACHE_SIZE);

    	    for (i = 0 ; i < nValidOldStackEntries ; i++)
    	    {
                 WRITE_WORD ((unsigned int) scBottom, 'D', sCacheMem[((unsigned int) scBottom >> 2) % SCACHE_SIZE]);
                 vUpdateGR (GR_sc_bottom, (unsigned int) scBottom-JAVAWORDSIZE);
            }
        }

        /* now fetch in enuff entries from just below optop to cross
           the fill mark */
        vUpdateGR (GR_sc_bottom, (unsigned int) optop);
        for (i = 0 ; i < fill_mark ; i++)
        {
            vUpdateGR (GR_sc_bottom, (unsigned int) scBottom+JAVAWORDSIZE);
            READ_WORD ((unsigned int) scBottom, 'D', data);
            memcpy (&(sCacheMem[((unsigned int) scBottom >> 2) % SCACHE_SIZE]), 
                    &data, sizeof(stack_item));
        }
    }
    else if (nValidEntries < fill_mark)
    {   /* Fill in */
        for (i = 0 ; i < fill_mark - nValidEntries ; i++)
        {
            vUpdateGR (GR_sc_bottom, (unsigned int) scBottom+JAVAWORDSIZE);
            READ_WORD ((unsigned int) scBottom, 'D', data);
            memcpy (&(sCacheMem[((unsigned int) scBottom >> 2) % SCACHE_SIZE]), 
                    &data, sizeof(stack_item));
        }
    }
    else if (nValidEntries > spill_mark)
    {   /* Spill out */
        for (i = 0 ; i < nValidEntries - spill_mark ; i++)
        {
            WRITE_WORD ((unsigned int) scBottom, 'D', sCacheMem[((unsigned int) scBottom >> 2) % SCACHE_SIZE]);
            vUpdateGR (GR_sc_bottom, (unsigned int) scBottom-JAVAWORDSIZE);
        }
    }
}

/*
  checkpoint function for scache module 
*/

int scache_checkpoint (CPR_REQUEST_T req, FILE *fp)

{
    int i;
  
    switch (req)
    {
      case CPR_QUERY:
      {
        /* always ready to checkpoint */
        break;
      }
      case CPR_CHECKPOINT:
      {
	/* start writing out all reg values */
        for (i = 0 ; i < SCACHE_SIZE ; i++)
	{
            unsigned int j;
 
            vSCacheRead (i, &j);
            CHECKING_FWRITE (&j, sizeof (j), 1, fp)
	}
        break;
      }

      case CPR_RESTART:
      {

	/* start writing out all reg values */
        for (i = 0 ; i < SCACHE_SIZE ; i++)
	{
            unsigned int j;
      
            CHECKING_FREAD (&j, sizeof (j), 1, fp)
            vSCacheWrite (i, &j);
	}
        break;
      }
    }

    return (0);
}
