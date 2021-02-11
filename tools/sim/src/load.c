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




static char *sccsid = "@(#)load.c 1.4 Last modified 10/06/98 11:39:15 SMI";

#include <stdio.h>
#include <string.h>
#include "dsv.h"
#include "decaf.h"
#include "tcl.h"
#include "sim.h"

int resetLoaded = 0;
/*
 * loadClass class1 class 2 ...
 *
 * redo the command will overwrite the previous loaded classes if same name
 * memory is not free at this time or no reload is allowed
 */
int
loadClassCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   int i;
   char *cptr;
   char fn[BUFSIZ];

   i = 1;
   while (argv[i] != NULL) {
    cptr = strchr(argv[i], '\0');
    cptr = cptr - strlen(".class");
    if (strcmp(cptr, ".class") == 0) {
     strcpy(fn, argv[i]);
    }
    else {
     sprintf(fn, "%s.class", argv[i]);
    }
    if (loadClassFile(fn, 0) == DSV_FAIL) {
     sprintf(interp->result, "Error: Can not load the class file %s\n", fn);
     return(TCL_ERROR);
    }
    i++;
   }
   if (i==0) {
    sprintf(interp->result, "Error: No class file specified");
    return TCL_ERROR;
   }

   return(TCL_OK);

}

