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



module dcctl (
    biu_dcu_ack,         // input  (dc_dec) <= ()
    cf_addr,             // input  (dc_dec,dcudp_cntl) <= ()
    clk,                 // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    sin,       		// input  (dc_dec) <= ()
    dcu_addr_c,          // input  (dc_dec,dcudp_cntl,wrbuf_cntl) <= ()
    dcu_addr_c_31,          // input  (dc_dec,dcudp_cntl,wrbuf_cntl) <= ()
    dcu_hit0,            // input  (dcudp_cntl) <= ()
    dcu_hit1,            // input  (dcudp_cntl) <= ()
    dtg_stat_out,        // input  (dcudp_cntl,wrbuf_cntl) <= ()
    iu_trap_c,		 // input  (dc_dec) <= ()
    kill_inst_e,	//  input  (dc_dec) <= ()
    iu_special_e,
    iu_addr_e_2,         // input  (dcudp_cntl) <= ()
    iu_addr_e_31,        // input  (dcudp_cntl) <= ()
    iu_diag_e,           // input  (dc_dec) <= ()
    iu_flush_cmp_e,      // input  (dc_dec) <= ()
    iu_flush_inv_e,      // input  (dc_dec) <= ()
    iu_flush_index_e,    // input  (dc_dec) <= ()
    iu_inst_e,           // input  (dc_dec) <= ()
    iu_psr_dce,          // input  (dc_dec) <= ()
    iu_zero_e,           // input  (dc_dec) <= ()
    misc_din,            // input  (dcudp_cntl) <= ()
    pcsu_powerdown,      // input  (dc_dec) <= ()
    reset_l,               // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    sm,                  // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    smu_ld,              // input  (dc_dec) <= ()
    smu_st,              // input  (dc_dec) <= ()
    smu_prty,	   	 // input  (dc_dec) <= ()
    smu_na_st,		//  for na_st_e
    algn_sel_15_8,       // output (dc_dec) => ()
    algn_sel_23_16,      // output (dc_dec) => ()
    algn_sel_31_24,      // output (dc_dec) => ()
    algn_sel_7_0,        // output (dc_dec) => ()
    algn_sign_sel,       // output (dc_dec) => ()
    algn_size_sel,       // output (dc_dec) => ()
    arbiter_sel,         // output (dcudp_cntl) => ()
    dc_addr_sel,         // output (dcudp_cntl) => ()
    dc_data_sel,         // output (dcudp_cntl) => ()
    so,      		// output (miss_cntl) => ()
    dcu_bank_sel,        // output (dcudp_cntl) => ()
    dcu_bypass,          // output (dc_dec) => ()
    dcu_dout_sel,        // output (dcudp_cntl) => ()
    dcu_err_ack,         // output (dc_dec) => ()
    dcu_in_powerdown,    // output (dc_dec) => ()
    dcu_pwrdown,         // output (dc_dec) => ()
    dcu_ram_we,          // output (dc_dec) => ()
    dcu_req,             // output (dc_dec) => ()
    dcu_set_sel,         // output (dcudp_cntl) => ()
    dcu_size,            // output (dc_dec) => ()
    dcu_smu_st,          // output (dc_dec) => ()
    dcu_stat_out,        // output (dcudp_cntl) => ()
    dcu_stat_we,         // output (dcudp_cntl) => ()
    dcu_tag_sel,         // output (dcudp_cntl) => ()
    dcu_tag_we,          // output (dcudp_cntl) => ()
    dcu_type,            // output (dc_dec) => ()
    dcu_perf_sgnl,
    diag_stat_bits,      // output (dcudp_cntl) => ()
    dtag_rd_c,           // output (dc_dec) => ()
    fill_byte,           // output (dc_dec) => ()
    iu_data_vld,         // output (dc_dec) => ()
    iu_stall,            // output (dc_dec) => ()
    latch_addr_c,        // output (dcudp_cntl) => ()
    latch_cf_addr,       // output (dcudp_cntl) => ()
    latch_wb_addr,       // output (dcudp_cntl) => ()
    latch_wr_data,       // output (dcudp_cntl) => ()
    merge_sel,           // output (dc_dec) => ()
    repl_addr,           // output (wrbuf_cntl) => ()
    req_addr_sel,        // output (dcudp_cntl) => ()
    smu_data_vld,        // output (dc_dec) => ()
    smu_stall,           // output (dc_dec) => ()
    stat_addr_sel,       // output (dcudp_cntl) => ()
    swap_sel_15_8,       // output (dc_dec) => ()
    swap_sel_23_16,      // output (dc_dec) => ()
    swap_sel_31_24,      // output (dc_dec) => ()
    swap_sel_7_0,        // output (dc_dec) => ()
    wb_ce,               // output (wrbuf_cntl) => ()
    wb_sel,              // output (wrbuf_cntl) => ()
    wb_set_sel,          // output (dcudp_cntl) => ()
    word_addr            // output (dcudp_cntl) => ()
    );

