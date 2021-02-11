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



//`timescale 1ns/1ns
`timescale 1ns/10ps
module multmod ( multout, nx_multfunc_rom0, nx_multfunc_rom1, romsel, nx_cyc0_rdy, movf, ma1, ma0, mb1, mb0, 
    		 sm, sin, so, clk, reset_l, fpuhold);
output [31:0] multout;
output movf;
input  [31:0] ma1;
input  [3:0] nx_multfunc_rom0, nx_multfunc_rom1;
input  [1:0] romsel;
input  nx_cyc0_rdy; 
input  [20:0] ma0;
input  [31:0] mb1;
input  [20:0] mb0;
input  sm, sin, clk, reset_l, fpuhold;
output so;

wire [17:0]   nx_multdec_muxcntl;


multmod_dp p_multmod_dp (	.mb1(mb1), 
				.mb0(mb0), 
				.ma1(ma1), 
				.ma0(ma0), 
				.clk(clk), 
				.reset_l(reset_l),
				.nx_multdec_muxcntl(nx_multdec_muxcntl),
        			.multout(multout), 
				.movf(movf),
				.fpuhold(fpuhold),
				.so(),
				.sm(),
				.sin());



multmod_cntl p_multmod_cntl ( 	.nx_multfunc_rom0(nx_multfunc_rom0),
				.nx_multfunc_rom1(nx_multfunc_rom1),
				.romsel(romsel), 
				.nx_cyc0_rdy(nx_cyc0_rdy),
		      		.clk(clk), 
				.reset_l(reset_l), 
				.nx_multdec_muxcntl(nx_multdec_muxcntl)); 
endmodule

