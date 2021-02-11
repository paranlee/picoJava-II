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




#ifndef _TRAPS_H_
#define _TRAPS_H_

#pragma ident "@(#)traps.h 1.7 Last modified 10/06/98 11:37:15 SMI"

typedef enum {
	por	= 0,
	async_err = 1,
	mem_prot_err = 2,       /* used only for picoJava-II */
	data_acc_mem_err = 3,
	instr_acc_mem_err = 4,
	priv_instr = 5,
	illegal_instr = 6,
	breakpoint1 = 7,
	breakpoint2 = 8,
	mem_addr_not_aligned = 9,
	data_acc_io_err = 10,
	oplim_trap = 12,
    soft_trap = 13,
	arithmetic_excep = 22,
	indexoutofbnds_excep = 25,
	nullptr_excep = 27,

	lock_count_overflow_trap = 35,
	lock_enter_miss_trap = 36,
	lock_release_trap = 37, 
	lock_exit_miss_trap = 38,
	gc_notify = 39,
	ZeroLineEmulationTrap = 0x29,
	nmi = 0x30,
	interrupt_level_tt_base = 0x31

} trap_name;

void invoke_trap (int trap_type);

#endif /* _TRAPS_H_ */
