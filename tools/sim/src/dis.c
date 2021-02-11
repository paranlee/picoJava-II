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




static char *sccsid = "@(#)dis.c 1.5 Last modified 10/06/98 11:39:10 SMI";

#include <stdio.h>
#include "dsv.h"
#include "decaf.h"
#include "tcl.h"
#include "sim.h"
#include "cm.h"
#include "global_regs.h"

int
disAsmAddrCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int addr;
   unsigned int len;
   FILE *fp;

   if (argc <= 1) {
    addr = (int)pc;
   }
   else if (argc == 2) {
    addr = strtoul (argv[1], (char **) NULL, 0);
    len = 1;
   }
   else {
    addr = strtoul (argv[1], (char **) NULL, 0);
    len = strtoul (argv[2], (char **) NULL, 0);
   }

   fp = getOutputFile();
   disAssembly((unsigned char *)addr, len, fp);
   return TCL_OK;
}

/*
 *  disAsm className methodName
 */
int
disAsmCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   char *methodName;
   char *className;
   decafClass_for_classLoader *dcls;
   decafMethod_for_classLoader *m;
   FILE *fp;
   

   if (argc <= 2) {
    /* dump current method */
    sprintf(interp->result, "Error: Class and method names not specified");
    return TCL_ERROR;
   }

   className = argv[1];
   dcls = cmFindClass(className);
   if (dcls == NULL) {
    sprintf(interp->result, "Error: Can not find %s class", className);
    return TCL_ERROR;
   }

   methodName = argv[2];
   m = cmFindMethod(dcls, methodName);
   if (m == NULL) {
    sprintf(interp->result, "Error: Can not find %s method", methodName);
    return TCL_ERROR;
   }

   fp = getOutputFile();
   disAsmMethod(m, fp);

   return TCL_OK;

}

