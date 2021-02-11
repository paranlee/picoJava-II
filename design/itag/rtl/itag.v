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





`include        "defines.h"

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

cmp20_e hit_cmp(  .ai({1'b0,itag_vld,itag_dout[`it_msb:0]}),
                  .bi({2'b01,tag_in_q[`it_msb+1:1]}),
                  .a_eql_b(itag_hit)
                  );


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

