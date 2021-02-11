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




module icctl (
    biu_icu_ack,       // input  (ic_cntl) <= ()
    clk,               // input  (ibuf_ctl,ic_cntl) <= ()
    sin,     		// input  (ic_cntl) <= ()
    icu_addr_2_0,      // input  (ibuf_ctl,ic_cntl) <= ()
    icu_hit,           // input  (ic_cntl) <= ()
    iu_brtaken_e,      // input  (ic_cntl) <= ()
    iu_data_e_0,       // input  (ic_cntl) <= ()
    iu_flush_e,        // input  (ic_cntl) <= ()
    iu_ic_diag_e,      // input  (ic_cntl) <= ()
    iu_psr_ice,        // input  (ic_cntl) <= ()
    iu_shift_d,        // input  (ibuf_ctl) <= ()
    reset_l,             // input  (ibuf_ctl,ic_cntl) <= ()
    sm,                // input  (ibuf_ctl,ic_cntl) <= ()
    pcsu_powerdown,    // input  (ic_cntl) <= ()	
    iu_psr_bm8,        // input  (ic_cntl, ibuf_ctl) <= (iu)
    next_fetch_inc,    // output (ic_cntl) => (icu_dpath)
    encod_shift_e,     // output (ibuf_ctl) => ()
    ibuf_pc_sel,       // output (ibuf_ctl) => ()
    icu_addr_sel,       // output (ic_cntl) => ()
    ibuf_enable,
    ic_data_sel,       // output (ic_cntl) => ()
    ic_dout_sel,       // output (ibuf_ctl) => ()
    so,		       // output (ibuf_ctl) => ()
    icu_bypass_q,      // output (ic_cntl) => ()
    icu_drty_d,        // output (ibuf_ctl) => ()
    icu_itag_we,       // output (ic_cntl) => ()
    latch_biu_addr,    // output (ic_cntl) => ()
    icu_ram_we,        // output (ic_cntl) => ()
    icu_req,           // output (ic_cntl) => ()
    icu_size,          // output (ic_cntl) => ()
    icu_tag_sel,       // output (ic_cntl) => ()
    icu_tag_vld,       // output (ic_cntl) => ()
    icu_type,          // output (ic_cntl) => ()
    icu_vld_d,         // output (ibuf_ctl) => ()
    next_addr_sel,     // output (ic_cntl) => ()
    addr_reg_sel,     // output (ic_cntl) => ()
    addr_reg_enable,
    biu_addr_sel,     // output (ic_cntl) => ()
    diag_ld_cache_c,   // output (icctl) => (icu_dpath)
    icu_in_powerdown,  // output (icctl) => (pcsu)
    icram_powerdown,     // output (icctl) => (icu_dpath)	
    icu_hold,           // output (icctl) => (iu)
    valid,
    misc_wrd_sel,
    fill_word_addr,
    ice_line_align,
    bypass_ack
    );

input	[1:0]	biu_icu_ack;     // Acknowledge from biu that data from memory is available
input		clk;
input		sin;
input	[2:0]	icu_addr_2_0;    // bits 2:0 of icu_addr bus;
input		icu_hit;         // Icache Hit
input		iu_brtaken_e;    // branch taken in E stage
input		iu_data_e_0;     // bit 0 of iu data bus used for diagnostic writes
input		iu_flush_e;      // flush instruction in E stage
input	[3:0]	iu_ic_diag_e;    // diagnostic rd/wr to tags/ram
input		iu_psr_ice;      // Icache Enable in the PSR 
input	[7:0]	iu_shift_d;      // This tells how many times data should be	-- From iu
input		reset_l;
input		sm;
input           pcsu_powerdown;  // PCSU request for powerdown
input           iu_psr_bm8;      // 8 bit boot code enable from IU
input		ice_line_align;  //
output  [3:0]   next_fetch_inc;  // next_fetch_inc = 1, if iu_psr_bm8 is asserted,
                                 // otherwise next_fetch_inc = 4, if bypass
				 // next_fetch_inc = 8, if hit
