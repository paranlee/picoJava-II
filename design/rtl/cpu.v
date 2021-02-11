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
module cpu(
	pj_su,
	pj_boot8,
	pj_no_fpu,
	pj_irl,
	pj_nmi,
	pj_brk1_sync,
        pj_brk2_sync,
        pj_in_halt,
        pj_inst_complete,
        pj_halt,
        pj_resume,
	pj_standby_out,
	sm, 
	sin, 
	so, 
	pj_clk_out,
	clk, 
	pj_reset_out,
	reset_l,
	pj_dcureq,
	pj_dcusize,
	pj_dcutype,
	pj_dcuaddr,
	pj_dataout,
	pj_dcuack,
	pj_icureq,
	pj_icusize,
	pj_icutype,
	pj_icuaddr,
	pj_icuack,
	pj_datain,
	
	// The following ports are added for the performance counter
	pj_perf_sgnl,
	// The following signals are added for test purpose
	dc_test_err_l,
	dt_test_err_l,
	ic_test_err_l,
	it_test_err_l,
	bist_mode,
	bist_reset,
	test_mode
);

// Memory Interface Signals.
        output pj_su;

// Debug Interface Signals.
        output pj_brk1_sync;
        output pj_brk2_sync;
        output pj_in_halt;
        output pj_inst_complete;
        input pj_halt;
        input pj_resume;

// Processor Interface Signals.
        input pj_boot8;
        input pj_no_fpu;
        input [3:0] pj_irl;
        input pj_nmi;
        input sm;
        input sin;
        input reset_l;
        output pj_standby_out;
        output pj_reset_out;
        input clk;
        output pj_clk_out;
        output so;

//	BIU signals...
	output pj_dcureq;
	output [1:0] pj_dcusize;
	output [2:0] pj_dcutype;
	output [31:0] pj_dcuaddr;
	output [31:0] pj_dataout;
	output pj_icureq;
	output [1:0] pj_icusize;
	output pj_icutype;
	output [31:0] pj_icuaddr;
	input [1:0] pj_dcuack;
	input [1:0] pj_icuack;
	input [31:0] pj_datain;

// 	These are performance counter connection ports
        output [5:0] pj_perf_sgnl;

//	These are test mode connection ports
	output dc_test_err_l;
	output dt_test_err_l;
	output ic_test_err_l;
	output it_test_err_l;
	input [1:0] bist_mode;
	input bist_reset;
	input test_mode;

// Internal busses defined here.


// Originating from the IU
wire	[31:0]	iu_addr_e;		// address bus for dcache/icache 
wire		iu_addr_e_2;		// bit 2 of iu_addr-e
wire		iu_addr_e_31;		// bit 31 of iu_addr-e
wire	[7:0]	iu_inst_e;		// ld/store instruction to dcu
wire	[2:0]	iu_dcu_flush_e;		// flush insts to dcu
wire		iu_icu_flush_e;		// flush icache
wire		iu_zero_e;		// zeroline inst to dcu
wire	[3:0]	iu_d_diag_e;		// diagnostic rd/wr commands to dcu
wire	[3:0]	iu_i_diag_e;		// diagnostic rd/wr commands to icu
wire	[31:0]	iu_br_pc;		// Branch/Trap PC to Icache unit
wire	[31:0]	iu_data_e;		// data for writes to dcu/icu.
wire	[7:0]	iu_shift_d;		// No. of bytes consumed by IU.to ICu
wire	[31:0]	iu_rf_dout;		// stackcache data for spills by smu
wire	[31:0]	iu_smiss_addr;		// scache write miss addr to smu 
wire	[31:0]	iu_smiss_data;		// scache write miss data to smu 

// The following four signals are added to help SMU generate it's own versions of
// sbase and optop signals. this will improve timing on smu_stall paths

wire 	[31:0] 	iu_optop_din;          // Signal at the din input of arch optop flop
 
wire       	iu_optop_int_we;        // This is the write enable for the flop
                                        // in SMU to generate it's own version of optop
wire 	[31:0] 	iu_data_in;            // Data to be written onto SMU's version
                                        // of sbase in case of wr_sbase opcodes
