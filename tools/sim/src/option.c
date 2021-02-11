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




static char *sccsid = "@(#)option.c 1.6 Last modified 10/06/98 11:39:17 SMI";

#include <stdlib.h>
#include "dsv.h"
#include "iam.h"
#include "breakpoints.h"
#include "profiler.h"
#include "interrupts.h"
#include "tcl.h"

extern void update_psr();

/*
 * boot8
 */
int
boot8Cmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    ias_boot8 = 1;

    update_psr();

    printf("ias : Boot 8-bit mode\n");
    return(TCL_OK);

}

/*
 * reset
 */
int
resetCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{

    initPico ();
    sprintf (interp->result, "CPU has been reset\n");
    return(TCL_OK);

}

/*
 * interrupt
 */
int
intrCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    if (argc == 2) 
    {
        if (! strcasecmp (argv[1], "list"))
        {
            intr_list ();
        }
        else
        {
            sprintf(interp->result, "Invalid interrupt command\n");
            return(TCL_ERROR);
        }
    }
    else if (argc == 3)
    {
        if (! strcasecmp (argv[1], "disable"))
        {
            unsigned int intr_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            intr_disable (intr_id);

        }
        else 
        {
            /* schedule a non-repeating intr */
            intr_add (strtoull (argv[1], (char **) NULL, 0),
                      strtoul (argv[2], (char **) NULL, 0), 0);
        }
    }
    else if (argc == 4)
    {
        if (! strcasecmp (argv[1], "repeat"))
        {
            intr_add (strtoull (argv[2], (char **) NULL, 0),
                      strtoul (argv[3], (char **) NULL, 0), 1);
        }
        else 
	{
            sprintf (interp->result, "Invalid interrupt command\n");
            return (TCL_ERROR);
	}
    }
    else
    {
        sprintf(interp->result, "Invalid interrupt command\n");
        return(TCL_ERROR);
    }

    return (TCL_OK);
}

int
brkCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)

{
    if (argc == 2) 
    {
        if (! strcasecmp (argv[1], "list"))
        {
            brkpt_list ();
        }
        else
        {
            sprintf(interp->result, "Invalid breakpoint command\n");
            return(TCL_ERROR);
        }
    }
    else if (argc == 3)
    {
        if (! strcasecmp (argv[1], "exec"))
        {
            unsigned int brkpt_addr = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            brkpt_add (brkpt_addr, BRKPT_EXEC);
        }
        else if (! strcasecmp (argv[1], "read"))
        {
            unsigned int brkpt_addr = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            brkpt_add (brkpt_addr, BRKPT_READ);
        }
        else if (! strcasecmp (argv[1], "write"))
        {
            unsigned int brkpt_addr = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            brkpt_add (brkpt_addr, BRKPT_WRITE);
        }
        else if (! strcasecmp (argv[1], "access"))
        {
            unsigned int brkpt_addr = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            brkpt_add (brkpt_addr, BRKPT_READ);
            brkpt_add (brkpt_addr, BRKPT_WRITE);
        }
        else if (! strcasecmp (argv[1], "enable"))
        {
            unsigned int brkpt_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            brkpt_enable (brkpt_id);
        }
        else if (! strcasecmp (argv[1], "disable"))
        {
            unsigned int brkpt_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            brkpt_disable (brkpt_id);
        }
        else
        {
            sprintf(interp->result, "Invalid breakpoint command\n");
            return(TCL_ERROR);
        }
    }
    else if (argc == 4)
    {
        if (! strcasecmp (argv[1], "ignore"))
        {
            unsigned int brkpt_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            unsigned int ignore_count = 
                (unsigned int) strtoul (argv[3], (char **) NULL, 0);
            brkpt_set_ignore_count (brkpt_id, ignore_count);
        }
    }
    else
    {
        sprintf(interp->result, "Invalid breakpoint command\n");
        return(TCL_ERROR);
    }

    return (TCL_OK);
} 

int
profileCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)

{
    if (argc == 2) 
    {
        if (! strcasecmp (argv[1], "list"))
        {
            profiler_print_summary ();
        }
        else if (! strcasecmp (argv[1], "markenter"))
        {
            mark_block_enter (current_profile_id, "USER_DEFINED_BLOCK", FALSE, FALSE);
        }
        else if (! strcasecmp (argv[1], "markexit"))
        {
            mark_block_exit (current_profile_id);
        }
        else
        {
            sprintf(interp->result, "Invalid profile command\n");
            return(TCL_ERROR);
        }
    }
    else if (argc == 3)
    {
        if (! strcasecmp (argv[1], "create"))
        {
            unsigned int profile_id =
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_create (profile_id);
        }
        else if (! strcasecmp (argv[1], "switch"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_switch (profile_id);
        }
        else if (! strcasecmp (argv[1], "reset"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_reset (profile_id);
        }
        else if (! strcasecmp (argv[1], "print"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_print (profile_id, stdout);
        }
        else if (! strcasecmp (argv[1], "freeze"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_freeze (profile_id, TRUE);
        }
        else if (! strcasecmp (argv[1], "unfreeze"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_freeze (profile_id, FALSE);
        }
        else if (! strcasecmp (argv[1], "enable"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_enable (profile_id, TRUE);
        }
        else if (! strcasecmp (argv[1], "disable"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_enable (profile_id, FALSE);
        }
        else if (! strcasecmp (argv[1], "close"))
        {
            unsigned int profile_id = 
                (unsigned int) strtoul (argv[2], (char **) NULL, 0);
            if (profile_id == -1)
                profile_id = current_profile_id;
            profile_close (profile_id);
        }
        else
        {
            sprintf(interp->result, "Invalid profile command\n");
            return(TCL_ERROR);
        }
    }
    else
    {
        sprintf(interp->result, "Invalid profile command\n");
        return(TCL_ERROR);
    }

    return (TCL_OK);
} 
