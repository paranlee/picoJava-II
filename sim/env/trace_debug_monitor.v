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




 /* ************************************************************************
 * This trace and debug monitor interfaces to the picoJava-II core 
 * and performs the following tasks:
 *
 * 1) Test pj_halt/pj_inst_complete.
 *
 * 2) Test pj_in_halt/pj_resume.
 *
 * 3) Test single instruction step.
 *
 * 4) Display the pj_brk1_sync and pj_brk2_sync signals.
 *
 *  Command line argument :   +pj_halt
 *			      +single_step                        
 *  Note: If +pj_halt plug is used, it overrides +single_step. 
 *
 *  Note: +pj_halt can NOT be used to check pj_in_halt/pj_resume.
 *        There is a special pj_resume test program, in which the brk1a, 
 *        brk2a, and brk12c are programmed to perform pj_in_halt/pj_resume 
 *        mode. And this trace_debug_monitor supports the hardware signals.  
 *
 * *********************************************************************** */

module trace_debug_monitor(
        sys_clk,
        pj_halt,
        pj_resume,
        pj_brk1_sync,
        pj_brk2_sync,
        pj_in_halt,
        pj_inst_complete,
        pj_clk
        );

input           sys_clk;
input           pj_brk1_sync;
input  		pj_brk2_sync;
input           pj_in_halt;
input           pj_inst_complete;
 
output          pj_halt;
output          pj_resume;
output          pj_clk;
 

reg             pj_halt;
reg             pj_resume;
wire            pj_clk;


reg             single_step_flag; 
reg             pj_halt_flag; 
reg             step_sel;
initial
  begin
        pj_halt = 1'b0;
        pj_resume = 1'b0;
        step_sel = 1'b0;
        single_step_flag = 1'b0;
        pj_halt_flag = 1'b0;

        if($test$plusargs("pj_halt"))  pj_halt_flag = 1'b1;
        else if($test$plusargs("single_step")) single_step_flag = 1'b1;

        if (pj_halt_flag) force pj_halt = 1'b0; 
        repeat(20) @(posedge pj_clk); 
              if (pj_halt_flag) release pj_halt;
 end

// Display pj_brk1_sync and pj_brk2_sync signals

  always @(posedge pj_brk1_sync) begin
     $display("pj_brk1_sync is asserted.");
     end 

  always @(posedge pj_brk2_sync) begin
     $display("pj_brk2_sync is asserted.");
     end 

// Perform pj_halt in random fashion

  always @(negedge sys_clk) begin
     if (pj_halt_flag && pj_inst_complete && !pj_in_halt) begin
        pj_halt <= #1 1'b1;
        repeat(100) @(posedge sys_clk); 
        pj_halt <= #1 1'b0; 
        end
     end

// Perform single instruction step

  always @(negedge sys_clk) begin
       if(single_step_flag && pj_inst_complete) begin
       step_sel = 1'b1; 
       repeat(100) @(posedge sys_clk);
       step_sel = 1'b0;  
       wait(!pj_inst_complete);
       end
     end
     
assign pj_clk = (step_sel) ? 1'b0 :sys_clk;
 
// Perform pj_in_halt/pj_resume test 

  always @(posedge pj_in_halt) begin
        repeat(100) @(posedge sys_clk); 
        pj_resume <= #1 1'b1;
        repeat(1) @(posedge sys_clk); 
        pj_resume <= #1 1'b0; 
        end

endmodule
          
      
