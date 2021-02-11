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



module dc_dec ( 
		iu_valid_c,
		iu_stall,	
    		iu_data_vld,
    		smu_data_vld,
		smu_stall,
		dcu_type,
		dcu_size,
		dcu_req,
		iu_ld_st_e, 
		normal_ack, 
		error_ack, 
		store_c,
		miss_store,
		dc_inst_c,
		smu_na_st_c,
		iu_na_st_c,
		non_cacheable_c,
		nc_xaction,
		stall_valid,
		swap_sel_7_0,
		swap_sel_15_8,
		swap_sel_23_16,
		swap_sel_31_24,
		merge_sel,
		iu_flush_inv_c,
		iu_flush_cmp_c,
		iu_flush_index_c,
		dcu_ram_we,
		dcu_bypass,
		algn_sign_sel,
		algn_sel_7_0,
		algn_sel_15_8,
		algn_sel_23_16,
		algn_sel_31_24,
		algn_size_sel,
		req_outstanding,
		diagnostic_c,
		dtag_rd_c,
		special_raw_e,
		diag_rdy_e,
		tag_st_rdy_e,
		nc_write_c,
		zeroline_c,
		fill_byte,
		dcu_pwrdown,
		dcu_in_powerdown,
		dcu_err_ack,
		smu_na_st_fill,
		iu_req_c,
		smu_req_c,
		dcu_perf_sgnl,
		iu_special_e,

		// INPUTS
		dcu_hit0,
		dcu_hit1,
		biu_dcu_ack,
		cf_addr,
		dcu_addr_c,
		dcu_hit_c,
		pcsu_powerdown,
		iu_psr_dce_raw,
		wb_idle,
		dc_idle,
		zeroline_busy,
		repl_busy,
		first_fill_cyc,
		fill_cyc_active,
		dcu_miss_c,
		dc_req,
		wb_req,
		miss_wait,
		iu_trap_c,
		kill_inst_e,
		iu_raw_inst_e,
		iu_raw_zero_e,
		iu_raw_flush_inv_e,
		iu_raw_flush_cmp_e,
		iu_raw_flush_index_e,
		iu_raw_diag_e,
		smu_raw_ld,
		smu_raw_st,
		smu_na_st,
		smu_prty,
	  	dcu_smu_st,
		clk,	
		reset_l,
		sin,
		so,
		sm	
	);
output			iu_valid_c;
output			iu_stall;		// Stall the IU pipe due to dcache busy,miss
output			iu_data_vld;		// Data on the dcu_data bus is valid
output			smu_data_vld;		// Data on the dcu_data bus is valid
output			smu_stall;		// stall the smu pipe due to dcahe busy,miss
output			iu_ld_st_e;		// valid ld/st inst in E stage
output			normal_ack;		// transaction is a valid one
output			error_ack;		// transaction is an error one
output			store_c;		// Valid store in C stage 
output			miss_store;		// current miss is a store
output			dc_inst_c;		// Valid dcache related inst in C stage
output			smu_na_st_c;             // dcu non_allocated store in c (smu )
output			iu_na_st_c;		// Non allocating IU store

output			nc_xaction;		// NC transcation
output			zeroline_c;		// Zeroline instruction in C stage
output			non_cacheable_c;	// NC inst in C stage
output			diagnostic_c;		// diagnostic access in C stage
output			stall_valid;		// recirculate the address/data reg in C stage
output			iu_flush_cmp_c;		// flush cmp in C stage
output			iu_flush_inv_c;		// flush invalidate in C stage
output			iu_flush_index_c;	// flush index in C stage
output	[2:0]		swap_sel_7_0;		// mux selects to swap write data[7:0]
output  [2:0]           swap_sel_15_8;		// mux selects to swap write data[15:8]
output  [2:0]           swap_sel_23_16;		// mux selects to swap write data[23:16]
output  [2:0]          	swap_sel_31_24;		// mux selects to swap write data[31:24]
output	[3:0]		merge_sel;		// mux select to sel fill data or writedata
output	[3:0]		dcu_ram_we;		// Write enables to the dcram
output			dcu_bypass;		// bypass data from the dcram
output	[4:0]		algn_sign_sel;		// Aligner mux select - selects sign extn
output	[3:0]		algn_sel_7_0;		// aligner mux select - select data[7:0]
output	[3:0]		algn_sel_15_8;		// aligner mux select - select data[15:8]
output  	        algn_sel_23_16;         // aligner mux select - select data[23:16]
output             	algn_sel_31_24;         // aligner mux select - select data[31:24]
output	[1:0]		algn_size_sel;		// aligner mux select
output			req_outstanding;	// there is a memory request outstanding
output			dtag_rd_c;		// Diagnostic read access of tags in C stage
output			dcu_req;		// Request memory on cache miss
output	[3:0]		dcu_type;		// Type of transaction requested from memory
output	[1:0]		dcu_size;		// Size of transaction requested from memory
output			iu_special_e;		// special inst in E
input			special_raw_e;		// RAW special inst in E
output			diag_rdy_e;		// diagnostic inst ready to be executed  in E
output			tag_st_rdy_e;		// diagnostic tag store ready to be executed in E
output			nc_write_c;		// noncacheable write in C stage
output	[1:0]		fill_byte;		// fill word offset sent to memory
output			dcu_smu_st;		// smu store in c stage
output	[2:0]		dcu_err_ack;		// Data access Exception
output 		        smu_na_st_fill;        // fill cycle for nonallocate smu store miss 
output			dcu_pwrdown;		// Dcache in powerdown mode (includes internal & pscu powerdown)
output			dcu_in_powerdown;	// Inform pcsu that dcu is in powerdown mode.
output			iu_req_c;
output			smu_req_c;
output	[2:0]		dcu_perf_sgnl;

input			dcu_hit0;
input			dcu_hit1;

