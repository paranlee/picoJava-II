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




#ifndef _COMMANDS_H_
#define _COMMANDS_H_

#pragma ident "@(#)commands.h 1.6 Last modified 02/28/99 12:03:55 SMI"

extern int flag_icache_once_inited;
extern int flag_dcache_once_inited;

extern void doConfigureCmd (int argc, char **argv);
extern void doDumpDcacheCmd (int argc, char **argv);
extern void doDumpIcacheCmd (int argc, char **argv);
extern void doScacheCmd (int argc, char **argv);

#endif /* _COMMANDS_H_ */
