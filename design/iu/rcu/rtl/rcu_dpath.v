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

module rcu_dpath (

	iu_sc_bottom,
	iu_optop_e,
	iu_lvars,
	ucode_addr_s,
	ucode_areg0,
	ex_adder_out_e,
	offset_1_rs1_r,
	offset_2_rs1_r,
	offset_1_rs2_r,
	offset_2_rs2_r,
	gl_sel_rs1,
	const_sel_1_rs1,
	const_sel_2_rs1,
	const_gl_sel_rs1,
	scache_addr_sel_rs1,
	final_data_sel_rs1,
	gl_sel_rs2,
	const_sel_1_rs2,
        const_sel_2_rs2,
        const_gl_sel_rs2,
        scache_addr_sel_rs2,
        final_data_sel_rs2,
	offset_rsd_r,
	optop_incr_sel,
	dest_addr_sel_r,
	dest_addr_sel_e,
	optop_offset_sel_r,
	net_optop_sel1,
	net_optop_sel2,
	net_optop_sel,
	gl_reg0_we_w,
	gl_reg1_we_w,
	gl_reg2_we_w,
	gl_reg3_we_w,
	hold_ucode,
	hold_e,
	hold_c,
	iu_data_w,
	iu_data_we_w,
	smu_data,
	smu_rf_addr,
	smu_we,
	enable_cmp_e_rs1,
	enable_cmp_c_rs1,
	enable_cmp_w_rs1,
	enable_cmp_e_rs2,
	enable_cmp_c_rs2,
	enable_cmp_w_rs2,
	scache_wr_miss_w,
	sin,
	sm,
	clk,
	iu_smu_data,
	rs1_data_e,
	rs2_data_e,
	sc_miss_rs1_int,
	sc_miss_rs2_int,
	optop_offset,
	scache_miss_addr_e,
	bypass_scache_rs1_e,
	bypass_scache_rs1_c,
	bypass_scache_rs1_w,
	bypass_scache_rs2_e,
	bypass_scache_rs2_c,
	bypass_scache_rs2_w,
	sc_wr_addr_gr_scbot,
	dest_addr_w,
	iu_smu_flush_le,
	iu_smu_flush_ge,
	so
);

input	[31:0]	iu_sc_bottom;		// sc bottom from e-stage
input	[31:0]	iu_optop_e;		// optop from e-stage
input	[31:0]	iu_lvars;		// local var. reg
input	[31:0]	ucode_addr_s;		// ucode address to access stack cache
input	[31:0]	ucode_areg0;		// ucode areg data to be used as dest addr
input	[31:0]	ex_adder_out_e;		// ex adder out to be used as dest addr
input	[7:0]	offset_1_rs1_r;		// 1st byte of offset in RS1 stage
input	[7:0]	offset_2_rs1_r;		// 2nd byte of offset in RS1 stage
input	[7:0]	offset_1_rs2_r;		// 1st byte of offset in RS2 stage
input	[7:0]	offset_2_rs2_r;		// 2nd byte of offset in RS2 stage
input	[3:0]	gl_sel_rs1;		// ctrl signal for selecting one of the gl regs
input	[5:0]	const_sel_1_rs1;	// following two ctrl signals are used for
input	[6:0]	const_sel_2_rs1;	// for selecting constants or imm. offset
input	[2:0]	const_gl_sel_rs1;	// ctrl signal to slect one of globals or constants
input	[4:0]	scache_addr_sel_rs1;	// ctrl signal to determine what address is used for
					// accessing scache
input	[1:0]	final_data_sel_rs1;	// ctrl signal to determine whether we select data 
					// from scache or from globals/constants as the final
					// rs1_data_e
input	[3:0]	gl_sel_rs2;		// ctrl signal for selecting one of the gl regs
input	[5:0]	const_sel_1_rs2;	// following two ctrl signals are used for
input	[6:0]	const_sel_2_rs2;	// for selecting constants or imm. offset
input	[2:0]	const_gl_sel_rs2;	// ctrl signal to slect one of globals or constants
input	[4:0]	scache_addr_sel_rs2;	// ctrl signal to determine what address is used for
					// accessing scache
input	[1:0]	final_data_sel_rs2;	// ctrl signal to determine whether we select data 
					// from scache or from globals/constants 
					// as the final rs2_data_e
