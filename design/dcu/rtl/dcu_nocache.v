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



`include    "defines.h"
/***********************************
`define  dc_msb         11        // MSB of Address Bus needed to index into the cache
`define  dt_msb		19	  // MSB of Dcache Tag Field (Used for storing tag of a cache line)
`define  dt_index	7	  // MSB of Tag address used to index tag of a cache.
`define  dt_mxblks	255       // Number of Blocks in the cache
********************************************************************************/

module dcu_nocache (
    biu_data,            // input  (dcu_dpath) <= ()
    biu_dcu_ack,         // input  (dcctl) <= ()
    clk,                 // input  (dcctl,dcu_dpath) <= ()
    dcram_dout,          // input  (dcu_dpath) <= ()
    sin,         	// input  (dcu_dpath) <= ()
    sm,              	// input  (dcctl,dcu_dpath) <= ()
    dtg_dout,           // input  (dcu_dpath) <= ()
    hit0,		//  input
    hit1, 		//  input
    dtg_stat_out,        // input  (dcctl,dcu_dpath) <= ()
    iu_trap_c,		 // input  (dcctl) <= ()
    kill_inst_e,	//  input  (dcctl) <= ()
    iu_special_e,
    iu_addr_e,           // input  (dcctl,dcu_dpath) <= ()
    iu_addr_e_31,	 // input  (dcctl) <= ()
    iu_addr_e_2,	 // input  (dcctl) <= ()
    iu_data_e,           // input  (dcu_dpath) <= ()
    iu_diag_e,           // input  (dcctl) <= ()
    iu_flush_cmp_e,      // input  (dcctl) <= ()
    iu_flush_inv_e,
    iu_flush_index_e,    // input  (dcctl) <= ()
    iu_inst_e,           // input  (dcctl) <= ()
    iu_psr_dce,          // input  (dcctl) <= ()
    iu_zero_e,           // input  (dcctl) <= ()
    misc_din,            // input  (dcctl,dcu_dpath) <= ()
    pcsu_powerdown,      // input  (dcctl) <= ()
    reset_l,               // input  (dcctl) <= ()
    smu_addr,            // input  (dcu_dpath) <= ()
    smu_data,            // input  (dcu_dpath) <= ()
    smu_ld,              // input  (dcctl) <= ()
    smu_prty,		 // input  (dcctl) <= ()
    pj_halt,		 // input  (dcctl) <= ()
    pj_in_halt,		 // input  (dcctl) <= ()
    smu_st,              // input  (dcctl) <= ()
    smu_na_st,		 // input  (dcctl) <= ()
    dcu_addr_out,        // output (dcu_dpath) => ()
    dcu_bank_sel,        // output (dcctl) => ()
    dcu_biu_addr,        // output (dcu_dpath) => ()
    dcu_biu_data,        // output (dcu_dpath) => ()
    dcu_bypass,          // output (dcctl) => ()
    dcu_data,            // output (dcu_dpath) => ()
    dcu_din_e,           // output (dcu_dpath) => ()
    dcu_err_ack,         // output (dcctl) => ()
    dcu_in_powerdown,    // output (dcctl) => ()
    dcu_pwrdown,         // output (dcctl) => ()
    dcu_ram_we,          // output (dcctl) => ()
    dcu_req,             // output (dcctl) => ()
    dcu_perf_sgnl,
    so,        		// output (dcctl) => ()
    dcu_set_sel,         // output (dcctl) => ()
    dcu_size,            // output (dcctl) => ()
    dcu_smu_st,          // output (dcctl) => ()
    dcu_stat_addr,       // output (dcu_dpath) => ()
    dcu_stat_out,        // output (dcctl) => ()
    dcu_stat_we,         // output (dcctl) => ()
    dcu_tag_in,          // output (dcu_dpath) => ()
    dcu_tag_we,          // output (dcctl) => ()
    wb_set_sel,
    dcu_type,            // output (dcctl) => ()
    iu_data_vld,         // output (dcctl) => ()
    iu_stall,            // output (dcctl) => ()
    misc_dout,           // output (dcu_dpath) => ()
    smu_data_vld,        // output (dcctl) => ()
    smu_stall            // output (dcctl) => ()
    );

input	[31:0]	biu_data;          // Data from the BIU
input	[1:0]	biu_dcu_ack;       // Ack bus from Biu
input		clk;               // clock
input	[63:0]	dcram_dout;	   // Output of Data RAM
input		sin;
input		sm;
input	[`dt_msb:0]	dtg_dout;   // Data out of the Tag for writeback addressing
input	[4:0]	dtg_stat_out;      // status bits from the tag ram
input	[31:0]	iu_addr_e;         // Address from IU
input	[31:0]	iu_data_e;         // Data from IU
input	[3:0]	iu_diag_e;
input		iu_trap_c;	   // Trapped instruction in C stage
input		kill_inst_e;	   // Dont execute the instruction in E
input		iu_special_e;	   // special inst from iu
input		iu_addr_e_31;	   // bit 31 of addr for diagnostics
input		iu_addr_e_2;	   // bit 2 of addr for diagnostics
input		iu_flush_cmp_e;
input		iu_flush_inv_e;
input		iu_flush_index_e;
input	[7:0]	iu_inst_e;         //  bit[8] be na_store
input		iu_psr_dce;
input		iu_zero_e;
input	[31:0]	misc_din;          // for diagnostic writes into status register
input		pcsu_powerdown;    // Go into powerdown mode
input		reset_l;             // Reset
input	[31:0]	smu_addr;          // Address from Dribbler
input	[31:0]	smu_data;          // Data from Dribbler
input		smu_ld;
input		smu_prty;
input		pj_halt;
input		pj_in_halt;
input		smu_st;
input		smu_na_st;

