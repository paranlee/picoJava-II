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




// triquest fsm_begin
module  ic_cntl(
	icu_addr_sel,
	next_addr_sel,
	addr_reg_sel,
	addr_reg_enable,
	biu_addr_sel,
	icu_tag_sel,
	ic_data_sel,
	icu_req,
	icu_type,
	icu_size,
	ic_drty,
	icu_stall,
	icu_tag_vld,
	icu_itag_we,
	icu_ram_we,
	icu_bypass_q,
	latch_biu_addr,
        diag_ld_cache_c,
  	fill_word_addr,
        icu_in_powerdown,
        icram_powerdown,
        next_fetch_inc, 

	// INPUTS
	iu_psr_bm8,
	iu_psr_ice,
	iu_flush_e,
	iu_ic_diag_e,
	iu_brtaken_e,
	ibuf_full,
	iu_data_e_0,
	icu_hit,
	biu_icu_ack,
        pcsu_powerdown,
	icu_hold,
	misc_wrd_sel,
	ice_line_align,
	bypass_ack,
	clk,
	sin,
	sm,
	so,
	reset_l
	);
	


output			icu_req;	// request memory on a cache miss
output	[3:0]		icu_type;	// type of transaction
output	[1:0]		icu_size;	// size of transaction
output	[1:0]		icu_addr_sel;	// select addr input to the tags/data
output	[3:0]		next_addr_sel;	// select the correct next_addr to access cache
output	[1:0]		addr_reg_sel;	// select the correct next_addr to access cache
output			addr_reg_enable;// enable to icu_addr_d1 latch
output  [1:0]           biu_addr_sel;
output			ic_data_sel;	// select cache fill data or misc data for instruction ram
output			icu_tag_sel;	// To select input to the tag ram. either mar or misc store.
output			ic_drty;	// Error acknowledge returned by memory
output			icu_stall;	// Stall to iu pipe for diagnostic rd/writes
output			icu_tag_vld;	// valid bit of the tag - to be written into tagram
output			icu_itag_we;	// Write enable to the tags
output	[1:0]		icu_ram_we;	// write enable to the inst ram
output			icu_bypass_q;	// bypass data from the cache
output			latch_biu_addr; // latch the memory addr (in case of cache miss)
output                  diag_ld_cache_c;// diagnostic rd to ram
output	[1:0]		fill_word_addr; //  word addr during fill
output                  icu_in_powerdown;// ICU notifies PCSU it is ready for clock shut off.
output                  icram_powerdown;// powerdown signal to RAM and TAG
output  [3:0]           next_fetch_inc; // next_fetch_inc = 1, if iu_psr_bm8 is asserted,
                                        // otherwise next_fetch_inc = 4, if bypass, 8, if hit
output			icu_hold;       // hold iu pipe for diagnostic access when
					// there is outstanding transaction in ICU 
input           	iu_psr_bm8;     // 8 bit boot code enable from IU
input	[3:0]		iu_ic_diag_e;	// diagnostic rd/wr to tags/ram
input	[1:0]		biu_icu_ack;	// Acknowledge from biu that data from memory is available
input			iu_psr_ice;	// Icache Enable in the PSR 
input			iu_brtaken_e;	// branch taken in E stage
input			iu_flush_e;	// flush instruction in E stage
input			ibuf_full;	// Ibuffer is full. (icache should go idle)
input			icu_hit;	// Icache Hit
input			iu_data_e_0;	// bit 0 of iu data bus used for diagnostic writes
input                   pcsu_powerdown; // PCSU request for powerdown
input			misc_wrd_sel;
input			ice_line_align;
output			bypass_ack;
input			clk;
input			reset_l;
input			sin;		// scan input
input			sm;		// scan enable
output			so;		// scan output

wire			normal_ack;
wire			second_fill_cyc;
wire 			third_fill_cyc;
wire			fourth_fill_cyc;
wire			nc_fill_cyc;
wire			error_ack;
wire	[6:0]		ic_miss_state;
wire	[6:0]		next_miss_state;
wire			valid_diag_e;
wire			valid_diag_c;
wire			icu_miss;
wire			ic_idle;
wire			diag_st_cache_e;
wire			diag_ld_cache_e;
wire			diag_st_tag_e;
wire			diag_ld_tag_e;
wire			set_stall ;
wire			cache_fill_cyc;
wire			stall_valid;
wire			reset_d1_l ;
wire			jmp_e;
wire			fourth_fill_cyc_d1;
wire			nc_fill_cyc_d1;
wire			ic_idle_d1;
wire                    icram_powerdown;
wire 	[3:0]		next_fetch_inc;
wire 			qual_iu_flush_e; 
wire			icu_hold;
wire			nc_req;
wire			ic_req;
wire 			cacheable;
wire 			qual_iu_psr_ice;
wire 			qual_iu_psr_ice_q;
wire			icu_bypass_q;
wire			standby_d1;
wire			new_psr_ice;

