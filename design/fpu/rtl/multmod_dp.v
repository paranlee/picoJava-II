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




module multmod_dp ( mb1, mb0, ma1, ma0, 
    		    clk, reset_l, nx_multdec_muxcntl,
		    multout, movf, fpuhold, sm, sin, so);

input  [31:0] mb1;
input  [20:0] mb0;
input  [31:0] ma1;
input  [20:0] ma0;
input  clk; 
input  reset_l, fpuhold;
input  [17:0] nx_multdec_muxcntl;
input sm, sin;


output so;
output [31:0] multout;
output movf;


wire [14:0] multiplier; 
wire [26:0] mcan; 
wire [27:0] sinma; 
wire [27:0] sinhi; 
wire [27:0] sinlo; 
wire [27:0] cin; 
wire [27:0] cinhi; 
wire [27:0] cinlo; 
wire [27:0] nx_sinlo; 
wire [27:0] nx_cinlo; 
wire [27:0] nx_sinhi; 
wire [27:0] nx_cinhi; 
wire [27:0] sout;
wire [27:0] cout;
wire [1:0]  mout_sel;

//wire [2:0]  hi_selx, stop_selx, lo_selx;
//wire [1:0]  mctselx, hi_addx, dp_hix, hix;

wire dpmul, mctsel, hi_add, dp_hi, hi;
wire [2:0] multsel;
wire [1:0] mcansel, hi_sel, lo_sel, stop_sel;

wire fpuhold_l = ~fpuhold;


mj_s_ff_snre_d_18 multdecout_moutselcntl(.out({dpmul, multsel, mcansel, hi_sel, lo_sel, stop_sel, mctsel, hi_add, dp_hi, hi,mout_sel}),
					.din({nx_multdec_muxcntl[15:0],nx_multdec_muxcntl[17:16]}),
					.lenable(fpuhold_l),
					.reset_l(reset_l),
					.clk(clk));


