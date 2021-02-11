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

module	pipe_cntl(

		//OUTPUTS
		inst_vld,
		inst_vld_e_v1,
		sc_dcache_req,
		iu_optop_int_we,
		sc_data_vld,
		icu_data_vld,
		sc_rd_miss_sel,
		squash_fold,	
		lduse_bypass,
		scache_miss,
		lduse_hold,
		rs1_bypass_hold,
		rs2_bypass_hold,
		kill_inst_d,
		kill_inst_e,
		kill_inst_e_int,
		reissue_c,
		fold_c,
		fold_sc_miss_e,
		optop_sel_e,
		optop_sel_c,
		optop_enable,
		pc_enable,
		hold_ucode,
		hold_r,
		hold_e,
		hold_c,
		hold_c_int,
		iu_perf_sgnl,
		rs1_mux_sel_din,
		forward_c_sel_din,

		//INPUTS
		iu_brtaken_e,
		iu_trap_c,
		async_error,
		iu_trap_r,
		trap_vld_r,
		trap_vld_e,
		trap_in_progress,
		inst_vld_r,
		fold_r,
		icu_hold,
		first_cyc_r,
		load_c,
		ucode_stk_rd,
		ucode_done,
		ucode_last,
		ru_byp_rs1_e_hit,
		ru_byp_rs2_e_hit,
		scache_rd_miss_e,
		rs2_bypass_vld,
		rs1_bypass_vld,
		wr_optop_e,
		icu_diag_ld_c,
		iu_data_vld,
		powerdown_op_e,
		clk,
		sm,
		reset_l,
		sin,
		so );





output	[2:0]		inst_vld;		// Valid bit pipeline 2:0 = W,C,E 
output			inst_vld_e_v1;		// quick version for EX
output	[3:0]		optop_sel_e;		// select correct optop
output	[3:0]		optop_sel_c;		// select correct optop
output	[2:0]		optop_enable;		// enable bits for optop pipe
output	[2:0]		pc_enable;		// enable signals for pc pipe
output			sc_dcache_req;		// dcache req on stackcache read miss
output			iu_optop_int_we;	// Write enable to the flop in SMU which
						// generates it's own version of optop
output			sc_data_vld;		// dcache data is due to stackcache read
output			icu_data_vld;		// diagnostic I$ data valid
output			squash_fold;		// disable folding to det trapping instruction
output			sc_rd_miss_sel;		// used for selecting D$ data from S$ miss
output			rs1_bypass_hold;	// hold rs1 data
output			rs2_bypass_hold;	// hold rs2 data
output			lduse_bypass;		// bypass data from D$ on load-use case
input			hold_ucode;		// hold the microcode
input			hold_r;			// Hold R stage flop
input			hold_e;			// Hold E stage flop
input			hold_c;			// Hold C stage flop
input			hold_c_int;		// Hold C stage flop
output			kill_inst_d;		// kill instruction in D stage
output			reissue_c;		// reissue the instruction in C stage
output			fold_sc_miss_e;		// Folded group misses S$
output			fold_c;			// folding group in C stage
output			kill_inst_e;		// kill instruction in E. lduse case/S$ read miss
output			kill_inst_e_int;		// kill instruction in E. lduse case/S$ read miss
output			iu_perf_sgnl;		// performance monitor signals
output			rs1_mux_sel_din;	// Selects scache data for RS1 in case of S$ misses
output			forward_c_sel_din;	// Selects DCU data for forward data_c
output			lduse_hold;
output			scache_miss;

input			iu_brtaken_e;		// branch taken in E
input			iu_trap_c;		// Trap taken in C
input			async_error;		// asynchronous error
input			iu_trap_r;		// Trap in R stage.build frame
input			trap_vld_r;		// Possible trap in R
input			trap_vld_e;		// Possible trap in E
input			trap_in_progress;	//  trap frame building in progress
input			inst_vld_r;		// Valid instruction in R stage
input			fold_r;			// there is a folded group in R
input			icu_hold;		// hold for diagnostic i$ load
input			icu_diag_ld_c;		// Diagnostic ICU load in C stage
input			first_cyc_r;		// multicycle R stage. longs/doubles
input			load_c;			// IU load in E stage
input			ucode_done;		// Microcode is not busy.
input			ucode_stk_rd;		// read stack cache.
input			ucode_last;		// Microcode's last cycle in E stage
input			ru_byp_rs1_e_hit;	// RS1 bypass hit for E stage. used for lduse case
input			ru_byp_rs2_e_hit;	// RS2 bypass hit for E stage. used for lduse case
input			rs2_bypass_vld;		// whether an instruction uses RS2 bypass or not.
input			rs1_bypass_vld;		// whether an instruction uses RS1 bypass or not.
input			scache_rd_miss_e;	// stack cache read miss in E 
input			iu_data_vld;		// data valid from dcache
input			wr_optop_e;		// write to optop register
input			powerdown_op_e;		// powerdown instruction in E
input			clk;			
input			sm;
input			reset_l;
input			sin;
output			so;

