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

module	pipe (

	// OUTPUTS
	arch_pc,
	pc_r,
	opcode_pc_e,
	arch_optop,
	iu_optop_din,
	optop_e,
	optop_e_v1,
	optop_e_v2,
	inst_vld,
	inst_vld_e,
	iu_optop_int_we,
	reissue_c,
	fold_c,
	fold_sc_miss_e,
	squash_fold,
	lduse_bypass,
	rs1_bypass_hold,
	rs2_bypass_hold,
	sc_dcache_req,
	sc_data_vld,
	icu_data_vld,
	icu_diag_ld_c,
	sc_rd_miss_sel,
	kill_inst_d,
	kill_inst_e,
	kill_inst_e_int,
	hold_ucode,
	hold_r,
	hold_e,
	hold_c,
	hold_c_int,
	iu_perf_sgnl,
	rs1_mux_sel_din,
	forward_c_sel_din,
	
 	// INPUTS
        icu_pc_d,
        optop_shft_r,
	pc_offset_r,
        fold_r,
	iu_brtaken_e,
	iu_trap_c,
	async_error,
	iu_trap_r,
	trap_vld_r,
	trap_vld_e,
	trap_in_progress,
        inst_vld_r,
        wr_optop_e,
        iu_data_e,
	icu_hold,      
        first_cyc_r,     
        load_c,         
	ucode_stk_rd,
        ucode_done,     
	ucode_last,
        ru_byp_rs1_e_hit,
        ru_byp_rs2_e_hit,
	rs2_bypass_vld,
	rs1_bypass_vld,
        scache_rd_miss_e,
	scache_miss,
	lduse_hold,
        iu_data_vld, 
	powerdown_op_e,

	clk,
	reset_l,
	sm,
	sin,
	so

);

output	[31:0]		arch_pc;		// Architectural PC
output	[31:0]		pc_r;			// PC R stage
output	[31:0]		opcode_pc_e;		// PC of opcode in E stage
output	[31:0]		arch_optop; 		// Architectural OPTOP
output	[31:0]		iu_optop_din; 		// Signal at the din input of arch optop flop
output	[31:0]		optop_e;		// Temporary Optop used by following inst
output	[31:0]		optop_e_v1;		// Temporary Optop used by following inst
output	[31:0]		optop_e_v2;		// Temporary Optop used by following inst
output	[2:0]		inst_vld;	// Valid bits for the pipe to keep track of instructions
output			inst_vld_e;
output			iu_optop_int_we;	// This is the write enable for the flop
						// in SMU to generate it's own version of optop
output			squash_fold;	// disable folding. folded group has trapped
output			sc_dcache_req;	// stack miss dcache request
output			sc_data_vld;	// dcache data available is due to S$ read miss
output			icu_data_vld;	// icu diagnostic data available

output			sc_rd_miss_sel;	// used to select D$ data for S$ read misses
output			lduse_bypass;	// bypass data from DCU on load-use case
output			rs1_bypass_hold;// hold rs1 data
output			rs2_bypass_hold;// hold rs2 data
output			kill_inst_d;	// kill instruction in D stage
output			kill_inst_e;	// kill DCU requests/priv writes in E stage
output			kill_inst_e_int;// kill DCU requests/priv writes in E stage
output			reissue_c;	// reissue the instruction which is in C stage
output			fold_c;		// folded group in C stage
output			fold_sc_miss_e;	// folded group misses S$ 
input			hold_r;		// hold contents of R stage
input			hold_e;		// hold contents of E stage 
input			hold_c;		// hold contents of C stage 
input			hold_c_int;		// hold contents of C stage 
input			hold_ucode;
output			iu_perf_sgnl;	// performance monitor signals
output			rs1_mux_sel_din;	// This signal selects scache data in case of s$ misses
output			forward_c_sel_din;	// This signal selects DCU data for forward data_c
					// for RS1
output			scache_miss;
output			lduse_hold;



input	[31:0]		icu_pc_d;	// PC of first instruction of Ibuffer
input	[31:0]		optop_shft_r;	// Shift in optop due to instructions dispatched.
input	[2:0]		pc_offset_r;	// pc offset to calculate PC of branching instr.
input			iu_brtaken_e;	// Branch has been taken. need to squash vld bits
input			iu_trap_c;	// Trap has been taken need to squash valid bits.
input			async_error;	// asynchronous error in C stage
input			iu_trap_r;	// Trap in R stage.need to start trapframe building
input			trap_vld_r;	// possible trap in R stage
input			trap_vld_e;	// possible trap in E stage
input			trap_in_progress;// trap frame building in R stage
input			inst_vld_r;	// Instruction in R stage is valid
input	[31:0]		iu_data_e;	// Data bus for write to optop on priv_write_optop
input			icu_hold;	// icu unable to service request.
input			ucode_stk_rd;	// ucode reading stackcache
input			first_cyc_r;	// first cycle of a 2 cycle op
input			load_c;		// load instruction in C stage
input			ucode_done;	// ucode is free accept new instruction
input			ucode_last;	// ucode's last  cycle
input			ru_byp_rs1_e_hit;// rs1 bypass hit e stage destination
input			ru_byp_rs2_e_hit;// rs2 bypass hit e stage destination
input			rs2_bypass_vld;	//  instruction uses RS2 bypass
input			rs1_bypass_vld;	//  instruction uses RS1 bypass
input			scache_rd_miss_e;// stack cache read miss
input			icu_diag_ld_c;	// diagnostic load in C stage
input			iu_data_vld;	// data from dcache valid.
input			fold_r;		// folded group in R stage
input			wr_optop_e;	// write to optop register
input			powerdown_op_e;	// powerdown inst in E
input			clk;		
input			reset_l;
input			sm;
input			sin;
output			so;

