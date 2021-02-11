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

module	trap (

		iu_trap_c,
		trap_vld_r,
		trap_vld_e,
		trap_in_progress,
		iu_kill_fpu,
		iu_kill_ucode,
		iu_kill_dcu,
		kill_powerdown,
		iu_trap_r,
		tt_we,
		tt_c,
		pj_in_halt,
		pj_brk1_sync,
		pj_brk2_sync,
		pj_resume,
		pj_irl,
		pj_nmi,
		pj_no_fpu,
		ucode_abort,
		iu_psr_pil,
		iu_psr_ie,
		iu_psr_fpe,
		hold_r,
		iu_psr_ace,
		iu_psr_aem,
		inst_brk1_r,
		inst_brk2_r,
		first_cyc_e,
		inst_vld_c,
		imem_acc_err_r,
		illegal_r,
		priv_inst_r,
		fpu_inst_r,
		zero_trap_e,
		soft_trap_r,
		arithm_exe_e,
		null_ptr_exe_e,
		lock_trap_e,
		u_ref_null_c,
		u_ary_ovf_c,
		u_ptr_un_eq_c,
		dcu_err_ack,
		async_mem_prot_err,
		async_error,
		mem_prot_err_c,
		data_brk1_c,
		data_brk2_c,
		oplim_trap_c,
		align_err_c,
		emul_op_r,
		gc_trap_c,
		opcode_c,
		fold_c,
		fold_sc_miss_e,
		powerdown_op_e,
		brk12c_halt,
		iu_brtaken_e,
		ucode_done,
		ucode_last,
		hold_e,
		hold_c,
		clk,
		reset_l,
		sm,
		sin,
		so

);


output	[7:0]		tt_c;			// TT field of Trapbase Reg
output			tt_we;			// TT field write enable
output			iu_trap_c;		// Trap taken in C stage
output			trap_vld_r;		// possible trap in R stage
output			trap_vld_e;		// possible trap in E stage
output			trap_in_progress;	// trap frame building in progress
output			iu_trap_r;		// request for ucode to build trap
output			iu_kill_fpu;		// kill any fpu operation
output			iu_kill_ucode;		// kill any ucode op.
output			iu_kill_dcu;		// kill any dcu operation in C
output			kill_powerdown;		// kill the powerdown hold
output			pj_brk1_sync;		// breakpoint 1
output			pj_brk2_sync;		// breakpoint 2
output			pj_in_halt;		// in halt mode.
output			async_error;		// asynchronous error

input			pj_resume;		// resume the processor
input	[3:0]		pj_irl;			// interrupt level
input			pj_nmi;			// nmi interrupt
input			pj_no_fpu;		// fpu not present in core
input	[3:0]		iu_psr_pil;		// processor interrupt level
input			iu_psr_ie;		// Interrupt enable bit
input			hold_r;			// Hold the R stage trap
input			ucode_abort;		// abort dcu/stack read/write
input			iu_psr_ace;		// address compare enable bit
input			iu_psr_fpe;		// fpu enable bit
input			iu_psr_aem;		// memory protection check bit
input			inst_brk1_r;		// instr brk point 1 in R
input			inst_brk2_r;		// instr brk point 2 in R
input			first_cyc_e;		// First cyle in Estage of 2 cycle instn.
input			inst_vld_c;		// Instruction valid in CStage
input			imem_acc_err_r;		// instruction memory error in R
input			illegal_r;		// illegal inst in R
input			soft_trap_r;		// softtrap in R
input			priv_inst_r;		// privileged inst in R
input			fpu_inst_r;		// fpu instr in R
input			zero_trap_e;		// zeroline trap in E stage
input			null_ptr_exe_e;		// null ptr exception
input			arithm_exe_e;		// arithmatic exception
input	[3:0]		lock_trap_e;		// lock trap
input			u_ref_null_c;		// ucode exception.reference null
input			u_ary_ovf_c;		// array overflow exception
input			u_ptr_un_eq_c;		// ptr unequal exception.ucode
input	[2:0]		dcu_err_ack;		// dcache memory error
input			async_mem_prot_err;	// Memory protection error due to smu
input			mem_prot_err_c;		// Memory protection error
input			powerdown_op_e;		// powerdown inst in E
input			data_brk1_c;		// data brk point in C
input			data_brk2_c;		// data brk point in C
input			oplim_trap_c;		// oplim trap in C
input			align_err_c;		// Misaligned trap in C
input			emul_op_r;		// emulated inst in R
input			gc_trap_c;		// Garbage collection trap
input	[7:0]		opcode_c;		// opcode in C stage
input			fold_c;			// folded group in C stage
input			fold_sc_miss_e;		// folded group missed in E stage
input			iu_brtaken_e;		// branch taken in E stage
input			brk12c_halt;		// on a brkpoint,halt the processor
input			ucode_done;		// ucode has completed execution
input			ucode_last;		// last cycle of ucode