output	[2:0]	encod_shift_e;   // Encoded value of registerd iu_shft_d to be used in ibuffer for
output	[1:0]	ibuf_pc_sel;     // This will select either the seq. pc or br pc -- To Ibuffer
output	[1:0]	icu_addr_sel;     // select addr input to the tags/data
output		ic_data_sel;     // select cache fill data or misc data for instruction ram
output	[11:0]	ic_dout_sel;     // These selcets will select one of the four 	-- To ibuff
output		so;
output		icu_bypass_q;    // bypass data from the cache
output	[6:0]	icu_drty_d;      // Dirty outputs from the first 5 locations     -- To iu
output		icu_itag_we;     // Write enable to the tags
output		latch_biu_addr;  // cache miss
output  [1:0]	icu_ram_we;      // write enable to the inst ram
output		ibuf_enable;
output		icu_req;         // request memory on a cache miss
output	[1:0]	icu_size;        // size of transaction
output		icu_tag_sel;     // To select input to the tag ram. either mar or misc store.
output		icu_tag_vld;     // valid bit of the tag - to be written into tagram
output	[3:0]	icu_type;        // type of transaction
output	[6:0]	icu_vld_d;       // Valid outputs from the first 5 locations	-- To iu
output	[3:0]	next_addr_sel;   // select the correct next_addr to access cache
output	[1:0]	addr_reg_sel;   // select the correct next_addr to access cache
output		addr_reg_enable;   // select the correct next_addr to access cache
output	[1:0]	biu_addr_sel;
output		diag_ld_cache_c; // Diagnostic rd to ram
output          icu_in_powerdown;// ICU notifies PCSU it is ready for clock shut off.
output          icram_powerdown; // powerdown signal to RAM and TAG
output          icu_hold;        // hold iu pipe for diagnostic access when
                                 // there is outstanding transaction in ICU
output	[15:0]	valid;
input		misc_wrd_sel;
output	[1:0]	fill_word_addr;
output		bypass_ack;

wire		ibuf_full;
wire		ic_drty;
wire		icu_stall;
wire    [3:0]   next_fetch_inc;

ic_cntl ic_cntl (
    .icu_req       (icu_req),            // output (ic_cntl) => ()
    .icu_type      (icu_type[3:0]),      // output (ic_cntl) => ()
    .icu_size      (icu_size[1:0]),      // output (ic_cntl) => ()
    .icu_addr_sel  (icu_addr_sel[1:0]),   // output (ic_cntl) => ()
    .next_addr_sel (next_addr_sel[3:0]), // output (ic_cntl) => ()
    .addr_reg_sel   (addr_reg_sel), // output (ic_cntl) => ()
    .addr_reg_enable(addr_reg_enable), // output (ic_cntl) => ()
    .biu_addr_sel  (biu_addr_sel[1:0]),  // output (ic_cntl) => ()
    .ic_data_sel   (ic_data_sel),        // output (ic_cntl) => ()
    .icu_tag_sel   (icu_tag_sel),        // output (ic_cntl) => ()
    .ic_drty       (ic_drty),            // output (ic_cntl) => (ibuf_ctl)
    .icu_stall     (icu_stall),          // output (ic_cntl) => (ibuf_ctl)
    .icu_tag_vld   (icu_tag_vld),        // output (ic_cntl) => ()
    .icu_itag_we   (icu_itag_we),        // output (ic_cntl) => ()
    .icu_ram_we    (icu_ram_we[1:0]),    // output (ic_cntl) => ()
    .icu_bypass_q  (icu_bypass_q),       // output (ic_cntl) => ()
    .latch_biu_addr (latch_biu_addr),	 // output (ic_cntl) => ()
    .diag_ld_cache_c(diag_ld_cache_c),   // output (ic_cntl) => (icu_dpath)
    .icu_in_powerdown (icu_in_powerdown),// output (ic_cntl) => ()
    .icram_powerdown (icram_powerdown),	 // output (ic_cntl) => ()
    .icu_hold      (icu_hold),           // output (ic_cntl) => ()
    .iu_ic_diag_e  (iu_ic_diag_e[3:0]),  // input  (ic_cntl) <= ()
    .biu_icu_ack   (biu_icu_ack[1:0]),   // input  (ic_cntl) <= ()
    .iu_psr_ice    (iu_psr_ice),         // input  (ic_cntl) <= ()
    .iu_brtaken_e  (iu_brtaken_e),       // input  (ic_cntl) <= ()
    .iu_flush_e    (iu_flush_e),         // input  (ic_cntl) <= ()
    .ibuf_full     (ibuf_full),          // input  (ic_cntl) <= (ibuf_ctl)
    .icu_hit       (icu_hit),            // input  (ic_cntl) <= ()
    .iu_data_e_0   (iu_data_e_0),        // input  (ic_cntl) <= ()
    .pcsu_powerdown(pcsu_powerdown),     // input  (ic_cntl) <= ()
    .next_fetch_inc(next_fetch_inc),     // output (ic_cntl) =>(icu_dpath)
    .iu_psr_bm8	   (iu_psr_bm8),         // input  (ic_cntl,ibuf_ctl) <=(iu)
    .misc_wrd_sel  (misc_wrd_sel),	 // input  
    .fill_word_addr (fill_word_addr),	 // output	
    .ice_line_align(ice_line_align),
    .bypass_ack    (bypass_ack),
    .clk           (clk),                // input  (ibuf_ctl,ic_cntl) <= ()
    .reset_l       (reset_l),            // input  (ibuf_ctl,ic_cntl) <= ()
    .sin           (),			 // input  (ic_cntl) <= ()
    .so            (),                   // output (ic_cntl) => (ibuf_ctl)
    .sm            ()                    // input  (ibuf_ctl,ic_cntl) <= ()
    );

