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

module smu_dpath (

iu_optop_in,
iu_optop_int_we,
iu_data_in,
iu_sbase_int_we,
iu_sbase_int_sel,
smu_sbase,
num_entries,
und_flw_bit,
optop_en,
smu_addr,
smu_rf_addr,
nxt_sb_sel,
dcache_sb_sel,
sbase_sel,
scache_addr_sel,
fill,
spill,
smu_data,
dcu_data,
iu_rf_dout,
smu_rf_din,
zero_entries_fl,
sbase_hold,

iu_data,
iu_address,
smu_data_sel,

clk,
sin,
so,
sm

);

input	[31:0]	iu_optop_in;	// From the din input of iu_optop_c flop
input		iu_optop_int_we;// Corresponding write enable signal
input	[31:0]	iu_data_in;
input		iu_sbase_int_we;
input	[2:0]	iu_sbase_int_sel;
output	[31:0]	smu_sbase;	// This is the new sbase whihc will go to IU
output	[29:0]	num_entries;	// This tells how many entries are there on the stack $
output		und_flw_bit;	// Indicates that # of entries in s$ is -ve
input		optop_en;	// This helps to preserve the old value of optop in case
				// of overflows
output	[31:0]	smu_addr;	// Address to D$
output	[5:0]	smu_rf_addr;
input	[1:0]	nxt_sb_sel;
input	[1:0]	dcache_sb_sel;	// determines the next address to D$
input	[1:0]	sbase_sel;	// Determines the new sbase
input		spill;
input	[1:0]	scache_addr_sel; // determines what address goes to s$
input		fill;
output	[31:0]	smu_data;	// Data to Dcache
input	[31:0]	dcu_data;	// Data from Dcache
input	[31:0]	iu_rf_dout;	// Data from s $
output	[31:0]	smu_rf_din;	// Data to s $
output		zero_entries_fl;// Tells whether smu_addr is equal to optop old
input		sbase_hold;

input 	[31:0]	iu_address;	// Come from IU of the istore miss address
input	[31:0]	iu_data;	// Come from IU of the istore miss data
input	[1:0]	smu_data_sel;	// determines the next address and data to D$

input		clk;		// clk
input		sm;		// scan enable
input		sin;
output		so;


wire	[31:0]  num_entries_out;
wire	[31:0]	optop_old;
wire	[31:0]	smu_rf_addr_out;
wire	[31:0]	sbase_c_inc_dec;	
wire	[29:0]	sbase_c_inc_dec_out;	
wire	[31:0]	sbase_e;	
wire	[31:0]	sbase_c;	
wire	[31:0]	sbase_w;	
wire	[31:0]	dcu_data_w;
wire	[31:0]	iu_optop_int;
wire	[31:0]	iu_sbase_int;
wire	[31:0]	iu_sbase_int_din;

wire	[31:0]	smu_addr_early;

// Since smu_stall is appearing lots of timing critical paths, we have
// decided to replicate the flops for iu_sbase in SMU itself
// This internal sbase signal is called iu_sbase_int and all the signal related
// to it are named accordingly. This iu_sbase_int is used through out smu_dpath

// Select
// . SC_BOTTOM_POR_VALUE when there's reset
// . smu_sbase if smu_sbase_we is high
// . iu_data_in, otherwise

