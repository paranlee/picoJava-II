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



module dcudp_cntl (
		word_addr,
		dcu_tag_we,
		dcu_stat_we,
		dcu_stat_out,
		dcu_tag_sel,
		arbiter_sel,
		dcu_miss_c,
		dcu_hit_c,
		dc_addr_sel,
		flush_inst_c2,
		flush_inst_c_or_c1,
		flush_set_sel,
		stat_addr_sel,
		latch_cf_addr,
		req_addr_sel,
		latch_wb_addr,
		latch_addr_c,
		repl_start,
		latch_wr_data,
		dc_data_sel,
		dcu_dout_sel,
		dcu_set_sel,
		wb_set_sel,
		dcu_bank_sel,
		diag_stat_bits,
		

//		INPUTS
		iu_req_c,
		smu_req_c,
		iu_valid_c,
		store_c,
		diagnostic_c,
		iu_flush_inv_c,
		iu_flush_cmp_c,
		iu_flush_index_c,
		req_outstanding,
		non_cacheable_c,
		zeroline_cyc,
		zeroline_c,
		dc_req,
		wb_req,
		miss_store,
		nc_xaction,
		dc_idle,
		special_e,
		iu_ld_st_e,
		tag_st_rdy_e,
		diag_rdy_e,
		first_fill_cyc,
		fill_cyc_active,
		nc_write_cyc,
		last_fill_cyc,
		dc_wr_cyc123,
		dtg_stat_out,
		stall_valid,
		repl_busy,
		dcu_hit0,
		dcu_hit1,
		misc_din,
		dc_inst_c,
		smu_na_st_fill,
		iu_na_st_c,
		iu_addr_e_31,
		dcu_addr_c_2,
		dcu_addr_c_31,
		iu_addr_e_2,
		cf_addr,
		clk,
		reset_l,
		sm,	
		so,
		sin
		);


output		[1:0]	word_addr;	// Selects 32 bit word out of the cache line
output			dcu_tag_we ;	// Write Enable to the tags
output		[4:0]	dcu_stat_we;	// Write Enable for status bits
output		[4:0]	dcu_stat_out;	// Status bits to be written into ram
output			arbiter_sel;	// arbitrates requests from smu and iu.
output			latch_addr_c;	// latch addr/data in C on a cache miss/replacing dirty line.
output			flush_inst_c2;	// flush inst was in C stage 2 cycles back (used for starting wb)
output			flush_inst_c_or_c1;	// flush inst in C or C1 stage
output			flush_set_sel;	// set that needs to be flushed.
output			dcu_miss_c;	// Cache miss due to tag mismatch in C stage
output			dcu_hit_c;	// cache  hit due to tag match - should not match for NC insts ?
output		[3:0]	dc_addr_sel;	// select addr input to the dcache ram
output	                stat_addr_sel;	// select status reg addr input 
output	                latch_cf_addr;	// latch cache fill addr 
output	                req_addr_sel;	// select address for memory request
output	                latch_wb_addr;	// Clock enable to latch writeback addr
output			repl_start;	// start the replace dirty line state machine
output			latch_wr_data;	// latch data in C stage into write miss reg on cache miss
output         [3:0]    dc_data_sel;	// select data input to the dc ram.
output               	dcu_dout_sel;	// select data to be sent to memory for write transactions.
output			dcu_set_sel;	// select set for writes into tag
output			wb_set_sel;	// select tag of address to be written back to memory
output	       [1:0]	dcu_bank_sel;	// select bank for writes into dcram
output	       		dcu_tag_sel;	// select input to tag ram
output	  	[2:0]	diag_stat_bits;	// Status bits for a diagnostic read access of tag ram
output			dcu_addr_c_31;	


input			iu_valid_c;     // iu valid instruction at c stage,if any.
input		[1:0]	cf_addr;	// Part of address used to access word out of cache line
input			repl_busy;	// currently replacing dirty line into writebuffer
input			req_outstanding;// there is a memory request outstanding
input			non_cacheable_c;// Non cacheable inst in C stage
input			zeroline_cyc;	// Zeroline inst last cycle
input			zeroline_c;	// zeroline inst in C stage
input			iu_flush_cmp_c;	// flush inst in C stage
input			iu_flush_inv_c;	// flush invalidate inst in C stage
input			iu_flush_index_c;// flush inst in C stage
input			dc_req;		// cache miss request sent to memory
input			wb_req;		// writeback request
input			dc_inst_c;	// valid instruction in C stage
input			iu_req_c;
input			smu_req_c;
input			iu_na_st_c;	// Nonallocating IU store
input 			smu_na_st_fill; // smu na_store  missed cache. this cycle
					 // the store data is written into the $line.