input		hit0;		   // hit tag set 0
input		hit1;		   // hit tag set 1

output	[31:0]	dcu_addr_out;      // Address of data to be accessed in cache next cycle
output	[1:0]	dcu_bank_sel;      // select bank for writes into dcram
output	[31:0]	dcu_biu_addr;      // Address to the BIU
output	[31:0]	dcu_biu_data;      // Data to the BIU
output		dcu_bypass;        // bypass data from the dcram
output	[31:0]	dcu_data;          // Data out of DCU to IU/Dribbler
output	[31:0]	dcu_din_e;         // Data into the Data RAM
output	[2:0]	dcu_err_ack;       // Data access Exception
output		dcu_in_powerdown;  // Inform pcsu that dcu is in powerdown mode.
output		dcu_pwrdown;       // Dcache in powerdown mode (includes internal & pscu powerdown)
output	[3:0]	dcu_ram_we;        // Write enables to the dcram
output		dcu_req;           // Request memory on cache miss
output		so;
output		dcu_set_sel;       // select set for writes into tag
output	[1:0]	dcu_size;          // Size of transaction requested from memory
output		dcu_smu_st;        // smu store in c stage
output	[`dc_msb:0]	dcu_stat_addr;     // Address for writes to status reg/ data RAM
output	[4:0]	dcu_stat_out;      // Status bits to be written into ram
output	[4:0]	dcu_stat_we;       // Write Enable for status bits
output	[`dt_msb:0]	dcu_tag_in;        // Data input to the tag ram
output		dcu_tag_we;        // Write Enable to the tags
output     wb_set_sel;		   //  writeback set select for dtag megacell

output	[3:0]	dcu_type;          // Type of transaction requested from memory
output		iu_data_vld;       // Data on the dcu_data bus is valid
output		iu_stall;          // Stall the IU pipe due to dcache busy,miss
output	[31:0]	misc_dout;         // Diagnostic data output
output		smu_data_vld;      // Data on the dcu_data bus is valid
output		smu_stall;         // stall the smu pipe due to dcahe busy,miss
output	[2:0]	dcu_perf_sgnl;	   // DCU performance signals

reg	[31:0]	data_hold;        // Hold output for 1 cycle
wire	[3:0]	algn_sel_15_8;
wire		algn_sel_23_16;
wire		algn_sel_31_24;
wire	[3:0]	algn_sel_7_0;
wire	[4:0]	algn_sign_sel;
wire	[1:0]	algn_size_sel;
wire		arbiter_sel;
wire	[3:0]	cf_addr;
wire	[3:0]	dc_addr_sel;
wire	[3:0]	dc_data_sel;
wire	[3:0]	dcu_addr_c;
wire		dcu_addr_c_31;
wire		dcu_dout_sel;
wire    	dcu_tag_sel;
wire	[2:0]	diag_stat_bits;
wire		dtag_rd_c;
wire	[1:0]	fill_byte;
wire		latch_addr_c;
wire		latch_cf_addr;
wire		latch_wb_addr;
wire		latch_wr_data;
wire	[3:0]	merge_sel;
wire	[3:0]	repl_addr;
wire		req_addr_sel;
wire		stat_addr_sel;
wire	[2:0]	swap_sel_15_8;
wire	[2:0]	swap_sel_23_16;
wire	[2:0]	swap_sel_31_24;
wire	[2:0]	swap_sel_7_0;
wire	[1:0]	wb_ce;
wire	[3:0]	wb_sel;
wire		wb_set_sel;
wire	[1:0]	word_addr;
wire		smuprty_pjhalt;			// smu_hold from smu or pj_halt or pj_in_halt.

