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
module ex_dpath(carry_in_e,
		adder2_carry_in,
		imdr_data_e,
		pc_r,
		pc_c,
		pc_e,
		vars_out,
		ru_rs1_e,
		ru_rs2_e,
		scache_miss_addr_e,
		ucode_porta_e,
		ucode_portc_e,
		iu_alu_a,
		iu_alu_b,
		u_m_adder_porta_e,
		u_m_adder_portb_e,
		reg_data_e,
		opcode_r,
		dcu_diag_data_c,
		fpu_data_e,
		fpu_hold,
		icu_diag_data_c,
		dcu_data_c,

		rs1_bypass_mux_out,
		rs2_bypass_mux_out,
		iu_data_in,
		ucode_porta_mux_out,
		adder_out_e,
		carry_out_e,
		cmp_gt_e,
		cmp_eq_e,
		cmp_lt_e,
		null_objref_e,
		iu_addr_e,
  		iu_addr_e_2,
		iu_addr_e_31,
		iu_br_pc_e,
		iu_data_e,
		wr_optop_data_e,
		iu_addr_c,
		alu_out_w,
		dcu_data_w,
		load_buffer_mux_out_0,

		shift_dir_e,
		shift_count_e,
		sign_e,
	/******************** monitor caching change *****************/
		monitorenter_e,
			
		iu_data_vld,
		sc_data_vld,
		hold_e,
		hold_c,
		dcu_data_reg_we,
		iu_rs1_e_0_l,
		iu_rs2_e_0_l,

		ucode_active,
		rs1_mux_sel_din,
		forward_c_sel_din,
		ex_adder2_src1_mux_sel,
		rs1_bypass_mux_sel,
		rs2_bypass_mux_sel,
		cmp_mux_sel,
		adder_src1_mux_sel,
		adder_src2_mux_sel,
		shifter_src1_mux_sel,
		shifter_src2_mux_sel,
		shifter_word_sel,
		bit_mux_sel,
		cvt_mux_sel,
		bit_cvt_mux_sel,
		constant_mux_sel,
		alu_out_mux_sel,
		offset_mux_sel,
		adder2_src2_mux_sel,
		iu_br_pc_mux_sel,
		iu_data_mux_sel,
		wr_optop_mux_sel,
		load_data_c_mux_sel,
		fpu_mux_sel,
		forward_w_sel_din,
		load_buffer_mux_sel,

// All of the following signals are added to prevent RS1 and RS2 from
// going from EX -> UCODE -> EX; Timing Improvement 

		iu_optop_e,
		ucode_reg_data,
		ucode_madder_sel2,
		ucode_alu_a_sel,
		ucode_alu_b_sel,
		ucode_porta_sel,
		ucode_busy_e,
		sc_dcache_req,
		

		reset_l,
		clk,
		sm,
		sin,
		so);

   // Data buses
   input	 carry_in_e;		// Carry input to the main adder
   input 	 adder2_carry_in;	// Carry input to the address adder
   input [31:0]  imdr_data_e;		// Result of IMDR unit
   input [31:0]  pc_r;			// R stage PC value
   input [31:0]  pc_e;			// E stage PC value
   input [31:0]  pc_c;			// C stage PC value
   input [31:0]  vars_out;		// C stage VARS value from ex_regs
   input [31:0]  ru_rs1_e;		// Operand 1 value from R unit
   input [31:0]  ru_rs2_e;		// Operand 2 value from R unit
   input [31:0]  scache_miss_addr_e;	// S$ miss address to adder2
   input [31:0]  ucode_porta_e;		// Operand 1 value from ucode
   input [31:0]  ucode_portc_e;		// Result of ucode computation
   input [31:0]  iu_alu_a;		// ucode input to alu adder
   input [31:0]  iu_alu_b;		// ucode input to alu adder
   input [31:0]  u_m_adder_porta_e;	// ucode address 1 to adder2
   input [31:0]  u_m_adder_portb_e;	// ucode address 2 to adder2
   input [31:0]  reg_data_e;		// Output of register mux
   input [31:0]  opcode_r;		/* Coming from IFU
					 * 31:24 - opcode_2_op_r
					 * 23:16 - opcode_3_op_r
					 * 15: 8 - opcode_4_op_r
					 *  7: 0 - opcode_5_op_r
					 */
   input [31:0]  dcu_diag_data_c;	// DCU diagnostic read data
   input [31:0]  fpu_data_e;		// FPU result
   input  	 fpu_hold;		// Hold the fpu data
   input [31:0]  icu_diag_data_c;	// ICU diagnostic read data
   input [31:0]  dcu_data_c;		// Input to dcu_hold_reg

   output [31:0] rs1_bypass_mux_out;	// Output of rs1_bypass_mux
   output [31:0] rs2_bypass_mux_out;	// Output of rs2_bypass_mux
   output [31:0] ucode_porta_mux_out;	// Output of ucode_porta_mux
   output [31:0] iu_data_in;		// Data to be written onto SMU's version
                                        // of sbase in case of wr_sbase opcodes
   output [31:0] adder_out_e;		// Output of main adder
   output 	 carry_out_e;		// Carry output of main adder
   output 	 cmp_gt_e;		// Operand 1 >  operand 2
   output 	 cmp_eq_e;		// Operand 1 == operand 2
   output 	 cmp_lt_e;		// Operand 1 <  operand 2
   output 	 null_objref_e;		// ucode_porta_mux_out == zero
   output	 iu_rs1_e_0_l;		// fast signal for ucode. rs1_bypass[0]
   output	 iu_rs2_e_0_l;		// fast signal for ucode. rs2_bypass[0]
   output [31:0] iu_addr_e;		// Address adder output, E stage
   output	 iu_addr_e_2;
   output	 iu_addr_e_31;
   output [31:0] iu_br_pc_e;		// Branch target PC to ICU
   output [31:0] iu_data_e;		// Data corresponding to iu_addr_e
   output [31:0] wr_optop_data_e;	// Data for write optop operation
   output [31:0] iu_addr_c;		// Address adder output, C stage
   output [31:0] alu_out_w;		// Main alu output, W stage
   output [31:0] dcu_data_w;		// Output of dcu_hold_reg
   output 	 load_buffer_mux_out_0;	// lockbit used in monitorenter	

   // E stage control signals
   input	 ucode_active;
   input 	 shift_dir_e;		// Shifter: 0: left, 1: right
   input [5:0] 	 shift_count_e;		// Shifter: # of bits to shift
   input 	 sign_e;		/* Sign extension for shifter
					 * and converter
					 */
   /******************** monitor caching change  *****************/
   input	monitorenter_e;
   

   // C stage control signals
   input 	 iu_data_vld;		// From IU input
   input 	 sc_data_vld;		// Indicate dcu_data_c is from S$ miss
   input 	 hold_e;		// Hold signal from pipe control
   input 	 hold_c;		// Hold signal from pipe control

   // W stage control signal
   input  [1:0]	 dcu_data_reg_we;	/* Eanbled if:
					 * 1. IDLE and valid
					 * 2. ST1 and ~hold and valid
					 * 3. ST2 and ~hold
					 */
   // Mux select signals.  0 is the default selection.
   input  	 rs1_mux_sel_din;	/* 1: scache_miss_data_e */
   input  	 forward_c_sel_din;	/* 1: scache_miss_data_e
					 */
   input	ex_adder2_src1_mux_sel; 

   input [4:0] 	 rs1_bypass_mux_sel;	/* 16: rs1_hold_reg
					   8: forward_data_w1
					 * 4: forward_data_w
					 * 2: forward_data_c
					 * 1: rs1_mux_out
					 */
   input [4:0] 	 rs2_bypass_mux_sel;	/* 16:rs2_hold_reg
					   8: forward_data_w1
					 * 4: forward_data_w
					 * 2: forward_data_c
					 * 1: ru_rs2_e
					 */
   input [2:0] 	 cmp_mux_sel;		/* 2: Rs1, zero
					 * 1: Rs2, Rs1
					 */
   input [1:0] 	 adder_src1_mux_sel;	/* 2: ~Rs1
					 * 1: Rs1
					 */
   input [2:0] 	 adder_src2_mux_sel;	/* 4: zero
					 * 2: ~Rs2
					 * 1: Rs2
					 */
   input [4:0] 	 shifter_src1_mux_sel;	/* 16: rs2_bypass_mux_out_d1
					 *  8: {32{rs2_bypass_mux_out[31]}}
					 *  4: rs2_bypass_mux_out
					 *  2: rs1_bypass_mux_out
					 *  1: zero
					 */
   input [2:0] 	 shifter_src2_mux_sel;	/* 4: rs2_bypass_mux_out_d1
					 * 2: rs2_bypass_mux_out
					 * 1: zero
					 */
   input 	 shifter_word_sel;	/* 1: MSW
					 * 0: LSW
					 */
   input [4:0] 	 bit_mux_sel;		/* 16: rs1_bypass_mux_out with bit 31
					 *     flipped for fneg and dneg
					 *  8: pc_r
					 *  4: xor
					 *  2: and
					 *  1: or
					 */
   input [4:0] 	 cvt_mux_sel;		/* 16: i2s
					 *  8: i2c
					 *  4: i2b
					 *  2: i2l
					 *  1: sethi
					 */
   input [1:0] 	 bit_cvt_mux_sel;	/* 2: bit operator output
					 * 1: converter output
					 */
   input [2:0] 	 constant_mux_sel;	/* 4:  1 -- gt
					 * 2:  0 -- eq
					 * 1: -1 -- lt
					 */
   input [7:0] 	 alu_out_mux_sel;	/* 128: constant_mux_out
					 *  64: imdr_data_e
					 *  32: reg_mux_out
					 *  16: bit_cvt_mux_out
					 *   8: shifter output
					 *   4: adder output
					 *   2: ucode_portc_e
					 *   1: bypass
					 */
   input [4:0] 	 offset_mux_sel;	/* 16: 32-bit offset for ld/st index
					 *  8: 16-bit offset for ld/st index
					 *  4: 8-bit offset for ld/st index
					 *  2: opcode_e (32-bit offset)
					 *  1: offset16 (16-bit offset)
					 */

   input [3:0] 	 adder2_src2_mux_sel;	/* 8: zero
					 * 4: offset_e
					 * 2: u_m_adder_portb_e
					 * 1: ~u_m_adder_portb_e
					 */
   input [2:0] 	 iu_br_pc_mux_sel;	/* 4: ucode_porta_e
					 * 2: pc_c
					 * 1: adder2 output
					 */
   input [1:0] 	 iu_data_mux_sel;	/* 2: ucode_portc_e
					 * 1: rs2_bypass_mux_out
					 */
   input [1:0] 	 wr_optop_mux_sel;	/* 2: vars_out
					 * 1: ucode_porta_mux_out
					 */
   input [2:0] 	 load_data_c_mux_sel;	/* 4: icu_diag_data_c
					 * 2: dcu_diag_data_c
					 * 1: dcu_data_c 
					 */

   input [1:0]	 fpu_mux_sel;		// 2: fpu_data
					// 1: alu data

   input [1:0] 	 forward_w_sel_din;/* 2: output of dcu_hold register
					 * 1: output of W stage alu_out
					 *    register
					 */
   input [1:0] 	 load_buffer_mux_sel;	/* 2: load_buffer_reg_out (in state 2)
					 * 1: dcu_data_c (otherwise)
					 */

   input [31:0] iu_optop_e;		// optop
   input [31:0] ucode_reg_data;		// ucode arch reg data
   input [3:0]	ucode_madder_sel2;	// u_f19[3] and u_f19[1:0] frpom ucode
   input [1:0]	ucode_alu_a_sel;	// u_f23[1:0] from ucode
   input [2:0]	ucode_alu_b_sel;	// u_f07[2:0] from ucode
   input [1:0]	ucode_porta_sel;	// u_f00[1:0] from ucode
   input	ucode_busy_e;		// Ucode is busy
   input	sc_dcache_req;		// dcache req on a smiss

   // Miscellaneous global signals
   input	 reset_l;		// Global Reset signal
   input 	 clk;			// Global clock signal
   input 	 sm;			// Scan enable
   input 	 sin;			// Scan input of this module
   output 	 so;			// Scan output of this module

   
   // Internal buses
   wire [31:0] 	scache_miss_data_e;	// Operand 1 value when S$ miss
   wire [31:0] 	rs1_bypass_hold;	/* Latched rs1_bypass_mux_out for the
					 * "bubbled" forward case
					 */
   wire [31:0] 	rs2_bypass_hold;	/* Latched rs2_bypass_mux_out for the
					 * "bubbled" forward case
					 */
   wire [31:0] 	rs1_mux_out;		// Output of rs1_mux
   wire [31:0] 	ucode_alu_a_mux_out;	// Output of ucode_alu_a_mux
   wire [31:0] 	ucode_alu_b_mux_out;	// Output of ucode_alu_b_mux
   wire [31:0] 	cmp_src1_mux_out;	// Output of cmp_src1_mux
   wire [31:0] 	cmp_src2_mux_out;	// Output of cmp_src2_mux
   wire [31:0] 	adder_src1_mux_out;	// Output of adder_src1_mux
   wire [31:0] 	adder_src2_mux_out;	// Output of adder_src2_mux
   wire [31:0] 	rs2_bypass_mux_out_d1;	// Latched version of rs2_bypass_mux_out
   wire [31:0] 	shifter_src1_mux_out;	// Output of shifter_msb_mux
   wire [31:0] 	shifter_src2_mux_out;	// Output of shifter_lsb_mux
   wire [31:0] 	shifter_out;		// Output of 64-bit shifter
   wire [31:0] 	bit_mux_out;		// Output of bit_mux
   wire [31:0] 	cvt_src0;		// Input to converter
   wire [31:0] 	cvt_src1;		// Input to converter
   wire [31:0] 	cvt_src2;		// Input to converter
   wire [31:0] 	cvt_src3;		// Input to converter
   wire [31:0] 	cvt_src4;		// Input to converter
   wire [31:0] 	cvt_mux_out;		// Output of cvt_mux
   wire [31:0] 	bit_cvt_mux_out;	// Output of bit_cvt_mux
   wire [31:0] 	constant_mux_out;	// Output of constant_mux
   wire [31:0] 	alu_out_e;		// Output of alu_out_mux
   wire [31:0] 	alu_out_c;		// Latched version of alu_out_e 
   wire [31:0]  load_data_c;		// Input to the load buffer
   wire [31:0] 	alu_out_c_d1;		// Latched version of alu_out_c 
   wire [31:0] 	alu_out_w;		// Mux output in W stage
   wire [31:0] 	forward_data_c;		// forward_data_c_mux_out
   wire [31:0] 	load_buffer_reg_out;	// Output of the (1st) load_buffer_reg
   wire [31:0] 	load_buffer_mux_out;	// Outptu of the load_buffer_mux
   wire [31:0] 	forward_data_w;		/* forward_data_w_mux_out
					 * Equivalent to iu_data_w
					 */
   wire [31:0] 	forward_data_w1;	// Output of W1 stage register
   wire [31:0] 	opcode_e;		// Latched version of opcode_r
   wire [31:0] 	offset16;		/* Signed extended offset for 16-bit
					 * branch offset
					 */
   wire	[31:0]	rs2_bypass_mux_out_gen;
   wire	[31:0]	rs2_bypass_mux_out_v1;

   wire	[31:0]	rs1_bypass_mux_out_gen;
   wire	[31:0]	rs1_bypass_mux_out_inv;
   wire	[31:0]	rs1_bypass_mux_out_v1;
   wire	[31:0]	rs1_bypass_mux_out_v2;

   wire [31:0] 	alu_out_e_new;		// including fpu data. timing fix
   wire [31:0] 	offset_e;		// Branch offset to adder2
   wire [31:0] 	adder2_src1_mux_out;	// Output of adder2_src1_mux
   wire [31:0] 	adder2_src2_mux_out;	// Output of adder2_src2_mux
   wire 	adder2_carry_out;	// Carry output of dpath_adder2

