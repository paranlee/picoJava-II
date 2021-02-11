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



module smu_ctl (

num_entries,
und_flw_bit,
iu_sbase_we,
iu_psr_dre,
iu_int,
clk,
low_mark,
high_mark,
sm,
sin,
so,
reset_l,
iu_sbase_int_we,
iu_sbase_int_sel,
nxt_sb_sel,
dcache_sb_sel,
sbase_sel,
scache_addr_sel,
ret_optop_update,
smu_data_vld,
spill,
fill,
smu_st_c,
dribble_stall,
smu_we,
iu_flush,
smu_ld,
smu_st,
zero_entries_fl,
smu_sbase_we,
optop_en,
sbase_hold,
smu_prty,

iu_smiss,
smu_data_sel,
dcu_smu_stall,
smu_na_st,
smu_addr
);

input	[29:0]	num_entries;	// Comes from data path
input		und_flw_bit;	// indicates that num_entries is -ve
input		iu_sbase_we;	// Write enable signal from IU for sbase
input		iu_psr_dre;	// dribbler enable bit from IU
input		iu_int;		// Input from IU which tells that
				// interrupt has come while handling
				// Overflows/Underflows and the dribble
				// stall has to be squashed.
input	[5:0]	low_mark;
input	[5:0]	high_mark;
input		clk;
input		sm;
output		so;
input		sin;
input		reset_l;
output	[2:0]	iu_sbase_int_sel;
output		iu_sbase_int_we;
output	[1:0]	nxt_sb_sel;
output	[1:0]	dcache_sb_sel;
output	[1:0]	sbase_sel;
output	[1:0]	scache_addr_sel;

input		ret_optop_update; // This signal tells that the return is not due to 
				  // c_switch
input		smu_data_vld;
output		fill;
output		spill;
input		smu_st_c;
output		dribble_stall;
output		smu_we;
input		iu_flush;  	// Signal from IU which is generated as a  result of 
				// IU wanting to write d$ in locations between sb-4 
				// and sb+4. 
				// This will create a WAW hazard as dribbler is busy 
				// fetching data to these locations in scache

input 		iu_smiss;
input		dcu_smu_stall;
input	[3:2]	smu_addr;
output	[1:0]	smu_data_sel;
output		smu_na_st;	// Tell DCU it is non-allocate 

output		smu_ld;
output		smu_st;
input		zero_entries_fl;
output		smu_sbase_we;
output		optop_en;
output		sbase_hold;
output		smu_prty;

wire		squash_store;
wire		spill_d;
wire		stall_six;
wire		idle_six;
wire		iu_int_c;
wire		idle_e;
wire		spill_raw;
wire		spill_cs;
wire		squash_hold_ld_st;
wire		fill_raw;
wire		fill_d;
wire		spill_e;
wire		fill_e;
wire		ovr_flw;
wire		und_flw;
wire		und_flw_d;
wire		ovr_flw_d;
wire		cs_undflw_d;
wire		load_c;
wire		load_w;
wire		store_c;
wire		store_w;
wire		stall_ovr_flw;
wire		iu_smu_flush;
wire		iu_smu_flush_c;
wire		stall_und_flw;
wire		ovr_flw_bit;
wire	[4:0]	dribb_state;
wire	[4:0]	nxt_dribb_state;
wire	[1:0]	nxt_six_state;
wire	[1:0]	six_state;
wire	[3:0]	nxt_cs_spill_st;
wire	[3:0]	cs_spill_st;
wire		squash_fill;
wire		squash_hold_w;
wire		squash_hold_c;
wire		squash_hold;
wire		zero_entries;
wire		zero_entries_c;
wire		smu_st_w;
wire		squash_state;
wire		squash_state_e;
wire		stall_ovr2;
wire		stall_ovr1;
wire		squash_fill_cs;
wire		smu_data_vld_w;
wire		idle;
wire		flush_pipe;
wire		less_than_6;
wire		less_than_6_raw;

