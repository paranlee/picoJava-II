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




#ifndef _EXT_OPS_H_
#define _EXT_OPS_H_

#pragma ident "@(#)ext_ops.h 1.8 Last modified 10/06/98 11:36:46 SMI"


#define	opc_load_ubyte			0
#define	opc_load_byte			1
#define	opc_load_char			2
#define	opc_load_short			3
#define	opc_load_word			4
#define	opc_load_char_oe		10
#define	opc_load_short_oe		11
#define	opc_load_word_oe		12
#define	opc_ncload_ubyte		16
#define	opc_ncload_byte		    17
#define	opc_ncload_char		    18
#define	opc_ncload_short		19
#define	opc_ncload_word		    20
#define	opc_cache_invalidate    23
#define	opc_ncload_char_oe		26
#define	opc_ncload_short_oe		27
#define	opc_ncload_word_oe		28
#define	opc_store_byte			32
#define	opc_store_short		    34
#define	opc_store_word			36
#define opc_soft_trap           37

#define	opc_store_short_oe		42
#define	opc_store_word_oe		44
#define	opc_ncstore_byte		48
#define	opc_ncstore_short		50
#define	opc_ncstore_word		52
#define	opc_ncstore_short_oe	58
#define	opc_ncstore_word_oe		60

#define	opc_priv_reset			54
#define opc_get_current_class   55
#define	opc_priv_powerdown      22

#define	opc_zero_line			62
#define opc_priv_update_optop   63
#define	opc_cache_flush		    30
#define	opc_cache_index_flush	31

#define	opc_priv_read_dcache_tag		6
#define	opc_priv_write_dcache_tag	38
#define	opc_priv_read_dcache_data	7
#define	opc_priv_write_dcache_data	39
#define	opc_priv_read_icache_tag		14
#define	opc_priv_write_icache_tag	46
#define	opc_priv_read_icache_data	15
#define	opc_priv_write_icache_data	47
#define	opc_priv_ret_from_trap	5

#define opc_call                61
#define opc_return0             13
#define opc_return1             29
#define opc_return2             45

#define	opc_read_pc   			64
#define opc_read_vars           65
#define opc_read_frame           66
#define opc_read_optop           67
#define opc_priv_read_oplim           68
#define opc_read_const_pool      69 
#define opc_priv_read_psr             70 
#define opc_priv_read_trapbase        71 
#define opc_priv_read_lockcount0      72 
#define opc_priv_read_lockcount1      73
#define opc_priv_read_lockaddr0       76 
#define opc_priv_read_lockaddr1       77 
#define opc_priv_read_userrange1      80 
#define opc_priv_read_userrange2      85 
#define opc_priv_read_gc_config       81 
#define opc_priv_read_brk1a           82 
#define opc_priv_read_brk2a           83
#define opc_priv_read_brk12c          84 
#define opc_priv_read_versionid       87 
#define opc_priv_read_hcr             88 
#define opc_priv_read_sc_bottom       89 
#define opc_read_global0              90
#define opc_read_global1              91
#define opc_read_global2              92
#define opc_read_global3              93

#define	opc_ret_from_sub 		 96
#define opc_write_pc             96
#define opc_write_vars           97
#define opc_write_frame          98 
#define opc_write_optop          99
#define opc_priv_write_oplim     100 
#define opc_write_const_pool     101 
#define opc_priv_write_psr       102  
#define opc_priv_write_trapbase  103
#define opc_priv_write_lockcount0     104 
#define opc_priv_write_lockcount1     105 
#define opc_priv_write_lockaddr0      108 
#define opc_priv_write_lockaddr1      109 
#define opc_priv_write_userrange1     112  
#define opc_priv_write_userrange2     117  
#define opc_priv_write_gc_config   113  
#define opc_priv_write_brk1a     114   
#define opc_priv_write_brk2a     115
#define opc_priv_write_brk12c    116  
#define opc_priv_write_sc_bottom 121
#define opc_write_global0        122
#define opc_write_global1        123
#define opc_write_global2        124
#define opc_write_global3        125

/* PICOJAVA-II EXTENSIONS */
#define opc_iucmp                21

#define TRAP_IF_NONPRIV { if (!(psr & 0x20)) {                              \
          fprintf(stdout, "Taking privileged instruction trap ...\n");      \
          vSetupException (PRIV_INSTR_EXCEPTION); return; } }

#define	END_ADDRESS	 0xFFFC
#define	END_ADDRESS1 0xFFFFFFFC
#define EOI_ADDRESS  0xFFF8

extern char *ext_hw_opcode_names[];

#define	ERROR(name, data) \
		fprintf(stdout,"name data\n");

void vDoExtOp (unsigned char ext_opcode);

#endif /* _EXT_OPS_H_ */
