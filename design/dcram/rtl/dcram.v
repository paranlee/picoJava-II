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





`include "defines.h"

/*****************
`define	 dc_msb		12	  	// MSB of Address Bus
`define	 dc_size	8*1024 -1  	// Size of 1 set of Cache Ram.
*******************************************************************/

module  dcram      (
                data_in,
                we,
		bypass,
		bank_sel,
                enable,  
		bist_enable,
                addr,
                clk,
                data_out,
		bist_data_in, 
		bist_we,
		bist_addr,
		test_mode,
		dcache_ram0_do,
		dcache_ram1_do,
		sin,
		sm,
		so

	);

input   [63:0]  data_in;      // Write data_in port
input   [63:0]  bist_data_in;      // Write data_in port
input   [3:0]   we; 		// Byte select when write
input   [3:0]   bist_we; 		// Byte select when write
input		bypass;
input           enable;     // Power down mode,active low
input		bist_enable;
input   [`dc_msb:0]  addr;     // Address inputs
input   [`dc_msb-2:0]  bist_addr;     // Address inputs
input	[1:0]	bank_sel;	// Set select for writes & diagnostic writes
input           clk;            // Clock
input		test_mode;
input		sin;
input		sm;
 
output  [63:0]  data_out;     // data output
output  [31:0]  dcache_ram0_do;     // data output
output  [31:0]  dcache_ram1_do;     // data output
output 		so;
 
// synopsys translate_off

reg [63:0] 	data_in_q ;
reg [3:0]  	byte_sel_q ;
reg [3:0]  	bist_sel_q ;
reg [`dc_msb-2:0] 	addr_q_0 ;	
reg [`dc_msb-2:0] 	addr_q_1 ;	
reg [1:0]	bank_sel_q;
reg		pwrdown_q;
reg		bypass_q;
reg		so;
reg		addr_q2;

wire[3:0]	we0;
wire[3:0]	we1;
wire[63:0]	dout;
wire[2:0]	dout_sel;

assign dcache_ram0_do = data_out[31:0];
assign dcache_ram1_do = data_out[63:32];

wire [63:0] i_data_in = test_mode ? bist_data_in : data_in;
wire [3:0] i_we = we;
wire i_bypass = test_mode ? 1'b0 : bypass;
wire i_enable = test_mode ? bist_enable : enable;
wire [`dc_msb-2:0] i_addr1 = test_mode ? bist_addr : addr[`dc_msb:2];
wire [`dc_msb-2:0] i_addr0 = test_mode ? bist_addr : {addr[`dc_msb:4],addr[1:0]};
wire i_addr2 = test_mode ? bist_addr[2] : addr[2];
wire [1:0] i_bank_sel = bank_sel;

// latching all the inputs 
always @(posedge clk) 
	pwrdown_q = #1  !i_enable ;

always @(posedge clk) 
if (i_enable)
begin
fork
        data_in_q = #1  i_data_in;
        byte_sel_q = #1 i_we;
        bist_sel_q = #1 bist_we;
        addr_q_0 =  #1 i_addr0; 
        addr_q_1 =  #1 i_addr1; 
        addr_q2 =  #1 i_addr2; 
	bank_sel_q  = #1  i_bank_sel;
	bypass_q =  #1  i_bypass ;
join
end



// Generating Write Enables
assign 	we0[3]	= test_mode ? bist_sel_q[1] : byte_sel_q[3]& bank_sel_q[0] ;
assign 	we0[2]	= test_mode ? bist_sel_q[1] : byte_sel_q[2]& bank_sel_q[0] ;
assign 	we0[1]	= test_mode ? bist_sel_q[0] : byte_sel_q[1]& bank_sel_q[0] ;
assign 	we0[0]	= test_mode ? bist_sel_q[0] : byte_sel_q[0]& bank_sel_q[0] ;

assign  we1[3]  = test_mode ? bist_sel_q[3] : byte_sel_q[3]&  bank_sel_q[1] ;
assign  we1[2]  = test_mode ? bist_sel_q[3] : byte_sel_q[2]&  bank_sel_q[1] ;
assign  we1[1]  = test_mode ? bist_sel_q[2] : byte_sel_q[1]&  bank_sel_q[1] ;
assign  we1[0]  = test_mode ? bist_sel_q[2] : byte_sel_q[0]&  bank_sel_q[1] ;


dram  dcache_ram1(
                .adr(addr_q_1),
                .do (dout[63:32]),
                .di (data_in_q[63:32]),
                .we (we1[3:0]),
		.pwrdown(pwrdown_q),
                .clk(clk)
                );

dram	dcache_ram0(
		.adr(addr_q_0),
                .do (dout[31:0]),
                .di (data_in_q[31:0]),
                .we (we0[3:0]),
		.pwrdown(pwrdown_q),
                .clk(clk)
                );

// Bypass data in case of write 
// Flip sets in case of addr[2] = 1 ;
// normal read in case of !addr[2] = 0 ;


assign	dout_sel[0] =  bypass_q ;
assign	dout_sel[1] =  !bypass_q & !addr_q2 ;
assign	dout_sel[2] =  !bypass_q & addr_q2 ;

assign  data_out[63:32] = (dout_sel[0])?data_in_q[31:0]:(dout_sel[1])?dout[63:32]:dout[31:0];
assign  data_out[31:0] = (dout_sel[0])?data_in_q[31:0]:(dout_sel[1])?dout[31:0]:dout[63:32];

// synopsys translate_on  

endmodule

// RAM  MODULE
module dram (
        adr,
        do,
        di,
        we,
	pwrdown,
        clk
        );
 
        input [`dc_msb:2] adr ;
        input [31:0] di ;
        input [3:0] we ;
        input clk ;
	input pwrdown;
        output[31:0] do;

// synopsys translate_off
        // ram instantiated
        reg [7:0] dc_ram [0:`dc_size] ;         // (2^12 - 1)
 
        // Derive an active low WE pulse
        wire [3:0] we_;
	wire unknown_adr;



        assign we_[3:0] = (~{we[3:0] & {4{!pwrdown}}&{4{~clk}}});
	assign unknown_adr = (^adr === 1'bx);
 
        // Read Dcache 
 
        assign do[31:24] = ( pwrdown | unknown_adr )? do[31:24]:dc_ram[{adr[`dc_msb:2],2'b00}];
        assign do[23:16] = ( pwrdown | unknown_adr )? do[23:16]:dc_ram[{adr[`dc_msb:2],2'b01}];
        assign do[15:8]  = ( pwrdown | unknown_adr )? do[15:8]:dc_ram[{adr[`dc_msb:2],2'b10}];
        assign do[7:0]   = ( pwrdown | unknown_adr )? do[7:0]:dc_ram[{adr[`dc_msb:2],2'b11}];
 
        // Write Dcache

        always @(negedge we_[3]) dc_ram[{adr,2'b00}] <= #2 di[31:24] ;
        always @(negedge we_[2]) dc_ram[{adr,2'b01}] <= #2 di[23:16] ;
        always @(negedge we_[1]) dc_ram[{adr,2'b10}] <= #2 di[15:8]  ;
        always @(negedge we_[0]) dc_ram[{adr,2'b11}] <= #2 di[7:0]   ;
 
// synopsys translate_on
 
endmodule