wire		ucode_busy_e,ucode_done_c;
wire		inst_vld_e,inst_vld_c,inst_vld_w;
wire		valid_r,valid_e,valid_c;
wire	[2:0]	smiss_state,next_smiss_state;
wire	[2:0]	lduse_state,next_lduse_state;
wire		scmiss_req,scmiss_req_wait,scmiss_wait;
wire		scmiss_idle;
wire	[4:0]	fold_state,next_fold_state;
wire		fold_r_out,fold_e,fold_e_raw,fold_c,fold_c_trapped;
wire		new_inst_r,fold_sc_miss_e,fold_sc_miss_c,sc_rd_miss_e;
wire		load_use;
wire	[2:0]	iu_perf_mon;
wire		hold_e_d1,new_inst_e;
wire		sc_miss_sticky_set,sc_miss_sticky;
wire		fold_c_out;
wire		hold_c_int;
wire		kill_data_vld,set_kill_data_vld,data_vld;
wire		fold_trapped;


// Instruction Valid Pipeline 
// Squash R stage valid bit on a branch ,trap ,reissue or a possible trap in R or E.
// squash E stage valid bit on a trap or reissue.
// squash C stage valid bit on a trap or reissue. the instruction is retired when
// microcode finishes building trap frame.
// If there is a hold and a valid instruction is in C, it moves
// into the W stage only after the hold_c is inactive.
// Thus, in the W stage any instruction will be there only for one cycle.
// iu_trap_r is treated just like a new instruction in R stage.

assign	valid_r	=	(iu_trap_r|inst_vld_r)&~iu_trap_c&~iu_brtaken_e&~fold_sc_miss_e&
			~trap_vld_r&~trap_vld_e&~fold_sc_miss_c&~powerdown_op_e&(~hold_r|first_cyc_r);
ff_sre		vld_e_reg(.out(inst_vld_e),.din(valid_r),.clk(clk),
			.reset_l(reset_l),.enable(~hold_e|iu_trap_c|fold_sc_miss_c));

ff_sre          vld_e_v1_reg(.out(inst_vld_e_v1),.din(valid_r),.clk(clk),
                        .reset_l(reset_l),.enable(~hold_e|iu_trap_c|fold_sc_miss_c));
 


// if ucode is in E stage, the valid bit is still propagated down the pipe.
// bcos, ucode takes over the ECW part of the pipe.(stores to S$,D$ accesses)
// need to use ucode_last also,bcos ucode_done is not high for last cycle of ucode.
// But dont propagate valid bits if ucode is held up. this generates unnecessary
// valid bits causing cosim to go beserk.
assign	ucode_busy_e = (~ucode_done | ucode_last)&~hold_ucode;
assign	valid_e =	inst_vld_e&~iu_trap_c&~fold_sc_miss_c&(~hold_e| ucode_busy_e);
ff_sre          vld_c_reg(.out(inst_vld_c),.din(valid_e),.clk(clk),
                        .reset_l(reset_l),.enable(~hold_c |iu_trap_c|fold_sc_miss_c));

assign	valid_c =	inst_vld_c&~hold_c&~iu_trap_c&~fold_sc_miss_c ;
ff_sr          vld_w_reg(.out(inst_vld_w),.din(valid_c),.clk(clk),
                        .reset_l(reset_l));
 

// We do not use trap_vld_r to kill instruction in D bcos,it is
// possible for an instruction(emul_op_r) to kill itself and no trap would be
// taken (especially when there is hold_e)
assign	kill_inst_d =	iu_brtaken_e | fold_sc_miss_e| fold_sc_miss_c 
			| trap_vld_e | trap_in_progress | powerdown_op_e;

