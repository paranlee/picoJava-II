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

module rcu (

	iu_optop_e,
	iu_lvars,
	iu_sc_bottom,
	ucode_addr_s,
	ucode_areg0,
	ex_adder_out_e,
	ucode_dest_we,
	ucode_dest_sel,
	ucode_active,
	opcode_1_rs1_r,
	opcode_2_rs1_r,
	offset_1_rs1_r,
	offset_2_rs1_r,
	valid_rs1_r,
	help_rs1_r,	
	type_rs1_r,
	lvars_acc_rs1_r,
	st_index_op_rs1_r,
	lv_rs1_r,
	reverse_ops_rs1_r,
	update_optop_r,
	opcode_1_rs2_r,
	opcode_2_rs2_r,	
	offset_1_rs2_r,
	offset_2_rs2_r,
	valid_rs2_r,
	lvars_acc_rs2_r,
	lv_rs2_r,
	valid_op_r,
	put_field2_quick_r,
	hold_ucode,
	hold_e,
	hold_c,
	iu_data_w,
	smu_data,
	iu_smu_data,
	smu_rf_addr,
	smu_we,
	offset_rsd_r,
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
	inst_vld,
	ucode_done,
	iu_trap_r,
	sin,
	sm,
	clk,
	reset_l,
	rs1_data_e,
	rs2_data_e,
	scache_rd_miss_e,
	scache_miss_addr_e,
	optop_offset,
	rs1_forward_mux_sel,
	rs2_forward_mux_sel,
	dest_addr_w,
	scache_wr_miss_w,
	iu_smu_flush,
	first_cycle,
	second_cycle,
	first_vld_c,
	inst_complete_w,
	so

);

input   [31:0]  iu_optop_e;             // optop from e-stage
input   [31:0]  iu_lvars;               // local var. reg
input   [31:0]  iu_sc_bottom;           // sc_bottom register
input   [31:0]  ucode_addr_s;           // ucode address to access stack cache
input           ucode_active;           // This signal indicates that ucode want to acess
                                        // scache
input   [31:0]  ucode_areg0;        	// // ucode areg data to be used as dest addr
input   [31:0]  ex_adder_out_e;         // ex adder out to be used as dest addr
input   	ucode_dest_we;        	// corresponding we signal to scache
input   	ucode_dest_sel;        	// ucode_dest_sel -> 1: Use adder_out_e as the address, else
                                        // use ucode_areg0
input   [7:0]   opcode_1_rs1_r;         // 1st byte of opcode in RS1 stage
input   [7:0]   opcode_2_rs1_r;         // 2nd byte of opcode in RS1 stage
input	[7:0]	offset_1_rs1_r;		// 1st byte of offset in RS1 stage
input	[7:0]	offset_2_rs1_r;		// 1st byte of offset in RS1 stage
input           valid_rs1_r;            // Inicates that the opcode in RS1 is valid
input           help_rs1_r;             // Indicates multi-rstage op. in RS1
input   [7:0]   type_rs1_r;             // indicates the type of long op in rs1
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
input           lvars_acc_rs1_r;        // This signal is asserted for all operations
                                        // which access scache using lvars reg in RS1
input		st_index_op_rs1_r;	// This tells that there's a st*_index op in RS1
input           lv_rs1_r;               // Indicates that there's a pure LV op in RS1
input		reverse_ops_rs1_r;	// Used to fix an Xface problem between FPU and IU
input		update_optop_r;		// Indicates thata there's a update_optop in RS1
input   [7:0]   opcode_1_rs2_r;         // 1st byte of opcode in RS2 stage
input   [7:0]   opcode_2_rs2_r;         // 2nd byte of ocpode in RS2 stage
input	[7:0]	offset_1_rs2_r;		// 1st byte of offset in RS2 stage
input	[7:0]	offset_2_rs2_r;		// 1st byte of offset in RS2 stage
input           valid_rs2_r;            // Indicates a valid opcode in RS2 stage
input           lvars_acc_rs2_r;        // This signal is asserted for all operations
                                        // wich access scache using lvars reg in RS2
