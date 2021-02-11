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


//`timescale 1ns/1ns
`timescale 1ns/10ps

module exponent_dp (addtop, sa, expsame, bele, aele, azle, bzle,
		    aexp, bexp, nx_mconfunc_rom0,nx_mconfunc_rom1, 
		    nx_exconfunc_rom0, nx_exconfunc_rom1, romsel,
		    nx_dprec,dprec, mux1ad, mux2ad, muxbed, addlow,
		    muxlimd, muxsad_a, muxsad_b, muxaed, 
		    aexp_sel, bexp_sel, or_out, cyc0_rdy,
		    muxpaed_a, mux2bd, priout, priout_l, addtcin, 
		    addlcin, topsign, clk, muxpaed_b, muxpaed_c,
		    aexpin, bexpin, sin, sm, so, incovf, 
		    reset_l, eadd, rsovf, amsb,ae_small,fpuhold
);

input		nx_dprec, dprec;        // Double PRECision indicator.
input		muxbed;
input		cyc0_rdy;
input		eadd, rsovf, amsb, incovf;
input	[1:0]	mux1ad, mux2ad; 
input	[1:0]	aexp_sel, bexp_sel, muxaed, muxpaed_a, muxpaed_b, 
		muxpaed_c;
input	[1:0]	muxlimd, muxsad_a, muxsad_b, mux2bd;
input   [1:0]    nx_mconfunc_rom0,nx_mconfunc_rom1, romsel;
input   [3:0]   nx_exconfunc_rom0, nx_exconfunc_rom1;
input	[5:0]	priout, priout_l;
input		addtcin, addlcin, clk, sin,
		sm, reset_l, or_out, fpuhold;
input	[10:0]	aexpin, bexpin;

output		so;
output	[15:0]	sa, aexp, bexp, addtop, addlow;
output		expsame, bele, aele, azle, bzle, 
		ae_small,topsign;


// wire	[15:0]	eout, ex0sel, ex1sel, ex2sel, ex3sel;
wire	[15:0]	nxaexp_a, nxaexp_b, nxaexp_c, nxbexp, muxasel, muxasel_a;
wire	[15:0]	muxasel_b, muxasel_c, muxbsel, muxbsel_temp, mux1a,
		muxasel_tempa, muxasel_tempb, muxasel_tempc;
wire	[15:0]	bexp, addtop, mux2a, mux2b, addlow, mux3out, nxsa, nxsa_a,
		nxsa_b, sa, aexp, aexp_l, priadd, muxlim, muxpae_a, 
		muxpae_b, muxpae_c, excon, excon_l;

//wire	[3:0]   aexpselx, bexpselx, muxaedx, muxlimdx, muxsadx_a, 
//		muxsadx_b, mux2bdx;
//wire	[3:0]	muxpaedx_a, muxpaedx_b, muxpaedx_c;
//wire	[2:0]	mux2adx, mux1adx;
//wire	[1:0]	muxbedx, cyc0_rdysel, topsign_sel, muxasel_1, muxasel_2,
//		or_outx;
wire		ae_small, topsign, topsign_l;


wire    fpuhold_l = ~fpuhold;
assign aexp_l = ~aexp;
assign topsign = addtop[15];
//assign ae_small = addtop[15];
assign topsign_l = ~topsign;

//*****************************************************************
//****************DATA PATH SECTION of exponent********************

wire [15:0] nx_excon_rom0, nx_excon_rom1;
 excon_dec i_excon_dec_rom0(	.nx_excon(nx_excon_rom0),
			.nx_dprec(nx_dprec),
			.muxbsel(muxbsel),
			.nx_exconfunc(nx_exconfunc_rom0),
			.nx_mconfunc(nx_mconfunc_rom0) );

 excon_dec i_excon_dec_rom1(	.nx_excon(nx_excon_rom1),
			.nx_dprec(nx_dprec),
			.muxbsel(muxbsel),
			.nx_exconfunc(nx_exconfunc_rom1),
			.nx_mconfunc(nx_mconfunc_rom1) );

wire [15:0] nx_excon;
mj_s_mux3_d_16 excon_mux(	.mx_out(nx_excon),
				.sel(romsel),
				.in0(nx_excon_rom0),
				.in1(nx_excon_rom1),
				.in2(16'h0));

 mj_s_ff_snre_d_16 ff_excon(.out(excon),
			.din(nx_excon),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));

 assign excon_l = ~excon;

//***************************************************************
// Now do the EXPCALC section of the block.  



mj_s_mux3_d_16 m1a(	.mx_out(mux1a),
			.sel(mux1ad),
			.in0(excon_l),
			.in1(excon),
			.in2(bexp));


 cla_adder_16 atop(	.sum(addtop),
			.in1(aexp),
			.in2(mux1a),
			.cin(addtcin),
			.cout());

 cla_adder_16 pri_add(	.sum(priadd),
			.in1(aexp),
			.in2({10'h3ff,priout_l}),
			.cin(1'h1),
			.cout());


// to produce ae_small 
 wire [14:0] dummy1;
 wire [15:0] bexp_l = ~bexp;
// wire ae_small_0, ae_small_1;



 cla_adder_16 aeadd_1  (.sum({ae_small, dummy1}),
			.in1(aexp),
			.in2(bexp_l),
			.cin(1'b1),		// since we're actually doing a-b, we can put 1'b1 here instead of addtcin
			.cout());


mj_s_mux3_d_16 m2a(	.mx_out(mux2a),
			.sel(mux2ad),
			.in0(excon),
			.in1(sa),
			.in2(aexp));

mj_s_mux4_d_16 m2b(	.mx_out(mux2b),
			.sel(mux2bd),
			.in0(excon_l),
			.in1(aexp_l),
			.in2(16'h1),
			.in3(16'hffff));

mj_s_mux2_d_16 mx3(	.mx_out(mux3out),
			.sel(topsign),
			.in0(addtop),
			.in1(addlow));

 cla_adder_16 alow(	.sum(addlow),
			.in1(mux2a),
			.in2(mux2b),
			.cin(addlcin),
			.cout());



//***************************************************************

mj_s_mux4_d_16 mlim(	.mx_out(muxlim),
			.sel(muxlimd),
			.in0(16'h0),
			.in1(addlow),
                	.in2(sa),
			.in3(mux3out));

mj_s_mux4_d_16 nsa_a(	.mx_out(nxsa_a),
			.sel(muxsad_a),
			.in0({10'h0,dprec,5'h1f}),
			.in1({10'h0,priout}),
			.in2(excon),
             		.in3(muxlim));

mj_s_mux4_d_16 nsa_b(   .mx_out(nxsa_b),
                        .sel(muxsad_b),
                        .in0({10'h0,dprec,5'h1f}),
                        .in1({10'h0,priout}),
                        .in2(excon),
                        .in3(muxlim));

mj_s_mux2_d_16 nxsa_mux(.mx_out(nxsa),	
			.sel(or_out),
			.in0(nxsa_b),
			.in1(nxsa_a));

mj_s_mux4_d_16 mpae_a(	.mx_out(muxpae_a),
			.sel(muxpaed_a),
			.in0(addtop),
			.in1(addlow),
			.in2(aexp),
			.in3(priadd));

mj_s_mux4_d_16 mpae_b(  .mx_out(muxpae_b),
                        .sel(muxpaed_b),
                        .in0(addtop),
                        .in1(addlow),
                        .in2(aexp),
                        .in3(priadd));

mj_s_mux4_d_16 mpae_c(  .mx_out(muxpae_c),
                        .sel(muxpaed_c),
                        .in0(addtop),
                        .in1(addlow),
                        .in2(aexp),
                        .in3(priadd));

mj_s_mux2_d_16 nbexp(	.mx_out(nxbexp),
			.sel(muxbed),
			.in0(bexp),
			.in1(aexp));


//wire [3:0] muxaedx_a, muxaedx_b, muxaedx_c;

mj_s_mux4_d_16 naexp_a(	.mx_out(nxaexp_a),
			.sel(muxaed),
			.in0(aexp),
			.in1(excon),
			.in2(addtop),
               		.in3(muxpae_a));

mj_s_mux4_d_16 naexp_b( .mx_out(nxaexp_b),
                        .sel(muxaed),
                        .in0(aexp),
                        .in1(excon),
                        .in2(addtop),
                        .in3(muxpae_b));

mj_s_mux4_d_16 naexp_c( .mx_out(nxaexp_c),
                        .sel(muxaed),
                        .in0(aexp),
                        .in1(excon),
                        .in2(addtop),
                        .in3(muxpae_c));

// Do the EXPCOMP data path section.

 compare_16 expsame_comp(.out(expsame),.in0(aexp),.in1(bexp));
 compare_16 be(.out(bele),.in0(bexp),.in1(excon));
 compare_16 ae(.out(aele),.in0(aexp),.in1(excon));
 
 cmp_zro_16 az(.out(azle),.in(aexp));	// in f_dp_cells.
 cmp_zro_16 bz(.out(bzle),.in(bexp));	// in f_dp_cells.


// Now do the EXPREG data path section. 

//wire cyc0_rst = cyc0_rdy & reset_l;
wire cyc0_rst = cyc0_rdy;

mj_s_mux4_d_16 nxasel_a(.mx_out(muxasel_a),
			.sel(aexp_sel),
			.in0(nxaexp_a),
			.in1({8'h0,aexpin[10:3]}),
                	.in2({5'h0,aexpin[10:0]}),
			.in3(16'h0));
mj_s_mux4_d_16 nxasel_b(.mx_out(muxasel_b),
                        .sel(aexp_sel),
                        .in0(nxaexp_b),
                        .in1({8'h0,aexpin[10:3]}),
                        .in2({5'h0,aexpin[10:0]}),
                        .in3(16'h0));
mj_s_mux4_d_16 nxasel_c(.mx_out(muxasel_c),
                        .sel(aexp_sel),
                        .in0(nxaexp_c),
                        .in1({8'h0,aexpin[10:3]}),
                        .in2({5'h0,aexpin[10:0]}),
                        .in3(16'h0));



mj_s_mux4_d_16 nxbsel(	.mx_out(muxbsel_temp),
			.sel(bexp_sel),
			.in0(nxbexp),
			.in1({8'h0,bexpin[10:3]}),
                	.in2({5'h0,bexpin[10:0]}),
			.in3(16'h0));

mj_s_mux2_d_16 exp_d1(	.mx_out(muxasel_tempa),
			.sel(cyc0_rst),
			.in0(nxaexp_a),
			.in1(muxasel_a));
mj_s_mux2_d_16 exp_d2(	.mx_out(muxasel_tempb),
			.sel(cyc0_rst),
			.in0(nxaexp_b),
			.in1(muxasel_b));
mj_s_mux2_d_16 exp_d3(	.mx_out(muxasel_tempc),
			.sel(cyc0_rst),
			.in0(nxaexp_c),
			.in1(muxasel_c));
mj_s_mux2_d_16 mubxsel_m0(.mx_out(muxbsel),
			.sel(cyc0_rst),
			.in0(nxbexp),
			.in1(muxbsel_temp));


assign muxasel = (eadd & (rsovf | incovf)) ? muxasel_tempa :
		 (amsb | incovf) ? muxasel_tempb : muxasel_tempc;
 


mj_s_ff_snre_d_16 aex(.out(aexp),.din(muxasel),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));
mj_s_ff_snre_d_16 bex(.out(bexp),.din(muxbsel),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));
mj_s_ff_snre_d_16 sax(.out(sa),.din(nxsa),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));


endmodule //exponent_dp


module excon_dec (	nx_excon,
			nx_dprec,
			muxbsel,
			nx_exconfunc,
			nx_mconfunc);

input   [1:0]   nx_mconfunc;
input   [3:0]   nx_exconfunc;
input  [15:0]   muxbsel;
input           nx_dprec;        // Double PRECision indicator.
output [15:0]   nx_excon;

reg    [15:0]   nx_excon, excon1;


 always @(nx_mconfunc or nx_dprec) begin
                case(nx_mconfunc)   //synopsys parallel_case full_case
                  2'b00: excon1 = 16'hc000;
                  2'b01: if(nx_dprec)
                           excon1 = 16'h35;
                         else
                           excon1 = 16'h18;
                  2'b10: excon1 = {6'h0,nx_dprec,nx_dprec,nx_dprec,7'h7f};
                  2'b11: excon1 = 16'h0;
                endcase
               end


 always @(nx_exconfunc or nx_dprec or muxbsel or excon1) begin
  case(nx_exconfunc)	//synopsys parallel_case full_case
      4'b0000: nx_excon = 16'h0;
      4'b0001: nx_excon = 16'h1;
      4'b0010: nx_excon = 16'h41e;
      4'b0011: nx_excon = 16'h43e;
      4'b0100: nx_excon = 16'h3ff;
      4'b0101: nx_excon = 16'h9e;
      4'b0110: nx_excon = 16'h7f;
      4'b0111: nx_excon = {5'h0,nx_dprec,nx_dprec,nx_dprec,8'hfe};
      4'b1000: nx_excon = 16'h7ff;
      4'b1001: nx_excon = 16'hff;
      4'b1010: nx_excon = {5'h0,nx_dprec,nx_dprec,nx_dprec,8'hff};
      4'b1011: nx_excon = excon1;
      4'b1100: nx_excon = 16'h380;
      4'b1101: nx_excon = 16'hbe;
      4'b1110: nx_excon = muxbsel;
      4'b1111: nx_excon = 16'h20;
  endcase
 end

endmodule
