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
`include "fpu.h"


module code_seq_dp (	romsel, 
			branch, 
			nxcode, 
			mword, 
			clk, 
			reset_l,
			valid_opcode, 
                     	opcode, 
			nx_opcode,
			nx_fpop_valid, 
			opcode_look, 
			nx_opcode_look, 
			cyc0_rdy, 
			nx_cyc0_rdy, 
			cyc0_rdy_p, 
			fpkill,
			erop,
			powerdown,
			fpuhold,
			nx_incfunc_rom1,
			nx_incfunc_rom0,
 			nx_multfunc_rom1,
			nx_multfunc_rom0,
			nx_rsfunc_rom0,
			nx_rsfunc_rom1,
			nx_expfunc_rom0,
			nx_expfunc_rom1,
			nx_prifunc_rom0,
			nx_prifunc_rom1,
			nx_exconfunc_rom0, nx_exconfunc_rom1,
			nx_mconfunc_rom0, nx_mconfunc_rom1,
			test_mode,
			sin,sm,so );

  input   [7:0] nx_opcode;
  input   [1:0] romsel;
  input         clk, nx_fpop_valid, opcode_look, nx_opcode_look, reset_l, fpuhold, fpkill;
  input    	sin,sm,test_mode, powerdown;
  output	so;
  output [41:0] mword;
  output  [7:0] nxcode, opcode;
  output  [3:0] branch, nx_multfunc_rom1, nx_multfunc_rom0, nx_incfunc_rom1, 
		nx_incfunc_rom0, nx_expfunc_rom0, nx_expfunc_rom1;
  output        valid_opcode, cyc0_rdy, nx_cyc0_rdy, cyc0_rdy_p, erop;
  output  [2:0] nx_rsfunc_rom0, nx_rsfunc_rom1, nx_prifunc_rom0,nx_prifunc_rom1;
output	[1:0]	nx_mconfunc_rom0, nx_mconfunc_rom1;
output	[3:0]	nx_exconfunc_rom0, nx_exconfunc_rom1 ;    // EXCON func.

  wire   [63:0] rom1out,rom0out,rom_mux_out;
  wire   [7:0]  mapadd, code_add;
  wire   [3:0]  link, nx_link;

  wire   [9:0]  extra ;
  wire   [63:0] buf_rom0out, buf_rom1out;
  wire		te;
  wire   [7:0]  bist_addr;

  wire valid_opcode_a, valid_opcode, fpop_valid;

wire [3:0] nx_link_0, nx_link_1;
wire [7:0] code_add_rom0, code_add_rom1, code_add_0;
wire [1:0] code_mux_sel_rom0,code_mux_sel_rom1,code_mux_sel_0; 

  
  wire fpuhold_l = ~fpuhold;
/*  wire fphold = fpuhold; */

/* wire [7:0] current_code_add, new_code_add; */

/* Testability Logic for Rom  */

/* Bist Address flop */
mj_s_ff_snr_d_8 tba     (
                        .out    (bist_addr),
                        .din    (~bist_addr),
                        .clk    (clk),
                        .reset_l  (reset_l)
);

/* Enable flop */
mj_s_ff_snr_d   tbe     (
                        .out    (te),
                        .in     (!te),
                        .clk    (clk),
                        .reset_l(reset_l)
);


/* Normal Address flop */
mj_s_ff_s_d_8   tff1    (
                        .out    (),
                        .din    (code_add),
                        .clk    (clk)
);
 
/* Normal Enable flop */
mj_s_ff_s_d     tff2    (
                        .out    (),
                        .in     (fpuhold_l),
                        .clk    (clk)
);

/* Normal Enable flop */
mj_s_ff_s_d     tff3    (
                        .out    (),
                        .in     (!powerdown),
                        .clk    (clk)
);
 
/* Rom0 data flop */
mj_s_ff_s_d_64  rom0_ff    (
                        .out    (),
                        .in    (buf_rom0out),
                        .clk    (clk)
);
/* Rom1 data flop */
mj_s_ff_s_d_64  rom1_ff    (
                        .out    (),
                        .in    (buf_rom1out),
                        .clk    (clk)
);

buf_64 buf1     ( .out(buf_rom1out), .in(rom1out) );
buf_64 buf0     ( .out(buf_rom0out), .in(rom0out) );

/* End of testability logic */

  fp_roms fprom_mod(	.rom_en(fpuhold_l),
			.me(!powerdown),
			.adr(code_add),
		        .clk(clk),
 			.do1(rom1out),
 			.do0(rom0out),
			.tadr(bist_addr),
			.tm(test_mode),
			.te(te)
			);


 mj_s_mux3_d_32 romouta(.mx_out(rom_mux_out[63:32]), 
			.sel(romsel), 
			.in0(rom0out[63:32]), 
			.in1(rom1out[63:32]),
			.in2(32'b0)
			);

 mj_s_mux3_d_32 romoutb(.mx_out(rom_mux_out[31:0]), 
			.sel(romsel), 
			.in0(rom0out[31:0]), 
			.in1(rom1out[31:0]),
			.in2(32'b0)
			);


assign nx_multfunc_rom0 = rom0out[41:38];
assign nx_multfunc_rom1 = rom1out[41:38];
assign nx_incfunc_rom0 = rom0out[9:6];
assign nx_incfunc_rom1 = rom1out[9:6];
assign nx_rsfunc_rom0 = rom0out[2:0];
assign nx_rsfunc_rom1 = rom1out[2:0];
assign nx_expfunc_rom0 = rom0out[20:17]; 
assign nx_expfunc_rom1 = rom1out[20:17];
assign nx_prifunc_rom0 = rom0out[5:3];
assign nx_prifunc_rom1 = rom1out[5:3];
assign nx_exconfunc_rom0 = rom0out[13:10];
assign nx_exconfunc_rom1 = rom1out[13:10];
assign nx_mconfunc_rom0 = rom0out[22:21];
assign nx_mconfunc_rom1 = rom1out[22:21];


mj_s_ff_snre_d_64 mw (	.out({extra,branch,nxcode,mword}),
			.din(rom_mux_out),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));

// when fpop is not 1, we don't bother to look and don't change address on rom
 wire   [7:0]  nx_opcode_v;
assign  nx_opcode_v = (nx_fpop_valid) ? nx_opcode :  8'b0;


wire nx_valid_opcode_pre, nx_valid_opcode_a, call_0, call_1;
  map mapd ( 		.mapadd(mapadd), 
			.nx_valid_opcode(nx_valid_opcode_pre), 
			.nx_valid_opcode_a(nx_valid_opcode_a), 
			.nx_opcode_v(nx_opcode_v), 
              		.nx_fpop_valid(nx_fpop_valid));

wire nx_valid_opcode = nx_valid_opcode_pre && !fpkill;

  acode_dec acode (	.code_mux_sel_rom0(code_mux_sel_rom0),
			.code_mux_sel_rom1(code_mux_sel_rom1),
			.code_mux_sel_0(code_mux_sel_0), 
			.fpkill(fpkill),
			.call_0(call_0), 
			.call_1(call_1), 
			.a2func(mword[31:29]), 
			.nx_a2func_rom0(rom0out[31:29]), 
			.nx_a2func_rom1(rom1out[31:29]), 
			.opcode_look(opcode_look), 
			.nx_opcode_look(nx_opcode_look), 
			.valid_opcode(valid_opcode), 
			.nx_valid_opcode(nx_valid_opcode), 
			.reset_l(reset_l), 
			.cyc0_rdy_p(cyc0_rdy_p), 
			.erop(erop));

  wire nx_cyc0_rdy = (nx_opcode_look && nx_valid_opcode_a &&
		   nx_fpop_valid); 

//  wire cyc0_rdy = (opcode_look && valid_opcode_a &&
//		   fpop_valid && ! fphold); 

  wire cyc0_rdy = (opcode_look && valid_opcode_a &&
		   fpop_valid);


/*********  3 choices of code_add pending romsel ****/
mj_s_mux4_d_8  mx_code_add_rom0(.mx_out(code_add_rom0),
                        .sel(code_mux_sel_rom0),
                        .in0(rom0out[49:42]),
                        .in1(mapadd),
                        .in2(8'h0),
                        .in3({4'h4,nx_link_0}));

mj_s_mux4_d_8  mx_code_add_rom1(.mx_out(code_add_rom1),
                        .sel(code_mux_sel_rom1),
                        .in0(rom1out[49:42]),
                        .in1(mapadd),
                        .in2(8'h0),
                        .in3({4'h4,nx_link_1}));

mj_s_mux4_d_8  mx_code_add_0(.mx_out(code_add_0),
                        .sel(code_mux_sel_0),
                        .in0(8'b0),
                        .in1(mapadd),
                        .in2(8'h0),
                        .in3({4'h4,link}));

mj_s_mux3_d_8  mx_code_add(.mx_out(code_add),
                        .sel(romsel),
                        .in0(code_add_rom0),
                        .in1(code_add_rom1),
                        .in2(code_add_0));
/********************************************************/


mj_s_ff_snre_d_8 ffopcode (	.out(opcode),
			.din(nx_opcode_v),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));


mj_s_ff_snre_d ff_opvalid (.out(fpop_valid),
			.in(nx_fpop_valid),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d ff_valid (.out(valid_opcode),
			.in(nx_valid_opcode),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d ff_valid_a (.out(valid_opcode_a),
			.in(nx_valid_opcode_a),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));



mj_s_mux2_d_4  linkmux_0(.mx_out(nx_link_0),
                        .sel(call_0),
                        .in0(link),
                        .in1(rom0out[13:10]));
mj_s_mux2_d_4  linkmux_1(.mx_out(nx_link_1),
                        .sel(call_1),
                        .in0(link),
                        .in1(rom1out[13:10]));


mj_s_mux3_d_4  linkmuxfinal(.mx_out(nx_link),
                        .sel(romsel),
			.in0(nx_link_0),
          		.in1(nx_link_1),
			.in2(link));
	

mj_s_ff_snre_d_4 link_mod (.out(link),
			.din(nx_link),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
            
endmodule


module acode_dec(       code_mux_sel_rom0, 
			code_mux_sel_rom1, 
			code_mux_sel_0,
                        call_0,
			call_1,
                        a2func,
			fpkill,
                        opcode_look,
                        valid_opcode,
                        nx_a2func_rom0,
                        nx_a2func_rom1,
                        nx_opcode_look,
                        nx_valid_opcode,
                        reset_l,
                        cyc0_rdy_p,
                        erop);	
               
 input  [2:0]  a2func, nx_a2func_rom0, nx_a2func_rom1;
 input         opcode_look, fpkill, reset_l, valid_opcode;
 input	       nx_opcode_look, nx_valid_opcode;

 output [1:0]  code_mux_sel_rom0, code_mux_sel_rom1, code_mux_sel_0;
 output        call_0, call_1, cyc0_rdy_p,erop;

 reg   [1:0]   code_mux_sel_rom0, code_mux_sel_rom1, code_mux_sel_0;


 assign erop = (a2func==3'h7);


  always @(nx_opcode_look or nx_valid_opcode or nx_a2func_rom0 or reset_l or fpkill) begin
     if(!reset_l || fpkill)                        code_mux_sel_rom0 = 2'h2;  // pick ZERO (goto idle) 
     else if(nx_opcode_look && nx_valid_opcode)  code_mux_sel_rom0 = 2'h1;  // pick MAPADD. 
     else if(nx_a2func_rom0==3'h5)                 code_mux_sel_rom0 = 2'h3;  // return with LINK. 
     else                                  code_mux_sel_rom0 = 2'h0;  // pick NXCODE. 
  end

  always @(nx_opcode_look or nx_valid_opcode or nx_a2func_rom1 or reset_l or fpkill) begin
     if(!reset_l || fpkill)                        code_mux_sel_rom1 = 2'h2;  
     else if(nx_opcode_look && nx_valid_opcode)  code_mux_sel_rom1 = 2'h1;  
     else if(nx_a2func_rom1==3'h5)                 code_mux_sel_rom1 = 2'h3;  
     else                                  code_mux_sel_rom1 = 2'h0;  
  end

  always @(nx_opcode_look or nx_valid_opcode or reset_l or fpkill) begin
     if(!reset_l || fpkill)                        code_mux_sel_0 = 2'h2;  
     else if(nx_opcode_look && nx_valid_opcode)  code_mux_sel_0 = 2'h1;  
     else                                  code_mux_sel_0 = 2'h0;  
  end


assign cyc0_rdy_p = (opcode_look && valid_opcode);

//  assign call     = (nx_a2func==3'h4);
  assign call_0     = (nx_a2func_rom0==3'h4);
  assign call_1     = (nx_a2func_rom1==3'h4);

endmodule


module map(     mapadd,
                nx_valid_opcode,
                nx_valid_opcode_a,
                nx_opcode_v,
                nx_fpop_valid);

  input  [7:0] nx_opcode_v;
  input        nx_fpop_valid;

  output [7:0] mapadd;
  output       nx_valid_opcode, nx_valid_opcode_a;

  reg    [7:0] mapadd;



  always @(nx_opcode_v) begin
    case(nx_opcode_v)   // synopsys parallel_case
        `FCMPG,
        `FCMPL,
        `DCMPG,
        `DCMPL: mapadd = 8'h5f;
        `DSUB,
        `DADD:  mapadd = 8'h1;
        `FSUB,
        `FADD:  mapadd = 8'h2c;
        `F2D:   mapadd = 8'h16;
        `D2F:   mapadd = 8'h1a;
        `F2I:   mapadd = 8'h3e;
        `F2L:   mapadd = 8'h1c;
        `D2I:   mapadd = 8'h5a;
        `D2L:   mapadd = 8'h50;
        `I2F:   mapadd = 8'h47;
        `L2F:   mapadd = 8'h4a;
        `I2D:   mapadd = 8'h52;
        `L2D:   mapadd = 8'h55;
        `FMUL:  mapadd = 8'h70;
        `DMUL:  mapadd = 8'h7a;
        `FDIV,
        `DDIV:  mapadd = 8'h80;
        `FREM,
        `DREM:  mapadd = 8'h94;
        default: mapadd = 8'h0;
   endcase
  end


  assign nx_valid_opcode = (nx_fpop_valid && (| mapadd));
  assign nx_valid_opcode_a = | mapadd;

endmodule

