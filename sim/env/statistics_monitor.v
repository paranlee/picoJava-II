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


`include "defines.h"

module statistics_monitor(
	pj_clk,
	num_entries,
	smu_hold,
	// pj_hold,
	endsim
	);

input		pj_clk;
input	[29:0]	num_entries;
input		smu_hold;
// input		pj_hold;
input		endsim;


real		total_smu_hold_clk_count;
integer		total_smu_hold_count;
real		stack_entries;
real		avg_stack_entries;
real		smu_hold_avg_cycles;
wire		non_ignored_smu_hold;
reg		statistics_enable;

wire	[4:0]	bucket_1;
reg	[4:0]	bucket_1_save;
wire	[4:0]	bucket_2;
reg	[4:0]	bucket_2_save;
wire	[4:0]	bucket_3;
reg	[4:0]	bucket_3_save;
wire	[4:0]	bucket_4;
reg	[4:0]	bucket_4_save;
wire	[7:0]	bucket_5;
reg	[7:0]	bucket_5_save;
wire	[4:0]	bucket_6;
reg	[4:0]	bucket_6_save;
wire	[3:0]	bucket_7;
reg	[3:0]	bucket_7_save;
wire	[2:0]	bucket_8;
reg	[2:0]	bucket_8_save;
integer		bucket_1_count;
integer		bucket_2_count;
integer		bucket_3_count;
integer		bucket_4_count;
integer		bucket_5_count;
integer		bucket_6_count;
integer		bucket_7_count;
integer		bucket_8_count;

assign bucket_1 = {`PICOJAVAII.`DESIGN.iu_smiss_data[4],
		   `PICOJAVAII.`DESIGN.iu_rs1_e[4],
		   `PICOJAVAII.`DESIGN.iu.ex.cmp_lt_e,
		   `PICOJAVAII.`DESIGN.iu.ex.branch_taken_e,
		   ~`PICOJAVAII.`DESIGN.iu.ifu.kill_vld_d & `PICOJAVAII.`DESIGN.iu.trap.hold_r};
assign bucket_2 = {`PICOJAVAII.`DESIGN.iu_smiss_data[0],
		   `PICOJAVAII.`DESIGN.iu.ucode_porta[0],
		   `PICOJAVAII.`DESIGN.iu.iu_alu_a[0],
		   `PICOJAVAII.`DESIGN.iu.carry_out_e,
		   `PICOJAVAII.`DESIGN.iu.ucode.ucode_dpath_0.ucode_reg_0.nxt_u_fxx[66]};
assign bucket_3 = {`PICOJAVAII.`DESIGN.sc_bottom[2],
		   `PICOJAVAII.`DESIGN.smu.num_entries[2],
		   `PICOJAVAII.`DESIGN.smu.smu_ctl.ovr_flw_bit,
		   `PICOJAVAII.`DESIGN.smu_hold,
		   `PICOJAVAII.`DESIGN.iu.hold_logic.hold_e};
assign bucket_4 = {`PICOJAVAII.`DESIGN.iu.ifu.accum_len1[5],
		   `PICOJAVAII.`DESIGN.iu.ifu.accum_len2[5],
		   `PICOJAVAII.`DESIGN.iu.ifu.fold_3_inst,
		   `PICOJAVAII.`DESIGN.iu_shift_d[4],
		   `PICOJAVAII.`DESIGN.icu.icctl.ibuf_ctl.ibuf_ctl_1.dirty_in};
assign bucket_5 = {`PICOJAVAII.`DESIGN.iu.ex.iu_addr_c[24],
		   `PICOJAVAII.`DESIGN.iu.mem_prot_error_c,
		   `PICOJAVAII.`DESIGN.iu.iu_trap_c,
		   `PICOJAVAII.`DESIGN.iu_kill_dcu,
		   `PICOJAVAII.`DESIGN.dcu.dcctl.iu_valid_c,
		   `PICOJAVAII.`DESIGN.dcu.dc_addr_sel[3],
		   `PICOJAVAII.`DESIGN.dcu.dc_addr_sel[1],
`ifdef NO_ICACHE
		   `PICOJAVAII.`DESIGN.dcu.dc_addr_sel[1]};
