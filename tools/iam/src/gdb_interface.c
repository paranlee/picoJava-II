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




static char *sccsid = "@(#)gdb_interface.c 1.18 Last modified 02/28/99 12:03:56 SMI";

#include <signal.h>

#include "iam.h"
#include "global_regs.h"
#include "javamem.h"
#include "breakpoints.h"
#include "ctype.h"
#include "dprint.h"
#include "commands.h"
#include "checkpoint.h"
#include "gdb_interface.h"

/* Main simulator entry points ...

   All functions that can get an error must call the gdb routine `error',
   they can only return upon success.
   		void error(char *string, ...);

   The parameters are similar or printf. For example:
		error("No such register %d\n", regno);

  */

/* Initialize the simulator.  This function is called when the simulator
   is selected from the command line. ARGS is passed from the command line
   and can be used to select whatever run time options the simulator provides.
   ARGS is the raw character string and must be parsed by the simulator,
   which is trivial to do with the buildargv function in libiberty.
   It is ok to do nothing.  */

int running_under_gdb = 0;

/*
sim_hbreak: effectively functions as a h/w breakpoint (uses simulator
brkpt functionality, not pico h/w breakpoint registers)
sets a hbrkpt on the given address, 
hbrkpt_type = 
0 => code breakpoint
1 => data read brkpt
2 => data write brkpt
3 => data read+write brkpt
*/
void sim_hbreak (unsigned int address, int hbrkpt_type)

{
    switch (hbrkpt_type)
    {
      case 0:
        brkpt_add (address, BRKPT_EXEC);
        break; /* point */
      case 1:
        brkpt_add (address, BRKPT_READ);
        break; /* point */
      case 2:
        brkpt_add (address, BRKPT_WRITE);
        break; /* point */
      case 3:
        brkpt_add (address, BRKPT_READ);
        brkpt_add (address, BRKPT_WRITE);
        break; /* point */
    }
}

/*
sim_remove_hbreak: remove a simulator breakpoint based on a byte 
address and a hbrkpt type
hbrkpt_type = 
0 => code breakpoint
1 => data read brkpt
2 => data write brkpt
3 => data read+write brkpt

if no brkpt matching this address exists, silently does nothing.
*/
void sim_remove_hbreak (unsigned int address, int hbrkpt_type)

{
    switch (hbrkpt_type)
    {
      case 0:
        brkpt_disable_addr (address, BRKPT_EXEC);
        break; /* point */
      case 1:
        brkpt_disable_addr (address, BRKPT_READ);
        break; /* point */
      case 2:
        brkpt_disable_addr (address, BRKPT_WRITE);
        break; /* point */
      case 3:
        brkpt_disable_addr (address, BRKPT_READ);
        brkpt_disable_addr (address, BRKPT_WRITE);
        break; /* point */
    }
}

void sim_open (char *args)

{
    DPRINTF (GDB_DBG_LVL, ("sim_open called with args = %s\n", args));
    running_under_gdb = 1;

	if (cmInit (0) == DSV_FAIL)
	{   
		fprintf (stderr, "common memory initialisation failed!\n");
		exit (1);
    }

	initPico ();
	ias_trace = 0;  /* just for now, for gdb bringup */
}

/* Terminate usage of the simulator.  This may involve freeing target memory
   and closing any open files and mmap'd areas.  You cannot assume sim_kill
   has already been called.
   QUITTING is non-zero if we cannot hang on errors.  */

void sim_close (int quitting)

{ /* do nothing */ 
    DPRINTF (GDB_DBG_LVL, ("sim_close called, doing nothing\n"));
}

/* Load program PROG into the simulator.
   Return non-zero if you wish the caller to handle it
   (it is done this way because most simulators can use gr_load_image,
   but defining it as a callback seems awkward).  */

int sim_load (char *prog, int from_tty)

{ 
    DPRINTF (GDB_DBG_LVL, ("sim_load called, doing nothing\n"));
    return (1); 
}

