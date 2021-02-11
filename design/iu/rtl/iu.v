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

module iu(
	  // From/To EX
  	  iu_data_vld,	
	  dcu_diag_data_c,
	  icu_diag_data_c,
	  dcu_data_c,
	  smu_sbase,
	  smu_addr,
	  smu_st,
	  smu_ld,
	  smu_sbase_we,
	  pj_boot8_e,
	  pj_no_fpu_e,
	  iu_inst_e,
	  iu_special_e,
	  kill_inst_e,
	  iu_dcu_flush_e,
	  iu_icu_flush_e,
	  iu_zero_e,
	  iu_d_diag_e,
	  iu_i_diag_e,
	  iu_addr_e,
	  iu_addr_e_2,
	  iu_addr_e_31,
	  iu_br_pc_e,
	  iu_data_e,
	  iu_brtaken_e,
	  psr,
	  optop_c,
	  iu_optop_din,
	  iu_optop_int_we,
	  iu_data_in,
	  iu_sbase_we,
	  sc_bottom,
	  ret_optop_update,
	  iu_powerdown_op_e,

	 // From/To IFU
	  icu_data,	
	  icu_drty,
	  icu_vld_d,
	  icu_length_d,
	  iu_shift_d,

	  // To RCU
	  smu_data,
	  smu_rf_addr,
	  smu_we,
	  pj_inst_complete,

	  // To SMU
	  iu_smu_data,
	  iu_data_w,
	  dest_addr_w,
	  scache_wr_miss_w,
	  iu_smu_flush,

	// To  Pipe
	  icu_pc_d,	
	  iu_perf_sgnl,

	// To hold-logic
	  dcu_stall,
	  pj_halt,
	  pj_resume,
	  icu_hold,
	  fp_rdy_e,
	  smu_hold,

	// To/from trap
	  pj_irl,
	  pj_nmi,
	  dcu_err_ack,
	  pj_brk1_sync,
	  pj_brk2_sync,
	  pj_in_halt,
	  iu_kill_fpu,
	  iu_kill_dcu,

	// To/from FPU
	  fpu_data_e,
	  opcode_1_op_r,
	  valid_op_r,
	  iu_rs1_e,
	  iu_rs2_e,
	  hold_fpu,
	  
	  
	

	// Global signals
	  te_ieu_rom,
	  reset_out,
	  reset_l,
	  clk,
	  sm,
	  so,
	  sin);

   /*********************
    * Interface signals *
    *********************/

   // Input to EX
   input	 iu_data_vld;
   input [31:0]  dcu_diag_data_c;	// DCU diagnostic read data
   input [31:0]  fpu_data_e;		// FPU result
   input [31:0]  icu_diag_data_c;	// ICU diagnostic read data
   input [31:0]  dcu_data_c;		// Input to dcu_hold_reg
   input [31:2]  smu_sbase;		// SC_BOTTOM value from SMU
   input 	 smu_sbase_we;		// Write-enable of SC_BOTTOM from SMU
   input 	 pj_boot8_e;		// Input from pin
   input 	 pj_no_fpu_e;		// Input from pin
   input [29:14] smu_addr;		// smu addr for memory protection check
   input	 smu_ld;		// smu load
   input	 smu_st;		// smu store

   // Output of EX
   output [7:0]  iu_inst_e;		// [7]	 = non allocating
					// [6]	 = opposite endiannes
					// [5]	 = signed
					// [4]	 = noncacheable
					// [3]	 = store
					// [2]	 = load
					// [1:0] = size
					 
   output	 iu_special_e;		// dcu related special inst
   output	 kill_inst_e;		// kill dcu inst in e
   output 	 iu_icu_flush_e;	// Tell ICU that it is a cache_flush,
					// cache_index_flush or cache_invalidate 
   output [2:0]	 iu_dcu_flush_e;	// Tell DCU that it is a cache_flush,
					// cache_index_flush or cache_invalidate 
   output 	 iu_zero_e;		// cache zero line
   output [3:0]  iu_d_diag_e;		// [3] = Dcache RAm Write
					// [2] = Dcache Ram Read
					// [1] = DTag Write
					// [0] = Dtag Read
   output [3:0]  iu_i_diag_e;		// [3] = Icache RAm Write
					// [2] = Icache Ram Read
					// [1] = ITag Write
					// [0] = Itag Read
   output	 iu_brtaken_e;		// Tell ICU and Pipe that branch should be taken
					 
   output [31:0] iu_addr_e;		// Address to Dcache/Icache
   output	 iu_addr_e_2;
   output	 iu_addr_e_31;
   output [31:0] iu_br_pc_e;		// Branch target PC to ICU
   output [31:0] iu_data_e;		// Data corresponding to address
   output [31:0] psr;			// PSR register  
   output [31:0] sc_bottom;		// PSR register  
   output [31:0] iu_optop_din;		// Signal at the din input of arch optop flop

   output	iu_optop_int_we;	// This is the write enable for the flop
                                        // in SMU to generate it's own version of optop
   output [31:0] iu_data_in;		// Data to be written onto SMU's version
                                        // of sbase in case of wr_sbase opcodes
   output	iu_sbase_we;		// Write enable signal to SMU, whenever there's 
					// wr_sbase etc.
   output [31:0] iu_rs1_e ;		// RS1 operand for FPU
   output [31:0] iu_rs2_e ;		// RS2 operand for FPU
   output	 ret_optop_update;	// return instruction caused optop change
   output	 iu_powerdown_op_e;	// powerdown inst in E stage
	

   // Input to IFU
   input [55:0]	 icu_data;		// Top 7 bytes of Ibuffer
   input [6:0]	 icu_drty;		// Dirty bits of the 7 entrees in ibuf
   input [6:0]	 icu_vld_d;		// Valid bits of the 7 entries in ibuf
   input [27:0]	 icu_length_d;		/* Len. of the instr. corresp. to 
					 * 7 bytes in Ibuffer */
   // Output of IFU
   output [7:0]  iu_shift_d;
   output [31:0]  optop_c;		// OPTOP register  
   output	 valid_op_r;		// valid opcode in R stage
   output [7:0]	 opcode_1_op_r;		// opcode in r

   // Input to RCU
   input [31:0]  smu_data;		/* Data from dribbler to be written
					 * onto scache
					 */
   input [5:0] 	 smu_rf_addr;		// dribbler address to scache
   input 	 smu_we;		/* scache write enable signal from
					 * dribbler
					 */
   // Output of RCU
   output [31:0] iu_smu_data;		// Data output from scache to dribbler
   output [31:0] iu_data_w;		// Data to be written to DCU incase of scache write misses
   output [31:0] dest_addr_w;		// Scache addr to SMU incase of write misses
   output  	 scache_wr_miss_w;	// Signal to SMU indicating a scache write miss
   output	 iu_smu_flush;		// Signal to SMU to kill al the lds/stores in its pipeline
   output	 pj_inst_complete;	// instruction completed execution. w stage

   // Input to PIPE/hold logic
   input [31:0]	 icu_pc_d;		// PC of first instruction of Ibuffer
   input	 dcu_stall;		// dcu unable to accept request.
   input	 icu_hold;		// icu unable to service request.
   input	 fp_rdy_e;		// fpu ready to accept new request
   input	 smu_hold;		// smu holds the pipe
   input	 pj_halt;		// halt the processor
   input	 pj_resume;		// resume the processor
   output	 hold_fpu;		// hold signal for fpu
   output [2:0]	 iu_perf_sgnl;		// performance monitor signals

   // Input/outputs to trap logic
   input [3:0]	 pj_irl;		// interrupts
   input 	 pj_nmi;		// Non-maskable interrupt
   input [2:0]	 dcu_err_ack;		// Error acks from Dcache
   output        iu_kill_fpu;           // kill the fpu operation
   output        iu_kill_dcu;           // kill any outstanding dcu operation
   output	 pj_brk1_sync;		// Breakpoint 1 detected
   output	 pj_brk2_sync;		// Breakpoint 2 detected
   output	 pj_in_halt;		// processor in halt mode
  


   // Global signals
   input         te_ieu_rom;            // test enable  for ieu_rom

   output	 reset_out;		// software reset
   input 	 reset_l;			// The internal reset signal
   input 	 clk;			// The internal clock signal
   input 	 sm;			// Scan enable
   input 	 sin;		// Scan input
   output 	 so;		// Scan output

   /******************
    * Internal wires *
    ******************/

   // Output of EX
   wire [31:0] 	 lvars;			// ex	-> ifu
   wire 	 wr_optop_e;		// ex	-> pipe
   wire [31:0]	 wr_optop_data_e;	// ex	-> pipe
   wire 	 imdr_done_e;		// ex	-> pipe
   wire 	 load_c;		// ex	-> pipe
   wire		 icu_diag_ld_c;		// ex   -> pipe
   wire 	 imdr_div0_e;		// ex	-> trap
   wire 	 illegal_op_r;		// ex	-> trap
   wire 	 priv_inst_r;		// ex	-> trap
   wire 	 soft_trap_r;		// ex	-> trap
   wire 	 mis_align_c;		// ex	-> trap
   wire 	 emulated_trap_r;	// ex	-> trap
   wire [7:0] 	 opcode_c;		// ex	-> trap
   wire 	 mem_prot_error_c;	// ex	-> trap
   wire 	 oplim_trap_c;		// ex	-> trap
   wire		 branch_taken_e;	// ex   -> trap,pipe
   wire [31:0] 	 ucode_reg_data;	// ex	-> ucode
   wire 	 cmp_eq_e;		// ex	-> ucode
   wire 	 carry_out_e;		// ex	-> ucode
   wire	[3:0]	 lock_trap_e;		// ex   -> trap 
   wire		 zero_trap_e;		// ex   -> trap 
   wire		 fpu_inst_r;		// ex   -> trap 
   wire		 null_ptr_exe_e;	// ex   -> trap
   wire 	 reset_out;		// ex	-> outside core
   wire 	 brk12c_halt;		// ex	-> trap
   wire		 inst_brk1_r;		// ex   -> trap
   wire		 inst_brk2_r;		// ex   -> trap
   wire		 data_brk1_c;		// ex   -> trap
   wire		 data_brk2_c;		// ex   -> trap
   wire		 async_mem_prot_err;	// ex   -> trap
   wire	[31:0]	 dcu_data_w;		// ex   -> ucode
   wire [31:0]	 adder_out_e;		// ex   -> ucode
   wire		 ret_optop_update;      // ex   -> smu 
   wire		 iu_bypass_rs1_e ;	// ex   -> pipe
   wire		 iu_bypass_rs2_e ;	// ex   -> pipe
   wire		 iu_rs1_e_0_l;		// ex   -> ucode
   wire		 iu_rs2_e_0_l;		// ex   -> ucode

   // Output of IFU
   wire [7:0] 	 opcode_1_op_r_rcu;	// ifu	-> rcu
   wire [7:0] 	 opcode_1_op_r_ex;	// ifu	-> ex
   wire [7:0] 	 opcode_1_op_r_ucode;	// ifu	-> ucode
   wire [7:0] 	 opcode_2_op_r;		// ifu	-> ex
   wire [7:0] 	 opcode_3_op_r;		// ifu	-> ex
   wire [7:0] 	 opcode_4_op_r;		// ifu	-> ex
   wire [7:0] 	 opcode_5_op_r;		// ifu	-> ex
   wire 	 valid_op_r_rcu;	// ifu	-> rcu
   wire 	 valid_op_r_ex;		// ifu	-> ex 
   wire 	 valid_op_r_pipe;	// ifu	-> pipe
   wire 	 valid_op_r_ucode;	// ifu	-> ucode 
   wire 	 group_1_r;		// ifu	-> unconnected
   wire 	 group_2_r;		// ifu	-> rcu
   wire 	 group_3_r;		// ifu	-> rcu
   wire 	 group_4_r;		// ifu	-> rcu
   wire 	 group_5_r;		// ifu	-> rcu
   wire 	 group_6_r;		// ifu	-> rcu
   wire 	 group_7_r;		// ifu	-> rcu
   wire 	 group_8_r;		// ifu	-> unconnected
   wire 	 group_9_r;		// ifu	-> rcu
   wire [7:0] 	 opcode_1_rs1_r;	// ifu	-> rcu
   wire [7:0] 	 opcode_2_rs1_r;	// ifu	-> rcu
   wire [7:0] 	 offset_1_rs1_r;	// ifu	-> rcu
   wire [7:0] 	 offset_2_rs1_r;	// ifu	-> rcu
   wire 	 valid_rs1_r;		// ifu	-> rcu
   wire 	 help_rs1_r;		// ifu	-> rcu
   wire 	 lv_rs1_r;		// ifu	-> rcu
   wire 	 reverse_ops_rs1_r;	// ifu	-> rcu
   wire [7:0] 	 type_rs1_r;		// ifu	-> rcu
   wire 	 lvars_acc_rs1_r;	// ifu	-> rcu
   wire 	 st_index_op_rs1_r;	// ifu	-> rcu
   wire		 update_optop_r;	// ifu  -> rcu
   wire [7:0] 	 opcode_1_rs2_r;	// ifu	-> rcu
   wire [7:0] 	 opcode_2_rs2_r;	// ifu	-> rcu
   wire [7:0] 	 offset_1_rs2_r;	// ifu	-> rcu
   wire [7:0] 	 offset_2_rs2_r;	// ifu	-> rcu
   wire 	 valid_rs2_r;		// ifu	-> rcu
   wire 	 lv_rs2_r;		// ifu	-> rcu
   wire 	 lvars_acc_rs2_r;	// ifu	-> rcu
   wire [7:0] 	 offset_rsd_r;		// ifu	-> rcu
   wire 	 valid_rsd_r;		// ifu	-> rcu
   wire 	 drty_inst_r;		// ifu	-> rcu
   wire 	 no_fold_r;		// ifu	-> rcu
   wire [7:0] 	 opcode_1_rsd_r;	// ifu	-> rcu
   wire [7:0] 	 opcode_2_rsd_r;	// ifu	-> rcu
   wire [2:0] 	 offset_pc_br_r;	// ifu	-> pipe
   wire 	 fold_r;		// ifu	-> pipe
   wire		 put_field2_quick_r;	// ifu  -> rcu

   // Output of RCU
   wire 	 first_cyc_r;		// rcu	-> ex
   wire 	 second_cyc_r;		// rcu	-> ex
   wire [31:0] 	 rs1_data_e;		// rcu	-> ex
   wire [31:0] 	 rs2_data_e;		// rcu	-> ex
   wire [3:0] 	 rs1_forward_mux_sel;	// rcu	-> ex
   wire [3:0] 	 rs2_forward_mux_sel;	// rcu	-> ex
   wire [31:0] 	 scache_miss_addr_e;	// rcu	-> ex
   wire [31:0] 	 optop_offset_r;	// rcu	-> pipe
   wire 	 scache_rd_miss_e;	// rcu	-> pipe
   wire		 first_vld_c;		// rcu  -> pipe

   // Output of PIPE
   wire [2:0] 	 inst_valid;		// pipe	-> ex, rcu
   wire		 inst_vld_e;
   wire [31:0] 	 optop_e;		// pipe	-> ex
   wire [31:0] 	 optop_e_v1;		// pipe	-> ex
   wire [31:0] 	 optop_e_v2;		// pipe	-> ex
   wire [31:0] 	 pc_r;			// pipe	-> ex
   wire [31:0] 	 pc_e;			// pipe	-> ex
   wire [31:0] 	 pc_c;			// pipe	-> ex
   wire 	 reissue_c;		// pipe	-> ex
   wire		 lduse_bypass;		// pipe -> ex
   wire 	 sc_data_vld;		// pipe	-> ex
   wire		 icu_data_vld;		// pipe -> ex
   wire		 rs1_bypass_hold;	// pipe -> ex
   wire		 rs2_bypass_hold;	// pipe -> ex
   wire		 fold_c;		// pipe -> trap/ex
   wire 	 squash_fold;		// pipe	-> ifu
   wire		 scache_miss;		// pipe -> hold logic
   wire		 lduse_hold;		// pipe -> hold logic
   wire		 sc_dcache_req;		// pipe -> ex
   wire		 sc_rd_miss_sel;	// pipe -> ex
   wire 	 kill_inst_d;		// pipe	-> ifu
   wire		 kill_inst_e;		// pipe -> dcu
   wire		 kill_inst_e_int;	// pipe -> ex
   wire		 ieu_in_powerdown=1'b0; // pipe -> pcscu
   wire		 fold_sc_miss_e;	// pipe -> trap
   wire		 rs1_mux_sel_din;	// pipe -> ex
   wire		 forward_c_sel_din;	// pipe -> ex

  // Output of Hold Logic
   wire		hold_ucode;
   wire         hold_fpu;
   wire         hold_imdr;
   wire         hold_ifu_d;
   wire         hold_ifu_r;
   wire         hold_ifu_e;
   wire         hold_ifu_c;
   wire         hold_pipe_r;
   wire         hold_pipe_e;
   wire         hold_pipe_c;
   wire         hold_rcu_e;
   wire         hold_rcu_c;
   wire         hold_rcu_ucode;
   wire         hold_trap_r;
   wire         hold_trap_e;
   wire         hold_trap_c;
   wire         hold_ex_ctl_e;
   wire         hold_ex_ctl_c;
   wire         hold_ex_reg_e;
   wire         hold_ex_reg_c;
   wire         hold_ex_dp_e;
   wire         hold_ex_dp_c;
   wire		hold_ex_fpu;
   wire         hold_pipe_c_int;
 

   // Output of UCODE
   wire 	 ucode_done		;	// ucode-> ex
   wire		 ucode_last		;	// ucode-> pipe
   wire [31:0] 	 ucode_porta		;	// ucode-> ex
   wire [31:0] 	 ucode_portc		;	// ucode-> ex
   wire [31:0]	 iu_alu_a		;	// ucode-> ex
   wire [31:0]	 iu_alu_b		;	// ucode-> ex
   wire [31:0] 	 m_adder_porta	;		// ucode-> ex
   wire [31:0] 	 m_adder_portb	;		// ucode-> ex
   wire [6:0] 	 ucode_reg_data_mux_sel	;	// ucode-> ex
   wire [2:0]	 ucode_reg_wr		;	// ucode-> ex
   wire [2:0]	 ucode_reg_rd		;	// ucode-> ex
   wire [1:0]	 alu_adder_fn		;	// ucode-> ex
   wire [1:0]	 mem_adder_fn		;	// ucode-> ex
   wire [1:0]	 ucode_dcu_req		;	// ucode-> ex
   wire [1:0]	 u_f02			;	// ucode -> rcu
   wire [31:0] 	 ucode_rd_addr		;	// ucode-> rcu
   wire	[31:0]	 u_areg0		;	// ucode -> rcu
   wire		 ucode_dest_sel		;	// ucode -> rcu
   wire		 ucode_stk_wr		;	// ucode-> rcu
   wire		 ucode_stk_rd		;	// ucode-> rcu
   wire [1:0]	 ucode_porta_sel	;	// ucode-> ex
   wire		 ucode_abort		;	// ucode -> trap
   wire		 u_ref_null_c		;	// ucode-> trap
   wire		 u_ary_ovf_c		;	// ucode-> trap
   wire		 u_ptr_un_eq_c		;	// ucode-> trap
   wire		 gc_trap_c		;	// ucode-> trap
   wire		 udone_l;			// ucode-> hold
   wire	[3:0]	 ucode_madder_sel2	;	// u_f19
   wire	[1:0]    ucode_alu_a_sel 	;	// u_f23
   wire [2:0]	 ucode_alu_b_sel	;	// u_f07


   // Output of TRAP
   wire 	 iu_trap_c;			// trap	-> pipe,ifu
   wire	[7:0]	 tt_c ;				// trap -> ex
   wire		 tt_we;				// trap -> ex
   wire		 trap_vld_r;			// trap -> pipe
   wire		 trap_vld_e;			// trap -> pipe
   wire		 trap_in_progress;		// trap -> pipe,ex
   wire		 iu_trap_r;			// trap -> ucode,rcu
   wire		 pj_in_halt;			// trap -> pipe
   wire		 kill_powerdown;		// trap -> pipe
   wire		 iu_kill_ucode;			// trap -> ucode
   wire		 async_error;			// trap -> pipe


   ex ex(
	.opcode_1_op_r		(opcode_1_op_r_ex),
 	.opcode_2_op_r		(opcode_2_op_r),
	.opcode_3_op_r		(opcode_3_op_r),
	.opcode_4_op_r		(opcode_4_op_r),
	.opcode_5_op_r		(opcode_5_op_r),
	.valid_op_r		(valid_op_r_ex),
	.illegal_op_r		(illegal_op_r),
	.priv_inst_r		(priv_inst_r),
	.mis_align_c		(mis_align_c),
	.emulated_trap_r	(emulated_trap_r),
	.opcode_1_op_c		(opcode_c),
	.soft_trap_r		(soft_trap_r),
	.zero_trap_e		(zero_trap_e),
	.fpu_op_r		(fpu_inst_r),
	.brk12c_halt		(brk12c_halt),
	.data_brk1_c		(data_brk1_c),
	.data_brk2_c		(data_brk2_c),
	.inst_brk1_r		(inst_brk1_r),
	.inst_brk2_r		(inst_brk2_r),
	.first_cyc_e		(first_cyc_e),
	.lock_count_overflow_e	(lock_trap_e[3]),
	.lock_enter_miss_e	(lock_trap_e[1]),
	.lock_exit_miss_e	(lock_trap_e[2]),
	.lock_release_e		(lock_trap_e[0]),
	.load_c			(load_c),
	.iu_bypass_rs1_e	(iu_bypass_rs1_e),
	.iu_bypass_rs2_e	(iu_bypass_rs2_e),
	.inst_valid		({inst_valid[2:1],inst_vld_e}),
	.iu_smiss		(sc_rd_miss_sel),
	.lduse_bypass		(lduse_bypass),
	.reissue_c		(reissue_c),
	.fold_c			(fold_c),
	.iu_trap_r		(iu_trap_r),
	.iu_trap_c		(iu_trap_c),
	.first_cyc_r		(first_cyc_r),
	.second_cyc_r		(second_cyc_r),
	.ucode_active		(ucode_stk_rd),
	.pj_resume		(pj_resume),
	.trap_in_progress	(trap_in_progress),
	.hold_ex_ctl_e		(hold_ex_ctl_e),
	.hold_ex_ctl_c		(hold_ex_ctl_c),
	.hold_ex_dp_e		(hold_ex_dp_e),
	.hold_ex_dp_c		(hold_ex_dp_c),
	.hold_ex_reg_e		(hold_ex_reg_e),
	.hold_ex_reg_c		(hold_ex_reg_c),
	.hold_imdr		(hold_imdr),
	.kill_inst_e		(kill_inst_e_int),
        .iu_special_e		(iu_special_e),
	.smu_addr		(smu_addr[29:14]),
	.smu_ld			(smu_ld),
	.smu_st			(smu_st),
	.async_error		(async_mem_prot_err),
	.mem_prot_error_c	(mem_prot_error_c),
	.oplim_trap_c		(oplim_trap_c),
	.wr_optop_e		(wr_optop_e),
	.ret_optop_update	(ret_optop_update),
	.ucode_reg_data		(ucode_reg_data),
	.ucode_reg_rd		(ucode_reg_rd),
	.ucode_reg_wr		(ucode_reg_wr),
	.alu_adder_fn		(alu_adder_fn),
	.mem_adder_fn		(mem_adder_fn),
	.ucode_madder_sel2	(ucode_madder_sel2),
	.ucode_alu_a_sel	(ucode_alu_a_sel),
	.ucode_alu_b_sel	(ucode_alu_b_sel),
	.ucode_porta_sel	(ucode_porta_sel),
	.rs1_mux_sel_din	(rs1_mux_sel_din),
	.forward_c_sel_din	(forward_c_sel_din),
	.sc_dcache_req		(sc_dcache_req),
	.sc_data_vld		(sc_data_vld),
	.null_ptr_exception_e	(null_ptr_exe_e),
	.priv_powerdown_e	(iu_powerdown_op_e),
	.priv_reset_e		(reset_out),

 	.dcu_data_w		(dcu_data_w[31:0]),
	.vars_out		(lvars),
	.psr_out		(psr),
	.sc_bottom_out		(sc_bottom),
	.alu_out_w		(iu_data_w[31:0]),
	.iu_brtaken_e		(iu_brtaken_e),
	.branch_taken_e		(branch_taken_e),
	.iu_inst_e		(iu_inst_e),
	.iu_icu_flush_e		(iu_icu_flush_e),
	.iu_dcu_flush_e		(iu_dcu_flush_e[2:0]),
	.iu_zero_e		(iu_zero_e),
	.iu_d_diag_e		(iu_d_diag_e),
	.iu_i_diag_e		(iu_i_diag_e),
	.ucode_done		(ucode_done),
	.optop_c		(optop_c),
	.optop_e		(optop_e_v1),
	.pc_r			(pc_r),
	.pc_e			(pc_e),
	.pc_c			(pc_c),
	.ru_rs1_e		(rs1_data_e),
	.ru_rs2_e		(rs2_data_e),
	.scache_miss_addr_e	(scache_miss_addr_e),
	.ucode_porta_e		(ucode_porta),
	.ucode_portc_e		(ucode_portc),
	.iu_alu_a		(iu_alu_a),
	.iu_alu_b		(iu_alu_b),
	.u_m_adder_porta_e	(m_adder_porta),
	.u_m_adder_portb_e	(m_adder_portb),
	.adder_out_e		(adder_out_e[31:0]),
	.rs1_bypass_mux_out	(iu_rs1_e[31:0]),
	.rs2_bypass_mux_out	(iu_rs2_e[31:0]),
	.iu_rs1_e_0_l		(iu_rs1_e_0_l),
	.iu_rs2_e_0_l		(iu_rs2_e_0_l),
	.iu_addr_e		(iu_addr_e),
	.iu_addr_e_2		(iu_addr_e_2),
	.iu_addr_e_31		(iu_addr_e_31),
	.iu_br_pc_e		(iu_br_pc_e),
	.iu_data_e		(iu_data_e),
	.iu_data_in 		(iu_data_in),
	.iu_sbase_we		(iu_sbase_we),
	.wr_optop_data_e	(wr_optop_data_e[31:0]),
	.dcu_diag_data_c	(dcu_diag_data_c),
	.fpu_data_e		(fpu_data_e),
	.fpu_hold		(hold_ex_fpu),
	.icu_diag_data_c	(icu_diag_data_c),
	.dcu_data_c		(dcu_data_c),
	.rs1_bypass_mux_sel	({rs1_bypass_hold,rs1_forward_mux_sel}),
	.rs2_bypass_mux_sel	({rs2_bypass_hold,rs2_forward_mux_sel}),
	.ucode_reg_data_mux_sel	(ucode_reg_data_mux_sel),
	.ucode_dcu_req		(ucode_dcu_req[1:0]),
	.imdr_done_e		(imdr_done_e),
	.imdr_div0_e		(imdr_div0_e),
	.null_objref_e		(cmp_eq_e),
	.carry_out_e		(carry_out_e),
	.iu_data_vld		(iu_data_vld),
	.icu_data_vld		(icu_data_vld),
	.icu_diag_ld_c		(icu_diag_ld_c),
	.smu_sbase		(smu_sbase[31:2]),
	.smu_sbase_we		(smu_sbase_we),
	.pj_boot8_e		(pj_boot8_e),
	.pj_no_fpu_e		(pj_no_fpu_e),
	.tbase_tt_e		(tt_c),
	.tbase_tt_we_e		(tt_we),
	.sin			(),
	.so			(),
	.sm			(),
	.reset_l			(reset_l),
	.clk			(clk)
	);

   ifu ifu(
	.ibuff_0		(icu_data[55:48]),
	.ibuff_1		(icu_data[47:40]),
	.ibuff_2		(icu_data[39:32]),
	.ibuff_3		(icu_data[31:24]),
	.ibuff_4		(icu_data[23:16]),
	.ibuff_5		(icu_data[15:8]),
	.ibuff_6		(icu_data[7:0]),
	.fetch_drty		(icu_drty),
	.fetch_valid		(icu_vld_d[6:0]),
	.fetch_len0		(icu_length_d[27:24]),
	.fetch_len1		(icu_length_d[23:20]),
	.fetch_len2		(icu_length_d[19:16]),
	.fetch_len3		(icu_length_d[15:12]),
	.fetch_len4		(icu_length_d[11:8]),
	.fetch_len5		(icu_length_d[7:4]),
	.fetch_len6		(icu_length_d[3:0]),
	.iu_psr_fle		(psr[6]),
	.sc_bottom		(sc_bottom),
	.lvars			(lvars),
	.squash_fold		(squash_fold),
	.kill_vld_d		(kill_inst_d),
	.hold_d			(hold_ifu_d),
	.hold_r			(hold_ifu_r),
	.hold_e			(hold_ifu_e),
	.hold_c			(hold_ifu_c),
	.iu_trap_c		(iu_trap_c),
	.group_1_r		(group_1_r),
	.group_2_r		(group_2_r),
	.group_3_r		(group_3_r),
	.group_4_r		(group_4_r),
	.group_5_r		(group_5_r),
	.group_6_r		(group_6_r),
	.group_7_r		(group_7_r),
	.group_8_r		(group_8_r),
	.group_9_r		(group_9_r),
	.no_fold_r		(no_fold_r),
	.fold_r			(fold_r),
	.opcode_1_rs1_r		(opcode_1_rs1_r),
	.opcode_2_rs1_r		(opcode_2_rs1_r),
	.offset_1_rs1_r		(offset_1_rs1_r),
	.offset_2_rs1_r		(offset_2_rs1_r),
	.valid_rs1_r		(valid_rs1_r),
	.help_rs1_r		(help_rs1_r),
	.lv_rs1_r		(lv_rs1_r),
	.type_rs1_r		(type_rs1_r),
	.lvars_acc_rs1_r	(lvars_acc_rs1_r),
	.st_index_op_rs1_r	(st_index_op_rs1_r),
	.reverse_ops_rs1_r	(reverse_ops_rs1_r),
	.update_optop_r		(update_optop_r),
	.opcode_1_rs2_r		(opcode_1_rs2_r),
	.opcode_2_rs2_r		(opcode_2_rs2_r),
	.offset_1_rs2_r		(offset_1_rs2_r),
	.offset_2_rs2_r		(offset_2_rs2_r),
	.valid_rs2_r		(valid_rs2_r),
	.lv_rs2_r		(lv_rs2_r),
	.lvars_acc_rs2_r	(lvars_acc_rs2_r),
	.opcode_1_op_r_rcu	(opcode_1_op_r_rcu),
	.opcode_1_op_r_ex	(opcode_1_op_r_ex),
	.opcode_1_op_r_fpu	(opcode_1_op_r),
	.opcode_1_op_r_ucode	(opcode_1_op_r_ucode),
	.opcode_2_op_r		(opcode_2_op_r),
	.opcode_3_op_r		(opcode_3_op_r),
	.opcode_4_op_r		(opcode_4_op_r),
	.opcode_5_op_r		(opcode_5_op_r),
	.valid_op_r_rcu		(valid_op_r_rcu),
	.valid_op_r_ucode	(valid_op_r_ucode),
	.valid_op_r_pipe	(valid_op_r_pipe),
	.valid_op_r_ex		(valid_op_r_ex),
	.valid_op_r_fpu		(valid_op_r),
	.opcode_1_rsd_r		(opcode_1_rsd_r),
	.opcode_2_rsd_r		(opcode_2_rsd_r),
	.offset_rsd_r		(offset_rsd_r),
	.valid_rsd_r		(valid_rsd_r),
	.offset_pc_br_r		(offset_pc_br_r),
	.drty_inst_r		(drty_inst_r),
	.put_field2_quick_r	(put_field2_quick_r),
	.iu_shift_d		(iu_shift_d),
	.sin			(),	
	.sm			(),
	.so			(),	
	.reset_l			(reset_l),
	.clk			(clk) 
	);

   rcu rcu(
	.iu_optop_e		(optop_e),
	.iu_lvars		(lvars),
	.iu_sc_bottom		(sc_bottom),
	.ucode_addr_s		(ucode_rd_addr),
	.ucode_areg0		(u_areg0),
	.ex_adder_out_e		(adder_out_e),
	.ucode_dest_we		(ucode_stk_wr),
	.ucode_dest_sel		(ucode_dest_sel),		
	.ucode_active		(ucode_stk_rd),
	.opcode_1_rs1_r		(opcode_1_rs1_r),
	.opcode_2_rs1_r		(opcode_2_rs1_r),
	.offset_1_rs1_r		(offset_1_rs1_r),
	.offset_2_rs1_r		(offset_2_rs1_r),
	.valid_rs1_r		(valid_rs1_r),
	.help_rs1_r		(help_rs1_r),	
	.type_rs1_r		(type_rs1_r),
	.lvars_acc_rs1_r	(lvars_acc_rs1_r),
	.st_index_op_rs1_r	(st_index_op_rs1_r),
	.lv_rs1_r		(lv_rs1_r),
	.first_vld_c		(first_vld_c),
	.reverse_ops_rs1_r	(reverse_ops_rs1_r),
	.update_optop_r		(update_optop_r),
	.opcode_1_rs2_r		(opcode_1_rs2_r),
	.opcode_2_rs2_r		(opcode_2_rs2_r),	
	.offset_1_rs2_r		(offset_1_rs2_r),
	.offset_2_rs2_r		(offset_2_rs2_r),
	.valid_rs2_r		(valid_rs2_r),
	.lvars_acc_rs2_r	(lvars_acc_rs2_r),
	.lv_rs2_r		(lv_rs2_r),
	.valid_op_r		(valid_op_r_rcu),
	.put_field2_quick_r	(put_field2_quick_r),
	.hold_ucode		(hold_rcu_ucode),
	.hold_e			(hold_rcu_e),
	.hold_c			(hold_rcu_c),
	.iu_data_w		(iu_data_w),
	.smu_data		(smu_data),
	.iu_smu_data		(iu_smu_data),
	.smu_rf_addr		(smu_rf_addr),
	.smu_we			(smu_we),
	.offset_rsd_r		(offset_rsd_r),
	.opcode_1_op_r		(opcode_1_op_r_rcu),
	.opcode_2_op_r		(opcode_2_op_r),
	.opcode_1_rsd_r		(opcode_1_rsd_r),
	.opcode_2_rsd_r		(opcode_2_rsd_r),
	.valid_rsd_r		(valid_rsd_r),
	.group_1_r		(group_1_r),
	.group_2_r		(group_2_r),
	.group_3_r		(group_3_r),
	.group_4_r		(group_4_r),
	.group_5_r		(group_5_r),
	.group_6_r		(group_6_r),
	.group_7_r		(group_7_r),
	.group_9_r		(group_9_r),
	.no_fold_r		(no_fold_r),
	.inst_vld		(inst_valid),
	.ucode_done		(ucode_done),
	.iu_trap_r		(iu_trap_r),
	.rs1_data_e		(rs1_data_e),
	.rs2_data_e		(rs2_data_e),
	.scache_rd_miss_e	(scache_rd_miss_e),
	.optop_offset		(optop_offset_r),
	.rs1_forward_mux_sel	(rs1_forward_mux_sel),
	.rs2_forward_mux_sel	(rs2_forward_mux_sel),
	.dest_addr_w		(dest_addr_w),
	.scache_wr_miss_w	(scache_wr_miss_w),
	.iu_smu_flush		(iu_smu_flush),
	.first_cycle		(first_cyc_r),
	.second_cycle		(second_cyc_r),
        .scache_miss_addr_e	(scache_miss_addr_e),
        .inst_complete_w	(pj_inst_complete),
	.sin			(),	
	.sm			(),
	.so			(),	
	.reset_l			(reset_l),
	.clk			(clk)
	);

  ucode ucode (
	.opcode_1_op_r		(opcode_1_op_r_ucode),
        .opcode_2_op_r		(opcode_2_op_r),
        .opcode_3_op_r		(opcode_3_op_r),
        .valid_op_r   		(valid_op_r_ucode),
        .iu_trap_r    		(iu_trap_r),
        .ie_stall_ucode		(hold_ucode),
        .ie_kill_ucode 		(iu_kill_ucode),
        .iu_hold_e     		(hold_ex_dp_e),
        .iu_psr_gce    		(psr[12]),
        .ie_alu_cryout 		(carry_out_e),
        .ie_comp_a_eq0 		(cmp_eq_e),
        .dreg			(dcu_data_w[31:0]),
        .rs1 			(iu_rs1_e[31:0]),
        .rs2 			(iu_rs2_e[31:0]),
        .rs1_0_l     		(iu_rs1_e_0_l),
        .rs2_0_l     		(iu_rs2_e_0_l),
        .iu_optop    		(optop_e_v2[31:0]),
        .alu_data    		(adder_out_e[31:0]),
        .archi_data  		(ucode_reg_data[31:0]),
        .ucode_addr_d		(iu_addr_e[31:0]),
        .te_ieu_rom             (te_ieu_rom),
        .ieu_in_powerdown       (ieu_in_powerdown),
        .sm   			(),
        .sin  			(),
	.so			(),
	.reset_l		(reset_l),
        .clk  		(clk),
        .ucode_porta		(ucode_porta[31:0]),
        .ucode_portc		(ucode_portc[31:0]),
	.u_f01_wt_stk		(ucode_stk_wr),
        .u_f02_rd_stk		(ucode_stk_rd),
        .u_addr_st_rd		(ucode_rd_addr),

        .ialu_a			(iu_alu_a[31:0]),
        .ucode_portb		(iu_alu_b[31:0]),
        .m_adder_porta		(m_adder_porta[31:0]),
        .m_adder_portb		(m_adder_portb[31:0]),
        .u_f00			(ucode_porta_sel),
        .u_f01			(ucode_reg_rd[2:0]),
        .u_f02			(u_f02),
        .u_f03			(ucode_dcu_req),
        .u_f04			(ucode_reg_data_mux_sel),
        .u_f05			(ucode_reg_wr[2:0]),
        .u_f07			(ucode_alu_b_sel[2:0]),
        .u_f17			(alu_adder_fn[1:0]),
        .u_f19			(ucode_madder_sel2[3:0]),
        .u_f21			(mem_adder_fn[1:0]),
	.u_f22			(ucode_dest_sel),
        .u_f23			(ucode_alu_a_sel[1:0]),
	.u_areg0                (u_areg0[31:0]),
        .u_done    		(ucode_done),
        .udone_l    		(udone_l),
        .u_last    		(ucode_last),
        .u_abt_rdwt		(ucode_abort),
 	.u_ary_ovf  		(u_ary_ovf_c),
        .u_ref_null 		(u_ref_null_c),
        .u_ptr_un_eq		(u_ptr_un_eq_c),
        .u_gc_notify		(gc_trap_c)
         );


   pipe pipe(
	.arch_pc		(pc_c),
     	.pc_r			(pc_r),
	.opcode_pc_e		(pc_e),
	.iu_optop_din		(iu_optop_din),
	.iu_optop_int_we	(iu_optop_int_we),
	.reissue_c		(reissue_c),
	.fold_c			(fold_c),
	.fold_sc_miss_e		(fold_sc_miss_e),
	.arch_optop		(optop_c),
	.optop_e		(optop_e),
	.optop_e_v1		(optop_e_v1),
	.optop_e_v2		(optop_e_v2),
	.inst_vld		(inst_valid),
	.inst_vld_e		(inst_vld_e),
	.squash_fold		(squash_fold),
	.sc_dcache_req		(sc_dcache_req), 
	.sc_data_vld		(sc_data_vld),
	.sc_rd_miss_sel		(sc_rd_miss_sel),
	.scache_miss		(scache_miss),
	.lduse_hold		(lduse_hold),
	.rs1_bypass_hold	(rs1_bypass_hold),
	.rs2_bypass_hold	(rs2_bypass_hold),
	.rs1_mux_sel_din	(rs1_mux_sel_din),
	.forward_c_sel_din	(forward_c_sel_din),
	.kill_inst_d		(kill_inst_d),
	.kill_inst_e		(kill_inst_e),
	.kill_inst_e_int	(kill_inst_e_int),
	.hold_r			(hold_pipe_r),
	.hold_e			(hold_pipe_e),
	.hold_c			(hold_pipe_c),
	.hold_ucode		(hold_rcu_ucode),
	.hold_c_int		(hold_pipe_c_int),
	.iu_perf_sgnl		(iu_perf_sgnl[0]),
	.icu_pc_d		(icu_pc_d),
	.optop_shft_r		(optop_offset_r),
	.pc_offset_r		(offset_pc_br_r),
	.fold_r			(fold_r),
	.iu_brtaken_e		(branch_taken_e),
	.iu_trap_c		(iu_trap_c),
	.async_error		(async_error),
	.iu_trap_r		(iu_trap_r),
	.trap_in_progress	(trap_in_progress),
	.trap_vld_r		(trap_vld_r),
	.trap_vld_e		(trap_vld_e),
	.inst_vld_r		(valid_op_r_pipe),
	.wr_optop_e		(wr_optop_e),
	.iu_data_e		(wr_optop_data_e),
	.icu_hold		(icu_hold),
	.first_cyc_r		(first_cyc_r),
	.load_c			(load_c),
	.lduse_bypass		(lduse_bypass),
	.ucode_done		(ucode_done),
	.ucode_last		(ucode_last),
	.ru_byp_rs1_e_hit	(rs1_forward_mux_sel[3]),
	.ru_byp_rs2_e_hit	(rs2_forward_mux_sel[3]),	
	.rs2_bypass_vld		(iu_bypass_rs2_e),
	.rs1_bypass_vld		(iu_bypass_rs1_e),
	.ucode_stk_rd		(ucode_stk_rd),
	.scache_rd_miss_e	(scache_rd_miss_e),	
	.iu_data_vld		(iu_data_vld),
	.icu_data_vld		(icu_data_vld),
	.icu_diag_ld_c		(icu_diag_ld_c),
	.powerdown_op_e		(iu_powerdown_op_e),
	.reset_l		(reset_l),
	.clk			(clk),
	.sm			(),
	.sin			(),
	.so			()
	);

