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

module ex_ctl(

// Input from IU
	inst_valid,
	iu_smiss,	
	sc_dcache_req,
	lduse_bypass,
	first_cyc_r,
	first_cyc_e,
	second_cyc_r,
	hold_e,
	hold_c,
	iu_addr_e,
	zero_addr_e,
	iu_addr_c,
	reissue_c,
	kill_inst_e,
	iu_trap_r,
	iu_trap_c,
	iu_data_vld,
	icu_data_vld,
	sc_data_vld,
	rs1_bypass_mux_out,
	pj_resume,
	trap_in_progress,

// Output to IU
	ucode_busy_e,
	wr_optop_e,
	iu_sbase_we,
	ret_optop_update,
	iu_brtaken_e,
	branch_taken_e,
	priv_inst_r,
	illegal_op_r,
	mis_align_c,
	emulated_trap_r,
	opcode_1_op_c,
	soft_trap_r,
	fpu_op_r,
	async_error,
	mem_prot_error_c,
	data_brk1_c,
	data_brk2_c,
	inst_brk1_r,
	inst_brk2_r,
	lock_count_overflow_e,
	lock_enter_miss_e,
	lock_exit_miss_e,
	lock_release_e,
	null_ptr_exception_e,
	priv_powerdown_e,
	priv_reset_e,
	all_load_c,
	icu_diag_ld_c,
	zero_trap_e,
	iu_bypass_rs1_e,
	iu_bypass_rs2_e,

// Output to DCU and ICU
	iu_inst_e,
	iu_dcu_flush_e,
	iu_icu_flush_e, 
	iu_zero_e,
	iu_special_e,
	iu_d_diag_e,
	iu_i_diag_e,

// Input from IFU
	opcode_1_op_r,
	opcode_2_op_r,
	valid_op_r,

// Input from ucode
	ucode_done,
	ucode_reg_wr,
	ucode_reg_rd,
	ucode_dcu_req,
	alu_adder_fn,
	mem_adder_fn,

// Input from E stage
	cmp_gt_e,
	cmp_eq_e,
	cmp_lt_e,
	null_objref_e,
	carry_out_e,
	psr_cac,
	psr_ace,
	psr_dce,
	psr_ice,
	psr_fle,
	psr_su,
	psr_drt,
	brk12c_brkm2,
	brk12c_brkm1,
	brk12c_subk2,
	brk12c_srcbk2,
	brk12c_brken2,
	brk12c_subk1,
	brk12c_srcbk1,
	brk12c_brken1,
	smu_ld,
	smu_st,
	range1_l_cmp1_lt,
	range1_h_cmp1_gt,
	range1_h_cmp1_eq,
	range2_l_cmp1_lt,
	range2_h_cmp1_gt,
	range2_h_cmp1_eq,
	range1_l_cmp2_lt,
	range1_h_cmp2_gt,
	range1_h_cmp2_eq,
	range2_l_cmp2_lt,
	range2_h_cmp2_gt,
	range2_h_cmp2_eq,
	data_brk1_31_13_eq,
	data_brk1_11_4_eq,
	data_brk1_misc_eq,
	data_brk2_31_13_eq,
	data_brk2_11_4_eq,
	data_brk2_misc_eq,
	inst_brk1_31_13_eq,
	inst_brk1_11_4_eq,
	inst_brk1_misc_eq,
	inst_brk2_31_13_eq,
	inst_brk2_11_4_eq,
	inst_brk2_misc_eq,
	la0_hit,
	lc0_eq_255,
	lc0_eq_0,
	lc0_m1_eq_0,
	lockwant0,
	lc0_co_bit,
	la0_null_e,
	la1_hit,
	lc1_eq_255,
	lc1_eq_0,
	lc1_m1_eq_0,
	lockwant1,
	lc1_co_bit,
	la1_null_e,
	
/******************** monitor caching change  *****************/	
	lockbit,

// Output to ex_dpath and ex_regs
	
	lock0_cache,
	lock1_cache,
	lock0_uncache,
	lock1_uncache,
	carry_in_e,
	mul_e,
	div_e,
	rem_e,
	shift_dir_e,
	shift_sel,
	sign_e,
	shift_count_e,
	lc0_count_reg_we,
	lc1_count_reg_we,
	priv_update_optop,
	dcu_data_reg_we,

	bit_cvt_mux_sel,
	alu_out_mux_sel,
	adder2_src1_mux_sel,
	adder2_src2_mux_sel,
	iu_data_mux_sel,
	reg_rd_mux_sel,
	reg_wr_mux_sel,
	load_data_c_mux_sel,
	fpu_mux_sel,
	forward_w_sel_din,
	cmp_mux_sel,
	adder_src1_mux_sel,
	adder_src2_mux_sel,
	bit_mux_sel,
	cvt_mux_sel,
	shifter_src1_mux_sel,
	shifter_src2_mux_sel,
	shifter_word_sel,
	constant_mux_sel,
	iu_br_pc_mux_sel,
	offset_mux_sel,
	lc0_din_mux_sel,
	lc1_din_mux_sel,
	adder2_carry_in,
	wr_optop_mux_sel,
	load_buffer_mux_sel,
	monitorenter_e,

	      reset_l,
	      clk,
	      sm,
	      sin,
	      so
	      );

   // Input signals from IU
   input [2:0]  inst_valid;	// Valid bits for the pipe to keep
				// track of instructions 0=E, 1=C and 2=W
   input 	iu_smiss;	// Stack cache miss 
   input	lduse_bypass;	// Need to bypass data for lduse
   input 	sc_dcache_req;	// Stack cache miss request to DCU 
   input 	first_cyc_r;	// Signal for 1st cycle of long operations 
   input 	second_cyc_r;	// Signal for 2nd cycle of long operations   
   input 	hold_e;		// Signal to tell ex to hold in E stage	 
   input 	hold_c;		// Signal to tell ex to hold in C stage	 
   input 	reissue_c;	// Re-issue the same instruction
   input 	kill_inst_e;	// kill any dcu requests/priv writes
   input	iu_trap_r;	// Indicates a trap in R stage.building frame
   input	iu_trap_c;	// Indicates a trap occurred in C stage
   input 	iu_data_vld;	// DCU indicates valid data has been returned
   input	icu_data_vld;	// I$ diagnostic data is available.
   input 	sc_data_vld;	// Similar to above but it's caused by S$ miss
   input [30:28]iu_addr_e;	// Address bits 30-28 at E stage for NC and OE  
   input [29:28]zero_addr_e;	// Address bits 30-28 at E stage for NC and OE  
   input [1:0] 	iu_addr_c;	// Address bits 1-0 at C stage for alignment  
   input [7:0] 	opcode_1_op_r;	// 1st byte of the opcode
   input [7:0] 	opcode_2_op_r;	// 2nd byte of the opcode
   input 	valid_op_r;	// This indicates whether the opcode
				// is valid or not
   input [5:0] 	rs1_bypass_mux_out;	// To calculate shift_count_e
   input	pj_resume;	// PJ RESUME signal for break points
   input	trap_in_progress;	// Indicates trap status

   // Input from ucode
   input 	ucode_done;	// ucode is using all the muxes
   input [2:0] 	ucode_reg_wr;	// write ucode_porta to priv registers 
   input [2:0] 	ucode_reg_rd;	// Read priv registers to stack cache 
   input [1:0] 	ucode_dcu_req;	// Ucode dcu request 
   input [1:0] 	alu_adder_fn;	// Ucode using adder 
   input [1:0] 	mem_adder_fn;	// Ucode using mem adder 

   // Input from E stage
   input 	cmp_gt_e;		// GT output of dpath comparator
   input 	cmp_lt_e;		// LT output of dpath comparator
   input 	cmp_eq_e;		// EQ output of dpath comparator
   input 	null_objref_e;		// ucode_porta_mux_out (Rs1) == zero
   input 	carry_out_e;		// Carry output of dpath ALU adder
   input 	psr_cac;		// PSR.CAC bit
   input 	psr_ace;		// PSR.ACE bit
   input 	psr_dce;		// PSR.DCE bit
   input 	psr_ice;		// PSR.ICE bit
   input 	psr_fle;		// PSR.FLE bit
   input 	psr_su;			// PSR.SU  bit
   input 	psr_drt;		// PSR.DRT  bit
   input [6:0]	brk12c_brkm2;		// BRK12C.BRKM2 bits
   input [6:0]	brk12c_brkm1;		// BRK12C.BRKM1 bits
   input 	brk12c_subk2;		// BRK12C.SUBK2 bits
   input [1:0]	brk12c_srcbk2;		// BRK12C.SRCBK2 bits
   input 	brk12c_brken2;		// BRK12C.BRKEN2 bits
   input 	brk12c_subk1;		// BRK12C.SUBK1 bits
   input [1:0]	brk12c_srcbk1;		// BRK12C.SRCBK1 bits
   input 	brk12c_brken1;		// BRK12C.BRKEN1 bits
   input 	smu_ld;			// Input from cpu.v
   input 	smu_st;			// Input from cpu.v
   input 	range1_l_cmp1_lt;	// iu_addr_c < userrange1.userlow
   input 	range1_h_cmp1_gt;	// iu_addr_c > userrange1.userhigh
   input 	range1_h_cmp1_eq;	// iu_addr_c = userrange1.userhigh
   input 	range2_l_cmp1_lt;	// iu_addr_c < userrange2.userlow
   input 	range2_h_cmp1_gt;	// iu_addr_c > userrange2.userhigh
   input 	range2_h_cmp1_eq;	// iu_addr_c = userrange2.userhigh
   input 	range1_l_cmp2_lt;	// optop_c < userrange1.userlow
   input 	range1_h_cmp2_gt;	// optop_c > userrange1.userhigh
   input 	range1_h_cmp2_eq;	// optop_c = userrange1.userhigh
   input 	range2_l_cmp2_lt;	// optop_c < userrange2.userlow
   input 	range2_h_cmp2_gt;	// optop_c > userrange2.userhigh
   input 	range2_h_cmp2_eq;	// optop_c = userrange2.userhigh
   input 	data_brk1_31_13_eq;	// iu_addr_c[31:13] == brk1a[31:13]
   input 	data_brk1_11_4_eq;	// iu_addr_c[11:4]  == brk1a[11:4]
   input [4:0] 	data_brk1_misc_eq;	// iu_addr_c[12,3:0]== brk1a[12,3:0]
   input 	data_brk2_31_13_eq;	// iu_addr_c[31:13] == brk2a[31:13]
   input 	data_brk2_11_4_eq;	// iu_addr_c[11:4]  == brk2a[11:4]
   input [4:0] 	data_brk2_misc_eq;	// iu_addr_c[12,3:0]== brk2a[12,3:0]
   input 	inst_brk1_31_13_eq;	// pc_r[31:13] == brk1a[31:13]
   input 	inst_brk1_11_4_eq;	// pc_r[11:4]  == brk1a[11:4]
   input [4:0] 	inst_brk1_misc_eq;	// pc_r[12,3:0]== brk1a[12,3:0]
   input 	inst_brk2_31_13_eq;	// pc_r[31:13] == brk2a[31:13]
   input 	inst_brk2_11_4_eq;	// pc_r[11:4]  == brk2a[11:4]
   input [4:0] 	inst_brk2_misc_eq;	// pc_r[12,3:0]== brk2a[12,3:0]
   input 	la0_hit;		// 1 if lockaddr0 == objref in data_in
   input 	lc0_eq_255;		// 1 if lockcount0   == 255, 0 otherwise
   input 	lc0_eq_0;		// 1 if lockcount0   ==   0, 0 otherwise
   input 	lc0_m1_eq_0;		// 1 if lockcount0-1 ==   0, 0 otherwise
   input 	lockwant0;		// Bit 14 of lockcount0 register
   input 	lc0_co_bit;		// Bit 15 of lockcount0 register
   input        la0_null_e;		// 1 if lockaddr0 == 0, 0 otherwise
   input 	la1_hit;		// 1 if lockaddr1 == objref in data_in
   input 	lc1_eq_255;		// 1 if lockcount1   == 255, 0 otherwise
   input 	lc1_eq_0;		// 1 if lockcount1   ==   0, 0 otherwise
   input 	lc1_m1_eq_0;		// 1 if lockcount1-1 ==   0, 0 otherwise
   input 	lockwant1;		// Bit 14 of lockcount1 register
   input	lc1_co_bit;		// Bit 15 of lockcount0 register
   input        la1_null_e;		// 1 if lockaddr1 == 0, 0 otherwise
   input	lockbit;		// bit 0 of dcu_data_c	

  // Output from ex_decode.v
   output 	 illegal_op_r;		// Unused extended opcodes

   // Output signals to IU
   output	 ucode_busy_e;		// UCODE is busy
   output 	 wr_optop_e;		// Tell IU it is a write_optop
   output	 iu_sbase_we;		// Write enable signal to SMU, whenever there's 
					// wr_sbase  etc.
   output 	 ret_optop_update;	// Tell IU it is a write_optop due to return
   output 	 iu_brtaken_e;		// Tell IU if branch taken 
   output	 branch_taken_e;	// internal signal in IU
   output 	 priv_inst_r;		// Privileged instructions
   output 	 mis_align_c;		// Mis_aligned exception
   output 	 emulated_trap_r;	// Emulated trap
   output [7:0]  opcode_1_op_c;		// Opcode at C stage
   output 	 soft_trap_r;		// Soft_trap in R stage
   output 	 fpu_op_r;		// FPU opcode in R stage
   output 	 async_error;		// asynchronous_error due to smu access
   output 	 mem_prot_error_c;	// mem_protection_error  in C stage
   output 	 data_brk1_c;		// Data breakpoint1 exception in C stage
   output 	 data_brk2_c;		// Data breakpoint2 exception in C stage
   output 	 inst_brk1_r;		// Inst breakpoint1 exception in R stage
   output 	 inst_brk2_r;		// Inst breakpoint2 exception in R stage
   output 	 lock_count_overflow_e;	// LockCountOverFlowTrap in E stage
   output 	 lock_enter_miss_e;	// LockEnterMissTrap	 in E stage
   output 	 lock_exit_miss_e;	// LockExitMissTrap	 in E stage
   output 	 lock_release_e;	// LockReleaseTrap	 in E stage
   output 	 null_ptr_exception_e;	// runtime_NullPtrException in E stage
   output 	 priv_powerdown_e;	// prive_powerdown instruction in E stage 
   output 	 priv_reset_e;		// prive_reset instruction in E stage 
   output 	 all_load_c;		// There is a load in C stage
   output	 icu_diag_ld_c;		// ICU Diagnostic load in C stage
   output 	 zero_trap_e;		// Take zero_line e-trap in E stage 
   output 	 iu_bypass_rs1_e;	// RS1 need bypass 
   output 	 iu_bypass_rs2_e;	// RS2 need bypass 
   output	 first_cyc_e;		// First cycle in EStage for two cycle instn.

   // Output to DCU
   output [7:0]  iu_inst_e;		// [7] =  non allocating
					// [6] =  opposite endiannes
					// [5] =  signed
					// [4] =  noncacheable
					// [3] =  store
					// [2] =  load
					// [1:0] = size
   output 	 iu_zero_e;		// cache zero line 
   output	 iu_special_e;		// dcu related special inst in E
   output [3:0]  iu_d_diag_e;		// [3] =  Dcache RAm Write
					// [2] =  Dcache Ram Read
					// [1] =  DTag	Write
					// [0] =  Dtag	Read
   output [3:0]  iu_i_diag_e;		// [3] =  Icache RAm Write
					// [2] =  Icache Ram Read
					// [1] =  ITag	Write
					// [0] =  Itag	Read
   output [2:0]  iu_dcu_flush_e;	// Signal to DCU for cache_flush [2],
					// cache_index_flush [1] and 
					// cache_invaliddate [0] 

   // Output to ICU
   output 	 iu_icu_flush_e;	// Signal to ICU for cache_flush,
					// cache_index_flush and cache_invaliddate 

   // E stage control signals
   output	 lock0_cache;		// control signal to cache a lock in lock pair 0
   output	 lock1_cache;		// control signal to cache a lock in lock pair 1
   output	 lock0_uncache;		// control signal to uncache a lock in lock pair 0
   output	 lock1_uncache;		// control signal to uncache a lock in lock pair 1
   output 	 carry_in_e;		// carry_in bit to adder
   output 	 mul_e;			// IMDR:	 multiplication
   output 	 div_e;			// IMDR:	 division
   output 	 rem_e;			// IMDR:	 remainder
   output 	 shift_sel;		// Shifter:	 0: left, 1: right
   output 	 sign_e;		// Shifter & Converter: sign extension
   output [5:0]  shift_count_e;		// Shifter: # of bits to shift
   output 	 lc0_count_reg_we;	// Write enable of lockcount0_count_reg
					// in ex_regs
   output 	 lc1_count_reg_we;	// Write enable of lockcount1_count_reg
					// in ex_regs
   output 	 priv_update_optop;	// Indicates priv_update_optop in R
   output [1:0]	 dcu_data_reg_we;	// The load buffer register write enables


   output [1:0]  bit_cvt_mux_sel;	// 1: bit operator output
					// 0: converter output

   output [7:0]  alu_out_mux_sel;	// 7: constant_mux_out 
					// 6: imdr_data
					// 5: reg_rd_mux_out
					// 4: bit_cvt_mux_out
					// 3: shifter output
					// 2: adder output
					// 1: ucode_portc
					// 0: bypass
						 
   output  adder2_src1_mux_sel;	
						 
   output [3:0]  adder2_src2_mux_sel;	 // 0: ~u_m_adder_portb
   	 				 // 1: u_m_adder_portb
					 // 2: offset_e
					 // 3: zero
						 
   output [1:0]  iu_data_mux_sel;	 // 1: ucode_portc  
					 // 0: rs2_bypass_mux_out
						 
   output [20:0] reg_rd_mux_sel;	 // 20: 0x80000: SC_BOTTOM
					 // 19: 0x40000: HCR
					 // 18: 0x20000: VERSIONID
					 // 17: 0x10000: USERRANGE2
					 // 16: 0x08000: BRK12C
					 // 15: 0x04000: BRK2A
					 // 14: 0x02000: BRK1A
					 // 13: 0x01000: GC_CONFIG
					 // 12: 0x00800: USERRANGE1
					 // 11: 0x00400: LOCKADDR1
					 // 10: 0x00200: LOCKADDR0
					 // 9:	0x00100: LOCKCOUNT1
					 // 8:	0x00080: LOCKCOUNT0
					 // 7:	0x00040: TRAPBASE
					 // 6:	0x00020: PSR
					 // 5:	0x00010: CONST_POOL
					 // 4:	0x00008: OPLIM
					 // 3:	0x00004: OPTOP
					 // 2:	0x00002: FRAME
					 // 1:	0x00001: VARS
					 // 0:	0x00000: PC

   output [18:0]  reg_wr_mux_sel;	/* bit 18, 0x40000: SC_BOTTOM
					 * bit 17, 0x20000: USERRANGE2
					 * bit 16, 0x10000: BRK12C
					 * bit 15, 0x08000: BRK2A
					 * bit 14, 0x04000: BRK1A
					 * bit 13, 0x02000: GC_CONFIG
					 * bit 12, 0x01000: USERRANGE1
					 * bit 11, 0x00800: LOCKADDR1
					 * bit 10, 0x00400: LOCKADDR0
					 * bit  9, 0x00200: LOCKCOUNT1
					 * bit  8, 0x00100: LOCKCOUNT0
					 * bit  7, 0x00080: TRAPBASE
					 * bit  6, 0x00040: PSR
					 * bit  5, 0x00020: CONST_POOL
					 * bit  4, 0x00010: OPLIM
					 * bit  3, 0x00008: OPTOP
					 * bit  2, 0x00004: FRAME
					 * bit  1, 0x00002: VARS
					 * bit  0, 0x00001: PC
					 */
   output [2:0]  load_data_c_mux_sel;	// 2: icu_diag_data_c
					// 1: dcu_diag_data_c
					// 0: dcu_data


   output [1:0]  fpu_mux_sel;		// 1: fpu_data_e
					// 0: alu_out_e

   output [1:0]  forward_w_sel_din;// 1: output of dcu_hold register 
					// 0: alu_out_c_d1

   output [2:0]  cmp_mux_sel;		// 1: Rs1, zero
					// 0: ~Rs1, Rs2

   output [1:0]  adder_src1_mux_sel;	// 1: ~Rs1
					// 0: Rs1

   output [2:0]  adder_src2_mux_sel;	// 2: zero
					// 1: ~Rs2
					// 0: Rs2

   output [4:0]  bit_mux_sel;		// 4: rs1_bypass_mux_out with bit 31
					//    flipped to support fneg and dneg
					// 3: pc_r 
					// 2: xor
					// 1: and
					// 0: or

   output [4:0]  cvt_mux_sel;		// 4: i2s
					// 3: i2c
					// 2: i2b
					// 1: i2l
					// 0: sethi
   output 	 shift_dir_e;		// Shifter:	 0: left, 1: right

   output [4:0]  shifter_src1_mux_sel;	/* 16: rs2_bypass_mux_out_d1
					 *  8: {32{rs2_bypass_mux_out[31]}}
					 *  4: rs2_bypass_mux_out
					 *  2: rs1_bypass_mux_out
					 *  1: zero
					 */
   output [2:0]  shifter_src2_mux_sel;	/* 4: rs2_bypass_mux_out_d1
					 * 2: rs2_bypass_mux_out
					 * 1: zero
					 */
   output 	 shifter_word_sel;	// 1: MSW
					// 0: LSW

   output [2:0]  constant_mux_sel;	// 2:	1 -- gt
					// 1:	0 -- eq
					// 0: -1 -- lt

   output [2:0]  iu_br_pc_mux_sel;	// 2: ucode_porta_e
					// 1: pc_c
					// 0: adder2 output

   output [4:0]  offset_mux_sel;	/* 16: 32-bit offset for ld/st index
					 *  8: 16-bit offset for ld/st index
					 *  4:  8-bit offset for ld/st index
					 *  2: opcode_e (32-bit offset)
					 *  1: offset16 (16-bit offset)
					 */

   output [3:0]  lc0_din_mux_sel;	/* 4: lc0_p1
					 * 2: lc0_m1
					 * 1: data_in from priv_write_lockcount0
					 */
   output [3:0]  lc1_din_mux_sel;	/* 4: lc1_p1
					 * 2: lc1_m1
					 * 1: data_in from priv_write_lockcount1
					 */

   output	 adder2_carry_in;	// Carry input to the address adder

   output [1:0]  wr_optop_mux_sel;      // 1: vars_out
                                        // 0: ucode_porta_mux_out
   output [1:0]  load_buffer_mux_sel;	/* 2: load_buffer_reg_out (in state 2)
					 * 1: dcu_data_c (otherwise)
					 */

   // Miscellaneous global signals
   input 	 reset_l;
   input 	 clk;
   input 	 sm;			// Scan enable
   input 	 sin;			// Scan data input
   output 	 so;			// Scan data output

