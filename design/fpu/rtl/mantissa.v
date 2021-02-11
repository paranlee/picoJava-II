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




module mantissa(a0func,a1func,a2func,rsout,lsout,a0inc,a1inc,ae_small,eadd,
                morethree_taken,expsame,altb,a2,a1,a0,b1,b0,fpout,aexpout,
                fpu_state,asign,sin,sm,so,clk,fpain,fpbin,cyc0_rdy,cyc1_rdy,
                cyc0_type,amsb,manzero,mconfunc, reset_l, fpuhold,
		nx_rsfunc_rom0, nx_rsfunc_rom1, romsel, r1out, r0out);


  input  [31:0]  rsout,lsout,a1inc,a0inc,fpain,fpbin;
  input  [10:0]  aexpout;
  input   [2:0]  a2func,a1func,a0func,cyc0_type;
  input	  [7:0]  fpu_state;
  input   [1:0]  mconfunc;
  input          ae_small,eadd,morethree_taken,expsame,altb,asign;
  input          cyc0_rdy,cyc1_rdy;
  input          sin,sm,clk, reset_l, fpuhold;
  input    [2:0]   nx_rsfunc_rom0, nx_rsfunc_rom1;
  input  [1:0]	   romsel;

  output	so;
  output [31:0]  a1,a0,b1,b0,fpout;
  output         a2,amsb,manzero;
  output   [31:0] r0out, r1out;

  wire    [2:0]  a0psel;
  wire    [2:0]  fp_out_sel;
  wire    [2:0]  a1sel,a0sel;  
  wire    [1:0]  a1psel,b0sel_a,b0sel_b,b1sel;
  wire    [1:0]  cyc0_sel;
  wire           b1msbin,b1psel;
  wire           a1comp,b1comp,a0comp,b0comp,a_small;
  wire 		nxa2, a1zzsel, b1_cyc0sel;

mantissa_cntl i_mantissa_cntl (.a0func(a0func),
		.a1func(a1func),
		.a2func(a2func),
		.ae_small(ae_small),
		.eadd(eadd),
                .morethree_taken(morethree_taken),
		.expsame(expsame),
		.altb(altb), 
		.a2(a2),
		.nxa2(nxa2),		// bring out for rsadd stuff generated in man_dp
                .fpu_state(fpu_state),
		.clk(clk),
		.reset_l(reset_l),
		.cyc0_rdy(cyc0_rdy),
		.cyc1_rdy(cyc1_rdy),
                .cyc0_type(cyc0_type),
		.manzero(manzero),
		.mconfunc(mconfunc),
		.a0psel(a0psel),
		.a1psel(a1psel),
		.fp_out_sel(fp_out_sel),
		.a1sel(a1sel),
		.a0sel(a0sel),
		.b0sel_a(b0sel_a),
		.b0sel_b(b0sel_b),
		.b1sel(b1sel),
		.b1psel(b1psel),
		.b1msbin(b1msbin),
		.amsb(a1[31]),
		.bmsb(b1[31]),
		.a1comp(a1comp),
		.b1comp(b1comp),
		.a0comp(a0comp),
		.b0comp(b0comp),
		.a_small(a_small),
                .a1zzsel(a1zzsel),
                .b1_cyc0sel(b1_cyc0sel),
		.fpuhold(fpuhold),
                .cyc0_sel(cyc0_sel),
		.sm(),
		.sin(),
		.so()	);

mantissa_dp   i_mantissa_dp (.rsout(rsout),
		.lsout(lsout),
		.a0inc(a0inc),
		.a1inc(a1inc),
		.a1(a1),
		.a0(a0),
		.b1(b1),
		.b0(b0),
		.nx_rsfunc_rom0(nx_rsfunc_rom0),  // for r0md generation
		.nx_rsfunc_rom1(nx_rsfunc_rom1),  // for r0md generation
		.romsel(romsel),
		.r1out(r1out),			  // send to rsadd
		.r0out(r0out),			  // send to rsadd
		.nxa2(nxa2),		          // from man_cntl for generating rsadd stuff
		.cyc0_rdy(cyc0_rdy),
		.fpout(fpout),
		.asign(asign),
		.clk(clk),
		.reset_l(reset_l),
		.fpain(fpain),
		.fpbin(fpbin), 
		.aexpout(aexpout),
		.a0psel(a0psel),
		.a1psel(a1psel),
		.fp_out_sel(fp_out_sel),
		.a1sel(a1sel),
		.a0sel(a0sel),
		.b1msbin(b1msbin),
		.b0sel_a(b0sel_a),
		.b0sel_b(b0sel_b),
		.b1sel(b1sel),
		.b1psel(b1psel),
		.a1comp(a1comp),
		.b1comp(b1comp),
		.a0comp(a0comp),
		.b0comp(b0comp),
		.amsb(amsb),
		.a0func(a0func),
		.a_small(a_small),
                .a1zzsel(a1zzsel),
                .b1_cyc0sel(b1_cyc0sel),
		.fpuhold(fpuhold),
                .cyc0_sel(cyc0_sel),
		.sm(),
		.sin(),
		.so()	);

endmodule