// *****************************************************************************
// 
// iu_psr_ice does not become effective until the subsequent icu_addr_d1 
// becomes aligned on line boundary( ice_line_align=(icu_addr_d1[3:0] == 4'h0) ).
// This simplifies the ibuffer new_valid equations because with ice_line_align  
// used to qualify iu_psr_ice there should be no need to align the cached data 
// to fill the ibuffer in the middle. This corner case occurs in a scenario:
//
// The cache is on while ibuf's PC is on 2nd or 4th word. After the line has been 
// filled to I$, the 2nd or 4th word needs to be aligned and filled to Ibuffer.    
// This kind of alignment complicates the new_valid equations and verification
// work.  
// 
// With qual_iu_psr_ice, if there is any alignment, it must be caused by branch
// or trap and the data always fill from the first byte of the ibuffer. 
//
// ******************************************************************************


// qual_iu_psr_ice changes only when there is a fetch address in cache access
// stage along a cache line boundary.
wire    qual_iu_psr_ice_sel = ic_idle& ice_line_align & !valid_diag_c&!nc_fill_cyc_d1&!fourth_fill_cyc_d1;
assign  qual_iu_psr_ice = qual_iu_psr_ice_sel ? new_psr_ice : qual_iu_psr_ice_q;
 
// Latch the new PSR bit only when in idle.
ff_sre  iu_psr_ice_reg (    		.out(new_psr_ice),
                                        .din(iu_psr_ice),
                                        .clk(clk),
					.enable(ic_idle),
                                        .reset_l(reset_l)
                                        );

mj_s_ff_snr_d  qual_iu_psr_ice_reg (    .out(qual_iu_psr_ice_q),
                                        .in(qual_iu_psr_ice),
                                        .clk(clk),
                                        .reset_l(reset_l)
                                        );
 

wire    valid_diag_window  = valid_diag_e | valid_diag_c;

// **************************************************************
//
// Icu_hold is generated to hold iu pipe for diagnostic access 
// when there is outstanding transaction in ICU.
// 
// **************************************************************

assign  icu_hold = (|iu_ic_diag_e[3:0] | (iu_flush_e & iu_psr_ice ))
                    & !ic_idle;


// **************************************************************
//
// iu_flush_e needs to be qualified by iu_psr_ice
// iu_flush_e is treated as a nop if iu_psr_ice is set to zero
// iu_flush_e also needs to be qualified by ic_idle since the 
// Icache flush can only be carried out when there is no 
// outstanding ICU transaction.
//
// **************************************************************

assign qual_iu_flush_e= iu_flush_e & iu_psr_ice & ic_idle;

// temp connection
// assign pcsu_powerdown = 1'b0;

// **************************************************************
//
// 8 Bit Boot Code Mode: 
//
// To perform boot mode correctly you need to be 
// aware of the following pitfalls:
// 
// 1. The execution of the priv_write_prs instruction 
//    disables the boot mode. So, do NOT use the priv_write_prs 
//    instruction until after the branch to non-boot memory 
//    location occurs.
//
// 2. To execute the priv_write_prs without modifing the 
//    content, you need issue priv_read_prs before 
//    priv_write_prs. So, use these two instructions as a pair   
//    to perform disabling Boot Mode.
//
// 3. The pair MUST start at word boundary.
//
// 4. Four Nops are required to inserted after the priv_write_prs
//    in order to recover from boot mode to word acccess.   
//
// 5. The pj_boot8 pin needs to tied to HIGH.
//    
// To summarize the usage, the boot code should be written in the 
// style shown as below:
//
// (8 bit PROM)
// Boot_Start:  Instruction_1
//              Instruction_2
//              ...
//              goto Application  // Application program must
//                                // begin at word boundary
//
// (Non-boot Memory)
// Application: priv_read_reg_psr  // To avoid modifing psr,the
//                                 // content of psr is pushed
//		sipush 0xBFFF      // Zero the bit 14 (PSR.BM8)
//    		iand		   //
//              priv_write_reg_psr // Then disable boot mode by
//                                 // poping the content to psr
//
//              nop                // 4 nops are inserted to
//              nop                // recover from boot mode to 
//	        nop		   // word acccess
//              nop
//
// **************************************************************

