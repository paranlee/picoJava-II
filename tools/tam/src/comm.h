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




#ifndef _COMM_H_
#define _COMM_H_

#include "cm.h"

#define CMDLENGTH 4
#define CMDLENGTH_BYTE CMDLENGTH*sizeof(int)

EXTERN int infd;
EXTERN int outfd;

EXTERN unsigned int cmdBuffer[CMDLENGTH];
EXTERN int tamPid;

EXTERN unsigned int maddress;
EXTERN unsigned int mdata;
EXTERN unsigned int msize;
EXTERN unsigned int mtype;

#define START  0
#define ACK  1
#define MEMREAD 2
#define MEMWRITE 3
#define READDATA 4
#define EXIT 5
#define NO_WORK 6
#define MEMTYPE 7
#define WRITEDATA 8
#define TYPEDATA 9
#define INTR 10
#define DOINTR 11


EXTERN tamSendCmd();
EXTERN tamReadRead();
EXTERN tamPoll();

#endif /* _COMM_H_ */
