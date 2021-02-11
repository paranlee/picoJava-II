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




module prils_dp (lsout,lsround,priout,a1,a0,multout,stin,m0c,m4,
		 m1c,mconfunc,m3c,m2c,saout,lsdprec);

output [31:0]  lsout;    // Left Shift module output.
output         lsround;  // Left Shift ROUND output.
output  [5:0]  priout;
input  [31:0]  a1,a0,multout;
input          stin;     // sticky register input.
input  [1:0] m2c,m3c,m1c;
input        m0c;
input        m4;
input [1:0] mconfunc;
input   [4:0]  saout;     // Shift amount Input.
input    lsdprec;

wire   [31:0]  m0out,top_muxout,m3out,mconout,lsoutp;
wire   [5:0]  m2out;

//wire  [1:0] m0x;
//wire [3:0] m1x,mconx;
//wire [2:0] m2x,m3x;


mj_s_mux4_d_32 mcon(.mx_out(mconout),
		.sel(mconfunc),
		.in0(32'hff000000),
		.in1(32'h7fffffff),
                .in2(32'hffffffff),
		.in3(32'h80000000));


mj_s_mux2_d_32 prils_dp_m0(.mx_out(m0out),
		.sel(m0c),
		.in0(32'h0),
		.in1(a0));


mj_s_mux4_d_32 prils_dp_m1(.mx_out(top_muxout),
		.sel(m1c),
		.in0(a0),
		.in1(a1),
		.in2(32'h0),
		.in3({1'h0,a1[30:0]}));


mj_s_mux3_d_6 prils_dp_m2(.mx_out(m2out),
		.sel(m2c),
		.in0({1'b0,5'h0}),
		.in1({1'b0,saout}),
		.in2({1'b0,priout[4:0]}));
 

mj_s_mux3_d_32 prils_dp_m3(.mx_out(m3out),
		.sel(m3c),
		.in0(32'h0),
		.in1(mconout),
		.in2(top_muxout));


lshift lsh(	.out(lsoutp),
		.high(m3out),
		.low(m0out[31:1]),
		.shifta(m2out[4:0]));


pri_encode pri_e(.out(priout),.in(top_muxout));

prils_round_dec ls2(	.roundout(lsround),
		.in(lsoutp[11:0]),
		.prec(lsdprec), 
		.gin(m0out[0]),
		.stin(stin));

mj_s_mux2_d_32 lsmux(.mx_out(lsout),
		.sel(m4),
		.in0(lsoutp),
		.in1(multout));

 
endmodule


module prils_round_dec(roundout,in,prec,gin,stin);
// Performs the extraction and round for the LS or RS portions.

input [11:0]  in;
input         prec,stin,gin;

output        roundout;

wire          g,l,stickyl,stickyh,s;

assign g       = (in[7] && !prec) || (in[10] && prec);
assign l       = (in[8] && !prec) || (in[11] && prec);
assign stickyl = (| in[6:0]) || gin || stin;
assign stickyh = (| in[9:7]) || stickyl;

assign s = (prec) ? stickyh : stickyl;

assign roundout = ((g && s) || (g && !s && l)) ? 1'h1 : 1'h0;  // round

endmodule