assign next_fetch_inc =  iu_psr_bm8     ? 4'b0001: 
                         !qual_iu_psr_ice ? 4'b0100 : 4'b1000;  

// Decode of Various signals
assign	valid_diag_e = qual_iu_flush_e | iu_ic_diag_e[3] | iu_ic_diag_e[2] | 
                       iu_ic_diag_e[1] | iu_ic_diag_e[0] ;

// **************************************************************
// diag_xx_xxx_e 
//
// The following diag_xx_xxx_e signals need to be qualified by 
// ic_idle because the diagnostic access can only be carried out 
// when there is no outstanding ICU transaction.
// **************************************************************

wire    diag_ld_c;
assign  diag_st_cache_e = iu_ic_diag_e[3]& ic_idle;
assign  diag_ld_cache_e = iu_ic_diag_e[2]& ic_idle;
assign  diag_st_tag_e   = iu_ic_diag_e[1]& ic_idle;
assign  diag_ld_tag_e   = iu_ic_diag_e[0]& ic_idle;

mj_s_ff_snr_d  diag_ld_c_reg (	.out(diag_ld_c),
				.in(diag_ld_cache_e|diag_ld_tag_e),
		                .clk(clk),
                      		.reset_l(reset_l)
				);

// Generate a miss only if in idle state and no diagnostic rd/wr in C stage.
// diagnostics should not generate any misses. but , at the same time they
// should generate a stall for ibuffer, so that it ignores data on the bus to 
// ibuffer.

// *** NOTE ***
// To suppress cache enable during the boot mode qual_iu_psr_ice needs to be
// negated by iu_psr_bm8.

assign  icu_miss =  (!qual_iu_psr_ice |iu_psr_bm8 | (!icu_hit) )
		    & ic_idle & !valid_diag_c&!fourth_fill_cyc_d1&!nc_fill_cyc_d1&!ic_drty;

// we latch on a miss or if there is a diagnostic rd/wr in c stage. we dont
// want to latch that address, as it is not in the instruction code flow.

// Note: latch_biu_addr means close biu_addr register. We use !latch_biu_addr
//       to latch the new icu_addr. So icu_miss is removed.


assign	fill_word_addr[1] = ic_miss_state[4] | ic_miss_state[5];
assign	fill_word_addr[0] = ic_miss_state[3] | ic_miss_state[5];

assign latch_biu_addr =   valid_diag_c | !ic_idle  ;

assign	normal_ack = biu_icu_ack[0] & !biu_icu_ack[1] ;
assign	error_ack  = biu_icu_ack[1] ;
assign  bypass_ack = normal_ack | error_ack;

// Delay ic_drty by one clock, as data

mj_s_ff_s_d  ic_drty_reg (	.out(ic_drty),
				.in(biu_icu_ack[1]),
                      		.clk(clk)
				);

// Delay ic_miss_state[2] by one clock to qualify icu_req 


mj_s_ff_snr_d  diag_ld_cache_c_reg (	.out(diag_ld_cache_c),
                        		.in(diag_ld_cache_e),
                        		.clk(clk),
                        		.reset_l(reset_l)
					);

mj_s_ff_snr_d  valid_diag_c_reg (	.out(valid_diag_c),
					.in(valid_diag_e),
					.clk(clk),
					.reset_l(reset_l)
					);

mj_s_ff_s_d  reset_reg (	.out(reset_d1_l),
	                        .in(reset_l),
	                        .clk(clk)
				);


// Generation of Mux selects
// Decreasing Priority for address buses
// 1. Reset 
// 2. Cache fill
// 3. Valid Diagnostic in E stage
// 4. Stalled branch/Trap pc
// 5. trap/branch 
// 6. ibuffer full
// 7. next sequential pc

// Select br_pc or next_addr. if I$ miss handling in progress, branch gets
// lower priority.
assign	icu_addr_sel[1]	=  jmp_e&(ic_idle&reset_d1_l);
assign	icu_addr_sel[0]	= ~icu_addr_sel[1];

