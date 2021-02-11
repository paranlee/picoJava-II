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





`include        "../rtl/defines.h"

module  itag_shell (    icu_tag_in,
                        icu_tag_vld,
                        icu_tag_we,
                        icu_tag_addr,
                        enable,
                        itag_vld,
                        itag_dout,
                        ic_hit,
                        clk,
                        bist_mode,
                        bist_reset,
                        test_mode,
                        itag_test_err_l,
                        sin,
                        sm,
                        so
                        );

input   [`it_msb:0]     icu_tag_in;     // Write data_in  -- address portion of tag
input                   icu_tag_vld;    // valid bit   -- valid bit of the tag
input                   icu_tag_we;     // Write enable for tag array
input   [`ic_msb:4]     icu_tag_addr;   // Address inputs for reading tag
input                   enable;         // power down mode
input                   clk;            // Clock
output  [`it_msb:0]     itag_dout;      // Tag output
output                  itag_vld;       // valid bit
output                  ic_hit;

input                   test_mode;           // BIST enable
input         [1:0]     bist_mode;           // BIST mode
input                   bist_reset;          // BIST reset
output                  itag_test_err_l;
input                   sin;
input                   sm;
output                  so;

wire    [`it_msb:0]     bist_icu_tag_in;     // Write data_in  -- address portion of tag
wire                    bist_icu_tag_vld;    // valid bit   -- valid bit of the tag

wire                    bist_icu_tag_we;     // Write enable for tag array
wire    [`ic_msb:4]     bist_icu_tag_addr;   // Address inputs for reading tag
wire                    bist_enable;         // power down mode

wire    [`it_msb:0]     itag_dout;      // Tag output
wire                    itag_vld;       // valid bit
wire                    ic_hit;
wire                    itag_enable;

itag_top itag_top (	.bist_reset(bist_reset), 
			.bist_mode(bist_mode),
			.icu_tag_addr(icu_tag_addr),
			.icu_tag_in(icu_tag_in), 
			.icu_tag_vld(icu_tag_vld), 
			.icu_tag_we(icu_tag_we), 
			.clk(clk), 
			.enable(!enable), 
			.test_mode(test_mode), 
			.ERROR(itag_test_err_l), 
			.itag_dout(itag_dout), 
			.itag_vld(itag_vld), 
			.itag_hit(ic_hit)
			);

itag_misc  i_itag_misc (        .enable(enable),
                                .icu_tag_in(icu_tag_in),
                                .icu_tag_vld(icu_tag_vld),
                                .icu_tag_we(icu_tag_we),
                                .icu_tag_addr(icu_tag_addr),
                                .clk(clk)
                                );
endmodule


module itag_top (	bist_reset, 
			bist_mode,
			icu_tag_addr,
			icu_tag_in, 
			icu_tag_vld, 
			icu_tag_we, 
			clk, 
			enable, 
			test_mode, 
			ERROR, 
			itag_dout, 
			itag_vld, 
			itag_hit
			);

   input bist_reset; 
   input [1:0] bist_mode; 
   input [`ic_msb-4:0] icu_tag_addr; 
   input [`it_msb:0] icu_tag_in; 
   input icu_tag_vld;
   input icu_tag_we; 
   input clk; 
   input enable; 
   input  test_mode; 

   output ERROR; 
   output [`it_msb:0] itag_dout; 
   output itag_vld;
   output itag_hit;

   wire BACKGROUND;  
   wire [`ic_msb-4:0] BIST_ADR;  
   wire BIST_CLK;  
   wire BIST_ON;  
   wire BIST_WE;  
   wire END_SEQ;  
   wire ERRN_ON;  
   wire INVERSE;  
   wire NO_COMP;  
   wire rritag_ERROR;  
   wire [`it_msb+1:0] PATTERN;  

   itag_Controller  Controller_Ins ( .TCLK(clk), .TRESET(bist_reset), .MODE(bist_mode),
               .test_mode(test_mode), .rritag_ERROR(rritag_ERROR), 
               .BIST_ADR(BIST_ADR), .BIST_WE(BIST_WE), .INVERSE(INVERSE),
               .END_SEQ(END_SEQ), .BIST_ON(BIST_ON), .ERRN_ON(ERRN_ON),
               .NO_COMP(NO_COMP), .BACKGROUND(BACKGROUND), 
               .DONE(), .ERROR(ERROR), .FAIL() );

   itag  itag ( .icu_tag_addr(icu_tag_addr), .bist_icu_tag_addr(BIST_ADR),
         .clk(clk), .icu_tag_in(icu_tag_in[`it_msb:0]), .icu_tag_vld(icu_tag_vld),
         .bist_icu_tag_in(PATTERN[`it_msb+1:1]), .bist_icu_tag_vld(PATTERN[0]), 
         .icu_tag_we(icu_tag_we), .bist_icu_tag_we(BIST_WE), .enable(enable),
         .bist_enable(1'b1), .test_mode(test_mode), 
         .itag_dout(itag_dout[`it_msb:0]), .itag_vld(itag_vld), .itag_hit(itag_hit) );

   rritag_LocalBist rritag_Bist_Ins ( .func_do({itag_dout[`it_msb:0],itag_vld}), .BIST_WE(BIST_WE),
         .ERRN_ON(ERRN_ON), .INVERSE(INVERSE), .NO_COMP(NO_COMP),
         .END_SEQ(END_SEQ), .BACKGROUND(BACKGROUND), .BIST_ADR(BIST_ADR),
         .rritag_ERROR(rritag_ERROR), .PATTERN(PATTERN) );

