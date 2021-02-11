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




module mult_array(eci, eco, multiplier,mcan,sti,aci,cin,sinma,negi,sout,cout,nego,aco,sto,stopout,
             stopin,hi,mcanmi,negseli,negselo,mcant,sm,so,sin,clk, fpuhold_l, reset_l);

 input  [27:0]   sinma,cin;
 input  [26:0]   mcan;
 input  [14:0]   multiplier;
 input      	 hi;
 input           sti,aci,negi,stopin,mcanmi,negseli,mcant, eci;
 input           sin,sm,clk,fpuhold_l, reset_l;

 output		 so;
 output [27:0]   sout,cout;
 output          aco,stopout,negselo,sto,nego, eco;


 wire [27:0]   	mp6, mp5, mp4, mp3, mp2, mp1, mp0;
 wire [6:0]	signbit;
 wire [6:0]	hilos27, hilos28, hiloc27;
 wire [6:0] 	savec0, saves0, saves1;
 wire [1:0] 	extra6c;


 wire [6:0]	localnegi, leadbit;
 signgen  signgeneration (.localnegi(localnegi), 
			.leadbit(leadbit), 
			.negi(negi), 
			.signbit(signbit), 
			.stopin(stopin), 
			.negselo(negselo), 
			.nego(nego), 
			.stopout(stopout)
			);



 mpselect  mpselection  ( .mp6(mp6), .mp5(mp5), .mp4(mp4), .mp3(mp3), .mp2(mp2), 
		.mp1(mp1), .mp0(mp0), .multiplier(multiplier), .mcant(mcant), 
		.mcan(mcan), .mcanmi(mcanmi), .signbit(signbit));


 wire [6:0] s27forsign, c27forsign; 
 wire [6:4] extrahiloc26;
 assign s27forsign[0] = sinma[27];
 assign c27forsign[0] = cin[27];
 highlow  highlowsel  (	.s27(s27forsign),
			.c27(c27forsign),
			.s28(leadbit),
			.hi(hi),
			.s0(saves0),
			.c0(savec0),
			.s1(saves1),
			.extra6c(extra6c),
			.extrahiloc26(extrahiloc26[6:4]),
			.eci(eci),
			.outs27(hilos27),
			.outc27(hiloc27),
			.outs28(hilos28)
			);



// prepare to sign extend  (data here used as inputs to highlow module which
// selects between sign extend and saved data addition.) 
// (localnegi[6] + mp6[27] is taken care of later.)
 addnegi  addnegi1 ( .ai(localnegi[5:0]),
		     .bi({mp5[27], mp4[27], mp3[27], mp2[27], mp1[27], mp0[27]}),
		     .co({c27forsign[6:1]}),
		     .so({s27forsign[6:1]})
			);

// add cin, sinma, and mp0
 wire [28:2] row0s_bit;
 wire [29:3] row0c_bit;
 tree27  treerow0 ( .ai({hilos28[0],hilos27[0],sinma[26:2]}),
		     .bi({hiloc27[0],cin[26:1]}),
		     .ci(mp0[26:0]),
		     .so(row0s_bit[28:2]),
		     .co(row0c_bit[29:3])
		     );


// add mp1, mp2, and mp3
 wire [30:8] row1s_bit;
 wire [31:9] row1c_bit;
 tree23  treerow1 (  .ai(mp1[26:4]),
		     .bi(mp2[24:2]),
		     .ci(mp3[22:0]),
		     .so(row1s_bit[30:8]),
		     .co(row1c_bit[31:9])
		     );

// add mp4, mp5, and mp6
 wire [36:14] row2s_bit;
 wire [37:15] row2c_bit;
 tree23  treerow2 (  .ai(mp4[26:4]),
		     .bi(mp5[24:2]),
		     .ci(mp6[22:0]),
 		     .so(row2s_bit[36:14]),
		     .co(row2c_bit[37:15])
		     );


/*******************************************************************************/
// add partials
 wire [32:4] row3s_bit;
 wire [33:5] row3c_bit;
 tree29  treerow3 (  .ai({hiloc27[2], hilos27[2], hiloc27[1], hilos27[1], row0s_bit[28:4]}),
		     .bi({hilos28[2], row1c_bit[31], hilos28[1], row0c_bit[29:4]}),
		     .ci({mp2[26:25], row1s_bit[30:8], mp1[3:0]}),
		     .so(row3s_bit[32:4]),
		     .co(row3c_bit[33:5])
		     );

// add partials
 wire [40:12] row4s_bit;
 wire [41:13] row4c_bit;
 tree29  treerow4 (  .ai({hiloc27[6], hilos27[6], hilos28[5], mp5[25], hilos28[4], 
				hilos27[4], mp3[26:23], row1c_bit[30:12]}),
		     .bi({hilos28[6], 1'b0, mp5[26], row2c_bit[37:15], 1'b0, mp5[1:0]}),
		     .ci({mp6[26:23], row2s_bit[36:14], mp4[3:2]}),
		     .so(row4s_bit[40:12]),
		     .co(row4c_bit[41:13])
		     );

