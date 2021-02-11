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

module length_dec (

	fetch_len0,
	fetch_len1,
	fetch_len2,
	fetch_len3,
	fetch_len4,
	fetch_len5,
	fetch_len6,
	fold_4_inst,
	fold_3_inst,
	fold_2_inst,
	fold_1_inst,
	not_valid,
	ex_len_first_inst,
	hold_d,

	iu_shift_d,
	accum_len0,
	accum_len1,
	accum_len2,
	accum_len3

);

input	[3:0]	fetch_len0;	// Length of the first byte as output from Fetch stage
input	[3:0]	fetch_len1;	// ...
input	[3:0]	fetch_len2;
input	[3:0]	fetch_len3;
input	[3:0]	fetch_len4;
input	[3:0]	fetch_len5;
input	[3:0]	fetch_len6;

input		fold_4_inst;
input		fold_3_inst;
input		fold_2_inst;
input		fold_1_inst;
input		not_valid;
input		hold_d;
input	[5:0]	ex_len_first_inst;


output	[7:0]	iu_shift_d;	// shift to ibuffer in ICU
output	[7:0]	accum_len0;	// This will give the accumulated length incl. 1st Inst.
output	[7:0]	accum_len1;	// This will give the accumulated length incl. 2nd Inst
output	[7:0]	accum_len2;	// This will give the accumulated length incl. 3nd Inst
output	[7:0]	accum_len3;	// This will give the accumulated length incl. 4nd Inst
				// Ex: I1 is 2 bytes long, I2 is 3, I3 is 1 and I4 is 1
				// accum_len0 = 2, len_1 = 5, len_2 = 6 and len_3 = 7

wire	[7:0]	iu_shift_d_int;
wire	[7:0]	int_len1;
wire	[7:0]	int_len2;
wire	[7:0]	int_len3;
wire	[7:0]	int_len4;
wire	[7:0]	int_len5;
wire	[7:0]	int_len6;

index1_add	index1_add( .operand(fetch_len1),
				.sum(int_len1));

index2_add	index2_add( .operand(fetch_len2),
				.sum(int_len2));

index3_add	index3_add( .operand(fetch_len3),
				.sum(int_len3));

index4_add	index4_add( .operand(fetch_len4),
				.sum(int_len4));

index5_add	index5_add( .operand(fetch_len5),
				.sum(int_len5));

index6_add	index6_add( .operand(fetch_len6),
				.sum(int_len6));

