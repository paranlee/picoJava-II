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




// synopsis translate_off
//`timescale 1ns/1ns
`timescale 1ns/10ps
`include "fpu.h"
// synopsis translate_on

module fpu_dummy(
     		fpain,    	// 32-bit A bus input.
     		fpbin,    	// 32-bit B bus input.
     		fpop,     	// Java Fp opcode (connected to first byte in IBUFF).
     		fpbusyn,  	// Signal asserted after valid operation begins
     		fpkill,   	// Input kills the operation returns to idle state.
     		fpout,    	// 32-bit output bus, Direct Drive.
     		clk,
     		so,
		sin,
		sm,
     		reset_l,
		powerdown, // used here to power down fpu roms
		test_mode,	// test signal for roms
     		fphold,     	// Signal to hold the data input/output on IU stalls.
     		fpop_valid); 	// Input indicating valid FPOP byte (connected to first
				// byte valid in IBUFF).

//  Top level FPU module.

  input [31:0]  fpain, fpbin;
  input  [7:0]  fpop;
  input         fpkill, fphold, reset_l, test_mode, powerdown;
  input         clk, sin,sm, fpop_valid;

  output [31:0] fpout;       // Direct Drive output,  No output tri-state needed.
  output        fpbusyn;     // Output signal for controlling FPU interface.
  output        so;

assign fpout[31:0] = 1'b0;
assign fpbusyn = 1'b1;

endmodule







             