wire multmux_temp;
 mj_s_mux6_d_16 multmux (.mx_out({multmux_temp, multiplier}), 
			.in5({1'b0,mb1[18:8],4'b0}),
        		.in4({1'b0,mb0[11:0],3'b0}), 
        		.in3({2'b0,mb1[31:18]}), 
        		.in2({1'b0,mb1[18:4]}),
			.in1({1'b0,mb1[4:0],mb0[20:11]}),
			.in0(16'b0), 
        		.sel(multsel) );


wire [4:0] mcanmux_temp;
mj_s_mux4_d_32 mcanmux(	.mx_out({mcanmux_temp,mcan}),
			.sel(mcansel),
			.in0(32'b0),
			.in1({5'b0,ma1[31:5]}),
			.in2({5'b0,ma1[4:0],ma0[20:0],1'h0}),
                   	.in3({5'b0,ma1[31:8],3'b0}));

wire mcant, mcanmi;
mj_s_mux2_d mcantmux ( 	.mx_out(mcant), 
			.in1(ma1[5]), 
			.in0(1'b0), 
			.sel(mctsel) );

mj_s_mux2_d mcanmimux (.mx_out(mcanmi), 
			.in1(ma1[4]), 
			.in0(1'b0), 
			.sel(dp_hi) );


wire [3:0] sinmux_temp;
mj_s_mux2_d_32 sinmux(	.mx_out({sinmux_temp,sinma}),
			.sel(dp_hi),
			.in0({4'b0,sinlo}),
			.in1({4'b0,sinhi}));


wire [3:0] cinmux_temp;
mj_s_mux2_d_32 cinmux(	.mx_out({cinmux_temp,cin}),
			.sel(dp_hi),
			.in0({4'b0,cinlo}),
			.in1({4'b0,cinhi}));
 

wire [3:0] sinhi_mux_temp;
wire [3:0] cinhi_mux_temp;
mj_s_mux3_d_32 sinhi_mux(.mx_out({sinhi_mux_temp,nx_sinhi}),
			.sel(hi_sel),
			.in0({32'b0}),
			.in1({4'b0,sout}),
			.in2({4'b0,sinhi}));
mj_s_mux3_d_32 cinhi_mux(.mx_out({cinhi_mux_temp,nx_cinhi}),
			.sel(hi_sel),
			.in0({32'b0}),
			.in1({4'b0,cout}),
			.in2({4'b0,cinhi}));


// add eci logic for new mult_array at multmod level  
wire 	eco, nx_eci, eci, nx_sti, sti, sto, nx_negseli, negseli, negselo, aco, nx_aci, aci;
wire [3:0] sinlo_mux_temp;
wire [3:0] cinlo_mux_temp;
mj_s_mux3_d_32 sinlo_mux(.mx_out({sinlo_mux_temp,nx_sinlo}),
			.sel(lo_sel),
			.in0(32'b0),
			.in1({4'b0,sout}),
			.in2({4'b0,sinlo}));
mj_s_mux3_d_32 cinlo_mux(.mx_out({cinlo_mux_temp,nx_cinlo}),
			.sel(lo_sel),
			.in0(32'b0),
			.in1({4'b0,cout}),
			.in2({4'b0,cinlo}));
mj_s_mux3_d stimux (.mx_out(nx_sti),
                        .in2(sti),
                        .in1(sto),
                        .in0(1'b0),
                        .sel(lo_sel) );
mj_s_mux3_d negselmux (.mx_out(nx_negseli),
                        .in2(negseli),
                        .in1(negselo),
                        .in0(1'b0),
                        .sel(lo_sel) );
mj_s_mux3_d acimux (.mx_out(nx_aci),
                        .in2(aci),
                        .in1(aco),
                        .in0(1'b0),
                        .sel(lo_sel) );
mj_s_mux3_d ecimux (.mx_out(nx_eci),
                        .in2(eci),
                        .in1(eco),
                        .in0(1'b0),
                        .sel(lo_sel) );

mj_s_ff_snre_d_28 ffsinlo(.out(sinlo),
			.din(nx_sinlo),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d_28 ffcinlo(.out(cinlo),
			.din(nx_cinlo),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d_28 ffsinhi(.out(sinhi),
			.din(nx_sinhi),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d_28 ffcinhi(.out(cinhi),
			.din(nx_cinhi),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));

wire negi, nego, stopout, stopin;
   mult_array marray(	.multiplier(multiplier),
			.mcan(mcan),
			.sti(sti),
			.aci(aci),
			.eci(eci),
			.cin(cin),
			.sinma(sinma),
              		.negi(negi),
			.sout(sout),
			.cout(cout),
			.nego(nego),
			.aco(aco),
			.eco(eco),
			.sto(sto),
			.stopout(stopout),
              		.stopin(stopin),
			.hi(hi),
			.mcanmi(mcanmi),
			.negseli(negseli),
			.negselo(negselo),
              		.mcant(mcant),
			.so(),
			.sm(),
			.sin(),
			.fpuhold_l(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));

   mult_add  madd(	.dpmul(dpmul),
			.hi_add(hi_add),
			.cinlo(cinlo[26:0]),
			.cinhi(cinhi[26:0]),
			.sinlo(sinlo),
                  	.sinhi(sinhi),
			.sti(sti),
			.multout(multout),
			.movf(movf),
                  	.aci(aci),
                 	.eci(eci),
			.mout_sel(mout_sel),
			.so(),
			.sm(),
			.sin(),
			.clk(clk),
			.fpuhold_l(fpuhold_l),
			.reset_l(reset_l));


wire nx_stopin, nx_negi;

mj_s_mux3_d stopinmux (.mx_out(nx_stopin),
                        .in2(stopin),
                        .in1(stopout),
                        .in0(1'b0),
                        .sel(stop_sel) );
mj_s_mux3_d negimux (.mx_out(nx_negi),
                        .in2(negi),
                        .in1(nego),
                        .in0(1'b0),
                        .sel(stop_sel) );

// Add one bit to mult_state for new mult_array 
// Added logic from multmod_cntl  


mj_s_ff_snre_d_6 mult_state (.out({aci,negseli,negi,stopin,sti,eci}),
			.din({nx_aci, nx_negseli, nx_negi, nx_stopin, nx_sti, nx_eci}),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
 
endmodule

module mult_add(eci, dpmul,hi_add,cinlo,cinhi,sinlo,sinhi,sti,multout,movf,
		aci,mout_sel, sin,sm,so,clk, reset_l, fpuhold_l);

  input  [27:0]  sinlo,sinhi;
  input  [26:0]  cinlo,cinhi;
  input  [1:0]   mout_sel;
  input          dpmul,sti,aci, eci, hi_add;
  input          sin,sm,clk, reset_l, fpuhold_l;
  output	 so;
  output [31:0]  multout;
  output         movf;

  wire   [27:0]  caddout,saddout,cadd,addout;
  wire   [23:0]  sp_out;
  wire   [22:0]  fadd;
  wire   [3:0]   multhold,por;
  wire   [1:0]   spmd, mout_dr;
  wire           saddtop,carry_in,iovf,lin,ctop,aovf,laovf;
  wire  [27:0]  newsinhi;
  wire  [27:0]  sinhiout;
	
// added new sinhi logic for new mult_array 
// using fa28 to add one 28-bit to one 1-bit
//	since this is not timing critical.
//	if it becomes critial, we can optimize this.

  cla_adder_28 inc_sinhi (      .in1(sinhi),
				.in2(28'b0),
				.cin(eci),
				.cout(),
				.sum(sinhiout)
				);


mj_s_ff_snre_d_28 ffincsin(.out(newsinhi),
			.din(sinhiout),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));


mj_s_mux2_d cadd27mux  (.mx_out(cadd[27]), 
			.in1(1'b0), 
			.in0(cinlo[26]), 
			.sel(dpmul) );

mj_s_mux2_d_4 pormux(.mx_out(por),
			.sel(dpmul),
			.in0({3'h0,sti}),
			.in1(multhold));

  assign cadd[26:0] = {cinlo[25:0],aci};
  assign laovf      = addout[27];
 
  assign saddtop = !dpmul & sinlo[27];


wire [3:0] caddmux_temp;
wire [3:0] saddmux_temp;
mj_s_mux2_d_32 caddmux(	.mx_out({caddmux_temp,caddout}),
			.sel(hi_add),
			.in0({4'b0,cadd}),
			.in1({4'b0,cinhi[26:0],ctop}));
mj_s_mux2_d_32 saddmux(	.mx_out({saddmux_temp,saddout}),
			.sel(hi_add),
			.in0({4'b0,saddtop,sinlo[26:0]}),
			.in1({4'b0,newsinhi}));
mj_s_mux2_d     carry(	.mx_out(carry_in),
			.sel(hi_add),
			.in0(1'h0),
			.in1(aovf));

mj_s_ff_snre_d_6 muhold (.out({aovf,ctop,multhold}),
			.din({laovf,cinlo[26], addout[26:23]}),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));

 
  cla_adder_28   add28(	.sum(addout),
			.in1(caddout),
			.in2(saddout),
			.cin(carry_in),
			.cout());
 
/************************************************
*** replace with new adder, inc23 combination     
***         see module mult_addinc below.
  increment_23  inc23(	.cout(iovf),
			.sum(fadd),
			.in(addout[26:4]));
************************************************/
  mult_addinc addinc_0 (.fadd(fadd),
			.iovf(iovf),
			.in0(caddout),
			.in1(saddout),
			.cin(carry_in));


  mj_s_mux4_d_16 spmux_23_8  (.mx_out(sp_out[23:8]),
			.sel(spmd),
			.in0({1'h1,fadd[22:8]}),
			.in1({1'h1,addout[26:12]}),
                	.in2(addout[26:11]),
			.in3(fadd[22:7])); 
  mj_s_mux4_d_8 spmux_7_0  (.mx_out(sp_out[7:0]),
			.sel(spmd),
			.in0(fadd[7:0]),
			.in1(addout[11:4]),
                	.in2({addout[10:4],lin}),
			.in3({fadd[6:0],lin})); 

 mj_s_mux4_d_32 moutmux(.mx_out(multout),
			.sel(mout_dr),
			.in0({sp_out,8'h0}),
			.in1({addout,por}),
                  	.in2({addout[22:0],8'h0,sti}),
			.in3({addout[26:0],por,1'h0}));

  spdec spdecode(	.spmd(spmd),
			.lin(lin),
			.laovf(laovf),
			.alow(addout[4:0]),
			.sti(sti),
			.mout_sel(mout_sel),
                 	.mout_dr(mout_dr),
			.iovf(iovf),
			.movf(movf));

endmodule





module spdec(spmd,lin,laovf,alow,sti,mout_sel,mout_dr,iovf,movf);
 
  input   [4:0]  alow;
  input   [1:0]  mout_sel;
  input          iovf,sti,laovf;
 
  output  [1:0]  spmd,mout_dr;
  output         movf,lin;
 
 
  reg     [1:0]  mout_dr,spmd;
  reg            lin;
 
  wire           sg,incp,incl,sticky,gbit,lbit,pbit;
 
 
   always @(mout_sel or laovf) begin
       if(mout_sel==2'h3) 
	begin
              if(laovf) 
		mout_dr = 2'h1;
              else      
		mout_dr = 2'h3;
        end
       else  
		mout_dr = mout_sel;
   end
 
   assign sticky = (sti || (| alow[1:0]));
   assign gbit   = alow[2];
   assign lbit   = alow[3];
   assign pbit   = alow[4];
 
   assign incl = ((gbit && sticky) || (gbit && lbit));  // round
 
   assign sg = gbit || sticky;
 
   assign incp = ((lbit && sg) || (lbit && pbit));  // round

   always @(laovf or incp or incl or lbit) 
    begin
      if(laovf) 
	begin
         	lin = 1'h0;
         	spmd = {1'b0,!incp};  /* pick RS1 inc at P position. */
		   		     /* else pick RS1 no inc.  */
        end
      else 
	begin
           if(incl &&  lbit) 
	     begin
                spmd=2'h3;  
		lin=1'h0;     /* no RS inc at P position. */
             end
            else if(incl && !lbit) 
	     begin
               	spmd=2'h2;  
		lin=1'h1;     /* no RS inc at L Position. */
             end
            else 
	     begin
              	spmd=2'h2;  
		lin=lbit;
             end
      	end
    end

assign movf = ((mout_sel==2'h0) && iovf && ((spmd==2'h3) || 
			(spmd==2'h0))) ? (laovf || iovf) : laovf;

 
endmodule
 

module mult_addinc(fadd,iovf,in0,in1,cin);
 
  input   [27:0] in0,in1;
  input   	 cin;
 
  output  [22:0] fadd;
  output         iovf;

wire [27:0] ai = in0;
wire [27:0] bi = in1;
wire [27:0] co, so, addsum;

assign fadd = addsum[26:4];
assign iovf = addsum[27];

cla_adder_28   add28(	.sum(addsum),
			.in1({co[26:0],1'b0}),
			.in2(so),
			.cin(cin),
			.cout());


multha  inc_ha0 (.ai(ai[0]), .bi(bi[0]), .co(co[0]), .so(so[0]));
multha  inc_ha1 (.ai(ai[1]), .bi(bi[1]), .co(co[1]), .so(so[1]));
multha  inc_ha2 (.ai(ai[2]), .bi(bi[2]), .co(co[2]), .so(so[2]));
multha  inc_ha3 (.ai(ai[3]), .bi(bi[3]), .co(co[3]), .so(so[3]));
multfa  inc_fa4 (.ai(ai[4]), .bi(bi[4]), .ci(1'b1), .co(co[4]), .so(so[4]));
multha  inc_ha5 (.ai(ai[5]), .bi(bi[5]), .co(co[5]), .so(so[5]));
multha  inc_ha6 (.ai(ai[6]), .bi(bi[6]), .co(co[6]), .so(so[6]));
multha  inc_ha7 (.ai(ai[7]), .bi(bi[7]), .co(co[7]), .so(so[7]));
multha  inc_ha8 (.ai(ai[8]), .bi(bi[8]), .co(co[8]), .so(so[8]));
multha  inc_ha9 (.ai(ai[9]), .bi(bi[9]), .co(co[9]), .so(so[9]));
multha  inc_ha10 (.ai(ai[10]), .bi(bi[10]), .co(co[10]), .so(so[10]));
multha  inc_ha11 (.ai(ai[11]), .bi(bi[11]), .co(co[11]), .so(so[11]));
multha  inc_ha12 (.ai(ai[12]), .bi(bi[12]), .co(co[12]), .so(so[12]));
multha  inc_ha13 (.ai(ai[13]), .bi(bi[13]), .co(co[13]), .so(so[13]));
multha  inc_ha14 (.ai(ai[14]), .bi(bi[14]), .co(co[14]), .so(so[14]));
multha  inc_ha15 (.ai(ai[15]), .bi(bi[15]), .co(co[15]), .so(so[15]));
multha  inc_ha16 (.ai(ai[16]), .bi(bi[16]), .co(co[16]), .so(so[16]));
multha  inc_ha17 (.ai(ai[17]), .bi(bi[17]), .co(co[17]), .so(so[17]));
multha  inc_ha18 (.ai(ai[18]), .bi(bi[18]), .co(co[18]), .so(so[18]));
multha  inc_ha19 (.ai(ai[19]), .bi(bi[19]), .co(co[19]), .so(so[19]));
multha  inc_ha20 (.ai(ai[20]), .bi(bi[20]), .co(co[20]), .so(so[20]));
multha  inc_ha21 (.ai(ai[21]), .bi(bi[21]), .co(co[21]), .so(so[21]));
multha  inc_ha22 (.ai(ai[22]), .bi(bi[22]), .co(co[22]), .so(so[22]));
multha  inc_ha23 (.ai(ai[23]), .bi(bi[23]), .co(co[23]), .so(so[23]));
multha  inc_ha24 (.ai(ai[24]), .bi(bi[24]), .co(co[24]), .so(so[24]));
multha  inc_ha25 (.ai(ai[25]), .bi(bi[25]), .co(co[25]), .so(so[25]));
multha  inc_ha26 (.ai(ai[26]), .bi(bi[26]), .co(co[26]), .so(so[26]));
multha  inc_ha27 (.ai(ai[27]), .bi(bi[27]), .co(co[27]), .so(so[27]));
 


endmodule




