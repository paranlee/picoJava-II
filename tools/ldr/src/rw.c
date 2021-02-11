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




static char *sccsid = "@(#)rw.c 1.10 Last modified 05/22/98 10:00:35 SMI";

#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <varargs.h>
#include <string.h>
#include <sys/wait.h>
#include <errno.h>

#include "veriuser.h"
#include "dsv.h"
#include "decaf.h"
#include "cm.h"
#include "vmacro.h"

static char errorBuffer[BUFSIZ];
static int init= 0;
static int cosim=0;
static int iasAckFd = -1;
static int readAckFd = -1;
static int outfd = -1;
static int pid = -1;
static unsigned int *addrToCheck = NULL;
static int sizeOfAddrArray = 0;
static int numberToCheck = 0;

int microJava = 0;
/*
 * $decaf_cm_load(classFileArg, needRes)
 * reg[8*SIZE:0] classFileArg
 * interger needRes
 *
 * The test case MUST be the first class to load.
 */
decaf_cm_load()
{
   int arg=0;
   s_tfexprinfo        exprinfo;
   char *classFileArg;
   char error = FALSE;
   static char routineName[] = "$decaf_cm_load";
   char buffer[BUFSIZ];
   FILE *tclfp;
   int needRes;
   char *cptr;
   char *fname;
   int nomore;

   classFileArg = tf_getcstringp(++arg);

   tf_exprinfo(++arg, &exprinfo);
   GET_INT(needRes, exprinfo.expr_value_p, "needRes", errorBuffer, routineName);

   if (init == 0) {
    if (cmInit(NULL) == DSV_FAIL) {
     io_printf("Fatal Error : Can not initialize decaf common memory\n");
     exit(-1);
    }
    init = 1;
   }

   if ((tclfp=(FILE *)fopen("cos", "w")) == NULL) {
    io_printf("Can not open file cos\n");
   }

   cptr = mc_scan_plusargs(classFileArg);

   /* if no follow-up argument, we treat it as file name */
   if ((cptr == NULL) || (*cptr == '\0')) {
    if (loadClassFile(classFileArg, needRes) == DSV_FAIL) {
     io_printf("Can not load the class file %s\n", classFileArg);
     exit(-1);
    }
    io_printf("Load class file %s\n", classFileArg);
    if (tclfp != NULL) fprintf(tclfp, "loadClass %s\n", classFileArg);

    if (cosim == 1) {
     sprintf(buffer,"loadClass %s; cosimAck %d\n", classFileArg, iasAckFd);
     /* send the command to pipe */
     if (sendCmd(buffer) == DSV_FAIL) {
      return DSV_FAIL;
     }
    }
    return DSV_SUCCESS;
   }

   fname = ++cptr;
   nomore = 0;
   while (1) {

    while ((*cptr != '+')&&(*cptr != '\0')) cptr++;
    if (*cptr == '\0') nomore = 1;
    if (*cptr == '+') *cptr = '\0';

    if (loadClassFile(fname, needRes) == DSV_FAIL) {
     io_printf("Can not load the class file %s\n", fname);
     exit(-1);
    }
    io_printf("Load class file %s\n", fname);
    if (tclfp != NULL) fprintf(tclfp, "loadClass %s\n", fname);
    if (cosim == 1) {
     sprintf(buffer,"loadClass %s; cosimAck %d\n", fname, iasAckFd);
     /* send the command to pipe */
     if (sendCmd(buffer) == DSV_FAIL) {
      return DSV_FAIL;
     }
    }

    if (nomore == 1) {
     if (tclfp != NULL) fclose(tclfp);
     return DSV_SUCCESS;
    }
    fname = ++cptr;

   }

}

/*
 * $decaf_cm_read(addr, data, size)
 * reg[32:0] addr
 * reg[32:0] data
 * integer size (in byte, power of 2, i.e., 0, 1, 2)
 */
decaf_cm_read()
{
   static char routineName[] = "$decaf_cm_read";
   s_tfexprinfo        exprinfo;
   unsigned int addr;
   unsigned int data = 0;
   int size;
   char error = FALSE;
   unsigned int dsv_status;

   /* addr */
   tf_exprinfo(1, &exprinfo);
   GET_VEC(addr, 32, exprinfo.expr_value_p, "addr", errorBuffer, routineName);
   /* size in byte */
   tf_exprinfo(3, &exprinfo);
   GET_INT(size, exprinfo.expr_value_p, "size", errorBuffer, routineName);
   
   dsv_status = cmMemoryRead(addr, &data, size);

   tf_putp(4,dsv_status);

   /* data = 0xbad0; */

   tf_exprinfo(2, &exprinfo);
   PUT_VEC(data, 32, exprinfo.expr_value_p, 2);

#if 1
   printf("rtl : memory read %08x, data %08x, size %08x)\n", addr, data, size);
#endif

   return DSV_SUCCESS;
   
}

