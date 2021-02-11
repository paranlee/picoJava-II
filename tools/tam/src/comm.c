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



#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <varargs.h>
#include <string.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <errno.h>

#include "dsv.h"
#include "comm.h"

int infd = -1;
int outfd = -1;

unsigned int cmdBuffer[CMDLENGTH];
int tamPid;


unsigned int maddress;
unsigned int mdata;
unsigned int msize;
unsigned int mtype;

tamSendCmd()
{
   int st;
   int len;

   if (outfd == -1) {
    return DSV_FAIL;
   }

#if 0
   printf("CMD : %d\n", *ack);
#endif

   if (write(outfd, (char *)cmdBuffer, CMDLENGTH_BYTE) < 0) {
    printf("1: Peer process exited.\n");
    cmdBuffer[0] = EXIT;
    return DSV_FAIL;
   }
   
   while (1) {
    if (waitpid(tamPid, &st, WNOHANG) > 0) {
     printf("2: Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }
    if (outfd == -1) {
     printf("3:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }

    if ((len=read(infd, (char *)cmdBuffer, sizeof(int))) <= 0) {
     if (len == 0) {
      printf("4:Peer process exited.\n");
      cmdBuffer[0] = EXIT;
      return DSV_FAIL;
     }
     if (errno == EAGAIN) {
      continue;
     }
     printf("5:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }
    if (cmdBuffer[0] == ACK) break;
   }

   return DSV_SUCCESS;
}

tamReadCmd()
{
   int st;
   int len;
   static int ack = ACK;

   while (1) {
    if (waitpid(tamPid, &st, WNOHANG) > 0) {
     printf("a:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }
    if (outfd == -1) {
     printf("b:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }

    if ((len=read(infd, (char *)cmdBuffer, CMDLENGTH_BYTE)) < 0) {
     printf("e:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }
    if (len==CMDLENGTH_BYTE) break;
   }

   if (write(outfd, &ack, sizeof(int)) <0) {
    printf("f:Peer process exited.\n");
    cmdBuffer[0] = EXIT;
    return DSV_FAIL;
   }
    return DSV_SUCCESS;
}

tamPoll()
{
   int st;
   int len;
   static int ack = ACK;

   if (waitpid(tamPid, &st, WNOHANG) > 0) {
    printf("aa:Peer process exited.\n");
    cmdBuffer[0] = EXIT;
    return DSV_FAIL;
   }
   if (outfd == -1) {
    printf("b:Peer process exited.\n");
    cmdBuffer[0] = EXIT;
    return DSV_FAIL;
   }

   if ((len=read(infd, (char *)cmdBuffer, CMDLENGTH_BYTE)) <= 0) {
    if (len == 0) {
     printf("c:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }
    if (errno == EAGAIN) {
     cmdBuffer[0] = NO_WORK;
     return DSV_SUCCESS;
    }
    printf("d:Peer process exited.\n");
    cmdBuffer[0] = EXIT;
    return DSV_FAIL;
   }
   if (len==CMDLENGTH_BYTE) {

    if (write(outfd, &ack, sizeof(int)) <0) {
     printf("e:Peer process exited.\n");
     cmdBuffer[0] = EXIT;
     return DSV_FAIL;
    }
    return DSV_SUCCESS;

   }

}

