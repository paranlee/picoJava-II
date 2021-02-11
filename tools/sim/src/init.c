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
 
 
 

static char *sccsid = "@(#)init.c 1.15 Last modified 03/01/99 13:10:34 SMI";

#include <stdio.h>

#include "dsv.h"
#include "cm.h"
#include "decaf.h"
#include "tcl.h"
#include "iam.h"
#include "sim.h"
#include "global_regs.h"

static FILE *outfp=stdout;

static Tcl_Interp *ip;

EXTERN unsigned int readProgMem(unsigned int);

int stackTop1;
int stackTop2;
int stackTop3;
int stackTop4;
int stackTop5;

simInit(Tcl_Interp *interp)
{
   char cmd[BUFSIZ];

   ip = interp;

   Tcl_CreateCommand(interp, "loadClass", loadClassCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "loadElf", loadElfCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "run", runCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "cont", contCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "configure", configureCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "steps", stepsCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpClass", dumpClassCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpReg", dumpRegCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpStack", dumpStackCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpMethod", dumpMethodCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "readMemory", displayMemoryCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "readMemoryDirect", displayMemoryDirectCmd, 
            (ClientData) 0, (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "writeMemory", writeMemoryCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "disAsm", disAsmCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "disAsmAddr", disAsmAddrCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "itrace", itraceCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "cosimAck", cosimAckCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "memPeek", memPeekCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "memPeekDirect", memPeekDirectCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "memPoke", memPokeDirectCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "memPokeDirect", memPokeDirectCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpDcache", dumpDcacheCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpIcache", dumpIcacheCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "boot8", boot8Cmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "scache", scacheCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "reset", resetCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "intr", intrCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);

/* the dispCP command is present, but kinda vaguely works,
   so we don't document it publicly. only people who know exactly
   how it works shd use it. same thing for dispLV */
   Tcl_CreateCommand(interp, "dispCP", dispCPCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "brk", brkCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "checkpoint", checkpointCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "restart", restartCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "memfile", memfileCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "bmemfile", bmemfileCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "loadCache", loadCacheCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "dumpStats", dumpStatsCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "profile", profileCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);
   Tcl_CreateCommand(interp, "createImage", createImageCmd, (ClientData) 0,
            (Tcl_CmdDeleteProc *) NULL);

   /* initialise caches according to proc_type - default 16K/16K I/D for maya,
      4K/8K for pico. proc_type has been set up before we come here since 
      it is done in cmInit */

   initPico ();

   getRegisters();
   /* Variable sections */
   Tcl_LinkVar(interp, "stackTop1", (char *)&stackTop1, TCL_LINK_INT);
   Tcl_LinkVar(interp, "stackTop2", (char *)&stackTop2, TCL_LINK_INT);
   Tcl_LinkVar(interp, "stackTop3", (char *)&stackTop3, TCL_LINK_INT);
   Tcl_LinkVar(interp, "stackTop4", (char *)&stackTop4, TCL_LINK_INT);
   Tcl_LinkVar(interp, "stackTop5", (char *)&stackTop5, TCL_LINK_INT);

   Tcl_LinkVar(interp, "optop", (char *)&optop, TCL_LINK_INT);
   Tcl_LinkVar(interp, "vars", (char *)&vars, TCL_LINK_INT);
   Tcl_LinkVar(interp, "userrange1", (char *)&userrange1, TCL_LINK_INT);
   Tcl_LinkVar(interp, "userrange2", (char *)&userrange2, TCL_LINK_INT);
   Tcl_LinkVar(interp, "pc", (char *)&pc, TCL_LINK_INT);
   Tcl_LinkVar(interp, "psr", (char *)&psr, TCL_LINK_INT);
   Tcl_LinkVar(interp, "oplim", (char *)&oplim, TCL_LINK_INT);
   Tcl_LinkVar(interp, "trapbase", (char *)&trapbase, TCL_LINK_INT);
   Tcl_LinkVar(interp, "versionid", (char *)&versionId, TCL_LINK_INT);
   Tcl_LinkVar(interp, "frame", (char *)&frame, TCL_LINK_INT);
   Tcl_LinkVar(interp, "cp", (char *)&const_pool, TCL_LINK_INT);
   Tcl_LinkVar(interp, "sc_bottom", (char *)&scBottom, TCL_LINK_INT);
   Tcl_LinkVar(interp, "hcr", (char *)&hcr, TCL_LINK_INT);

   Tcl_LinkVar(interp, "global0", (char *)&global0, TCL_LINK_INT);
   Tcl_LinkVar(interp, "global1", (char *)&global1, TCL_LINK_INT);
   Tcl_LinkVar(interp, "global2", (char *)&global2, TCL_LINK_INT);
   Tcl_LinkVar(interp, "global3", (char *)&global3, TCL_LINK_INT);

   Tcl_LinkVar(interp, "brk1a", (char *)&brk1a, TCL_LINK_INT);
   Tcl_LinkVar(interp, "brk2a", (char *)&brk2a, TCL_LINK_INT);
   Tcl_LinkVar(interp, "brk12c", (char *)&brk12c, TCL_LINK_INT);

   Tcl_LinkVar(interp, "lockaddr0", (char *)&(lockAddr[0]), TCL_LINK_INT);
   Tcl_LinkVar(interp, "lockaddr1", (char *)&(lockAddr[1]), TCL_LINK_INT);
   Tcl_LinkVar(interp, "lockcount0", (char *)&(lockCount[0]), TCL_LINK_INT);
   Tcl_LinkVar(interp, "lockcount1", (char *)&(lockCount[1]), TCL_LINK_INT);

   Tcl_LinkVar(interp, "gc_config", (char *)&gcConfig, TCL_LINK_INT);

   Tcl_LinkVar(interp, "sc_bottom_min", (char *)&sc_bottom_min, TCL_LINK_INT);
   Tcl_LinkVar(interp, "sc_bottom_max", (char *)&sc_bottom_max, TCL_LINK_INT);

   Tcl_LinkVar(interp, "icount_high", (char *)&icount, TCL_LINK_INT|TCL_LINK_READ_ONLY);
   Tcl_LinkVar(interp, "icount_low", (char *)((int)&icount + 4), TCL_LINK_INT|TCL_LINK_READ_ONLY);

   sprintf(cmd, "%s/etc/sim/sim.tcl", getenv("DSVHOME"));
   if (Tcl_EvalFile(interp, cmd) == TCL_ERROR) 
   {
       printf("Error : unable to execute Tcl control file: %s, exiting...\n", cmd);
       exit(-1);
   }


   return(TCL_OK);
}

static char oldFileName[BUFSIZ]="stdout";

FILE *
getOutputFile()
{
   char *outputFileName;

   outputFileName = Tcl_GetVar(ip, "dumpFile", TCL_GLOBAL_ONLY);
   if (outputFileName == NULL) {
    outfp = stdout;
    return(outfp);
   }
   if (strcmp(outputFileName, oldFileName)==0) {
    /* rewind is for saving disk space */
    /* rewind(outfp); */
    return(outfp);
   }
   else {
    if (outfp != stdout) fclose(outfp);
    outfp = fopen(outputFileName, "w");
    if (outfp == NULL) {
     printf("Error: Can not open %s for write\n", outputFileName);
     outfp = stdout;
     strcpy(oldFileName, "stdout");
    }
    else {
     strcpy(oldFileName, outputFileName);
    }
   }

   return(outfp);
}

void
getRegisters()
{
   stackTop1 = (int)readProgMem((unsigned int) optop + 4);
   stackTop2 = (int)readProgMem((unsigned int) optop + 8);
   stackTop3 = (int)readProgMem((unsigned int) optop + 12);
   stackTop4 = (int)readProgMem((unsigned int) optop + 16);
   stackTop5 = (int)readProgMem((unsigned int) optop + 20);

   fflush(stdout);
}