`else
		   `PICOJAVAII.`DESIGN.dcu.dc_addr_sel[1],
                   `PICOJAVAII.`DESIGN.dcu_stat_addr[6]};
`endif
`ifdef NO_FPU
assign bucket_6 = 0;
`else
assign bucket_6 = {`PICOJAVAII.`DESIGN.fpu.inc.l1out[0],
		   `PICOJAVAII.`DESIGN.fpu.inc.lowcarry,
		   `PICOJAVAII.`DESIGN.fpu.incovf,
		   `PICOJAVAII.`DESIGN.fpu.romsel[0],
		   `PICOJAVAII.`DESIGN.fpu.cs.p_code_seq_dp.code_add[0]};
`endif
assign bucket_7 = {`PICOJAVAII.`DESIGN.iu_rs1_e[15],
		   `PICOJAVAII.`DESIGN.iu.ex.cmp_gt_e,
		   `PICOJAVAII.`DESIGN.iu_brtaken_e,
		   `PICOJAVAII.`DESIGN.icu.icu_addr[5]};
assign bucket_8 = {`PICOJAVAII.`DESIGN.iu_rs1_e[3],
`ifdef NO_DCACHE
		   `PICOJAVAII.`DESIGN.iu_addr_e[31],1'b0};
`else
		   `PICOJAVAII.`DESIGN.iu_addr_e[31],
		   `PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram.bank_sel[0] &
		    `PICOJAVAII.`DESIGN.dcram_shell.dcram_top.dcram.we[0]};