// All of the following signals are added to improve timing 

   wire [4:0]	rs1_bypass_mux_sel_e;
   wire [4:0]	rs2_bypass_mux_sel_e;
   wire [1:0]	rs1_mux_sel;
   wire		rs1_0_mux_out;
   wire		rs1_0;
   wire		rs2_0;
   wire [31:0] cmp_porta ;
   wire [1:0]  forward_data_c_mux_sel;
   wire [1:0]  forward_data_w_mux_sel;


   wire	[7:0]	adder2_src1_mux_sel;
   wire [3:0]	ucode_alu_a_mux_sel;
   wire [7:0]	ucode_alu_b_mux_sel;
   wire	[2:0]	ucode_porta_mux_sel;
	

   /*****************************
    *				*
    *		E stage		*
    *				*
    *****************************/

   ff_se_32 scache_miss_data_e_reg(.out	   (scache_miss_data_e[31:0]),
				   .din	   (dcu_data_c[31:0]),
				   .enable (iu_data_vld & sc_data_vld),
				   .clk	   (clk)
				   );
   ff_s_32 rs1_bypass_reg(.out (rs1_bypass_hold[31:0]),
			  .din (rs1_bypass_mux_out[31:0]),
			  .clk (clk)
			  );
   ff_s_32 rs2_bypass_reg(.out (rs2_bypass_hold[31:0]),
			  .din (rs2_bypass_mux_out[31:0]),
			  .clk (clk)
			  );
   mux2_32 rs1_mux(.out	(rs1_mux_out[31:0]),
		   .in1	(scache_miss_data_e[31:0]),
		   .in0	(ru_rs1_e[31:0]),
		   .sel	(rs1_mux_sel[1:0])
		   );

