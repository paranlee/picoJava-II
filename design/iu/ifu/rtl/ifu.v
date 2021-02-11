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


module ifu (

	ibuff_0,
	ibuff_1,
	ibuff_2,
	ibuff_3,
	ibuff_4,
	ibuff_5,
	ibuff_6,
	fetch_drty,
	fetch_valid,
	fetch_len0,
	fetch_len1,
	fetch_len2,
	fetch_len3,
	fetch_len4,
	fetch_len5,
	fetch_len6,
	iu_psr_fle,
	sc_bottom,
	lvars,
	squash_fold,
	kill_vld_d,
	hold_d,
	hold_r,
	hold_e,
	hold_c,
	iu_trap_c,
	sin,
	sm,	
	reset_l,
	clk,
	group_1_r,
	group_2_r,
	group_3_r,
	group_4_r,
	group_5_r,
	group_6_r,
	group_7_r,
	group_8_r,
	group_9_r,
	no_fold_r,
	fold_r,
	opcode_1_rs1_r,
	opcode_2_rs1_r,
	offset_1_rs1_r,
	offset_2_rs1_r,
	valid_rs1_r,
	help_rs1_r,
	lv_rs1_r,
	type_rs1_r,
	lvars_acc_rs1_r,
	st_index_op_rs1_r,
	reverse_ops_rs1_r,
	update_optop_r,
	opcode_1_rs2_r,
	opcode_2_rs2_r,
	offset_1_rs2_r,
	offset_2_rs2_r,
	valid_rs2_r,
	lv_rs2_r,
	lvars_acc_rs2_r,
//	Generate different versions of opcode_1_op to
// 	improve timing

	opcode_1_op_r_rcu,
	opcode_1_op_r_ex,
	opcode_1_op_r_fpu,
	opcode_1_op_r_ucode,

	opcode_2_op_r,
	opcode_3_op_r,
	opcode_4_op_r,
	opcode_5_op_r,
	valid_op_r_rcu,
	valid_op_r_ucode,
	valid_op_r_pipe,
	valid_op_r_ex,
	valid_op_r_fpu,
	opcode_1_rsd_r,
	opcode_2_rsd_r,
	offset_rsd_r,
	valid_rsd_r,
	offset_pc_br_r,
	drty_inst_r,
	put_field2_quick_r,
	iu_shift_d,
	so


);

input	[7:0]	ibuff_0;		// 1st entry of Ibuffer
input	[7:0]	ibuff_1;                // 2nd entry of Ibuffer		
input	[7:0]	ibuff_2;                // 3rd entry of Ibuffer
input	[7:0]	ibuff_3;                // 4th entry of Ibuffer
input	[7:0]	ibuff_4;                // 5th entry of Ibuffer
input	[7:0]	ibuff_5;                // 6th entry of Ibuffer
input	[7:0]	ibuff_6;                // 7th entry of Ibuffer
input	[6:0]	fetch_drty;		// Dirty bits of the 7 entries in Ibuffer
input	[6:0]	fetch_valid;		// Valid bits of the 7 entries in Ibuffer
input	[3:0]	fetch_len0;		// Len. of the instr. corresp. to 1st byte in Ibuffer
input	[3:0]	fetch_len1;             // Len. of the instr. corresp. to 2nd byte in Ibuffer
input	[3:0]	fetch_len2;             // Len. of the instr. corresp. to 3rd byte in Ibuffer
input	[3:0]	fetch_len3;             // Len. of the instr. corresp. to 4th byte in Ibuffer
input	[3:0]	fetch_len4;             // Len. of the instr. corresp. to 5th byte in Ibuffer
input	[3:0]	fetch_len5;             // Len. of the instr. corresp. to 6th byte in Ibuffer
input	[3:0]	fetch_len6;             // Len. of the instr. corresp. to 7th byte in Ibuffer
input		iu_psr_fle;		// Bit in PSR reg. to enable folding
input	[31:0]	sc_bottom;		// Stack Bottom Register
input	[31:0]	lvars;			// Local Var. Register
input		squash_fold;		// Signal from pipeline control to disable
					// folding.
input		kill_vld_d;		// Signal from pipeline control to kill valids
					// in the d-stage for branches and traps
input		hold_d;			// Hold for D-stage
input		hold_r;			// Hold for R-stage
input		hold_e;			// Hold for E-stage
input		hold_c;			// Hold for C-stage
input		iu_trap_c;		// Trap in C-stage
input		sin;			// IFU Scan In Port
input		sm;			// IFU Scan Enable Port
input		reset_l;			// Reset
input		clk;			// Clock
output		group_1_r;		// Indicates  group_1 folding
output		group_2_r;              // Indicates  group_2 folding
output		group_3_r;              // Indicates  group_3 folding
output		group_4_r;              // Indicates  group_4 folding
output		group_5_r;              // Indicates  group_5 folding
output		group_6_r;              // Indicates  group_6 folding
output		group_7_r;              // Indicates  group_7 folding
output		group_8_r;              // Indicates  group_8 folding
output		group_9_r;              // Indicates  group_9 folding
output		no_fold_r;		// Indicates thatonly one instr. is issued
output		fold_r;			// Indicates that more than one instr is issued
output	[7:0]	opcode_1_rs1_r;		// 1st byte of opcode in RS1 stage
output	[7:0]	opcode_2_rs1_r;		// 2nd byte of opcode in RS1 stage
output	[7:0]	offset_1_rs1_r;		// 1st byte of offset in RS1 stage
output	[7:0]	offset_2_rs1_r;		// 2nd byte of offset in RS1 stage
output		valid_rs1_r;		// Indicates a valid LV + Long Load in RS1
output		help_rs1_r;		// Indicates multi-rstage operation in RS1
output		lv_rs1_r;		// Indicates an LV op in RS1