input			pcsu_powerdown;		// Go into powerdown mode
input			dc_req;			// Load requested from memory
input			wb_req;			// write requested from memory
input			iu_psr_dce_raw;		// Dcache is disable in PSR
input	[1:0]		cf_addr;		// word offset of cache fill line
input	[1:0]		dcu_addr_c;		// word offset of inst in C stage
input			wb_idle	;		// Writeback state m/c is in idle state
input			dc_idle;		// Miss state m/c is in idle state
input			repl_busy;		// Replacing 1st half line in progress
input			first_fill_cyc;		// first cache fill cycle
input			fill_cyc_active;	// current cycle is a cache fill cycle
input			zeroline_busy;		// zeroline instruction in progress
input			dcu_miss_c;		// Cache miss in C stage
input			dcu_hit_c;
input	[1:0]		biu_dcu_ack;		// Ack bus from Biu
input			miss_wait;		// the state in which pipe needs to wait till it gets data
input			iu_trap_c;		// Trap in C stage
input			kill_inst_e;		// kill the instruction in e stage
input	[7:0]		iu_raw_inst_e ;		// Normal ld/st instruction in E stage
input			iu_raw_zero_e;		// Zero line instruction in E stage
input	[3:0]		iu_raw_diag_e;		// diagnostic read in E stage
input			iu_raw_flush_inv_e;
input			iu_raw_flush_cmp_e;		// Compare flush inst in E stage
input			iu_raw_flush_index_e;	// Indexed flush inst in E stage
input			smu_raw_ld	;		// ld request from smu
input			smu_raw_st ;		// st request from smu
input			smu_na_st;		// Non allocating store from smu
input			smu_prty;		// higher priority to smu. mask off iu request
input			clk	;
input			reset_l ;
output			so;
input			sin;
input			sm ;


// Local Variables
wire	[7:0]	iu_miss_inst;
wire	[7:0]	iu_inst_c;
wire	[7:0]	iu_miss_stall_inst;
wire	[3:0]	smu_miss_inst;
wire	[3:0]	smu_miss_stall_inst;
wire	[3:0]	smu_inst_c;
wire	[3:0]	iu_diag_c;
wire		squash_iu_inst;
wire		iu_flush_index_e;
wire		iu_flush_cmp_e;
wire		iu_flush_inv_e;
wire		dcu_no_inst;
wire	[3:0]	iu_diag_e;
wire		smu_ld;
wire		smu_st;
wire		ld_st_e;
wire		ld_st_c;
wire		iu_ld_c;
wire		iu_st_c;
wire		smu_ld_c;
wire		smu_st_c;
wire		iu_nc_c;
wire		non_cacheable_e;
wire		zeroline_c;
wire	[2:0]	iu_flush_c;
wire		iu_ld_st_c;
wire		smu_ld_st_c;
wire		smu_ld_st;
wire		iu_anyinst_e;
wire		iu_anyinst_e_smu;
wire	[7:0]	iu_inst_e;
wire	[3:0]	smu_inst_e;
wire		iu_ready;
wire		smu_ready;
wire		iu_miss_stall_valid;
wire		smu_miss_stall_valid;
wire		iu_miss_stall_set;
wire		smu_miss_stall_set;
wire		iu_miss_sustain;
wire	[7:0]	new_iu_inst_e;
wire	[7:0]	iu_inst_valid_e;
wire		iu_oppend_c;
wire		iu_sign_c;
wire	[1:0]	iu_size_c;
wire	[1:0]	iu_size_e;
wire		smu_miss_sustain;
wire	[3:0]	new_smu_inst;
wire	[3:0]	smu_inst_valid_e;
wire		new_zeroline_e;
wire	[2:0]	new_flush_e;
wire	[3:0]	new_diag_e;
wire		wr_byte;
wire		wr_word;
wire		wr_short;
wire		wr_oppend;
wire		smu_wr_miss;
wire		iu_wr_miss;
wire		word_we;
wire	[3:0]	hit_we;
wire	[6:0]	align_inst;
wire	[1:0]	align_smu_inst;
wire	[1:0]	algn_addr;
wire	[1:0]	algn_size;
wire		algn_sign;
wire		algn_oppend;
wire		algn_iu_ld;
wire		algn_byte;
wire		algn_short;
wire		iu_miss_ld;
wire		smu_miss_ld;
wire		algn_word;
wire		iu_st_pending;
wire		smu_st_pending;
wire		iu_st_pending_set;
wire		smu_st_pending_set;
wire		algn_smu_ld;
wire		iu_flush_cmp_c;
wire		iu_flush_index_c;
wire		iu_flush_inv_c;
wire		iu_ld_e;
wire		iu_st_e;
wire		iu_nc_e;
wire		iu_oppend_e;
wire		iu_sign_e;
wire		tag_st_rdy_e;
wire		tag_st_rdy_e_in;
wire		tag_ld_rdy_e;
wire		ram_st_rdy_e;
wire		ram_ld_rdy_e;
wire	[2:0]	iu_flush_e;
wire		first_fill_cyc_d1;
wire		ms_byte;
wire		ms_word;
wire		iu_nc_e_raw;
wire		smu_nc_e;
wire		smu_nc_c;
wire		noncacheable_c2;
wire		ms_short;
wire		diagnostic_c;
wire		diagnostic_e;
wire		diag_ld_c ;
wire		iu_inst_c_vld;
wire		iu_miss_sustain_d1;
wire		iu_zero_e;
wire		any_store_c;
wire		smu_stall_st;
wire		iu_miss_stall_ld;
wire		int_pwrdown;
wire		set_pwrdown;
wire		mem_error;
wire		io_error;
wire		async_err;
wire		raw_iu_ld_e;
wire		smu_na_st_miss_cyc;
wire		iu_na_st_c;
wire		iu_na_st_e;
wire  		smu_na_st_miss_c,smu_na_st_miss_c1;
wire 		iu_valid_c,smu_miss_stall_sel,smu_recirculating_c;
wire	[2:0]	dcu_perf_mon;
wire		iu_miss_stall_sel;
wire		iu_recirculating_e;
wire		iu_recirculating_c;
wire		ram_st_rdy_e_in;
wire		zeroline_c_raw,non_cacheable_c_vld,cache_miss,qualify_miss,stall_pipe;




// Need to store cache enable/disable for a transaction.
// This way, we take care of situation when iu_psr_dce changes
// in betwn transaction.
// We can merge hardware and software noncacheables.
// ie: iu_psr_dce and nc instructions. that way, both
// will flow thru the control pipe in similar fashion.

// Filtering of Incoming Instructions
// Control signals needed to be squashed when there is an
// outstanding request from the same requestor. 

assign	iu_nc_e_raw     =       iu_raw_inst_e[4] | !iu_psr_dce_raw ;
assign	iu_inst_e[7:0]	={iu_raw_inst_e[7:5],iu_nc_e_raw,iu_raw_inst_e[3:0]}&{8{~squash_iu_inst}}; 
assign	iu_diag_e[3:0]	=	iu_raw_diag_e[3:0]&{4{~squash_iu_inst}};

