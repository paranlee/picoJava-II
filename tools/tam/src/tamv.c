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

#include "veriuser.h"
#include "dsv.h"
#include "vmacro.h"
#include "comm.h"

/*
#define POLL_DBG
#define EXIT_DBG
#define DBG
#define INTR_DBG
*/

static char errorBuffer[BUFSIZ];
extern int microJava;

decaf_tam_intr()
{
   int irl;
   static char routineName[] = "$decaf_tam_intr";
   s_tfexprinfo        exprinfo;
   char error = FALSE;

   /* interrupt level */
   tf_exprinfo(1, &exprinfo);
   GET_INT(irl, exprinfo.expr_value_p, "irl", errorBuffer, routineName);

#ifdef INTR_DBG
   printf("rtl : irl %d\n", irl);
   fflush(stdout);
#endif

   if (irl == -1) {
    cmdBuffer[0] = NO_WORK;
    cmdBuffer[1] = irl;
   }
   else {
    cmdBuffer[0] = DOINTR;
    cmdBuffer[1] = irl;
   }

   if (tamSendCmd() == DSV_FAIL) {
    printf("Error: rtl : Can not talk to tam\n");
    return DSV_FAIL;
   }
#ifdef INTR_DBG
   printf("rtl : tam intr, irl %d\n", irl);
   fflush(stdout);
#endif

   return DSV_SUCCESS;
}


decaf_tam_start()
{
   static char routineName[] = "$decaf_tam_start";
   char *tam;
   int fd[2];
   int ackfd[2];
   char av1[8];
   char av2[8];
   char av3[8];

   microJava = 1;

   if (outfd != -1) {
    io_printf("The transaction accurate simulator is already running\n");
    return DSV_FAIL;
   }

   tam = mc_scan_plusargs("tam");
   if (tam == NULL) {
    io_printf("Error: no transaction accurate simulator specified\n");
    return DSV_FAIL;
   }
   /* skip the + sign */
   tam++;

   pipe(fd);
   pipe(ackfd);

   sprintf(av3,"%d", getpid());

   /* invoke the simulator, send an initial command and wait for ack */
   if ((tamPid=fork()) == 0) {
    /* child process use fd[0] as input */
    sprintf(av1, "%d", fd[0]);
    close(fd[1]);
    
    /* child process use ackfd[1] as output */
    sprintf(av2, "%d", ackfd[1]);
    close(ackfd[0]);


    if (execlp(tam, tam, av1, av2, av3, NULL) == -1) {
     io_printf("Can not execute %s\n", tam);
     exit(-1);
    }
   }

   /* The parent process use fd[1] as output */
   close(fd[0]);

   /* The parent process use ackfd[0] as input */
   infd = ackfd[0];
   close(ackfd[1]);
   outfd = fd[1];

   cmdBuffer[0] = START;

   if (tamSendCmd() == DSV_FAIL) {
    return DSV_FAIL;
   }

   /* nonblocking */
   fcntl(infd, F_SETFL, O_NONBLOCK);
   
   return DSV_SUCCESS;

}

decaf_tam_memread()
{
   int i;
   static char routineName[] = "$decaf_tam_memread";
   s_tfexprinfo        exprinfo;
   char error = FALSE;

   /* addr */
   tf_exprinfo(1, &exprinfo);
   GET_VEC(maddress, 32, exprinfo.expr_value_p, "addr", errorBuffer, routineName);
   /* data  */
   tf_exprinfo(2, &exprinfo);
   GET_VEC(mdata, 32, exprinfo.expr_value_p, "data", errorBuffer, routineName);
   /* size in byte */
   tf_exprinfo(3, &exprinfo);
   GET_INT(msize, exprinfo.expr_value_p, "size", errorBuffer, routineName);

   cmdBuffer[0] = READDATA;
   cmdBuffer[1] = maddress;
   cmdBuffer[2] = mdata;
   cmdBuffer[3] = msize;

   if (tamSendCmd() == DSV_FAIL) {
    return DSV_FAIL;
   }
#ifdef DBG
   printf("rtl : tam mem read, addr %08x, data %08x, size %d\n", maddress, mdata, msize);
#endif

   return DSV_SUCCESS;
}

decaf_tam_memwrite()
{
   static char routineName[] = "$decaf_tam_memwrite";
   s_tfexprinfo        exprinfo;
   char error = FALSE;

   /* ask the value from tam */
   if (tamPoll() == DSV_FAIL) {
    cmdBuffer[0] = EXIT;
    tf_exprinfo(4, &exprinfo);
    PUT_VEC(cmdBuffer[0], 32, exprinfo.expr_value_p, 4);
    return DSV_FAIL;
   }

   maddress = cmdBuffer[1];
   mdata = cmdBuffer[2];
   msize = cmdBuffer[3];

   /* addr */
   tf_exprinfo(1, &exprinfo);
   PUT_VEC(maddress, 32, exprinfo.expr_value_p, 1);

   tf_exprinfo(2, &exprinfo);
   PUT_VEC(mdata, 32, exprinfo.expr_value_p, 2);

   /* size in byte */
   tf_exprinfo(3, &exprinfo);
   PUT_INT(msize, exprinfo.expr_value_p, 3);
   
#if 0
   printf("rtl : tam mem write, addr %08x, data %08x, size %d\n", maddress, mdata, msize);
#endif
   return DSV_SUCCESS;
   
}

decaf_tam_exit()
{
   cmdBuffer[0] = EXIT;

#ifdef EXIT_DBG
    printf("rtl : exit \n");
    fflush(stdout);
#endif

   if (tamSendCmd() == DSV_FAIL) {
    return DSV_FAIL;
   }

   return DSV_SUCCESS;

}

decaf_tam_poll()
{
   static char routineName[] = "$decaf_tam_poll";
   s_tfexprinfo        exprinfo;
   char error = FALSE;

   if (tamPoll() == DSV_FAIL) {
    cmdBuffer[0] = EXIT;
    tf_exprinfo(4, &exprinfo);
    PUT_VEC(cmdBuffer[0], 32, exprinfo.expr_value_p, 4);
    return DSV_FAIL;
   }

#ifdef POLL_DBG
    printf("rtl : poll \n");
    fflush(stdout);
#endif

   if (cmdBuffer[0] == NO_WORK) return DSV_SUCCESS;


    /* addr */
    tf_exprinfo(1, &exprinfo);
    PUT_VEC(cmdBuffer[1], 32, exprinfo.expr_value_p, 1);

    tf_exprinfo(2, &exprinfo);
    PUT_VEC(cmdBuffer[2], 32, exprinfo.expr_value_p, 2);

    /* size in byte */
    tf_exprinfo(3, &exprinfo);
    PUT_INT(cmdBuffer[3], exprinfo.expr_value_p, 3);

   /* result */
   tf_exprinfo(4, &exprinfo);
   PUT_VEC(cmdBuffer[0], 32, exprinfo.expr_value_p, 4);

#ifdef POLL_DBG
    printf("rtl : poll cmd %d, address %8x, data %8x, size %d\n", cmdBuffer[0], cmdBuffer[1], cmdBuffer[2], cmdBuffer[3]);
    fflush(stdout);
#endif

   return DSV_SUCCESS;
   
}