output	[7:0]	type_rs1_r;		// indicates the type of long op in rs1
                                	// type[0] = long or double load
                                	// type[1] = long or double store
                                	// type[2] = long add, and, sub, or, xor or 
					// neg operation
                                	// type[3] = double add, sub, rem, mul, div 
					// or compare operation
                                	// type[4] = long shift left operation
                                	// type[5] = long shift right operation
                                	// type[6] = priv write operations
                                	// type[7] = long compares

output		lvars_acc_rs1_r;	// Indicates that a scache access in RS1 uses lvars 
output		st_index_op_rs1_r;	// Indicates that there's st_*_index type of op in RS1
output		reverse_ops_rs1_r;	// Used to fix an Xface problem between FPU and IU
output		update_optop_r;		// Indicates that there's a priv_update_optop op
output	[7:0]	opcode_1_rs2_r;		// 1st byte of opcode in RS2 stage
output	[7:0]	opcode_2_rs2_r;		// 2nd byte of opcode in RS2 stage
output	[7:0]	offset_1_rs2_r;		// 1st byte of offset in RS2 stage
output	[7:0]	offset_2_rs2_r;		// 2nd byte of offset in RS2 stage
output		valid_rs2_r;		// Indicates a valid LV op in RS2
output		lv_rs2_r;		// Indicates a valid LV in RS2
output		lvars_acc_rs2_r;	// Indicates that a scache access in RS2 uses lvars 
output	[7:0]	opcode_1_op_r_rcu;	// 1st byte of opcode in OP stage to be used in RCU
output	[7:0]	opcode_1_op_r_ex;	// 1st byte of opcode in OP stage to be used in EX
output	[7:0]	opcode_1_op_r_fpu;	// 1st byte of opcode in OP stage to be used in FPU
output	[7:0]	opcode_1_op_r_ucode;	// 1st byte of opcode in OP stage to be used in UCODE
output	[7:0]	opcode_2_op_r;		// 2nd byte of opcode in OP stage
output	[7:0]	opcode_3_op_r;		// 3rd byte of opcode in OP stage
output	[7:0]	opcode_4_op_r;		// 4th byte of opcode in OP stage
output	[7:0]	opcode_5_op_r;		// 5th byte of opcode in OP stage

// Generating multiple versions of valid_op_r to improve timing on it 

output		valid_op_r_rcu;		// Indicates a valid OP in OP stage: used in RCU
output		valid_op_r_ucode;	// Indicates a valid OP in OP stage: used in Ucode
output		valid_op_r_pipe;	// Indicates a valid OP in OP stage: used in Pipe
output		valid_op_r_ex;		// Indicates a valid OP in OP stage: used in EX
output		valid_op_r_fpu;		// Indicates a valid OP in OP stage: used in FPU

output	[7:0]	opcode_1_rsd_r;		// 1st byte of opcode in RSd stage
output	[7:0]	opcode_2_rsd_r;		// 2nd byte of opcode in RSd stage
output	[7:0]	offset_rsd_r;		// offset in RSd stage
output		valid_rsd_r;		// Indicates a valid MEM operation in RSd stage
output	[2:0]	offset_pc_br_r;		// Gives the offset from PC, where the OP is there
output		drty_inst_r;		// Indicates that first instruction is a dirty one
output		put_field2_quick_r;	// Indicates a put_field_quick operation
output	[7:0]	iu_shift_d;		// tells how many bytes are consumed by folding
output		so;			// IFU Scan Out Port