// Mux used to latch the next sequential addr or branch addr.
assign	addr_reg_sel[1]	=  jmp_e;
assign	addr_reg_sel[0]	=  ~jmp_e;	

// used to latch branch addr or next sequential addr.
// latch contents if standby,ibuffer is full or diagnostic ld/st or I$ miss when I$ is On.
// we reissue the addr after fill is done. For noncacheable, the data is directly given to
// ibuffer.
assign	addr_reg_enable =  jmp_e | !( standby_d1|ibuf_full|valid_diag_window | !ic_idle |icu_miss |
				stall_valid | fourth_fill_cyc_d1);

// select cache fill address for reset or when not in idle mode
// select iu_addr_e for diagnostic rd/wr
// reissue addr for branch pending,ibuffer full, for cycle after cache misses,or valid diagnostic.
// else next addr.
// note: diagnostics in E and C freeze the fetch pipe.once the diagnostic rd/wr is done,we continue
// with the same fetch in C

assign	next_addr_sel[3] = ~reset_d1_l | !ic_idle ;
assign	next_addr_sel[2] = valid_diag_e&ic_idle&reset_d1_l;
assign	next_addr_sel[1] = (stall_valid|ibuf_full| fourth_fill_cyc_d1|valid_diag_c)&reset_d1_l&ic_idle&~valid_diag_e;
assign	next_addr_sel[0] = ~stall_valid&~ibuf_full&reset_d1_l&ic_idle&~valid_diag_e&~fourth_fill_cyc_d1;


assign  biu_addr_sel[1]  = ic_miss_state[2]|(ic_idle&cacheable);
assign  biu_addr_sel[0]  = !biu_addr_sel[1];

// Generation of Stall valid 
// When a branch is taken or trap occurs and icache is busy doing a cache fill,
// we stall the branch till the fill is done and then the branch is taken.
// to keep track of the jump, we use signal stall_valid

// Generation of standby_d1:
// If Powerdown occurs at idle state, after powerdown ends 
// the state machine enters idle state again, The assertion of !icu_stall 
// should be inhibited by asserting set_stall because no valid data is available.   
// 
// However if powerdown occurs on executing goto within a line , then
// after powerdown ends the state machine enters idle state and generates 
// !icu_stall because the pending goto has a hit. 
// The assertion of !icu_stall should NOT be inhibited for this case.   


mj_s_ff_s_d  standby_d1_reg (	.out(standby_d1),
                                .in(icu_in_powerdown),
                                .clk(clk)
				);

assign	set_stall =  (iu_brtaken_e) & !ic_idle | 
                     (stall_valid & !ic_idle);

// Generation of miss due to branch or trap

mj_s_ff_snr_d  set_stall_reg (	.out(stall_valid),
			        .in(set_stall),
			        .clk(clk),
			        .reset_l(reset_l)
				);

assign	jmp_e	= iu_brtaken_e;

// Select input to tag ram
// when there is data coming back from memory, select MAR for tag input
assign	icu_tag_sel = normal_ack | (ic_idle & !valid_diag_e) ;

// select input to inst ram
// when there is data coming back from memory, select biu data from data input
assign	ic_data_sel = normal_ack | error_ack ;


// Generation of Write Enables for RAMs/TAGs
// write to tags during the last cycle of cache fill or during diagnostic writes to tags
// we write to the tags in both the cycles. in the first cycle, we invalidate the
// tag. In the second cycle , we validate the tag. This way  we avoid wierd
// corner cases when part of new data has been written into and the transaction
// is cancelled due to diagnostic wr/rd or error acks.

assign	icu_itag_we	=  cache_fill_cyc |  diag_st_tag_e | qual_iu_flush_e;
assign	icu_ram_we[1]	=  ((ic_miss_state[2]|ic_miss_state[4]) & normal_ack) |
                           (diag_st_cache_e & !misc_wrd_sel);
assign	icu_ram_we[0]	=  ((ic_miss_state[3]|ic_miss_state[5]) & normal_ack) |
			   (diag_st_cache_e & misc_wrd_sel);
wire    icu_bypass      =  ic_miss_state[1] | error_ack;

mj_s_ff_s_d  icu_bypass_reg (	.out(icu_bypass_q),
                                .in(icu_bypass),
                                .clk(clk)
				);