assign		smuprty_pjhalt = smu_prty | pj_halt | pj_in_halt;

dcctl dcctl (
    .biu_dcu_ack      (biu_dcu_ack[1:0]),    // input  (dcctl) <= ()
    .cf_addr          (cf_addr[3:0]),        // input  (dcctl) <= (dcu_dpath)
    .clk              (clk),                 // input  (dcctl,dcu_dpath) <= ()
    .sin    		(),            // input  (dcctl) <= (dcu_dpath)
    .dcu_addr_c       (dcu_addr_c[3:0]),     // input  (dcctl) <= (dcu_dpath)
    .dcu_addr_c_31  (dcu_addr_c_31),       // output (dcu_dpath) => (dcctl)
    .dcu_hit0         (1'b0),            // input  (dcctl) <= (dcu_dpath)
    .dcu_hit1         (1'b0),            // input  (dcctl) <= (dcu_dpath)
    .dtg_stat_out     (5'b0),		 // input  (dcctl,dcu_dpath) <= ()
    .iu_trap_c	      (iu_trap_c),	     // input  (dcctl) <= ()
    .kill_inst_e      (kill_inst_e),	     // input  (dcctl) <= ()
    .iu_special_e     (iu_special_e),
    .iu_addr_e_2      (iu_addr_e_2),        // input  (dcctl,dcu_dpath) <= ()
    .iu_addr_e_31     (iu_addr_e_31),       // input  (dcctl,dcu_dpath) <= ()
    .iu_diag_e        (iu_diag_e[3:0]),      // input  (dcctl) <= ()
    .iu_flush_inv_e   (iu_flush_inv_e),
    .iu_flush_cmp_e   (iu_flush_cmp_e),      // input  (dcctl) <= ()
    .iu_flush_index_e (iu_flush_index_e),    // input  (dcctl) <= ()
    .iu_inst_e        (iu_inst_e[7:0]),      // input  (dcctl) <= ()
    .iu_psr_dce       (1'b0),	          // input  (dcctl) <= ()
    .iu_zero_e        (iu_zero_e),           // input  (dcctl) <= ()
    .misc_din         (misc_din[2:0]),       // input  (dcctl,dcu_dpath) <= ()
    .pcsu_powerdown   (pcsu_powerdown),      // input  (dcctl) <= ()
    .reset_l           (reset_l),               // input  (dcctl) <= ()
    .sm               (),              // input  (dcctl,dcu_dpath) <= ()
    .smu_ld           (smu_ld),              // input  (dcctl) <= ()
    .smu_prty	      (smuprty_pjhalt),	     // input  (dcctl) <= ()
    .smu_st           (smu_st),              // input  (dcctl) <= ()
    .smu_na_st	      (smu_na_st),	     // input for smu_na_st_e
    .algn_sel_15_8    (algn_sel_15_8[3:0]),  // output (dcctl) => (dcu_dpath)
    .algn_sel_23_16   (algn_sel_23_16),      // output (dcctl) => (dcu_dpath)
    .algn_sel_31_24   (algn_sel_31_24),      // output (dcctl) => (dcu_dpath)
    .algn_sel_7_0     (algn_sel_7_0[3:0]),   // output (dcctl) => (dcu_dpath)
    .algn_sign_sel    (algn_sign_sel[4:0]),  // output (dcctl) => (dcu_dpath)
    .algn_size_sel    (algn_size_sel[1:0]),  // output (dcctl) => (dcu_dpath)
    .arbiter_sel      (arbiter_sel),         // output (dcctl) => (dcu_dpath)
    .dc_addr_sel      (dc_addr_sel[3:0]),    // output (dcctl) => (dcu_dpath)
    .dc_data_sel      (dc_data_sel[3:0]),    // output (dcctl) => (dcu_dpath)
    .so   		(),        	     // output (dcctl) => ()
    .dcu_perf_sgnl    (dcu_perf_sgnl),
    .dcu_bank_sel     (),		     // output (dcctl) => ()
    .dcu_bypass       (),	             // output (dcctl) => ()
    .dcu_dout_sel     (dcu_dout_sel),        // output (dcctl) => (dcu_dpath)
    .dcu_err_ack      (dcu_err_ack[2:0]),    // output (dcctl) => ()
    .dcu_in_powerdown (dcu_in_powerdown),    // output (dcctl) => ()
    .dcu_pwrdown      (), 	             // output (dcctl) => ()
    .dcu_ram_we       (),		     // output (dcctl) => ()
    .dcu_req          (dcu_req),             // output (dcctl) => ()
    .dcu_set_sel      (),		     // output (dcctl) => ()
    .dcu_size         (dcu_size[1:0]),       // output (dcctl) => ()
    .dcu_smu_st       (dcu_smu_st),          // output (dcctl) => ()
    .dcu_stat_out     (),		     // output (dcctl) => ()
    .dcu_stat_we      (),		     // output (dcctl) => ()
    .dcu_tag_sel      (dcu_tag_sel),         // output (dcctl) => (dcu_dpath)
    .dcu_tag_we       (), 		     // output (dcctl) => ()
    .dcu_type         (dcu_type[3:0]),       // output (dcctl) => ()
    .diag_stat_bits   (diag_stat_bits[2:0]), // output (dcctl) => (dcu_dpath)
    .dtag_rd_c        (dtag_rd_c),           // output (dcctl) => (dcu_dpath)
    .fill_byte        (fill_byte[1:0]),      // output (dcctl) => (dcu_dpath)
    .iu_data_vld      (iu_data_vld),         // output (dcctl) => ()
    .iu_stall         (iu_stall),            // output (dcctl) => ()
    .latch_addr_c     (latch_addr_c),        // output (dcctl) => (dcu_dpath)
    .latch_cf_addr    (latch_cf_addr),       // output (dcctl) => (dcu_dpath)
    .latch_wb_addr    (latch_wb_addr),       // output (dcctl) => (dcu_dpath)
    .latch_wr_data    (latch_wr_data),       // output (dcctl) => (dcu_dpath)
    .merge_sel        (merge_sel[3:0]),      // output (dcctl) => (dcu_dpath)
    .repl_addr        (repl_addr[3:0]),      // output (dcctl) => (dcu_dpath)
    .req_addr_sel     (req_addr_sel),        // output (dcctl) => (dcu_dpath)
    .smu_data_vld     (smu_data_vld),        // output (dcctl) => ()
    .smu_stall        (smu_stall),           // output (dcctl) => ()
    .stat_addr_sel    (stat_addr_sel),       // output (dcctl) => (dcu_dpath)
    .swap_sel_15_8    (swap_sel_15_8[2:0]),  // output (dcctl) => (dcu_dpath)
    .swap_sel_23_16   (swap_sel_23_16[2:0]), // output (dcctl) => (dcu_dpath)
    .swap_sel_31_24   (swap_sel_31_24[2:0]), // output (dcctl) => (dcu_dpath)
    .swap_sel_7_0     (swap_sel_7_0[2:0]),   // output (dcctl) => (dcu_dpath)
    .wb_ce            (wb_ce[1:0]),          // output (dcctl) => (dcu_dpath)
    .wb_sel           (wb_sel[3:0]),         // output (dcctl) => (dcu_dpath)
    .wb_set_sel       (wb_set_sel),          // output (dcctl) => (dcu_dpath)
    .word_addr        (word_addr[1:0])       // output (dcctl) => (dcu_dpath)
    );

always @(posedge clk)
     data_hold = dcu_din_e;

dcu_dpath dcu_dpath (
    .iu_data_e      (iu_data_e[31:0]),     // input  (dcu_dpath) <= ()
    .iu_addr_e      (iu_addr_e[31:0]),     // input  (dcctl,dcu_dpath) <= ()
    .misc_din       (misc_din[31:0]),      // input  (dcctl,dcu_dpath) <= ()
    .misc_dout      (misc_dout[31:0]),     // output (dcu_dpath) => ()
    .dcu_data       (dcu_data[31:0]),      // output (dcu_dpath) => ()
    .dcu_tag_in     (),		           // output (dcu_dpath) => ()
    .smu_data       (smu_data[31:0]),      // input  (dcu_dpath) <= ()
    .smu_addr       (smu_addr[31:0]),      // input  (dcu_dpath) <= ()
    .dcram_dout     ({data_hold,32'b0}),    // input  (dcu_dpath) <= ()
    .dcu_addr_out   (),			  // output (dcu_dpath) => ()
    .dc_addr_sel    (dc_addr_sel[3:0]),    // input  (dcu_dpath) <= (dcctl)
    .word_addr      (word_addr[1:0]),      // input  (dcu_dpath) <= (dcctl)
    .diag_stat_bits (diag_stat_bits[2:0]), // input  (dcu_dpath) <= (dcctl)
    .dtag_rd_c      (dtag_rd_c),           // input  (dcu_dpath) <= (dcctl)
    .arbiter_sel    (arbiter_sel),         // input  (dcu_dpath) <= (dcctl)
    .latch_addr_c   (latch_addr_c),        // input  (dcu_dpath) <= (dcctl)
    .dc_data_sel    (dc_data_sel[3:0]),    // input  (dcu_dpath) <= (dcctl)
    .latch_cf_addr  (latch_cf_addr),       // input  (dcu_dpath) <= (dcctl)
    .latch_wb_addr  (latch_wb_addr),       // input  (dcu_dpath) <= (dcctl)
    .dcu_hit0       (1'b0),            // output (dcu_dpath) => (dcctl)
    .cf_word_addr   (cf_addr[3:0]),        // output (dcu_dpath) => (dcctl)
    .repl_word_addr (dcu_addr_c[3:0]),     // output (dcu_dpath) => (dcctl)
    .dcu_addr_c_31  (dcu_addr_c_31),       // output (dcu_dpath) => (dcctl)
    .dcu_dout_sel   (dcu_dout_sel),        // input  (dcu_dpath) <= (dcctl)
    .fill_byte      (fill_byte[1:0]),      // input  (dcu_dpath) <= (dcctl)
    .wb_sel         (wb_sel[3:0]),         // input  (dcu_dpath) <= (dcctl)
    .wb_ce          (wb_ce[1:0]),          // input  (dcu_dpath) <= (dcctl)
    .req_addr_sel   (req_addr_sel),        // input  (dcu_dpath) <= (dcctl)
    .stat_addr_sel  (stat_addr_sel),       // input  (dcu_dpath) <= (dcctl)
    .dcu_tag_sel    (dcu_tag_sel),         // input  (dcu_dpath) <= (dcctl)
    .repl_addr      (repl_addr[3:0]),      // input  (dcu_dpath) <= (dcctl)
    .algn_sign_sel  (algn_sign_sel[4:0]),  // input  (dcu_dpath) <= (dcctl)
    .algn_size_sel  (algn_size_sel[1:0]),  // input  (dcu_dpath) <= (dcctl)
    .algn_sel_7_0   (algn_sel_7_0[3:0]),   // input  (dcu_dpath) <= (dcctl)
    .algn_sel_15_8  (algn_sel_15_8[3:0]),  // input  (dcu_dpath) <= (dcctl)
    .algn_sel_23_16 (algn_sel_23_16),      // input  (dcu_dpath) <= (dcctl)
    .algn_sel_31_24 (algn_sel_31_24),      // input  (dcu_dpath) <= (dcctl)
    .swap_sel_7_0   (swap_sel_7_0[2:0]),   // input  (dcu_dpath) <= (dcctl)
    .swap_sel_15_8  (swap_sel_15_8[2:0]),  // input  (dcu_dpath) <= (dcctl)
    .swap_sel_23_16 (swap_sel_23_16[2:0]), // input  (dcu_dpath) <= (dcctl)
    .swap_sel_31_24 (swap_sel_31_24[2:0]), // input  (dcu_dpath) <= (dcctl)
    .merge_sel      (merge_sel[3:0]),      // input  (dcu_dpath) <= (dcctl)
    .latch_wr_data  (latch_wr_data),       // input  (dcu_dpath) <= (dcctl)
    .dtg_dout       ({(`dt_msb+1){1'b0}}), // input  (dcu_dpath) <= ()
    .dcu_din_e      (dcu_din_e[31:0]),     // output (dcu_dpath) => ()
    .dcu_stat_addr  (),			   // output (dcu_dpath) => ()
    .dcu_biu_addr   (dcu_biu_addr[31:0]),  // output (dcu_dpath) => ()
    .dcu_biu_data   (dcu_biu_data[31:0]),  // output (dcu_dpath) => ()
    .biu_data       (biu_data[31:0]),      // input  (dcu_dpath) <= ()
    .clk            (clk),                 // input  (dcctl,dcu_dpath) <= ()
    .sin  		(),         // input  (dcu_dpath) <= ()
    .so 		(),            // output (dcu_dpath) => (dcctl)
    .sm       		()               // input  (dcctl,dcu_dpath) <= ()
    );

endmodule
