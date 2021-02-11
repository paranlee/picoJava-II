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

module rcu_ctl (
	
	opcode_1_rs1_r,
	opcode_2_rs1_r,
	valid_rs1_r,
	help_rs1_r,
	type_rs1_r,
	lvars_acc_rs1,
	st_index_op_rs1_r,
	lv_rs1_r,
	reverse_ops_rs1_r,
	update_optop_r,
	ucode_active,
	ucode_dest_we,
	ucode_dest_sel,
	opcode_1_rs2_r,
	opcode_2_rs2_r,
	valid_rs2_r,
	lvars_acc_rs2,
	lv_rs2_r,
	valid_op_r,
	opcode_1_op_r,
	opcode_2_op_r,
	opcode_1_rsd_r,
	opcode_2_rsd_r,
	valid_rsd_r,
	group_1_r,
	group_2_r,
	group_3_r,
	group_4_r,
	group_5_r,
	group_6_r,
	group_7_r,
	group_9_r,
	no_fold_r,
	put_field2_quick_r,
	hold_e,
	hold_c,
	hold_ucode,
	inst_vld,
	sc_miss_rs1_int,
	sc_miss_rs2_int,
	bypass_scache_rs1_e,
	bypass_scache_rs1_c,
	bypass_scache_rs1_w,
	bypass_scache_rs2_e,
	bypass_scache_rs2_c,
	bypass_scache_rs2_w,
	sc_wr_addr_gr_scbot,
	iu_smu_flush_le,
	iu_smu_flush_ge,
	ucode_done,
	iu_trap_r,
	sin,	
	sm,
	clk,
	reset_l,
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
	scache_rd_miss_e,
	optop_incr_sel,
	dest_addr_sel_r,
	dest_addr_sel_e,
	net_optop_sel1,
	net_optop_sel2,
	net_optop_sel,
	optop_offset_sel_r,
	enable_cmp_e_rs1,
        enable_cmp_c_rs1,
        enable_cmp_w_rs1,
	enable_cmp_e_rs2,
        enable_cmp_c_rs2,
        enable_cmp_w_rs2,
	iu_data_we_w,
	gl_reg0_we_w,
	gl_reg1_we_w,
	gl_reg2_we_w,
	gl_reg3_we_w,
	rs1_forward_mux_sel,
	rs2_forward_mux_sel,
	scache_wr_miss_w,
	iu_smu_flush,
	first_cycle,
	second_cycle,
	first_vld_c,
	inst_complete_w,
	so
);

input	[7:0]	opcode_1_rs1_r;		// 1st byte of opcode in RS1 stage
input	[7:0]	opcode_2_rs1_r;		// 2nd byte of opcode in RS1 stage
input		valid_rs1_r;		// Inicates that the opcode in RS1 is valid
input		help_rs1_r;		// Indicates multi-rstage op. in RS1
input	[7:0]	type_rs1_r;		// indicates the type of long op in rs1
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
input		lvars_acc_rs1;		// This signal is asserted for all operations
					// which access scache using lvars reg in RS1
input		st_index_op_rs1_r;	// This indicates that there's a st_*_index op in RS1
input		lv_rs1_r;		// Indicates that there's a pure LV op in RS1
input		reverse_ops_rs1_r;	// Used to fix an Xface proble between FPU and IU
input		update_optop_r;		// priv_optop_update op in RS1
input		ucode_active;		// This signal indicates that ucode want to acess
					// scache
input		ucode_dest_we;		// This signal indicates that ucode wants to write to s$
input		ucode_dest_sel;		// ucode_dest_sel -> 1: Use adder_out_e as the address, else 
					// use ucode_areg0
input	[7:0]	opcode_1_rs2_r;		// 1st byte of opcode in RS2 stage
input	[7:0]	opcode_2_rs2_r;		// 2nd byte of opcode in RS2 stage
input		valid_rs2_r;		// Indicates a valid opcode in RS2 stage
input		lvars_acc_rs2;		// This signal is asserted for all operations
					// wich access scache using lvars reg in RS2
input		lv_rs2_r;		// Indicates that there's a pure LV op in RS2
input		valid_op_r;		// Indicates a valid opcode in OP
input	[7:0]	opcode_1_op_r;		// First byte of OP
input	[7:0]	opcode_2_op_r;		// Second byte of OP
input	[7:0]	opcode_1_rsd_r;		// First byte of RSd
input	[7:0]	opcode_2_rsd_r;		// Second byte of RSd
input		valid_rsd_r;		// Indicates a valid MEM op in rsd + long and dstores
input		group_1_r;		// Indicates a group 1 folding
input		group_2_r;		// Indicates a group 2 folding
input		group_3_r;		// Indicates a group 3 folding
input		group_4_r;		// Indicates a group 4 folding
input		group_5_r;		// Indicates a group 5 folding
input		group_6_r;		// Indicates a group 6 folding
input		group_7_r;		// Indicates a group 7 folding
input		group_9_r;		// Indicates a group 8 folding
input		no_fold_r;		// Indicates no folding
input		put_field2_quick_r;	// Indicates a putfield2_quick operation
input		hold_e;			// Signal from pipeline control to hold e-stage
input		hold_c;			// Signal from pipeline control to hold c-stage
input		hold_ucode;		// ucode hold signal
input	[2:0]	inst_vld;		// [2] -> Valid inst. in W, [1] in C stage and soon
input		sc_miss_rs1_int;	// Compare output of sc_bototm and scache_addr_rs1
input		sc_miss_rs2_int;	// Compare output of sc_bototm and scache_addr_rs2
input          	bypass_scache_rs1_e;    // Bypass data from e-stage to rs1 stage
input          	bypass_scache_rs1_c;    // Bypass data from c-stage to rs1 stage
input          	bypass_scache_rs1_w;    // Bypass data from w-stage to rs1 stage
input          	bypass_scache_rs2_e;    // Bypass data from e-stage to rs2 stage
input          	bypass_scache_rs2_c;    // Bypass data from c-stage to rs2 stage
input          	bypass_scache_rs2_w;    // Bypass data from w-stage to rs2 stage
input          	sc_wr_addr_gr_scbot;    // Indicates that scache write address is greater than sc_bot
input          	iu_smu_flush_le;    	// Indicates that scache write address is less than or eq to sc_bot+8
input          	iu_smu_flush_ge;    	// Indicates that scache write address is gr than or eq to sc_bot+8
input		ucode_done;		// Indicates ucode is done
input		iu_trap_r;		// Trap in R-stage
input		sin;			// RCU Control Scan In Port
input		sm;			// RCU Control Scan Enable Port
input		clk;			// Clock
input		reset_l;			// Reset
output	[3:0]   gl_sel_rs1;             // ctrl signal for selecting one of the gl regs in RS1
output  [5:0]   const_sel_1_rs1;        // following two ctrl signals are used for
output  [6:0]   const_sel_2_rs1;        // for selecting constants or imm. offset in RS1
output  [2:0]   const_gl_sel_rs1;       // ctrl signal to slect one of globals or constants in RS1
output  [4:0]   scache_addr_sel_rs1;    // ctrl signal to determine what address is used for
                                        // accessing scache in RS1
output  [1:0]   final_data_sel_rs1;     // ctrl signal to determine whether we select data
                                        // from scache or from globals/constants as the final
					// rs1_data_e in RS1
output  [3:0]   gl_sel_rs2;             // ctrl signal for selecting one of the gl regs in RS2
output  [5:0]   const_sel_1_rs2;        // following two ctrl signals are used for
output  [6:0]   const_sel_2_rs2;        // for selecting constants or imm. offset in RS2
output  [2:0]   const_gl_sel_rs2;       // ctrl signal to slect one of globals or constants in RS2
output  [4:0]   scache_addr_sel_rs2;    // ctrl signal to determine what address is used for
                                        // accessing scache in RS2
output	[1:0]   final_data_sel_rs2;     // ctrl signal to determine whether we select data
                                        // from scache or from globals/constants as the final rs2_data_e
output		scache_rd_miss_e;	// scache miss in RS1 or RS2 stage
output	[7:0]	optop_incr_sel;		// This will select the appropriate net optop as the dest addr.
output	[2:0]	dest_addr_sel_e;	// this selects the appropriate addr. as the final dest. addr in e
output	[2:0]	dest_addr_sel_r;	// this selects the appropriate addr. as the final dest. addr in r
output	[4:0]	net_optop_sel1;		// The following three signals are used to select the appr.
output	[3:0]	net_optop_sel2;		// optop in rcu_dpath
output	[1:0]	net_optop_sel;
output	[5:0]	optop_offset_sel_r;	// This will select app. inc/dec in optop 
output           enable_cmp_e_rs1;    	// Only incase of writes to dest, "d" and read to loc. "d" in e,
                                        // we should enable the bypassing comparison in e for RS1
output           enable_cmp_c_rs1;     	// Only incase of writes to dest, "d" and read to loc. "d" in e,
                                       	// we should enable the bypassing comparison in c for RS1
output           enable_cmp_w_rs1;     	// Only incase of writes to dest, "d" and read to loc. "d" in e,
                                        // we should enable the bypassing comparison in w for RS1
output           enable_cmp_e_rs2;    	// Only incase of writes to dest, "d" and read to loc. "d" in e,
                                        // we should enable the bypassing comparison in e for RS2
output           enable_cmp_c_rs2;     	// Only incase of writes to dest, "d" and read to loc. "d" in e,
                                       	// we should enable the bypassing comparison in c for RS2
output           enable_cmp_w_rs2;     	// Only incase of writes to dest, "d" and read to loc. "d" in e,
                                        // we should enable the bypassing comparison in w for RS2
output		iu_data_we_w;		// write enable signal to write the data onto scache
output		gl_reg0_we_w;		// Write Enable for Global Reg0 
output		gl_reg1_we_w;		// Write Enable for Global Reg1 
output		gl_reg2_we_w;		// Write Enable for Global Reg2 
output		gl_reg3_we_w;		// Write Enable for Global Reg3 
output	[3:0]	rs1_forward_mux_sel;	// 3-> forward from W, 2 from C and so-on 
output	[3:0]	rs2_forward_mux_sel;	// 3-> forward from W, 2 from C and so-on 
output		scache_wr_miss_w;	// Indicates that there's a scache write miss 
output		iu_smu_flush;		// Flush the stores/loads in the dribbler pipeline
output		first_cycle;		// First cycle of a multi-rstage op
output		second_cycle;		// Second cycle of a multi-rstage op
output		first_vld_c;		// For appr. holding of pipe for fpu ops
output		inst_complete_w;	// This signal indicates that instr. is complete (in w-stage)
output		so;			// RCU Control Scan Out Port

wire	[1:0]	mul_cyc_state;
wire	[1:0]	nxt_mul_cyc_state;
wire	[3:0]	gl_reg_id_r;
wire	[3:0]	gl_reg_id_e;
wire	[3:0]	gl_reg_id_c;
wire	[3:0]	gl_reg_id_w;
wire	[3:0]	gl_reg_id_rs1;
wire	[3:0]	gl_reg_id_rs2;
wire		act_bypass_scache_rs2_e;
wire		ext_opcode_rsd;
wire		gl_reg_we_r;
wire		gl_reg_we_e;
wire		gl_reg_we_e_int;
wire		gl_reg_we_c_int;
wire		gl_reg_we_w_int;
wire		write_global0;
wire		write_global1;
wire		write_global2;
wire		write_global3;
wire		ucode_done_c;
wire		ucode_done_w;
wire		scache_wr_miss_w_int;
wire		iinc_rs1;
wire		scache_wr_miss_c;
wire		first_cycle_e;
wire		first_cycle_c;
wire		first_cycle_w;
wire		gl_reg_rd_rs1;
wire		gl_reg_rd_rs2;
wire		scache_access_rs1;
wire		scache_access_rs2;
wire		bypass_hit_rs1_r;
wire		bypass_hit_rs2_r;
wire		bypass_data_rs1_estage_r;
wire		bypass_data_rs1_cstage_r;
wire		bypass_data_rs1_wstage_r;
wire		bypass_data_rs2_estage_r;
wire		bypass_data_rs2_cstage_r;
wire		bypass_data_rs2_wstage_r;
wire		bypass_gl_reg_rs1_e;
wire		bypass_gl_reg_rs1_c;
wire		bypass_gl_reg_rs1_w;
wire		bypass_gl_reg_rs2_e;
wire		bypass_gl_reg_rs2_c;
wire		bypass_gl_reg_rs2_w;
wire		nobypass_rs1_r;
wire		nobypass_rs2_r;
wire		gl_reg_we_c;
wire		gl_reg_we_w;
wire		sc_miss_rs1_int;
wire		iu_data_we_int;
wire		iu_data_we_r;
wire		iu_data_we_e_int;
wire		iu_data_we_e_int1;
wire		iu_data_we_e;
wire		iu_data_we_c_int;
wire		iu_data_we_c;
wire		iu_data_we_w_int;
wire		sc_miss_rs2_int;
wire		sc_miss_rs1;
wire		act_sc_miss_rs1;
wire		sc_miss_rs2;
wire		act_sc_miss_rs2;
wire		aconst_null_rs1;
wire		iconst_m1_rs1;
wire		iconst_0_rs1;
wire		iconst_1_rs1;
wire		iconst_2_rs1;
wire		iconst_3_rs1;
wire		iconst_4_rs1;
wire		iconst_5_rs1;
wire		fconst_0_rs1;
wire		fconst_1_rs1;
wire		fconst_2_rs1;
wire		lconst_0_rs1;
wire		lconst_1_rs1;
wire		dconst_0_rs1;
wire		dconst_1_rs1;
wire		sipush_rs1;
wire		bipush_rs1;
wire		read_gl0_rs1;
wire		read_gl1_rs1;
wire		read_gl2_rs1;
wire		read_gl3_rs1;
wire		aconst_null_rs2;
wire		iconst_m1_rs2;
wire		iconst_0_rs2;
wire		iconst_1_rs2;
wire		iconst_2_rs2;
wire		iconst_3_rs2;
wire		iconst_4_rs2;
wire		iconst_5_rs2;
wire		fconst_0_rs2;
wire		fconst_1_rs2;
wire		fconst_2_rs2;
wire		lconst_0_rs2;
wire		lconst_1_rs2;
wire		dconst_0_rs2;
wire		dconst_1_rs2;
wire		sipush_rs2;
wire		bipush_rs2;
wire		read_gl0_rs2;
wire		read_gl1_rs2;
wire		read_gl2_rs2;
wire		read_gl3_rs2;

