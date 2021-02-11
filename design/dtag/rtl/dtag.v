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

/*
`define  dc_size	8191  	  // Size of 1 set of Cache Ram.
`define	 dc_msb		12	  // MSB of Address Bus needed to index into the cache 
`define  dt_msb		18	  // MSB of Dcache Tag Field (Used for storing tag of a cache line)
`define  dt_index	8	  // MSB of Tag address used to index tag of a cache.
`define  dt_mxblks	512       // Number of Blocks in the cache
*/

module 	dtag	(
		tag_in,
		tag_we,
		cmp_addr_in,
		set_sel,
		wb_set_sel,
		addr,
		stat_in,
		stat_we,
		stat_addr, 
		enable,
		clk,
		hit0_out,
		hit1_out,
		dtag_dout,
		stat_out,
		bist_tag_we0,
		bist_tag_we1,
		bist_tag_in,
		bist_stat_in,
		bist_stat_we,
		bist_addr,
		bist_stat_addr,
		bist_enable,
		bist_tag_dout0,
		bist_tag_dout1,
		test_mode
		);


input	[`dt_msb:0]	tag_in;	// Write data_in
input	[`dt_msb:0]	bist_tag_in;	// Write data_in
input	[`dt_msb:0]	cmp_addr_in;  // dcu_addr_c for hit/miss decision, out of FF.
input	[4:0]		stat_in;	// Write status bus
input	[4:0]		bist_stat_in;	// Write status bus
input			set_sel;	// Select set 
input			wb_set_sel;	// Select set for tag_out
input			tag_we;	// Write enable for tag array
input			bist_tag_we0;	// Write enable for tag array
input			bist_tag_we1;	// Write enable for tag array
input	[4:0]		stat_we ;	// Write enable for status array
input	[4:0]		bist_stat_we ;	// Write enable for status array
input	[`dc_msb:4]	addr;	// Address inputs for reading tags and status reg
input	[`dc_msb-4:0]		bist_addr;	// Address inputs for reading tags and status reg
input	[`dc_msb:4]	stat_addr;	// Address inputs for writing into status regs
input	[`dc_msb:4]	bist_stat_addr;	// Address inputs for writing into status regs

input			enable;	// power down mode
input			bist_enable;	// power down mode
input			clk;		// Clock
input			test_mode;
output 			hit0_out;       // d$ hit on set0
output 			hit1_out;    	// d$ hit on set1 
output  [`dt_msb:0]	dtag_dout;	// Tag output for lower bits of wb_addr 
output  [`dt_msb:0]	bist_tag_dout0;	// Tag output for lower bits of wb_addr 
output  [`dt_msb:0]	bist_tag_dout1;	// Tag output for lower bits of wb_addr 
output	[4:0]		stat_out;	// status reg output


wire	[`dt_msb:0]	tag_in;
wire	[`dt_msb:0]	i_tag_in;
reg	[`dt_msb:0]	cmp_addr_q; 
wire	[4:0]		stat_in;
wire	[4:0]		i_stat_in;
wire			set_sel, wb_set_sel;
wire			i_set_sel, i_wb_set_sel;
wire 			tag_we;
wire 			i_tag_we;
wire	[4:0]		stat_we;
wire	[4:0]		i_stat_we;
wire	[`dc_msb:4]	i_addr;
wire	[`dc_msb:4]	i_stat_addr;
wire			i_enable;

reg	[`dt_msb:0]	tag_in_q;		
reg	[4:0]		stat_in_q;
reg	[`dc_msb:4]	addr1_q;	
reg	[`dc_msb:4]	addr2_q;	
reg			tag_we_q;
reg			pwrdown_q;
reg			set_sel_q;
reg	[4:0]		statwe_q;