ibuf_ctl ibuf_ctl (
    .ic_drty       (ic_drty),            // input  (ibuf_ctl) <= (ic_cntl)
    .ibuf_enable   (ibuf_enable),        // input  (ibuf_ctl) <= (ic_cntl)
    .icu_stall	   (icu_stall),
    .ic_dout_sel   (ic_dout_sel[11:0]),   // output (ibuf_ctl) => ()
    .sm            (), 	                 // input  (ibuf_ctl,ic_cntl) <= ()
    .icu_vld_d     (icu_vld_d[6:0]),     // output (ibuf_ctl) => ()
    .icu_drty_d    (icu_drty_d[6:0]),    // output (ibuf_ctl) => ()
    .ibuf_full     (ibuf_full),          // output (ibuf_ctl) => (ic_cntl)
    .iu_shift_d    (iu_shift_d[7:0]),    // input  (ibuf_ctl) <= ()
    .encod_shift_e (encod_shift_e[2:0]), // output (ibuf_ctl) => ()
    .icu_addr_2_0  (icu_addr_2_0[2:0]),  // input  (ibuf_ctl,ic_cntl) <= ()
    .ibuf_pc_sel   (ibuf_pc_sel[1:0]),   // output (ibuf_ctl) => ()
    .sin           (),                   // input  (ibuf_ctl) <= (ic_cntl)
    .so            (),                   // output (ibuf_ctl) => ()
    .reset_l       (reset_l),            // input  (ibuf_ctl,ic_cntl) <= ()
    .jmp_e         (iu_brtaken_e),              // input  (ibuf_ctl) <= (ic_cntl)
    .valid	   (valid),
    .iu_psr_bm8    (iu_psr_bm8),         // input  (ibuf_ctl,ic_cntl) <= (iu)
    .icu_bypass_q  (icu_bypass_q),       // input  (ibuf_ctl) <= (ic_cntl)
    .clk           (clk)                 // input  (ibuf_ctl,ic_cntl) <= ()
    );

mj_spare i1_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i2_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i3_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i4_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i5_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i6_spare (	.reset_l(reset_l),
			.clk(clk)
			);

endmodule