wire data_brk1_c_int, data_brk2_c_int;
wire nop,
  aconst_null,
  iconst_m1,
  iconst_0,
  iconst_1,
  iconst_2,
  iconst_3,
  iconst_4,
  iconst_5,
  lconst_0,
  lconst_1,
  fconst_0,
  fconst_1,
  fconst_2,
  dconst_0,
  dconst_1,
  bipush,
  sipush,
  ldc,
  ldc_w,
  ldc2_w,
  iload,
  lload,
  fload,
  dload,
  aload,
  iload_0,
  iload_1,
  iload_2,
  iload_3,
  lload_0,
  lload_1,
  lload_2,
  lload_3,
  fload_0,
  fload_1,
  fload_2,
  fload_3,
  dload_0,
  dload_1,
  dload_2,
  dload_3,
  aload_0,
  aload_1,
  aload_2,
  aload_3,
  iaload,
  laload,
  faload,
  daload,
  aaload,
  baload,
  caload,
  saload,
  istore,
  lstore,
  fstore,
  dstore,
  astore,
  istore_0,
  istore_1,
  istore_2,
  istore_3,
  lstore_0,
  lstore_1,
  lstore_2,
  lstore_3,
  fstore_0,
  fstore_1,
  fstore_2,
  fstore_3,
  dstore_0,
  dstore_1,
  dstore_2,
  dstore_3,
  astore_0,
  astore_1,
  astore_2,
  astore_3,
  aastore_quick,
  iastore,
  lastore,
  fastore,
  dastore,
  aastore,
  bastore,
  castore,
  sastore,
  pop,
  pop2,
  dup,
  dup_x1,
  dup_x2,
  dup2,
  dup2_x1,
  dup2_x2,
  swap,
  iadd,
  ladd,
  fadd,
  dadd,
  isub,
  lsub,
  fsub,
  dsub,
  imul,
  lmul,
  fmul,
  dmul,
  idiv,
  ldiv,
  fdiv,
  ddiv,
  irem,
  lrem,
  frem,
  drem,
  ineg,
  lneg,
  fneg,
  dneg,
  ishl,
  lshl,
  ishr,
  lshr,
  iushr,
  lushr,
  iand,
  land,
  ior,
  lor,
  ixor,
  lxor,
  iinc,
  i2l,
  i2f,
  i2d,
  l2i,
  l2f,
  l2d,
  f2i,
  f2l,
  f2d,
  d2i,
  d2l,
  d2f,
  int2byte,
  int2char,
  int2short,
  lcmp,
  fcmpl,
  fcmpg,
  dcmpl,
  dcmpg,
  ifeq,
  ifne,
  iflt,
  ifge,
  ifgt,
  ifle,
  if_icmpeq,
  if_icmpne,
  if_icmplt,
  if_icmpge,
  if_icmpgt,
  if_icmple,
  if_acmpeq,
  if_acmpne,
  goto,
  jsr,
  ret,
  tableswitch,
  lookupswitch,
  ireturn,
  lreturn,
  freturn,
  dreturn,
  areturn,
  return,
  getstatic,
  putstatic,
  getfield,
  putfield,
  invokevirtual,
  invokenonvirtual,
  invokestatic,
  invokeinterface,
  new,
  newarray,
  anewarray,
  arraylength,
  athrow,
  checkcast,
  instanceof,
  monitorenter,
  monitorexit,
  wide,
  multianewarray,
  ifnull,
  ifnonnull,
  goto_w,
  jsr_w,
  breakpoint,
  ldc_quick,
  ldc_w_quick,
  ldc2_w_quick,
  getfield_quick,
  putfield_quick,
  getfield2_quick,
  putfield2_quick,
  getstatic_quick,
  putstatic_quick,
  getstatic2_quick,
  putstatic2_quick,
  invokevirtual_quick,
  invokenonvirtual_quick,
  invokesuper_quick,
  invokestatic_quick,
  invokeinterface_quick,
  invokevirtualobject_quick,		// Not supported 
  invokeignored_quick,
  new_quick,
  anewarray_quick,
  multianewarray_quick,
  checkcast_quick,
  instanceof_quick,
  invokevirtual_quick_w,
  getfield_quick_w,
  putfield_quick_w,
  nonnull_quick,		// Not supported 
  agetfield_quick,
  aputfield_quick,
  agetstatic_quick,
  aputstatic_quick,
  aldc_quick,
  aldc_w_quick,
  exit_sync_method,
  sethi,
  load_word_index,
  load_short_index,
  load_char_index,
  load_byte_index,
  load_ubyte_index,
  store_word_index,
  nastore_word_index,
  store_short_index,
  store_byte_index,
  hardware ;

// Exented bytecodes
  wire	load_ubyte,
	load_byte,
	load_char,
	load_short,
	load_word,
	priv_ret_from_trap,
	priv_read_dcache_tag,
	priv_read_dcache_data,
	load_char_oe,
	load_short_oe,
	load_word_oe,
	return0,
	priv_read_icache_tag,
	priv_read_icache_data,
	ncload_ubyte,
	ncload_byte,
	ncload_char,
	ncload_short,
	ncload_word,
	iucmp,
	priv_powerdown,
	cache_invalidate,
	ncload_char_oe,
	ncload_short_oe,
	ncload_word_oe,
	return1,
	cache_flush,
	cache_index_flush,
	store_byte,
	store_short,
	store_word,
	soft_trap,
	priv_write_dcache_tag,
	priv_write_dcache_data,
	store_short_oe,
	store_word_oe,
	return2,
	priv_write_icache_tag,
	priv_write_icache_data,
	ncstore_byte,
	ncstore_short,
	ncstore_word,
	priv_reset,
	get_current_class,
	ncstore_short_oe,
	ncstore_word_oe,
	call,
	zero_line,
	read_pc,
	read_vars,
	read_frame,
	read_optop,
	priv_read_oplim,
	read_const_pool,
	priv_read_psr,
	priv_read_trapbase,
	priv_read_lockcount0,	
	priv_read_lockcount1,	
	priv_read_lockaddr0,
	priv_read_lockaddr1,
	priv_read_userrange1,
	priv_read_gc_config,
	priv_read_brk1a,
	priv_read_brk2a,
	priv_read_brk12c,
	priv_read_userrange2,
	priv_read_versionid,
	priv_read_hcr,
	priv_read_sc_bottom,
	read_global0,
	read_global1,
	read_global2,
	read_global3,
	write_pc,
	write_vars,
	write_frame,
	write_optop,
	priv_write_oplim,
	write_const_pool,
	priv_write_psr,
	priv_write_trapbase,
	priv_write_lockcount0,	
	priv_write_lockcount1,	
	priv_write_lockaddr0,
	priv_write_lockaddr1,
	priv_write_userrange1,
	priv_write_gc_config,
	priv_write_brk1a,
	priv_write_brk2a,
	priv_write_brk12c,
	priv_write_userrange2,
	priv_write_sc_bottom,
	write_global0,
	write_global1,
	write_global2,
	write_global3;

  wire	[255:0]		decodeout_1;	// Decode signals from JVM opcode[7:0]
  wire	[255:0]		decodeout_2;	// Decode signals from exented opcode[7:0]

  // R stage control signals
  wire monitorenter_r, monitorexit_r, carry_in_r;
  wire monitorenter_raw_e, monitorexit_raw_e, carry_in_raw_e;
  wire mul_r, div_r, rem_r, shift_sel_r, sign_r; 
  wire mul_raw_e, div_raw_e, rem_raw_e, shift_sel_raw; 
  wire sign_raw_e; 
  wire priv_reset_raw_e, priv_powerdown_raw_e;
  wire [1:0] bit_cvt_mux_sel_r;
  wire [7:0] alu_out_mux_sel_r; 
  wire [7:0] alu_out_mux_sel_raw_e; 
  wire adder2_src1_mux_sel_r;
  wire [1:0] iu_data_mux_sel_r;
  wire [4:0] offset_mux_sel_r;
  wire [20:0] reg_rd_mux_sel_r;
  wire [20:0] reg_rd_mux_sel_raw_e;
  wire [18:0] reg_wr_mux_sel_r;
  wire [18:0] reg_wr_mux_sel_raw_e;
  wire [18:0] reg_wr1_mux_sel;		/* reg_wr_mux_sel before qualified with
					 * inst_valid[0] and ~iu_trap_c
					 */
  wire [2:0] load_data_mux_sel_r;
  wire [2:0] load_data_mux_sel_e;
  wire [2:0] cmp_mux_sel_r;
  wire [1:0] adder_src1_mux_sel_r;
  wire [1:0] adder_src1_mux_sel_raw_e;
  wire       adder_src2_mux_sel_r;
  wire [4:0] bit_mux_sel_r;
  wire [4:0] cvt_mux_sel_r;  
  wire shift_dir_r, shift_dir_raw_e;
  wire [4:0] shifter_src1_mux_sel_r;
  wire [2:0] shifter_src2_mux_sel_r;
  wire all_load_c_raw, all_load_e;  // There is a load in W stage
  wire ucode_busy_r;
  wire[4:0] branch_qual;
  wire shifter_word_sel_r;
  wire ucode_busy_c;
  wire invalid_op_r;
  wire iu_bypass_rs1_r, iu_bypass_rs2_r;
  wire iu_bypass_rs1, iu_bypass_rs2;
  wire [1:0] forward_data_w_mux_sel_c;

  // Ucode signals
  wire	ucode_rd_psr_e;			// ucode_reg_rd[2:0] = 0x1
  wire	ucode_rd_vars_e;		// ucode_reg_rd[2:0] = 0x2
  wire	ucode_rd_frame_e;		// ucode_reg_rd[2:0] = 0x3
  wire	ucode_rd_const_p_e;		// ucode_reg_rd[2:0] = 0x4
  wire	ucode_rd_port_c_e;		// ucode_reg_rd[2:0] = 0x5
  wire	ucode_rd_dcache_e;		// ucode_reg_rd[2:0] = 0x6
  wire	ucode_rd_dcache_c;		// ucode_reg_rd[2:0] = 0x6 in C stage
  wire	ucode_rd_part_dcache_e;		// ucode_reg_rd[2:0] = 0x7
  wire	ucode_rd_part_dcache_c;		// ucode_reg_rd[2:0] = 0x7 in C stage
  wire	ucode_wr_pc_e;			// ucode_reg_wr[2:0] = 0x1
  wire	ucode_wr_vars_e;		// ucode_reg_wr[2:0] = 0x2
  wire	ucode_wr_frame_e;		// ucode_reg_wr[2:0] = 0x3
  wire	ucode_wr_const_p_e;		// ucode_reg_wr[2:0] = 0x4
  wire	ucode_wr_optop_e;		// ucode_reg_wr[2:0] = 0x5
  wire	ucode_wr_vars_optop_e;		// ucode_reg_wr[2:0] = 0x6
  wire	ucode_wr_psr_e;			// ucode_reg_wr[2:0] = 0x7

  // R stage control signals to IU 
  wire ucode_op_r;		// ucode opcodes
  wire [7:0] opcode_1_op_e;	// Opcode in E stage
  wire illegal_op_raw_r;	// Illegal instruction in R stage 

  // R stage control signals to DCU and IU
  wire wr_optop_r;		// Tell IU that OPTOP will be written 
  wire wr_optop_raw_e;		 
  wire [7:0] iu_inst_r;		
  wire data_brk1_e, data_brk2_e;
  wire [7:0] iu_inst_raw_e;		
  wire [7:0] iu_inst_raw;		
  wire [7:0] ucode_inst_e;		
  wire array_load_e;
  wire [1:0] iu_inst_e_mux_sel;
  wire iu_icu_flush_r;
  wire iu_icu_flush_raw_e;
  wire [2:0] iu_dcu_flush_r;
  wire [2:0] iu_dcu_flush_raw_e;
  wire iu_zero_r, iu_zero_raw_e;
  wire [3:0] iu_d_diag_r;
  wire [3:0] iu_i_diag_r;
  wire [3:0] iu_d_diag_raw_e;
  wire [3:0] iu_i_diag_raw_e;

  // E stage instruction signals
  wire ifeq_e, if_icmpeq_e, if_acmpeq_e, ifge_e, if_icmpge_e, ifle_e,ucode_st_e;
  wire if_icmple_e, ifnull_e, ifne_e, if_icmpne_e, if_acmpne_e;
  wire ifnonnull_e, ifgt_e, if_icmpgt_e, iflt_e, if_icmplt_e;
  wire goto_e, goto_w_e, jsr_e, jsr_w_e, ret_e, write_pc_e, all_return_e, all_return_r;
  wire baload_e,bastore_e,castore_e,caload_e,saload_e,sastore_e;
  wire ucode_read_reg_e, ret_optop_update_e;


   output       monitorenter_e;		// monitorenter
   wire       monitorexit_e;		// monitorexit
   wire       iucmp_e;			// Latched iucmp signal
   wire       lcmp_e;			// Latched lcmp signal
   wire       first_cyc_e;		// Latched first_cyc_r signal
   wire       second_cyc_e;		// Latched second_cyc_r signal
   wire       first_gt;			// lcmp first cycle -> gt
   wire       first_eq;			// lcmp first cycle -> eq
   wire       first_lt;			// lcmp first cycle -> lt
   wire       second_gt;		// lcmp second cycle -> gt
   wire       second_eq;		// lcmp second cycle -> eq
   wire       second_lt;		// lcmp second cycle -> lt
   wire       iucmp_gt;			// iucmp -> gt
   wire       iucmp_eq;			// iucmp -> eq
   wire       iucmp_lt;			// iucmp -> lt
   wire [5:0] shift_count_e1;		// Intermediate shift count
   wire [2:0] shift_count_mux_sel;	// Select for shift_count_mux
   wire	      shift_32_r;		// Indicate it's a 32-bit shift instr.
   wire	      shift_64_r;		// Indicate it's a 64-bit shift instr.
   wire	      shift_32_e;		// Latched version of shift_32_r
   wire	      shift_64_e;		// Latched version of shift_64_r
   wire       load_store_e;		// There is a ld/st to D$ in E stage
   wire       load_store_c;		// There is a ld/st to D$ in C stage
   wire	      iu_load_e;		// load in E
   wire	      iu_store_e;		// store in E
   wire       smu_access;		/* Latched smu_ld | smu_st to match
					 * smu_addr_d1
					 */
   wire       mem_prot_ldst;		/* Extended ld/st causes memory
					 * protection error exception.
					 */
   wire       mem_prot_stack;		/* Stack access causes memory
					 * protection error exception.
					 */
   wire [6:0] data_brk1_eq;		/* bit 6: [31:13]
					 * bit 5: 12
					 * bit 4: [11:4]
					 * bit 3: 3
					 * bit 2: 2
					 * bit 1: 1
					 * bit 0: 0
					 */
   wire       data_brk1_match_e;		// Asserted if data_brk1_eq[6:0]==0x7f
   wire [6:0] data_brk2_eq;		/* bit 6: [31:13]
					 * bit 5: 12
					 * bit 4: [11:4]
					 * bit 3: 3
					 * bit 2: 2
					 * bit 1: 1
					 * bit 0: 0
					 */
   wire       data_brk2_match_e;	// Asserted if data_brk2_eq[6:0]==0x7f
   wire [6:0] inst_brk1_eq;		/* bit 6: [31:13]
					 * bit 5: 12
					 * bit 4: [11:4]
					 * bit 3: 3
					 * bit 2: 2
					 * bit 1: 1
					 * bit 0: 0
					 */
   wire       inst_brk1_match;		// Asserted if inst_brk1_eq[6:0]==0x7f
   wire       inst_brk1_taken;		/* Inst breakpoint 1 will be taken after
					 * this signal is qualified with bit 31
					 * of BRK12C.
					 */
   wire [6:0] inst_brk2_eq;		/* bit 6: [31:13]
					 * bit 5: 12
					 * bit 4: [11:4]
					 * bit 3: 3
					 * bit 2: 2
					 * bit 1: 1
					 * bit 0: 0
					 */
   wire       inst_brk2_match;		// Asserted if inst_brk2_eq[6:0]==0x7f
   wire       inst_brk2_taken;		/* Inst breakpoint 2 will be taken after
					 * this signal is qualified with bit 31
					 * of BRK12C.
					 */

