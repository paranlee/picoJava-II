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


`include	"defines.h"

module dcu_dpath (
	iu_data_e,
	iu_addr_e,
	misc_din,
	misc_dout,
	dcu_data,
	smu_data,
	smu_addr,
	dcu_addr_out,
	dc_addr_sel,
	dc_data_sel,
	arbiter_sel,
	latch_cf_addr,
	latch_wb_addr,
	latch_addr_c,
	dcu_hit0,
	cf_word_addr,
	repl_word_addr,
	word_addr,
	diag_stat_bits,
	dtag_rd_c,
	wb_sel,
	wb_ce,
	repl_addr,
	req_addr_sel,
	stat_addr_sel,
	algn_sign_sel,
	algn_size_sel,
	algn_sel_7_0,
	algn_sel_15_8,
	algn_sel_23_16,
	algn_sel_31_24,
	swap_sel_7_0,
	swap_sel_15_8,
	swap_sel_23_16,
	swap_sel_31_24,
	merge_sel,
	fill_byte,
	dcu_addr_c_31,
	latch_wr_data,
	dcu_tag_sel,
	dtg_dout,
	dcu_din_e,
	dcram_dout,
	dcu_stat_addr,
	dcu_tag_in,
	dcu_biu_addr,
	dcu_biu_data,
	dcu_dout_sel,
	biu_data,
	clk,
	sin,
	so,
	sm
	);
	

input 	[31:0]		iu_data_e;		// Data from IU
input	[31:0]		iu_addr_e;		// Address from IU
input	[31:0]		misc_din ;		// Diagnostic data input
output	[31:0]		misc_dout;		// Diagnostic data output
output	[31:0]		dcu_data;		// Data out of DCU to IU/Dribbler
output	[`dt_addr_msb:`dc_msb+1]  dcu_tag_in;	// Data input to the tag ram
input	[31:0]		smu_data;		// Data from Dribbler
input	[31:0]		smu_addr;		// Address from Dribbler
input	[63:0]		dcram_dout;		// Output of Data RAM
output	[31:0]		dcu_addr_out;		// Address of data to be accessed in cache next cycle
input	[3:0]		dc_addr_sel;		// select Addr to be indexed into rams. 
input	[1:0]		word_addr;		// select word of a given cache line
input	[2:0]		diag_stat_bits;		// status bits for diagnostic reads
input			dtag_rd_c;		// Read Dcache tag inst in C stage
input			arbiter_sel;		// selects arbitrates iu and smu addr/data
input			latch_addr_c;		// CE to latch the addr/data in C stage
input	[3:0]		dc_data_sel;		// select data input to dcram 
input			latch_cf_addr ;		// CE to latch cache fill addr
input			latch_wb_addr ;		// CE to latch write back addr
input			dcu_hit0;		// cache hit in set 0
output	[3:0]		cf_word_addr;		// word offset of word being filled in
output	[3:0]		repl_word_addr;		// word offset of word being replaced
input			dcu_addr_c_31;		// used to select set for diagnostic reads
input			dcu_dout_sel;		// selects data to be sent onto memory bus
input	[1:0]		fill_byte;
input	[3:0]		wb_sel;			// Select particular 32 bit writeback register
input	[1:0]		wb_ce;			// CE to store data into particular wbreg
input			req_addr_sel ;		// select betn writeback addr,NC addr, fill cycle addr
input			stat_addr_sel;		// select addr to access status register
input			dcu_tag_sel;		// Select data input to the tag ram
input	[3:0]		repl_addr;		// word offset of line being replaced
input	[4:0]		algn_sign_sel;		// select sign extension
input	[1:0]		algn_size_sel;		// select sign depending on size of data
input	[3:0]		algn_sel_7_0;		// sel the correct 7:0 bits (rotation/align)
input	[3:0]		algn_sel_15_8;		// sel the correct 15:8 bits (rotation/align)
input			algn_sel_23_16;		// sel the correct 23:16 bits (rotation/align)
input			algn_sel_31_24;		// sel the correct 31:24 bits (rotation/align)
input	[2:0]		swap_sel_7_0 ;		// sel the correct 7:0 bits during merging
input	[2:0]		swap_sel_15_8 ;		// sel the correct 15:8 bits during merging
input	[2:0]		swap_sel_23_16 ;	// sel the correct 23:16 bits during merging
input	[2:0]		swap_sel_31_24 ;	// sel the correct 31:24 bits during merging
input	[3:0]		merge_sel;		// final byte selects during merging
input			latch_wr_data	;	// latch write miss data
input	[`dt_msb:0]	dtg_dout;		// Data out of the Tag for writeback addressing 
output	[31:0]		dcu_din_e;		// Data into the Data RAM
output  [`dc_msb:0]	dcu_stat_addr;		// Address for writes to status reg/ data RAM
output	[31:0]		dcu_biu_addr;		// Address to the BIU
output	[31:0]		dcu_biu_data;		// Data to the BIU
input	[31:0]		biu_data;		// Data from the BIU
input			clk;			// clock
input			sin;		// scan in
output			so;		// scan out
input			sm;		// scan enable

wire	[31:0]		dcu_addr_c;
wire	[31:0]		dcu_stat_addr_tmp;
wire	[31:0]		dcu_addr_out;
wire	[31:0]		dcu_addr_e;
wire	[31:0]		wb_addr	;	// addr of write buffer data
wire	[`dt_addr_msb+2:0]	wb_addr_tmp;	// Intermediate storage of addr of write buffer data
wire	[31:0]		cf_addr ;	// addr of cache fill line
wire	[31:0]		wb_addr_d1;
wire	[31:0]		wr_miss	;	// write miss data
wire	[31:0]		merge_data;	// data after merging write miss data & cache fill data
wire	[63:0]		align_data;	// Data after alignment/rotation
wire	[31:0]		wrbuf_data;
wire	[31:0]		dcu_data_c;
wire	[31:0]		dcu_data_e;
wire	[31:0]		swap_dout;
wire	[31:0]		diag_tagout;
wire	[31:0]		misc_rd_data;
wire	[31:0]		dcu_tag_in_tmp;

