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
 *****************************************************************/




#ifndef _CHECKPOINT_TYPES_H_
#define _CHECKPOINT_TYPES_H_
 
#pragma ident "@(#)checkpoint_types.h 1.3 Last modified 10/06/98 11:32:37 SMI"

typedef enum {CPR_QUERY, CPR_CHECKPOINT, CPR_RESTART} CPR_REQUEST_T;

/* versions of fread/write which simply return with a value of 1
if there is any error during a read or write. meant to ease checking
of fread/write status in the checkpointing function of each module.
preferably, restrict use of these macros to checkpointing only.
*/

#define CHECKING_FREAD(p1, p2, p3, p4) { \
        size_t n_elts = (p3); \
        if (fread ((p1), (p2), n_elts, (p4)) != n_elts) return (1); }

#define CHECKING_FWRITE(p1, p2, p3, p4) { \
        size_t n_elts = (p3); \
        if (fwrite ((p1), (p2), n_elts, (p4)) != n_elts) return (1); }
 
#endif /* _CHECKPOINT_TYPES_H_ */