input			hold_e;			// hold E stage flop
input			hold_c;			// hold / stage flop
input			clk;
input			reset_l;
input			sm;
input			sin;
output			so;



wire	irl_r,irl_e,irl_c,nmi_e,nmi_c,irl_r_out,nmi_r_out;
wire	inst_brk1_e,inst_brk2_e,inst_brk2_c,inst_brk1_c;
wire	br_c;
wire	trap_state,new_trap;
wire	imem_acc_err_e,imem_acc_err_c;
wire	ill_inst_e,ill_inst_c;
wire	fpu_unimp_r,fpu_unimp_e,fpu_unimp_c;
wire	zero_trap_c;
wire	[3:0]	lock_trap_c;
wire	lock_ov_trap_c,lock_enter_trap_c,lock_exit_trap_c,lock_release_trap_c;
wire	brk1_c,brk2_c;
wire   	dcu_async_err, mem_prot_err,brk1,brk2,imem_acc_err,ill_inst,priv_inst; 
wire  	oplim_trap,align_err,dmem_acc_err,femul,iemul_op,java_vm_err,gc_trap;
wire  	pj_nmi_prio,any_irl;
wire	nmi_r,priv_inst_e,priv_inst_c,emul_op_e,emul_op_c,arithm_exe_c;
wire	null_ptr_exe_c,java_vm_err_c;
wire	dcu_io_err_c,dcu_mem_err_c;
wire	[15:0]	trap_vec_c;
wire	soft_trap_c,soft_trap_e;
wire	[7:0]	other_tt_c;
wire	trap_vld_c, trap_vld_c_raw, trap_vld_r_new,trap_vld_e_new;
wire	trap_in_c,trap_in_w;
wire	irl_d,irl_d_new,nmi_d_new;
wire	halt;
wire	dcu_async_err_c,brtaken_c;
wire	async_mem_prot_error;
wire	new_brtaken_e;
wire [3:0] pj_irl_r,pj_irl_e,pj_irl_c;
wire	fast_trap;
wire 	inst_brk1_r_new;
wire 	inst_brk2_r_new;



// Interrupt Pipe
// Treat Interrrupts like instructions. Interrupts will enter the pipe in D stage.
// they propagate down the pipe till the C stage and trap in taken in C stage.
// In case of powerdown instruction in E,even though there is a hold_r,propagate
// the irl ,so the interrupt is taken immediately after powerdown inst.

assign  irl_d= (|pj_irl[3:0]);
assign	irl_d_new = irl_d&~trap_in_progress&~iu_brtaken_e&~br_c;
assign	nmi_d_new = pj_nmi&~trap_in_progress&~iu_brtaken_e&~br_c;

ff_sre  irl_r_reg(.out(irl_r_out),.din(irl_d_new),.clk(clk),.reset_l(reset_l),
	.enable(~hold_r|trap_in_progress|iu_brtaken_e|powerdown_op_e));
assign  irl_r = irl_r_out& (pj_irl_r[3:0]>iu_psr_pil[3:0])&iu_psr_ie;
assign  nmi_r = nmi_r_out&iu_psr_ie;

ff_sre	irl_e_reg(.out(irl_e),.din(irl_r)    ,.clk(clk),.reset_l(reset_l),.enable(~hold_e));
ff_sre	irl_c_reg(.out(irl_c),.din(irl_e)    ,.clk(clk),.reset_l(reset_l),.enable(~hold_c));