/* Prepare to run the simulated program.
   START_ADDRESS is, yes, you guessed it, the start address of the program.
   ARGV and ENV are NULL terminated lists of pointers.
   Gdb will set the start address via sim_store_register as well, but
   standalone versions of existing simulators are not set up to cleanly call
   sim_store_register, so the START_ADDRESS argument is there as a
   workaround.  */

void sim_create_inferior (SIM_ADDR start_address, char **argv, char **env)

{
    DPRINTF (GDB_DBG_LVL, ("sim_create_inferior called, setting PC to 0x%x\n", start_address));
	/* reset all registers on starting anew */
    initPico ();
    pc = (unsigned char *) start_address;
}

/* Kill the running program.
   This may involve closing any open files and deleting any mmap'd areas.  */

void sim_kill (void) 

{ /* do nothing */ 
    DPRINTF (GDB_DBG_LVL, ("sim_kill called\n"));
}

/* Read LENGTH bytes of the simulated program's memory and store in BUF.
   Result is number of bytes read, or zero if error.  */

int sim_read (SIM_ADDR mem, unsigned char *buf, int length)

{
    int i;
	unsigned char c;

    DPRINTF (GDB_DBG_LVL, ("sim_read called for address 0x%x, length %d\n", mem, length));

	for (i = 0 ; i < length ; i++)
	{
        READ_BYTE (mem+i, 'G', c); /* 'G' makes it look thru all caches */
		buf[i] = c;
	}
	return (length);
}

/* Store LENGTH bytes from BUF in the simulated program's memory.
   Result is number of bytes write, or zero if error.  */

int sim_write (SIM_ADDR mem, unsigned char *buf, int length)

{
    int i;
	unsigned char c;

    DPRINTF (GDB_DBG_LVL, ("sim_write called for address 0x%x, length %d\n", mem, length));
	if (length == 1)
	{
		DPRINTF (GDB_DBG_LVL, ("byte to be written: 0x%x\n", (unsigned int) (*buf)))
    }

	for (i = 0 ; i < length ; i++)
	{
		int word_aligned_addr = (mem+i) & 0xFFFFFFFC;
		int byte_offset = (mem+i) & 3;
		int full_word;
		char *full_word_bytes = (char *) &full_word;

        /* big endian dependence here! doesn't matter, ias is 
		   already endian dependent */
		READ_WORD (word_aligned_addr, 'G', full_word);
		full_word_bytes[byte_offset] = buf[i];

		/* 'G' makes it look thru all caches */
/* support gdb with caches on -
writing i-stream to insert opc_breakpoint wouldn't
work with caches on, so now flushing I$ and D$ for *every* write
to memory - don't expect significant efficiency impact.
we need to flush both D$ and I$ before writing directly to memory with 

type 'N' - otherwise problems in weird cases like when the instruction stream
is being modified, or the instruction word already exists in D$... 

cacheFlush takes weird parameters - incr and result_addr which
we don't really need, so set incr to 0 
*/
        cacheFlush (word_aligned_addr, 0, &word_aligned_addr);
        WRITE_WORD (word_aligned_addr, 'N', full_word); 
	}
	return (length);
}

/* Fetch register REGNO and store the raw value in BUF.  */

void sim_fetch_register (int regno, unsigned char *buf)