// kill any dcu requests when there is a lduse hold 
// or scache read miss 
assign	kill_inst_e     =   lduse_hold|scmiss_req;

// kill prive writes&imdr when there is a lduse hold or 
//scache read miss 
assign	kill_inst_e_int =   lduse_hold|scache_miss;

assign	inst_vld[2]=	inst_vld_w;
assign	inst_vld[1]=	inst_vld_c;
assign	inst_vld[0]=	inst_vld_e;


// Bypass Hold signal for Ex block.
// Hold rs1 data if e stage is held except when a lduse case or
// scache miss or ucode stkread occurs.

// Hold rs2 data if e stage is held except for lduse case.
wire lduse_byp_vld =  load_use&iu_data_vld|lduse_state[0] | lduse_state[1] ;

// moved bypass signals from RCU ro ex_dpath and latched those signals
// in ex_dpath, so we need to latch them in pipe too 

ff_sre       flop_bypass_rs1_hit(.out(ru_byp_rs1_e_hit_e),
                             .din(ru_byp_rs1_e_hit),
                             .clk(clk),
                             .enable(!(hold_e & !ucode_stk_rd)),
                             .reset_l(reset_l));

// assign	rs1_bypass_hld = hold_e&~(ucode_stk_rd&~hold_c)&~scmiss_req&
//			  ~(lduse_byp_vld&ru_byp_rs1_e_hit);

assign	rs1_bypass_hold = hold_e&~(ucode_stk_rd&~hold_c)&~scmiss_req&
			  ~(lduse_byp_vld&ru_byp_rs1_e_hit_e);

ff_sre       flop_bypass_rs2_hit(.out(ru_byp_rs2_e_hit_e),
                             .din(ru_byp_rs2_e_hit),
                             .clk(clk),
                             .enable(!hold_e),
                             .reset_l(reset_l));

// assign	rs2_bypass_hld = hold_e&~(lduse_byp_vld&ru_byp_rs2_e_hit_e);

assign	rs2_bypass_hold = hold_e&~(lduse_byp_vld&ru_byp_rs2_e_hit_e);


		      

// The above two lines and the following flop is commented out so as to
// let ex_dpath latch these select signals in ex_dpath itself. This is done
// to improve timing on RS1 and RS2 signals 

// ff_sr_2	 bypass_hold_reg (.out({rs1_bypass_hold,rs2_bypass_hold}),
// 			.din({rs1_bypass_hld,rs2_bypass_hld}),
// 			.clk(clk),
// 			.reset_l(reset_l));
	


// Stack cache read miss logic
// the DRE stage is held till the read miss data is fetched from
// Dcache and put into the RS1 register.
// go into the scmiss_req state if there is a scache_rd_miss_e & there is no hold.
// get out of req state once data_vld is available. but,wait in the wait state
// till hold_c is not there. this avoids deadlock case.hold_e->sc_miss_rd->hold_e
// If a trap occurs during a read from D$, reset the state m/c.
// Also, since hold_c has the scache_miss term during ucode, we need
// to ignore that part of hold for this state m/c to prevent deadlock.

assign  next_smiss_state[2:0]    =       smiss_state_fn(smiss_state[2:0],
                                        sc_rd_miss_e,
                                        hold_c_int,
					(iu_trap_c|fold_sc_miss_c),
                                        iu_data_vld);
 
// triquest state_vector smiss_state[2:0] SMISS_STATE enum SMISS_STATE_ENUM
ff_sr_3        smiss_state_reg( .out(smiss_state[2:0]),
                                .din(next_smiss_state[2:0]),
                                .clk(clk),
                                .reset_l(reset_l));

// The following signals are added to improve timing on RS1 signal.
// Idea is to latch all the select signals with in ex_dpath itself
// This way we can eleiminated routing delay from pipe 

assign	forward_c_sel_din = 	next_lduse_state[2];
assign	rs1_mux_sel_din = 	next_smiss_state[2];

 

function [2:0]	 smiss_state_fn;
input	[2:0]	 cur_state;
input		 sc_rd_miss_e;
input		 hold_c;
input		 iu_trap_c;
input		 iu_data_vld;

reg	[2:0]	next_state;

