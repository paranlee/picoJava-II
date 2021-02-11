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



module mantissa_dp(rsout,lsout,a0inc,a1inc,a1,a0,b1,b0,fpout,asign,clk,
		   fpain,fpbin, aexpout,a0psel, reset_l,
		   a1psel,fp_out_sel,a1sel, a0sel,b0sel_a,b1sel,
		   b1msbin,b1psel,a1comp,b1comp,a0comp,b0comp, amsb,
		   b0sel_b,a_small,a0func,a1zzsel,b1_cyc0sel,
		   cyc0_sel, cyc0_rdy, fpuhold,sm, sin, so,
		   nx_rsfunc_rom0, nx_rsfunc_rom1, romsel, r1out, r0out, nxa2);

  input   [31:0]  rsout,lsout,a1inc,a0inc,fpain,fpbin;
  input   [10:0]  aexpout;
  input           asign, a_small;
  input           clk, reset_l, cyc0_rdy, fpuhold;
  input    [2:0]  a0psel;
  input    [2:0]  fp_out_sel,a0func;
  input    [2:0]  a1sel;  
  input    [1:0]  b0sel_a,b0sel_b,b1sel;
  input    [1:0]  cyc0_sel,a1psel;
  input	   [2:0]  a0sel;
  input    	  b1psel,b1msbin, a1zzsel, b1_cyc0sel;
  input		  sm, sin;
  input    [2:0]   nx_rsfunc_rom0, nx_rsfunc_rom1;
  input  [1:0]	   romsel;
  input		  nxa2;

  output	  so;
  output [31:0]  a1,a0,b1,b0,fpout;
  output	a1comp,b1comp,a0comp,b0comp, amsb;
  output   [31:0] r0out, r1out;

  wire   [31:0]  asingle,a1double0,a1merged_double,a1double1,bsingle,b1double0,b1double1;
  wire   [31:0]  nxb1,cyc0_muxout,a1zout,nxb1_temp,nxb1_temp1;
  wire   [31:0]  a1pre,b1pre,a0pre;
  wire   [31:0]  nxa0,nxa0_temp,nxb0,nxa1,nxa1_temp,nxb0_a,nxb0_b,
		 nxa0_mid, nxa1_mid, nxb0_mid;

wire    fpuhold_l = ~fpuhold;	  


  mj_s_mux2_d_32 a1zmux(.mx_out(a1zout),
			.sel(a1zzsel),
			.in0(a1),
			.in1({b1msbin,b1[30:0]}));

