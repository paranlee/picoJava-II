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

module ex(opcode_1_op_r,	// From ex_ctl
	  opcode_2_op_r,
	  opcode_3_op_r,
	  opcode_4_op_r,
	  opcode_5_op_r,
	  valid_op_r,
	  inst_valid,
	  iu_data_vld,
	  iu_smiss,
	  lduse_bypass,
	  sc_dcache_req,
	  sc_data_vld,
	  reissue_c,
	  fold_c,
	  kill_inst_e,
	  iu_trap_r,
	  iu_trap_c,
	  first_cyc_r,
	  first_cyc_e,
	  second_cyc_r,
	  hold_ex_ctl_e,
	  hold_ex_ctl_c,
	  hold_ex_dp_e,
	  hold_ex_dp_c,
	  hold_ex_reg_e,
	  hold_ex_reg_c,
	  hold_imdr,
	  ucode_done,
	  ucode_reg_wr,
	  ucode_reg_rd,
	  ucode_dcu_req,
	  alu_adder_fn,
	  mem_adder_fn,
	  rs1_mux_sel_din,
	  forward_c_sel_din,
	  ucode_active,
	  pj_resume,
	  trap_in_progress,

	  illegal_op_r,
	  priv_inst_r,
	  soft_trap_r,
	  fpu_op_r,
	  mis_align_c,
	  emulated_trap_r,
	  async_error,
	  mem_prot_error_c,
	  oplim_trap_c,
	  brk12c_halt,
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
	  opcode_1_op_c,
	  wr_optop_e,
	  iu_sbase_we,
	  ret_optop_update,
	  iu_brtaken_e,
	  branch_taken_e,
	  iu_inst_e,
	  iu_special_e,
	  iu_dcu_flush_e,
	  iu_icu_flush_e,
	  iu_zero_e,
	  iu_d_diag_e,
	  iu_i_diag_e,
	  load_c,
	  icu_data_vld,
	  icu_diag_ld_c,
	  zero_trap_e,
	  iu_bypass_rs1_e,
	  iu_bypass_rs2_e,
	  iu_rs1_e_0_l,
	  iu_rs2_e_0_l,

	  optop_c,
	  pc_r,
	  pc_e,
	  pc_c,
	  ru_rs1_e,
	  ru_rs2_e,
	  scache_miss_addr_e,
	  ucode_porta_e,
	  ucode_portc_e,
	  iu_alu_a,
	  iu_alu_b,
	  u_m_adder_porta_e,
	  u_m_adder_portb_e,
	  rs1_bypass_mux_sel,
	  rs2_bypass_mux_sel,
	  ucode_reg_data_mux_sel,
	  dcu_diag_data_c,
	  fpu_data_e,
	  fpu_hold,
	  icu_diag_data_c,
	  dcu_data_c,
	  smu_sbase,
	  smu_sbase_we,
	  smu_addr,
	  smu_ld,
	  smu_st,
	  pj_boot8_e,
	  pj_no_fpu_e,
	  tbase_tt_e,
	  tbase_tt_we_e,

	  alu_out_w,
	  dcu_data_w,
	  iu_addr_e,
	  iu_addr_e_2,
	  iu_addr_e_31,
	  iu_br_pc_e,
	  iu_data_e,
	  wr_optop_data_e,
	  ucode_reg_data,
	  vars_out,
	  psr_out,
	  sc_bottom_out,
	  iu_data_in,
	  imdr_done_e,
	  imdr_div0_e,
	  null_objref_e,
	  rs1_bypass_mux_out,
	  rs2_bypass_mux_out,
	  adder_out_e,
	  carry_out_e,

	  optop_e,
	  ucode_madder_sel2,
	  ucode_alu_a_sel,
	  ucode_alu_b_sel,
	  ucode_porta_sel,

	  reset_l,
	  clk,
	  sm,
	  sin,
	  so);

   /***************************
    * Interface signals to IU *
    ***************************/

   // Input to ex_ctl
   input [7:0]	 opcode_1_op_r;		// 1st byte of the opcode
   input [7:0] 	 opcode_2_op_r;		// 2nd byte of the opcode
   input [7:0] 	 opcode_3_op_r;		// 3rd byte of the opcode
   input [7:0] 	 opcode_4_op_r;		// 4th byte of the opcode
   input [7:0] 	 opcode_5_op_r;		// 5th byte of the opcode
   input 	 valid_op_r;		/* This indicates whether the opcode is
					 * valid or not.
					 */
   input [2:0] 	 inst_valid;		/* Valid bits for the pipe to keep track
					 * of instructions.  0=E, 1=C, 2=W
					 */
   input 	 iu_data_vld;		// DCU data is available
   input	 icu_data_vld;		// Diagnostic ICU data available
   input 	 iu_smiss;		// Stack cache miss
   input	 lduse_bypass;		// Load use bypass
   input 	 sc_dcache_req;		// Stack cache miss req to DCU
   input	 sc_data_vld;		// data from d$ is due to S$ read miss.
   input 	 reissue_c;		// Reissue PC from IU
   input	 fold_c;		// folded group in C.
   input 	 kill_inst_e;		// kill dcu inst/priv writes
   input	 iu_trap_r;		// Indicates a trap in R stage
   input	 iu_trap_c;		// Indicates trap occurred in C stage
   input 	 first_cyc_r;		// Signal for 1st cycle of long instr.
   input 	 second_cyc_r;		// Signal for 2nd cycle of long instr.
   input 	 hold_ex_ctl_e;		// Signal to hold E stage
   input 	 hold_ex_dp_e;		// Signal to hold E stage
   input 	 hold_ex_reg_e;		// Signal to hold E stage
   input	 hold_imdr;		// Hold the mul/div unit
   input 	 hold_ex_ctl_c;		// Signal to hold C stage
   input 	 hold_ex_dp_c;		// Signal to hold C stage
   input 	 hold_ex_reg_c;		// Signal to hold C stage
   input 	 ucode_done;		// Ucode busy
   input [2:0] 	 ucode_reg_wr;		// Write ucode_porta to priv registers 
   input [2:0] 	 ucode_reg_rd;		// Read priv registers to stack cache 
   input [1:0]   ucode_dcu_req;  	// Ucode dcu request
   input [1:0]   alu_adder_fn;   	// Ucode using adder
   input [1:0]   mem_adder_fn;   	// Ucode using mem adder
   input	 rs1_mux_sel_din;	// Selects scache data in case of sc misses
   input	 forward_c_sel_din;	// Selects DCU data for forward data_c
   input	 ucode_active;		// Ucode is using scache to read
   input	 pj_resume;		// PJ RESUME signal for break points
   input	 trap_in_progress;	// Indicates trap status	

   // Output of ex_ctl
   output 	 illegal_op_r;		// Usused extended bytecodes
   output 	 priv_inst_r;		// Privileged instruction 
   output 	 soft_trap_r;		// Tell IU take soft_trap 
   output 	 fpu_op_r;		// FPU opcodes in R stage 
   output 	 mis_align_c;		// Mis-aligned exception 
   output 	 emulated_trap_r;	// Emulated trap
   output 	 async_error;		// asynchronous_error due to smu access
   output 	 mem_prot_error_c;	// Memory protection error in C stage
   output 	 oplim_trap_c;		// Oplim trap in C stage
   output 	 brk12c_halt;		// Bit 31 of BRK12C register
   output 	 data_brk1_c;		// Data breakpoint1 exception in C stage
   output 	 data_brk2_c;		// Data breakpoint2 exception in C stage
   output 	 inst_brk1_r;		// Inst breakpoint1 exception in R stage
   output 	 inst_brk2_r;		// Inst breakpoint2 exception in R stage
   output 	 first_cyc_e;		// First cycle in E Stage of two cycle instn.
   output 	 lock_count_overflow_e;	// LockCountOverFlowTrap in E stage
   output 	 lock_enter_miss_e;	// LockEnterMissTrap	 in E stage
   output 	 lock_exit_miss_e;	// LockExitMissTrap	 in E stage
   output 	 lock_release_e;	// LockReleaseTrap	 in E stage
   output 	 null_ptr_exception_e;	// runtime_NullPtrException in E stage
   output 	 priv_powerdown_e;	// priv_powerdown in E stage
   output 	 priv_reset_e;		// priv_reset in E stage
   output [7:0]  opcode_1_op_c;		// Opcode at C stage 
   output	 iu_sbase_we;		// Write enable signal to SMU, whenever there's wr_sbase
					// etc.
   output 	 wr_optop_e;		// Tell IU it is a write_optop
   output 	 ret_optop_update;	// Tell IU it is a write_optop due to a return
   output 	 iu_brtaken_e;		// Tell IU if it is branch taken 
   output	 branch_taken_e;	// internal branch signal.timing change
   output [7:0]  iu_inst_e;		// [7]	 = non allocating
					// [6]	 = opposite endiannes
					// [5]	 = signed
					// [4]	 = noncacheable
					// [3]	 = store
					// [2]	 = load
					// [1:0] = size
   output	 iu_special_e;		// special dcu related inst. timing purpose
					
   output [2:0]	 iu_dcu_flush_e;	// Tell DCU that it is a cache_flush,
					// cache_index_flush or cache_invalidate 
   output 	 iu_icu_flush_e;	// Tell ICU that it is a cache_flush,
					// cache_index_flush or cache_invalidate 
   output 	 iu_zero_e;		// cache zero line
   output [3:0]  iu_d_diag_e;		// [3] =  Dcache RAm Write
					// [2] =  Dcache Ram Read
					// [1] =  DTag	Write
					// [0] =  Dtag	Read
   output [3:0]  iu_i_diag_e;           // [3] =  Icache RAm Write
                                        // [2] =  Icache Ram Read
                                        // [1] =  ITag  Write
                                        // [0] =  Itag  Read
   output 	 load_c;		// There is a load in C stage
   output	 icu_diag_ld_c;		// ICU diagnostic load in C stage
   output 	 zero_trap_e;		// Take zero_line etrap in E stage 
   output        iu_bypass_rs1_e;       // RS1 need bypass
   output        iu_bypass_rs2_e;       // RS2 need bypass

   // Input to ex_dpath, ex_regs, and ex_imdr
   input [31:0]  optop_c;		// C stage OPTOP value from pipe control
   input [31:0]  pc_r;			// R stage PC value
   input [31:0]  pc_e;			// E stage PC value
   input [31:0]  pc_c;			// C stage PC value
   input [31:0]  ru_rs1_e;		// Operand 1 value from RCU
   input [31:0]  ru_rs2_e;		// Operand 2 value from RCU
   input [31:0]  scache_miss_addr_e;	// S$ miss address to adder2
   input [31:0]  ucode_porta_e;		// Operand 1 value from ucode
   input [31:0]  ucode_portc_e;		// Result of ucode computation
   input [31:0]  iu_alu_a;		// ucode alu adder input
   input [31:0]  iu_alu_b;		// ucode alu adder input
   input [31:0]  u_m_adder_porta_e;	// ucode address 1 to adder2
   input [31:0]  u_m_adder_portb_e;	// ucode address 2 to adder2
   input [4:0] 	 rs1_bypass_mux_sel;	// Select signal of rs1_forward_mux
   input [4:0] 	 rs2_bypass_mux_sel;	// Select signal of rs2_forward_mux
   input [6:0] 	 ucode_reg_data_mux_sel;/* bit 6, 0x40: TRAPBASE
					 * bit 5, 0x20: GC_CONFIG
					 * bit 4, 0x10: PSR
					 * bit 3, 0x08: CONST_POOL
					 * bit 2, 0x04: FRAME
					 * bit 1, 0x02: VARS
					 * bit 0, 0x01: PC (C stage)
					 */
   input [31:0]  dcu_diag_data_c;	// DCU diagnostic read data
   input [31:0]  fpu_data_e;		// FPU result
   input	 fpu_hold;		// Fold the fpu data
   input [31:0]  icu_diag_data_c;	// ICU diagnostic read data
   input [31:0]  dcu_data_c;		// Input to dcu_hold_reg
   input [31:2]  smu_sbase;		// SC_BOTTOM value from SMU
   input 	 smu_sbase_we;		// Write-enable of SC_BOTTOM from SMU
   input [29:14] smu_addr;		// Input from cpu.v
   input 	 smu_ld;		// Input from cpu.v
   input 	 smu_st;		// Input from cpu.v
   input 	 pj_boot8_e;		// Input from pin
   input 	 pj_no_fpu_e;		// Input from pin
   input [7:0] 	 tbase_tt_e;		// Input from trap.v
   input 	 tbase_tt_we_e;		// Input from trap.v

   // Output of ex_dpath, ex_regs, and ex_imdr
   output [31:0] alu_out_w;		// Main alu output, W stage
   output [31:0] dcu_data_w;		// Output of dcu_hold register
   output [31:0] iu_addr_e;		// Address adder (adder2) output
   output 	 iu_addr_e_2;		// Address adder (adder2) output
   output 	 iu_addr_e_31;		// Address adder (adder2) output
   output [31:0] iu_br_pc_e;		// Branch target PC to ICU
   output [31:0] iu_data_e;		// Data corresponding to address
   output [31:0] wr_optop_data_e;	// Data for write optop operation
   output [31:0] ucode_reg_data;	// Output bus for ucode register read
   output [31:0] vars_out;		// Output of the VARS register
   output [31:0] psr_out;		// Output of the PSR register
   output [31:0] sc_bottom_out;		// Output of the SC_BOTTOM register
   output [31:0] iu_data_in;		// Data to be written onto SMU's version
					// of sbase in case of wr_sbase opcodes
   output 	 imdr_done_e;		// Done signal from IMDR
   output 	 imdr_div0_e;		// Divide-by-zero from IMDR
   output 	 null_objref_e;		// Comparator equal output for ucode
   output [31:0] rs1_bypass_mux_out;	// Rs1 data after bypass mux
   output [31:0] rs2_bypass_mux_out;	// Rs2 data after bypass mux
   output	 iu_rs1_e_0_l;		// fast signal for ucode. rs1 bit0
   output	 iu_rs2_e_0_l;		// fast signal for ucode. rs2 bit0
   output [31:0] adder_out_e;		// Sum output of the ALU adder
   output 	 carry_out_e;		// Carry output of the ALU adder

   // Following signals are added to improve timing on ucode paths 

   input [31:0]  optop_e;		// E stage OPTOP value from pipe control
   input [3:0]	 ucode_madder_sel2;	// u_f19[1:0] from ucode
   input [1:0]	 ucode_alu_a_sel;	// u_f23[1:0] from ucode
   input [2:0]   ucode_alu_b_sel;       // u_f07[2:0] from ucode
   input [1:0]   ucode_porta_sel;       // u_f00[1:0] from ucode

   // Global signals
   input 	 reset_l;			// Global reset signal
   input 	 clk;			// Global clock signal
   input 	 sm;			// Scan enable
   input 	 sin;			// Scan input of this module
   output 	 so;			// Scan output of this module

   /******************
    * Internal wires *
    ******************/

   wire		 ucode_busy_e;
   wire 	 carry_in_e;		// carry_in bit from R decode to E
   wire 	 mul_e;			// IMDR: multiplication
   wire 	 div_e;			// IMDR: division
   wire 	 rem_e;			// IMDR: remainder
   wire 	 shift_dir_e;		// Shifter: 0: left, 1: right
   wire 	 shift_sel;		// Shifter: 0: left, 1: right
   wire 	 sign_e;		// Shifter & Converter: sign extension
   wire [31:0] 	 ucode_porta_mux_out;	// The real rs1 value after forwarding
					// and ucode
   wire [31:0] 	 reg_data_e;		// Output from register mux
   wire [31:0] 	 iu_addr_c;		// Address adder output, C stage
   wire 	 cmp_eq_e;		// Output of comparator in ex_dpath
   wire 	 cmp_gt_e;		// Output of comparator in ex_dpath
   wire 	 cmp_lt_e;		// Output of comparator in ex_dpath
   wire 	 null_objref_e;		// ucode_porta_mux_out (Rs1) == zero
   wire 	 range1_l_cmp1_lt;	// iu_addr_c < userrange1.userlow
   wire 	 range1_h_cmp1_gt;	// iu_addr_c > userrange1.userhigh
   wire 	 range1_h_cmp1_eq;	// iu_addr_c = userrange1.userhigh
   wire 	 range2_l_cmp1_lt;	// iu_addr_c < userrange2.userlow
   wire 	 range2_h_cmp1_gt;	// iu_addr_c > userrange2.userhigh
   wire 	 range2_h_cmp1_eq;	// iu_addr_c = userrange2.userhigh
   wire 	 range1_l_cmp2_lt;	// optop_c < userrange1.userlow
   wire 	 range1_h_cmp2_gt;	// optop_c > userrange1.userhigh
   wire 	 range1_h_cmp2_eq;	// optop_c = userrange1.userhigh
   wire 	 range2_l_cmp2_lt;	// optop_c < userrange2.userlow
   wire 	 range2_h_cmp2_gt;	// optop_c > userrange2.userhigh
   wire 	 range2_h_cmp2_eq;	// optop_c = userrange2.userhigh
   wire [31:0] 	 brk12c;		// Output of the BRK12C register
   wire 	 data_brk1_31_13_eq;	// iu_addr_c[31:13] == brk1a[31:13]
   wire 	 data_brk1_11_4_eq;	// iu_addr_c[11:4]  == brk1a[11:4]
   wire [4:0] 	 data_brk1_misc_eq;	// iu_addr_c[12,3:0]== brk1a[12,3:0]
   wire 	 data_brk2_31_13_eq;	// iu_addr_c[31:13] == brk2a[31:13]
   wire 	 data_brk2_11_4_eq;	// iu_addr_c[11:4]  == brk2a[11:4]
   wire [4:0] 	 data_brk2_misc_eq;	// iu_addr_c[12,3:0]== brk2a[12,3:0]
   wire 	 inst_brk1_31_13_eq;	// pc_r[31:13] == brk1a[31:13]
   wire 	 inst_brk1_11_4_eq;	// pc_r[11:4]  == brk1a[11:4]
   wire [4:0] 	 inst_brk1_misc_eq;	// pc_r[12,3:0]== brk1a[12,3:0]
   wire 	 inst_brk2_31_13_eq;	// pc_r[31:13] == brk2a[31:13]
   wire 	 inst_brk2_11_4_eq;	// pc_r[11:4]  == brk2a[11:4]
   wire [4:0] 	 inst_brk2_misc_eq;	// pc_r[12,3:0]== brk2a[12,3:0]
   wire 	 priv_update_optop;	// From ex_ctl to ex_regs
   wire 	 lc0_count_reg_we;	// Write enable of lockcount0 register
   wire 	 lc1_count_reg_we;	// Write enable of lockcount1 register
   wire 	 la0_hit;		// 1 if lockaddr0 == objref in data_in
   wire 	 lc0_eq_255;		// 1 if lockcount0   == 255, 0 otherwise
   wire 	 lc0_eq_0;		// 1 if lockcount0   ==   0, 0 otherwise
   wire 	 lc0_m1_eq_0;		// 1 if lockcount0-1 ==   0, 0 otherwise
   wire 	 lockwant0;		// Bit 14 of lockcount0 register
   wire		 lc0_co_bit;		// Bit 15 of lockcount0 register
   wire		 la0_null_e;		// 1 if lockaddr0 == 0, 0 otherwise
   wire 	 la1_hit;		// 1 if lockaddr1 == objref in data_in
   wire 	 lc1_eq_255;		// 1 if lockcount1   == 255, 0 otherwise
   wire 	 lc1_eq_0;		// 1 if lockcount1   ==   0, 0 otherwise
   wire 	 lc1_m1_eq_0;		// 1 if lockcount1-1 ==   0, 0 otherwise
   wire 	 lockwant1;		// Bit 14 of lockcount1 register
   wire		 lc1_co_bit;		// Bit 15 of lockcount0 register	
   wire   	 la1_null_e;		// 1 if lockaddr1 == 0, 0 otherwise
   wire		 lock0_cache;		// control signal to cache a lock in lock pair 0
   wire		 lock1_cache;		// control signal to cache a lock in lock pair 1
   wire		 lock0_uncache;		// control signal to uncache a lock in lock pair 0
   wire		 lock1_uncache;		// control signal to uncache a lock in lock pair 1
   wire		 monitorenter_e;	// monitorenter in E stage
   wire		 load_buffer_mux_out_0; // lockbit from ex_dpath to ex_ctl

   wire [1:0] 	 bit_cvt_mux_sel;	/* 1: bit operator output
					 * 0: converter wire
					 */
   wire [2:0] 	 constant_mux_sel;	/* 2:  1 -- gt
					 * 1:  0 -- eq
					 * 0: -1 -- lt
					 */
   wire [7:0] 	 alu_out_mux_sel;	/* 7: constant_mux_out
					 * 6: imdr_data
					 * 5: reg_mux_out
					 * 4: bit_cvt_mux_out
					 * 3: shifter wire
					 * 2: adder wire
					 * 1: ucode_portc
					 * 0: bypass
					 */
   wire [4:0] 	 offset_mux_sel;	/* 16: 32-bit offset for ld/st index
					 *  8: 16-bit offset for ld/st index
					 *  4: 8-bit offset for ld/st index
					 *  2: opcode_e (32-bit offset)
					 *  1: offset16 (16-bit offset)
					 */
   wire [1:0]    wr_optop_mux_sel;      /* 2: vars_out
                                         * 1: ucode_porta_mux_out
                                         */
   wire 	 adder2_src1_mux_sel;	

   wire [3:0] 	 adder2_src2_mux_sel;	/* 3: zero
					 * 2: offset_e
					 * 1: u_m_adder_portb
					 * 0: ~u_m_adder_portb
					 */
   wire [1:0] 	 iu_data_mux_sel;	/* 1: ucode_portc
					 * 0: rs2_bypass_mux_out
					 */
   wire [20:0] 	 reg_rd_mux_sel;	/* 20: 0x80000: SC_BOTTOM
					 * 19: 0x40000: HCR
					 * 18: 0x20000: VERSIONID
					 * 17: 0x10000: USERRANGE2
					 * 16: 0x08000: BRK12C
					 * 15: 0x04000: BRK2A
					 * 14: 0x02000: BRK1A
					 * 13: 0x01000: GC_CONFIG
					 * 12: 0x00800: USERRANGE1
					 * 11: 0x00400: LOCKADDR1
					 * 10: 0x00200: LOCKADDR0
					 *  9: 0x00100: LOCKCOUNT1
					 *  8: 0x00080: LOCKCOUNT0
					 *  7: 0x00040: TRAPBASE
					 *  6: 0x00020: PSR
					 *  5: 0x00010: CONST_POOL
					 *  4: 0x00008: OPLIM
					 *  3: 0x00004: OPTOP
					 *  2: 0x00002: FRAME
					 *  1: 0x00001: VARS
					 *  0: 0x00000: PC
					 */
   wire [18:0] 	 reg_wr_mux_sel;	/* bit 18, 0x40000: SC_BOTTOM
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
   wire [2:0] 	 load_data_c_mux_sel;	/* 2: icu_diag_data
					 * 1: dcu_diag_data
					 * 0: dcu_data_c
					 */
   wire [1:0]	 fpu_mux_sel;
   wire [1:0]    forward_w_sel_din;/* 2: output of dcu_hold reg.
                                         * 1: output of W stage alu_out register
                                         */

   wire [2:0] 	 cmp_mux_sel;		/* 1: Rs1, zero
					 * 0: ~Rs1, Rs2
					 */
   wire [1:0] 	 adder_src1_mux_sel;	/* 1: ~Rs1
					 * 0: Rs1
					 */
   wire [2:0] 	 adder_src2_mux_sel;	/* 2: zero
					 * 1: ~Rs2
					 * 0: Rs2
					 */
   wire [4:0] 	 bit_mux_sel;		/* 4: rs1_bypass_mux_out with bit 31
					 *    flipped to support fneg and dneg
					 * 3: pc_r
					 * 2: xor
					 * 1: and
					 * 0: or
					 */
   wire [4:0] 	 cvt_mux_sel;		/* 4: i2s
					 * 3: i2c
					 * 2: i2b
					 * 1: i2l
					 * 0: sethi
					 */
   wire [4:0] 	 shifter_src1_mux_sel;	/* 16: rs2_bypass_mux_out_d1
					 *  8: {32{rs2_bypass_mux_out[31]}}
					 *  4: rs2_bypass_mux_out
					 *  2: rs1_bypass_mux_out
					 *  1: zero
					 */
   wire [2:0] 	 shifter_src2_mux_sel;	/* 4: rs2_bypass_mux_out_d1
					 * 2: rs2_bypass_mux_out
					 * 1: zero
					 */
   wire 	 shifter_word_sel;	/* 1: MSW
					 * 0: LSW
					 */
   wire [31:0] 	 imdr_data_e;		// Output of IMDR
   wire [2:0]    iu_br_pc_mux_sel;      /* 2: ucode_porta_e
					 * 1: pc_c
					 * 0: adder2 output
					 */
   wire [5:0] 	 shift_count_e;		// Shift count from RCU
   wire 	 adder2_carry_in;	// Carry input to the address adder

   wire [3:0] 	 lc0_din_mux_sel;	/* 4: lc0_p1
					 * 2: lc0_m1
					 * 1: data_in
					 */
   wire [3:0] 	 lc1_din_mux_sel;	/* 4: lc1_p1
					 * 2: lc1_m1
					 * 1: data_in
					 */
   wire [1:0] 	 load_buffer_mux_sel;	/* 2: load_buffer_reg_out (in state 2)
					 * 1: dcu_data_c (otherwise)
					 */
   wire [1:0]	 dcu_data_reg_we;	/* Eanbled if:
					 * 1. IDLE and valid
					 * 2. ST1 and ~hold and valid
					 * 3. ST2 and ~hold
					 */

   assign brk12c_halt = brk12c[31];

   ex_ctl ex_ctl(.inst_valid			(inst_valid[2:0]),
		 .iu_smiss			(iu_smiss),
	 	 .lduse_bypass			(lduse_bypass),
		 .sc_dcache_req			(sc_dcache_req),
		 .first_cyc_r			(first_cyc_r),
		 .second_cyc_r			(second_cyc_r),
		 .hold_e			(hold_ex_ctl_e),
		 .hold_c			(hold_ex_ctl_c),
		 .iu_addr_c			(iu_addr_c[1:0]),
		 .iu_addr_e			(iu_addr_e[30:28]),
		 .reissue_c			(reissue_c),
		 .kill_inst_e			(kill_inst_e),
		 .iu_trap_r			(iu_trap_r),
		 .iu_trap_c			(iu_trap_c),
		 .iu_data_vld			(iu_data_vld),
		 .sc_data_vld			(sc_data_vld),
		 .rs1_bypass_mux_out		(rs1_bypass_mux_out[5:0]),
		 .zero_addr_e			(rs1_bypass_mux_out[29:28]),
		 .opcode_1_op_r			(opcode_1_op_r[7:0]),
		 .opcode_2_op_r			(opcode_2_op_r[7:0]),
		 .valid_op_r			(valid_op_r),
                 .illegal_op_r			(illegal_op_r),
                 .priv_inst_r			(priv_inst_r),
                 .soft_trap_r			(soft_trap_r),
                 .fpu_op_r			(fpu_op_r),
                 .mis_align_c			(mis_align_c),
                 .emulated_trap_r		(emulated_trap_r),
		 .async_error			(async_error),
		 .mem_prot_error_c		(mem_prot_error_c),
		 .data_brk1_c			(data_brk1_c),
		 .data_brk2_c			(data_brk2_c),
		 .inst_brk1_r			(inst_brk1_r),
		 .inst_brk2_r			(inst_brk2_r),
		 .first_cyc_e			(first_cyc_e),
		 .lock_count_overflow_e		(lock_count_overflow_e),
		 .lock_enter_miss_e		(lock_enter_miss_e),
		 .lock_exit_miss_e		(lock_exit_miss_e),
		 .lock_release_e		(lock_release_e),
		 .null_ptr_exception_e		(null_ptr_exception_e),
		 .priv_powerdown_e		(priv_powerdown_e),
		 .priv_reset_e			(priv_reset_e),
                 .opcode_1_op_c			(opcode_1_op_c[7:0]),
		 .ucode_done			(ucode_done),
		 .pj_resume			(pj_resume),
		 .trap_in_progress		(trap_in_progress),
		 .ucode_reg_wr			(ucode_reg_wr[2:0]),
		 .ucode_reg_rd			(ucode_reg_rd[2:0]),
		 .ucode_dcu_req			(ucode_dcu_req[1:0]),
		 .alu_adder_fn			(alu_adder_fn[1:0]),
		 .mem_adder_fn			(mem_adder_fn[1:0]),
		 .all_load_c			(load_c),
		 .icu_diag_ld_c			(icu_diag_ld_c),
		 .icu_data_vld			(icu_data_vld),
		 .zero_trap_e			(zero_trap_e),
		 .iu_bypass_rs1_e		(iu_bypass_rs1_e),
		 .iu_bypass_rs2_e		(iu_bypass_rs2_e),
		 .iu_sbase_we			(iu_sbase_we),
		 .wr_optop_e			(wr_optop_e),
		 .ret_optop_update		(ret_optop_update),
		 .iu_brtaken_e			(iu_brtaken_e),
		 .branch_taken_e		(branch_taken_e),
		 .iu_inst_e			(iu_inst_e[7:0]),
		 .iu_special_e			(iu_special_e),
		 .iu_dcu_flush_e		(iu_dcu_flush_e[2:0]),
		 .iu_icu_flush_e		(iu_icu_flush_e),
		 .iu_zero_e			(iu_zero_e),
		 .iu_d_diag_e			(iu_d_diag_e[3:0]),
		 .iu_i_diag_e			(iu_i_diag_e[3:0]),
		 .cmp_gt_e			(cmp_gt_e),
		 .cmp_eq_e			(cmp_eq_e),
		 .cmp_lt_e			(cmp_lt_e),
		 .null_objref_e			(null_objref_e),
		 .psr_cac			(psr_out[22]),
		 .psr_ace			(psr_out[13]),
		 .psr_dce			(psr_out[10]),
		 .psr_ice			(psr_out[9]),
		 .psr_fle			(psr_out[6]),
		 .psr_su			(psr_out[5]),
		 .psr_drt			(psr_out[15]),
		 .brk12c_brkm2			(brk12c[30:24]),
		 .brk12c_brkm1			(brk12c[22:16]),
		 .brk12c_subk2			(brk12c[11]),
		 .brk12c_srcbk2			(brk12c[10:9]),
		 .brk12c_brken2			(brk12c[8]),
		 .brk12c_subk1			(brk12c[3]),
		 .brk12c_srcbk1			(brk12c[2:1]),
		 .brk12c_brken1			(brk12c[0]),
		 .smu_ld			(smu_ld),
		 .smu_st			(smu_st),
		 .range1_l_cmp1_lt		(range1_l_cmp1_lt),
		 .range1_h_cmp1_gt		(range1_h_cmp1_gt),
		 .range1_h_cmp1_eq		(range1_h_cmp1_eq),
		 .range2_l_cmp1_lt		(range2_l_cmp1_lt),
		 .range2_h_cmp1_gt		(range2_h_cmp1_gt),
		 .range2_h_cmp1_eq		(range2_h_cmp1_eq),
		 .range1_l_cmp2_lt		(range1_l_cmp2_lt),
		 .range1_h_cmp2_gt		(range1_h_cmp2_gt),
		 .range1_h_cmp2_eq		(range1_h_cmp2_eq),
		 .range2_l_cmp2_lt		(range2_l_cmp2_lt),
		 .range2_h_cmp2_gt		(range2_h_cmp2_gt),
		 .range2_h_cmp2_eq		(range2_h_cmp2_eq),
		 .data_brk1_31_13_eq		(data_brk1_31_13_eq),
		 .data_brk1_11_4_eq		(data_brk1_11_4_eq),
		 .data_brk1_misc_eq		(data_brk1_misc_eq[4:0]),
		 .data_brk2_31_13_eq		(data_brk2_31_13_eq),
		 .data_brk2_11_4_eq		(data_brk2_11_4_eq),
		 .data_brk2_misc_eq		(data_brk2_misc_eq[4:0]),
		 .inst_brk1_31_13_eq		(inst_brk1_31_13_eq),
		 .inst_brk1_11_4_eq		(inst_brk1_11_4_eq),
		 .inst_brk1_misc_eq		(inst_brk1_misc_eq[4:0]),
		 .inst_brk2_31_13_eq		(inst_brk2_31_13_eq),
		 .inst_brk2_11_4_eq		(inst_brk2_11_4_eq),
		 .inst_brk2_misc_eq		(inst_brk2_misc_eq[4:0]),
		 .priv_update_optop		(priv_update_optop),
		 .la0_hit			(la0_hit),
		 .lc0_eq_255			(lc0_eq_255),
		 .lc0_eq_0			(lc0_eq_0),
		 .lc0_m1_eq_0			(lc0_m1_eq_0),
		 .lockwant0			(lockwant0),
		 .lc0_co_bit			(lc0_co_bit),
		 .la0_null_e			(la0_null_e),
		 .la1_hit			(la1_hit),
		 .lc1_eq_255			(lc1_eq_255),
		 .lc1_eq_0			(lc1_eq_0),
		 .lc1_m1_eq_0			(lc1_m1_eq_0),
		 .lockwant1			(lockwant1),
		 .lc1_co_bit			(lc1_co_bit),
		 .la1_null_e			(la1_null_e),
		 .lockbit			(dcu_data_w[0]),
		 .lock0_cache		        (lock0_cache),
		 .lock1_cache			(lock1_cache),
		 .lock0_uncache			(lock0_uncache),
		 .lock1_uncache			(lock1_uncache),
		 .carry_in_e			(carry_in_e),
		 .carry_out_e			(carry_out_e),
		 .mul_e				(mul_e),
		 .div_e				(div_e),
		 .rem_e				(rem_e),
		 .shift_dir_e			(shift_dir_e),
		 .shift_sel			(shift_sel),
		 .sign_e			(sign_e),
		 .shift_count_e			(shift_count_e[5:0]),
		 .ucode_busy_e			(ucode_busy_e),
		 .lc0_count_reg_we		(lc0_count_reg_we),
		 .lc1_count_reg_we		(lc1_count_reg_we),
		 .bit_cvt_mux_sel		(bit_cvt_mux_sel[1:0]),
		 .alu_out_mux_sel		(alu_out_mux_sel[7:0]),
		 .adder2_src1_mux_sel		(adder2_src1_mux_sel),
		 .adder2_src2_mux_sel		(adder2_src2_mux_sel[3:0]),
		 .iu_data_mux_sel		(iu_data_mux_sel[1:0]),
		 .reg_rd_mux_sel		(reg_rd_mux_sel[20:0]),
		 .reg_wr_mux_sel		(reg_wr_mux_sel[18:0]),
		 .load_data_c_mux_sel		(load_data_c_mux_sel[2:0]),
		 .fpu_mux_sel			(fpu_mux_sel[1:0]),
		 .forward_w_sel_din		(forward_w_sel_din[1:0]),
		 .cmp_mux_sel			(cmp_mux_sel[2:0]),
		 .adder_src1_mux_sel		(adder_src1_mux_sel[1:0]),
		 .adder_src2_mux_sel		(adder_src2_mux_sel[2:0]),
		 .bit_mux_sel			(bit_mux_sel[4:0]),
		 .cvt_mux_sel			(cvt_mux_sel[4:0]),
		 .shifter_src1_mux_sel		(shifter_src1_mux_sel[4:0]),
		 .shifter_src2_mux_sel		(shifter_src2_mux_sel[2:0]),
		 .shifter_word_sel		(shifter_word_sel),
		 .constant_mux_sel		(constant_mux_sel[2:0]),
		 .iu_br_pc_mux_sel		(iu_br_pc_mux_sel[2:0]),
		 .lc0_din_mux_sel		(lc0_din_mux_sel[3:0]),
		 .lc1_din_mux_sel		(lc1_din_mux_sel[3:0]),
		 .offset_mux_sel		(offset_mux_sel[4:0]),
		 .wr_optop_mux_sel		(wr_optop_mux_sel[1:0]),
		 .adder2_carry_in		(adder2_carry_in),
		 .load_buffer_mux_sel		(load_buffer_mux_sel[1:0]),
		 .dcu_data_reg_we		(dcu_data_reg_we[1:0]),
		 .monitorenter_e	        (monitorenter_e),
		 .reset_l				(reset_l),
		 .clk				(clk),
		 .sm				(),
		 .sin				(),
		 .so				()
		 );
  
   ex_dpath ex_dpath(.carry_in_e		(carry_in_e),
		     .adder2_carry_in		(adder2_carry_in),
		     .imdr_data_e		(imdr_data_e[31:0]),
		     .pc_r			(pc_r[31:0]),
		     .pc_e			(pc_e[31:0]),
		     .pc_c			(pc_c[31:0]),
		     .vars_out			(vars_out[31:0]),
		     .ru_rs1_e			(ru_rs1_e[31:0]),
		     .ru_rs2_e			(ru_rs2_e[31:0]),
		     .scache_miss_addr_e	(scache_miss_addr_e[31:0]),
		     .ucode_porta_e		(ucode_porta_e[31:0]),
		     .ucode_portc_e		(ucode_portc_e[31:0]),
		     .iu_alu_a			(iu_alu_a[31:0]),
		     .iu_alu_b			(iu_alu_b[31:0]),
		     .u_m_adder_porta_e		(u_m_adder_porta_e[31:0]),
		     .u_m_adder_portb_e		(u_m_adder_portb_e[31:0]),
		     .reg_data_e		(reg_data_e[31:0]),
		     .opcode_r			({opcode_2_op_r[7:0],
						  opcode_3_op_r[7:0],
						  opcode_4_op_r[7:0],
						  opcode_5_op_r[7:0]}),
		     .rs1_bypass_mux_out	(rs1_bypass_mux_out[31:0]),
		     .rs2_bypass_mux_out	(rs2_bypass_mux_out[31:0]),
	      	     .iu_rs1_e_0_l		(iu_rs1_e_0_l),
	      	     .iu_rs2_e_0_l		(iu_rs2_e_0_l),
		     .adder_out_e		(adder_out_e[31:0]),
		     .carry_out_e		(carry_out_e),
		     .cmp_gt_e			(cmp_gt_e),
		     .cmp_eq_e			(cmp_eq_e),
		     .cmp_lt_e			(cmp_lt_e),
		     .null_objref_e		(null_objref_e),
		     .iu_addr_e			(iu_addr_e[31:0]),
		     .iu_addr_e_2		(iu_addr_e_2),
		     .iu_addr_e_31		(iu_addr_e_31),
		     .iu_addr_c			(iu_addr_c[31:0]),
		     .iu_br_pc_e		(iu_br_pc_e[31:0]),
		     .iu_data_e			(iu_data_e[31:0]),
		     .wr_optop_data_e		(wr_optop_data_e[31:0]),
		     .ucode_porta_mux_out	(ucode_porta_mux_out[31:0]),
		     .dcu_diag_data_c		(dcu_diag_data_c[31:0]),
		     .fpu_data_e		(fpu_data_e[31:0]),
		     .fpu_hold			(fpu_hold),
		     .icu_diag_data_c		(icu_diag_data_c[31:0]),
		     .dcu_data_c		(dcu_data_c[31:0]),
		     .alu_out_w			(alu_out_w[31:0]),
		     .iu_data_in		(iu_data_in[31:0]),
		     .dcu_data_w		(dcu_data_w[31:0]),
		     .load_buffer_mux_out_0	(load_buffer_mux_out_0),
		     .shift_dir_e		(shift_dir_e),
		     .shift_count_e		(shift_count_e[5:0]),
		     .sign_e			(sign_e),
		     .monitorenter_e		(monitorenter_e),
		     .iu_data_vld		(iu_data_vld),
		     .sc_data_vld		(sc_data_vld),
		     .hold_e			(hold_ex_dp_e),
		     .hold_c			(hold_ex_dp_c),

		     .ucode_active		(ucode_active),
		     .rs1_mux_sel_din		(rs1_mux_sel_din),
		     .forward_c_sel_din		(forward_c_sel_din),
		     .rs1_bypass_mux_sel	(rs1_bypass_mux_sel[4:0]),
		     .rs2_bypass_mux_sel	(rs2_bypass_mux_sel[4:0]),
		     .cmp_mux_sel		(cmp_mux_sel[2:0]),
		     .adder_src1_mux_sel	(adder_src1_mux_sel[1:0]),
		     .adder_src2_mux_sel	(adder_src2_mux_sel[2:0]),
		     .shifter_src1_mux_sel	(shifter_src1_mux_sel[4:0]),
		     .shifter_src2_mux_sel	(shifter_src2_mux_sel[2:0]),
		     .shifter_word_sel		(shifter_word_sel),
		     .bit_mux_sel		(bit_mux_sel[4:0]),
		     .cvt_mux_sel		(cvt_mux_sel[4:0]),
		     .bit_cvt_mux_sel		(bit_cvt_mux_sel[1:0]),
		     .alu_out_mux_sel		(alu_out_mux_sel[7:0]),
		     .offset_mux_sel		(offset_mux_sel[4:0]),
		     .wr_optop_mux_sel		(wr_optop_mux_sel[1:0]),
		     .ex_adder2_src1_mux_sel	(adder2_src1_mux_sel),
		     .adder2_src2_mux_sel	(adder2_src2_mux_sel[3:0]),
		     .iu_data_mux_sel		(iu_data_mux_sel[1:0]),
		     .load_data_c_mux_sel	(load_data_c_mux_sel[2:0]),
		     .fpu_mux_sel		(fpu_mux_sel[1:0]),
		     .forward_w_sel_din		(forward_w_sel_din[1:0]),
		     .load_buffer_mux_sel	(load_buffer_mux_sel[1:0]),
		     .dcu_data_reg_we		(dcu_data_reg_we[1:0]),
		     .constant_mux_sel		(constant_mux_sel[2:0]),
		     .iu_br_pc_mux_sel		(iu_br_pc_mux_sel[2:0]),

		     // Added to imrpove timing on ucode paths 

		     .iu_optop_e		(optop_e),
		     .ucode_reg_data		(ucode_reg_data[31:0]),
		     .ucode_madder_sel2		(ucode_madder_sel2),
		     .ucode_alu_a_sel		(ucode_alu_a_sel),
		     .ucode_alu_b_sel		(ucode_alu_b_sel),
		     .ucode_porta_sel		(ucode_porta_sel),
		     .ucode_busy_e		(ucode_busy_e),
		     .sc_dcache_req		(sc_dcache_req),

		     .reset_l			(reset_l),
		     .clk			(clk),
		     .sm			(),
		     .sin			(),
		     .so			()
		     );

   imdr ex_imdr(.ie_mul_d			(mul_e),
		.ie_div_d			(div_e),
		.ie_rem_d			(rem_e),
		.kill_inst_e			(kill_inst_e),
		.ie_dataA_d			(rs2_bypass_mux_out[31:0]),
		.ie_dataB_d			(rs1_bypass_mux_out[31:0]),
		.pj_hold			(hold_imdr),
		.reset_l			(reset_l),
		.sm				(),
		.sin				(),
		.so				(),
		.clk				(clk),
		.imdr_done_e			(imdr_done_e),
		.imdr_div0_e			(imdr_div0_e),
		.imdr_data_out			(imdr_data_e[31:0])
		);

   ex_regs ex_regs(.data_in			(ucode_porta_mux_out[31:0]),
		   .pc_r			(pc_r[31:0]),
		   .pc_e			(pc_e[31:0]),
		   .pc_c			(pc_c[31:0]),
		   .optop_c			(optop_c[31:0]),
		   .smu_addr			(smu_addr[29:14]),
		   .iu_addr_c			(iu_addr_c[31:0]),
		   .iu_addr_e			(iu_addr_e[31:0]),
		   .hold_e			(hold_ex_reg_e),
		   .hold_c			(hold_ex_reg_c),
		   .inst_valid			(inst_valid[1]),
		   .fold_c			(fold_c),
		   .priv_update_optop		(priv_update_optop),
		   .reg_rd_mux_sel		(reg_rd_mux_sel[20:0]),
		   .reg_wr_mux_sel		(reg_wr_mux_sel[18:0]),
		   .ucode_reg_data_mux_sel	(ucode_reg_data_mux_sel[6:0]),
		   .lc0_din_mux_sel		(lc0_din_mux_sel[3:0]),
		   .lc1_din_mux_sel		(lc1_din_mux_sel[3:0]),
		   .lc0_count_reg_we		(lc0_count_reg_we),
		   .lc1_count_reg_we		(lc1_count_reg_we),
		   .lock0_cache		        (lock0_cache),
		   .lock1_cache			(lock1_cache),
		   .lock0_uncache		(lock0_uncache),
		   .lock1_uncache		(lock1_uncache),
		   .smu_sbase			(smu_sbase[31:2]),
		   .smu_sbase_we		(smu_sbase_we),
		   .pj_boot8_e			(pj_boot8_e),
		   .pj_no_fpu_e			(pj_no_fpu_e),
		   .tbase_tt_e			(tbase_tt_e[7:0]),
		   .tbase_tt_we_e		(tbase_tt_we_e),

		   .data_out			(reg_data_e[31:0]),
		   .ucode_reg_data		(ucode_reg_data[31:0]),
		   .vars_out			(vars_out[31:0]),
		   .psr_out			(psr_out[31:0]),
		   .brk12c_out			(brk12c[31:0]),
		   .sc_bottom_out		(sc_bottom_out[31:0]),
		   .range1_l_cmp1_lt		(range1_l_cmp1_lt),
		   .range1_h_cmp1_gt		(range1_h_cmp1_gt),
		   .range1_h_cmp1_eq		(range1_h_cmp1_eq),
		   .range2_l_cmp1_lt		(range2_l_cmp1_lt),
		   .range2_h_cmp1_gt		(range2_h_cmp1_gt),
		   .range2_h_cmp1_eq		(range2_h_cmp1_eq),
		   .range1_l_cmp2_lt		(range1_l_cmp2_lt),
		   .range1_h_cmp2_gt		(range1_h_cmp2_gt),
		   .range1_h_cmp2_eq		(range1_h_cmp2_eq),
		   .range2_l_cmp2_lt		(range2_l_cmp2_lt),
		   .range2_h_cmp2_gt		(range2_h_cmp2_gt),
		   .range2_h_cmp2_eq		(range2_h_cmp2_eq),
		   .data_brk1_31_13_eq		(data_brk1_31_13_eq),
		   .data_brk1_11_4_eq		(data_brk1_11_4_eq),
		   .data_brk1_misc_eq		(data_brk1_misc_eq[4:0]),
		   .data_brk2_31_13_eq		(data_brk2_31_13_eq),
		   .data_brk2_11_4_eq		(data_brk2_11_4_eq),
		   .data_brk2_misc_eq		(data_brk2_misc_eq[4:0]),
		   .inst_brk1_31_13_eq		(inst_brk1_31_13_eq),
		   .inst_brk1_11_4_eq		(inst_brk1_11_4_eq),
		   .inst_brk1_misc_eq		(inst_brk1_misc_eq[4:0]),
		   .inst_brk2_31_13_eq		(inst_brk2_31_13_eq),
		   .inst_brk2_11_4_eq		(inst_brk2_11_4_eq),
		   .inst_brk2_misc_eq		(inst_brk2_misc_eq[4:0]),
		   .oplim_trap_c		(oplim_trap_c),
		   .la0_hit			(la0_hit),
		   .lc0_eq_255			(lc0_eq_255),
		   .lc0_eq_0			(lc0_eq_0),
		   .lc0_m1_eq_0			(lc0_m1_eq_0),
		   .lockwant0			(lockwant0),
		   .lc0_co_bit			(lc0_co_bit),
		   .la0_null_e			(la0_null_e),
		   .la1_hit			(la1_hit),
		   .lc1_eq_255			(lc1_eq_255),
		   .lc1_eq_0			(lc1_eq_0),
		   .lc1_m1_eq_0			(lc1_m1_eq_0),
		   .lockwant1			(lockwant1),
		   .lc1_co_bit			(lc1_co_bit),
		   .la1_null_e			(la1_null_e),

		   .reset_l			(reset_l),
		   .clk				(clk),
		   .sm				(),
		   .sin				(),
		   .so				()
		   );

endmodule // ex