/*
 * $decaf_cm_write(addr, data, size)
 * reg[32:0] addr
 * reg[32:0] data
 * integer size (in byte, power of 2, i.e., 0, 1, 2)
 */
decaf_cm_write()
{
   int i;
   static char routineName[] = "$decaf_cm_write";
   s_tfexprinfo        exprinfo;
   unsigned int addr;
   unsigned int data;
   int size;
   char error = FALSE;

   /* addr */
   tf_exprinfo(1, &exprinfo);
   GET_VEC(addr, 32, exprinfo.expr_value_p, "addr", errorBuffer, routineName);
   /* data  */
   tf_exprinfo(2, &exprinfo);
   GET_VEC(data, 32, exprinfo.expr_value_p, "data", errorBuffer, routineName);
   /* size in byte */
   tf_exprinfo(3, &exprinfo);
   GET_INT(size, exprinfo.expr_value_p, "size", errorBuffer, routineName);

   cmMemoryWrite(addr, data, size);

   if (microJava == 0) {
    /* For memory checking, always check a word */
    addr = addr & 0xfffffffc;
#if 1
    printf("rtl : memory write %08x, data %08x, size %08x)\n", addr, data, size);
#endif

    if (sizeOfAddrArray <= numberToCheck) {
     sizeOfAddrArray += BUFSIZ;
     addrToCheck = (unsigned int *)realloc(addrToCheck, sizeOfAddrArray*sizeof(unsigned int *));
    }

    for (i=0; i < numberToCheck; i += 2) {
     if (addrToCheck[i] == (unsigned int)addr) {
#if 1
      io_printf("cosim warning: overwritten, address %x, old data %8x, new data %8x\n", addr, addrToCheck[i+1], (unsigned int)cmPeek(addr));
#endif
      break;
     }
    }
    if (i >= numberToCheck) numberToCheck += 2;
    addrToCheck[i++] = (unsigned int)addr;
    addrToCheck[i++] = (unsigned int)cmPeek(addr);
   }

   return DSV_SUCCESS;
}

decaf_cm_dump()
{
   char *dumpfilename;
   FILE *fp;

#if 0
   if (tf_nump() > 0) {
    dumpfilename = tf_getcstringp(1);
    fp = fopen(dumpfilename, "w");
    if (fp != NULL) {
    }
   }
#endif

   dumpCommonMemory(stdout);
   return DSV_SUCCESS;
}

decaf_cm_direct_dump()
{
   static char routineName[] = "$decaf_cm_direct_dump";
   s_tfexprinfo        exprinfo;
   unsigned int addr;
   unsigned int cnt;
   char error = FALSE;
   char *fname;
   FILE *fp;

   /* addr */
   tf_exprinfo(1, &exprinfo);
   GET_VEC(addr, 32, exprinfo.expr_value_p, "addr", errorBuffer, routineName);
   /* count */
   tf_exprinfo(2, &exprinfo);
   GET_INT(cnt, exprinfo.expr_value_p, "count", errorBuffer, routineName);

   /* file name */
   fname = tf_getcstringp(3);

   if (fname != NULL) {
    fp = (FILE *)fopen(fname, "w");
    if (fp != NULL) {
     cmMemoryDirectDumpNoAddress(addr, cnt, fp);
     fclose(fp);
     return DSV_SUCCESS;
    }
   }

   cmMemoryDirectDump(addr, cnt);

   return DSV_SUCCESS;
}

decaf_cm_load_method()
{
   int arg=0;
   s_tfexprinfo        exprinfo;
   char *classFile;
   char error = FALSE;
   static char routineName[] = "$decaf_cm_load_method";
   int index;
   int loc;

   classFile = tf_getcstringp(++arg);

   tf_exprinfo(++arg, &exprinfo);
   GET_INT(index, exprinfo.expr_value_p, "index", errorBuffer, routineName);

   tf_exprinfo(++arg, &exprinfo);
   GET_INT(loc, exprinfo.expr_value_p, "loc", errorBuffer, routineName);

   if (init == 0) {
    if (cmInit(NULL) == DSV_FAIL) {
     io_printf("Fatal Error : Can not initialize decaf common memory\n");
     exit(-1);
    }
    init = 1;
   }

   if (loadClassFileMethod(classFile, index, loc) == DSV_FAIL) {
    io_printf("Can not load method (index %d) in the class file %s into location %x\n", index, classFile, loc);
    exit(-1);
   }

   return DSV_SUCCESS;
}

