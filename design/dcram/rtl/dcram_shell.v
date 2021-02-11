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

module dcram_shell( clk, bist_mode, bist_reset, test_mode,
		    data_in, we, bypass, bank_sel, reg_enable, addr,
		    sin, so, sm, data_out, dcache_test_err_l);

input clk;
input [1:0] bist_mode;
input bist_reset;
input test_mode;
input [63:0] data_in;
input [3:0] we;
input bypass;
input [1:0] bank_sel;
input reg_enable;
input [`dc_msb:0] addr;
input sin;
input sm;
output so;
output [63:0] data_out;
output dcache_test_err_l;

wire [63:0] bist_data_in;
wire [3:0] bist_we;
wire [`dc_msb-2:0] bist_addr;

dcram_top dcram_top (	.data_in(data_in),
			.we(we),
			.bypass(bypass),
			.bank_sel(bank_sel),
			.enable(reg_enable),
			.addr(addr),
			.clk(clk),
			.data_out(data_out),
			.bist_reset(bist_reset),
			.bist_mode(bist_mode),
			.sin(sin),
			.sm(sm),
			.so(so),
			.test_mode(test_mode),
			.ERROR(dcache_test_err_l));

dcram_misc dcram_misc(	.addr(addr),
			.bank_sel(bank_sel),
			.bypass(bypass),
			.sin(sin),
			.sm(sm),
			.so(so),
			.we(we),
			.data_in(data_in),
			.clk(clk));
endmodule