wire		smu_stall;
wire		iu_smiss_l;		// latch iu_smiss if smu_stall is 1

assign smu_stall = dcu_smu_stall | iu_smiss | iu_smiss_l;


// The following comparator will determine if there are less than 6 entries
// in the stack cache

comp3_30	six_entr_comp(.result(less_than_6_raw),
				.operand1(3'b110),
				.operand2(num_entries),
				.signbit(und_flw_bit) );

assign	less_than_6 = less_than_6_raw & iu_psr_dre;

comp6_30	spill_comp(.result(spill_raw),
			.operand1(high_mark),
			.operand2(num_entries),
			.signbit(und_flw_bit));

// If dribbler is off don't generate any fills, spills, overflows

assign spill_d = (spill_raw | spill_cs) & iu_psr_dre;

// Look for the definition of squash_store

// If there's iu_smu_flush and smu_hold(dribble_stall) at the same time
// it will cause deadlock
// Also donot qualify squash_store with !dribble_stall; That would defeat
// the purpose of having squash_store

assign iu_smu_flush = (iu_flush &!dribble_stall | squash_store); 

// We'll have to squash fill and spill whenever there's iu_smu_flush
// This is to ensure that sbase_c will be equal to sbase

// Whenver there's an Interrupt squash spill

ff_sr	spill_flop (.out(spill_e),
		.din( spill_d & !(flush_pipe | squash_fill 
		   		| iu_smu_flush | iu_int)),
		.clk(clk),
		.reset_l(reset_l));

// load_c is added for the following reason:
// Low water mark condition is violated so dribbler issues a fill
// request to loc. x+4. DCU accepts this request and asserts smu_stall
// Meanwhile lots of data gets pushed into stack cache and now High water
// mark condition is violated. So, when dcu returns the first load val and
// deasserts the smu_stall, dribbler gives it a spill request. But since
// sbase_c points to the fill address (x+4 and it is not updated to x because
// of smu_satll),Dribbler issues a store request to address x+4 instead of x 
// thereby writing a wrong value to DCU

// load_w is added to help in the above scenario, when spill is asserted
// (load_c has become zero in the prev cycle) there is still load_w high and 
// this causes problem since it selects  wrong addr. to read from scache 
// (as it selects sbase_w ) instead of sbase_e for spill operation

assign	spill  = spill_e & !load_c & !load_w & !(iu_smiss | iu_smiss_l);


// Whenever there's an underflow while changing the threads, we need to
// flush out the valid entries just as in case of normal overflows

assign	cs_undflw_d   = und_flw_d & !ret_optop_update;

// Whenever the address sent to DCU is equal to optop_old and 
// if there's a store request to DCU, that means we have zero_entries
// to be flushed out; This is done so that there are no extra entries
// flushed out on an overflow or context switch underflow

assign zero_entries = zero_entries_fl & spill;

// Whenever there's an underflow during a context switch generate spills
// so as to flush valid entries from the current thread before switching 
// to the next one
// Also, when we update stack bottom after flushing out all the valid
// entries to new optop, make sure there are no spills generated;
// otherwise we'll see both spill and fill getting activated at the
// same time
// Also, whenever there's an Interrupt squash spill_cs

assign nxt_cs_spill_st	= cs_spill_state(cs_spill_st,
				cs_undflw_d,
				zero_entries,
				dribble_stall,
				iu_int,
				und_flw_d );

ff_sr_3		cs_spill_reg(.out(cs_spill_st[3:1]),
			  	.din(nxt_cs_spill_st[3:1]),
				.clk(clk),
				.reset_l(reset_l)
				);
ff_s		cs_spill_reg0 (.out(cs_spill_st[0]),
				.din (nxt_cs_spill_st[0] | ~reset_l),
				.clk(clk)
				);

assign	spill_cs = cs_spill_st[2] & !iu_int;
	
comp30_6	fill_comp(.result(fill_raw),
			.operand1(num_entries),
			.operand2(low_mark),
			.signbit(und_flw_bit));

// If dribbler is off don't generate any fills, spills, overflows

assign	fill_d = fill_raw & iu_psr_dre;


// squash_fill is necessary since when und_flw is 1, we need not
// have to generate any fill signals as it will prevent sbase_c from
// getting updated to iu_optop
// Also whenever ther's an Interrupt from IU, squash any fills

ff_sr	fill_flop (.out(fill_e),
		.din( (fill_d & !(flush_pipe | squash_fill | squash_fill_cs | 
		       iu_smu_flush | iu_int))),
		.clk(clk),
		.reset_l(reset_l));

// See the defintion on spill as to why we have added store_c in this eqn

assign	fill	= fill_e & !store_c & !store_w & !(iu_smiss | iu_smiss_l);


// Whenever there are 60 entries or more generate over flow.
// This is to ensure that at least 4 empty locations are always there
// on the stack

comp6_30	ovr_fl_cmp(.result(ovr_flw_bit),
			.operand1(6'b111011),
			.operand2(num_entries),
			.signbit(und_flw_bit));

// If dribbler is off don't generate any fills, spills, overflows

assign	ovr_flw_d = ovr_flw_bit & iu_psr_dre ;

ff_sr		ovr_flw_flop(.out(ovr_flw),
			.din(ovr_flw_d),
			.clk(clk),
			.reset_l(reset_l)
			);


// If dribbler is off don't generate any fills, spills, overflows

assign und_flw_d	= und_flw_bit & iu_psr_dre;

ff_sr		und_flw_flop(.out(und_flw),
			.din(und_flw_d),
			.clk(clk),
			.reset_l(reset_l)
			);

// Generate nxt_sb_sel

// Previously there were only spill and fill in this equation. But load_c, etc .. 
// are added for the following reason:
// There are two fills, say to locations, x+4, x+8. Both of these fills are in
// pipeline. So the sbase value is still x. Now for one cycle due to change in
// optop, there is no fill. So sbase_c is set to x. and in the next cycle, there's
// a fill due to change in optop. So we'll reisuue load from location x_4. Now
// we have three loads in the pipeline, x+4,x+8,x+4 in that order. Lets say optop
// jumps to  sbase, when sbase equals x+8. In the next clock cycle, sbase will be
// x+4 and optop is x+8, whihc causes smu to dribble out all of the memory.... 

assign 	nxt_sb_sel[0]	=	(fill | spill | load_c | load_w | store_c | store_w);

assign 	nxt_sb_sel[1]	=	!nxt_sb_sel[0];


// Generate dcache_sb_sel

assign	dcache_sb_sel[0] = 	!spill;
assign	dcache_sb_sel[1] = 	spill;

// Generate smu_data_sel to select iu_data and iu_address

assign	smu_data_sel[0] = !(iu_smiss | iu_smiss_l);
assign  smu_data_sel[1] = iu_smiss | iu_smiss_l;

// sbase_sel will determine whether the optop from iu or sbase from w stage is the 
// new sbase

assign  sbase_sel[0] =	!sbase_sel[1];

// select optop_e for sbase whenever there's an underflow or
// during squash_state -> see the defn. of squash state

assign	sbase_sel[1] = squash_fill;

// scache_addr_sel will determine what address has to be sent to access s cache

assign 	scache_addr_sel[1] =	load_w;
assign	scache_addr_sel[0] =    !scache_addr_sel[1];

// sbase_hold will hold the value of sbase_c when there's a hold from dcache
// see the defn. of sbase_hold

// iu_smu_flush_c is needed coz we'll have to let sbase_c equal sbase even in the
// presence of smu_stall
// For the same reason we need iu_int_c

assign	sbase_hold = smu_stall & !squash_hold & !iu_smu_flush & !iu_smu_flush_c 
				& !iu_int_c;

ff_sr	flush_flop(.out(iu_smu_flush_c),
		.din(iu_smu_flush),
		.clk(clk),
		.reset_l(reset_l));

ff_sr	int_flop(.out(iu_int_c),
		.din(iu_int),
		.clk(clk),
		.reset_l(reset_l));

// load signals in pipeline

// Squash load_c and store_c signals whenever there's flush_pipe, iu_smu_flush
// and iu_int signals even in the presence of sbase_hold signal

assign squash_hold_ld_st = !(flush_pipe | iu_smu_flush | iu_int);

ff_sre	load_c_flop(.out(load_c),
		.din(fill & squash_hold_ld_st),
		.clk(clk),
		.reset_l(reset_l),
		.enable(!(sbase_hold & squash_hold_ld_st))
		);

ff_sr	load_w_flop(.out(load_w),
		.din(load_c & squash_hold_ld_st),
		.clk(clk),
		.reset_l(reset_l)
		);

// store signals in pipeline
// squash_store  is also added to avoid deadlock situation when
// we are dribbling out data and there's an optop jmp such that for
// sc_bottom = new_optop,new_optop-1 or new_optop-2 and the in the 
// next clock cycle (or there // after) sc_bottom is lower than new_optop 
// due to pending stores and it might result in an under flow condition
// This may be treated as cs_underflow since ret_optop_update might not
// be still active

assign squash_store = ret_optop_update & less_than_6;

ff_sre	store_c_flop( .out(store_c),
		.din(spill & squash_hold_ld_st),
		.clk(clk),
		.reset_l(reset_l),
		.enable(!(sbase_hold & squash_hold_ld_st))
		);

ff_sr	store_w_flop( .out(store_w),
		.din(store_c & squash_hold_ld_st),
		.clk(clk),
		.reset_l(reset_l)
		);



// Generate various write and read enable signals

ff_sr	delay_flop1(.out(smu_st_w),
		.din(smu_st_c),
		.clk(clk),
		.reset_l(reset_l));

ff_sr	delay_flop2 (.out(smu_data_vld_w),
		.din(smu_data_vld),
		.clk(clk),
		.reset_l(reset_l));

// write sbase only if loads/stores finish in dcache or when there is over_flw and
// zero entries . Also don't update sbase in case if there's a flush req from IU.
// If this becaomes a timing problem send sbase_we to IU w.o flush and let IU and
// it with !flush there
// squash_store is added

assign smu_sbase_we =  ((load_w & smu_data_vld_w)  |  (store_w & smu_st_w ) | squash_fill) & !iu_smu_flush;

// Since smu_stall is appearing lots of timing critical paths, we have
// decided to replicate the flops for iu_sbase in SMU itself 
// This internal sbase signal is called iu_sbase_int and all the signal related
// to it are named accordingly

// Whenever, there's reset or there's an update signal from IU or whenever
// there's an update to sbase internally, generate iu_sbase_int_we

assign iu_sbase_int_we = ( smu_sbase_we	| iu_sbase_we | ~reset_l);

// Select
// . SC_BOTTOM_POR_VALUE when there's reset
// . smu_sbase if smu_sbase_we is high
// . iu_data_in, otherwise 

assign	iu_sbase_int_sel[2] = ~reset_l;
assign	iu_sbase_int_sel[1] = reset_l & smu_sbase_we;
assign	iu_sbase_int_sel[0] = reset_l & ~smu_sbase_we;

assign smu_we	    = (load_w & smu_data_vld_w);
assign smu_ld	    = fill;

assign smu_st	    = spill | iu_smiss | iu_smiss_l;

// Generate Non-allocate store only for spills. store misses are always write allocate
assign smu_na_st = smu_st & !iu_smiss&!iu_smiss_l& smu_addr[3] & smu_addr[2];


// Latch iu_smiss if smu_stall is 1

ff_sr   iu_smiss_flop (.out(iu_smiss_l),
                      .din((iu_smiss & dcu_smu_stall) | (iu_smiss_l & dcu_smu_stall)),
                      .clk(clk),
                      .reset_l(reset_l));

// This signal is used to store the old value  of optop in case of overflows

assign	optop_en  = !(stall_ovr_flw | ovr_flw_d | cs_undflw_d);

// The following signals are used to flush fill, smu_stall etc ...


ff_sr		squash_flop1(.out(squash_fill), 
			.din( ( (und_flw_d & idle & ret_optop_update) | squash_state)),
			.clk(clk),
			.reset_l(reset_l));

ff_sr		squash_flop2(.out(squash_hold_w),
			.din(squash_fill),
			.clk(clk),
			.reset_l(reset_l));

// Added "und_flw_d" term for generation of squash_hold_c. #Bug: 4193519

ff_sr		squash_flop3(.out(squash_hold_c),
			.din((ovr_flw_d | und_flw_d) & idle),
			.clk(clk),
			.reset_l(reset_l));

ff_sr		zero_flop(.out(zero_entries_c),
			.din(zero_entries),
			.clk(clk),
			.reset_l(reset_l));

// sqush fill also whenever there's an underflow and it's due to context switch
// as long as it is being handled. since we are already using fl_pipe to flush
// fill, just use stall_ovr1 and stall_ovr2 to flush fill

assign squash_fill_cs	= stall_ovr1 | stall_ovr2;

// squash hold will ignore smu_stall while stalling the contents of sbase_c, etc ...
// This is done so as to update sbase_c inspite of the presence of smu_stalls when
// handling under and over flows

assign	squash_hold = squash_hold_c | squash_hold_w;





//  DRIBBLER STATE MACHINE

assign	idle		= dribb_state[0] ;

ff_sr		idle_flop(.out(idle_e),
			.din(idle),
			.clk(clk),
			.reset_l(reset_l)
			);

assign	stall_ovr1	= dribb_state[1];
assign	stall_ovr2	= dribb_state[2];
assign	stall_ovr_flw	= (dribb_state[1] | dribb_state[2]);
assign	stall_und_flw	= (dribb_state[3] | dribb_state[4]);

// Previously und_flw_d and ovr_flw_d weren't there in this equation.
// Latter it is added coz, when there's an overflow and there's a push happening
// optop gets updated and we are missing one datum


assign	dribble_stall  	= stall_ovr_flw | stall_und_flw | ovr_flw_d | und_flw_d | idle_six & (less_than_6 & !und_flw_d) | stall_six | iu_smiss_l | iu_smiss;

// significance of smu_prty signal.
// This signal goes to DCU and tells it that SMU ld/st's should be given
// priority over IU ones so as to avoid deadlock condition, where by
// IU requests a ld from DCU, in the next clock optop changes causing
// smu_hold. DCU sends smu_stall signal to SMU since it is servicing
// IU request and IU cannot accept DCU data since smu_hold is asserted
// Also, whenever there's an smu_flush, smu_prty should be low

ff_sr	smu_prty_flop (.out(smu_prty),
			.din(dribble_stall &!iu_smu_flush),
			.clk(clk),
			.reset_l(reset_l)
			);

// squash state just functions like an und_flw signal and it is generated when
// there's an overflow happening and sbase equals old value of optop


assign	squash_state  = zero_entries &  stall_ovr2;

assign	flush_pipe =  idle&(und_flw_d | ovr_flw_d) | squash_state ;

ff_sr		squash_flop (.out(squash_state_e),
			.din(squash_state),
			.clk(clk),
			.reset_l(reset_l)
			);

assign	nxt_dribb_state	= dribble_state(dribb_state,
				less_than_6,
				spill_d,
				ovr_flw_d,
				und_flw_d,
				cs_undflw_d,
				ret_optop_update,
				zero_entries,
				zero_entries_c,
				iu_int);

ff_sr_4		dribb_state_reg ( .out(dribb_state[4:1]),
				.din(nxt_dribb_state[4:1]),
				.clk(clk),
				.reset_l(reset_l)
				);

ff_s		dribb_state_reg_0 (.out(dribb_state[0]),
			  	.din(~reset_l | nxt_dribb_state[0]),
				.clk(clk)
				);

assign	idle_six	= six_state[0];
assign	stall_six	= six_state[1];

assign	nxt_six_state = six_entr_state(six_state,
					less_than_6,
					und_flw_d);

ff_sr		six_state_reg (.out(six_state[1]),
				.din(nxt_six_state[1]),
				.clk(clk),
				.reset_l(reset_l)
				);

ff_s		six_state_reg_0 (.out(six_state[0]),
				.din( ~reset_l | nxt_six_state[0]),
				.clk(clk)
				);
					
				
				

// triquest fsm_begin		
function [1:0]	six_entr_state;

// triquest state_vector {curr_state[1:0]} CURR_STATE enum SIX_ENTR_STATE_ENUM

input	[1:0]	curr_state;
input		less_than_6;
input		und_flw_d;

reg	[1:0]	nxt_state;

parameter // triquest enum SIX_ENTR_STATE_ENUM

	IDLE		= 2'b01,
	STALL_SIX 	= 2'b10;

begin

	case (curr_state)

		IDLE: begin

			if (less_than_6 & ! und_flw_d) begin

				nxt_state = STALL_SIX;
			end
			else 	nxt_state = curr_state;

		end

		STALL_SIX:  begin

			if (!less_than_6) begin

				nxt_state = IDLE;
			end

			else nxt_state = curr_state;
		end

		default : nxt_state = 2'bx;

	endcase

six_entr_state = nxt_state;

end

endfunction
// triquest fsm_end


// End of the change

// triquest fsm_begin
function [4:0]	dribble_state;

// triquest state_vector {curr_state[4:0]} CURR_STATE enum DRIBBLE_STATE_ENUM
input	[4:0]	curr_state;
input		less_than_6;
input		spill_d;
input		ovr_flw_d;
input		und_flw_d;
input		cs_undflw_d;
input		ret_optop_update;
input		zero_entries;
input		zero_entries_c;
input		iu_int;

reg	[4:0]	nxt_state;

parameter // triquest enum DRIBBLE_STATE_ENUM

	IDLE		= 5'b00001,
	STALL_OVR1 	= 5'b00010,
	STALL_OVR2 	= 5'b00100,
	STALL_UND1	= 5'b01000,
	STALL_UND2	= 5'b10000;

begin

	case (curr_state)

		IDLE:	begin

			if (und_flw_d & ret_optop_update) begin
				
				nxt_state = STALL_UND1;
			end
			else if (ovr_flw_d |cs_undflw_d) begin

				nxt_state = STALL_OVR1;
			end 

			else nxt_state = curr_state;
		end

		STALL_UND1:	begin

			if (iu_int) begin

				nxt_state = IDLE;
			end

			else nxt_state = STALL_UND2;
		end

		STALL_UND2:	begin

			if (!less_than_6 | iu_int) begin

				nxt_state = IDLE;
			end

			else nxt_state = curr_state;
		end

		STALL_OVR1:	begin

			if (iu_int) begin
				
				nxt_state = IDLE;
			end
			
			else nxt_state = STALL_OVR2;

		end

		STALL_OVR2:	begin

			if (iu_int) begin

				nxt_state = IDLE;
			end

			else if(zero_entries_c) begin 
				
				nxt_state = STALL_UND2;
			end

// When there's an overflow, we flush out all the dirty entries.
// When we flush out all the dirty entries, if at this  point
// (SBASE - NEW_OPTOP)/4 == (HIGH_WM_MARK), spill_d = 0
// and at this same time SMU_ADDR = OLD_OPTOP, then  
// zero_entries is 1;
// Since zero_entries_c is used in the statemachine because of the 
// timing reasons and since spill_d is low, we go to IDLE state and 
// release the hold.
// But in next state we have sbase updated to new optop value and
// we hold the pipe since the number of entries on stack are zero.
// So, there's one cycle where smu hold goes low which causes problems
// TO fix this we have added the following line. Whereby we'll ignore
// spill_d being zero if zerOentries is asserted and do what zero_entries_c
// does except delayed by one cycle.

			else if (zero_entries & !spill_d) begin

				nxt_state = STALL_UND1;
			end
			else if (!spill_d) begin

			 	nxt_state = IDLE;
			end

			else	nxt_state = curr_state;
		end

		default:	nxt_state = 5'bx;
	endcase


dribble_state = nxt_state;
end

endfunction

// triquest fsm_end
	
			
// A New state called IGN_CS_UND is added. This is because when there's an underflow
// and it's not context switch (ret_optop_update is 1) und_flw_d signal will remain
// high for 2 clock cycles because sbase is updated in thh 2nd clock cyle after und_flw_d
// has occured, while ret_optop_update will be high only for one clock cycle. This may be
// interpreted as a cs_und_flw_d. We need to squash this.

// triquest fsm_begin
function [3:0] cs_spill_state;

// triquest state_vector {curr_state[3:0]} CURR_STATE enum CS_SPILL_STATE_ENUM
input	[3:0]	curr_state;
input		cs_undflw_d;
input		zero_entries;
input		dribble_stall;
input		iu_int;
input		und_flw_d;

reg	[3:0]	nxt_state;

parameter // triquest enum CS_SPILL_STATE_ENUM
	IDLE		= 4'b0001,
	IGN_CS_UND	= 4'b0010,
	SPILL		= 4'b0100,
	WAIT 		= 4'b1000;

begin
	case (curr_state)

		IDLE: 	begin

			if (cs_undflw_d) begin
				
				nxt_state = SPILL;
			end
			else if (und_flw_d) begin
				
				nxt_state = IGN_CS_UND;
			end
			else 	nxt_state = curr_state;
		end

		IGN_CS_UND:  begin

			nxt_state = IDLE;
		end

		SPILL:	begin

			if (iu_int) begin
				nxt_state = IDLE;
			end
			else if (zero_entries) begin
				
				nxt_state = WAIT;
			end
			else	nxt_state = curr_state;
		end

		WAIT:	begin				

			if (!dribble_stall | iu_int) begin
		
				nxt_state = IDLE;
			end
			else	nxt_state = curr_state;
		end
		default:	nxt_state = curr_state;	
	endcase
	cs_spill_state = nxt_state;

end

endfunction
// triquest fsm_end

endmodule

module	comp6_30(

	operand1,
	operand2,
	result,
	signbit
);

input	[5:0]	operand1;
input	[29:0]	operand2;
input		signbit;
output		result;

wire		gr;

comp_gr_6	comparator(.gr(gr),
		.in1(operand2[5:0]),
		.in2(operand1) );

// whenever operand2 is +ve and if any of bits [29:6] is 1 or
// if it's lower 6 bits are greater than operand1, output is 1

assign result = ( !(signbit) &&  ((|operand2[29:6]) || gr) );

endmodule

module	comp30_6(

	operand1,
	operand2,
	signbit,
	result
);

input	[29:0]	operand1;
input	[5:0]	operand2;
input		signbit;
output		result;

wire		gr;

comp_gr_6 	comparator(.gr(gr),
		.in1(operand2),
		.in2(operand1[5:0]) );

assign result  = ( signbit || ( (~|(operand1[29:6])) && gr) ); 

endmodule

module comp3_30 (

	operand1,
	operand2,
	signbit,
	result

);

input	[2:0]	operand1;
input	[29:0]	operand2;
input		signbit;
output		result;

wire		less;

less_comp3	comparator(.less(less),
		.in1(operand2[2:0]),
		.in2(operand1) );

assign result = ( signbit || ( (~|operand2[29:3]) && less) );

endmodule

module less_comp3 (
	in1,
	in2,
	less
);

input	[2:0]	in1;
input	[2:0]	in2;
output		less;


assign less = (in1 < in2);

endmodule