//***** BEGIN: RS1 section of the control ******//

// We need to qualify sc_miss_rs1_int with ucode_active and
// lvars_acc_rs1 signal to generate the actual miss signal

// Also if there's  a bypass hit, we should not generate any
// scache read miss signal

assign	sc_miss_rs1 = sc_miss_rs1_int & (ucode_active | lvars_acc_rs1)
			& !(bypass_hit_rs1_r); 

// Added to improve timing on scache read miss path 

// hold ucode is used to fix a problem 

assign	act_sc_miss_rs1 = (sc_miss_rs1 & (!hold_e | ucode_active&!hold_ucode));

// ff_sr           flop_scache_hit_rs1(.out(sc_miss_rs1_e),
//                                 .din((sc_miss_rs1 & (!hold_e | ucode_active))),
//                                 .clk(clk),
// 				.reset_l(reset_l) );

// Generate scache address select signals for RS1
// Whenever there's "iinc" or "ret" or "ld_*_index" or "st_*_index"   in op, 
// use lvars - offset to access scache

// In the second cycle of long or double loads, select lvars-offset-4
assign	scache_addr_sel_rs1[4] = !(ucode_active) & type_rs1_r[0] & second_cycle;

// For all other lvars access use lvars-offset
assign	scache_addr_sel_rs1[3] = !(ucode_active) & (lvars_acc_rs1) & 
				!(type_rs1_r[0] & second_cycle);

// Whenever ucode_active is high use ucode_addr_s
assign	scache_addr_sel_rs1[2] = ucode_active;

// Whenever we want to access optop+2 use this signal
assign	scache_addr_sel_rs1[1] = !ucode_active & (

		(type_rs1_r[1] & first_cycle) |	// long or double st and 1st cycle
		(type_rs1_r[2] & first_cycle) | // long add, and, sub, or, xor or
						// neg operation and 1st cycle
		(type_rs1_r[3] & second_cycle)|	// double add,sub,rem.mul,div or
						// compare operation and 2nd cycle
		(type_rs1_r[4] & second_cycle)| // long left shift  and 2nd cycle
		(type_rs1_r[5] & second_cycle)| // long right shift and 2nd cycle
		(type_rs1_r[7] & second_cycle)|	// long compare and 2nd cycle 
		(reverse_ops_rs1_r) 	      |	// For d2i,d2l,d2f,l2f,l2d
		(update_optop_r & second_cycle) // priv_update_optop needs oplim
						// in the second cycle
		);

// Otherwise access Top Of Stack
assign	scache_addr_sel_rs1[0] = !(|scache_addr_sel_rs1[4:1]);

// Decode the opcode in RS1

decode_opcode	decode_opcode_rs1(.opcode({opcode_1_rs1_r,opcode_2_rs1_r}),
				.valid(valid_rs1_r),
				.aconst_null(aconst_null_rs1),
				.iconst_m1(iconst_m1_rs1),
        			.iconst_0(iconst_0_rs1),
			        .iconst_1(iconst_1_rs1),
			        .iconst_2(iconst_2_rs1),
			        .iconst_3(iconst_3_rs1),
			        .iconst_4(iconst_4_rs1),
			        .iconst_5(iconst_5_rs1),
			        .lconst_0(lconst_0_rs1),
			        .lconst_1(lconst_1_rs1),
			        .fconst_0(fconst_0_rs1),
			        .fconst_1(fconst_1_rs1),
			        .fconst_2(fconst_2_rs1),
			        .dconst_0(dconst_0_rs1),
 			      	.dconst_1(dconst_1_rs1),
			        .bipush(bipush_rs1),
			        .sipush(sipush_rs1),
			        .read_gl0(read_gl0_rs1),
			        .read_gl1(read_gl1_rs1),
			        .read_gl2(read_gl2_rs1),
			        .read_gl3(read_gl3_rs1)
				);

// Generate controls for accessing appropriate global register in RS1

assign	gl_sel_rs1[3] = read_gl3_rs1;
assign	gl_sel_rs1[2] = read_gl2_rs1;
assign	gl_sel_rs1[1] = read_gl1_rs1;
assign	gl_sel_rs1[0] = !(|gl_sel_rs1[3:1]);


// Generate controls for accessing appropriate constants/offset in RS1

assign	const_sel_1_rs1[5] = iconst_4_rs1;
assign	const_sel_1_rs1[4] = iconst_3_rs1;
assign	const_sel_1_rs1[3] = iconst_2_rs1;
assign	const_sel_1_rs1[2] = iconst_1_rs1 | (lconst_1_rs1 & first_cycle) ;
assign	const_sel_1_rs1[1] = aconst_null_rs1 | iconst_0_rs1 | 
			     (lconst_1_rs1 & second_cycle) | (lconst_0_rs1);
assign	const_sel_1_rs1[0] = !(|const_sel_1_rs1[5:1]);

assign	const_sel_2_rs1[6] = sipush_rs1;
assign	const_sel_2_rs1[5] = bipush_rs1;
assign	const_sel_2_rs1[4] = fconst_2_rs1;
assign	const_sel_2_rs1[3] = dconst_1_rs1 & second_cycle;
assign	const_sel_2_rs1[2] = fconst_1_rs1;
assign	const_sel_2_rs1[1] = fconst_0_rs1 | (dconst_1_rs1 & first_cycle) |
					(dconst_0_rs1);
assign	const_sel_2_rs1[0] = !(|const_sel_2_rs1[6:1]);

// Generate controls for accessing either global regs/constants in RS1

assign	const_gl_sel_rs1[0] =  read_gl3_rs1 | read_gl2_rs1 | read_gl1_rs1 |
			       read_gl0_rs1;
assign	const_gl_sel_rs1[1] =  iconst_m1_rs1 | iconst_0_rs1 | aconst_null_rs1 |
			       iconst_1_rs1 | iconst_2_rs1 | iconst_3_rs1 | 
			       iconst_4_rs1 | lconst_0_rs1 | lconst_1_rs1;
assign	const_gl_sel_rs1[2] =  !(|const_gl_sel_rs1[1:0]);

// This signal is used for Global Reg, bypassing
assign	gl_reg_rd_rs1 = const_gl_sel_rs1[0];

// Generate controls for accessing either scache data/globaland constants in RS1
// Whenever ucode wants to access data, it should be given priority

assign	final_data_sel_rs1[0] = ( iconst_m1_rs1 | iconst_0_rs1 | iconst_1_rs1 |
				iconst_2_rs1  | iconst_3_rs1 | iconst_4_rs1 | 
				iconst_5_rs1  | fconst_0_rs1 | fconst_1_rs1 | 
				fconst_2_rs1  | dconst_0_rs1 | dconst_1_rs1 | 
				lconst_0_rs1  | lconst_1_rs1 | sipush_rs1   | 
				bipush_rs1    | read_gl0_rs1 | read_gl1_rs1 | 
				read_gl2_rs1  | read_gl3_rs1 | aconst_null_rs1) 
				& !ucode_active;

assign	final_data_sel_rs1[1] = !final_data_sel_rs1[0];

// This signal is used for Stcak Cache Access Bypass
assign	scache_access_rs1 = final_data_sel_rs1[1];

//***** END: RS1 section of the control *****//

//***** BEGIN: RS2 section of the control *****//

// We need to qualify sc_miss_rs2_int with
// lvars_acc_rs2 signal to generate the actual miss signal
// Also if there's  a bypass hit, we should not generate any
// scache read miss signal

assign	sc_miss_rs2 = (sc_miss_rs2_int &  lvars_acc_rs2) 
			& !(bypass_hit_rs2_r); 

// Added to improve timing on read scache miss signal 

// hold ucode is used to fix a problem 

assign	act_sc_miss_rs2 = (sc_miss_rs2 & !(hold_e | ucode_active&!hold_ucode) );

ff_sr           flop_scache_hit(.out(scache_rd_miss_e),
                                .din((act_sc_miss_rs1 | act_sc_miss_rs2)),
                                .clk(clk),
				.reset_l(reset_l) );

// Whenever there's a stack cache miss in either RS1 or RS2 stage
// generate a stck cache read miss. Also qualify it with valid
// inst. in e - Removed this to improve timing on read scache miss 

// assign	scache_rd_miss_e =  (sc_miss_rs1_e | sc_miss_rs2_e) & inst_vld[0];

// Generate scache address select signals for RS1
// Use this signal to access scache using lvars
assign	scache_addr_sel_rs2[4] = lvars_acc_rs2 ;

// Use this signal to access scache at location optop+4
assign	scache_addr_sel_rs2[3] =  

		(type_rs1_r[2] & first_cycle) |	// lond add, and, sub, or, xor or
						// neg operation and 1st cycle
		(type_rs1_r[3] & second_cycle)|	// double add,sub,rem,mul,div or
						// compare operation and 2nd cycle
		(type_rs1_r[7] & second_cycle); // long compare and 2nd cycle

//Use this signal to access scache at location optop+3
assign	scache_addr_sel_rs2[2] =

		(type_rs1_r[2] & second_cycle) | // lond add, and, sub, or, xor or
                                                // neg operation and 2nd cycle
		(type_rs1_r[3] & first_cycle)| 	// double add,sub,rem,mul,div or
                                                // compare operation and 1st cycle
		(type_rs1_r[4]) |		// long left shift op 
		(type_rs1_r[5] & second_cycle) |// long right shift and 2nd cycle
		(type_rs1_r[7] & first_cycle)  |// long compares and 1st cycle	
		put_field2_quick_r;		// putfield2_quick

// If there's an LV in RS1 and no LV in RS2 access Top Of Stack
// Also, whenever there are st_*_index operations in RS1 use RS2 to access
// TOS not NTOS
assign	scache_addr_sel_rs2[1] = (lv_rs1_r & !lv_rs2_r | st_index_op_rs1_r |
					reverse_ops_rs1_r);  // For d2i,d2l,d2f,l2f,l2d

//Otherwise access Next Top Of Stack
assign	scache_addr_sel_rs2[0] = !(|scache_addr_sel_rs2[4:1]);

//Decode the opcode in RS2
decode_opcode   decode_opcode_rs2(.opcode({opcode_1_rs2_r,opcode_2_rs2_r}),
                                .valid(valid_rs2_r),
				.aconst_null(aconst_null_rs2),
                                .iconst_m1(iconst_m1_rs2),
                                .iconst_0(iconst_0_rs2),
                                .iconst_1(iconst_1_rs2),
                                .iconst_2(iconst_2_rs2),
                                .iconst_3(iconst_3_rs2),
                                .iconst_4(iconst_4_rs2),
                                .iconst_5(iconst_5_rs2),
                                .lconst_0(lconst_0_rs2),
                                .lconst_1(lconst_1_rs2),
                                .fconst_0(fconst_0_rs2),
                                .fconst_1(fconst_1_rs2),
                                .fconst_2(fconst_2_rs2),
                                .dconst_0(dconst_0_rs2),
                                .dconst_1(dconst_1_rs2),
                                .bipush(bipush_rs2),
                                .sipush(sipush_rs2),
                                .read_gl0(read_gl0_rs2),
                                .read_gl1(read_gl1_rs2),
                                .read_gl2(read_gl2_rs2),
                                .read_gl3(read_gl3_rs2)
                                );
 
// Generate controls for accessing appropriate global register in RS2
 
assign  gl_sel_rs2[3] = read_gl3_rs2;
assign  gl_sel_rs2[2] = read_gl2_rs2;
assign  gl_sel_rs2[1] = read_gl1_rs2;
assign  gl_sel_rs2[0] = !(|gl_sel_rs2[3:1]);

// Generate controls for accessing appropriate constants/offset in RS2
 
assign  const_sel_1_rs2[5] = iconst_4_rs2;
assign  const_sel_1_rs2[4] = iconst_3_rs2;
assign  const_sel_1_rs2[3] = iconst_2_rs2;
assign  const_sel_1_rs2[2] = iconst_1_rs2; 
assign  const_sel_1_rs2[1] = iconst_0_rs2 | aconst_null_rs2;
assign  const_sel_1_rs2[0] = !(|const_sel_1_rs2[5:1]);
 
