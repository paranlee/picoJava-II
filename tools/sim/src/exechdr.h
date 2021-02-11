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




#ifndef _SYS_EXECHDR_H
#define	_SYS_EXECHDR_H

#pragma ident "@(#)exechdr.h 1.3 Last modified 10/06/98 11:39:13 SMI"

#ifdef	__cplusplus
extern "C" {
#endif

/*
 * format of the exec header
 * known by kernel and by user programs
 */
struct exec {
#ifdef sun
	unsigned	a_dynamic:1;	/* has a __DYNAMIC */
	unsigned	a_toolversion:7; /* version of toolset used to */
					/* create this file */
	unsigned char	a_machtype;	/* machine type */
	unsigned short	a_magic;	/* magic number */
#else
	unsigned long	a_magic;	/* magic number */
#endif
	unsigned long	a_text;		/* size of text segment */
	unsigned long	a_data;		/* size of initialized data */
	unsigned long	a_bss;		/* size of uninitialized data */
	unsigned long	a_syms;		/* size of symbol table */
	unsigned long	a_entry;	/* entry point */
	unsigned long	a_trsize;	/* size of text relocation */
	unsigned long	a_drsize;	/* size of data relocation */
};

#define	OMAGIC	0407		/* old impure format */
#define	NMAGIC	0410		/* read-only text */
#define	ZMAGIC	0413		/* demand load format */

/* machine types */

#ifdef sun
#define	M_OLDSUN2	0	/* old sun-2 executable files */
#define	M_68010		1	/* runs on either 68010 or 68020 */
#define	M_68020		2	/* runs only on 68020 */
#define	M_SPARC		3	/* runs only on SPARC */

#define	TV_SUN2_SUN3	0
#define	TV_SUN4		1
#endif	/* sun */

#ifdef	__cplusplus
}
#endif

#endif /* _SYS_EXECHDR_H */