wire       	iu_sbase_we;            // Write enable signal to SMU, whenever there's
                                        // wr_sbase etc.

wire		iu_smiss;		// scache write miss . To smu    
wire	        pj_brk1_sync ;		// Break point 1 encountered	 
wire	        pj_brk2_sync ;		// Break point 2 encountered
wire          	pj_in_halt ;		// Processor in Halt mode	
wire         	pj_inst_complete ;	// Instruction completed
wire	[31:0]	iu_rs1_e ;		// operand A bus to fpu 	
wire	[31:0]	iu_rs2_e ;		// operand B bus to fpu 	
wire	[7:0]	fpop;			// floating point operation	
wire		fpop_valid;		// floating point inst is valid 
wire		hold_fpu;		// hold the fpu pipe
wire		iu_brtaken_e ;		// branch taken. to ICU	 	
wire	[31:0]	iu_psr	;		// PSR register		
wire		iu_kill_fpu ;		// kill any fpu operation 	
wire		iu_kill_dcu ;		// kill any outstanding dcu operation	
wire		iu_special_e;		// special inst to dcu
wire		kill_inst_e;		// kill dcu inst in E
wire	[31:0]	iu_optop_c;		// OPtop register for smu	
wire		ret_optop_update;	// return instruction in pipe
wire	[31:0]	sc_bottom ;		// SC_Bottom register		
wire		iu_smu_flush ;		// flush the smu pipe		
wire		iu_powerdown_op_e;	// powerdown inst in E		
wire          	pj_su   = iu_psr[5];	// Processor in supervisor mode  





// Originating from ICU
wire 	[55:0] 	icu_data;		// Top 7 bytes of ibuffer
wire	[31:0]	icu_diag_data;		// diagnostic read bus to IU
wire	[6:0]	icu_drty;		// indicate inst is dirty. to IU
wire	[6:0]	icu_vld_d;		// indicate inst is valid. to IU
wire	[27:0]	icu_length_d;		// length of instr in ibuf. to IU
wire		icu_tag_we;		// Write to IcacheTag. 
wire	[1:0]	icu_ram_we;		// Write enable to Icache RAM
wire	[31:0]	icu_pc_d;		// PC of first byte of ibuffer
wire	[1:0]	icu_size;		// Size of transaction. To biu
wire	[3:0]	icu_type;		// Type of transaction. To biu
wire	[`it_msb:0] icu_tag_in;		// Data to be written into tag ram
wire		icu_tag_vld;		// valid bit value to be written to tag.
wire		icu_in_powerdown;	// Icache in Powerdown mode
wire		icram_powerdown;	// Icache ram to go into powerdown
wire		icu_hold;		// Hold the IU pipe
wire	[31:0]	icu_din;		// Data to be written into Icache ram
wire	[`ic_msb:0]icu_addr;		// Icache address used by icache ram & tag.

// Originating from Icache RAM
wire	[63:0]	icram_dout;		// Icache RAM output to ICU


// Originating from Icache Tag
wire		itag_vld;		// valid bit of the icache tag
wire		ic_hit;			// icache hit .used by icu
wire	[`it_msb:0] itag_dout;		// Tag output


// Originating from DCU
wire		dcu_smu_st;		// smu store in C stage .for smu
wire	[31:0] dcu_addr_out;	// dcu addr used for dcache ram & tag
wire	[1:0]	dcu_bank_sel;		// select bank of dcache ram.
wire	[31:0]	dcu_data;		// dcu data for iu/smu for loads.
wire	[31:0]	dcu_din_e;		// data to be written into dcache ram.
wire	[3:0]	dcu_ram_we;		// write enables to the dcache ram
wire		dcu_tag_we;		// write enable for the tag ram
wire		dcu_in_powerdown;	// dcu is in powerdown mode
wire		dcu_pwrdown;		// dcram & dtag to go into powerdown
wire	[2:0]	dcu_err_ack;		// Error Acks to IU.due to mem errors
wire		dcu_set_sel;		// Select set of Tag.
wire		dcu_bypass;		// Bypass dcache ram.
wire		un_conn;		// unconnected wire
wire    [`dc_msb:0]	dcu_stat_addr;	// address to status register of tag
wire    [`dt_msb:0] dcu_tag_in;		// data to be written into the  tag
wire	[4:0]	dcu_stat_out;		// data to be written into status reg
wire	[4:0]	dcu_stat_we;		// write enables to status reg of tag.
wire		iu_stall;		// stall the iu pipe
wire		smu_stall;		// stall the smu pipe
wire		smu_data_vld;		// data on dcu_data is valid smu data
wire		iu_data_vld;		// data on dcu_data is valid iu data
wire	[31:0]	dcu_diag_data;		// diagnostic data from dcu to iu	
wire		wb_set_sel;		// writebuffer set select



// Originating from Dcache RAM
wire	[63:0]	dcram_dout;		// dcache ram output to dcu

// Originating from Dcache Tag
wire	[`dt_msb:0] tag_dout;		// tag data of set 0
wire	[4:0]	dtg_stat_out;		// status bits of the tag
wire		hit0 	 ;		// cache hit in set 0
wire		hit1	;		// cache hit is set 1


