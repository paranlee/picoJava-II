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




// synopsis translate_off
//`timescale 1ns/1ns
`timescale 1ns/10ps
`include "fpu.h"
// synopsis translate_on

module fpu(
     		fpain,    	// 32-bit A bus input.
     		fpbin,    	// 32-bit B bus input.
     		fpop,     	// Java Fp opcode (connected to first byte in IBUFF).
     		fpbusyn,  	// Signal asserted after valid operation begins
     		fpkill,   	// Input kills the operation returns to idle state.
     		fpout,    	// 32-bit output bus, Direct Drive.
     		clk,
     		so,
		sin,
		sm,
     		reset_l,
		powerdown, // used here to power down fpu roms
		test_mode,	// test signal for roms
     		fphold,     	// Signal to hold the data input/output on IU stalls.
     		fpop_valid); 	// Input indicating valid FPOP byte (connected to first
				// byte valid in IBUFF).

//  Top level FPU module.

  input [31:0]  fpain, fpbin;
  input  [7:0]  fpop;
  input         fpkill, fphold, reset_l, test_mode, powerdown;
  input         clk, sin,sm, fpop_valid;

  output [31:0] fpout;       // Direct Drive output,  No output tri-state needed.
  output        fpbusyn;     // Output signal for controlling FPU interface.
  output        so;

//  wire  [41:0]  mword;      // Microcode word.
  wire  [31:0]  a1, a0, b1, b0, a1inc, a0inc, rsout, lsout, multout;
  wire  [10:0]  aexpout;
  wire   [5:0]  priout;
  wire   [4:0]  saout;
  wire   [3:0]  expfunc, exconfunc, incfunc, multfunc, nx_multfunc_rom0, nx_multfunc_rom1, nx_incfunc_rom0, nx_incfunc_rom1, nx_expfunc_rom0, nx_expfunc_rom1;
  wire   [2:0]  incinfunc, asignfunc, a2func, a1func, a0func, safunc, prifunc, rsfunc, nx_rsfunc_rom0, nx_rsfunc_rom1,nx_prifunc_rom0,nx_prifunc_rom1;
  wire   [2:0]  cyc0_type; 
  wire   [7:0]  fpu_state;
  wire   [1:0]  mconfunc, romsel;
  wire          dprec, nx_dprec, eadd, rsovf, movf, amsb, incovf, morethree, le, expsame;
  wire		ae_small, fmulovf, rs32, rsge64, manzero, morethree_taken, absign;
  wire          altb, incin, a2, rsneg, rs2zero, lsround, stin, asign;
  wire          nx_cyc0_rdy, cyc0_rdy, cyc1_rdy, rsovfi, bsignin, qin, erop, qmsb;
wire	[1:0]	nx_mconfunc_rom0, nx_mconfunc_rom1;
wire	[3:0]	nx_exconfunc_rom0, nx_exconfunc_rom1 ;    // EXCON func.
wire   [31:0] r0out, r1out;
 