mux3_30 sc_bottom_din_mux(.out(iu_sbase_int_din[31:2]),
                       	.in2(`SC_BOTTOM_POR_VALUE >> 2),
                        .in1(smu_sbase[31:2]),
                        .in0(iu_data_in[31:2]),
                        .sel(iu_sbase_int_sel[2:0]) );

ff_se_30 sc_bottom_reg(.out(iu_sbase_int[31:2]),
                     	.din(iu_sbase_int_din[31:2]),
                        .enable(iu_sbase_int_we),
                        .clk(clk) );

assign iu_sbase_int[1:0] = 2'b00;

// iu_optop is also replicated 

ff_se_32        optop_int_flop(.out(iu_optop_int[31:0]),
                        .din(iu_optop_in[31:0]),
                        .clk(clk),
                        .enable(iu_optop_int_we));




// The following flop is used to store the old value of optop in case of overflows

ff_se_32	optop_flop (.din(iu_optop_int),
		.out(optop_old),
		.clk(clk),
		.enable(optop_en)
		);

// If the address sent out to DCU is equal to optop_old, in case of overflows
// that means we have flushed out enough entries

comp_eq_32	comp(.eq(zero_entries_fl),
		.in1(optop_old),
		.in2(smu_addr));

// assign	smu_data = iu_rf_dout;
// Latch data coming from D cache and send it to s$

// New mux for smu_data

mux2_32 smu_data_mux(.out(smu_data),
                        .in0(iu_rf_dout),
                        .in1(iu_data),
                        .sel(smu_data_sel[1:0]));

ff_s_32	data_flop(.out(dcu_data_w),
		.din(dcu_data),
		.clk(clk)
		);

assign	smu_rf_din = dcu_data_w;

// Find how many entries are there on the s$

sub2_32	sub (.result(num_entries_out),
	.und_flw_bit(und_flw_bit),
	.operand1(iu_sbase_int),
	.operand2(iu_optop_int));

// since each stack entry is 4 bytes, to determine the # of stack entries 
// ignore the lower 2 bits

assign	num_entries = num_entries_out[31:2];

inc_dec_30	inc_dec(.result(sbase_c_inc_dec_out),
			.operand(sbase_c[31:2]),
			.control({fill,spill}));

assign	sbase_c_inc_dec = {sbase_c_inc_dec_out,2'b0};

mux2_32	sbase_e_mux (.out(sbase_e),
		.in0(sbase_c_inc_dec),
		.in1(iu_sbase_int),
		.sel(nxt_sb_sel[1:0]));

// The following mux is used to select the address to be sent out to dcache


mux2_32	dcache_sbase_mux(.out(smu_addr_early),
			.in0(sbase_e),
			.in1(sbase_c),
			.sel(dcache_sb_sel[1:0]));
mux2_32	smu_address_mux(.out(smu_addr),
			.in0(smu_addr_early),
			.in1(iu_address),
			.sel(smu_data_sel[1:0]));
	
	
ff_se_32		sbase_c_flop(.out(sbase_c),
			.din(sbase_e),
			.enable(!sbase_hold),
			.clk(clk)
			);

ff_s_32		sbase_e_flop(.out(sbase_w),
			.din(sbase_c),
			.clk(clk)
			);

// Generate new sbase

mux2_32		sbase_new_mux (.out(smu_sbase),
			.in0(sbase_w),
			.in1(iu_optop_int),
			.sel(sbase_sel[1:0]));


// Generate  new sbase to access s$

mux2_32		scache_addr_mux(.out(smu_rf_addr_out),
			.in0(sbase_c),
			.in1(sbase_w),
			.sel(scache_addr_sel[1:0]));

// Just send only 6 bits to IU

assign	smu_rf_addr[5:0] = smu_rf_addr_out[7:2];

endmodule

module	sub2_32(

	result,
	operand1,
	operand2,
	und_flw_bit
);

output	[31:0]	result;
output		und_flw_bit;
input	[31:0]	operand1;
input	[31:0]	operand2;

wire		c_out;

// since we already have adders, we would like to
// perform subtraction using adders

cla_adder_32	adder (.in1(operand1),
			.in2(~operand2),
			.cin(1'b1),
			.sum(result),
			.cout(c_out));

// If an adder is used as a subtractor, we need to
// invert carry bit

assign	und_flw_bit = !c_out;

endmodule

module inc_dec_30 (

	operand,
	result,
	control
);

input	[29:0]	operand;
output	[29:0]	result;
input	[1:0]	control;

wire	[29:0]	neg_one;
wire		NC0,NC1,NC2;

assign	neg_one	= {30{control[0]}};

cla_adder_32 adder ( .in1({2'b00,operand}),
		.in2({2'b00,neg_one}),
		.cin(control[1]),
		.sum({NC2,NC1,result}),
		.cout(NC0) );

endmodule
