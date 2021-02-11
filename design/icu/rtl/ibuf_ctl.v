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





module ibuf_ctl (

	ic_drty,
	icu_stall,
	ibuf_enable,
	ic_dout_sel,
	sin,
	sm,
	so,
	icu_vld_d,
	icu_drty_d,
	ibuf_full,
	iu_shift_d,
	encod_shift_e,
	icu_addr_2_0,
	ibuf_pc_sel,
	reset_l,
	jmp_e,
	valid,
	iu_psr_bm8,
	icu_bypass_q,
	clk
);

input		ic_drty;		// This bit tells that data from Icache is 	-- From iu
					// dirty
input		icu_stall;		// Ecache miss signal				-- From iu
output	[11:0]	ic_dout_sel;		// These selects will select one of the eight 	-- To ibuff
					// bytes from bypass/icache to ibuffer
					// Icache or following buffers in ibuffer
input		sin;			// scan input
input		sm;			// scan enable
output		so;			// scan output
output	[6:0]	icu_vld_d;		// Valid outputs from the first 5 locations	-- To iu
output	[6:0]	icu_drty_d;		// Dirty outputs from the first 5 locations     -- To iu
output		ibuf_full;		// This tells that Ibuffer is full		-- To iu
input	[7:0]	iu_shift_d;		// This tells how many times data should be	-- From iu
					// shifted
output	[2:0]	encod_shift_e;		// Encoded value of iu_shft_e to be used in ibuffer for
					// calculating the value of the address of the first
					// datum in the ibuffer
input	[2:0]	icu_addr_2_0;		// The lower 3 bits of the PC			-- From iu
output	[1:0]	ibuf_pc_sel;		// This will select either the seq. pc or br pc -- To Ibuffer
output		ibuf_enable;
output	[15:0]	valid;			// Valid bits of ibuffer entries
input		reset_l;
input		jmp_e;
input		iu_psr_bm8;             // 8 bit boot code enable from IU               -- From iu
input		icu_bypass_q;
input		clk;

wire	[3:0]	ic_dout_sel_ext;
wire	[15:0]	dirty;
wire	[15:0]	new_valid;
wire	[15:0]	new_dirty;
wire	[15:0]	buf_ic_valid;
wire	[15:0]	buf_ic_drty;
wire		ibuf_en;
wire		squash_vld;
wire	[15:0]	ic_fill_sel;

assign	ibuf_enable =  !icu_stall |!iu_shift_d[0];
assign	ibuf_en	    =  !icu_stall | !iu_shift_d[0] | jmp_e;




ibuf_ctl_slice	ibuf_ctl_0 (.valid_bits(buf_ic_valid[7:1]),
			.dirty_bits(buf_ic_drty[7:1]),
			.shft_dsel(iu_shift_d[7:0]),
			.valid_out(valid[0]),
			.dirty_out(dirty[0]),
			.buf_ic_drty(buf_ic_drty[0]),
			.buf_ic_valid(buf_ic_valid[0]),
			.jmp_e	(jmp_e),
			.ibuf_en(ibuf_en),
			.icu_stall(icu_stall),
			.fill_sel(ic_fill_sel[0]),
			.new_valid(new_valid[0]),
			.sin(),
			.sm(),
			.so(),
			.new_dirty(new_dirty[0]),
			.reset_l(reset_l),
			.clk(clk));
			
ibuf_ctl_slice	ibuf_ctl_1 (.valid_bits(buf_ic_valid[8:2]),
			.dirty_bits(buf_ic_drty[8:2]),
			.shft_dsel(iu_shift_d[7:0]),
			.valid_out(valid[1]),
			.dirty_out(dirty[1]),
			.buf_ic_drty(buf_ic_drty[1]),
			.buf_ic_valid(buf_ic_valid[1]),
			.icu_stall(icu_stall),
			.jmp_e	(jmp_e),
			.ibuf_en(ibuf_en),
			.fill_sel(ic_fill_sel[1]),
			.new_valid(new_valid[1]),
			.sin(),
			.sm(),
			.so(),
			.new_dirty(new_dirty[1]),
			.reset_l(reset_l),
			.clk(clk));

