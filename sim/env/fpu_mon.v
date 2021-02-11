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


`include "fpu_mon.h"

module fpu_mon(
     pj_clk,
     fpain,    // 32-bit A bus input.
     fpbin,    // 32-bit B bus input.
     fpop,     // Java Fp opcode (connected to first byte in IBUFF).
     fpbusyn,  // Signal asserted after valid operation begins
     fpkill,   // Input kills the operation returns to idle state.
     fpout,    
     fphold,     // Signal to hold the data input/output on IU stalls.
     fpop_valid); 


  input         pj_clk;
  input [31:0]  fpain,fpbin;
  input  [7:0]  fpop;
  input         fpkill,fphold;
  input         fpop_valid;

  input [31:0] fpout;       
  input        fpbusyn;     // Output signal fo;



integer no_inputs,no_outputs;
reg opcode_valid,exec_state_reg;
reg [2:0] state;
reg [7:0] fopcode;
integer clk_count;
integer bsy_low_cnt;
event print_fpout;


initial begin

  state = `IN1;
  clk_count = 0;

end

// clock counter
  always @(negedge pj_clk)
   begin
    clk_count = clk_count +1;
   end

//  FPU Monitor State M/C

always @( posedge pj_clk) begin

 //#1;
 case (state)

 `IN1: begin

  if (fpbusyn == 1'b0) 
    $display("ERROR: PICO.FPU.FPUBUSYN asserted during FPU Idle state");
   
  if (fphold == 1'b1 || fpkill == 1'b1) 
     state = `IN1;
  else begin
   
   if (^(fpop) === 1'bx && fpop_valid == 1'b1) begin
      $display("\nFPU getting the opcode as X's");
      state = `IN1;
   end
   else begin
    Is_Valid_Opcode(opcode_valid,fpop_valid,fpop);

    if (opcode_valid == 1'b1) begin
	fopcode = fpop;
	state = `IN2_OPR1;
    end
   end
  end
  #1;
 end

 `IN2_OPR1: begin

//      $display("\nclk:%d fpop:%x fpain:%x fpbin:%x fpkill:%x fphold:%x fpop_valid:%x fpout:%x\n",clk_count,fopcode,fpain,fpbin,fpkill,fphold,fpop_valid,fpout); 

   if (fpkill == 1'b1)
     state = `IN1;
   else if (fphold == 1'b1)
     state = `IN2_OPR1;
   else begin
 
     if (no_inputs == 1) begin
      if (^fpain === 1'bx)
       $display("\nERROR: Input Data went to X's");
     end
     else begin
      if (^fpain === 1'bx || ^fpbin === 1'bx) 
          $display("\nERROR: Input Data went to X's");
     end

     if ($test$plusargs("fpu_debug"))
     begin
        if (no_inputs == 1) 
          $display("\nclk:%d Opcode:%x Operand1:%x\n",clk_count,fopcode,fpain);

        else
          $display("\nclk:%d Opcode:%x Operand1:%x Operand2:%x\n",clk_count,fopcode,fpain,fpbin);

     end

      if (no_inputs == 4) 
        state = `IN2_OPR2;
      else begin
        exec_state_reg = 1'b0;
        state = `EXEC;
      end
   end

  #1;

 end

 `IN2_OPR2: begin

  
    if ( fpkill == 1'b1)
      state = `IN1;
    else if (fphold == 1'b1)
      state = `IN2_OPR2;
    else begin
      if (fpbusyn === 1'bx)
        $display("\n ERROR: PICO.FPU.FPBUSYN went to x in clk:%d",clk_count);       
      else if (fpbusyn != 1'b0)
       $display("\nERROR: PICO.FPU.FPBUSYN did not go low in clk:%d",clk_count);    
      else
        bsy_low_cnt = 0;

     if ($test$plusargs("fpu_debug"))
     begin
       $display("\nclk:%d Operand1:%x Operand2:%x\n",clk_count,fpain,fpbin);
     end

      if (^fpain === 1'bx || ^fpbin === 1'bx)
          $display("\nERROR: Input Data went to X's");

     state = `EXEC; 

   end

  #1;

 end

 `EXEC: begin

   	if (fpkill == 1'b1)
	     state = `IN1;
   	else begin
     		if (no_inputs != 4 && exec_state_reg == 1'b0) begin
     
      			if (fpbusyn === 1'bx)
			        $display("\n ERROR: PICO.FPU.FPBUSYN went to x in clk:%d",clk_count);
		        else if (fpbusyn != 1'b0) 
       				$display("\nERROR: PICO.FPU.FPBUSYN did not go low in clk:%d",clk_count); 
      			else
        			bsy_low_cnt = 0; 

      			exec_state_reg = 1'b1;  
     		end

     		if (fpbusyn == 1'b1) begin

			-> print_fpout;

   			if (no_outputs == 2)
     				state = `OUT1;
   			else begin

			    if (fphold)
			        state = `IN1;
			    else
			    begin
   				if (^(fpop) === 1'bx && fpop_valid == 1'b1) begin
      					$display("\nFPU getting the opcode as X's");
      						state = `IN1;
   				end
   				else begin
    					Is_Valid_Opcode(opcode_valid,fpop_valid,fpop);

    					if (opcode_valid == 1'b1) begin
        					fopcode = fpop;
        					state = `IN2_OPR1;
				        end
					else
						state = `IN1;
				end
			    end

   			end
    
     		end
     		else begin
       			if (bsy_low_cnt == `MAX_BSY_LENGTH) begin
//	         		$display("\nERROR: PICO.FPU.FPBUSYN asserted for very long time");
         			bsy_low_cnt = 1'b0;
       			end

       			bsy_low_cnt = bsy_low_cnt + 1;
       			state = `EXEC;
     		end
  	end

  #1;

 end

 `OUT1: begin

   if (fpkill == 1'b1)
    state = `IN1;
   else if (fphold == 1'b1)
    state = `OUT1;
   else begin

 if ($test$plusargs("fpu_debug"))
 begin
    $display("\nclk:%d fpout:%x\n",clk_count,fpout);
 end
 
    if (^(fpout) === 1'bx)
     $display("\nFPU giving the output as X's");

//    if (no_outputs == 2) 
//     -> print_fpout;

   if (^(fpop) === 1'bx && fpop_valid == 1'b1) begin
      $display("\nFPU getting the opcode as X's");
      state = `IN1;
   end
   else begin
    Is_Valid_Opcode(opcode_valid,fpop_valid,fpop);

    if (opcode_valid == 1'b1) begin
        fopcode = fpop;
        state = `IN2_OPR1;
   end
   else
	state = `IN1;
   end

    
   end
   
 end
 
 endcase

  #1;

end       


always @(print_fpout) 
begin:OUT_BLK

reg lp;

 lp = 1'b1;

 while (lp == 1'b1) begin
   if (fpkill == 1'b1)
     disable OUT_BLK;
   if (fphold == 1'b0)
    lp = 1'b0;
   else
    @(posedge pj_clk); 
 end
 if ($test$plusargs("fpu_debug"))
 begin
    $display("\nclk:%d fpout:%x\n",clk_count,fpout);
 end

 if (^(fpout) === 1'bx) 
    $display("\nFPU giving the output as X's");

end

    
task Is_Valid_Opcode;

 output opcode_valid;
 input fpop_valid;
 input [7:0] fpop;

 begin

//  $display("\nTask Is_valid activated fpop:%x",fpop);

  if (fpop_valid == 1'b0)
    opcode_valid = 1'b0;
  else begin
    opcode_valid = 1'b1;

  case (fpop)
 
   `DCMPG: begin no_inputs = 4; no_outputs = 1; end
   `DCMPL: begin no_inputs = 4; no_outputs = 1; end
   `DADD: begin no_inputs = 4; no_outputs = 2; end
   `DSUB: begin no_inputs = 4; no_outputs = 2; end
   `DMUL: begin no_inputs = 4; no_outputs = 2; end
   `DDIV: begin no_inputs = 4; no_outputs = 2; end
   `DREM: begin no_inputs = 4; no_outputs = 2; end
   `FCMPG: begin no_inputs = 2; no_outputs = 1; end
   `FCMPL: begin no_inputs = 2; no_outputs = 1; end
   `FADD: begin no_inputs = 2; no_outputs = 1; end
   `FSUB: begin no_inputs = 2; no_outputs = 1; end
   `FMUL: begin no_inputs = 2; no_outputs = 1; end
   `FDIV: begin no_inputs = 2; no_outputs = 1; end
   `FREM: begin no_inputs = 2; no_outputs = 1; end
   `D2F : begin no_inputs = 2; no_outputs = 1; end
   `D2L : begin no_inputs = 2; no_outputs = 2; end
   `D2I : begin no_inputs = 2; no_outputs = 1; end
   `L2F : begin no_inputs = 2; no_outputs = 1; end
   `L2D : begin no_inputs = 2; no_outputs = 2; end
   `F2D : begin no_inputs = 1; no_outputs = 2; end
   `F2I : begin no_inputs = 1; no_outputs = 1; end
   `F2L : begin no_inputs = 1; no_outputs = 2; end
   `I2F : begin no_inputs = 1; no_outputs = 1; end
   `I2D : begin no_inputs = 1; no_outputs = 2; end
 
   default: opcode_valid = 1'b0;
 
  endcase
 end
 end

endtask
endmodule