/*******************************************************************************/
// add partials

 wire [39:6] row5s_bit;
 wire [40:7] row5c_bit;
 tree34  treerow5 (  .ai({extrahiloc26[6], hiloc27[5], hilos27[5], hiloc27[4], 
				extrahiloc26[4], hiloc27[3], hilos27[3], row3s_bit[32:6]}),
		     .bi({row4c_bit[39:35], hilos28[3], row3c_bit[33:6]}),
		     .ci({row4s_bit[39:12], row1c_bit[11:9], 1'b0, mp2[1:0]}),
		     .so(row5s_bit[39:6]),
		     .co(row5c_bit[40:7])
		     );


/*******************************************************************************/
// add partials
 wire [41:8] row6s_bit;
 wire [42:9] row6c_bit;
 tree34  treerow6 (  .ai({localnegi[6], row4s_bit[40], row5s_bit[39:8]}),
		     .bi({mp6[27], row5c_bit[40:8]}),
		     .ci({row4c_bit[41:40], 2'b0, extrahiloc26[5], 2'b0, 
				row4c_bit[34:13], 1'b0, mp4[1:0], 2'b0}),
		     .so(row6s_bit[41:8]),
		     .co(row6c_bit[42:9])
		     );

/*******************************************************************************/

wire	final6c_bit16, 	final6c_bit15, 	final6s_bit15, 	final6s_bit14;
guesscout guesscout0 (	.row1c_bit14(row1c_bit[14]), 
			.row2s_bit14(row2s_bit[14]), 
			.row3s_bit14(row3s_bit[14]), 
			.row3c_bit14(row3c_bit[14]),
			.row5c_bit14(row5c_bit[14]), 
			.row4c_bit14(row4c_bit[14]), 
			.row5s_bit15(row5s_bit[15]),
			.row6c_bit14(row6c_bit[14]),
			.row6s_bit14(row6s_bit[14]), 
			.row6s_bit15(row6s_bit[15]), 
			.row6c_bit15(row6c_bit[15]), 
			.row6c_bit16(row6c_bit[16]),
			.final6c_bit16(final6c_bit16), 	
			.final6c_bit15(final6c_bit15), 	
			.final6s_bit15(final6s_bit15), 	
			.final6s_bit14(final6s_bit14)
		);

assign cout[27:0] = {row6c_bit[42:17],final6c_bit16,final6c_bit15};
assign sout[27:0] = {row6s_bit[41:16],final6s_bit15,final6s_bit14};

assign eco = row4c_bit[41];


// save intermediate data for use in the next array iteration.
// used in double precision after calculation of upper arrays.


mj_s_ff_snre_d_7 ffsavec0(.out(savec0),
			.din({row6c_bit[13], row6c_bit[11], row6c_bit[9], row5c_bit[7], row3c_bit[5], row0c_bit[3], cin[0]}),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d_7 ffsaves0(.out(saves0),
			.din({row6s_bit[12], row6s_bit[10], row6s_bit[8], row5s_bit[6], row3s_bit[4], row0s_bit[2], sinma[0]}),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d_7 ffsaves1(.out(saves1),
			.din({row6s_bit[13], row6s_bit[11], row6s_bit[9], row5s_bit[7], row3s_bit[5], row0s_bit[3], sinma[1]}),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));
mj_s_ff_snre_d_2 ffextra6c(.out(extra6c),
			.din({row6c_bit[12],row6c_bit[10]}),
			.lenable(fpuhold_l),
			.reset_l(reset_l),
			.clk(clk));




// sum up right edge and do 2's complement
propagate_end propend(	.signbit(signbit), .sin0(sinma[0]), .sin1(sinma[1]), 
			.cin0(cin[0]), .row0s_bit3(row0s_bit[3]), 
			.row0s_bit2(row0s_bit[2]), .row0c_bit3(row0c_bit[3]),
			.row3s_bit5(row3s_bit[5]), .row3s_bit4(row3s_bit[4]), 
			.row3c_bit5(row3c_bit[5]), .row5s_bit7(row5s_bit[7]), 
			.row5s_bit6(row5s_bit[6]), .row5c_bit7(row5c_bit[7]),
			.row6s_bit13(row6s_bit[13]), .row6s_bit11(row6s_bit[11]), 
			.row6s_bit10(row6s_bit[10]), .row6c_bit12(row6c_bit[12]), 
			.row6c_bit11(row6c_bit[11]), .aci(aci), .sti(sti), .negseli(negseli), 
			.row3s_bit8(row3s_bit[8]), .row3c_bit8(row3c_bit[8]), 
			.row5s_bit9(row5s_bit[9]), .row5c_bit8(row5c_bit[8]), 
			.row5s_bit12(row5s_bit[12]), .row5c_bit12(row5c_bit[12]), 
			.aco(aco), .sto(sto)
			);

endmodule


module signgen (localnegi, leadbit, negi, signbit, stopin, negselo, nego, stopout);

output [6:0] 	localnegi, leadbit;
output		negselo, nego, stopout;
input 		negi, stopin;
input [6:0]  	signbit;

// localnegi inputs to a row indicates whether any previous rows have selected
// a negative multiplicand.
 assign localnegi[0] = negi;
 assign localnegi[1] = negi | signbit[0];
 assign localnegi[2] = negi | signbit[0] | signbit[1];
 assign localnegi[3] = negi | signbit[0] | signbit[1] | signbit[2];
 assign localnegi[4] = negi | signbit[0] | signbit[1] | signbit[2] | signbit[3];
 assign localnegi[5] = negi | signbit[0] | signbit[1] | signbit[2] | signbit[3] 
			| signbit[4];
 assign localnegi[6] = negi | signbit[0] | signbit[1] | signbit[2] | signbit[3] 
			| signbit[4] | signbit[5];

 assign negselo = signbit[6];
 assign nego = localnegi[6] | signbit[6];


// leadbits are used for "sign extension."  we actually only have unsigned numbers,
// so what we do is not really sign extension, but rather flipping the leading bits
// if a negative multiple is selected.
 assign leadbit[0] = stopin;
 assign leadbit[1] = localnegi[0] ^ signbit[0];
 assign leadbit[2] = localnegi[1] ^ signbit[1];
 assign leadbit[3] = localnegi[2] ^ signbit[2];
 assign leadbit[4] = localnegi[3] ^ signbit[3];
 assign leadbit[5] = localnegi[4] ^ signbit[4];
 assign leadbit[6] = localnegi[5] ^ signbit[5];

 assign stopout = localnegi[6] ^ signbit[6];

endmodule


module highlow(eci, s27, c27, s28, hi, s0, c0, s1, outs27, outc27, outs28, extra6c, extrahiloc26);

// in double precision, each "row" of multiplication calculation is
// split between 2 arrays, which can be viewed as adjacent:  the higher
// order and the lower order arrays.  The higher order array produces
// intermediate signals which must be used by the lower order array.
// also, the higher order array needs to account for leading "1" bits
// whenever a negative multiple is selected by the booth logic.
// this module selects the "datasave" when we are doing the lower order
// arrays, and selects the leading "1" maintenance logic when we are doing
// higher order arrays (or when we're doing single precision.)

input [6:0] 	s27, c27, s28, s0, c0, s1;
input [1:0]	extra6c;
output [6:0]	outs27, outc27, outs28;
output [2:0]	extrahiloc26;
input		eci, hi;

wire		extra4c;
wire [3:0] 	news0, newc0, news1;
wire 		temp1, temp2, temp3;

// 0
multha  hiloha0 (.ai(eci), .bi(s0[0]), .co(newc0[0]), .so(news0[0]));
multha  hiloha1 (.ai(s1[0]), .bi(c0[0]), .co(temp1), .so(news1[0]));

// 1
multha  hiloha2 (.ai(temp1), .bi(s0[1]), .co(newc0[1]), .so(news0[1]));
multha  hiloha3 (.ai(s1[1]), .bi(c0[1]), .co(temp2), .so(news1[1]));

// 2
multha  hiloha4 (.ai(temp2), .bi(s0[2]), .co(newc0[2]), .so(news0[2]));
multha  hiloha5 (.ai(s1[2]), .bi(c0[2]), .co(temp3), .so(news1[2]));

// 3
multha  hiloha6 (.ai(temp3), .bi(s0[3]), .co(newc0[3]), .so(news0[3]));
multha  hiloha7 (.ai(s1[3]), .bi(c0[3]), .co(extra4c), .so(news1[3]));


mj_s_mux2_d_3 muxextra (.mx_out(extrahiloc26),
		.sel(hi),
		.in0({extra6c[1:0], extra4c}),
		.in1(3'b0)
		);
mj_s_mux2_d_3 muxhi0 (	.mx_out({outs27[0],outc27[0],outs28[0]}),
		.sel(hi),
		.in0({news0[0],newc0[0],news1[0]}),
		.in1({s27[0],c27[0],s28[0]})
		);
mj_s_mux2_d_3 muxhi1 (	.mx_out({outs27[1],outc27[1],outs28[1]}),
		.sel(hi),
		.in0({news0[1],newc0[1],news1[1]}),
		.in1({s27[1],c27[1],s28[1]})
		);
mj_s_mux2_d_3 muxhi2 (	.mx_out({outs27[2],outc27[2],outs28[2]}),
		.sel(hi),
		.in0({news0[2],newc0[2],news1[2]}),
		.in1({s27[2],c27[2],s28[2]})
		);
mj_s_mux2_d_3 muxhi3 (	.mx_out({outs27[3],outc27[3],outs28[3]}),
		.sel(hi),
		.in0({news0[3],newc0[3],news1[3]}),
		.in1({s27[3],c27[3],s28[3]})
		);
mj_s_mux2_d_3 muxhi4 (	.mx_out({outs27[4],outc27[4],outs28[4]}),
		.sel(hi),
		.in0({s0[4],c0[4],s1[4]}),
		.in1({s27[4],c27[4],s28[4]})
		);
mj_s_mux2_d_3 muxhi5 (	.mx_out({outs27[5],outc27[5],outs28[5]}),
		.sel(hi),
		.in0({s0[5],c0[5],s1[5]}),
		.in1({s27[5],c27[5],s28[5]})
		);
mj_s_mux2_d_3 muxhi6 (	.mx_out({outs27[6],outc27[6],outs28[6]}),
		.sel(hi),
		.in0({s0[6],c0[6],s1[6]}),
		.in1({s27[6],c27[6],s28[6]})
		);


endmodule





module guesscout (row1c_bit14, row2s_bit14, row3s_bit14, row3c_bit14,
		row5c_bit14, row4c_bit14, row5s_bit15, row6c_bit14,
		row6s_bit14, row6s_bit15, row6c_bit15, row6c_bit16,
		final6c_bit16, 	final6c_bit15, 	final6s_bit15, 	final6s_bit14);

input 	row1c_bit14, row2s_bit14, row3s_bit14, row3c_bit14,
		row5c_bit14, row4c_bit14, row5s_bit15, row6c_bit14,
		row6s_bit14, row6s_bit15, row6c_bit15, row6c_bit16;
output	final6c_bit16, 	final6c_bit15, 	final6s_bit15, 	final6s_bit14;

wire	guess6c_bit16, 	guess6c_bit15, 	guess6s_bit15, 	guess6s_bit14;
wire 	guess5c_bit15, 	guess5s_bit14, 	guess4c_bit15, 	guess4s_bit14;

multfa  guessfa0 (	.ai(row1c_bit14),
			.bi(row2s_bit14),
			.ci(1'b1),		// guess a 1 at row6c_bit[14]
			.so(guess4s_bit14),
			.co(guess4c_bit15)
		);

multfa  guessfa1 (	.ai(row3s_bit14),
			.bi(row3c_bit14),
			.ci(guess4s_bit14),		
			.so(guess5s_bit14),
			.co(guess5c_bit15)
		);

multfa  guessfa2 (	.ai(row5c_bit14),
			.bi(row4c_bit14),
			.ci(guess5s_bit14),		
			.so(guess6s_bit14),
			.co(guess6c_bit15)
		);

multfa  guessfa3 (	.ai(row5s_bit15),
			.bi(guess5c_bit15),
			.ci(guess4c_bit15),		
			.so(guess6s_bit15),
			.co(guess6c_bit16)
		);

mj_s_mux2_d_4 guessfinal0 (	.mx_out({final6s_bit14, final6s_bit15, final6c_bit15, final6c_bit16}),
			.sel(row6c_bit14),
			.in0({row6s_bit14, row6s_bit15, row6c_bit15, row6c_bit16}),
			.in1({guess6s_bit14, guess6s_bit15, guess6c_bit15, guess6c_bit16}));
endmodule




module mpselect(mp6, mp5, mp4, mp3, mp2, mp1, mp0, multiplier, mcant, mcan, 
		mcanmi, signbit);

// this module uses radix-4 booth recoding to select multiplicands.
// there are 7 values of multiplicands selected because we "look" at 2 bits 
// of the multiplier input at a time (therefore 14/2 = 7).  (booth actually
// needs a third bit (bit(i-1)) in order to resolve the multiplicand
// selection for the 2 bits we are taking care of.)

 output [27:0]   mp6, mp5, mp4, mp3, mp2, mp1, mp0;
 output [6:0]	 signbit;
 input  [26:0]   mcan;
 input  [14:0]   multiplier;
 input		 mcant, mcanmi;

 wire   [1:0]	 mselx0, mselx1, mselx2, mselx3, mselx4, mselx5, mselx6;
 wire		 negsel0, negsel1, negsel2, negsel3, negsel4, negsel5, negsel6;

   fpu_booth  booth0 (.mselx(mselx0),.negsel(negsel0),
			.bits(multiplier[2:0]), .signbit(signbit[0]));
   fpu_booth  booth1 (.mselx(mselx1),.negsel(negsel1),
			.bits(multiplier[4:2]), .signbit(signbit[1]));
   fpu_booth  booth2 (.mselx(mselx2),.negsel(negsel2),
			.bits(multiplier[6:4]), .signbit(signbit[2]));
   fpu_booth  booth3 (.mselx(mselx3),.negsel(negsel3),
			.bits(multiplier[8:6]), .signbit(signbit[3]));
   fpu_booth  booth4 (.mselx(mselx4),.negsel(negsel4),
			.bits(multiplier[10:8]), .signbit(signbit[4]));
   fpu_booth  booth5 (.mselx(mselx5),.negsel(negsel5),
			.bits(multiplier[12:10]), .signbit(signbit[5]));
   fpu_booth  booth6 (.mselx(mselx6),.negsel(negsel6),
			.bits(multiplier[14:12]), .signbit(signbit[6]));

   mpmux      mpselect0 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel0), .mselx(mselx0), .mp(mp0));
   mpmux      mpselect1 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel1), .mselx(mselx1), .mp(mp1));
   mpmux      mpselect2 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel2), .mselx(mselx2), .mp(mp2));
   mpmux      mpselect3 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel3), .mselx(mselx3), .mp(mp3));
   mpmux      mpselect4 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel4), .mselx(mselx4), .mp(mp4));
   mpmux      mpselect5 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel5), .mselx(mselx5), .mp(mp5));
   mpmux      mpselect6 (.mcant(mcant), .mcan(mcan), .mcanmi(mcanmi), 
			.negsel(negsel6), .mselx(mselx6), .mp(mp6));

