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



module exponent(aexpin, bexpin, dprec, nx_dprec, nx_exconfunc_rom0, nx_exconfunc_rom1, cyc0_type, cyc0_rdy,
expfunc, safunc, eadd, rsovf, movf, amsb, incovf, priout, morethree,
le, expsame, ae_small, rs32, rsge64, aexpout, saout, clk, sin,
sm, so, nx_mconfunc_rom0, nx_mconfunc_rom1, fmulovf, erop, reset_l, nx_expfunc_rom0, nx_expfunc_rom1,
romsel,fpuhold);


input	[10:0]	aexpin,bexpin;// Exponent load inputs.
input	[5:0]	priout;       // PRIority encoder OUTput.
input	[3:0]	expfunc;      // Exponent function control.
input	[3:0]	nx_expfunc_rom0;
input	[3:0]	nx_expfunc_rom1;
input	[1:0]	nx_mconfunc_rom0, nx_mconfunc_rom1;
input	[3:0]	nx_exconfunc_rom0, nx_exconfunc_rom1 ;    // EXCON func.
input	[2:0]	safunc;       // Shift amount function control.
input	[1:0]	romsel;
input		eadd;         // Effective add signal.
input		rsovf;        // Right Shift Overflow signal.
input		movf;         // Multiply overflow signal.
input		amsb;         // A1 msb.
input		incovf;       // INCrement module OVerFlow.
input		dprec, nx_dprec;        // Double PRECision indicator.
input		cyc0_rdy;     // CYC0 is READY (asserted)
input	[2:0]	cyc0_type;    // Type of cyc0 transaction.
input		clk;
input		reset_l, fpuhold;
input		sin,sm;   // Input to the exp scan chain.

input		erop;   // Rem operation. 

output		so;
output		le;          // Branch output.
output		expsame;     // Indicates exponents are equal.
output		morethree,ae_small,rs32,rsge64,fmulovf;
output	[10:0]	aexpout;
output 	[4:0]	saout;

wire	[4:0]	saout;
wire	[5:0]	priout_l;
wire	[10:0]	aexpout;
wire	[15:0]	sa, aexp, bexp, addtop, addlow;
wire		le, morethree, ae_small, rs32, rsge64, fmulovf,
		topsign, expsame, aele, bele, azle, bzle,
		addtcin, addlcin, muxbed, or_out;
wire	[1:0]	mux1ad, mux2ad;
wire	[1:0]	aexp_sel, bexp_sel, muxaed, muxpaed_a, muxpaed_b, 
		muxpaed_c;
wire	[1:0]	muxlimd, muxsad_a, muxsad_b, mux2bd;


exponent_cntl	p_exponent_cntl	(
//Outputs
		.le		(le),
		.morethree	(morethree),
		.rs32		(rs32),
		.rsge64		(rsge64),
		.fmulovf	(fmulovf),
		.topsign	(topsign),
		.aexpout	(aexpout),
		.saout		(saout),
		.priout_l	(priout_l),
		.addtcin	(addtcin),
		.addlcin	(addlcin),
		.mux1ad		(mux1ad),
		.mux2ad		(mux2ad),
		.muxbed		(muxbed),
		.muxlimd	(muxlimd),
		.muxsad_a	(muxsad_a),
		.muxsad_b	(muxsad_b),
		.muxaed		(muxaed),
		.aexp_sel	(aexp_sel),
		.bexp_sel	(bexp_sel),
		.muxpaed_a	(muxpaed_a),
		.muxpaed_b	(muxpaed_b),
		.muxpaed_c	(muxpaed_c),
		.mux2bd		(mux2bd),
		.or_out		(or_out),
		.so		(),
//Inputs
		.sin		(),
		.sm		(),
		.expfunc	(expfunc),
		.nx_expfunc_rom0(nx_expfunc_rom0),
		.nx_expfunc_rom1(nx_expfunc_rom1),
		.romsel		(romsel),
		.safunc		(safunc),
		.cyc0_type	(cyc0_type),
		.priout		(priout),
//		.eadd		(eadd),
//		.rsovf		(rsovf),
		.movf		(movf),
//		.amsb		(amsb),
		.dprec		(dprec),
//		.cyc0_rdy	(cyc0_rdy),
		.erop		(erop),
		.sa		(sa),
		.addtop		(addtop),
		.addlow		(addlow),
		.bele		(bele),
		.aele		(aele),
		.azle		(azle),
		.bzle		(bzle),
		.aexp		(aexp),
		.bexp		(bexp),
		.clk		(clk),
		.reset_l		(reset_l),
		.fpuhold	(fpuhold)
); //exponent_cntl

exponent_dp	p_exponent_dp	(
//Outputs
		.addtop		(addtop),
		.addlow		(addlow),
		.sa		(sa),
		.aexp		(aexp),
		.bexp		(bexp),
		.expsame	(expsame),
		.bele		(bele),
		.aele		(aele),
		.azle		(azle),
		.bzle		(bzle),
		.ae_small	(ae_small),
		.so		(),
//Inputs
		.fpuhold	(fpuhold),
		.nx_dprec	(nx_dprec),
		.dprec		(dprec),
		.nx_mconfunc_rom0(nx_mconfunc_rom0),
		.nx_mconfunc_rom1(nx_mconfunc_rom1),
		.nx_exconfunc_rom0(nx_exconfunc_rom0),
		.nx_exconfunc_rom1(nx_exconfunc_rom1),
		.romsel		(romsel),
		.cyc0_rdy	(cyc0_rdy),
		.mux1ad		(mux1ad),
		.mux2ad		(mux2ad),
		.muxbed		(muxbed),
		.muxlimd	(muxlimd),
		.muxsad_a	(muxsad_a),
		.muxsad_b	(muxsad_b),
		.muxaed		(muxaed),
		.aexp_sel	(aexp_sel),
		.bexp_sel	(bexp_sel),
		.muxpaed_a	(muxpaed_a),
		.muxpaed_b	(muxpaed_b),
		.muxpaed_c	(muxpaed_c),
		.mux2bd		(mux2bd),
		.priout		(priout),
		.priout_l	(priout_l),
		.addtcin	(addtcin),
		.addlcin	(addlcin),
		.topsign	(topsign),
		.clk		(clk),
		.reset_l		(reset_l),
		.sin	(),
		.sm	(),
		.aexpin		(aexpin),
		.incovf		(incovf),
		.bexpin		(bexpin),
		.eadd		(eadd),
		.rsovf		(rsovf),
		.amsb		(amsb),
		.or_out		(or_out)
); //exponent_dp

endmodule //exponent
