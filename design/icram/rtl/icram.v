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


module  icram      (
                icu_din,
                icu_ram_we,
                enable,
                icu_addr,
                clk,
                test_mode,
                bist_enable,
                bist_icu_din,
                bist_icu_ram_we,
                bist_icu_addr,
                icram_dout
        );

input   [31:0]  icu_din;             // Write data_in port
input   [1:0]   icu_ram_we;          // Write enable
input           enable;           // Power down mode. Active-low
input           test_mode;
input   [`ic_msb:3]  icu_addr;       // Address inputs
input           clk;                 // Clock
input           bist_enable;          // BIST enable
input   [31:0]  bist_icu_din;        // BIST Write data_in port
input   [1:0]   bist_icu_ram_we;     // BIST Write enable
input   [`ic_msb:3]  bist_icu_addr;  // BIST Address inputs
output  [63:0]  icram_dout;          // data output


reg [31:0]      data_in_q ;
reg [1:0]       write_en_q ;
reg [`ic_msb:3] addr_q ;
reg             enable_q;
reg             test_mode_q;

wire             icram_enable;
wire [31:0]      sel_data_in ;
wire [1:0]       sel_write_en ;
wire [`ic_msb:3] sel_addr ;


assign icram_enable = (test_mode_q)?bist_enable:enable;
assign sel_addr = (test_mode_q)?bist_icu_addr:icu_addr;
assign sel_data_in = (test_mode_q)?bist_icu_din:icu_din;
assign sel_write_en = (test_mode_q)?bist_icu_ram_we:icu_ram_we;

// latching all the inputs 
always @(posedge clk) fork
        test_mode_q = #1.0 test_mode;
        data_in_q  <= #1.0 sel_data_in;
        write_en_q <= #1.0 sel_write_en;
        addr_q     <= #1.0 sel_addr;
        enable_q  <= #1.0 icram_enable;
   join



iram  iram(
                .adr(addr_q[`ic_msb:3]),
                .do (icram_dout[63:0]),
                .di (data_in_q[31:0]),
                .we (write_en_q),
                .enable(enable_q),
                .clk(clk)
                );

endmodule

// RAM  MODULE
module iram (
        adr,
        do,
        di,
        we,
        enable,
        clk
        );
 
        input [`ic_msb:3] adr ;
        input [31:0] di ;
        input [1:0] we ;
        input clk ;
        input enable;
        output[63:0] do;

        // ram instantiated
        reg [7:0] ic_ram [`ic_size:0] ;
 
        // Derive an active low WE pulse
        wire low_we_, upper_we_;
        wire unknown_adr;


        assign low_we_ = ~(we[0]&enable&~clk);
        assign upper_we_ = ~(we[1]&enable&~clk);
        assign unknown_adr = (^adr === 1'bx);
 
        // Read Dcache 

        assign do[63:56] = ( !enable )? do[63:56] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b000}]);
        assign do[55:48] = ( !enable )? do[55:48] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b001}]);
        assign do[47:40] = ( !enable )? do[47:40] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b010}]);
        assign do[39:32] = ( !enable )? do[39:32] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b011}]);
        assign do[31:24] = ( !enable )? do[31:24] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b100}]);
        assign do[23:16] = ( !enable )? do[23:16] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b101}]);
        assign do[15:8]  = ( !enable )? do[15:8] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b110}]);
        assign do[7:0]   = ( !enable )? do[7:0] :
                           ((unknown_adr)?8'bx:ic_ram[{adr,3'b111}]);


        // Write Dcache

        always @(negedge upper_we_)
          begin
                ic_ram[{adr,3'b000}] = di[31:24] ;
                ic_ram[{adr,3'b001}] = di[23:16] ;
                ic_ram[{adr,3'b010}] = di[15:8] ;
                ic_ram[{adr,3'b011}] = di[7:0] ;
          end

        always @(negedge low_we_) 
          begin
                ic_ram[{adr,3'b100}] = di[31:24] ;
                ic_ram[{adr,3'b101}] = di[23:16] ;
                ic_ram[{adr,3'b110}] = di[15:8] ;
                ic_ram[{adr,3'b111}] = di[7:0] ;
          end
 
endmodule