sp_mux4_8		mux_len1(.out(accum_len1),
			.in0(8'b00000001),
			.in1(int_len1),
			.in2(int_len2),
			.in3(int_len3),
			.sel(fetch_len0) );

sp_mux8_8		mux_len2(.out(accum_len2),
			.in0(8'b00000001),
			.in1(int_len1),
			.in2(int_len2),
			.in3(int_len3),
			.in4(int_len4),
			.in5(int_len5),
			.in6(int_len6),
			.in7(8'b00000001),
			.sel(accum_len1) );

sp_mux8_8		mux_len3(.out(accum_len3),
			.in0(8'b00000001),
			.in1(int_len1),
			.in2(int_len2),
			.in3(int_len3),
			.in4(int_len4),
			.in5(int_len5),
			.in6(int_len6),
			.in7(8'b00000001),
			.sel(accum_len2) );


sp_mux4_8               mux_shift_d (.out(iu_shift_d_int),
                                .in0({2'b0,ex_len_first_inst}),
                                .in1(accum_len1),
                                .in2(accum_len2),
                                .in3(accum_len3),
                                .sel({fold_4_inst,fold_3_inst,fold_2_inst,
                                        fold_1_inst}) );

// Whenever there's hold_d, iu_shift_d = 8'b00000001
assign  iu_shift_d[7:1] = (iu_shift_d_int[7:1]) & {7{~hold_d}};
assign  iu_shift_d[0] =   (not_valid | hold_d);

assign	accum_len0 =  {4'b0,fetch_len0};

endmodule


module sp_mux4_8 
		( out,
		  in0,
		  in1,
		  in2,
		  in3,
		  sel);


output	[7:0]	out;
input	[7:0]	in0;
input	[7:0]	in1;
input	[7:0]	in2;
input	[7:0]	in3;
input	[3:0]	sel;



assign	out[7] = in3[7]&sel[3]|
		 in2[7]&sel[2]|
		 in1[7]&sel[1]|
		 in0[7]&sel[0];


assign  out[6] = in3[6]&sel[3]|
                 in2[6]&sel[2]|
                 in1[6]&sel[1]|
                 in0[6]&sel[0];

assign  out[5] = in3[5]&sel[3]|
                 in2[5]&sel[2]|
                 in1[5]&sel[1]|
                 in0[5]&sel[0];

assign  out[4] = in3[4]&sel[3]|
                 in2[4]&sel[2]|
                 in1[4]&sel[1]|
                 in0[4]&sel[0];


assign  out[3] = in3[3]&sel[3]|
                 in2[3]&sel[2]|
                 in1[3]&sel[1]|
                 in0[3]&sel[0];
 
assign  out[2] = in3[2]&sel[3]|
                 in2[2]&sel[2]|
                 in1[2]&sel[1]|
                 in0[2]&sel[0];
 
assign  out[1] = in3[1]&sel[3]|
                 in2[1]&sel[2]|
                 in1[1]&sel[1]|
                 in0[1]&sel[0];


assign  out[0] = in3[0]&sel[3]|
                 in2[0]&sel[2]|
                 in1[0]&sel[1]|
                 in0[0]&sel[0];


endmodule


module sp_mux8_8
                ( out,
                  in0,
                  in1,
                  in2,
                  in3,
                  in4,
                  in5,
                  in6,
                  in7,
                  sel);
 
 
output  [7:0]   out;
input   [7:0]   in0;
input   [7:0]   in1;
input   [7:0]   in2;
input   [7:0]   in3;
input   [7:0]   in4;
input   [7:0]   in5;
input   [7:0]   in6;
input   [7:0]   in7;

input   [7:0]   sel;
 
 
 
assign  out[7] = in7[7]&sel[7]|
		 in6[7]&sel[6]|
		 in5[7]&sel[5]|
		 in4[7]&sel[4]|
		 in3[7]&sel[3]|
                 in2[7]&sel[2]|
                 in1[7]&sel[1]|
                 in0[7]&sel[0];
 

assign  out[6] = in7[6]&sel[7]|
                 in6[6]&sel[6]|
                 in5[6]&sel[5]|
                 in4[6]&sel[4]|
                 in3[6]&sel[3]|
                 in2[6]&sel[2]|
                 in1[6]&sel[1]|
                 in0[6]&sel[0];

assign  out[5] = in7[5]&sel[7]|
                 in6[5]&sel[6]|
                 in5[5]&sel[5]|
                 in4[5]&sel[4]|
                 in3[5]&sel[3]|
                 in2[5]&sel[2]|
                 in1[5]&sel[1]|
                 in0[5]&sel[0];

assign  out[4] = in7[4]&sel[7]|
                 in6[4]&sel[6]|
                 in5[4]&sel[5]|
                 in4[4]&sel[4]|
                 in3[4]&sel[3]|
                 in2[4]&sel[2]|
                 in1[4]&sel[1]|
                 in0[4]&sel[0];


assign  out[3] = in7[3]&sel[7]|
                 in6[3]&sel[6]|
                 in5[3]&sel[5]|
                 in4[3]&sel[4]|
                 in3[3]&sel[3]|
                 in2[3]&sel[2]|
                 in1[3]&sel[1]|
                 in0[3]&sel[0];

assign  out[2] = in7[2]&sel[7]|
                 in6[2]&sel[6]|
                 in5[2]&sel[5]|
                 in4[2]&sel[4]|
                 in3[2]&sel[3]|
                 in2[2]&sel[2]|
                 in1[2]&sel[1]|
                 in0[2]&sel[0];

assign  out[1] = in7[1]&sel[7]|
                 in6[1]&sel[6]|
                 in5[1]&sel[5]|
                 in4[1]&sel[4]|
                 in3[1]&sel[3]|
                 in2[1]&sel[2]|
                 in1[1]&sel[1]|
                 in0[1]&sel[0];

assign  out[0] = in7[0]&sel[7]|
                 in6[0]&sel[6]|
                 in5[0]&sel[5]|
                 in4[0]&sel[4]|
                 in3[0]&sel[3]|
                 in2[0]&sel[2]|
                 in1[0]&sel[1]|
                 in0[0]&sel[0];

endmodule