input	[7:0]	offset_rsd_r;		// offset in RSd stage
input	[7:0]	optop_incr_sel;		// This will select the appr. net optop as the dest. addr
input	[2:0]	dest_addr_sel_r;	// Selects the appropriate destination address in r
input	[2:0]	dest_addr_sel_e;	// Selects the appropriate destination address in e
input	[4:0]	net_optop_sel1;		// The following three signals are used to select appr.
input	[3:0]	net_optop_sel2;		// optop 
input	[1:0]	net_optop_sel;
input	[5:0]	optop_offset_sel_r;	// Selects the appropriate inc/dec in optop
input		gl_reg0_we_w;		// Global Reg0 write enable
input		gl_reg1_we_w;		// Global Reg1 write enable
input		gl_reg2_we_w;		// Global Reg2 write enable
input		gl_reg3_we_w;		// Global Reg3 write enable
input		hold_ucode;		// Ucode hold
input		hold_e;			// Signal from pipeline control which holds e-stage
input		hold_c;			// Signal from pipeline control which holds c-stage
input	[31:0]	iu_data_w;		// Data to be written onto scache
input		iu_data_we_w;		// Corresponding write enable signal
input	[31:0]	smu_data;		// Data from dribbler to be written onto scache
input	[5:0]	smu_rf_addr;		// dribbler address to scache
input		smu_we;			// scache write enable signal from dribbler
input		enable_cmp_e_rs1;	// Only incase of writes to dest, "d" and read to loc. "d" in e,
					// we should enable the bypassing comparison in e for RS1
input		enable_cmp_c_rs1;	// Only incase of writes to dest, "d" and read to loc. "d" in e,
					// we should enable the bypassing comparison in c for RS1
input		enable_cmp_w_rs1;	// Only incase of writes to dest, "d" and read to loc. "d" in e,
					// we should enable the bypassing comparison in w for RS1
input		enable_cmp_e_rs2;	// Only incase of writes to dest, "d" and read to loc. "d" in e,
					// we should enable the bypassing comparison in e for RS2
input		enable_cmp_c_rs2;	// Only incase of writes to dest, "d" and read to loc. "d" in e,
					// we should enable the bypassing comparison in c for RS2
input		enable_cmp_w_rs2;	// Only incase of writes to dest, "d" and read to loc. "d" in e,
					// we should enable the bypassing comparison in w for RS2
input          	scache_wr_miss_w;       // Indicates that there's a scache write miss
input		sin;			// RCU DataPath Scacn In port
input		sm;			// RCU DataPath Scacn Enable port
input		clk;			// Clock
output	[31:0]	iu_smu_data;		// Data output from scache to dribbler
output	[31:0]	rs1_data_e;		// Data output from RS1 stage
output	[31:0]	rs2_data_e;		// Data output from RS2 stage
output		sc_miss_rs1_int;	// Compare out put of scache_addr_rs1 and stack_bottom
output		sc_miss_rs2_int;	// Compare out put of scache_addr_rs2 and stack_bottom
output	[31:0]	optop_offset;		// Indicates optop +/- net change
output	[31:0]	scache_miss_addr_e;	// Used to access dcache in case of scache read miss
output		bypass_scache_rs1_e;	// Bypass data from e-stage to rs1 stage
output		bypass_scache_rs1_c;	// Bypass data from c-stage to rs1 stage
output		bypass_scache_rs1_w;	// Bypass data from w-stage to rs1 stage
output		bypass_scache_rs2_e;	// Bypass data from e-stage to rs2 stage
output		bypass_scache_rs2_c;	// Bypass data from c-stage to rs2 stage
output		bypass_scache_rs2_w;	// Bypass data from w-stage to rs2 stage
output		sc_wr_addr_gr_scbot;	// Indicates that scache write address is greater than sc_bot
output [31:0]	dest_addr_w;		// Indicates the address of scache write miss	
output		iu_smu_flush_le;	// Indicates that scache write address is less than or eq to sc_bot+8
output		iu_smu_flush_ge;	// Indicates that scache write address is gr than or eq to sc_bot-8
output		so;			// RCU DataPath Scan Out Port