ibuf_ctl_slice  ibuf_ctl_2 (.valid_bits(buf_ic_valid[9:3]),
                        .dirty_bits(buf_ic_drty[9:3]),
                        .shft_dsel(iu_shift_d[7:0]),
			.ibuf_en(ibuf_en),
                        .valid_out(valid[2]),
			.icu_stall(icu_stall),
                        .dirty_out(dirty[2]),
			.buf_ic_drty(buf_ic_drty[2]),
			.buf_ic_valid(buf_ic_valid[2]),
			.fill_sel(ic_fill_sel[2]),
			.jmp_e	(jmp_e),
                        .new_valid(new_valid[2]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[2]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_3 (.valid_bits(buf_ic_valid[10:4]),
                        .dirty_bits(buf_ic_drty[10:4]),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[3]),
                        .dirty_out(dirty[3]),
			.buf_ic_drty(buf_ic_drty[3]),
			.buf_ic_valid(buf_ic_valid[3]),
			.ibuf_en(ibuf_en),
			.fill_sel(ic_fill_sel[3]),
			.icu_stall(icu_stall),
			.jmp_e	(jmp_e),
                        .new_valid(new_valid[3]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[3]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_4 (.valid_bits(buf_ic_valid[11:5]),
                        .dirty_bits(buf_ic_drty[11:5]),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[4]),
                        .dirty_out(dirty[4]),
			.buf_ic_drty(buf_ic_drty[4]),
			.buf_ic_valid(buf_ic_valid[4]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[4]),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
                        .new_valid(new_valid[4]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[4]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_5 (.valid_bits(buf_ic_valid[12:6]),
                        .dirty_bits(buf_ic_drty[12:6]),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[5]),
                        .dirty_out(dirty[5]),
			.buf_ic_drty(buf_ic_drty[5]),
			.buf_ic_valid(buf_ic_valid[5]),
			.jmp_e	(jmp_e),
			.icu_stall(icu_stall),
			.fill_sel(ic_fill_sel[5]),
                        .new_valid(new_valid[5]),
			.ibuf_en(ibuf_en),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[5]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_6 (.valid_bits(buf_ic_valid[13:7]),
                        .dirty_bits(buf_ic_drty[13:7]),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[6]),
                        .dirty_out(dirty[6]),
			.buf_ic_drty(buf_ic_drty[6]),
			.buf_ic_valid(buf_ic_valid[6]),
                        .new_valid(new_valid[6]),
			.jmp_e	(jmp_e),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
			.fill_sel(ic_fill_sel[6]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[6]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_7 (.valid_bits(buf_ic_valid[14:8]),
                        .dirty_bits(buf_ic_drty[14:8]),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[7]),
                        .dirty_out(dirty[7]),
			.buf_ic_drty(buf_ic_drty[7]),
			.buf_ic_valid(buf_ic_valid[7]),
			.jmp_e	(jmp_e),
			.ibuf_en(ibuf_en),
			.icu_stall(icu_stall),
			.fill_sel(ic_fill_sel[7]),
                        .new_valid(new_valid[7]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[7]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_8 (.valid_bits(buf_ic_valid[15:9]),
                        .dirty_bits(buf_ic_drty[15:9]),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[8]),
                        .dirty_out(dirty[8]),
			.buf_ic_drty(buf_ic_drty[8]),
			.buf_ic_valid(buf_ic_valid[8]),
			.jmp_e	(jmp_e),
			.ibuf_en(ibuf_en),
			.icu_stall(icu_stall),
			.fill_sel(ic_fill_sel[8]),
                        .new_valid(new_valid[8]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[8]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_9 (.valid_bits({1'b0,buf_ic_valid[15:10]}),
                        .dirty_bits({1'b0,buf_ic_drty[15:10]}),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[9]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[9]),
			.ibuf_en(ibuf_en),
			.icu_stall(icu_stall),
                        .dirty_out(dirty[9]),
			.buf_ic_drty(buf_ic_drty[9]),
			.buf_ic_valid(buf_ic_valid[9]),
                        .new_valid(new_valid[9]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[9]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_10 (.valid_bits({2'b0,buf_ic_valid[15:11]}),
                        .dirty_bits({2'b0,buf_ic_drty[15:11]}),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[10]),
                        .dirty_out(dirty[10]),
			.buf_ic_drty(buf_ic_drty[10]),
			.buf_ic_valid(buf_ic_valid[10]),
			.fill_sel(ic_fill_sel[10]),
			.jmp_e	(jmp_e),
			.icu_stall(icu_stall),
                        .new_valid(new_valid[10]),
			.ibuf_en(ibuf_en),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[10]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_11 (.valid_bits({3'b0,buf_ic_valid[15:12]}),
                        .dirty_bits({3'b0,buf_ic_drty[15:12]}),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[11]),
                        .dirty_out(dirty[11]),
			.buf_ic_drty(buf_ic_drty[11]),
			.buf_ic_valid(buf_ic_valid[11]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[11]),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
                        .new_valid(new_valid[11]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[11]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_12 (.valid_bits({4'b0,buf_ic_valid[15:13]}),
                        .dirty_bits({4'b0,buf_ic_drty[15:13]}),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[12]),
                        .dirty_out(dirty[12]),
			.buf_ic_drty(buf_ic_drty[12]),
			.buf_ic_valid(buf_ic_valid[12]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[12]),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
                        .new_valid(new_valid[12]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[12]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_13 (.valid_bits({5'b0,buf_ic_valid[15:14]}),
                        .dirty_bits({5'b0,buf_ic_drty[15:14]}),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[13]),
                        .dirty_out(dirty[13]),
			.buf_ic_drty(buf_ic_drty[13]),
			.buf_ic_valid(buf_ic_valid[13]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[13]),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
                        .new_valid(new_valid[13]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[13]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_14 (.valid_bits({6'b0,buf_ic_valid[15]}),
                        .dirty_bits({6'b0,buf_ic_drty[15]}),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[14]),
                        .dirty_out(dirty[14]),
			.buf_ic_drty(buf_ic_drty[14]),
			.buf_ic_valid(buf_ic_valid[14]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[14]),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
                        .new_valid(new_valid[14]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[14]),
                        .reset_l(reset_l),
                        .clk(clk));

ibuf_ctl_slice  ibuf_ctl_15 (.valid_bits(7'b0),
                        .dirty_bits(7'b0),
                        .shft_dsel(iu_shift_d[7:0]),
                        .valid_out(valid[15]),
                        .dirty_out(dirty[15]),
			.buf_ic_drty(buf_ic_drty[15]),
			.buf_ic_valid(buf_ic_valid[15]),
			.jmp_e	(jmp_e),
			.fill_sel(ic_fill_sel[15]),
			.icu_stall(icu_stall),
			.ibuf_en(ibuf_en),
                        .new_valid(new_valid[15]),
			.sin(),
			.sm(),
			.so(),
                        .new_dirty(new_dirty[15]),
                        .reset_l(reset_l),
                        .clk(clk));

// New Valid bits generated due to a cache fill

// Use dword_align to avoid filling a word to ibuf when
// the word is not double-word aligned at cache mode.


wire    dword_align  =  (icu_addr_2_0 == 3'b000);

assign	new_valid[0] =  1'b1;

assign	new_valid[1] =  ((!icu_bypass_q & !icu_addr_2_0[2]) | !(icu_addr_2_0[1] & icu_addr_2_0[0])
			 & !iu_psr_bm8)| (ic_fill_sel[0] & iu_psr_bm8);

assign	new_valid[2] =  (((!icu_bypass_q & !icu_addr_2_0[2]) | !icu_addr_2_0[1])
			 & !iu_psr_bm8)| (ic_fill_sel[1] & iu_psr_bm8);

assign	new_valid[3] =  (((!icu_bypass_q & !icu_addr_2_0[2])|(!icu_addr_2_0[1] & !icu_addr_2_0[0]))
                         & !iu_psr_bm8)| (ic_fill_sel[2] & iu_psr_bm8);

assign	new_valid[4] =  ((!icu_bypass_q & !icu_addr_2_0[2]) | 
                         (icu_bypass_q & ic_fill_sel[0] ) 
                         & !iu_psr_bm8) | ic_fill_sel[3];

assign	new_valid[5] =  ((!icu_bypass_q & (!icu_addr_2_0[2] & !(icu_addr_2_0[1] & icu_addr_2_0[0]))) |
                         (icu_bypass_q & ic_fill_sel[1] ) 
                         & !iu_psr_bm8) | ic_fill_sel[4];

assign	new_valid[6] =  ((!icu_bypass_q & !icu_addr_2_0[2] & !icu_addr_2_0[1]) |
                         (icu_bypass_q & ic_fill_sel[2] )
                         & !iu_psr_bm8) | ic_fill_sel[5];

assign	new_valid[7] =  (!icu_bypass_q & !icu_addr_2_0[2] & !icu_addr_2_0[1] & !icu_addr_2_0[0] |
                         icu_bypass_q & ic_fill_sel[3])
                         & !iu_psr_bm8 | ic_fill_sel[6];

assign	new_valid[8] =   !iu_psr_bm8 & (!icu_bypass_q & dword_align &ic_fill_sel[0]  |  
                          icu_bypass_q & ic_fill_sel[4] ) | ic_fill_sel[7]; 

assign	new_valid[9] =   !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[1] | 
                          icu_bypass_q & ic_fill_sel[5] );

assign	new_valid[10] =  !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[2] | 
                          icu_bypass_q & ic_fill_sel[6]); 

assign	new_valid[11] =  !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[3] | 
                          icu_bypass_q & ic_fill_sel[7]); 

assign	new_valid[12] =  !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[4] | 
                          icu_bypass_q & ic_fill_sel[8]); 

assign	new_valid[13] =  !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[5] | 
                          icu_bypass_q & ic_fill_sel[9]);

assign	new_valid[14] =  !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[6] | 
                          icu_bypass_q & ic_fill_sel[10]); 

assign	new_valid[15] =  !iu_psr_bm8 & (!icu_bypass_q & dword_align & ic_fill_sel[7] | 
                          icu_bypass_q & ic_fill_sel[11]); 

// new_dirty[x] will be one if:
//	. ic_dout_sel[x-1] is 1 and iu_psr_bm8 is 1 or
//	. ic_dout_sel[x:x-3] is 1 and !iu_psr_bm8

assign	new_dirty[0] = icu_bypass_q & ic_drty & ic_dout_sel[0];

assign	new_dirty[1] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[0]) |
						(!iu_psr_bm8 & (|ic_dout_sel[1:0])) );

assign	new_dirty[2] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[1]) |
						(!iu_psr_bm8 & (|ic_dout_sel[2:0])) );

assign	new_dirty[3] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[2]) |
						(!iu_psr_bm8 & (|ic_dout_sel[3:0])) );

assign	new_dirty[4] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[3]) |
						(!iu_psr_bm8 & (|ic_dout_sel[4:1])) );

assign	new_dirty[5] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[4]) |
						(!iu_psr_bm8 & (|ic_dout_sel[5:2])) );

assign	new_dirty[6] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[5]) |
						(!iu_psr_bm8 & (|ic_dout_sel[6:3])) );

assign	new_dirty[7] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[6]) |
						(!iu_psr_bm8 & (|ic_dout_sel[7:4])) );

assign	new_dirty[8] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[7]) |
						(!iu_psr_bm8 & (|ic_dout_sel[8:5])) );

assign	new_dirty[9] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[8]) |
						(!iu_psr_bm8 & (|ic_dout_sel[9:6])) );

assign	new_dirty[10] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[9]) |
						(!iu_psr_bm8 & (|ic_dout_sel[10:7])) );

assign	new_dirty[11] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[10]) |
						(!iu_psr_bm8 & (|ic_dout_sel[11:8])) );

assign	new_dirty[12] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel[11]) |
						(!iu_psr_bm8 & (|ic_dout_sel[11:9] |
								ic_dout_sel_ext[0]) ));

assign	new_dirty[13] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel_ext[0]) |
						(!iu_psr_bm8 & (|ic_dout_sel[11:10] | 
								(|ic_dout_sel_ext[1:0]))) );

assign	new_dirty[14] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel_ext[1]) |
						(!iu_psr_bm8 & (ic_dout_sel[11] | 
								(|ic_dout_sel_ext[2:0]))) );

assign	new_dirty[15] = icu_bypass_q & ic_drty & ( (iu_psr_bm8 & ic_dout_sel_ext[2]) |
						(!iu_psr_bm8 & (|ic_dout_sel_ext[3:0])) );

// To locate the first location of cache fill.
// ex: ic_dout_sel[x] indicates the first byte of data from cache will be written into x location
// of ibuffer.
assign ic_dout_sel[0]  = !valid[0];
assign ic_dout_sel[1]  = valid[0]&!valid[1] ;
assign ic_dout_sel[2]  = valid[1]&!valid[2] ;
assign ic_dout_sel[3]  = valid[2]&!valid[3] ;
assign ic_dout_sel[4]  = valid[3]&!valid[4] ;
assign ic_dout_sel[5]  = valid[4]&!valid[5] ;
assign ic_dout_sel[6]  = valid[5]&!valid[6] ;
assign ic_dout_sel[7]  = valid[6]&!valid[7] ;
assign ic_dout_sel[8]  = valid[7]&!valid[8] ;
assign ic_dout_sel[9]  = valid[8]&!valid[9] ;
assign ic_dout_sel[10] = valid[9]&!valid[10] ;
assign ic_dout_sel[11] = valid[10]&!valid[11] ;
assign ic_dout_sel_ext[0] = valid[11]&!valid[12] ;
assign ic_dout_sel_ext[1] = valid[12]&!valid[13] ;
assign ic_dout_sel_ext[2] = valid[13]&!valid[14] ;
assign ic_dout_sel_ext[3] = valid[14]&!valid[15] ;

// Generate ibuf_full signal:
//

// mj_h_mux8  ibuf_full_mux1 (	.mx_out(curr_valid_bit),
//				.in0(valid[8]),
//				.in1(valid[9]),
//				.in2(valid[10]),
//				.in3(valid[11]),
//				.in4(valid[12]),
//				.in5(valid[13]),
//				.in6(valid[14]),
//				.in7(valid[15]),
//				.sel(iu_shift_d[7:0]),
//				.sel_l(~iu_shift_d[7:0])
//				);
//
// wire    curr_valid_bit_bypass;
//
// mj_h_mux8  ibuf_full_mux2 (	.mx_out(curr_valid_bit_bypass),
//				.in0(valid[12]),
//				.in1(valid[13]),
//				.in2(valid[14]),
//				.in3(valid[15]),
//				.in4(1'b0),
//				.in5(1'b0),
//				.in6(1'b0),
//				.in7(1'b0),
//				.sel(iu_shift_d[7:0]),
//				.sel_l(~iu_shift_d[7:0])
//				);

// Single byte mode is not optimized for performance
// To simplify the design, ibuf_full is asserted when
// when ibuffer is half full at boot mode.

// assign ibuf_full  = (curr_valid_bit_bypass | 
//                     (!icu_bypass_q & curr_valid_bit & icu_hit) |
//                     (iu_psr_bm8 & curr_valid_bit) ) & !squash_vld;

ff_sr	squash_vld_reg(.out(squash_vld),
			.din(jmp_e),
			.clk(clk),
			.reset_l(reset_l));

 assign ibuf_full  = (valid[12]|(!icu_bypass_q|iu_psr_bm8) & valid[8]) & !squash_vld;

// Generate  icu_vld_d and icu_drty_d outputs

assign icu_vld_d[6:0] = valid[6:0] ; 
assign icu_drty_d[6:0] = dirty[6:0];


// Generate encod_shift_e, instead of encod_shift_d
// to improve timing for the path shift 

wire [7:0] iu_shift_e;

mj_s_ff_snr_d_8 iu_shift_e_reg (	.out(iu_shift_e[7:0]),
				        .din(iu_shift_d[7:0]),
				        .clk(clk),
			        	.reset_l(reset_l)
					);

wire [2:0] encod_shift_e;

encode_shift_module i_encode_shift_module
                    (.iu_shift_e(iu_shift_e),
		     .encod_shift_e(encod_shift_e)
                    );

// Generate ibuf_pc_sel

assign ibuf_pc_sel[1]	=  squash_vld;
assign ibuf_pc_sel[0]	= !squash_vld;



endmodule

module encode_shift_module( iu_shift_e, encod_shift_e); 

input [7:0] iu_shift_e;
output [2:0] encod_shift_e;

reg [2:0] encod_shift_e;

  always @(iu_shift_e)

    casex(iu_shift_e) // synopsys parallel_case full_case
    8'b0000000x : encod_shift_e = 3'b000;
    8'b00000010 : encod_shift_e = 3'b001;
    8'b00000100 : encod_shift_e = 3'b010;
    8'b00001000 : encod_shift_e = 3'b011;
    8'b00010000 : encod_shift_e = 3'b100;
    8'b00100000 : encod_shift_e = 3'b101;
    8'b01000000 : encod_shift_e = 3'b110;
    8'b10000000 : encod_shift_e = 3'b111;
  endcase

endmodule

			

/****************************************************************
***     This module defines one slice ibuffer control which will
***     be instantiated in the ibuffer control.
****************************************************************/

module ibuf_ctl_slice (

	valid_bits,
	dirty_bits,
	shft_dsel,
	valid_out,
	dirty_out,
	new_valid,
	icu_stall,
	fill_sel,
	ibuf_en,
	sin,
	sm,
	so,
	new_dirty,
	buf_ic_drty,
	buf_ic_valid,
	jmp_e,
	reset_l,
	clk
);

input	[6:0]	valid_bits;		// Valid bits from the following 7 buffers	-- From ibuf_ctl
input	[6:0]	dirty_bits;		// Dirty bits from the following 7 buffers	-- From ibuf_ctl
					// until Icache is accessed succesfully
input	[7:0]	shft_dsel;		// These selects will determine which of the    -- From ibuf_ctl
                                        // following 7 valid bits will be selected
					// The last bit indicates that it's a stall
input		jmp_e;
input		ibuf_en;
input		icu_stall;
output		fill_sel;
output		valid_out;		// Valid bit o/p
output		dirty_out;		// Dirty bit o/p
input		new_valid;		// Internal control signal
					// icache or follwoing 5 buffers
input		sin;			// scan input
input		sm;			// scan enable
output		so;			// scan output
input		new_dirty;			// This indicates that Icache data is dirty	-- From iu
output		buf_ic_drty;
output		buf_ic_valid;
input		reset_l;
input		clk;

	
wire	valid_in;
wire	dirty_in;

// buf_ic_valid is one if either teh current ibuffer entry is valid
// or the icache entry into the current one is valid

assign buf_ic_valid = (valid_out | new_valid&!icu_stall);
assign buf_ic_drty = (dirty_out | new_dirty&!icu_stall);

mux8  valid_mux (	.out(valid_in),
			.in0(buf_ic_valid),
			.in1(valid_bits[0]),
			.in2(valid_bits[1]),
			.in3(valid_bits[2]),
			.in4(valid_bits[3]),
			.in5(valid_bits[4]),
			.in6(valid_bits[5]),
			.in7(valid_bits[6]),
			.sel(shft_dsel)
			);

mux8  dirty_mux (	.out(dirty_in),
			.in0(buf_ic_drty),	
			.in1(dirty_bits[0]),	
			.in2(dirty_bits[1]),	
			.in3(dirty_bits[2]),	
			.in4(dirty_bits[3]),	
			.in5(dirty_bits[4]),	
			.in6(dirty_bits[5]),	
			.in7(dirty_bits[6]),	
			.sel(shft_dsel)
			);

// If shifted bit is not 1
assign	fill_sel  =  valid_out ;

mj_s_ff_snre_d  valid_flop (	.out(valid_out),
				.in(valid_in&!jmp_e),
				.clk(clk),
				.reset_l(reset_l),
				.lenable(ibuf_en)
				);

mj_s_ff_snre_d  dirty_flop (	.out(dirty_out),
				.in(dirty_in&!jmp_e),
				.clk(clk),
				.reset_l(reset_l),
				.lenable(ibuf_en)
				);

endmodule