input	[1:0]	biu_dcu_ack;       // Ack bus from Biu
input	[3:0]	cf_addr;           // Part of address used to access word out of cache line
input		clk;               // clock
input		sin;
input	[3:0]	dcu_addr_c;        // word offset of inst in C stage
input		dcu_hit0;          // line in set 0 -- noncacheable inst should not generate hit*****
input		dcu_hit1;          // line in set 1
input	[4:0]	dtg_stat_out;      // status bits from the tag ram
input		iu_trap_c;	   // trap in C stage
input		kill_inst_e;	   // Dont execute the inst. in E stage
input		iu_special_e;	   // special inst from IU
input		iu_addr_e_2;       // for selecting set
input		iu_addr_e_31;      // for diagnostic writes into status register
input	[3:0]	iu_diag_e;
input		iu_flush_cmp_e;
input		iu_flush_inv_e;
input		iu_flush_index_e;
input	[7:0]	iu_inst_e;	   // added bit[7] for na_store. 
input		iu_psr_dce;
input		iu_zero_e;
input	[2:0]	misc_din;          // for diagnostic writes into status register
input		pcsu_powerdown;    // Go into powerdown mode
input		reset_l;             // Reset
input		sm;                // Scan Enable
input		smu_ld;
input		smu_prty;
input		smu_st;
input		smu_na_st;	   //  for detecting non allocating smu store
output		dcu_addr_c_31;
output	[3:0]	algn_sel_15_8;     // aligner mux select - select data[15:8]
output		algn_sel_23_16;    // aligner mux select - select data[23:16]
output		algn_sel_31_24;    // aligner mux select - select data[31:24]
output	[3:0]	algn_sel_7_0;      // aligner mux select - select data[7:0]
output	[4:0]	algn_sign_sel;     // Aligner mux select - selects sign extn
output	[1:0]	algn_size_sel;     // aligner mux select
output		arbiter_sel;       // arbitrates requests from smu and iu.
output	[3:0]	dc_addr_sel;       // select addr input to the dcache ram
output	[3:0]	dc_data_sel;       // select data input to the dc ram.
output		so;
output	[1:0]	dcu_bank_sel;      // select bank for writes into dcram
output		dcu_bypass;        // bypass data from the dcram
output		dcu_dout_sel;      // select data to be sent to memory for write transactions.
output	[2:0]	dcu_err_ack;       // Data access Exception
output		dcu_in_powerdown;  // Inform pcsu that dcu is in powerdown mode.
output		dcu_pwrdown;       // Dcache in powerdown mode (includes internal & pscu powerdown)
output	[3:0]	dcu_ram_we;        // Write enables to the dcram
output		dcu_req;           // Request memory on cache miss
output		dcu_set_sel;       // select set for writes into tag
output	[1:0]	dcu_size;          // Size of transaction requested from memory
output		dcu_smu_st;        // smu store in c stage
output	[4:0]	dcu_stat_out;      // Status bits to be written into ram
output	[4:0]	dcu_stat_we;       // Write Enable for status bits
output		dcu_tag_sel;       // select input to tag ram
output		dcu_tag_we;        // Write Enable to the tags
output	[3:0]	dcu_type;          // Type of transaction requested from memory
output	[2:0]	diag_stat_bits;    // Status bits for a diagnostic read access of tag ram
output		dtag_rd_c;         // Diagnostic read access of tags in C stage
output	[1:0]	fill_byte;         // fill word offset sent to memory
output		iu_data_vld;       // Data on the dcu_data bus is valid
output		iu_stall;          // Stall the IU pipe due to dcache busy,miss
output		latch_addr_c;      // latch addr/data in C on a cache miss/replacing dirty line.
output		latch_cf_addr;     // latch cache fill addr 
output		latch_wb_addr;     // Clock enable to latch writeback addr
output		latch_wr_data;     // latch data in C stage into write miss reg on cache miss
output	[3:0]	merge_sel;         // mux select to sel fill data or writedata
output	[3:0]	repl_addr;         // Word offset in the line being replaced (one for each bank).
output		req_addr_sel;      // select address for memory request
output		smu_data_vld;      // Data on the dcu_data bus is valid
output		smu_stall;         // stall the smu pipe due to dcahe busy,miss
output		stat_addr_sel;     // select status reg addr input 
output	[2:0]	swap_sel_15_8;     // mux selects to swap write data[15:8]
output	[2:0]	swap_sel_23_16;    // mux selects to swap write data[23:16]
output	[2:0]	swap_sel_31_24;    // mux selects to swap write data[31:24]
output	[2:0]	swap_sel_7_0;      // mux selects to swap write data[7:0]
output	[1:0]	wb_ce;             // Clock enables to latch data into writebuffer	
output	[3:0]	wb_sel;            // Select which entry in writebuffer to be put on data bus            
output		wb_set_sel;        // select tag of address to be written back to memory
output	[1:0]	word_addr;         // Selects 32 bit word out of the cache line
output  [2:0]	dcu_perf_sgnl;	   // performance monitor signals