endmodule



module mpmux (mcant, mcan, mcanmi, negsel, mselx, mp);

 input  [26:0]   mcan;
 input		 mcant, mcanmi, negsel;
 input  [1:0]	 mselx;

 output [27:0]	 mp;

 wire  	[26:0]	 mcan_l   = ~mcan; 
 wire   	 mcant_l  = !mcant;

/*************************************
 wire   	 mcanmi_l = !mcanmi;

 wire   [27:0]   mp_1x, mp_2x, mp_a, mp_b;

// select negative first, since negsel signal is fast
wire [3:0] neg1x_temp;
wire [3:0] neg2x_temp;

mj_s_mux2_d_32 neg1x (.mx_out({neg1x_temp,mp_1x}), .sel(negsel), 
			.in0({4'b0,mcant,mcan}), .in1({4'b0,mcant_l,mcan_l}));
mj_s_mux2_d_32 neg2x (.mx_out({neg1x_temp,mp_2x}), .sel(negsel), 
			.in0({4'b0,mcan,mcanmi}), .in1({4'b0,mcan_l,mcanmi_l}));

// use 3 nands to perform a fast 2:1 mux with 0 as default output when both selects are low.

 fpu_nand in_1x (.outz(mp_a), .ina({28{mselx[0]}}), .inb(mp_1x));
 fpu_nand in_2x (.outz(mp_b), .ina({28{mselx[1]}}), .inb(mp_2x));
 fpu_nand mpsel (.outz(mp), .ina(mp_a), .inb(mp_b));
**************************************/