input           lv_rs2_r;               // Indicates that there's a pure LV op in RS2
input           valid_op_r;          	// Indicates a valid opcode in OP
input		put_field2_quick_r;	// Indicates a put_field2_quick operation
input		hold_ucode;		// Ucode is held
input		hold_e;			// Signal from pipeline control which holds e-stage
input		hold_c;			// Signal from pipeline control which holds c-stage
input   [31:0]  iu_data_w;              // Data to be written onto scache
input   [31:0]  smu_data;               // Data from dribbler to be written onto scache
output  [31:0]  iu_smu_data;            // Data output from scache to dribbler
input   [5:0]   smu_rf_addr;            // dribbler address to scache
input           smu_we;                 // scache write enable signal from dribbler
input	[7:0]	offset_rsd_r;           // offset in RSd stage
input	[7:0]	opcode_1_op_r;          // First byte of OP
input	[7:0]	opcode_2_op_r;          // Second byte of OP
input	[7:0]	opcode_1_rsd_r;         // First byte of RSd
input	[7:0]	opcode_2_rsd_r;         // Second byte of RSd
input		valid_rsd_r;		// Indicates a valid MEM op in rsd + long and dstores
input           group_1_r;              // Indicates a group 1 folding
input           group_2_r;              // Indicates a group 2 folding
input           group_3_r;              // Indicates a group 3 folding
input           group_4_r;              // Indicates a group 4 folding
input           group_5_r;              // Indicates a group 5 folding
input           group_6_r;              // Indicates a group 6 folding
input           group_7_r;              // Indicates a group 7 folding
input           group_9_r;              // Indicates a group 8 folding
input		no_fold_r;		// Indicates no folding
input	[2:0]	inst_vld;		// [2] -> Valid Inst in W, [1] in C stage and soon
input		ucode_done;		// Indicates that ucode is done
input		iu_trap_r;		// Indicates a trap in R-stage
input		sin;			// RCU Scan In Port
input		sm;			// RCU Scan Enable Port
input           clk;                    // Clock
input           reset_l;                  // Reset
output  [31:0]  rs1_data_e;             // Data output from RS1 stage
output  [31:0]  rs2_data_e;             // Data output from RS2 stage
output          scache_rd_miss_e;       // scache miss in RS1 or RS2 stage
output 	[31:0]  scache_miss_addr_e;     // Addr. to access d$ in case of s$ read miss
output	[31:0]	optop_offset;		// Indicates optop +/- net change
output  [3:0]   rs1_forward_mux_sel;    // 3-> forward from W, 2 from C and so-on
output  [3:0]   rs2_forward_mux_sel;    // 3-> forward from W, 2 from C and so-on
output		scache_wr_miss_w;       // Indicates that there's a scache write miss
output [31:0]   dest_addr_w;            // Indicates the address of scache write miss
output          iu_smu_flush;           // Flush the stores/loads in the dribbler pipeline
output          first_cycle;            // First cycle of a multi-rstage op
output		second_cycle;		// Indicates 2nd cycle of 2 cycle r-stage op
output		first_vld_c;		// Used to hold pipe appropriately for fpu ops
output		inst_complete_w;	// Indicates that instr. is complete (in W-stage)
output		so;			// RCU Scan Out Port


wire   	[3:0]	gl_sel_rs1;             
wire   	[5:0]   const_sel_1_rs1;        
wire   	[6:0]   const_sel_2_rs1;        
wire   	[2:0]   const_gl_sel_rs1;       
wire   	[4:0]   scache_addr_sel_rs1;    
wire   	[1:0]   final_data_sel_rs1;     
wire   	[3:0]   gl_sel_rs2;             
wire   	[5:0]   const_sel_1_rs2;        
wire   	[6:0]   const_sel_2_rs2;        
wire   	[2:0]   const_gl_sel_rs2;       
wire   	[4:0]   scache_addr_sel_rs2;    
wire   	[1:0]   final_data_sel_rs2;     
wire	[7:0]	optop_incr_sel;
wire	[2:0]	dest_addr_sel_r;
wire	[2:0]	dest_addr_sel_e;
wire	[5:0]	optop_offset_sel_r;
wire	[4:0]	net_optop_sel1;
wire	[3:0]	net_optop_sel2;
wire	[1:0]	net_optop_sel;
wire		iu_smu_flush_le;
wire		iu_smu_flush_ge;
wire		sc_wr_addr_gr_scbot;
wire		enable_cmp_e_rs1;
wire		enable_cmp_c_rs1;
wire		enable_cmp_w_rs1;
wire		enable_cmp_e_rs2;
wire		enable_cmp_c_rs2;
wire		enable_cmp_w_rs2;
wire		sc_miss_rs1_int;
wire		sc_miss_rs2_int;
wire		bypass_scache_rs1_e;
wire		bypass_scache_rs1_c;
wire		bypass_scache_rs1_w;
wire		bypass_scache_rs2_e;
wire		bypass_scache_rs2_c;
wire		bypass_scache_rs2_w;
wire		gl_reg0_we_w;
wire		gl_reg1_we_w;
wire		gl_reg2_we_w;
wire		gl_reg3_we_w;
wire		iu_data_we_w;