wire		dc_idle;
wire		dc_inst_c;
wire		dc_req;
wire		dc_wr_cyc123;
wire		dcu_hit_c;
wire		dcu_miss_c;
wire		diag_rdy_e;
wire		diagnostic_c;
wire		error_ack;
wire		fill_cyc_active;
wire		first_fill_cyc;
wire		flush_inst_c2;
wire		flush_inst_c_or_c1;
wire		flush_set_sel;
wire		iu_flush_cmp_c;
wire		iu_flush_inv_c;
wire		iu_flush_index_c;
wire		iu_ld_st_e;
wire		last_fill_cyc;
wire		miss_store;
wire		miss_wait;
wire		nc_write_c;
wire		nc_write_cyc;
wire		nc_xaction;
wire		non_cacheable_c;
wire		normal_ack;
wire		repl_busy;
wire		repl_start;
wire		req_outstanding;
wire		special_e;
wire		stall_valid;
wire		store_c;
wire		tag_st_rdy_e;
wire		wb_idle;
wire		wb_req;
wire		zeroline_busy;
wire		zeroline_c;
wire		zeroline_cyc;

wire 		smu_na_st_fill;
wire		smu_na_st_c;
wire		iu_na_st_c;
wire		miss_idle;
wire		real_wb_req;

wire		iu_req_c;
wire		smu_req_c;
wire		iu_valid_c;
wire		dc_error;