// Because of timing reasons, we have moved the mux selects for 
// Rs1 and Rs2 into data path only 

   ff_sr	flop_rs1_mux(.out(rs1_mux_sel[1]),
                    	.din(rs1_mux_sel_din),
                       	.clk(clk),
                       	.reset_l(reset_l));

   assign	rs1_mux_sel[0] = !rs1_mux_sel[1];


   ff_sre_4	flop_rs1_bypass_sel(.out(rs1_bypass_mux_sel_e[3:0]),
			.din(rs1_bypass_mux_sel[3:0]),
                        .clk(clk),
			.enable(!(hold_e & !ucode_active)),
                        .reset_l(reset_l));

   ff_sr	flop_rs1_bypass_sel_4(.out(rs1_bypass_mux_sel_e[4]),
			.din(rs1_bypass_mux_sel[4]),
                        .clk(clk),
                        .reset_l(reset_l));


   mux5_32 rs1_bypass_mux(.out (rs1_bypass_mux_out_gen[31:0]),
			   .in4 (rs1_bypass_hold[31:0]),
			   .in3 (forward_data_c[31:0]),
			   .in2 (forward_data_w[31:0]),
			   .in1 (forward_data_w1[31:0]),
			   .in0 (rs1_mux_out[31:0]),
			   .sel (rs1_bypass_mux_sel_e[4:0])
			   );