// Generation of Valid bit for Tags
// valid bit set whenever cache fill is done or during a diagnostic write .
assign	icu_tag_vld 	=  ((ic_miss_state[5] & normal_ack) | diag_st_tag_e & iu_data_e_0)& !qual_iu_flush_e ;

// Generation of icu_stall signal
// icu_stall becomes high if
//   . or if there's an i$ miss 
//   . or if i$ is not idle and the first fill data is not back yet
// * or if there is an outstanding branch/trap and
// 	or if there is a valid diagnostic in C stage and 1 clock after reset.(no valid data)


wire           valid_diag_window_d1;

mj_s_ff_s_d  valid_diag_window_flop (	.out(valid_diag_window_d1),
		                        .in(valid_diag_window),
		                        .clk(clk)
					);

// no valid data on cache miss or during cache miss transaction. but,during nc accesses, when data
// is back, we accept it even if cache miss is indicated. Also, for cache misses when the Icache is
// ON, when the data is written into the I$, the last cycle is ignored(fourth_fill_cyc_d1).bcos,
// the addr is issued again and the correct data is available a cycle later.

assign icu_stall = (icu_miss )| (!ic_idle| valid_diag_window | stall_valid | ibuf_full | standby_d1 
			|!reset_d1_l | fourth_fill_cyc_d1);
			


// For generation of icu_stall (signal which informs ibuffer that data on bus to ibuffer is invalid)
// we need to generate a signal fourth_fill_cyc_d1 which indicates that the  fourth word being 
// written into the icache in this cycle. Thus, any hit obtained due to this 
// new write is nullified and thus icu_stall remains valid.

mj_s_ff_snr_d  nc_fill_cyc_flop (	.out(nc_fill_cyc_d1),
					.in(nc_fill_cyc&~stall_valid),
					.clk(clk),
					.reset_l(reset_l)
					);

mj_s_ff_snr_d  fourth_fill_cyc_flop (	.out(fourth_fill_cyc_d1),
					.in(fourth_fill_cyc&~stall_valid),
					.clk(clk),
					.reset_l(reset_l)
					);

/************** ICACHE  MISS STATE MACHINE ******************/

assign          ic_idle         = ic_miss_state[0];
assign          nc_req          = ic_miss_state[1];
assign          icu_req         = ic_miss_state[1] | ic_miss_state[2];
assign          ic_req          = ic_miss_state[2]|ic_miss_state[3]|ic_miss_state[4]|
				  ic_miss_state[5];


assign		second_fill_cyc	= (ic_miss_state[3] & (normal_ack | error_ack));

assign		third_fill_cyc	= (ic_miss_state[4] & (normal_ack | error_ack));

assign		fourth_fill_cyc	= (ic_miss_state[5] & (normal_ack | error_ack));

assign		nc_fill_cyc	= ic_miss_state[1] & (normal_ack | error_ack) ;

assign		cache_fill_cyc  = (ic_miss_state[2]|ic_miss_state[3]|ic_miss_state[4]|
                                   ic_miss_state[5]) & (normal_ack | error_ack);

assign		icu_type[0]	= 1'b0;	// always a load
assign		icu_type[1]	= ic_miss_state[1];// noncacheable if icache turned off
assign		icu_type[2]	= 1'b0;		// for icache req - 0
assign		icu_type[3]     = 1'b0;		// for icache req = 0

assign		icu_size[0]     = 1'b0;
assign		icu_size[1]     = !iu_psr_bm8;

assign 		cacheable       = qual_iu_psr_ice & !iu_psr_bm8;

   
assign  next_miss_state[6:0]    =       miss_state( ic_miss_state[6:0],
					valid_diag_window,
                                        icu_miss,
                                        normal_ack,
                                        cacheable,
                                        error_ack,
					pcsu_powerdown,
					jmp_e,
                                        ibuf_full);

// triquest state_vector {ic_miss_state[6:1] ic_miss_state[0]} ICU_MISS_STATE enum ICU_MISS_STATE_ENUM
mj_s_ff_snr_d_6  miss_state_reg (	.out(ic_miss_state[6:1]),
	                                .din(next_miss_state[6:1]),
                               		.clk(clk),
                               		.reset_l(reset_l)
					);
 
mj_s_ff_s_d  miss_state_reg_0 (	.out(ic_miss_state[0]),
                                .in((!reset_l) | next_miss_state[0]),
                                .clk(clk)
				);

