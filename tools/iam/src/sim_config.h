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




#ifndef _SIM_CONFIG_H_
#define _SIM_CONFIG_H_

#pragma ident "@(#)sim_config.h 1.5 Last modified 10/06/98 11:37:11 SMI"


/* some of these can be turned off to speed execution of 
the simulator at the expense of reduced exception checking
or debug info */

/*
#define TRACING 
*/
#define CHECK_EXCEPTIONS 
#define PICO_BREAKPOINTS 
#define PICO_INTERRUPTS 
#define SIM_BREAKPOINTS 
#define MEM_PROTECTION_CHECK
#define INLINE_STATS 
#define PROFILING 

/* any new option added here must also be reflected in the messages
   printed at startup (when simulator config is printed out) - update
   this in sim/src/tclAppInit.c
*/

#endif /* _SIM_CONFIG_H_ */