sendCmd(char *buffer)
{
   int st;
   char ch;

   if (outfd == -1) {
    cosim = 0;
    return DSV_FAIL;
   }

#if 0
   printf("CMD : %s\n", buffer);
#endif

   if (write(outfd, buffer, strlen(buffer)) < 0) {
    printf("Can not write to instruction simulator (%d).\n", errno);
    cosim = 0;
    return DSV_FAIL;
   }
   
    if (outfd == -1) {
     cosim = 0;
     io_printf("1 : Intruction simulator exited.\n");
     return DSV_FAIL;
    }
    ch = -1;
    if (read(readAckFd, &ch, sizeof(char)) > 0) {
     if (ch == 0) return DSV_SUCCESS;
    }

    /* io_printf("ack value %d from ias is not correct\n", st); */
#if 0
    if (waitpid(pid, &st, WNOHANG) > 0) {
      cosim = 0;
      io_printf("3 : Intruction simulator exited.\n");
      break;
    }
#endif

   return DSV_SUCCESS;
}

void
cosimEnd(int disp)
{
   io_printf("Instruction simulator exits.\n");
   outfd = -1;
}


/*
 * start the instruction simulator
 *
 * +cosim+ias
 *
 * $decaf_cosim("cosim");
 *
 * Tcl commands :
 *   set dumpFile ...
 *   loadClass ...
 *   run start
 *   dump...
 */
decaf_cosim()
{
   int arg=0;
   s_tfexprinfo        exprinfo;
   char error = FALSE;
   static char routineName[] = "$decaf_cosim";
   char *ias;
   int start;
   char buffer[BUFSIZ];
   int fd[2];
   int ackfd[2];
   int st;

   if (outfd != -1) {
    io_printf("The instruction simulator is already running\n");
    return DSV_FAIL;
   }
   /* get the initial Tcl command from cosim argument */
   ias = mc_scan_plusargs("cosim");
   if (ias == NULL) {
    io_printf("Error: no instruction simulator specified\n");
    return DSV_FAIL;
   }
   /* skip the + sign */
   ias++;

   pipe(fd);
   pipe(ackfd);
   cosim = 1;

   /* invoke the simulator, send an initial command and wait for ack */
   if ((pid=fork()) == 0) {
    /* child process use fd[0] as input */
    close(fd[1]);
    dup2(fd[0], fileno(stdin));
    
    /* child process use ackfd[1] as ack output */
    close(ackfd[0]);

    if (execlp(ias, ias, NULL) == -1) {
     io_printf("Can not execute %s\n", ias);
     exit(-1);
    }
   }

   /* The parent process use fd[1] as output */
   close(fd[0]);

   /* The parent process use ackfd[0] as input */
   readAckFd = ackfd[0];
   iasAckFd = ackfd[1];
   close(ackfd[1]);
   sprintf(buffer, "cosimAck %d\n", iasAckFd);
   outfd = fd[1];

#if 1
   /* Let's wait for a while to make sure ias is up and running */
   sleep(5);
#endif

   if (sendCmd(buffer) == DSV_FAIL) {
    return DSV_FAIL;
   }

   /* good! Ias is up and running */


   return DSV_SUCCESS;
}

/*
 * send the command to the simulator
 *
 * $decaf_cosim_cntl(tclCmd);
 *
 *   Tcl command
 *   steps step
 *   dump...
 */
decaf_cosim_cntl()
{
   int arg=0;
   s_tfexprinfo        exprinfo;
   char error = FALSE;
   static char routineName[] = "$decaf_cosim_cntl";
   char *tclCmd;
   char buffer[BUFSIZ];
   char buf[BUFSIZ];
   char str[40];
   int i;

   if (cosim == 0) {
    tf_dofinish();
    return DSV_FAIL;
   }

   /* get the initial Tcl command from cosim argument */
   tclCmd = tf_getcstringp(++arg);

/*
   printf ("cosim issuing command: %s\n", tclCmd); 
*/

#if 0
   /* disable for now until ias does not direct access memory */
   /* check the memory activity also */
   i = 0;
   buf[0] = '\0';
   while (i < numberToCheck) {
    sprintf(str, "compareMemory %x %x;", addrToCheck[i++], addrToCheck[i++]);
    strcat(buf, str);
   }

   if (numberToCheck > 0) {
    sprintf(buffer,"%s; %s; cosimAck %d\n", tclCmd, buf, iasAckFd);
   }
   else {
    sprintf(buffer,"%s; cosimAck %d\n", tclCmd, iasAckFd);
   }

   numberToCheck = 0;
#else
   if (strcmp(tclCmd, "exit") == 0) {
    sprintf(buffer,"%s\n", tclCmd);
   }
   else {
    sprintf(buffer,"%s; cosimAck %d\n", tclCmd, iasAckFd);
   }
#endif

   /* send the command to pipe */
   if (sendCmd(buffer) == DSV_FAIL) {
    return DSV_FAIL;
   }

   return DSV_SUCCESS;

}

