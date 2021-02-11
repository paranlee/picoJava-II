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




#ifndef _GDB_INTERFACE_H_
#define _GDB_INTERFACE_H_

#pragma ident "@(#)gdb_interface.h 1.8 Last modified 02/28/99 12:03:57 SMI"

typedef unsigned int SIM_ADDR;

enum sim_stop { sim_exited, sim_stopped, sim_signalled };

extern int running_under_gdb;
extern int simulation_interrupted;

void sim_open (char *args);
void sim_close (int quitting);
int sim_load (char *prog, int from_tty);
void sim_create_inferior (SIM_ADDR start_address, char **argv, char **env);
void sim_kill (void);
int sim_read (SIM_ADDR mem, unsigned char *buf, int length);
int sim_write (SIM_ADDR mem, unsigned char *buf, int length);
void sim_fetch_register (int regno, unsigned char *buf);
void sim_store_register (int regno, unsigned char *buf);
void sim_info (int verbose);
void sim_stop_reason (enum sim_stop *reason, int *sigrc);
void sim_resume (int step, int siggnal);
void sim_do_command (char *cmd);
void sim_set_callbacks ();

/*
new function: sim_hbreak: effectively functions as a h/w breakpoint (uses simulator
brkpt functionality, not pico h/w breakpoint registers)
sets a hbrkpt on the given address, 
hbrkpt_type = 
0 => code breakpoint
1 => data read brkpt
2 => data write brkpt
3 => data read+write brkpt
*/
void sim_hbreak (unsigned int address, int hbrkpt_type);

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
void sim_remove_hbreak (unsigned int address, int hbrkpt_type);

#endif /* _GDB_INTERFACE_H_ */