// Whenver there's an iinc in RS1 we need to sign extend
// offset_2_rs1_r and shove it thru RS2
// For iinc, valid_rs1 is not high. Hence we cannot determine
// it from opcode_1_rs1_r and valid_rs1_r
assign	iinc_rs1 = (opcode_1_op_r == 8'd132) & valid_op_r;
assign  const_sel_2_rs2[6] = iinc_rs1;
assign  const_sel_2_rs2[5] = sipush_rs2;
assign  const_sel_2_rs2[4] = bipush_rs2;
assign  const_sel_2_rs2[3] = fconst_2_rs2;
assign  const_sel_2_rs2[2] = fconst_1_rs2;
assign  const_sel_2_rs2[1] = fconst_0_rs2;
assign  const_sel_2_rs2[0] = !(|const_sel_2_rs2[6:1]);
 
// Generate controls for accessing either global regs/constants in RS2
 
assign  const_gl_sel_rs2[0] =  read_gl3_rs2 | read_gl2_rs2 | read_gl1_rs2 |
                               read_gl0_rs2;
assign  const_gl_sel_rs2[1] =  iconst_m1_rs2 | aconst_null_rs2 | iconst_0_rs2 | 
			       iconst_1_rs2 | iconst_2_rs2 | iconst_3_rs2 | 
			       iconst_4_rs2;
assign  const_gl_sel_rs2[2] =  !(|const_gl_sel_rs2[1:0]);

// This signal is used for Global Reg, bypassing
assign	gl_reg_rd_rs2 = const_gl_sel_rs2[0];

// Generate controls for accessing either scache data/globaland constants in RS1
 
assign  final_data_sel_rs2[0] = iconst_m1_rs2 | iconst_0_rs2 | iconst_1_rs2 |
                                iconst_2_rs2  | iconst_3_rs2 | iconst_4_rs2 |
                                iconst_5_rs2  | fconst_0_rs2 | fconst_1_rs2 |
                                fconst_2_rs2  | sipush_rs2   | bipush_rs2   | 
				read_gl0_rs2 | read_gl1_rs2  | read_gl2_rs2 | 
				read_gl3_rs2 | aconst_null_rs2 | iinc_rs1;
 
assign	final_data_sel_rs2[1] = !(final_data_sel_rs2[0]);

// This signal is used for Stcak Cache Access Bypass
assign	scache_access_rs2 = final_data_sel_rs2[1];

 
//***** END: RS2 section of the control *****//

//***** BEGIN: RSd section of the control ******//

// Instantiate a decoder which will decode the offset which need be added to optop to
// generate the destination address
 
dest_decoder    dest_dec(.opcode({opcode_1_op_r,opcode_2_op_r}),
                        .first_cyc(first_cycle),
                        .second_cyc(second_cycle),
                        .valid(valid_op_r),
			.group_2_r(group_2_r),
			.group_3_r(group_3_r),
			.group_5_r(group_5_r),
			.group_6_r(group_6_r),
			.group_7_r(group_7_r),
                        .optop_incr_sel(optop_incr_sel),
			.dest_we(iu_data_we_int) );

// Now whenver there's a valid_rsd or iinc, select lvars - offset as the destination
// address, otherwise select optop + offset

// Whenever, ucode wants to write to stack and ucode_dest_sel is 1,
// select adder_out_e as the dest address
assign	dest_addr_sel_e[2] =	ucode_dest_we & ucode_dest_sel; 

// Whenever, ucode wants to write to stack and ucode_dest_sel is 0,
// select ucode_areg0 as the dest address
assign	dest_addr_sel_e[1] =	ucode_dest_we & !ucode_dest_sel; 

// In all other cases select dest_addr_e_int

assign	dest_addr_sel_e[0] =	!ucode_dest_we;


// Whenever there's a long or double store, select lvars - offset - 4 in the
// second cycle 
assign	dest_addr_sel_r[1] =  valid_rsd_r & second_cycle;

// otherwise if there's a valid_rsd  select lvars - offset
assign	dest_addr_sel_r[2] = (valid_rsd_r & !second_cycle);

// by default select optop + offset
assign	dest_addr_sel_r[0] = !(|dest_addr_sel_r[2:1]);


optop_decoder	optop_dec(.opcode({opcode_1_op_r,opcode_2_op_r}),
			.valid(valid_op_r),
			.second_cyc(second_cycle),
			.group_3_r(group_3_r),
			.group_5_r(group_5_r),
			.group_6_r(group_6_r),
			.net_optop_sel1(net_optop_sel1),
			.net_optop_sel2(net_optop_sel2),
			.net_optop_sel(net_optop_sel) );

// Whenever there's
// . group_1_r or group_8_r, net inc. in optop is 0
// . group_4_r, net inc. in optop is 1
// . group_9_r, net inc. in optop is 2
// . group_2_r, net inc. in optop is -1
// For all the other groups and in case of just  one instr. issue,
// we have to use the optop_offset_int generated by decoding opcode in OP stage

// Whenever there's a trap in R-stage, we should decrement the optop by 4 entries
// This will save ucode 2 cycles. If valid_op_r is not used in the following 
// equations, then there may be two signals going high at the same time
assign 	optop_offset_sel_r[5] =  iu_trap_r;
assign 	optop_offset_sel_r[4] =  group_2_r & valid_op_r;
assign 	optop_offset_sel_r[3] =  group_4_r & valid_op_r;
assign 	optop_offset_sel_r[2] =  group_9_r & valid_op_r;
assign 	optop_offset_sel_r[1] =  (group_3_r | group_5_r | 
			      group_6_r | no_fold_r) & valid_op_r ;

assign	optop_offset_sel_r[0] = !(|optop_offset_sel_r[5:1]);

// Propogate iu_data_we_r along the pipe

// Whenever there's a valid_rsd (Except for the global writes)
// or whenever there's an operation in OP and no global writes in 
// Rsd, there would be a write enable onto scache

assign	iu_data_we_r = (iu_data_we_int | valid_rsd_r) & 
			 !(write_global0 | write_global1 |
					 write_global2 | write_global3);

ff_sre		flop_data_we_e(.out(iu_data_we_e_int),
				.din(iu_data_we_r),
				.reset_l(reset_l),
				.clk(clk),
				.enable(!hold_e));

// iu_data_we enable is either of iu data we or ucode data we

assign	iu_data_we_e_int1 = (iu_data_we_e_int | ucode_dest_we );

// Qualify iu_data_we_e_int1 with inst_vld[0] to generate
// iu_data_we_e
assign	iu_data_we_e = iu_data_we_e_int1 & inst_vld[0];
ff_sre		flop_data_we_c(.out(iu_data_we_c_int),
				.din(iu_data_we_e &inst_vld[0]),
				.reset_l(reset_l),
				.clk(clk),
				.enable(!hold_c));

// Qualify iu_data_we_c_int with inst_vld[1] to generate
// iu_data_we_c
assign	iu_data_we_c = iu_data_we_c_int & inst_vld[1];

// Since we do not hold w-stage, "AND" iu_data_we_c with !hold_c
ff_sr		flop_data_we_w(.out(iu_data_we_w_int),
				.din(iu_data_we_c &!hold_c),
				.reset_l(reset_l),
				.clk(clk));
// Qualify iu_data_we_w_int with inst_vld[2] to generate
// iu_data_we_w
assign	iu_data_we_w = iu_data_we_w_int & inst_vld[2];

// if scache write address is greater than sc_bot or
// if it is less than or equal to optop and 
// if there's a write enable in c-stage and it there's no
// hold in c-stage, generate a iu_sc_wr_miss

assign	scache_wr_miss_c = (sc_wr_addr_gr_scbot) &
			iu_data_we_c & !hold_c;

ff_sr	flop_scache_wr_miss(.out(scache_wr_miss_w_int),
			.din(scache_wr_miss_c),
			.clk(clk),
			.reset_l(reset_l));

assign	scache_wr_miss_w = scache_wr_miss_w_int & inst_vld[2];

// Whenever sc_bot-8 <= sc_wr_addr_c <= sc_bot+8 and there's a we signal
// to scache, assert iu_smu_flush signal
assign	iu_smu_flush	= (iu_smu_flush_le & iu_smu_flush_ge) & iu_data_we_c;
			

//***** BEGIN: Global Reg. section of the control ******//

// Propogate write enables to global registers and reg. IDs along the pipe

// Generate write enables for global registers

assign	ext_opcode_rsd	= (opcode_1_rsd_r == 8'd255)& valid_rsd_r;

assign	write_global0 = ext_opcode_rsd & (opcode_2_rsd_r == 8'd122);
assign	write_global1 = ext_opcode_rsd & (opcode_2_rsd_r == 8'd123);
assign	write_global2 = ext_opcode_rsd & (opcode_2_rsd_r == 8'd124);
assign	write_global3 = ext_opcode_rsd & (opcode_2_rsd_r == 8'd125);

assign	gl_reg_id_r[0] = write_global0;
assign	gl_reg_id_r[1] = write_global1;
assign	gl_reg_id_r[2] = write_global2;
assign	gl_reg_id_r[3] = write_global3;
assign	gl_reg_we_r = write_global0 | write_global1 | 
			write_global2 | write_global3;

ff_sre		flop_global_we_e(.out(gl_reg_we_e_int),
				.din(gl_reg_we_r),
				.clk(clk),
				.enable(!hold_e),
				.reset_l(reset_l));

assign		gl_reg_we_e = gl_reg_we_e_int & inst_vld[0];

ff_sre		flop_global_we_c(.out(gl_reg_we_c_int),
				.din(gl_reg_we_e),
				.clk(clk),
				.enable(!hold_c),
				.reset_l(reset_l));

assign		gl_reg_we_c = gl_reg_we_c_int & inst_vld[1];

// Since we donot hold w-stage, we have to "AND" gl_reg_we_c with
// !hold_c to generate gl_reg_we_w

ff_sr		flop_global_we_w(.out(gl_reg_we_w_int),
				.din(gl_reg_we_c &!hold_c),
				.clk(clk),
				.reset_l(reset_l));

assign		gl_reg_we_w = gl_reg_we_w_int & inst_vld[2];

ff_se_4		flop_global_reg_e(.out(gl_reg_id_e),
				.din(gl_reg_id_r),
				.clk(clk),
				.enable(!hold_e));
				
ff_se_4		flop_global_reg_c(.out(gl_reg_id_c),
				.din(gl_reg_id_e),
				.clk(clk),
				.enable(!hold_c));
				
ff_s_4		flop_global_reg_w(.out(gl_reg_id_w),
				.din(gl_reg_id_c),
				.clk(clk));

// Generate write enables to  individual registers

assign	gl_reg0_we_w = gl_reg_we_w & gl_reg_id_w[0];
assign	gl_reg1_we_w = gl_reg_we_w & gl_reg_id_w[1];
assign	gl_reg2_we_w = gl_reg_we_w & gl_reg_id_w[2];
assign	gl_reg3_we_w = gl_reg_we_w & gl_reg_id_w[3];

// Generate bypass controls for Global Register reads in RS1

assign	gl_reg_id_rs1 = {read_gl3_rs1,read_gl2_rs1,read_gl1_rs1,read_gl0_rs1};

// Enable the comparision only if there are global reg. reads in RS1 and 
// writes to them in the  app. stages 
cmp_we_4	comp_bypass_reg_rs1_e(.out(bypass_gl_reg_rs1_e),
				.in1(gl_reg_id_rs1),
				.in2(gl_reg_id_e),
				.enable((gl_reg_we_e & gl_reg_rd_rs1)) );
				
cmp_we_4	comp_bypass_reg_rs1_c(.out(bypass_gl_reg_rs1_c),
				.in1(gl_reg_id_rs1),
				.in2(gl_reg_id_c),
				.enable((gl_reg_we_c & gl_reg_rd_rs1)) );
				
cmp_we_4	comp_bypass_reg_rs1_w(.out(bypass_gl_reg_rs1_w),
				.in1(gl_reg_id_rs1),
				.in2(gl_reg_id_w),
				.enable((gl_reg_we_w & gl_reg_rd_rs1)) );

// Incase of multiple matches for bypassing, use a priprity encoder to resolve the
// contention

// bypass_gl_reg_rs1[0] = bypass data from c-stage
// bypass_gl_reg_rs1[1] = bypass data from w-stage
// bypass_gl_reg_rs1[2] = bypass data from w+1-stage

// Removed the priority Encoder. bypass signals are used as mux selects in RS1 and
// RS2 and these mux selects already go througha priority encoder. This improves
// timing on byapss as well as RS1 and RS2 paths 

// pri_encod_3	pri_encod_bypass_reg_rs1(.out(bypass_gl_reg_rs1),
// 				.in0(bypass_gl_reg_rs1_e),
// 				.in1(bypass_gl_reg_rs1_c),
// 				.in2(bypass_gl_reg_rs1_w) );
				
// These signals will see if there are writes to scache and reads to scache to
// determine bypassing for RS1
assign	enable_cmp_e_rs1 = iu_data_we_e & scache_access_rs1;
assign	enable_cmp_c_rs1 = iu_data_we_c & scache_access_rs1;
assign	enable_cmp_w_rs1 = iu_data_we_w & scache_access_rs1;

// Generate bypass controls for Global Register reads in RS2

assign	gl_reg_id_rs2 = {read_gl3_rs2,read_gl2_rs2,read_gl1_rs2,read_gl0_rs2};

// Enable the comparision only if there are global reg. reads in RS1 and 
// writes to them in the  app. stages 
cmp_we_4	comp_bypass_reg_rs2_e(.out(bypass_gl_reg_rs2_e),
				.in1(gl_reg_id_rs2),
				.in2(gl_reg_id_e),
				.enable((gl_reg_we_e & gl_reg_rd_rs2)) );
				
cmp_we_4	comp_bypass_reg_rs2_c(.out(bypass_gl_reg_rs2_c),
				.in1(gl_reg_id_rs2),
				.in2(gl_reg_id_c),
				.enable((gl_reg_we_c & gl_reg_rd_rs2)) );
				
cmp_we_4	comp_bypass_reg_rs2_w(.out(bypass_gl_reg_rs2_w),
				.in1(gl_reg_id_rs2),
				.in2(gl_reg_id_w),
				.enable((gl_reg_we_w & gl_reg_rd_rs2)) );
// Incase of multiple matches for bypassing, use a priprity encoder to resolve the
// contention

// bypass_gl_reg_rs2[0] = bypass data from c-stage
// bypass_gl_reg_rs2[1] = bypass data from w-stage
// bypass_gl_reg_rs2[2] = bypass data from w+1-stage

// Removed the priority Encoder. bypass signals are used as mux selects in RS1 and
// RS2 and these mux selects already go througha priority encoder. This improves
// timing on byapss as well as RS1 and RS2 paths 

// pri_encod_3	pri_encod_bypass_reg_rs2(.out(bypass_gl_reg_rs2),
// 				.in0(bypass_gl_reg_rs2_e),
// 				.in1(bypass_gl_reg_rs2_c),
// 				.in2(bypass_gl_reg_rs2_w) );

// Bypass logic for stack operands in RS1
// Qualify the comparision with 
// . (ucode_active | lv_acc_rs1) -> This means the address scache_addr_rs1 
//				    is a valid one and
// . iu_data_we			-> This means dest_addr_e used is a valid one

// These signals will see if there are writes to scache and reads to scache to
// determine bypassing for RS2
assign	enable_cmp_e_rs2 = iu_data_we_e & scache_access_rs2;
assign	enable_cmp_c_rs2 = iu_data_we_c & scache_access_rs2;
assign	enable_cmp_w_rs2 = iu_data_we_w & scache_access_rs2;

// Incase of multiple matches for bypassing, use a priprity encoder to resolve the
// contention

// bypass_scache_rs1[0] = bypass data from c-stage
// bypass_scache_rs1[1] = bypass data from w-stage
// bypass_scache_rs1[2] = bypass data from w+1-stage

// Removed the priority Encoder. bypass signals are used as mux selects in RS1 and
// RS2 and these mux selects already go througha priority encoder. This improves
// timing on byapss as well as RS1 and RS2 paths 

// pri_encod_3	pri_encod_bypass_scache_rs1(.out(bypass_scache_rs1),
// 				.in0(bypass_scache_rs1_e),
// 				.in1(bypass_scache_rs1_c),
// 				.in2(bypass_scache_rs1_w) );


// Incase of multiple matches for bypassing, use a priprity encoder to resolve the
// contention

// bypass_scache_rs2[0] = bypass data from c-stage
// bypass_scache_rs2[1] = bypass data from w-stage
// bypass_scache_rs2[2] = bypass data from w+1-stage

// Incase of 2-cycle operations, we dont have to bypass data from
// R2 stage (E-stage) to R1 stage. This will remove lots of false
// bypassing stuff incase of Double operations, Eg:
// DADD ->	cyc.1 Read Top1 and Top3 (MSBs) write to LSB -> Top4
//		cyc.2 Read Top2 and Top4  (LSBs)

assign	act_bypass_scache_rs2_e = bypass_scache_rs2_e & !second_cycle;

// Removed the priority Encoder. bypass signals are used as mux selects in RS1 and
// RS2 and these mux selects already go througha priority encoder. This improves
// timing on byapss as well as RS1 and RS2 paths 

// pri_encod_3	pri_encod_bypass_scache_rs2(.out(bypass_scache_rs2),
// 				.in0(act_bypass_scache_rs2_e),
// 				.in1(bypass_scache_rs2_c),
// 				.in2(bypass_scache_rs2_w) );

// Final Bypass Signals from R-stage

// For RS1

// In case of Global Reg matches or scache addr matches in estage 
// bypass estage data and so-on

// Removed the priority Encoder. bypass signals are used as mux selects in RS1 and
// RS2 and these mux selects already go througha priority encoder. This improves
// timing on byapss as well as RS1 and RS2 paths 

// assign	bypass_data_rs1_estage_r = bypass_gl_reg_rs1[0] | bypass_scache_rs1[0];
// assign	bypass_data_rs1_cstage_r = bypass_gl_reg_rs1[1] | bypass_scache_rs1[1];
// assign	bypass_data_rs1_wstage_r = bypass_gl_reg_rs1[2] | bypass_scache_rs1[2];

// Added ucode_done to fix a problem 
// Whwnever there's a ucode instruction in E-stage, write_global_X in C/W stage
// and read_global_X in R-stage, we'll have bypass high there by giving wrong
// data to Ucode stack access  

assign	bypass_data_rs1_estage_r = (bypass_gl_reg_rs1_e &ucode_done)
					| bypass_scache_rs1_e;
assign	bypass_data_rs1_cstage_r = (bypass_gl_reg_rs1_c &ucode_done)  
					| bypass_scache_rs1_c;
assign	bypass_data_rs1_wstage_r = (bypass_gl_reg_rs1_w &ucode_done)  
					| bypass_scache_rs1_w;

assign	nobypass_rs1_r = !(bypass_data_rs1_estage_r | bypass_data_rs1_cstage_r |
			   bypass_data_rs1_wstage_r);
// Whenver there's a bypass hit, we should not generate any scache read miss
assign	bypass_hit_rs1_r = (bypass_data_rs1_estage_r | bypass_data_rs1_cstage_r |
				bypass_data_rs1_wstage_r);

// All the bypass signals are latched in ex_dpath to imrpove timing on RS1 and RS2
// The following flops are all moved to ex_dpath to improve timing 

// ff_sre	flop_bypass_rs1_estage(.out(bypass_data_rs1_estage_e),
// 				.din(bypass_data_rs1_estage_r),
// 				.clk(clk),
// 				.enable(!(hold_e & !ucode_active)),
// 				.reset_l(reset_l));

// ff_sre	flop_bypass_rs1_cstage(.out(bypass_data_rs1_cstage_e),
// 				.din(bypass_data_rs1_cstage_r),
// 				.clk(clk),
// 				.enable(!(hold_e & !ucode_active)),
// 				.reset_l(reset_l));

// ff_sre	flop_bypass_rs1_wstage(.out(bypass_data_rs1_wstage_e),
// 				.din(bypass_data_rs1_wstage_r),
// 				.clk(clk),
// 				.enable(!(hold_e & !ucode_active)),
// 				.reset_l(reset_l));

// ff_sre	flop_nobypass_rs1(.out(nobypass_rs1_e),
// 			.din(nobypass_rs1_r),
// 			.clk(clk),
// 			.enable(!(hold_e & !ucode_active)),
// 			.reset_l(reset_l));

//  This signal is used for selecting appr. data in EX stage
// assign	rs1_forward_mux_sel[3] = bypass_data_rs1_estage_e;
// assign	rs1_forward_mux_sel[2] = bypass_data_rs1_cstage_e;
// assign	rs1_forward_mux_sel[1] = bypass_data_rs1_wstage_e;
// assign	rs1_forward_mux_sel[0] = nobypass_rs1_e;

assign	rs1_forward_mux_sel[3] = bypass_data_rs1_estage_r;
assign	rs1_forward_mux_sel[2] = bypass_data_rs1_cstage_r;
assign	rs1_forward_mux_sel[1] = bypass_data_rs1_wstage_r;
assign	rs1_forward_mux_sel[0] = nobypass_rs1_r;

// For RS2

// In case of Global Reg matches or scache addr matches in estage 
// bypass estage data and so-on.

// Removed the priority Encoder. bypass signals are used as mux selects in RS1 and
// RS2 and these mux selects already go througha priority encoder. This improves
// timing on byapss as well as RS1 and RS2 paths 

// assign	bypass_data_rs2_estage_r = ( bypass_gl_reg_rs2[0] | bypass_scache_rs2[0]);
// assign	bypass_data_rs2_cstage_r = ( bypass_gl_reg_rs2[1] | bypass_scache_rs2[1]);
// assign	bypass_data_rs2_wstage_r = ( bypass_gl_reg_rs2[2] | bypass_scache_rs2[2]);

assign	bypass_data_rs2_estage_r = ( (bypass_gl_reg_rs2_e &ucode_done)
						 | act_bypass_scache_rs2_e);
assign	bypass_data_rs2_cstage_r = ( (bypass_gl_reg_rs2_c &ucode_done)
						 | bypass_scache_rs2_c);
assign	bypass_data_rs2_wstage_r = ( (bypass_gl_reg_rs2_w &ucode_done)
						 | bypass_scache_rs2_w);

assign	nobypass_rs2_r = !(bypass_data_rs2_estage_r | bypass_data_rs2_cstage_r |
			   bypass_data_rs2_wstage_r);

// Whenver there's a bypass hit, we should not generate any scache read miss
assign	bypass_hit_rs2_r = (bypass_data_rs2_estage_r | bypass_data_rs2_cstage_r |
				bypass_data_rs2_wstage_r);

// All the bypass signals are latched in ex_dpath to imrpove timing on RS1 and RS2
// The following flops are all moved to ex_dpath to improve timing 

// ff_sre	flop_bypass_rs2_estage(.out(bypass_data_rs2_estage_e),
// 				.din(bypass_data_rs2_estage_r),
// 				.clk(clk),
// 				.enable(!hold_e),
// 				.reset_l(reset_l));

// ff_sre	flop_bypass_rs2_cstage(.out(bypass_data_rs2_cstage_e),
// 				.din(bypass_data_rs2_cstage_r),
// 				.clk(clk),
// 				.enable(!hold_e),
// 				.reset_l(reset_l));

// ff_sre	flop_bypass_rs2_wstage(.out(bypass_data_rs2_wstage_e),
// 				.din(bypass_data_rs2_wstage_r),
// 				.clk(clk),
// 				.enable(!hold_e),
// 				.reset_l(reset_l));

// ff_sre	flop_nobypass_rs2(.out(nobypass_rs2_e),
// 			.din(nobypass_rs2_r),
// 			.clk(clk),
// 			.enable(!hold_e),
// 			.reset_l(reset_l));

//  This signal is used for selecting appr. data in EX stage

// assign  rs2_forward_mux_sel[3] = bypass_data_rs2_wstage_e;
// assign  rs2_forward_mux_sel[2] = bypass_data_rs2_cstage_e;
// assign  rs2_forward_mux_sel[1] = bypass_data_rs2_estage_e;
// assign  rs2_forward_mux_sel[0] = nobypass_rs2_e;

assign  rs2_forward_mux_sel[3] = bypass_data_rs2_estage_r;
assign  rs2_forward_mux_sel[2] = bypass_data_rs2_cstage_r;
assign  rs2_forward_mux_sel[1] = bypass_data_rs2_wstage_r;
assign  rs2_forward_mux_sel[0] = nobypass_rs2_r;
 


// This function is used for multi-cycle r-stage operations //

function [1:0]	mult_cyc_state;
input	[1:0]	curr_state;
input		help_rs1_r;
input		hold_e;

reg	[1:0]	nxt_state;

parameter

	IDLE 	= 2'b01,
	SEC_CYC	= 2'b10;
begin

	case (curr_state)

		IDLE: begin

			if (help_rs1_r & !hold_e) begin
				
				nxt_state = SEC_CYC;
			end
			else nxt_state = curr_state;
		end

		SEC_CYC: begin

			if (!hold_e) begin
				nxt_state = IDLE;
			end
			else nxt_state = curr_state;
		end

		default: nxt_state = 2'bx;
	endcase

mult_cyc_state = nxt_state;

end

endfunction

assign	nxt_mul_cyc_state = mult_cyc_state(mul_cyc_state,
					help_rs1_r,
					hold_e );

ff_sr	flop_mult_cyc_st(.out(mul_cyc_state[1]),
			.din(nxt_mul_cyc_state[1]),
			.clk(clk),
			.reset_l(reset_l) );

ff_s	flop_mult_cyc_st_0(.out(mul_cyc_state[0]),
			.din(~reset_l | nxt_mul_cyc_state[0]),
			.clk(clk));

assign	second_cycle = mul_cyc_state[1];
assign	first_cycle = help_rs1_r & !second_cycle;

// Misc. Logic
// COSIM SIGNALS
// Provide inst_complete_w signal to cosim
// inst_vld_w is valid for both the cycles in case of a long op.
// But cosim needs only one signal during the second cycle. So, we propogate 
// first_cycle through pipe and then use first_cycle_w to qualify inst_vld[2]

ff_sre  flop_fc_e (.out(first_cycle_e),
                        .din(first_cycle&valid_op_r),
                        .reset_l(reset_l),
                        .enable(!hold_e),
                        .clk(clk));

ff_sre  flop_fc_c (.out(first_cycle_c),
                        .din(first_cycle_e),
                        .reset_l(reset_l),
                        .enable(!hold_c),
                        .clk(clk));

// Whenver there's a Write Enable signal in C-stage and it's 
// a first cycle, generate a signal "first_vld_c" to pipe
// so as to hold the pipe appropriately in case of fpu ops.
// Especially inthe case of dcmpg and dcmpl ops

assign	first_vld_c = first_cycle_c & iu_data_we_c;

// Whenever there's a hold_c, we need to kill inst_complete_w
// This is because we donot hold w-stage and hold_w == hold_c

ff_sr  flop_fc_w (.out(first_cycle_w),
                        .din((first_cycle_c & !hold_c)),
                        .reset_l(reset_l),
                        .clk(clk));


// We need to qualify inst_complete with ucode_done_w

ff_sre	flop_udone_c(.out(ucode_done_c),
		.din(ucode_done),
		.clk(clk),
		.enable(!hold_c),
		.reset_l(reset_l) );

ff_sre	flop_udone_w(.out(ucode_done_w),
		.din((ucode_done_c & !hold_c)),
		.clk(clk),
		.enable(!hold_c),
		.reset_l(reset_l) );
		
assign	inst_complete_w = inst_vld[2] & !first_cycle_w & ucode_done_w;



mj_spare spare1( .clk(clk),
                .reset_l(reset_l));

mj_spare spare2( .clk(clk),
                .reset_l(reset_l));
 

 
endmodule

module	decode_opcode (
	opcode,
	valid,
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
	read_gl0,
	read_gl1,
	read_gl2,
	read_gl3
);

input	[15:0]	opcode;
input		valid;
output		aconst_null;
output		iconst_m1;
output		iconst_0;
output		iconst_1;
output		iconst_2;
output		iconst_3;
output		iconst_4;
output		iconst_5;
output		lconst_0;
output		lconst_1;
output		fconst_0;
output		fconst_1;
output		fconst_2;
output		dconst_0;
output		dconst_1;
output		bipush;
output		sipush;
output		read_gl0;
output		read_gl1;
output		read_gl2;
output		read_gl3;

wire		ext_opcode;

assign	aconst_null =  (opcode[15:8] == 8'd1)  & valid;
assign	iconst_m1 =  (opcode[15:8] == 8'd2)  & valid;
assign	iconst_0  =  (opcode[15:8] == 8'd3)  & valid;
assign	iconst_1  =  (opcode[15:8] == 8'd4)  & valid;
assign	iconst_2  =  (opcode[15:8] == 8'd5)  & valid;
assign	iconst_3  =  (opcode[15:8] == 8'd6)  & valid;
assign	iconst_4  =  (opcode[15:8] == 8'd7)  & valid;
assign	iconst_5  =  (opcode[15:8] == 8'd8)  & valid;
assign	lconst_0  =  (opcode[15:8] == 8'd9)  & valid;
assign	lconst_1  =  (opcode[15:8] == 8'd10) & valid;
assign	fconst_0  =  (opcode[15:8] == 8'd11) & valid;
assign	fconst_1  =  (opcode[15:8] == 8'd12) & valid;
assign	fconst_2  =  (opcode[15:8] == 8'd13) & valid;
assign	dconst_0  =  (opcode[15:8] == 8'd14) & valid;
assign	dconst_1  =  (opcode[15:8] == 8'd15) & valid;
assign	bipush	  =  (opcode[15:8] == 8'd16) & valid;
assign	sipush	  =  (opcode[15:8] == 8'd17) & valid;

assign	ext_opcode = (opcode[15:8] == 8'hff) & valid;
assign	read_gl0   = ((opcode[7:0]  == 8'd90) & ext_opcode) & valid; 
assign	read_gl1   = ((opcode[7:0]  == 8'd91) & ext_opcode) & valid; 
assign	read_gl2   = ((opcode[7:0]  == 8'd92) & ext_opcode) & valid; 
assign	read_gl3   = ((opcode[7:0]  == 8'd93) & ext_opcode) & valid; 

endmodule

module dest_decoder (

	opcode,
	valid,
	first_cyc,
	second_cyc,
	group_2_r,
	group_3_r,
	group_5_r,
	group_6_r,
	group_7_r,
	optop_incr_sel,
	dest_we
);

input	[15:0]	opcode;
input		valid;
input		first_cyc;
input		second_cyc;
input		group_2_r;
input		group_3_r;
input		group_5_r;
input		group_6_r;
input		group_7_r;
output	[7:0]	optop_incr_sel;
output		dest_we;

wire	[15:0]	opcode_int;
wire		ext_opcode;
wire		curr_inc_optop_1;
wire		curr_inc_optop_2;
wire		curr_inc_optop_3;
wire		curr_inc_optop_4;
wire		curr_dec_optop_1;
wire		curr_no_change_optop;
wire		act_inc_optop_1;
wire		act_inc_optop_2;
wire		act_inc_optop_3;
wire		act_inc_optop_4;
wire		act_dec_optop_1;
wire		act_dec_optop_2;
wire		act_dec_optop_3;
wire		act_no_change_optop;

assign  opcode_int[15:0] = (opcode[15:0] ) & ({16{valid}});
assign	ext_opcode = (opcode_int[15:8] == 8'd255);


assign	curr_inc_optop_1 = (

		(opcode_int[15:8] == 8'd116)  |			// ineg
		(opcode_int[15:8] == 8'd118)  |			// fneg
		(opcode_int[15:8] == 8'd134)  |                 // i2f
                ((opcode_int[15:8] == 8'd135) & first_cyc)  |   // i2d
                ((opcode_int[15:8] == 8'd141) & first_cyc)  |   // f2d
                ((opcode_int[15:8] == 8'd138) & second_cyc)  |  // l2d
                (opcode_int[15:8] == 8'd139)  |                 // f2i
                ((opcode_int[15:8] == 8'd140) & first_cyc) |    // f2l
                ((opcode_int[15:8] == 8'd143) & second_cyc)  |  // d2l
                (opcode_int[15:8] == 8'd145)  |                 // i2b
                (opcode_int[15:8] == 8'd146)  |                 // i2c
                (opcode_int[15:8] == 8'd147)  |                 // i2s
		(opcode_int[15:8] == 8'd237)  | 		// sethi
		(ext_opcode & (opcode_int[7:0] == 8'd0))| 	// load_ubyte
		(ext_opcode & (opcode_int[7:0] == 8'd1))| 	// load_byte
		(ext_opcode & (opcode_int[7:0] == 8'd2))| 	// load_char
		(ext_opcode & (opcode_int[7:0] == 8'd3))| 	// load_short
		(ext_opcode & (opcode_int[7:0] == 8'd4))| 	// load_word
		(ext_opcode & (opcode_int[7:0] == 8'd6))| 	// priv_read_dcache_tag
		(ext_opcode & (opcode_int[7:0] == 8'd7))| 	// priv_read_dcache_data
		(ext_opcode & (opcode_int[7:0] == 8'd10))| 	// load_char_oe
		(ext_opcode & (opcode_int[7:0] == 8'd11))| 	// load_short_oe
		(ext_opcode & (opcode_int[7:0] == 8'd12))| 	// load_word_oe
		(ext_opcode & (opcode_int[7:0] == 8'd14)
						& first_cyc) | 	// priv_read_icache_tag
		(ext_opcode & (opcode_int[7:0] == 8'd15)
						& first_cyc) | 	// priv_read_icache_data
		(ext_opcode & (opcode_int[7:0] == 8'd16))| 	// ncload_ubyte
		(ext_opcode & (opcode_int[7:0] == 8'd17))| 	// ncload_byte
		(ext_opcode & (opcode_int[7:0] == 8'd18))| 	// ncload_char
		(ext_opcode & (opcode_int[7:0] == 8'd19))| 	// ncload_short
		(ext_opcode & (opcode_int[7:0] == 8'd20))| 	// ncload_word
		(ext_opcode & (opcode_int[7:0] == 8'd23))| 	// cache_invalidate
		(ext_opcode & (opcode_int[7:0] == 8'd26))| 	// ncload_char_oe
		(ext_opcode & (opcode_int[7:0] == 8'd27))| 	// ncload_short_oe
		(ext_opcode & (opcode_int[7:0] == 8'd28))| 	// ncload_word_oe
		(ext_opcode & (opcode_int[7:0] == 8'd30))| 	// cache_flush
		(ext_opcode & (opcode_int[7:0] == 8'd31))| 	// cache_index_flush
		((opcode_int[15:8] == 8'd117) & second_cyc) |	// lneg
		(opcode_int[15:8] == 8'd119) 			// dneg

		);

assign	curr_inc_optop_2 = (

		(opcode_int[15:8] == 8'd96)  |			// iadd
		(opcode_int[15:8] == 8'd98)  |			// fadd
		(opcode_int[15:8] == 8'd100)  |			// isub
		(opcode_int[15:8] == 8'd102)  |			// fsub
		(opcode_int[15:8] == 8'd104)  |			// imul
		(opcode_int[15:8] == 8'd106)  |			// fmul
		(opcode_int[15:8] == 8'd108)  |			// idiv
		(opcode_int[15:8] == 8'd110)  |			// fdiv
		(opcode_int[15:8] == 8'd112)  |			// irem
		(opcode_int[15:8] == 8'd114)  |			// frem
		((opcode_int[15:8] == 8'd117) & first_cyc)  |	// lneg
		(opcode_int[15:8] == 8'd120)  |			// ishl
		((opcode_int[15:8] == 8'd121) & second_cyc)  |	// lshl
		(opcode_int[15:8] == 8'd122)  |			// ishr
		((opcode_int[15:8] == 8'd123) & first_cyc)  |	// lshr
		(opcode_int[15:8] == 8'd124)  |			// iushr
		((opcode_int[15:8] == 8'd125) & first_cyc)  |	// lushr
		(opcode_int[15:8] == 8'd126)  |			// iand
		(opcode_int[15:8] == 8'd128)  |			// ior
		(opcode_int[15:8] == 8'd130)  |			// ixor
		(opcode_int[15:8] == 8'd137)  |			// l2f
		((opcode_int[15:8] == 8'd138) & first_cyc)  |	// l2d
		(opcode_int[15:8] == 8'd142)  |			// d2i
		((opcode_int[15:8] == 8'd143) & first_cyc)  |	// d2l
		(opcode_int[15:8] == 8'd144)  |			// d2f
		(opcode_int[15:8] == 8'd149)  |			// fcmpl
		(opcode_int[15:8] == 8'd150)  |			// fcmpg
		(ext_opcode & (opcode_int[7:0] == 8'd21)) 	// iucmp

	);

assign	curr_inc_optop_3 = (

   	         ((opcode_int[15:8] == 8'd97) & second_cyc)  | 	// ladd
   	         ((opcode_int[15:8] == 8'd99) & second_cyc)  | 	// dadd
   	         ((opcode_int[15:8] == 8'd101) & second_cyc) | 	// lsub
   	         ((opcode_int[15:8] == 8'd103) & second_cyc) | 	// dsub
   	         ((opcode_int[15:8] == 8'd105) & second_cyc) | 	// lmul
   	         ((opcode_int[15:8] == 8'd107) & second_cyc) | 	// dmul
   	         ((opcode_int[15:8] == 8'd109) & second_cyc) | 	// ldiv
   	         ((opcode_int[15:8] == 8'd111) & second_cyc) | 	// ddiv
   	         ((opcode_int[15:8] == 8'd113) & second_cyc) | 	// lrem
   	         ((opcode_int[15:8] == 8'd115) & second_cyc) | 	// drem
   	         ((opcode_int[15:8] == 8'd121) & first_cyc) | 	// lshl
   	         ((opcode_int[15:8] == 8'd123) & second_cyc) | 	// lshr
   	         ((opcode_int[15:8] == 8'd125) & second_cyc) | 	// lushr
   	         ((opcode_int[15:8] == 8'd127) & second_cyc) | 	// land
   	         ((opcode_int[15:8] == 8'd129) & second_cyc) | 	// lor
   	         ((opcode_int[15:8] == 8'd131) & second_cyc)  	// lxor

	);

assign	curr_inc_optop_4 = (

   	         ((opcode_int[15:8] == 8'd97) & first_cyc)  | 	// ladd
   	         ((opcode_int[15:8] == 8'd99) & first_cyc)  | 	// dadd
   	         ((opcode_int[15:8] == 8'd101) & first_cyc) | 	// lsub
   	         ((opcode_int[15:8] == 8'd103) & first_cyc) | 	// dsub
   	         ((opcode_int[15:8] == 8'd105) & first_cyc) | 	// lmul
   	         ((opcode_int[15:8] == 8'd107) & first_cyc) | 	// dmul
   	         ((opcode_int[15:8] == 8'd109) & first_cyc) | 	// ldiv
   	         ((opcode_int[15:8] == 8'd111) & first_cyc) | 	// ddiv
   	         ((opcode_int[15:8] == 8'd113) & first_cyc) | 	// lrem
   	         ((opcode_int[15:8] == 8'd115) & first_cyc) | 	// drem
   	         ((opcode_int[15:8] == 8'd127) & first_cyc) | 	// land
   	         ((opcode_int[15:8] == 8'd129) & first_cyc) | 	// lor
   	         ((opcode_int[15:8] == 8'd131) & first_cyc) |  	// lxor
   	         ((opcode_int[15:8] == 8'd148) & second_cyc) |	// lcmp
   	         ((opcode_int[15:8] == 8'd151) & second_cyc) |	// dcmpl
   	         ((opcode_int[15:8] == 8'd152) & second_cyc)   	// dcmpg
	);

assign	curr_dec_optop_1 = (

   	         ((opcode_int[15:8] == 8'd9) & second_cyc)  | 	// lconst_0
   	         ((opcode_int[15:8] == 8'd10) & second_cyc)  | 	// lconst_1
   	         ((opcode_int[15:8] == 8'd14) & second_cyc)  | 	// dconst_0
   	         ((opcode_int[15:8] == 8'd15) & second_cyc)  | 	// dconst_1
   	         ((opcode_int[15:8] == 8'd22) & second_cyc)  | 	// lload
   	         ((opcode_int[15:8] == 8'd24) & second_cyc)  | 	// dload
   	         ((opcode_int[15:8] == 8'd30) & second_cyc)  | 	// lload_0
   	         ((opcode_int[15:8] == 8'd31) & second_cyc)  | 	// lload_1
   	         ((opcode_int[15:8] == 8'd32) & second_cyc)  | 	// lload_2
   	         ((opcode_int[15:8] == 8'd33) & second_cyc)  | 	// lload_3
   	         ((opcode_int[15:8] == 8'd38) & second_cyc)  | 	// dload_0
   	         ((opcode_int[15:8] == 8'd39) & second_cyc)  | 	// dload_1
   	         ((opcode_int[15:8] == 8'd40) & second_cyc)  | 	// dload_2
   	         ((opcode_int[15:8] == 8'd41) & second_cyc)   	// dload_3
	);

assign		curr_no_change_optop = !(curr_inc_optop_1 | curr_inc_optop_2 | 
					curr_inc_optop_3 | curr_inc_optop_4 | 
					curr_dec_optop_1);

// BG2 op sometimes pushes 1 item onto stack and sometimes 2. Because of
// this it's difficult to determine the dest_offset just from group
// information. Hence we need  to decode BG2 and then use grouping
// info. to calculate the offset. For ex. for LV LB BG2 (group_3_r)
// If BG2 pushes one item onto stack, then decoding BG2 we'll get dest
// offset as +1 (it consumes 2 and pushes 1), but if we use the group info.
// (in this case group_3), then offset is -2 +1 (since 2 operands needed by
// BG2 are now available within the instruction itself  instead of popping
// them from scache. Same holds good for groups  5 and 6 (LV BG2 and LV BG1)
// for groups 2 and 7 (LV LV OP and LV OP), dest offsets are 0 and +1 resp

assign	act_inc_optop_4 = curr_inc_optop_4 & !(group_3_r | group_5_r | group_6_r);

assign	act_inc_optop_3 = curr_inc_optop_3 & !(group_3_r | group_5_r | group_6_r) |
			  curr_inc_optop_4 & (group_5_r | group_6_r);

assign	act_inc_optop_2 =  curr_inc_optop_2 &!(group_3_r | group_5_r | group_6_r) |
			    curr_inc_optop_4 & (group_3_r) |
			    curr_inc_optop_3 & (group_5_r | group_6_r);

assign	act_inc_optop_1 =  curr_inc_optop_1 &!(group_3_r | group_5_r | group_6_r) |
			    curr_inc_optop_3 & (group_3_r) |
			    curr_inc_optop_2 & (group_5_r | group_6_r);

assign	act_no_change_optop = curr_no_change_optop &!(group_3_r | group_5_r | group_6_r) |
			    curr_inc_optop_2 & (group_3_r) |
			    curr_inc_optop_1 & (group_5_r | group_6_r);

assign	act_dec_optop_1 =  curr_dec_optop_1 &!(group_3_r | group_5_r | group_6_r) |
			    curr_no_change_optop & (group_5_r | group_6_r) |
			    curr_inc_optop_1 & (group_3_r);

assign	act_dec_optop_2 =  curr_dec_optop_1 & (group_5_r | group_6_r) |
			    curr_no_change_optop & (group_3_r) ;

assign	act_dec_optop_3 =  curr_dec_optop_1 & (group_3_r );



// Instead of providing the offset, we are now providing the selects to MUXes
// to improve timing 

assign	optop_incr_sel[7] = act_inc_optop_4 & !(group_7_r | group_2_r);
assign	optop_incr_sel[6] = act_inc_optop_3 & !(group_7_r | group_2_r);
assign	optop_incr_sel[5] = act_inc_optop_2 & !(group_7_r | group_2_r);
assign	optop_incr_sel[4] = (act_inc_optop_1 | group_7_r) & !group_2_r;
assign	optop_incr_sel[3] = act_dec_optop_1 & !(group_7_r | group_2_r);
assign	optop_incr_sel[2] = act_dec_optop_2 & !(group_7_r | group_2_r);
assign	optop_incr_sel[1] = act_dec_optop_3 & !(group_7_r | group_2_r);
assign	optop_incr_sel[0] = !(|optop_incr_sel[7:1]); 
			

/*
mux8_32		mux_dest_offset_int (.out(dest_offset_int),
				.in0(32'h0),
				.in1(32'hfffffff4),	// 2's complement of 4*-3
				.in2(32'hfffffff8),	// 2's complement of 4*-2
				.in3(32'hfffffffc),	// 2's complement of 4*-1
				.in4(32'h4),		// 4*1
				.in5(32'h8),		// 4*2
				.in6(32'hc),		// 4*3
				.in7(32'h10),		// 4*4
				.sel({
					act_inc_optop_4,
					act_inc_optop_3,
					act_inc_optop_2,
					act_inc_optop_1,
					act_dec_optop_1,
					act_dec_optop_2,
					act_dec_optop_3,
					(default_ch_optop | act_no_change_optop) 
				     }) );
				    
mux3_32		mux_dest_offset(.out(dest_offset),
				.in0(dest_offset_int),
				.in1(32'h0),
				.in2(32'h4),
				.sel ( {
					group_7_r,
					group_2_r,
					!(group_7_r | group_2_r)
					}) );
*/

assign	dest_we	= (

		(opcode_int[15:8] == 8'd1) |			// aconst_null
		(opcode_int[15:8] == 8'd2) |			// iconst_m1
		(opcode_int[15:8] == 8'd3) |			// iconst_0
		(opcode_int[15:8] == 8'd4) |			// iconst_1
		(opcode_int[15:8] == 8'd5) |			// iconst_2
		(opcode_int[15:8] == 8'd6) |			// iconst_3
		(opcode_int[15:8] == 8'd7) |			// iconst_4
		(opcode_int[15:8] == 8'd8) |			// iconst_5
		(opcode_int[15:8] == 8'd9) |			// lconst_0
		(opcode_int[15:8] == 8'd10) |			// lconst_1
		(opcode_int[15:8] == 8'd11) |			// fconst_0
		(opcode_int[15:8] == 8'd12) |			// fconst_1
		(opcode_int[15:8] == 8'd13) |			// fconst_2
		(opcode_int[15:8] == 8'd14) |			// dconst_0
		(opcode_int[15:8] == 8'd15) |			// dconst_1
		(opcode_int[15:8] == 8'd16) |			// bipush
		(opcode_int[15:8] == 8'd17) |			// sipush
		(opcode_int[15:8] == 8'd21) |			// iload
		(opcode_int[15:8] == 8'd22) |			// lload
		(opcode_int[15:8] == 8'd23) |			// fload
		(opcode_int[15:8] == 8'd24) |			// dload
		(opcode_int[15:8] == 8'd25) |			// aload
		(opcode_int[15:8] == 8'd26) |			// iload_0
		(opcode_int[15:8] == 8'd27) |			// iload_1
		(opcode_int[15:8] == 8'd28) |			// iload_2
		(opcode_int[15:8] == 8'd29) |			// iload_3
		(opcode_int[15:8] == 8'd30) |			// lload_0
		(opcode_int[15:8] == 8'd31) |			// lload_1
		(opcode_int[15:8] == 8'd32) |			// lload_2
		(opcode_int[15:8] == 8'd33) |			// lload_3
		(opcode_int[15:8] == 8'd34) |			// fload_0
		(opcode_int[15:8] == 8'd35) |			// fload_1
		(opcode_int[15:8] == 8'd36) |			// fload_2
		(opcode_int[15:8] == 8'd37) |			// fload_3
		(opcode_int[15:8] == 8'd38) |			// dload_0
		(opcode_int[15:8] == 8'd39) |			// dload_1
		(opcode_int[15:8] == 8'd40) |			// dload_2
		(opcode_int[15:8] == 8'd41) |			// dload_3
		(opcode_int[15:8] == 8'd42) |			// aload_0
		(opcode_int[15:8] == 8'd43) |			// aload_1
		(opcode_int[15:8] == 8'd44) |			// aload_2
		(opcode_int[15:8] == 8'd45) |			// aload_3
		(opcode_int[15:8] == 8'd89) |			// dup
		(opcode_int[15:8] == 8'd96) |			// iadd
		(opcode_int[15:8] == 8'd97) |			// ladd
		(opcode_int[15:8] == 8'd98) |			// fadd
		(opcode_int[15:8] == 8'd99) |			// dadd
		(opcode_int[15:8] == 8'd100) |			// isub
		(opcode_int[15:8] == 8'd101) |			// lsub
		(opcode_int[15:8] == 8'd102) |			// fsub
		(opcode_int[15:8] == 8'd103) |			// dsub
		(opcode_int[15:8] == 8'd104) |			// imul
		(opcode_int[15:8] == 8'd106) |			// fmul
		(opcode_int[15:8] == 8'd107) |			// dmul
		(opcode_int[15:8] == 8'd108) |			// idiv
		(opcode_int[15:8] == 8'd110) |			// fdiv
		(opcode_int[15:8] == 8'd111) |			// ddiv
		(opcode_int[15:8] == 8'd112) |			// irem
		(opcode_int[15:8] == 8'd114) |			// frem
		(opcode_int[15:8] == 8'd115) |			// drem
		(opcode_int[15:8] == 8'd116) |			// ineg
		(opcode_int[15:8] == 8'd117) |			// lneg
		(opcode_int[15:8] == 8'd118) |			// fneg
		(opcode_int[15:8] == 8'd119) |			// dneg
		(opcode_int[15:8] == 8'd120) |			// ishl
		(opcode_int[15:8] == 8'd121) |			// lshl
		(opcode_int[15:8] == 8'd122) |			// ishr
		(opcode_int[15:8] == 8'd123) |			// lshr
		(opcode_int[15:8] == 8'd124) |			// iushr
		(opcode_int[15:8] == 8'd125) |			// lushr
		(opcode_int[15:8] == 8'd126) |			// iand
		(opcode_int[15:8] == 8'd127) |			// iand
		(opcode_int[15:8] == 8'd128) |			// ior
		(opcode_int[15:8] == 8'd129) |			// ior
		(opcode_int[15:8] == 8'd130) |			// ixor
		(opcode_int[15:8] == 8'd131) |			// ixor
		(opcode_int[15:8] == 8'd132) |			// iinc
		(opcode_int[15:8] == 8'd133) |			// i2l
		(opcode_int[15:8] == 8'd134) |			// i2f
		(opcode_int[15:8] == 8'd135) |			// i2d
		(opcode_int[15:8] == 8'd137) |			// l2f
		(opcode_int[15:8] == 8'd138) |			// l2d
		(opcode_int[15:8] == 8'd139) |			// f2i
		(opcode_int[15:8] == 8'd140) |			// f2l
		(opcode_int[15:8] == 8'd141) |			// f2d
		(opcode_int[15:8] == 8'd142) |			// d2i
		(opcode_int[15:8] == 8'd143) |			// d2l
		(opcode_int[15:8] == 8'd144) |			// d2f
		(opcode_int[15:8] == 8'd145) |			// i2b
		(opcode_int[15:8] == 8'd146) |			// i2c
		(opcode_int[15:8] == 8'd147) |			// i2s
		((opcode_int[15:8] == 8'd148) & second_cyc) |	// lcmp
		(opcode_int[15:8] == 8'd149) |			// fcmpl
		(opcode_int[15:8] == 8'd150) |			// fcmpg
		((opcode_int[15:8] == 8'd151) & second_cyc) |	// dcmpl
		((opcode_int[15:8] == 8'd152) & second_cyc) |	// dcmpg
		(opcode_int[15:8] == 8'd168) |			// jsr
		(opcode_int[15:8] == 8'd201) |			// jsr_w
		(opcode_int[15:8] == 8'd237) |			// sethi
		(opcode_int[15:8] == 8'd238) |			// load_word_index
		(opcode_int[15:8] == 8'd239) |			// load_short_index
		(opcode_int[15:8] == 8'd240) |			// load_char_index
		(opcode_int[15:8] == 8'd241) |			// load_byte_index
		(opcode_int[15:8] == 8'd242) |			// load_ubyte_index
		(ext_opcode & (opcode_int[7:0] == 8'd0))| 	// load_ubyte
		(ext_opcode & (opcode_int[7:0] == 8'd1))| 	// load_byte
		(ext_opcode & (opcode_int[7:0] == 8'd2))| 	// load_char
		(ext_opcode & (opcode_int[7:0] == 8'd3))| 	// load_short
		(ext_opcode & (opcode_int[7:0] == 8'd4))| 	// load_word
		(ext_opcode & (opcode_int[7:0] == 8'd6))| 	// priv_read_dcache_tag
		(ext_opcode & (opcode_int[7:0] == 8'd7))| 	// priv_read_dcache_data
		(ext_opcode & (opcode_int[7:0] == 8'd10))| 	// load_char_oe
		(ext_opcode & (opcode_int[7:0] == 8'd11))| 	// load_short_oe
		(ext_opcode & (opcode_int[7:0] == 8'd12))| 	// load_word_oe
		(ext_opcode & (opcode_int[7:0] == 8'd14) 
						& first_cyc) | 	// priv_read_icache_tag
		(ext_opcode & (opcode_int[7:0] == 8'd15) 
						& first_cyc) | 	// priv_read_icache_data
		(ext_opcode & (opcode_int[7:0] == 8'd16))| 	// ncload_ubyte
		(ext_opcode & (opcode_int[7:0] == 8'd17))| 	// ncload_byte
		(ext_opcode & (opcode_int[7:0] == 8'd18))| 	// ncload_char
		(ext_opcode & (opcode_int[7:0] == 8'd19))| 	// ncload_short
		(ext_opcode & (opcode_int[7:0] == 8'd20))| 	// ncload_word
		(ext_opcode & (opcode_int[7:0] == 8'd21))| 	// iucmp
		(ext_opcode & (opcode_int[7:0] == 8'd23))| 	// cache_invalidate
		(ext_opcode & (opcode_int[7:0] == 8'd26))| 	// ncload_char_oe
		(ext_opcode & (opcode_int[7:0] == 8'd27))| 	// ncload_short_oe
		(ext_opcode & (opcode_int[7:0] == 8'd28))| 	// ncload_word_oe
		(ext_opcode & (opcode_int[7:0] == 8'd30))| 	// cache_flush
		(ext_opcode & (opcode_int[7:0] == 8'd31))| 	// cache_index_flush
		(ext_opcode & (opcode_int[7:0] == 8'd64))| 	// read_pc
		(ext_opcode & (opcode_int[7:0] == 8'd65))| 	// read_vars
		(ext_opcode & (opcode_int[7:0] == 8'd66))| 	// read_frame
		(ext_opcode & (opcode_int[7:0] == 8'd67))| 	// read_optop
		(ext_opcode & (opcode_int[7:0] == 8'd68))| 	// priv_read_oplim
		(ext_opcode & (opcode_int[7:0] == 8'd69))| 	// read_const_pool
		(ext_opcode & (opcode_int[7:0] == 8'd70))| 	// priv_read_psr
		(ext_opcode & (opcode_int[7:0] == 8'd71))| 	// priv_read_trapbase
		(ext_opcode & (opcode_int[7:0] == 8'd72))| 	// priv_read_lockcount0
		(ext_opcode & (opcode_int[7:0] == 8'd73))| 	// priv_read_lockcount1
		(ext_opcode & (opcode_int[7:0] == 8'd76))| 	// priv_read_lockaddr0
		(ext_opcode & (opcode_int[7:0] == 8'd77))| 	// priv_read_lockaddr1
		(ext_opcode & (opcode_int[7:0] == 8'd80))| 	// priv_read_userrange1
		(ext_opcode & (opcode_int[7:0] == 8'd81))| 	// priv_read_gc_config
		(ext_opcode & (opcode_int[7:0] == 8'd82))| 	// priv_read_brk1a
		(ext_opcode & (opcode_int[7:0] == 8'd83))| 	// priv_read_brk2a
		(ext_opcode & (opcode_int[7:0] == 8'd84))| 	// priv_read_brk12c
		(ext_opcode & (opcode_int[7:0] == 8'd85))| 	// priv_read_userrange2
		(ext_opcode & (opcode_int[7:0] == 8'd87))| 	// priv_read_versionid
		(ext_opcode & (opcode_int[7:0] == 8'd88))| 	// priv_read_hcr
		(ext_opcode & (opcode_int[7:0] == 8'd89))| 	// priv_read_sc_bottom
		(ext_opcode & (opcode_int[7:0] == 8'd90))| 	// read_global0
		(ext_opcode & (opcode_int[7:0] == 8'd91))| 	// read_global1
		(ext_opcode & (opcode_int[7:0] == 8'd92))| 	// read_global2
		(ext_opcode & (opcode_int[7:0] == 8'd93)) 	// read_global3

	);
endmodule

module optop_decoder (

	opcode,
	valid,
	second_cyc,
	group_3_r,
	group_5_r,
	group_6_r,
	net_optop_sel1,
	net_optop_sel2,
	net_optop_sel

);

input	[15:0]	opcode;
input		valid;
input		second_cyc;
input		group_3_r;
input		group_5_r;
input		group_6_r;
output	[4:0]	net_optop_sel1;
output	[3:0]	net_optop_sel2;
output	[1:0]	net_optop_sel;

wire	[15:0]	opcode_int;
wire		inc_optop_1;
wire		inc_optop_2;
wire		inc_optop_3;
wire		inc_optop_4;
wire		dec_optop_1;
wire		dec_optop_2;
wire		ext_opcode;
wire		no_change;
wire		no_change_optop;

assign  opcode_int[15:0] = (opcode[15:0] ) & ({16{valid}});
assign	ext_opcode	= (opcode[15:8] == 8'd255);

assign	dec_optop_1	= (

		(opcode_int[15:8] == 8'd1) |			// aconst_null	
		(opcode_int[15:8] == 8'd2) |			// iconst_m1	
		(opcode_int[15:8] == 8'd3) |			// iconst_0	
		(opcode_int[15:8] == 8'd4) |			// iconst_1	
		(opcode_int[15:8] == 8'd5) |			// iconst_2	
		(opcode_int[15:8] == 8'd6) |			// iconst_3	
		(opcode_int[15:8] == 8'd7) |			// iconst_4	
		(opcode_int[15:8] == 8'd8) |			// iconst_5	
		(opcode_int[15:8] == 8'd11) |			// fconst_0	
		(opcode_int[15:8] == 8'd12) |			// fconst_1	
		(opcode_int[15:8] == 8'd13) |			// fconst_2	
		(opcode_int[15:8] == 8'd16) |			// bipush	
		(opcode_int[15:8] == 8'd17) |			// sipush	
		(opcode_int[15:8] == 8'd21) |			// iload	
		(opcode_int[15:8] == 8'd23) |			// fload	
		(opcode_int[15:8] == 8'd25) |			// aload	
		(opcode_int[15:8] == 8'd26) |			// iload_0	
		(opcode_int[15:8] == 8'd27) |			// iload_1	
		(opcode_int[15:8] == 8'd28) |			// iload_2	
		(opcode_int[15:8] == 8'd29) |			// iload_3	
		(opcode_int[15:8] == 8'd34) |			// fload_0	
		(opcode_int[15:8] == 8'd35) |			// fload_1	
		(opcode_int[15:8] == 8'd36) |			// fload_2	
		(opcode_int[15:8] == 8'd37) |			// fload_3	
		(opcode_int[15:8] == 8'd42) |			// aload_0	
		(opcode_int[15:8] == 8'd43) |			// aload_1	
		(opcode_int[15:8] == 8'd44) |			// aload_2	
		(opcode_int[15:8] == 8'd45) |			// aload_3	
		(opcode_int[15:8] == 8'd89) |			// dup	
		(opcode_int[15:8] == 8'd90) |			// dup_x1	
		(opcode_int[15:8] == 8'd91) |			// dup_x2	
		(opcode_int[15:8] == 8'd133) |			// i2l	
		((opcode_int[15:8] == 8'd135) & second_cyc) |	// i2d	
		((opcode_int[15:8] == 8'd140) & second_cyc) |	// f2l	
		((opcode_int[15:8] == 8'd141) & second_cyc) |	// f2d	
		(opcode_int[15:8] == 8'd168) |			// jsr	
		(opcode_int[15:8] == 8'd201) |			// jsr_w	
		(opcode_int[15:8] == 8'd203) |			// ldc_quick	
		(opcode_int[15:8] == 8'd204) |			// ldc_w_quick	
		(opcode_int[15:8] == 8'd208) |			// getfield2_quick	
		(opcode_int[15:8] == 8'd210) |			// getstatic_quick	
		(opcode_int[15:8] == 8'd232) |			// agetstatic_quick	
		(opcode_int[15:8] == 8'd234) |			// aldc_quick	
		(opcode_int[15:8] == 8'd235) |			// aldc_w_quick	
		(opcode_int[15:8] == 8'd238) |			// load_word_index	
		(opcode_int[15:8] == 8'd239) |			// load_short_index	
		(opcode_int[15:8] == 8'd240) |			// load_char_index	
		(opcode_int[15:8] == 8'd241) |			// load_byte_index	
		(opcode_int[15:8] == 8'd242) |			// load_ubyte_index	
		( ext_opcode & (opcode_int[7:0] == 8'd55)) |	// get_current_class	
		( ext_opcode & (opcode_int[7:0] == 8'd64)) |	// read_pc	
		( ext_opcode & (opcode_int[7:0] == 8'd65)) |	// read_vars	
		( ext_opcode & (opcode_int[7:0] == 8'd66)) |	// read_frame	
		( ext_opcode & (opcode_int[7:0] == 8'd67)) |	// read_optop	
		( ext_opcode & (opcode_int[7:0] == 8'd68)) |	// read_oplim	
		( ext_opcode & (opcode_int[7:0] == 8'd69)) |	// read_const_pool	
		( ext_opcode & (opcode_int[7:0] == 8'd70)) |	// priv_read_psr	
		( ext_opcode & (opcode_int[7:0] == 8'd71)) |	// priv_read_trapbase	
		( ext_opcode & (opcode_int[7:0] == 8'd72)) |	// priv_read_lockcount0	
		( ext_opcode & (opcode_int[7:0] == 8'd73)) |	// priv_read_lockcount1	
		( ext_opcode & (opcode_int[7:0] == 8'd76)) |	// priv_read_lockaddr0	
		( ext_opcode & (opcode_int[7:0] == 8'd77)) |	// priv_read_lockaddr1	
		( ext_opcode & (opcode_int[7:0] == 8'd80)) |	// priv_readuserrange1	
		( ext_opcode & (opcode_int[7:0] == 8'd81)) |	// priv_read_gc_config	
		( ext_opcode & (opcode_int[7:0] == 8'd82)) |	// priv_read_brk1a	
		( ext_opcode & (opcode_int[7:0] == 8'd83)) |	// priv_read_brk2a	
		( ext_opcode & (opcode_int[7:0] == 8'd84)) |	// priv_read_brk12c	
		( ext_opcode & (opcode_int[7:0] == 8'd85)) |	// priv_read_userrange2	
		( ext_opcode & (opcode_int[7:0] == 8'd87)) |	// priv_read_versionid	
		( ext_opcode & (opcode_int[7:0] == 8'd88)) |	// priv_read_hcr	
		( ext_opcode & (opcode_int[7:0] == 8'd89)) |	// priv_read_sc_bottom	
		( ext_opcode & (opcode_int[7:0] == 8'd90)) |	// priv_read_global0	
		( ext_opcode & (opcode_int[7:0] == 8'd91)) |	// priv_read_global1	
		( ext_opcode & (opcode_int[7:0] == 8'd92)) |	// priv_read_global2	
		( ext_opcode & (opcode_int[7:0] == 8'd93)) 	// priv_read_global3	

	);


assign dec_optop_2 = (

		((opcode_int[15:8] == 8'd9) & second_cyc) |	// lconst_0	
		((opcode_int[15:8] == 8'd10) & second_cyc) |	// lconst_1	
		((opcode_int[15:8] == 8'd14) & second_cyc) |	// dconst_0	
		((opcode_int[15:8] == 8'd15) & second_cyc) |	// dconst_1	
		((opcode_int[15:8] == 8'd22) & second_cyc) |	// lload
		((opcode_int[15:8] == 8'd24) & second_cyc) |	// dload
		((opcode_int[15:8] == 8'd30) & second_cyc) |	// lload_0	
		((opcode_int[15:8] == 8'd31) & second_cyc) |	// lload_1	
		((opcode_int[15:8] == 8'd32) & second_cyc) |	// lload_2	
		((opcode_int[15:8] == 8'd33) & second_cyc) |	// lload_3	
		((opcode_int[15:8] == 8'd38) & second_cyc) |	// dload_0	
		((opcode_int[15:8] == 8'd39) & second_cyc) |	// dload_1	
		((opcode_int[15:8] == 8'd40) & second_cyc) |	// dload_2	
		((opcode_int[15:8] == 8'd41) & second_cyc) |	// dload_3	
		(opcode_int[15:8] == 8'd92) |			// dup2	
		(opcode_int[15:8] == 8'd93) |			// dup2_x1	
		(opcode_int[15:8] == 8'd94) |			// dup2_x2	
		(opcode_int[15:8] == 8'd205) |			// ldc2_w_quick	
		(opcode_int[15:8] == 8'd212) 			// getstatic2_quick	
	);

assign	inc_optop_1 = (

		(opcode_int[15:8] == 8'd46) |			// iaload
		(opcode_int[15:8] == 8'd48) |			// faload
		(opcode_int[15:8] == 8'd50) |			// aaload
		(opcode_int[15:8] == 8'd51) |			// baload
		(opcode_int[15:8] == 8'd52) |			// caload
		(opcode_int[15:8] == 8'd53) |			// saload
		(opcode_int[15:8] == 8'd54) |			// istore
		(opcode_int[15:8] == 8'd56) |			// fstore
		(opcode_int[15:8] == 8'd58) |			// astore
		(opcode_int[15:8] == 8'd59) |			// istore_0
		(opcode_int[15:8] == 8'd60) |			// istore_1
		(opcode_int[15:8] == 8'd61) |			// istore_2
		(opcode_int[15:8] == 8'd62) |			// istore_3
		(opcode_int[15:8] == 8'd67) |			// fstore_0
		(opcode_int[15:8] == 8'd68) |			// fstore_1
		(opcode_int[15:8] == 8'd69) |			// fstore_2
		(opcode_int[15:8] == 8'd70) |			// fstore_3
		(opcode_int[15:8] == 8'd75) |			// astore_0
		(opcode_int[15:8] == 8'd76) |			// astore_1
		(opcode_int[15:8] == 8'd77) |			// astore_2
		(opcode_int[15:8] == 8'd78) |			// astore_3
		(opcode_int[15:8] == 8'd87) |			// pop
		(opcode_int[15:8] == 8'd96) |			// iadd
		(opcode_int[15:8] == 8'd98) |			// fadd
		(opcode_int[15:8] == 8'd100) |			// isub
		(opcode_int[15:8] == 8'd102) |			// fsub
		(opcode_int[15:8] == 8'd104) |			// imul
		(opcode_int[15:8] == 8'd106) |			// fmul
		(opcode_int[15:8] == 8'd108) |			// idiv
		(opcode_int[15:8] == 8'd110) |			// fdiv
		(opcode_int[15:8] == 8'd112) |			// irem
		(opcode_int[15:8] == 8'd114) |			// frem
		(opcode_int[15:8] == 8'd120) |			// ishl
		((opcode_int[15:8] == 8'd121) & second_cyc) |	// lshl
		(opcode_int[15:8] == 8'd122) |			// ishr
		((opcode_int[15:8] == 8'd123) & second_cyc) |	// lshr
		(opcode_int[15:8] == 8'd124) |			// iushr
		((opcode_int[15:8] == 8'd125) & second_cyc) |	// lushr
		(opcode_int[15:8] == 8'd126) |			// iand
		(opcode_int[15:8] == 8'd128) |			// ior
		(opcode_int[15:8] == 8'd130) |			// ixor
		(opcode_int[15:8] == 8'd136) |			// l2i
		(opcode_int[15:8] == 8'd137) |			// l2f
		(opcode_int[15:8] == 8'd142) |			// d2i
		(opcode_int[15:8] == 8'd144) |			// d2f
		(opcode_int[15:8] == 8'd149) |			// fcmpl
		(opcode_int[15:8] == 8'd150) |			// fcmpg
		(opcode_int[15:8] == 8'd153) |			// ifeq
		(opcode_int[15:8] == 8'd154) |			// ifne
		(opcode_int[15:8] == 8'd155) |			// iflt
		(opcode_int[15:8] == 8'd156) |			// ifge
		(opcode_int[15:8] == 8'd157) |			// ifgt
		(opcode_int[15:8] == 8'd158) |			// ifle
		(opcode_int[15:8] == 8'd170) |			// tableswitch
		(opcode_int[15:8] == 8'd172) |			// ireturn
		(opcode_int[15:8] == 8'd174) |			// freturn
		(opcode_int[15:8] == 8'd176) |			// areturn
		(opcode_int[15:8] == 8'd194) |			// monitorenter
		(opcode_int[15:8] == 8'd195) |			// monitorexit
		(opcode_int[15:8] == 8'd198) |			// ifnull
		(opcode_int[15:8] == 8'd199) |			// ifnonnull
		(opcode_int[15:8] == 8'd211) |			// putstatic_quick
		(opcode_int[15:8] == 8'd229) |			// nunull_quick
		(opcode_int[15:8] == 8'd233) |			// aputstatic_quick
		(opcode_int[15:8] == 8'd243) |			// store_word_index
		(opcode_int[15:8] == 8'd244) |			// nastore_word_index
		(opcode_int[15:8] == 8'd245) |			// store_short_index
		(opcode_int[15:8] == 8'd246) |			// store_byte_index
		(ext_opcode & (opcode_int[7:0] == 8'd21)) |	// iucmp
		(ext_opcode & (opcode_int[7:0] == 8'd62)) |	// zero_line
		(ext_opcode & (opcode_int[7:0] == 8'd96)) |	// write_pc
		(ext_opcode & (opcode_int[7:0] == 8'd97) &
						second_cyc) |	// write_vars
		(ext_opcode & (opcode_int[7:0] == 8'd98) &
						second_cyc) |	// write_frame
		(ext_opcode & (opcode_int[7:0] == 8'd99) &
						second_cyc) |	// write_optop
		(ext_opcode & (opcode_int[7:0] == 8'd100) &
						second_cyc) |	// write_oplim
		(ext_opcode & (opcode_int[7:0] == 8'd101) &
						second_cyc) |	// write_const_pool
		(ext_opcode & (opcode_int[7:0] == 8'd102) &
						second_cyc) |	// priv_write_psr
		(ext_opcode & (opcode_int[7:0] == 8'd103) &
						second_cyc) |	// priv_write_trapbase
		(ext_opcode & (opcode_int[7:0] == 8'd104) &
						second_cyc) |	// priv_write_lockcount0
		(ext_opcode & (opcode_int[7:0] == 8'd105) &
						second_cyc) |	// priv_write_lockcount1
		(ext_opcode & (opcode_int[7:0] == 8'd108) &
						second_cyc) |	// priv_write_lockaddr0
		(ext_opcode & (opcode_int[7:0] == 8'd109) &
						second_cyc) |	// priv_write_lockaddr1
		(ext_opcode & (opcode_int[7:0] == 8'd112) &
						second_cyc) |	// priv_write_userrange1
		(ext_opcode & (opcode_int[7:0] == 8'd113) &
						second_cyc) |	// priv_write_gc_config
		(ext_opcode & (opcode_int[7:0] == 8'd114) &
						second_cyc) |	// priv_write_brk1a
		(ext_opcode & (opcode_int[7:0] == 8'd115) &
						second_cyc) |	// priv_write_brk2a
		(ext_opcode & (opcode_int[7:0] == 8'd116) &
						second_cyc) |	// priv_write_brk12c
		(ext_opcode & (opcode_int[7:0] == 8'd117) &
						second_cyc) |	// priv_write_userrange2
		(ext_opcode & (opcode_int[7:0] == 8'd121) &
						second_cyc) |	// priv_write_sc_bottom
		(ext_opcode & (opcode_int[7:0] == 8'd122)) |	// write_gl0
		(ext_opcode & (opcode_int[7:0] == 8'd123)) |	// write_gl1
		(ext_opcode & (opcode_int[7:0] == 8'd124)) |	// write_gl2
		(ext_opcode & (opcode_int[7:0] == 8'd125)) 	// write_gl3
	);

assign	inc_optop_2 = (

		((opcode_int[15:8] == 8'd55) & second_cyc) |	// lstore
		((opcode_int[15:8] == 8'd57) & second_cyc) |	// dstore
		((opcode_int[15:8] == 8'd63) & second_cyc) |	// lstore_0
		((opcode_int[15:8] == 8'd64) & second_cyc) |	// lstore_1
		((opcode_int[15:8] == 8'd65) & second_cyc) |	// lstore_2
		((opcode_int[15:8] == 8'd66) & second_cyc) |	// lstore_3
		((opcode_int[15:8] == 8'd71) & second_cyc) |	// dstore_0
		((opcode_int[15:8] == 8'd72) & second_cyc) |	// dstore_1
		((opcode_int[15:8] == 8'd73) & second_cyc) |	// dstore_2
		((opcode_int[15:8] == 8'd74) & second_cyc) |	// dstore_3
		(opcode_int[15:8] == 8'd88) |			// pop2
		((opcode_int[15:8] == 8'd97) & second_cyc) |	// ladd
		((opcode_int[15:8] == 8'd99) & second_cyc) |	// dadd
		((opcode_int[15:8] == 8'd101) & second_cyc) |	// lsub
		((opcode_int[15:8] == 8'd103) & second_cyc) |	// dsub
		((opcode_int[15:8] == 8'd107) & second_cyc) |	// dmul
		((opcode_int[15:8] == 8'd111) & second_cyc) |	// ddiv
		((opcode_int[15:8] == 8'd115) & second_cyc) |	// drem
		((opcode_int[15:8] == 8'd127) & second_cyc) |	// land
		((opcode_int[15:8] == 8'd129) & second_cyc) |	// lor
		((opcode_int[15:8] == 8'd131) & second_cyc) |	// lxor
		(opcode_int[15:8] == 8'd159) |			// if_icmpeq
		(opcode_int[15:8] == 8'd160) |			// if_icmpne
		(opcode_int[15:8] == 8'd161) |			// if_icmplt
		(opcode_int[15:8] == 8'd162) |			// if_icmpge
		(opcode_int[15:8] == 8'd163) |			// if_icmpgt
		(opcode_int[15:8] == 8'd164) |			// if_icmple
		(opcode_int[15:8] == 8'd165) |			// if_icmpeq
		(opcode_int[15:8] == 8'd166) |			// if_icmpne
		(opcode_int[15:8] == 8'd173) |			// lreturn
		(opcode_int[15:8] == 8'd175) |			// dreturn
		(opcode_int[15:8] == 8'd207) |			// putfield_quick
		(opcode_int[15:8] == 8'd213) |			// putstatic2_quick
		(opcode_int[15:8] == 8'd231) |			// aputfield_quick
		(ext_opcode & (opcode_int[7:0] == 8'd32)) |	// store_byte
		(ext_opcode & (opcode_int[7:0] == 8'd34)) |	// store_short
		(ext_opcode & (opcode_int[7:0] == 8'd36)) |	// store_word
		(ext_opcode & (opcode_int[7:0] == 8'd38)) |	// priv_write_dcache_tag
		(ext_opcode & (opcode_int[7:0] == 8'd39)) |	// priv_write_dcache_data
		(ext_opcode & (opcode_int[7:0] == 8'd42)) |	// store_short_oe
		(ext_opcode & (opcode_int[7:0] == 8'd44)) |	// store_word_oe
		(ext_opcode & (opcode_int[7:0] == 8'd46)) |	// priv_write_icache_tag
		(ext_opcode & (opcode_int[7:0] == 8'd47)) |	// priv_write_icache_data
		(ext_opcode & (opcode_int[7:0] == 8'd48)) |	// ncstore_byte
		(ext_opcode & (opcode_int[7:0] == 8'd50)) |	// ncstore_short
		(ext_opcode & (opcode_int[7:0] == 8'd52)) |	// ncstore_word
		(ext_opcode & (opcode_int[7:0] == 8'd58)) |	// ncstore_short_oe
		(ext_opcode & (opcode_int[7:0] == 8'd60)) 	// ncstore_word_oe
	);

assign	inc_optop_3 = (

		(opcode_int[15:8] == 8'd79) |			// iastore
		(opcode_int[15:8] == 8'd220) |			// aastore_quick
		(opcode_int[15:8] == 8'd81) |			// fastore
		(opcode_int[15:8] == 8'd84) |			// bastore
		(opcode_int[15:8] == 8'd85) |			// castore
		(opcode_int[15:8] == 8'd86) |			// sastore
		((opcode_int[15:8] == 8'd148) & second_cyc) |	// lcmp
		((opcode_int[15:8] == 8'd151) & second_cyc) |	// dcmpl
		((opcode_int[15:8] == 8'd152) & second_cyc) |	// dcmpg
		(opcode_int[15:8] == 8'd209) 			// putfield2_quick
	);

assign	inc_optop_4 = (

		(opcode_int[15:8] == 8'd80) |			// lastore
		(opcode_int[15:8] == 8'd82)			// dastore

	);

assign  no_change_optop = !(inc_optop_1 | inc_optop_2 | inc_optop_3 |
                            inc_optop_4 | dec_optop_1 | dec_optop_2 );
// BG2 op sometimes pushes 1 item onto stack and sometimes 2. Because of
// this it's difficult to determine the optop_offset just from group
// information. Hence we need  to decode BG2 and then use grouping
// info. to calculate the offset. For ex. for LV LB BG2 (group_3_r)
// If BG2 pushes one item onto stack, then decoding BG2 we'll get optop
// offset as +1 (it consumes 2 and pushes 1), but if we use the group info.
// (in this case group_3), then offset is -2 +1 (since 2 operands needed by
// BG2 are now available within the insgtruction itself  instead of popping
// them from scache. Same holds good for groups  5 and 6 (LV BG2 and LV BG1)


// So for groups 5 and 6 decrement the decode value of offset by 1 
// and for group 3 by 2 and so-on

assign	no_change = !(group_3_r | group_5_r | group_6_r);

// Since we don't have a 9_32 mux, we'll split them into 5_32 and 4_32 muxes
// and then use another 2_32 mux

assign	net_optop_sel1[4] = dec_optop_2 & (group_3_r); 			// optop - 4

assign	net_optop_sel1[3] = dec_optop_2 & (group_5_r | group_6_r) 		
				| dec_optop_1 & (group_3_r); 		// optop - 3

assign	net_optop_sel1[2] = dec_optop_2 & (no_change) |
				dec_optop_1 & (group_5_r | group_6_r) |
				no_change_optop & (group_3_r); 		// optop - 2

assign	net_optop_sel1[1] = dec_optop_1 & (no_change) |
			  	no_change_optop & (group_5_r | group_6_r) |
				inc_optop_1 & (group_3_r); 		// optop - 1

assign	net_optop_sel1[0] = !(|net_optop_sel1[4:1]);			// optop + 4


assign	net_optop_sel2[3] = inc_optop_3 & (no_change) |
				inc_optop_4 & (group_5_r | group_6_r) ;	// optop + 3

assign	net_optop_sel2[2] = inc_optop_2 & (no_change) |
				inc_optop_3 & (group_5_r | group_6_r) |
				inc_optop_4 & (group_3_r) ; 		// optop + 2

assign	net_optop_sel2[1] = inc_optop_1 & (no_change) |
				inc_optop_2 & (group_5_r | group_6_r) |
				inc_optop_3 & (group_3_r) ; 		// optop + 1

assign	net_optop_sel2[0] = !(|net_optop_sel2[3:1]);


assign	net_optop_sel[1] =  |(net_optop_sel1[4:1]) | inc_optop_4 & no_change;
assign	net_optop_sel[0] = !(net_optop_sel[1]);
				
endmodule
	
module	cmp_we_4 (

	in1,
	in2,
	enable,
	out
);

input	[3:0]	in1;
input	[3:0]	in2;
input		enable;
output		out;

assign	out = (in1 == in2) & enable;

endmodule

module pri_encod_3 (

	in0,
	in1,
	in2,
	out 
);

input		in0;
input		in1;
input		in2;
output	[2:0]	out;

assign	out[0] = in0;
assign	out[1] = !in0 & in1;
assign	out[2] = !in0 & !in1 & in2;

endmodule