wire	[7:0]	accum_len0;
wire	[7:0]	accum_len1;
wire	[7:0]	accum_len2;
wire	[7:0]	accum_len3;
wire	[3:0]	dec_valid;
wire	[5:0]	ex_len_first_inst;
wire	[5:0]	inst_1_type;
wire	[5:0]	inst_2_type;
wire	[5:0]	inst_3_type;
wire	[5:0]	inst_4_type;
wire	[7:0]	offset_1_rs1_int;
wire	[7:0]	offset_1_rs2_int;
wire	[7:0]	opcode_1_rs1;
wire	[7:0]	opcode_2_rs1;
wire	[7:0]	opcode_1_rs2;
wire	[7:0]	opcode_2_rs2;
wire	[7:0]	opcode_1_op_r_gen;
wire	[2:0]	instrs_folded;
wire	[2:0]	instrs_folded_r;
wire	[2:0]	instrs_folded_e;
wire	[2:0]	instrs_folded_c;
wire	[2:0]	instrs_folded_w;
wire		valid_op_r_gen;
wire		reverse_ops_rs1;
wire		update_optop;
wire		put_field2_quick;
wire		fold;
wire		valid_rs1_int1;
wire		group_1;
wire		group_2;
wire		group_3;
wire		group_4;
wire		group_5;
wire		group_6;
wire		group_7;
wire		group_8;
wire		group_9;
wire		valid_rs1_int;
wire		lv_rs1_int;
wire		lvars_acc_rs1_int;
wire		st_index_op_rs1;
wire		valid_rs2_int;
wire		lv_rs2_int;
wire		lv_rs2_int1;
wire		lvars_acc_rs2_int1;
wire		lvars_acc_rs2_int;
wire		vld_drty_entries;
wire		scache_miss_int;
wire		scache_miss;
wire		fold_enable;
wire		fold_1_inst;
wire		fold_2_inst;
wire		fold_3_inst;
wire		fold_4_inst;
wire		not_valid;
wire	[4:0]	offset_sel_rs1;
wire		valid_rs1;
wire		mem_op_rs1;
wire		help_rs1;
wire	[7:0]	type_rs1;
wire		lv_rs1;
wire	[4:0]	offset_sel_rs2;
wire	[7:0]	offset_1_rs1;
wire	[7:0]	offset_1_rs2;
wire	[7:0]	offset_2_rs1;
wire	[7:0]	offset_2_rs2;
wire		valid_rs2;
wire	[2:0]	op_sel;
wire	[7:0]	opcode_inst2_1;
wire	[7:0]	opcode_inst2_2;
wire	[7:0]	opcode_inst2_3;
wire	[7:0]	opcode_inst3_1;
wire	[7:0]	opcode_inst3_2;
wire	[7:0]	opcode_inst3_3;
wire	[7:0]	opcode_inst4_1;
wire	[7:0]	opcode_inst4_2;
wire	[7:0]	opcode_inst4_3;
wire	[7:0]	opcode_1_op;
wire	[7:0]	opcode_2_op;
wire	[7:0]	opcode_3_op;
wire		valid_op;
wire		valid_rsd;
wire	[7:0]	rs2_inst_1;
wire	[7:0]	rs2_inst_2;
wire	[7:0]	rs2_inst_3;
wire	[3:0]	opcode_sel_rsd;
wire	[7:0]	opcode_1_rsd;
wire	[7:0]	opcode_2_rsd;
wire	[7:0]	opcode_3_rsd;
wire	[7:0]	offset_rsd_int;
wire	[7:0]	offset_rsd;
wire	[3:0]	offset_rsd_ctl;
wire	[4:0]	offset_sel_rsd;
wire	[7:0]	offset_pc_br_dec;
wire	[2:0]	offset_pc_br;
wire	[1:0]	swap_rs1_rs2;
wire		drty_inst;
wire		drty_inst_1;
wire		drty_inst_2;
wire		drty_inst_3;
wire		drty_inst_4;
wire		drty_inst_5;
wire		lv_rs2;
wire		lvars_acc_rs1;
wire		lvars_acc_rs2;


// Decode the exact length of the first inst.

ex_len_dec	ex_len_dec (.opcode(ibuff_0),
				.valid(fetch_valid[4:0]),
				.len0(ex_len_first_inst[0]),
				.len1(ex_len_first_inst[1]),
				.len2(ex_len_first_inst[2]),
				.len3(ex_len_first_inst[3]),
				.len4(ex_len_first_inst[4]),
				.len5(ex_len_first_inst[5]) );
				
// Instantiate accumulated length detector
// This detector will output four lengths, accum_len0..accum_len3, 
// accum_len0 -> length of the 1st instr
// accum_len1 -> length of the 1st instr + length of the 2nd instr
// The above four lengths correspond to four prospective instructions to be folded

length_dec	length_dec (.fetch_len0(fetch_len0),
				.fetch_len1(fetch_len1),
				.fetch_len2(fetch_len2),
				.fetch_len3(fetch_len3),
				.fetch_len4(fetch_len4),
				.fetch_len5(fetch_len5),
				.fetch_len6(fetch_len6),
				.fold_4_inst(fold_4_inst),
				.fold_3_inst(fold_3_inst),
				.fold_2_inst(fold_2_inst),
				.fold_1_inst(fold_1_inst),
				.not_valid(not_valid),
				.ex_len_first_inst(ex_len_first_inst),
				.hold_d	(hold_d),
				.iu_shift_d(iu_shift_d[7:0]),
				.accum_len0(accum_len0),
				.accum_len1(accum_len1),
				.accum_len2(accum_len2),
				.accum_len3(accum_len3) );

// Instantiate valid decoder
// This will output four valids. dec_valid (decoder valids) corrseponding
// to four prospective instructions to be folded

valid_dec	valid_dec (.fetch_valid(fetch_valid),
				.accum_len0(accum_len0),
				.accum_len1(accum_len1),
				.accum_len2(accum_len2),
				.ex_len_first_inst(ex_len_first_inst),
				.fetch_len1(fetch_len1),
				.fetch_len2(fetch_len2),
				.fetch_len3(fetch_len3),
				.fetch_len4(fetch_len4),
				.fetch_len5(fetch_len5),
				.fetch_len6(fetch_len6),
				.dec_valid(dec_valid) );
				

// Instantiate folding decoder
//  This wil output folding types, inst_0..3_type of four prospective instructions
// to be folded	

// inst_0_type[0] =  Non Foldable
// inst_0_type[1] =  Local Variable
// inst_0_type[2] =  Operation
// inst_0_type[3] =  Break Group2
// inst_0_type[4] =  Break Group1
// inst_0_type[5] =  Memory Store



fold_dec	fold_dec (.ibuff_0(ibuff_0),
				.ibuff_1(ibuff_1),
				.ibuff_2(ibuff_2),
				.ibuff_3(ibuff_3),
				.ibuff_4(ibuff_4),
				.ibuff_5(ibuff_5),
				.ibuff_6(ibuff_6),
				.accum_len0(accum_len0),
				.accum_len1(accum_len1),
				.accum_len2(accum_len2),
				.type_0(inst_1_type),
				.type_1(inst_2_type),
				.type_2(inst_3_type),
				.type_3(inst_4_type) );
				