trap	trap (
 	.iu_trap_c		(iu_trap_c),
        .trap_vld_r		(trap_vld_r),
        .trap_vld_e		(trap_vld_e),	
        .trap_in_progress	(trap_in_progress),
	.iu_trap_r		(iu_trap_r),
	.iu_kill_dcu		(iu_kill_dcu),
	.iu_kill_fpu		(iu_kill_fpu),
	.iu_kill_ucode		(iu_kill_ucode),
	.kill_powerdown		(kill_powerdown),
        .tt_c			(tt_c),
	.tt_we			(tt_we),
	.pj_brk1_sync		(pj_brk1_sync),
	.pj_brk2_sync		(pj_brk2_sync),
	.inst_vld_c		(inst_valid[1]),
	.pj_resume		(pj_resume),
	.pj_in_halt		(pj_in_halt),
        .pj_irl			(pj_irl[3:0]),
        .pj_nmi			(pj_nmi),
	.ucode_abort		(ucode_abort),
        .pj_no_fpu		(pj_no_fpu_e),
        .iu_psr_pil		(psr[3:0]),
        .iu_psr_ie		(psr[4]),
        .iu_psr_fpe		(psr[11]),
        .hold_r			(hold_trap_r),
        .iu_psr_ace		(psr[13]),
        .iu_psr_aem		(psr[8]),
        .inst_brk1_r		(inst_brk1_r),
        .inst_brk2_r		(inst_brk2_r),
        .first_cyc_e		(first_cyc_e),
        .imem_acc_err_r		(drty_inst_r),
        .illegal_r		(illegal_op_r),
        .priv_inst_r		(priv_inst_r),
        .fpu_inst_r		(fpu_inst_r),
        .zero_trap_e		(zero_trap_e),
        .soft_trap_r		(soft_trap_r),
        .arithm_exe_e		(imdr_div0_e),
	.powerdown_op_e		(iu_powerdown_op_e),
        .null_ptr_exe_e		(null_ptr_exe_e),
        .lock_trap_e		(lock_trap_e[3:0]),
        .u_ref_null_c		(u_ref_null_c),
        .u_ary_ovf_c		(u_ary_ovf_c),
        .u_ptr_un_eq_c		(u_ptr_un_eq_c),
        .dcu_err_ack		(dcu_err_ack),
	.async_mem_prot_err	(async_mem_prot_err),
	.async_error		(async_error),
        .mem_prot_err_c		(mem_prot_error_c),
        .data_brk1_c		(data_brk1_c),
        .data_brk2_c		(data_brk2_c),
        .oplim_trap_c		(oplim_trap_c),
        .align_err_c		(mis_align_c),
        .emul_op_r		(emulated_trap_r),
        .gc_trap_c		(gc_trap_c),
        .opcode_c		(opcode_c[7:0]),
	.fold_c			(fold_c),
	.fold_sc_miss_e		(fold_sc_miss_e),
	.brk12c_halt		(brk12c_halt),
	.iu_brtaken_e		(branch_taken_e),
        .ucode_done		(ucode_done),
	.ucode_last		(ucode_last),
        .hold_e			(hold_trap_e),
        .hold_c			(hold_trap_c),
        .clk			(clk),
        .reset_l			(reset_l),
        .sm			(),
        .sin			(),
        .so			()
);