/**** instantiate H0261a *****/

wire [27:0] ina = {  mcant,  mcan};
wire [27:0] inb = {mcant_l,mcan_l};
wire ri_in = mcanmi ^ negsel;

wire	part1lo, part2lo, part3lo, part4lo, part5lo, part6lo;
wire [27:0] mp_l;

mppartial mppart1	(	.P0(mp_l[0]), .P1(mp_l[1]), .P2(mp_l[2]), .P3(mp_l[3]),
			.LO(part1lo), .RI(ri_in),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[0]), .A1(ina[1]), .A2(ina[2]), .A3(ina[3]),
			.B0(inb[0]), .B1(inb[1]), .B2(inb[2]), .B3(inb[3]));

mppartial mppart2	(	.P0(mp_l[4]), .P1(mp_l[5]), .P2(mp_l[6]), .P3(mp_l[7]),
			.LO(part2lo), .RI(part1lo),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[4]), .A1(ina[5]), .A2(ina[6]), .A3(ina[7]),
			.B0(inb[4]), .B1(inb[5]), .B2(inb[6]), .B3(inb[7]));

mppartial mppart3	(	.P0(mp_l[8]), .P1(mp_l[9]), .P2(mp_l[10]), .P3(mp_l[11]),
			.LO(part3lo), .RI(part2lo),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[8]), .A1(ina[9]), .A2(ina[10]), .A3(ina[11]),
			.B0(inb[8]), .B1(inb[9]), .B2(inb[10]), .B3(inb[11]));

mppartial mppart4	(	.P0(mp_l[12]), .P1(mp_l[13]), .P2(mp_l[14]), .P3(mp_l[15]),
			.LO(part4lo), .RI(part3lo),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[12]), .A1(ina[13]), .A2(ina[14]), .A3(ina[15]),
			.B0(inb[12]), .B1(inb[13]), .B2(inb[14]), .B3(inb[15]));

mppartial mppart5	(	.P0(mp_l[16]), .P1(mp_l[17]), .P2(mp_l[18]), .P3(mp_l[19]),
			.LO(part5lo), .RI(part4lo),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[16]), .A1(ina[17]), .A2(ina[18]), .A3(ina[19]),
			.B0(inb[16]), .B1(inb[17]), .B2(inb[18]), .B3(inb[19]));

mppartial mppart6	(	.P0(mp_l[20]), .P1(mp_l[21]), .P2(mp_l[22]), .P3(mp_l[23]),
			.LO(part6lo), .RI(part5lo),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[20]), .A1(ina[21]), .A2(ina[22]), .A3(ina[23]),
			.B0(inb[20]), .B1(inb[21]), .B2(inb[22]), .B3(inb[23]));