// Originating from the SMU
wire	[31:0]	smu_addr;		// address to dcu for spills/fills
wire	[31:0]	smu_data;		// data to dcu on spills
wire		smu_ld;			// smu load to dcu
wire		smu_st;			// smu store to dcu
wire		smu_na_st;		// non allocating store to dcu
wire	[31:0]	smu_sbase;		// new sbase value to IU
wire		smu_sbase_we;		// write enable for new sbase value
wire		smu_prty;		// smu has priority over iu in dcu
wire		smu_hold_out;		// hold the IU pipe (output from smu)
// The following assignment has been done for random assertion of smu_hold for debugging. This
// does not affect any functionality.
wire		smu_hold = smu_hold_out; // hold the IU pipe. Input to dcu and iu blocks.
wire		smu_we;			// write enable for stackcache write
wire	[5:0]	smu_rf_addr;		// address of stackcache entry
wire	[31:0]	smu_rf_din;		// data to stackcache on fills


// BIU - CPU External Xface...
wire 	[1:0] 	pj_dcuack;		// data acknowledge to ICU
wire 	[1:0] 	pj_icuack;		// data acknowledge to DCU
wire 	[31:0] 	pj_datain;		// data to ICU/DCU


// Originating from PCSU
// wire		pj_internal_clk;	// clk to other modules 
wire		pcsu_powerdown;		// command to other blocks to powerdown.
wire	[3:0]	pj_irl_sync;		// interrupts synchronized. to IU		
wire		pj_nmi_sync;		// nonmaskable intr synchronized. to IU		

// Originating from FPU
wire	[31:0]	fpu_data_e;		// output data of FPU
wire		fp_rdy_e;		// fpu ready for new instruction.