input			miss_store;	// Missed instruction is a store
input			nc_xaction;	// current transaction is a noncacheable one
input			dc_idle;	// Miss state machine is in idle state
input			stall_valid;	// miss occurred while processing another miss
input			iu_ld_st_e ;	// Valid iu Load/store in E stage
input			special_e;	// valid special inst like zeroline,diag,flush in E stage
input			tag_st_rdy_e;	// diagnostic tag store ready to be executed in E 
input			diag_rdy_e;	// diagnostic inst ready to be executed in E 
input			first_fill_cyc;	// First word to be filled into the cache
input	                fill_cyc_active;// currently filling up the cache with cache fill data
input	                last_fill_cyc;	// Last word of the file line being written into cache
input			nc_write_cyc;	// Noncacheable write transaction
input	                dc_wr_cyc123;	// first 3 cycles of fill data being written into cache 
input			diagnostic_c;
input	[4:0]		dtg_stat_out;	// status bits from the tag ram

input			store_c;	// Store instruction in C stage
input			iu_addr_e_31;	// for diagnostic writes into status register
input	[2:0]		misc_din;	// for diagnostic writes into status register
input			iu_addr_e_2;	// for selecting set
input			dcu_addr_c_2;	// for selecting set
input			dcu_hit0;	// line in set 0 -- noncacheable inst should not generate hit*****
input			dcu_hit1;	// line in set 1
input			clk;		// clock
input			reset_l;		// Reset
output			so ;		// Scan Out
input			sin ;		// Scan In
input			sm;		// Scan Enable


wire	[4:0]	addr;
wire	[4:0]	addr_next;
wire		valid_flush;
wire		dcu_set_sel_d1;
wire		flush_inst_c,flush_inst_c1,flush_inst_c2;
wire		flush_inst_c_or_c1;
wire		valid0,valid1,dirty0,dirty1,lru_bit;
wire		dcu_hit0_c,dcu_hit1_c;
wire		write_set_sel;
wire		diag_bank_sel;
wire	[4:0]	set_mux_sel;
wire		fill_set_sel,fill_set_sel_d1,fill_bank_sel;
wire		last_cyc;
wire		flush_set_sel;
wire		flush_set_sel_d1;
wire		flush_set;
wire		diag_set;
wire		flush_index_set;
wire		default_set;
wire		repl_line_inv;

wire		qualify_miss,cache_miss;
wire		qualify_miss_int;
wire		dcu_miss_c_int;


wire		dcu_hit;

// invalidate the line immediately follow the miss so that
// subsequent store/load will not asynchrously use it as a hit line



assign	flush_inst_c	=  iu_flush_inv_c | iu_flush_cmp_c | iu_flush_index_c ;
assign	flush_inst_c_or_c1 = flush_inst_c | flush_inst_c1 ;
ff_sr_2		flush_inst_c2_reg(.out({flush_inst_c2,flush_inst_c1}),
				.din({flush_inst_c1,flush_inst_c}),
				.clk(clk),
				.reset_l(reset_l));

//**** Generation of Mux Selects for Addr datapath ***/

// Recirculate dcu_addr if there is a miss, or dirty line needs to be replaced or there is a ack in the 2nd cycle of
// of a store hit. (store takes 2 cycles to complete)
// Select smu  if there no iu ld/st requests and no cache fill ack returned or no cache miss in C stage
// For flush instructions, we take 2 cycles if there  is a dirty line even it is not a hit. 
 
assign  arbiter_sel =     iu_ld_st_e | special_e  ;

assign	latch_addr_c =   !( dcu_miss_c | repl_busy | stall_valid |  flush_inst_c & iu_valid_c ) ;


// if there is a cache miss or dirty line needs to be replaced or a miss occurs while there is a mem req outstanding 
// select the dcu_addr_c. For cache line fills, use  cf_addr. else in normal cases use dcu_addr_e
// select addr_c for first cycle of replacing old line since it is not yet latched into the cf addr reg.


