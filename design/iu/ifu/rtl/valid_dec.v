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

// This module is used to determine valid bits for the four prospective instructions
// to be folded

module valid_dec (

	fetch_valid,
	accum_len0,
	accum_len1,
	accum_len2,
	ex_len_first_inst,
	fetch_len1,
	fetch_len2,
	fetch_len3,
	fetch_len4,
	fetch_len5,
	fetch_len6,
	dec_valid
);

input	[6:0]	fetch_valid; 	// Valid bits for the top 7 bytes of the ibuffer
input	[7:0]	accum_len0; 	// accumulated lengths from length_decoder
input	[7:0]	accum_len1;
input	[7:0]	accum_len2;	
input	[5:0]	ex_len_first_inst; // Exact length for the first inst.
input	[3:0]	fetch_len1;	// Length of the 2nd byte from the fetch stage
input	[3:0]	fetch_len2;
input	[3:0]	fetch_len3;
input	[3:0]	fetch_len4;
input	[3:0]	fetch_len5;
input	[3:0]	fetch_len6;
output	[3:0]	dec_valid;	// Valids of the four prospective instructions to be 
				// folded

wire	vld_0_len2, vld_0_len3, vld_0_len4, vld_0_len5;
wire	vld_1_len1, vld_1_len2, vld_1_len3;
wire	vld_2_len1, vld_2_len2, vld_2_len3;
wire	vld_3_len1, vld_3_len2, vld_3_len3;
wire	vld_4_len1, vld_4_len2, vld_4_len3;
wire	vld_5_len1, vld_5_len2, vld_5_len3;
wire	vld_6_len1, vld_6_len2, vld_6_len3;

wire	vld_0, vld_1, vld_2, vld_3, vld_4, vld_5, vld_6;

assign vld_0_len2 = &(fetch_valid[1:0]); 
assign vld_0_len3 = &(fetch_valid[2:0]); 
assign vld_0_len4 = &(fetch_valid[3:0]); 
assign vld_0_len5 = &(fetch_valid[4:0]); 

assign	vld_1_len1 = fetch_valid[1];
assign	vld_1_len2 = &(fetch_valid[2:1]);
assign	vld_1_len3 = &(fetch_valid[3:1]);

assign	vld_2_len1 = fetch_valid[2];
assign	vld_2_len2 = &(fetch_valid[3:2]);
assign	vld_2_len3 = &(fetch_valid[4:2]);

assign	vld_3_len1 = fetch_valid[3];
assign	vld_3_len2 = &(fetch_valid[4:3]);
assign	vld_3_len3 = &(fetch_valid[5:3]);

assign	vld_4_len1 = fetch_valid[4];
assign	vld_4_len2 = &(fetch_valid[5:4]);
assign	vld_4_len3 = &(fetch_valid[6:4]);

assign	vld_5_len1 = fetch_valid[5];
assign	vld_5_len2 = &(fetch_valid[6:5]);
assign	vld_5_len3 = 1'b0;

assign	vld_6_len1 = fetch_valid[6];
assign	vld_6_len2 = 1'b0;
assign	vld_6_len3 = 1'b0;

// Determine for each of the bytes in the ibuffer, what would be the valids
// depending on their lengths

assign	vld_0 = |(ex_len_first_inst[5:1]);

mux4	mux_vld_1_byte (.out(vld_1),
			.in0(1'b0),
			.in1(vld_1_len1),
			.in2(vld_1_len2),
			.in3(vld_1_len3),
			.sel(fetch_len1) );

mux4	mux_vld_2_byte (.out(vld_2),
			.in0(1'b0),
			.in1(vld_2_len1),
			.in2(vld_2_len2),
			.in3(vld_2_len3),
			.sel(fetch_len2) );

mux4	mux_vld_3_byte (.out(vld_3),
			.in0(1'b0),
			.in1(vld_3_len1),
			.in2(vld_3_len2),
			.in3(vld_3_len3),
			.sel(fetch_len3) );

mux4	mux_vld_4_byte (.out(vld_4),
			.in0(1'b0),
			.in1(vld_4_len1),
			.in2(vld_4_len2),
			.in3(vld_4_len3),
			.sel(fetch_len4) );

mux4	mux_vld_5_byte (.out(vld_5),
			.in0(1'b0),
			.in1(vld_5_len1),
			.in2(vld_5_len2),
			.in3(vld_5_len3),
			.sel(fetch_len5) );

mux4	mux_vld_6_byte (.out(vld_6),
			.in0(1'b0),
			.in1(vld_6_len1),
			.in2(vld_6_len2),
			.in3(vld_6_len3),
			.sel(fetch_len6) );

// Now determine the valids of the four prospcetive instructions to be folded

assign	dec_valid[0] = vld_0;

mux8	mux_vld_1_inst (.out(dec_valid[1]),
			.in0(1'b0),
			.in1(vld_1),
			.in2(vld_2),
			.in3(vld_3),
			.in4(vld_4),
			.in5(vld_5),
			.in6(vld_6),
			.in7(1'b0),
			.sel(accum_len0) );

mux8	mux_vld_2_inst (.out(dec_valid[2]),
			.in0(1'b0),
			.in1(vld_1),
			.in2(vld_2),
			.in3(vld_3),
			.in4(vld_4),
			.in5(vld_5),
			.in6(vld_6),
			.in7(1'b0),
			.sel(accum_len1) );

mux8	mux_vld_3_inst (.out(dec_valid[3]),
			.in0(1'b0),
			.in1(vld_1),
			.in2(vld_2),
			.in3(vld_3),
			.in4(vld_4),
			.in5(vld_5),
			.in6(vld_6),
			.in7(1'b0),
			.sel(accum_len2) );

endmodule
