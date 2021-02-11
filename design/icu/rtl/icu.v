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

module icu (
    biu_data,        // input  (icu_dpath) <= ()
    biu_icu_ack,     // input  (icctl) <= ()
    clk,             // input  (icctl,icu_dpath) <= ()
    icram_dout,      // input  (icu_dpath) <= ()
    sin,             // input  (icctl) <= ()
    sm,              // input  (icctl,icu_dpath) <= ()
    itag_dout,       // input  (icu_dpath) <= ()
    itag_vld,        // input  (icu_dpath) <= ()
    iu_addr_e,       // input  (icu_dpath) <= ()
    iu_br_pc,        // input  (icu_dpath) <= ()
    iu_brtaken_e,    // input  (icctl) <= ()
    iu_flush_e,      // input  (icctl) <= ()
    iu_ic_diag_e,    // input  (icctl) <= ()
    iu_psr_ice,      // input  (icctl) <= ()
    iu_shift_d,      // input  (icctl,icu_dpath) <= ()
    ic_hit,          // input  (icu_dpath) <= ()
    misc_din,        // input  (icctl,icu_dpath) <= ()
    pcsu_powerdown,  // input  (ic_cntl) <= (pcsu)
    iu_psr_bm8,	     // input  (ic_cntl) <= (iu)
    reset_l,         // input  (icctl,icu_dpath) <= ()
    misc_dout,       // output (icu_dpath) => ()
    icu_addr,        // output (icu_dpath) => ()
    icu_biu_addr,    // output (icu_dpath) => ()
    icu_din,         // output (icu_dpath) => ()
    icu_dout_d,      // output (icu_dpath) => ()
    ibuf_oplen,      // output (icu_dpath) => ()
    icu_drty_d,      // output (icctl) => ()
    icu_itag_we,     // output (icctl) => ()
    icu_pc_d,        // output (icu_dpath) => ()
    icu_ram_we,      // output (icctl) => ()
    icu_req,         // output (icctl) => ()
    so,              // output (icu_dpath) => ()
    icu_size,        // output (icctl) => ()
    icu_tag_in,      // output (icu_dpath) => ()
    icu_tag_vld,     // output (icctl) => ()
    icu_type,        // output (icctl) => ()
    icu_vld_d,       // output (icctl) => ()
    diag_ld_cache_c, // output (icctl) => (icu_dpath)
    icu_in_powerdown,// output (icctl) => (pcsu)
    icram_powerdown, // output (icctl) => (icu_dpath)
    icu_hold        // output (icctl) => (iu)
    );

input	[31:0]	biu_data;      // Data from the BIU
input	[1:0]	biu_icu_ack;   // Acknowledge from biu that data is available
input		clk;           // clock
input	[63:0]	icram_dout;    // Data out of the icache ram.
input		sin;
input		sm;
input	[`it_msb:0]	itag_dout;     // Data out of the Tag 
input		itag_vld;      // Tag data is valid
input	[31:0]	iu_addr_e;     // Address from IU
input	[31:0]	iu_br_pc;      // addr to jump on branch taken 
input		iu_brtaken_e;  // branch taken in E stage
input		iu_flush_e;    // flush instruction in E stage
input	[3:0]	iu_ic_diag_e;  // diagnostic rd/wr to tags/ram
input		iu_psr_ice;    // Icache Enable in the PSR 
input	[7:0]	iu_shift_d;    // This tells how many times data should be-- From iu
input	[31:0]	misc_din;      // Diagnostic data input
input		ic_hit;	       // Tag compare
input           pcsu_powerdown;// PCSU request for powerdown
input           iu_psr_bm8;    // 8 bit boot code enable from IU
input		reset_l;
output	[31:0]	icu_addr;      // Address of data to be accessed in cache next cycle
output	[31:0]	icu_biu_addr;  // Address to the BIU
output	[31:0]	icu_din;       // Data into the Instruction RAM
output  [55:0]  icu_dout_d;    // First 7 bytes of the ibuffer
output  [27:0]  ibuf_oplen;    // opcode length from ibuffer
output	[6:0]	icu_drty_d;    // Dirty outputs from the first 5 locations-- To iu
output		icu_itag_we;   // Write enable to the tags
output	[31:0]	icu_pc_d;      // PC of the 1 byte of the ibuffer
output  [1:0]	icu_ram_we;    // write enable to the inst ram
output		icu_req;       // request memory on a cache miss
output		so;
output	[1:0]	icu_size;      // size of transaction
output	[`it_msb:0]	icu_tag_in;    // Data input to the tag ram
output		icu_tag_vld;   // valid bit of the tag - to be written into tagram
output	[3:0]	icu_type;      // type of transaction
output	[6:0]	icu_vld_d;     // Valid outputs from the first 5 locations-- To iu
output	[31:0]	misc_dout;     // Diagnostic data output
output  diag_ld_cache_c;       // Diagnostic rd to ram 
output  icu_in_powerdown;      // ICU notifies PCSU it is ready for clock shut off.
output  icram_powerdown;       // powerdown signal to RAM and TAG
output          icu_hold;      // hold iu pipe for diagnostic access when
                               // there is outstanding transaction in ICU