// Misc
wire    [31:`ic_msb+1] unconn;		// unconnected part of icu addr.


// IU [Integer Unit]

iu      iu (
          // From/To EX
          .iu_data_vld		(iu_data_vld),
          .dcu_diag_data_c	(dcu_diag_data[31:0]),
          .icu_diag_data_c	(icu_diag_data[31:0]),
          .dcu_data_c		(dcu_data[31:0]),
          .pj_boot8_e		(pj_boot8),
          .pj_no_fpu_e		(pj_no_fpu),
          .iu_inst_e		(iu_inst_e[7:0]),
          .iu_dcu_flush_e	(iu_dcu_flush_e[2:0]),
          .iu_icu_flush_e	(iu_icu_flush_e),
          .iu_zero_e		(iu_zero_e),
          .iu_d_diag_e		(iu_d_diag_e[3:0]),
          .iu_i_diag_e		(iu_i_diag_e[3:0]),
	  .iu_special_e		(iu_special_e),
	  .kill_inst_e		(kill_inst_e),
          .iu_addr_e		(iu_addr_e[31:0]),
	  .iu_addr_e_2		(iu_addr_e_2),
	  .iu_addr_e_31		(iu_addr_e_31),
          .iu_br_pc_e		(iu_br_pc[31:0]),
          .iu_data_e		(iu_data_e[31:0]),
	  .iu_brtaken_e		(iu_brtaken_e),
	  .iu_data_in		(iu_data_in),
	  .iu_sbase_we		(iu_sbase_we),
	  .iu_optop_din		(iu_optop_din),
	  .iu_optop_int_we	(iu_optop_int_we),
	  .sc_bottom		(sc_bottom[31:0]),
	  .psr			(iu_psr[31:0]),
	  .optop_c		(iu_optop_c[31:0]),
	  .ret_optop_update	(ret_optop_update),
	  .iu_powerdown_op_e	(iu_powerdown_op_e),

         // From/To IFU
          .icu_data		(icu_data[55:0]),
          .icu_drty		(icu_drty[6:0]),
          .icu_vld_d		(icu_vld_d[6:0]),
          .icu_length_d		(icu_length_d[27:0]),
          .iu_shift_d		(iu_shift_d[7:0]),

          // To RCU
          .smu_data		(smu_rf_din[31:0]),
          .smu_rf_addr		(smu_rf_addr[5:0]),
          .smu_we		(smu_we),
          .iu_smu_data		(iu_rf_dout[31:0]),
	  .smu_sbase		(smu_sbase[31:2]),
	  .smu_sbase_we		(smu_sbase_we),
 	  .iu_smu_flush		(iu_smu_flush),
	  .scache_wr_miss_w	(iu_smiss),
	  .iu_data_w		(iu_smiss_data),
	  .dest_addr_w		(iu_smiss_addr),

        // To  Pipe
          .icu_pc_d		(icu_pc_d[31:0]),
          .dcu_stall		(iu_stall),
          .icu_hold		(icu_hold),
          .fp_rdy_e		(fp_rdy_e),
          .smu_hold		(smu_hold),
	  .iu_perf_sgnl		(pj_perf_sgnl[2:0]),

	  .smu_addr		(smu_addr[29:14]),
	  .smu_st		(smu_st),
	  .smu_ld		(smu_ld),
	  .pj_in_halt		(pj_in_halt),
	  .pj_resume		(pj_resume),
	  .pj_halt		(pj_halt),
	  .pj_brk1_sync		(pj_brk1_sync),
	  .pj_brk2_sync		(pj_brk2_sync),
	  .pj_inst_complete	(pj_inst_complete),
  	  .pj_nmi		(pj_nmi_sync),
  	  .pj_irl		(pj_irl_sync),
	  .iu_kill_fpu		(iu_kill_fpu),
	  .iu_kill_dcu		(iu_kill_dcu),
	  .dcu_err_ack		(dcu_err_ack[2:0]),

	// to/from fpu
          .fpu_data_e		(fpu_data_e[31:0]),
          .opcode_1_op_r	(fpop[7:0]),
          .valid_op_r		(fpop_valid),
          .iu_rs1_e		(iu_rs1_e[31:0]),
          .iu_rs2_e		(iu_rs2_e[31:0]),
          .hold_fpu		(hold_fpu),
	
	

        // Global signals
	  .te_ieu_rom		(test_mode),
	  .reset_out		(pj_reset_out),
          .reset_l		(reset_l),
          .clk			(clk),
          .sm			(),
          .sin			(),
          .so			()
        );

`ICU_MODULE icu (
    .biu_data     (pj_datain[31:0]),     // input  (icu) <= (mem_ctl)
    .biu_icu_ack  (pj_icuack[1:0]),   // input  (icu) <= (mem_ctl)
    .clk          (clk),    // input  (icram,icu,itag,iu_stub,mem_ctl) <= ()
    .icram_dout   (icram_dout[63:0]),   // input  (icu) <= (icram)
    .sin  	  (),        		// input  (icu) <= ()
    .sm       	  (),     // input  (icram,icu,itag) <= ()
    .itag_dout    (itag_dout),		// input  (icu) <= (itag)
    .itag_vld     (itag_vld),           // input  (icu) <= (itag)
    .iu_addr_e    ({2'b0,iu_addr_e[29:0]}),// Connect iu_addr_e from iu
    .iu_br_pc     (iu_br_pc[31:0]),     // input  (icu) <= ()
    .iu_brtaken_e (iu_brtaken_e),       // input  (icu) <= ()
    .iu_flush_e   (iu_icu_flush_e),     // Connect iu_flush_e from iu
    .iu_ic_diag_e (iu_i_diag_e[3:0]),   // Connect iu_ic_diag_e from iu 
    .iu_psr_ice   (iu_psr[9]),          // Connect iu_psr_ice from iu
    .iu_shift_d   (iu_shift_d[7:0]),    // input  (icu) <= (iu)
    .misc_din     (iu_data_e[31:0]),    // Connect misc_din from iu, once it is ready
    .misc_dout	  (icu_diag_data[31:0]),
    .pcsu_powerdown (pcsu_powerdown),   // input  (ic_cntl) <= (pcsu)
    .iu_psr_bm8   (iu_psr[14]),         // input  (ic_cntl) <= (iu)
    .reset_l        (reset_l),           // input  (icu) <= ()
    .icu_addr     ({unconn,icu_addr}),  // output (icu) => (icram,itag)
    .icu_biu_addr (pj_icuaddr[31:0]), // output (icu) => ()
    .icu_din      (icu_din[31:0]),      // output (icu) => (icram)
    .icu_dout_d   (icu_data[55:0]),   	// output (icu) => (iu)
    .ibuf_oplen   (icu_length_d[27:0]), 
    .icu_drty_d   (icu_drty[6:0]),      // Connect to icu_drty in iu
    .icu_itag_we  (icu_tag_we),         // output (icu) => (itag)
    .icu_pc_d     (icu_pc_d[31:0]),     	// output (icu) => ()
    .icu_ram_we   (icu_ram_we[1:0]),    // output (icu) => (icram)
    .icu_req      (pj_icureq),            // output (icu) => (mem_ctl)
    .so 		(),      		// output (icu) => (icram)
    .icu_size     (pj_icusize[1:0]),      // output (icu) => ()
    .icu_tag_in   (icu_tag_in),         // output (icu) => (itag)
    .icu_tag_vld  (icu_tag_vld),        // output (icu) => (itag)
    .icu_type     ({icu_type[3:2],pj_icutype,icu_type[0]}),      // output (icu) => (mem_ctl)
    .icu_vld_d    (icu_vld_d[6:0]),     // output (icu) => (iu_stub)
    .diag_ld_cache_c (diag_ld_cache_c), // output (icctl) => (icu_dpath)
    .icu_in_powerdown (icu_in_powerdown), // output (icctl) => (pcsu)
    .icram_powerdown    (icram_powerdown),// output (icctl) => (icu_dpath)
    .icu_hold     (icu_hold),
    .ic_hit       (ic_hit)
    );

`ICRAM_MODULE icram_shell (
    .icu_din    (icu_din[31:0]),       // input  (icram) <= (icu)
    .icu_ram_we (icu_ram_we[1:0]),     // input  (icram) <= (icu)
    .enable     (icram_powerdown),     // input  (icram,itag) <= ()
    .icu_addr   (icu_addr[`ic_msb:3]), // input  (icram,itag) <= (icu)
    .icram_dout (icram_dout[63:0]),     // output (icram) => (icu)
    .clk        (clk),     // input  (icram,icu,itag,iu_stub,mem_ctl) <= ()
    .bist_mode  (bist_mode),           // input (pico) => (icram_shell)  
    .bist_reset (bist_reset),          // input (pico) => (icram_shell)  
    .test_mode  (test_mode),                // input (pico) => (icram_shell)
    .icache_test_err_l (ic_test_err_l),
    .sin               (),             // scan input
    .sm                (),             // scan enable
    .so                ()              // scan output
    );