// Determine Folding Enable
// Folding is disbaled if:
// 1. iu_psr_fle is 0
// 2. scache_miss  and there's scache access in one or both of RS1 and RS2
// 3. any valid dirty entries in the ibuff

// determine scache miss
// since we dont have time to calculate exact offset and subtract it from lvars and
// then compare it against sc_bottom, we'll use  a littl bit pessimistic approach

comp_gr_32	scache_miss_comp(.in1(lvars),
				.in2(sc_bottom),
				.gr(scache_miss_int) );

// Qualify scache_miss_int with local var accesses in RS1 and RS2
// to generate actual scache_miss signal
assign	scache_miss = scache_miss_int & (lvars_acc_rs1_int | lvars_acc_rs2_int1);

// If there are any valid dirty entries in the top 7 bytes of ibuffer
// donot fold

assign	vld_drty_entries = (	(fetch_valid[0] & fetch_drty[0]) | 
				(fetch_valid[1] & fetch_drty[1]) |
				(fetch_valid[2] & fetch_drty[2]) |
				(fetch_valid[3] & fetch_drty[3]) |
				(fetch_valid[4] & fetch_drty[4]) |
				(fetch_valid[5] & fetch_drty[5]) |
				(fetch_valid[6] & fetch_drty[6]) ) ;

// Optimization: Whenever there are no scache accesses in RS1 and RS2
// Ignore scache hit while folding; This will greatly improve the number
// of instructions being folded

// assign	fold_enable = iu_psr_fle & scache_hit & 
// 			!(vld_drty_entries)  &!squash_fold;

assign	fold_enable = iu_psr_fle & !scache_miss &
 			!(vld_drty_entries)  &!squash_fold;

// Use folding logic to determine how many instructions can be folded
// and what group the folded instructions fall into
// group_1 : LV LV MEM OP
// group_2 : LV LV OP
// group_3 : LV LV BG2
// group_4 : LV OP MEM
// group_5 : LV BG2
// group_6 : LV BG1
// group_7 : LV OP
// group_8 : LV MEM
// group_9 : OP MEM

fold_logic	fold_logic (.F0(inst_1_type),
				.F1(inst_2_type),
				.F2(inst_3_type),
				.F3(inst_4_type),
				.V0(dec_valid[0]),
				.V1(dec_valid[1]),
				.V2(dec_valid[2]),
				.V3(dec_valid[3]),
				.FOE(fold_enable),
				.notvalid(not_valid),
				.fold1(fold_1_inst),
				.fold2(fold_2_inst),
				.fold3(fold_3_inst),
				.fold4(fold_4_inst),
				.gr1(group_1),
				.gr2(group_2),
				.gr3(group_3),
				.gr4(group_4),
				.gr5(group_5),
				.gr6(group_6),
				.gr7(group_7),
				.gr8(group_8),
				.gr9(group_9) );

// Flop the group information

