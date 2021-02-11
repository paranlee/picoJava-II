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




module code_seq (	rsovfi, 
			rsneg, 
			amsb, 
			incovf, 
			rs2zero,
			rs32, 
			rsge64, 
			eadd, 
			le, 
                 	manzero, 
			morethree, 
			morethree_taken, 
			absign, 
			fmulovf, 
			nx_opcode,
                  	reset_l, 
			fpkill, 
			cyc0_rdy, 
			nx_cyc0_rdy,
			cyc1_rdy, 
			cyc0_type, 
			dprec, 
			nx_dprec, 
			mword, 
                  	fpuhold, 
			fpu_state, 
			clk, 
			fpbusyn, 
			top_fpbin,
                  	bsignin, 
			nx_fpop_valid, 
			qin, 
			qmsb, 
			powerdown,
			erop,
			nx_multfunc_rom1,
			nx_multfunc_rom0,
			nx_incfunc_rom1,
			nx_incfunc_rom0,
			nx_rsfunc_rom0,
			nx_rsfunc_rom1,
			nx_expfunc_rom0,
			nx_expfunc_rom1,
			nx_prifunc_rom0,
			nx_prifunc_rom1,
			nx_mconfunc_rom0, 
			nx_mconfunc_rom1,
			nx_exconfunc_rom0, 
			nx_exconfunc_rom1,
			romsel,
			test_mode,
			so,
			sin,
			sm
			);

  input   [7:0] nx_opcode;
  input         rsovfi, rsneg, amsb, incovf, rs2zero, rs32;
  input         rsge64, eadd, le, manzero, morethree, absign, fmulovf;  // Branch inputs
  input         top_fpbin, nx_fpop_valid, qin, qmsb;
  input         reset_l, fpkill, fpuhold;                    // state control inputs.
  input         clk;
  input         test_mode, powerdown;
  input         sm, sin;
  output	so;

  output [41:0] mword;
  output  [2:0] cyc0_type, nx_rsfunc_rom0, nx_rsfunc_rom1; 
  output  [7:0] fpu_state;
  output        morethree_taken, fpbusyn, bsignin;
  output        cyc0_rdy, nx_cyc0_rdy, cyc1_rdy, dprec, nx_dprec, erop;
  output [3:0]  nx_multfunc_rom1, nx_multfunc_rom0, nx_incfunc_rom1, 
		nx_incfunc_rom0, nx_expfunc_rom0, nx_expfunc_rom1;
  output [2:0]  nx_prifunc_rom0, nx_prifunc_rom1;
output	[1:0]	nx_mconfunc_rom0, nx_mconfunc_rom1;
output	[3:0]	nx_exconfunc_rom0, nx_exconfunc_rom1 ;    // EXCON func.

  wire    [7:0] nxcode;
  wire    [3:0] branch;
  output  [1:0] romsel;
  wire          valid_opcode, opcode_look, nx_opcode_look, cyc0_rdy_p;
  wire    [7:0] opcode;
  


  code_seq_cntl p_code_seq_cntl ( 	.reset_l(reset_l), 
					.valid_opcode(valid_opcode), 
        				.fpuhold(fpuhold), 
					.fpu_state(fpu_state), 
					.opcode_look(opcode_look), 
					.nx_opcode_look(nx_opcode_look), 
        				.fpbusyn(fpbusyn), 
					.cyc1_rdy(cyc1_rdy), 
					.fpkill(fpkill), 
					.clk(clk), 
					.romsel(romsel), 
        				.morethree_taken(morethree_taken), 
					.rsovfi(rsovfi), 
					.rsneg(rsneg), 
        				.amsb(amsb), 
					.incovf(incovf), 
					.rs2zero(rs2zero), 
					.rs32(rs32), 
					.rsge64(rsge64), 
					.eadd(eadd), 
					.le(le), 
					.manzero(manzero), 
					.morethree(morethree), 
					.absign(absign), 
					.fmulovf(fmulovf), 
					.cyc0_rdy_p(cyc0_rdy_p), 
					.branch(branch), 
					.qin(qin), 
        				.qmsb(qmsb), 
					.a2func(mword[31:29]),
					.opcode(opcode), 
					.cyc0_type(cyc0_type), 
					.top_fpbin(top_fpbin), 
					.bsignin(bsignin), 
					.dprec(dprec), 
					.nx_dprec(nx_dprec),
					.sm(),.sin(),.so(),
        				.nxcode(nxcode) );

  code_seq_dp p_code_seq_dp ( 		.romsel(romsel), 
					.branch(branch), 
					.nxcode(nxcode), 
        				.mword(mword), 
					.clk(clk), 
					.valid_opcode(valid_opcode), 
					.fpkill(fpkill), 
					.opcode(opcode), 
					.nx_opcode(nx_opcode), 
					.nx_fpop_valid(nx_fpop_valid), 
					.opcode_look(opcode_look), 
					.nx_opcode_look(nx_opcode_look), 
					.reset_l(reset_l), 
					.cyc0_rdy(cyc0_rdy), 
					.nx_cyc0_rdy(nx_cyc0_rdy), 
					.cyc0_rdy_p(cyc0_rdy_p), 
					.erop(erop),
					.fpuhold(fpuhold),
					.powerdown(powerdown),
                                        .nx_multfunc_rom1(nx_multfunc_rom1),
					.nx_multfunc_rom0(nx_multfunc_rom0),
                                        .nx_incfunc_rom1(nx_incfunc_rom1),
					.nx_incfunc_rom0(nx_incfunc_rom0),
					.nx_rsfunc_rom0(nx_rsfunc_rom0),
					.nx_rsfunc_rom1(nx_rsfunc_rom1),
					.nx_expfunc_rom0(nx_expfunc_rom0),
					.nx_expfunc_rom1(nx_expfunc_rom1),
					.nx_prifunc_rom0(nx_prifunc_rom0),
					.nx_prifunc_rom1(nx_prifunc_rom1),
					.nx_mconfunc_rom0(nx_mconfunc_rom0),
					.nx_mconfunc_rom1(nx_mconfunc_rom1),
					.nx_exconfunc_rom0(nx_exconfunc_rom0),
					.nx_exconfunc_rom1(nx_exconfunc_rom1),
					.sm(),.sin(), 
					.test_mode(test_mode),.so());

endmodule