// nop zeroline inst,flush insts if cache is turned off

assign	diagnostic_e	= iu_diag_e[0] | iu_diag_e[1] | iu_diag_e[2] | iu_diag_e[3] ;
assign	iu_special_e	=	special_raw_e& (iu_psr_dce_raw|diagnostic_e)&~squash_iu_inst; 
assign	iu_zero_e	=	iu_raw_zero_e& iu_psr_dce_raw&~squash_iu_inst; 
assign	iu_flush_index_e =  	iu_raw_flush_index_e & iu_psr_dce_raw&~squash_iu_inst;
assign	iu_flush_cmp_e =  	iu_raw_flush_cmp_e & iu_psr_dce_raw&~squash_iu_inst; 
assign	iu_flush_inv_e	=	iu_raw_flush_inv_e & iu_psr_dce_raw&~squash_iu_inst;

assign	smu_ld		=	smu_raw_ld  ;
assign	smu_st		=	smu_raw_st  ;
assign	smu_nc_e	=      !iu_psr_dce_raw ;


// IU requests are squashed if there is a smu_prty signal. Because, whenever
// smu gets priority, we ignore IU requests.
// since smu_prty is timing critical, we only disable ram,tag and stat we .
// we also dont allow the instruction to move into C stage.
ff_sr	squash_inst_reg	(.out(squash_iu_inst),
			.din(smu_prty),
			.clk(clk),
			.reset_l(reset_l));


// Decoding of Instructions

assign	iu_ld_st_e	=  iu_ld_e  | iu_st_e 	;
assign	ld_st_e		=  iu_ld_e | iu_st_e | smu_ld | smu_st   ;
assign	ld_st_c		=  iu_ld_c | iu_st_c |  smu_ld_c | smu_st_c ;
assign	normal_ack	=  !biu_dcu_ack[1] & biu_dcu_ack[0];
assign	error_ack	=   biu_dcu_ack[1] ;
assign	store_c		=  (smu_st_c & !smu_nc_c| iu_st_c& !iu_nc_c )&!fill_cyc_active ;
assign	any_store_c	=	smu_st_c |  iu_st_c ;
assign	miss_store	=  iu_miss_inst[3] | smu_miss_inst[1] ;
assign	nc_xaction 	=  !dc_idle&(iu_miss_inst[4]&(iu_miss_inst[3] | iu_miss_inst[2]) | 
			   iu_miss_inst[7]&iu_miss_inst[3]		|	// Nonallocating store
			   smu_miss_inst[2]&(smu_miss_inst[1] | smu_miss_inst[0])) ; 
assign  non_cacheable_c_vld =  iu_ld_st_c& iu_nc_c | smu_ld_st_c & smu_nc_c;
assign	non_cacheable_c = (iu_ld_c|iu_st_c)&iu_nc_c | smu_ld_st_c&smu_nc_c;
assign	non_cacheable_e	=  iu_nc_e | smu_nc_e ;		// what if standby is high

// iu_valid_c only applies to iu_ld_st_c, however, since other instructions will not cause "trap", we simply
// use the dont care for logic minimization. 
assign  iu_req_c = ( iu_ld_c | iu_st_c | zeroline_c_raw | iu_flush_c[2] | iu_flush_c[0] | iu_flush_c[1] );
assign  smu_req_c = smu_st_c | smu_ld_c;
assign  dc_inst_c =  iu_req_c | smu_req_c;


assign  iu_inst_c_vld   =       iu_ld_c | iu_st_c | zeroline_c_raw | iu_flush_c[0] | iu_flush_c[1] | iu_flush_c[2] | diagnostic_c ;
assign	iu_ld_st_c	=	(iu_ld_c | iu_st_c )&iu_valid_c;
assign	smu_ld_st_c	=	smu_ld_c | smu_st_c ;
assign	smu_ld_st	=	smu_ld | smu_st ;
assign	iu_anyinst_e	=   iu_ld_st_e | special_raw_e ;
// Created this signal just to prevent smu_stall from getting asserted incase
// of smu_hold and any special insturction in E-stage

assign	iu_anyinst_e_smu =   iu_ld_st_e | iu_special_e ;

// Since we introduced non_allocating store , dc_idle will be true even
// a line replacement is going on. 
assign	req_outstanding =  !wb_idle | !dc_idle | repl_busy | smu_na_st_miss_cyc;

// we need req_outstanding so that only if there are no pending requests, the nc store is 
// dispatched. 
// convert Non-allocating store into noncacheable instruction on a cache miss.
assign	nc_write_c 	=  (smu_st_c & smu_nc_c | iu_st_c & iu_valid_c&(iu_nc_c | iu_na_st_c&dcu_miss_c) ) & !req_outstanding;

assign	diagnostic_c	= iu_diag_c[0] | iu_diag_c[1] | iu_diag_c[2] | iu_diag_c[3] ;
assign	iu_flush_e[2:0] =  {iu_flush_inv_e,iu_flush_cmp_e,iu_flush_index_e} ;

assign	diag_ld_c	=	iu_diag_c[0] | iu_diag_c[2] ;
assign	iu_ld_e		=	iu_inst_e[2];
assign	iu_st_e		=	iu_inst_e[3];
assign	iu_nc_e		=	iu_inst_e[4];
assign	iu_oppend_e	=	iu_inst_e[6];
assign  iu_na_st_e      =       iu_inst_e[7];    
assign	iu_size_e[1:0]	=	iu_inst_e[1:0];
assign	iu_sign_e	=	iu_inst_e[5];


 
assign	dcu_no_inst	= !req_outstanding &!stall_valid & !dc_inst_c &!repl_busy&!zeroline_busy& reset_l;
assign	ram_st_rdy_e_in	=	iu_diag_e[3] & dcu_no_inst;
assign	ram_ld_rdy_e	=	iu_diag_e[2] & dcu_no_inst;
assign	tag_st_rdy_e_in	=	iu_diag_e[1] & dcu_no_inst;

// Used to generate tag write enables
assign	tag_st_rdy_e	=	tag_st_rdy_e_in &~smu_prty;
assign	ram_st_rdy_e	=	ram_st_rdy_e_in &~smu_prty;

assign	tag_ld_rdy_e	=	iu_diag_e[0] & dcu_no_inst;
assign	diag_rdy_e	=	ram_st_rdy_e_in | tag_st_rdy_e_in | ram_ld_rdy_e | tag_ld_rdy_e;