wire	[4:0]		statwe ;
wire	[1:0]		we;
wire    [`dt_msb:0]     dout0,dout1;
reg     [1:0] 		i_bist_we;

// synopsys translate_off

/****** Latch the inputs *****/

assign i_tag_we = tag_we;
assign i_tag_in = test_mode ? bist_tag_in : tag_in;
assign i_stat_in = test_mode ? bist_stat_in : stat_in;
assign i_stat_we = test_mode ? bist_stat_we : stat_we;
assign i_addr = test_mode ? bist_addr : addr;
assign i_enable = test_mode ? bist_enable : enable;
assign i_set_sel = set_sel;
assign i_wb_set_sel = wb_set_sel;
assign i_stat_addr = test_mode ? bist_stat_addr : stat_addr;

always @(posedge clk) 
	pwrdown_q = #1 !i_enable ;

always @(posedge clk) 
if (i_enable)
begin
fork
	tag_in_q = #1 i_tag_in;
	stat_in_q = #1 i_stat_in;
	addr1_q = #1 i_addr;
	addr2_q = #1 i_stat_addr;
	statwe_q = #1  i_stat_we ;
	tag_we_q = #1 i_tag_we ;
	set_sel_q = #1 i_set_sel ;
	cmp_addr_q = #1 cmp_addr_in ;
	i_bist_we = #1 {bist_tag_we1,bist_tag_we0};
	join
end

assign	we[0] = test_mode ? i_bist_we[0] : tag_we_q & !set_sel_q ;
assign	we[1] = test_mode ? i_bist_we[1] : tag_we_q & set_sel_q ;

assign	statwe[4] =  statwe_q[4];
assign	statwe[3] =  set_sel_q & statwe_q[3] ;
assign	statwe[2] =  set_sel_q & statwe_q[2] ;
assign	statwe[1] =  !set_sel_q & statwe_q[1] ;
assign	statwe[0] =  !set_sel_q & statwe_q[0] ;


assign dtag_dout = (i_wb_set_sel) ?  dout1 : dout0;

// 20 bit comparator here
assign hit1_out = ( { dout1,1'b1 } == { cmp_addr_q, stat_out[2] } );

assign hit0_out = ( { dout0,1'b1 } == { cmp_addr_q, stat_out[0] } );

assign bist_tag_dout0 = dout0;
assign bist_tag_dout1 = dout1;

dtram		dtag_ram1(
                .adr(addr1_q),
                .do (dout1[`dt_msb:0]),
                .di (tag_in_q[`dt_msb:0]),
                .we (we[1]),
		.pwrdown(pwrdown_q),
                .clk(clk)
                );

dtram       	dtag_ram0(
                .adr(addr1_q),
                .do (dout0[`dt_msb:0]),
                .di (tag_in_q[`dt_msb:0]),
                .we (we[0]),
		.pwrdown(pwrdown_q),
                .clk(clk)
                );

stram		status_ram(
		.adr1(addr1_q),
		.adr2(addr2_q),
		.do(stat_out[4:0]),
		.di(stat_in_q[4:0]),
		.we(statwe[4:0]),
		.pwrdown(pwrdown_q),
		.clk(clk)
		);

// synopsys translate_on

endmodule

// Module Definition of Tag RAMS and status RAM

module dtram(
		adr,
		do,
		di,
		we,
		pwrdown,
		clk
		);

input	[`dt_index:0]	adr;
input	[`dt_msb:0]	di ;
output	[`dt_msb:0]	do ;
input			clk;
input			we ;
input			pwrdown;


wire	we_ ;
wire	unknown_adr ;


// synopsys translate_off

// Dtag ram instantiated, maxblocks = 256 in decaf
reg [`dt_msb:0] t_ram [0:`dt_mxblks] ;


assign we_      = ~(we & !pwrdown & ~clk);
assign unknown_adr = (^adr === 1'bx) ;

// Dtag Read
assign do[`dt_msb:0]   = (pwrdown | unknown_adr)? {do[`dt_msb:0]}:t_ram[adr];

// Write Dtag
always @(negedge we_) t_ram[adr] = di;

// synopsys translate_on

endmodule



module stram(
                adr1,
		adr2,
                do,
                di,
                we,
		pwrdown,
                clk
                );
 
input   [`dt_index:0]   adr1;	// used for read of status register
input   [`dt_index:0]   adr2;	// used for write into status register
input   [4:0]     	di ;	// data in
output  [4:0]     	do ;	// data out
input                   clk;
input   [4:0]           we ;	// write enable
input			pwrdown;// Power Down
 
 
wire    	we_ ;
wire	[4:0]	do_int;
wire		unknown_adr ;
wire		statwe ;
wire	[4:0]	tmp;
 

// synopsys translate_off
 
// Dtag Status ram instantiated, maxblocks = 256 in decaf
reg [4:0]stram [0:`dt_mxblks] ;
 
assign	statwe = we[4] | we[3] | we[2] | we[1] | we[0] ;
assign we_  = ~(statwe & !pwrdown & ~clk) ;
assign unknown_adr = (^adr1 === 1'bx) ;
 
// Status Read
assign do[4:0]     = (pwrdown | unknown_adr)?do[4:0]:stram[adr1[`dt_index:0]];
 
// Write status reg
assign do_int[4:0]	= stram[adr2[`dt_index:0]] ;
assign	tmp[4]	= (we[4] & !pwrdown )? di[4]: do_int[4] ;
assign	tmp[3]	= (we[3] & !pwrdown )? di[3]: do_int[3] ;
assign	tmp[2]	= (we[2] & !pwrdown )? di[2]: do_int[2] ;
assign	tmp[1]	= (we[1] & !pwrdown )? di[1]: do_int[1] ;
assign	tmp[0]	= (we[0] & !pwrdown )? di[0]: do_int[0] ;
always @(negedge we_) stram[adr2] = tmp[4:0] ;
 
// synopsys translate_on
 
endmodule
 
