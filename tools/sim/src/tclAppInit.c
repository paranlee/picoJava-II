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




static char *sccsid = "@(#)tclAppInit.c 1.6 Last modified 10/06/98 11:39:20 SMI";

/* 
 * tclAppInit.c --
 *
 *	Provides a default version of the main program and Tcl_AppInit
 *	procedure for Tcl applications (without Tk).
 *
 * Copyright (c) 1993 The Regents of the University of California.
 * Copyright (c) 1994-1995 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 */

#include <stdlib.h>
#include "dsv.h"
#include "decaf.h"
#include "tcl.h"
#include "sim.h"
#include "sim_config.h"
#include "build_info.h"

/*
 * The following variable is a special hack that is needed in order for
 * Sun shared libraries to be used for Tcl.
 */

extern int matherr();
int *tclDummyMathPtr = (int *) matherr;

#ifdef TCL_TEST
EXTERN int		Tcltest_Init _ANSI_ARGS_((Tcl_Interp *interp));
#endif /* TCL_TEST */

/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	This is the main program for the application.
 *
 * Results:
 *	None: Tcl_Main never returns here, so this procedure never
 *	returns either.
 *
 * Side effects:
 *	Whatever the application does.
 *
 *----------------------------------------------------------------------
 */
extern int ldrNameChange;

static void printConfigurationLine ()

{
    fprintf (stdout, "Simulator Configuration:\n");
#ifdef PICO_BREAKPOINTS
    fprintf (stdout, "Pico breakpoints registers   : present\n");
#else
    fprintf (stdout, "Pico breakpoints registers   : absent\n");
#endif

#ifdef SIM_BREAKPOINTS
    fprintf (stdout, "Simulator breakpoints        : present\n");
#else
    fprintf (stdout, "Simulator breakpoints        : absent\n");
#endif

#ifdef PICO_INTERRUPTS
    fprintf (stdout, "Interrupt functionality      : present\n");
#else
    fprintf (stdout, "Interrupt functionality      : absent\n");
#endif

#ifdef MEM_PROTECTION_CHECK
    fprintf (stdout, "Memory protection checks     : present\n");
#else
    fprintf (stdout, "Memory protection checks     : absent\n");
#endif

#ifdef TRACING
    fprintf (stdout, "Tracing functionality        : present\n");
#else
    fprintf (stdout, "Tracing functionality        : absent\n");
#endif

#ifdef PROFILING
    fprintf (stdout, "Collection of inlining stats : present\n");
#else
    fprintf (stdout, "Collection of inlining stats : absent\n");
#endif
#ifdef PROFILING
    fprintf (stdout, "Profiling functionality      : present\n");
#else
    fprintf (stdout, "Profiling functionality      : absent\n");
#endif

    fprintf (stdout, "\n");
}

int
main(argc, argv)
    int argc;			/* Number of command-line arguments. */
    char **argv;		/* Values of command-line arguments. */
{
    char path[BUFSIZ];
    char *cptr;
    int i;

    fprintf (stdout, "picoJava IAS version %s, built %s\n", ias_version, build_date);
    system("/bin/uname -a");
    printConfigurationLine ();

    if ((cptr=getenv("DSVHOME"))==NULL) {
     fprintf (stderr, "IAS: Environment variable DSVHOME not set! Bailing out ...\n");
	 exit (1);
    }

    sprintf(path,"TCL_LIBRARY=%s/etc/tcl", cptr);
    putenv(path);

    if ((argc > 1) && (strcmp(argv[1], "-nmc") == 0)) {
     ldrNameChange = 0; /* @@ */
     for (i=1; i < argc-1; i++) {
      argv[i] = argv[i+1];
     }
     argc--;
    }

    decaf = 1;
    if (cmInit(NULL) == DSV_FAIL) {
     printf("IAS Error: Cannot initialize common memory for picoJava\n");
     exit(-1);
    }

    if (resetLoaded == 0) {
     loadTrapHandlers();
     resetLoaded = 1;
    }
    Tcl_Main(argc, argv, Tcl_AppInit);
    return 0;			/* Needed only to prevent compiler warning. */
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *	Most applications, especially those that incorporate additional
 *	packages, will have their own version of this procedure.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in interp->result if an error occurs.
 *
 * Side effects:
 *	Depends on the startup script.
 *
 *----------------------------------------------------------------------
 */

int
Tcl_AppInit(interp)
    Tcl_Interp *interp;		/* Interpreter for application. */
{
    if (Tcl_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }

#ifdef TCL_TEST
    if (Tcltest_Init(interp) == TCL_ERROR) {
	return TCL_ERROR;
    }
    Tcl_StaticPackage(interp, "Tcltest", Tcltest_Init,
            (Tcl_PackageInitProc *) NULL);
#endif /* TCL_TEST */

    if (simInit(interp) == TCL_ERROR) {
     return TCL_ERROR;
    }

    /*
     * Call the init procedures for included packages.  Each call should
     * look like this:
     *
     * if (Mod_Init(interp) == TCL_ERROR) {
     *     return TCL_ERROR;
     * }
     *
     * where "Mod" is the name of the module.
     */

    /*
     * Call Tcl_CreateCommand for application-specific commands, if
     * they weren't already created by the init procedures called above.
     */

    /*
     * Specify a user-specific startup file to invoke if the application
     * is run interactively.  Typically the startup file is "~/.apprc"
     * where "app" is the name of the application.  If this line is deleted
     * then no user-specific startup file will be run under any conditions.
     */

    Tcl_SetVar(interp, "tcl_rcFileName", ".iasrc", TCL_GLOBAL_ONLY);

/*
    if (resetLoaded == 0) {
     loadTrapHandlers();
     resetLoaded = 1;
    }
*/
    return TCL_OK;
}