{
    unsigned int i;


    switch (regno)
	{
	  case 0:
	    i = (unsigned int) pc;
	    break;
      case 1:
        i = (unsigned int) vars;
        break;
      case 2:
        i = (unsigned int) frame;
        break;
      case 3:
        i = (unsigned int) optop;
        break;
      case 4:
        i = (unsigned int) oplim;
        break;
      case 5:
        i = (unsigned int) const_pool;
        break;
      case 6:
        i = (unsigned int) psr;
        break;
      case 7:
        i = (unsigned int) trapbase;
        break;
      case 8: 
		i = (unsigned int) userrange1;
	    break;
      case 9: 
		i = (unsigned int) versionId;
	    break;
      case 10: 
        i = *((unsigned int *) (&hcr));
	    break;
      case 11:
		i = (unsigned int) scBottom;
	    break;
      case 12:
		i = (unsigned int) global0;
	    break;
      case 13:
		i = (unsigned int) global1;
	    break;
      case 14:
		i = (unsigned int) global2;
	    break;
      case 15:
		i = (unsigned int) global3;
	    break;
      case 16:
		i = (unsigned int) userrange2;
	    break;
      case 17:
		i = (unsigned int) lockAddr[0];
	    break;
      case 18:
		i = (unsigned int) lockAddr[1];
	    break;
      case 19:
		i = (unsigned int) lockCount[0];
	    break;
      case 20:
		i = (unsigned int) lockCount[1];
	    break;
      case 21:
		i = (unsigned int) gcConfig;
	    break;
      case 22:
		i = *(unsigned int *) &brk12c;
	    break;
      case 23:
		i = (unsigned int) brk1a;
	    break;
      case 24:
		i = (unsigned int) brk2a;
	    break;
    }

    DPRINTF (GDB_DBG_LVL, ("sim_fetch_register called for register no. %d, returning value %d\n", regno, i));

	buf[0] = (i & 0xFF000000) >> 24;
	buf[1] = (i & 0x00FF0000) >> 16;
	buf[2] = (i & 0x0000FF00) >> 8;
	buf[3] = (i & 0x000000FF);
}

/* Store register REGNO from BUF (in raw format) */
/* Use the same numbers as for fetch */

void sim_store_register (int regno, unsigned char *buf) 

{
    unsigned int i;

	i = ((*buf) << 24) | (*(buf+1) << 16) | (*(buf+2) << 8) | *(buf+3);

    DPRINTF (GDB_DBG_LVL, ("sim_store_register called for register no. %d, new value is %d\n", regno, i));

    switch (regno)
    {
      case 0:
        pc = (unsigned char *) i;
        break;
      case 1:
        vars = (stack_item *) i;
        break;
      case 2:
        frame = (stack_item *) i;
        break;
      case 3:
	  {
	    unsigned int old_optop = (unsigned int) optop;
        optop = (stack_item *) i;
		vUpdateSCache (old_optop);
        break;
	  }
      case 4:
        oplim = i;
        break;
      case 5:
        const_pool = (decafCpItemType *) i;
        break;
      case 6:
        psr = i;
        break;
      case 7:
        trapbase = i;
        break;
      case 8: 
		userrange1 = i;
		break;
      case 12: 
		global0 = i;
		break;
      case 13: 
		global1 = i;
		break;
      case 14: 
		global2 = i;
		break;
      case 15: 
		global3 = i;
		break;
      case 16: 
		userrange2 = i;
		break;
      case 17: 
		lockAddr[0] = i;
		break;
      case 18: 
		lockAddr[1] = i;
		break;
      case 19: 
		lockCount[0] = i;
		break;
      case 20: 
		lockCount[1] = i;
		break;
      case 21: 
		gcConfig = i;
		break;
      case 22: 
		*(unsigned int *) &brk12c = i;
		break;
      case 23: 
		brk1a = i;
		break;
      case 24: 
		brk2a = i;
		break;

		/* not supporting writes of the other 3 registers since only h/w
		   can write to them, and changing them on the fly will wreak havoc */
    }
}

/* Print some interesting information about the simulator.
   VERBOSE is non-zero for the wordy version.  */

void sim_info (int verbose) 

{
    DPRINTF (GDB_DBG_LVL, ("sim_info called\n"))
    fprintf (stderr, "ias backend, running under gdb\n");
}

/* Fetch why the program stopped.
   SIGRC will contain either the argument to exit() or the signal number.  */

void sim_stop_reason (enum sim_stop *reason, int *sigrc)