wire fpuhold= fphold & !fpkill;

  exponent exp(		.aexpin(fpain[30:20]),
			.bexpin(fpbin[30:20]),
			.dprec(dprec),
			.nx_dprec(nx_dprec),
			.nx_mconfunc_rom0(nx_mconfunc_rom0),
			.nx_mconfunc_rom1(nx_mconfunc_rom1),
			.nx_exconfunc_rom0(nx_exconfunc_rom0),
			.nx_exconfunc_rom1(nx_exconfunc_rom1),
              		.cyc0_type(cyc0_type),
			.cyc0_rdy(cyc0_rdy),
			.expfunc(expfunc),
			.nx_expfunc_rom0(nx_expfunc_rom0),
			.nx_expfunc_rom1(nx_expfunc_rom1),
			.romsel(romsel),
			.safunc(safunc),
              		.eadd(eadd),
			.rsovf(rsovf),
			.movf(movf),
			.amsb(amsb),
			.incovf(incovf),
              		.priout(priout),
			.morethree(morethree),
			.le(le),
			.expsame(expsame),
              		.ae_small(ae_small),
			.rs32(rs32),
			.rsge64(rsge64),
			.aexpout(aexpout),
			.saout(saout),
              		.clk(clk),
			.reset_l(reset_l),
              		.sm(),
			.sin(),
			.so(),
              		.fmulovf(fmulovf),
			.fpuhold(fpuhold),
			.erop(erop)
			);


  incmod inc(		.a1(a1),
			.a0(a0),
			.b1(b1),
			.b0(b0),
			.incfunc(incfunc),
			.stin(stin),
			.eadd(eadd),
            		.amsb(amsb),
			.altb(altb),
			.incovf(incovf),
			.a1inc(a1inc),
			.a0inc(a0inc),
            		.incin(incin),
			.rsovf(rsovf),
			.dprec(dprec),
			.qin(qin),
			.qmsb(qmsb),
            		.clk(clk),
			.reset_l(reset_l),
              		.sm(),
			.sin(),
			.so(),
			.nx_incfunc_rom1(nx_incfunc_rom1),
			.nx_incfunc_rom0(nx_incfunc_rom0),
			.fpuhold(fpuhold),
			.romsel(romsel)
			);


  rsadd rsa(		.saout(saout),
		//	.a2(a2),
		//	.a1(a1),
			.a0(a0),
			.rsfunc(rsfunc),
		//	.nx_rsfunc_rom0(nx_rsfunc_rom0),
		//	.nx_rsfunc_rom1(nx_rsfunc_rom1),
		//	.romsel(romsel),
			.r1out(r1out),
			.r0out(r0out),
			.reset_l(reset_l),
			.eadd(eadd),
           		.rsout(rsout),
			.rsovfi(rsovfi),
			.rsneg(rsneg),
			.rs2zero(rs2zero),
			.lsround(lsround),
           		.b0(b0),
			.b1(b1),
			.clk(clk),
		 	.sm(),
			.sin(),
			.so(),
			.incin(incin),
           		.stin(stin),
			.rs32(rs32),
			.incinfunc(incinfunc),
			.rsovf(rsovf),
			.fpuhold(fpuhold),
			.erop(erop)
			);


  prils prif(		.a1(a1),
			.a0(a0),
			.prifunc(prifunc),
			.nx_prifunc_rom0(nx_prifunc_rom0),
			.nx_prifunc_rom1(nx_prifunc_rom1),
			.romsel(romsel),
			.clk(clk),
			.reset_l(reset_l),
			.mconfunc(mconfunc),
			.lsround(lsround),
           		.incinfunc(incinfunc),
			.stin(stin),
			.lsout(lsout),
			.saout(saout),
           		.priout(priout),
			.fpuhold(fpuhold),
			.multout(multout),
		 	.sm(),
			.sin(),
			.so()	
			);

  code_seq cs(		.rsovfi(rsovfi),
			.rsneg(rsneg),
			.amsb(amsb),
			.incovf(incovf),
			.rs2zero(rs2zero),
              		.rs32(rs32),
			.rsge64(rsge64),
			.eadd(eadd),
			.le(le),
              		.manzero(manzero),
			.powerdown(powerdown),
			.morethree(morethree),
			.morethree_taken(morethree_taken),
              		.absign(absign),
			.fmulovf(fmulovf),
			.nx_opcode(fpop),
			.reset_l(reset_l),
			.fpkill(fpkill),
              		.cyc0_rdy(cyc0_rdy),
              		.nx_cyc0_rdy(nx_cyc0_rdy),
			.cyc1_rdy(cyc1_rdy),
			.cyc0_type(cyc0_type),
			.dprec(dprec),
              		.mword({multfunc, incinfunc, asignfunc, a2func, a1func, a0func, mconfunc, expfunc, safunc, exconfunc, incfunc, prifunc, rsfunc}),
			.fpuhold(fpuhold),
			.fpu_state(fpu_state),
			.clk(clk),
              		.sm(),
			.sin(),
			.so(),
			.fpbusyn(fpbusyn),
			.top_fpbin(fpbin[31]),
              		.bsignin(bsignin),
			.nx_fpop_valid(fpop_valid),
			.qin(qin),
			.qmsb(qmsb),
              		.erop(erop),
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
			.nx_dprec(nx_dprec),
			.nx_mconfunc_rom0(nx_mconfunc_rom0),
			.nx_mconfunc_rom1(nx_mconfunc_rom1),
			.nx_exconfunc_rom0(nx_exconfunc_rom0),
			.nx_exconfunc_rom1(nx_exconfunc_rom1),
			.romsel(romsel),
			.test_mode(test_mode)
			);


  nxsign nxs(		.asignfunc(asignfunc),
			.ae_small(ae_small),
			.expsame(expsame),
			.altb(altb),
              		.morethree_taken(morethree_taken),
			.eadd(eadd),
			.absign(absign),
			.asign(asign),
              		.clk(clk),
			.reset_l(reset_l),
			.sm(),
			.sin(),
			.so(),
			.asignin(fpain[31]),
              		.bsignin(bsignin),
			.fpuhold(fpuhold),
			.cyc0_rdy(cyc0_rdy)
			);

  mantissa man(		.a0func(a0func),
			.a1func(a1func),
			.a2func(a2func),
			.nx_rsfunc_rom0(nx_rsfunc_rom0),  // for r0md generation
			.nx_rsfunc_rom1(nx_rsfunc_rom1),  // for r0md generation
			.romsel(romsel),
			.r1out(r1out),			  // send to rsadd
			.r0out(r0out),			  // send to rsadd
			.rsout(rsout),
              		.lsout(lsout),
			.a0inc(a0inc),
			.a1inc(a1inc),
			.ae_small(ae_small),
              		.eadd(eadd),
			.morethree_taken(morethree_taken),
			.expsame(expsame),
              		.altb(altb),
			.a2(a2),
			.a1(a1),
			.a0(a0),
			.b1(b1),
			.b0(b0),
			.fpout(fpout),
              		.aexpout(aexpout),
			.fpu_state(fpu_state),
			.asign(asign),
			.sm(),
			.sin(),
			.so(),
			.clk(clk),
			.reset_l(reset_l),
			.fpain(fpain),
			.fpbin(fpbin),
              		.cyc0_rdy(cyc0_rdy),
			.cyc1_rdy(cyc1_rdy),
			.cyc0_type(cyc0_type),
              		.amsb(amsb),
			.manzero(manzero),
			.fpuhold(fpuhold),
			.mconfunc(mconfunc)
			);

  multmod mult1(	.multout(multout),
			.nx_multfunc_rom1(nx_multfunc_rom1),
			.nx_multfunc_rom0(nx_multfunc_rom0),
			.romsel(romsel),
              		.nx_cyc0_rdy(nx_cyc0_rdy),
			.movf(movf),
                	.ma1(a1),
			.ma0(a0[31:11]),
			.mb1(b1),
			.mb0(b0[31:11]),
			.so(),
			.sm(),
			.sin(),
                	.clk(clk),
			.fpuhold(fpuhold),
			.reset_l(reset_l)
			);


mj_spare i1_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i2_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i3_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i4_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i5_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i6_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i7_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i8_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i9_spare (	.reset_l(reset_l),
			.clk(clk)
			);

mj_spare i10_spare (	.reset_l(reset_l),
			.clk(clk)
			);
endmodule







             
