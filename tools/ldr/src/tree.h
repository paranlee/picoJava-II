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

 ***   Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 *****************************************************************/




/*
 * Definitions having to do with the program tree
 */

#ifndef _TREE_H_
#define _TREE_H_

#pragma ident "@(#)tree.h 1.7 Last modified 10/06/98 11:34:23 SMI"

#include "oobj.h"	/* for the definition of unicode */

extern int   SkipSourceChecks;
extern char *progname;
extern ClassClass **binclasses;
extern long nbinclasses, sizebinclasses;
extern int verbose;
extern int verbosegc;
extern int verifyclasses;
extern int noasyncgc;

extern int ImportAcceptable;
extern int InhibitExecute;

/* User specifiable attributes */
#define ACC_PUBLIC            0x0001    /* visible to everyone */
#define ACC_PRIVATE           0x0002	/* visible only to the defining class */
#define ACC_PROTECTED         0x0004    /* visible to subclasses */
#define ACC_STATIC            0x0008    /* instance variable is static */
#define ACC_FINAL             0x0010    /* no further subclassing, overriding */
#define ACC_SYNCHRONIZED      0x0020    /* wrap method call in monitor lock */
#define ACC_SUPER             0x0020    /* funky handling of invokenonvirtual */
#define ACC_THREADSAFE        0x0040    /* can cache in registers */
#define ACC_TRANSIENT         0x0080    /* not persistant */
#define ACC_NATIVE            0x0100    /* implemented in C */
#define ACC_INTERFACE         0x0200    /* class is an interface */
#define ACC_ABSTRACT	      0x0400	/* no definition provided */
#define ACC_XXUNUSED1         0x0800    /*  */

#define ACC_WRITTEN_FLAGS     0x0FFF    /* flags actually put in .class file */

/* Other attributes */
#define ACC_VALKNOWN          0x1000    /* constant with known value */
#define ACC_DOCED             0x2000    /* documentation generated */
#define ACC_MACHINE_COMPILED  0x4000    /* compiled to machine code */
#define ACC_XXUNUSED3         0x8000    /*  */

#define IsPrivate(access) (((access) & ACC_PRIVATE) != 0)
#define IsPublic(access)  (((access) & ACC_PUBLIC) != 0)
#define IsProtected(access)  (((access) & ACC_PROTECTED) != 0)

char *addstr(char *s, char *buf, char *limit, char term);
char *addhex(long n, char *buf, char *limit);
char *adddec(long n, char *buf, char *limit);

#ifdef TRIMMED
# undef DEBUG
# undef STATS
# define NOLOG
#endif


#endif /* !_TREE_H_ */