wire	[3:0]		optop_sel_e;
wire	[3:0]		optop_sel_c;
wire	[2:0]		optop_enable;
wire	[2:0]		pc_enable;


pipe_dpath	pipe_dpath(
			.arch_pc		(arch_pc[31:0]),
			.pc_r			(pc_r[31:0]),
			.opcode_pc_e		(opcode_pc_e[31:0]),
			.arch_optop		(arch_optop[31:0]),
			.iu_optop_din		(iu_optop_din[31:0]),
			.optop_e		(optop_e[31:0]),
			.optop_e_v1		(optop_e_v1[31:0]),
			.optop_e_v2		(optop_e_v2[31:0]),
			.optop_sel_e		(optop_sel_e[3:0]),
			.optop_sel_c		(optop_sel_c[3:0]),
			.optop_enable		(optop_enable[2:0]),
			.pc_enable		(pc_enable[2:0]),
			.optop_shft_r		(optop_shft_r[31:0]),
			.pc_offset_r		(pc_offset_r[2:0]),
			.iu_data_e		(iu_data_e[31:0]),
			.icu_pc_d		(icu_pc_d[31:0]),
			.trap_in_progress	(trap_in_progress),
			.clk			(clk),
			.reset_l			(reset_l),
			.sm			(),
			.sin			(),
			.so			());


pipe_cntl	pipe_cntl(
			.inst_vld		(inst_vld[2:0]),
			.inst_vld_e_v1		(inst_vld_e),
			.sc_dcache_req		(sc_dcache_req),
			.sc_data_vld		(sc_data_vld),
			.squash_fold		(squash_fold),
			.iu_optop_int_we	(iu_optop_int_we),
			.sc_rd_miss_sel		(sc_rd_miss_sel),
			.lduse_bypass		(lduse_bypass),
			.optop_sel_e		(optop_sel_e[3:0]),
			.optop_sel_c		(optop_sel_c[3:0]),
			.optop_enable           (optop_enable[2:0]),
                        .pc_enable              (pc_enable[2:0]),
			.kill_inst_d		(kill_inst_d),
			.kill_inst_e		(kill_inst_e),
			.kill_inst_e_int	(kill_inst_e_int),
			.reissue_c		(reissue_c),
			.rs1_bypass_hold	(rs1_bypass_hold),
			.rs2_bypass_hold	(rs2_bypass_hold),
			.fold_c			(fold_c),
			.fold_sc_miss_e		(fold_sc_miss_e),
			.hold_r			(hold_r),
			.hold_e			(hold_e),
			.hold_c			(hold_c),
			.hold_c_int		(hold_c_int),
			.hold_ucode		(hold_ucode),
			.iu_perf_sgnl		(iu_perf_sgnl),
			.rs1_mux_sel_din	(rs1_mux_sel_din),
			.forward_c_sel_din	(forward_c_sel_din),
			.iu_brtaken_e		(iu_brtaken_e),
			.iu_trap_c		(iu_trap_c),
			.async_error		(async_error),
			.iu_trap_r		(iu_trap_r),
			.trap_vld_r		(trap_vld_r),
			.trap_vld_e		(trap_vld_e),
			.trap_in_progress	(trap_in_progress),
			.icu_hold		(icu_hold),
			.first_cyc_r		(first_cyc_r),
			.load_c			(load_c),
			.ucode_done		(ucode_done),
			.ucode_stk_rd		(ucode_stk_rd),
			.ucode_last		(ucode_last),
			.ru_byp_rs1_e_hit	(ru_byp_rs1_e_hit),
			.ru_byp_rs2_e_hit	(ru_byp_rs2_e_hit),
			.rs1_bypass_vld		(rs1_bypass_vld),
			.rs2_bypass_vld		(rs2_bypass_vld),
			.scache_rd_miss_e	(scache_rd_miss_e),
			.scache_miss		(scache_miss),
			.lduse_hold		(lduse_hold),
			.icu_data_vld		(icu_data_vld),
			.icu_diag_ld_c		(icu_diag_ld_c),
			.iu_data_vld		(iu_data_vld),
			.powerdown_op_e		(powerdown_op_e),
			.fold_r			(fold_r),
			.wr_optop_e		(wr_optop_e),
			.inst_vld_r		(inst_vld_r),
			.clk			(clk),
			.sm			(),
			.reset_l			(reset_l),
			.sin			(),
			.so			());


endmodule