assign  smu_inst_e[3:0] = { (smu_na_st&~smu_nc_e),smu_nc_e,smu_st,smu_ld} ;
assign	raw_iu_ld_e	=	iu_raw_diag_e[2] | iu_raw_diag_e[0] | iu_raw_inst_e[2] ;

/*******************************  Pipeline Flow of Instructions ***********************************/
// Instructions come to the DCU in the E stage. They go thru C and C2 stages.
// Trap is used in C stage to cancel instruction.
// When in Error state, the instruction is squashed from miss state register.
// If an instruction is ready to be executed, it passes into the C stage.
// In the C stage, if there is a miss and no outstanding request, the inst moves into the miss inst
// reg. If there already exists an outstanding request, the inst moves into miss stall reg. on a 
// store hit, the inst moves into the C2 register. Data is written into the cache in C2 stage.

// Priority of Functions in DCU
//1. Replace Dirty line
//2. Cache fill Data
//3. Store hit in C stage
//4. Missed Stalled Instruction - another miss during a miss
//5. IU ld/st inst in E
//6. SMU ld/st inst in E
//9. write buffer complete
//10. flush,Zeroline inst,diagnostic read/writes


// IU ld/st/flush ready to goto C stage
// Valid IU ld/st inst  in C stage 
// Do not dispatch a IU ld/st inst if
// a.	replacing a dirty line, 
// b. 	cache fill cycle
// c.	store in C and iu load in E (bubble),
// d. 	cache miss in C stage
// e. 	miss occurs while processing another miss, 
// f.	noncacheable ld or st in E and there is a inst in C or a memory request is outstanding.
// g.	zeroline inst or flush inst in C stage, 
// h. 	special inst in E and there is another inst in C stage or request pending. 
  

// Since iu cannot provide back to back loads or stores , we need to ignore E stage instruction when
// there is a valid iu inst in C stage or a iu inst miss request is being processed.
// This is because, iu_inst_e is recirculated for an extra cycle bcos there is no C stage and we
// dont want to execute the same instruction twice.

assign		iu_ready = !(iu_stall | !reset_l | kill_inst_e ) ;
assign	new_iu_inst_e[7:0]	=  iu_inst_e[7:0] & {8{iu_ready&~smu_prty}} ;
assign  iu_miss_stall_sel = (iu_miss_stall_valid &!req_outstanding | iu_st_pending&!fill_cyc_active );
assign	iu_inst_valid_e[7:0] 	=  (iu_miss_stall_sel) ?
						iu_miss_stall_inst[7:0]:new_iu_inst_e[7:0] ;

assign  iu_recirculating_e =  iu_miss_stall_sel;

ff_s_8   iu_inst_c_reg(	.out(iu_inst_c[7:0]),
        		.din(iu_inst_valid_e[7:0]),
        		.clk(clk));

// kill any instruction which has trapped. also squash any iu load inst which has
// has caused smu hold.

assign  iu_na_st_c     	=  	iu_inst_c[7]&iu_inst_c[3] ; //& !iu_trap_c;
assign  iu_oppend_c     =       iu_inst_c[6] ; // & !iu_trap_c ;
assign  iu_sign_c       =       iu_inst_c[5] ; // & !iu_trap_c ;
assign  iu_nc_c         =       iu_inst_c[4] ; // & !iu_trap_c ;
assign  iu_st_c         =       iu_inst_c[3] ; // & !iu_trap_c ;
assign  iu_ld_c         =       iu_inst_c[2] ; //& !iu_trap_c;
assign  iu_size_c[1:0]  =       iu_inst_c[1:0] ;
 
assign  iu_valid_c      =       !iu_trap_c | iu_recirculating_c ;


// SMU ld/st read to goto C stage
// Do not dispatch a SMU ld/st inst if
// a. 	replacing dirty line.
// b.   cache fill cycle
// b. 	store in C and smu load in E (bubble)
// c. 	Cache miss in C stage
// d.	Miss occurs while another miss is being processed
// f. 	zeroline inst or flush in C stage
// g.	iu inst, flush, zeroline inst , diagnostic read/wr in E stage.
// h.   reset


assign	smu_ready =  !( smu_stall | !reset_l );
assign	new_smu_inst[3:0]=	smu_inst_e[3:0] &{4{smu_ready}} ;
assign	smu_miss_stall_sel = smu_miss_stall_valid&!req_outstanding| smu_st_pending&!fill_cyc_active ;
assign	smu_inst_valid_e[3:0]=	(smu_miss_stall_sel)?
				smu_miss_stall_inst[3:0]:new_smu_inst[3:0];

assign	stall_valid = (iu_miss_stall_valid | smu_miss_stall_valid | iu_st_pending | smu_st_pending ) | fill_cyc_active &any_store_c;

ff_s_4	smu_inst_c_reg(.out(smu_inst_c[3:0]),
			.din(smu_inst_valid_e[3:0]),
			.clk(clk) );

assign	smu_ld_c	= smu_inst_c[0];
assign	smu_st_c	= smu_inst_c[1];
assign	smu_nc_c	= smu_inst_c[2];
assign  smu_na_st_c     = smu_inst_c[3] & smu_st_c;


// signalling SMU completion of store.
// Need to nullify this store with smu_stall_store . This way
// we dont count the store twice.
 assign	dcu_smu_st	= smu_st_c & !smu_stall_st;

ff_sr	smu_stall_store_reg(.out(smu_stall_st),
			.din(smu_miss_stall_valid& smu_miss_stall_inst[1]),
			.clk(clk),
			.reset_l(reset_l));

// Valid zeroline inst in C stage
// Dispatch zeroline inst only if there is no outstanding requests
// to memory and no  ld/st inst in C stage 

assign  new_zeroline_e	= iu_zero_e & dcu_no_inst&~smu_prty&~kill_inst_e ;
ff_s   zeroline_c_reg(.out(zeroline_c_raw),
        .din(new_zeroline_e),
        .clk(clk));
assign	zeroline_c =	zeroline_c_raw&~iu_trap_c;

// valid Flush inst in C stage
// dispatch flush inst only if there is no instruction in C 
// stage and there is no stalled instruction.
assign	new_flush_e[2:0]	= iu_flush_e[2:0] & {3{dcu_no_inst&~smu_prty&~kill_inst_e}};
ff_s_3   	flush_c_reg(.out(iu_flush_c[2:0]),
        .din(new_flush_e[2:0]),
        .clk(clk));