hold_logic hold_logic(

	.hold_ucode		(hold_ucode),
        .hold_fpu		(hold_fpu),
        .hold_ex_fpu		(hold_ex_fpu),
        .hold_imdr		(hold_imdr),
 
        .hold_ifu_d		(hold_ifu_d),
        .hold_ifu_r		(hold_ifu_r),
        .hold_ifu_e		(hold_ifu_e),
        .hold_ifu_c		(hold_ifu_c),

        .hold_pipe_r		(hold_pipe_r),
        .hold_pipe_e		(hold_pipe_e),
        .hold_pipe_c		(hold_pipe_c),

        .hold_rcu_e		(hold_rcu_e),
        .hold_rcu_c		(hold_rcu_c),
        .hold_rcu_ucode		(hold_rcu_ucode),

        .hold_trap_r		(hold_trap_r),
        .hold_trap_e		(hold_trap_e),
        .hold_trap_c		(hold_trap_c),

        .hold_ex_ctl_e		(hold_ex_ctl_e),
        .hold_ex_ctl_c		(hold_ex_ctl_c),

        .hold_ex_regs_e		(hold_ex_reg_e),
        .hold_ex_regs_c		(hold_ex_reg_c),

        .hold_ex_dp_e		(hold_ex_dp_e),
	.hold_ex_dp_c		(hold_ex_dp_c),

        .hold_pipe_c_int	(hold_pipe_c_int),
	.perf_sgnl		(iu_perf_sgnl[2:1]),

         //INPUTS
        .dcu_stall		(dcu_stall),
        .icu_hold		(icu_hold),
        .imdr_done_e		(imdr_done_e),
        .fp_rdy_e		(fp_rdy_e),
        .first_cyc_r		(first_cyc_r),
        .first_vld_c		(first_vld_c),
        .smu_hold		(smu_hold),
        .scache_miss		(scache_miss),
        .lduse_hold		(lduse_hold),
        .powerdown_op_e		(iu_powerdown_op_e),
        .kill_powerdown		(kill_powerdown),
        .u_done_l		(udone_l),
        .pj_in_halt		(pj_in_halt),
        .pj_halt		(pj_halt),
	.clk			(clk),
	.reset_l		(reset_l),
	.sm			(),
	.si			(),
	.so			());

	
endmodule // iu
