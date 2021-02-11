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




 // This file generate interrupt at a precise time after a trigger signal
// You define two things: INT_LEVEL, and INT_TRIGGER
// INT_LEVEL defines the interrupt level 
// INT_TRIGGER defines the signal to trigger
// "+int_cycle_n," [n= 0,1,2,3,4]  defines the precise location to 
// interrupt after the trigger

// define the interrupt level (1-16), 16 is nmi
`define INT_LEVEL 16

// define the trigger signal
`define INT_TRIGGER (negedge `PICOJAVAII.`DESIGN.iu.ucode_done)


reg	toggle;

integer delay_clk;

initial begin

    delay_clk = 0;

    if($test$plusargs("int_cycle_0")) delay_clk = 0;
    else
    if($test$plusargs("int_cycle_1")) delay_clk = 1;
    else
    if($test$plusargs("int_cycle_2")) delay_clk = 2;
    else
    if($test$plusargs("int_cycle_3")) delay_clk = 3;
    else
    if($test$plusargs("int_cycle_4")) delay_clk = 4;

    toggle = 1'b0;

  end

always @`INT_TRIGGER begin
 if (toggle == 1'b0) begin
  toggle = 1'b1;
  if($test$plusargs("int_cmd")) begin
   $display("interrupt microcode");
   repeat(delay_clk) @(posedge `PICOJAVAII.`DESIGN.clk); 
   int_cmd_flag = 1'b0;
   pending_reg[`INT_LEVEL] <= #1 1'b1;
  end
 end
 else begin 
  toggle = 1'b0;
 end

end