parameter // triquest  enum SMISS_STATE_ENUM
	IDLE		= 3'b000,
	SMISS_REQ_WAIT	= 3'b001,
	SMISS_REQ  	= 3'b010,
	SMISS_WAIT 	= 3'b100;

begin

case	(cur_state)	// synopsys full_case parallel_case
	IDLE:	begin
		if(sc_rd_miss_e&~iu_trap_c&~hold_c) begin
		next_state = SMISS_REQ;
		end
		else if(sc_rd_miss_e&~iu_trap_c&hold_c) begin
		next_state = SMISS_REQ_WAIT;
		end
		else next_state = cur_state ;
        end

	SMISS_REQ_WAIT:begin
		if(~hold_c&~iu_trap_c) begin
		next_state = SMISS_REQ;
		end
		else if(iu_trap_c) begin
		next_state = IDLE;
		end
		else next_state = cur_state;
	end

	SMISS_REQ: begin
		if(iu_data_vld) begin
		next_state = SMISS_WAIT;
		end
		else if(iu_trap_c) begin
		next_state = IDLE;
		end
		else next_state = cur_state ;
        end


	SMISS_WAIT: begin
                if(~hold_c) begin
                next_state = IDLE;
                end
		else if(iu_trap_c) begin
                next_state = IDLE;
                end
                 else next_state = cur_state ;
        end

 	default:        next_state = 3'bx;
endcase
smiss_state_fn = next_state ;
end
endfunction

assign	scmiss_idle	=	~(|smiss_state[2:0]);
assign	scmiss_req_wait =	smiss_state[0];
assign	scmiss_req 	=	smiss_state[1];
assign	scmiss_wait 	=	smiss_state[2];



// Usually scache_rd_miss_e is high only for 1 cycle, but if
// there is hold and scache_rd_miss_e in the same cycle,we get
// into a deadlock. To avoid it, need to qualify scache_rd_miss_e
// with scache state m/c not idle. 

assign	sc_rd_miss_e	=   scache_rd_miss_e&inst_vld[0]&~fold_e&scmiss_idle;
assign	scache_miss	=   sc_rd_miss_e | scmiss_req_wait |scmiss_req;
assign	sc_dcache_req	=   scache_rd_miss_e | scmiss_req_wait;
assign	sc_data_vld	=   scmiss_req;
assign	sc_rd_miss_sel  =   scmiss_wait;


// Load - Use Hold generation.
// When there is a load in C and use in E, a load-use condition is triggered.
// the data is bypassed to E stage when the load data is available in W stage.
// This state machine needs to be in sync with the load buffer. Thus, if
// there is a hold_c, we still need to keep track of loaduse even after
// data_valid has been recieved. Thus,only when the load goes into W stage,
// data is bypassed to E stage.

 ff_sr hold_e_reg(.out    (hold_e_d1),
                  .din    (hold_e),
                  .reset_l (reset_l),
                  .clk    (clk));
assign new_inst_e = ~hold_e_d1 & inst_vld[0];
assign	load_use	=   (ru_byp_rs1_e_hit_e&rs1_bypass_vld |ru_byp_rs2_e_hit_e&rs2_bypass_vld)&
			     load_c&inst_vld_c&new_inst_e;

assign	lduse_bypass	=  lduse_state[2];
assign	lduse_hold	=  load_use | lduse_state[0] | lduse_state[1] ;

// For latching Diagnostic ICU data, we generate a icu_data_vld. this
// is similar to iu_data_vld generated by dcu. But, because ICU has no
// concept of smu hold, we need to generate a single cycle pulse to latch
// icu data for diagnostic reads. Thus,even if there is hold_c,icu_data_vld
// is one a cycle cycle pulse.
assign	data_vld	=  icu_diag_ld_c&~icu_hold;
assign	set_kill_data_vld = data_vld&hold_c | kill_data_vld&hold_c ;
ff_sr	kill_dv_reg(.out(kill_data_vld),
		    .din(set_kill_data_vld),
		    .clk(clk),
		    .reset_l(reset_l));

assign	icu_data_vld	=  data_vld&~kill_data_vld;


assign  	next_lduse_state[2:0]    =       lduse_state_fn(lduse_state[2:0],
                                        load_use,
                                        hold_c,
                                        (iu_trap_c|fold_sc_miss_c),
                                        (icu_data_vld|iu_data_vld) );
 
