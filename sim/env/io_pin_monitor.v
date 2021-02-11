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

module io_pin_monitor(
	pj_reset,
	pj_reset_out,
	pj_clk,
	pj_clk_out,
	pj_irl,
	pj_nmi,
	pj_boot8,
	pj_su,
	pj_standby,
	pj_standby_out,
	pj_no_fpu,
	pj_scan_out,
	pj_scan_mode,
	pj_scan_in,
	pj_data_in,
	pj_data_out,
	pj_address,
	pj_size,
	pj_type,
	pj_tv,
	pj_ale,
	pj_ack,
	pj_halt,
	pj_resume,
	pj_brk1_sync,
	pj_brk2_sync,
	pj_in_halt,
	pj_inst_complete,
	end_of_simulation
);

input		pj_reset;
input		pj_reset_out;
input		pj_clk;
input		pj_clk_out;
input	[3:0]	pj_irl;
input		pj_nmi;
input		pj_boot8;
input		pj_su;
input		pj_standby;
input		pj_standby_out;
input		pj_no_fpu;
input		pj_scan_out;
input		pj_scan_mode;
input		pj_scan_in;
input	[31:0]	pj_data_in;
input	[31:0]	pj_data_out;
input	[29:0]	pj_address;
input	[1:0]	pj_size;
input	[3:0]	pj_type;
input		pj_tv;
input		pj_ale;
input	[1:0]	pj_ack;
input		pj_halt;
input		pj_resume;
input		pj_brk1_sync;
input		pj_brk2_sync;
input		pj_in_halt;
input		pj_inst_complete;
input		end_of_simulation;

integer		pj_reset_cnt;
integer		pj_reset_cnt2;
integer		pj_reset_out_cnt;
integer		pj_reset_out_cnt2;
integer		pj_irl_cnt;
integer		pj_irl_cnt2;
integer		pj_nmi_cnt;
integer		pj_nmi_cnt2;
integer		pj_boot8_cnt;
integer		pj_su_cnt;
integer		pj_su_cnt2;
integer		pj_standby_cnt;
integer		pj_standby_cnt2;
integer		pj_standby_out_cnt;
integer		pj_standby_out_cnt2;
integer		pj_no_fpu_cnt;
integer		pj_scan_out_cnt;
integer		pj_scan_out_cnt2;
integer		pj_scan_mode_cnt;
integer		pj_scan_mode_cnt2;
integer		pj_scan_in_cnt;
integer		pj_scan_in_cnt2;
// integer		pj_data_in_cnt;
// integer		pj_data_out_cnt;
// integer		pj_address_cnt;
// integer		pj_size_cnt;
// integer		pj_tv_cnt;
// integer		pj_ale_cnt;
// integer		pj_ack_cnt;
integer		pj_halt_cnt;
integer		pj_halt_cnt2;
integer		pj_resume_cnt;
integer		pj_resume_cnt2;
integer		pj_brk1_sync_cnt;
integer		pj_brk1_sync_cnt2;
integer		pj_brk2_sync_cnt;
integer		pj_brk2_sync_cnt2;
integer		pj_in_halt_cnt;
integer		pj_in_halt_cnt2;
integer		pj_inst_complete_cnt;

// Add for halt mode checking
integer		halt_cond;

wire		irl_any;
assign	irl_any = |pj_irl;