// stalled store writing to incorrect address. smu store in C coincides with fillcycactive.
// thus stall_valid is high. after fill_cyc, we reissue the store. But the address used to access the
// tags was incorrect because we squashed stall_valid with req_outstanding. we should use fill_cyc_active.
// We didnt catch this because in most cases, the incorrect tag addr gives tag outputs which cause cache miss
// and we wait till outstanding mem operation is complete before reissuing the store. In this case, the
// incorrect tag addr had the same tag as this store.

assign	dc_addr_sel[3] 	   = 	   (dcu_miss_c_int | stall_valid )&!fill_cyc_active | flush_inst_c |
				   repl_busy ;
assign  dc_addr_sel[2]     =       fill_cyc_active |smu_na_st_fill;
assign	dc_addr_sel[1]	   =	   !dc_addr_sel[2] & !dc_addr_sel[3] & arbiter_sel;
assign	dc_addr_sel[0]	   =	   !dc_addr_sel[3] & !dc_addr_sel[2] &!arbiter_sel;
 

// select immed or delayed  addr for  accessing status ram and data ram
// select immed addr for diagnostic stores and cache fill cycles
// select delayed addr for write hits. in case of fill cycle , use
// the immed addr.
assign stat_addr_sel    =       store_c & dcu_hit_c&!fill_cyc_active ;
 
// Latch dcu_addr_c into the cf addr reg when there is cache miss/NC instructions
// Also latch it for zeroline instructions
// 
assign  latch_cf_addr  =       (zeroline_c & iu_valid_c ) | dcu_miss_c & !req_outstanding ;
 
// select tag to be written into the ram
assign  dcu_tag_sel     =       first_fill_cyc | smu_na_st_fill;

// Select address to be sent for memory request
// selects cachefill addr during cache fill process/noncacheable request
 assign req_addr_sel     =       !dc_idle & !wb_req ;
// assign req_addr_sel     =       !dc_idle ;

// The clock enable determines if there is a line to be replaced.
// replace line if both entries of a set are valid and the least recently
// used entry is a dirty entry.
// Start replacing dirty line if there is a flush to a line which is dirty
// Two kinds of flush: flush_cmp : flush a line only if there is a tag hit.
// flush_index: flush a line based on index. no need to check tags.

assign repl_start = dcu_miss_c & !req_outstanding & !non_cacheable_c &!iu_na_st_c&
                    ( valid0 & dirty0 &!lru_bit| valid1&dirty1&lru_bit) |
			valid_flush ;

assign valid_flush = 	iu_flush_cmp_c& (dirty1&dcu_hit1 | dirty0&dcu_hit0) | 
		iu_flush_index_c&(dirty1&valid1&dcu_addr_c_31 | dirty0&valid0&!dcu_addr_c_31);

assign	latch_wb_addr = repl_busy; 
// in case of diagnostic read outs, select set depending on bit 31 of address bus. for flush
// instruction
assign	wb_set_sel	= (diagnostic_c| flush_inst_c1)?dcu_set_sel_d1:fill_set_sel_d1;
 

/*******Generation of Mux selects and clock enables for Data path ******/
 
// arbiter selects are same for addr path and data path

// Clock enable to latch data on write miss

assign  latch_wr_data =   dcu_miss_c & ! req_outstanding ;

 
// Mux select for selecting $fill, write data, zeroes or diagnostic bus
assign  dc_data_sel[3]  =       zeroline_cyc ;
assign  dc_data_sel[2]  =       diag_rdy_e  ;
assign  dc_data_sel[1]  =       fill_cyc_active&!zeroline_cyc | smu_na_st_fill;
assign  dc_data_sel[0]  =       !dc_data_sel[3] & !dc_data_sel[2] & !dc_data_sel[1] ;
 
// select data to be sent out to memory
// for noncacheable insts, send directly to memory. for wb transactions send data from write buffer
assign  dcu_dout_sel    =  nc_write_cyc ;

/**************************************************************************/


// Status Register -    _________________________________________
//                      | LRU   |  D1   |  V1   |  D0   |  V0   |
//                      |_______|_______|_______|_______|_______|
 
assign lru_bit  = dtg_stat_out[4] ;
assign  dirty1  = dtg_stat_out[3] ;
assign  valid1  = dtg_stat_out[2] ;
assign  dirty0  = dtg_stat_out[1] ;
assign  valid0  = dtg_stat_out[0] ;


// Cache hit Calculation
assign  dcu_hit   = dcu_hit0 | dcu_hit1;
 
