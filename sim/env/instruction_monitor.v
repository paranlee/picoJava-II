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




 module instruction_monitor(
	clk,
	opcode_1,
	opcode_2,
	valid_op,
	endsim
	);

input	[7:0]	opcode_1;
input	[7:0]	opcode_2;
input		valid_op;
input		clk;
output		endsim;

reg	[255:0]	inst_enabled;
reg	[255:0]	extended_inst_enabled;
reg		endsim;

`include "instr_enable.h"

initial
  endsim = 'b0;

always @(posedge clk) begin
  if (valid_op) begin
    if (opcode_1 != 8'hff) begin
      if (inst_enabled[opcode_1[7:0]] == 1'b0) begin
	$display("COSIM Error: INSTRUCTION MONITOR: instruction 0x%x is not enabled: aborting test", opcode_1[7:0]);
	endsim = 1'b1;
      end
    end
    else begin
      if (extended_inst_enabled[opcode_2[7:0]] == 1'b0) begin
	$display("COSIM Error: INSTRUCTION MONITOR: instruction 0xff%x is not enabled: aborting test", opcode_2[7:0]);
	endsim = 1'b1;
      end
    end
  end
end

endmodule