assign	iu_flush_inv_c	= iu_flush_c[2];
assign	iu_flush_cmp_c	= iu_flush_c[1];
assign	iu_flush_index_c= iu_flush_c[0];

// Valid diagnostic ld/st in C stage
// dispatch diagnostic ld/st only if there are no outstanding
// memory requests(miss is being processed) and no inst in C stage
assign  new_diag_e[3:0] = iu_diag_e[3:0] & {4{dcu_no_inst&~smu_prty}};
ff_s_4	diag_c_reg(.out(iu_diag_c[3:0]),
		.din(new_diag_e[3:0]),
		.clk(clk));

assign	dtag_rd_c	=	iu_diag_c[0];


/*********************  Generation of  Miss Instruction *********************/
//When an instruction in C stage misses the cache(not including diags/flushes)
//and there is no outstanding requests to memory, the instruction is moved into
// the miss register. If there is an outstanding request, move the instruction
// into miss_stall register. This would be reexecuted once the older miss has
// been completely processed. We also reexecute a store which is incomplete
// when a cache fill is returned during the execution of first cycle of store.

	
assign	iu_miss_stall_set 	=  iu_ld_st_c & dcu_miss_c & req_outstanding | req_outstanding &iu_miss_stall_valid ;
ff_sr	miss_stall_vld_reg(.out(iu_miss_stall_valid),
			.din(iu_miss_stall_set),
			.reset_l(reset_l),
			.clk(clk));

ff_sre_8	iu_miss_stall_reg(.out(iu_miss_stall_inst[7:0]),
			.din(iu_inst_c[7:0]),  
			.reset_l(reset_l),
			.clk(clk),
			.enable(dcu_miss_c & req_outstanding | iu_st_c&iu_valid_c&fill_cyc_active ));

assign	iu_miss_stall_ld = iu_miss_stall_inst[2]&iu_miss_stall_valid ;

assign  smu_miss_stall_set       =  smu_ld_st_c & dcu_miss_c & req_outstanding | req_outstanding &smu_miss_stall_valid ;
ff_sr   smu_miss_stall_vld_reg(.out(smu_miss_stall_valid),
                        .din(smu_miss_stall_set),
                        .reset_l(reset_l),
                        .clk(clk));

ff_sre_4	smu_miss_stall_reg(.out(smu_miss_stall_inst[3:0]),
			.din(smu_inst_c[3:0]),
			.reset_l(reset_l),
			.clk(clk),
			.enable(dcu_miss_c & req_outstanding  | smu_st_c&fill_cyc_active));



// On a d$ miss for a non-allocate smu store, we take 2 cycles
// to remove the dirty line into the writebuffer and then complete
// the store

assign     smu_na_st_miss_c =  smu_na_st_c&dcu_miss_c&~req_outstanding;
ff_sr	   smu_na_st_miss_reg(
		.out(smu_na_st_miss_c1),
		.din(smu_na_st_miss_c),
		.clk(clk),
		.reset_l(reset_l) );

ff_sr      smu_na_st_miss_c2_reg (
                .out(smu_na_st_fill),
                .din(smu_na_st_miss_c1),
                .clk(clk),
                .reset_l(reset_l) );

// do not accept any new requests during handling na store miss.
assign	 smu_na_st_miss_cyc = smu_na_st_miss_c1|smu_na_st_fill ;


// new one-bit register for recirculating instructions 

ff_sr      iu_reciculating_reg(
		.out( iu_recirculating_c),
		.din( iu_recirculating_e),
		.clk(clk),
		.reset_l(reset_l) );

ff_sr      smu_reciculating_reg(
                .out( smu_recirculating_c),
                .din( smu_miss_stall_sel),
                .clk(clk),
                .reset_l(reset_l) );
 



 
ff_sre_8	iu_miss_reg(.out(iu_miss_inst[7:0]),
		.din(iu_inst_c[7:0]),
		.reset_l(reset_l),
		.clk(clk),
		.enable(!req_outstanding ));

assign	iu_miss_ld	= 	iu_miss_inst[2] ;
assign	smu_miss_ld	=	smu_miss_inst[0];

ff_sre_4  smu_miss_reg(.out(smu_miss_inst[3:0]),
                        .din(smu_inst_c[3:0]),
			.reset_l(reset_l),
                        .clk(clk),
                        .enable(!req_outstanding));

/************  Store Pending Control ******************************/
// A store hit takes 2 cycles to complete. if after the first cycle,
// there is a cache fill from memory, we need to complete cache fill first
// and then complete the pending store.

// if there is store which misses the cache and there
// is a cache fill happening, we consider it a missed store and raise stall.
// we should not raise store pending. this should be done only for store hits.

// store pending could also happens for non_allocating store 
//
assign  iu_st_pending_set  =  iu_st_c &iu_valid_c&dcu_hit_c&fill_cyc_active|
			      iu_st_pending&fill_cyc_active ;
ff_sr    iu_pending_reg(.out(iu_st_pending),
                        .din(iu_st_pending_set),
			.reset_l(reset_l),
                        .clk(clk));


assign  smu_st_pending_set  =  smu_st_c &dcu_hit_c&fill_cyc_active|
			       smu_st_pending&fill_cyc_active ;

ff_sr    smu_pending_reg(.out(smu_st_pending),
                        .din(smu_st_pending_set),
                        .reset_l(reset_l),
                        .clk(clk));

/************ Cache Fill word offset calculation ******************/

ff_sre		nc_c2_reg(.out(noncacheable_c2),
			.din(non_cacheable_c_vld | iu_na_st_c&dcu_miss_c&iu_valid_c),
			.clk(clk),
			.reset_l(reset_l),
			.enable(dcu_miss_c&!req_outstanding));

assign	fill_byte	= (noncacheable_c2)?cf_addr[1:0]:2'b0 ;

/******************************************************************************/

// Need to stall the pipe till the requested data is returned during miss handling.
assign	iu_miss_sustain = 	miss_wait&(iu_miss_inst[3] | iu_miss_inst[2]);
assign	smu_miss_sustain =	miss_wait &(smu_miss_inst[1] | smu_miss_inst[0]) ;

ff_sr		miss_sustain_reg(.out(iu_miss_sustain_d1),
				.din(iu_miss_sustain&iu_miss_ld),
				.clk(clk),
				.reset_l(reset_l));

 
