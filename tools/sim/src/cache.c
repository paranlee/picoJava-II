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
 
 
 

static char *sccsid = "@(#)cache.c 1.11 Last modified 02/28/99 16:52:20 SMI";

#include <stdlib.h>
#include "dsv.h"
#include "tcl.h"
#include "decaf.h"
#include "sim.h"
#include "iam.h"
#include "cache.h"
#include "global_regs.h"
#include "commands.h"


int
configureCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   argv++;   /* get rid of configure */
   doConfigureCmd (argc-1, argv);
   return TCL_OK;
}

int
dumpDcacheCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   doDumpDCacheCmd (argc, argv);
   return TCL_OK;
}

int
dumpIcacheCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   doDumpICacheCmd (argc, argv);
   return TCL_OK;
}

int
scacheCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   doSCacheCmd (argc, argv);
   return TCL_OK;
}

int loadCacheCmd (ClientData dummy, Tcl_Interp *interp, int argc, char **argv)

{
    if (argc != 2)
    {
        sprintf (interp->result, "Usage: loadCache <path to cache initialisation files>\n");
        return TCL_ERROR;
    }

    if (preloadCaches (argv[1]))
        return TCL_ERROR;

    return TCL_OK;
}