rcu_dpath	rcu_dpath (.iu_sc_bottom(iu_sc_bottom),
			.iu_optop_e(iu_optop_e),
			.iu_lvars(iu_lvars),
			.ucode_addr_s(ucode_addr_s),
			.ucode_areg0(ucode_areg0),
			.ex_adder_out_e(ex_adder_out_e),
			.offset_1_rs1_r(offset_1_rs1_r),
			.offset_2_rs1_r(offset_2_rs1_r),
			.offset_1_rs2_r(offset_1_rs2_r),
			.offset_2_rs2_r(offset_2_rs2_r),
			.gl_sel_rs1(gl_sel_rs1),
			.const_sel_1_rs1(const_sel_1_rs1),
			.const_sel_2_rs1(const_sel_2_rs1),
			.const_gl_sel_rs1(const_gl_sel_rs1),
			.scache_addr_sel_rs1(scache_addr_sel_rs1),
			.final_data_sel_rs1(final_data_sel_rs1),
			.gl_sel_rs2(gl_sel_rs2),
			.const_sel_1_rs2(const_sel_1_rs2),
			.const_sel_2_rs2(const_sel_2_rs2),
			.const_gl_sel_rs2(const_gl_sel_rs2),
			.scache_addr_sel_rs2(scache_addr_sel_rs2),
			.final_data_sel_rs2(final_data_sel_rs2),
			.offset_rsd_r(offset_rsd_r),
        		.optop_incr_sel(optop_incr_sel),
        		.dest_addr_sel_r(dest_addr_sel_r),
        		.dest_addr_sel_e(dest_addr_sel_e),
        		.optop_offset_sel_r(optop_offset_sel_r),
        		.net_optop_sel1(net_optop_sel1),
        		.net_optop_sel2(net_optop_sel2),
        		.net_optop_sel(net_optop_sel),
        		.gl_reg0_we_w(gl_reg0_we_w),
        		.gl_reg1_we_w(gl_reg1_we_w),
        		.gl_reg2_we_w(gl_reg2_we_w),
        		.gl_reg3_we_w(gl_reg3_we_w),
			.hold_ucode(hold_ucode),
			.hold_e(hold_e),
			.hold_c(hold_c),
			.iu_data_w(iu_data_w),
			.iu_data_we_w(iu_data_we_w),
			.smu_data(smu_data),
			.smu_rf_addr(smu_rf_addr),
			.smu_we(smu_we),
			.sc_miss_rs1_int(sc_miss_rs1_int),
			.sc_miss_rs2_int(sc_miss_rs2_int),
			.enable_cmp_e_rs1(enable_cmp_e_rs1),
        		.enable_cmp_c_rs1(enable_cmp_c_rs1),
			.enable_cmp_w_rs1(enable_cmp_w_rs1),
			.enable_cmp_e_rs2(enable_cmp_e_rs2),
        		.enable_cmp_c_rs2(enable_cmp_c_rs2),
			.enable_cmp_w_rs2(enable_cmp_w_rs2),
			.scache_wr_miss_w(scache_wr_miss_w),
			.sin(),
			.sm(),
			.clk(clk),
			.iu_smu_data(iu_smu_data),
			.rs1_data_e(rs1_data_e),
			.rs2_data_e(rs2_data_e),
			.optop_offset(optop_offset),
			.scache_miss_addr_e(scache_miss_addr_e),
			.bypass_scache_rs1_e(bypass_scache_rs1_e),
       			.bypass_scache_rs1_c(bypass_scache_rs1_c),
        		.bypass_scache_rs1_w(bypass_scache_rs1_w),
        		.bypass_scache_rs2_e(bypass_scache_rs2_e),
        		.bypass_scache_rs2_c(bypass_scache_rs2_c),
        		.bypass_scache_rs2_w(bypass_scache_rs2_w),
			.sc_wr_addr_gr_scbot(sc_wr_addr_gr_scbot),
			.dest_addr_w(dest_addr_w),
			.iu_smu_flush_le(iu_smu_flush_le),
			.iu_smu_flush_ge(iu_smu_flush_ge),
			.so() );

