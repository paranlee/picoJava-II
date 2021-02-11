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
 
 
 

#ifndef _SIM_H_
#define _SIM_H_

#pragma ident "@(#)sim.h 1.10 Last modified 02/28/99 12:04:00 SMI"

EXTERN simInit _ANSI_ARGS_((Tcl_Interp *interp));

EXTERN loadClassCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN runCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN contCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN stepsCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpClassCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpRegCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpStackCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpMethodCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpMemoryCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN displayMemoryCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN displayMemoryDirectCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN writeMemoryCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN disAsmCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN disAsmAddrCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN itraceCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN itraceCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN cosimAckCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN memPeekCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN memPeekDirectCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN memPokeDirectCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN configureCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpDcacheCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpIcacheCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN boot8Cmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN scacheCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN resetCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN intrCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN loadElfCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dispCPCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN brkCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN checkpointCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN restartCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN memfileCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN bmemfileCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN loadCacheCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN dumpStatsCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN profileCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));
EXTERN createImageCmd _ANSI_ARGS_((ClientData dummy, Tcl_Interp *interp, int argc, char **argv));

EXTERN int resetLoaded;
EXTERN decafClass *currentClass;
EXTERN decafMethod *currentMethod;

EXTERN FILE *getOutputFile();
EXTERN void getRegisters();
EXTERN void vExternalReset();
EXTERN void vSetInterrupt (int offset, unsigned int irl);

#endif /* _SIM_H_ */