assign  dcu_hit_c = dc_inst_c&dcu_hit;
assign	dcu_hit0_c = dcu_hit0&dc_inst_c ;
assign	dcu_hit1_c = dcu_hit1&dc_inst_c ;


assign	cache_miss = !(dcu_hit0|dcu_hit1);
assign	qualify_miss = iu_req_c&!flush_inst_c&iu_valid_c| smu_req_c ;
assign	dcu_miss_c =  (cache_miss| non_cacheable_c)&qualify_miss ;


assign	qualify_miss_int = iu_req_c&!flush_inst_c | smu_req_c ;
assign	dcu_miss_c_int = (cache_miss | non_cacheable_c)&qualify_miss_int;


// select set into which data is to be written into for cache fill operation
// or during replacing dirty line or during diagnostic writes
// new set_sel value is loaded when  there is a  cache miss and no outstanding
// transaction
// lru bit indicates the most recently written set. so, to replace we use 
// value of lru.

// Since we are using interleaving sets, we need to change set selection as
// shown below.

//  Set 1 and 0 are interleaved between two banks as shown below.
//		________________
//		|  S1_O	|  S0_0	|
//		|_______|_______|
//		|  S0_1	|  S1_1	|
//		|______	|_______|
//		|  S1_2	|  S0_2	|
//		|_______|_______|
//		|  S0_3	|  S1_3	|
//		|_______|_______|
//

// if there is a d$ miss and one of the valid,non-dirty lines is being
// replaced, that line needs to be invalidated immediately. this prevents a following
// store to write to that location.
// Thus, whenever there is a d$ miss on a cacheable transaction and a valid line needs to
// be replaced , invalidate the line immediately.
 
assign  repl_line_inv   = dcu_miss_c&~req_outstanding&~non_cacheable_c&~flush_inst_c&~iu_na_st_c;
 

///***  Tag Set Selects   ****/

// Tag select - For cache fill operations (zeroline and normal cache fill cycles )
assign	fill_set_sel =	(zeroline_c&dcu_hit)?dcu_hit1:lru_bit ;
ff_sre		tag_set_reg(.out(fill_set_sel_d1),
			.din(fill_set_sel),
			.clk(clk),
			.reset_l(reset_l),
			.enable(!req_outstanding ) );	

assign	diag_set	= iu_addr_e_31 ;
assign	flush_index_set	= dcu_addr_c_31;
assign	default_set	= dcu_hit1  	;

mux5		dcu_set_sel_mux(.out(dcu_set_sel),
				.in4(lru_bit),
				.in3(fill_set_sel_d1),
				.in2(diag_set),
				.in1(flush_index_set),
				.in0(default_set),
				.sel(set_mux_sel[4:0]));

 
assign	set_mux_sel[4]	=	repl_line_inv;
assign  set_mux_sel[3]  =       fill_cyc_active | repl_busy&!flush_inst_c1 |smu_na_st_fill;
assign  set_mux_sel[2]  =       diag_rdy_e  ;
assign	set_mux_sel[1]	=	iu_flush_index_c;
assign  set_mux_sel[0]  =       !set_mux_sel[2] & !set_mux_sel[1]& !set_mux_sel[3] & !set_mux_sel[4] ;

ff_sr		diag_set_sel_reg(.out(dcu_set_sel_d1),
				.din(dcu_set_sel),
				.clk(clk),
				.reset_l(reset_l));

ff_sr           dcu_addr_c_31_reg(.out(dcu_addr_c_31),
                                .din(iu_addr_e_31),
                                .clk(clk),
                                .reset_l(reset_l));



// For replacing dirty lines, we usually use lrubit except for flush instructions.
// for flush instructions, the set used to flush is ...
assign	flush_set	=	iu_flush_cmp_c&dcu_hit1 | iu_flush_index_c&dcu_addr_c_31 ;
ff_sr		flush_set_sel_reg(.out(flush_set_sel_d1),
				.din(flush_set),
				.clk(clk),
				.reset_l(reset_l));

assign	flush_set_sel = flush_set | flush_set_sel_d1 ;


/**** Select Bank of the DCRAM ******/
// due to set interleaving, bank selects are different from set selects ...
// need to update this mechanism for zeroline inst

assign	fill_bank_sel = (word_addr[0])?!fill_set_sel_d1:fill_set_sel_d1 ;
assign  diag_bank_sel  = iu_addr_e_31&!iu_addr_e_2 | !iu_addr_e_31& iu_addr_e_2 ;
assign  write_set_sel = dcu_hit1&!dcu_addr_c_2 | dcu_hit0&dcu_addr_c_2 ;