mppartial mppart7	(	.P0(mp_l[24]), .P1(mp_l[25]), .P2(mp_l[26]), .P3(mp_l[27]),
			.LO(), .RI(part6lo),
			.SBN(!negsel), .SB(negsel), .SL0(mselx[0]), .SL1(mselx[1]),
			.A0(ina[24]), .A1(ina[25]), .A2(ina[26]), .A3(ina[27]),
			.B0(inb[24]), .B1(inb[25]), .B2(inb[26]), .B3(inb[27]));

assign mp = ~mp_l;

endmodule


module fpu_booth(mselx,negsel,signbit,bits);

 input   [2:0]  bits;

 output  [1:0]  mselx;
 output         negsel, signbit;

 reg     [1:0]  mselx;

//    (RADIX-4 booth recoding)
// when both bits of mselx are 0, we actually want to select 0 output.
// the fpu_nands used in mpmux performs this function.  thus replacing
// a 3:1 mux function with a 2:1 mux.

 always @(bits) begin
      case(bits)    // synopsys full_case parallel_case
         3'b000,3'b111:             	mselx = 2'b00; 	//     0x
         3'b001,3'b010,3'b101,3'b110:   mselx = 2'b01; 	// +/- 1x
         3'b011,3'b100:    	        mselx = 2'b10; 	// +/- 2x
         default:               	mselx = 2'b00; 	//     0x
      endcase
 end

 assign negsel = bits[2];
 assign signbit = bits[2] & !(&bits[1:0]);	// no more -0x, so we must leave -0x out.

endmodule

/**** not used
module fpu_nand (ina, inb, outz);

input	[27:0] 	ina, inb;
output 	[27:0]	outz;

// use this instantiated module to force synopsys to use nand gates
assign outz = ~(ina & inb);

endmodule
****/


module propagate_end (signbit, sin0, sin1, cin0, row0s_bit3, row0s_bit2, row0c_bit3,
		row3s_bit5, row3s_bit4, row3c_bit5, row5s_bit7, row5s_bit6, row5c_bit7,
		row6s_bit13, row6s_bit11, row6s_bit10, row6c_bit12, row6c_bit11,
		aci, sti, negseli, row3s_bit8, row3c_bit8, row5s_bit9, row5c_bit8, row5s_bit12,
		row5c_bit12, aco, sto);

input [6:0] 	signbit;
input		sin0, sin1, cin0;  			//first triangle
input		row0s_bit3, row0s_bit2, row0c_bit3; 	//second triangle
input 		row3s_bit5, row3s_bit4, row3c_bit5;	//third triangle
input		row5s_bit7, row5s_bit6, row5c_bit7;	//fourth triangle
input		row6s_bit13, row6s_bit11, row6s_bit10, 
		row6c_bit12, row6c_bit11; 		// remaining "triangle" bits
							// will be generated in here.
							// (see prop*_bit* variables)
input 		aci, sti, negseli;
input		row3s_bit8, row3c_bit8, row5s_bit9, 
		row5c_bit8, row5s_bit12, row5c_bit12;	// drafted out of tree so we can 
							//   advanced signbit absorption

output		aco, sto;

wire prop5s_bit8, prop5c_bit9, prop6s_bit12, prop6s_bit9, prop6s_bit8, 
		prop6c_bit13, prop6c_bit10, prop6c_bit9;

multfa  propfa0 (	.ai(row3c_bit8),
			.bi(row3s_bit8),
			.ci(signbit[4]),		//signbit insertion
			.so(prop5s_bit8),
			.co(prop5c_bit9)
		);

multfa  propfa1 (	.ai(prop5s_bit8),
			.bi(row5c_bit8),
			.ci(signbit[4]),		//signbit insertion
			.so(prop6s_bit8),
			.co(prop6c_bit9)
		);

multfa  propfa2 (	.ai(prop5c_bit9),
			.bi(row5s_bit9),
			.ci(signbit[4]),		//signbit insertion
			.so(prop6s_bit9),
			.co(prop6c_bit10)
		);

multfa  propfa3 (	.ai(row5c_bit12),
			.bi(row5s_bit12),
			.ci(signbit[5]),		//signbit insertion
			.so(prop6s_bit12),
			.co(prop6c_bit13)
		);




wire [14:0] propsum;
wire	tri0c, tri1c, tri2c, tri3c;
wire	sto_1_0, sto_3_0, sto_5_0, sto_7_0;


// triangles
// 2 bit propagate adder
//*********************************************************************
 multadd2 triangle0 (	.ai({cin0,negseli}),
			.bi({sin1, sin0}),
			.ci(aci),
			.so(propsum[1:0]),
			.co(tri0c)
			);

 assign sto_1_0 = sti | (|propsum[1:0]);
 
 multadd2 triangle1 (   .ai({row0s_bit3,row0s_bit2}), 
                        .bi({row0c_bit3,signbit[0]}), 
                        .ci(tri0c), 
                        .so(propsum[3:2]),
                        .co(tri1c)
                        );

 assign sto_3_0 = sto_1_0 | (|propsum[3:2]);

 multadd2 triangle2 (   .ai({row3s_bit5,row3s_bit4}), 
                        .bi({row3c_bit5,signbit[1]}), 
                        .ci(tri1c), 
                        .so(propsum[5:4]), 
                        .co(tri2c)
                        ); 

 assign sto_5_0 = sto_3_0 | (|propsum[5:4]);

 multadd2 triangle3 (   .ai({row5s_bit7,row5s_bit6}),
                        .bi({row5c_bit7,signbit[2]}),
                        .ci(tri2c),
                        .so(propsum[7:6]),
                        .co(tri3c)
                        );

 assign sto_7_0 = sto_5_0 | (|propsum[7:6]);

 fa6	last_part  (	.a({row6s_bit13,prop6s_bit12,row6s_bit11,row6s_bit10,prop6s_bit9,prop6s_bit8}),
			.b({prop6c_bit13,row6c_bit12,row6c_bit11,prop6c_bit10,prop6c_bit9,signbit[3]}),
			.c(tri3c),
			.sum(propsum[13:8]),
			.cout(propsum[14])
			);

 multor7  finalor  (	.in({sto_7_0, propsum[13:8]}),
			.out(sto)
			);

 assign aco = propsum[14];

 //mux2_3  remux(.out({aco,s1,s0}),.sel({aci,!aci}),.in0({acop,s1p,s0p}),.in1({acoq,s1q,s0q}));

