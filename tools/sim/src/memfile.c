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




static char *sccsid = "@(#)memfile.c 1.2 Last modified 10/06/98 11:39:16 SMI";


#include <stdio.h>

#include "dsv.h"
#include "decaf.h"
#include "cm.h"
#include "tcl.h"
#include "sim.h"


int memfileCmd (ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int step;

   if (argc != 2) {
    sprintf(interp->result, "Usage: memfile <memfile>");
    return TCL_ERROR;
   }
   if (initFile (argv[1]) != 0)
   {
       sprintf (interp->result, "Error: unable to load text init file: %s\n", argv[1]);
       return TCL_ERROR;
   }

   return TCL_OK;
}

int bmemfileCmd (ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int step;

   if (argc != 2) {
    sprintf(interp->result, "Usage: bmemfile <memfile>");
    return TCL_ERROR;
   }
   if (bInitFile (argv[1]) != 0)
   {
       sprintf (interp->result, "Error: unable to load binary init file: %s\n", argv[1]);
       return TCL_ERROR;
   }

   return TCL_OK;
}
