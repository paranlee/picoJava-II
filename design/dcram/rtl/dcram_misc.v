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

module dcram_misc( addr, bank_sel, bypass,
		   we, data_in, sin, so, sm, clk);

input clk;
input [`dc_msb:0] addr;
input [1:0] bank_sel;
input bypass;
input [3:0] we;
input [63:0] data_in;
input sm;
input sin;

output so;


reg [`dc_msb:0] addr_l;


mj_s_ff_s_d ff0(	.out(),
			.in(bypass),
			.clk(clk));

always @(posedge clk) begin

	addr_l = #1 addr;

end

mj_s_ff_s_d_2 ff2(	.out(),
			.din(bank_sel),
			.clk(clk));			

mj_s_ff_s_d_4 ff3(	.out(),
			.din(we),
			.clk(clk));

mj_s_ff_s_d_64 ff4(	.out(),
			.in(data_in),
			.clk(clk));

endmodule