`endif


// assign non_ignored_smu_hold = smu_hold & pj_hold;
assign non_ignored_smu_hold = smu_hold;

initial begin
  total_smu_hold_clk_count = 0;
  total_smu_hold_count = 0;
  stack_entries = 0;
  statistics_enable = 1'b0;
  if($test$plusargs("statistics")) statistics_enable = 1'b1;

  bucket_1_save = bucket_1;
  bucket_2_save = bucket_2;
  bucket_3_save = bucket_3;
  bucket_4_save = bucket_4;
  bucket_5_save = bucket_5;
  bucket_6_save = bucket_6;
  bucket_7_save = bucket_7;
  bucket_8_save = bucket_8;

  bucket_1_count = 0;
  bucket_2_count = 0;
  bucket_3_count = 0;
  bucket_4_count = 0;
  bucket_5_count = 0;
  bucket_6_count = 0;
  bucket_7_count = 0;
  bucket_8_count = 0;
end

always @(posedge non_ignored_smu_hold) begin
  total_smu_hold_count = total_smu_hold_count + 1;
end

always @(posedge pj_clk) begin
  if (|num_entries !== 1'bx) begin
    if ((num_entries > 0) && (num_entries < 62)) begin
      stack_entries = stack_entries + num_entries;
    end
  end
  total_smu_hold_clk_count = total_smu_hold_clk_count + non_ignored_smu_hold;

  if (statistics_enable) begin
    if ((bucket_1[1] ^ bucket_1_save[1]) & (bucket_1[0] ^ bucket_1_save[0]) &
	(bucket_1[2] ^ bucket_1_save[2]) & (bucket_1[3] ^ bucket_1_save[3]) &
	(bucket_1[4] ^ bucket_1_save[4]))
      begin
      $display("bucket #1 hit");
      bucket_1_count = bucket_1_count + 1;
      end
    if ((bucket_2[1] ^ bucket_2_save[1]) & (bucket_2[0] ^ bucket_2_save[0]) &
	(bucket_2[2] ^ bucket_2_save[2]) & (bucket_2[3] ^ bucket_2_save[3]) &
	(bucket_2[4] ^ bucket_2_save[4]))
      begin
      $display("bucket #2 hit");
      bucket_2_count = bucket_2_count + 1;
      end
    if ((bucket_3[1] ^ bucket_3_save[1]) & (bucket_3[0] ^ bucket_3_save[0]) &
	(bucket_3[2] ^ bucket_3_save[2]) & (bucket_3[3] ^ bucket_3_save[3]) &
	(bucket_3[4] ^ bucket_3_save[4]))
      begin
      $display("bucket #3 hit");
      bucket_3_count = bucket_3_count + 1;
      end
    if ((bucket_4[1] ^ bucket_4_save[1]) & (bucket_4[0] ^ bucket_4_save[0]) &
	(bucket_4[2] ^ bucket_4_save[2]) & (bucket_4[3] ^ bucket_4_save[3]) &
	(bucket_4[4] ^ bucket_4_save[4]))
      begin
      $display("bucket #4 hit");
      bucket_4_count = bucket_4_count + 1;
      end
    if ((bucket_5[1] ^ bucket_5_save[1]) & (bucket_5[0] ^ bucket_5_save[0]) &
	(bucket_5[2] ^ bucket_5_save[2]) & (bucket_5[3] ^ bucket_5_save[3]) &
	(bucket_5[4] ^ bucket_5_save[4]) & (bucket_5[5] ^ bucket_5_save[5]) &
	(bucket_5[6] ^ bucket_5_save[6]) & (bucket_5[7] ^ bucket_5_save[7]))
      begin
      $display("bucket #5 hit");
      bucket_5_count = bucket_5_count + 1;
      end
    if ((bucket_6[1] ^ bucket_6_save[1]) & (bucket_6[0] ^ bucket_6_save[0]) &
	(bucket_6[2] ^ bucket_6_save[2]) & (bucket_6[3] ^ bucket_6_save[3]) &
	(bucket_6[4] ^ bucket_6_save[4]))
      begin
      $display("bucket #6 hit");
      bucket_6_count = bucket_6_count + 1;
      end
    if ((bucket_7[1] ^ bucket_7_save[1]) & (bucket_7[0] ^ bucket_7_save[0]) &
	(bucket_7[2] ^ bucket_7_save[2]) & (bucket_7[3] ^ bucket_7_save[3]))
      begin
      $display("bucket #7 hit");
      bucket_7_count = bucket_7_count + 1;
      end
    if ((bucket_8[1] ^ bucket_8_save[1]) & (bucket_8[0] ^ bucket_8_save[0]) &
	(bucket_8[2] ^ bucket_8_save[2]))
      begin
      $display("bucket #8 hit");
      bucket_8_count = bucket_8_count + 1;
      end
    bucket_1_save = bucket_1;
    bucket_2_save = bucket_2;
    bucket_3_save = bucket_3;
    bucket_4_save = bucket_4;
    bucket_5_save = bucket_5;
    bucket_6_save = bucket_6;
    bucket_7_save = bucket_7;
    bucket_8_save = bucket_8;
  end

end

always @(posedge endsim) begin
  if (statistics_enable) begin
    avg_stack_entries = stack_entries / `PICOJAVAII.clk_count;
    smu_hold_avg_cycles = total_smu_hold_clk_count / total_smu_hold_count;
    $display("smu hold was asserted %d times", total_smu_hold_count);
    $display("total_smu_hold_clk_count = %f", total_smu_hold_clk_count);
    $display("average cycles per smu_hold = %f", smu_hold_avg_cycles);
    // $display("total stack entries = %f", stack_entries);
    // $display("clock count = %d", `PICOJAVAII.clk_count);
    $display("average number of stack cache entries = %f", avg_stack_entries);

    $display("bucket #1 was hit %d times", bucket_1_count);
    $display("bucket #2 was hit %d times", bucket_2_count);
    $display("bucket #3 was hit %d times", bucket_3_count);
    $display("bucket #4 was hit %d times", bucket_4_count);
    $display("bucket #5 was hit %d times", bucket_5_count);
    $display("bucket #6 was hit %d times", bucket_6_count);
    $display("bucket #7 was hit %d times", bucket_7_count);
    $display("bucket #8 was hit %d times", bucket_8_count);
    $display("COVERAGE: timing_buckets %d%d%d%d%d%d%d%d",
	(bucket_1_count != 0), (bucket_2_count != 0),
	(bucket_3_count != 0), (bucket_4_count != 0),
	(bucket_5_count != 0), (bucket_6_count != 0),
	(bucket_7_count != 0), (bucket_8_count != 0));
  end
end

endmodule
