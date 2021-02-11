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

module  itag_dummy (    icu_tag_in,
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


endmodule