ff_sre_4 pj_irl_r_reg(.out(pj_irl_r),
			.din(pj_irl),
			.clk(clk),
			.enable(~hold_r | powerdown_op_e|trap_in_progress|iu_brtaken_e),
			.reset_l(reset_l));

ff_sre_4 pj_irl_e_reg(.out(pj_irl_e),
                        .din(pj_irl_r),
                        .clk(clk),
                        .enable(~hold_e),
                        .reset_l(reset_l));
 
ff_sre_4 pj_irl_c_reg(.out(pj_irl_c),
                        .din(pj_irl_e),
                        .clk(clk),
                        .enable(~hold_c),
                        .reset_l(reset_l));
 

ff_sre	nmi_r_reg(.out(nmi_r_out),.din(nmi_d_new),.clk(clk),.reset_l(reset_l),
	.enable(~hold_r|trap_in_progress|iu_brtaken_e|powerdown_op_e));
ff_sre	nmi_e_reg(.out(nmi_e),.din(nmi_r)    ,.clk(clk),.reset_l(reset_l),.enable(~hold_e));
ff_sre	nmi_c_reg(.out(nmi_c),.din(nmi_e)    ,.clk(clk),.reset_l(reset_l),.enable(~hold_c));

assign	kill_powerdown = irl_r | nmi_r ;

// Instruction Break point pipe


// Kill the breakpoint if previous instn. is branch or trap

assign inst_brk1_r_new = inst_brk1_r & ~iu_brtaken_e & ~trap_in_progress & ~br_c;
assign inst_brk2_r_new = inst_brk2_r & ~iu_brtaken_e & ~trap_in_progress & ~br_c;

ff_sre  inst_brk1_e_reg(.out(inst_brk1_e),.din(inst_brk1_r_new),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  inst_brk2_e_reg(.out(inst_brk2_e),.din(inst_brk2_r_new),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  inst_brk1_c_reg(.out(inst_brk1_c),.din((inst_brk1_e & !hold_e)),.clk(clk),
	.reset_l((reset_l & !pj_resume)),.enable(!hold_c));
ff_sre  inst_brk2_c_reg(.out(inst_brk2_c),.din((inst_brk2_e & !hold_e)),.clk(clk),
	.reset_l((reset_l & !pj_resume)),.enable(!hold_c));


// Instruction & data break points
assign	brk1_c = (inst_brk1_c&trap_vld_c | data_brk1_c)&~brk12c_halt ;
assign	brk2_c = (inst_brk2_c&trap_vld_c | data_brk2_c)&~brk12c_halt ;


ff_sre first_cyc_c_reg(.out     (first_cyc_c),
                        .din     (first_cyc_e),
                        .enable  (~hold_c),
                        .reset_l (reset_l),
                        .clk     (clk)
                        );

assign	pj_brk1_sync = (inst_brk1_c&(trap_vld_c| (brk12c_halt & inst_vld_c)) | data_brk1_c) & ~first_cyc_c;
assign	pj_brk2_sync = (inst_brk2_c&(trap_vld_c| (brk12c_halt & inst_vld_c)) | data_brk2_c) & ~first_cyc_c;



// Instruction Memory exception pipe
ff_sre  imem_e_reg(.out(imem_acc_err_e),.din(imem_acc_err_r),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  imem_c_reg(.out(imem_acc_err_c),.din((imem_acc_err_e & !hold_e)),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));


// Illegal Instruction pipe
ff_sre  ill_e_reg(.out(ill_inst_e),.din(illegal_r),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  ill_c_reg(.out(ill_inst_c),.din((ill_inst_e & !hold_e)),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));
 
// Privileged Instruction trap pipe
ff_sre  priv_e_reg(.out(priv_inst_e),.din(priv_inst_r),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  priv_c_reg(.out(priv_inst_c),.din((priv_inst_e & !hold_e)),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));
 
// FPU unimplemented trap pipe
assign	fpu_unimp_r	=	fpu_inst_r & (pj_no_fpu|~iu_psr_fpe);
ff_sre  fpu_e_reg(.out(fpu_unimp_e),.din(fpu_unimp_r),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  fpu_c_reg(.out(fpu_unimp_c),.din((fpu_unimp_e & !hold_e)),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));

// Emulated opcodes pipe
ff_sre  emul_op_e_reg(.out(emul_op_e),.din(emul_op_r),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  emul_op_c_reg(.out(emul_op_c),.din((emul_op_e & !hold_e)),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));


// software trap pipe
ff_sre  soft_e_reg(.out(soft_trap_e),.din(soft_trap_r),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e));
ff_sre  soft_c_reg(.out(soft_trap_c),.din((soft_trap_e & !hold_e)),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));


