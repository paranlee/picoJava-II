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

module	pipe_dpath (

	  	arch_pc,
		pc_r,
		opcode_pc_e,
                arch_optop,
                iu_optop_din,
                optop_e,
		optop_e_v1,
		optop_e_v2,
                iu_data_e,
                icu_pc_d,
		optop_sel_e,
		optop_sel_c,
		optop_enable,
		pc_enable,
		optop_shft_r,
		pc_offset_r,
		trap_in_progress,
		reset_l,
                clk,
                sm,
                sin,
                so 

) ;


output	[31:0]		arch_pc;	// Architectural PC
output	[31:0]		arch_optop;	// Architectural OPTOP
output	[31:0]		iu_optop_din;	// Signal at the din input of
					// arch optop flop
output	[31:0]		optop_e;	// E stage optop -- RCU
output	[31:0]		optop_e_v1;	// E stage optop -- EX
output	[31:0]		optop_e_v2;	// E stage optop -- UCODE
output	[31:0]		opcode_pc_e;	// E stage opcode PC
output	[31:0]		pc_r;		// R stage PC

input	[31:0]		iu_data_e;	// write port to write to optop
input	[31:0]		icu_pc_d;	// PC of first instruction of ibuffer
input	[2:0]		pc_offset_r;	// pc offset used to determine PC of operation
input	[31:0]		optop_shft_r;// shift in optop due to insts dispatched
input	[3:0]		optop_sel_e;	// mux selects to select correct optop
input	[3:0]		optop_sel_c;	// mux selects to select correct optop
input	[2:0]		optop_enable;	// enable for optop pipe
input	[2:0]		pc_enable;	// enable for pc pipe
input			trap_in_progress;// Trap frame building is in progress.
input			clk	;
input			reset_l;
input			sm;
input			sin;
output			so;


wire	[31:0]	pc_e,new_pc_r,pc_w,new_opcode_pc_r;
wire	[31:0]	opcode_pc_r;
wire	[31:0]	arch_optop_in;
wire	[31:0]	shadow_optop,optop_e_in;

// PC PIPE

ff_se_32	pc_r_reg(.out(pc_r[31:0]),
			.din(icu_pc_d[31:0]),
			.clk(clk),
			.enable(pc_enable[0]));


cla_adder_32	opcode_pc_adder(.in1(pc_r[31:0]),
			.in2({29'b0,pc_offset_r[2:0]}),
			.cin(1'b0),
			.cout(),
			.sum(opcode_pc_r[31:0])	);

// Only when building a trap frame, we move the C stage instruction
// into ucode. thus the arch_pc is moved into the E stage.
// assign new_opcode_pc_r[31:0]	= (trap_in_progress)?arch_pc[31:0]:opcode_pc_r;
mux2_32 new_opcode_pc_r_mux(.out(new_opcode_pc_r),
                            .in1(arch_pc),
                            .in0(opcode_pc_r),
                            .sel({trap_in_progress,~trap_in_progress}));

ff_se_32	opcode_pc_reg(.out(opcode_pc_e[31:0]),
			.din(new_opcode_pc_r[31:0]),
			.clk(clk),
			.enable(pc_enable[1]));

// assign new_pc_r[31:0]	=	(trap_in_progress)?arch_pc[31:0]:pc_r;
mux2_32 new_pc_r_mux(.out(new_pc_r),
                     .in1(arch_pc),
                     .in0(pc_r),
                     .sel({trap_in_progress,~trap_in_progress}));

ff_se_32	pc_e_reg(.out(pc_e[31:0]),
                        .din(new_pc_r[31:0]),
                        .clk(clk),
                        .enable(pc_enable[1]));


ff_sre_32        arch_pcreg(.out(arch_pc[31:0]),
                        .din(pc_e[31:0]),
                        .clk(clk),
                        .enable(pc_enable[2]),
			.reset_l(reset_l));

 
// synopsys translate_off
// for cosim purposes
ff_s_32        cosimpcreg(.out(pc_w[31:0]),
                        .din(arch_pc[31:0]),
                        .clk(clk));

// synopsys translate_on

// OPTOP PIPE

mux4_32         optop_e_mux(.out(optop_e_in[31:0]),
				.in3(32'h3ffffc),
                                .in2(shadow_optop[31:0]),
                                .in1(iu_data_e[31:0]),
				.in0(optop_shft_r[31:0]),
                                .sel(optop_sel_e[3:0]));


ff_se_30        optop_e_reg(.out(optop_e[31:2]),
                        .din(optop_e_in[31:2]),
                        .clk(clk),
                        .enable(optop_enable[0]));

assign 		optop_e[1:0] = 2'b00;

assign		optop_e_v1 = optop_e ;
assign		optop_e_v2 = optop_e ;
 

mux4_32		arch_optop_mux(.out(arch_optop_in[31:0]),
				.in3(32'h3ffffc),
				.in2(shadow_optop[31:0]),
				.in1(iu_data_e[31:0]),
				.in0(optop_e[31:0]),
				.sel(optop_sel_c[3:0]));
// iu_optop_din is latched in SMU to create it's own
// version of optop. This is done  to improve timing on
// smu_stall signal 

assign	iu_optop_din[31:2] = arch_optop_in[31:2];
assign	iu_optop_din[1:0] = 2'b00;

ff_se_30        optop_arch_reg(.out(arch_optop[31:2]),
                        .din(arch_optop_in[31:2]),
                        .clk(clk),
                        .enable(optop_enable[1]));

assign arch_optop[1:0] = 2'b00;


ff_se_32		shadow_reg(.out(shadow_optop[31:0]),
			.din(arch_optop[31:0]),
			.clk(clk),
			.enable(optop_enable[2]));


endmodule