wire	[5:0]	optop_inc1;
wire	[5:0]	optop_inc2;
wire	[5:0]	optop_inc3;
wire	[5:0]	optop_inc4;
wire	[7:0]	iu_addr_w;
wire	[31:0]	lvars_minus_offset_rs1;
wire	[31:0]	lvars_minus_offset_rs2;
wire	[31:0]	lvars_offset_int;
wire	[31:0]	lvars_offset_sec_cyc;
wire	[31:0]	scache_addr_rs1;
wire	[31:0]	scache_addr_rs2;
wire	[31:0]	gl_out_rs1;
wire	[31:0]	gl_out_rs2;
wire	[31:0]	gl_reg0;
wire	[31:0]	gl_reg1;
wire	[31:0]	gl_reg2;
wire	[31:0]	gl_reg3;
wire	[31:0]	const_1_rs1;
wire	[31:0]	const_2_rs1;
wire	[31:0]	const_1_rs2;
wire	[31:0]	const_2_rs2;
wire	[31:0]	const_final_rs1;
wire	[31:0]	const_final_rs2;
wire	[31:0]	rs1_data;
wire	[31:0]	rs2_data;
wire	[31:0]	scache_dout_rs1;
wire	[31:0]	scache_dout_rs2;
wire	[31:0]	optop_addr;
wire	[31:0]	lvars_minus_offset_rsd;
wire	[31:0]	lvars_offset_int_rsd;
wire	[31:0]	lvars_offset_sec_cyc_rsd;
wire	[31:0]	dest_addr_r;
wire	[31:0]	optop_inc1_32;
wire	[31:0]	optop_inc2_32;
wire	[31:0]	optop_inc3_32;
wire	[31:0]	optop_inc4_32;
wire	[31:0]	optop_dec1_32;
wire	[31:0]	optop_dec2_32;
wire	[31:0]	optop_dec3_32;
wire	[31:0]	optop_dec4_32;
wire	[31:0]	dest_addr_e;
wire	[31:0]	dest_addr_c;
wire	[31:0]	bypass_scache_addr_rs1;
wire	[31:0]	bypass_scache_addr_rs2;
wire	[31:0]	dest_addr_e_int;
wire	[31:0]	sc_bot_p12;
wire	[31:0]	sc_bot_m12;
wire	[31:0]	optop_int1;
wire	[31:0]	optop_int2;
wire	[31:0]	optop_op;
wire		un_used1;
wire		un_used2;
wire		un_used3;
wire		un_used4;
wire		un_used5;
wire		un_used6;
wire		un_used8;
wire		un_used9;
wire		un_used10;
wire		un_used12;
wire		un_used13;
wire		un_used14;
wire		un_used16;
wire		un_used17;
wire		un_used18;
wire		un_used19;
wire		un_used20;
wire		un_used22;
wire		un_used23;
wire		un_used24;
wire		un_used26;
wire		un_used27;
wire		un_used28;
wire		un_used29;
wire		un_used30;
wire		un_used31;
wire		un_used32;
wire		un_used33;
wire		un_used34;
wire		un_used35;
wire		un_used36;
wire		un_used37;
wire		un_used38;
wire		un_used39;
wire		un_used40;

