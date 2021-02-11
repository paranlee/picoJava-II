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


module incmod(	a1, 
		a0, 
		b1, 
		b0, 
		incfunc, 
		stin, 
		eadd, 
		amsb, 
		altb, 
		incovf, 
		a1inc, 
		a0inc,
              	incin, 
		rsovf, 
		dprec, 
		qin, 
		qmsb, 
		clk, 
		reset_l,
     		so,
		sin,
		sm,
		romsel,
		nx_incfunc_rom0,
		nx_incfunc_rom1,
		fpuhold
		);

//  INCrement MODule

input  [31:0]  a1, a0, b1, b0;
input   [3:0]  incfunc, nx_incfunc_rom0, nx_incfunc_rom1;
input          stin, eadd, amsb, incin, rsovf, dprec;
input          clk, sin, sm, reset_l, fpuhold;
input  [1:0]   romsel;

output [31:0]  a1inc, a0inc;
output         altb, incovf, qin, qmsb;
  output        so;

//   Variable "lowcarry" undefined and "carrylow" not used anywhere
//   in the code. Changed variable "carrylow" to "lowcarry".
wire           carrytop, lowcarry;
wire   [31:0]  t1out, t0out, l1out, l0out, botadd, topadd, 
		pmd_muxout, t1out0, t1out1,
		loadd, loaddp, a0inc_0, a0inc_1, a1inc_0, a1inc_1;
reg    [31:0]  pmd_temp1;
wire   [31:0]  nxq1, nxq0, q1, q0, q1in1, q0in2, pmd_temp0, pmd_temp2; 
reg	[31:0] t1out_new0, t1out_new1;
wire    [1:0]  t1md;
wire    [2:0]  pmd;
wire    [1:0]  qmd, divmd0, divmd1, l1md, t0md, l0md;
wire           zmd, amsb, incrnd;  
wire           loadd_cin, si, div_sign, tcarry;

wire fpuhold_l = ~fpuhold;

// Following two decode modules is the decode (unstructured) portion of the INCMOD block.

 assign qmsb = q1[31];

 inc_decode incdec(	.t1md(t1md),
			.t0md(t0md),
			.l1md(l1md),
			.l0md(l0md),
			.incfunc(incfunc),
			.nx_incfunc_rom0(nx_incfunc_rom0),
			.nx_incfunc_rom1(nx_incfunc_rom1),
            	//	.rsovf(rsovf),
		//	.amsb(amsb),
		//	.eadd(eadd),
			.si(si),
			.loadd_cin(loadd_cin),
			.zmd(zmd),
			.romsel(romsel),
			.clk(clk),
			.reset_l(reset_l),
			.fpuhold_l(fpuhold_l),
			.so(),
			.sin(),
			.sm());


 div_decode divdec(	.divmd0(divmd0),
			.divmd1(divmd1),
			.qmd(qmd),
			.qin(qin),
			.sign_topadd(topadd[31]),
			.sign_botadd(botadd[31]),
                   	.lowcarry(lowcarry),
			.incfunc(incfunc),
			.incrnd(incrnd),
			.dprec(dprec),
			.pmd(pmd),
                   	.carrytop(carrytop),
			.incovf(incovf),
			.stin(stin),
			.div_sign(div_sign),
			.alsb(a1[0]),
			.t1in(t1out[8:0]));