// Address Datapath

// Selects IU or SMU request for Dcache. When pipe stalls, recirculates addr
// Recirculation is done when a cache miss occurs while there is an outstanding memory request
// Also recirculated when there is a write hit followed by a cache fill transaction

mux2_32	dcu_addr_e_mux(.out(dcu_addr_e[31:0]),
			.in1(iu_addr_e[31:0]),
			.in0(smu_addr[31:0]),
			.sel({arbiter_sel,~arbiter_sel}));

ff_se_32 dcu_addr_c_reg(.out(dcu_addr_c[31:0]),
	.din(dcu_addr_e[31:0]),
	.clk(clk),
	.enable(latch_addr_c));

// selct addr_c for replacing old line
// select cf_addr for cache fill line
// for normal operation select dcu_addr_e
// NOTE: The dcu_addr_out[1:0] are used are used as addr[3:2] for bank 1,
// This is done to accomodate accessing different word of the same line 
// in the two banks. this scenario arises for replacing dirty line due
// to set interleaving.

mux4_32	dcu_adout_mux(.out(dcu_addr_out[31:0]),
		.in3({dcu_addr_c[31:4],repl_addr[3:0]}),
		.in2({cf_addr[31:4],word_addr[1:0],word_addr[1:0]}),
		.in1({iu_addr_e[31:2],iu_addr_e[3:2]}),
		.in0({smu_addr[31:2],smu_addr[3:2]}),
		.sel(dc_addr_sel[3:0]));


// cf_addr --> cache fill address. Used for all cache fill transactions.
// This register get its new value whenever a load/store misses the cache.

ff_se_32 cf_addr_reg(.out(cf_addr[31:0]),
        .din(dcu_addr_c[31:0]),
        .clk(clk),
	.enable(latch_cf_addr));

assign	cf_word_addr[3:0]	= cf_addr[3:0] ;
assign	repl_word_addr[3:0]	= dcu_addr_c[3:0];

// Address for DC RAM & for Status RAM
mux2_32 dcu_stat_addr_mux(.out(dcu_stat_addr_tmp[31:0]),
                        .in1({dcu_addr_c[31:2],dcu_addr_c[3:2]}),
                        .in0(dcu_addr_out[31:0]),
                        .sel({stat_addr_sel,~stat_addr_sel}));