// triquest state_vector lduse_state[2:0] LDUSE_STATE enum LDUSE_STATE_ENUM
ff_sr_3        lduse_state_reg( .out(lduse_state[2:0]),
                                .din(next_lduse_state[2:0]),
                                .clk(clk),
                                .reset_l(reset_l));
 

function [2:0]   lduse_state_fn;
input   [2:0]    cur_state;
input            load_use;
input            hold_c;
input            iu_trap_c;
input            iu_data_vld;
 
reg     [2:0]   next_state;
 
parameter	// triquest enum LDUSE_STATE_ENUM
        IDLE            = 3'b000,
        LDUSE_WAIT  	= 3'b001,
        LDUSE_HOLD      = 3'b010,
	LDUSE_BYP	= 3'b100;
 
begin
 
case    (cur_state)     // synopsys full_case parallel_case
        IDLE:   	begin
                	if(load_use&~iu_data_vld&~iu_trap_c) begin
                	next_state = LDUSE_WAIT;
               		end
			else if(load_use&iu_data_vld&~hold_c&~iu_trap_c) begin
			next_state = LDUSE_BYP;
			end
			else if(load_use&iu_data_vld&hold_c&~iu_trap_c) begin
			next_state = LDUSE_HOLD;
			end
                	else next_state = cur_state ;
        end

	LDUSE_WAIT: 	begin
			if(iu_trap_c) begin
			next_state = IDLE;
			end
			else if(iu_data_vld&~hold_c) begin
			next_state = LDUSE_BYP ;
			end
			else if(iu_data_vld&hold_c) begin
			next_state = LDUSE_HOLD;
			end
			else next_state = cur_state;
	end

	LDUSE_HOLD:	begin
			if(iu_trap_c) begin
			next_state = IDLE;
			end
			else if(~hold_c) begin
			next_state = LDUSE_BYP;
			end
			else next_state = cur_state;
	end
			
	LDUSE_BYP:	begin
			next_state = IDLE;
			end

   	default:        next_state = 3'bx;
	endcase
 
lduse_state_fn = next_state ;
end
endfunction



// Peformance Monitor stuff
ff_sr  iu_perf_reg(.out(iu_perf_sgnl),
			.din(iu_brtaken_e),
			.clk(clk),
			.reset_l(reset_l));



// OPTOP Selects generation
assign  optop_sel_e[3]       =       ~reset_l ;
assign  optop_sel_e[2]       =       iu_trap_c|fold_sc_miss_c;
assign  optop_sel_e[1]       =       wr_optop_e;
assign  optop_sel_e[0]       =       ~optop_sel_e[3]&~optop_sel_e[2]&~optop_sel_e[1];  

// OPTOP Selects generation
assign  optop_sel_c[3]       =       ~reset_l ;
assign  optop_sel_c[2]       =       iu_trap_r|fold_sc_miss_c;
assign  optop_sel_c[1]       =       wr_optop_e;
assign  optop_sel_c[0]       =       ~optop_sel_c[3]&~optop_sel_c[2]&~optop_sel_c[1];




// Enable for updating optop
ff_sre          ucode_done_reg(.out(ucode_done_c),.din(ucode_done),.clk(clk),
                        .reset_l(reset_l),.enable(~hold_c));
 

// Recirculate optop register. use shadow optop

 
 
assign	optop_enable[0]	=(inst_vld_r|iu_trap_r)&~iu_brtaken_e&~hold_e | wr_optop_e&~hold_ucode | fold_sc_miss_c | 
			iu_trap_c | ~reset_l;
assign	optop_enable[1]	= ~hold_ucode ;
assign	optop_enable[2]	=valid_c&ucode_done_c	; 

// This signal is used as an enable signal to the flop in SMU, which
// generates it's own version of optop. This is done to improve timing on
// smu_stall: 

assign	iu_optop_int_we	= optop_enable[1];


// Enable for PC Pipe

assign	pc_enable[0]		=	~hold_r;
assign	pc_enable[1]		=	~hold_e;
assign	pc_enable[2]		=	~hold_c&~trap_in_progress&~fold_sc_miss_c;



// Folding Pipe

assign	fold_r_out	=	fold_r&inst_vld_r;

ff_sre	fold_e_reg(.out(fold_e_raw),
		.din(fold_r_out),
		.clk(clk),
		.reset_l(reset_l),
		.enable(~hold_e));