//*********************************************************************


endmodule




module multadd2 (ai, bi, so, co, ci);

input 	 [1:0]	ai, bi;
input		ci;
output 	 [1:0]	so;
output		co;

assign {co,so} = ai + bi +ci; 

endmodule


module tree34 (ai, bi, ci, so, co);

input [33:0] 	ai, bi, ci;
output [33:0]	co, so;

multfa  tree34fa0 (.ai(ai[0]), .bi(bi[0]), .ci(ci[0]), .co(co[0]), .so(so[0]));
multfa  tree34fa1 (.ai(ai[1]), .bi(bi[1]), .ci(ci[1]), .co(co[1]), .so(so[1]));
multfa  tree34fa2 (.ai(ai[2]), .bi(bi[2]), .ci(ci[2]), .co(co[2]), .so(so[2]));
multfa  tree34fa3 (.ai(ai[3]), .bi(bi[3]), .ci(ci[3]), .co(co[3]), .so(so[3]));
multfa  tree34fa4 (.ai(ai[4]), .bi(bi[4]), .ci(ci[4]), .co(co[4]), .so(so[4]));
multfa  tree34fa5 (.ai(ai[5]), .bi(bi[5]), .ci(ci[5]), .co(co[5]), .so(so[5]));
multfa  tree34fa6 (.ai(ai[6]), .bi(bi[6]), .ci(ci[6]), .co(co[6]), .so(so[6]));
multfa  tree34fa7 (.ai(ai[7]), .bi(bi[7]), .ci(ci[7]), .co(co[7]), .so(so[7]));
multfa  tree34fa8 (.ai(ai[8]), .bi(bi[8]), .ci(ci[8]), .co(co[8]), .so(so[8]));
multfa  tree34fa9 (.ai(ai[9]), .bi(bi[9]), .ci(ci[9]), .co(co[9]), .so(so[9]));
multfa  tree34fa10 (.ai(ai[10]), .bi(bi[10]), .ci(ci[10]), .co(co[10]), .so(so[10]));
multfa  tree34fa11 (.ai(ai[11]), .bi(bi[11]), .ci(ci[11]), .co(co[11]), .so(so[11]));
multfa  tree34fa12 (.ai(ai[12]), .bi(bi[12]), .ci(ci[12]), .co(co[12]), .so(so[12]));
multfa  tree34fa13 (.ai(ai[13]), .bi(bi[13]), .ci(ci[13]), .co(co[13]), .so(so[13]));
multfa  tree34fa14 (.ai(ai[14]), .bi(bi[14]), .ci(ci[14]), .co(co[14]), .so(so[14]));
multfa  tree34fa15 (.ai(ai[15]), .bi(bi[15]), .ci(ci[15]), .co(co[15]), .so(so[15]));
multfa  tree34fa16 (.ai(ai[16]), .bi(bi[16]), .ci(ci[16]), .co(co[16]), .so(so[16]));
multfa  tree34fa17 (.ai(ai[17]), .bi(bi[17]), .ci(ci[17]), .co(co[17]), .so(so[17]));
multfa  tree34fa18 (.ai(ai[18]), .bi(bi[18]), .ci(ci[18]), .co(co[18]), .so(so[18]));
multfa  tree34fa19 (.ai(ai[19]), .bi(bi[19]), .ci(ci[19]), .co(co[19]), .so(so[19]));
multfa  tree34fa20 (.ai(ai[20]), .bi(bi[20]), .ci(ci[20]), .co(co[20]), .so(so[20]));
multfa  tree34fa21 (.ai(ai[21]), .bi(bi[21]), .ci(ci[21]), .co(co[21]), .so(so[21]));
multfa  tree34fa22 (.ai(ai[22]), .bi(bi[22]), .ci(ci[22]), .co(co[22]), .so(so[22]));
multfa  tree34fa23 (.ai(ai[23]), .bi(bi[23]), .ci(ci[23]), .co(co[23]), .so(so[23]));
multfa  tree34fa24 (.ai(ai[24]), .bi(bi[24]), .ci(ci[24]), .co(co[24]), .so(so[24]));
multfa  tree34fa25 (.ai(ai[25]), .bi(bi[25]), .ci(ci[25]), .co(co[25]), .so(so[25]));
multfa  tree34fa26 (.ai(ai[26]), .bi(bi[26]), .ci(ci[26]), .co(co[26]), .so(so[26]));
multfa  tree34fa27 (.ai(ai[27]), .bi(bi[27]), .ci(ci[27]), .co(co[27]), .so(so[27]));
multfa  tree34fa28 (.ai(ai[28]), .bi(bi[28]), .ci(ci[28]), .co(co[28]), .so(so[28]));
multfa  tree34fa29 (.ai(ai[29]), .bi(bi[29]), .ci(ci[29]), .co(co[29]), .so(so[29]));
multfa  tree34fa30 (.ai(ai[30]), .bi(bi[30]), .ci(ci[30]), .co(co[30]), .so(so[30]));
multfa  tree34fa31 (.ai(ai[31]), .bi(bi[31]), .ci(ci[31]), .co(co[31]), .so(so[31]));
multfa  tree34fa32 (.ai(ai[32]), .bi(bi[32]), .ci(ci[32]), .co(co[32]), .so(so[32]));
multfa  tree34fa33 (.ai(ai[33]), .bi(bi[33]), .ci(ci[33]), .co(co[33]), .so(so[33]));

endmodule


module tree29 (ai, bi, ci, so, co);

input [28:0] 	ai, bi, ci;
output [28:0]	co, so;

