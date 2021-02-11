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

/*
`define  dc_size	8191  	  // Size of 1 set of Cache Ram.
`define	 dc_msb		12	  // MSB of Address Bus needed to index into the cache 
`define  dt_msb		18	  // MSB of Dcache Tag Field (Used for storing tag of a cache line)
`define  dt_index	8	  // MSB of Tag address used to index tag of a cache.
`define  dt_mxblks	512       // Number of Blocks in the cache
*/


module dtag_top(clk, bist_reset, bist_mode, addr, tag_in, tag_we, enable, set_sel, wb_set_sel,
       cmp_addr_in, sin, sm, test_mode, stat_addr, stat_in, stat_we,
       so, ERROR, dtag_dout, stat_out, hit0_out, hit1_out);

   input clk; 
   input bist_reset; 
   input [1:0] bist_mode; 
   input [`dc_msb:4] addr; 
   input [`dt_msb:0] tag_in; 
   input tag_we; 
   input enable; 
   input set_sel;
   input wb_set_sel;
   input [`dt_msb:0] cmp_addr_in;
   input sm;
   input sin;
   input test_mode;
   input [`dc_msb:4] stat_addr; 
   input [4:0] stat_in; 
   input [4:0] stat_we; 

   output ERROR; 
   output so;
   output [`dt_msb:0] dtag_dout; 
   output [4:0] stat_out;
   output hit0_out;
   output hit1_out; 

   wire BACKGROUND;  
   wire [8:0] BIST_ADR;  
   wire [`dc_msb:4] int_BIST_ADR;  
   wire BIST_ON;  
   wire BIST_WE;  
   wire END_SEQ;  
   wire ERRN_ON;  
   wire INVERSE;  
   wire NO_COMP;  
   wire rr512x5_ENABLE;  
   wire rr512x5_ERROR;  
   wire rrdtag_0_ENABLE;  
   wire rrdtag_0_ERROR;  
   wire rrdtag_1_ENABLE;  
   wire rrdtag_1_ERROR;  
   wire int_web;
   wire int_we0;
   wire int_we1;
   wire int_test_mode;
   wire [4:0] bist_stat_we;
   wire [4:0] stat_out;
   wire [4:0] int_dib;
   wire [`dt_msb:0] int_do0;
   wire [`dt_msb:0] int_do1;
   wire [`dt_msb:0] int_di0;
   wire [`dt_msb:0] int_di1;
   wire [`dt_msb:0] int_dit;

   assign bist_stat_we[0] = int_web;
   assign bist_stat_we[1] = int_web;
   assign bist_stat_we[2] = int_web;
   assign bist_stat_we[3] = int_web;
   assign bist_stat_we[4] = int_web;

   assign int_BIST_ADR[`dc_msb:4]  = BIST_ADR[8:0];


   Controller1  Controller_Ins(.TCLK(clk), .TRESET(bist_reset), .MODE(bist_mode), 
      .rrdtag_0_ERROR(rrdtag_0_ERROR), .rrdtag_1_ERROR(rrdtag_1_ERROR), 
      .rr512x5_ERROR(rr512x5_ERROR), .BIST_ADR(BIST_ADR), .rrdtag_0_ENABLE(rrdtag_0_ENABLE), 
      .rrdtag_1_ENABLE(rrdtag_1_ENABLE), .rr512x5_ENABLE(rr512x5_ENABLE), .BIST_WE(BIST_WE), 
      .INVERSE(INVERSE), .END_SEQ(END_SEQ), .BIST_ON(BIST_ON), .test_mode(int_test_mode),
      .ERRN_ON(ERRN_ON), .NO_COMP(NO_COMP), .BACKGROUND(BACKGROUND), .DONE(), .ERROR(ERROR), .FAIL());

   rrdtag_0_LocalBist  rrdtag_0_Bist_Ins(.BIST_PATTERN(int_di0), .we(int_we0), .func_do(int_do0),
      .BIST_ADR(BIST_ADR), .BIST_WE(BIST_WE),
      .BIST_ON(BIST_ON), .ERRN_ON(ERRN_ON), .INVERSE(INVERSE),
      .NO_COMP(NO_COMP), .END_SEQ(END_SEQ), .rrdtag_0_ENABLE(rrdtag_0_ENABLE),
      .BACKGROUND(BACKGROUND), .rrdtag_0_ERROR(rrdtag_0_ERROR));

   rrdtag_1_LocalBist  rrdtag_1_Bist_Ins(.BIST_PATTERN(int_di1), .we(int_we1), .func_do(int_do1),
      .BIST_ADR(BIST_ADR), .BIST_WE(BIST_WE),
      .BIST_ON(BIST_ON), .ERRN_ON(ERRN_ON), .INVERSE(INVERSE),
      .NO_COMP(NO_COMP), .END_SEQ(END_SEQ), .rrdtag_1_ENABLE(rrdtag_1_ENABLE),
      .BACKGROUND(BACKGROUND), .rrdtag_1_ERROR(rrdtag_1_ERROR));

   rr512x5_LocalBist  rr512x5_Bist_Ins(.BIST_PATTERN(int_dib), .web(int_web), .func_doa(stat_out),
      .BIST_ADR(BIST_ADR), .BIST_WE(BIST_WE),
      .BIST_ON(BIST_ON), .ERRN_ON(ERRN_ON), .INVERSE(INVERSE),
      .NO_COMP(NO_COMP), .END_SEQ(END_SEQ), .rr512x5_ENABLE(rr512x5_ENABLE),
      .BACKGROUND(BACKGROUND), .rr512x5_ERROR(rr512x5_ERROR));

   dtag	 dtag(.tag_in(tag_in), .tag_we(tag_we), .cmp_addr_in(cmp_addr_in), .set_sel(set_sel),
      .wb_set_sel(wb_set_sel), .addr(addr), .stat_in(stat_in), .stat_we(stat_we), .stat_addr(stat_addr),
      .enable(enable), .clk(clk), .hit0_out(hit0_out),.hit1_out(hit1_out), .dtag_dout(dtag_dout),
      .stat_out(stat_out), .test_mode(test_mode), .bist_enable(1'b1),
      .bist_tag_we0(int_we0), .bist_tag_we1(int_we1), .bist_stat_we(bist_stat_we), .bist_tag_in(int_dit),
      .bist_stat_in(int_dib), .bist_addr(int_BIST_ADR), .bist_stat_addr(int_BIST_ADR), .bist_tag_dout0(int_do0),
      .bist_tag_dout1(int_do1));

endmodule


module Controller1 ( TCLK, TRESET, MODE, rrdtag_0_ERROR, 
    rrdtag_1_ERROR, rr512x5_ERROR, BIST_ADR, rrdtag_0_ENABLE, rrdtag_1_ENABLE, 
    rr512x5_ENABLE, BIST_WE, INVERSE, END_SEQ, BIST_ON, ERRN_ON, NO_COMP, 
    BACKGROUND, DONE, ERROR, FAIL, test_mode );
input  [1:0] MODE;
output [8:0] BIST_ADR;
input  TCLK, TRESET, rrdtag_0_ERROR, rrdtag_1_ERROR, rr512x5_ERROR, test_mode;
output rrdtag_0_ENABLE, rrdtag_1_ENABLE, rr512x5_ENABLE, BIST_WE, INVERSE, 
    END_SEQ, BIST_ON, ERRN_ON, NO_COMP, BACKGROUND, DONE, ERROR, FAIL;
    
endmodule

module rrdtag_0_LocalBist ( BIST_ADR, BIST_WE, 
    func_do, BIST_ON, ERRN_ON, INVERSE, 
    NO_COMP, END_SEQ, rrdtag_0_ENABLE, BACKGROUND, BIST_PATTERN, we, 
    rrdtag_0_ERROR );

input  [`dt_msb:0] func_do;
output [`dt_msb:0] BIST_PATTERN;
input  [8:0] BIST_ADR;
input  BIST_WE, BIST_ON, ERRN_ON, INVERSE,
       NO_COMP, END_SEQ, rrdtag_0_ENABLE, BACKGROUND;
output rrdtag_0_ERROR, we;

endmodule



module rrdtag_1_LocalBist ( BIST_ADR, BIST_WE, 
    func_do, BIST_ON, ERRN_ON, INVERSE, 
    NO_COMP, END_SEQ, rrdtag_1_ENABLE, BACKGROUND, BIST_PATTERN, we, 
    rrdtag_1_ERROR );

input  [`dt_msb:0] func_do;
output [`dt_msb:0] BIST_PATTERN;
input  [8:0] BIST_ADR;
input  BIST_WE, BIST_ON, ERRN_ON, INVERSE,
       NO_COMP, END_SEQ, rrdtag_1_ENABLE, BACKGROUND;
output rrdtag_1_ERROR, we;

endmodule


module rr512x5_LocalBist ( BIST_ADR, BIST_WE,
    func_doa, BIST_ON, ERRN_ON, INVERSE,
    NO_COMP, END_SEQ, rr512x5_ENABLE, BACKGROUND,  BIST_PATTERN, web,
    rr512x5_ERROR );
    
input  [4:0] func_doa;
output [4:0] BIST_PATTERN;
input  [8:0] BIST_ADR;
input  BIST_WE, BIST_ON, ERRN_ON, INVERSE,
       NO_COMP, END_SEQ, rr512x5_ENABLE, BACKGROUND;
output rr512x5_ERROR, web;

endmodule