// fill data can be written into the cache if there is no valid ld/st in E stage or
// store in C stage. Also if there is missed stall condition, filldata can be written.

 
/*************** For Generation of pj_type ****************************/
//	dc_type	    BIT 0	    BIT  1
//	Bits
//	_________________________________________
//	|  0	|    Load	|   Store	|
//	|_______|_______________|_______________|
//	|  1	|   Cacheable	|  Noncacheable	|
//	|_______|_______________|_______________|
//	|  2	|   Icache	|   Dcache	|
//	|_______|_______________|_______________|
//	|  3	|     - 	|   Dribble	|
//	|_______|_______________|_______________|
//


assign	dcu_type[0] =  wb_req ;
assign  dcu_type[1] =  iu_miss_inst[4]&(iu_miss_inst[3] | iu_miss_inst[2])
		|	iu_miss_inst[3]&iu_miss_inst[7]
        	|      smu_miss_inst[2] &(smu_miss_inst[1] | smu_miss_inst[0]);
assign	dcu_type[2] =  dc_req | wb_req ;
assign	dcu_type[3] =  smu_miss_inst[1] | smu_miss_inst[0] ;

// Generation of Dcache request
assign	 dcu_req   =  dc_req | wb_req ;

// Size of request
assign	dcu_size   = (iu_miss_inst[3]|iu_miss_inst[2])?iu_miss_inst[1:0]:2'b10 ;

/*************   Merge data selects   ******************************/
// Various Scenarios
// write data to be merged --> w3 w2 w1 w0 (each 1 byte)
// cache fill data         --> c3 c2 c1 c0 (each 1 byte)
//
//      c3 c2 c1 c0     No data merge
//      w0 c2 c1 c0     store byte in loc 0
//      c3 w0 c1 c0     store byte in loc 1
//      c3 c2 w0 c0     store byte in loc 2
//      c3 c2 c1 w0     store byte in loc 3
//      w1 w0 c1 c0     store half word in loc 0
//      w0 w1 c1 c0     store half word in loc 0 - opp endianness
//      c3 c2 w1 w0     store half word in loc 1
//      c3 c2 w0 w1     store half word in loc 1 - opp endianness
//      w3 w2 w1 w0     store word
//      w0 w1 w2 w3     store word - opp endianess

// how do we deal with noncacheable insts?(same as others except bypass cache)
assign	wr_byte		=  !iu_inst_c[1] & !iu_inst_c[0] ;
assign	wr_short	=  !iu_inst_c[1] & iu_inst_c[0] ;
assign	wr_word		=  iu_inst_c[1] & !iu_inst_c[0] ;
assign	wr_oppend	=  iu_inst_c[6] ;

// select swap_data[31:24]
assign	swap_sel_31_24[2] =     smu_st_c | (iu_st_c & wr_word & !wr_oppend)  ;	
assign	swap_sel_31_24[1] =     (iu_st_c&wr_short&!wr_oppend)  ;	
assign	swap_sel_31_24[0] =    !swap_sel_31_24[2] & !swap_sel_31_24[1] ;	

// select swap_data[23:15]
assign	swap_sel_23_16[2] =	smu_st_c | (iu_st_c & wr_word & !wr_oppend)  ; 
assign	swap_sel_23_16[1] =	(iu_st_c&(wr_word&wr_oppend | wr_short&wr_oppend))  ;
assign	swap_sel_23_16[0] =	!swap_sel_23_16[2] & !swap_sel_23_16[1] ;

// select swap_data[15:8]
assign	swap_sel_15_8[2] =	(iu_st_c& wr_oppend & wr_word )  ;
assign	swap_sel_15_8[1] =	smu_st_c | (iu_st_c&!wr_oppend&(wr_word | wr_short)) ;
assign	swap_sel_15_8[0] =	!swap_sel_15_8[2] & !swap_sel_15_8[1];

// select swap_data[7:0]
assign	swap_sel_7_0[2] =   	(iu_st_c & wr_oppend & wr_word ) ;
assign	swap_sel_7_0[1] =	(iu_st_c & wr_oppend & wr_short) ;
assign	swap_sel_7_0[0] =	!swap_sel_7_0[2] & !swap_sel_7_0[1] ;
				


/************************ Generate Merge Data Mux selects ***************************/

assign	smu_wr_miss	=  smu_miss_inst[1];
assign	iu_wr_miss	=  iu_miss_inst[3];
assign	ms_byte		=   !iu_miss_inst[1] & !iu_miss_inst[0] ;
assign  ms_short        =  !iu_miss_inst[1] & iu_miss_inst[0] ;
assign  ms_word         =  iu_miss_inst[1] & !iu_miss_inst[0] ;

