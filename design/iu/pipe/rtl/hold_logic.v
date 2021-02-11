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

module	hold_logic(

		//OUTPUTS
		hold_ucode,
		hold_fpu,
		hold_ex_fpu,
		hold_imdr,

		hold_ifu_d,
		hold_ifu_r,
		hold_ifu_e,
		hold_ifu_c,

		hold_pipe_r,
		hold_pipe_e,
		hold_pipe_c,

		hold_rcu_e,
		hold_rcu_c,
		hold_rcu_ucode,

		hold_trap_r,
		hold_trap_e,
		hold_trap_c,

		hold_ex_ctl_e,
		hold_ex_ctl_c,

		hold_ex_regs_e,
		hold_ex_regs_c,

		hold_ex_dp_e,
		hold_ex_dp_c,

		hold_pipe_c_int,
		perf_sgnl,

		//INPUTS
		dcu_stall,
		icu_hold,
		imdr_done_e,
		fp_rdy_e,
		first_cyc_r,
		first_vld_c,
		smu_hold,
		scache_miss,
		lduse_hold,
		powerdown_op_e,
		kill_powerdown,
		u_done_l,
		pj_in_halt,
		pj_halt,
		clk,
		reset_l,
		sm,
		si,
		so
		);



output 	  	hold_ucode;
output          hold_fpu;
output          hold_ex_fpu;
output          hold_imdr;
 
output          hold_ifu_d;
output          hold_ifu_r;
output          hold_ifu_e;
output          hold_ifu_c;
 
output          hold_pipe_r;
output          hold_pipe_e;
output          hold_pipe_c;
 
output          hold_rcu_e;
output          hold_rcu_c;
output          hold_rcu_ucode;
 
output          hold_trap_r;
output          hold_trap_e;
output          hold_trap_c;
 
output          hold_ex_ctl_e;
output          hold_ex_ctl_c;
 
output          hold_ex_regs_e;
output          hold_ex_regs_c;
 
output          hold_ex_dp_e;
output          hold_ex_dp_c;
 
output          hold_pipe_c_int;
output	[1:0]	perf_sgnl;
 

input			dcu_stall;		// D$ stall. hold for load data
input			icu_hold;		// hold for diagnostic i$ load
input			imdr_done_e;		// mul/div/rem unit not busy
input			smu_hold;		// smu holds the pipe.
input			scache_miss;		// stack cache miss.
input			lduse_hold;		// load use bubble.
input			fp_rdy_e;		//  fpu is ready for next inst
input			powerdown_op_e;		//  powerdown operation
input			kill_powerdown;		//  remove powerdown hold
input			u_done_l;		// Microcode is busy.
input			pj_halt;		// external signal to halt processor
input			pj_in_halt;		// halt processor due to brkpoint match
input			first_cyc_r;		// Multicycle R stage inst
input			first_vld_c;		//  FPU valid in C stage
input			clk;
input			reset_l;
input			si;
input			sm;
output			so;

wire hold_d,hold_e,hold_c;
wire	powerdown_hold;
wire first_cyc_e, fp_hold_d1,fp_hold;

// For floating pt doubles, we delay the fpu hold for a clk.
// this allows the fp operation to occupy C and E stages of
// the pipe.when the hold goes away, the data is picked up
// in the C stage.
// In case of single precision fp, the fpu op is held in E
// stage.and the data is still picked up in the C stage

ff_sre  first_cyc_e_reg(.out(first_cyc_e),.din(first_cyc_r),.clk(clk),
                .reset_l(reset_l),.enable(~hold_e));
ff_sre  fphold_reg(.out(fp_hold_d1),.din(~fp_rdy_e),.clk(clk),
                .enable(~hold_fpu),.reset_l(reset_l));
assign  fp_hold = (first_vld_c|first_cyc_e)?fp_hold_d1:~fp_rdy_e;

