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

// Microcode monitor


`include "../../design/iu/ucode/rtl/ucode.h"

module ucode_monitor(
	clk,
	reset_l,
	u_addr_st_wt,
	u_addr_st_rd,
	dreg_data,
	ucode_addr_d,
	u_f01_wt_stk,
	u_f02_rd_stk,
	u_f00,
	u_f01,
	u_f02,
	u_f03,
	u_f04,
	u_f05,
	u_f06,
	u_f07,
	u_f08,
	u_f09,
	u_f10,
	u_f11,
	u_f12,
	u_f13,
	u_f14,
	u_f15,
	u_f16,
	u_f17,
	u_f18,
	u_f19,
	u_f20,
	u_f21,
	u_f22,
	u_done,
	u_last,
	ucode_porta,
	ucode_portc,
	u_ref_null_c,
	u_ary_ovf_c,
	gc_trap_c,
	u_ptr_un_eq_c,
	u_abt_rdwt,
	ie_stall_ucode,
	u_exception,
	nxt_ucode_last,
	reg_enable,
	optop,
	vars,
	ucode_cnt,
	iu_trap_r,
	ifu_op_valid_r,
	frame,
	cp,
	invokestatic_quick,
	invokenonvirtual_quick,
	invokevirtual_quick,
	invokevirtualobject_quick,
	invokevirtual_quick_w,
	invokesuper_quick,
	soft_trap,
	se,
	hold_e,
	opcode_1_op_r,
	valid_op_r,
	iu_hold_e
);

input		clk;
input		reset_l;
input	[31:0]	u_addr_st_wt;
input	[31:0]	u_addr_st_rd;
input	[31:0]	dreg_data;
input	[31:0]	ucode_addr_d;
input		u_f01_wt_stk;
input		u_f02_rd_stk;
input	[1:0]	u_f00;
input	[2:0]	u_f01;
input	[1:0]	u_f02;
input	[1:0]	u_f03;
input	[6:0]	u_f04;
input	[2:0]	u_f05;
input	[3:0]	u_f06;
input	[1:0]	u_f07;
input	[2:0]	u_f08;
input	[2:0]	u_f09;
input	[2:0]	u_f10;
input	[2:0]	u_f11;
input	[1:0]	u_f12;
input	[1:0]	u_f13;
input	[1:0]	u_f14;
input		u_f15;
input	[1:0]	u_f16;
input	[1:0]	u_f17;
input	[11:0]	u_f18;
input	[3:0]	u_f19;
input	[3:0]	u_f20;
input	[1:0]	u_f21;
input		u_f22;
input		u_done;
input		u_last;
input	[31:0]	ucode_porta;
input	[31:0]	ucode_portc;
input		u_ref_null_c;
input		u_ary_ovf_c;
input		gc_trap_c;
input		u_ptr_un_eq_c;
input		u_abt_rdwt;
input		ie_stall_ucode;
input		u_exception;
input		nxt_ucode_last;
input		reg_enable;
input	[31:0]	optop;
input	[31:0]	vars;
input	[8:0]	ucode_cnt;
input		iu_trap_r;
input		ifu_op_valid_r;
input	[31:0]	frame;
input	[31:0]	cp;
input		invokestatic_quick;
input		invokenonvirtual_quick;
input		invokevirtual_quick;
input		invokevirtualobject_quick;
input		invokevirtual_quick_w;
input		invokesuper_quick;
input		soft_trap;
input		se;
input		hold_e;
input	[7:0]	opcode_1_op_r;
input		valid_op_r;
input		iu_hold_e;

integer		monitor_enable;

initial
  if ($test$plusargs("no_ucode_mon")) begin
    monitor_enable = 0;
    $display("*** microcode monitor is disabled");
  end
  else begin
    monitor_enable = 1;
    $display("*** microcode monitor is enabled");
  end

wire		ie_kill_ucode;
assign	ie_kill_ucode = `PICOJAVAII.`DESIGN.iu.ucode.ie_kill_ucode;

wire		ucode_special_request;

assign ucode_special_request = ((u_f01 === `F01_WT_DREG_STK) ||
				(u_f01 === `F01_WT_DREG_STK_M8));

reg	[31:0]	data;
reg	[31:0]	addr;

// rule 1 : reading and writing at the same stack-cache address is
//          not allowed

always @(posedge clk) begin
  #2;
  if (reset_l & monitor_enable)
    if ((u_f01_wt_stk & u_f02_rd_stk) && (u_addr_st_wt === u_addr_st_rd))
      $display("ERROR: Ucode monitor: simultaneous read and write to same address of stack cache");
end

// rule 2 : If the ucode special request is made, the d$ data will be
//          requested to be written to the s$.  The data from d$ must
//          match what gets written to the s$ 3 cycles later.

ff_sre	reset_l_minus_1	(.out(reset_l_1),
			 .din(reset_l),
			 .enable(1'b1),
			 .reset_l(reset_l),
			 .clk(clk));

ff_sre	reset_l_minus_2	(.out(reset_l_2),
			 .din(reset_l_1),
			 .enable(1'b1),
			 .reset_l(reset_l),
			 .clk(clk));

ff_sre	reset_l_minus_3	(.out(reset_l_3),
			 .din(reset_l_2),
			 .enable(1'b1),
			 .reset_l(reset_l),
			 .clk(clk));

reg	[31:0]	rule_2_s_cache_addr;

//always @(posedge clk) begin
//  #2;
//  if (reset_l & reset_l_3 & monitor_enable & u_done)
//    if (ucode_special_request) begin
//      data = dreg_data;
//      rule_2_s_cache_addr = u_addr_st_wt;
//      #`CLK_HALF_PERIOD;
//      #`CLK_HALF_PERIOD;
//      if (~ie_stall_ucode) begin
//	#`CLK_HALF_PERIOD;
//	#`CLK_HALF_PERIOD;
//	if (~ie_stall_ucode) begin
//	  #`CLK_HALF_PERIOD;
//	  #`CLK_HALF_PERIOD;
//	  if (u_done & data !==
//	      `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.scache.ram[rule_2_s_cache_addr%64])
//	    $display("Warning: Ucode monitor: %d: special request made but d$ data 3 cycles ago does not match s$ data now", `PICOJAVAII.clk_count);
//	end
//      end
//    end
//end 

// rule 3 : Conversely, if a ucode special request is not made, the d$ data
//	    should NOT be written into the same address of the stack cache
//	    two cycles later.

//reg	[31:0]	rule_3_s_cache_addr;

//always @(posedge clk) begin
//  #2;
//  if (reset_l & reset_l_3 & ~ucode_special_request &
//      u_f01_wt_stk & monitor_enable) begin
//    rule_3_s_cache_addr = u_addr_st_wt;
//    #`CLK_HALF_PERIOD;
//    #`CLK_HALF_PERIOD;
//    #`CLK_HALF_PERIOD;
//    #`CLK_HALF_PERIOD;
//    #`CLK_HALF_PERIOD;
//    #`CLK_HALF_PERIOD;
//    if (rule_3_s_cache_addr === u_addr_st_wt)
//      $display("ERROR: Ucode monitor: %d: special request not made yet d$ addr 3 cycles ago matches s$ write addr now", `PICOJAVAII.clk_count);
//  end
//end


// rule 4 : when a special request is made, u_f03 must indicate a
//          data cache read ("F03_RD_DCACHE")

wire		read_d_cache;
assign	read_d_cache = (u_f03 === `F03_RD_DCACHE) ||
		       (u_f03 === `F03_ARY_LD);

always @(posedge clk) begin
  #2;
  if (reset_l & ucode_special_request & monitor_enable & ~read_d_cache)
    $display("ERROR: Ucode monitor: ucode is not reading d$ during special request");
end


// rule 5 : if a read or write request is made to s$ or d$, and one of
//          4 exception cases occurs, no state should be changed in the
//          w-stage.  We will detect the exception signals from iu, which
//          takes place in the c-stage (even though ucode asserts it late
//          in e-stage).  Further, u_done should be high when one of these
//          exceptions occurs.

wire		d_cache_access;
assign d_cache_access = |u_f03;

wire		s_cache_access;
assign s_cache_access = (|u_f01) | (|u_f02);


wire		one_of_four_exceptions;
assign one_of_four_exceptions = u_ref_null_c | u_ary_ovf_c |
                                gc_trap_c | u_ptr_un_eq_c;

always @(posedge clk) begin
  #2;
  if (reset_l & monitor_enable)
    if (d_cache_access || s_cache_access) begin
      #`CLK_HALF_PERIOD;
      #`CLK_HALF_PERIOD;    // now in c-stage
      if (one_of_four_exceptions) begin
	#`CLK_HALF_PERIOD;
	#`CLK_HALF_PERIOD;
	if (u_done == 0)
	  $display("ERROR: Ucode monitor: cache access in e-stage; exception seen in c-stage; but u_done not asserted by w-stage");
      end
    end
end


// rule 6 : if a read or write is request is made to s$ or d$, and iu
//          aborts the request, d$/s$ state should not be changed.

// always @(posedge clk) begin
//   #2;
//   if (u_abt_rdwt & reset_l & monitor_enable)
//     if (d_cache_access || s_cache_access)
//       $display("ERROR: Ucode monitor: ucode aborted d$ or s$ read/write but request still outstanding");
// end


// rule 7 : if ucode is stalled, exceptions may not be thrown.

always @(posedge clk) begin
  #2;
  if (ie_stall_ucode & u_exception & reset_l & monitor_enable)
    $display("ERROR: Ucode monitor: ucode threw exception when stalled");
end


// rule 8 : u_done is asserted during the last ucode cycle

always @(posedge clk) begin
  if (u_last & ~u_done & reset_l & monitor_enable)
    $display("ERROR: Ucode monitor: u_last asserted without u_done");
end
  

// rule 9 : optop and vars cannot be updated by ucode in the last ucode cycle

wire		next_is_last_cycle;
assign next_is_last_cycle = nxt_ucode_last & reg_enable;
wire		optop_change_requested;
assign	optop_change_requested = (u_f05 === `F05_WT_A_OPTOP) ||
				(u_f05 === `F05_WT_V_OPTOP);
wire		vars_change_requested;
assign	vars_change_requested = (u_f05 === `F05_WT_A_VARS);

reg	[31:0]	rule_9_optop;
reg	[31:0]	rule_9_vars;

always @(posedge clk) begin
  #2;
  if (next_is_last_cycle & ~u_exception & reset_l & monitor_enable) begin
    rule_9_optop = optop;
    rule_9_vars = vars;
    #`CLK_HALF_PERIOD;
    #`CLK_HALF_PERIOD;
    // if (rule_9_optop !== optop)
    if (optop_change_requested)
      $display("ERROR: Ucode monitor: optop updated in last ucode cycle");
    // if (rule_9_vars !== vars)
    if (vars_change_requested)
      $display("ERROR: Ucode monitor: vars updated in last ucode cycle");
  end
end


// rule 10 : if microcode is done, all fields should be in idle (default) state

wire		all_at_default;
assign all_at_default = (
  (u_f00 === `F00_DEFAULT)    &&
  (u_f01 === `F01_DEFAULT)    && (u_f02 === `F02_DEFAULT)    &&
  (u_f03 === `F03_DEFAULT)    && (u_f04 === `F04_DEFAULT)    &&
  (u_f05 === `F05_DEFAULT)    && (u_f06 === `F06_DEFAULT)    &&
  (u_f07 === `F07_DEFAULT)    && (u_f08 === `F08_DEFAULT)    &&
  (u_f09 === `F09_DEFAULT)    && (u_f10 === `F10_DEFAULT)    &&
  (u_f11 === `F11_DEFAULT)    && (u_f12 === `F12_DEFAULT)    &&
  (u_f13 === `F13_DEFAULT)    && (u_f14 === `F14_DEFAULT)    &&
  (u_f15 === `F15_DEFAULT)    && (u_f16 === `F16_DEFAULT)    &&
  (u_f17 === `F17_DEFAULT)    && (u_f18 === `F18_DEFAULT)    &&
  (u_f19 === `F19_DEFAULT)    && (u_f20 === `F20_DEFAULT)    &&
  (u_f21 === `F21_DEFAULT)    && (u_f22 === `F22_DEFAULT)
);

// always @(negedge u_last) begin
//   #5;
//   if (~all_at_default & reset_l & monitor_enable & u_done & ~ie_stall_ucode
//                       & ~ie_kill_ucode)
//       $display("ERROR: Ucode monitor: %d: u_f?? not at default when ucode completed", `PICOJAVAII.clk_count);
// end


// rule 11 : after synchronous interrupt (only at first cycle),
//           s$, d$, and regs should be unchanged.

wire		s_cache_write;
assign s_cache_write = |u_f01;
wire		d_cache_write;
assign d_cache_write = (u_f03 === `F03_WT_DCACHE);
wire		reg_write;
assign reg_write = |u_f05;

wire		any_write_request;
assign any_write_request = s_cache_write | d_cache_write | reg_write;
wire		write_req_killed;
assign	write_req_killed = `PICOJAVAII.`DESIGN.iu.rcu.iu_data_we_w |
			   `PICOJAVAII.`DESIGN.iu.iu_kill_dcu ;

// always @(negedge u_done) begin
//   #2;
//   if (`PICOJAVAII.`DESIGN.iu.ucode.ie_kill_ucode & any_write_request & ~write_req_killed & reset_l & monitor_enable)
//     $display("ERROR: Ucode monitor: ucode interrupt occurred during 1st cycle but s$/d$ write not killed");
// end


// rule 12 : for asynchronous exception, print a warning message saying
//           that the state will be unknown

// always @(negedge u_done) begin
//   #2;
//   #`CLK_HALF_PERIOD;
//   #`CLK_HALF_PERIOD;
// 
//   while (~u_done & reset_l & monitor_enable) begin
//     #5;
//     if (`PICOJAVAII.`DESIGN.iu.ucode.ie_kill_ucode)
//       $display("Warning: Ucode monitor: asynchronous exception taken");
//   end
// end


/******************** Commented out. iu_trap_r is also high for traps.
// rule 13 : iu_trap_r must be high if executing a soft_trap instruction

ff_sre	soft_trap_flop	(.out(soft_trap_e),
			 .din(soft_trap),
			 .enable(!ie_stall_ucode),
			 .reset_l(reset_l),
			 .clk(clk));

always @(posedge clk) begin
  #2;
  if ((soft_trap_e ^ iu_trap_r) & reset_l & monitor_enable & ~u_done & ~ie_stall_ucode)
    $display("ERROR: Ucode monitor: iu_trap_r doesn't match soft_trap_e");
end

********************************************************************************/

// rule 14 : iu_trap_r and ifu_op_valid_r are never active at the same time

always @(posedge clk) begin
  #2;
  if (iu_trap_r & ifu_op_valid_r & reset_l & monitor_enable)
    $display("ERROR: Ucode monitor: iu_trap_r = ifu_op_valid_r = 1");
end


// rule 15 : if vars/frame/cp is changed, ucode may not make any further
//	     d$ read requests

reg	[31:0]	rule_15_vars;
reg	[31:0]	rule_15_frame;
reg	[31:0]	rule_15_cp;
integer		write_reg_request_made;
integer		register_changed;

wire		d_cache_read;
assign d_cache_read = ((u_f03 === `F03_RD_DCACHE) || (u_f03 === `F03_ARY_LD));

always @(posedge clk) begin
  #2;
  if (~u_done & reset_l & monitor_enable) begin
    if ((u_f05 === `F05_WT_A_VARS) || (u_f05 === `F05_WT_A_FRAME) ||
	                (u_f05 === `F05_WT_A_CONST_P)) begin
      rule_15_vars = vars;
      rule_15_frame = frame;
      rule_15_cp = cp;
      write_reg_request_made = 1;
    end
    if (write_reg_request_made)
      if ((rule_15_vars !== vars) || (rule_15_frame !== frame) ||
			(rule_15_cp !== cp))
	register_changed = 1;
    if (write_reg_request_made && register_changed && d_cache_read)
      $display("ERROR: Ucode monitor: cannot make ucode read request after vars/frame/cp have changed.");
  end
  else begin
    write_reg_request_made = 0;
    register_changed = 0;
  end
end
      

// rule 16 : during invoke_*_quick, optop must be changed before any
//           stack write request

wire		invoke_in_r;
assign invoke_in_r = invokestatic_quick |
		     invokenonvirtual_quick |
		     invokevirtual_quick |
		     invokevirtualobject_quick |
		     invokevirtual_quick_w |
		     invokesuper_quick ;

ff_sre	invoke_e_flop	(.out(invoke_in_e),
			 .din(invoke_in_r),
			 .enable(!ie_stall_ucode),
			 .clk(clk),
			 .reset_l(reset_l));

wire		rule_16_optop_change_requested;
assign rule_16_optop_change_requested = (
		(u_f05 === `F05_WT_V_OPTOP) ||
		(u_f05 === `F05_WT_A_OPTOP));

integer		rule_16_optop_latched;
integer		rule_16_optop_changed;
reg	[31:0]	rule_16_optop;

// always @(posedge clk) begin
//   #2;
//   if (invoke_in_e & ~u_done & ~ie_stall_ucode & reset_l & monitor_enable) begin
//     if (rule_16_optop_change_requested) begin
//       rule_16_optop = optop;
//       rule_16_optop_latched = 1;
//     end
//     if (rule_16_optop_latched && (rule_16_optop !== optop)) begin
//       rule_16_optop_changed = 1;
//       rule_16_optop_latched = 0;
//     end
//     if (s_cache_write && !rule_16_optop_changed)
//       $display("ERROR: Ucode monitor: stack cache write requested before optop changed");
//   end
//   else begin
//     rule_16_optop_latched = 0;
//     rule_16_optop_changed = 0;
//   end
// end


// rule 17:  ucode is never allowed to read optop+4 or optop+8

wire	[7:0]	opcode_e;
reg	[7:0]	opcode_e_next;

always @(posedge clk)
  if ((valid_op_r === 1'b1) & ~u_done)
    opcode_e_next = opcode_1_op_r;

//ff_sre_8	ff_invoke_in_e (.out		(opcode_e[7:0]),
//				.din		(opcode_e_next[7:0]),
//				.enable		(!iu_hold_e),
//				.reset_l	(reset_l),
//				.clk		(clk));

assign 	opcode_e = opcode_e_next;

wire	rule_17_invoke_in_e;
assign	rule_17_invoke_in_e =	((opcode_e === 8'hd6) || (opcode_e === 8'hd7) || (opcode_e === 8'hd8) ||
				 (opcode_e === 8'hd9) || (opcode_e === 8'hda) || (opcode_e === 8'hdb));

wire	dup_in_e;
assign	dup_in_e = 		((opcode_e === 8'd90) || (opcode_e === 8'd91) || (opcode_e === 8'd92) ||
				 (opcode_e === 9'd93) || (opcode_e === 9'd94) || (opcode_e === 8'd95));

//always @(posedge u_f02_rd_stk) begin
//  if (~rule_17_invoke_in_e & ~u_done & ~dup_in_e)
//    if (u_addr_st_rd === (optop + 32'd4))
//      $display("ERROR: Ucode monitor: ucode tried to read optop+4");
//    if (u_addr_st_rd === (optop + 32'd8))
//      $display("ERROR: Ucode monitor: ucode tried to read optop+8");
//end

endmodule
