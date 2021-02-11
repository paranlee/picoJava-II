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

module dtag_misc( test_mode, addr, set_sel,
		  tag_in, status_in, sm, sin, so, clk, wb_set_sel,
		  tag_we, stat_we, stat_addr, cmp_addr_in);

input clk;
input test_mode;
input [`dc_msb-4:0] addr;
input [`dt_msb:0] cmp_addr_in;
input [`dc_msb-4:0] stat_addr;
input set_sel;
input [`dt_msb:0] tag_in;
input [4:0] status_in;
input sm;
input sin;
input wb_set_sel;
input tag_we;
input [4:0] stat_we;

output so;

reg[`dc_msb-4:0] addr_l,stat_addr_l;
reg [`dt_msb:0] cmp_addr_in_l;
reg [`dt_msb:0] tag_in_l;


mj_s_ff_s_d ff0(	.out(),
			.in(set_sel),
			.clk(clk));

mj_s_ff_s_d ff5(        .out(),
                        .in(wb_set_sel),
                        .clk(clk));

mj_s_ff_s_d ff1(	.out(),
			.in(tag_we),
			.clk(clk));

mj_s_ff_s_d ff6(        .out(),
                        .in(tag_we),
                        .clk(clk));


mj_s_ff_s_d_5 ff2(	.out(),
			.din(status_in),
			.clk(clk));

mj_s_ff_s_d_5 ff3(	.out(),
			.din(stat_we),
			.clk(clk));

// Replacing hardcoded flops with configurable (depending on cache size) code.

/*
mj_s_ff_s_d ff7(	.out(),
			.in(addr[8]),
			.clk(clk));

mj_s_ff_s_d ff8(	.out(),
			.in(addr[7]),
			.clk(clk));

mj_s_ff_s_d ff9(        .out(),
                        .in(addr[6]),
                        .clk(clk));

mj_s_ff_s_d ff10(        .out(),
                        .in(addr[5]),
                        .clk(clk));

mj_s_ff_s_d ff11(        .out(),
                        .in(addr[4]),
                        .clk(clk));

mj_s_ff_s_d ff12(        .out(),
                        .in(addr[3]),
                        .clk(clk));

mj_s_ff_s_d ff13(        .out(),
                        .in(addr[2]),
                        .clk(clk));

mj_s_ff_s_d ff14(        .out(),
                        .in(addr[1]),
                        .clk(clk));

mj_s_ff_s_d ff15(        .out(),
                        .in(addr[0]),
                        .clk(clk));
*/

always @(posedge clk) begin

	addr_l = #1 addr;

end


// Replacing hardcoded flops with configurable (depending on cache size) code.

/*
mj_s_ff_s_d ff16(        .out(),
                        .in(stat_addr[8]),
                        .clk(clk));

mj_s_ff_s_d ff17(        .out(),
                        .in(stat_addr[7]),
                        .clk(clk));

mj_s_ff_s_d ff18(        .out(),
                        .in(stat_addr[6]),
                        .clk(clk));

mj_s_ff_s_d ff19(        .out(),
                        .in(stat_addr[5]),
                        .clk(clk));

mj_s_ff_s_d ff20(        .out(),
                        .in(stat_addr[4]),
                        .clk(clk));

mj_s_ff_s_d ff21(        .out(),
                        .in(stat_addr[3]),
                        .clk(clk));

mj_s_ff_s_d ff22(        .out(),
                        .in(stat_addr[2]),
                        .clk(clk));

mj_s_ff_s_d ff23(        .out(),
                        .in(stat_addr[1]),
                        .clk(clk));

mj_s_ff_s_d ff24(        .out(),
                        .in(stat_addr[0]),
                        .clk(clk));
*/

always @(posedge clk) begin

	stat_addr_l = #1 stat_addr;

end


// Replacing hardcoded flops with configurable (depending on cache size) code.

/*
mj_s_ff_s_d ff25(        .out(),
                        .in(tag_in[18]),
                        .clk(clk));

mj_s_ff_s_d ff26(        .out(),
                        .in(tag_in[17]),
                        .clk(clk));

mj_s_ff_s_d ff27(        .out(),
                        .in(tag_in[16]),
                        .clk(clk));

mj_s_ff_s_d ff28(        .out(),
                        .in(tag_in[15]),
                        .clk(clk));

mj_s_ff_s_d ff29(        .out(),
                        .in(tag_in[14]),
                        .clk(clk));

mj_s_ff_s_d ff30(        .out(),
                        .in(tag_in[13]),
                        .clk(clk));

mj_s_ff_s_d ff31(        .out(),
                        .in(tag_in[12]),
                        .clk(clk));

mj_s_ff_s_d ff32(        .out(),
                        .in(tag_in[11]),
                        .clk(clk));

mj_s_ff_s_d ff33(        .out(),
                        .in(tag_in[10]),
                        .clk(clk));

mj_s_ff_s_d ff34(        .out(),
                        .in(tag_in[9]),
                        .clk(clk));

mj_s_ff_s_d ff34a(        .out(),
                        .in(tag_in[8]),
                        .clk(clk));

mj_s_ff_s_d ff35(        .out(),
                        .in(tag_in[7]),
                        .clk(clk));

mj_s_ff_s_d ff36(        .out(),
                        .in(tag_in[6]),
                        .clk(clk));

mj_s_ff_s_d ff37(        .out(),
                        .in(tag_in[5]),
                        .clk(clk));

mj_s_ff_s_d ff38(        .out(),
                        .in(tag_in[4]),
                        .clk(clk));

mj_s_ff_s_d ff39(        .out(),
                        .in(tag_in[3]),
                        .clk(clk));

mj_s_ff_s_d ff40(        .out(),
                        .in(tag_in[2]),
                        .clk(clk));

mj_s_ff_s_d ff41(        .out(),
                        .in(tag_in[1]),
                        .clk(clk));

mj_s_ff_s_d ff42(        .out(),
                        .in(tag_in[0]),
                        .clk(clk));
*/

always @(posedge clk) begin

        tag_in_l = #1 tag_in;

end


// Replacing hardcoded flops with configurable (depending on cache size) code.

/*
mj_s_ff_s_d ff43(        .out(),
                        .in(cmp_addr_in[8]),
                        .clk(clk));

mj_s_ff_s_d ff44(        .out(),
                        .in(cmp_addr_in[7]),
                        .clk(clk));

mj_s_ff_s_d ff45(        .out(),
                        .in(cmp_addr_in[6]),
                        .clk(clk));

mj_s_ff_s_d ff46(        .out(),
                        .in(cmp_addr_in[5]),
                        .clk(clk));

mj_s_ff_s_d ff47(        .out(),
                        .in(cmp_addr_in[4]),
                        .clk(clk));

mj_s_ff_s_d ff48(        .out(),
                        .in(cmp_addr_in[3]),
                        .clk(clk));

mj_s_ff_s_d ff49(        .out(),
                        .in(cmp_addr_in[2]),
                        .clk(clk));

mj_s_ff_s_d ff50(        .out(),
                        .in(cmp_addr_in[1]),
                        .clk(clk));

mj_s_ff_s_d ff51(        .out(),
                        .in(cmp_addr_in[0]),
                        .clk(clk));

mj_s_ff_s_d ff52(        .out(),
                        .in(cmp_addr_in[10]),
                        .clk(clk));

mj_s_ff_s_d ff53(        .out(),
                        .in(cmp_addr_in[11]),
                        .clk(clk));

mj_s_ff_s_d ff54(        .out(),
                        .in(cmp_addr_in[12]),
                        .clk(clk));

mj_s_ff_s_d ff55(        .out(),
                        .in(cmp_addr_in[13]),
                        .clk(clk));

mj_s_ff_s_d ff56(        .out(),
                        .in(cmp_addr_in[14]),
                        .clk(clk));

mj_s_ff_s_d ff57(        .out(),
                        .in(cmp_addr_in[15]),
                        .clk(clk));

mj_s_ff_s_d ff58(        .out(),
                        .in(cmp_addr_in[16]),
                        .clk(clk));

mj_s_ff_s_d ff59(        .out(),
                        .in(cmp_addr_in[17]),
                        .clk(clk));

mj_s_ff_s_d ff60(        .out(),
                        .in(cmp_addr_in[18]),
                        .clk(clk));
*/

always @(posedge clk) begin

        cmp_addr_in_l = #1 cmp_addr_in;

end

endmodule