endmodule


// synopsys translate_off
module  itag    (
                icu_tag_in,
                icu_tag_vld,
                icu_tag_we,
                icu_tag_addr,
                enable,
                test_mode,
                bist_icu_tag_in,
                bist_icu_tag_vld,
                bist_icu_tag_we,
                bist_icu_tag_addr,
                bist_enable,
                clk,
                itag_vld,
                itag_dout,
                itag_hit
                );


input   [`it_msb:0]     icu_tag_in;     // Write data_in  -- address portion of tag
input                   icu_tag_vld;    // valid bit   -- valid bit of the tag
input                   icu_tag_we;     // Write enable for tag array
input   [`ic_msb:4]     icu_tag_addr;   // Address inputs for reading tag
input                   enable;         // power down mode
input                   test_mode;
input   [`it_msb:0]     bist_icu_tag_in;        // BIST Write data_in  -- address portion of tag
input                   bist_icu_tag_vld;       // BIST valid bit   -- valid bit of the tag
input                   bist_icu_tag_we;        // BIST Write enable for tag array
input   [`ic_msb:4]     bist_icu_tag_addr;      // BIST Address inputs for reading tag
input                   bist_enable;            // BIST enable
input                   clk;            // Clock
output  [`it_msb:0]     itag_dout;      // Tag output
output                  itag_vld;       // valid bit
output                  itag_hit;

wire    [`it_msb:0]     itag_dout;      // Tag output
wire                    itag_vld;       // valid bit


reg     [`it_msb+1:0]   tag_in_q;
reg     [`ic_msb:4]     addr_q;
reg                     tag_we_q;
reg                     enable_q;
reg                     test_mode_q;

wire                    itag_enable;
wire    [`it_msb+1:0]   sel_tag_in;
wire    [`ic_msb:4]     sel_addr;
wire                    sel_tag_we;


assign itag_enable = (test_mode_q)?bist_enable:enable;
assign sel_addr = (test_mode_q)?bist_icu_tag_addr:icu_tag_addr;
assign sel_tag_in = (test_mode_q)?{bist_icu_tag_in,bist_icu_tag_vld }:{icu_tag_in,icu_tag_vld };
assign sel_tag_we = (test_mode_q)?bist_icu_tag_we:icu_tag_we;

/****** Latch the inputs *****/

always @(posedge clk) fork
        test_mode_q = #1 test_mode;
        tag_in_q = #1 sel_tag_in;
        addr_q = #1 sel_addr;
        enable_q = #1 itag_enable;
        tag_we_q = #1 sel_tag_we;
join