// If powerdown instruction in E, hold the pipe. when interrupts occurs release hold
assign   powerdown_hold =  powerdown_op_e&~kill_powerdown;
 

// performance measuring signals
ff_sr_2 iu_perf_reg(.out(perf_sgnl[1:0]),
                        .din({hold_e,hold_fpu}),
                        .clk(clk),
                        .reset_l(reset_l));


assign	hold_ucode =    dcu_stall | icu_hold| smu_hold | powerdown_hold	|pj_in_halt|
			~imdr_done_e | scache_miss|lduse_hold | fp_hold | pj_halt ;

assign	hold_fpu   =    dcu_stall | icu_hold| smu_hold | powerdown_hold	|
 			~imdr_done_e | scache_miss|lduse_hold | u_done_l 
			| pj_halt|pj_in_halt;

assign	hold_ex_fpu =   hold_fpu;

assign	hold_imdr  =    dcu_stall | icu_hold| smu_hold | pj_halt| pj_in_halt;


assign	hold_ifu_d 	= dcu_stall 	| 
			icu_hold  	| 
			~imdr_done_e 	| 
			fp_hold 	| 
			smu_hold 	|
			scache_miss	|
			lduse_hold	|
			first_cyc_r	|
			pj_in_halt	|
			pj_halt		|
			powerdown_hold	|
			u_done_l	;

assign  hold_d      	= dcu_stall     |
                        icu_hold        |
                        ~imdr_done_e    |
                        fp_hold         |
                        smu_hold        |
                        scache_miss     |
                        lduse_hold      |
                        first_cyc_r     |
                        pj_in_halt      |
                        pj_halt         |
                        powerdown_hold  |
                        u_done_l     ;
 


assign          hold_ifu_r = hold_d ;
assign          hold_pipe_r= hold_d ;
assign          hold_trap_r = hold_d;

assign          hold_ifu_e = hold_e;
assign          hold_ifu_c = hold_c;
 
assign          hold_pipe_e = hold_e;
assign          hold_pipe_c = hold_c;
 
assign          hold_rcu_e = hold_e;
assign          hold_rcu_c = hold_c;
assign          hold_rcu_ucode = hold_ucode;
 
assign          hold_trap_e = hold_e;
assign          hold_trap_c = hold_c;
 
assign          hold_ex_ctl_e = hold_e;
assign          hold_ex_ctl_c = hold_c;
 
assign          hold_ex_regs_e = hold_e;
assign          hold_ex_regs_c = hold_c;
 
assign          hold_ex_dp_e = hold_e;
assign          hold_ex_dp_c = hold_c;
 

			

assign	hold_e	=	dcu_stall	|
			icu_hold	|
			~imdr_done_e	|
			fp_hold		|
			smu_hold	|
			scache_miss	|
			lduse_hold	|
			pj_in_halt	|
			pj_halt		|
			powerdown_hold	|
			u_done_l	;
				

// Hold the C stage for fpu only for doubles. because,the fpu dest occupies
// c and e stages of the pipe.
// during microcode, if there is a S$ miss, we need to hold up the 
// entire pipe,because ucode cannot accept any data from C or W stage.
// Thus,even though scache_miss is an E stage event,in case of
// ucode s$ miss,we still hold up the C stage.
assign	hold_c	=	dcu_stall		|
			icu_hold		|
			pj_halt			|
			pj_in_halt		|
			fp_hold	&first_vld_c	|
			scache_miss&u_done_l |
			smu_hold	;

// used only for S$ read misses.
// to avoid deadlock case when ucode S$ accesses miss S$
// If there is a lduse case and a scache miss at the 
// same time, we hold the scmiss state m/c till the
// lduse case goes away. then a d$ request is issued
// to dcu. 

assign	hold_pipe_c_int =	dcu_stall               |
                        icu_hold                |
                        pj_halt                 |
                        pj_in_halt              |
                        lduse_hold    		|
			smu_hold;	



endmodule