rcu_ctl		rcu_ctl (.opcode_1_rs1_r(opcode_1_rs1_r),
		        .opcode_2_rs1_r(opcode_2_rs1_r),
			.valid_rs1_r(valid_rs1_r),
			.help_rs1_r(help_rs1_r),
			.type_rs1_r(type_rs1_r),
			.st_index_op_rs1_r(st_index_op_rs1_r),
			.lvars_acc_rs1(lvars_acc_rs1_r),
			.lv_rs1_r(lv_rs1_r),
			.reverse_ops_rs1_r(reverse_ops_rs1_r),
			.update_optop_r(update_optop_r),
			.ucode_active(ucode_active),
			.ucode_dest_we(ucode_dest_we),
			.ucode_dest_sel(ucode_dest_sel),
			.opcode_1_rs2_r(opcode_1_rs2_r),
			.opcode_2_rs2_r(opcode_2_rs2_r),
			.valid_rs2_r(valid_rs2_r),
			.lvars_acc_rs2(lvars_acc_rs2_r),
			.lv_rs2_r(lv_rs2_r),
			.valid_op_r(valid_op_r),
			.opcode_1_op_r(opcode_1_op_r),
        		.opcode_2_op_r(opcode_2_op_r),
			.opcode_1_rsd_r(opcode_1_rsd_r),
        		.opcode_2_rsd_r(opcode_2_rsd_r),
        		.valid_rsd_r(valid_rsd_r),
        		.group_1_r(group_1_r),
        		.group_2_r(group_2_r),
        		.group_3_r(group_3_r),
        		.group_4_r(group_4_r),
        		.group_5_r(group_5_r),
        		.group_6_r(group_6_r),
        		.group_7_r(group_7_r),
        		.group_9_r(group_9_r),
        		.no_fold_r(no_fold_r),
			.put_field2_quick_r(put_field2_quick_r),
        		.hold_e(hold_e),
        		.hold_c(hold_c),
			.hold_ucode(hold_ucode),
			.inst_vld(inst_vld),
			.bypass_scache_rs1_e(bypass_scache_rs1_e),
        		.bypass_scache_rs1_c(bypass_scache_rs1_c),
        		.bypass_scache_rs1_w(bypass_scache_rs1_w),
        		.bypass_scache_rs2_e(bypass_scache_rs2_e),
        		.bypass_scache_rs2_c(bypass_scache_rs2_c),
        		.bypass_scache_rs2_w(bypass_scache_rs2_w),
			.sc_wr_addr_gr_scbot(sc_wr_addr_gr_scbot),
			.iu_smu_flush_le(iu_smu_flush_le),
			.iu_smu_flush_ge(iu_smu_flush_ge),
			.ucode_done(ucode_done),
			.iu_trap_r(iu_trap_r),
			.sin(),
			.sm(),
			.clk(clk),
			.reset_l(reset_l),
			.gl_sel_rs1(gl_sel_rs1),
			.const_sel_1_rs1(const_sel_1_rs1),
			.const_sel_2_rs1(const_sel_2_rs1),
			.const_gl_sel_rs1(const_gl_sel_rs1),
			.scache_addr_sel_rs1(scache_addr_sel_rs1),
			.final_data_sel_rs1(final_data_sel_rs1),
			.gl_sel_rs2(gl_sel_rs2),
			.const_sel_1_rs2(const_sel_1_rs2),
			.const_sel_2_rs2(const_sel_2_rs2),
			.const_gl_sel_rs2(const_gl_sel_rs2),
			.scache_addr_sel_rs2(scache_addr_sel_rs2),
			.final_data_sel_rs2(final_data_sel_rs2),
			.scache_rd_miss_e(scache_rd_miss_e),
			.optop_incr_sel(optop_incr_sel),
        		.dest_addr_sel_r(dest_addr_sel_r),
        		.dest_addr_sel_e(dest_addr_sel_e),
        		.net_optop_sel1(net_optop_sel1),
        		.net_optop_sel2(net_optop_sel2),
        		.net_optop_sel(net_optop_sel),
        		.optop_offset_sel_r(optop_offset_sel_r),
			.enable_cmp_e_rs1(enable_cmp_e_rs1),
        		.enable_cmp_c_rs1(enable_cmp_c_rs1),
			.enable_cmp_w_rs1(enable_cmp_w_rs1),
			.enable_cmp_e_rs2(enable_cmp_e_rs2),
        		.enable_cmp_c_rs2(enable_cmp_c_rs2),
			.enable_cmp_w_rs2(enable_cmp_w_rs2),
        		.iu_data_we_w(iu_data_we_w),
			.sc_miss_rs1_int(sc_miss_rs1_int),	
			.sc_miss_rs2_int(sc_miss_rs2_int),	
        		.gl_reg0_we_w(gl_reg0_we_w),
        		.gl_reg1_we_w(gl_reg1_we_w),
        		.gl_reg2_we_w(gl_reg2_we_w),
        		.gl_reg3_we_w(gl_reg3_we_w),
			.rs1_forward_mux_sel(rs1_forward_mux_sel),
			.rs2_forward_mux_sel(rs2_forward_mux_sel),
			.scache_wr_miss_w(scache_wr_miss_w),
			.iu_smu_flush(iu_smu_flush),
			.second_cycle(second_cycle),
			.first_cycle(first_cycle),
			.first_vld_c(first_vld_c),
			.inst_complete_w(inst_complete_w),
			.so() );
			

endmodule