//Lock traps
ff_sre_4 lock_trap_reg(.out(lock_trap_c[3:0]),.din(lock_trap_e[3:0]),.clk(clk),
			.reset_l(reset_l),.enable(~hold_c));
assign	lock_ov_trap_c		=	lock_trap_c[3];
assign	lock_exit_trap_c	=	lock_trap_c[2];
assign	lock_enter_trap_c	=	lock_trap_c[1];
assign	lock_release_trap_c	=	lock_trap_c[0];


// Zeroline Trap pipe
ff_sre	zero_c_reg(.out(zero_trap_c),.din(zero_trap_e),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));


// Coalese the jvm errors. No need to prioritize them.
// ucode exceptions are considered C stage ,so that any ucode related ld/st can
// killed in time. to avoid killing the wrong ld/st ,we need to qualify it with
ff_sre  vm_err_c_reg(.out(arithm_exe_c),.din(arithm_exe_e),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));
ff_sre  null_ptr_c_reg(.out(null_ptr_exe_c),.din(null_ptr_exe_e),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c));
assign	java_vm_err_c	= u_ref_null_c | u_ary_ovf_c | (arithm_exe_c | null_ptr_exe_c)&trap_vld_c;


// Dcache Memory exceptions
ff_sr  async_err_reg(.out(async_mem_prot_error),.din(async_mem_prot_err),.clk(clk),
        .reset_l(reset_l));


assign	dcu_async_err_c	=  	dcu_err_ack[2] | async_mem_prot_error;
assign	dcu_mem_err_c	=	dcu_err_ack[0];
assign	dcu_io_err_c	=	dcu_err_ack[1];
assign	async_error 	=  	dcu_async_err_c&~iu_psr_aem;


// Trap valid pipe 
assign	trap_vld_r =	irl_r | nmi_r | (inst_brk1_r| inst_brk2_r)&~brk12c_halt |priv_inst_r | illegal_r
			| imem_acc_err_r | fpu_unimp_r | emul_op_r | soft_trap_r ;


// Need to kill any trap for an extra cycle after branch,bcos the PC pipe is
// not correct and need 1 cycles to adjust the pipe to fetch the branch pc.
ff_sr   br_c_reg(.out(br_c),.din(iu_brtaken_e),.clk(clk),.reset_l(reset_l));

assign	trap_vld_r_new =  trap_vld_r & ~iu_brtaken_e &~fold_sc_miss_e&~trap_in_progress&~br_c;

ff_sre  trap_vld_e_reg(.out(trap_vld_e),.din(trap_vld_r_new),.clk(clk),
	.reset_l(reset_l),.enable(~hold_e |trap_in_progress|iu_brtaken_e));

assign	trap_vld_e_new	=  (trap_vld_e| (|lock_trap_e[3:0])|arithm_exe_e |
			   zero_trap_e|null_ptr_exe_e)&~trap_in_progress;

ff_sre  trap_vld_c_reg(.out(trap_vld_c_raw),.din(trap_vld_e_new),.clk(clk),
	.reset_l(reset_l),.enable(~hold_c|trap_in_progress));

assign trap_vld_c = trap_vld_c_raw;

// To generate a state which indicates trap frame building is in progress.
assign	new_trap	=  iu_trap_r | trap_state&ucode_done;
ff_sr	trap_stat_reg(.out(trap_state),.din(new_trap),.clk(clk),.reset_l(reset_l));
assign	trap_in_progress	=	trap_in_c | iu_trap_r| trap_state;
 
