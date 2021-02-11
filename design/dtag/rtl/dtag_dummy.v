/****************************************************************
 ---------------------------------------------------------------
     Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
     Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
     The contents of this file are subject to the current
     version of the Sun Community Source License, picoJava-II
     Core ("the License").  You may not use this file except
     in compliance with the License.  You may obtain a copy
     of the License by searching for "Sun Community Source
     License" on the World Wide Web at http://www.sun.com.
     See the License for the rights, obligations, and
     limitations governing use of the contents of this file.

     Sun, Sun Microsystems, the Sun logo, and all Sun-based
     trademarks and logos, Java, picoJava, and all Java-based
     trademarks and logos are trademarks or registered trademarks 
     of Sun Microsystems, Inc. in the United States and other
     countries.
 ----------------------------------------------------------------
******************************************************************/



`include "defines.h"

module 	dtag_dummy	(
		tag_in,
		tag_we,
		cmp_addr_in,
		set_sel,
		wb_set_sel,
		addr,
		stat_in,
		stat_we,
		stat_addr, 
		reg_enable,
		clk,
		sin,
		sm,
		so,
		hit0_out,
		hit1_out,
		dtag_dout,
		stat_out,
		test_mode,
		bist_mode,
		bist_reset,
		dtag_test_err_l
		);


input	[`dt_msb:0]	tag_in;	// Write data_in
input	[`dt_msb:0]	cmp_addr_in;  // dcu_addr_c for hit/miss decision, out of FF.
input	[4:0]		stat_in;	// Write status bus
input			set_sel;	// Select set 
input			wb_set_sel;	// Select set for tag_out
input			tag_we;	// Write enable for tag array
input	[4:0]		stat_we ;	// Write enable for status array
input	[`dc_msb:4]	addr;	// Address inputs for reading tags and status reg
input	[`dc_msb:4]	stat_addr;	// Address inputs for writing into status regs
input			reg_enable;	// power down mode
input			clk;		// Clock
input			sin;		// Scan input
input			sm;		// Scan mode
input			test_mode;
input   [1:0]		bist_mode;
input			bist_reset;

output			so;		// scan output
output 			hit0_out;       // d$ hit on set0
output 			hit1_out;    	// d$ hit on set1 
output  [`dt_msb:0]	dtag_dout;	// Tag output for lower bits of wb_addr 
output	[4:0]		stat_out;	// status reg output
output 			dtag_test_err_l;

wire	[`dt_msb:0]	bist_tag_in;
wire	[4:0]		bist_stat_in;
wire 	[8:0]		bist_addr;
wire	[`dc_msb:4]	bist_stat_addr;
wire			bist_wb_set_sel;
wire 			bist_tag_we;
wire 	[`dt_msb:0] 	bist_tagin;
wire	[4:0]		bist_stat_we;



endmodule
