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



 
static char *sccsid = "@(#)checkpoint.c 1.9 Last modified 10/06/98 11:36:37 SMI";

#define CHECKPOINT_FILE_SIGNATURE 0x43484b50 /* ASCII "CHKP" */

/* change the version nos. every time the checkpoint format is changed! */
#define THIS_MAJOR_VERSION 1
#define THIS_MINOR_VERSION 5

#include <stdio.h>

#include "checkpoint_types.h"
#include "cm.h"
#include "global_regs.h"
#include "iam.h"
#include "scache.h"
#include "breakpoints.h"
#include "interrupts.h"
#include "cache.h"
#include "checkpoint.h"

struct checkpoint_module {
int (*cpr_function)(CPR_REQUEST_T req, FILE *fp);
char *name;
};

/* for more state to be checkpointed, the ONLY thing to be done
is to introduce the checkpoint function and the name for the 
module in this table. the last entry in the table must be NULL.
Warning:
checkpointing functions must NOT use state (variables of other
functions) during the checkpoint/restart! i.e. they shd not depend
on order in which modules are checkpointed/restarted. i.i.e. no module
can assume another module's checkpoint/restart function is being
called before/after it.
*/

struct checkpoint_module checkpoint_modules[] = {
    {cm_checkpoint, "main memory"},
    {global_regs_checkpoint, "CPU registers"},
    {cache_checkpoint, "instruction and data caches"},
    {iam_checkpoint, "simulation control"}, 
    {scache_checkpoint, "stack cache"},
    {brkpt_checkpoint, "breakpoints"},
    {intr_checkpoint, "interrupts"},
    {NULL, "ARRAY_OVERRUN-INTERNAL ERROR!!!"} /* has to be the last entry!! */
};

/* checkpoint current state to file */

int checkpoint (char *filename)

{
    FILE *fp;
    int i = 0;
    unsigned int sig = CHECKPOINT_FILE_SIGNATURE;

    for (i = 0 ; checkpoint_modules[i].cpr_function != NULL ; i++)
    {
        if ((*(checkpoint_modules[i].cpr_function))(CPR_QUERY, NULL) != 0)
	{
            fprintf (stderr, "Checkpointing failed, module \"%s\" not ready for checkpointing\n", checkpoint_modules[i].name);
            return 1;
	}
    }

    if ((fp = fopen (filename, "w")) == NULL)
    {
        fprintf (stderr, "Unable to open file %s for writing, checkpoint aborted...\n", filename);
        return 1;
    }

    CHECKING_FWRITE (&sig, sizeof (sig), 1, fp)
    sig = THIS_MAJOR_VERSION;
    CHECKING_FWRITE (&sig, sizeof (sig), 1, fp)
    sig = THIS_MINOR_VERSION;
    CHECKING_FWRITE (&sig, sizeof (sig), 1, fp)
    
    for (i = 0 ; checkpoint_modules[i].cpr_function != NULL ; i++)
    {
        if ((*(checkpoint_modules[i].cpr_function))(CPR_CHECKPOINT, fp) != 0)
	{
            fprintf (stderr, "Checkpointing failed while writing data for module \"%s\" into file %s\n", checkpoint_modules[i].name, filename);
            return 1;
	}
    }

    fclose (fp);
    return 0;
}

int restart (char *filename)

{
    FILE *fp;
    int i;
    unsigned int sig, major_rev, minor_rev;

    if ((fp = fopen (filename, "r")) == NULL)
    {
        fprintf (stderr, "Unable to open file %s for reading, restart aborted...\n", filename);
        return 1;
    }

    /* check signature first to make sure it is a valid checkpoint file */

    CHECKING_FREAD (&sig, sizeof (sig), 1, fp)    
 
    if (sig != CHECKPOINT_FILE_SIGNATURE)
    {
        fprintf (stderr, "%s is not a valid checkpoint file "
                         "(incorrect signature found)\nrestart aborted...\n", 
                         filename);
        return 1;
    }
    
    CHECKING_FREAD (&major_rev, sizeof (major_rev), 1, fp)    
    CHECKING_FREAD (&minor_rev, sizeof (minor_rev), 1, fp)    
 
    if ((major_rev != THIS_MAJOR_VERSION) || (minor_rev != THIS_MINOR_VERSION))
    {
        fprintf (stderr, "Incorrect revision number on checkpoint file %s\n"
                         "File has revision %d.%d, this version of simulator "
                         "expects revision %d.%d\n", filename, major_rev, minor_rev,
                          THIS_MAJOR_VERSION, THIS_MINOR_VERSION);
        return 1;
    }

    /* initPico once in case it has not already been done. 
       no harm if it has already been done */
    initPico ();

    /* now read in checkpointed data for all modules */

    for (i = 0 ; checkpoint_modules[i].cpr_function != NULL ; i++)
    {
        if ((*(checkpoint_modules[i].cpr_function))(CPR_RESTART, fp) != 0)
	{
            fprintf (stderr, "restart failed while reading data for module %s from file %s\n", checkpoint_modules[i].name, filename);
            return 1;
	}
    }

    fclose (fp);
    return 0;
}
