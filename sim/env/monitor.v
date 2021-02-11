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




 module monitor(
	pj_standby,
	pj_nmi,
	pj_irl,
	pj_halt,
	pj_resume,
	pj_clk,
	monitor_end_sim
	);

// driven by powerdown_monitor
output		pj_standby;
output		pj_nmi;
output	[3:0]	pj_irl;

// driven by trace_debug_monitor
output		pj_halt;
output		pj_resume;
output		pj_clk;

// end of simulation driven by monitors
output		monitor_end_sim;

wire		smu_monitor_end_sim;
wire		instr_monitor_end_sim;

assign monitor_end_sim = smu_monitor_end_sim | instr_monitor_end_sim;

always @(posedge monitor_end_sim) begin
  if (smu_monitor_end_sim === 1'b1)
    $display("smu monitor is ending the simulation now.");
  if (instr_monitor_end_sim === 1'b1)
    $display("instruction monitor is ending the simulation now.");
end

/* *******************************************
 * IBUFFER MONITOR:
 *
 * If +ibuf_mon option is used the ibuffer
 * state will be monitored.
 *
 * ***************************************** */
 
// ibuf_monitor
 
ibuf_monitor ibuf_monitor(
	.clk			(`PICOJAVAII.pj_clk),
	.num_val_byte		(`PICOJAVAII.`DESIGN.icu.icctl.ibuf_ctl.valid[15:0]),
	.num_rd_byte		(`PICOJAVAII.`DESIGN.iu_shift_d[7:0]),
	.nth_wr_byte_input	(~`PICOJAVAII.`DESIGN.icu.icctl.ibuf_ctl.ic_fill_sel[15:0]),
	.reset			(`PICOJAVAII.pj_reset)
	);


/* *******************************************
 * POWERDOWN MONITOR:
 *
 * The powerdown_monitor drives the pj_nmi,
 * pj_irl, and pj_standy signals.
 *
 * ***************************************** */
// powerdown monitor
 
powerdown_monitor powerdown_monitor(
	.pj_clk			(`PICOJAVAII.pj_clk),
	.pj_standby_out		(`PICOJAVAII.pj_standby_out),
	.pj_irl			(pj_irl[3:0]),
	.pj_nmi			(pj_nmi),
	.pj_standby		(pj_standby),
	.pj_address		(`PICOJAVAII.pj_address),
	.pj_tv			(`PICOJAVAII.pj_tv),
	.pj_reset		(`PICOJAVAII.pj_reset)
	);
 
/* *******************************************
 * Trace and Debug signals MONITOR:
 *
 * The trace_debug_monitor drives the pj_halt,
 * pj_resume, and pj_clk signals.
 *
 * ***************************************** */
// trace_debug_monitor monitor
 
trace_debug_monitor trace_debug_monitor(
	.sys_clk		(`PICOJAVAII.sys_clk),
	.pj_halt		(pj_halt),
	.pj_resume		(pj_resume),
	.pj_brk1_sync		(`PICOJAVAII.pj_brk1_sync),
	.pj_brk2_sync		(`PICOJAVAII.pj_brk2_sync),
	.pj_in_halt		(`PICOJAVAII.pj_in_halt),
	.pj_inst_complete	(`PICOJAVAII.pj_inst_complete),
	.pj_clk			(pj_clk)
	);
 
bus_monitor  bus_monitor(
	.clk			(pj_clk),
	.reset			(`PICOJAVAII.pj_reset),
	.pj_tv			(`PICOJAVAII.pj_tv),
	.pj_type		(`PICOJAVAII.pj_type[3:0]),
	.pj_size		(`PICOJAVAII.pj_size),
	.pj_ack			(`PICOJAVAII.pj_ack),
	.pj_data_in		(`PICOJAVAII.pj_data_in),
	.pj_data_out		(`PICOJAVAII.pj_data_out),
	.pj_standby_out		(`PICOJAVAII.pj_standby_out),
	.pj_address		(`PICOJAVAII.pj_address)
	);
 

 
smu_monitor smu_monitor(
	.pj_clk			(pj_clk),
	.pj_reset		(`PICOJAVAII.pj_reset),
	.und_flw_bit		(`PICOJAVAII.`DESIGN.smu.smu_dpath.und_flw_bit),
	.num_entries		(`PICOJAVAII.`DESIGN.smu.smu_ctl.num_entries[29:0]),
	.fill_d			(`PICOJAVAII.`DESIGN.smu.smu_ctl.fill_d),
	.spill_d		(`PICOJAVAII.`DESIGN.smu.smu_ctl.spill_d),
	.und_flw_d		(`PICOJAVAII.`DESIGN.smu.smu_ctl.und_flw_d),
	.ovr_flw_d		(`PICOJAVAII.`DESIGN.smu.smu_ctl.ovr_flw_d),
	.low_mark		(`PICOJAVAII.`DESIGN.smu.smu_ctl.low_mark[5:0]),
	.high_mark		(`PICOJAVAII.`DESIGN.smu.smu_ctl.high_mark[5:0]),
	.less_than_6		(`PICOJAVAII.`DESIGN.smu.smu_ctl.less_than_6),
	.dribble_stall		(`PICOJAVAII.`DESIGN.smu.smu_ctl.dribble_stall),
	.smu_st			(`PICOJAVAII.`DESIGN.smu.smu_st),
	.smu_data		(`PICOJAVAII.`DESIGN.smu.smu_data[31:0]),
	.smu_data_vld		(`PICOJAVAII.`DESIGN.smu.smu_data_vld),
	.dcu_data		(`PICOJAVAII.`DESIGN.smu.dcu_data[31:0]),
	.spill			(`PICOJAVAII.`DESIGN.smu.smu_ctl.spill),
	.fill			(`PICOJAVAII.`DESIGN.smu.smu_ctl.fill),
	.iu_int			(`PICOJAVAII.`DESIGN.smu.smu_ctl.iu_int),
	.dcu_smu_st		(`PICOJAVAII.`DESIGN.dcu.smu_st),
	.dcu_smu_data		(`PICOJAVAII.`DESIGN.dcu.smu_data[31:0]),
	.smu_monitor_end_sim	(smu_monitor_end_sim),
	.smu_sbase_we		(`PICOJAVAII.`DESIGN.smu.smu_ctl.smu_sbase_we),
	.smu_we			(`PICOJAVAII.`DESIGN.smu.smu_ctl.smu_we),
	.load_w			(`PICOJAVAII.`DESIGN.smu.smu_ctl.load_w),
	.squash_fill		(`PICOJAVAII.`DESIGN.smu.smu_ctl.squash_fill),
	.smu_sbase		(`PICOJAVAII.`DESIGN.smu.smu_dpath.smu_sbase)
);
 
// Module FPU Monitor
fpu_mon fpu_mon (
	.pj_clk			(`PICOJAVAII.`DESIGN.fpu.clk),
	.fpain			(`PICOJAVAII.`DESIGN.fpu.fpain[31:0]),
	.fpbin			(`PICOJAVAII.`DESIGN.fpu.fpbin[31:0]),
	.fpop			(`PICOJAVAII.`DESIGN.fpu.fpop[7:0]),
	.fpbusyn		(`PICOJAVAII.`DESIGN.fp_rdy_e),
	.fpkill			(`PICOJAVAII.`DESIGN.fpu.fpkill),
	.fpout			(`PICOJAVAII.`DESIGN.fpu_data_e[31:0]),
	.fphold			(`PICOJAVAII.`DESIGN.fpu.fphold),
	.fpop_valid		(`PICOJAVAII.`DESIGN.fpu.fpop_valid)
);
 
// Instn. Folding Monitor
fold_monitor	fold_monitor(
	.clk			(pj_clk)
);
 
// DCU  Monitor
dcu_mon  dcu_mon(
        .clk                    (pj_clk),
        .clk_count              (`PICOJAVAII.clk_count),
        .dc_inst_c              (`PICOJAVAII.`DESIGN.dcu.dcctl.dc_inst_c),
        .iu_inst_c              (`PICOJAVAII.`DESIGN.dcu.dcctl.dc_dec.iu_inst_c[7:0]),
        .smu_inst_c             (`PICOJAVAII.`DESIGN.dcu.dcctl.dc_dec.smu_inst_c[3:0]),
        .dcu_addr_c             (`PICOJAVAII.`DESIGN.dcu.dcu_dpath.dcu_addr_c[31:0]),
        .dcu_data_c             (`PICOJAVAII.`DESIGN.dcu.dcu_dpath.dcu_data_c[31:0]),
        .dcu_data               (`PICOJAVAII.`DESIGN.dcu.dcu_data[31:0]),
        .iu_data_vld            (`PICOJAVAII.`DESIGN.dcu.iu_data_vld),
        .smu_data_vld           (`PICOJAVAII.`DESIGN.dcu.smu_data_vld)
);

// Statistics Monitor
statistics_monitor	statistics_monitor(
	.pj_clk			(pj_clk),
	.num_entries		(`PICOJAVAII.`DESIGN.smu.smu_ctl.num_entries[29:0]),
	.smu_hold		(`PICOJAVAII.`DESIGN.smu_hold),
	// .pj_hold		(`PICOJAVAII.`DESIGN.iu.pj_hold),
	.endsim			(`PICOJAVAII.end_of_simulation)
);
 
// Microcode monitor

`define UCODE		`PICOJAVAII.`DESIGN.iu.ucode

ucode_monitor 		ucode_monitor(
	.clk			(pj_clk),
	.reset_l		(`PICOJAVAII.biu.reset_l),
	.u_addr_st_wt		(`PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.dest_addr_e[31:0]),
	.u_addr_st_rd		(`UCODE.u_addr_st_rd[31:0]),
	.dreg_data		(`UCODE.dreg[31:0]),
	.ucode_addr_d		(`UCODE.ucode_addr_d[31:0]),
	.u_f01_wt_stk		(`UCODE.u_f01_wt_stk),
	.u_f02_rd_stk		(`UCODE.u_f02_rd_stk),
	.u_f00			(`UCODE.u_f00),
	.u_f01			(`UCODE.u_f01[2:0]),
	.u_f02			(`UCODE.u_f02[1:0]),
	.u_f03			(`UCODE.u_f03[1:0]),
	.u_f04			(`UCODE.u_f04[6:0]),
	.u_f05			(`UCODE.u_f05[2:0]),
	.u_f06			(`UCODE.ucode_dpath_0.u_f06[3:0]),
	.u_f07			(`UCODE.ucode_dpath_0.u_f07[1:0]),
	.u_f08			(`UCODE.ucode_dpath_0.u_f08[2:0]),
	.u_f09			(`UCODE.ucode_dpath_0.u_f09[2:0]),
	.u_f10			(`UCODE.ucode_dpath_0.u_f10[2:0]),
	.u_f11			(`UCODE.ucode_dpath_0.u_f11[2:0]),
	.u_f12			(`UCODE.ucode_dpath_0.u_f12[1:0]),
	.u_f13			(`UCODE.ucode_dpath_0.u_f13[1:0]),
	.u_f14			(`UCODE.ucode_dpath_0.u_f14[1:0]),
	.u_f15			(`UCODE.ucode_dpath_0.u_f15),
	.u_f16			(`UCODE.ucode_dpath_0.u_f16[1:0]),
	.u_f17			(`UCODE.u_f17[1:0]),
	.u_f18			(`UCODE.u_f18[11:0]),
	.u_f19			(`UCODE.ucode_dpath_0.u_f19[3:0]),
	.u_f20			(`UCODE.ucode_dpath_0.u_f20[3:0]),
	.u_f21			(`UCODE.u_f21[1:0]),
	.u_f22			(`UCODE.ucode_dpath_0.u_f22),
	.u_done			(`UCODE.u_done),
	.u_last			(`UCODE.u_last),
	.ucode_porta		(`UCODE.ucode_porta[31:0]),
	.ucode_portc		(`UCODE.ucode_portc[31:0]),
	.u_ref_null_c		(`PICOJAVAII.`DESIGN.iu.u_ref_null_c),
	.u_ary_ovf_c		(`PICOJAVAII.`DESIGN.iu.u_ary_ovf_c),
	.gc_trap_c		(`PICOJAVAII.`DESIGN.iu.gc_trap_c),
	.u_ptr_un_eq_c		(`PICOJAVAII.`DESIGN.iu.u_ptr_un_eq_c),
	.u_abt_rdwt		(`UCODE.u_abt_rdwt),
	.ie_stall_ucode		(`UCODE.ie_stall_ucode),
	.u_exception		(`UCODE.ucode_ctrl_0.ucode_seq_0.u_exception),
	.nxt_ucode_last		(`UCODE.ucode_ctrl_0.ucode_seq_0.nxt_ucode_last),
	.reg_enable		(`UCODE.ucode_ctrl_0.ucode_seq_0.reg_enable),
	.optop			(`PICOJAVAII.`DESIGN.iu.ex.ex_regs.optop_w[31:0]),
	.vars			(`PICOJAVAII.`DESIGN.iu.lvars[31:0]),
	.ucode_cnt		(`UCODE.ucode_dpath_0.nxt_ucode_cnt[8:0]),
	.iu_trap_r		(`UCODE.iu_trap_r),
	.ifu_op_valid_r		(`UCODE.valid_op_r),
	.frame			(`PICOJAVAII.`DESIGN.iu.ex.ex_regs.frame_w[31:0]),
	.cp			(`PICOJAVAII.`DESIGN.iu.ex.ex_regs.const_pool_w[31:0]),
	.invokestatic_quick	(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.invokestatic_quick),
	.invokenonvirtual_quick	(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.invokenonvirtual_quick),
	.invokevirtual_quick	(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.invokevirtualobject_quick),
	.invokevirtualobject_quick	(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.invokevirtualobject_quick),
	.invokevirtual_quick_w	(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.invokevirtual_quick_w),
	.invokesuper_quick	(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.invokesuper_quick),
	.soft_trap		(`PICOJAVAII.`DESIGN.iu.ex.ex_ctl.soft_trap),
	.se			(1'b0),
	.hold_e			(`PICOJAVAII.`DESIGN.iu.hold_logic.hold_e),
	.opcode_1_op_r		(`UCODE.opcode_1_op_r[7:0]),
	.valid_op_r		(`UCODE.valid_op_r),
	.iu_hold_e		(`UCODE.iu_hold_e)
);





