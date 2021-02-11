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

module fold_dec (

	ibuff_0,	
	ibuff_1,
	ibuff_2,
	ibuff_3,
	ibuff_4,
	ibuff_5,
	ibuff_6,
	accum_len0,
	accum_len1,
	accum_len2,
	type_0,
	type_1,
	type_2,
	type_3
);

input	[7:0]	ibuff_0;
input	[7:0]	ibuff_1;
input	[7:0]	ibuff_2;
input	[7:0]	ibuff_3;
input	[7:0]	ibuff_4;
input	[7:0]	ibuff_5;
input	[7:0]	ibuff_6;
input	[7:0]	accum_len0;
input	[7:0]	accum_len1;
input	[7:0]	accum_len2;

output	[5:0]	type_0;		// Indicates what type is Inst 1, i.e LV, BG1, etc ..
output	[5:0]	type_1;
output	[5:0]	type_2;
output	[5:0]	type_3;

wire	[5:0]	int_type_0;
wire	[5:0]	int_type_1;
wire	[5:0]	int_type_2;
wire	[5:0]	int_type_3;
wire	[5:0]	int_type_4;
wire	[5:0]	int_type_5;
wire	[5:0]	int_type_6;
wire	[5:0]	non_fold_type;
wire	[7:0]	invalid_byte;

assign non_fold_type = 6'b000001;
assign	invalid_byte = 8'hff;

// We decode each of the 7 pairs of cosecutive bytes to determines their types

fdec	fdec_0(.opcode({ibuff_0,ibuff_1}),
		.type(int_type_0) );

fdec	fdec_1(.opcode({ibuff_1,ibuff_2}),
		.type(int_type_1) );

fdec	fdec_2(.opcode({ibuff_2,ibuff_3}),
		.type(int_type_2) );

fdec	fdec_3(.opcode({ibuff_3,ibuff_4}),
		.type(int_type_3) );

fdec	fdec_4(.opcode({ibuff_4,ibuff_5}),
		.type(int_type_4) );

fdec	fdec_5(.opcode({ibuff_5,ibuff_6}),
		.type(int_type_5) );

fdec	fdec_6(.opcode({ibuff_6,invalid_byte}),
		.type(int_type_6) );

// Generate the four folding types of 4 prospective instructions to be folded

assign	type_0 = int_type_0;

mux8_6	mux_type_1(.out(type_1),
			.in0(non_fold_type),
			.in1(int_type_1),
			.in2(int_type_2),
			.in3(int_type_3),
			.in4(int_type_4),
			.in5(int_type_5),
			.in6(int_type_6),
			.in7(non_fold_type),
			.sel(accum_len0) );

mux8_6	mux_type_2(.out(type_2),
			.in0(non_fold_type),
			.in1(int_type_1),
			.in2(int_type_2),
			.in3(int_type_3),
			.in4(int_type_4),
			.in5(int_type_5),
			.in6(int_type_6),
			.in7(non_fold_type),
			.sel(accum_len1) );

mux8_6	mux_type_3(.out(type_3),
			.in0(non_fold_type),
			.in1(int_type_1),
			.in2(int_type_2),
			.in3(int_type_3),
			.in4(int_type_4),
			.in5(int_type_5),
			.in6(int_type_6),
			.in7(non_fold_type),
			.sel(accum_len2) );

endmodule
