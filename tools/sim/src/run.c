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




static char *sccsid = "@(#)run.c 1.7 Last modified 10/06/98 11:39:18 SMI";

#include <stdio.h>
#include "dsv.h"
#include "decaf.h"
#include "cm.h"
#include "checkpoint.h"
#include "tcl.h"
#include "sim.h"

decafClass *currentClass = NULL;
decafMethod *currentMethod = NULL;

/*
 * run [numSteps]
 */
int
runCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int step;

   if (argc <= 1) {
       executeBytecode (-1, 0);
   }
   else
   {
       /* get the number of steps */
       step = strtoul (argv[1], (char **) NULL, 0);
       executeBytecode (step, 0);
   }

   getRegisters();
   return TCL_OK;
}

int
contCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)

{
    executeBytecode (-1, 1);
    return TCL_OK;
}

/*
 * steps [numSteps]
 */
int
stepsCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int step;
   char cmd[BUFSIZ];

   /* get the number of steps */
   if (argc <= 1) {
    step = 1;
   }
   else {
    step = strtoul (argv[1], (char **) NULL, 0);
   }

   executeBytecode (step, 1);

   /* get the current pointers */
   getRegisters();
   return TCL_OK;
}

int
checkpointCmd (ClientData dummy, Tcl_Interp *interp, int argc, char **argv)

{
   if (argc != 2) {
    sprintf(interp->result, "Usage: checkpoint <filename>");
    return TCL_ERROR;
   }
 
   checkpoint (argv[1]);
   return TCL_OK;
}

int
restartCmd (ClientData dummy, Tcl_Interp *interp, int argc, char **argv)

{
   if (argc != 2) {
    sprintf(interp->result, "Usage: restart <filename>");
    return TCL_ERROR;
   }
 
   restart (argv[1]);
   return TCL_OK;
}
