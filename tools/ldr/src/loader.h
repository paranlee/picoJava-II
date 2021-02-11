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




#ifndef _LOADER_H_
#define _LOADER_H_

#pragma ident "@(#)loader.h 1.7 Last modified 10/06/98 11:34:12 SMI"

struct CICcontext {
    unsigned char *ptr;
    unsigned char *end_ptr;
    ClassClass *cb;
    jmp_buf jump_buffer;
    char **detail;
};

typedef struct CICcontext CICcontext;

ClassClass **binclasses;
long nbinclasses, sizebinclasses;

/* load up text or binary init files from the file given in path */
int initFile (char *path);
int bInitFile (char *path);

#endif /* _LOADER_H_ */