// To generate trap signal in R stage for ucode to start building a trap frame.
// even if the ucode is not ready to read iu_trap_r (due to hold..),iu_trap_r is
// held by using hold_e. but if there is a hold_e when trap occurs, we still need
// to latch iu_trap_c. do not activate trap if there is a folded group.
ff_sre	iu_trap_reg(.out(iu_trap_r),.din(trap_in_c&~fold_c| async_error),.clk(clk),.enable(~hold_e|trap_in_c),
	.reset_l(reset_l));

// Write to TT field only if there is no folded group or an async_error .
assign	tt_we		=	trap_in_c&~fold_c | async_error;


// iu_trap_c maybe be valid only for one cycle .Thus,even ifthere is hold_c,
// we need to latch it into iu_trap_r.
assign	fast_trap 	=  trap_vec_c[15] |(|trap_vec_c[11:9]) |(|trap_vec_c[7:0]) ;
assign	iu_trap_c 	=  mem_prot_err_c|brk1_c|brk2_c| oplim_trap_c| fast_trap;

 // The C-stage partial Priority Encoder module.
wire [15:0] ptrap_in_c;
pencoder_16 trap_encoder( .trap_vec_c(trap_vec_c[15:0]),
                          .ptrap_in_c(ptrap_in_c[15:0]));
 
 
 // Extract the signals from the prioritized output
assign  dcu_async_err   =       ptrap_in_c[15];
assign  mem_prot_err    =       ptrap_in_c[14];
assign  brk1            =       ptrap_in_c[13];
assign  brk2            =       ptrap_in_c[12];
assign  imem_acc_err    =       ptrap_in_c[11];
assign  ill_inst        =       ptrap_in_c[10];
assign  priv_inst       =       ptrap_in_c[9];
assign  oplim_trap      =       ptrap_in_c[8];
assign  align_err       =       ptrap_in_c[7];
assign  dmem_acc_err    =       ptrap_in_c[6];
assign  femul           =       ptrap_in_c[5];
assign  iemul_op        =       ptrap_in_c[4];
assign  java_vm_err     =       ptrap_in_c[3];
assign  gc_trap         =       ptrap_in_c[2];
assign  pj_nmi_prio     =       ptrap_in_c[1];
assign  any_irl         =       ptrap_in_c[0];
 
assign  trap_vec_c[15]  =       dcu_async_err_c&~iu_psr_aem;
assign  trap_vec_c[14]  =       mem_prot_err_c&iu_psr_ace ;
assign  trap_vec_c[13]  =       brk1_c;
assign  trap_vec_c[12]  =       brk2_c;
assign  trap_vec_c[11]  =       imem_acc_err_c&trap_vld_c;
assign  trap_vec_c[10]  =       ill_inst_c&trap_vld_c ;
assign  trap_vec_c[9]   =       priv_inst_c&trap_vld_c;
assign  trap_vec_c[8]   =       oplim_trap_c ;
assign  trap_vec_c[7]   =       align_err_c;
assign  trap_vec_c[6]   =       dcu_mem_err_c | dcu_io_err_c;
assign  trap_vec_c[5]   =       fpu_unimp_c & (pj_no_fpu | ~iu_psr_fpe)&trap_vld_c ;
assign  trap_vec_c[4]   =       (emul_op_c| soft_trap_c| lock_enter_trap_c|
                                lock_ov_trap_c| lock_exit_trap_c| lock_release_trap_c)&trap_vld_c|u_ptr_un_eq_c;
assign  trap_vec_c[3]   =       java_vm_err_c;
assign  trap_vec_c[2]   =       gc_trap_c | zero_trap_c&trap_vld_c;
assign  trap_vec_c[1]   =       nmi_c&trap_vld_c;
assign  trap_vec_c[0]   =       irl_c&trap_vld_c;

assign  trap_in_c       =       (|trap_vec_c[15:0]);

wire data_acc_io_err = dmem_acc_err & dcu_io_err_c;
wire data_acc_mem_err= dmem_acc_err & dcu_mem_err_c;
wire soft_trap= iemul_op & soft_trap_c;
wire lock_enter_trap= lock_enter_trap_c & iemul_op;
wire lock_ov_trap= lock_ov_trap_c & iemul_op;
wire lock_exit_trap= lock_exit_trap_c & iemul_op;
wire lock_release_trap= lock_release_trap_c & iemul_op;
wire zero_trap		= zero_trap_c&gc_trap;
wire gc_notify		= gc_trap&~zero_trap_c;
 
