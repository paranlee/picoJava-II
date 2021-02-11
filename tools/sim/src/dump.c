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




static char *sccsid = "@(#)dump.c 1.8 Last modified 10/06/98 11:39:11 SMI";

#include <stdio.h>
#include "dsv.h"
#include "decaf.h"
#include "tcl.h"
#include "iam.h"
#include "sim.h"
#include "global_regs.h"
#include "cm.h"
#include "report.h"

static FILE *outfp;

/*
 * display constant pool
 */
int
dispCPCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
  int index;
  int i;

  if (argc <= 1) {
   /* display the entire constant pool */
   index = findConstanPoolCount(const_pool);
   if (index == -1) {
    printf("Error: no loaded class has constant pool value 0x%08x\n", const_pool);
    return TCL_ERROR;
   }
   outfp = getOutputFile();
   dumpRelConstantPool(findConstanPoolCount(const_pool), 
                      (int)const_pool-8, outfp);
   return TCL_OK;
  }

  index = strtoul (argv[1], (char **) NULL, 0);


  if (index <= 0) {
   printf("Wrong constant pool index %d\n", index);
   return TCL_ERROR;
  }
  i = findConstanPoolCount(const_pool);
  if (i == -1) {
   printf("Error: no loaded class has constant pool value 0x%08x\n", const_pool);
   return TCL_ERROR;
  }
  if (index >= i) {
   printf("Wrong constant pool index %d\n", index);
   return TCL_ERROR;
  }

  outfp = getOutputFile();
  dumpRelConstantPoolIndex(index, const_pool, outfp);

  return(TCL_OK);
}

/*
 * dumpClass className
 */
int
dumpClassCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   
   char *className;
   decafClass_for_classLoader *dcls;

   if (argc <= 1) {
    /* dump all classes */
    outfp = getOutputFile();
    dumpCommonMemory(outfp);
   
    return TCL_OK;
   }

   className = argv[1];
   dcls = cmFindClass(className);
   if (dcls == NULL) {
    sprintf(interp->result, "Error: Cannot find class %s ", className);
    return TCL_ERROR;
   }
   outfp = getOutputFile();

   dumpClass(dcls, outfp);

   return TCL_OK;
}

/*
 * dumpReg [regName], default all
 */
int
dumpRegCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{

   outfp = getOutputFile();
   if (argc <= 1) {
    DisplayReg(NULL, outfp); 
    return TCL_OK;
   }
 
   DisplayReg(argv[1], outfp);
   fflush(outfp);
 
   return TCL_OK;
}

/*
 * dumpStack [depths]
 */
int
dumpStackCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   int depth;

   if (argc <= 1) {
    depth = 8; /* default value */
   }
   else {
    depth = strtoul (argv[1], (char **) NULL, 0);
   }
   outfp = getOutputFile();
 
   DisplayStack(depth, outfp);
   fflush(outfp);

   return TCL_OK;

}

/*
 * dumpMethod className methodName
 */
int
dumpMethodCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   char *methodName;
   char *className;
   decafClass_for_classLoader *dcls;
   decafMethod_for_classLoader *m;
   

   if (argc <= 2) {
    /* dump current method */
    sprintf(interp->result, "Error: Class and method names not specified");
    return TCL_ERROR;
   }

   className = argv[1];
   dcls = cmFindClass(className);
   if (dcls == NULL) {
    sprintf(interp->result, "Error: Cannot find class %s", className);
    return TCL_ERROR;
   }

   methodName = argv[2];
   m = cmFindMethod(dcls, methodName);
   if (m == NULL) {
    sprintf(interp->result, "Error: Cannot find method %s in class %s", methodName, className);
    return TCL_ERROR;
   }

   outfp = getOutputFile();
   dumpOneMethod(m, outfp);

   return TCL_OK;

}

/*
 * dumpMemory
 */
int
dumpMemoryCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   outfp = getOutputFile();
   dumpCommonMemory(outfp);
   
   return TCL_OK;
}

/*
 * displayMemory address [length]
 */
int
displayMemoryCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int addr;
   unsigned int length;
   int i, j, k, m;

   if (argc <= 1) {
    sprintf(interp->result, "Error: Address must be specified");
    return TCL_ERROR;
   }
   addr = strtoul (argv[1], (char **) NULL, 0);

   if (argc >= 3) {
    length = strtoul (argv[2], (char **) NULL, 0);
   }
   else {
    length = 1;
   }

   for (i = addr & 0xFFFFFFFC ; i < addr + length ; i += 4)
   {
	   j = readProgMem (i);
	   fprintf (stdout, "0x%08x 0x%08x  ", i, j);
	   for (k = 3 ; k >= 0 ; k--)
	   {
			m = (j >> (k * 8)) & 0xff;
	        fprintf (stdout, "%c", ((m > 32) && (m < 127)) ? (char) m : '.');

       }
	   fprintf (stdout, "\n");
   }
   
   return TCL_OK;
}

int
displayMemoryDirectCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int addr;
   unsigned int length;

   if (argc <= 1) {
    sprintf(interp->result, "Error: Address must be specified");
    return TCL_ERROR;
   }

   addr = strtoul (argv[1], (char **) NULL, 0);

   if (argc >= 3) {
    length = strtoul (argv[2], (char **) NULL, 0);
   }
   else {
    length = 1;
   }

   outfp = getOutputFile();
   if (cmMemoryDirectDump(addr, length, outfp) != DSV_SUCCESS) {
    return TCL_ERROR;
   }
   
   return TCL_OK;
}
/*
 * writeMemory address value
 */
int
writeMemoryCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
   unsigned int addr;
   unsigned int value;

   if (argc <= 2) {
    sprintf(interp->result, "Error: Address and value must be specified");
    return TCL_ERROR;
   }

   addr = strtoul (argv[1], (char **) NULL, 0);
   value = strtoul (argv[2], (char **) NULL, 0);

   if (cmMemoryDirectWrite(addr, (char)value) != DSV_SUCCESS) {
    return TCL_ERROR;
   }
   
   return TCL_OK;
}

int
memPokeDirectCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    unsigned int addr;
    unsigned int value;

    if (argc != 3) {
     return(TCL_ERROR);
    }

    addr = strtoul (argv[1], (char **) NULL, 0);
    value = strtoul (argv[2], (char **) NULL, 0);

    cmPoke(addr, value);

    return(TCL_OK);
}

int
memPeekCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    unsigned int addr, data;

    if (argc != 2) {
     return(TCL_ERROR);
    }

    addr = strtoul (argv[1], (char **) NULL, 0);

    data = readProgMem (addr);
    sprintf(interp->result, "0x%08x", data);

    return(TCL_OK);
}

int
memPeekDirectCmd(ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    unsigned int addr, data;

    if (argc != 2) {
     return(TCL_ERROR);
    }

    addr = strtoul (argv[1], (char **) NULL, 0);

    data = cmPeek (addr);
    sprintf(interp->result, "0x%08x", data);

    return(TCL_OK);
}

int dumpStatsCmd (ClientData dummy, Tcl_Interp *interp, int argc, char **argv)
{
    unsigned int addr, data;

    if (argc > 2) {
     return(TCL_ERROR);
    }

    if (argc > 1) 
        printStats (argv[1]);
    else
        printStats (NULL);

    return(TCL_OK);
}

