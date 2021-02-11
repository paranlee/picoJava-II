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




#ifndef _SCACHE_H_
#define _SCACHE_H_

#pragma ident "@(#)scache.h 1.6 Last modified 10/06/98 11:37:08 SMI"

#include <stdio.h>

#include "checkpoint_types.h"
#include "iam.h"

#define SCACHE_SIZE 64 /* number of words */

/* if at any time the scache does not contain between 
SCACHE_{MIN,MAX}_ENTRIES, the pipe is held till this condition is
established */

#define SCACHE_MIN_ENTRIES 4
#define SCACHE_MAX_ENTRIES 60

#define SCACHE_INIT_VALUE 0xdeadbeef

void vSCacheInit ();
void vSCacheFlush ();
void vSCacheRead (const unsigned int stack_offset, unsigned int *data);
void vSCacheWrite (const unsigned int stack_offset, unsigned int *data);
void vUpdateSCache (stack_item *old_RelOptop);
int scache_checkpoint (CPR_REQUEST_T req, FILE *fp);

#endif /* _SCACHE_H_ */