wire arith_excptn= java_vm_err & arithm_exe_c;
wire index_out_bnd_excptn= java_vm_err & u_ary_ovf_c;
wire nullptr_excptn= java_vm_err & (u_ref_null_c| null_ptr_exe_c);
 


 // TBR.tt generation logic

assign	other_tt_c[7]	=	1'b0;
assign	other_tt_c[6]	=	1'b0;
assign	other_tt_c[5]	=	lock_release_trap|lock_exit_trap|lock_ov_trap|lock_enter_trap | gc_trap | pj_nmi_prio|any_irl;

assign	other_tt_c[4]	=	arith_excptn | index_out_bnd_excptn | nullptr_excptn | pj_nmi_prio|any_irl;

assign	other_tt_c[3]	=	brk2 | oplim_trap | align_err | data_acc_io_err | soft_trap | index_out_bnd_excptn | 
				nullptr_excptn| zero_trap | any_irl&pj_irl_c[3];

assign	other_tt_c[2]	=	brk1 | imem_acc_err | ill_inst | priv_inst | oplim_trap | soft_trap | arith_excptn|
				lock_enter_trap |lock_release_trap|lock_exit_trap | gc_notify | any_irl&pj_irl_c[2];

assign	other_tt_c[1]	=	brk1 | mem_prot_err | ill_inst | data_acc_mem_err | data_acc_io_err | arith_excptn | nullptr_excptn |
				lock_ov_trap|lock_exit_trap | gc_notify | any_irl&pj_irl_c[1];

assign	other_tt_c[0]	=	brk1 | dcu_async_err| priv_inst | align_err | data_acc_mem_err | soft_trap | index_out_bnd_excptn 
				|lock_ov_trap|nullptr_excptn |lock_release_trap | gc_notify | zero_trap | any_irl&pj_irl_c[0];


// Switch for emulation traps
assign tt_c= (femul | iemul_op&(emul_op_c|u_ptr_un_eq_c)) ? opcode_c[7:0]: other_tt_c[7:0];

// kill any outstanding fpu or dcu operations
// iu_brtaken_e is qualified with ucode_done to avoid killing
// ucode when ucode issues a branch.

// if there is a trap instruction in C and dcu instruction in E stage,
// we need to kill the dcu request. bcos of timing reasons,we will kill
// when it enters C stage. thus,we use trap_in_w also to kill_dcu
// Need to qualify done with ucode_last because ucode_done is high
// one cycle early.

ff_sre   trap_w_reg(.out(trap_in_w),.din(trap_in_c),.clk(clk),
		   .enable(~hold_c|trap_in_c),.reset_l(reset_l));

// Because ucode can write to Pc in the last cycle, and if there is
// a hold and another S$ write to be done, the write is lost if we kill
// ucode in the same cycle. therefore we latch the brtaken signal
// and kill the ucode/fpu in the next cycle. this also fixes the
// the timing path to fpu.
// But,do not assert brtaken_c,if there was a trap along with branch.
// bcos, we need to build trap frame by ucode and dont want to kill
// ucode.
assign	new_brtaken_e 	= iu_brtaken_e&ucode_done&~trap_in_c;
ff_sre   brtaken_reg(.out(brtaken_c),.din(new_brtaken_e),.clk(clk),
                   .enable(~hold_c|trap_in_c),.reset_l(reset_l));
 

assign	iu_kill_dcu	= iu_trap_c | trap_in_w  | ucode_abort;
assign	iu_kill_fpu	= trap_in_w | trap_vld_e | fold_sc_miss_e |brtaken_c;
assign	iu_kill_ucode   = iu_trap_c | trap_vld_e | fold_sc_miss_e |brtaken_c;





// Halt & Resume Logic

assign	pj_in_halt	= brk12c_halt&(pj_brk1_sync | pj_brk2_sync);

mj_spare spare( .clk(clk),
                .reset_l(reset_l));
 
endmodule
