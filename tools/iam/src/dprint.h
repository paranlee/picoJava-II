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




#ifndef _DPRINT_H_
#define _DPRINT_H_

#pragma ident "@(#)dprint.h 1.7 Last modified 10/06/98 11:36:42 SMI"

#include <stdio.h>

#include "iam.h"

#define INSTR_TRACE_DBG_LVL 3 /* instruction disassembly */
#define IRL_CHANGE_LVL 3      /* message whenever IRL pins change */
#define TRAP_DBG_LVL 1        /* messages at trap entry and exit points */
#define INTR_MSG_LVL 1        /* messages at trap entry and exit points */
#define GDB_DBG_LVL  2        /* messages at GDB interface functions */
#define JSR_DBG_LVL 2         /* messages at jsr and return points */
#define PROFILE_DBG_LVL 3     /* messages at profile entry and return points */
#define REGDUMP_DBG_LVL 4     /* register dump before each instruction */
#define MEM_DBG_LVL 8         /* messages for every memory access */

#define DPRINTF(dbg_lvl, print_str) { \
if (ias_trace >= (dbg_lvl)) \
{ printf ("TRACE(%d):", dbg_lvl); printf print_str; } }

#define BRKPT_PRINTF(print_str) {  printf print_str; }
#define INTR_PRINTF(print_str) {  DPRINTF (INTR_MSG_LVL, print_str); }

#define INFO_WARN(print_str) { \
printf ("pjsim Warning: "); printf print_str; \
}

#define WARN(print_str) { \
printf ("pjsim Warning: "); printf print_str; \
if (exit_on_warning) { \
   printf ("env-var PJSIM_EXIT_ON_WARNING set, exiting ...\n"); \
   exit (1); \
} }

#endif /* _DPRINT_H_ */