assign	dcu_stat_addr[`dc_msb:0] = dcu_stat_addr_tmp[`dc_msb:0] ;
 


// Data input to the Tag Ram
// select E stage addr for tag input in case of diagnostic writes
mux2_32 dcu_tag_in_mux(.out(dcu_tag_in_tmp[31:0]),
                        .in1(cf_addr[31:0]),
                        .in0(misc_din[31:0]),
                        .sel({dcu_tag_sel,~dcu_tag_sel}));

assign	dcu_tag_in[`dt_addr_msb:`dc_msb+1] = dcu_tag_in_tmp[`dt_addr_msb:`dc_msb+1] ;


// Data output of Tag ram

assign	diag_tagout[31:`dc_msb+1] = wb_addr[31:`dc_msb+1];
assign	diag_tagout[2:0] 	= diag_stat_bits[2:0] ;
assign	diag_tagout[`dc_msb:3]	= {(`dc_msb-2){1'b0}} ;

// The upper 2 bits are set to 0 for dt_addr_msb = 29.

assign 	wb_addr_tmp[`dt_addr_msb+2:`dc_msb+1] = {2'b00,dtg_dout};
assign  wb_addr[31:0] = wb_addr_tmp[31:0];

assign  wb_addr[`dc_msb:4] = dcu_addr_c[`dc_msb:4] ;
assign	wb_addr[3:0]	 = 4'b0000 ;


 
// Used to store copyback transaction addr
ff_se_32 wb_addr_reg(.out(wb_addr_d1[31:0]),
        .din(wb_addr[31:0]),
        .clk(clk),
        .enable(latch_wb_addr));

mux2_32 dcu_biu_adr_mux(.out(dcu_biu_addr[31:0]),
                        .in1({cf_addr[31:2],fill_byte}),
                        .in0(wb_addr_d1[31:0]),
                        .sel({req_addr_sel,~req_addr_sel}));
 



/*******      Data  Path	******/

mux2_32 dcu_data_e_mux(.out(dcu_data_e[31:0]),
                        .in1(iu_data_e[31:0]),
                        .in0(smu_data[31:0]),
                        .sel({arbiter_sel,~arbiter_sel}));

ff_se_32 dcu_data_reg (.out(dcu_data_c[31:0]),
        .din(dcu_data_e[31:0]),
	.enable (latch_addr_c),
        .clk(clk));

// For endianness & aligning stores 
swapper		data_swapper( 
			.din		(dcu_data_c[31:0]),
			.sel_7_0	(swap_sel_7_0[2:0]),
			.sel_15_8	(swap_sel_15_8[2:0]),
			.sel_23_16	(swap_sel_23_16[2:0]),
			.sel_31_24	(swap_sel_31_24[2:0]),
			.dout		(swap_dout[31:0]));

ff_se_32 write_miss_reg(.out(wr_miss[31:0]),
			.din(swap_dout[31:0]),
			.clk(clk),
			.enable(latch_wr_data));

mux2_8 merge_data_mux3(.out(merge_data[31:24]),
                        .in1(wr_miss[31:24]),
                        .in0(biu_data[31:24]),
                        .sel({merge_sel[3],~merge_sel[3]}));

mux2_8 merge_data_mux2(.out(merge_data[23:16]),
                        .in1(wr_miss[23:16]),
                        .in0(biu_data[23:16]),
                        .sel({merge_sel[2],~merge_sel[2]}));
 
mux2_8 merge_data_mux1(.out(merge_data[15:8]),
                        .in1(wr_miss[15:8]),
                        .in0(biu_data[15:8]),
                        .sel({merge_sel[1],~merge_sel[1]}));
 
mux2_8 merge_data_mux0(.out(merge_data[7:0]),
                        .in1(wr_miss[7:0]),
                        .in0(biu_data[7:0]),
                        .sel({merge_sel[0],~merge_sel[0]}));

mux4_32  dcu_data_c_mux(.out(dcu_din_e[31:0]),
	.in3({32{1'b0}}),		// cache line zeroing
	.in2(misc_din[31:0]),		// diagnostic writes
	.in1(merge_data[31:0]),		// cache fill write or write misses 
	.in0(swap_dout[31:0]),		// Write Hits
	.sel(dc_data_sel[3:0]) );


/***** Alignment Muxes -- Rotation ******/
// Assumption - data is aligned on boundaries //
// Endianness is also corrected at this point

aligner		aligner_1(
		.dcram_dout	(dcram_dout[31:0]),
		.sign_sel	(algn_sign_sel[4:0]),
		.algn_sel_7_0	(algn_sel_7_0[3:0] ),
		.algn_sel_15_8	(algn_sel_15_8[3:0]),
		.algn_sel_23_16	(algn_sel_23_16),
		.algn_sel_31_24	(algn_sel_31_24),
		.algn_size_sel	(algn_size_sel[1:0]),
		.align_data	(align_data[31:0]));

aligner       aligner_2(
                .dcram_dout        (dcram_dout[63:32]),
                .sign_sel       (algn_sign_sel[4:0]),
                .algn_sel_7_0   (algn_sel_7_0[3:0] ),
                .algn_sel_15_8  (algn_sel_15_8[3:0]),
                .algn_sel_23_16 (algn_sel_23_16),
                .algn_sel_31_24 (algn_sel_31_24),
                .algn_size_sel  (algn_size_sel[1:0]),
                .align_data     (align_data[63:32])
                );


wire [31:0] dcu_data_l;
mx21_32_l dcu_d_mx (
	.mx_out(dcu_data_l), 
	.sel(dcu_hit0), 
	.in0(align_data[63:32]), 
	.in1(align_data[31: 0]) );
assign dcu_data = ~ dcu_data_l;

// Select data for diagnostic reads and replacing dirty lines into writebuffer

mx21_32_l misc_rd_d_mx (
	.mx_out(misc_rd_data), 		// inverted value
	.sel(dcu_addr_c_31), 
	.in0(dcram_dout[31:0]), 
	.in1(dcram_dout[63:32]) );

mx21_32_l dtag_rd_d_mx (
	.mx_out(misc_dout), 
	.sel(dtag_rd_c), 
	.in0(misc_rd_data), 		// inverted value
	.in1(~diag_tagout) );

wire [31:0] dcu_biu_data_l;
mx21_32_l dcu_biu_d_mx (
	.mx_out(dcu_biu_data_l), 
	.sel(dcu_dout_sel), 
	.in0(wrbuf_data), 
	.in1(wr_miss) );
assign dcu_biu_data = ~ dcu_biu_data_l;


/**************************  WRITE BUFFER  **********************************/

buffer       wr_buffer  ( 
                .din            (dcram_dout[63:0]),
                .dout           (wrbuf_data[31:0]),
                .buf_sel        (wb_sel[3:0]),
                .buf_ce         (wb_ce[1:0]),
                .clk            (clk),
                .so             (),
                .sin             (),
                .sm             ());


endmodule

 

module aligner (

	dcram_dout,
	sign_sel,
	algn_sel_7_0,
	algn_sel_15_8,
	algn_sel_23_16,
	algn_sel_31_24,
	algn_size_sel,
	align_data
	);

input	[31:0]	 	dcram_dout;
input	[4:0]		sign_sel;
input	[3:0]		algn_sel_7_0;		//sel the correct 7:0 bits (rotation)
input   [3:0]           algn_sel_15_8;          // sel the correct 15:8 bits (rotation)
input                   algn_sel_23_16;         // sel the correct 23:16 bits (rotation)
input                   algn_sel_31_24;         // sel the correct 31:24 bits (rotation)
input   [1:0]           algn_size_sel;          // select sign extension depending on size of data
output	[31:0]		align_data ;

wire	[31:8]	unsign_data	;
wire		sign;

mux5    sign_sel_mux(.out(sign),
        .in4(1'b0),
        .in3(dcram_dout[7]),
        .in2(dcram_dout[15]),
        .in1(dcram_dout[23]),
        .in0(dcram_dout[31]),
        .sel(sign_sel[4:0]) );
 
mux4_8  align_data_7_0_mux(.out(align_data[7:0]),
        .in3(dcram_dout[31:24]), 
	.in2(dcram_dout[23:16]), 
	.in1(dcram_dout[15:8]),
        .in0(dcram_dout[7:0] ),
        .sel(algn_sel_7_0[3:0]) );

mux4_8  unsign_data_15_8_mux(.out(unsign_data[15:8]),
        .in3(dcram_dout[31:24]),
        .in2(dcram_dout[23:16]),
        .in1(dcram_dout[15:8]),
        .in0(dcram_dout[7:0] ),
        .sel(algn_sel_15_8[3:0]) );
 
mux2_8 unsign_data_mux1(.out(unsign_data[23:16]),
                        .in1(dcram_dout[23:16]),
                        .in0(dcram_dout[15:8]),
                        .sel({algn_sel_23_16,~algn_sel_23_16}));

mux2_8 unsign_data_mux2(.out(unsign_data[31:24]),
                        .in1(dcram_dout[31:24]),
                        .in0(dcram_dout[7:0]),
                        .sel({algn_sel_31_24,~algn_sel_31_24}));

mux2_8 align_data_mux1(.out(align_data[15:8]),
                        .in1(unsign_data[15:8]),
                        .in0({8{sign}}),
                        .sel({algn_size_sel[0],~algn_size_sel[0]}));

mux2_16 align_data_mux2(.out(align_data[31:16]),
                        .in1(unsign_data[31:16]),
                        .in0({16{sign}}),
                        .sel({algn_size_sel[1],~algn_size_sel[1]}));
 

endmodule



module	swapper(
		din,
		sel_7_0,
                sel_15_8,
                sel_23_16,
                sel_31_24,
		dout);

input	[31:0]		din;
input	[2:0]           sel_7_0 ;
input   [2:0]           sel_15_8        ;
input   [2:0]           sel_23_16       ;
input   [2:0]           sel_31_24       ;
output	[31:0]		dout	;

mux3_8          swap_data_31_24_mux(.out(dout[31:24]),
                                .in2(din[31:24]),
                                .in1(din[15:8]),
                                .in0(din[7:0]),
                                .sel(sel_31_24[2:0]) );
 
mux3_8          swap_data_23_16_mux(.out(dout[23:16]),
                                .in2(din[23:16]),
                                .in1(din[15:8]),
                                .in0(din[7:0]),
                                .sel(sel_23_16[2:0]) );
 
mux3_8          swap_data_15_8_mux(.out(dout[15:8]),
                                .in2(din[23:16]),
                                .in1(din[15:8]),
                                .in0(din[7:0]),
                                .sel(sel_15_8[2:0]) );
 
mux3_8          swap_data_7_0_mux(.out(dout[7:0]),
                                .in2(din[31:24]),
                                .in1(din[15:8]),
                                .in0(din[7:0]),
                                .sel(sel_7_0[2:0]) );

endmodule


module 	buffer	( din,
		dout,
		buf_sel,
		buf_ce,
		clk,
		so,
		sin,
		sm );

input	[63:0]		din;
output	[31:0]		dout;
input	[3:0]		buf_sel;
input	[1:0]		buf_ce;
input			clk;
input			sin;
output			so;
input			sm ;

wire	[31:0]	buf_data0,buf_data1,buf_data2,buf_data3 ;

ff_se_32  buf0(.out(buf_data0[31:0]),
        .din(din[63:32]),
        .clk(clk),
        .enable(buf_ce[0]));
 
ff_se_32  buf1(.out(buf_data1[31:0]),
        .din(din[31:0]),
        .clk(clk),
        .enable(buf_ce[0]));
 
ff_se_32  buf2(.out(buf_data2[31:0]),
        .din(din[63:32]),
        .clk(clk),
        .enable(buf_ce[1]));
 
ff_se_32  buf3(.out(buf_data3[31:0]),
        .din(din[31:0]),
        .clk(clk),
        .enable(buf_ce[1]));

mux4_32  buf_mux(.out(dout[31:0]),
        .in3(buf_data3[31:0]),
        .in2(buf_data2[31:0]),
        .in1(buf_data1[31:0]),
        .in0(buf_data0[31:0]),
        .sel(buf_sel[3:0]) );

endmodule