mj_s_ff_s_d  ic_idle_d1_reg (	.out(ic_idle_d1),
			        .in(ic_idle),
			        .clk(clk)
				);

// **************************************************************
//
// Power Down Feature for ICU: 
//
// Most RAM cells have a pin to disable all functions
// except for the retaining of data in order to reduce
// power consumption.
//
// Normal Power Down Mode:
//
// ICU enters the normal power down state
// when ICU is waiting for NC data or the missed data.
// A signal, icram_powerdown is asserted in this state and
// the state remains unchanged until normal_ack returns or
// valid_diag_e occurs.
//
// As an option, the signal, icram_powerdown can be
// connected to a powerdown pin of the RAM megacell.
//
// Standby Power Down Mode:
//
// State machine enters the standby power down state
// after PCSU asserts pcsu_powerdown signals and ICU
// completes the pending access.
// In this state,  a signal, icu_in_powerdown will be
// asserted to PCSU. Then PCSU shuts off the clock to ICU.
//
// Notes:
//
//   1. The powerdown pin is a registered input to RAM cell.
//
//   2. The powerdown signal should be set up before the 
//      rising edge of the clock.
//          
//   3. All inputs except powerdown signal are ignored during
//      the powerdown mode.
// Diagram:
//                    ______        ______        ______
//   clk       ______/      \______/      \______/      \_
//                                             
//                                        Tsetup | Thold
//                  _________________________    | 
//   powerdown ____/                         \____________
//				                 |
//   inputs    _____________________________  _____  ____
//                     Ignored              \/valid\/
//             _____________________________/\_____/\____
//
// **************************************************************

assign icram_powerdown = !ic_idle & !normal_ack & !valid_diag_window;
assign icu_in_powerdown = ic_miss_state[6] & !jmp_e;


function [6:0] 	miss_state ;
 
input   [6:0]  	cur_state ;
input		valid_diag_window;
input          	icu_miss ;
input          	normal_ack;
input          	cacheable ;
input          	error_ack ;
input          	pcsu_powerdown;
input           jmp_e;
input           ibuf_full;
 
reg     [6:0]  	next_state;

// State Encoding
parameter // triquest enum ICU_MISS_STATE_ENUM
        IDLE            = 7'b0000001,
	NC_REQ_STATE	= 7'b0000010,
        REQ_STATE       = 7'b0000100,
        FILL_2ND_WD     = 7'b0001000,
        REQ_STATE2      = 7'b0010000,
        FILL_4TH_WD     = 7'b0100000,
        STANDBY_PWR_DN  = 7'b1000000; 
begin
 
case    (cur_state)     // synopsys parallel_case
        IDLE:   begin
                if (pcsu_powerdown & !jmp_e & !valid_diag_window) begin
                next_state = STANDBY_PWR_DN;
                end
                else if (valid_diag_window | ibuf_full | jmp_e) begin
                next_state = cur_state;
                end
                else if(icu_miss&!cacheable) begin
                next_state = NC_REQ_STATE ;
                end
		else if (icu_miss&cacheable) begin
		next_state = REQ_STATE;
		end
                else    next_state = cur_state ;
        end

	NC_REQ_STATE: begin
                if(normal_ack| error_ack) begin
                next_state = IDLE ;
                end
                else    next_state = cur_state ;
        end

        REQ_STATE: begin
                if (normal_ack) begin
                next_state = FILL_2ND_WD;
                end
                else if (error_ack) begin
                next_state = IDLE ;
                end
                else next_state = cur_state ;
 	end
 
        FILL_2ND_WD: begin
                if(normal_ack) begin
                next_state = REQ_STATE2;
                end
                else if (error_ack) begin
                next_state = IDLE ;
                end
                else next_state = cur_state ;
        end

        REQ_STATE2: begin
                if(normal_ack) begin
                next_state = FILL_4TH_WD;
                end
                else if (error_ack) begin
                next_state = IDLE ;
                end
                else next_state = cur_state ;
        end

        FILL_4TH_WD: begin
                if(normal_ack| error_ack) begin
                next_state = IDLE;
                end
                else next_state = cur_state ;
        end

        STANDBY_PWR_DN: begin
                if(!pcsu_powerdown | jmp_e ) begin
                next_state = IDLE;
                end
                else next_state = STANDBY_PWR_DN;
        end

        default:        next_state = 7'bx;

endcase
miss_state = next_state ;
end
endfunction

endmodule

// triquest fsm_end
