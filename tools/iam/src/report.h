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




#ifndef _REPORT_H_
#define _REPORT_H_

#pragma ident "@(#)report.h 1.5 Last modified 10/06/98 11:37:05 SMI"

/*
 * This file defines the return code from simulation
 * A return value is an integer
 * The upper 16 bit is for identifying a subsystem
 * The lower 16 bit is for a specific error
 *
 * Subsystem identifier
 * 'h0000 -- top level
 * 'h0001 -- IU
 * 'h0002 -- Traps
 * 'h0003 -- Fatal exceptions
 *
 */

typedef struct { 
    int failure_code; 
    char failure_string[200];
} failure_t;

void printStats (char* filename);

/* successful exit code is 0. failure codes must be non-zero. */

#endif  /* _REPORT_H_ */