/******************** monitor caching change  *****************/
   wire	      monitorenter_c;		// monitorenter waits for lockbit from DCU in C stage
   wire	      la0_null_c;		// la0_null_e propagate to C stage
   wire	      la1_null_c;		// la1_null_e propagate to C stage	

   wire       lock0_enter;		// monitorenter hits on lockaddr0
   wire       lock0_exit;		// monitorexit  hits on lockaddr0
   wire       lock1_enter;		// monitorenter hits on lockaddr1
   wire       lock1_exit;		// monitorexit  hits on lockaddr1
   wire       lock0_overflow;		/* monitorenter hits on lockaddr0, and
					 * lockcount0 is 255
					 */
   wire       lock0_underflow;		/* monitorexit  hits on lockaddr0, and
					 * lockcount0 is 0
					 */
   wire       lock1_overflow;		/* monitorenter hits on lockaddr1, and
					 * lockcount1 is 255
					 */
   wire       lock1_underflow;		/* monitorexit  hits on lockaddr1, and
					 * lockcount1 is 0
					 */
   wire       lock_miss_valid;		/* monitorenter or monitorexit misses
					 * both lockaddr0 and lockaddr1,
					 * qualified with E stage inst_valid[0] 
					 */
   wire       lock0_release;		/* monitorexit hits on lockaddr0, and
					 * lockcount0 - 1 == 0, and
					 * lockwant0 (bit 14) == 1
					 */
   wire       lock1_release;		/* monitorexit hits on lockaddr1, and
					 * lockcount1 - 1 == 0, and
					 * lockwant1 (bit 14) == 1
					 */
   wire       nonnull_quick_e;		// E stage nonnull_quick signal
   wire       curr_s;			// Current state of the double-load FSM
   wire       next_s;			// Next state of the double-load FSM


  // Signals for mis-aligned exception
   wire ldst_half_word_r, ldst_word_r;	// Half word and word aligned ld/st in R
   wire ldst_half_word_e, ldst_word_e;	// Half word and word aligned ld/st in E
   wire ldst_half_word_c, ldst_word_c;	// Half word and word aligned ld/st in C
   wire data_st_e;
   wire data_brk1_vld_e,data_brk2_vld_e;
   wire offset_branch_r,offset_branch_e,fpu_op_e;
 
  // R-stage logic

  ex_decode ex_decode(
	.opcode_1_op_r (opcode_1_op_r[7:0]),
	.opcode_2_op_r (opcode_2_op_r[7:0]),
	.decodeout_1 (decodeout_1[255:0]),
	.decodeout_2 (decodeout_2[255:0]),
	.invalid_op_r (invalid_op_r),
	.illegal_op_r (illegal_op_raw_r));

  assign illegal_op_r = illegal_op_raw_r & valid_op_r;


  // Output to IU for updating optop

  assign wr_optop_r = (write_optop & first_cyc_r) | 
		      (priv_update_optop & first_cyc_r);

  ff_sre wr_optop_e_flop (.out	  (wr_optop_raw_e),
			  .din	  (wr_optop_r),
			  .enable (~hold_e),
			  .reset_l (reset_l),
			  .clk	  (clk)
			  );

  assign wr_optop_e = (wr_optop_raw_e | ucode_wr_optop_e | 
		       ucode_wr_vars_optop_e)&inst_valid[0];

  assign ret_optop_update_e = all_return_e & wr_optop_e & ~hold_c;

   ff_sr ret_optop_update_flop (.out    (ret_optop_update),
                                .din    (ret_optop_update_e),
                                .reset_l (reset_l),
                                .clk    (clk)
                                 );

   // Output to IU if branch taken or not

   ff_sre ifeq_e_flop (.out    (ifeq_e),
		       .din    (ifeq),
		       .enable (~hold_e),
		       .reset_l (reset_l),
		       .clk    (clk)
		       );
   ff_sre if_icmpeq_e_flop (.out    (if_icmpeq_e),
			    .din    (if_icmpeq),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre if_acmpeq_e_flop (.out    (if_acmpeq_e),
			    .din    (if_acmpeq),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre ifge_e_flop (.out    (ifge_e),
		       .din    (ifge),
		       .enable (~hold_e),
		       .reset_l (reset_l),
		       .clk    (clk)
		       );
   ff_sre if_icmpge_e_flop (.out    (if_icmpge_e),
			    .din    (if_icmpge),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre ifle_e_flop (.out    (ifle_e),
		       .din    (ifle),
		       .enable (~hold_e),
		       .reset_l (reset_l),
		       .clk    (clk)
		       );
   ff_sre if_icmple_e_flop (.out    (if_icmple_e),
			    .din    (if_icmple),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre ifnull_e_flop (.out	 (ifnull_e),
			 .din	 (ifnull),
			 .enable (~hold_e),
			 .reset_l (reset_l),
			 .clk	 (clk)
			 );
   ff_sre ifne_e_flop (.out    (ifne_e),
		       .din    (ifne),
		       .enable (~hold_e),
		       .reset_l (reset_l),
		       .clk    (clk)
		       );
   ff_sre if_icmpne_e_flop (.out    (if_icmpne_e),
			    .din    (if_icmpne),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre if_acmpne_e_flop (.out    (if_acmpne_e),
			    .din    (if_acmpne),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre ifnonnull_e_flop (.out    (ifnonnull_e),
			    .din    (ifnonnull),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   ff_sre ifgt_e_flop (.out    (ifgt_e),
		       .din    (ifgt),
		       .enable (~hold_e),
		       .reset_l (reset_l),
		       .clk    (clk)
		       );
   ff_sre if_icmpgt_e_flop (.out(if_icmpgt_e),
			    .din(if_icmpgt),
			    .clk(clk),
			    .enable(~hold_e),
			    .reset_l(reset_l));

   ff_sre iflt_e_flop (.out(iflt_e),
		       .din(iflt),
		       .clk(clk),
		       .enable(~hold_e),
		       .reset_l(reset_l));

   ff_sre if_icmplt_e_flop (.out(if_icmplt_e),
			    .din(if_icmplt),
			    .clk(clk),
			    .enable(~hold_e),
			    .reset_l(reset_l));

   ff_sre goto_e_flop (.out(goto_e),
		       .din(goto),
		       .clk(clk),
		       .enable(~hold_e),
		       .reset_l(reset_l));

   ff_sre goto_w_e_flop (.out(goto_w_e),
			 .din(goto_w),
			 .clk(clk),
			 .enable(~hold_e),
			 .reset_l(reset_l));

   ff_sre jsr_e_flop (.out(jsr_e),
		      .din(jsr),
		      .clk(clk),
		      .enable(~hold_e),
		      .reset_l(reset_l));

   ff_sre jsr_w_e_flop (.out(jsr_w_e),
			.din(jsr_w),
			.clk(clk),
			.enable(~hold_e),
			.reset_l(reset_l));

   ff_sre write_pc_e_flop (.out(write_pc_e),
			   .din(write_pc),
			   .clk(clk),
			   .enable(~hold_e),
			   .reset_l(reset_l));

   ff_sre ret_e_flop (.out(ret_e),
		      .din(ret),
		      .clk(clk),
		      .enable(~hold_e),
		      .reset_l(reset_l));

   ff_sre priv_powerdown_flop (.out(priv_powerdown_raw_e),
			       .din(priv_powerdown),
			       .clk(clk),
			       .enable(~hold_e),
			       .reset_l(reset_l));

   assign priv_powerdown_e = priv_powerdown_raw_e & inst_valid[0];

   ff_sre priv_reset_flop (.out(priv_reset_raw_e),
			   .din(priv_reset),
			   .clk(clk),
			   .enable(~hold_e),
			   .reset_l(reset_l));

   assign priv_reset_e = priv_reset_raw_e & inst_valid[0] & psr_su;

   assign all_return_r = ireturn | lreturn | freturn | dreturn | areturn | return 
			 | priv_ret_from_trap | return0 | return1 | return2;

   ff_sre all_return_flop (.out(all_return_e),
                           .din(all_return_r),
                           .clk(clk),
                           .enable(~hold_e),
                           .reset_l(reset_l));


// branch is asserted only when there is no hold_e due to loaduse or scache rd miss.
// this avoids asserting incorrect brtaken_e even though, there was no branch.

/***
  assign iu_brtaken_e = (((ifeq_e | if_icmpeq_e | if_acmpeq_e | ifge_e | if_icmpge_e | 
			  ifle_e | if_icmple_e | ifnull_e) & cmp_eq_e) |
			((ifne_e | if_icmpne_e | if_acmpne_e | ifnonnull_e) & ~cmp_eq_e) |
			((ifge_e | if_icmpge_e | ifgt_e | if_icmpgt_e) & cmp_gt_e) |
			((iflt_e | ifle_e | if_icmplt_e | if_icmple_e) & cmp_lt_e) |
			goto_e | goto_w_e | jsr_e | jsr_w_e | write_pc_e | ret_e) 
			& inst_valid[0]&~kill_inst_e | ucode_wr_pc_e&inst_valid[0]| reissue_c; 


***/
// Modify logic for timing purposes.

assign	branch_qual[4]	=	(ifeq_e | if_icmpeq_e | if_acmpeq_e | ifge_e | if_icmpge_e|
			        ifle_e | if_icmple_e | ifnull_e)&inst_valid[0]&~kill_inst_e;
assign	branch_qual[3]	=	(ifne_e | if_icmpne_e | if_acmpne_e | ifnonnull_e)&inst_valid[0]&~kill_inst_e;
assign	branch_qual[2]	=	(ifge_e | if_icmpge_e | ifgt_e | if_icmpgt_e)&inst_valid[0]&~kill_inst_e ;
assign	branch_qual[1]	=	(iflt_e | ifle_e | if_icmplt_e | if_icmple_e)&inst_valid[0]&~kill_inst_e ;
assign	branch_qual[0]	=	(goto_e | goto_w_e | jsr_e | jsr_w_e | write_pc_e | ret_e|ucode_wr_pc_e)&
				inst_valid[0]&~kill_inst_e;

branch_logic	branch_logic(
		.branch_qual	(branch_qual[4:0]),
                .cmp_eq_e	(cmp_eq_e),
                .cmp_gt_e	(cmp_gt_e),
                .cmp_lt_e	(cmp_lt_e),
                .reissue_c	(reissue_c),
                .sc_dcache_req	(sc_dcache_req),
                .kill_inst_e	(kill_inst_e),
                .iu_inst_raw_e	(iu_inst_raw_e[3:2]),
                .inst_valid	(inst_valid[0]),
		.ucode_busy_e	(ucode_busy_e),
                .ucode_dcu_req	(ucode_dcu_req[1:0]),
	
                .iu_brtaken_e	(iu_brtaken_e),
		.branch_taken_e	(branch_taken_e),
                .iu_inst_e	(iu_inst_e[3:2])

);

 // Output to DCU 

 assign iu_inst_r[7] = nastore_word_index;
 assign iu_inst_r[6] = load_char_oe | load_short_oe | load_word_oe |
		      ncload_char_oe | ncload_short_oe | ncload_word_oe |
		      store_short_oe | store_word_oe | ncstore_short_oe |
		      ncstore_word_oe; 
 assign iu_inst_r[5] = ~(load_char_index | load_ubyte_index |
			load_ubyte | load_char | load_char_oe |
			ncload_ubyte | ncload_char | ncload_char_oe);
 assign iu_inst_r[4] = ncload_ubyte | ncload_byte | ncload_char |
		      ncload_short | ncload_word | ncload_char_oe | 
		      ncload_short_oe | ncload_word_oe | ncstore_byte | 
		      ncstore_short | ncstore_word | ncstore_short_oe |
		      ncstore_word_oe; 
 assign iu_inst_r[3] = store_word_index | nastore_word_index | 
		      store_short_index | store_byte_index |
		      store_byte | store_short | store_word |
		      store_short_oe | store_word_oe | ncstore_byte |
		      ncstore_short | ncstore_word | ncstore_short_oe |
		      ncstore_word_oe;	
 assign iu_inst_r[2] = load_word_index | load_short_index | load_char_index |
		      load_byte_index | load_ubyte_index | load_ubyte |
		      load_byte | load_char | load_short | load_word | 
		      load_char_oe | load_short_oe | load_word_oe |
		      ncload_ubyte | ncload_byte | ncload_char |
		      ncload_short | ncload_word | ncload_char_oe |
		      ncload_short_oe | ncload_word_oe;
 // iu_inst_e[1:0] for size 2'b00 => byte, 2'b01 => half word and 2'b10 => word
 assign iu_inst_r[1] = load_word_index | store_word_index | nastore_word_index |
		      load_word | load_word_oe | ncload_word | ncload_word_oe |
		      store_word | store_word_oe | ncstore_word | 
		      ncstore_word_oe;
 assign iu_inst_r[0] = load_short_index | store_short_index | load_short |
		      load_short_oe | ncload_short | ncload_short_oe |
		      store_short | store_short_oe | ncstore_short |
		      ncstore_short_oe | load_char_index | load_char |
		      load_char_oe | ncload_char | ncload_char_oe;

  ff_sre_8	   iu_inst_e_reg (.out(iu_inst_raw_e[7:0]),
				 .din(iu_inst_r[7:0]),
				 .clk(clk),
				 .enable(~hold_e),
				 .reset_l(reset_l)
				  );

  assign iu_inst_raw[7] = iu_inst_raw_e[7] & ~sc_dcache_req; 
  assign iu_inst_raw[6] = (iu_inst_raw_e[6] ^ iu_addr_e[30]) & ~sc_dcache_req; 
  assign iu_inst_raw[5] = iu_inst_raw_e[5] | sc_dcache_req; 
  assign iu_inst_raw[4] = (iu_inst_raw_e[4] | (iu_addr_e[29] & iu_addr_e[28])) 
			  & ~sc_dcache_req ; 
  assign iu_inst_raw[1] = iu_inst_raw_e[1] | sc_dcache_req | monitorenter_e; 
  assign iu_inst_raw[0] = iu_inst_raw_e[0] & ~sc_dcache_req; 

  ff_sre_3		baload_e_reg(.out({baload_e,saload_e,caload_e}),
				     .din({baload,saload,caload}),
				     .clk(clk),
				     .enable(~hold_e),
				     .reset_l(reset_l)
				     );

  ff_sre_3                bastore_e_reg(.out({bastore_e,sastore_e,castore_e}),
                                     .din({bastore,sastore,castore}),      
                                     .clk(clk),
                                     .enable(~hold_e), 
                                     .reset_l(reset_l)
					);
  
// For ucode, when there is an array_load_e, then need to look at
// the instruction to determine the size.by default, size is word.
// need sign extension for saload and baload instructions. 

  assign array_load_e = ucode_dcu_req[1] & ucode_dcu_req[0];
  assign ucode_st_e   =  ucode_dcu_req[1] & ~ucode_dcu_req[0];

  assign ucode_inst_e[7:6] = 2'b00;
  assign ucode_inst_e[5] = saload_e | baload_e ;
  assign ucode_inst_e[4] = 1'b0 ;
  assign ucode_inst_e[1:0]= (baload_e&array_load_e | 
			bastore_e&ucode_st_e)? 2'b00:
			(saload_e|caload_e)&array_load_e | 
			(sastore_e|castore_e)&ucode_st_e?2'b01:
			2'b10 ;

  mux2_6 iu_inst_e_mux(.out ({iu_inst_e[7:4],iu_inst_e[1:0]}),
                       .in1 ({ucode_inst_e[7:4],ucode_inst_e[1:0]}),
                       .in0 ({iu_inst_raw[7:4],iu_inst_raw[1:0]}),
                       .sel (iu_inst_e_mux_sel[1:0])
                       );
 
  assign iu_inst_e_mux_sel[1] = ucode_busy_e & ~sc_dcache_req;
  assign iu_inst_e_mux_sel[0] = ~iu_inst_e_mux_sel[1];
  assign iu_store_e	     =  iu_inst_e[3] ;
  assign iu_load_e	     =  iu_inst_e[2] ;

// Keep track there is a any normal load or  diag load in C stage
  assign all_load_e = iu_load_e | iu_d_diag_e[0] | iu_d_diag_e[2] |
			iu_i_diag_e[0] | iu_i_diag_e[2]; 

  ff_sre   all_load_c_flop (.out(all_load_c_raw),
                            .din(all_load_e),
                            .clk(clk),
                            .enable(~hold_c),
                            .reset_l(reset_l));

  assign all_load_c = all_load_c_raw & inst_valid[1];


// Signals to ICU

 assign iu_icu_flush_r = cache_flush | cache_index_flush | cache_invalidate;

  ff_sre   iu_icu_flush_e_flop (.out(iu_icu_flush_raw_e),
                                .din(iu_icu_flush_r),
                                .clk(clk),
                                .enable(~hold_e),
                                .reset_l(reset_l));

 assign iu_icu_flush_e = iu_icu_flush_raw_e & inst_valid[0] & psr_ice;

// Signals to DCU

 assign iu_dcu_flush_r[2] = cache_flush;
 assign iu_dcu_flush_r[1] = cache_index_flush;
 assign iu_dcu_flush_r[0] = cache_invalidate;

  ff_sre_3   iu_dcu_flush_e_flop (.out(iu_dcu_flush_raw_e[2:0]),
                                  .din(iu_dcu_flush_r[2:0]),
                                  .clk(clk),
                                  .enable(~hold_e),
                                  .reset_l(reset_l));

 assign iu_dcu_flush_e[2:0] = iu_dcu_flush_raw_e[2:0] & {3{inst_valid[0]}} & {3{psr_dce}};
		
 assign iu_zero_r = zero_line & valid_op_r;

  ff_sre   iu_zero_e_flop (.out(iu_zero_raw_e),
			  .din(iu_zero_r),
			  .clk(clk),
			  .enable(~hold_e),
			  .reset_l(reset_l));

 assign iu_zero_e = iu_zero_raw_e & inst_valid[0];

wire iu_special_r,iu_special_raw_e;
assign	iu_special_r = (|iu_dcu_flush_r[2:0])|zero_line | (|iu_d_diag_r[3:0]) ;
ff_sre   iu_special_e_ff (.out(iu_special_raw_e),
                          .din(iu_special_r),
                          .clk(clk),
                          .enable(~hold_e),
                          .reset_l(reset_l));
assign	iu_special_e = iu_special_raw_e&inst_valid[0];


// Take zero_line E-trap in E stage

  assign zero_trap_e = iu_zero_e & (~psr_dce | zero_addr_e[29]&zero_addr_e[28]);

 assign iu_d_diag_r[3] = priv_write_dcache_data; 
 assign iu_d_diag_r[2] = priv_read_dcache_data; 
 assign iu_d_diag_r[1] = priv_write_dcache_tag; 
 assign iu_d_diag_r[0] = priv_read_dcache_tag; 

  ff_sre_4	   iu_d_diag_e_reg (.out(iu_d_diag_raw_e[3:0]),
				    .din(iu_d_diag_r[3:0]),
				    .clk(clk),
				    .reset_l(reset_l),
				    .enable(~hold_e)
				    );

 assign iu_d_diag_e[3:0] = iu_d_diag_raw_e[3:0] & {4{inst_valid[0]}};

 assign iu_i_diag_r[3] = priv_write_icache_data;
 assign iu_i_diag_r[2] = priv_read_icache_data&first_cyc_r;
 assign iu_i_diag_r[1] = priv_write_icache_tag;
 assign iu_i_diag_r[0] = priv_read_icache_tag&first_cyc_r;

  ff_sre_4         iu_i_diag_e_reg (.out(iu_i_diag_raw_e[3:0]),
                                    .din(iu_i_diag_r[3:0]),
                                    .clk(clk),
                                    .reset_l(reset_l),
                                    .enable(~hold_e)
				    );

 assign iu_i_diag_e[3:0] = iu_i_diag_raw_e[3:0] & {4{inst_valid[0]}};
		
 // Decode the emulated trap opcodes

 assign emulated_trap_r = (ldiv
		| lmul
		| lrem
		| ldc
		| ldc_w
		| ldc2_w
		| getstatic
		| putstatic
		| getfield
		| putfield
		| new
		| newarray
		| anewarray
		| checkcast
		| instanceof
		| multianewarray
		| new_quick
		| anewarray_quick
		| multianewarray_quick
		| invokevirtual
		| invokenonvirtual
		| invokestatic
		| invokeinterface
		| invokeinterface_quick
//		| invokevirtualobject_quick
		| putfield_quick_w
		| getfield_quick_w
		| aastore
		| athrow
		| breakpoint
		| lookupswitch
		| wide
		| (drem & psr_drt)
		| invalid_op_r ) & valid_op_r
		;


  ff_sre_8	   opcode_1_op_e_reg (.out(opcode_1_op_e[7:0]),
				      .din(opcode_1_op_r[7:0]),
				      .clk(clk),
				      .enable(~hold_e),
				      .reset_l(reset_l)
				      );

  ff_sre_8	   opcode_1_op_c_reg (.out(opcode_1_op_c[7:0]),
				      .din(opcode_1_op_e[7:0]),
				      .clk(clk),
				      .enable(~hold_c),
				      .reset_l(reset_l)
				      );

  assign soft_trap_r = soft_trap & valid_op_r;

// The ucoded instructions: 

 assign ucode_op_r = (iaload 
		| laload
		| faload
		| daload
		| aaload
		| baload
		| caload
		| saload
		| aastore_quick
		| iastore
		| lastore
		| fastore
		| dastore
		| bastore
		| castore
		| sastore
		| dup_x1
		| dup_x2
		| dup2
		| dup2_x1
		| dup2_x2
		| swap
		| tableswitch
		| ireturn
		| lreturn
		| freturn
		| dreturn
		| areturn
		| return
		| arraylength
		| ldc_quick
		| ldc_w_quick
		| ldc2_w_quick
		| getfield_quick
		| putfield_quick
		| getfield2_quick
		| putfield2_quick
		| getstatic_quick
		| putstatic_quick
		| getstatic2_quick
		| putstatic2_quick
		| invokevirtual_quick
		| invokenonvirtual_quick
		| invokesuper_quick
		| invokestatic_quick
		| invokevirtual_quick_w
		| checkcast_quick  
		| instanceof_quick 
		| agetfield_quick
		| aputfield_quick
		| agetstatic_quick
		| aputstatic_quick
		| aldc_quick
		| aldc_w_quick
		| exit_sync_method
		| priv_ret_from_trap
		| return0
		| return1
		| return2
		| get_current_class
		| call ) & valid_op_r;

  assign priv_inst_r = (priv_ret_from_trap | 
			priv_read_dcache_tag |
			priv_read_dcache_data |
			priv_read_icache_tag |
			priv_read_icache_data |
			priv_powerdown |
			priv_write_dcache_tag |
			priv_write_dcache_data |
			priv_write_icache_tag |
			priv_write_icache_data |
			priv_reset |
			priv_update_optop |
			priv_read_oplim |
			priv_read_psr |
			priv_read_trapbase |
			priv_read_lockcount0 |
			priv_read_lockcount1 |
			priv_read_lockaddr0 |
			priv_read_lockaddr1 |
			priv_read_userrange1 |
			priv_read_gc_config |
			priv_read_brk1a |
			priv_read_brk2a |
			priv_read_brk12c |
			priv_read_userrange2 |
			priv_read_versionid |
			priv_read_hcr |
			priv_read_sc_bottom |
			priv_write_oplim |
			priv_write_psr |
			priv_write_trapbase |
			priv_write_lockcount0 |
			priv_write_lockcount1 |
			priv_write_lockaddr0 |
			priv_write_lockaddr1 |
			priv_write_userrange1 |
			priv_write_gc_config |	
			priv_write_brk1a |
			priv_write_brk2a |
			priv_write_brk12c |
			priv_write_userrange2 |
			priv_write_sc_bottom) & valid_op_r & (~psr_su);

  assign ldst_half_word_r =	load_short_index |
				load_char_index |
				load_char |
				load_short |
				load_char_oe |
				load_short_oe |
				ncload_char |
				ncload_short |
				ncload_char_oe |
				ncload_short_oe |
				store_short_index |
				store_short |
				store_short_oe |
				ncstore_short |
				ncstore_short_oe;

  ff_sre   ldst_half_word_e_flop (.out(ldst_half_word_e),
				  .din(ldst_half_word_r),
				  .clk(clk),
				  .enable(~hold_e),
				  .reset_l(reset_l));

  ff_sre   ldst_half_word_c_flop (.out(ldst_half_word_c),
				  .din(ldst_half_word_e),
				  .clk(clk),
				  .enable(~hold_c),
				  .reset_l(reset_l));

  assign ldst_word_r =	load_word_index |
			load_word |
			load_word_oe |
			ncload_word |
			ncload_word_oe |
			store_word_index |
			nastore_word_index |
			store_word |
			store_word_oe |
			ncstore_word |
			ncstore_word_oe;

  ff_sre   ldst_word_e_flop (.out(ldst_word_e),
			     .din(ldst_word_r),
			     .clk(clk),
			     .enable(~hold_e),
			     .reset_l(reset_l));

  ff_sre   ldst_word_c_flop (.out(ldst_word_c),
			     .din(ldst_word_e),
			     .clk(clk),
			     .enable(~hold_c),
			     .reset_l(reset_l));

  assign mis_align_c =	((iu_addr_c[0] & (ldst_half_word_c | ldst_word_c)) |
			(iu_addr_c[1] & ldst_word_c)) & inst_valid[1];
			
			
  assign ucode_busy_r = ~ucode_done | ucode_op_r| iu_trap_r; 

 // Bypass logic

  assign iu_bypass_rs2_r = ucode_op_r | 
			   fpu_op_r	|
				iadd	|
				ladd	|
				isub	|
				lsub	|
				imul	|
				idiv	|
				irem	|
				ishl	|
				lshl	|
				ishr	|
				lshr	|
				iushr	|
				lushr	|
				iand	|
				land	|
				ior	|
				lor	|
				ixor	|
				lxor	|
				lcmp	|
				if_icmpeq	|	
				if_icmpne	|
				if_icmplt	|
				if_icmpge	|
				if_icmpgt	|
				if_icmple	|
				if_acmpeq	|
				if_acmpne	|
				store_word_index	|
				nastore_word_index	|
				store_short_index	|
				store_byte_index	|
				iucmp	|		
				cache_invalidate	|
				cache_flush	|
				cache_index_flush	|
				store_byte	|
				store_short	|
				store_word	|
				priv_write_dcache_tag	|
				priv_write_dcache_data	|
				store_short_oe		|
				store_word_oe		|
				priv_write_icache_tag	|
				priv_write_icache_data	|
				ncstore_byte	|
				ncstore_short	|
				ncstore_word	|
				ncstore_short_oe	|
				ncstore_word_oe		|
				priv_update_optop	;

  assign iu_bypass_rs1_r =	ucode_op_r | ~(
				emulated_trap_r |
				illegal_op_r	|
				nop	|
				aconst_null	|
				iconst_m1	|
				iconst_0	|
				iconst_1	|
				iconst_2	|
				iconst_3	|
				iconst_4	|
				iconst_5	|
				lconst_0	|
				lconst_1	|
				fconst_0	|
				fconst_1	|
				fconst_2	|
				dconst_0	|
				dconst_1	|
				bipush		|
				sipush		|
				pop		|
				pop2		|
				l2i		|
				goto		|
				jsr		|
				goto_w		|
				jsr_w		|
				priv_powerdown	|
				priv_reset	|
				read_pc		|
				read_vars	|
				read_frame	|			
				read_optop	|
				priv_read_oplim	|
				read_const_pool	|
				priv_read_psr	|
				priv_read_trapbase	|
				priv_read_lockcount0	|
				priv_read_lockcount1	|
				priv_read_lockaddr0	|
				priv_read_lockaddr1	|
				priv_read_userrange1	|
				priv_read_gc_config	|
				priv_read_brk1a		|
				priv_read_brk2a		|
				priv_read_brk12c	|
				priv_read_userrange2	|
				priv_read_versionid	|	
				priv_read_hcr		|
				priv_read_sc_bottom	|
				read_global0		|
				read_global1		|
				read_global2		|
				soft_trap		|
				read_global3		);

  ff_sre   iu_bypass_rs1_flop (.out(iu_bypass_rs1),
                         	.din(iu_bypass_rs1_r),
                                .clk(clk),
                                .enable(~hold_e),
                                .reset_l(reset_l));

  assign iu_bypass_rs1_e = iu_bypass_rs1 & inst_valid[0];

  ff_sre   iu_bypass_rs2_flop (.out(iu_bypass_rs2),
                                .din(iu_bypass_rs2_r),
                                .clk(clk),
                                .enable(~hold_e),
                                .reset_l(reset_l));

  assign iu_bypass_rs2_e = iu_bypass_rs2 & inst_valid[0];

 // FPU opcodes
  assign fpu_op_r = (fadd | dadd | fsub | dsub | fmul | dmul |
			fdiv | ddiv | frem | drem | i2f | i2d |
			l2f | l2d | f2i | f2l | d2i | d2l | f2d |
			d2f | fcmpg | fcmpl | dcmpg | dcmpl) & valid_op_r;

 // Re-extract the decode outputs from ex_decode.v 
  assign   nop	 = decodeout_1[0];
  assign   aconst_null	 = decodeout_1[1];
  assign   iconst_m1   = decodeout_1[2];
  assign   iconst_0   = decodeout_1[3];
  assign   iconst_1   = decodeout_1[4];
  assign   iconst_2   = decodeout_1[5];
  assign   iconst_3   = decodeout_1[6];
  assign   iconst_4   = decodeout_1[7];
  assign   iconst_5   = decodeout_1[8];
  assign   lconst_0   = decodeout_1[9];
  assign   lconst_1   = decodeout_1[10];
  assign   fconst_0   = decodeout_1[11];
  assign   fconst_1   = decodeout_1[12];
  assign   fconst_2   = decodeout_1[13];
  assign   dconst_0   = decodeout_1[14];
  assign   dconst_1   = decodeout_1[15];
  assign   bipush   = decodeout_1[16];
  assign   sipush   = decodeout_1[17];
  assign   ldc	 = decodeout_1[18];
  assign   ldc_w   = decodeout_1[19];
  assign   ldc2_w   = decodeout_1[20];
  assign   iload   = decodeout_1[21];
  assign   lload   = decodeout_1[22];
  assign   fload   = decodeout_1[23];
  assign   dload   = decodeout_1[24];
  assign   aload   = decodeout_1[25];
  assign   iload_0   = decodeout_1[26];
  assign   iload_1   = decodeout_1[27];
  assign   iload_2   = decodeout_1[28];
  assign   iload_3   = decodeout_1[29];
  assign   lload_0   = decodeout_1[30];
  assign   lload_1   = decodeout_1[31];
  assign   lload_2   = decodeout_1[32];
  assign   lload_3   = decodeout_1[33];
  assign   fload_0   = decodeout_1[34];
  assign   fload_1   = decodeout_1[35];
  assign   fload_2   = decodeout_1[36];
  assign   fload_3   = decodeout_1[37];
  assign   dload_0   = decodeout_1[38];
  assign   dload_1   = decodeout_1[39];
  assign   dload_2   = decodeout_1[40];
  assign   dload_3   = decodeout_1[41];
  assign   aload_0   = decodeout_1[42];
  assign   aload_1   = decodeout_1[43];
  assign   aload_2   = decodeout_1[44];
  assign   aload_3   = decodeout_1[45];
  assign   iaload   = decodeout_1[46];
  assign   laload   = decodeout_1[47];
  assign   faload   = decodeout_1[48];
  assign   daload   = decodeout_1[49];
  assign   aaload   = decodeout_1[50];
  assign   baload   = decodeout_1[51];
  assign   caload   = decodeout_1[52];
  assign   saload   = decodeout_1[53];
  assign   istore   = decodeout_1[54];
  assign   lstore   = decodeout_1[55];
  assign   fstore   = decodeout_1[56];
  assign   dstore   = decodeout_1[57];
  assign   astore   = decodeout_1[58];
  assign   istore_0   = decodeout_1[59];
  assign   istore_1   = decodeout_1[60];
  assign   istore_2   = decodeout_1[61];
  assign   istore_3   = decodeout_1[62];
  assign   lstore_0   = decodeout_1[63];
  assign   lstore_1   = decodeout_1[64];
  assign   lstore_2   = decodeout_1[65];
  assign   lstore_3   = decodeout_1[66];
  assign   fstore_0   = decodeout_1[67];
  assign   fstore_1   = decodeout_1[68];
  assign   fstore_2   = decodeout_1[69];
  assign   fstore_3   = decodeout_1[70];
  assign   dstore_0   = decodeout_1[71];
  assign   dstore_1   = decodeout_1[72];
  assign   dstore_2   = decodeout_1[73];
  assign   dstore_3   = decodeout_1[74];
  assign   astore_0   = decodeout_1[75];
  assign   astore_1   = decodeout_1[76];
  assign   astore_2   = decodeout_1[77];
  assign   astore_3   = decodeout_1[78];
  assign   iastore   = decodeout_1[79];
  assign   lastore   = decodeout_1[80];
  assign   fastore   = decodeout_1[81];
  assign   dastore   = decodeout_1[82];
  assign   aastore   = decodeout_1[83];
  assign   bastore   = decodeout_1[84];
  assign   castore   = decodeout_1[85];
  assign   sastore   = decodeout_1[86];
  assign   pop	 = decodeout_1[87];
  assign   pop2	  = decodeout_1[88];
  assign   dup	 = decodeout_1[89];
  assign   dup_x1   = decodeout_1[90];
  assign   dup_x2   = decodeout_1[91];
  assign   dup2	  = decodeout_1[92];
  assign   dup2_x1   = decodeout_1[93];
  assign   dup2_x2   = decodeout_1[94];
  assign   swap	  = decodeout_1[95];
  assign   iadd	  = decodeout_1[96];
  assign   ladd	  = decodeout_1[97];
  assign   fadd	  = decodeout_1[98];
  assign   dadd	  = decodeout_1[99];
  assign   isub	  = decodeout_1[100];
  assign   lsub	  = decodeout_1[101];
  assign   fsub	  = decodeout_1[102];
  assign   dsub	  = decodeout_1[103];
  assign   imul	  = decodeout_1[104];
  assign   lmul	  = decodeout_1[105];
  assign   fmul	  = decodeout_1[106];
  assign   dmul	  = decodeout_1[107];
  assign   idiv	  = decodeout_1[108];
  assign   ldiv	  = decodeout_1[109];
  assign   fdiv	  = decodeout_1[110];
  assign   ddiv	  = decodeout_1[111];
  assign   irem	  = decodeout_1[112];
  assign   lrem	  = decodeout_1[113];
  assign   frem	  = decodeout_1[114];
  assign   drem	  = decodeout_1[115];
  assign   ineg	  = decodeout_1[116];
  assign   lneg	  = decodeout_1[117];
  assign   fneg	  = decodeout_1[118];
  assign   dneg	  = decodeout_1[119];
  assign   ishl	  = decodeout_1[120];
  assign   lshl	  = decodeout_1[121];
  assign   ishr	  = decodeout_1[122];
  assign   lshr	  = decodeout_1[123];
  assign   iushr   = decodeout_1[124];
  assign   lushr   = decodeout_1[125];
  assign   iand	  = decodeout_1[126];
  assign   land	  = decodeout_1[127];
  assign   ior	 = decodeout_1[128];
  assign   lor	 = decodeout_1[129];
  assign   ixor	  = decodeout_1[130];
  assign   lxor	  = decodeout_1[131];
  assign   iinc	  = decodeout_1[132];
  assign   i2l	 = decodeout_1[133];
  assign   i2f	 = decodeout_1[134];
  assign   i2d	 = decodeout_1[135];
  assign   l2i	 = decodeout_1[136];
  assign   l2f	 = decodeout_1[137];
  assign   l2d	 = decodeout_1[138];
  assign   f2i	 = decodeout_1[139];
  assign   f2l	 = decodeout_1[140];
  assign   f2d	 = decodeout_1[141];
  assign   d2i	 = decodeout_1[142];
  assign   d2l	 = decodeout_1[143];
  assign   d2f	 = decodeout_1[144];
  assign   int2byte   = decodeout_1[145];
  assign   int2char   = decodeout_1[146];
  assign   int2short   = decodeout_1[147];
  assign   lcmp	  = decodeout_1[148];
  assign   fcmpl   = decodeout_1[149];
  assign   fcmpg   = decodeout_1[150];
  assign   dcmpl   = decodeout_1[151];
  assign   dcmpg   = decodeout_1[152];
  assign   ifeq	  = decodeout_1[153];
  assign   ifne	  = decodeout_1[154];
  assign   iflt	  = decodeout_1[155];
  assign   ifge	  = decodeout_1[156];
  assign   ifgt	  = decodeout_1[157];
  assign   ifle	  = decodeout_1[158];
  assign   if_icmpeq   = decodeout_1[159];
  assign   if_icmpne   = decodeout_1[160];
  assign   if_icmplt   = decodeout_1[161];
  assign   if_icmpge   = decodeout_1[162];
  assign   if_icmpgt   = decodeout_1[163];
  assign   if_icmple   = decodeout_1[164];
  assign   if_acmpeq   = decodeout_1[165];
  assign   if_acmpne   = decodeout_1[166];
  assign   goto	  = decodeout_1[167];
  assign   jsr	 = decodeout_1[168];
  assign   ret	 = decodeout_1[169];
  assign   tableswitch	 = decodeout_1[170];
  assign   lookupswitch	  = decodeout_1[171];
  assign   ireturn   = decodeout_1[172];
  assign   lreturn   = decodeout_1[173];
  assign   freturn   = decodeout_1[174];
  assign   dreturn   = decodeout_1[175];
  assign   areturn   = decodeout_1[176];
  assign   return   = decodeout_1[177];
  assign   getstatic   = decodeout_1[178];
  assign   putstatic   = decodeout_1[179];
  assign   getfield   = decodeout_1[180];
  assign   putfield   = decodeout_1[181];
  assign   invokevirtual   = decodeout_1[182];
  assign   invokenonvirtual   = decodeout_1[183];
  assign   invokestatic	  = decodeout_1[184];
  assign   invokeinterface   = decodeout_1[185];
// decodeout_1[186] is unused JVM opcode
  assign   new	 = decodeout_1[187];
  assign   newarray   = decodeout_1[188];
  assign   anewarray   = decodeout_1[189];
  assign   arraylength	 = decodeout_1[190];
  assign   athrow   = decodeout_1[191];
  assign   checkcast   = decodeout_1[192];
  assign   instanceof	= decodeout_1[193];
  assign   monitorenter	  = decodeout_1[194];
  assign   monitorexit	 = decodeout_1[195];
  assign   wide	  = decodeout_1[196];
  assign   multianewarray   = decodeout_1[197];
  assign   ifnull   = decodeout_1[198];
  assign   ifnonnull   = decodeout_1[199];
  assign   goto_w   = decodeout_1[200];
  assign   jsr_w   = decodeout_1[201];
  assign   breakpoint	= decodeout_1[202];
  assign   ldc_quick   = decodeout_1[203];
  assign   ldc_w_quick	 = decodeout_1[204];
  assign   ldc2_w_quick	  = decodeout_1[205];
  assign   getfield_quick   = decodeout_1[206];
  assign   putfield_quick   = decodeout_1[207];
  assign   getfield2_quick   = decodeout_1[208];
  assign   putfield2_quick   = decodeout_1[209];
  assign   getstatic_quick   = decodeout_1[210];
  assign   putstatic_quick   = decodeout_1[211];
  assign   getstatic2_quick   = decodeout_1[212];
  assign   putstatic2_quick   = decodeout_1[213];
  assign   invokevirtual_quick	 = decodeout_1[214];
  assign   invokenonvirtual_quick   = decodeout_1[215];
  assign   invokesuper_quick   = decodeout_1[216];
  assign   invokestatic_quick	= decodeout_1[217];
  assign   invokeinterface_quick   = decodeout_1[218];
  assign   invokevirtualobject_quick   = decodeout_1[219];
 //  assign   invokeignored_quick	 = decodeout_1[220];  // Check this!
  assign   aastore_quick	 = decodeout_1[220]; 
  assign   new_quick   = decodeout_1[221];
  assign   anewarray_quick   = decodeout_1[222];
  assign   multianewarray_quick	  = decodeout_1[223];
  assign   checkcast_quick   = decodeout_1[224];
  assign   instanceof_quick   = decodeout_1[225];
  assign   invokevirtual_quick_w   = decodeout_1[226];
  assign   getfield_quick_w   = decodeout_1[227];
  assign   putfield_quick_w   = decodeout_1[228];
  assign   nonnull_quick   = decodeout_1[229];
  assign   agetfield_quick   = decodeout_1[230];
  assign   aputfield_quick   = decodeout_1[231];
  assign   agetstatic_quick   = decodeout_1[232];
  assign   aputstatic_quick   = decodeout_1[233];
  assign   aldc_quick	= decodeout_1[234];
  assign   aldc_w_quick	  = decodeout_1[235];
  assign   exit_sync_method   = decodeout_1[236];
  assign   sethi   = decodeout_1[237];	
  assign   load_word_index   = decodeout_1[238];
  assign   load_short_index   = decodeout_1[239];
  assign   load_char_index   = decodeout_1[240];
  assign   load_byte_index   = decodeout_1[241];
  assign   load_ubyte_index   = decodeout_1[242];
  assign   store_word_index   = decodeout_1[243];
  assign   nastore_word_index	= decodeout_1[244];
  assign   store_short_index   = decodeout_1[245];
  assign   store_byte_index   = decodeout_1[246];
  assign   hardware   = decodeout_1[255];

  assign  load_ubyte   = hardware & (decodeout_2[0]);
  assign  load_byte   = hardware & (decodeout_2[1]);
  assign  load_char   = hardware & (decodeout_2[2]);
  assign  load_short   = hardware & (decodeout_2[3]);
  assign  load_word   = hardware & (decodeout_2[4]);
  assign  priv_ret_from_trap   = hardware & (decodeout_2[5]);
  assign  priv_read_dcache_tag	 = hardware & (decodeout_2[6]);
  assign  priv_read_dcache_data	  = hardware & (decodeout_2[7]);
  assign  load_char_oe	 = hardware & (decodeout_2[10]);
  assign  load_short_oe	  = hardware & (decodeout_2[11]);
  assign  load_word_oe	 = hardware & (decodeout_2[12]);
  assign  return0   = hardware & (decodeout_2[13]);
  assign  priv_read_icache_tag	 = hardware & (decodeout_2[14]);
  assign  priv_read_icache_data	  = hardware & (decodeout_2[15]);
  assign  ncload_ubyte	 = hardware & (decodeout_2[16]);
  assign  ncload_byte	= hardware & (decodeout_2[17]);
  assign  ncload_char	= hardware & (decodeout_2[18]);
  assign  ncload_short	 = hardware & (decodeout_2[19]);
  assign  ncload_word	= hardware & (decodeout_2[20]);
  assign  iucmp	  = hardware & (decodeout_2[21]);
  assign  priv_powerdown   = hardware & (decodeout_2[22]);
  assign  cache_invalidate   = hardware & (decodeout_2[23]);
  assign  ncload_char_oe   = hardware & (decodeout_2[26]);
  assign  ncload_short_oe   = hardware & (decodeout_2[27]);
  assign  ncload_word_oe   = hardware & (decodeout_2[28]);
  assign  return1   = hardware & (decodeout_2[29]);
  assign  cache_flush	= hardware & (decodeout_2[30]);
  assign  cache_index_flush   = hardware & (decodeout_2[31]);
  assign  store_byte   = hardware & (decodeout_2[32]);
  assign  store_short	= hardware & (decodeout_2[34]);
  assign  store_word   = hardware & (decodeout_2[36]);
  assign  soft_trap   = hardware & (decodeout_2[37]);
  assign  priv_write_dcache_tag	  = hardware & (decodeout_2[38]);
  assign  priv_write_dcache_data   = hardware & (decodeout_2[39]);
  assign  store_short_oe   = hardware & (decodeout_2[42]);
  assign  store_word_oe	  = hardware & (decodeout_2[44]);
  assign  return2   = hardware & (decodeout_2[45]);
  assign  priv_write_icache_tag	  = hardware & (decodeout_2[46]);
  assign  priv_write_icache_data   = hardware & (decodeout_2[47]);
  assign  ncstore_byte	 = hardware & (decodeout_2[48]);
  assign  ncstore_short	  = hardware & (decodeout_2[50]);
  assign  ncstore_word	 = hardware & (decodeout_2[52]);
  assign  priv_reset   = hardware & (decodeout_2[54]);
  assign  get_current_class   = hardware & (decodeout_2[55]);
  assign  ncstore_short_oe   = hardware & (decodeout_2[58]);
  assign  ncstore_word_oe   = hardware & (decodeout_2[60]);
  assign  call	 = hardware & (decodeout_2[61]);
  assign  zero_line   = hardware & (decodeout_2[62]);
  assign  priv_update_optop   = hardware & (decodeout_2[63]);
  assign  read_pc   = hardware & (decodeout_2[64]);
  assign  read_vars   = hardware & (decodeout_2[65]);
  assign  read_frame   = hardware & (decodeout_2[66]);
  assign  read_optop   = hardware & (decodeout_2[67]);
  assign  priv_read_oplim   = hardware & (decodeout_2[68]);
  assign  read_const_pool   = hardware & (decodeout_2[69]);
  assign  priv_read_psr	  = hardware & (decodeout_2[70]);
  assign  priv_read_trapbase   = hardware & (decodeout_2[71]);
  assign  priv_read_lockcount0	 = hardware & (decodeout_2[72]);
  assign  priv_read_lockcount1	 = hardware & (decodeout_2[73]);
  assign  priv_read_lockaddr0	= hardware & (decodeout_2[76]);
  assign  priv_read_lockaddr1	= hardware & (decodeout_2[77]);
  assign  priv_read_userrange1	 = hardware & (decodeout_2[80]);
  assign  priv_read_gc_config	= hardware & (decodeout_2[81]);
  assign  priv_read_brk1a   = hardware & (decodeout_2[82]);
  assign  priv_read_brk2a   = hardware & (decodeout_2[83]);
  assign  priv_read_brk12c   = hardware & (decodeout_2[84]);
  assign  priv_read_userrange2	 = hardware & (decodeout_2[85]);
  assign  priv_read_versionid	= hardware & (decodeout_2[87]);
  assign  priv_read_hcr	  = hardware & (decodeout_2[88]);
  assign  priv_read_sc_bottom	= hardware & (decodeout_2[89]);
  assign  read_global0	 = hardware & (decodeout_2[90]);
  assign  read_global1	 = hardware & (decodeout_2[91]);
  assign  read_global2	 = hardware & (decodeout_2[92]);
  assign  read_global3	 = hardware & (decodeout_2[93]);
  assign  write_pc   = hardware & (decodeout_2[96]);
  assign  write_vars   = hardware & (decodeout_2[97]);
  assign  write_frame	= hardware & (decodeout_2[98]);
  assign  write_optop	= hardware & (decodeout_2[99]);
  assign  priv_write_oplim   = hardware & (decodeout_2[100]);
  assign  write_const_pool   = hardware & (decodeout_2[101]);
  assign  priv_write_psr   = hardware & (decodeout_2[102]);
  assign  priv_write_trapbase	= hardware & (decodeout_2[103]);
  assign  priv_write_lockcount0	  = hardware & (decodeout_2[104]);
  assign  priv_write_lockcount1	  = hardware & (decodeout_2[105]);
  assign  priv_write_lockaddr0	 = hardware & (decodeout_2[108]);
  assign  priv_write_lockaddr1	 = hardware & (decodeout_2[109]);
  assign  priv_write_userrange1	  = hardware & (decodeout_2[112]);
  assign  priv_write_gc_config	 = hardware & (decodeout_2[113]);
  assign  priv_write_brk1a   = hardware & (decodeout_2[114]);
  assign  priv_write_brk2a   = hardware & (decodeout_2[115]);
  assign  priv_write_brk12c   = hardware & (decodeout_2[116]);
  assign  priv_write_userrange2	  = hardware & (decodeout_2[117]);
  assign  priv_write_sc_bottom	 = hardware & (decodeout_2[121]);
  assign  write_global0	  = hardware & (decodeout_2[122]);
  assign  write_global1	  = hardware & (decodeout_2[123]);
  assign  write_global2	  = hardware & (decodeout_2[124]);
  assign  write_global3	  = hardware & (decodeout_2[125]);

   // Generate E stage nonnull_quick_e for null pointer exception logic
   ff_sre nonnull_quick_reg(.out    (nonnull_quick_e),
			    .din    (nonnull_quick),
			    .enable (~hold_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );

// Generate control signals monitorenter and monitorexit 
  assign monitorenter_r = monitorenter;

  ff_sre   monitorenter_e_flop (.out(monitorenter_raw_e),
			       .din(monitorenter_r),
			       .clk(clk),
			       .enable(~hold_e),
			       .reset_l(reset_l));

  assign monitorenter_e = monitorenter_raw_e & inst_valid[0]&~kill_inst_e;

  assign monitorexit_r = monitorexit;

  ff_sre   monitorexit_e_flop (.out(monitorexit_raw_e),
			       .din(monitorexit_r),
			       .clk(clk),
			       .enable(~hold_e),
			       .reset_l(reset_l));

  assign monitorexit_e = monitorexit_raw_e & inst_valid[0]&~kill_inst_e;

// Generate carry_in bit for adder
  assign carry_in_r = isub | ineg | (lsub & first_cyc_r) |
		      (carry_out_e & lsub & second_cyc_r) |
		      (carry_out_e & ladd & second_cyc_r) |
		      (lneg & first_cyc_r) |
		      (carry_out_e & lneg & second_cyc_r);

  ff_sre   carry_in_e_flop (.out(carry_in_raw_e),
			    .din(carry_in_r),
			    .clk(clk),
			    .enable(~hold_e),
			    .reset_l(reset_l));

  assign carry_in_e = (carry_in_raw_e | ucode_busy_e & (
			(alu_adder_fn[1] & ~alu_adder_fn[0]) |
			(~alu_adder_fn[1] & alu_adder_fn[0])))
			 & inst_valid[0];

// Generate control signals for mul/div
  assign mul_r = imul;

  ff_sre   mul_e_flop (.out(mul_raw_e),
		      .din(mul_r),
		      .clk(clk),
		      .enable(~hold_e),
		      .reset_l(reset_l));

  assign mul_e = mul_raw_e & inst_valid[0];

  assign div_r = idiv;

  ff_sre   div_e_flop (.out(div_raw_e),
		      .din(div_r),
		      .clk(clk),
		      .enable(~hold_e),
		      .reset_l(reset_l));

  assign div_e = div_raw_e & inst_valid[0];

  assign rem_r = irem;

  ff_sre   rem_e_flop (.out(rem_raw_e),
		      .din(rem_r),
		      .clk(clk),
		      .enable(~hold_e),
		      .reset_l(reset_l));

  assign rem_e = rem_raw_e & inst_valid[0];

  assign shift_dir_r = ishr | (lshr & (first_cyc_r | second_cyc_r)) | 
		       iushr | (lushr & (first_cyc_r | second_cyc_r)); 

  ff_sre   shift_dir_e_flop (.out(shift_dir_raw_e),
			    .din(shift_dir_r),
			    .clk(clk),
			    .enable(~hold_e),
			    .reset_l(reset_l));

  assign shift_dir_e = shift_dir_raw_e & inst_valid[0];

// Control signals for shifter
  assign shift_sel_r = ishl | ishr | iushr; 

  ff_sre   shift_sel_flop (.out(shift_sel_raw),
			  .din(shift_sel_r),
			  .clk(clk),
			  .enable(~hold_e),
			  .reset_l(reset_l));

  assign shift_sel = shift_sel_raw & inst_valid[0];

  assign sign_r = ishr | nonnull_quick | (lcmp & first_cyc_r) | 
		  ifeq | ifne | iflt | ifge | ifgt | ifle | if_icmpeq |
		  if_icmpne | if_icmplt | if_icmpge | if_icmpgt |
		  if_icmple | if_icmpeq | if_icmpne | if_acmpeq |
		  if_acmpne | ifnull | ifnonnull |
		  (lshr & (first_cyc_r | second_cyc_r));

  ff_sre   sign_e_flop (.out(sign_raw_e),
		       .din(sign_r),
		       .clk(clk),
		       .enable(~hold_e),
		       .reset_l(reset_l));

  assign sign_e = sign_raw_e & inst_valid[0];

// Generate shift_count_e[5:0] from rs1_bypass_mux_out[5:0]

   assign shift_32_r = ishl | ishr | iushr ;
   assign shift_64_r = lshl | lshr | lushr ;
   ff_sre shift_32_e_flop(.out(shift_32_e),
			  .din(shift_32_r),
			  .enable(~hold_e),
			  .reset_l(reset_l),
			  .clk(clk)
			  );
   ff_sre shift_64_e_flop(.out(shift_64_e),
			  .din(shift_64_r),
			  .enable(~hold_e),
			  .reset_l(reset_l),
			  .clk(clk)
			  );
   ff_sre_6   shift_count_e1_flop (.out(shift_count_e1[5:0]),
				   .din(rs1_bypass_mux_out[5:0]),
				   .enable(~hold_e),
				   .reset_l(reset_l),
				   .clk(clk)
				   );
   assign shift_count_mux_sel[2] = shift_32_e;
   assign shift_count_mux_sel[1] = shift_64_e & first_cyc_e;
   assign shift_count_mux_sel[0] = shift_64_e & second_cyc_e;
   mux3_6 shift_count_mux(.out(shift_count_e[5:0]),
			  .in2({1'b0, rs1_bypass_mux_out[4:0]}),
			  .in1(rs1_bypass_mux_out[5:0]),
			  .in0(shift_count_e1[5:0]),
			  .sel(shift_count_mux_sel[2:0]));

   // Mux select for Bit or Convert outputs
  assign bit_cvt_mux_sel_r[1] = iand | ior | ixor | jsr | jsr_w | fneg | dneg |
				(lor & (first_cyc_r | second_cyc_r)) |
				(lxor & (first_cyc_r | second_cyc_r)) |
				(land & (first_cyc_r | second_cyc_r));
  assign bit_cvt_mux_sel_r[0] = ~bit_cvt_mux_sel_r[1];

  ff_sre_2   bit_cvt_mux_sel_reg (.out(bit_cvt_mux_sel[1:0]),
				 .din(bit_cvt_mux_sel_r[1:0]),
				 .clk(clk),
				 .enable(~hold_e),
				 .reset_l(reset_l));

// Mux select for ALU output
  assign alu_out_mux_sel_r[7] = lcmp | iucmp; 
  assign alu_out_mux_sel_r[6] = imul | idiv | irem; 
  assign alu_out_mux_sel_r[5] = read_pc | read_vars | 
				read_frame | read_optop | 
				priv_read_oplim | read_const_pool | 
				priv_read_psr |
				priv_read_trapbase | priv_read_lockcount0 |
				priv_read_lockcount1 | priv_read_lockaddr0 |
				priv_read_lockaddr1 | priv_read_userrange1 |
				priv_read_gc_config | priv_read_brk1a |
				priv_read_brk2a | priv_read_brk12c |
				priv_read_userrange2 | priv_read_versionid | 
				priv_read_hcr | priv_read_sc_bottom;
				
  assign alu_out_mux_sel_r[4] = iand | ior | ixor | i2l | jsr | jsr_w |
				int2byte | int2char | int2short | sethi |
				lor | lxor | land | fneg | dneg;
  assign alu_out_mux_sel_r[3] = ishl | ishr | iushr | lshr | lushr | lshl ;	 
  assign alu_out_mux_sel_r[2] = iadd | isub | ineg | iinc |
				cache_invalidate | cache_flush | cache_index_flush | 
				ladd | lsub |lneg; 
  assign alu_out_mux_sel_r[1] = 1'b0;  
  assign alu_out_mux_sel_r[0] = ~(alu_out_mux_sel_r[7] | 
				  alu_out_mux_sel_r[6] |
				  alu_out_mux_sel_r[5] |
				  alu_out_mux_sel_r[4] |
				  alu_out_mux_sel_r[3] |
				  alu_out_mux_sel_r[2] |
				  alu_out_mux_sel_r[1]) ;


  ff_sre_8	   alu_out_mux_sel_raw_e_reg (.out(alu_out_mux_sel_raw_e[7:0]),
				              .din(alu_out_mux_sel_r[7:0]),
				              .clk(clk),
				              .reset_l(reset_l),
				              .enable(~hold_e)
					      );

  assign ucode_read_reg_e	=ucode_rd_psr_e|ucode_rd_vars_e|ucode_rd_frame_e|
				ucode_rd_const_p_e;

  assign alu_out_mux_sel[7] = alu_out_mux_sel_raw_e[7]&~ucode_busy_e;
  assign alu_out_mux_sel[6] = alu_out_mux_sel_raw_e[6]&~ucode_busy_e;
  assign alu_out_mux_sel[5] = alu_out_mux_sel_raw_e[5] | ucode_read_reg_e ;
  assign alu_out_mux_sel[4] = alu_out_mux_sel_raw_e[4]&~ucode_busy_e;
  assign alu_out_mux_sel[3] = alu_out_mux_sel_raw_e[3]&~ucode_busy_e;
  assign alu_out_mux_sel[2] = alu_out_mux_sel_raw_e[2]&~ucode_busy_e;
  assign alu_out_mux_sel[1] =  ucode_rd_port_c_e; 
  assign alu_out_mux_sel[0] = ~(alu_out_mux_sel[7] |
                                alu_out_mux_sel[6] |
                                alu_out_mux_sel[5] |
                                alu_out_mux_sel[4] |
                                alu_out_mux_sel[3] |
                                alu_out_mux_sel[2] |
                                alu_out_mux_sel[1]) ;

    assign adder2_src1_mux_sel_r = ~ucode_busy_r &
				(ret | load_word_index | load_short_index |
				 load_char_index | load_byte_index |
				 load_ubyte_index | store_word_index |
				 nastore_word_index | store_short_index |
				 store_byte_index | load_ubyte | load_byte |
				 load_char | load_short | load_word |
				 priv_read_dcache_tag | priv_read_dcache_data |
				 load_char_oe | load_short_oe | load_word_oe |
				 priv_read_icache_tag | priv_read_icache_data |
				 ncload_ubyte | ncload_byte | ncload_char |
				 ncload_short | ncload_word | cache_invalidate |
				 ncload_char_oe | ncload_short_oe | ncload_word_oe |
				 cache_flush | cache_index_flush | store_byte |
				 store_short | store_word | priv_write_dcache_tag |
				 priv_write_dcache_data | store_short_oe |
				 store_word_oe | priv_write_icache_tag |
				 priv_write_icache_data | ncstore_byte |
				 ncstore_short | ncstore_word | ncstore_short_oe |
				 ncstore_word_oe | zero_line | write_pc);

    ff_sre         adder2_src1_mux_sel_reg
                        (.out(adder2_src1_mux_sel),
                         .din(adder2_src1_mux_sel_r),
                         .clk(clk),
                         .reset_l(reset_l),
                         .enable(~hold_e)
			 );


// Mux select for source 2 of address adder
// Select offset for branch pc.
  assign offset_branch_r     = ~ucode_busy_r&(ifeq | ifne | iflt | ifge | 
				    ifgt | ifle | if_icmpeq | if_icmpne |
				    if_icmplt | if_icmpge | if_icmpgt | 
				    if_icmple | if_acmpeq | if_acmpne | goto |
				    jsr | ifnull | ifnonnull |goto_w |
				    jsr_w | load_word_index | load_short_index |
				    load_char_index | load_byte_index |
				    load_ubyte_index | store_word_index |
				    nastore_word_index | store_short_index |
				    store_byte_index); 

  ff_sre	   adder2_src2_mux_sel_reg 
			(.out(offset_branch_e),
			 .din(offset_branch_r),
			 .clk(clk),
			 .reset_l(reset_l),
			 .enable(~hold_e)
			 );

  assign adder2_src2_mux_sel[0] =  ~sc_dcache_req & mem_adder_fn[1] & ~mem_adder_fn[0];
  assign adder2_src2_mux_sel[1] =  ~sc_dcache_req & mem_adder_fn[1]& mem_adder_fn[0];
  assign adder2_src2_mux_sel[2] =  ~sc_dcache_req & offset_branch_e;
  assign adder2_src2_mux_sel[3] =  ~(adder2_src2_mux_sel[0] | adder2_src2_mux_sel[2]
					| adder2_src2_mux_sel[1]);


  assign adder2_carry_in = ~sc_dcache_req&mem_adder_fn[1]&~mem_adder_fn[0];

  assign wr_optop_mux_sel[1] = ucode_wr_vars_optop_e;
  assign wr_optop_mux_sel[0] = ~wr_optop_mux_sel[1];


// Mux select for ucode_portc or rs2_bypass
  assign iu_data_mux_sel_r[1] = ucode_busy_r;
  assign iu_data_mux_sel_r[0] = ~iu_data_mux_sel_r[1];

  ff_sre_2	   iu_data_mux_sel_reg
			(.out     (iu_data_mux_sel[1:0]),
			 .din     (iu_data_mux_sel_r[1:0]),
			 .enable  (~hold_e),
			 .reset_l (reset_l),
			 .clk     (clk)
			 );


   ff_sre iucmp_reg(.out     (iucmp_e),
		    .din     (iucmp),
		    .enable  (~hold_e),
		    .reset_l (reset_l),
		    .clk     (clk)
		    );
   ff_sre lcmp_reg(.out	    (lcmp_e),
		   .din	    (lcmp),
		   .enable  (~hold_e),
		   .reset_l (reset_l),
		   .clk	    (clk)
		   );
   ff_sre first_cyc_reg(.out	 (first_cyc_e),
			.din	 (first_cyc_r),
			.enable	 (~hold_e),
			.reset_l (reset_l),
			.clk	 (clk)
			);
   ff_sre second_cyc_reg(.out	  (second_cyc_e),
			 .din	  (second_cyc_r),
			 .enable  (~hold_e),
			 .reset_l (reset_l),
			 .clk	  (clk)
			 );
   assign iucmp_gt = iucmp_e & cmp_gt_e;
   assign iucmp_eq = iucmp_e & cmp_eq_e;
   assign iucmp_lt = iucmp_e & cmp_lt_e;
   ff_sre first_gt_reg(.out     (first_gt),
		       .din     (lcmp_e & first_cyc_e & cmp_gt_e),
		       .enable  (~hold_e),
		       .reset_l (reset_l),
		       .clk     (clk)
		       );
   ff_sre first_eq_reg(.out     (first_eq),
		       .din     (lcmp_e & first_cyc_e & cmp_eq_e),
		       .enable  (~hold_e),
		       .reset_l (reset_l),
		       .clk     (clk)
		       );
   ff_sre first_lt_reg(.out     (first_lt),
		       .din     (lcmp_e & first_cyc_e & cmp_lt_e),
		       .enable  (~hold_e),
		       .reset_l (reset_l),
		       .clk     (clk)
		       );

   assign second_gt = lcmp_e & second_cyc_e & first_eq & cmp_gt_e;
   assign second_eq = lcmp_e & second_cyc_e & first_eq & cmp_eq_e;
   assign second_lt = lcmp_e & second_cyc_e & first_eq & cmp_lt_e;
   assign constant_mux_sel[2] = iucmp_gt | first_gt | second_gt;
   assign constant_mux_sel[1] = iucmp_eq | second_eq;
   assign constant_mux_sel[0] = iucmp_lt | first_lt | second_lt;


   /****************************************************************************
    * asynchronous_error due to smu access
    ***************************************************************************/
   ff_sr smu_access_reg(.out	 (smu_access),
			.din	 (smu_ld | smu_st),
			.reset_l (reset_l),
			.clk	 (clk)
			);
   assign mem_prot_stack = (range1_h_cmp2_gt | range1_h_cmp2_eq |
			    range1_l_cmp2_lt) &
			   (range2_h_cmp2_gt | range2_h_cmp2_eq |
			    range2_l_cmp2_lt);
   assign async_error = mem_prot_stack & psr_ace & psr_cac & smu_access;

   /****************************************************************************
    * mem_protection_error
    ***************************************************************************/
   /*
    * Because zero_line is not accounted for within iu_inst_e[3] (store) and
    * iu_inst_e[2] (load), it is brought to E stage and OR'd into the equation.
    */
   /*
    * iu_inst_raw[3:2] is checked when PSR.CAC = 0, which is extended ld/st
    * only.  iu_inst_e[3:2] contains DCU access from ucode.
    */
   assign load_store_e = iu_inst_raw_e[3] | iu_inst_raw_e[2] |
			 psr_cac & (iu_load_e | iu_store_e| iu_zero_e |iu_dcu_flush_e[0]);
   ff_sre load_store_c_reg(.out(load_store_c),
			   .din	    (load_store_e),
			   .enable  (~hold_c),
			   .reset_l (reset_l),
			   .clk	    (clk)
			   );
// Removed term iu_load_e. 
   assign data_st_e = iu_store_e | iu_zero_e |iu_dcu_flush_e[0];


   assign mem_prot_ldst	 = (range1_h_cmp1_gt | range1_h_cmp1_eq |
			    range1_l_cmp1_lt) &
			   (range2_h_cmp1_gt | range2_h_cmp1_eq |
			    range2_l_cmp1_lt);
   assign mem_prot_error_c = mem_prot_ldst & psr_ace & load_store_c &
			     inst_valid[1];

   /****************************************************************************
    * breakpoint1 and breakpoint2
    ***************************************************************************/

   /*
    * Don't need to qualify breakpoints with BRK12C.HALT, because trap logic
    * will determine that and it still needs to see breakpoint signals coming
    * out.
    */

   // Data breakpoint 1
   assign data_brk1_eq[6]   = data_brk1_31_13_eq     | ~brk12c_brkm1[6];
   assign data_brk1_eq[5]   = data_brk1_misc_eq[4]   | ~brk12c_brkm1[5];
   assign data_brk1_eq[4]   = data_brk1_11_4_eq	     | ~brk12c_brkm1[4];
   assign data_brk1_eq[3:0] = data_brk1_misc_eq[3:0] | ~brk12c_brkm1[3:0];
   assign data_brk1_match_e   = &data_brk1_eq[6:0];
   assign data_brk1_vld_e     = (iu_load_e&~brk12c_srcbk1[0]| data_st_e&brk12c_srcbk1[0])&
			      ~(psr_su & brk12c_subk1)&brk12c_brken1&~brk12c_srcbk1[1]&inst_valid[0];
   assign data_brk1_e	    = data_brk1_match_e&data_brk1_vld_e;

// Removed inst_valid term as data_bkpt gets killed during data loads for S$ miss. Also
// included trap_in_progress signal for enable of data_brk_c flop. 
  assign data_brk1_c = data_brk1_c_int;
ff_sre  data_brk1_c_reg(.out(data_brk1_c_int),.din(data_brk1_e),.clk(clk),
        .reset_l((reset_l & !pj_resume)),.enable(!hold_c|trap_in_progress));


   // Data breakpoint 2
   assign data_brk2_eq[6]   = data_brk2_31_13_eq     | ~brk12c_brkm2[6];
   assign data_brk2_eq[5]   = data_brk2_misc_eq[4]   | ~brk12c_brkm2[5];
   assign data_brk2_eq[4]   = data_brk2_11_4_eq	     | ~brk12c_brkm2[4];
   assign data_brk2_eq[3:0] = data_brk2_misc_eq[3:0] | ~brk12c_brkm2[3:0];
   assign data_brk2_match_e   = &data_brk2_eq[6:0];
   assign data_brk2_vld_e     = (iu_load_e&~brk12c_srcbk2[0]| data_st_e&brk12c_srcbk2[0])&
                              ~(psr_su & brk12c_subk2)&brk12c_brken2&~brk12c_srcbk2[1]&inst_valid[0];
   assign data_brk2_e	    = data_brk2_match_e&data_brk2_vld_e;

  assign data_brk2_c = data_brk2_c_int;

ff_sre  data_brk2_c_reg(.out(data_brk2_c_int),.din(data_brk2_e),.clk(clk),
        .reset_l((reset_l & !pj_resume)),.enable(!hold_c|trap_in_progress));

   // Instruction breakpoint 1
   assign inst_brk1_eq[6]   = inst_brk1_31_13_eq     | ~brk12c_brkm1[6];
   assign inst_brk1_eq[5]   = inst_brk1_misc_eq[4]   | ~brk12c_brkm1[5];
   assign inst_brk1_eq[4]   = inst_brk1_11_4_eq	     | ~brk12c_brkm1[4];
   assign inst_brk1_eq[3:0] = inst_brk1_misc_eq[3:0] | ~brk12c_brkm1[3:0];
   assign inst_brk1_match   = &inst_brk1_eq[6:0];
   assign inst_brk1_taken   = inst_brk1_match & valid_op_r &
			      ~(psr_su & brk12c_subk1) & brk12c_srcbk1[1] &
			      brk12c_srcbk1[0] & brk12c_brken1;
   assign inst_brk1_r	    = inst_brk1_taken & ~psr_fle;

   // Instruction breakpoint 2
   assign inst_brk2_eq[6]   = inst_brk2_31_13_eq     | ~brk12c_brkm2[6];
   assign inst_brk2_eq[5]   = inst_brk2_misc_eq[4]   | ~brk12c_brkm2[5];
   assign inst_brk2_eq[4]   = inst_brk2_11_4_eq	     | ~brk12c_brkm2[4];
   assign inst_brk2_eq[3:0] = inst_brk2_misc_eq[3:0] | ~brk12c_brkm2[3:0];
   assign inst_brk2_match   = &inst_brk2_eq[6:0];
   assign inst_brk2_taken   = inst_brk2_match & valid_op_r &
			      ~(psr_su & brk12c_subk2) & brk12c_srcbk2[1] &
			      brk12c_srcbk2[0] & brk12c_brken2;
   assign inst_brk2_r	    = inst_brk2_taken & ~psr_fle;

   /****************************************************************************
    * runtime_NullPtrException
    ***************************************************************************/
   assign null_ptr_exception_e = (monitorenter_raw_e | monitorexit_raw_e |
				  nonnull_quick_e) & null_objref_e & ~kill_inst_e&
				 inst_valid[0];

   /****************************************************************************
    * monitorenter/monitorexit
    * LockCountOverflowTrap, LockEnterMissTrap, LockExitMissTrap,
    * and LockReleaseTrap
    ***************************************************************************/
   // First create some shared signals
   assign lock0_enter = monitorenter_e & la0_hit & ~null_objref_e;
   assign lock0_exit  = monitorexit_e  & la0_hit & ~null_objref_e;
   assign lock1_enter = monitorenter_e & la1_hit & ~null_objref_e;
   assign lock1_exit  = monitorexit_e  & la1_hit & ~null_objref_e;

   // monitorenter/monitorexit
   assign lc0_din_mux_sel[3] = lock0_cache;			// lc0_p1
   assign lc0_din_mux_sel[2] = lock0_enter;			// lc0_p1
   assign lc0_din_mux_sel[1] = lock0_exit;			// lc0_m1
   assign lc0_din_mux_sel[0] = ~(|lc0_din_mux_sel[3:1]);	// wr_lc0
   assign lc0_count_reg_we   = (lock0_enter | lock0_exit |reg_wr_mux_sel[8] |
			       lock0_cache) & ~hold_e;
   assign lc1_din_mux_sel[3] = lock1_cache;			// lc1_p1
   assign lc1_din_mux_sel[2] = lock1_enter;			// lc1_p1
   assign lc1_din_mux_sel[1] = lock1_exit;			// lc1_m1
   assign lc1_din_mux_sel[0] = ~(|lc1_din_mux_sel[3:1]);	// wr_lc1
   assign lc1_count_reg_we   = (lock1_enter | lock1_exit | reg_wr_mux_sel[9] |
			        lock1_cache) & ~hold_e;

   // LockCountOverflowTrap
   assign lock0_overflow  = lock0_enter & lc0_eq_255;
   assign lock0_underflow = lock0_exit  & lc0_eq_0;
   assign lock1_overflow  = lock1_enter & lc1_eq_255;
   assign lock1_underflow = lock1_exit  & lc1_eq_0;
   assign lock_count_overflow_e = (lock0_overflow | lock0_underflow |
				   lock1_overflow | lock1_underflow) & 
				   ~hold_e;

   // LockEnterMissTrap & LockExitMissTrap
   assign lock_miss_valid   = ~la0_hit & ~la1_hit & ~null_objref_e;
   assign lock_enter_miss_e = lock_miss_valid & (((la0_null_e | la1_null_e) & lockbit) |
				(~(la0_null_e | la1_null_e))) & ~hold_e & monitorenter_e; 
   assign lock_exit_miss_e  = monitorexit_e  & lock_miss_valid;

   // LockReleaseTrap
   assign lock0_release  = lc0_m1_eq_0 & lock0_exit & lockwant0;
   assign lock1_release	 = lc1_m1_eq_0 & lock1_exit & lockwant1;
   assign lock_release_e = (lock0_release | lock1_release) & inst_valid[0];


   			   
   // lock0_cache and lock1_cache
   
   assign lock0_cache = ~lockbit & ~hold_e & lock_miss_valid & la0_null_e & monitorenter_e;
   assign lock1_cache = ~lockbit & ~hold_e & lock_miss_valid & ~la0_null_e & la1_null_e & monitorenter_e;
   


   // lock0_uncache and lock1_uncache
   
   assign lock0_uncache = lock0_exit & lc0_m1_eq_0 & lc0_co_bit & ~lockwant0;
   assign lock1_uncache = lock1_exit & lc1_m1_eq_0 & lc1_co_bit & ~lockwant1;
    
   
   /*
    * The load buffer state machine
    */
   assign load_buffer_mux_sel[1] = curr_s;
   assign load_buffer_mux_sel[0] = ~load_buffer_mux_sel[1];

   assign dcu_data_reg_we[0] = ~hold_c & all_load_c&inst_valid[1]&~sc_data_vld;
   assign dcu_data_reg_we[1] = iu_data_vld&~sc_data_vld | icu_data_vld;

   assign next_s = load_buffer_fsm(curr_s,
				   dcu_data_reg_we[1],
				   hold_c
				   );
   ff_sr load_buffer_fsm_reg(.out     (curr_s),
			     .din     (next_s),
			     .reset_l (reset_l),
			     .clk     (clk)
			     );

   function load_buffer_fsm;

      input current_state;
      input valid;
      input hold;
      reg   next_state;

      parameter IDLE = 1'b0,
		HOLD = 1'b1;

      begin : fsm
	 case (current_state)
	   IDLE:
	      if (hold & valid)
		 next_state = HOLD;
	      else
		 next_state = current_state;
	   HOLD:
	      if (~hold & ~valid)
		 next_state = IDLE;
	      else
		 next_state = current_state;
	   default:
	      next_state = 1'bx;
	 endcase // case(current_state)
	 load_buffer_fsm = next_state;
      end // block: fsm

   endfunction // load_buffer_fsm


   /* 
    * Now the register mux select for read and write are separated to support
    * rd/wr register at the same cycle.  This is primarily for ucode.
    */
   // Select which register to read from
   assign reg_rd_mux_sel_r[20] = priv_read_sc_bottom;
   assign reg_rd_mux_sel_r[19] = priv_read_hcr;
   assign reg_rd_mux_sel_r[18] = priv_read_versionid;
   assign reg_rd_mux_sel_r[17] = priv_read_userrange2;
   assign reg_rd_mux_sel_r[16] = priv_read_brk12c;
   assign reg_rd_mux_sel_r[15] = priv_read_brk2a;
   assign reg_rd_mux_sel_r[14] = priv_read_brk1a;
   assign reg_rd_mux_sel_r[13] = priv_read_gc_config;
   assign reg_rd_mux_sel_r[12] = priv_read_userrange1;
   assign reg_rd_mux_sel_r[11] = priv_read_lockaddr1;
   assign reg_rd_mux_sel_r[10] = priv_read_lockaddr0;
   assign reg_rd_mux_sel_r[9]  = priv_read_lockcount1;
   assign reg_rd_mux_sel_r[8]  = priv_read_lockcount0;
   assign reg_rd_mux_sel_r[7]  = priv_read_trapbase;
   assign reg_rd_mux_sel_r[6]  = priv_read_psr;
   assign reg_rd_mux_sel_r[5]  = read_const_pool;
   assign reg_rd_mux_sel_r[4]  = priv_read_oplim;
   assign reg_rd_mux_sel_r[3]  = read_optop;
   assign reg_rd_mux_sel_r[2]  = read_frame;
   assign reg_rd_mux_sel_r[1]  = read_vars;
   assign reg_rd_mux_sel_r[0]  = ~(|reg_rd_mux_sel_r[20:1]);

   ff_sre_21 reg_rd_mux_sel_raw_e_reg(.out    (reg_rd_mux_sel_raw_e[20:0]),
				      .din    (reg_rd_mux_sel_r[20:0]),
				      .enable (~hold_e),
				      .reset_l (reset_l),
				      .clk    (clk)
				      );

   // Select which register to write to
   assign reg_wr_mux_sel_r[18] = priv_write_sc_bottom;

   assign reg_wr_mux_sel_r[17] = priv_write_userrange2;
   assign reg_wr_mux_sel_r[16] = priv_write_brk12c;
   assign reg_wr_mux_sel_r[15] = priv_write_brk2a;
   assign reg_wr_mux_sel_r[14] = priv_write_brk1a;
   assign reg_wr_mux_sel_r[13] = priv_write_gc_config;
   assign reg_wr_mux_sel_r[12] = priv_write_userrange1;
   assign reg_wr_mux_sel_r[11] = priv_write_lockaddr1;
   assign reg_wr_mux_sel_r[10] = priv_write_lockaddr0;
   assign reg_wr_mux_sel_r[9]  = priv_write_lockcount1;
   assign reg_wr_mux_sel_r[8]  = priv_write_lockcount0;
   assign reg_wr_mux_sel_r[7]  = priv_write_trapbase;
   assign reg_wr_mux_sel_r[6]  = priv_write_psr;
   assign reg_wr_mux_sel_r[5]  = write_const_pool;
   assign reg_wr_mux_sel_r[4]  = priv_write_oplim | 
				(priv_update_optop & second_cyc_r);
   assign reg_wr_mux_sel_r[3]  = write_optop | 
				(priv_update_optop & first_cyc_r);
   assign reg_wr_mux_sel_r[2]  = write_frame;
   assign reg_wr_mux_sel_r[1]  = write_vars;
   assign reg_wr_mux_sel_r[0]  = ~(|reg_wr_mux_sel_r[18:1]);

   ff_sre_19 reg_wr_mux_sel_raw_e_reg(.out    (reg_wr_mux_sel_raw_e[18:0]),
				      .din    (reg_wr_mux_sel_r[18:0]),
				      .enable (~hold_e),
				      .reset_l (reset_l),
				      .clk    (clk)
				      );

// ucode register select
  assign ucode_rd_psr_e = ~ucode_reg_rd[2] & ~ucode_reg_rd[1] & ucode_reg_rd[0];
  assign ucode_rd_vars_e = ~ucode_reg_rd[2] & ucode_reg_rd[1] & ~ucode_reg_rd[0];
  assign ucode_rd_frame_e = ~ucode_reg_rd[2] & ucode_reg_rd[1] & ucode_reg_rd[0];
  assign ucode_rd_const_p_e = ucode_reg_rd[2] & ~ucode_reg_rd[1] & ~ucode_reg_rd[0];
  assign ucode_rd_port_c_e = ucode_reg_rd[2] & ~ucode_reg_rd[1] & ucode_reg_rd[0];
  assign ucode_rd_dcache_e = ucode_reg_rd[2] & ucode_reg_rd[1] & ~ucode_reg_rd[0];
  assign ucode_rd_part_dcache_e = ucode_reg_rd[2] & ucode_reg_rd[1] & ucode_reg_rd[0];

  ff_sre_2   ucode_rd_part_dcache_c_reg (.out({ucode_rd_dcache_c,ucode_rd_part_dcache_c}),
                                       .din({ucode_rd_dcache_e,ucode_rd_part_dcache_e}),
                                       .clk(clk),
                                       .reset_l(reset_l),
                                       .enable(~hold_c)
					 );


  assign ucode_wr_pc_e = ~ucode_reg_wr[2] & ~ucode_reg_wr[1] & ucode_reg_wr[0];
  assign ucode_wr_vars_e = ~ucode_reg_wr[2] & ucode_reg_wr[1] & ~ucode_reg_wr[0];
  assign ucode_wr_frame_e = ~ucode_reg_wr[2] & ucode_reg_wr[1] & ucode_reg_wr[0];
  assign ucode_wr_const_p_e = ucode_reg_wr[2] & ~ucode_reg_wr[1] & ~ucode_reg_wr[0];
  assign ucode_wr_optop_e = ucode_reg_wr[2] & ~ucode_reg_wr[1] & ucode_reg_wr[0];
  assign ucode_wr_vars_optop_e = ucode_reg_wr[2] & ucode_reg_wr[1] & ~ucode_reg_wr[0];
  assign ucode_wr_psr_e = ucode_reg_wr[2] & ucode_reg_wr[1] & ucode_reg_wr[0];

   /*
    * Separte the rd/wr register mux select for ucode support
    */
   assign reg_rd_mux_sel[20:7] = reg_rd_mux_sel_raw_e[20:7];
   assign reg_rd_mux_sel[6]    = reg_rd_mux_sel_raw_e[6] | ucode_rd_psr_e;
   assign reg_rd_mux_sel[5]    = reg_rd_mux_sel_raw_e[5] | ucode_rd_const_p_e;
   assign reg_rd_mux_sel[4]    = reg_rd_mux_sel_raw_e[4];
   assign reg_rd_mux_sel[3]    = reg_rd_mux_sel_raw_e[3];
   assign reg_rd_mux_sel[2]    = reg_rd_mux_sel_raw_e[2] | ucode_rd_frame_e;
   assign reg_rd_mux_sel[1]    = reg_rd_mux_sel_raw_e[1] | ucode_rd_vars_e;
   assign reg_rd_mux_sel[0]    = ~(|reg_rd_mux_sel[20:1]);
   assign reg_wr1_mux_sel[18:7] = reg_wr_mux_sel_raw_e[18:7];

   // write enable to SMU's version of sbase signal whenever there's
   // write_sbase opcode - This is done to improve timing on smu_stall
   // signal 

   assign iu_sbase_we = reg_wr_mux_sel[18];

   assign reg_wr1_mux_sel[6]    = reg_wr_mux_sel_raw_e[6] | ucode_wr_psr_e;
   assign reg_wr1_mux_sel[5]    = reg_wr_mux_sel_raw_e[5] | ucode_wr_const_p_e;
   assign reg_wr1_mux_sel[4]    = reg_wr_mux_sel_raw_e[4];
   assign reg_wr1_mux_sel[3]    = reg_wr_mux_sel_raw_e[3] | ucode_wr_optop_e;
   assign reg_wr1_mux_sel[2]    = reg_wr_mux_sel_raw_e[2] | ucode_wr_frame_e; 
   assign reg_wr1_mux_sel[1]    = reg_wr_mux_sel_raw_e[1] | ucode_wr_vars_e; 
   assign reg_wr1_mux_sel[0]    = ~(|reg_wr1_mux_sel[18:1]);

   // Remember to qualify it with inst_valid[0] and ~iu_trap_c, because there
   // is no reg_wr_e anymore.
   assign reg_wr_mux_sel[18:0] = reg_wr1_mux_sel[18:0] & {19{inst_valid[0]&~hold_c}} &
				 {19{~kill_inst_e&~iu_trap_c}};

   // This mux is used to select data input for the load buffer. 
   // Mux to select (icu_diag data ,dcu_dia data, dcu_data)
   assign load_data_mux_sel_r[2] = priv_read_icache_tag | priv_read_icache_data;
   assign load_data_mux_sel_r[1] = priv_read_dcache_tag | priv_read_dcache_data;
   assign load_data_mux_sel_r[0] = ~(|load_data_mux_sel_r[2:1]);

   ff_sre_3 load_data_mux_sel_e_reg(.out    (load_data_mux_sel_e[2:0]),
				    .din    (load_data_mux_sel_r[2:0]),
				    .enable (~hold_e),
				    .reset_l (reset_l),
				    .clk    (clk)
				    );

   ff_sre_3 load_data_mux_sel_reg (.out	   (load_data_c_mux_sel[2:0]),
				   .din	   (load_data_mux_sel_e[2:0]),
				   .enable (~hold_c),
				   .reset_l (reset_l),
				   .clk	   (clk)
				   );
   assign	icu_diag_ld_c 	=	load_data_c_mux_sel[2]&inst_valid[1];

   ff_sre fpop_reg(.out   (fpu_op_e),
			 .din	(fpu_op_r),
			 .enable(~hold_e),
			 .reset_l(reset_l),
			 .clk	(clk)
			 );
assign	fpu_mux_sel[1]	=	fpu_op_e ;
assign	fpu_mux_sel[0]	=	~fpu_op_e ;



// Mux to select (output of dcu_hold reg. or output of W stage alu_out reg)
// select dcache data for ucode only if there is either rd_dcache_w or rd_part_dcache_w
// is active. else select the alu_out_w data. Also select dcache data for
// normal loads in the W stage 
  assign forward_data_w_mux_sel_c[1] = ucode_rd_part_dcache_c | ucode_rd_dcache_c 
					| all_load_c&~ucode_busy_c;
  assign forward_data_w_mux_sel_c[0] = ~forward_data_w_mux_sel_c[1];


// To improve timing on RS1 and RS2, we are moving all the mux selects to ex_dpath

  assign forward_w_sel_din = forward_data_w_mux_sel_c;


// Mux sel for output from cmp 
  assign cmp_mux_sel_r[2] = ifeq | ifne | iflt | ifge | ifgt |
			    ifle | nonnull_quick | ifnull | ifnonnull;
  assign cmp_mux_sel_r[1] = if_acmpeq | if_acmpne ;
  assign cmp_mux_sel_r[0] = ~cmp_mux_sel_r[1]&~cmp_mux_sel_r[2];

  ff_sre_3   cmp_mux_sel_reg (.out(cmp_mux_sel[2:0]),
			      .din(cmp_mux_sel_r[2:0]),
			      .clk(clk),
			      .enable(~hold_e),
			      .reset_l(reset_l));

// Mux select for scr1 of data adder
  assign adder_src1_mux_sel_r[1] = isub | ineg | 
				   (lsub & (first_cyc_r | second_cyc_r)) | 
				   (lneg & (first_cyc_r | second_cyc_r));
  assign adder_src1_mux_sel_r[0] = ~adder_src1_mux_sel_r[1]; 

  ff_sre_2   adder_src1_mux_sel_raw_ereg (.out(adder_src1_mux_sel_raw_e[1:0]),
				          .din(adder_src1_mux_sel_r[1:0]),
				          .clk(clk),
				          .enable(~hold_e),
				          .reset_l(reset_l));

  assign adder_src1_mux_sel[1] = adder_src1_mux_sel_raw_e[1] |
				 (~alu_adder_fn[1] & alu_adder_fn[0]);
  assign adder_src1_mux_sel[0] = ~(adder_src1_mux_sel[1]);

// Mux select for scr2 of data adder
  ff_sre   adder_src2_mux_sel_reg (.out(adder_src2_mux_sel_r),
				     .din(lneg|ineg),
				     .clk(clk),
				     .enable(~hold_e),
				     .reset_l(reset_l));
assign	adder_src2_mux_sel[2]	=	adder_src2_mux_sel_r&~ucode_busy_e;
assign	adder_src2_mux_sel[1]	=	ucode_busy_e&alu_adder_fn[1] & ~alu_adder_fn[0];
assign	adder_src2_mux_sel[0] 	=	~adder_src2_mux_sel[2]&~adder_src2_mux_sel[1];

// Ucode busy pipe.
  ff_sre   ucode_busy_e_reg (.out(ucode_busy_e),
			     .din(ucode_busy_r),
			     .clk(clk),
			     .enable(~hold_e),
			     .reset_l(reset_l));

 ff_sre   ucode_busy_c_reg (.out(ucode_busy_c),
                             .din(ucode_busy_e),
                             .clk(clk),
                             .enable(~hold_c),
                             .reset_l(reset_l));

// Mux select for branch address 
  assign iu_br_pc_mux_sel[2] = ucode_busy_e & ~reissue_c;
  assign iu_br_pc_mux_sel[1] = reissue_c;
  assign iu_br_pc_mux_sel[0] = ~(iu_br_pc_mux_sel[2] | iu_br_pc_mux_sel[1]);

   // Bit logic control
   assign bit_mux_sel_r[4] = fneg | dneg;
   assign bit_mux_sel_r[3] = jsr  | jsr_w;
   assign bit_mux_sel_r[2] = ixor | (lxor & (first_cyc_r | second_cyc_r));
   assign bit_mux_sel_r[1] = iand | land & (first_cyc_r | second_cyc_r);
   assign bit_mux_sel_r[0] = ~(|bit_mux_sel_r[4:1]);

   ff_sre_5 bit_mux_sel_reg (.out    (bit_mux_sel[4:0]),
			     .din    (bit_mux_sel_r[4:0]),
			     .enable (~hold_e),
			     .reset_l (reset_l),
			     .clk    (clk)
			     );

// Convert logic control
  assign cvt_mux_sel_r[4] = int2short; 
  assign cvt_mux_sel_r[3] = int2char; 
  assign cvt_mux_sel_r[2] = int2byte; 
  assign cvt_mux_sel_r[1] = i2l; 
  assign cvt_mux_sel_r[0] = ~(cvt_mux_sel_r[4] | cvt_mux_sel_r[3] |
				cvt_mux_sel_r[2] | cvt_mux_sel_r[1]); 

  ff_sre_5   cvt_mux_sel_reg (.out(cvt_mux_sel[4:0]),
			     .din(cvt_mux_sel_r[4:0]),
			     .clk(clk),
			     .reset_l(reset_l),
			     .enable(~hold_e)
			      );

   // Mux select for scr1 of shifter
   assign shifter_src1_mux_sel_r[4] = (lshr | lushr) & second_cyc_r;
   assign shifter_src1_mux_sel_r[3] = ishr;
   assign shifter_src1_mux_sel_r[2] = (lshr | lushr) & first_cyc_r;
   assign shifter_src1_mux_sel_r[1] = lshl & second_cyc_r;
   assign shifter_src1_mux_sel_r[0] = ~(|shifter_src1_mux_sel_r[4:1]);
   ff_sre_5 shifter_src1_mux_sel_reg (.out    (shifter_src1_mux_sel[4:0]),
				      .din    (shifter_src1_mux_sel_r[4:0]),
				      .enable (~hold_e),
				      .reset_l (reset_l),
				      .clk    (clk)
				      );

   // Mux select for scr2 of shifter
   assign shifter_src2_mux_sel_r[2] = lshl & second_cyc_r;
   assign shifter_src2_mux_sel_r[1] = ishl | (lshl & first_cyc_r) |
				      ishr | iushr | (lshr & second_cyc_r) |
				      (lushr & second_cyc_r);
   assign shifter_src2_mux_sel_r[0] = ~(|shifter_src2_mux_sel_r[2:1]);
   ff_sre_3 shifter_src2_mux_sel_reg (.out    (shifter_src2_mux_sel[2:0]),
				      .din    (shifter_src2_mux_sel_r[2:0]),
				      .enable (~hold_e),
				      .reset_l (reset_l),
				      .clk    (clk)
				      );

// Shifter word select MSW LSW 
  assign shifter_word_sel_r = (lshl & second_cyc_r) | (lshr & first_cyc_r) | 
			      (lushr & first_cyc_r); 

   ff_sre shifter_word_sel_flop(.out	(shifter_word_sel),
				.din	(shifter_word_sel_r),
				.enable	(~hold_e),
				.reset_l	(reset_l),
				.clk	(clk)
				);

   // Mux select for a 32 bits or 16 bits PC offset
   assign offset_mux_sel_r[4] = load_word_index | store_word_index |
				nastore_word_index;
   assign offset_mux_sel_r[3] = load_short_index | load_char_index |
				store_short_index;
   assign offset_mux_sel_r[2] = load_byte_index | load_ubyte_index |
				store_byte_index; 
   assign offset_mux_sel_r[1] = goto_w | jsr_w; 
   assign offset_mux_sel_r[0] = ~(|offset_mux_sel_r[4:1]);

   ff_sre_5 offset_mux_sel_reg (.out	(offset_mux_sel[4:0]),
				.din	(offset_mux_sel_r[4:0]),
				.enable	(~hold_e),
				.reset_l	(reset_l),
				.clk	(clk)
				);


mj_spare spare1( .clk(clk),
                .reset_l(reset_l));

mj_spare spare2( .clk(clk),
                .reset_l(reset_l));

 
endmodule


module branch_logic 
		(	
		 branch_qual,
		 cmp_eq_e,
		 cmp_gt_e,
	         cmp_lt_e,
		 reissue_c,
		 sc_dcache_req,
		 kill_inst_e,
		 iu_inst_raw_e,
		 inst_valid,
		 ucode_dcu_req,
		 ucode_busy_e,
		 iu_brtaken_e,
		 branch_taken_e,
		 iu_inst_e

);


input	[4:0]	branch_qual;
input		cmp_eq_e;
input		cmp_gt_e;
input		cmp_lt_e;
input		reissue_c;
input		sc_dcache_req;
input		kill_inst_e;
input	[3:2]	iu_inst_raw_e;
input		inst_valid;
input	[1:0]	ucode_dcu_req;
input		ucode_busy_e;

output		iu_brtaken_e;
output		branch_taken_e;
output	[3:2]	iu_inst_e;

wire	[3:2]	iu_inst_raw;
wire	[3:2]	ucode_inst_e;


assign	iu_brtaken_e 	=	branch_qual[4]& cmp_eq_e |
				branch_qual[3]&!cmp_eq_e |
				branch_qual[2]& cmp_gt_e |
				branch_qual[1]& cmp_lt_e |
				branch_qual[0] |reissue_c;

assign	branch_taken_e	 =      iu_brtaken_e;

assign iu_inst_e[3]	=  (ucode_dcu_req[1] & ~ucode_dcu_req[0]|iu_inst_raw_e[3])& ~sc_dcache_req & inst_valid;
assign iu_inst_e[2]	=  (ucode_dcu_req[0]| iu_inst_raw_e[2] | sc_dcache_req )
	  	           &inst_valid;

endmodule
