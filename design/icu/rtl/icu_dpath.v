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
module icu_dpath (
	iu_addr_e,
	misc_din,
	iu_br_pc,
	icu_addr,
	icu_dout_d,
	ibuf_oplen,
	icu_pc_d,
	addr_reg_sel,
	addr_reg_enable,
	icu_addr_sel,
        biu_addr_sel,
	ic_data_sel,
	valid,
	icu_tag_sel,
	ibuf_pc_sel,
	encod_shift_e,
	next_addr_sel,
	icu_hit,
	latch_biu_addr,
	itag_dout,
	itag_vld,
	icu_din,
	icu_tag_in,
	icram_dout,
	icu_biu_addr,
	biu_data,
	ibuf_enable,
  	next_fetch_inc,
	ic_dout_sel,
	iu_shift_d,
	icu_addr_2_0,
	clk,
	reset_l,
	sin,
	sm,
	so,
	misc_dout,
        diag_ld_cache_c,
        icram_powerdown,
	iu_psr_bm8,
	fill_word_addr,
	icu_bypass_q,
 	misc_wrd_sel,
        ic_hit,
	ice_line_align,
	bypass_ack
	);
	

input	[31:0]		iu_addr_e;		// Address from IU
input	[31:0]		misc_din ;		// Diagnostic data input
input	[31:0]		iu_br_pc ;		// addr to jump on branch taken 
input	[15:0]		valid ;
input	[63:0]		icram_dout ;		// Data out of the icache ram.
output	[`it_addr_msb:`ic_msb+1]  icu_tag_in;	// Data input to the tag ram
output	[31:0]		icu_addr;		// Address of data to be accessed in cache next cycle
output	[55:0]		icu_dout_d;		// First 5 bytes of the ibuffer
output  [27:0]  	ibuf_oplen;             // opcode length from ibuffer
output	[31:0]		icu_pc_d;		// PC of the 1 byte of the ibuffer
input	[1:0]		addr_reg_sel;		// used to latch current I$ addr.to determine next fetch
input			addr_reg_enable;		// used to latch current I$ addr.to determine next fetch
input	[1:0]		icu_addr_sel;		// select Addr to be indexed into rams. 
input	[1:0]		biu_addr_sel;		 
input			ic_data_sel;		// select data input to icram 
input			icu_tag_sel;		// select input to tag ram
input	[11:0]		ic_dout_sel;		// selects for the ibuffer
input	[1:0]		ibuf_pc_sel;		// select pc input in ibuffer
input	[2:0]		encod_shift_e;		// encoded select used to calculate next pc_d
input	[7:0]		iu_shift_d;		// shifter selects for the ibuffer
input	[3:0]		next_addr_sel;		// select addr input to icram
input			reset_l;
output			icu_hit;		// cache hit in set 0
input			latch_biu_addr;		// cache miss
input	[`it_msb:0]	itag_dout;		// Data out of the Tag 
input			itag_vld;		// Tag data is valid
output	[31:0]		icu_din;		// Data into the Instruction RAM
output	[31:0]		icu_biu_addr;		// Address to the BIU
input	[31:0]		biu_data;		// Data from the BIU
input			clk;			// clock
input			sin;			// scan data input
input			sm;			// scan enable
output			so;			// scan data output
output	[31:0]		misc_dout;		// Diagnostic data output
input			diag_ld_cache_c;	// Diagnostic rd to ram
input			ibuf_enable;		//
input   [3:0]		next_fetch_inc;		// next_fetch_inc = 1, if 8 bit
						// next_fetch_inc = 4, if bypass 
						// next_fetch_inc = 8, if cache_hit 
input                   icram_powerdown;        // powerdown signal to RAM and TAG

input			ic_hit;			// tag compare result
input			iu_psr_bm8;
input  [1:0]		fill_word_addr;
input			icu_bypass_q;
output  [2:0]           icu_addr_2_0;           // bits 2:0 of icu_addr bus     
output			misc_wrd_sel;
output			ice_line_align;
input			bypass_ack;

wire	[3:0]		icu_addr_qw_align_int;
wire 			icram_powerdown;
wire    [31:0]          next_addr;
wire	[31:0]		icu_addr_d1;
wire	[31:0]		icu_addr_qw_align;
wire	[31:0]		biu_addr;
wire    [31:0] 		icu_fill_addr;
wire	[63:0]		align_data;
wire  	[1:0]           icu_addr_offset;        // icu_addr_offset to IBUF is set
                                                // to be byte addressable,
                                                // if iu_psr_bm8 is asserted.
wire  	[1:0]           biu_addr_offset;	// biu_addr_offset to BIU is set
                                        	// to be byte addressable,
                                        	// if iu_psr_bm8 is asserted.
wire 	[31:0] 		encode_oplen;

// Two sets of addr_offsets, one for buffer alignment,
// another for BIU word alignment.

assign  icu_addr_2_0[2:0] = icu_addr_d1[2:0] ;

assign icu_addr_offset = (iu_psr_bm8)? icu_addr_2_0[1:0]: 2'b00;

assign biu_addr_offset = (iu_psr_bm8)? biu_addr[1:0]: 2'b00;

wire	[31:0]	addr_reg_data;
wire	[31:0]	next_fetch;
// Address Datapath

// Address sent to memory on cache misses
// even if the requested data may not be word aligned, requests to memory
// are word aligned. The aligner in the datapath will align depending the
// lower two bits of the address.
 
mux4_32 next_addr_mux (	.out(next_addr[31:0]), 
			.in3(icu_fill_addr[31:0]),	// cache miss
			.in2(iu_addr_e[31:0]),		// diagnostic access
			.in1(icu_addr_d1),		// stall
			.in0(next_fetch[31:0]),		// next sequential fetch
			.sel(next_addr_sel[3:0])
			);

mux2_32  icu_addr_mux ( .out(icu_addr[31:0]),
		        .in1(iu_br_pc[31:0]),		// on a branch
		        .in0(next_addr[31:0]), 		// next sequential fetch
		        .sel(icu_addr_sel[1:0])
				);
mux2_32 addr_reg_mux ( .out(addr_reg_data[31:0]),
                        .in1(iu_br_pc[31:0]),          // branch
                        .in0(next_fetch[31:0]),        // next sequential fetch
                        .sel(addr_reg_sel[1:0])
                        );

mux2_4   biu_addr_mux (	.out(icu_addr_qw_align_int[3:0]),
				.in1(4'b0),
				.in0(icu_addr_d1[3:0]),
				.sel(biu_addr_sel[1:0])
				);

assign	icu_addr_qw_align = {icu_addr_d1[31:4],icu_addr_qw_align_int[3:0]};


// Used to latch nextfetch addr in case of ibufferfull or diagnostic rd/wr
// Also latch branch/trap address if they occur inbetn a cache miss transaction

ff_sre_32 icu_addr_d1_reg 	(.out(icu_addr_d1[31:0]),
					.din(addr_reg_data[31:0]),
					.clk(clk),
					.enable(addr_reg_enable),
					.reset_l(reset_l)
					);

// Latch fill address

assign	icu_fill_addr[31:0]	= {biu_addr[31:4],fill_word_addr[1:0],2'b0};

// Latch biu address

ff_sre_32 biu_addr_reg (	.out(biu_addr[31:0]),
				        .din(icu_addr_qw_align[31:0]),
				        .enable(!latch_biu_addr),
					.reset_l(reset_l),
				        .clk(clk)
					);

assign icu_biu_addr[31:0] = {biu_addr[31:2],biu_addr_offset} ;

assign ice_line_align = (icu_addr_d1[3:0] == 4'h0);

// Generate Next fetch Address 
// Fetch the next word if it is NC access
// Fetch one byte in case of 8bit mode
// Fetch one two words if it cache hit access


cla_adder_32    next_fetch_adder(
                .in1({icu_addr_d1[31:3],!next_fetch_inc[3] & icu_addr_d1[2], icu_addr_offset}),
                .in2({8'b00000000,8'b00000000,8'b00000000,4'b0000,next_fetch_inc}),
                .cin(1'b0),
                .sum(next_fetch),
                .cout());



// Data input to the Tag Ram
// select MAR reg for tag input in case of cache misses and
// select icu_data in case of diagnostic writes to icache tag

// replaced behavorial coded mux with an instantiated mux
assign icu_tag_in[`it_addr_msb:`ic_msb+1] = (icu_tag_sel)?icu_addr[`it_addr_msb:`ic_msb+1]:misc_din[`it_addr_msb:`ic_msb+1];

// Generation of icram_pwdn_d1
// !icram_powerdown is sampled by synchronous itag ram, so 
// it takes on tick to change itag_vld from unknown state(powerdown mode)
// to a valid state. To avoid icu_hit being X, a delayed icram_powerdown
// is used to negate it.
// 
// Note:
// itag_vld's state during powerdown mode depends on the silicon implementation
// This is why we model it as "X" during powerdown mode, our "X' means it can 
// be "1 ,or "0", or floating. 
// If can make sure itag_vld remains at solid "0", during 
// powerdown mode then they have an option to remove icram_pwdn_d1 to save 
// one flip-flop.  
  
wire icram_pwdn_d1; 

mj_s_ff_s_d  icram_pwdn_reg (	.out(icram_pwdn_d1),
                               	.in(icram_powerdown),
                               	.clk(clk)
				);


// The new ic_hit from itag.v has logically changed to (ic_hit & itag_vld)
assign icu_hit = ic_hit & !icram_powerdown & !icram_pwdn_d1;

assign misc_wrd_sel = icu_addr[2];

wire   misc_wrd_sel_d1;

mj_s_ff_snr_d  misc_wrd_se_reg (	.out(misc_wrd_sel_d1),
	                        	.clk(clk),
	                        	.in(misc_wrd_sel),
	                        	.reset_l(reset_l)
					);

/*******      Data  Path	******/

// replaced behavorial coded mux with an instantiated mux
// assign	icu_din = (ic_data_sel)? biu_data[31:0]:misc_din[31:0];

mux2_32 icu_din_mux (	.out(icu_din[31:0]), 
			.in1(biu_data[31:0]), 
			.in0(misc_din[31:0]), 
			.sel({ic_data_sel,1'b0})
			);

// replaced behavorial coded mux with an instantiated mux
// wire    [31:0] misc_out_temp = misc_wrd_sel_d1? icram_dout[31:0]:icram_dout[63:32]; 

wire [31:0]  misc_out_temp;

mux2_32 misc_out_temp_mux (	.out(misc_out_temp[31:0]), 
				.in1(icram_dout[31:0]), 
				.in0(icram_dout[63:32]), 
				.sel({misc_wrd_sel_d1,1'b0})
				);

// replaced behavorial coded mux with an instantiated mux
//assign	misc_dout = (diag_ld_cache_c)? misc_out_temp:
//                    {itag_dout[`it_msb:0],{(30-`it_msb){1'b0}},itag_vld};

wire	[`it_addr_msb+2:0]	misc_in_tmp;
wire	[31:0]			misc_in;

// Upper two bits are 0 for it_addr_msb = 29.

assign misc_in_tmp[`it_addr_msb+2:0] = {2'b00,itag_dout[`it_msb:0],{(`it_addr_msb-`it_msb-1){1'b0}},itag_vld};
assign misc_in[31:0] = misc_in_tmp[31:0];

mux2_32 misc_dout_mux (	.out(misc_dout[31:0]), 
			.in1(misc_out_temp[31:0]), 
			.in0(misc_in[31:0]), 
			.sel({diag_ld_cache_c,1'b0})
			);

// Bypass register to latch biu_data 
 
wire [31:0] biu_din_q;

// replaced behavorial coded mux with an instantiated mux
// wire [31:0] biu_data_in = bypass_ack? biu_data: biu_din_q;

wire [31:0] biu_data_in;

mux2_32 bypass_ack_mux (	.out(biu_data_in), 
				.in1(biu_data), 
				.in0(biu_din_q), 
				.sel({bypass_ack,1'b0})
				);

mj_s_ff_s_d_32 icu_din_reg (	.out(biu_din_q[31:0]), 
			        .din(biu_data_in[31:0]),   
			        .clk(clk)
				);

// Aligner -- align data out of cache 

ic_aligner		ic_aligner(
				   .bypass_nalgn_dina(biu_din_q[31:0]),
                                   .icache_nalgn_dinb(icram_dout[63:0]),
				   .dout(align_data[63:0]),
                                   .sel({iu_psr_bm8,icu_addr_2_0[2:0]}),
			           .bypass(icu_bypass_q));

ic_len_decoder opcode_len_encode_0(.opcode(align_data[63:56]), .len(encode_oplen[31:28]));
ic_len_decoder opcode_len_encode_1(.opcode(align_data[55:48]), .len(encode_oplen[27:24]));
ic_len_decoder opcode_len_encode_2(.opcode(align_data[47:40]), .len(encode_oplen[23:20]));
ic_len_decoder opcode_len_encode_3(.opcode(align_data[39:32]), .len(encode_oplen[19:16]));
ic_len_decoder opcode_len_encode_4(.opcode(align_data[31:24]), .len(encode_oplen[15:12]));
ic_len_decoder opcode_len_encode_5(.opcode(align_data[23:16]), .len(encode_oplen[11:8]));
ic_len_decoder opcode_len_encode_6(.opcode(align_data[15:8]), .len(encode_oplen[7:4]));
ic_len_decoder opcode_len_encode_7(.opcode(align_data[7:0]), .len(encode_oplen[3:0]));


ibuffer			ibuffer (
				.ibuf_dout	(icu_dout_d[55:0]),
				.ibuf_oplen     (ibuf_oplen[27:0]),
				.icache_data	(align_data[63:0]),
			        .encode_oplen   (encode_oplen[31:0]),	
				.shft_dsel	(iu_shift_d[7:0]),
				.nxt_ibuf_pc	(icu_pc_d[31:0]),
				.encod_dsel	(encod_shift_e[2:0]),
				.ibuf_enable	(ibuf_enable),
				.buf_ic_sel	(valid),
				.jmp_pc		(icu_addr_d1[31:0]),
				.ibuf_pc_sel	(ibuf_pc_sel[1:0]),
				.ic_sel		(ic_dout_sel[11:0]),
				.sin		(),
				.sm		(),
				.so		(),
				.reset_l	(reset_l),
				.clk		(clk));
				
endmodule

module	ic_aligner (
		bypass_nalgn_dina,
		icache_nalgn_dinb,
		dout,
		sel,
		bypass);

input	[31:0]	bypass_nalgn_dina;
input	[63:0]	icache_nalgn_dinb;
output	[63:0]	dout;
input	[3:0]	sel;
input        	bypass;
 

wire  [63:0]  dout_8b;
wire  [31:0]  dout_4b;

wire [63:0] dout;


mux2_32 i_algn_dout_lo32_mux (	.out(dout[31:0]),
	                        .sel({!bypass,bypass}),
	                        .in0({32'h00000000}),
        	                .in1({dout_8b[31:0]})
	                        );

mux2_32 i_algn_dout_up32_mux (	.out(dout[63:32]),
	                        .sel({!bypass,bypass}),
	                        .in0({dout_4b}),
	                        .in1({dout_8b[63:32]})
		                );

wire [7:0] A = icache_nalgn_dinb[63:56];  
wire [7:0] B = icache_nalgn_dinb[55:48];  
wire [7:0] C = icache_nalgn_dinb[47:40];  
wire [7:0] D = icache_nalgn_dinb[39:32];  
wire [7:0] E = icache_nalgn_dinb[31:24];  
wire [7:0] F = icache_nalgn_dinb[23:16];  
wire [7:0] G = icache_nalgn_dinb[15:8];  
wire [7:0] H = icache_nalgn_dinb[7:0];  

wire [7:0] W = bypass_nalgn_dina[31:24];  
wire [7:0] X = bypass_nalgn_dina[23:16];  
wire [7:0] Y = bypass_nalgn_dina[15:8];  
wire [7:0] Z = bypass_nalgn_dina[7:0];  

// 8 byte aligner
// replaced case statement with dec3_8 and mux8_64
wire  [2:0] en_sel = {((!sel[3]) & sel[2]),((!sel[3]) & sel[1]),((!sel[3]) & sel[0])};

mj_s_mux8_d_8 i_dout_8b_mux_63_56 (	.mx_out(dout_8b[63:56]), 
					.sel(en_sel[2:0]), 
					.in0(A), 
					.in1(B),
					.in2(C),
					.in3(D),
					.in4(E),
					.in5(F),
					.in6(G),
					.in7(H)
					);

mj_s_mux8_d_8 i_dout_8b_mux_55_48 (	.mx_out(dout_8b[55:48]), 
					.sel(en_sel[2:0]), 
					.in0(B), 
					.in1(C),
					.in2(D),
					.in3(E),
					.in4(F),
					.in5(G),
					.in6(H),
					.in7(8'b0)
					);

mj_s_mux6_d_8 i_dout_8b_mux_47_40 (	.mx_out(dout_8b[47:40]), 
					.sel(en_sel[2:0]), 
					.in0(C), 
					.in1(D),
					.in2(E),
					.in3(F),
					.in4(G),
					.in5(H)
					);

mj_s_mux6_d_8 i_dout_8b_mux_39_32 (	.mx_out(dout_8b[39:32]), 
					.sel(en_sel[2:0]), 
					.in0(D), 
					.in1(E),
					.in2(F),
					.in3(G),
					.in4(H),
					.in5(8'b0)
					);

mj_s_mux4_d_8 i_dout_8b_mux_31_24 (	.mx_out(dout_8b[31:24]), 
					.sel(en_sel[1:0]), 
					.in0(E), 
					.in1(F),
					.in2(G),
					.in3(H)
					);

mj_s_mux3_d_8 i_dout_8b_mux_23_16 (	.mx_out(dout_8b[23:16]), 
					.sel(en_sel[1:0]), 
					.in0(F), 
					.in1(G),
					.in2(H)
					);

mj_s_mux2_d_8 i_dout_8b_mux_15_8 (	.mx_out(dout_8b[15:8]), 
					.sel(en_sel[0]), 
					.in0(G), 
					.in1(H)
					);
assign dout_8b[7:0] = H;

// 4 byte aligner
// replaced case statement with custom mux
wire [3:0] dout_4b_sel;

mj_s_mux4_d_8 i_dout_4b_mux_31_24 (	.mx_out(dout_4b[31:24]), 
					.sel(en_sel[1:0]), 
					.in0(W), 
					.in1(X),
					.in2(Y),
					.in3(Z)
					);

mj_s_mux3_d_8 i_dout_4b_mux_23_16 (	.mx_out(dout_4b[23:16]), 
					.sel(en_sel[1:0]), 
					.in0(X), 
					.in1(Y),
					.in2(Z)
					);

mj_s_mux2_d_8 i_dout_4b_mux_15_8 (	.mx_out(dout_4b[15:8]), 
					.sel(en_sel[0]), 
					.in0(Y), 
					.in1(Z)
					);

assign dout_4b[7:0] = Z;

endmodule


// **************************
//
// ic_len_decoder is designed by
//
// 
// **************************

module ic_len_decoder ( opcode,
			len
);

input	[7:0]	opcode;
output	[3:0]	len;

reg	[3:0]	len;

always @(opcode)  begin
case (opcode[7:0])  
 8'h00, 
 8'h01, 
 8'h02, 
 8'h03, 
 8'h04, 
 8'h05, 
 8'h06, 
 8'h07, 
 8'h08, 
 8'h09, 
 8'h0a, 
 8'h0b, 
 8'h0c, 
 8'h0d, 
 8'h0e,
 8'h0f, 
 8'h1a, 
 8'h1b, 
 8'h1c, 
 8'h1d, 
 8'h1e, 
 8'h1f, 
 8'h20, 
 8'h21, 
 8'h22, 
 8'h23, 
 8'h24, 
 8'h25, 
 8'h26, 
 8'h27, 
 8'h28, 
 8'h29, 
 8'h2a, 
 8'h2b, 
 8'h2c, 
 8'h2d, 
 8'h2e, 
 8'h2f, 
 8'h30, 
 8'h31, 
 8'h32, 
 8'h33, 
 8'h34, 
 8'h35, 
 8'h3b, 
 8'h3c, 
 8'h3d, 
 8'h3e, 
 8'h3f, 
 8'h40, 
 8'h41, 
 8'h42, 
 8'h43, 
 8'h44, 
 8'h45, 
 8'h46, 
 8'h47, 
 8'h48, 
 8'h49, 
 8'h4a, 
 8'h4b, 
 8'h4c, 
 8'h4d, 
 8'h4e, 
 8'h4f, 
 8'h50, 
 8'h51, 
 8'h52, 
 8'h53, 
 8'h54, 
 8'h55, 
 8'h56, 
 8'h57, 
 8'h58, 
 8'h59, 
 8'h5a, 
 8'h5b, 
 8'h5c, 
 8'h5d, 
 8'h5e, 
 8'h5f, 
 8'h60, 
 8'h61, 
 8'h62, 
 8'h63, 
 8'h64, 
 8'h65, 
 8'h66, 
 8'h67, 
 8'h68, 
 8'h69, 
 8'h6a, 
 8'h6b, 
 8'h6c, 
 8'h6d, 
 8'h6e, 
 8'h6f,
 8'h70, 
 8'h71, 
 8'h72, 
 8'h73, 
 8'h74, 
 8'h75, 
 8'h76, 
 8'h77,
 8'h78, 
 8'h79,
 8'h7a, 
 8'h7b,
 8'h7c, 
 8'h7d, 
 8'h7e, 
 8'h7f,
 8'h80, 
 8'h81, 
 8'h82, 
 8'h83, 
 8'h85, 
 8'h86, 
 8'h87,
 8'h88, 
 8'h89, 
 8'h8a, 
 8'h8b, 
 8'h8c,
 8'h8d, 
 8'h8e,
 8'h8f, 
 8'h90, 
 8'h91, 
 8'h92, 
 8'h93, 
 8'h94, 
 8'h95, 
 8'h96, 
 8'h97, 
 8'h98, 
 8'haa,
 8'hab,
 8'hac, 
 8'had, 
 8'hae, 
 8'haf, 
 8'hb0, 
 8'hb1, 
 8'hbe, 
 8'hbf, 
 8'hc2, 
 8'hc3, 
 8'hc4, 
 8'hca, 
 8'he5,
 8'hec : len = 4'b0010; 

 8'h10, 
 8'h12, 
 8'h15, 
 8'h16, 
 8'h17, 
 8'h18, 
 8'h19, 
 8'h36, 
 8'h37,
 8'h38, 
 8'h39, 
 8'h3a, 
 8'ha9, 
 8'hbc, 
 8'hcb,
 8'hea,
 8'hff : len = 4'b0100; 

 8'h11,
 8'h13,
 8'h14,
 8'h84,
 8'h99,
 8'h9a,
 8'h9b,
 8'h9c,
 8'h9d,
 8'h9e,
 8'h9f,
 8'ha0,
 8'ha1,
 8'ha2,
 8'ha3,
 8'ha4,
 8'ha5,
 8'ha6,
 8'ha7,
 8'ha8,
 8'hb2,
 8'hb3,
 8'hb4,
 8'hb5,
 8'hb6,
 8'hb7,
 8'hb8,
 8'hbb,
 8'hbd,
 8'hc0,
 8'hc1,
 8'hc6,
 8'hc7,
 8'hcc,
 8'hcd,
 8'hce,
 8'hcf,
 8'hd0,
 8'hd1,
 8'hd2,
 8'hd3,
 8'hd4,
 8'hd5,
 8'hd6,
 8'hd7,
 8'hd8,
 8'hd9,
 8'hda,
 8'hdb,
 8'hdd,
 8'hde,
 8'hdf,
 8'he0,
 8'he1,
 8'he2,
 8'he3,
 8'he4,
 8'he6,
 8'he7,
 8'he8,
 8'he9,
 8'heb,
 8'hed,
 8'hee,
 8'hef,
 8'hf0,
 8'hf1,
 8'hf2,
 8'hf3,
 8'hf4,
 8'hf5,
 8'hf6: len = 4'b1000;
default:  len = 4'b0001; 

endcase

end

endmodule