wire	[11:0]	ic_dout_sel;
wire	[2:0]	encod_shift_e;
wire	[1:0]	ibuf_pc_sel;
wire	[1:0]	icu_addr_sel;
wire		ic_data_sel;
wire		ibuf_enable;
wire	[2:0]	icu_addr_2_0;
wire		icu_hit;
wire		latch_biu_addr;
wire		icu_tag_sel;
wire	[3:0]	next_addr_sel;
wire	[1:0]	addr_reg_sel;
wire		addr_reg_enable;
wire	[1:0]	biu_addr_sel;
wire    [3:0]   next_fetch_inc;
wire 		icu_bypass_q;           
wire    [55:0]  icu_dout_d;
wire		bypass_ack;
wire	[15:0]	valid;
wire		misc_wrd_sel;
wire		ice_line_align;
wire	[1:0]	fill_word_addr;

icctl icctl (
    .biu_icu_ack    (biu_icu_ack[1:0]),   // input  (icctl) <= ()
    .clk            (clk),                // input  (icctl,icu_dpath) <= ()
    .sin            (),                   // input  (icctl) <= ()
    .icu_addr_2_0   (icu_addr_2_0[2:0]),  // input  (icctl) <= (icu_dpath)
    .valid        (valid),            // input  (icctl) <= (icu_dpath)
    .icu_hit        (icu_hit),            // input  (icctl) <= (icu_dpath)
    .iu_brtaken_e   (iu_brtaken_e),       // input  (icctl) <= ()
    .iu_data_e_0    (misc_din[0]),        // input  (icctl,icu_dpath) <= ()
    .iu_flush_e     (iu_flush_e),         // input  (icctl) <= ()
    .iu_ic_diag_e   (iu_ic_diag_e[3:0]),  // input  (icctl) <= ()
    .iu_psr_ice     (iu_psr_ice),         // input  (icctl) <= ()
    .iu_shift_d     (iu_shift_d[7:0]),    // input  (icctl,icu_dpath) <= ()
    .reset_l        (reset_l),            // input  (icctl,icu_dpath) <= ()
    .sm             (),                   // input  (icctl,icu_dpath) <= ()
    .pcsu_powerdown (pcsu_powerdown),     // input  (ic_cntl) <= ()
    .iu_psr_bm8     (iu_psr_bm8),         // input  (ic_cntl, ibuf_ctl) <= (iu)
    .next_fetch_inc (next_fetch_inc[3:0]),// output (ic_cntl) => (icu_dpath)
    .encod_shift_e  (encod_shift_e[2:0]), // output (icctl) => (icu_dpath)
    .ibuf_pc_sel    (ibuf_pc_sel[1:0]),   // output (icctl) => (icu_dpath)
    .icu_addr_sel    (icu_addr_sel[1:0]),   // output (icctl) => (icu_dpath)
    .ic_data_sel    (ic_data_sel),        // output (icctl) => (icu_dpath)
    .ic_dout_sel    (ic_dout_sel[11:0]),   // output (icctl) => (icu_dpath)
    .so             (),                   // output (icctl) => (icu_dpath)
    .ibuf_enable    (ibuf_enable),
    .icu_bypass_q   (icu_bypass_q),       // output (icctl) => ()
    .icu_drty_d     (icu_drty_d[6:0]),    // output (icctl) => ()
    .icu_itag_we    (icu_itag_we),        // output (icctl) => ()
    .latch_biu_addr (latch_biu_addr), 	  // output (icctl) => (icu_dpath)
    .icu_ram_we     (icu_ram_we[1:0]),    // output (icctl) => ()
    .icu_req        (icu_req),            // output (icctl) => ()
    .icu_size       (icu_size[1:0]),      // output (icctl) => ()
    .icu_tag_sel    (icu_tag_sel),        // output (icctl) => (icu_dpath)
    .icu_tag_vld    (icu_tag_vld),        // output (icctl) => ()
    .icu_type       (icu_type[3:0]),      // output (icctl) => ()
    .icu_vld_d      (icu_vld_d[6:0]),     // output (icctl) => ()
    .next_addr_sel  (next_addr_sel[3:0]), // output (icctl) => (icu_dpath)
    .addr_reg_sel    (addr_reg_sel), 	// output (icctl) => (icu_dpath)
    .addr_reg_enable (addr_reg_enable), 	// output (icctl) => (icu_dpath)
    .biu_addr_sel   (biu_addr_sel[1:0]),  // output (icctl) => (icu_dpath)
    .diag_ld_cache_c (diag_ld_cache_c),   // output (icctl) => (icu_dpath)
    .icu_in_powerdown (icu_in_powerdown), // output (ic_cntl) => ()
    .icram_powerdown  (icram_powerdown),  // output (ic_cntl) => ()
    .icu_hold       (icu_hold),           // output (ic_cntl) => (iu) 
    .misc_wrd_sel   (misc_wrd_sel),
    .fill_word_addr(fill_word_addr),
    .ice_line_align (ice_line_align),
    .bypass_ack     (bypass_ack)
    );