{
    if (breakpoint_hit)
	{
		*reason = sim_stopped;
		*sigrc = SIGTRAP;
    }
    else if (simulation_interrupted)
	{
		*reason = sim_stopped;
		*sigrc = SIGINT;
    }
    else
	{
		*reason = sim_exited;
		*sigrc = program_exit_code;
    }

    DPRINTF (GDB_DBG_LVL, ("sim_stop reason called, returning reason %d\n", (int) *reason));
}

/* Run (or resume) the program.  */

void sim_resume (int step, int sig) 

{
    /* if step = 0, execute one instruction, else run free */
    DPRINTF (GDB_DBG_LVL, ("sim_resume called, step = %d\n", step));
    executeBytecode ((step == 0) ? -1 : 1, 1);

}

/* Passthru for other commands that the simulator might support. 
currently supports
cache {on|off}
dumpDCache
dumpICache
itrace <level>
scache {on|off}
*/

void sim_do_command (char *cmd)

{
#define MAX_SIM_DO_COMMAND_ARGS 20
    char *lasts; /* temp pointer for strtok_r */
    int argc = 0;
    char *s;
    char **argv = (char **) malloc (MAX_SIM_DO_COMMAND_ARGS * sizeof (char *));
    char *usage = "usage: sim itrace|dumpDCache|dumpICache|cache|scache";

    DPRINTF (GDB_DBG_LVL, ("sim_do_command called with string %s\n", cmd));

    /* first split cmd into argv, argc for easy processing thereafter */

    /* argument on first call to strtok_r is cmd, NULL thereafter */
    /* split input cmd argument on blanks and tabs */
    if (cmd != NULL)
    {
        while ((s = (char *) strtok_r ((argc == 0) ? cmd : NULL, " \t", &lasts)) != NULL)
        {
              if (argc == MAX_SIM_DO_COMMAND_ARGS)
              {   /* if too many args, just return */
                  printf ("Command ignored, too many arguments: %s\n", 
                          cmd);
                  printf ("Max number of arguments to sim command: %d\n", 
                          MAX_SIM_DO_COMMAND_ARGS);
                  goto returnPoint;
              }
              argv[argc++] = s;
              DPRINTF (GDB_DBG_LVL, ("parsing args, found %s\n", argv[argc-1]));
         }
    }

    if (argc <= 0)
    {
        printf ("%s", usage);
        goto returnPoint;
    }

    if (!strcasecmp (argv[0], "itrace"))
    {
        if (argc > 1)
        {
            ias_trace = strtol (argv[1], (char **) NULL, 0);
            printf ("trace level has been set to %d\n", ias_trace);
        }
        else
            printf ("current trace level is %d\n", ias_trace);
    }
    else if (!strcasecmp (argv[0], "dumpDcache"))
    {
        doDumpDCacheCmd (argc, argv);
    }
    else if (!strcasecmp (argv[0], "dumpIcache"))
    {
        doDumpICacheCmd (argc, argv);
    }
    else if (!strcasecmp (argv[0], "configure"))
    {
        argv++;  /* doConfigureCmd needs the "configure" part of cmd removed */
        doConfigureCmd (argc, argv);
    }
    else if (!strcasecmp (argv[0], "scache"))
    {
        doSCacheCmd (argc, argv);
    }
    else if (!strcasecmp (argv[0], "checkpoint"))
    {
        if (argc != 2)
	{
           printf ("checkpoint needs to be given a filename\n");
        }
        else
            checkpoint (argv[1]);
    }
    else if (!strcasecmp (argv[0], "restart"))
    {
        if (argc != 2)
	{
           printf ("restart needs to be given a filename\n");
        }
        else
            restart (argv[1]);
    }
    else 
        printf ("sim command not understood...\n%s\n", usage);
returnPoint:
    free (argv);
#undef MAX_SIM_DO_COMMAND_ARGS
}

void sim_set_callbacks ()

{ /* do nothing */ 
    DPRINTF (GDB_DBG_LVL, ("sim_set_callbacks called\n"));
}
