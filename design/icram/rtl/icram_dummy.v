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

module  icram_dummy(   icu_din,
                        icu_ram_we,
                        enable,
                        icu_addr,
                        icram_dout,
                        clk,
                        bist_mode,
                        bist_reset,
                        test_mode,
                        icache_test_err_l,
                        sin,
                        sm,
                        so
                        );

input       [31:0]      icu_din;             // Write data_in port
input        [1:0]      icu_ram_we;          // Write enable
input                   enable;              // Power down mode. Active-low
input  [`ic_msb:3]      icu_addr;            // Address inputs
output      [63:0]      icram_dout;          // data output
input                   clk;                 // Clock
input                   test_mode;           // BIST enable
input        [1:0]      bist_mode;           // BIST mode
input                   bist_reset;          // BIST reset
output                  icache_test_err_l;
input                   sin;
input                   sm;
output                  so;

wire        [31:0]      bist_icu_din;        // BIST Write data_in port
wire         [1:0]      bist_icu_ram_we;     // BIST Write enable
wire   [`ic_msb:3]      bist_icu_addr;       // BIST Address inputs
wire                    bist_enable;
wire        [63:0]      icram_dout;          // data output => icram_bist


endmodule