initial begin
  #10;
  wait(pj_reset == 1'b0);
  pj_reset_cnt = 0;
  pj_reset_cnt2 = 0;
  pj_reset_out_cnt = 0;
  pj_reset_out_cnt2 = 0;
  pj_irl_cnt = 0;
  pj_irl_cnt2 = 0;
  pj_nmi_cnt = 0;
  pj_nmi_cnt2 = 0;
  pj_boot8_cnt = 0;
  pj_su_cnt = 0;
  pj_su_cnt2 = 0;
  pj_standby_cnt = 0;
  pj_standby_cnt2 = 0;
  pj_standby_out_cnt = 0;
  pj_standby_out_cnt2 = 0;
  pj_no_fpu_cnt = 0;
  pj_scan_out_cnt = 0;
  pj_scan_out_cnt2 = 0;
  pj_scan_mode_cnt = 0;
  pj_scan_mode_cnt2 = 0;
  pj_scan_in_cnt = 0;
  pj_scan_in_cnt2 = 0;
  // pj_data_in_cnt = 0;
  // pj_data_out_cnt = 0;
  // pj_address_cnt = 0;
  // pj_size_cnt = 0;
  // pj_tv_cnt = 0;
  // pj_ale_cnt = 0;
  // pj_ack_cnt = 0;
  pj_halt_cnt = 0;
  pj_halt_cnt2 = 0;
  pj_resume_cnt = 0;
  pj_resume_cnt2 = 0;
  pj_brk1_sync_cnt = 0;
  pj_brk1_sync_cnt2 = 0;
  pj_brk2_sync_cnt = 0;
  pj_brk2_sync_cnt2 = 0;
  pj_in_halt_cnt = 0;
  pj_in_halt_cnt2 = 0;
  pj_inst_complete_cnt = 0;
  if($test$plusargs("halt_check")) halt_cond = 1'b1 ;
  else halt_cond = 0;
end

always @(posedge pj_reset) begin
  $display("pj_reset asserted.");
  pj_reset_cnt = pj_reset_cnt + 1;
end
always @(negedge pj_reset) begin
  $display("pj_reset deasserted.");
  pj_reset_cnt2 = pj_reset_cnt2 + 1;
end
always @(posedge pj_reset_out) begin
  $display("pj_reset_out asserted.");
  pj_reset_out_cnt = pj_reset_out_cnt + 1;
end
always @(negedge pj_reset_out) begin
  $display("pj_reset_out deasserted.");
  pj_reset_out_cnt2 = pj_reset_out_cnt2 + 1;
end
always @(posedge irl_any) begin
  $display("irl is nonzero.");
  pj_irl_cnt = pj_irl_cnt + 1;
end
always @(negedge irl_any) begin
  $display("irl is zero.");
  pj_irl_cnt2 = pj_irl_cnt2 + 1;
end
always @(posedge pj_nmi) begin
  $display("pj_nmi is asserted.");
  pj_nmi_cnt = pj_nmi_cnt + 1;
end
always @(negedge pj_nmi) begin
  $display("pj_nmi is deasserted.");
  pj_nmi_cnt2 = pj_nmi_cnt2 + 1;
end
always @(posedge pj_boot8) begin
  $display("pj_boot8 is asserted.");
  pj_boot8_cnt = pj_boot8_cnt + 1;
end
always @(posedge pj_su) begin
  $display("pj_su is asserted.");
  pj_su_cnt = pj_su_cnt + 1;
end
always @(negedge pj_su) begin
  $display("pj_su is asserted.");
  pj_su_cnt = pj_su_cnt + 1;
end
always @(posedge pj_standby) begin
  $display("pj_standby asserted.");
  pj_standby_cnt = pj_standby_cnt + 1;
end
always @(negedge pj_standby) begin
  $display("pj_standby deasserted.");
  pj_standby_cnt2 = pj_standby_cnt2 + 1;
end
always @(posedge pj_standby_out) begin
  $display("pj_standby_out asserted.");
  pj_standby_out_cnt = pj_standby_out_cnt + 1;
end
always @(negedge pj_standby_out) begin
  $display("pj_standby_out deasserted.");
  pj_standby_out_cnt2 = pj_standby_out_cnt2 + 1;
end
always @(posedge pj_no_fpu) begin
  $display("pj_no_fpu asserted.");
  pj_no_fpu_cnt = pj_no_fpu_cnt + 1;
end
always @(posedge pj_scan_out) begin
  $display("pj_scan_out asserted.");
  pj_scan_out_cnt = pj_scan_out_cnt + 1;
end
always @(negedge pj_scan_out) begin
  $display("pj_scan_out deasserted.");
  pj_scan_out_cnt2 = pj_scan_out_cnt2 + 1;
end
always @(posedge pj_scan_mode) begin
  $display("pj_scan_mode asserted.");
  pj_scan_mode_cnt = pj_scan_mode_cnt + 1;
end
always @(negedge pj_scan_mode) begin
  $display("pj_scan_mode deasserted.");
  pj_scan_mode_cnt2 = pj_scan_mode_cnt2 + 1;
end
always @(posedge pj_scan_in) begin
  $display("pj_scan_in asserted.");
  pj_scan_in_cnt = pj_scan_in_cnt + 1;
end
always @(negedge pj_scan_in) begin
  $display("pj_scan_in deasserted.");
  pj_scan_in_cnt2 = pj_scan_in_cnt2 + 1;
end
always @(posedge pj_halt) begin
  $display("pj_halt asserted.");
  pj_halt_cnt = pj_halt_cnt + 1;
end
always @(negedge pj_halt) begin
  $display("pj_halt deasserted.");
  pj_halt_cnt2 = pj_halt_cnt2 + 1;
end
always @(posedge pj_resume) begin
  $display("pj_resume asserted.");
  pj_resume_cnt = pj_resume_cnt + 1;
end
always @(negedge pj_resume) begin
  $display("pj_resume deasserted.");
  pj_resume_cnt2 = pj_resume_cnt2 + 1;
end
always @(posedge pj_brk1_sync) begin
  $display("pj_brk1_sync asserted.");
  pj_brk1_sync_cnt = pj_brk1_sync_cnt + 1;
end
always @(negedge pj_brk1_sync) begin
  $display("pj_brk1_sync deasserted.");
  pj_brk1_sync_cnt2 = pj_brk1_sync_cnt2 + 1;
end
always @(posedge pj_brk2_sync) begin
  $display("pj_brk2_sync asserted.");
  pj_brk2_sync_cnt = pj_brk2_sync_cnt + 1;
end
always @(negedge pj_brk2_sync) begin
  $display("pj_brk2_sync deasserted.");
  pj_brk2_sync_cnt2 = pj_brk2_sync_cnt2 + 1;
end
always @(posedge pj_in_halt) begin
  $display("pj_in_halt asserted.");
  pj_in_halt_cnt = pj_in_halt_cnt + 1;
  halt_cond = 0;
end
always @(negedge pj_in_halt) begin
  $display("pj_in_halt deasserted.");
  pj_in_halt_cnt2 = pj_in_halt_cnt2 + 1;
end
//always @(posedge pj_inst_complete) begin
//  $display("pj_inst_complete asserted.");
//  pj_inst_complete_cnt = pj_inst_complete_cnt + 1;
//end

always @(posedge end_of_simulation) begin
  //pj_reset_out_cnt = pj_reset_out_cnt - 1;
  //pj_reset_out_cnt2 = pj_reset_out_cnt2 - 1;
  if (!($test$plusargs("no_io_pin_stats"))) begin
    $display("i/o pin assert/deassert statistics");
    $display("%d pj_reset assertions.", pj_reset_cnt);
    $display("%d pj_reset deassertions.", pj_reset_cnt2);
    $display("%d pj_reset_out assertions.", pj_reset_out_cnt);
    $display("%d pj_reset_out deassertions.", pj_reset_out_cnt2);
    $display("%d pj_irl assertions.", pj_irl_cnt);
    $display("%d pj_irl deassertions.", pj_irl_cnt2);
    $display("%d pj_nmi assertions.", pj_nmi_cnt);
    $display("%d pj_nmi deassertions.", pj_nmi_cnt2);
    // $display("%d pj_boot8 assertions.", pj_boot8_cnt);
    $display("%d pj_su assertions.", pj_su_cnt);
    $display("%d pj_su deassertions.", pj_su_cnt2);
    $display("%d pj_standby assertions.", pj_standby_cnt);
    $display("%d pj_standby deassertions.", pj_standby_cnt2);
    $display("%d pj_standby_out assertions.", pj_standby_out_cnt);
    $display("%d pj_standby_out deassertions.", pj_standby_out_cnt2);
    // $display("%d pj_no_fpu assertions.", pj_no_fpu_cnt);
    $display("%d pj_scan_out assertions.", pj_scan_out_cnt);
    $display("%d pj_scan_out deassertions.", pj_scan_out_cnt2);
    $display("%d pj_scan_mode assertions.", pj_scan_mode_cnt);
    $display("%d pj_scan_mode deassertions.", pj_scan_mode_cnt2);
    $display("%d pj_scan_in assertions.", pj_scan_in_cnt);
    $display("%d pj_scan_in deassertions.", pj_scan_in_cnt2);
    $display("%d pj_halt assertions.", pj_halt_cnt);
    $display("%d pj_halt deassertions.", pj_halt_cnt2);
    $display("%d pj_resume assertions.", pj_resume_cnt);
    $display("%d pj_resume deassertions.", pj_resume_cnt2);
    $display("%d pj_brk1_sync assertions.", pj_brk1_sync_cnt);
    $display("%d pj_brk1_sync deassertions.", pj_brk1_sync_cnt2);
    $display("%d pj_brk2_sync assertions.", pj_brk2_sync_cnt);
    $display("%d pj_brk2_sync deassertions.", pj_brk2_sync_cnt2);
    $display("%d pj_in_halt assertions.", pj_in_halt_cnt);
    $display("%d pj_in_halt deassertions.", pj_in_halt_cnt2);
    //$display("%d pj_inst_complete assertions.", pj_inst_complete_cnt);
    if(halt_cond) $display("ERROR: pj_in_halt never go 1 with -halt_check option\n");
    else $display("%d halt_cond ", halt_cond);
  end
  $display("COVERAGE: io_pins %d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
	(pj_reset_cnt!=0), (pj_reset_cnt2!=0), (pj_reset_out_cnt!=0),
	(pj_reset_out_cnt2!=0), (pj_irl_cnt!=0), (pj_irl_cnt2!=0),
	(pj_nmi_cnt!=0), (pj_nmi_cnt2!=0), (pj_su_cnt!=0),
	(pj_su_cnt2!=0), (pj_standby_cnt!=0), (pj_standby_cnt2!=0),
	(pj_standby_out_cnt!=0), (pj_standby_out_cnt2!=0),
	(pj_scan_out_cnt!=0), (pj_scan_out_cnt2!=0), (pj_scan_mode_cnt!=0),
	(pj_scan_mode_cnt2!=0), (pj_scan_in_cnt!=0), (pj_scan_in_cnt2!=0),
	(pj_halt_cnt!=0), (pj_halt_cnt2!=0), (pj_resume_cnt!=0),
	(pj_resume_cnt2!=0), (pj_brk1_sync_cnt!=0), (pj_brk1_sync_cnt2!=0),
	(pj_brk2_sync_cnt!=0), (pj_brk2_sync_cnt2!=0), (pj_in_halt_cnt!=0),
	(pj_in_halt_cnt2!=0) );
end

endmodule
