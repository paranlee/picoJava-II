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

module main_dec (

	ibuff_0,
	ibuff_1,
	ibuff_2,
	ibuff_3,
	ibuff_4,
	ibuff_5,
	ibuff_6,
	fetch_valid,
	accum_len0,
	accum_len1,
	accum_len2,
	offset_rsd_ctl,
	offset_sel_rs1,
	valid_rs1,
	mem_op,
	help_rs1,
	type,
	lv_rs1,
	lvars_acc_rs1,
	st_index_op_rs1,
	update_optop,
	offset_sel_rs2,
	lv_rs2,
	lvars_acc_rs2,
	reverse_ops_rs1,
	offset_sel_rsd
);

input	[7:0]	ibuff_0;
input	[7:0]	ibuff_1;
input	[7:0]	ibuff_2;
input	[7:0]	ibuff_3;
input	[7:0]	ibuff_4;
input	[7:0]	ibuff_5;
input	[7:0]	ibuff_6;
input	[6:0]	fetch_valid;
input	[7:0]	accum_len0;
input	[7:0]	accum_len1;
input	[7:0]	accum_len2;
input	[3:0]	offset_rsd_ctl;  
output	[4:0]	offset_sel_rs1;
output		valid_rs1;
output		mem_op;
output		help_rs1;
output	[7:0]	type;
output		lv_rs1;
output		st_index_op_rs1;
output		update_optop;
output	[4:0]	offset_sel_rs2;
output		lv_rs2;
output		lvars_acc_rs1;
output		lvars_acc_rs2;
output		reverse_ops_rs1;
output	[4:0]	offset_sel_rsd;


wire	[4:0]	offset_sel_rs2_len1;
wire	[4:0]	offset_sel_rs2_len2;
wire	[4:0]	offset_sel_rs2_len3;
wire	[4:0]	offset_sel_rsd_by0;
wire	[4:0]	offset_sel_rsd_by1;
wire	[4:0]	offset_sel_rsd_by2;
wire	[4:0]	offset_sel_rsd_by3;
wire	[4:0]	offset_sel_rsd_by4;
wire	[4:0]	offset_sel_rsd_by5;
wire	[4:0]	offset_sel_rsd_by6;
wire	[4:0]	offset_sel_rsd_inst1;
wire	[4:0]	offset_sel_rsd_inst2;
wire	[4:0]	offset_sel_rsd_inst3;
wire		lv_rs2_len1;
wire		lv_rs2_len2;
wire		lv_rs2_len3;
wire		lvars_acc_rs2_len1;
wire		lvars_acc_rs2_len2;
wire		lvars_acc_rs2_len3;

rs1_dec	rs1_dec(.opcode({ibuff_0,ibuff_1}),
		.valid(fetch_valid[2:0]),
		.valid_rs1(valid_rs1),
		.offset_sel_rs1(offset_sel_rs1),
		.mem_op(mem_op),
		.help_rs1(help_rs1),
		.type(type),
		.lv_rs1(lv_rs1),
		.st_index_op(st_index_op_rs1),
		.update_optop(update_optop),
		.reverse_ops(reverse_ops_rs1),
		.lvars_acc_rs1(lvars_acc_rs1) );

rs2_dec	rs2_dec_len1(.opcode({ibuff_1,ibuff_2}),
			.valid(fetch_valid[3:1]),
			.lv_rs2(lv_rs2_len1),
			.lvars_acc_rs2(lvars_acc_rs2_len1),
			.offset_sel_rs2(offset_sel_rs2_len1) );
	
rs2_dec	rs2_dec_len2(.opcode({ibuff_2,ibuff_3}),
			.valid(fetch_valid[4:2]),
			.lv_rs2(lv_rs2_len2),
			.lvars_acc_rs2(lvars_acc_rs2_len2),
			.offset_sel_rs2(offset_sel_rs2_len2) );
	
rs2_dec	rs2_dec_len3(.opcode({ibuff_3,ibuff_4}),
			.valid(fetch_valid[5:3]),
			.lv_rs2(lv_rs2_len3),
			.lvars_acc_rs2(lvars_acc_rs2_len3),
			.offset_sel_rs2(offset_sel_rs2_len3) );

