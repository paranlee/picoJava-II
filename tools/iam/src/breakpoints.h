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




#ifndef _BREAKPOINTS_H_
#define _BREAKPOINTS_H_

#pragma ident "@(#)breakpoints.h 1.6 Last modified 10/06/98 11:36:36 SMI"

#include "checkpoint_types.h"

#define MAX_BRKPTS 1000 /* max number of brkpts, storage for these is */
                        /* statically allocated */

typedef enum {BRKPT_EXEC, BRKPT_READ, BRKPT_WRITE} BRKPT_ACCESS_T;

typedef struct {
    unsigned int brkpt_addr;
    BRKPT_ACCESS_T brkpt_type;
    int ignore_count;
    int is_enabled;
} breakpoint_t;

extern void brkpt_init_module ();
extern void brkpt_add (unsigned int brk_addr, BRKPT_ACCESS_T access_type);
extern void brkpt_list ();
extern void brkpt_enable (int brkpt_id);
extern void brkpt_disable (int brkpt_id);

/* disables all brkpts which match this byte address and type 
   return the brkpt id of the last brkpt which matches, -1 if no match 
 */
extern int brkpt_disable_addr (unsigned int brk_addr, BRKPT_ACCESS_T access_type);

extern void brkpt_set_ignore_count (int brkpt_id, int count);
extern int brkpt_match (unsigned int addr, unsigned int size, BRKPT_ACCESS_T access_type);

extern int brkpt_checkpoint (CPR_REQUEST_T req, FILE *fp);

#endif /* _BREAKPOINTS_H_ */