itram   itram(  .adr(addr_q),
                  .do ({itag_dout[`it_msb:0],itag_vld}),
                  .di (tag_in_q[`it_msb+1:0]),
                  .we (tag_we_q),
                  .enable(enable_q),
                  .clk(clk)
                  );

// Replacing hardcoded comparator with configurable (depending on cache size) code.

/*
cmp19_e hit_cmp(  .ai({itag_vld,itag_dout[`it_msb:0]}),
                  .bi({1'b1,tag_in_q[`it_msb+1:1]}),
                  .a_eql_b(itag_hit)
                  );
*/

assign itag_hit = ({itag_vld,itag_dout[`it_msb:0]} == {1'b1,tag_in_q[`it_msb+1:1]});



endmodule

// Module Definition of Tag RAM

module itram(
                adr,
                do,
                di,
                we,
                enable,
                clk
                );

input   [`it_index:0]   adr;
input   [`it_msb+1:0]   di;
output  [`it_msb+1:0]   do;
input                   clk;
input                   we;
input                   enable;


wire    we_ ;
wire    unknown_adr;



// itag ram instantiated, maxblocks = 512 by default
reg [`it_msb+1:0] t_ram [`it_mxblks:0] ;


assign we_      = ~(we & enable & ~clk);

assign unknown_adr = (^adr === 1'bx) ;

// Itag Read
assign do[`it_msb+1:0]   = (!enable)? (do[`it_msb+1:0]):
                            ((unknown_adr)? {2'bx,{`it_msb{1'bx}}}:t_ram[adr]);

// Write itag
always @(negedge we_) t_ram[adr] = di;

endmodule
// synopsys translate_on


module rritag_LocalBist ( BIST_ADR, BIST_WE, func_do, 
    ERRN_ON, INVERSE, NO_COMP, 
    END_SEQ, BACKGROUND, rritag_ERROR, PATTERN );

input  [`it_msb+1:0] func_do;
input  [`ic_msb-4:0] BIST_ADR;
input  BIST_WE, ERRN_ON, 
    INVERSE, NO_COMP, END_SEQ, BACKGROUND;
output rritag_ERROR;
output [`it_msb+1:0] PATTERN;

endmodule


module itag_Controller ( TCLK, TRESET, MODE, rritag_ERROR, BIST_ADR, BIST_WE, 
    INVERSE, END_SEQ, BIST_ON, ERRN_ON, NO_COMP, BACKGROUND, DONE, 
    ERROR, FAIL, test_mode );
input  [1:0] MODE;
output [`ic_msb-4:0] BIST_ADR;
input  TCLK, TRESET, rritag_ERROR, test_mode;
output BIST_WE, INVERSE, END_SEQ, BIST_ON, ERRN_ON, NO_COMP, BACKGROUND, 
    DONE, ERROR, FAIL;

endmodule


module  itag_misc (     enable,
                        icu_tag_in,
                        icu_tag_vld,
                        icu_tag_we,
                        icu_tag_addr,
                        clk
                        );

input                   enable;         // power down mode
input   [`it_msb:0]     icu_tag_in;     // Write data_in  -- address portion of tag
input                   icu_tag_vld;    // valid bit   -- valid bit of the tag
input                   icu_tag_we;     // Write enable for tag array
input   [`ic_msb:4]     icu_tag_addr;   // Address inputs for reading tag
input                   clk;            // Clock
reg    [`it_msb:0]     icu_tag_in_q;   // Write data_in  -- address portion of tag
wire                    icu_tag_vld_q;  // valid bit   -- valid bit of the tag
wire                    icu_tag_we_q;   // Write enable for tag array
reg    [`ic_msb:4]     icu_tag_addr_q; // Address inputs for reading tag
wire                    enable_q;       // power down mode



// Replacing hardcoded flops with configurable (depending on cache size) code.
/*
mj_s_ff_s_d_10 i_icu_tag_addr_ff (      .out(icu_tag_addr_q), 
                                        .din(icu_tag_addr),
                                        .clk(clk)
                                        );
*/

always @(posedge clk) begin

	icu_tag_addr_q = #1 icu_tag_addr;
end


// Replacing hardcoded flops with configurable (depending on cache size) code.

/*
mj_s_ff_s_d_18 i_icu_tag_in_ff (        .out(icu_tag_in_q), 
                                        .din(icu_tag_in),
                                        .clk(clk)
                                        );
*/

always @(posedge clk) begin

	icu_tag_in_q = #1 icu_tag_in;
end



mj_s_ff_s_d i_icu_tag_vld_ff (  .out(icu_tag_vld_q),
                                .in(icu_tag_vld), 
                                .clk(clk)
                                );

mj_s_ff_s_d i_icu_tag_we_ff (   .out(icu_tag_we_q),
                                .in(icu_tag_we), 
                                .clk(clk)
                                );

mj_s_ff_s_d i_enable_ff (       .out(enable_q), 
                                .in(enable),
                                .clk(clk)
                                );

endmodule