mux4_5	mux_offset_rs2(.out(offset_sel_rs2),
			.in0(5'b00001),
			.in1(offset_sel_rs2_len1),
			.in2(offset_sel_rs2_len2),
			.in3(offset_sel_rs2_len3),
			.sel(accum_len0[3:0]) );

mux4	mux_lv_rs2 (.out(lv_rs2),
			.in0(1'b0),
			.in1(lv_rs2_len1),
			.in2(lv_rs2_len2),
			.in3(lv_rs2_len3),
			.sel(accum_len0[3:0]) );

mux4	mux_lv_acc_rs2 (.out(lvars_acc_rs2),
			.in0(1'b0),
			.in1(lvars_acc_rs2_len1),
			.in2(lvars_acc_rs2_len2),
			.in3(lvars_acc_rs2_len3),
			.sel(accum_len0[3:0]) );


rsd_dec	rsd_dec_byte0(.opcode(ibuff_0),
			.valid(fetch_valid[2:0]),
			.offset_sel_rsd(offset_sel_rsd_by0) );
			
rsd_dec	rsd_dec_byte1(.opcode(ibuff_1),
			.valid(fetch_valid[3:1]),
			.offset_sel_rsd(offset_sel_rsd_by1) );
			
rsd_dec	rsd_dec_byte2(.opcode(ibuff_2),
			.valid(fetch_valid[4:2]),
			.offset_sel_rsd(offset_sel_rsd_by2) );
			
rsd_dec	rsd_dec_byte3(.opcode(ibuff_3),
			.valid(fetch_valid[5:3]),
			.offset_sel_rsd(offset_sel_rsd_by3) );
			
rsd_dec	rsd_dec_byte4(.opcode(ibuff_4),
			.valid(fetch_valid[6:4]),
			.offset_sel_rsd(offset_sel_rsd_by4) );
			
rsd_dec	rsd_dec_byte5(.opcode(ibuff_5),
			.valid({1'b0,fetch_valid[6:5]}),
			.offset_sel_rsd(offset_sel_rsd_by5) );
			
rsd_dec	rsd_dec_byte6(.opcode(ibuff_6),
			.valid({2'b0,fetch_valid[6]}),
			.offset_sel_rsd(offset_sel_rsd_by6) );

mux4_5	mux_rsd_inst1(.out(offset_sel_rsd_inst1),
			.in0(5'b00001),
			.in1(offset_sel_rsd_by1),
			.in2(offset_sel_rsd_by2),
			.in3(offset_sel_rsd_by3),
			.sel(accum_len0[3:0]) ) ;
		
mux8_5	mux_rsd_inst2(.out(offset_sel_rsd_inst2),
			.in0(5'b00001),
			.in1(offset_sel_rsd_by1),
			.in2(offset_sel_rsd_by2),
			.in3(offset_sel_rsd_by3),
			.in4(offset_sel_rsd_by4),
			.in5(offset_sel_rsd_by5),
			.in6(offset_sel_rsd_by6),
			.in7(5'b00001),
			.sel(accum_len1) ) ;
		
mux8_5	mux_rsd_inst3(.out(offset_sel_rsd_inst3),
			.in0(5'b00001),
			.in1(offset_sel_rsd_by1),
			.in2(offset_sel_rsd_by2),
			.in3(offset_sel_rsd_by3),
			.in4(offset_sel_rsd_by4),
			.in5(offset_sel_rsd_by5),
			.in6(offset_sel_rsd_by6),
			.in7(5'b00001),
			.sel(accum_len2) ) ;

mux4_5	mux_offset_rsd(.out(offset_sel_rsd),
			.in0(offset_sel_rsd_by0),
			.in1(offset_sel_rsd_inst1),
			.in2(offset_sel_rsd_inst2),
			.in3(offset_sel_rsd_inst3),
			.sel(offset_rsd_ctl) );
		
			
endmodule
