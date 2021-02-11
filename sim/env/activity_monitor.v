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
`include "defines.h"


module activity_monitor(pj_clk, end_of_simulation);
input pj_clk;
input end_of_simulation;

wire [14:0] event_signals;
reg prev_inst_e_2;
reg prev_inst_e_3;
reg prev_biu_dcu_ack;
reg [`it_msb:4] prev_icu_tag_addr;
reg prev_icu_req;

reg[8*40:1] event_names[14:0];

reg[8*40:1]   totalCyclesString;
reg[8*40:1]   totalInsnString;
reg[8*40:1]   totalFoldString;

integer event_counts[14:0];
integer i;
integer actv_cntr_on;
integer actv_insn_count;

assign event_signals[0] = `PICOJAVAII.`DESIGN.icu.icctl.ic_cntl.icu_req;
assign event_signals[1] = `PICOJAVAII.`DESIGN.icram_powerdown;
assign event_signals[2] = `PICOJAVAII.`DESIGN.icu.icu_dpath.ibuffer.ibuf_enable;
assign event_signals[3] = (prev_inst_e_2 == 1'b0 && (`PICOJAVAII.`DESIGN.iu_inst_e[2] == 1));
assign event_signals[4] = (prev_inst_e_3 == 1'b0 && (`PICOJAVAII.`DESIGN.iu_inst_e[3] == 1));
assign event_signals[5] = (prev_biu_dcu_ack == 1'b0 && (`PICOJAVAII.`DESIGN.dcu.biu_dcu_ack[0] == 1));
assign event_signals[6] = `PICOJAVAII.`DESIGN.dcu_pwrdown;
assign event_signals[7] = `PICOJAVAII.`DESIGN.dcu.dcctl.wrbuf_cntl.wb_idle;
assign event_signals[8] = `PICOJAVAII.`DESIGN.iu.dcu_stall;
assign event_signals[9] = `PICOJAVAII.`DESIGN.iu.smu_hold;
assign event_signals[10] = `PICOJAVAII.`DESIGN.iu.ifu.not_valid;
// assign event_signals[10] = ~ ((`PICOJAVAII.`DESIGN.iu.ifu.valid_rs1_r == 0) | (`PICOJAVAII.`DESIGN.iu.ifu.valid_rs2_r == 0) |
//			     (`PICOJAVAII.`DESIGN.iu.ifu.valid_op == 0) | (`PICOJAVAII.`DESIGN.iu.ifu.valid_rsd_r == 0));

assign event_signals[11] = `PICOJAVAII.`DESIGN.iu.ucode.u_done;
assign event_signals[12] = `PICOJAVAII.`DESIGN.fp_rdy_e;
`ifdef NO_ICACHE
assign event_signals[13] = 0;
`else
assign event_signals[13] = (prev_icu_tag_addr != `PICOJAVAII.`DESIGN.itag_shell.icu_tag_addr );
`endif
assign event_signals[14] = ((prev_icu_req == 1'b0) && (`PICOJAVAII.`DESIGN.icu.icu_req == 1'b1));

initial
begin
    actv_cntr_on = 0;
    actv_insn_count = 0;
    prev_inst_e_2 = 1'b0;
    prev_inst_e_3 = 1'b0;
    prev_biu_dcu_ack = 1'b0;
    prev_icu_tag_addr = 0;
    prev_icu_req = 1'b0;
    
    for (i = 0 ; i < 15 ; i=i+1)
    begin
        event_counts[i] = 0;
    end
    event_names[0] = "ICU_CONTROL_IDLE_CYCLES";
    event_names[1] = "ICRAM_DISABLED_CYCLES";
    event_names[2] = "IBUFFER_ACTIVE_CYCLES";
    event_names[3] = "DCU_READ_CYCLES";
    event_names[4] = "DCU_WRITE_CYCLES";
    event_names[5] = "DCU_LINE_FILL_CYCLES";
    event_names[6] = "DCRAM_DISABLED_CYCLES";
    event_names[7] = "WRITE_BUFFER_IDLE_CYCLES";
    event_names[8] = "DCU_HOLD_PIPE_CYCLES";
    event_names[9] = "SMU_HOLD_PIPE_CYCLES";
    event_names[10] = "ICU_HOLD_PIPE_CYCLES";
    event_names[11] = "UCODE_BUSY_CYCLES";
    event_names[12] = "FPU_IDLE_CYCLES";
    event_names[13] = "NUMBER OF I$ ACCESSES";
    event_names[14] = "NUMBER OF I$ MISSES";
    
    
end

// check for write to enable/disable perf counters
// temporarily use the perf counter to control the activity monitors

   always @(posedge pj_clk) begin
     if (`PICOJAVAII.pj_address == `PERF_COUNTER_ADDRESS) 
     begin
        if (`PICOJAVAII.pj_data_out == 1)
        begin
           $display ("Activity data gathering enabled at time %d\n", `PICOJAVAII.clk_count);
           actv_cntr_on = 1;
        end
        else if (`PICOJAVAII.pj_data_out == 0)
        begin
           $display ("Activity data gathering disabled at time %d\n", `PICOJAVAII.clk_count);
           actv_cntr_on = 0;
        end
        else
          $display ("Warning: Performance counter location (0x%x) touched with invalid data (0x%x)\n", `PERF_COUNTER_ADDRESS, `PICOJAVAII.pj_data_out);
     end
   end
 

  always @(posedge pj_clk) 
  begin
      #1 prev_inst_e_2 = `PICOJAVAII.`DESIGN.iu_inst_e[2];
      prev_inst_e_3 = `PICOJAVAII.`DESIGN.iu_inst_e[3];
      prev_biu_dcu_ack = `PICOJAVAII.`DESIGN.dcu.biu_dcu_ack[0];
`ifdef NO_ICACHE
`else
      prev_icu_tag_addr = `PICOJAVAII.`DESIGN.itag_shell.icu_tag_addr;
`endif
      prev_icu_req = `PICOJAVAII.`DESIGN.icu.icu_req;
      
  end

  always @(posedge pj_clk) 
  begin
    if (actv_cntr_on == 1)
    begin
      for (i = 0 ; i < 15 ; i=i+1)
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
    if (actv_cntr_on == 1)
    begin
      if (`PICOJAVAII.`DESIGN.iu.rcu.rcu_ctl.inst_complete_w)
          actv_insn_count = actv_insn_count + 
                            `PICOJAVAII.`DESIGN.iu.ifu.instrs_folded_w;
    end
  end
  always @(posedge end_of_simulation)
  begin
//      $display("RTL-STAT: %s %d", totalCyclesString, `PICOJAVAII.clk_count);
//      $display("RTL-STAT: %s %d", totalInsnString, `PICOJAVAII.total_instr_count);
//      $display("RTL-STAT: %s %d", totalFoldString, `PICOJAVAII.total_instr_count - `PICOJAVAII.instr_complete_count);
      for (i = 0 ; i < 15 ; i = i+1)
      begin
          $display("RTL-STAT: %s %d", event_names[i], event_counts[i]);
      end
      
  end
 
endmodule