ff_sre	flop_gr_1(.out(group_1_r),
		.din((group_1 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_2(.out(group_2_r),
		.din((group_2 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_3(.out(group_3_r),
		.din((group_3 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_4(.out(group_4_r),
		.din((group_4 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_5(.out(group_5_r),
		.din((group_5 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_6(.out(group_6_r),
		.din((group_6 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_7(.out(group_7_r),
		.din((group_7 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_8(.out(group_8_r),
		.din((group_8 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_gr_9(.out(group_9_r),
		.din((group_9 & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));

assign	fold = (fold_2_inst | fold_3_inst | fold_4_inst);

ff_sre	flop_fold(.out(fold_r),
		.din((fold & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
ff_sre	flop_no_fold(.out(no_fold_r),
		.din((fold_1_inst & !kill_vld_d)),
		.clk(clk),
		.enable(!(hold_r & !kill_vld_d)),
		.reset_l(reset_l));
			
		
// Instantiate the main decoder which will provide offset_selects for
// rs1, rs2, valids for them, etc ...

main_dec	main_dec (.ibuff_0(ibuff_0),
				.ibuff_1(ibuff_1),
				.ibuff_2(ibuff_2),
				.ibuff_3(ibuff_3),
				.ibuff_4(ibuff_4),
				.ibuff_5(ibuff_5),
				.ibuff_6(ibuff_6),
				.fetch_valid(fetch_valid[6:0]),
				.accum_len0(accum_len0),
				.accum_len1(accum_len1),
				.accum_len2(accum_len2),
				.offset_rsd_ctl(offset_rsd_ctl),
				.offset_sel_rs1(offset_sel_rs1),
				.valid_rs1(valid_rs1_int1),
				.mem_op(mem_op_rs1),
				.help_rs1(help_rs1),
				.type(type_rs1),
				.lv_rs1(lv_rs1_int),
				.lvars_acc_rs1(lvars_acc_rs1_int),
				.st_index_op_rs1(st_index_op_rs1),
				.reverse_ops_rs1(reverse_ops_rs1),
				.update_optop(update_optop),
				.offset_sel_rs2(offset_sel_rs2),
				.lv_rs2(lv_rs2_int1),
				.lvars_acc_rs2(lvars_acc_rs2_int1),
				.offset_sel_rsd(offset_sel_rsd) );
				
// Whenever there's no foldable inst in the first spot  make lvars_acc_rs2_int1 
// and lv_rs2_int1 zeroes. This is because in case of combinations like lcmp lload 
// or lcmp iload, we have lvars_acc_rs2_int1 and lv_rs2_int1 are high
// To prevent this we and them !(fold_1_inst);
assign lvars_acc_rs2_int = lvars_acc_rs2_int1 & !fold_1_inst;
assign	lv_rs2_int = lv_rs2_int1 & !fold_1_inst;

// Provide opcode, offset, valids, etc .. for RS1 stage

// Opcode first

// Imp. Note1
// Because of some arch. oversight, incase of groups 
// LV LV OP MEM -> gropu 1
// LV LV OP  -> group 2
// LV LV BG2  -> group 3
// We used to use first LV in RS1 and 2nd one in RS2,
// which is not true. It should be otherway around.
// To incorporate this change we flip i/ps to RS1 and RS2
// for these 3 gropus

assign	swap_rs1_rs2[1] = (group_1 | group_2 | group_3 );
assign	swap_rs1_rs2[0] = !swap_rs1_rs2[1];
mux2_8		mux_opcode_1_rs1(.out(opcode_1_rs1),
				.in0(ibuff_0),
				.in1(rs2_inst_1),
				.sel(swap_rs1_rs2) );

ff_se_8		flop_opcode_1_rs1(.out(opcode_1_rs1_r),
					.din(opcode_1_rs1),
					.clk(clk),
					.enable(!hold_r));

mux2_8		mux_opcode_2_rs1_swap(.out(opcode_2_rs1),
				.in0(ibuff_1),
				.in1(rs2_inst_2),
				.sel(swap_rs1_rs2) );

ff_se_8		flop_opcode_2_rs1(.out(opcode_2_rs1_r),
					.din(opcode_2_rs1),
					.clk(clk),
					.enable(!hold_r));

// Offset now

mux2_8		mux_opcode_2_rs1(.out(offset_1_rs1),
				.in0(offset_1_rs1_int),
				.in1(offset_1_rs2_int),
				.sel(swap_rs1_rs2) );

mux5_8		mux_offset_rs1 (.out(offset_1_rs1_int),
				.in0(8'b00000000),
				.in1(8'b00000001),
				.in2(8'b00000010),
				.in3(8'b00000011),
				.in4(ibuff_1),
				.sel(offset_sel_rs1) );

ff_se_8		flop_offset_1_rs1(.out(offset_1_rs1_r),
					.din(offset_1_rs1),
					.clk(clk),
					.enable(!hold_r));

mux2_8		mux_offset_2_rs2_swap(.out(offset_2_rs1),
				.in0(ibuff_2),
				.in1(rs2_inst_3),
				.sel(swap_rs1_rs2) );

ff_se_8		flop_offset_2_rs1(.out(offset_2_rs1_r),
					.din(offset_2_rs1),
					.clk(clk),
					.enable(!hold_r));

// valid, dup, type, help, etc .. for RS1 stage

// Look at Imp. Note1
// Whenever there's a kill_vld_d signal is there, kill all valids
// Also propogate these valids even when there is hold_r
assign	valid_rs1_int = valid_rs1_int1 & !kill_vld_d;

mux2	mux_valid_rs1 (.out(valid_rs1),
			.in0(valid_rs1_int),
			.in1(valid_rs2_int),
			.sel(swap_rs1_rs2) );

ff_sre	flop_valid_rs1 (.out(valid_rs1_r),
			.din(valid_rs1),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));
			

ff_sre	flop_help_rs1 (.out(help_rs1_r),
			.din((help_rs1 & !kill_vld_d)),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

mux2    mux_lv_rs1 (.out(lv_rs1),
                        .in0(lv_rs1_int),
                        .in1(lv_rs2_int),
                        .sel(swap_rs1_rs2) );
 
ff_sre	flop_lv_rs1 (.out(lv_rs1_r),
			.din((lv_rs1 & !kill_vld_d)),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

// Look at Imp. Note1
mux2    mux_lvacc_rs1 (.out(lvars_acc_rs1),
                        .in0(lvars_acc_rs1_int),
                        .in1(lvars_acc_rs2_int),
                        .sel(swap_rs1_rs2) );
 

ff_sre	flop_lv_acc_rs1 (.out(lvars_acc_rs1_r),
			.din((lvars_acc_rs1 & !kill_vld_d)),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

ff_sre_8	flop_type_rs1 (.out(type_rs1_r),
			.din((type_rs1&{8{!kill_vld_d}})),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

ff_sre		flop_rev_ops (.out(reverse_ops_rs1_r),
			.din(reverse_ops_rs1 & !kill_vld_d),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

ff_sre		flop_st_op (.out(st_index_op_rs1_r),
			.din((st_index_op_rs1 & !kill_vld_d)),
			.clk(clk),
			.enable(!(hold_r & !kill_vld_d)),
			.reset_l(reset_l));

ff_sre		flop_optop (.out(update_optop_r),
			.din((update_optop & !kill_vld_d)),
			.clk(clk),
			.enable(!(hold_r & !kill_vld_d)),
			.reset_l(reset_l));

// Opcode, offset, valid for RS2 stage

// opcode first

// Depending on the length of the first instruction, select the first three
// bytes of the instr. which will go into RS2 

mux4_24		mux_rs2_inst ( .out({rs2_inst_1,rs2_inst_2,rs2_inst_3}),
				.in0(24'b0),
				.in1({ibuff_1,ibuff_2,ibuff_3}),
				.in2({ibuff_2,ibuff_3,ibuff_4}),
				.in3({ibuff_3,ibuff_4,ibuff_5}),
				.sel(accum_len0[3:0]) );

//See note Imp. Note1
mux2_8		mux_opcode_1_rs2(.out(opcode_1_rs2),
				.in0(rs2_inst_1),
				.in1(ibuff_0),
				.sel(swap_rs1_rs2) );

ff_se_8		flop_opcode_1_rs2(.out(opcode_1_rs2_r),
					.din(opcode_1_rs2),
					.clk(clk),
					.enable(!hold_r));

mux2_8		mux_opcode_2_rs2_swap(.out(opcode_2_rs2),
				.in0(rs2_inst_2),
				.in1(ibuff_1),
				.sel(swap_rs1_rs2) );

ff_se_8		flop_opcode_2_rs2(.out(opcode_2_rs2_r),
					.din(opcode_2_rs2),
					.clk(clk),
					.enable(!hold_r));

// Offset now

mux2_8		mux_offset_2_rs2(.out(offset_1_rs2),
				.in0(offset_1_rs2_int),
				.in1(offset_1_rs1_int),
				.sel(swap_rs1_rs2) );

mux5_8		mux_offset_rs2 (.out(offset_1_rs2_int),
				.in0(8'b00000000),
				.in1(8'b00000001),
				.in2(8'b00000010),
				.in3(8'b00000011),
				.in4(rs2_inst_2),
				.sel(offset_sel_rs2) );

ff_se_8		flop_offset_1_rs2(.out(offset_1_rs2_r),
					.din(offset_1_rs2),
					.clk(clk),
					.enable(!hold_r));

mux2_8		mux_opcode_2_rs2(.out(offset_2_rs2),
				.in0(rs2_inst_3),
				.in1(ibuff_2),
				.sel(swap_rs1_rs2) );

ff_se_8		flop_offset_2_rs2(.out(offset_2_rs2_r),
					.din(offset_2_rs2),
					.clk(clk),
					.enable(!hold_r));

// Valid: There's a valid RS2 only for the groups, g1, g2 and g3
// Whenever there's a kill_vld_d signal is there, kill all valids
// Also propogate these valids even when there is hold_r
assign	valid_rs2_int =	(group_1 | group_2 | group_3) & !kill_vld_d ;

// Look at Imp. Note1
mux2    mux_valid_rs2 (.out(valid_rs2),
                        .in0(valid_rs2_int),
                        .in1(valid_rs1_int),
                        .sel(swap_rs1_rs2) );
 


ff_sre   flop_vld_rs2 (.out(valid_rs2_r),
                        .din(valid_rs2),
                        .reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
                        .clk(clk));

mux2    mux_lv_rs2 (.out(lv_rs2),
                        .in0(lv_rs2_int),
                        .in1(lv_rs1_int),
                        .sel(swap_rs1_rs2) );
 
ff_sre	flop_lv_rs2 (.out(lv_rs2_r),
			.din((lv_rs2 & !kill_vld_d)),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));


// Look at Imp. Note1
mux2    mux_lvacc_rs2 (.out(lvars_acc_rs2),
                        .in0(lvars_acc_rs2_int),
                        .in1(lvars_acc_rs1_int),
                        .sel(swap_rs1_rs2) );

ff_sre	flop_lvars_acc_rs2 (.out(lvars_acc_rs2_r),
                        .din((lvars_acc_rs2 & !kill_vld_d)), 
                        .reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
                        .clk(clk));




// Opcode and valid for operation stage

// Depending on Folding groups, op can be either the 1st,2nd or 3rd inst.
// in the group.

// For groups 1..3, op will be the third inst.

assign	op_sel[2] = (group_1 | group_2 | group_3);

// For groups 4..8, op will be the 2nd inst.

assign	op_sel[1] = (group_4 | group_5 | group_6 | group_7 | group_8);

// Select the 1st inst. otherwise

assign	op_sel[0] = !(|op_sel[2:1]);

// opcode_inst2_1 will be opcode's first byte if the op. is 2nd inst and so-on

mux4_24		mux_op_2 (.out({opcode_inst2_1,opcode_inst2_2,opcode_inst2_3}),
				.in0(24'b0),
				.in1({ibuff_1,ibuff_2,ibuff_3}),
				.in2({ibuff_2,ibuff_3,ibuff_4}),
				.in3({ibuff_3,ibuff_4,ibuff_5}),
				.sel(accum_len0[3:0]) );

// opcode_inst3_1 will be opcode's first byte if the op. is 3nd inst and so-on

mux8_24		mux_op_3 (.out({opcode_inst3_1,opcode_inst3_2,opcode_inst3_3}),
				.in0(24'b0),
				.in1({ibuff_1,ibuff_2,ibuff_3}),
				.in2({ibuff_2,ibuff_3,ibuff_4}),
				.in3({ibuff_3,ibuff_4,ibuff_5}),
				.in4({ibuff_4,ibuff_5,ibuff_6}),
				.in5({ibuff_5,ibuff_6,8'b0}),
				.in6({ibuff_6,16'b0}),
				.in7({24'b0}),
				.sel(accum_len1) );


// Now select either the 1st, 2nd or 3rd as op.

mux3_24		mux_op (.out({opcode_1_op,opcode_2_op,opcode_3_op}),
			.in0({ibuff_0,ibuff_1,ibuff_2}),
			.in1({opcode_inst2_1,opcode_inst2_2,opcode_inst2_3}),
			.in2({opcode_inst3_1,opcode_inst3_2,opcode_inst3_3}),
			.sel(op_sel) );

// Whenever there's trap_c, we need to reset the opcode 1 of OP to NOP
// This is because trap_r signal (delayed by one flop wrt trap_c) activates
// the valid_op_r in R-stage and the opcode in R when it goes to E will be
// treated as a genuine one.

ff_sre_8		flop_opcode_1_op (.out(opcode_1_op_r_gen),
					.din(opcode_1_op),
					.clk(clk),
					.enable(!hold_r),
					.reset_l(!iu_trap_c));

// Replicating opcode_1_op_r_gen to improve timing 

assign	opcode_1_op_r_rcu   =	opcode_1_op_r_gen;
assign	opcode_1_op_r_ex    =	opcode_1_op_r_gen;
assign	opcode_1_op_r_fpu   =	opcode_1_op_r_gen;
assign	opcode_1_op_r_ucode =	opcode_1_op_r_gen;

ff_se_8		flop_opcode_2_op (.out(opcode_2_op_r),
					.din(opcode_2_op),
					.clk(clk),
					.enable(!hold_r));

ff_se_8		flop_opcode_3_op (.out(opcode_3_op_r),
					.din(opcode_3_op),
					.enable(!hold_r),
					.clk(clk));

ff_se_8		flop_opcode_4_op (.out(opcode_4_op_r),
					.din(ibuff_3),
					.clk(clk),
					.enable(!hold_r));

ff_se_8		flop_opcode_5_op (.out(opcode_5_op_r),
					.din(ibuff_4),
					.clk(clk),
					.enable(!hold_r));

// If there's a folded instr or even just dispatching 1 instr., vaild for op
// should be high

// Whenever there's a kill_vld_d signal is there, kill all valids
// Also propogate all these valids even in the presence of hold_r
assign	valid_op = dec_valid[0] & !kill_vld_d;

// Replicating valid_op_r to improve timing 

ff_sre	flop_vld_op_rcu (.out(valid_op_r_rcu),
			.din(valid_op),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

ff_sre	flop_vld_op_ucode (.out(valid_op_r_ucode),
			.din(valid_op),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

ff_sre	flop_vld_op_gen (.out(valid_op_r_gen),
			.din(valid_op),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

// valid_op_r_ex,fgu and pipe are not very critical, so we dont use separate flops to
// generate them

assign	valid_op_r_ex	= valid_op_r_gen;
assign	valid_op_r_pipe	= valid_op_r_gen;
assign	valid_op_r_fpu	= valid_op_r_gen;

// Generate offset from PC, where OP is there.
// This is because: For
// LV LV JMP02 X, we need to know the the pc location where JMP02 is there,
// so that the offset (02) acn be added to it to generate the destination address
// In case of no folding, PC of the first inst. is the pc of branch
// Incase of folding 2, use accum_len0 as the offset and so-on

mux3_8		mux_offset_br(.out(offset_pc_br_dec),
				.in0(8'b00000001),
				.in1(accum_len0),
				.in2(accum_len1),
				.sel(op_sel) );

// encode the pc_br into 4-bits

assign	offset_pc_br[2] = (offset_pc_br_dec[4] | offset_pc_br_dec[5] |
			   offset_pc_br_dec[6] | offset_pc_br_dec[7] );
assign	offset_pc_br[1] = (offset_pc_br_dec[2] | offset_pc_br_dec[3] |
			   offset_pc_br_dec[6] | offset_pc_br_dec[7] );
assign	offset_pc_br[0] = (offset_pc_br_dec[1] | offset_pc_br_dec[3] |
			   offset_pc_br_dec[5] | offset_pc_br_dec[7] );

ff_sre_3		flop_offset_br (.out(offset_pc_br_r),
				.din(offset_pc_br),
				.clk(clk),
				.enable(!hold_r),
				.reset_l(reset_l));

// Opcode, offset and valid for RSd stage

// opcode first
// opcode for RSd can be 
// . 4th instr for group_1
// . 3rd instr for group_4
// . 2nd instr for groups 8 & 9
// . 1st otherwise

assign	opcode_sel_rsd[3] = group_1;
assign	opcode_sel_rsd[2] = group_4;
assign	opcode_sel_rsd[1] = (group_8 | group_9);
assign	opcode_sel_rsd[0] = !(|opcode_sel_rsd[3:1]);

mux8_24		mux_op_4 (.out({opcode_inst4_1,opcode_inst4_2,opcode_inst4_3}),
				.in0(24'b0),
				.in1({ibuff_1,ibuff_2,ibuff_3}),
				.in2({ibuff_2,ibuff_3,ibuff_4}),
				.in3({ibuff_3,ibuff_4,ibuff_5}),
				.in4({ibuff_4,ibuff_5,ibuff_6}),
				.in5({ibuff_5,ibuff_6,8'b0}),
				.in6({ibuff_6,16'b0}),
				.in7({24'b0}),
				.sel(accum_len2) );

mux4_24		mux_op_rsd (.out({opcode_1_rsd,opcode_2_rsd,opcode_3_rsd}),
				.in0({ibuff_0,ibuff_1,ibuff_2}),
				.in1({opcode_inst2_1,opcode_inst2_2,opcode_inst2_3}),
				.in2({opcode_inst3_1,opcode_inst3_2,opcode_inst3_3}),
				.in3({opcode_inst4_1,opcode_inst4_2,opcode_inst4_3}),
				.sel(opcode_sel_rsd) );

ff_se_8		flop_opcode_1_rsd (.out(opcode_1_rsd_r),
					.din(opcode_1_rsd),
					.clk(clk),
					.enable(!hold_r));

ff_se_8		flop_opcode_2_rsd (.out(opcode_2_rsd_r),
					.din(opcode_2_rsd),
					.clk(clk),
					.enable(!hold_r));


// Generate offset_rsd_ctl
// This is used to select appropriate offset_sel_rsd
// Essentially this will tell which Instruction should be used
// to derive offset_sel_rsd. The same signal is used to derive
// the 1 byte offset for rsd stage

assign	offset_rsd_ctl[1] = group_8 | group_9;
assign	offset_rsd_ctl[2] = group_4;
assign	offset_rsd_ctl[3] = group_1;
assign	offset_rsd_ctl[0] = !(|offset_rsd_ctl[3:1]);

// valid for RSd

// Whenever there's a mem op in the fisrt inst or if it is any of the following
// groups, valid for rsd should be high

// Whenever there's a kill_vld_d signal is there, kill all valids
// Also propogate these valids even in presence of hold_r
assign	valid_rsd = (mem_op_rs1 | group_1 | group_4 | group_8 | group_9) & !kill_vld_d;

ff_sre	flop_vld_rsd (.out(valid_rsd_r),
			.din(valid_rsd),
			.reset_l(reset_l),
			.enable(!(hold_r & !kill_vld_d)),
			.clk(clk));

// rsd offset logic

// Select the 2nd byte of the appropriate instruction for
// determining the offset

mux4_8		mux_offset_rsd_int(.out(offset_rsd_int),
				.in0(ibuff_1),
				.in1(opcode_inst2_2),
				.in2(opcode_inst3_2),
				.in3(opcode_inst4_2),
				.sel(offset_rsd_ctl) );

mux5_8		mux_offset_rsd(.out(offset_rsd),
				.in0(8'd0),
				.in1(8'd1),
				.in2(8'd2),
				.in3(8'd3),
				.in4(offset_rsd_int),
				.sel(offset_sel_rsd) );
		
ff_se_8		flop_offset_rsd(.out(offset_rsd_r),
				.din(offset_rsd),
				.enable(!hold_r),
				.clk(clk) );

// Whenever there's a dirty bit in the first instruction, assert drty_inst_r

assign	drty_inst_1 = fetch_drty[0];
assign	drty_inst_2 = |(fetch_drty[1:0]);
assign	drty_inst_3 = |(fetch_drty[2:0]);
assign	drty_inst_4 = |(fetch_drty[3:0]);
assign	drty_inst_5 = |(fetch_drty[4:0]);

mux6	mux_drty_inst(.out(drty_inst),
			.in0(1'b0),
			.in1(drty_inst_1),
			.in2(drty_inst_2),
			.in3(drty_inst_3),
			.in4(drty_inst_4),
			.in5(drty_inst_5),
			.sel(ex_len_first_inst) );

ff_sre	flop_drty_inst(.out(drty_inst_r),
			.din((drty_inst & !kill_vld_d)),
			.clk(clk),
			.enable(!(hold_r & !kill_vld_d)),
			.reset_l(reset_l));
				
// Whenever there's putfield2_quick,we need to provide top3 item 
// from scache for RS2 instead of teh default top2

assign	put_field2_quick = (ibuff_0 == 8'd209) & fetch_valid[0] ;

ff_sre	flop_putfield(.out(put_field2_quick_r),
			.din((put_field2_quick & !kill_vld_d)),
			.clk(clk),
			.enable(!(hold_r & !kill_vld_d)),
			.reset_l(reset_l));
				

mj_spare spare1( .clk(clk),
                .reset_l(reset_l));

mj_spare spare2( .clk(clk),
                .reset_l(reset_l));
 


// Misc. Logic
// COSIM SIGNALS
// synopsys translate_off
// Provide number of instructions folded info.  to cosim
mux5_3		mux_inst_fold(.out(instrs_folded),
			.in0(3'd0),
			.in1(3'd1),
			.in2(3'd2),
			.in3(3'd3),
			.in4(3'd4),
			.sel( {fold_4_inst,fold_3_inst,fold_2_inst,
				fold_1_inst,not_valid}) );

ff_sre_3	flop_inst_fold_r(.out(instrs_folded_r),
				.din((instrs_folded & {3{!kill_vld_d}})),
				.clk(clk),
				.reset_l(reset_l),
				.enable(!(hold_r & !kill_vld_d)));

ff_sre_3	flop_inst_fold_e(.out(instrs_folded_e),
				.din(instrs_folded_r),
				.clk(clk),
				.reset_l(reset_l),
				.enable(!hold_e));

ff_sre_3	flop_inst_fold_c(.out(instrs_folded_c),
				.din(instrs_folded_e),
				.clk(clk),
				.reset_l(reset_l),
				.enable(!hold_c));

ff_sr_3		flop_inst_fold_w(.out(instrs_folded_w),
				.din(instrs_folded_c),
				.clk(clk),
				.reset_l(reset_l));

// synopsys translate_on
endmodule