// instruction monitor
instruction_monitor	instruction_monitor(
	.clk		(pj_clk),
	.opcode_1	(`PICOJAVAII.`DESIGN.iu.opcode_1_op_r[7:0]),
	.opcode_2	(`PICOJAVAII.`DESIGN.iu.opcode_2_op_r[7:0]),
	.valid_op	(`PICOJAVAII.`DESIGN.iu.pipe.pipe_cntl.valid_r),
	.endsim		(instr_monitor_end_sim)
);

// trap monitor
trap_monitor		trap_monitor();

// i/o pin monitor
io_pin_monitor		io_pin_monitor(
	.pj_reset		(`PICOJAVAII.pj_reset),
	.pj_reset_out		(`PICOJAVAII.pj_reset_out),
	.pj_clk			(pj_clk),
	.pj_clk_out		(`PICOJAVAII.pj_clk_out),
	.pj_irl			(`PICOJAVAII.pj_irl[3:0]),
	.pj_nmi			(`PICOJAVAII.pj_nmi),
	.pj_boot8		(`PICOJAVAII.pj_boot8),
	.pj_su			(`PICOJAVAII.pj_su),
	.pj_standby		(`PICOJAVAII.pj_standby),
	.pj_standby_out		(`PICOJAVAII.pj_standby_out),
	.pj_no_fpu		(`PICOJAVAII.pj_no_fpu),
	.pj_scan_out		(`PICOJAVAII.pj_scan_out),
	.pj_scan_mode		(`PICOJAVAII.pj_scan_mode),
	.pj_scan_in		(`PICOJAVAII.pj_scan_in),
	.pj_data_in		(`PICOJAVAII.pj_data_in[31:0]),
	.pj_data_out		(`PICOJAVAII.pj_data_out[31:0]),
	.pj_address		(`PICOJAVAII.pj_address[29:0]),
	.pj_size		(`PICOJAVAII.pj_size[1:0]),
	.pj_type		(`PICOJAVAII.pj_type[3:0]),
	.pj_tv			(`PICOJAVAII.pj_tv),
	.pj_ale			(`PICOJAVAII.pj_ale),
	.pj_ack			(`PICOJAVAII.pj_ack),
	.pj_halt		(`PICOJAVAII.pj_halt),
	.pj_resume		(`PICOJAVAII.pj_resume),
	.pj_brk1_sync		(`PICOJAVAII.pj_brk1_sync),
	.pj_brk2_sync		(`PICOJAVAII.pj_brk2_sync),
	.pj_in_halt		(`PICOJAVAII.pj_in_halt),
	.pj_inst_complete	(`PICOJAVAII.pj_inst_complete),
	.end_of_simulation	(`PICOJAVAII.end_of_simulation)
);
 
// performance analysis monitor
performance_monitor performance_monitor (
         .pj_clk (`PICOJAVAII.pj_clk),
         .end_of_simulation (`PICOJAVAII.end_of_simulation)
);
// activity analysis monitor
activity_monitor activity_monitor (
         .pj_clk (`PICOJAVAII.pj_clk),
         .end_of_simulation (`PICOJAVAII.end_of_simulation)
);



endmodule