dc_dec dc_dec (
    .iu_valid_c	  (iu_valid_c),
    .smu_na_st_fill	  (smu_na_st_fill),	  // output 
    .iu_stall             (iu_stall),             // output (dc_dec) => ()
    .iu_data_vld          (iu_data_vld),          // output (dc_dec) => ()
    .smu_data_vld         (smu_data_vld),         // output (dc_dec) => ()
    .smu_stall            (smu_stall),            // output (dc_dec) => ()
    .iu_ld_st_e           (iu_ld_st_e),           // output (dc_dec) => (dcudp_cntl)
    .normal_ack           (normal_ack),           // output (dc_dec) => (miss_cntl,wrbuf_cntl)
    .error_ack            (error_ack),            // output (dc_dec) => (miss_cntl,wrbuf_cntl)
    .store_c              (store_c),              // output (dc_dec) => (dcudp_cntl)
    .miss_store           (miss_store),           // output (dc_dec) => (dcudp_cntl)
    .dc_inst_c            (dc_inst_c),            // output (dc_dec) => (dcudp_cntl)
    .smu_na_st_c	  (smu_na_st_c),
    .iu_na_st_c	  	  (iu_na_st_c),
    .nc_xaction           (nc_xaction),           // output (dc_dec) => (dcudp_cntl,miss_cntl)
    .zeroline_c           (zeroline_c),           // output (dc_dec) => (dcudp_cntl,miss_cntl)
    .non_cacheable_c      (non_cacheable_c),      // output (dc_dec) => (dcudp_cntl)
    .diagnostic_c         (diagnostic_c),         // output (dc_dec) => (dcudp_cntl)
    .stall_valid          (stall_valid),          // output (dc_dec) => (dcudp_cntl,wrbuf_cntl)
    .iu_flush_cmp_c       (iu_flush_cmp_c),       // output (dc_dec) => (dcudp_cntl)
    .iu_flush_inv_c       (iu_flush_inv_c),       // output (dc_dec) => (dcudp_cntl)
    .iu_flush_index_c     (iu_flush_index_c),     // output (dc_dec) => (dcudp_cntl)
    .swap_sel_7_0         (swap_sel_7_0[2:0]),    // output (dc_dec) => ()
    .swap_sel_15_8        (swap_sel_15_8[2:0]),   // output (dc_dec) => ()
    .swap_sel_23_16       (swap_sel_23_16[2:0]),  // output (dc_dec) => ()
    .swap_sel_31_24       (swap_sel_31_24[2:0]),  // output (dc_dec) => ()
    .merge_sel            (merge_sel[3:0]),       // output (dc_dec) => ()
    .dcu_ram_we           (dcu_ram_we[3:0]),      // output (dc_dec) => ()
    .dcu_bypass           (dcu_bypass),           // output (dc_dec) => ()
    .algn_sign_sel        (algn_sign_sel[4:0]),   // output (dc_dec) => ()
    .algn_sel_7_0         (algn_sel_7_0[3:0]),    // output (dc_dec) => ()
    .algn_sel_15_8        (algn_sel_15_8[3:0]),   // output (dc_dec) => ()
    .algn_sel_23_16       (algn_sel_23_16),       // output (dc_dec) => ()
    .algn_sel_31_24       (algn_sel_31_24),       // output (dc_dec) => ()
    .algn_size_sel        (algn_size_sel[1:0]),   // output (dc_dec) => ()
    .req_outstanding      (req_outstanding),      // output (dc_dec) => (dcudp_cntl,miss_cntl)
    .dtag_rd_c            (dtag_rd_c),            // output (dc_dec) => ()
    .dcu_req              (dcu_req),              // output (dc_dec) => ()
    .dcu_type             (dcu_type[3:0]),        // output (dc_dec) => ()
    .dcu_size             (dcu_size[1:0]),        // output (dc_dec) => ()
    .special_raw_e        (iu_special_e),            // output (dc_dec) => (dcudp_cntl)
    .iu_special_e         (special_e),            // output (dc_dec) => (dcudp_cntl)
    .diag_rdy_e           (diag_rdy_e),           // output (dc_dec) => (dcudp_cntl)
    .tag_st_rdy_e         (tag_st_rdy_e),         // output (dc_dec) => (dcudp_cntl)
    .nc_write_c           (nc_write_c),           // output (dc_dec) => (wrbuf_cntl)
    .fill_byte            (fill_byte[1:0]),       // output (dc_dec) => ()
    .dcu_smu_st           (dcu_smu_st),           // output (dc_dec) => ()
    .dcu_err_ack          (dcu_err_ack[2:0]),     // output (dc_dec) => ()
    .dcu_pwrdown          (dcu_pwrdown),          // output (dc_dec) => ()
    .dcu_in_powerdown     (dcu_in_powerdown),     // output (dc_dec) => ()
    .iu_req_c		  (iu_req_c),
    .smu_req_c		  (smu_req_c),
    .dcu_perf_sgnl	  (dcu_perf_sgnl),
    .dcu_hit0		 (dcu_hit0),
    .dcu_hit1		 (dcu_hit1),
    .smu_na_st		(smu_na_st),
    .pcsu_powerdown       (pcsu_powerdown),       // input  (dc_dec) <= ()
    .dc_req               (dc_req),               // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .wb_req               (wb_req),               // input  (dc_dec) <= (wrbuf_cntl)
    .iu_psr_dce_raw       (iu_psr_dce),           // input  (dc_dec) <= ()
    .cf_addr              (cf_addr[1:0]),         // input  (dc_dec,dcudp_cntl) <= ()
    .dcu_addr_c           (dcu_addr_c[1:0]),      // input  (dc_dec,dcudp_cntl,wrbuf_cntl) <= ()
    .wb_idle              (wb_idle),              // input  (dc_dec) <= (wrbuf_cntl)
    .dc_idle              (dc_idle),              // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .repl_busy            (repl_busy),            // input  (dc_dec,dcudp_cntl) <= (wrbuf_cntl)
    .first_fill_cyc       (first_fill_cyc),       // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .fill_cyc_active      (fill_cyc_active),      // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .zeroline_busy        (zeroline_busy),        // input  (dc_dec) <= (miss_cntl)
    .dcu_miss_c           (dcu_miss_c),           // input  (dc_dec,miss_cntl) <= (dcudp_cntl)
    .dcu_hit_c            (dcu_hit_c),            // input  (dc_dec) <= (dcudp_cntl)
    .biu_dcu_ack          (biu_dcu_ack[1:0]),     // input  (dc_dec) <= ()
    .miss_wait            (miss_wait),            // input  (dc_dec) <= (miss_cntl)
    .iu_trap_c		  (iu_trap_c),		  // input  (dc_dec) <= ()
    .kill_inst_e	  (kill_inst_e),	  // input  (dc_dec) <= ()
    .iu_raw_inst_e        (iu_inst_e[7:0]),       // input  (dc_dec) <= ()
    .iu_raw_zero_e        (iu_zero_e),            // input  (dc_dec) <= ()
    .iu_raw_diag_e        (iu_diag_e[3:0]),       // input  (dc_dec) <= ()
    .iu_raw_flush_cmp_e   (iu_flush_cmp_e),       // input  (dc_dec) <= ()
    .iu_raw_flush_inv_e   (iu_flush_inv_e),       // input  (dc_dec) <= ()
    .iu_raw_flush_index_e (iu_flush_index_e),     // input  (dc_dec) <= ()
    .smu_raw_ld           (smu_ld),               // input  (dc_dec) <= ()
    .smu_raw_st           (smu_st),               // input  (dc_dec) <= ()
    .smu_prty		  (smu_prty),		  // input  (dc_dec) <= ()
    .clk                  (clk),                  // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .reset_l              (reset_l),              // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .so             		(),            // output (dc_dec) => (dcudp_cntl)
    .sin              		(),        // input  (dc_dec) <= ()
    .sm                   	()             // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    );

dcudp_cntl dcudp_cntl (
    .word_addr          (word_addr[1:0]),      // output (dcudp_cntl) => ()
    .dcu_tag_we         (dcu_tag_we),          // output (dcudp_cntl) => ()
    .dcu_stat_we        (dcu_stat_we[4:0]),    // output (dcudp_cntl) => ()
    .dcu_stat_out       (dcu_stat_out[4:0]),   // output (dcudp_cntl) => ()
    .arbiter_sel        (arbiter_sel),         // output (dcudp_cntl) => ()
    .latch_addr_c       (latch_addr_c),        // output (dcudp_cntl) => ()
    .iu_na_st_c	  	  (iu_na_st_c),
    .flush_inst_c2      (flush_inst_c2),       // output (dcudp_cntl) => (wrbuf_cntl)
    .flush_inst_c_or_c1 (flush_inst_c_or_c1),  // output (dcudp_cntl) => (wrbuf_cntl)
    .flush_set_sel      (flush_set_sel),       // output (dcudp_cntl) => (wrbuf_cntl)
    .dcu_miss_c         (dcu_miss_c),          // output (dcudp_cntl) => (dc_dec,miss_cntl)
    .dcu_hit_c          (dcu_hit_c),           // output (dcudp_cntl) => (dc_dec)
    .dc_addr_sel        (dc_addr_sel[3:0]),    // output (dcudp_cntl) => ()
    .stat_addr_sel      (stat_addr_sel),       // output (dcudp_cntl) => ()
    .latch_cf_addr      (latch_cf_addr),       // output (dcudp_cntl) => ()
    .req_addr_sel       (req_addr_sel),        // output (dcudp_cntl) => ()
    .latch_wb_addr      (latch_wb_addr),       // output (dcudp_cntl) => ()
    .repl_start         (repl_start),          // output (dcudp_cntl) => (miss_cntl,wrbuf_cntl)
    .latch_wr_data      (latch_wr_data),       // output (dcudp_cntl) => ()
    .dc_data_sel        (dc_data_sel[3:0]),    // output (dcudp_cntl) => ()
    .dcu_dout_sel       (dcu_dout_sel),        // output (dcudp_cntl) => ()
    .dcu_set_sel        (dcu_set_sel),         // output (dcudp_cntl) => ()
    .wb_set_sel         (wb_set_sel),          // output (dcudp_cntl) => ()
    .dcu_bank_sel       (dcu_bank_sel),        // output (dcudp_cntl) => ()
    .dcu_tag_sel        (dcu_tag_sel),         // output (dcudp_cntl) => ()
    .diag_stat_bits     (diag_stat_bits[2:0]), // output (dcudp_cntl) => ()
    .iu_req_c           (iu_req_c),
    .smu_req_c          (smu_req_c),
    .iu_valid_c		(iu_valid_c), 
    .smu_na_st_fill     (smu_na_st_fill )  ,  // input from dc_dec 
    .cf_addr            (cf_addr[3:2]),        // input  (dc_dec,dcudp_cntl) <= ()
    .repl_busy          (repl_busy),           // input  (dc_dec,dcudp_cntl) <= (wrbuf_cntl)
    .req_outstanding    (req_outstanding),     // input  (dcudp_cntl,miss_cntl) <= (dc_dec)
    .non_cacheable_c    (non_cacheable_c),     // input  (dcudp_cntl) <= (dc_dec)
    .zeroline_cyc       (zeroline_cyc),        // input  (dcudp_cntl,wrbuf_cntl) <= (miss_cntl)
    .zeroline_c         (zeroline_c),          // input  (dcudp_cntl,miss_cntl) <= (dc_dec)
    .iu_flush_cmp_c     (iu_flush_cmp_c),      // input  (dcudp_cntl) <= (dc_dec)
    .iu_flush_inv_c     (iu_flush_inv_c),      // input  (dcudp_cntl) <= (dc_dec)
    .iu_flush_index_c   (iu_flush_index_c),    // input  (dcudp_cntl) <= (dc_dec)
    .dc_req             (dc_req),              // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .wb_req		(real_wb_req), 		//  input
    .dc_inst_c          (dc_inst_c),           // input  (dcudp_cntl) <= (dc_dec)
    .miss_store         (miss_store),          // input  (dcudp_cntl) <= (dc_dec)
    .nc_xaction         (nc_xaction),          // input  (dcudp_cntl,miss_cntl) <= (dc_dec)
    .dc_idle            (dc_idle),             // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .dcu_addr_c_31	(dcu_addr_c_31),
    .stall_valid        (stall_valid),         // input  (dcudp_cntl,wrbuf_cntl) <= (dc_dec)
    .iu_ld_st_e         (iu_ld_st_e),          // input  (dcudp_cntl) <= (dc_dec)
    .special_e          (special_e),           // input  (dcudp_cntl) <= (dc_dec)
    .tag_st_rdy_e       (tag_st_rdy_e),        // input  (dcudp_cntl) <= (dc_dec)
    .diag_rdy_e         (diag_rdy_e),          // input  (dcudp_cntl) <= (dc_dec)
    .first_fill_cyc     (first_fill_cyc),      // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .fill_cyc_active    (fill_cyc_active),     // input  (dc_dec,dcudp_cntl) <= (miss_cntl)
    .last_fill_cyc      (last_fill_cyc),       // input  (dcudp_cntl,wrbuf_cntl) <= (miss_cntl)
    .nc_write_cyc       (nc_write_cyc),        // input  (dcudp_cntl) <= (wrbuf_cntl)
    .dc_wr_cyc123       (dc_wr_cyc123),        // input  (dcudp_cntl) <= (miss_cntl)
    .diagnostic_c       (diagnostic_c),        // input  (dcudp_cntl) <= (dc_dec)
    .dtg_stat_out       (dtg_stat_out[4:0]),   // input  (dcudp_cntl,wrbuf_cntl) <= ()
    .store_c            (store_c),             // input  (dcudp_cntl) <= (dc_dec)
    .iu_addr_e_31       (iu_addr_e_31),        // input  (dcudp_cntl) <= ()
    .misc_din           (misc_din[2:0]),       // input  (dcudp_cntl) <= ()
    .iu_addr_e_2        (iu_addr_e_2),         // input  (dcudp_cntl) <= ()
    .dcu_addr_c_2       (dcu_addr_c[2]),       // input  (dc_dec,dcudp_cntl,wrbuf_cntl) <= ()
    .dcu_hit0           (dcu_hit0),            // input  (dcudp_cntl) <= ()
    .dcu_hit1           (dcu_hit1),            // input  (dcudp_cntl) <= ()
    .clk                (clk),                 // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .reset_l              (reset_l),               // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .so                 (),       // output (dcudp_cntl) => (wrbuf_cntl)
    .sin                 (),           // input  (dcudp_cntl) <= (dc_dec)
    .sm                 ()                   // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    );

wrbuf_cntl wrbuf_cntl (
    .wb_ce              (wb_ce[1:0]),         // output (wrbuf_cntl) => ()
    .wb_sel             (wb_sel[3:0]),        // output (wrbuf_cntl) => ()
    .wb_idle            (wb_idle),            // output (wrbuf_cntl) => (dc_dec)
    .repl_addr          (repl_addr[3:0]),     // output (wrbuf_cntl) => ()
    .repl_busy          (repl_busy),          // output (wrbuf_cntl) => (dc_dec,dcudp_cntl)
    .wb_req             (wb_req),             // output (wrbuf_cntl) => (dc_dec)
    .real_wb_req        (real_wb_req),        // output (wrbuf_cntl) => (dc_dec)
    .nc_write_cyc       (nc_write_cyc),       // output (wrbuf_cntl) => (dcudp_cntl)
    .dcu_addr_c         (dcu_addr_c[3:2]),    // input  (dc_dec,dcudp_cntl,wrbuf_cntl) <= ()
    .error_ack          (error_ack),          // input  (miss_cntl,wrbuf_cntl) <= (dc_dec)
    .normal_ack         (normal_ack),         // input  (miss_cntl,wrbuf_cntl) <= (dc_dec)
    .flush_inst_c2      (flush_inst_c2),      // input  (wrbuf_cntl) <= (dcudp_cntl)
    .flush_inst_c_or_c1 (flush_inst_c_or_c1), // input  (wrbuf_cntl) <= (dcudp_cntl)
    .flush_set_sel      (flush_set_sel),      // input  (wrbuf_cntl) <= (dcudp_cntl)
    .lru_bit            (dtg_stat_out[4]),    // input  (dcudp_cntl,wrbuf_cntl) <= ()
    .repl_start         (repl_start),         // input  (miss_cntl,wrbuf_cntl) <= (dcudp_cntl)
    .smu_na_st_fill	(smu_na_st_fill),
    .stall_valid        (stall_valid),        // input  (dcudp_cntl,wrbuf_cntl) <= (dc_dec)
    .first_fill_cyc      (first_fill_cyc),      // input  (dcudp_cntl,wrbuf_cntl) <= (miss_cntl)
    .miss_idle		(miss_idle),
    .dc_error		(dc_error),
    .nc_write_c         (nc_write_c),         // input  (wrbuf_cntl) <= (dc_dec)
    .clk                (clk),                // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .sin            	(),      // input  (wrbuf_cntl) <= (dcudp_cntl)
    .so           	(),      // output (wrbuf_cntl) => (miss_cntl)
    .sm                 (),                 // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .reset_l              (reset_l)         // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    );

miss_cntl miss_cntl (
    .dc_idle         (dc_idle),         // output (miss_cntl) => (dc_dec,dcudp_cntl)
    .dc_req          (dc_req),          // output (miss_cntl) => (dc_dec,dcudp_cntl)
    .dc_error		(dc_error),
    .last_fill_cyc   (last_fill_cyc),   // output (miss_cntl) => (dcudp_cntl,wrbuf_cntl)
    .first_fill_cyc  (first_fill_cyc),  // output (miss_cntl) => (dc_dec,dcudp_cntl)
    .fill_cyc_active (fill_cyc_active), // output (miss_cntl) => (dc_dec,dcudp_cntl)
    .zeroline_busy   (zeroline_busy),   // output (miss_cntl) => (dc_dec)
    .zeroline_cyc    (zeroline_cyc),    // output (miss_cntl) => (dcudp_cntl,wrbuf_cntl)
    .dc_wr_cyc123    (dc_wr_cyc123),    // output (miss_cntl) => (dcudp_cntl)
    .miss_wait       (miss_wait),       // output (miss_cntl) => (dc_dec)
    .miss_idle	     (miss_idle),
    .req_outstanding (req_outstanding), // input  (dcudp_cntl,miss_cntl) <= (dc_dec)
    .repl_start      (repl_start),      // input  (miss_cntl,wrbuf_cntl) <= (dcudp_cntl)
    .dcu_miss_c      (dcu_miss_c),      // input  (dc_dec,miss_cntl) <= (dcudp_cntl)
    .smu_na_st_c      (smu_na_st_c),
    .zeroline_c      (zeroline_c),      // input  (dcudp_cntl,miss_cntl) <= (dc_dec)
    .normal_ack      (normal_ack),      // input  (miss_cntl,wrbuf_cntl) <= (dc_dec)
    .nc_xaction      (nc_xaction),      // input  (dcudp_cntl,miss_cntl) <= (dc_dec)
    .error_ack       (error_ack),       // input  (miss_cntl,wrbuf_cntl) <= (dc_dec)
    .reset_l           (reset_l),           // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .clk             (clk),             // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    .sin              (),   // input  (miss_cntl) <= (wrbuf_cntl)
    .so              (),  // output (miss_cntl) => ()
    .sm              ()               // input  (dc_dec,dcudp_cntl,miss_cntl,wrbuf_cntl) <= ()
    );

endmodule