mj_s_mux8_d_32 na1(	.mx_out(nxa1_temp),
			.sel(a1sel),
			.in0(a1pre),
			.in1(rsout),
			.in2(lsout),
			.in3(a1inc),
			.in4(a0inc),
			.in5(a1double1),
			.in6(a1zout),
			.in7(32'h0)	);

mj_s_mux4_d_32 a1pr_cyc0(.mx_out(a1pre),
			.sel(a1psel),
			.in0(a1double0),
			.in1(asingle),
			.in2(fpain),
			.in3(a1merged_double)	);

mj_s_mux4_d_32 nb0_b(	.mx_out(nxb0_b),
			.sel(b0sel_b),
			.in0(b0),
			.in1(a0),
			.in2({fpbin[20:0],11'h0}),
			.in3(32'h0)	);

mj_s_mux4_d_32 nb0_a(	.mx_out(nxb0_a),
			.sel(b0sel_a),
			.in0(b0),
			.in1(a0),
			.in2({fpbin[20:0],11'h0}),
			.in3(32'h0)	);

mj_s_mux6_d_32 na0(	.mx_out(nxa0_temp),
			.sel(a0sel),
			.in0(rsout),
			.in1(a0inc),
			.in2(lsout),
			.in3(a0pre),
			.in4(cyc0_muxout),
			.in5(32'h0)	);

mj_s_mux6_d_32 a0pre_mux(.mx_out(a0pre),
			.sel(a0psel),
			.in0(a0),
			.in1(b0),
			.in2(a1),
			.in3(32'h0),	
			.in4({fpain[20:0],11'h0}),
			.in5(32'h0));


mj_s_mux3_d_32 cyc0_mux(	.mx_out(cyc0_muxout),
			.sel(cyc0_sel),
			.in0(32'h0),
			.in1({fpbin[20:0],11'h0}),
			.in2(fpbin)	);

mj_s_mux6_d_32 fpo(	.mx_out(fpout),
			.sel(fp_out_sel),
			.in0(32'h0),
			.in1(a1),
			.in2(a0),
			.in3({asign,aexpout,a1[30:11]}),
			.in4({a1[10:0],a0[31:11]}),
			.in5({asign,aexpout[7:0],a1[30:8]})	);

mj_s_mux2_d_32 b1_cyc0mux(	.mx_out(nxb1_temp1),
			.sel(b1_cyc0sel),
			.in0(nxb1_temp),
			.in1(b1pre)	);

mj_s_mux4_d_32 nb1(	.mx_out(nxb1_temp),
			.sel(b1sel),
			.in0(b1),
			.in1(a1),
			.in2({1'h0,b1[30:0]}),
                	.in3(b1double1)	);

mj_s_mux2_d_32 b1pse(	.mx_out(b1pre),
			.sel(b1psel),
			.in0(bsingle),
			.in1(b1double0));

 
    compare_zero_32 a1zero(.out(a1comp),.in({1'h0,a1[30:0]}));
    compare_zero_32 b1zero(.out(b1comp),.in({1'h0,b1[30:0]}));
    compare_zero_32 a0zero(.out(a0comp),.in(a0));
    compare_zero_32 b0zero(.out(b0comp),.in(b0));
  


    wire [31:0] nxb0_temp = ((a0func==5) || ((a0func==1) && !a_small)) ?
		       		nxb0_b : nxb0_a;


    assign asingle         = {1'h1,fpain[22:0],8'h0};
    assign a1double0       = {1'h1,fpain[19:0],11'h0};
    assign a1merged_double = {1'h1,fpain[19:0],fpbin[31:21]};
    assign a1double1       = {a1[31:11],fpain[31:21]};

    assign bsingle         = {1'h1,fpbin[22:0],8'h0};
    assign b1double0       = {1'h1,fpbin[19:0],11'h0};
    assign b1double1       = {b1[31:11],fpbin[31:21]};

    assign amsb = a1[31];



assign nxb0 = nxb0_mid;
assign nxb1 = nxb1_temp1;
assign nxa0 = nxa0_mid;
assign nxa1 = nxa1_mid;


mj_s_mux2_d_32 nxb0_m1(	.mx_out(nxb0_mid),
                        .sel(cyc0_rdy),
                        .in1(32'b0),
                        .in0(nxb0_temp));

mj_s_mux2_d_32 nxa0_m1(	.mx_out(nxa0_mid),
                        .sel(cyc0_rdy),
                        .in1(cyc0_muxout),
                        .in0(nxa0_temp));

mj_s_mux2_d_32 nxa1_m1(	.mx_out(nxa1_mid),
                        .sel(cyc0_rdy),
                        .in1(a1pre),
                        .in0(nxa1_temp));


mj_s_ff_snre_d_32	nta1(.out(a1),.din(nxa1),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));
mj_s_ff_snre_d_32	nta0(.out(a0),.din(nxa0),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));
mj_s_ff_snre_d_32	ntb1(.out(b1),.din(nxb1),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));
mj_s_ff_snre_d_32	ntb0(.out(b0),.din(nxb0),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));


/***** from rsadd  *****/
//wire [1:0]  nx_r0md, r0md;
reg  [1:0]  r0md_rom0, r0md_rom1;

 always @(nx_rsfunc_rom0) 
   begin
      casex(nx_rsfunc_rom0)    // synopsys full_case parallel_case
         3'b000:  r0md_rom0 = 2'h2;
         3'b001,
         3'b010,
         3'b11x:  r0md_rom0 = 2'h0;
         3'b011,
         3'b10x:  r0md_rom0 = 2'h1;
         default: r0md_rom0 = 2'hx;
      endcase
   end

 always @(nx_rsfunc_rom1)
   begin
      casex(nx_rsfunc_rom1)    // synopsys full_case parallel_case
         3'b000:  r0md_rom1 = 2'h2;
         3'b001,
         3'b010,
         3'b11x:  r0md_rom1 = 2'h0;
         3'b011,
         3'b10x:  r0md_rom1 = 2'h1;
         default: r0md_rom1 = 2'hx;
      endcase
   end



wire [31:0] nx_r0out, nx_r1out, nx_r0out_rom0, nx_r0out_rom1, nx_r1out_rom0, nx_r1out_rom1;
mj_s_mux3_d_32 muxr0_rom0 ( 	.mx_out(nx_r0out_rom0),
				.in2(32'h0),
				.in1(nxa1), 
				.in0(nxa0), 
				.sel(r0md_rom0) 
				);
mj_s_mux3_d_32 muxr1_rom0 ( 	.mx_out(nx_r1out_rom0),
				.in2(32'h0),
				.in1({32{nxa2}}), 
				.in0(nxa1), 
				.sel(r0md_rom0) 
				);
mj_s_mux3_d_32 muxr0_rom1 ( 	.mx_out(nx_r0out_rom1),
				.in2(32'h0),
				.in1(nxa1), 
				.in0(nxa0), 
				.sel(r0md_rom1) 
				);
mj_s_mux3_d_32 muxr1_rom1 ( 	.mx_out(nx_r1out_rom1),
				.in2(32'h0),
				.in1({32{nxa2}}), 
				.in0(nxa1), 
				.sel(r0md_rom1) 
				);

mj_s_mux3_d_32 r0mux(		.mx_out(nx_r0out),
				.sel(romsel),
				.in0(nx_r0out_rom0),
				.in1(nx_r0out_rom1),
				.in2(32'h0));

mj_s_mux3_d_32 r1mux(		.mx_out(nx_r1out),
				.sel(romsel),
				.in0(nx_r1out_rom0),
				.in1(nx_r1out_rom1),
				.in2(32'h0));

mj_s_ff_snre_d_32	ff_r1out(.out(r1out),.din(nx_r1out),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));
mj_s_ff_snre_d_32	ff_r0out(.out(r0out),.din(nx_r0out),.lenable(fpuhold_l),.reset_l(reset_l),.clk(clk));


endmodule
