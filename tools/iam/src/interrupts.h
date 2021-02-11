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




#ifndef _INTERRUPTS_H_
#define _INTERRUPTS_H_

#pragma ident "@(#)interrupts.h 1.5 Last modified 10/06/98 11:36:53 SMI"

#include "typedefs_md.h"
#include "checkpoint_types.h"

#define MAX_INTRS 1000

void intr_init_module ();
void intr_add (int64_t count, int irl, int is_repeating);
void intr_dispatch ();
void intr_schedule_next ();
void intr_disable (int intr_id);
void intr_list ();

typedef struct {
    int irl;          /* IRL level (0 = NMI) */
    int64_t next_intr_at; /* time at which next intr is scheduled */
    int is_enabled;   /* 1 if enabled */
    int is_repeating; /* 1 if repeating interrupt */
    int64_t repeat_count;
} interrupt_t;

int intr_checkpoint (CPR_REQUEST_T req, FILE *fp);

#endif /* _INTERRUPTS_H_ */