// Check folding related logic only for 1st cycle of E stage.
// for ucode. if a ucode instruction is folded but later ucode accesses
// S$ causing S$ miss, it should not generate reissue logic. 
assign	fold_e	=	fold_e_raw&ucode_done_c;

assign	fold_c		=  fold_c_out&inst_vld_c;
ff_sre  fold_c_reg(.out(fold_c_out),
                .din(fold_e_raw&inst_vld_e),
                .clk(clk),
                .reset_l(reset_l),
                .enable(~hold_c));


// Reissue instruction if a folded group traps or a folded
// group misses stackcache.
// In case of stackcache miss, kill ucode,kill fpu and 
// disable valid bit C. Since scache_rd_miss_e is active
// only for one cycle even when there is a hold, we need
// to have a sticky bit for keeping track of sc_miss_e.

assign	sc_miss_sticky_set =   scache_rd_miss_e&hold_e&inst_vld[0] | sc_miss_sticky&hold_e;
ff_sr	sc_sticky_reg(.out(sc_miss_sticky),
			.din(sc_miss_sticky_set),
			.clk(clk),
			.reset_l(reset_l));

assign	fold_sc_miss_e =	fold_e&(scache_rd_miss_e&inst_vld[0]|sc_miss_sticky);


ff_sre  fold_sc_reg(.out(fold_sc_miss_c),
                .din(fold_sc_miss_e),
                .clk(clk),
                .reset_l(reset_l),
                .enable(~hold_c));
 
// Reissue instructions 
// for trapped folded group, branch in W stage. timing reasons
 assign	reissue_c	= fold_trapped | fold_sc_miss_c ;

ff_sr  fold_trapped_reg(.out(fold_trapped),
                .din(fold_c_trapped),
                .clk(clk),
                .reset_l(reset_l));


// Squash folding 
// If there is a trap of a folded group, disable folding
// for the next 3 instructions.

assign	fold_c_trapped	=	fold_c&inst_vld_c&iu_trap_c&~async_error;
assign	new_inst_r	=	inst_vld_r&~hold_r;
assign  next_fold_state[4:0]    =       fold_state_fn(fold_state[4:0],
                                        fold_c_trapped,
                                        new_inst_r);

// triquest state_vector {fold_state[4:1],fold_state[0]} FOLD_STATE enum FOLD_STATE_ENUM
ff_sr_4 fold_state_reg( .out(fold_state[4:1]),
                                .din(next_fold_state[4:1]),
                                .clk(clk),
                                .reset_l(reset_l));
 
ff_s            fold_state_reg_0(.out(fold_state[0]),
                                .din(~reset_l | next_fold_state[0]),
                                .clk(clk));
assign	squash_fold	=	~fold_state[0] ;


function [4:0] fold_state_fn ;
 
input   [4:0]  cur_state ;
input          fold_c_trapped ;
input		new_inst_r;

reg	[4:0]	next_state;
//State Encoding
parameter	// triquest enum FOLD_STATE_ENUM
	IDLE		=	5'b00001,
	TRAP_STATE 	=	5'b00010,
	NONFOLD_1 	=	5'b00100,
	NONFOLD_2 	=	5'b01000,
	NONFOLD_3 	=	5'b10000;
	
begin

case (cur_state)		//synopsys full_case parallel_case

IDLE:	begin
	if (fold_c_trapped) begin
	next_state = TRAP_STATE;
	end
 	else    next_state = cur_state ;
        end


TRAP_STATE: begin
	if(new_inst_r) begin
	next_state = NONFOLD_1;
        end
        else    next_state = cur_state ;
        end
	
	
NONFOLD_1: begin
        if(new_inst_r) begin    
        next_state = NONFOLD_2;    
        end    
        else    next_state = cur_state ;       
        end    


NONFOLD_2: begin
        if(new_inst_r) begin    
        next_state = NONFOLD_3;    
        end    
        else    next_state = cur_state ;       
        end    
 
NONFOLD_3: begin
        if(new_inst_r) begin    
        next_state = IDLE;    
        end    
        else    next_state = cur_state ;       
        end    

	default:        next_state = 5'bx;
endcase

fold_state_fn = next_state ;
end
endfunction

mj_spare spare( .clk(clk),
                .reset_l(reset_l));
 
endmodule