// Following statements are the 32-bit datapath portion of the INCMOD block.

 mj_s_mux4l_d_32 t1mux0(	.mx_out(t1out0),
			.sel(t1md),
			.in0(a1),
			.in1(~a1),
			.in2(32'h0),
            		.in3(t1out_new0));


 mj_s_mux4l_d_32 t1mux1( .mx_out(t1out1),
                        .sel(t1md),
                        .in0(a1),
                        .in1(~a1),
                        .in2(32'h0),
                        .in3(t1out_new1));


 mj_s_mux2l_d_32 t1out_newmux(	.mx_out(t1out),
				.sel(amsb),
				.in0(t1out1),
				.in1(t1out0));

always @(eadd or rsovf or a1)
        if(eadd & rsovf)
                t1out_new0 = {1'h1,a1[31:1]};
        else 
                t1out_new0= a1;		// amsb =1

always @(eadd or rsovf or a1)
        if(eadd & rsovf)
                t1out_new1 = {1'h1,a1[31:1]};
        else
                t1out_new1 = {a1[30:0],1'h0}; 	//amsb = 0



 mj_s_mux4_d_32 t0mux(	.mx_out(t0out),
			.sel(t0md),
			.in0(32'h1),
			.in1({23'h0,incin,8'h0}),
			.in2(32'h0),
			.in3(~b1));


 cla_adder_32 bottad(	.cout(carrytop),
			.sum(botadd),
			.in1(t1out),
			.in2(t0out),
			.cin(1'h0));

 cla_adder_32 toppadd(	.cout(tcarry),
			.sum(topadd),
			.in1(a1),
			.in2(~b1),
			.cin(1'h1));


 mj_s_mux4_d_32 l1(	.mx_out(l1out),
			.sel(l1md),
			.in0(32'h0),
			.in1(a0),
			.in2(~a0),
			.in3(~b1));

 mj_s_mux4_d_32 l0(	.mx_out(l0out),
			.sel(l0md),
			.in0(32'h1),
			.in1({20'h0,incin,11'h0}),
			.in2(32'h0),
			.in3(~b0));


 cla_adder_32 looadd(	.cout(lowcarry),
			.sum(loaddp),
			.in1(l1out),
			.in2(l0out),
			.cin(loadd_cin));


 mj_s_mux2_d_32 loadd_mux(	.mx_out(loadd),
				.sel(zmd),
				.in0(loaddp),
				.in1({a1[0],a0[31:1]}));


 compare_lt_32 complt(	.out(altb),
			.in0(a1),
			.in1(b1));   // altb = (a1 < b1) ? 1 : 0;

 mj_s_mux6_d_32 pmdmux(	.mx_out(pmd_muxout),
			.sel(pmd),
			.in0(botadd),
			.in1(pmd_temp0),
			.in2({si,botadd[31:1]}),
			.in3(pmd_temp1),
			.in4(pmd_temp2),
			.in5(32'h0));




 mj_s_mux2_d_32 pmd_temp0_mux(	.mx_out(pmd_temp0),
				.sel(lowcarry),
				.in0(t1out),
				.in1(botadd));

// assign pmd_temp0 = lowcarry ? botadd : t1out;  

 always @(carrytop or incrnd or si or botadd or t1out)
 	if(incrnd)
	     pmd_temp1 = carrytop ? {si,botadd[31:1]} : botadd;
	else
	     pmd_temp1 = t1out;

 mj_s_mux2_d_32 pmd_temp2_mux(	.mx_out(pmd_temp2),
				.sel(lowcarry),
				.in0(botadd),
				.in1(topadd));

//  assign pmd_temp2 = lowcarry ? topadd : botadd;

  
 assign q1in1 = {q1[30:7],qin,7'h0};
 assign q0in2 = {q0[30:10],qin,10'h0};

 mj_s_mux4_d_32 q1mux(	.mx_out(nxq1),
			.sel(qmd),
			.in0(32'h0),
			.in1(q1in1),
			.in2({q1[30:0],q0[31]}),
			.in3(q1));

 mj_s_mux4_d_32 q0mux(	.mx_out(nxq0),
			.sel(qmd),
			.in0(32'h0),
			.in1(32'h0),
			.in2(q0in2),
			.in3(q0));

 mj_s_ff_snre_d_32 q0reg(	.out(q1),
				.din(nxq1),
				.reset_l(reset_l),
				.clk(clk),
				.lenable(fpuhold_l));

 mj_s_ff_snre_d_32 q1reg(	.out(q0),
				.din(nxq0),
				.reset_l(reset_l),
				.clk(clk),
				.lenable(fpuhold_l));
			

 mj_s_mux4_d_32 a0incmux_0(	.mx_out(a0inc_0),
				.sel(divmd0),
				.in0(loadd),
				.in1({loadd[30:0],1'h0}),
                  		.in2({a0[30:0],1'h0}),.in3(q0));

 mj_s_mux4_d_32 a0incmux_1(    	.mx_out(a0inc_1),
                        	.sel(divmd1),
                        	.in0(loadd),
                        	.in1({loadd[30:0],1'h0}),
                        	.in2({a0[30:0],1'h0}),.in3(q0));


 mj_s_mux4_d_32 a1incmux_0(	.mx_out(a1inc_0),
				.sel(divmd0),
				.in0(pmd_muxout),
				.in1({pmd_muxout[30:0],loadd[31]}),
                  		.in2({a1[30:0],a0[31]}),.in3(q1));

 mj_s_mux4_d_32 a1incmux_1(	.mx_out(a1inc_1),
				.sel(divmd1),
				.in0(pmd_muxout),
				.in1({pmd_muxout[30:0],loadd[31]}),
                  		.in2({a1[30:0],a0[31]}),.in3(q1));

 assign a0inc = div_sign ? a0inc_1 : a0inc_0;
 assign a1inc = div_sign ? a1inc_1 : a1inc_0;

endmodule


module div_decode(	divmd0, 
			divmd1, 
			qmd,
			qin, 
			sign_topadd, 
			sign_botadd, 
			lowcarry, 
			incfunc, 
			incrnd,
			dprec,
                  	pmd, 
			carrytop, 
			incovf, 
			stin, 
			alsb, 
			t1in,
			div_sign
			);

 input    [8:0] t1in;
 input    [3:0] incfunc;
 input          sign_topadd, sign_botadd, lowcarry, dprec, carrytop;
 input          stin, alsb; 

 output   [1:0] divmd0, divmd1, qmd;
 output   [2:0] pmd;
 output         incovf, incrnd, qin, div_sign;

 reg      [1:0]   qmd;

//reg	[1:0]	pmd_0, pmd_1;
reg	[2:0]	pmd;

wire	[1:0]	divmd0, divmd1, divmd_pre;

 wire           div_sign, sticky, incrnd;

wire		incovf_pre;
//wire		incovf_0, incovf_1;


 assign sticky = stin | alsb | (| t1in[6:0]);
 assign incrnd = t1in[7] && (sticky || (!sticky && t1in[8]));  // round

always @(incfunc)
	if((incfunc==4'h1) || (incfunc==4'h2))
		pmd = 3'h1;
	else if(incfunc==4'h5)
		pmd = 3'h3;
	else if(incfunc==4'h8)
		pmd = 3'h4;
	else if((incfunc==4'h7) || (incfunc==4'ha))
                pmd = 3'h2;
          else
                pmd = 3'h0;


// assign incovf_pre = (pmd==2'h0) || (incfunc==4'h5);
assign incovf_pre = ((incfunc==4'h1) || (incfunc==4'h2) || 
	             (incfunc==4'h8)) & !lowcarry;

assign incovf = !incovf_pre & incrnd & carrytop ;



 assign div_sign = (lowcarry) ? sign_topadd : sign_botadd;

assign divmd_pre = {(incfunc[3] & !incfunc[2] & !incfunc[1] & incfunc[0]),
		   (incfunc[3] & !incfunc[2] & !incfunc[1] & incfunc[0])}; 

assign divmd0 = (incfunc[3] & !incfunc[2] & !incfunc[1] & !incfunc[0]) ?  
			2'b01 : divmd_pre;
assign divmd1 = (incfunc[3] & !incfunc[2] & !incfunc[1] & !incfunc[0]) ?  
			2'b10 : divmd_pre;



 always @(incfunc or dprec) 
	begin
           if(incfunc==4'h8)           
		qmd = {dprec,!dprec};  // DDIV, DREM or FDIV, FREM 
      	   else if((incfunc==4'hb) || (incfunc==4'h7)) 
		qmd = 2'h3;  // hold on Qhold   
      	   else                                        
		qmd = 2'h0; 
	end


wire qin = ((incfunc[3] & !incfunc[2] & !incfunc[1] & !incfunc[0]) && 
 	    !div_sign);



endmodule


module inc_decode(	t1md, 
			t0md, 
			l1md, 
			l0md, 
			incfunc, 
			nx_incfunc_rom0, 
			nx_incfunc_rom1, 
			romsel,
//			rsovf, 
//			amsb, 
//			eadd, 
			si,
                  	loadd_cin, 
			zmd,
			clk,
			reset_l,
     			so,
			sin,
			sm,
			fpuhold_l
			);

// INCrement module DECoder

input  [3:0]   incfunc, nx_incfunc_rom0, nx_incfunc_rom1;
input          clk, reset_l, fpuhold_l;
input  [1:0]   romsel;
input	       sin, sm;

output	       so;
output [1:0]   t1md;
output [1:0]   l1md, t0md, l0md;
output         zmd;
output         si, loadd_cin;

wire    [1:0]   t1md, t1mda, nx_t1mda;
wire    [1:0]   t1mda_rom0, t1mda_rom1;
wire    [1:0]   nx_t0md, nx_l1md, t0md, l1md, t0md_rom0,
		t0md_rom1, l1md_rom0, l1md_rom1;
wire   [1:0]    nx_l0md, l0md, l0md_rom0, l0md_rom1;

//wire	[2:0]	nx_t1mdb, t1mdb_0_rom0, t1mdb_0_rom1, t1mdb_1_rom0,
//		t1mdb_1_rom1; 
//wire	[2:0]   t1mdb_0, t1mdb_1;
wire           zmd;

inc_t1mda_rom i0 (	.t1mda_rom(t1mda_rom0), 
			.nx_incfunc_rom(nx_incfunc_rom0));
inc_t1mda_rom i1 (	.t1mda_rom(t1mda_rom1), 	
			.nx_incfunc_rom(nx_incfunc_rom1));

inc_t0md_rom i5 (	.t0md_rom(t0md_rom0), 
			.nx_incfunc_rom(nx_incfunc_rom0));
inc_t0md_rom i6 (	.t0md_rom(t0md_rom1), 
			.nx_incfunc_rom(nx_incfunc_rom1));

inc_l1md_rom i7 (	.l1md_rom(l1md_rom0), 
			.nx_incfunc_rom(nx_incfunc_rom0));
inc_l1md_rom i8 (	.l1md_rom(l1md_rom1), 
			.nx_incfunc_rom(nx_incfunc_rom1));

inc_l0md_rom i9 (	.l0md_rom(l0md_rom0), 
			.nx_incfunc_rom(nx_incfunc_rom0));
inc_l0md_rom i10 (	.l0md_rom(l0md_rom1), 
			.nx_incfunc_rom(nx_incfunc_rom1));

mj_s_mux3_d_2 t1mda_mux(	.mx_out(nx_t1mda),
				.sel(romsel),
				.in0(t1mda_rom0),
				.in1(t1mda_rom1),
				.in2(2'h2));

mj_s_mux3_d_2 t0md_mux(		.mx_out(nx_t0md),
				.sel(romsel),
                        	.in0(t0md_rom0),
                        	.in1(t0md_rom1),
                        	.in2(2'h2));

mj_s_mux3_d_2 l1md_mux(		.mx_out(nx_l1md),
				.sel(romsel),
                        	.in0(l1md_rom0),
                        	.in1(l1md_rom1),
                        	.in2(2'h0));

mj_s_mux3_d_2 l0md_mux(        	.mx_out(nx_l0md),
                        	.sel(romsel),
                        	.in0(l0md_rom0),
                        	.in1(l0md_rom1),
                        	.in2(2'h2));


mj_s_ff_snre_d_2 t1mda_ff(      .out(t1mda),
                        	.din(nx_t1mda),
                        	.reset_l(reset_l),
                        	.clk(clk),
				.lenable(fpuhold_l));

mj_s_ff_snre_d_2 t0md_ff(       .out(t0md),
                        	.din(nx_t0md),
                       		.reset_l(reset_l),
                        	.clk(clk),
				.lenable(fpuhold_l));

mj_s_ff_snre_d_2 l0md_ff(       .out(l0md),
                        	.din(nx_l0md),
                       		.reset_l(reset_l),
                        	.clk(clk),
				.lenable(fpuhold_l));

mj_s_ff_snre_d_2 l1md_ff(       .out(l1md),
                        	.din(nx_l1md),
                       		.reset_l(reset_l),
                        	.clk(clk),
				.lenable(fpuhold_l));

// assign t1mdb = (amsb) ? t1mdb_1 : t1mdb_0 ;

// assign t1md = (eadd && rsovf) ? t1mda : t1mdb;

assign t1md = t1mda;

 assign si        = !(incfunc==4'ha);
 assign loadd_cin = (incfunc==4'h8);
 assign zmd       = (incfunc==4'ha);


endmodule



module inc_t1mda_rom (t1mda_rom, nx_incfunc_rom);

input [3:0] nx_incfunc_rom;
output [1:0] t1mda_rom;

reg [1:0] t1mda_rom;

 always @(nx_incfunc_rom) begin
    casex(nx_incfunc_rom)          // synopsys full_case parallel_case
           4'b0000,
	   4'b1011: t1mda_rom=2'h2;
	   4'b001x,
           4'b0100: t1mda_rom=2'h1;
           4'b0101: t1mda_rom=2'h3;
	   4'b0001,
           4'b011x,
	   4'b1010,
	   4'b100x: t1mda_rom=2'h0;
           default: t1mda_rom=2'hx;
    endcase
 end

endmodule



/************* not used
module inc_t1mdb_rom (t1mdb_1_rom, t1mdb_0_rom, nx_incfunc_rom);

input [3:0] nx_incfunc_rom;
output [2:0] t1mdb_1_rom, t1mdb_0_rom;

reg [2:0] t1mdb_1_rom, t1mdb_0_rom; 

 always @(nx_incfunc_rom) begin
    casex(nx_incfunc_rom)      // synopsys full_case parallel_case
           4'b0000,
           4'b1011: t1mdb_1_rom=3'h4;
	   4'b001x,
           4'b0100: t1mdb_1_rom=3'h1;
           4'b0101: t1mdb_1_rom = 3'h0;
           4'b0001, 
           4'b011x,
           4'b1010,
           4'b100x: t1mdb_1_rom=3'h0;
           default: t1mdb_1_rom=3'hx;
    endcase
 end
 always @(nx_incfunc_rom ) begin
    casex(nx_incfunc_rom)       // synopsys full_case parallel_case
           4'b0000,
           4'b1011: t1mdb_0_rom=3'h4;
	   4'b001x,
           4'b0100: t1mdb_0_rom=3'h1;
           4'b0101: t1mdb_0_rom = 3'h2;
           4'b0001, 
           4'b011x,
           4'b1010,
           4'b100x: t1mdb_0_rom=3'h0;
           default: t1mdb_0_rom=3'hx;
    endcase
 end

endmodule
************* not used *********/


module inc_t0md_rom (t0md_rom, nx_incfunc_rom);

output [1:0] t0md_rom;
input [3:0] nx_incfunc_rom;

reg [1:0] t0md_rom;

 always @(nx_incfunc_rom) begin
    casex(nx_incfunc_rom)      // synopsys full_case parallel_case
           4'b0000, 
           4'b0111,
           4'b101x: t0md_rom=2'h2;
           4'b0001, 
           4'b001x,
           4'b0100: t0md_rom=2'h0;
           4'b0101,
           4'b0110: t0md_rom=2'h1;
           4'b100x: t0md_rom=2'h3;
           default: t0md_rom=2'hx;
    endcase 
 end
endmodule


module inc_l1md_rom (l1md_rom, nx_incfunc_rom);
output [1:0] l1md_rom;
input [3:0] nx_incfunc_rom;

reg [1:0] l1md_rom;

 always @(nx_incfunc_rom) begin
    casex(nx_incfunc_rom)        // synopsys full_case parallel_case
           4'b0001,
           4'b100x: l1md_rom=2'h1;
           4'b0010: l1md_rom=2'h2;
           4'b0011: l1md_rom=2'h3;
	   4'b0000,
	   4'b010x,
           4'b011x,
           4'b101x: l1md_rom=2'h0;
           default: l1md_rom=2'hx;
    endcase
 end
endmodule


module inc_l0md_rom(nx_incfunc_rom, l0md_rom);

input [3:0] nx_incfunc_rom;
output [1:0] l0md_rom;

reg [1:0] l0md_rom;

 always @(nx_incfunc_rom) begin
     casex(nx_incfunc_rom)           // synopsys full_case parallel_case
           4'b0001: l0md_rom=2'h1;
	   4'b001x: l0md_rom=2'h0;
	   4'b0000,
           4'b010x, 
           4'b011x,
           4'b101x: l0md_rom=2'h2;
           4'b100x: l0md_rom=2'h3;
           default: l0md_rom=2'hx;
     endcase
 end

endmodule
