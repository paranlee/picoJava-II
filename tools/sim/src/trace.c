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




static char *sccsid = "@(#)trace.c 1.4 Last modified 10/06/98 11:39:21 SMI";

#include <stdlib.h>
#include "dsv.h"
#include "iam.h"
#include "tcl.h"

/*
 * itrace on|off
 */
int
itraceCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   if (argc == 2) {
    if (strcmp(argv[1], "on") == 0) {
     ias_trace = 3;
    }
    else {
     ias_trace = strtol (argv[1], (char **) NULL, 0);
    }
	fprintf (stdout, "IAS trace level is now %d\n", ias_trace);
    return(TCL_OK);
   }

   sprintf(interp->result, "IAS trace level is %d", ias_trace);
   return TCL_OK;
}