assign dcu_bank_sel[0] = !dcu_bank_sel[1];

mux4    dcu_bank_sel_mux(.out(dcu_bank_sel[1]),
                        .in3(fill_bank_sel),
                        .in2(diag_bank_sel),
			.in1(flush_set_sel),
                        .in0(write_set_sel),
                        .sel(set_mux_sel[3:0]));


// ** Generation of Status bits for diagnostic read access of tags **/
assign	diag_stat_bits[2]=	lru_bit;
assign	diag_stat_bits[1:0] = (dcu_addr_c_31)?dtg_stat_out[3:2]:dtg_stat_out[1:0] ;

//************* Write Enables for Status Bits ************************/
// a. Normal write Hit (next cycle)
// b. Cache fill cycle (last cycle)
// c. Cache Invalidate (diagnostic) (same cycle)
// d. Zero line        (last cycle)
// e. cache flush hit  (next cycle)
// f. on a cache miss  (after 2 cycles -- timing reason)

// instead of invalidating a cache line during replacing dirty line,
// we could to invalidate when the first fill data comes in.
// but , due to this there can be a store to the same location which
// would not be stored back to memory.

// Valid of Set 0
// last cycle of cache fill or diagnostic store or last cycle of
// zeroline inst or 2 cycles after dcu_miss or flush hit 
 
assign dcu_stat_we[0] 	=  last_fill_cyc |
			   tag_st_rdy_e |
			   repl_line_inv |
			   first_fill_cyc& !nc_xaction |
			   smu_na_st_fill |
			   dcu_hit0& (iu_flush_cmp_c | iu_flush_inv_c) |
                           !dcu_addr_c_31&iu_flush_index_c;


// Dirty bit of set 0
assign	dcu_stat_we[1] =   dcu_hit0_c & store_c&(iu_req_c&iu_valid_c|smu_req_c)  | 	//2nd cycle of store hit 
			   last_fill_cyc  |	// last cycle of cache fill or zeroline
			   tag_st_rdy_e |	// diag store
			   smu_na_st_fill  ;	// non_allocating store		

// Valid bit of Set 1
assign dcu_stat_we[2]   =  last_fill_cyc |
                           tag_st_rdy_e |
			   first_fill_cyc & !nc_xaction |
                           repl_line_inv |
                           dcu_hit1 &( iu_flush_cmp_c | iu_flush_inv_c) |
			   smu_na_st_fill |
			   dcu_addr_c_31&iu_flush_index_c;

// Dirty bit of Set 1
assign  dcu_stat_we[3] =   dcu_hit1_c & store_c&(iu_req_c&iu_valid_c|smu_req_c)  | 	// 2nd cycle of store hit
			   last_fill_cyc |		// last cycle of cache fill or zeroline inst
                           tag_st_rdy_e |		// diag store
			   smu_na_st_fill ;		// non_allocating store


// LRU Bit of the set
assign dcu_stat_we[4] =    dcu_hit & store_c&iu_valid_c | 
			   last_fill_cyc |
			   dcu_hit & (iu_flush_cmp_c | iu_flush_inv_c) |
                           iu_flush_index_c |
			   tag_st_rdy_e |
			   smu_na_st_fill ;


/**************Generate Status bits for the status RAM ***************************/

//Valid Bit for Set 0
assign dcu_stat_out[0] = last_fill_cyc  		// set valid for last cyc of cache fill
			| tag_st_rdy_e&misc_din[0]  // and zeroline inst. also for diag store set 0 bit
			| smu_na_st_fill;          // non_allocating store
			

//Dirty bit of Set 0
//set for last cycle of write miss fill,last cycle of zeroline inst,
//write hit in C , diagnostic write with bit 1 of datapath 
assign	dcu_stat_out[1] = last_fill_cyc & (miss_store | zeroline_cyc)| 
			store_c |
			smu_na_st_fill  | 
			tag_st_rdy_e & misc_din[1] ;

//Valid bit of set 1
assign dcu_stat_out[2] = last_fill_cyc  |
			 tag_st_rdy_e&misc_din[0] |
			smu_na_st_fill ;

//Dirty bit of set 1
assign dcu_stat_out[3] = last_fill_cyc & (miss_store | zeroline_cyc)| 
			store_c |
			tag_st_rdy_e & misc_din[1] |
			smu_na_st_fill;