decaf_cosim_compare_memory_at_end()
{
   int arg=0;
   s_tfexprinfo        exprinfo;
   char error = FALSE;
   static char routineName[] = "$decaf_cosim_compare_memory_at_end";
   char *tclCmd;
   char buffer[BUFSIZ];
   char buf[BUFSIZ];
   char str[40];
   int i;
   int cmdLen;

   if (cosim == 0) return DSV_FAIL;

   io_printf("Memory comparison at end of simulation\n");

   if (numberToCheck <= 0) return DSV_SUCCESS;

   cmdLen = 1;
   tclCmd = (char *)malloc(cmdLen*BUFSIZ);

   /* check the memory activity also */
   i = 0;
   tclCmd[0] = '\0';
   while (i < numberToCheck) {
    sprintf(str, "compareMemory %x %x;", addrToCheck[i++], addrToCheck[i++]);
    if ((cmdLen*BUFSIZ) < (strlen(str)+strlen(tclCmd)+1)) {
     cmdLen++; 
     tclCmd = (char *)realloc(tclCmd, cmdLen*BUFSIZ);
    }
    strcat(tclCmd, str);
   }

   numberToCheck = 0;
   sprintf(str, "cosimAck %d\n", iasAckFd);
   if ((cmdLen*BUFSIZ) < (strlen(str)+strlen(tclCmd)+16)) { 
     cmdLen++;   
     tclCmd = (char *)realloc(tclCmd, cmdLen*BUFSIZ); 
    }   
    strcat(tclCmd, str); 

   /* send the command to pipe */
   if (sendCmd(tclCmd) == DSV_FAIL) {
    free(tclCmd);
    return DSV_FAIL;
   }

   free(tclCmd);
   return DSV_SUCCESS;
}

/*
 * disasm the instruction upon completion
 */
decaf_disasm()
{
   int arg = 0;
   static char routineName[] = "$decaf_disasm";
   s_tfexprinfo        exprinfo;
   unsigned int addr;
   char error = FALSE;
   int clkCount;
   int trp;

   /* clock count */
   tf_exprinfo(++arg, &exprinfo);
   GET_INT(clkCount, exprinfo.expr_value_p, "clk_count", errorBuffer, routineName);

   /* addr */
   tf_exprinfo(++arg, &exprinfo);
   GET_VEC(addr, 32, exprinfo.expr_value_p, "addr", errorBuffer, routineName);

   /* trp */
   tf_exprinfo(++arg, &exprinfo);
   GET_INT(trp, exprinfo.expr_value_p, "trp", errorBuffer, routineName);

   if (addr > CM_SIZE) {
    if (((addr >= BAD_MEMORY_START) &&
         (addr < (unsigned int)BAD_MEMORY_START + (unsigned int)BAD_SIZE)) ||
        ((addr >= BAD_IO_START) &&
         (addr < (unsigned int)BAD_IO_START + (unsigned int)BAD_SIZE))) {
     io_printf("Warning: addr %xh is not valid\n", addr);
     return DSV_FAIL;
    }
   }
   
   fprintf(stdout, "%d:", clkCount);
   disAssembly((unsigned char *)addr, 1, stdout);
   if (trp != 0) {
    fprintf(stdout,"%d: [** trapped **] RTL completed building trap frame\n", clkCount);
   }

   fflush(stdout);

   return DSV_SUCCESS;
}


/*
 * trap handlers loader
 */
decaf_load_traphandlers()
{
   s_tfexprinfo        exprinfo;
   char error = FALSE;
   static char routineName[] = "$decaf_load_traphandlers";

   decaf = 1;
   loadTrapHandlers();

   return DSV_SUCCESS;
}

decaf_load_tmem_file ()

{
   char *cptr;
   char *fname;
   static char routineName[] = "$decaf_load_tinit_file";

   cptr = mc_scan_plusargs ("tmem");
   if (cptr == NULL)
       return;
   cptr++; /* skip the first + */
   if (initFile (cptr) != 0)
       fprintf (stderr, "Error: unable to load text init file: %s\n", cptr);
}

decaf_load_bmem_file ()

{
   char *cptr;
   char *fname;
   static char routineName[] = "$decaf_load_binit_file";

   cptr = mc_scan_plusargs ("bmem");
   if (cptr == NULL)
       return;
   cptr++; /* skip the first + */
   if (bInitFile (cptr) != 0)
       fprintf (stderr, "Error: unable to load binary init file: %s\n", cptr);
}