// Constructing a buffer tree so as to aid timing 
// rs1_bypass_mux_out is used in non-critical places, while
// rs1_bypass_mux_out_v1 and v2 will be used in timing critical places

buf10_drv_32	buf_rs1 (.out(rs1_bypass_mux_out), .in(rs1_bypass_mux_out_gen) );
inv10_drv_32	inv_rs1_1 (.out(rs1_bypass_mux_out_inv), .in(rs1_bypass_mux_out_gen) );
inv10_drv_32	inv_rs1_2 (.out(rs1_bypass_mux_out_v1), .in(rs1_bypass_mux_out_inv) );
inv10_drv_32	inv_rs1_3 (.out(rs1_bypass_mux_out_v2), .in(rs1_bypass_mux_out_inv) );


// The following two muxes are replicated to generate a dedicated
// rs1 bit 0 to be used in ucode. This will help some
// critical paths

   mux2 rs1_0_mux(.out	(rs1_0_mux_out),
		   .in1	(scache_miss_data_e[0]),
		   .in0	(ru_rs1_e[0]),
		   .sel	(rs1_mux_sel[1:0])
		   );

   mux5 rs1_0_bypass_mux(.out (rs1_0),
			   .in4 (rs1_bypass_hold[0]),
			   .in3 (forward_data_c[0]),
			   .in2 (forward_data_w[0]),
			   .in1 (forward_data_w1[0]),
			   .in0 (rs1_0_mux_out),
			   .sel (rs1_bypass_mux_sel_e[4:0])
			   );

   assign	iu_rs1_e_0_l	= ~rs1_0 ;

// Because of timing reasons, we have moved the mux selects for 
// Rs1 and Rs2 into data path only 

   ff_sre_4	flop_rs2_bypass_sel(.out(rs2_bypass_mux_sel_e[3:0]),
			.din(rs2_bypass_mux_sel[3:0]),
                        .clk(clk),
			.enable(!hold_e),
                        .reset_l(reset_l));

   ff_sr	flop_rs2_bypass_sel_4(.out(rs2_bypass_mux_sel_e[4]),
			.din(rs2_bypass_mux_sel[4]),
                        .clk(clk),
                        .reset_l(reset_l));

   mux5_32 rs2_bypass_mux (.out (rs2_bypass_mux_out_gen[31:0]),
			   .in4 (rs2_bypass_hold[31:0]),
			   .in3 (forward_data_c[31:0]),
			   .in2 (forward_data_w[31:0]),
			   .in1 (forward_data_w1[31:0]),
			   .in0 (ru_rs2_e[31:0]),
			   .sel (rs2_bypass_mux_sel_e[4:0])
			   );

// Inserting a buffer tree for improving timing on RS2 

buf10_drv_32	buf_rs2_1(.out(rs2_bypass_mux_out), .in(rs2_bypass_mux_out_gen) );
buf10_drv_32	buf_rs2_2(.out(rs2_bypass_mux_out_v1), .in(rs2_bypass_mux_out_gen) );

// The following mux is replicated to give a dedicated rs2[0] to 
// ucode to help timing 

   mux5 rs2_0_bypass_mux (.out (rs2_0),
			   .in4 (rs2_bypass_hold[0]),
			   .in3 (forward_data_c[0]),
			   .in2 (forward_data_w[0]),
			   .in1 (forward_data_w1[0]),
			   .in0 (ru_rs2_e[0]),
			   .sel (rs2_bypass_mux_sel_e[4:0])
			   );

   assign	iu_rs2_e_0_l	= ~rs2_0 ;

/***********       iu_alu_a path improvement  ********************/
/****				BEGIN		    	*****/