icu_dpath icu_dpath (
    .iu_addr_e      (iu_addr_e[31:0]),    // input  (icu_dpath) <= ()
    .misc_din       (misc_din[31:0]),     // input  (icctl,icu_dpath) <= ()
    .iu_br_pc       (iu_br_pc[31:0]),     // input  (icu_dpath) <= ()
    .valid          (valid),     
    .icram_dout     (icram_dout[63:0]),   // input  (icu_dpath) <= ()
    .icu_tag_in     (icu_tag_in[`it_msb:0]),// output (icu_dpath) => ()
    .icu_addr       (icu_addr[31:0]),     // output (icu_dpath) => ()
    .icu_dout_d     (icu_dout_d[55:0]),   // output (icu_dpath) => ()
    .ibuf_oplen	    (ibuf_oplen[27:0]),
    .icu_pc_d       (icu_pc_d[31:0]),     // output (icu_dpath) => ()
    .icu_addr_sel   (icu_addr_sel[1:0]),   // input  (icu_dpath) <= (icctl)
    .ic_data_sel    (ic_data_sel),        // input  (icu_dpath) <= (icctl)
    .icu_tag_sel    (icu_tag_sel),        // input  (icu_dpath) <= (icctl)
    .ic_dout_sel    (ic_dout_sel[11:0]),   // input  (icu_dpath) <= (icctl)
    .ibuf_pc_sel    (ibuf_pc_sel[1:0]),   // input  (icu_dpath) <= (icctl)
    .encod_shift_e  (encod_shift_e[2:0]), // input  (icu_dpath) <= (icctl)
    .ibuf_enable    (ibuf_enable),
    .next_fetch_inc (next_fetch_inc[3:0]),// input  (icu_dpath) <= (icctl)
    .iu_shift_d     (iu_shift_d[7:0]),    // input  (icctl,icu_dpath) <= ()
    .next_addr_sel  (next_addr_sel[3:0]), // input  (icu_dpath) <= (icctl)
    .addr_reg_sel    (addr_reg_sel), 	   // input  (icu_dpath) <= (icctl)
    .addr_reg_enable (addr_reg_enable),    // input  (icu_dpath) <= (icctl)
    .biu_addr_sel   (biu_addr_sel[1:0]),  // input  (icu_dpath) <= (icctl)
    .reset_l        (reset_l),            // input  (icctl,icu_dpath) <= ()
    .ic_hit         (ic_hit),             // input
    .icu_hit        (icu_hit),            // output (icu_dpath) => (icctl)
    .latch_biu_addr (latch_biu_addr), 	  // input  (icu_dpath) <= (icctl)
    .itag_dout      (itag_dout[`it_msb:0]),  // input  (icu_dpath) <= ()
    .itag_vld       (itag_vld),           // input  (icu_dpath) <= ()
    .icu_din        (icu_din[31:0]),      // output (icu_dpath) => ()
    .icu_biu_addr   (icu_biu_addr[31:0]), // output (icu_dpath) => ()
    .biu_data       (biu_data[31:0]),     // input  (icu_dpath) <= ()
    .icu_addr_2_0   (icu_addr_2_0[2:0]),  // output (icu_dpath) => (icctl)
    .clk            (clk),                // input  (icctl,icu_dpath) <= ()
    .sin            (),                   // input  (icu_dpath) <= (icctl)
    .so             (),                   // output (icu_dpath) => ()
    .sm             (),                   // input  (icctl,icu_dpath) <= ()
    .misc_dout      (misc_dout[31:0]),    // output (icu_dpath) => ()
    .diag_ld_cache_c(diag_ld_cache_c),    // input  (icu_dpath) <= (icctl)
    .icram_powerdown(icram_powerdown),    // input  (icu_dpath) <= (icctl)
    .misc_wrd_sel   (misc_wrd_sel),
    .fill_word_addr(fill_word_addr),
    .iu_psr_bm8     (iu_psr_bm8),
    .icu_bypass_q   (icu_bypass_q),
    .ice_line_align (ice_line_align),
    .bypass_ack     (bypass_ack)
    );
endmodule
