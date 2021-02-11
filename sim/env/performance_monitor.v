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

`include "sys.h"

module performance_monitor(pj_clk, end_of_simulation);
input pj_clk;
input end_of_simulation;

wire [13:0] event_signals;
reg prev_ibuf_full;

reg[8*40:1] event_names[13:0];

reg[8*40:1]   totalCyclesString;
reg[8*40:1]   totalInsnString;
reg[8*40:1]   totalFoldString;

integer event_counts[13:0];
integer i;
integer perf_cntr_on;
integer perf_insn_count;

assign event_signals[0] = `PICOJAVAII.`DESIGN.iu.hold_logic.hold_d;
assign event_signals[1] = `PICOJAVAII.`DESIGN.iu.dcu_stall;
assign event_signals[2] = `PICOJAVAII.`DESIGN.iu.icu_hold;
assign event_signals[3] = `PICOJAVAII.`DESIGN.iu.smu_hold;
assign event_signals[4] = `PICOJAVAII.`DESIGN.iu.hold_logic.fp_hold;
assign event_signals[5] = ~ `PICOJAVAII.`DESIGN.iu.pipe.pipe_cntl.ucode_done;
assign event_signals[6] = ~ `PICOJAVAII.`DESIGN.iu.imdr_done_e;
assign event_signals[7] = `PICOJAVAII.`DESIGN.iu.pipe.pipe_cntl.lduse_hold;
assign event_signals[8] = `PICOJAVAII.`DESIGN.iu.pipe.pipe_cntl.first_cyc_r;
assign event_signals[9] = (~ `PICOJAVAII.`DESIGN.iu.hold_logic.hold_d) & (~ `PICOJAVAII.`DESIGN.iu.ifu.dec_valid[0]);
assign event_signals[10] = (`PICOJAVAII.`DESIGN.icu.icctl.ibuf_full);
assign event_signals[11] = (prev_ibuf_full == 1'b0 && (`PICOJAVAII.`DESIGN.icu.icctl.ibuf_full == 1));
assign event_signals[12] = `PICOJAVAII.`DESIGN.iu.rcu.rcu_ctl.inst_complete_w;
assign event_signals[13] = 1'b1;

initial
begin
    perf_cntr_on = 0;
    perf_insn_count = 0;
    prev_ibuf_full = 1'b0;
    for (i = 0 ; i < 14 ; i=i+1)
    begin
        event_counts[i] = 0;
    end
    event_names[0] = "TOTAL_DSTAGE_HOLD_CYCLES";
    event_names[1] = "DCU_HOLD_CYCLES";
    event_names[2] = "ICU_HOLD_CYCLES";
    event_names[3] = "SMU_HOLD_CYCLES";
    event_names[4] = "FPU_HOLD_CYCLES";
    event_names[5] = "UCODE_HOLD_CYCLES";
    event_names[6] = "IMDR_HOLD_CYCLES";
    event_names[7] = "LDUSE_HOLD_CYCLES";
    event_names[8] = "LONG_OP_HOLD_CYCLES";
    event_names[9] = "IBUF_STALL_CYCLES";
    event_names[10] = "IBUF-FULL-CYCLES";
    event_names[11] = "IBUF-NOT-FULL-TO-FULL-TRANSITIONS";
    event_names[12] = "INSN-GROUPS";
    event_names[13] = "CLOCK_CYCLES";
end

// check for write to enable/disable perf counters
   always @(posedge pj_clk) begin
     if (`PICOJAVAII.pj_address == `PERF_COUNTER_ADDRESS) 
     begin
        if (`PICOJAVAII.pj_data_out == 1)
        begin
           $display ("Performance data gathering enabled at time %d\n", `PICOJAVAII.clk_count);
           perf_cntr_on = 1;
        end
        else if (`PICOJAVAII.pj_data_out == 0)
        begin
           $display ("Performance data gathering disabled at time %d\n", `PICOJAVAII.clk_count);
           perf_cntr_on = 0;
        end
        else
          $display ("Warning: Performance counter location (0x%x) touched with invalid data (0x%x)\n", `PERF_COUNTER_ADDRESS, `PICOJAVAII.pj_data_out);
     end
   end
 

  always @(posedge pj_clk) 
  begin
      #1 prev_ibuf_full = `PICOJAVAII.`DESIGN.icu.icctl.ibuf_full;
  end

  always @(posedge pj_clk) 
  begin
    if (perf_cntr_on == 1)
    begin
      for (i = 0 ; i < 14 ; i=i+1)
      begin
        if (event_signals[i])
        begin
          event_counts[i] = event_counts[i]+1;
        end
      end
    end
  end


  always @(posedge pj_clk) 
  begin
    if (perf_cntr_on == 1)
    begin
      if (`PICOJAVAII.`DESIGN.iu.rcu.rcu_ctl.inst_complete_w)
          perf_insn_count = perf_insn_count + 
                            `PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w;
    end
  end
  always @(posedge end_of_simulation)
  begin
//      $display("RTL-STAT: %s %d", totalCyclesString, `PICOJAVAII.clk_count);
//      $display("RTL-STAT: %s %d", totalInsnString, `PICOJAVAII.total_instr_count);
//      $display("RTL-STAT: %s %d", totalFoldString, `PICOJAVAII.total_instr_count - `PICOJAVAII.instr_complete_count);
      for (i = 0 ; i < 14 ; i = i+1)
      begin
          $display("RTL-STAT: %s %d", event_names[i], event_counts[i]);
      end
      $display ("RTL-STAT:                          PERF-INSN-COUNT %d", perf_insn_count);
  end
 
endmodule