//   mux2_32 ucode_alu_a_mux(.out	(ucode_alu_a_mux_out[31:0]),
//			   .in1	(iu_alu_a[31:0]),
//			   .in0	(rs1_bypass_mux_out[31:0]),
//			   .sel	(ucode_mux_sel[1:0])
//			   );

   mux4_32 ucode_alu_a_mux(.out	(ucode_alu_a_mux_out[31:0]),
			   .in3	({rs1_bypass_mux_out_v1[28:0],3'b0}),
			   .in2	({rs1_bypass_mux_out_v1[29:0],2'b0}),
			   .in1	(iu_alu_a[31:0]),
			   .in0	(rs1_bypass_mux_out_v1[31:0]),
			   .sel	(ucode_alu_a_mux_sel[3:0])
			   );

// If u_f23[1:0] == 11, select RS1[28:0],3'b0
assign	ucode_alu_a_mux_sel[3] = ucode_alu_a_sel[1] & ucode_alu_a_sel[0];

// If u_f23[1:0] == 10, select RS1[29:0],2'b0
assign	ucode_alu_a_mux_sel[2] = ucode_alu_a_sel[1] & !ucode_alu_a_sel[0];

// If u_f23[1:0] == 01, select iu_alu_a
assign	ucode_alu_a_mux_sel[1] = !ucode_alu_a_sel[1] & ucode_alu_a_sel[0];

// If u_f23[1:0] == 00, select RS1
assign	ucode_alu_a_mux_sel[0] = !ucode_alu_a_sel[1] & !ucode_alu_a_sel[0];

/****				  END				    	*****/
/***********       iu_alu_a path improvement   ********************/

/************    iu_alu_b path improvement      *******************/
/****				BEGIN				    	*****/

//   mux2_32 ucode_alu_b_mux(.out(ucode_alu_b_mux_out[31:0]),
//			   .in1	(iu_alu_b[31:0]),
//			   .in0	(rs2_bypass_mux_out[31:0]),
//			   .sel	(ucode_mux_sel[1:0])
//			   );

   mux8_32 ucode_alu_b_mux(.out	(ucode_alu_b_mux_out[31:0]),
			   .in7	(iu_alu_b[31:0]),
			   .in6	(rs1_bypass_mux_out_v1[31:0]),
			   .in5	(ucode_reg_data[31:0]),
			   .in4	(iu_optop_e[31:0]),
			   .in3	({rs1_bypass_mux_out_v1[31:2],2'b0}),
			   .in2	({ucode_reg_data[31:2],2'b0}),
			   .in1	(32'b0),
			   .in0	(rs2_bypass_mux_out_v1[31:0]),
			   .sel	(ucode_alu_b_mux_sel[7:0])
			   );

// if u_f07[2:0] == 001, select iu_alu_b
assign	ucode_alu_b_mux_sel[7] 	=  !ucode_alu_b_sel[2] & !ucode_alu_b_sel[1] 
					& ucode_alu_b_sel[0];

// if u_f07[2:0] == 010, select RS1
assign	ucode_alu_b_mux_sel[6] 	=  !ucode_alu_b_sel[2] & ucode_alu_b_sel[1] 
					& !ucode_alu_b_sel[0];

// if u_f07[2:0] == 011, select ucode_reg_data
assign	ucode_alu_b_mux_sel[5] 	=  !ucode_alu_b_sel[2] & ucode_alu_b_sel[1] 
					& ucode_alu_b_sel[0];

// if u_f07[2:0] == 100, select iu_optop_e
assign	ucode_alu_b_mux_sel[4] 	=  ucode_alu_b_sel[2] & !ucode_alu_b_sel[1] 
					& !ucode_alu_b_sel[0];

// if u_f07[2:0] == 101, select RS1[31:2],2'b0
assign	ucode_alu_b_mux_sel[3] 	=  ucode_alu_b_sel[2] & !ucode_alu_b_sel[1] 
					& ucode_alu_b_sel[0];

// if u_f07[2:0] == 110, select ucode_reg_data[31:2],2'b0
assign	ucode_alu_b_mux_sel[2] 	=  ucode_alu_b_sel[2] & ucode_alu_b_sel[1] 
					& !ucode_alu_b_sel[0];

// if u_f07[2:0] == 111, select 32'b0
assign	ucode_alu_b_mux_sel[1] 	=  ucode_alu_b_sel[2] & ucode_alu_b_sel[1] 
					& ucode_alu_b_sel[0];

// if u_f07[2:0] == 000, select RS2
assign	ucode_alu_b_mux_sel[0] 	=  !ucode_alu_b_sel[2] & !ucode_alu_b_sel[1] 
					& !ucode_alu_b_sel[0];

/****				 END				    	*****/
/*******       iu_alu_b path improvement        *******************/


/*******  ucode_porta_mux_out path improvement  *******************/
/****				BEGIN				    	*****/

    mux2_32 ucode_porta_mux(.out	(ucode_porta_mux_out[31:0]),
 			   .in1	(ucode_porta_e[31:0]),
 			   .in0	(rs1_bypass_mux_out_v1[31:0]),
 			   .sel	({ucode_busy_e,~ucode_busy_e})
 			   );

   mux3_32 cmp_porta_mux(.out	(cmp_porta[31:0]),
			   .in2	(rs2_bypass_mux_out_v1[31:0]),
			   .in1	(ucode_porta_e[31:0]),
			   .in0	(rs1_bypass_mux_out_v2[31:0]),
			   .sel	(ucode_porta_mux_sel[2:0]));

// Select RS2 whenever u_f00[1:0] is 11
assign	ucode_porta_mux_sel[2] 	=  ucode_porta_sel[1] & ucode_porta_sel[0];

// Select ucode_porta_e whenever u_f00[1:0] is 10
assign	ucode_porta_mux_sel[1] 	=  ucode_porta_sel[1] & !ucode_porta_sel[0];

// Select RS1 otherwise
assign	ucode_porta_mux_sel[0] 	=  !ucode_porta_sel[1];

/****				 END				    	*****/
/*******  ucode_porta_mux_out path improvement  *******************/

// Data to be written onto SMU's version of sbase in case 
// of wr_sbase opcodes. This is done to improve timing on 
// smu_stall signal 

assign 	iu_data_in = ucode_porta_mux_out;

   compare_zero_32 objref_cmp(.in(cmp_porta[31:0]),
			.out(null_objref_e)
			 );

   // The signed/unsigned 32-bit comparator
   mux3_32 cmp_src1_mux(.out (cmp_src1_mux_out[31:0]),
			.in2 (rs1_bypass_mux_out_v2[31:0]),
			.in1 ({2'b0,rs2_bypass_mux_out_v1[29:2],2'b0}),
			.in0 (rs2_bypass_mux_out_v1[31:0]),
			.sel (cmp_mux_sel[2:0])
			);
   mux3_32 cmp_src2_mux(.out (cmp_src2_mux_out[31:0]),
			.in2 (32'h0),
			.in1 ({2'b0,rs1_bypass_mux_out_v2[29:2],2'b0}),
			.in0 (rs1_bypass_mux_out_v2[31:0]),
			.sel (cmp_mux_sel[2:0])
			);
   cmp_32 dpath_cmp(.gt	  (cmp_gt_e),
		    .eq	  (cmp_eq_e),
		    .lt	  (cmp_lt_e),
		    .in1  (cmp_src1_mux_out[31:0]),
		    .in2  (cmp_src2_mux_out[31:0]),
		    .sign (sign_e)
		    );

   // The 32-bit adder
   mux2_32 adder_src1_mux(.out	(adder_src1_mux_out[31:0]),
			  .in1	(~ucode_alu_a_mux_out[31:0]),
			  .in0	(ucode_alu_a_mux_out[31:0]),
			  .sel	(adder_src1_mux_sel[1:0])
			  );
   mux3_32 adder_src2_mux(.out	(adder_src2_mux_out[31:0]),
			  .in2	(32'h0),
			  .in1	(~ucode_alu_b_mux_out[31:0]),
			  .in0	(ucode_alu_b_mux_out[31:0]),
			  .sel	(adder_src2_mux_sel[2:0])
			  );
   cla_adder_32 dpath_adder(.cout (carry_out_e),
			    .sum  (adder_out_e[31:0]),
			    .in1  (adder_src1_mux_out[31:0]),
			    .in2  (adder_src2_mux_out[31:0]),
			    .cin  (carry_in_e)
			    );

   // The 64-bit shifter
   /* 
    * We need to latch rs2_bypass_mux_out for long shift so the second cycle
    * can use the correct operand (LSW for lshl and MSW for lshr and lushr).
    */
   ff_se_32 rs2_bypass_mux_out_reg(.out    (rs2_bypass_mux_out_d1[31:0]),
				   .din    (rs2_bypass_mux_out[31:0]),
				   .enable (~hold_e),
				   .clk    (clk)
				   );
   mux5_32 shifter_src1_mux(.out (shifter_src1_mux_out[31:0]),
			    .in4 (rs2_bypass_mux_out_d1[31:0]),
			    .in3 ({32{rs2_bypass_mux_out[31]}}),
			    .in2 (rs2_bypass_mux_out[31:0]),
			    .in1 (rs1_bypass_mux_out[31:0]),
			    .in0 (32'h0),
			    .sel (shifter_src1_mux_sel[4:0])
			    );
   mux3_32 shifter_src2_mux(.out (shifter_src2_mux_out[31:0]),
			    .in2 (rs2_bypass_mux_out_d1[31:0]),
			    .in1 (rs2_bypass_mux_out[31:0]),
			    .in0 (32'h0),
			    .sel (shifter_src2_mux_sel[2:0])
			    );
   shift_64 dpath_shifter(.out	    (shifter_out[31:0]),
			  .msw_in   (shifter_src1_mux_out[31:0]),
			  .lsw_in   (shifter_src2_mux_out[31:0]),
			  .count    (shift_count_e[5:0]),
			  .dir	    (shift_dir_e),
			  .arith    (sign_e),
			  .word_sel (shifter_word_sel)
			  );

   // AND, OR, XOR
   mux5_32 bit_mux(.out	(bit_mux_out[31:0]),
		   .in4 ({~rs1_bypass_mux_out[31], rs1_bypass_mux_out[30:0]}),
		   .in3	(pc_r[31:0]),
		   .in2	(rs1_bypass_mux_out[31:0] ^ rs2_bypass_mux_out[31:0]),
		   .in1	(rs1_bypass_mux_out[31:0] & rs2_bypass_mux_out[31:0]),
		   .in0	(rs1_bypass_mux_out[31:0] | rs2_bypass_mux_out[31:0]),
		   .sel	(bit_mux_sel[4:0])
		   );

   // Converter
   // sethi
   assign cvt_src0 = {offset_e[15:0], rs1_bypass_mux_out[15:0]};
   // i2l
   assign cvt_src1 = {32{rs1_bypass_mux_out[31]}};
   // i2b
   assign cvt_src2 = {{24{rs1_bypass_mux_out[7]}}, rs1_bypass_mux_out[7:0]};
   // i2c
   assign cvt_src3 = {16'h0, rs1_bypass_mux_out[15:0]};
   // i2s
   assign cvt_src4 = {{16{rs1_bypass_mux_out[15]}}, rs1_bypass_mux_out[15:0]};
   mux5_32 cvt_mux(.out	(cvt_mux_out[31:0]),
		   .in4	(cvt_src4[31:0]),
		   .in3	(cvt_src3[31:0]),
		   .in2	(cvt_src2[31:0]),
		   .in1	(cvt_src1[31:0]),
		   .in0	(cvt_src0[31:0]),
		   .sel	(cvt_mux_sel[4:0])
		   );
   mux2_32 bit_cvt_mux(.out (bit_cvt_mux_out[31:0]),
		       .in1 (bit_mux_out[31:0]),
		       .in0 (cvt_mux_out[31:0]),
		       .sel (bit_cvt_mux_sel[1:0])
		       );
   mux3_32 constant_mux(.out (constant_mux_out[31:0]),
			.in2 (32'h1),
			.in1 (32'h0),
			.in0 (32'hffffffff),
			.sel (constant_mux_sel[2:0])
			);
   mux8_32 alu_out_mux(.out (alu_out_e[31:0]),
		       .in7 (constant_mux_out[31:0]),
		       .in6 (imdr_data_e[31:0]),
		       .in5 (reg_data_e[31:0]),
		       .in4 (bit_cvt_mux_out[31:0]),
		       .in3 (shifter_out[31:0]),
		       .in2 (adder_out_e[31:0]),
		       .in1 (ucode_portc_e[31:0]),
		       .in0 (rs1_bypass_mux_out[31:0]),
		       .sel (alu_out_mux_sel[7:0])
		       );
   ff_se_32 opcode_r_reg(.out	 (opcode_e[31:0]),
			 .din	 (opcode_r[31:0]),
			 .enable (~hold_e),
			 .clk	 (clk)
			 );
   assign offset16 = {{16{opcode_e[31]}}, opcode_e[31:16]};
   mux5_32 offset_mux(.out (offset_e[31:0]),
		      .in4 ({{22{opcode_e[23]}}, opcode_e[23:16], 2'b00}),
		      .in3 ({{23{opcode_e[23]}}, opcode_e[23:16], 1'b0}),
		      .in2 ({{24{opcode_e[23]}}, opcode_e[23:16]}),
		      .in1 (opcode_e[31:0]),
		      .in0 (offset16[31:0]),
		      .sel (offset_mux_sel[4:0])
		      );
/*********** m_adder_port_a path improvement   ********************/
/****				BEGIN				    	*****/

// Replacing the following mux to improve timing 

//    mux4_32 adder2_src1_mux(.out	(adder2_src1_mux_out[31:0]),
// 			   .in3	(u_m_adder_porta_e[31:0]),
// 			   .in2	(rs1_bypass_mux_out[31:0]),
// 			   .in1	(scache_miss_addr_e[31:0]),
// 			   .in0	(pc_e[31:0]),
// 			   .sel	(adder2_src1_mux_sel[3:0])
// 			   );


mux8_32 adder2_src1_mux(.out(adder2_src1_mux_out[31:0]),
                        .in7(scache_miss_addr_e[31:0]),
                        .in6(rs1_bypass_mux_out_v2[31:0]),
                        .in5({rs1_bypass_mux_out_v2[31:2],2'b0}),
                        .in4({rs2_bypass_mux_out_v1[31:2],2'b0}),
                        .in3(ucode_reg_data[31:0]),
                        .in2({ucode_reg_data[31:6],2'b10,ucode_reg_data[3:0]}),
                        .in1(u_m_adder_porta_e[31:0]),
                        .in0(pc_e),
                        .sel (adder2_src1_mux_sel[7:0]) );
 

assign  adder2_src1_mux_sel[7]  = sc_dcache_req;
 
// Whenever f21[1] is set and f19[3:0] are 1001 or whenever
// ex_adder2_src1_mux_sel is  high pick RS1
 
assign  adder2_src1_mux_sel[6]  = ( (ucode_madder_sel2[3] & !ucode_madder_sel2[2] &
                                    !ucode_madder_sel2[1] & ucode_madder_sel2[0]) |
                                    (ex_adder2_src1_mux_sel &! ucode_busy_e) );
 
// Whenever f21[1] is set and f19[3:0] are 1010, pick RS1[31:2],2'b0

/******************** monitor caching change  *****************/
// pick RS1[31:2],2'b0 when checking lockbit in monitorenter
 
assign  adder2_src1_mux_sel[5]  = (ucode_madder_sel2[3] & !ucode_madder_sel2[2] &
                                        ucode_madder_sel2[1] & !ucode_madder_sel2[0])
                                  | monitorenter_e;
 
// Whenever f19[3:0] are 1011, pick RS2[31:2],2'b0
 
assign  adder2_src1_mux_sel[4]  = ucode_madder_sel2[3] & !ucode_madder_sel2[2] &
                                        ucode_madder_sel2[1] & ucode_madder_sel2[0];
 
// Whenever f19[3:0] are 0110, pick ucode_reg_data
 
assign  adder2_src1_mux_sel[3]  = !ucode_madder_sel2[3] & ucode_madder_sel2[2] &
                                        ucode_madder_sel2[1] & !ucode_madder_sel2[0];
 
// Whenever f19[3:0] are 0111, pick ucode_reg_data[31:6],2'b10,[3:0]
 
assign  adder2_src1_mux_sel[2]  = !ucode_madder_sel2[3] & ucode_madder_sel2[2] &
                                        ucode_madder_sel2[1] & ucode_madder_sel2[0];
 
// Whenever ucode_busy_e is set, pick u_m_adder_porta_e
 
assign  adder2_src1_mux_sel[1]  = ucode_busy_e ;

// Else pick pc_e
 
assign  adder2_src1_mux_sel[0]  = !ucode_busy_e ;
 

/****				  END				    	*****/
/*********** m_adder_port_a path improvement 8  ********************/




   mux4_32 adder2_src2_mux(.out	(adder2_src2_mux_out[31:0]),
			   .in3	(32'h0),
			   .in2	(offset_e[31:0]),
			   .in1 (u_m_adder_portb_e[31:0]),
                           .in0 (~u_m_adder_portb_e[31:0]),
			   .sel	(adder2_src2_mux_sel[3:0])
			   );

   /*
    * For extended ld/st, bit 31 is used for GC and bit 30 is used for LE.
    * But for diagnostis rd/wr, bit 31 is used to select which way of the
    * cache to access.  Need to select the right bit to go into DCU.
    */
   cla_adder_32 dpath_adder2(.cout (adder2_carry_out),
			     .sum  (iu_addr_e[31:0]),
			     .in1  (adder2_src1_mux_out[31:0]),
			     .in2  (adder2_src2_mux_out[31:0]),
			     .cin  (adder2_carry_in)
			     );
   assign iu_addr_e_2 =  rs1_bypass_mux_out[2] ;
   assign iu_addr_e_31 = rs1_bypass_mux_out[31] ;

   /*
    * iu_addr_c is used to check mem_protection_error and data breakpoints.
    * Bit 31 (GC) and bit 30 (LE) should be masked off so they don't get
    * compared.
    */
   assign iu_addr_c[31:30] = 2'b00;
   ff_se_30 iu_addr_e_reg(.out	  (iu_addr_c[29:0]),
			  .din	  (iu_addr_e[29:0]),
			  .enable (~hold_c),
			  .clk	  (clk)
			  );
   mux3_32 iu_br_pc_mux(.out (iu_br_pc_e[31:0]),
			.in2 (ucode_porta_e[31:0]),
			.in1 (pc_c[31:0]),
			.in0 (iu_addr_e[31:0]),
			.sel (iu_br_pc_mux_sel[2:0])
			);
   mux2_32 iu_data_mux(.out (iu_data_e[31:0]),
		       .in1 (ucode_portc_e[31:0]),
		       .in0 (rs2_bypass_mux_out_v1[31:0]),
		       .sel (iu_data_mux_sel[1:0])
		       );
   mux2_32 wr_optop_mux(.out (wr_optop_data_e[31:0]),
			.in1 (vars_out[31:0]),
			.in0 (ucode_porta_mux_out[31:0]),
			.sel (wr_optop_mux_sel[1:0])
			);

    mux2_32 fpu_data_mux(.out (alu_out_e_new[31:0]),
                        .in1 (fpu_data_e[31:0]),
                        .in0 (alu_out_e[31:0]),
                        .sel (fpu_mux_sel[1:0])
                        );

   ff_se_32 alu_out_c_reg(.out	  (alu_out_c[31:0]),
			  .din	  (alu_out_e_new[31:0]),
			  .enable (~hold_c | ~fpu_hold&fpu_mux_sel[1]),
			  .clk	  (clk)
			  );

   /*****************************
    *				*
    *		C stage		*
    *				*
    *****************************/

// Because of timing reasons, we have moved the mux selects for 
// Rs1 and Rs2 into data path only 

   mux2_32 forward_data_c_mux(.out (forward_data_c[31:0]),
			      .in1 (dcu_data_w[31:0]),
			      .in0 (alu_out_c[31:0]),
			      .sel (forward_data_c_mux_sel[1:0])
			      );

ff_sr        for_c_flop( .out(forward_data_c_mux_sel[1]),
                                .din(forward_c_sel_din),
                                .clk(clk),
                                .reset_l(reset_l));

assign	forward_data_c_mux_sel[0] = !forward_data_c_mux_sel[1];



   ff_se_32 alu_out_c_d1_reg(.out (alu_out_c_d1[31:0]),
			  .din	  (alu_out_c[31:0]),
			  .enable (~hold_c),
			  .clk	  (clk)
			  );

   mux3_32  load_data_c_mux (.out(load_data_c[31:0]),
                             .in2 (icu_diag_data_c[31:0]),
                             .in1 (dcu_diag_data_c[31:0]),
                             .in0 (dcu_data_c[31:0]),
                             .sel (load_data_c_mux_sel[2:0]));

   /*
    * The following logic handles this problem:
    *
    * E stage | C stage | W stage
    *  ucode  |   LD1   |   LD2
    *
    * ucode in E wants to use the result of LD2 (through forwarding), but LD1
    * will overwrite the register with its result.
    */

   ff_se_32 load_buffer_reg(.out    (load_buffer_reg_out[31:0]),
			    .din    (load_data_c[31:0]),
			    .enable (dcu_data_reg_we[1]),
			    .clk    (clk)
			    );
   mux2_32 load_buffer_mux(.out	(load_buffer_mux_out[31:0]),
			   .in1	(load_buffer_reg_out[31:0]),
			   .in0	(load_data_c[31:0]),
			   .sel (load_buffer_mux_sel[1:0])
			   );
   ff_se_32 dcu_data_reg(.out	 (dcu_data_w[31:0]),
			 .din	 (load_buffer_mux_out[31:0]),
			 .enable (dcu_data_reg_we[0]),
			 .clk	 (clk)
			 );
			 
// output to ex_ctl as the lockbit used in monitorenter

   assign load_buffer_mux_out_0 = load_buffer_mux_out[0];	
	
   /*****************************
    *				*
    *		W stage		*
    *				*
    *****************************/

// Because of timing reasons, we have moved the mux selects for 
// Rs1 and Rs2 into data path only 

   ff_se_2 for_w_flop(.out (forward_data_w_mux_sel[1:0]),
                                      .din (forward_w_sel_din[1:0]),
                                      .enable (~hold_c),
                                      .clk (clk)
                                       );

   mux2_32 forward_data_w_mux(.out (forward_data_w[31:0]),
			      .in1 (dcu_data_w[31:0]),
			      .in0 (alu_out_c_d1[31:0]),
			      .sel (forward_data_w_mux_sel[1:0])
			      );
   assign alu_out_w = forward_data_w;
   ff_s_32 forward_data_w_reg(.out (forward_data_w1[31:0]),
			      .din (forward_data_w[31:0]),
			      .clk (clk)
			      );

   /*****************************
    *				*
    *		W1 stage	*
    *				*
    *****************************/

endmodule // ex_dpath