multfa  tree29fa0 (.ai(ai[0]), .bi(bi[0]), .ci(ci[0]), .co(co[0]), .so(so[0]));
multfa  tree29fa1 (.ai(ai[1]), .bi(bi[1]), .ci(ci[1]), .co(co[1]), .so(so[1]));
multfa  tree29fa2 (.ai(ai[2]), .bi(bi[2]), .ci(ci[2]), .co(co[2]), .so(so[2]));
multfa  tree29fa3 (.ai(ai[3]), .bi(bi[3]), .ci(ci[3]), .co(co[3]), .so(so[3]));
multfa  tree29fa4 (.ai(ai[4]), .bi(bi[4]), .ci(ci[4]), .co(co[4]), .so(so[4]));
multfa  tree29fa5 (.ai(ai[5]), .bi(bi[5]), .ci(ci[5]), .co(co[5]), .so(so[5]));
multfa  tree29fa6 (.ai(ai[6]), .bi(bi[6]), .ci(ci[6]), .co(co[6]), .so(so[6]));
multfa  tree29fa7 (.ai(ai[7]), .bi(bi[7]), .ci(ci[7]), .co(co[7]), .so(so[7]));
multfa  tree29fa8 (.ai(ai[8]), .bi(bi[8]), .ci(ci[8]), .co(co[8]), .so(so[8]));
multfa  tree29fa9 (.ai(ai[9]), .bi(bi[9]), .ci(ci[9]), .co(co[9]), .so(so[9]));
multfa  tree29fa10 (.ai(ai[10]), .bi(bi[10]), .ci(ci[10]), .co(co[10]), .so(so[10]));
multfa  tree29fa11 (.ai(ai[11]), .bi(bi[11]), .ci(ci[11]), .co(co[11]), .so(so[11]));
multfa  tree29fa12 (.ai(ai[12]), .bi(bi[12]), .ci(ci[12]), .co(co[12]), .so(so[12]));
multfa  tree29fa13 (.ai(ai[13]), .bi(bi[13]), .ci(ci[13]), .co(co[13]), .so(so[13]));
multfa  tree29fa14 (.ai(ai[14]), .bi(bi[14]), .ci(ci[14]), .co(co[14]), .so(so[14]));
multfa  tree29fa15 (.ai(ai[15]), .bi(bi[15]), .ci(ci[15]), .co(co[15]), .so(so[15]));
multfa  tree29fa16 (.ai(ai[16]), .bi(bi[16]), .ci(ci[16]), .co(co[16]), .so(so[16]));
multfa  tree29fa17 (.ai(ai[17]), .bi(bi[17]), .ci(ci[17]), .co(co[17]), .so(so[17]));
multfa  tree29fa18 (.ai(ai[18]), .bi(bi[18]), .ci(ci[18]), .co(co[18]), .so(so[18]));
multfa  tree29fa19 (.ai(ai[19]), .bi(bi[19]), .ci(ci[19]), .co(co[19]), .so(so[19]));
multfa  tree29fa20 (.ai(ai[20]), .bi(bi[20]), .ci(ci[20]), .co(co[20]), .so(so[20]));
multfa  tree29fa21 (.ai(ai[21]), .bi(bi[21]), .ci(ci[21]), .co(co[21]), .so(so[21]));
multfa  tree29fa22 (.ai(ai[22]), .bi(bi[22]), .ci(ci[22]), .co(co[22]), .so(so[22]));
multfa  tree29fa23 (.ai(ai[23]), .bi(bi[23]), .ci(ci[23]), .co(co[23]), .so(so[23]));
multfa  tree29fa24 (.ai(ai[24]), .bi(bi[24]), .ci(ci[24]), .co(co[24]), .so(so[24]));
multfa  tree29fa25 (.ai(ai[25]), .bi(bi[25]), .ci(ci[25]), .co(co[25]), .so(so[25]));
multfa  tree29fa26 (.ai(ai[26]), .bi(bi[26]), .ci(ci[26]), .co(co[26]), .so(so[26]));
multfa  tree29fa27 (.ai(ai[27]), .bi(bi[27]), .ci(ci[27]), .co(co[27]), .so(so[27]));
multfa  tree29fa28 (.ai(ai[28]), .bi(bi[28]), .ci(ci[28]), .co(co[28]), .so(so[28]));

endmodule


module tree27 (ai, bi, ci, so, co);

input [26:0] 	ai, bi, ci;
output [26:0]	co, so;

multfa  tree27fa0 (.ai(ai[0]), .bi(bi[0]), .ci(ci[0]), .co(co[0]), .so(so[0]));
multfa  tree27fa1 (.ai(ai[1]), .bi(bi[1]), .ci(ci[1]), .co(co[1]), .so(so[1]));
multfa  tree27fa2 (.ai(ai[2]), .bi(bi[2]), .ci(ci[2]), .co(co[2]), .so(so[2]));
multfa  tree27fa3 (.ai(ai[3]), .bi(bi[3]), .ci(ci[3]), .co(co[3]), .so(so[3]));
multfa  tree27fa4 (.ai(ai[4]), .bi(bi[4]), .ci(ci[4]), .co(co[4]), .so(so[4]));
multfa  tree27fa5 (.ai(ai[5]), .bi(bi[5]), .ci(ci[5]), .co(co[5]), .so(so[5]));
multfa  tree27fa6 (.ai(ai[6]), .bi(bi[6]), .ci(ci[6]), .co(co[6]), .so(so[6]));
multfa  tree27fa7 (.ai(ai[7]), .bi(bi[7]), .ci(ci[7]), .co(co[7]), .so(so[7]));
multfa  tree27fa8 (.ai(ai[8]), .bi(bi[8]), .ci(ci[8]), .co(co[8]), .so(so[8]));
multfa  tree27fa9 (.ai(ai[9]), .bi(bi[9]), .ci(ci[9]), .co(co[9]), .so(so[9]));
multfa  tree27fa10 (.ai(ai[10]), .bi(bi[10]), .ci(ci[10]), .co(co[10]), .so(so[10]));
multfa  tree27fa11 (.ai(ai[11]), .bi(bi[11]), .ci(ci[11]), .co(co[11]), .so(so[11]));
multfa  tree27fa12 (.ai(ai[12]), .bi(bi[12]), .ci(ci[12]), .co(co[12]), .so(so[12]));
multfa  tree27fa13 (.ai(ai[13]), .bi(bi[13]), .ci(ci[13]), .co(co[13]), .so(so[13]));
multfa  tree27fa14 (.ai(ai[14]), .bi(bi[14]), .ci(ci[14]), .co(co[14]), .so(so[14]));
multfa  tree27fa15 (.ai(ai[15]), .bi(bi[15]), .ci(ci[15]), .co(co[15]), .so(so[15]));
multfa  tree27fa16 (.ai(ai[16]), .bi(bi[16]), .ci(ci[16]), .co(co[16]), .so(so[16]));
multfa  tree27fa17 (.ai(ai[17]), .bi(bi[17]), .ci(ci[17]), .co(co[17]), .so(so[17]));
multfa  tree27fa18 (.ai(ai[18]), .bi(bi[18]), .ci(ci[18]), .co(co[18]), .so(so[18]));
multfa  tree27fa19 (.ai(ai[19]), .bi(bi[19]), .ci(ci[19]), .co(co[19]), .so(so[19]));
multfa  tree27fa20 (.ai(ai[20]), .bi(bi[20]), .ci(ci[20]), .co(co[20]), .so(so[20]));
multfa  tree27fa21 (.ai(ai[21]), .bi(bi[21]), .ci(ci[21]), .co(co[21]), .so(so[21]));
multfa  tree27fa22 (.ai(ai[22]), .bi(bi[22]), .ci(ci[22]), .co(co[22]), .so(so[22]));
multfa  tree27fa23 (.ai(ai[23]), .bi(bi[23]), .ci(ci[23]), .co(co[23]), .so(so[23]));
multfa  tree27fa24 (.ai(ai[24]), .bi(bi[24]), .ci(ci[24]), .co(co[24]), .so(so[24]));
multfa  tree27fa25 (.ai(ai[25]), .bi(bi[25]), .ci(ci[25]), .co(co[25]), .so(so[25]));
multfa  tree27fa26 (.ai(ai[26]), .bi(bi[26]), .ci(ci[26]), .co(co[26]), .so(so[26]));

