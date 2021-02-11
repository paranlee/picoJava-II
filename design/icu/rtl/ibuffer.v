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




`timescale  1ns / 10ps

module	ibuffer (

	icache_data,
        encode_oplen,
	ibuf_dout,
	ibuf_oplen,
	shft_dsel,
	encod_dsel,
	nxt_ibuf_pc,
	jmp_pc,
	ibuf_pc_sel,
	ic_sel,
	buf_ic_sel,
	ibuf_enable,
	sin,
	sm,
	so,
	reset_l,
	clk
);

input	[63:0]	icache_data;		// Data from Icache after aligned properly      -- From Aligner
input	[31:0]	encode_oplen;		// Opcode length encoded data  -- From Aligner
output	[55:0]	ibuf_dout;		// Data going out from ibuffer                  -- To iu
output	[27:0]	ibuf_oplen;		// opcode length going out from ibuffer         -- To iu
input	[7:0]	shft_dsel;		// These selects will determine which of the    -- From ibuf_ctl
                                        // following 7 bytes will be selected
input	[2:0]	encod_dsel;		// Encoded value of shft_dsel used in determining the
					// PC of the first dataum in the ibuffer
output  [31:0]  nxt_ibuf_pc;	  	// PC value output from ibuffer		 	-- To iu
input  	[31:0]	jmp_pc;			// PC value input				-- From iu
input	[1:0]	ibuf_pc_sel;		// This will select either the seq. pc or br pc -- From iu
input	[11:0]	ic_sel;			// This will select which of the  8 bytes from	-- From ibuf_ctl
					// Icache is selected
input		ibuf_enable;
input	[15:0]	buf_ic_sel;		// Indicate whether ibuffer entries are valid or not
input		sin;			// Scan data input
input		sm;			// Scan Enable input
output		so;			// Scan data output
input		reset_l;		// Active-low reset
input		clk;			// Clk

wire  	[7:0]	ibuf_0_out;
wire  	[7:0]	ibuf_1_out;
wire  	[7:0]	ibuf_2_out;
wire  	[7:0]	ibuf_3_out;
wire  	[7:0]	ibuf_4_out;
wire  	[7:0]	ibuf_5_out;
wire  	[7:0]	ibuf_6_out;
wire  	[7:0]	ibuf_7_out;
wire  	[7:0]	ibuf_8_out;
wire  	[7:0]	ibuf_9_out;
wire  	[7:0]	ibuf_10_out;
wire  	[7:0]	ibuf_11_out;
wire  	[7:0]	ibuf_12_out;
wire  	[7:0]	ibuf_13_out;
wire  	[7:0]	ibuf_14_out;
wire  	[7:0]	ibuf_15_out;
wire  	[3:0]	ibuf_0_oplen;
wire  	[3:0]	ibuf_1_oplen;
wire  	[3:0]	ibuf_2_oplen;
wire  	[3:0]	ibuf_3_oplen;
wire  	[3:0]	ibuf_4_oplen;
wire  	[3:0]	ibuf_5_oplen;
wire  	[3:0]	ibuf_6_oplen;
wire  	[3:0]	ibuf_7_oplen;
wire  	[3:0]	ibuf_8_oplen;
wire  	[3:0]	ibuf_9_oplen;
wire  	[3:0]	ibuf_10_oplen;
wire  	[3:0]	ibuf_11_oplen;
wire  	[3:0]	ibuf_12_oplen;
wire  	[3:0]	ibuf_13_oplen;
wire  	[3:0]	ibuf_14_oplen;
wire  	[3:0]	ibuf_15_oplen;
wire	[7:0]	buf_ic_dout_0;
wire	[7:0]	buf_ic_dout_1;
wire	[7:0]	buf_ic_dout_2;
wire	[7:0]	buf_ic_dout_3;
wire	[7:0]	buf_ic_dout_4;
wire	[7:0]	buf_ic_dout_5;
wire	[7:0]	buf_ic_dout_6;
wire	[7:0]	buf_ic_dout_7;
wire	[7:0]	buf_ic_dout_8;
wire	[7:0]	buf_ic_dout_9;
wire	[7:0]	buf_ic_dout_10;
wire	[7:0]	buf_ic_dout_11;
wire	[7:0]	buf_ic_dout_12;
wire	[7:0]	buf_ic_dout_13;
wire	[7:0]	buf_ic_dout_14;
wire	[7:0]	buf_ic_dout_15;
wire	[3:0]	buf_ic_oplen_0;
wire	[3:0]	buf_ic_oplen_1;
wire	[3:0]	buf_ic_oplen_2;
wire	[3:0]	buf_ic_oplen_3;
wire	[3:0]	buf_ic_oplen_4;
wire	[3:0]	buf_ic_oplen_5;
wire	[3:0]	buf_ic_oplen_6;
wire	[3:0]	buf_ic_oplen_7;
wire	[3:0]	buf_ic_oplen_8;
wire	[3:0]	buf_ic_oplen_9;
wire	[3:0]	buf_ic_oplen_10;
wire	[3:0]	buf_ic_oplen_11;
wire	[3:0]	buf_ic_oplen_12;
wire	[3:0]	buf_ic_oplen_13;
wire	[3:0]	buf_ic_oplen_14;
wire	[3:0]	buf_ic_oplen_15;
wire	[31:0]	nxt_pc;
wire	[31:0]	nxt_ibuf_pc;
wire		ibuf_enable;


// The first 7 bytes of data from ibuffer are available for Decode Unit to choose data from

assign ibuf_dout[55:0] = {ibuf_0_out[7:0],ibuf_1_out[7:0],ibuf_2_out[7:0],
                          ibuf_3_out[7:0],ibuf_4_out[7:0],ibuf_5_out[7:0],ibuf_6_out[7:0]};

assign ibuf_oplen[27:0] = {ibuf_0_oplen[3:0],ibuf_1_oplen[3:0],ibuf_2_oplen[3:0],
                          ibuf_3_oplen[3:0],ibuf_4_oplen[3:0],ibuf_5_oplen[3:0],ibuf_6_oplen[3:0]};

ibuf_slice	ibuf_0 (.icache_data(icache_data),
		.icache_data_sel(8'b00000001),
		.shft_data({buf_ic_dout_7,buf_ic_dout_6,buf_ic_dout_5,buf_ic_dout_4,buf_ic_dout_3,buf_ic_dout_2,buf_ic_dout_1}),
		.shft_oplen({buf_ic_oplen_7,buf_ic_oplen_6,buf_ic_oplen_5,buf_ic_oplen_4,buf_ic_oplen_3,buf_ic_oplen_2,buf_ic_oplen_1}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_0_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_0_oplen),
		.buf_ic_sel(buf_ic_sel[0]),
		.buf_ic_dout(buf_ic_dout_0),
		.buf_ic_oplen(buf_ic_oplen_0),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));
		
ibuf_slice	ibuf_1 (.icache_data(icache_data),
		.icache_data_sel({6'b0,ic_sel[0],!ic_sel[0]}),
		.shft_data({buf_ic_dout_8,buf_ic_dout_7,buf_ic_dout_6,buf_ic_dout_5,buf_ic_dout_4,buf_ic_dout_3,buf_ic_dout_2}),
		.shft_oplen({buf_ic_oplen_8,buf_ic_oplen_7,buf_ic_oplen_6,buf_ic_oplen_5,buf_ic_oplen_4,buf_ic_oplen_3,buf_ic_oplen_2}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_1_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_1_oplen),
		.buf_ic_sel(buf_ic_sel[1]),
		.buf_ic_dout(buf_ic_dout_1),
		.buf_ic_oplen(buf_ic_oplen_1),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));
		
ibuf_slice	ibuf_2 (.icache_data(icache_data),
		.icache_data_sel({5'b0,ic_sel[0],ic_sel[1],!(ic_sel[0]|ic_sel[1])}),
		.shft_data({buf_ic_dout_9,buf_ic_dout_8,buf_ic_dout_7,buf_ic_dout_6,buf_ic_dout_5,buf_ic_dout_4,buf_ic_dout_3}),
		.shft_oplen({buf_ic_oplen_9,buf_ic_oplen_8,buf_ic_oplen_7,buf_ic_oplen_6,buf_ic_oplen_5,buf_ic_oplen_4,buf_ic_oplen_3}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_2_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_2_oplen),
		.buf_ic_sel(buf_ic_sel[2]),
		.buf_ic_dout(buf_ic_dout_2),
		.buf_ic_oplen(buf_ic_oplen_2),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));
		
ibuf_slice	ibuf_3 (.icache_data(icache_data),
		.icache_data_sel({4'b0000,ic_sel[0],ic_sel[1],ic_sel[2],!(ic_sel[0]|ic_sel[1]|ic_sel[2])}),
		.shft_data({buf_ic_dout_10,buf_ic_dout_9,buf_ic_dout_8,buf_ic_dout_7,buf_ic_dout_6,buf_ic_dout_5,buf_ic_dout_4}),
		.shft_oplen({buf_ic_oplen_10,buf_ic_oplen_9,buf_ic_oplen_8,buf_ic_oplen_7,buf_ic_oplen_6,buf_ic_oplen_5,buf_ic_oplen_4}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_3_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_3_oplen),
		.buf_ic_sel(buf_ic_sel[3]),
		.buf_ic_dout(buf_ic_dout_3),
		.buf_ic_oplen(buf_ic_oplen_3),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));
		
ibuf_slice	ibuf_4 (.icache_data(icache_data),
		.icache_data_sel({3'b0,ic_sel[0],ic_sel[1],ic_sel[2],ic_sel[3],!(ic_sel[0]|ic_sel[1]|ic_sel[2]|ic_sel[3])}),
		.shft_data({buf_ic_dout_11,buf_ic_dout_10,buf_ic_dout_9,buf_ic_dout_8,buf_ic_dout_7,buf_ic_dout_6,buf_ic_dout_5}),
		.shft_oplen({buf_ic_oplen_11,buf_ic_oplen_10,buf_ic_oplen_9,buf_ic_oplen_8,buf_ic_oplen_7,buf_ic_oplen_6,buf_ic_oplen_5}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_4_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_4_oplen),
		.buf_ic_sel(buf_ic_sel[4]),
		.buf_ic_dout(buf_ic_dout_4),
		.buf_ic_oplen(buf_ic_oplen_4),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

ibuf_slice	ibuf_5 (.icache_data(icache_data),
		.icache_data_sel({2'b0,ic_sel[0],ic_sel[1],ic_sel[2],ic_sel[3],ic_sel[4],!(ic_sel[0]|ic_sel[1]|ic_sel[2]|ic_sel[3]|ic_sel[4])}),
		.shft_data({buf_ic_dout_12,buf_ic_dout_11,buf_ic_dout_10,buf_ic_dout_9,buf_ic_dout_8,buf_ic_dout_7,buf_ic_dout_6}),
		.shft_oplen({buf_ic_oplen_12,buf_ic_oplen_11,buf_ic_oplen_10,buf_ic_oplen_9,buf_ic_oplen_8,buf_ic_oplen_7,buf_ic_oplen_6}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_5_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_5_oplen),
		.buf_ic_sel(buf_ic_sel[5]),
		.buf_ic_dout(buf_ic_dout_5),
		.buf_ic_oplen(buf_ic_oplen_5),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

ibuf_slice	ibuf_6 (.icache_data(icache_data),
		.icache_data_sel({1'b0,ic_sel[0],ic_sel[1],ic_sel[2],ic_sel[3],ic_sel[4],ic_sel[5],!(ic_sel[0]|ic_sel[1]|ic_sel[2]|ic_sel[3]|ic_sel[4]|ic_sel[5])}),
		.shft_data({buf_ic_dout_13,buf_ic_dout_12,buf_ic_dout_11,buf_ic_dout_10,buf_ic_dout_9,buf_ic_dout_8,buf_ic_dout_7}),
		.shft_oplen({buf_ic_oplen_13,buf_ic_oplen_12,buf_ic_oplen_11,buf_ic_oplen_10,buf_ic_oplen_9,buf_ic_oplen_8,buf_ic_oplen_7}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_6_out),
		.encode_oplen(encode_oplen),
	  	.ibuf_oplen(ibuf_6_oplen),	
		.buf_ic_sel(buf_ic_sel[6]),
		.buf_ic_dout(buf_ic_dout_6),
		.buf_ic_oplen(buf_ic_oplen_6),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

wire or_ic_sel_6_0;

multor7 i_ibuf7_or7a (	.in(ic_sel[6:0]),
			.out(or_ic_sel_6_0)
			);

ibuf_slice	ibuf_7 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[0],ic_sel[1],ic_sel[2],ic_sel[3],ic_sel[4],ic_sel[5],ic_sel[6],!or_ic_sel_6_0}),
		.shft_data({buf_ic_dout_14,buf_ic_dout_13,buf_ic_dout_12,buf_ic_dout_11,buf_ic_dout_10,buf_ic_dout_9,buf_ic_dout_8}),
		.shft_oplen({buf_ic_oplen_14,buf_ic_oplen_13,buf_ic_oplen_12,buf_ic_oplen_11,buf_ic_oplen_10,buf_ic_oplen_9,buf_ic_oplen_8}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_7_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_7_oplen),
		.buf_ic_sel(buf_ic_sel[7]),
		.buf_ic_dout(buf_ic_dout_7),
		.buf_ic_oplen(buf_ic_oplen_7),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

wire or_ic_sel_7_1;

multor7 i_ibuf7_or7b (	.in(ic_sel[7:1]),
			.out(or_ic_sel_7_1)
			);

ibuf_slice	ibuf_8 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[1],ic_sel[2],ic_sel[3],ic_sel[4],ic_sel[5],ic_sel[6],ic_sel[7],!or_ic_sel_7_1}),
		.shft_data({buf_ic_dout_15,buf_ic_dout_14,buf_ic_dout_13,buf_ic_dout_12,buf_ic_dout_11,buf_ic_dout_10,buf_ic_dout_9}),
		.shft_oplen({buf_ic_oplen_15,buf_ic_oplen_14,buf_ic_oplen_13,buf_ic_oplen_12,buf_ic_oplen_11,buf_ic_oplen_10,buf_ic_oplen_9}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_8_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_8_oplen),
		.buf_ic_sel(buf_ic_sel[8]),
		.buf_ic_dout(buf_ic_dout_8),
		.buf_ic_oplen(buf_ic_oplen_8),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

wire or_ic_sel_8_2;

multor7 i_ibuf7_or7c (	.in(ic_sel[8:2]),
			.out(or_ic_sel_8_2)
			);

ibuf_slice	ibuf_9 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[2],ic_sel[3],ic_sel[4],ic_sel[5],ic_sel[6],ic_sel[7],ic_sel[8], !or_ic_sel_8_2}),
		.shft_data({8'b0,buf_ic_dout_15,buf_ic_dout_14,buf_ic_dout_13,buf_ic_dout_12,buf_ic_dout_11,buf_ic_dout_10}),
		.shft_oplen({4'b0,buf_ic_oplen_15,buf_ic_oplen_14,buf_ic_oplen_13,buf_ic_oplen_12,buf_ic_oplen_11,buf_ic_oplen_10}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_9_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_9_oplen),
		.buf_ic_sel(buf_ic_sel[9]),
		.buf_ic_dout(buf_ic_dout_9),
		.buf_ic_oplen(buf_ic_oplen_9),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

wire or_ic_sel_9_3;

multor7 i_ibuf7_or7d (	.in(ic_sel[9:3]),
			.out(or_ic_sel_9_3)
			);

ibuf_slice	ibuf_10 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[3],ic_sel[4],ic_sel[5],ic_sel[6],ic_sel[7],ic_sel[8],ic_sel[9], !or_ic_sel_9_3}),
		.shft_data({8'b0,8'b0,buf_ic_dout_15,buf_ic_dout_14,buf_ic_dout_13,buf_ic_dout_12,buf_ic_dout_11}),
		.shft_oplen({4'b0,4'b0,buf_ic_oplen_15,buf_ic_oplen_14,buf_ic_oplen_13,buf_ic_oplen_12,buf_ic_oplen_11}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_10_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_10_oplen),
		.buf_ic_sel(buf_ic_sel[10]),
		.buf_ic_dout(buf_ic_dout_10),
		.buf_ic_oplen(buf_ic_oplen_10),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

wire or_ic_sel_10_4;

multor7 i_ibuf7_or7e (	.in(ic_sel[10:4]),
			.out(or_ic_sel_10_4)
			);

ibuf_slice	ibuf_11 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[4],ic_sel[5],ic_sel[6],ic_sel[7],ic_sel[8],ic_sel[9],ic_sel[10], !or_ic_sel_10_4}),
		.shft_data({8'b0,8'b0,8'b0,buf_ic_dout_15,buf_ic_dout_14,buf_ic_dout_13,buf_ic_dout_12}),
		.shft_oplen({4'b0,4'b0,4'b0,buf_ic_oplen_15,buf_ic_oplen_14,buf_ic_oplen_13,buf_ic_oplen_12}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_11_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_11_oplen),
		.buf_ic_sel(buf_ic_sel[11]),
		.buf_ic_dout(buf_ic_dout_11),
		.buf_ic_oplen(buf_ic_oplen_11),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));
	
wire or_ic_sel_11_5;

multor7 i_ibuf7_or7f (	.in(ic_sel[11:5]),
			.out(or_ic_sel_11_5)
			);

ibuf_slice	ibuf_12 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[5],ic_sel[6],ic_sel[7],ic_sel[8],ic_sel[9],ic_sel[10],ic_sel[11], !or_ic_sel_11_5}),
		.shft_data({8'b0,8'b0,8'b0,8'b0,buf_ic_dout_15,buf_ic_dout_14,buf_ic_dout_13}),
		.shft_oplen({4'b0,4'b0,4'b0,4'b0,buf_ic_oplen_15,buf_ic_oplen_14,buf_ic_oplen_13}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_12_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_12_oplen),
		.buf_ic_sel(buf_ic_sel[12]),
		.buf_ic_dout(buf_ic_dout_12),
		.buf_ic_oplen(buf_ic_oplen_12),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));


ibuf_slice	ibuf_13 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[6],ic_sel[7],ic_sel[8],ic_sel[9],ic_sel[10],ic_sel[11],!(ic_sel[6]|ic_sel[7]|ic_sel[8]|ic_sel[9]|ic_sel[10]|ic_sel[11]),1'b0}),
		.shft_data({8'b0,8'b0,8'b0,8'b0,8'b0,buf_ic_dout_15,buf_ic_dout_14}),
		.shft_oplen({4'b0,4'b0,4'b0,4'b0,4'b0,buf_ic_oplen_15,buf_ic_oplen_14}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_13_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_13_oplen),
		.buf_ic_sel(buf_ic_sel[13]),
		.buf_ic_dout(buf_ic_dout_13),
		.buf_ic_oplen(buf_ic_oplen_13),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

ibuf_slice	ibuf_14 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[7],ic_sel[8],ic_sel[9],ic_sel[10],ic_sel[11],!(ic_sel[7]|ic_sel[8]|ic_sel[9]|ic_sel[10]|ic_sel[11]),2'b0}),
		.shft_data({8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,buf_ic_dout_15}),
		.shft_oplen({4'b0,4'b0,4'b0,4'b0,4'b0,4'b0,buf_ic_oplen_15}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_14_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_14_oplen),
		.buf_ic_sel(buf_ic_sel[14]),
		.buf_ic_dout(buf_ic_dout_14),
		.buf_ic_oplen(buf_ic_oplen_14),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

ibuf_slice	ibuf_15 (.icache_data(icache_data),
		.icache_data_sel({ic_sel[8],ic_sel[9],ic_sel[10],ic_sel[11],!(ic_sel[8]|ic_sel[9]|ic_sel[10]|ic_sel[11]),3'b0}),
		.shft_data({8'b0,8'b0,8'b0,8'b0,8'b0,8'b0,8'b0}),
		.shft_oplen({4'b0,4'b0,4'b0,4'b0,4'b0,4'b0,4'b0}),
		.shft_data_sel(shft_dsel[7:0]),
		.ibuf_en(ibuf_enable),
		.ibuf_dout(ibuf_15_out),
		.encode_oplen(encode_oplen),
		.ibuf_oplen(ibuf_15_oplen),
		.buf_ic_sel(buf_ic_sel[15]),
		.buf_ic_dout(buf_ic_dout_15),
		.buf_ic_oplen(buf_ic_oplen_15),
		.sin(),
		.sm(),
		.so(),
		.clk(clk));

// ibuf_pc will indicate the address of the first byte in the Ibuffer

wire [31:0] jmp_pc_d1; 

mj_s_ff_snr_d_32  jmp_pc_d1_reg (	.out(jmp_pc_d1),
					.din(jmp_pc),
					.reset_l(reset_l),
					.clk(clk)
					);

wire [1:0]  ibuf_pc_sel_d1;
 
mj_s_ff_s_d_2 ibuf_pc_sel_d1_reg (	.out(ibuf_pc_sel_d1),
		                        .din(ibuf_pc_sel),
		                        .clk(clk)
					);


mux2_32	pc_mux  (	.out(nxt_ibuf_pc),
				.in1(jmp_pc_d1),
				.in0(nxt_pc),
				.sel(ibuf_pc_sel_d1[1:0]));

//assign	nxt_pc =  ibuf_pc + encod_dsel;
wire [31:0] ibuf_pc;
cla_adder_32    nxt_pc_adder (	.in1(ibuf_pc),
                              	.in2({8'b0,8'b0,8'b0,5'b00000,encod_dsel}),
                              	.cin(1'b0),
                              	.sum(nxt_pc),
			      	.cout()
				);

mj_s_ff_snr_d_32  pc_flop (	.out(ibuf_pc),
				.din(nxt_ibuf_pc),
				.reset_l(reset_l),
				.clk(clk)
				);

endmodule

/****************************************************************
***	This module defines one slice of 8 byte buffer which will
***	be instantiated in the ibuffer.
****************************************************************/

module ibuf_slice (
	icache_data,
	icache_data_sel,
	shft_data,
        shft_oplen,
	shft_data_sel,
	ibuf_dout,
	encode_oplen,
        ibuf_oplen,
	ibuf_en,
	buf_ic_sel,
	buf_ic_dout,
	buf_ic_oplen,
	clk,
	sin,
	sm,
	so
);

input	[63:0]	icache_data;		// Data from Icache after aligned properly 	-- From Aligner
input	[7:0]	icache_data_sel;	// These selects will determine which of the 	-- From ibuf_ctl
					// eight bytes from icache will be selected	  
input	[55:0]	shft_data;		// Data from the following 7 Buffer locations	-- From ibuf
input	[27:0]	shft_oplen;		// opcode length from the following 7 Buffer locations	-- From ibuf
input   [7:0]   shft_data_sel;		// These selects will determine which of the 	-- From ibuf_ctl
					// following 5 bytes will be selected
output	[7:0]	ibuf_dout;		// Data going out from ibuffer			-- To iu
input   [31:0]  encode_oplen;
input		buf_ic_sel;		// Tells whether the current Ibuffer entry os valid or not
output	[3:0]	ibuf_oplen;		// opcode length going out from ibuffer		-- To iu
output	[7:0]	buf_ic_dout;		// Curent ibuffer or icache data out
output  [3:0]	buf_ic_oplen;		// Current Ibuffer or icache opcode lengths
input		clk;			// Clk
input		sin;			// Scan data input
input		sm;			// Scan Enable input
output		so;			// Scan data output
input		ibuf_en;		// ibuffer clock enable


wire	[7:0] 	icache_mux_out;
wire 	[7:0]	ic_fill_mux_out;
wire    [3:0]   oplen_mux_out;
wire    [3:0]   oplen_fill_mux_out;



//  This mux will determine which of the 8 bytes coming from Aligner(Icache)
//  is choosen to reside in this particular ibuffer location

mux8_8 i_ic_mux (	.out(icache_mux_out),
                        .in7(icache_data[7:0]),
                        .in6(icache_data[15:8]),
                        .in5(icache_data[23:16]),
                        .in4(icache_data[31:24]),
                        .in3(icache_data[39:32]),
                        .in2(icache_data[47:40]),
                        .in1(icache_data[55:48]),
                        .in0(icache_data[63:56]),
                        .sel(icache_data_sel));

//  This mux will determine which of the 8 4-bit lengths coming from 
// len dec.s is choosen to reside in this particular ibuffer location

mux8_4 i_oplen_mux (       .out(oplen_mux_out),
                           .in7(encode_oplen[3:0]),
                           .in6(encode_oplen[7:4]),
                           .in5(encode_oplen[11:8]),
                           .in4(encode_oplen[15:12]),
                           .in3(encode_oplen[19:16]),
                           .in2(encode_oplen[23:20]),
                           .in1(encode_oplen[27:24]),
                           .in0(encode_oplen[31:28]),
                           .sel(icache_data_sel));


// This mux will determine whether the data from current ibuffer or icache 
// data is selected

mux2_8 ic_fill_mux (	.out(buf_ic_dout),
                        	.sel({buf_ic_sel,!buf_ic_sel}),
	                        .in0({icache_mux_out}),
	                        .in1({ibuf_dout})
	                        );

mux2_4 i_oplen_fill_mux (	.out(buf_ic_oplen),
                        	.sel({buf_ic_sel,!buf_ic_sel}),
                        	.in0({oplen_mux_out}),
                        	.in1({ibuf_oplen})
                        	);

// select the appr. data out and oplen
mux8_8 i_shft_mux (	.out(ic_fill_mux_out),
	                        .in7(shft_data[55:48]),
	                        .in6(shft_data[47:40]),
	                        .in5(shft_data[39:32]),
	                        .in4(shft_data[31:24]),
	                        .in3(shft_data[23:16]),
	                        .in2(shft_data[15:8]),
	                        .in1(shft_data[7:0]),
	                        .in0(buf_ic_dout),
	                        .sel(shft_data_sel));

mux8_4 i_shft_oplen_mux (  .out(oplen_fill_mux_out),
                                .in7(shft_oplen[27:24]),
                                .in6(shft_oplen[23:20]),
                                .in5(shft_oplen[19:16]),
                                .in4(shft_oplen[15:12]),
                                .in3(shft_oplen[11:8]),
                                .in2(shft_oplen[7:4]),
                                .in1(shft_oplen[3:0]),
                                .in0(buf_ic_oplen),
                                .sel(shft_data_sel));
//  Ibuffer flop

mj_s_ff_se_d_8 ibuf_data_flop (	.out(ibuf_dout),
				.din(ic_fill_mux_out),
				.lenable(ibuf_en),
				.clk(clk)
				);

mj_s_ff_se_d_4 ibuf_len_flop (	.out(ibuf_oplen),
				.din(oplen_fill_mux_out),
				.lenable(ibuf_en),
				.clk(clk)
				);
endmodule