// LRU bit of set
assign dcu_stat_out[4] = (smu_na_st_fill |last_fill_cyc )& !fill_set_sel_d1 | dcu_hit0_c & store_c |
			 tag_st_rdy_e & misc_din[2] | dcu_hit1_c & (iu_flush_cmp_c | iu_flush_inv_c) |
                         iu_flush_index_c & dcu_addr_c_31  ;

			  

/*********** Generate Tag write Enable --> for tag addr ************************/
// write into tags when
// a. Cache fill cycle (first cycle data is returned)
// b. diagnostic writes bit 31 = 1 --> write to tag1. bit 31=0 write to tag0
// c. zeroline inst (last cyc of zeroline operation) 
			
assign dcu_tag_we  = first_fill_cyc & !nc_xaction |  
			tag_st_rdy_e | 
			 smu_na_st_fill ; 		 // for na store


/**********Generate word offset in a cache line during a fill operation ******/


//note: what happens if a error ack is returned inbetween.
// by including dc_idle, we thus allow state m/c to come back to idle state

assign	last_cyc = dc_idle | last_fill_cyc; 
assign	addr_next[4:0]	=  addr_state( addr[4:0],
					cf_addr[1:0],
					dc_req,
					zeroline_c,
					dc_wr_cyc123,
					last_cyc );

ff_sre_4	cf_word_addr_reg(.out(addr[4:1]),
		.din(addr_next[4:1]),
		.clk(clk),
		.reset_l(reset_l),
		.enable(1'b1));

ff_s		cf_word_addr_0_reg(.out(addr[0]),
				.din(!reset_l | addr_next[0]),
				.clk(clk));

// Since we use cf_addr for smu na store, we force the word to be C 
// instead of using the state machine output
assign	word_addr[1]	=      (smu_na_st_fill)? 1'b1:(addr[4] | addr[3]);
assign	word_addr[0]	=      (smu_na_st_fill)? 1'b1:(addr[2] | addr[4]);


function [4:0]	addr_state;

input	[4:0]	cur_state;
input	[1:0]	cf_addr;
input		dc_req;
input		zeroline_c;
input		dc_wr_cyc123;
input		last_cyc ;

reg 	[4:0]	next_state;

parameter // triquest enum DCUDP_CNTL_ENUM
	IDLE		= 5'b00001,
	WORD0_STATE 	= 5'b00010,
	WORD1_STATE     = 5'b00100,
	WORD2_STATE     = 5'b01000,
	WORD3_STATE     = 5'b10000;

begin
case (cur_state)  // synopsys full_case parallel_case

	IDLE:		begin
			if (!cf_addr[1] & !cf_addr[0] & dc_req | zeroline_c) begin
			next_state = WORD0_STATE ;
			end
			else if( !cf_addr[1] & cf_addr[0] & dc_req) begin
			next_state = WORD1_STATE;
			end
			else if( cf_addr[1] & !cf_addr[0] & dc_req) begin
                        next_state = WORD2_STATE;
                        end   
			else if( cf_addr[1] & cf_addr[0] & dc_req) begin
                        next_state = WORD3_STATE;
                        end   
			else next_state = cur_state ;
			end
			
	WORD0_STATE:	begin
			if (dc_wr_cyc123 ) begin
			next_state = WORD1_STATE;
			end
			else if ( last_cyc) begin
			next_state = IDLE ;
			end
			else next_state = cur_state;
			end


	 WORD1_STATE:    begin
                        if (dc_wr_cyc123 ) begin
                        next_state = WORD2_STATE;
			end
                        else if ( last_cyc) begin
                        next_state = IDLE ;
                        end
                        else next_state = cur_state;
                        end
 

	 WORD2_STATE:    begin
                        if (dc_wr_cyc123 ) begin
                        next_state = WORD3_STATE;
			end
                        else if ( last_cyc) begin
                        next_state = IDLE ;
                        end
                        else next_state = cur_state;
                        end
 

	 WORD3_STATE:    begin
                        if (dc_wr_cyc123 ) begin
                        next_state = WORD0_STATE;
			end
                        else if ( last_cyc) begin
                        next_state = IDLE ;
                        end
                        else next_state = cur_state;
                        end

	default:	next_state = 5'bx;

endcase
addr_state[4:0]	= next_state[4:0] ;
end
endfunction

mj_spare spare(	.clk(clk),
		.reset_l(reset_l));

endmodule