`ITAG_MODULE itag_shell (
    .icu_tag_in   (icu_tag_in),          // input  (itag) <= (icu)
    .icu_tag_vld  (icu_tag_vld),         // input  (itag) <= (icu)
    .icu_tag_we   (icu_tag_we),          // input  (itag) <= (icu)
    .icu_tag_addr (icu_addr[`ic_msb:4]), // input  (icram,itag) <= (icu)
    .enable       (icram_powerdown),          // input  (icram,itag) <= ()
    .itag_dout    (itag_dout),           // output (itag) => (icu)
    .itag_vld     (itag_vld),            // output (itag) => (icu)
    .ic_hit       (ic_hit),              // output (itag) => (icu)
    .clk          (clk),                 // input  (icram,icu,itag,iu_stub,mem_ctl) <= ()
    .bist_mode    (bist_mode),
    .bist_reset   (bist_reset),
    .test_mode    (test_mode),
    .itag_test_err_l    (it_test_err_l),
    .sm           (),                    // input  (icram,icu,itag) <= ()
    .sin          (),                    // input  (itag) <= (icram)
    .so           ()                     // output (itag) => ()
    );


`DCU_MODULE dcu (
    .biu_data         (pj_datain[31:0]),       // input  (dcu) <= ()
    .biu_dcu_ack      (pj_dcuack[1:0]),     // input  (dcu) <= ()
    .clk              (clk),                  // input  (dcram,dcu,dtag) <= ()
    .dcram_dout       (dcram_dout[63:0]),     // input  (dcu) <= (dcram)
    .sin      		(),          	      // input  (dcu) <= ()
    .sm           		(),         // input  (dcram,dcu,dtag) <= ()
    .dtg_dout         (tag_dout[`dt_msb:0]), // input  (dcu) <= (dtag)
    .dtg_stat_out     (dtg_stat_out[4:0]),    // input  (dcu) <= (dtag)
    .hit0	      (hit0),			// input (dcu) <= (dtag)
    .hit1	      (hit1),			// input (dcu) <= (dtag)
    .iu_addr_e        ({2'b0,iu_addr_e[29:0]}),      // input  (dcu) <= ()
    .iu_addr_e_2	(iu_addr_e_2),
    .iu_addr_e_31	(iu_addr_e_31),
    .iu_trap_c	      (iu_kill_dcu),	     //  input (dcu)  <= ()
    .kill_inst_e      (kill_inst_e),
    .iu_special_e     (iu_special_e),
    .iu_data_e        (iu_data_e[31:0]),      // input  (dcu) <= ()
    .iu_diag_e        (iu_d_diag_e[3:0]),       // input  (dcu) <= ()
    .iu_flush_cmp_e   (iu_dcu_flush_e[2]),       // input  (dcu) <= ()
    .iu_flush_index_e (iu_dcu_flush_e[1]),     // input  (dcu) <= ()
    .iu_flush_inv_e   (iu_dcu_flush_e[0]),
    .iu_inst_e        (iu_inst_e[7:0]),       // input  (dcu) <= ()
    .iu_psr_dce       (iu_psr[10]),           // input  (dcu) <= ()
    .dcu_smu_st	      (dcu_smu_st),	      //input to smu
    .iu_zero_e        (iu_zero_e),            // input  (dcu) <= ()
    .misc_din         (iu_data_e[31:0]),      // input  (dcu) <= ()
    .pcsu_powerdown   (pcsu_powerdown),		
    .reset_l            (reset_l),             // input  (dcu) <= ()
    .smu_addr         (smu_addr[31:0]),       // input  (dcu) <= ()
    .smu_data         (smu_data[31:0]),       // input  (dcu) <= ()
    .smu_ld           (smu_ld),               // input  (dcu) <= ()
    .smu_st           (smu_st),               // input  (dcu) <= ()
    .smu_na_st        (smu_na_st),            // input  (dcu) <= ()
    .smu_prty	      (smu_hold),	      // input  (dcu) <= ()
    .pj_halt	      (pj_halt),	      // input  (dcu) <= ()
    .pj_in_halt	      (pj_in_halt),	      // input  (dcu) <= ()
    .dcu_addr_out     (dcu_addr_out[31:0]),// output (dcu) => (dcram,dtag)
    .dcu_bank_sel     (dcu_bank_sel),         // output (dcu) => (dcram)
    .dcu_biu_addr     (pj_dcuaddr[31:0]),   // output (dcu) => ()
    .dcu_biu_data     (pj_dataout[31:0]),   // output (dcu) => ()
    .dcu_data         (dcu_data[31:0]),       // output (dcu) => ()
    .dcu_din_e        (dcu_din_e[31:0]),      // output (dcu) => (dcram)
    .dcu_ram_we       (dcu_ram_we[3:0]),      // output (dcu) => (dcram)
    .dcu_req          (pj_dcureq),              // output (dcu) => ()
    .dcu_in_powerdown (dcu_in_powerdown),     // need to connect to pcsu
    .dcu_pwrdown      (dcu_pwrdown ) ,        // connect to dcram and dtag
    .dcu_err_ack      (dcu_err_ack),
    .dcu_perf_sgnl    (pj_perf_sgnl[5:3]),	
    .so     		(),         // output (dcu) => ()
    .dcu_set_sel      (dcu_set_sel),          // output (dcu) => (dtag)
    .dcu_bypass       (dcu_bypass),
    .dcu_size         (pj_dcusize[1:0]),        // output (dcu) => ()
    .dcu_stat_addr    (dcu_stat_addr),        // output (dcu) => (dtag)
    .dcu_stat_out     (dcu_stat_out[4:0]),    // output (dcu) => (dtag)
    .dcu_stat_we      (dcu_stat_we[4:0]),     // output (dcu) => (dtag)
    .dcu_tag_in       (dcu_tag_in[`dt_msb:0]),    // output (dcu) => (dtag)
    .dcu_tag_we       (dcu_tag_we),           // output (dcu) => (dtag)
    .dcu_type         ({pj_dcutype[2],un_conn,pj_dcutype[1:0]}),        // output (dcu) => ()
    .iu_stall         (iu_stall),             // output (dcu) => ()
    .smu_data_vld     (smu_data_vld),
    .iu_data_vld      (iu_data_vld),
    .misc_dout        (dcu_diag_data[31:0]),      // output (dcu) => ()
    .smu_stall        (smu_stall),            // output (dcu) => ()
    .wb_set_sel	      (wb_set_sel)	      // output (dcu) =>(dtag)
    );
 
`DCRAM_MODULE dcram_shell (
    .data_in      ({dcu_din_e[31:0],dcu_din_e[31:0]}), // input  (dcram) <= (dcu)
    .we           (dcu_ram_we[3:0]),     // input  (dcram) <= (dcu)
    .reg_enable       (dcu_pwrdown),          // input  (dcram,dtag) <= ()
    .addr         (dcu_stat_addr[`dc_msb:0]), // input  (dcram,dtag) <= (dcu)
    .bank_sel     (dcu_bank_sel),        // input  (dcram) <= (dcu)
    .bypass       (dcu_bypass),
    .clk          (clk),              // input  (dcram,dcu,dtag) <= ()
    .sm           (),        // input  (dcram,dcu,dtag) <= ()
    .sin          (),                // input  (dcram) <= ()
    .so           (),            // output (dcram) => ()
    .data_out    (dcram_dout[63:0]),    // output (dcram) => (dcu)
    .bist_mode    (bist_mode),
    .bist_reset   (bist_reset),
    .test_mode    (test_mode),
    .dcache_test_err_l (dc_test_err_l)
    );


`DTAG_MODULE dtag_shell (
    .tag_in       (dcu_tag_in[`dt_msb:0]),    // input  (dtag) <= (dcu)
    .stat_in      (dcu_stat_out[4:0]),    // input  (dtag) <= (dcu)
    .set_sel      (dcu_set_sel),          // input  (dtag) <= (dcu)
    .wb_set_sel	  (wb_set_sel),
    .tag_we       (dcu_tag_we),           // input  (dtag) <= (dcu)
    .stat_we      (dcu_stat_we[4:0]),     // input  (dtag) <= (dcu)
    .addr         (dcu_addr_out[`dc_msb:4]),  // input  (dcram,dtag) <= (dcu)
    .stat_addr    (dcu_stat_addr[`dc_msb:4]),        // input  (dtag) <= (dcu)
    .hit0_out     (hit0),                   // output (dtag) <= (dcu)
    .hit1_out     (hit1),                   // output (dtag) <= (dcu)
    .reg_enable       (dcu_pwrdown),           // input  (dcram,dtag) <= ()
    .clk          (clk),               // input  (dcram,dcu,dtag) <= ()
    .sm           (),         // input  (dcram,dcu,dtag) <= ()
    .sin          (),                 // input  (dtag) <= ()
    .so           (),               // output (dtag) => ()
    .dtag_dout     (tag_dout[`dt_msb:0]), // output (dtag) => (dcu)
    .cmp_addr_in  (dcu_addr_out[`dt_addr_msb:`dc_msb+1]),
    .stat_out     (dtg_stat_out[4:0]),     // output (dtag) => (dcu)
    .test_mode    (test_mode),
    .bist_mode    (bist_mode),
    .bist_reset   (bist_reset),
    .dtag_test_err_l (dt_test_err_l)
    );


// Module Dribbler [Stack manager Unit]

smu smu (

	.iu_data_in		(iu_data_in),
	.iu_sbase_we		(iu_sbase_we),
	.iu_optop_in		(iu_optop_din),
	.iu_optop_int_we	(iu_optop_int_we),
	.low_mark({iu_psr[18:16],3'b0}),
	.high_mark({iu_psr[21:19],3'b0}),
	.iu_int(1'b0),
	.ret_optop_update(ret_optop_update),
        .smu_addr(smu_addr),
        .smu_data(smu_data),
        .smu_sbase(smu_sbase),
        .smu_sbase_we(smu_sbase_we),
        .smu_ld(smu_ld),
        .smu_st(smu_st),
	.smu_na_st(smu_na_st),
	.smu_prty(smu_prty),
        .smu_stall(smu_stall),
        .smu_we(smu_we),
        .smu_hold(smu_hold_out),
        .smu_data_vld(smu_data_vld),
        .smu_st_c(dcu_smu_st),
        .iu_smu_flush(iu_smu_flush),
        .smu_rf_addr(smu_rf_addr),
        .smu_rf_din(smu_rf_din),
        .iu_rf_dout(iu_rf_dout),
        .dcu_data(dcu_data),
	.iu_psr_dre(iu_psr[7]),
	.iu_smiss(iu_smiss),
	.iu_address(iu_smiss_addr),
	.iu_data(iu_smiss_data),
        .clk(clk),
        .sm(),
        .so(),
        .sin(),
        .reset_l(reset_l) 

);


// Module PCSU [Powerdown, Clock, Scan unit]

pcsu    pcsu (
        // OUTPUTS
        .pj_clk_out             (pj_clk_out),
        .pj_standby_out         (pj_standby_out),
        .pcsu_powerdown         (pcsu_powerdown),
        .so		        (),
        .reset_l                (reset_l),
        .pj_irl_sync            (pj_irl_sync[3:0]),
        .pj_nmi_sync            (pj_nmi_sync),

        // INPUTS
        .clk                    (clk),
        .pj_irl                 (pj_irl[3:0]),
        .pj_nmi                 (pj_nmi),
        .dcu_in_powerdown       (dcu_in_powerdown),
        .icu_in_powerdown       (icu_in_powerdown),
        .iu_powerdown_e         (iu_powerdown_op_e),
        .sin             	(),
        .sm  	                ()
);
		
// Module FPU [The Floating point Unit]
// This is the fpu module variable which gets set to either 
// use fpu (when the fpu is present) or fpu_dummy (when the fpu is absent)
// Please refer to picoJava-II/sim/test/sample_tests/README for more information
 
`FPU_MODULE fpu (
     	.fpain			(iu_rs2_e[31:0]), // A bus input.
     	.fpbin			(iu_rs1_e[31:0]), // B bus input.
     	.fpop			(fpop[7:0]),   // Java Fp opcode.
	.fpop_valid		(fpop_valid),	// Valid instruction in D stage
     	.fpbusyn		(fp_rdy_e),  	    // FPU ready when 1.
     	.fpkill			(iu_kill_fpu), 	    // kill fpop.
     	.fpout			(fpu_data_e[31:0]),  // fpu Output bus.
     	.clk			(clk),
     	.sin			(),
     	.sm			(),
	.so			(),
        .powerdown         (pcsu_powerdown),
     	.reset_l		(reset_l),
     	.fphold  		(hold_fpu), 	    // Hold the fpu
	.test_mode		(test_mode)
);



endmodule