// select 31:24 of fill_data or swap data 
assign	merge_sel[3]	=	smu_na_st_fill | first_fill_cyc&(smu_wr_miss | iu_wr_miss&(ms_word |
				ms_short&!cf_addr[1] | ms_byte&(cf_addr[1:0] == 2'b00 )));

// select 23:16 of filldata or swap data
assign	merge_sel[2]	=	smu_na_st_fill | first_fill_cyc&(smu_wr_miss | iu_wr_miss&(ms_word |
				ms_short&!cf_addr[1] | ms_byte&(cf_addr[1:0] ==2'b01 )));

// select 15:8 of filldata or swap data
assign	merge_sel[1]	=	smu_na_st_fill | first_fill_cyc&(smu_wr_miss | iu_wr_miss&(ms_word |
				ms_short&cf_addr[1] | ms_byte&(cf_addr[1:0] == 2'b10 )));

// select 7:0 of filldata or swap data
assign	merge_sel[0]	=	smu_na_st_fill | first_fill_cyc&(smu_wr_miss | iu_wr_miss&(ms_word |
				ms_short&cf_addr[1] | ms_byte&(cf_addr[1:0] == 2'b11 )));


/*********************** Generate  Write Enables for the Data RAM **********************/
assign	word_we	=		fill_cyc_active&!nc_xaction | ram_st_rdy_e | smu_na_st_fill ;

assign	hit_we[3]	=	smu_st_c&!smu_nc_c| iu_valid_c&iu_st_c&!iu_nc_c&(wr_word | wr_short&!dcu_addr_c[1] | 
				wr_byte&(dcu_addr_c[1:0] == 2'b00) );	
assign	hit_we[2]	=	smu_st_c&!smu_nc_c | iu_valid_c&iu_st_c&!iu_nc_c&(wr_word | wr_short&!dcu_addr_c[1] |
				wr_byte&(dcu_addr_c[1:0] == 2'b01) );
assign	hit_we[1]	= 	smu_st_c&!smu_nc_c | iu_valid_c&iu_st_c&!iu_nc_c&(wr_word | wr_short&dcu_addr_c[1] |
                                wr_byte&(dcu_addr_c[1:0] == 2'b10) );
assign	hit_we[0]	=	smu_st_c&!smu_nc_c | iu_valid_c&iu_st_c&!iu_nc_c&(wr_word | wr_short&dcu_addr_c[1] |     
                                wr_byte&(dcu_addr_c[1:0] == 2'b11) ); 	

assign	dcu_ram_we[3:0]	=   (dcu_hit_c & !fill_cyc_active)   ? hit_we[3:0]  :   {4{word_we}} ;	

// Bypass cache only for noncacheable loads,first fill cycle of lds or erroneous transactions
assign		dcu_bypass	=  first_fill_cyc;


/***************** Sign Select For Aligner *******************************/
// For sign selection, for unsigned loads, higher bits are set to zero.
// For signed loads, higher bits are set to bit 7 or 15 or 23 or 31 depending
// on  addr
 
// 1'b0         -       ld character, unsigned byte
// bit 7        -       load byte, addr[1:0] 11/ load short addr[1] 1 - opp endianness
// bit 15       -       load byte addr1:0] 10 / load short addr[1] 1
// bit 23       -       load byte, addr[1:0] 01/ load short addr[1] 0 - opp endianness
// bit 31       -       load byte addr[1:0] 00 / load short addr[1] 0

ff_sr		fill_cyc_d1reg(.out(first_fill_cyc_d1),
			.din(first_fill_cyc),
			.clk(clk),
			.reset_l(reset_l));

// Need to select which inst is being completed. (miss_inst or inst_c )
assign	align_inst[6:0]		=	(first_fill_cyc_d1)?iu_miss_inst[6:0]:iu_inst_c[6:0];
assign	align_smu_inst[1:0]	=	(first_fill_cyc_d1)?smu_miss_inst[1:0]:smu_inst_c[1:0];
assign	algn_addr[1:0]		=	(first_fill_cyc_d1)?cf_addr[1:0]:dcu_addr_c[1:0] ;

assign	algn_size[1:0]	=	align_inst[1:0] ;	
assign	algn_sign	=	align_inst[5];
assign	algn_oppend	=	align_inst[6];
assign	algn_iu_ld	=	align_inst[2];
assign	algn_byte	=  	!algn_size[1]&!algn_size[0] ;
assign	algn_short	=  	!algn_size[1]&algn_size[0] ;
assign	algn_word	=  	algn_size[1]&!algn_size[0] ;
assign	algn_smu_ld	=	align_smu_inst[0];

assign	algn_sign_sel[4]	=	!algn_sign_sel[3]& !algn_sign_sel[2] & !algn_sign_sel[1] &!algn_sign_sel[0] ;

assign	algn_sign_sel[3]	=	algn_iu_ld&(algn_sign&algn_byte&(algn_addr[1:0] == 2'b11) |
					algn_sign&algn_short&algn_oppend&algn_addr[1]) ;

assign	algn_sign_sel[2]	=	algn_iu_ld&(algn_sign &algn_byte&(algn_addr[1:0] == 2'b10) |
					algn_sign &algn_short&!algn_oppend&algn_addr[1]) ;

assign	algn_sign_sel[1]	=	algn_iu_ld&(algn_sign &algn_byte&(algn_addr[1:0] == 2'b01) |
					algn_sign &algn_short&algn_oppend&!algn_addr[1]);

assign  algn_sign_sel[0]	=	algn_iu_ld&(algn_sign &algn_byte&(algn_addr[1:0] == 2'b00) |
					algn_sign &algn_short&!algn_oppend&!algn_addr[1]);

/**************************************************************************/

/******************** Aligner Mux  Selects *************************************/
// D3 D2 D1 D0 -- > 4 bytes of data out of the cache
// Various Scenarios
 
//      d3 d2 d1 d0     load word
//      d0 d1 d2 d3     load word - opp endianness
//      _  _  _  d0     load byte , addr[1:0] 11
//      _  _  _  d1     load byte , addr[1:0] 10
//      _  _  _  d2     load byte , addr[1:0] 01
//      _  _  _  d3     load byte , addr[1:0] 00
//      -  -  d1 d0     load half word, addr[1] 1
//      -  -  d0 d1     load half word, addr[1] 1 , opp endianness
//      -  -  d3 d2     load half word, addr[1] 0
//      -  -  d2 d3     load half word, addr[1] 0 , opp endianness


// algn_sel_7_0 mux selects
assign	algn_sel_7_0[3]	=	algn_iu_ld&(algn_word&algn_oppend | algn_byte&(algn_addr[1:0] == 2'b00) |
				algn_short&!algn_addr[1]&algn_oppend ) ;

assign	algn_sel_7_0[2]	=	algn_iu_ld&(algn_byte&(algn_addr[1:0] == 2'b01) | algn_short& !algn_oppend&
				!algn_addr[1] );

assign	algn_sel_7_0[1]	=	algn_iu_ld&(algn_byte&(algn_addr[1:0] == 2'b10) |algn_short& algn_oppend&
				algn_addr[1]);	

assign	algn_sel_7_0[0]	=	!algn_sel_7_0[3] & !algn_sel_7_0[2] & !algn_sel_7_0[1] ;
			

// algn_sel_15_8 mux selects	
assign	algn_sel_15_8[3] =	algn_iu_ld&algn_short&!algn_addr[1]&!algn_oppend ;

assign	algn_sel_15_8[2] =	algn_iu_ld&(algn_short&!algn_addr[1]&algn_oppend | algn_word&algn_oppend) ;

assign	algn_sel_15_8[1] =	algn_smu_ld | algn_iu_ld&(algn_word&!algn_oppend |
				algn_short&algn_addr[1]&!algn_oppend) ; 
assign 	algn_sel_15_8[0] = 	!algn_sel_15_8[3] & !algn_sel_15_8[2] & !algn_sel_15_8[1] ;


// algn_sel_23_16 mux selects
assign	algn_sel_23_16	=	algn_smu_ld | algn_iu_ld&algn_word&!algn_oppend ;

// algn_sel_31_24 mux select
assign	algn_sel_31_24	=	algn_smu_ld | algn_iu_ld&algn_word&!algn_oppend ;

// aligner size selects
assign	algn_size_sel[1] =	algn_smu_ld | algn_iu_ld&algn_word ;
assign	algn_size_sel[0] =	algn_smu_ld | algn_iu_ld&(algn_word|algn_short );


/****** Error ack generation for iu *************************************************/
// Memory error - ack = 10  ;  I/O error - ack = 11 ;
// error triggered only for reads. erroneous stores silently dropped.
// for smu read errors, both mem and i/o error triggered.

assign	mem_error =  iu_miss_ld&biu_dcu_ack[1] & !biu_dcu_ack[0] ;
assign	io_error  =  iu_miss_ld&biu_dcu_ack[1] &  biu_dcu_ack[0] ;
assign	async_err =  ~iu_miss_ld&biu_dcu_ack[1];

ff_sr_3		error_reg(.out(dcu_err_ack[2:0]),
			.din({async_err,io_error,mem_error}),
			.clk(clk),
			.reset_l(reset_l));

/******* Generation of Powerdown Signal  *********************************************/
// Internal Powerdown of caches when there are no instructions. Powerdown if
//a. no instructions in E stage
//b. no instruction in C stage ( can be more aggressive . (not needed for load hits)
//c. no cache fill cycle
//d. not replacing dirty lines
//e. not executing zeroline instruction.
//f. not when a stalled instruction is present.
//g. there is a pending store.
//h. there is no nonallocate store in progress.

assign	int_pwrdown = !(iu_anyinst_e | smu_ld_st | fill_cyc_active | dc_inst_c | repl_busy | 
			zeroline_busy | smu_na_st_fill | iu_st_pending | smu_st_pending |
		      (smu_miss_stall_valid | iu_miss_stall_valid)&!req_outstanding);

// Active low signal - acts as enable to rams.
assign	dcu_pwrdown  = !(int_pwrdown | dcu_in_powerdown & !(iu_anyinst_e | smu_ld_st )) ;

// When pcsu_powerdown signal is  recd from PCSU, wait till no inst in E and beyond and then
// go into powerdown.
 
assign  set_pwrdown = pcsu_powerdown&dcu_no_inst &!(iu_anyinst_e | smu_ld_st) |
			 dcu_in_powerdown&!(iu_anyinst_e | smu_ld_st ) ; 

ff_sr           pwrdown_reg (.out(dcu_in_powerdown),
                        .din(set_pwrdown),
                        .clk(clk),
                        .reset_l(reset_l) );


/*************************************************************************************/

// we have separate stall and data valid signals bcos, there are some cases where
// iu_stall = 1 and data valid = 1. but,in general, if iu_stall=1 data valid = 0;
// scenario 1: if there a cache fill going on, and the cycle before data is
// back, we process another load request and it is a cache hit. data is back
// in the cycle cache fill is taking place. thus,we cant service any new 
// requests but, data is available. 
// scenario 2: if there is a ld cache hit followed immediately by ld miss,
// stall goes up in the second cycle and data is not being latched.
// thus we need two signals. iu_stall and iu_data_vld
// iu_data_vld is used to latch data from DCU into W stage of IU.
// iu_stall is used exclusively for holding new instructions flowing into the dcu.
// we squash iu_stall when there is a data valid signal .
// squash_inst and stall out of sync. 
// no need for data valid signal. stall is asserted only for loads
// or an iu inst coming to dcu while dcu is processing a miss.
// dcu-smu-iu hold : for this to happen, iu issues a ld/st to dcu and in the same cycle,
// there is a smu-hold. to avoid this deadlock, dcu services the ld/st from iu and changes
// priority to smu. but, data of the ld is lost by iu bcos it doesnt use data_vlds.
// so, for loads, we redo the instruction by asserting stall for an extra cycle..

// ****************************************************************************************************

wire stall_pipe0,stall_pipe1,special_c ;
assign	cache_miss	= !(dcu_hit0|dcu_hit1);
assign	iu_stall	=  cache_miss&qualify_miss | stall_pipe; //bubble betn store followed by load
assign	qualify_miss	=  iu_ld_c | iu_anyinst_e&dc_inst_c;
assign	stall_pipe0	=  iu_ld_c&iu_nc_c|
			   iu_miss_ld & iu_miss_sustain |       // load waiting for data
                           iu_miss_stall_ld             |       // load waiting for data
			   squash_iu_inst ;

assign stall_pipe1      =  iu_anyinst_e& special_c |
			   special_raw_e&(req_outstanding | dc_inst_c) ;

assign special_c = 	non_cacheable_c | repl_busy |fill_cyc_active|
                           stall_valid | zeroline_c_raw |  smu_na_st_miss_cyc |
                           zeroline_busy | iu_flush_cmp_c | iu_flush_index_c |iu_flush_inv_c ;

assign stall_pipe = iu_ld_e & store_c | stall_pipe0 | stall_pipe1 ;

			 
assign	iu_data_vld	= dcu_hit_c & iu_ld_c& !iu_nc_c &iu_valid_c | iu_miss_ld&first_fill_cyc_d1| diag_ld_c ;
assign	smu_data_vld	= dcu_hit_c & smu_ld_c&!smu_nc_c   | smu_miss_ld&first_fill_cyc_d1 ;
 
assign smu_stall        =cache_miss&dc_inst_c    |       // SMU inst misses in C stage
			non_cacheable_c		|	// noncacheable instruction in C stage
                        smu_miss_sustain         |      // miss cycle in progress
                        smu_ld & any_store_c         |      // bubble betwn store followed by load
                        stall_valid     |		// there is a miss pending
                        smu_ld_st & (repl_busy | smu_na_st_miss_cyc)  |	// replacing dirty line or na store
			fill_cyc_active |			// cache fill occurring
                        zeroline_c   |				// zeroline inst execution
			zeroline_busy |
                        iu_anyinst_e_smu  | 
			smu_prty&~squash_iu_inst |	// Hold smu for one cycle during smu_hold- timing reason
                        iu_flush_inv_c | iu_flush_cmp_c | iu_flush_index_c       ;
 

// Performance Monitors:

assign	dcu_perf_mon[0]	=	dc_inst_c&~iu_recirculating_c&~smu_recirculating_c;	// D$ accesses
assign	dcu_perf_mon[1]	=	smu_st_c&~smu_recirculating_c;	// SMU D$ stores
assign	dcu_perf_mon[2]	=	smu_ld_c&~smu_recirculating_c;	// SMU D$ loads

ff_sr_3		dcu_perf_reg(.out(dcu_perf_sgnl[2:0]),
				.din(dcu_perf_mon[2:0]),
				.clk(clk),
				.reset_l(reset_l));
endmodule