endmodule


module tree23 (ai, bi, ci, so, co);

input [22:0] 	ai, bi, ci;
output [22:0]	co, so;

multfa  tree23fa0 (.ai(ai[0]), .bi(bi[0]), .ci(ci[0]), .co(co[0]), .so(so[0]));
multfa  tree23fa1 (.ai(ai[1]), .bi(bi[1]), .ci(ci[1]), .co(co[1]), .so(so[1]));
multfa  tree23fa2 (.ai(ai[2]), .bi(bi[2]), .ci(ci[2]), .co(co[2]), .so(so[2]));
multfa  tree23fa3 (.ai(ai[3]), .bi(bi[3]), .ci(ci[3]), .co(co[3]), .so(so[3]));
multfa  tree23fa4 (.ai(ai[4]), .bi(bi[4]), .ci(ci[4]), .co(co[4]), .so(so[4]));
multfa  tree23fa5 (.ai(ai[5]), .bi(bi[5]), .ci(ci[5]), .co(co[5]), .so(so[5]));
multfa  tree23fa6 (.ai(ai[6]), .bi(bi[6]), .ci(ci[6]), .co(co[6]), .so(so[6]));
multfa  tree23fa7 (.ai(ai[7]), .bi(bi[7]), .ci(ci[7]), .co(co[7]), .so(so[7]));
multfa  tree23fa8 (.ai(ai[8]), .bi(bi[8]), .ci(ci[8]), .co(co[8]), .so(so[8]));
multfa  tree23fa9 (.ai(ai[9]), .bi(bi[9]), .ci(ci[9]), .co(co[9]), .so(so[9]));
multfa  tree23fa10 (.ai(ai[10]), .bi(bi[10]), .ci(ci[10]), .co(co[10]), .so(so[10]));
multfa  tree23fa11 (.ai(ai[11]), .bi(bi[11]), .ci(ci[11]), .co(co[11]), .so(so[11]));
multfa  tree23fa12 (.ai(ai[12]), .bi(bi[12]), .ci(ci[12]), .co(co[12]), .so(so[12]));
multfa  tree23fa13 (.ai(ai[13]), .bi(bi[13]), .ci(ci[13]), .co(co[13]), .so(so[13]));
multfa  tree23fa14 (.ai(ai[14]), .bi(bi[14]), .ci(ci[14]), .co(co[14]), .so(so[14]));
multfa  tree23fa15 (.ai(ai[15]), .bi(bi[15]), .ci(ci[15]), .co(co[15]), .so(so[15]));
multfa  tree23fa16 (.ai(ai[16]), .bi(bi[16]), .ci(ci[16]), .co(co[16]), .so(so[16]));
multfa  tree23fa17 (.ai(ai[17]), .bi(bi[17]), .ci(ci[17]), .co(co[17]), .so(so[17]));
multfa  tree23fa18 (.ai(ai[18]), .bi(bi[18]), .ci(ci[18]), .co(co[18]), .so(so[18]));
multfa  tree23fa19 (.ai(ai[19]), .bi(bi[19]), .ci(ci[19]), .co(co[19]), .so(so[19]));
multfa  tree23fa20 (.ai(ai[20]), .bi(bi[20]), .ci(ci[20]), .co(co[20]), .so(so[20]));
multfa  tree23fa21 (.ai(ai[21]), .bi(bi[21]), .ci(ci[21]), .co(co[21]), .so(so[21]));
multfa  tree23fa22 (.ai(ai[22]), .bi(bi[22]), .ci(ci[22]), .co(co[22]), .so(so[22]));



endmodule



module addnegi (ai, bi, so, co);
// just half adders for adding negi to high order bit of multiplicands
// break out this addition as a half adder so the addition is faster.
// we then select between this result and those saved from previous cycle
// to be summed into the tree.

input 	 [5:0]	ai, bi;
output 	 [5:0]	co, so;

multha  negiha0 (.ai(ai[0]), .bi(bi[0]), .co(co[0]), .so(so[0]));
multha  negiha1 (.ai(ai[1]), .bi(bi[1]), .co(co[1]), .so(so[1]));
multha  negiha2 (.ai(ai[2]), .bi(bi[2]), .co(co[2]), .so(so[2]));
multha  negiha3 (.ai(ai[3]), .bi(bi[3]), .co(co[3]), .so(so[3]));
multha  negiha4 (.ai(ai[4]), .bi(bi[4]), .co(co[4]), .so(so[4]));
multha  negiha5 (.ai(ai[5]), .bi(bi[5]), .co(co[5]), .so(so[5]));

endmodule


