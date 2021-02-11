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




static char *sccsid = "@(#)ack.c 1.3 Last modified 10/06/98 11:39:08 SMI";

#include <stdlib.h>
#include "dsv.h"
#include "tcl.h"

/*
 * cosimAck fileName
 */
int
cosimAckCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   int fd;
   static char st=0;

   fd = atoi(argv[1]);

   if (write(fd, &st, sizeof(char)) < 0) {
    sprintf(interp->result, "Can not write to ack fd\n");
    return TCL_ERROR;
   }

   /* printf("CMD : completed\n"); */

   return TCL_OK;
}

