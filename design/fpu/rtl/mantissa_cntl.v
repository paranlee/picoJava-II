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


module mantissa_cntl(a0func,a1func,a2func,ae_small,eadd,
                     morethree_taken,expsame,altb,a2,nxa2,
                     fpu_state,clk,cyc0_rdy,cyc1_rdy,
                     cyc0_type,manzero,mconfunc,
		     a0psel,
		     a1psel,fp_out_sel,a1sel,
		     a0sel,b0sel_a,b0sel_b,b1sel,b1psel,
		     b1msbin,amsb,bmsb, reset_l,a_small,
		     a0comp,a1comp,b0comp,b1comp,a1zzsel,
		     b1_cyc0sel,cyc0_sel, fpuhold, sm, sin, so);

  input   [2:0]  a2func,a1func,a0func,cyc0_type;
  input   [7:0]  fpu_state;
  input   [1:0]  mconfunc;
  input          ae_small,eadd,morethree_taken,expsame,altb, amsb, bmsb;
  input          cyc0_rdy,cyc1_rdy;
  input          clk;
  input 	 reset_l, fpuhold;
  input          a0comp,a1comp,b0comp,b1comp;

input sin, sm;
output so;
  
  output           a2, nxa2;
  output    [2:0]  a0psel;
  output    [2:0]  fp_out_sel;
  output    [2:0]  a1sel,a0sel;  
  output    [1:0]  a1psel,b0sel_a,b0sel_b,b1sel,cyc0_sel;
  output    	   b1psel,a1zzsel,b1_cyc0sel;

  output           b1msbin,manzero,a_small;

  wire    [1:0]  a2sel;
  wire           nxa2;

 wire    fpuhold_l = ~fpuhold;

    mantissa_dec mandec(.b0sel_a(b0sel_a),
			.b0sel_b(b0sel_b),
			.a1sel(a1sel),
			.a0sel(a0sel),
			.a0psel(a0psel),
	//		.a0psel_b(a0psel_b),
	//		.a0psel_c(a0psel_c),
                    	.altb(altb),
			.expsame(expsame),
			.ae_small(ae_small),
			.b1sel(b1sel),
                    	.a0func(a0func),
			.a1func(a1func),
			.fp_out_sel(fp_out_sel),
                    	.fpu_state(fpu_state),
			.b1msb(bmsb),
                    	.b1msbin(b1msbin),
			.b1psel(b1psel),
			.a1psel(a1psel),
			.a2sel(a2sel),
                    	.eadd(eadd),
			.a2func(a2func),
			.morethree_taken(morethree_taken),
                    	.cyc0_rdy(cyc0_rdy),
			.cyc0_type(cyc0_type),
			.cyc1_rdy(cyc1_rdy),
			.a1comp(a1comp),
                    	.a0comp(a0comp),
			.b1comp(b1comp),
			.b0comp(b0comp),
			.mconfunc(mconfunc),
                    	.amsb(amsb),
			.manzero(manzero),
			.a_small(a_small),
			.a1zzsel(a1zzsel),
			.b1_cyc0sel(b1_cyc0sel),
			.cyc0_sel(cyc0_sel));

    // assign amsb = a1[31];


mj_s_mux3_d nta2_mux(	.mx_out(nxa2), 
			.sel(a2sel), 
			.in0(a2), 
			.in1(1'h0),
			.in2(1'h1));

mj_s_ff_snre_d	a2reg(.out(a2),.in(nxa2), .lenable(fpuhold_l),.reset_l(reset_l), .clk(clk));

endmodule

