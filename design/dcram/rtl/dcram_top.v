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



`timescale 1ns/10ps

// `define	 dc_size	8*1024 -1  	// Size of 1 set of Cache Ram.

module dcram_top(clk, enable, bist_reset, bist_mode, bank_sel, bypass, we, addr, data_in, test_mode, sin, sm,
                 ERROR, data_out, so);

   input clk;
   input enable;
   input test_mode;
   input bist_reset; 
   input bypass; 
   input [3:0] we; 
   input [1:0] bist_mode; 
   input [1:0] bank_sel;
   input [63:0] data_in;
   input [`dc_msb:0] addr;     		// Address inputs
   input sin;
   input sm;
   
   output ERROR; 
   output [63:0] data_out;
   output so;

   wire BACKGROUND;  
   wire [`dc_msb-2:0] BIST_ADR;  
   wire BIST_ON;  
   wire BIST_WE;  
   wire END_SEQ;  
   wire ERRN_ON;  
   wire INVERSE;  
   wire NO_COMP;  
   wire dcache_ram0_ENABLE;  
   wire dcache_ram0_ERROR;  
   wire dcache_ram1_ENABLE;  
   wire dcache_ram1_ERROR;
   
   wire [31:0] int_di0;
   wire [31:0] int_do0;
   wire [63:0] int_di;
   wire [31:0] int_di1;
   wire [31:0] int_do1;
   
   wire        int_we0;
   wire        int_we1;
   wire [3:0]  int_we;

   assign int_we[0] = int_we0;
   assign int_we[1] = int_we0;
   assign int_we[2] = int_we1;
   assign int_we[3] = int_we1;

   assign int_di[31:0]  = int_di0[31:0];
   assign int_di[63:32] = int_di1[31:0];

   Controller  Controller_Ins(.TCLK(clk), .TRESET(bist_reset), .MODE(bist_mode), 
      .dcache_ram0_ERROR(dcache_ram0_ERROR), .dcache_ram1_ERROR(dcache_ram1_ERROR), 
      .BIST_ADR(BIST_ADR), .dcache_ram0_ENABLE(dcache_ram0_ENABLE), .dcache_ram1_ENABLE(dcache_ram1_ENABLE), 
      .BIST_WE(BIST_WE), .INVERSE(INVERSE), .END_SEQ(END_SEQ), .BIST_ON(BIST_ON), .test_mode(test_mode),
      .ERRN_ON(ERRN_ON), .NO_COMP(NO_COMP), .BACKGROUND(BACKGROUND), .DONE(), .ERROR(ERROR), .FAIL());

   dcache_ram0_LocalBist  dcache_ram0_Bist_Ins(.BIST_PATTERN(int_di0), .we(int_we0), .func_do(int_do0), 
      .BIST_ADR(BIST_ADR), .BIST_WE(BIST_WE), 
      .BIST_ON(BIST_ON), .ERRN_ON(ERRN_ON), .INVERSE(INVERSE), 
      .NO_COMP(NO_COMP), .END_SEQ(END_SEQ), .dcache_ram0_ENABLE(dcache_ram0_ENABLE), 
      .BACKGROUND(BACKGROUND), .dcache_ram0_ERROR(dcache_ram0_ERROR));

   dcache_ram1_LocalBist  dcache_ram1_Bist_Ins(.BIST_PATTERN(int_di1), .we(int_we1), .func_do(int_do1), 
      .BIST_ADR(BIST_ADR), .BIST_WE(BIST_WE), 
      .BIST_ON(BIST_ON), .ERRN_ON(ERRN_ON), .INVERSE(INVERSE), 
      .NO_COMP(NO_COMP), .END_SEQ(END_SEQ), .dcache_ram1_ENABLE(dcache_ram1_ENABLE), 
      .BACKGROUND(BACKGROUND), .dcache_ram1_ERROR(dcache_ram1_ERROR));

   dcram  dcram(.data_in(data_in), .we(we), .bypass(bypass), .bank_sel(bank_sel), .enable(enable),
      .addr(addr), .data_out(data_out), .test_mode(test_mode), .bist_enable(1'b1),
      .dcache_ram0_do(int_do0), .dcache_ram1_do(int_do1), .bist_we(int_we),
      .clk(clk), .bist_data_in(int_di), .bist_addr(BIST_ADR), .sin(sin),
      .sm(sm), .so(so) );

endmodule

module Controller ( TCLK, TRESET, MODE, dcache_ram0_ERROR, 
    dcache_ram1_ERROR, BIST_ADR, dcache_ram0_ENABLE, dcache_ram1_ENABLE, 
    BIST_WE, INVERSE, END_SEQ, BIST_ON, ERRN_ON, NO_COMP, BACKGROUND, 
    DONE, ERROR, FAIL, test_mode );
input  [1:0] MODE;
output [`dc_msb-2:0] BIST_ADR;
input  TCLK, TRESET, dcache_ram0_ERROR, dcache_ram1_ERROR, test_mode;
output dcache_ram0_ENABLE, dcache_ram1_ENABLE, BIST_WE, INVERSE, END_SEQ, 
    BIST_ON, ERRN_ON, NO_COMP, BACKGROUND, DONE, ERROR, FAIL;

endmodule

module dcache_ram0_LocalBist ( BIST_ADR, BIST_WE, 
    func_do, BIST_ON, ERRN_ON, INVERSE, 
    NO_COMP, END_SEQ, dcache_ram0_ENABLE, BACKGROUND, BIST_PATTERN, we,
    dcache_ram0_ERROR );

input  [31:0] func_do;
output [31:0] BIST_PATTERN;
input  [`dc_msb-2:0] BIST_ADR;
input  BIST_WE, BIST_ON, ERRN_ON, INVERSE, 
       NO_COMP, END_SEQ, dcache_ram0_ENABLE, BACKGROUND;
output dcache_ram0_ERROR, we;

endmodule

module dcache_ram1_LocalBist ( BIST_ADR, BIST_WE, 
    func_do, BIST_ON, ERRN_ON, INVERSE, 
    NO_COMP, END_SEQ, dcache_ram1_ENABLE, BACKGROUND, BIST_PATTERN, we,
    dcache_ram1_ERROR );

input  [31:0] func_do;
output [31:0] BIST_PATTERN;
input  [`dc_msb-2:0] BIST_ADR;
input  BIST_WE, BIST_ON, ERRN_ON, INVERSE, 
       NO_COMP, END_SEQ, dcache_ram1_ENABLE, BACKGROUND;
output dcache_ram1_ERROR, we;

endmodule