// Use 6-bit adder to generate optop+1: We need just a 6 bit
// adder to access scache
cla_adder_6	add_optop_inc1(.in1(iu_optop_e[7:2]),
				.in2(6'b000001),
				.cin(1'b0),
				.sum(optop_inc1[5:0]),
				.cout(un_used1) );
// We need a 32-bit adder though for determining the bypass ctrl
// signals 
inc32		inc_optop_1(.ai({2'b0,iu_optop_e[31:2]}),
			.sum({un_used9,un_used10,optop_inc1_32[31:2]}));
assign	optop_inc1_32[1:0] = iu_optop_e[1:0];
			

// Use 6-bit adder to generate optop+2
cla_adder_6	add_optop_inc2(.in1(iu_optop_e[7:2]),
				.in2(6'b000010),
				.cin(1'b0),
				.sum(optop_inc2[5:0]),
				.cout(un_used2) );

inc32		inc_optop_2(.ai({3'b0,iu_optop_e[31:3]}),
			.sum({un_used12,un_used13,un_used14,
				optop_inc2_32[31:3]}));
assign	optop_inc2_32[2:0] = iu_optop_e[2:0];

// Use 6-bit adder to generate optop+3
cla_adder_6	add_optop_inc3(.in1(iu_optop_e[7:2]),
				.in2(6'b000011),
				.cin(1'b0),
				.sum(optop_inc3[5:0]),
				.cout(un_used3) );

cla_adder_32		add_optop_3(.in1(iu_optop_e[31:0]),
				.in2(32'd12),
				.cin(1'b0),
				.sum(optop_inc3_32[31:0]),
				.cout(un_used16) );

// Use 6-bit adder to generate optop+4
cla_adder_6	add_optop_inc4(.in1(iu_optop_e[7:2]),
				.in2(6'b000100),
				.cin(1'b0),
				.sum(optop_inc4[5:0]),
				.cout(un_used4) );

inc32		inc_optop_4(.ai({4'b0,iu_optop_e[31:4]}),
			.sum({un_used17,un_used18,un_used19,
			      un_used20,optop_inc4_32[31:4]}));
assign	optop_inc4_32[3:0] = iu_optop_e[3:0];

//***** BEGIN:  RS1 section the data path *******// 

// Subtract offset from lvars to generate lvars - offset

cla_adder_32	sub_lvars_offset_rs1(.in1(iu_lvars),
				.in2({22'h3fffff,(~offset_1_rs1_r[7:0]),2'h3}),
				.cin(1'b1),
				.sum(lvars_minus_offset_rs1),
				.cout(un_used5) );

// We need to generate lvars - offset - 4 in the second cycle
// of long and double loads for accessing scache

dec_32		dec_lvars_sec_cyc(.out(lvars_offset_int),
				.in({2'b0,lvars_minus_offset_rs1[31:2]}) );

ff_se_32	flop_lvars_sec_cyc(.out(lvars_offset_sec_cyc),
				.din({lvars_offset_int[29:0],2'b00}),
				.clk(clk),
				.enable(!hold_e) );

// Select the address to access stack cache

mux5_32		mux_scache_addr_rs1(.out(scache_addr_rs1),
				.in0({24'b0,optop_inc1,2'b00}),
				.in1({24'b0,optop_inc2,2'b00}),
				.in2(ucode_addr_s),
				.in3(lvars_minus_offset_rs1),
				.in4(lvars_offset_sec_cyc),
				.sel(scache_addr_sel_rs1) );

// Generate a full 32 bit address for bypass purposes since
// scache address uses optop_increments computed by 6bit adders
// and not the ones done by 32 bit adders due to timing reasons
// Also use this full 32 bit address to access dcache in case
// of stack cache read miss


mux5_32		mux_bypass_scache_addr_rs1(.out(bypass_scache_addr_rs1),
				.in0(optop_inc1_32),
				.in1(optop_inc2_32),
				.in2(ucode_addr_s),
				.in3(lvars_minus_offset_rs1),
				.in4(lvars_offset_sec_cyc),
				.sel(scache_addr_sel_rs1) );

// Bypass logic for stack operands in RS1
// Qualify the comparision with
// . (ucode_active | lv_acc_rs1) -> This means the address scache_addr_rs1
//                                  is a valid one and
// . iu_data_we                 -> This means dest_addr_e used is a valid one
 
cmp_we_32       comp_bypass_scache_rs1_e(.out(bypass_scache_rs1_e),
                                        .in1(bypass_scache_addr_rs1),
                                        .in2(dest_addr_e),
                                        .enable(enable_cmp_e_rs1) );

cmp_we_32       comp_bypass_scache_rs1_c(.out(bypass_scache_rs1_c),
                                        .in1(bypass_scache_addr_rs1),
                                        .in2(dest_addr_c),
                                        .enable(enable_cmp_c_rs1) );
 
cmp_we_32       comp_bypass_scache_rs1_w(.out(bypass_scache_rs1_w),
                                        .in1(bypass_scache_addr_rs1),
                                        .in2(dest_addr_w),
                                        .enable(enable_cmp_w_rs1) );



// Incase of scache read miss, we need to use this address to access d$

// If there are any back-> back ucode scache misses, then the old scache
// miss address will be overwritten.  That's why we are using hold_ucode,
// instead of hold_e & !ucode_active
ff_se_32		flop_scache_miss_addr(.out(scache_miss_addr_e),
					.din(bypass_scache_addr_rs1),
					.clk(clk),
					//.enable(!(hold_e & !ucode_active)));
					.enable(!hold_ucode) );

// Select appropriate Global Register File to read

mux4_32		mux_gl_rs1(.out(gl_out_rs1),
			.in0(gl_reg0),
			.in1(gl_reg1),
			.in2(gl_reg2),
			.in3(gl_reg3),
			.sel(gl_sel_rs1) );

// Select the appropriate constant or offset

mux6_32		mux_const_1_rs1(.out(const_1_rs1),
				.in0(32'hffffffff),
				.in1(32'h00000000),
				.in2(32'h00000001),
				.in3(32'h00000002),
				.in4(32'h00000003),
				.in5(32'h00000004),
				.sel(const_sel_1_rs1) );

mux7_32		mux_const_2_rs1(.out(const_2_rs1),
				.in0(32'h00000005),
				.in1(32'h00000000),
				.in2(32'h3f800000), // FP 1.0
				.in3(32'h3ff00000), // Double 1.0
				.in4(32'h40000000), // FP 2.0
				.in5({{24{offset_1_rs1_r[7]}},offset_1_rs1_r}),
				.in6({{16{offset_1_rs1_r[7]}},offset_1_rs1_r,offset_2_rs1_r}),
				.sel(const_sel_2_rs1) );

mux3_32		mux_const_final_rs1(.out(const_final_rs1),
				.in0(gl_out_rs1),
				.in1(const_1_rs1),
				.in2(const_2_rs1),
				.sel(const_gl_sel_rs1) );

// Select the final data to be output from  RS1 stage

mux2_32		mux_final_data_rs1(.out(rs1_data),
				.in0(const_final_rs1),
				.in1(scache_dout_rs1),
				.sel(final_data_sel_rs1) );

// Donot hold the data in R-stage for RS1  when ucode is active as it
// will use RS1 to access scache; Removing hold since we are removing
// hold from bypass select signals in rcu_ctl. All the holds for data
// and control are taken care off in e-stage???
ff_s_32		flop_rs1_data(.out(rs1_data_e),
				.din(rs1_data),
				.clk(clk));


// Comparator for determining scache hits in RS1
 
comp_gr_32      comp_scache_hit_rs1(.gr(sc_miss_rs1_int),
                                .in1(scache_addr_rs1),
                                .in2(iu_sc_bottom) );

//***** END:  RS1 section the data path *******// 

//***** BEGIN:  RS2 section the data path *******// 

// Subtract offset from lvars to generate lvars - offset
 
cla_adder_32    sub_lvars_offset_rs2(.in1(iu_lvars),
                                .in2({22'h3fffff,(~offset_1_rs2_r[7:0]),2'h3}),
                                .cin(1'b1),
                                .sum(lvars_minus_offset_rs2),
                                .cout(un_used6) );

// Select the address to access stack cache
 
mux5_32         mux_scache_addr_rs2(.out(scache_addr_rs2),
                                .in0({24'b0,optop_inc2,2'b00}),
                                .in1({24'b0,optop_inc1,2'b00}),
                                .in2({24'b0,optop_inc3,2'b00}),
                                .in3({24'b0,optop_inc4,2'b00}),
                                .in4(lvars_minus_offset_rs2),
                                .sel(scache_addr_sel_rs2) );

// Generate a full 32 bit address for bypass purposes since
// scache address uses optop_increments computed by 6bit adders
// and not the ones done by 32 bit adders due to timing reasons

mux5_32         mux_bypass_scache_addr_rs2(.out(bypass_scache_addr_rs2),
                                .in0(optop_inc2_32),
                                .in1(optop_inc1_32),
                                .in2(optop_inc3_32),
                                .in3(optop_inc4_32),
                                .in4(lvars_minus_offset_rs2),
                                .sel(scache_addr_sel_rs2) );

// Bypass logic for stack operands in RS2
// Qualify the comparision with
// . lv_acc_rs2 -> This means the address scache_addr_rs2
//                                  is a valid one and
// . iu_data_we                 -> This means dest_addr_e used is a valid one
 
cmp_we_32       comp_bypass_scache_rs2_e(.out(bypass_scache_rs2_e),
                                        .in1(bypass_scache_addr_rs2),
                                        .in2(dest_addr_e),
                                        .enable(enable_cmp_e_rs2) );
 
cmp_we_32       comp_bypass_scache_rs2_c(.out(bypass_scache_rs2_c),
                                        .in1(bypass_scache_addr_rs2),
                                        .in2(dest_addr_c),
                                        .enable(enable_cmp_c_rs2) );
 
cmp_we_32       comp_bypass_scache_rs2_w(.out(bypass_scache_rs2_w),
                                        .in1(bypass_scache_addr_rs2),
                                        .in2(dest_addr_w),
                                        .enable(enable_cmp_w_rs2) );
 

// Select appropriate Global Register File to read
 
mux4_32         mux_gl_rs2(.out(gl_out_rs2),
                        .in0(gl_reg0),
                        .in1(gl_reg1),
                        .in2(gl_reg2),
                        .in3(gl_reg3),
                        .sel(gl_sel_rs2) );
 
// Select the appropriate constant or offset
 
mux6_32         mux_const_1_rs2(.out(const_1_rs2),
                                .in0(32'hffffffff),
                                .in1(32'h00000000),
                                .in2(32'h00000001),
                                .in3(32'h00000002),
                                .in4(32'h00000003),
                                .in5(32'h00000004),
                                .sel(const_sel_1_rs2) );
 
mux7_32         mux_const_2_rs2(.out(const_2_rs2),
                                .in0(32'h00000005),
                                .in1(32'h00000000),
                                .in2(32'h3f800000), // FP 1.0
                                .in3(32'h40000000), // FP 2.0
				.in4({{24{offset_1_rs2_r[7]}},offset_1_rs2_r}),
				.in5({{16{offset_1_rs2_r[7]}},offset_1_rs2_r,offset_2_rs2_r}),
				.in6({{24{offset_2_rs1_r[7]}},offset_2_rs1_r}),
                                .sel(const_sel_2_rs2) );
 
mux3_32         mux_const_final_rs2(.out(const_final_rs2),
                                .in0(gl_out_rs2),
                                .in1(const_1_rs2),
                                .in2(const_2_rs2),
                                .sel(const_gl_sel_rs2) );
 
// Select the final data to be output from  RS1 stage
 
mux2_32         mux_final_data_rs2(.out(rs2_data),
                                .in0(const_final_rs2),
				.in1(scache_dout_rs2),
                                .sel(final_data_sel_rs2) );
 
// We are not holding the data in R-stage; But the the actual hold
// happens in the e-stage
ff_s_32        flop_rs2_data(.out(rs2_data_e),
                                .din(rs2_data),
                                .clk(clk));
 
// Comparator for determining scache hits in RS2
 
comp_gr_32      comp_scache_hit_rs2(.gr(sc_miss_rs2_int),
                                .in1(scache_addr_rs2),
                                .in2(iu_sc_bottom) );
 

 
//***** END:  RS2 section the data path *******//

// Note: for iu_data_we_w we "and" it with !scache_wr_miss_w.
// This is because whenever there's a scache write miss, it is
// handled by SMU and there should n't be any write enable to scache

// Instantiate Register File for Scache

rf	scache(.do_a(scache_dout_rs1),
		.do_b(scache_dout_rs2),
		.do_c(iu_smu_data),
		.di_d(iu_data_w),
		.di_e(smu_data),
		.add_a(scache_addr_rs1[7:2]),
		.add_b(scache_addr_rs2[7:2]),
		.add_c(smu_rf_addr[5:0]),
		.add_d(iu_addr_w[7:2]),
		.add_e(smu_rf_addr[5:0]),
		.we_d(((iu_data_we_w & !scache_wr_miss_w) & ~clk)),
		.we_e(smu_we & ~clk) );

//***** BEGIN:  RSd section the data path *******// 

// Generate optop_dec1, optop_dec2 and optop_dec3 to help in dest addr.
// calculation

dec_32	dec_optop_1(.out({un_used31,un_used32,optop_dec1_32[31:2]}),
			.in({2'b0,iu_optop_e[31:2]}) );
assign	optop_dec1_32[1:0] = iu_optop_e[1:0];

dec_32	dec_optop_2(.out({un_used33,un_used34,un_used35,optop_dec2_32[31:3]}),
			.in({3'b0,iu_optop_e[31:3]}) );
assign	optop_dec2_32[2:0] = iu_optop_e[2:0];

cla_adder_32	dec_optop_3(.sum(optop_dec3_32[31:0]),
				.in1(iu_optop_e),
				.in2(32'hfffffff3),
				.cin(1'b1),
				.cout(un_used36) );
dec_32	dec_optop_4(.out({un_used37,un_used38,un_used39,un_used40,		
					optop_dec4_32[31:4]}),
			.in({4'b0,iu_optop_e[31:4]}) );
assign	optop_dec4_32[3:0] = iu_optop_e[3:0];

// Select the appr. net optop to be used for dest. addr calculation

mux8_32		mux_optop_rsd(.out(optop_addr),
				.in0(iu_optop_e),
				.in1(optop_dec3_32),
				.in2(optop_dec2_32),
				.in3(optop_dec1_32),
				.in4(optop_inc1_32),
				.in5(optop_inc2_32),
				.in6(optop_inc3_32),
				.in7(optop_inc4_32),
				.sel(optop_incr_sel) );
				
// Removed to improve timing

/*//add the offset generated in rcu_ctl to optop to get destination address

cla_adder_32	adder_optop_rsd(.sum(optop_addr),
				.in1(iu_optop_e),
				.in2(dest_addr_offset[31:0]),
				.cin(1'b0),
				.cout(un_used7) );
*/

// In the case of MEM operations, the destination address would be lvars - offset

cla_adder_32	sub_lvars_offset_rsd(.sum(lvars_minus_offset_rsd),
				.in1(iu_lvars),
				.in2({22'h3fffff,(~offset_rsd_r[7:0]),2'h3}),
				.cin(1'b1),
				.cout(un_used8) );

// In case of long and double stores, we need to store results at lvars-offset-4

dec_32		dec_lvars_sec_cyc_rsd(.out(lvars_offset_int_rsd),
				.in({2'b0,lvars_minus_offset_rsd[31:2]}) );

ff_se_32	flop_lvars_sec_cyc_rsd(.out(lvars_offset_sec_cyc_rsd),
					.din({lvars_offset_int_rsd[29:0],2'b0}),
					.clk(clk),
					.enable(!hold_e) );

// depending on the grouping, select either
// . optop +/-  offset or
// . lvars - offset or
// . lvars - offset -4 as the final destination address

mux3_32		mux_dest_addr(.out(dest_addr_r),
				.in0(optop_addr),
				.in1(lvars_offset_sec_cyc_rsd),
				.in2(lvars_minus_offset_rsd),
				.sel(dest_addr_sel_r)  );

// Pass the destination address along the pipe line

ff_se_32	flop_dest_addr_e(.out(dest_addr_e_int),
				.din(dest_addr_r),
				.enable(!hold_e),
				.clk(clk));

// Ucode also wants to write to stack cache

mux3_32		mux_dest_addr_e(.out(dest_addr_e),
				.in0(dest_addr_e_int),
				.in1(ucode_areg0),
				.in2(ex_adder_out_e),
				.sel(dest_addr_sel_e) );


ff_se_32	flop_dest_addr_c(.out(dest_addr_c),
				.din(dest_addr_e),
				.enable(!hold_c),
				.clk(clk));

// Now we have to hold dest_addr_w. Otherwise next address will
// overwrite in case of hold_c

ff_se_32	flop_dest_addr_w(.out(dest_addr_w),
				.din(dest_addr_c),
				.clk(clk),
				.enable(!hold_c));

// Whenever there's
// . group_1_r or group_9_r, net inc. in optop is 0
// . group_4_r, net inc. in optop is 1
// . group_8_r, net inc. in optop is 2
// . group_2_r, net inc. in optop is -1
// For all the other groups and in case of just  one instr. issue,
// we have to use the optop_offset_int generated by decoding opcode in OP stage
 
// Now due to timing reasons we are gib]ving the resultant optop change to pipe
// instead of jsu the offset; But the signal name "optop_offset" will remain
// the same. It just means: optop_offset = optop +/- appr. offset

mux5_32		mux_optop_op1(.out(optop_int1),
				.in0(optop_inc4_32),
				.in1(optop_dec1_32),
				.in2(optop_dec2_32),
				.in3(optop_dec3_32),
				.in4(optop_dec4_32),
				.sel(net_optop_sel1) );

mux4_32		mux_optop_op2(.out(optop_int2),
				.in0(iu_optop_e),
				.in1(optop_inc1_32),
				.in2(optop_inc2_32),
				.in3(optop_inc3_32),
				.sel(net_optop_sel2) );

mux2_32		mux_optop_op(.out(optop_op),
				.in0(optop_int2),
				.in1(optop_int1),
				.sel(net_optop_sel) );

mux6_32         mux_offset_optop(.out(optop_offset),
                                .in0(iu_optop_e),
                                .in1(optop_op),
                                .in2(optop_inc2_32),
                                .in3(optop_inc1_32),
                                .in4(optop_dec1_32),
                                .in5(optop_dec4_32),
                                .sel(optop_offset_sel_r) );

assign	iu_addr_w[7:0] = dest_addr_w[7:0];

// Check for Scache Write Misses
comp_gr_32	comp_sc_wr1(.gr(sc_wr_addr_gr_scbot),
			.in1(dest_addr_c),
			.in2(iu_sc_bottom) );

// Generate iu_smu_flush signal

// Calculate iu_sc_bottom + 12
 
inc32         incr_sc_bot_12(.ai({4'b0,iu_sc_bottom[31:4]}),
                        .sum({un_used22,un_used23,un_used24,un_used29,
				sc_bot_p12[31:4]}));

assign	sc_bot_p12[3:0] = iu_sc_bottom[3:0];

comp_le_32	comp_flush1(.le(iu_smu_flush_le),
			.in1(dest_addr_c),
			.in2(sc_bot_p12) );
		
// Calculate iu_sc_bottom - 12

dec_32		dec_sc_bot_12(.in({4'b0,iu_sc_bottom[31:4]}),
			.out({un_used26,un_used27,un_used28,un_used30,
                                sc_bot_m12[31:4]}) );

assign	sc_bot_m12[3:0] = iu_sc_bottom[3:0];


comp_ge_32	comp_flush2(.ge(iu_smu_flush_ge),
			.in1(dest_addr_c),
			.in2(sc_bot_m12));
		
		
//***** BEGIN:  Global Reg. section the data path *******// 

ff_se_32		flop_global0(.out(gl_reg0),
			.din(iu_data_w),
			.clk(clk),
			.enable(gl_reg0_we_w));

ff_se_32		flop_global1(.out(gl_reg1),
			.din(iu_data_w),
			.clk(clk),
			.enable(gl_reg1_we_w));

ff_se_32		flop_global2(.out(gl_reg2),
			.din(iu_data_w),
			.clk(clk),
			.enable(gl_reg2_we_w));

ff_se_32		flop_global3(.out(gl_reg3),
			.din(iu_data_w),
			.clk(clk),
			.enable(gl_reg3_we_w));

endmodule

module rf (

	di_d, 
	di_e, 
	add_a, 
	add_b, 
	add_c, 
	add_d, 
	add_e, 
	we_d, 
	we_e,
	do_a, 
	do_b, 
	do_c 
); 

input	[31:0]	di_d;	// Write port D i/p data
input	[31:0]	di_e;	// Write port E i/p data
input	[5:0]	add_a;	// Addr. of Rd. port A
input	[5:0]	add_b;	// Addr. of Rd. port B
input	[5:0]	add_c;	// Addr. of Rd. port C
input	[5:0]	add_d;	// Addr. of Wr. port D
input	[5:0]	add_e;	// Addr. of Wr. port E
input		we_d;	// We signal for Port D
input		we_e;	// We signal for Port E
output	[31:0]	do_a;	// Data out from Rd. port A
output	[31:0]	do_b;	// Data out from Rd. port B
output	[31:0]	do_c;	// Data out from Rd. port C

// synopsys translate_off
 reg [31:0] ram [63:0];

 // Write Cycle 
 always @(posedge we_d) begin
     ram[add_d[5:0]]= di_d[31:0];
 end
 always @(posedge we_e) begin
     ram[add_e[5:0]]= di_e[31:0];
 end

 // Read Cycle
assign #1 do_a[31:0]= (^(add_a[5:0])===1'bx) ? 32'bx: ram[add_a[5:0]];
assign #1 do_b[31:0]= (^(add_b[5:0])===1'bx) ? 32'bx: ram[add_b[5:0]];
assign #1 do_c[31:0]= (^(add_c[5:0])===1'bx) ? 32'bx: ram[add_c[5:0]];

// synopsys translate_on

endmodule


module  cmp_we_32 (
 
        in1,
        in2,
        enable,
        out
);
 
input   [31:0]  in1;
input   [31:0]  in2;
input           enable;
output          out;
 
wire            eq_out;
 
comp_eq_32      comp_eq(.eq(eq_out),
                        .in1(in1),
                        .in2(in2) );
 
assign  out = eq_out & enable;
 
endmodule

