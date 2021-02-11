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



// ------------------- 19-bit bit_wise comparator -----------------------

module cmp19_e (ai, bi, a_eql_b);  
  
input  [18:0]  ai;
input  [18:0]  bi;
output	       a_eql_b;		// ai equal to bi.
 
/* Logic
assign a_eql_b = ( ai[18:0] == bi[18:0] ) ; 
*/

/*Use this portion for RTL simulation.*/

wire    [18:0]  bit_eql;	// bit-wise equal output
wire    [4:0]  level_1;		// 8-equal_not output
wire    [1:0]  level_2;		// 4-equal
assign bit_eql[18:0] = ai[18:0] ^~ bi[18:0] ;	// 32 2-in exnor, g10p "en".
assign level_1[4] = !(&bit_eql[18:16]);		// 1 3-in "nd3".
assign level_1[3] = !(&bit_eql[15:12]);		// 1 4-in "nd4".
assign level_1[2] = !(&bit_eql[11:8]);		// 1 4-in "nd4".
assign level_1[1] = !(&bit_eql[7:4]);		// 1 4-in "nd4".
assign level_1[0] = !(&bit_eql[3:0]);		// 1 4-in "nd4".
assign level_2[1] = !(|level_1[4:2]);		// 1 2-in "nr3".
assign level_2[0] = !(|level_1[1:0]);		// 1 2-in "nr2".
assign a_eql_b =   (&level_2[1:0]);		// 1 2-in "and4".

endmodule

// ------------------- 1) 20-bit bit_wise comparator -----------------------

module cmp20_e (ai, bi, a_eql_b);  
  
input  [19:0]  ai;
input  [19:0]  bi;
output	       a_eql_b;		// ai equal to bi.
 
/* Logic
assign a_eql_b = ( ai[19:0] == bi[19:0] ) ; 
*/

/*Use this portion for RTL simulation.*/
wire    [19:0]  bit_eql;	// bit-wise equal output
wire    [4:0]  level_1;		// 8-equal_not output
wire    [1:0]  level_2;		// 4-equal
assign bit_eql[19:0] = ai[19:0] ^~ bi[19:0] ;	// 32 2-in exnor, g10p "en".
assign level_1[4] = !(&bit_eql[19:16]);		// 1 4-in "nd4".
assign level_1[3] = !(&bit_eql[15:12]);		// 1 4-in "nd4".
assign level_1[2] = !(&bit_eql[11:8]);		// 1 4-in "nd4".
assign level_1[1] = !(&bit_eql[7:4]);		// 1 4-in "nd4".
assign level_1[0] = !(&bit_eql[3:0]);		// 1 4-in "nd4".
assign level_2[1] = !(|level_1[4:2]);		// 1 2-in "nr3".
assign level_2[0] = !(|level_1[1:0]);		// 1 2-in "nr2".
assign a_eql_b =   (&level_2[1:0]);		// 1 2-in "and4".

endmodule

// -------------------2) 6-bit adder --------------------------

module fa6 (a, b, c, sum, cout);  
  
input  [5:0]  a;
input  [5:0]  b;
output  [5:0]  sum;

input		c;		// carry in
output		cout;		// carry out


// -------------------- carry tree level 1 ----------------------------
// produce the generate for the least significant bit

wire g0_l = !(((a[0] | b[0]) & c) | (a[0] &b[0]));

// produce the propagates and generates for the other bits

wire gen0_l, p0_l, g1_l, p1_l, g2_l, p2_l, g3_l, p3_l, g4_l, p4_l, 
	g5_l, p5_l;

pgnx_fa6 pgnx0 (a[0], b[0], gen0_l, p0_l);	// gen0_l is used only for sum[0] calc.
pgnx_fa6 pgnx1 (a[1], b[1], g1_l, p1_l);
pgnx_fa6 pgnx2 (a[2], b[2], g2_l, p2_l);
pgnx_fa6 pgnx3 (a[3], b[3], g3_l, p3_l);
pgnx_fa6 pgnx4 (a[4], b[4], g4_l, p4_l);
pgnx_fa6 pgnx5 (a[5], b[5], g5_l, p5_l);


// -------------------- carry tree level 2 ----------------------------
// produce group propagates/generates for sets of 2 bits 
// this stage contains the ling modification, which simplifies
//      this stage, but the outputs are Pseudo-generates, which
//      later need to be recovered by anding with p

wire g0to1, g1to2, g2to3, g4to5, p0to1, p1to2, p3to4;

pg2lg_fa6 pg2lg (	.gd_l(g0_l), 
		.gu_l(g1_l), 
		.g(g0to1));	//assign g0to1 =  !(g0_l & g1_l);

pg2l_fa6 p2gl0 (	.gd_l(g1_l), 
		.gu_l(g2_l), 
		.pd_l(p0_l), 
		.pu_l(p1_l),
		.g(g1to2),	//assign g1to2 =  !(g1_l & g2_l);
		.p(p0to1));	//assign p0to1 =  !(p0_l | p1_l);

pg2l_fa6 p2gl1 (	.gd_l(g2_l), 
		.gu_l(g3_l), 
		.pd_l(p1_l), 
		.pu_l(p2_l),
		.g(g2to3),	//assign g2to3 =  !(g2_l & g3_l);
		.p(p1to2));	//assign p1to2 =  !(p1_l | p2_l);

pg2l_fa6 p2gl2 (	.gd_l(g4_l), 
		.gu_l(g5_l), 
		.pd_l(p3_l), 
		.pu_l(p4_l),
		.g(g4to5),	//assign g4to5 =  !(g4_l & g5_l);
		.p(p3to4));	//assign p3to4 =  !(p3_l | p4_l);





// -------------------- carry tree level 3 ----------------------------
// use aoi to make group generates

wire g0to2_l, g0to3_l, g2to5_l, p1to4_l;

aoig_fa6 aoig0 (	.gd(~g0_l), 
		.gu(g1to2), 
		.pu(p0to1), 
		.g_l(g0to2_l));		//assign g0to2_l = !((!g0_l & p0to1) | g1to2);

aoig_fa6 aoig1 (	.gd(g0to1), 
		.gu(g2to3), 
		.pu(p1to2), 
		.g_l(g0to3_l));		//assign g0to3_l = !((g0to1 & p1to2) | g2to3);

baoi_fa6 baoi0 (	.gd(g2to3), 
		.gu(g4to5), 
		.pd(p1to2), 
		.pu(p3to4),
		.g_l(g2to5_l),		//assign g2to5_l = !((g2to3 & p3to4) | g4to5);
		.p_l(p1to4_l));		//assign p1to4_l = !(p1to2 & p3to4);	



// -------------------- carry tree level 4 ----------------------------
// use oai's since the inputs are active-low.
wire g0to5;

oaig_fa6 oaig0 (	.gd_l(~g0to1), 
		.gu_l(g2to5_l), 
		.pu_l(p1to4_l), 
		.g(g0to5));

//assign g0to5 = !((!g0to1 | p1to4_l) & g2to5_l);

// -------------------- sum, and cout ----------------------------

assign cout = g0to5 & !p5_l;  // recover cout by anding p5 with the pseudo-generate

wire [5:0] suma, sumb;            // local sums before carry select mux

sum2_fa6 sum0to1 (.g1(~gen0_l), .g2(~g1_l),
                .p0(1'b1), .p1(~p0_l), .p2(~p1_l),
                .sum1a(suma[0]), .sum2a(suma[1]),
                .sum1b(sumb[0]), .sum2b(sumb[1]));
sum2_fa6 sum2to3 (.g1(~g2_l), .g2(~g3_l),
                .p0(~p1_l), .p1(~p2_l), .p2(~p3_l),
                .sum1a(suma[2]), .sum2a(suma[3]),
                .sum1b(sumb[2]), .sum2b(sumb[3]));
sum2_fa6 sum4to5 (.g1(~g4_l), .g2(~g5_l),
                .p0(~p3_l), .p1(~p4_l), .p2(~p5_l),
                .sum1a(suma[4]), .sum2a(suma[5]),
                .sum1b(sumb[4]), .sum2b(sumb[5]));


/**********  mux to select sum using G*  signals from carry tree *****/

selsum2_fa6 selsum0to1 (  .sum1a(suma[0]), .sum2a(suma[1]),
		      .sum1b(sumb[0]), .sum2b(sumb[1]),
		      .sel(c), 
		      .sum1(sum[0]), .sum2(sum[1]));
selsum2_fa6 selsum2to3 (  .sum1a(suma[2]), .sum2a(suma[3]),
		      .sum1b(sumb[2]), .sum2b(sumb[3]),
		      .sel(g0to1), 
		      .sum1(sum[2]), .sum2(sum[3]));
selsum2_fa6 selsum4to5 (  .sum1a(suma[4]), .sum2a(suma[5]),
		      .sum1b(sumb[4]), .sum2b(sumb[5]),
		      .sel(~g0to3_l), 
		      .sum1(sum[4]), .sum2(sum[5]));
endmodule




// -------------------- selsum2 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selsum2_fa6 (sel, sum1, sum2,
	     sum1a, sum2a,
	     sum1b, sum2b);

input sum1a, sum2a,
	sum1b, sum2b, sel;
output sum1, sum2;
wire sum1, sum2;

assign sum1 = sel ? sum1a : sum1b;
assign sum2 = sel ? sum2a : sum2b;

endmodule


// -------------------- sum  ----------------------------
// we need to recover the real generates
//       after the ling modification used in level 2.
// we also are replacing the a,b with p,g to reduce loading
//       of the a,b inputs.  (a ^ b = p & !g)
// send out two sets of sums to be selected with mux at last stage

module sum2_fa6 (g1, g2, p0, p1, p2, 
	     sum1a, sum2a,
	     sum1b, sum2b);

output sum1a, sum2a,
	sum1b, sum2b;	// sum outputs.
input  g1, g2;  		// individual generate inputs.
input  p0, p1, p2;  		// individual propagate inputs.
//input  G;    		        	// global carry input. (pseudo-generate)
wire	sum1a, sum2a,
	sum1b, sum2b;

assign      sum1a = (p1 & (~g1)) ^ p0;
assign      sum2a = (p2 & (~g2)) ^ (g1 | (p1 & p0));
assign      sum1b = p1 & (~g1);
assign      sum2b = (p2 & (~g2)) ^ g1;



endmodule



// -------------------- pgnx ----------------------------
module pgnx_fa6 (a, b, g_l, p_l); // level 1 propagate and generate signals

input a, b;
output g_l, p_l;

assign g_l = !(a & b);	//nand to make initial generate
assign p_l = !(a | b);	//nor to make initial propagate

endmodule


// -------------------- pg2lg ----------------------------
// ling modification stage, generate only

module pg2lg_fa6 (gd_l, gu_l, g); 

input gd_l, gu_l;
output g;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate

endmodule


// -------------------- pg2l ----------------------------
// ling modification stage, psuedo group generate and propagate

module pg2l_fa6 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pd_l, pu_l;
output g, p;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate
assign p = !(pd_l | pu_l);	//nor to make pseudo generate

endmodule


// -------------------- aoig ----------------------------
// aoi for carry tree generates

module aoig_fa6 (gd, gu, pu, g_l); 

input gd, gu, pu;
output g_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate

endmodule

// -------------------- oaig ----------------------------
// aoi for carry tree generates

module oaig_fa6 (gd_l, gu_l, pu_l, g); 

input gd_l, gu_l, pu_l;
output g;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate

endmodule

// -------------------- baoi ----------------------------
// aoi for carry tree generates + logic for propagate

module baoi_fa6 (gd, gu, pd, pu, g_l, p_l); 

input gd, gu, pd, pu;
output g_l, p_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate
assign p_l = ~(pd & pu); // nand to make group prop

endmodule




// ------------------- 3) 6-bit greater than comparator------------------

module gr6 (a, b, gr);  
  
input  [5:0]  a;
input  [5:0]  b;
output		gr;		// carry out


// -------------------- carry tree level 1 ----------------------------
// produce the generate for the least significant bit (sch: glsbs)

wire g0_l = !((a[0] &b[0]));

// produce the propagates and generates for the other bits

wire gen0_l, p0_l, g1_l, p1_l, g2_l, p2_l, g3_l, p3_l, g4_l, p4_l, 
	g5_l, p5_l;

pgnx_gr6 pgnx0 (a[0], b[0], gen0_l, p0_l);	// gen0_l is used only for sum[0] calc.
pgnx_gr6 pgnx1 (a[1], b[1], g1_l, p1_l);
pgnx_gr6 pgnx2 (a[2], b[2], g2_l, p2_l);
pgnx_gr6 pgnx3 (a[3], b[3], g3_l, p3_l);
pgnx_gr6 pgnx4 (a[4], b[4], g4_l, p4_l);
pgnx_gr6 pgnx5 (a[5], b[5], g5_l, p5_l);


// -------------------- carry tree level 2 ----------------------------
// produce group propagates/generates for sets of 2 bits
// this stage contains the ling modification, which simplifies
//      this stage, but the outputs are Pseudo-generates, which
//      later need to be recovered by anding

wire g0to1, g1to2, g2to3, g4to5, p0to1, p1to2, p3to4;

pg2lg_gr6 pg2lg (	.gd_l(g0_l), 
		.gu_l(g1_l), 
		.g(g0to1));	//assign g0to1 =  !(g0_l & g1_l);

pg2l_gr6 p2gl0 (	.gd_l(g1_l), 
		.gu_l(g2_l), 
		.pd_l(p0_l), 
		.pu_l(p1_l),
		.g(g1to2),	//assign g1to2 =  !(g1_l & g2_l);
		.p(p0to1));	//assign p0to1 =  !(p0_l | p1_l);

pg2l_gr6 p2gl1 (	.gd_l(g2_l), 
		.gu_l(g3_l), 
		.pd_l(p1_l), 
		.pu_l(p2_l),
		.g(g2to3),	//assign g2to3 =  !(g2_l & g3_l);
		.p(p1to2));	//assign p1to2 =  !(p1_l | p2_l);

pg2l_gr6 p2gl2 (	.gd_l(g4_l), 
		.gu_l(g5_l), 
		.pd_l(p3_l), 
		.pu_l(p4_l),
		.g(g4to5),	//assign g4to5 =  !(g4_l & g5_l);
		.p(p3to4));	//assign p3to4 =  !(p3_l | p4_l);



// -------------------- carry tree level 3 ----------------------------
// use aoi to make group generates

wire g0to2_l, g0to3_l, g2to5_l, p1to4_l;

aoig_gr6 aoig0 (	.gd(~g0_l), 
		.gu(g1to2), 
		.pu(p0to1), 
		.g_l(g0to2_l));		//assign g0to2_l = !((!g0_l & p0to1) | g1to2);

aoig_gr6 aoig1 (	.gd(g0to1), 
		.gu(g2to3), 
		.pu(p1to2), 
		.g_l(g0to3_l));		//assign g0to3_l = !((g0to1 & p1to2) | g2to3);

baoi_gr6 baoi0 (	.gd(g2to3), 
		.gu(g4to5), 
		.pd(p1to2), 
		.pu(p3to4),
		.g_l(g2to5_l),		//assign g2to5_l = !((g2to3 & p3to4) | g4to5);
		.p_l(p1to4_l));		//assign p1to4_l = !(p1to2 & p3to4);	



// -------------------- carry tree level 4 ----------------------------
// use oai's since the inputs are active-low.
wire g0to5;

oaig_gr6 oaig0 (	.gd_l(~g0to1), 
		.gu_l(g2to5_l), 
		.pu_l(p1to4_l), 
		.g(g0to5));

//assign g0to5 = !((!g0to1 | p1to4_l) & g2to5_l);

// -------------------- cout ----------------------------

assign gr = g0to5 & !p5_l;  // recover gr by anding p5 with the pseudo-generate

endmodule


// -------------------- pgnx ----------------------------
module pgnx_gr6 (a, b, g_l, p_l); // level 1 propagate and generate signals

input a, b;
output g_l, p_l;

assign g_l = !(a & b);	//nand to make initial generate
assign p_l = !(a | b);	//nor to make initial propagate

endmodule


// -------------------- pg2lg ----------------------------
// ling modification stage, generate only

module pg2lg_gr6 (gd_l, gu_l, g); 

input gd_l, gu_l;
output g;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate

endmodule


// -------------------- pg2l ----------------------------
// ling modification stage, psuedo group generate and propagate

module pg2l_gr6 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pd_l, pu_l;
output g, p;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate
assign p = !(pd_l | pu_l);	//nor to make pseudo generate

endmodule


// -------------------- aoig ----------------------------
// aoi for carry tree generates

module aoig_gr6 (gd, gu, pu, g_l); 

input gd, gu, pu;
output g_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate

endmodule

// -------------------- oaig ----------------------------
// aoi for carry tree generates

module oaig_gr6 (gd_l, gu_l, pu_l, g); 

input gd_l, gu_l, pu_l;
output g;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate

endmodule

// -------------------- baoi ----------------------------
// aoi for carry tree generates + logic for propagate

module baoi_gr6 (gd, gu, pd, pu, g_l, p_l); 

input gd, gu, pd, pu;
output g_l, p_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate
assign p_l = ~(pd & pu); // nand to make group prop

endmodule


// -------------------4)  32-bit all_zero comparator -----------------------

module cmp32zero (ai, a_eql_z);  
  
input  [31:0]  ai;
output	       a_eql_z;		// ai equal to all_zero.
 
/* Logic
assign a_eql_z = ( ai[31:0] == 32'b0 ) ; 
*/

/* Use this portion for RTL simulation.*/
wire    [31:0]  bit_eql;	// bit-wise equal output
wire    [7:0]  level_1;		// 8-equal_not output
wire    [3:0]  level_2;		// 4-equal
assign bit_eql[31:0] = ~ai[31:0] ;		// 32 "n1a".
assign level_1[7] = !(&bit_eql[31:28]);		// 1 4-in "nd4".
assign level_1[6] = !(&bit_eql[27:24]);		// 1 4-in "nd4".
assign level_1[5] = !(&bit_eql[23:20]);		// 1 4-in "nd4".
assign level_1[4] = !(&bit_eql[19:16]);		// 1 4-in "nd4".
assign level_1[3] = !(&bit_eql[15:12]);		// 1 4-in "nd4".
assign level_1[2] = !(&bit_eql[11:8]);		// 1 4-in "nd4".
assign level_1[1] = !(&bit_eql[7:4]);		// 1 4-in "nd4".
assign level_1[0] = !(&bit_eql[3:0]);		// 1 4-in "nd4".
assign level_2[3] = !(|level_1[7:6]);		// 1 2-in "nr2".
assign level_2[2] = !(|level_1[5:4]);		// 1 2-in "nr2".
assign level_2[1] = !(|level_1[3:2]);		// 1 2-in "nr2".
assign level_2[0] = !(|level_1[1:0]);		// 1 2-in "nr2".
assign a_eql_z =   (&level_2[3:0]);		// 1 2-in "and4".

endmodule

// ------------------- 5) 30-bit incrementer --------------
module inc30 (ai, sum);  
  
input  [29:0]  ai;
output [29:0]  sum;
 
assign	sum[29:0]=ai[29:0]+ 1'b1;
endmodule
// ------------------- 5) 32-bit incrementer ---------------
// ------------------- Kogge-Stone style     ---------------
module inc32 (ai, sum);  
  
input  [31:0]  ai;
output [31:0]  sum;
 
wire    g1_0_l;
wire    p26_25_l, p24_23_l, p22_21_l, p20_19_l, p18_17_l, p16_15_l, p14_13_l,
        p12_11_l, p10_9_l, p8_7_l, p6_5_l, p4_3_l, p2_1_l;
wire    g3_0;
wire    p26_23, p22_19, p18_15, p14_11, p10_7, p6_3;
wire 	g7_0_l;
wire    p26_19_l, p22_15_l, p18_11_l, p14_7_l, p10_3_l;
wire    g15_0, g11_0;
wire    p26_11, p22_7, p18_3;
wire    g27_0_l, g23_0_l, g19_0_l;
wire    w2i_g3_0, w3_g7_0, w3_g3_0, w4i_g15_0, w4i_g11_0, w4i_g7_0, w4i_g3_0 ;
wire    [31:0] in, inb;
wire    [31:0] sum;


/* prop0_inc32 stage */

prop0_inc32 p_26_25 ( .p2grp_l(p26_25_l),
                .ain(ai[26:25]));

prop0_inc32 p_24_23 ( .p2grp_l(p24_23_l),
                .ain(ai[24:23]));

prop0_inc32 p_22_21 ( .p2grp_l(p22_21_l),
                .ain(ai[22:21]));

prop0_inc32 p_20_19 ( .p2grp_l(p20_19_l),
                .ain(ai[20:19]));

prop0_inc32 p_18_17 ( .p2grp_l(p18_17_l),
                .ain(ai[18:17]));

prop0_inc32 p_16_15 ( .p2grp_l(p16_15_l),
                .ain(ai[16:15]));

prop0_inc32 p_14_13 ( .p2grp_l(p14_13_l),
                .ain(ai[14:13]));

prop0_inc32 p_12_11 ( .p2grp_l(p12_11_l),
                .ain(ai[12:11]));

prop0_inc32 p_10_9 ( .p2grp_l(p10_9_l),
               .ain(ai[10:9]));

prop0_inc32 p_8_7 ( .p2grp_l(p8_7_l),
              .ain(ai[8:7]));

prop0_inc32 p_6_5 ( .p2grp_l(p6_5_l),
              .ain(ai[6:5]));

prop0_inc32 p_4_3 ( .p2grp_l(p4_3_l),
               .ain(ai[4:3]));

prop0_inc32 p_2_1 ( .p2grp_l(p2_1_l),
              .ain(ai[2:1]));

assign g1_0_l = !ai[0];



/* prop1_inc32 stage */

prop1_inc32 p_26_23 ( .pgrp(p26_23),
                .pu_in(p26_25_l),
                .pd_in(p24_23_l));

prop1_inc32 p_22_19 ( .pgrp(p22_19),
                .pu_in(p22_21_l),
                .pd_in(p20_19_l));

prop1_inc32 p_18_15 ( .pgrp(p18_15),
                .pu_in(p18_17_l),
                .pd_in(p16_15_l));

prop1_inc32 p_14_11 ( .pgrp(p14_11),
                .pu_in(p14_13_l),
                .pd_in(p12_11_l));

prop1_inc32 p_10_7 (  .pgrp(p10_7),
                .pu_in(p10_9_l),
                .pd_in(p8_7_l));

prop1_inc32 p_6_3 (   .pgrp(p6_3),
                .pu_in(p6_5_l),
                .pd_in(p4_3_l));

gen1_inc32 g_3_0 (    .ggrp(g3_0),
                .pu_in(p2_1_l),
                .gd_in(g1_0_l));



/* prop2_inc32 stage */

prop2_inc32 p_26_19 ( .pgrp_l(p26_19_l),
                .pu_in(p26_23),
                .pd_in(p22_19));

prop2_inc32 p_22_15 ( .pgrp_l(p22_15_l),
                .pu_in(p22_19),
                .pd_in(p18_15));

prop2_inc32 p_18_11 ( .pgrp_l(p18_11_l),
                .pu_in(p18_15),
                .pd_in(p14_11));

prop2_inc32 p_14_7 (  .pgrp_l(p14_7_l),
                .pu_in(p14_11),
                .pd_in(p10_7));

prop2_inc32 p_10_3 (  .pgrp_l(p10_3_l),
                .pu_in(p10_7),
                .pd_in(p6_3));

gen2_inc32 g_7_0 (    .ggrp_l(g7_0_l),
                .pu_in(p6_3),
                .gd_in(g3_0));

assign w2i_g3_0 = !g3_0;



/* prop3_inc32 stage */

prop3_inc32 p_26_11 (.pgrp(p26_11),
                .pu_in(p26_19_l),
                .pd_in(p18_11_l));

prop3_inc32 p_22_7 ( .pgrp(p22_7),
                .pu_in(p22_15_l),
                .pd_in(p14_7_l));

prop3_inc32 p_18_3 ( .pgrp(p18_3),
                .pu_in(p18_11_l),
                .pd_in(p10_3_l));

gen3_inc32 g_15_0 (   .ggrp(g15_0),
                .pu_in(p14_7_l),
                .gd_in(g7_0_l));

gen3_inc32 g_11_0 (   .ggrp(g11_0),
                .pu_in(p10_3_l),
                .gd_in(w2i_g3_0));

assign w3_g7_0 = !g7_0_l;

assign w3_g3_0 = !w2i_g3_0;



/* g4 stage */

gen4_inc32 g_27_0 (   .ggrp_l(g27_0_l),
                .pu_in(p26_11),
                .gd_in(g11_0));

gen4_inc32 g_23_0 (   .ggrp_l(g23_0_l),
                .pu_in(p22_7),
                .gd_in(w3_g7_0));

gen4_inc32 g_19_0 (   .ggrp_l(g19_0_l),
                .pu_in(p18_3),
                .gd_in(w3_g3_0));

assign w4i_g15_0 = !g15_0;
assign w4i_g11_0 = !g11_0;
assign w4i_g7_0  = !w3_g7_0;
assign w4i_g3_0  = !w3_g3_0;


/* Local Sum, Carry-select stage */

presum_i32 psum31_28 (.p0(!(!ai[27])), .p1(!(!ai[28])), .p2(!(!ai[29])), .p3(!(!ai[30])), .p4(!(!ai[31])),
                .s1(in[28]), .s2(in[29]), .s3(in[30]), .s4(in[31]),
                .s1b(inb[28]), .s2b(inb[29]), .s3b(inb[30]), .s4b(inb[31]));
                
presum_i32 psum27_24 (.p0(!(!ai[23])), .p1(!(!ai[24])), .p2(!(!ai[25])), .p3(!(!ai[26])), .p4(!(!ai[27])),
                .s1(in[24]), .s2(in[25]), .s3(in[26]), .s4(in[27]),
                .s1b(inb[24]), .s2b(inb[25]), .s3b(inb[26]), .s4b(inb[27]));

presum_i32 psum23_20 (.p0(!(!ai[19])), .p1(!(!ai[20])), .p2(!(!ai[21])), .p3(!(!ai[22])), .p4(!(!ai[23])),
                .s1(in[20]), .s2(in[21]), .s3(in[22]), .s4(in[23]),
                .s1b(inb[20]), .s2b(inb[21]), .s3b(inb[22]), .s4b(inb[23]));

presum_i32 psum19_16 (.p0(!(!ai[15])), .p1(!(!ai[16])), .p2(!(!ai[17])), .p3(!(!ai[18])), .p4(!(!ai[19])),
                .s1(in[16]), .s2(in[17]), .s3(in[18]), .s4(in[19]),
                .s1b(inb[16]), .s2b(inb[17]), .s3b(inb[18]), .s4b(inb[19]));

presum_i32 psum15_12 (.p0(!(!ai[11])), .p1(!(!ai[12])), .p2(!(!ai[13])), .p3(!(!ai[14])), .p4(!(!ai[15])),
                .s1(in[12]), .s2(in[13]), .s3(in[14]), .s4(in[15]),
                .s1b(inb[12]), .s2b(inb[13]), .s3b(inb[14]), .s4b(inb[15]));

presum_i32 psum11_8 (.p0(!(!ai[7])), .p1(!(!ai[8])), .p2(!(!ai[9])), .p3(!(!ai[10])), .p4(!(!ai[11])),
                .s1(in[8]), .s2(in[9]), .s3(in[10]), .s4(in[11]),
                .s1b(inb[8]), .s2b(inb[9]), .s3b(inb[10]), .s4b(inb[11]));

presum_i32 psum7_4 (.p0(!(!ai[3])), .p1(!(!ai[4])), .p2(!(!ai[5])), .p3(!(!ai[6])), .p4(!(!ai[7])),
                .s1(in[4]), .s2(in[5]), .s3(in[6]), .s4(in[7]),
                .s1b(inb[4]), .s2b(inb[5]), .s3b(inb[6]), .s4b(inb[7]));

presum_i32 psum3_0 (.p0(1'b1), .p1(!(!ai[0])), .p2(!(!ai[1])), .p3(!(!ai[2])), .p4(!(!ai[3])),
                .s1(in[0]), .s2(in[1]), .s3(in[2]), .s4(in[3]),
                .s1b(inb[0]), .s2b(inb[1]), .s3b(inb[2]), .s4b(inb[3]));


/* Sum stage */

sum4s_i32 sum31_28 (.csel(!g27_0_l), .sin1(in[28]), .sin2(in[29]), .sin3(in[30]), .sin4(in[31]),
                .sin1b(inb[28]), .sin2b(inb[29]), .sin3b(inb[30]), .sin4b(inb[31]),
                .sum1(sum[28]), .sum2(sum[29]), .sum3(sum[30]), .sum4(sum[31]));

sum4s_i32 sum27_24 (.csel(!g23_0_l), .sin1(in[24]), .sin2(in[25]), .sin3(in[26]), .sin4(in[27]),
                .sin1b(inb[24]), .sin2b(inb[25]), .sin3b(inb[26]), .sin4b(inb[27]),
                .sum1(sum[24]), .sum2(sum[25]), .sum3(sum[26]), .sum4(sum[27]));

sum4s_i32 sum23_20 (.csel(!g19_0_l), .sin1(in[20]), .sin2(in[21]), .sin3(in[22]), .sin4(in[23]),
                .sin1b(inb[20]), .sin2b(inb[21]), .sin3b(inb[22]), .sin4b(inb[23]),
                .sum1(sum[20]), .sum2(sum[21]), .sum3(sum[22]), .sum4(sum[23]));

sum4s_i32 sum19_16 (.csel(!w4i_g15_0), .sin1(in[16]), .sin2(in[17]), .sin3(in[18]), .sin4(in[19]),
                .sin1b(inb[16]), .sin2b(inb[17]), .sin3b(inb[18]), .sin4b(inb[19]),
                .sum1(sum[16]), .sum2(sum[17]), .sum3(sum[18]), .sum4(sum[19]));

sum4s_i32 sum15_12 (.csel(!w4i_g11_0), .sin1(in[12]), .sin2(in[13]), .sin3(in[14]), .sin4(in[15]),
                .sin1b(inb[12]), .sin2b(inb[13]), .sin3b(inb[14]), .sin4b(inb[15]),
                .sum1(sum[12]), .sum2(sum[13]), .sum3(sum[14]), .sum4(sum[15]));

sum4s_i32 sum11_8 (.csel(!w4i_g7_0), .sin1(in[8]), .sin2(in[9]), .sin3(in[10]), .sin4(in[11]),
                .sin1b(inb[8]), .sin2b(inb[9]), .sin3b(inb[10]), .sin4b(inb[11]),
                .sum1(sum[8]), .sum2(sum[9]), .sum3(sum[10]), .sum4(sum[11]));

sum4s_i32 sum7_4 (.csel(!w4i_g3_0), .sin1(in[4]), .sin2(in[5]), .sin3(in[6]), .sin4(in[7]),
                .sin1b(inb[4]), .sin2b(inb[5]), .sin3b(inb[6]), .sin4b(inb[7]),
                .sum1(sum[4]), .sum2(sum[5]), .sum3(sum[6]), .sum4(sum[7]));

sum4s_i32 sum3_0 (.csel(1'b1), .sin1(in[0]), .sin2(in[1]), .sin3(in[2]), .sin4(in[3]),
                .sin1b(inb[0]), .sin2b(inb[1]), .sin3b(inb[2]), .sin4b(inb[3]),
                .sum1(sum[0]), .sum2(sum[1]), .sum3(sum[2]), .sum4(sum[3]));

endmodule


/* prop0_inc32 */
module prop0_inc32 (p2grp_l, ain);

output p2grp_l;
input [1:0] ain;

assign p2grp_l = !(ain[1] & ain[0]);

endmodule


/* prop1_inc32 */
module prop1_inc32 (pgrp, pu_in, pd_in);

output pgrp;
input pu_in, pd_in;

assign pgrp = !(pu_in | pd_in);

endmodule


/* gen1_inc32 */
module gen1_inc32 (ggrp, pu_in, gd_in);

output ggrp;
input pu_in, gd_in;

assign ggrp = !(pu_in | gd_in);

endmodule


/* prop2_inc32 */
module prop2_inc32 (pgrp_l, pu_in, pd_in);

output pgrp_l;
input pu_in, pd_in;

assign pgrp_l = !(pu_in & pd_in);

endmodule


/* gen2_inc32 */
module gen2_inc32 (ggrp_l, pu_in, gd_in);

output ggrp_l;
input pu_in, gd_in;

assign ggrp_l = !(pu_in & gd_in);

endmodule


/* prop3_inc32 */
module prop3_inc32 (pgrp, pu_in, pd_in);

output pgrp;
input pu_in, pd_in;

assign pgrp = !(pu_in | pd_in);

endmodule


/* gen3_inc32 */
module gen3_inc32 (ggrp, pu_in, gd_in);

output ggrp;
input pu_in, gd_in;

assign ggrp = !(pu_in | gd_in);

endmodule


/* gen4_inc32 */
module gen4_inc32 (ggrp_l, pu_in, gd_in);

output ggrp_l;
input pu_in, gd_in;

assign ggrp_l = !(pu_in & gd_in);

endmodule


/* Sum stage logic. Carry-select approach is used */
module sum4s_i32 (csel, sin1, sin2, sin3, sin4, sin1b, sin2b, sin3b, sin4b, sum1, sum2, sum3, sum4);

output sum1, sum2, sum3, sum4;		// sum outputs.
input  sin1, sin2, sin3, sin4;  	// sel inputs assuming csel=1
input  sin1b, sin2b, sin3b, sin4b;	// sel_l inputs assuming csel=0
input  csel;    		        // global carry input.

/* carry-select approach used here */

      assign sum1 = csel == 1 ? sin1 : sin1b;
      assign sum2 = csel == 1 ? sin2 : sin2b;
      assign sum3 = csel == 1 ? sin3 : sin3b;
      assign sum4 = csel == 1 ? sin4 : sin4b;

endmodule


module presum_i32 (p0, p1, p2, p3, p4, s1, s2, s3, s4, s1b, s2b, s3b, s4b);

input p0, p1, p2, p3, p4;
output s1, s2, s3, s4;
output s1b, s2b, s3b, s4b;

      assign s1b = p1;
      assign s2b = p2;
      assign s3b = p3;
      assign s4b = p4;
      assign s1 = p1 ^ p0;
      assign s2 = p2 ^ (p1 & p0);
      assign s3 = p3 ^ ((p1 & p0) & p2);
      assign s4 = p4 ^ (((p1 & p0) & p2) & p3);

endmodule

// -------------------6) 32-bit full adder -----------------------------------
// ------------------- Kogge-Stone style -----------------------------------

module fa32 (ai, bi, cin, sum, cout);  
  
input  [31:0]  ai, bi;
input          cin;
output [31:0]  sum;
output	       cout;
 
wire    [31:0]  gi_l;	// bit-wise generate carry output
wire    [31:0]  pi_l;	// bit-wise propgate carry output
wire    gen1_l;
wire    g31_30, g2_fa329_28, g2_fa327_26, g2_fa325_24, g2_fa323_22, g2_fa321_20, g19_18, g17_16, g15_14,
        g13_12, g11_10, g9_8, g7_6, g5_4, g3_2, g1_0;
wire    p30_29, p28_27, p26_25, p24_23, p22_21, p20_19, p18_17, p16_15, p14_13,
        p12_11, p10_9, p8_7, p6_5, p4_3, p2_1;
wire    g31_28_l, g2_fa327_24_l, g2_fa323_20_l, g19_16_l, g15_12_l, g11_8_l, g7_4_l, g3_0_l;
wire    p30_27_l, p26_23_l, p22_19_l, p18_15_l, p14_11_l, p10_7_l, p6_3_l;
wire 	g31_24, g2_fa327_20, g2_fa323_16, g19_12, g15_8, g11_4, g7_0;
wire    p30_23, p26_19, p22_15, p18_11, p14_7, p10_3;
wire    g31_16_l, g2_fa327_12_l, g2_fa323_8_l, g19_4_l, g15_0_l, g11_0_l;
wire    p30_15_l, p26_11_l, p22_7_l, p18_3_l;
wire    g31_0, g2_fa327_0, g2_fa323_0, g19_0;
wire    w2_3_0, w3i_7_0, w3i_3_0, w4_15_0, w4_11_0, w4_7_0, w4_3_0;
wire    [31:0] in, inb;
wire    [31:0] sum;

assign gen1_l     = ~ (ai[0] & bi[0]);

/* pgnx_fa32 stage */
pgnx_fa32 pg_31 ( .gen_l(gi_l[31]), .pro_l(pi_l[31]), .ain(ai[31]), .bin(bi[31]));
pgnx_fa32 pg_30 ( .gen_l(gi_l[30]), .pro_l(pi_l[30]), .ain(ai[30]), .bin(bi[30]));
pgnx_fa32 pg_29 ( .gen_l(gi_l[29]), .pro_l(pi_l[29]), .ain(ai[29]), .bin(bi[29]));
pgnx_fa32 pg_28 ( .gen_l(gi_l[28]), .pro_l(pi_l[28]), .ain(ai[28]), .bin(bi[28]));
pgnx_fa32 pg_27 ( .gen_l(gi_l[27]), .pro_l(pi_l[27]), .ain(ai[27]), .bin(bi[27]));
pgnx_fa32 pg_26 ( .gen_l(gi_l[26]), .pro_l(pi_l[26]), .ain(ai[26]), .bin(bi[26]));
pgnx_fa32 pg_25 ( .gen_l(gi_l[25]), .pro_l(pi_l[25]), .ain(ai[25]), .bin(bi[25]));
pgnx_fa32 pg_24 ( .gen_l(gi_l[24]), .pro_l(pi_l[24]), .ain(ai[24]), .bin(bi[24]));
pgnx_fa32 pg_23 ( .gen_l(gi_l[23]), .pro_l(pi_l[23]), .ain(ai[23]), .bin(bi[23]));
pgnx_fa32 pg_22 ( .gen_l(gi_l[22]), .pro_l(pi_l[22]), .ain(ai[22]), .bin(bi[22]));
pgnx_fa32 pg_21 ( .gen_l(gi_l[21]), .pro_l(pi_l[21]), .ain(ai[21]), .bin(bi[21]));
pgnx_fa32 pg_20 ( .gen_l(gi_l[20]), .pro_l(pi_l[20]), .ain(ai[20]), .bin(bi[20]));
pgnx_fa32 pg_19 ( .gen_l(gi_l[19]), .pro_l(pi_l[19]), .ain(ai[19]), .bin(bi[19]));
pgnx_fa32 pg_18 ( .gen_l(gi_l[18]), .pro_l(pi_l[18]), .ain(ai[18]), .bin(bi[18]));
pgnx_fa32 pg_17 ( .gen_l(gi_l[17]), .pro_l(pi_l[17]), .ain(ai[17]), .bin(bi[17]));
pgnx_fa32 pg_16 ( .gen_l(gi_l[16]), .pro_l(pi_l[16]), .ain(ai[16]), .bin(bi[16]));
pgnx_fa32 pg_15 ( .gen_l(gi_l[15]), .pro_l(pi_l[15]), .ain(ai[15]), .bin(bi[15]));
pgnx_fa32 pg_14 ( .gen_l(gi_l[14]), .pro_l(pi_l[14]), .ain(ai[14]), .bin(bi[14]));
pgnx_fa32 pg_13 ( .gen_l(gi_l[13]), .pro_l(pi_l[13]), .ain(ai[13]), .bin(bi[13]));
pgnx_fa32 pg_12 ( .gen_l(gi_l[12]), .pro_l(pi_l[12]), .ain(ai[12]), .bin(bi[12]));
pgnx_fa32 pg_11 ( .gen_l(gi_l[11]), .pro_l(pi_l[11]), .ain(ai[11]), .bin(bi[11]));
pgnx_fa32 pg_10 ( .gen_l(gi_l[10]), .pro_l(pi_l[10]), .ain(ai[10]), .bin(bi[10]));
pgnx_fa32 pg_9  ( .gen_l(gi_l[9]), .pro_l(pi_l[9]), .ain(ai[9]), .bin(bi[9]));
pgnx_fa32 pg_8  ( .gen_l(gi_l[8]), .pro_l(pi_l[8]), .ain(ai[8]), .bin(bi[8]));
pgnx_fa32 pg_7  ( .gen_l(gi_l[7]), .pro_l(pi_l[7]), .ain(ai[7]), .bin(bi[7]));
pgnx_fa32 pg_6  ( .gen_l(gi_l[6]), .pro_l(pi_l[6]), .ain(ai[6]), .bin(bi[6]));
pgnx_fa32 pg_5  ( .gen_l(gi_l[5]), .pro_l(pi_l[5]), .ain(ai[5]), .bin(bi[5]));
pgnx_fa32 pg_4  ( .gen_l(gi_l[4]), .pro_l(pi_l[4]), .ain(ai[4]), .bin(bi[4]));
pgnx_fa32 pg_3  ( .gen_l(gi_l[3]), .pro_l(pi_l[3]), .ain(ai[3]), .bin(bi[3]));
pgnx_fa32 pg_2  ( .gen_l(gi_l[2]), .pro_l(pi_l[2]), .ain(ai[2]), .bin(bi[2]));
pgnx_fa32 pg_1  ( .gen_l(gi_l[1]), .pro_l(pi_l[1]), .ain(ai[1]), .bin(bi[1]));
pgnl_fa32 pg_0  ( .gen_l(gi_l[0]), .pro_l(pi_l[0]), .ain(ai[0]), .bin(bi[0]), .carryin(cin));

/* pg2_fa32 stage */

pg2_fa32 pg_31_30 ( .g_u_d(g31_30),
               .p_u_d(p30_29),
               .g_l_in(gi_l[31:30]),
               .p_l_in(pi_l[30:29]));

pg2_fa32 pg_29_28 ( .g_u_d(g2_fa329_28),
               .p_u_d(p28_27),
               .g_l_in(gi_l[29:28]),
               .p_l_in(pi_l[28:27]));

pg2_fa32 pg_27_26 ( .g_u_d(g2_fa327_26),
               .p_u_d(p26_25),
               .g_l_in(gi_l[27:26]),
               .p_l_in(pi_l[26:25]));

pg2_fa32 pg_25_24 ( .g_u_d(g2_fa325_24),
               .p_u_d(p24_23),
               .g_l_in(gi_l[25:24]),
               .p_l_in(pi_l[24:23]));

pg2_fa32 pg_23_22 ( .g_u_d(g2_fa323_22),
               .p_u_d(p22_21),
               .g_l_in(gi_l[23:22]),
               .p_l_in(pi_l[22:21]));

pg2_fa32 pg_21_20 ( .g_u_d(g2_fa321_20),
               .p_u_d(p20_19),
               .g_l_in(gi_l[21:20]),
               .p_l_in(pi_l[20:19]));

pg2_fa32 pg_19_18 ( .g_u_d(g19_18),
               .p_u_d(p18_17),
               .g_l_in(gi_l[19:18]),
               .p_l_in(pi_l[18:17]));

pg2_fa32 pg_17_16 ( .g_u_d(g17_16),
               .p_u_d(p16_15),
               .g_l_in(gi_l[17:16]),
               .p_l_in(pi_l[16:15]));

pg2_fa32 pg_15_14 ( .g_u_d(g15_14),
               .p_u_d(p14_13),
               .g_l_in(gi_l[15:14]),
               .p_l_in(pi_l[14:13]));

pg2_fa32 pg_13_12 ( .g_u_d(g13_12),
               .p_u_d(p12_11),
               .g_l_in(gi_l[13:12]),
               .p_l_in(pi_l[12:11]));

pg2_fa32 pg_11_10 ( .g_u_d(g11_10),
               .p_u_d(p10_9),
               .g_l_in(gi_l[11:10]),
               .p_l_in(pi_l[10:9]));

pg2_fa32 pg_9_8 (   .g_u_d(g9_8),
               .p_u_d(p8_7),
               .g_l_in(gi_l[9:8]),
               .p_l_in(pi_l[8:7]));

pg2_fa32 pg_7_6 (   .g_u_d(g7_6),
               .p_u_d(p6_5),
               .g_l_in(gi_l[7:6]),
               .p_l_in(pi_l[6:5]));

pg2_fa32 pg_5_4 (   .g_u_d(g5_4),
               .p_u_d(p4_3),
               .g_l_in(gi_l[5:4]),
               .p_l_in(pi_l[4:3]));

pg2_fa32 pg_3_2 (   .g_u_d(g3_2),
               .p_u_d(p2_1),
               .g_l_in(gi_l[3:2]),
               .p_l_in(pi_l[2:1]));

g2_fa32 g_1_0 (     .g_u_d(g1_0),
               .g_l_in(gi_l[1:0]));



/* b1 stage */

b1aoi_fa32 pg_31_28 ( .ggrp_l(g31_28_l),
                .pgrp_l(p30_27_l),
                .gu_in(g31_30),
                .pu_in(p30_29),
                .gd_in(g2_fa329_28),
                .pd_in(p28_27));


b1aoi_fa32 pg_27_24 ( .ggrp_l(g2_fa327_24_l),
                .pgrp_l(p26_23_l),
                .gu_in(g2_fa327_26),
                .pu_in(p26_25),
                .gd_in(g2_fa325_24),
                .pd_in(p24_23));


b1aoi_fa32 pg_23_20 ( .ggrp_l(g2_fa323_20_l),
                .pgrp_l(p22_19_l),
                .gu_in(g2_fa323_22),
                .pu_in(p22_21),
                .gd_in(g2_fa321_20),
                .pd_in(p20_19));


b1aoi_fa32 pg_19_16 ( .ggrp_l(g19_16_l),
                .pgrp_l(p18_15_l),
                .gu_in(g19_18),
                .pu_in(p18_17),
                .gd_in(g17_16),
                .pd_in(p16_15));

b1aoi_fa32 pg_15_12 ( .ggrp_l(g15_12_l),
                .pgrp_l(p14_11_l),
                .gu_in(g15_14),
                .pu_in(p14_13),
                .gd_in(g13_12),
                .pd_in(p12_11));

b1aoi_fa32 pg_11_8 (  .ggrp_l(g11_8_l),
                .pgrp_l(p10_7_l),
                .gu_in(g11_10),
                .pu_in(p10_9),
                .gd_in(g9_8),
                .pd_in(p8_7));

b1aoi_fa32 pg_7_4 (   .ggrp_l(g7_4_l),
                .pgrp_l(p6_3_l),
                .gu_in(g7_6),
                .pu_in(p6_5),
                .gd_in(g5_4),
                .pd_in(p4_3));

g1aoi_fa32 g_3_0 (   .ggrp_l(g3_0_l),
                .gu_in(g3_2),
                .pu_in(p2_1),
                .gd_in(g1_0));




/* b2 stage */

b2oai_fa32 pg_31_24 ( .ggrp(g31_24),
                .pgrp(p30_23),
                .gu_in(g31_28_l),
                .pu_in(p30_27_l),
                .gd_in(g2_fa327_24_l),
                .pd_in(p26_23_l));

b2oai_fa32 pg_27_20 ( .ggrp(g2_fa327_20),
                .pgrp(p26_19),
                .gu_in(g2_fa327_24_l),
                .pu_in(p26_23_l),
                .gd_in(g2_fa323_20_l),
                .pd_in(p22_19_l));

b2oai_fa32 pg_23_16 ( .ggrp(g2_fa323_16),
                .pgrp(p22_15),
                .gu_in(g2_fa323_20_l),
                .pu_in(p22_19_l),
                .gd_in(g19_16_l),
                .pd_in(p18_15_l));

b2oai_fa32 pg_19_12 ( .ggrp(g19_12),
                .pgrp(p18_11),
                .gu_in(g19_16_l),
                .pu_in(p18_15_l),
                .gd_in(g15_12_l),
                .pd_in(p14_11_l));

b2oai_fa32 pg_15_8 (  .ggrp(g15_8),
                .pgrp(p14_7),
                .gu_in(g15_12_l),
                .pu_in(p14_11_l),
                .gd_in(g11_8_l),
                .pd_in(p10_7_l));


b2oai_fa32 pg_11_4 (  .ggrp(g11_4),
                .pgrp(p10_3),
                .gu_in(g11_8_l),
                .pu_in(p10_7_l),
                .gd_in(g7_4_l),
                .pd_in(p6_3_l));

g2oai_fa32 g_7_0 (   .ggrp(g7_0),
                .gu_in(g7_4_l),
                .pu_in(p6_3_l),
                .gd_in(g3_0_l));

assign w2_3_0 = ~ g3_0_l;



/* b3 stage */

b3aoi_fa32 pg_31_16 ( .ggrp_l(g31_16_l),
                .pgrp_l(p30_15_l),
                .gu_in(g31_24),
                .pu_in(p30_23),
                .gd_in(g2_fa323_16),
                .pd_in(p22_15));

b3aoi_fa32 pg_27_12 ( .ggrp_l(g2_fa327_12_l),
                .pgrp_l(p26_11_l),
                .gu_in(g2_fa327_20),
                .pu_in(p26_19),
                .gd_in(g19_12),
                .pd_in(p18_11));

b3aoi_fa32 pg_23_8 (  .ggrp_l(g2_fa323_8_l),
                .pgrp_l(p22_7_l),
                .gu_in(g2_fa323_16),
                .pu_in(p22_15),
                .gd_in(g15_8),
                .pd_in(p14_7));

b3aoi_fa32 pg_19_4 (  .ggrp_l(g19_4_l),
                .pgrp_l(p18_3_l),
                .gu_in(g19_12),
                .pu_in(p18_11),
                .gd_in(g11_4),
                .pd_in(p10_3));

g3aoi_fa32 g_15_0 (   .ggrp_l(g15_0_l),
                .gu_in(g15_8),
                .pu_in(p14_7),
                .gd_in(g7_0));


g3aoi_fa32 g_11_0 (   .ggrp_l(g11_0_l),
                .gu_in(g11_4),
                .pu_in(p10_3),
                .gd_in(w2_3_0));

assign w3i_7_0 = ~ g7_0;

assign w3i_3_0 = ~ w2_3_0;



/* g4 stage */

g4oai_fa32 g_31_0 (   .ggrp(g31_0),
                .gu_in(g31_16_l),
                .pu_in(p30_15_l),
                .gd_in(g15_0_l));

g4oai_fa32 g_27_0 (   .ggrp(g2_fa327_0),
                .gu_in(g2_fa327_12_l),
                .pu_in(p26_11_l),
                .gd_in(g11_0_l));

g4oai_fa32 g_23_0 (   .ggrp(g2_fa323_0),
                .gu_in(g2_fa323_8_l),
                .pu_in(p22_7_l),
                .gd_in(w3i_7_0));

g4oai_fa32 g_19_0 (   .ggrp(g19_0),
                .gu_in(g19_4_l),
                .pu_in(p18_3_l),
                .gd_in(w3i_3_0));

assign w4_15_0 = ~ g15_0_l;
assign w4_11_0 = ~ g11_0_l;
assign w4_7_0  = ~ w3i_7_0;
assign w4_3_0  = ~ w3i_3_0;


/* Local Sum, Carry-select stage */

presum_fa32 psum31_28 (.g1(~gi_l[28]), .g2_fa32(~gi_l[29]), .g3(~gi_l[30]), .g4(~gi_l[31]),
                .p0(~pi_l[27]), .p1(~pi_l[28]), .p2(~pi_l[29]), .p3(~pi_l[30]), .p4(~pi_l[31]),
                .s1(in[28]), .s2(in[29]), .s3(in[30]), .s4(in[31]),
                .s1b(inb[28]), .s2b(inb[29]), .s3b(inb[30]), .s4b(inb[31]));
                
presum_fa32 psum27_24 (.g1(~gi_l[24]), .g2_fa32(~gi_l[25]), .g3(~gi_l[26]), .g4(~gi_l[27]),
                .p0(~pi_l[23]), .p1(~pi_l[24]), .p2(~pi_l[25]), .p3(~pi_l[26]), .p4(~pi_l[27]),
                .s1(in[24]), .s2(in[25]), .s3(in[26]), .s4(in[27]),
                .s1b(inb[24]), .s2b(inb[25]), .s3b(inb[26]), .s4b(inb[27]));

presum_fa32 psum23_20 (.g1(~gi_l[20]), .g2_fa32(~gi_l[21]), .g3(~gi_l[22]), .g4(~gi_l[23]),
                .p0(~pi_l[19]), .p1(~pi_l[20]), .p2(~pi_l[21]), .p3(~pi_l[22]), .p4(~pi_l[23]),
                .s1(in[20]), .s2(in[21]), .s3(in[22]), .s4(in[23]),
                .s1b(inb[20]), .s2b(inb[21]), .s3b(inb[22]), .s4b(inb[23]));

presum_fa32 psum19_16 (.g1(~gi_l[16]), .g2_fa32(~gi_l[17]), .g3(~gi_l[18]), .g4(~gi_l[19]),
                .p0(~pi_l[15]), .p1(~pi_l[16]), .p2(~pi_l[17]), .p3(~pi_l[18]), .p4(~pi_l[19]),
                .s1(in[16]), .s2(in[17]), .s3(in[18]), .s4(in[19]),
                .s1b(inb[16]), .s2b(inb[17]), .s3b(inb[18]), .s4b(inb[19]));

presum_fa32 psum15_12 (.g1(~gi_l[12]), .g2_fa32(~gi_l[13]), .g3(~gi_l[14]), .g4(~gi_l[15]),
                .p0(~pi_l[11]), .p1(~pi_l[12]), .p2(~pi_l[13]), .p3(~pi_l[14]), .p4(~pi_l[15]),
                .s1(in[12]), .s2(in[13]), .s3(in[14]), .s4(in[15]),
                .s1b(inb[12]), .s2b(inb[13]), .s3b(inb[14]), .s4b(inb[15]));

presum_fa32 psum11_8 (.g1(~gi_l[8]), .g2_fa32(~gi_l[9]), .g3(~gi_l[10]), .g4(~gi_l[11]),
                .p0(~pi_l[7]), .p1(~pi_l[8]), .p2(~pi_l[9]), .p3(~pi_l[10]), .p4(~pi_l[11]),
                .s1(in[8]), .s2(in[9]), .s3(in[10]), .s4(in[11]),
                .s1b(inb[8]), .s2b(inb[9]), .s3b(inb[10]), .s4b(inb[11]));

presum_fa32 psum7_4 (.g1(~gi_l[4]), .g2_fa32(~gi_l[5]), .g3(~gi_l[6]), .g4(~gi_l[7]),
                .p0(~pi_l[3]), .p1(~pi_l[4]), .p2(~pi_l[5]), .p3(~pi_l[6]), .p4(~pi_l[7]),
                .s1(in[4]), .s2(in[5]), .s3(in[6]), .s4(in[7]),
                .s1b(inb[4]), .s2b(inb[5]), .s3b(inb[6]), .s4b(inb[7]));

presum_fa32 psum3_0 (.g1(~gen1_l), .g2_fa32(~gi_l[1]), .g3(~gi_l[2]), .g4(~gi_l[3]),
                .p0(1'b1), .p1(~pi_l[0]), .p2(~pi_l[1]), .p3(~pi_l[2]), .p4(~pi_l[3]),
                .s1(in[0]), .s2(in[1]), .s3(in[2]), .s4(in[3]),
                .s1b(inb[0]), .s2b(inb[1]), .s3b(inb[2]), .s4b(inb[3]));


/* Sum stage */

sum4s_fa32 sum31_28 (.csel(g2_fa327_0), .sin1(in[28]), .sin2(in[29]), .sin3(in[30]), .sin4(in[31]),
                .sin1b(inb[28]), .sin2b(inb[29]), .sin3b(inb[30]), .sin4b(inb[31]),
                .sum1(sum[28]), .sum2(sum[29]), .sum3(sum[30]), .sum4(sum[31]));

sum4s_fa32 sum27_24 (.csel(g2_fa323_0), .sin1(in[24]), .sin2(in[25]), .sin3(in[26]), .sin4(in[27]),
                .sin1b(inb[24]), .sin2b(inb[25]), .sin3b(inb[26]), .sin4b(inb[27]),
                .sum1(sum[24]), .sum2(sum[25]), .sum3(sum[26]), .sum4(sum[27]));

sum4s_fa32 sum23_20 (.csel(g19_0), .sin1(in[20]), .sin2(in[21]), .sin3(in[22]), .sin4(in[23]),
                .sin1b(inb[20]), .sin2b(inb[21]), .sin3b(inb[22]), .sin4b(inb[23]),
                .sum1(sum[20]), .sum2(sum[21]), .sum3(sum[22]), .sum4(sum[23]));

sum4s_fa32 sum19_16 (.csel(w4_15_0), .sin1(in[16]), .sin2(in[17]), .sin3(in[18]), .sin4(in[19]),
                .sin1b(inb[16]), .sin2b(inb[17]), .sin3b(inb[18]), .sin4b(inb[19]),
                .sum1(sum[16]), .sum2(sum[17]), .sum3(sum[18]), .sum4(sum[19]));

sum4s_fa32 sum15_12 (.csel(w4_11_0), .sin1(in[12]), .sin2(in[13]), .sin3(in[14]), .sin4(in[15]),
                .sin1b(inb[12]), .sin2b(inb[13]), .sin3b(inb[14]), .sin4b(inb[15]),
                .sum1(sum[12]), .sum2(sum[13]), .sum3(sum[14]), .sum4(sum[15]));

sum4s_fa32 sum11_8 (.csel(w4_7_0), .sin1(in[8]), .sin2(in[9]), .sin3(in[10]), .sin4(in[11]),
                .sin1b(inb[8]), .sin2b(inb[9]), .sin3b(inb[10]), .sin4b(inb[11]),
                .sum1(sum[8]), .sum2(sum[9]), .sum3(sum[10]), .sum4(sum[11]));

sum4s_fa32 sum7_4 (.csel(w4_3_0), .sin1(in[4]), .sin2(in[5]), .sin3(in[6]), .sin4(in[7]),
                .sin1b(inb[4]), .sin2b(inb[5]), .sin3b(inb[6]), .sin4b(inb[7]),
                .sum1(sum[4]), .sum2(sum[5]), .sum3(sum[6]), .sum4(sum[7]));

sum4s_fa32 sum3_0 (.csel(cin), .sin1(in[0]), .sin2(in[1]), .sin3(in[2]), .sin4(in[3]),
                .sin1b(inb[0]), .sin2b(inb[1]), .sin3b(inb[2]), .sin4b(inb[3]),
                .sum1(sum[0]), .sum2(sum[1]), .sum3(sum[2]), .sum4(sum[3]));

assign cout = (~pi_l[31]) & g31_0;

endmodule


/* pgnx_fa32 */
module pgnx_fa32 (gen_l, pro_l, ain, bin);

output gen_l;
output pro_l;
input ain;
input bin;

assign gen_l = ~ (ain & bin);
assign pro_l = ~ (ain | bin);

endmodule


/* pgnl_fa32 */
module pgnl_fa32 (gen_l, pro_l, ain, bin, carryin);

output gen_l;
output pro_l;
input ain;
input bin;
input carryin;

assign gen_l = ~ ((ain & bin) | (carryin & (ain | bin)));
assign pro_l = ~ (ain | bin);

endmodule


/* pg2_fa32 stage */
module pg2_fa32 (g_u_d, p_u_d, g_l_in, p_l_in);

output g_u_d;			// carry_generated.
output p_u_d;			// carry_propgated. lower 1-bit
input  [1:0]  g_l_in;		// generate inputs.
input  [1:0]  p_l_in;		// propgate inputs. lower 1-bit

/* Ling modification used here */
assign g_u_d = 	~ (g_l_in[1] & g_l_in[0]); 	// 2-bit pseudo generate.

assign p_u_d =  ~ (p_l_in[1] | p_l_in[0]);         // 2-bit pseudo propagate.

endmodule


/* g2_fa32 stage */
module g2_fa32 (g_u_d, g_l_in);

output g_u_d;			// carry_generated.
input  [1:0]  g_l_in;		// generate inputs.

/* Ling modification used here */
assign g_u_d = 	~ (g_l_in[1] & g_l_in[0]); 	// 2-bit pseudo generate.

endmodule


/* B1AOI stage */
module b1aoi_fa32 (ggrp_l, pgrp_l, gu_in, pu_in, gd_in, pd_in);

output ggrp_l;		// group generate.
output pgrp_l;		// group propgate. lower 1-bit
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.
input  pd_in;  		// lower propgate input. lower 1-bit

/* conventional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

assign pgrp_l =  ~ (pu_in & pd_in);              // group propagate. lower 1-bit

endmodule


/* G1AOI stage */
module g1aoi_fa32 (ggrp_l, gu_in, pu_in, gd_in);

output ggrp_l;		// group generate.
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

endmodule


/* B3AOI stage */
module b3aoi_fa32 (ggrp_l, pgrp_l, gu_in, pu_in, gd_in, pd_in);

output ggrp_l;		// group generate.
output pgrp_l;		// group propgate. lower 1-bit
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.
input  pd_in;  		// lower propgate input. lower 1-bit

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

assign pgrp_l =  ~ (pu_in & pd_in);              // group propagate. lower 1-bit

endmodule


/* G3AOI stage */
module g3aoi_fa32 (ggrp_l, gu_in, pu_in, gd_in);

output ggrp_l;		// group generate.
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

endmodule



/* B2OAI stage */
module b2oai_fa32 (ggrp, pgrp, gu_in, pu_in, gd_in, pd_in);

output ggrp;		// group generate.
output pgrp;		// group propgate. lower 1-bit
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.
input  pd_in;  		// lower propgate input. lower 1-bit

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & (pu_in | gd_in));     // group generate.

assign pgrp =  ~ (pu_in | pd_in);               // group propagate. lower 1-bit

endmodule


/* G2OAI stage */
module g2oai_fa32 (ggrp, gu_in, pu_in, gd_in);

output ggrp;		// group generate.
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & (pu_in | gd_in));     // group generate.

endmodule


/* G4OAI stage */
module g4oai_fa32 (ggrp, gu_in, pu_in, gd_in);

output ggrp;		// group generate.
input  gu_in;  		// upper generate input.
input  pu_in;  		// upper propgate input. lower 1-bit
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & (pu_in | gd_in));     // group generate.

endmodule


/* Sum stage logic. Carry-select approach is used */
module sum4s_fa32 (csel, sin1, sin2, sin3, sin4, sin1b, sin2b, sin3b, sin4b, sum1, sum2, sum3, sum4);

output sum1, sum2, sum3, sum4;		// sum outputs.
input  sin1, sin2, sin3, sin4;  	// sel inputs assuming csel=1
input  sin1b, sin2b, sin3b, sin4b;	// sel_l inputs assuming csel=0
input  csel;    		        // global carry input.

/* carry-select approach used here */

      assign sum1 = csel == 1 ? sin1 : sin1b;
      assign sum2 = csel == 1 ? sin2 : sin2b;
      assign sum3 = csel == 1 ? sin3 : sin3b;
      assign sum4 = csel == 1 ? sin4 : sin4b;

endmodule


module presum_fa32 (g1, g2_fa32, g3, g4, p0, p1, p2, p3, p4, s1, s2, s3, s4, s1b, s2b, s3b, s4b);

input g1, g2_fa32, g3, g4, p0, p1, p2, p3, p4;
output s1, s2, s3, s4;
output s1b, s2b, s3b, s4b;

      assign s1 = (p1 & (~g1)) ^ p0;
      assign s2 = (p2 & (~g2_fa32)) ^ (g1 | (p1 & p0));
      assign s3 = (p3 & (~g3)) ^ (g2_fa32 | ((g1 | (p1 & p0)) & p2));
      assign s4 = (p4 & (~g4)) ^ (g3 | ((g2_fa32 | ((g1 | (p1 & p0)) & p2)) & p3));
      assign s1b = p1 & (~g1);
      assign s2b = (p2 & (~g2_fa32)) ^ g1;
      assign s3b = (p3 & (~g3)) ^ (g2_fa32 | (g1 & p2));
      assign s4b = (p4 & (~g4)) ^ (g3 | (g2_fa32 | (g1 & p2)) & p3);
endmodule

// -------------------7) 32-bit bit_wise comparator -----------------------
// ------------- first level 8 4:1 muxs, second level 1 8:1 mux ---------

module cmp3s_32_leg (ai, bi, a_ltn_b, a_eql_b, a_gtn_b);  
  
input  [31:0]  ai;
input  [31:0]  bi;
output         a_ltn_b;		// ai less  than bi.
output	       a_eql_b;		// ai equal to   bi.
output         a_gtn_b; 	// ai great than bi.
 
/* Logic
assign a_ltn_b = ( ai[31:0]  < bi[31:0] ) ;
assign a_eql_b = ( ai[31:0] == bi[31:0] ) ;
assign a_gtn_b = ( ai[31:0]  > bi[31:0] ) ; 
*/

wire    [31:0]  bit_eql_not;	// bit-wise equal_not output
 
reg    [2:0]  np7;	// 7th's nip_equal_great_less output
reg    [2:0]  np6;	// 6th
reg    [2:0]  np5;	// 5th
reg    [2:0]  np4;	// 5th
reg    [2:0]  np3, np2, np1, np0;	// 3~0th
reg    [2:0]  np_hi, np_lo;		// second level.

assign bit_eql_not = ai ^ bi ;

always @ (bit_eql_not or ai or bi)
    begin
	casex (bit_eql_not[31:28]) // synopsys full_case parallel_case
	4'b1xxx: np7 = {1'b0, ai[31], bi[31]} ;
	4'b01xx: np7 = {1'b0, ai[30], bi[30]} ;
	4'b001x: np7 = {1'b0, ai[29], bi[29]} ;
	4'b0001: np7 = {1'b0, ai[28], bi[28]} ;
	4'b0000: np7 = {1'b1, 1'b0,1'b0} ; // 4_equal, next 
	default:     np7 = 3'bxxx ;
	endcase

	casex (bit_eql_not[27:24]) // synopsys full_case parallel_case
	4'b1xxx: np6 = {1'b0, ai[27], bi[27]} ;
	4'b01xx: np6 = {1'b0, ai[26], bi[26]} ;
	4'b001x: np6 = {1'b0, ai[25], bi[25]} ;
	4'b0001: np6 = {1'b0, ai[24], bi[24]} ;
	4'b0000: np6 = {1'b1, 1'b0,1'b0} ; // 4_equal, next 
	default:     np6 = 3'bxxx ;
	endcase

	casex (bit_eql_not[23:20]) // synopsys full_case parallel_case
	4'b1xxx: np5 = {1'b0, ai[23], bi[23]} ;
	4'b01xx: np5 = {1'b0, ai[22], bi[22]} ;
	4'b001x: np5 = {1'b0, ai[21], bi[21]} ;
	4'b0001: np5 = {1'b0, ai[20], bi[20]} ;
	4'b0000: np5 = {1'b1, 1'b0,1'b0} ; // 4_equal, next 
	default:     np5 = 3'bxxx ;
	endcase

	casex (bit_eql_not[19:16]) // synopsys full_case parallel_case
	4'b1xxx: np4 = {1'b0, ai[19], bi[19]} ;
	4'b01xx: np4 = {1'b0, ai[18], bi[18]} ;
	4'b001x: np4 = {1'b0, ai[17], bi[17]} ;
	4'b0001: np4 = {1'b0, ai[16], bi[16]} ;
	4'b0000: np4 = {1'b1, 1'b0,1'b0} ; // 4_equal, next 
	default:     np4 = 3'bxxx ;
	endcase

	casex (bit_eql_not[15:12]) // synopsys full_case parallel_case
	4'b1xxx: np3 = {1'b0, ai[15], bi[15]} ;
	4'b01xx: np3 = {1'b0, ai[14], bi[14]} ;
	4'b001x: np3 = {1'b0, ai[13], bi[13]} ;
	4'b0001: np3 = {1'b0, ai[12], bi[12]} ;
	4'b0000: np3 = {1'b1,1'b0,1'b0} ; // 4_equal, next
	default:     np3 = 3'bxxx ;
	endcase

	casex (bit_eql_not[11:8]) // synopsys full_case parallel_case
	4'b1xxx: np2 = {1'b0, ai[11], bi[11]} ;
	4'b01xx: np2 = {1'b0, ai[10], bi[10]} ;
	4'b001x: np2 = {1'b0, ai[9], bi[9]} ;
	4'b0001: np2 = {1'b0, ai[8], bi[8]} ;
	4'b0000: np2 = {1'b1, 1'b0,1'b0} ; // 4_equal, next 
	default:     np2 = 3'bxxx ;
	endcase

	casex (bit_eql_not[7:4]) // synopsys full_case parallel_case
	4'b1xxx: np1 = {1'b0, ai[7], bi[7]} ;
	4'b01xx: np1 = {1'b0, ai[6], bi[6]} ;
	4'b001x: np1 = {1'b0, ai[5], bi[5]} ;
	4'b0001: np1 = {1'b0, ai[4], bi[4]} ;
	4'b0000: np1 = {1'b1, 1'b0,1'b0} ;	// 4_equal, next 
	default:     np1 = 3'bxxx ;
	endcase

	casex (bit_eql_not[3:0]) // synopsys full_case parallel_case
	4'b1xxx: np0 = {1'b0, ai[3], bi[3]} ;
	4'b01xx: np0 = {1'b0, ai[2], bi[2]} ;
	4'b001x: np0 = {1'b0, ai[1], bi[1]} ;
	4'b0001: np0 = {1'b0, ai[0], bi[0]} ;
	4'b0000: np0 = {1'b1,1'b0,1'b0 } ;	// 4_equal, next 
	default:     np0 = 3'bxxx ;
	endcase
    end

always @ ( np7 or np6 or np5 or np4 )
    begin
	casex ({np7[2],np6[2],np5[2],np4[2]}) // synopsys full_case parallel_case
	4'b0xxx: np_hi = {1'b0,np7[1:0]} ;
	4'b10xx: np_hi = {1'b0,np6[1:0]} ;
	4'b110x: np_hi = {1'b0,np5[1:0]} ;
	4'b1110: np_hi = {1'b0,np4[1:0]} ;
	4'b1111: np_hi = {1'b1,np4[1:0]} ;
	default: np_hi = {1'b1,np4[1:0]} ;
	endcase
    end

always @ ( np3 or np2 or np1 or np0 )
    begin
	casex ({np3[2],np2[2],np1[2],np0[2]}) // synopsys full_case parallel_case
	4'b0xxx: np_lo = {1'b0,np3[1:0]} ;
	4'b10xx: np_lo = {1'b0,np2[1:0]} ;
	4'b110x: np_lo = {1'b0,np1[1:0]} ;
	4'b1110: np_lo = {1'b0,np0[1:0]} ;
	4'b1111: np_lo = {1'b1,np0[1:0]} ;
	default: np_lo = {1'b1,np0[1:0]} ;
	endcase
    end

assign a_eql_b = np_hi[2] & np_lo[2] ;
assign {a_gtn_b, a_ltn_b} = (!np_hi[2]) ? np_hi[1:0] : np_lo[1:0] ;

endmodule


// ------------------- 8)16-bit adder (using sum4 stages)-------------------

module fa16 (a, b, c, sum, cout);  
  
input  [15:0]  a;
input  [15:0]  b;
output  [15:0]  sum;

input		c;		// carry in
output		cout;		// carry out


// -------------------- carry tree level 1 ----------------------------
// produce the generate for the least significant bit (sch: glsbs)

wire g0_l = !(((a[0] | b[0]) & c) | (a[0] &b[0]));

// produce the propagates and generates for the other bits

wire gen0_l, p0_l, g1_l, p1_l, g2_l, p2_l, g3_l, p3_l, g4_l, p4_l, 
	g5_l, p5_l, g6_l, p6_l, g7_l, p7_l, g8_l, p8_l, g9_l, p9_l, 
	g10_l, p10_l, g11_l, p11_l, g12_l, p12_l, g13_l, p13_l, g14_l, p14_l, 
	g15_l, p15_l;

pgnx_fa16 pgnx0 (a[0], b[0], gen0_l, p0_l);	// gen0_l is used only for sum[0] calc.
pgnx_fa16 pgnx1 (a[1], b[1], g1_l, p1_l);
pgnx_fa16 pgnx2 (a[2], b[2], g2_l, p2_l);
pgnx_fa16 pgnx3 (a[3], b[3], g3_l, p3_l);
pgnx_fa16 pgnx4 (a[4], b[4], g4_l, p4_l);
pgnx_fa16 pgnx5 (a[5], b[5], g5_l, p5_l);
pgnx_fa16 pgnx6 (a[6], b[6], g6_l, p6_l);
pgnx_fa16 pgnx7 (a[7], b[7], g7_l, p7_l);
pgnx_fa16 pgnx8 (a[8], b[8], g8_l, p8_l);
pgnx_fa16 pgnx9 (a[9], b[9], g9_l, p9_l);
pgnx_fa16 pgnx10 (a[10], b[10], g10_l, p10_l);
pgnx_fa16 pgnx11 (a[11], b[11], g11_l, p11_l);
pgnx_fa16 pgnx12 (a[12], b[12], g12_l, p12_l);
pgnx_fa16 pgnx13 (a[13], b[13], g13_l, p13_l);
pgnx_fa16 pgnx14 (a[14], b[14], g14_l, p14_l);
pgnx_fa16 pgnx15 (a[15], b[15], g15_l, p15_l);


// -------------------- carry tree level 2 ----------------------------
// produce group propagates/generates for sets of 2 bits (sch: pg2)
// this stage contains the ling modification, which simplifies
//      this stage, but the outputs are Pseudo-generates, which
//      later need to be recovered by anding.

wire g0to1, g2to3, g4to5, g6to7, g8to9, g10to11, g12to13,g14to15,
	p1to2, p3to4, p5to6, p7to8, p9to10, p11to12, p13to14;

pg2lg_fa16 pg2lg (	.gd_l(g0_l), 
		.gu_l(g1_l), 
		.g(g0to1));	//assign g0to1 	=  !(g0_l & g1_l);

pg2l_fa16 p2gl0 (	.gd_l(g2_l), 
		.gu_l(g3_l), 
		.pd_l(p1_l), 
		.pu_l(p2_l),
		.g(g2to3),	//assign g2to3 	=  !(g2_l & g3_l);
		.p(p1to2));	//assign p1to2 	=  !(p1_l | p2_l);
				

pg2l_fa16 p2gl1 (	.gd_l(g4_l), 
		.gu_l(g5_l), 
		.pd_l(p3_l), 
		.pu_l(p4_l),
		.g(g4to5),	//assign g4to5 	=  !(g4_l & g5_l);
		.p(p3to4));	//assign p3to4 	=  !(p3_l | p4_l);

pg2l_fa16 p2gl2 (	.gd_l(g6_l), 
		.gu_l(g7_l), 
		.pd_l(p5_l), 
		.pu_l(p6_l),
		.g(g6to7),	//assign g6to7 	=  !(g6_l & g7_l);
		.p(p5to6));	//assign p5to6 	=  !(p5_l | p6_l);

pg2l_fa16 p2gl3 (	.gd_l(g8_l), 
		.gu_l(g9_l), 
		.pd_l(p7_l), 
		.pu_l(p8_l),
		.g(g8to9),	//assign g8to9 	=  !(g8_l & g9_l);
		.p(p7to8));	//assign p7to8 	=  !(p7_l | p8_l);

pg2l_fa16 p2gl4 (	.gd_l(g10_l), 
		.gu_l(g11_l), 
		.pd_l(p9_l), 
		.pu_l(p10_l),
		.g(g10to11),	//assign g10to11 =  !(g10_l & g11_l);
		.p(p9to10));	//assign p9to10  =  !(p9_l | p10_l);

pg2l_fa16 p2gl5 (	.gd_l(g12_l), 
		.gu_l(g13_l), 
		.pd_l(p11_l), 
		.pu_l(p12_l),
		.g(g12to13),	//assign g12to13 =  !(g12_l & g13_l);
		.p(p11to12));	//assign p11to12 =  !(p11_l | p12_l);

pg2l_fa16 p2gl6 (	.gd_l(g14_l), 
		.gu_l(g15_l), 
		.pd_l(p13_l), 
		.pu_l(p14_l),
		.g(g14to15),	//assign g14to15 	=  !(g14_l & g15_l);
		.p(p13to14));	//assign p13to14 	=  !(p13_l | p14_l);




// -------------------- carry tree level 3 ----------------------------
// use aoi to make group generates

wire g0to3_l, g4to7_l, g8to11_l, g12to15_l,
	      p3to6_l, p7to10_l, p11to14_l;

aoig_fa16 aoig0 (	.gd(g0to1), 
		.gu(g2to3), 
		.pu(p1to2), 
		.g_l(g0to3_l));		//assign g0to3_l  = !((g0to1 & p1to2) | g2to3);

baoi_fa16 baoi0 (	.gd(g4to5), 
		.gu(g6to7), 
		.pd(p3to4), 
		.pu(p5to6),
		.g_l(g4to7_l),		//assign g4to7_l  = !((g4to5 & p5to6) | g6to7);
		.p_l(p3to6_l));		//assign p3to6_l = !(p3to4 & p5to6);	

baoi_fa16 baoi1 (	.gd(g8to9), 
		.gu(g10to11), 
		.pd(p7to8), 
		.pu(p9to10),
		.g_l(g8to11_l),		//assign g8to11_l = !((g8to9 & p9to10) | g10to11);
		.p_l(p7to10_l));	//assign p7to10_l = !(p7to8 & p9to10);

baoi_fa16 baoi2 (	.gd(g12to13), 
		.gu(g14to15), 
		.pd(p11to12), 
		.pu(p13to14),
		.g_l(g12to15_l),	//assign g12to15_l = !((g12to13 & p13to14) | g14to15);	
		.p_l(p11to14_l));	//assign p11to14_l = !(p11to12 & p13to14);



// -------------------- carry tree level 4 ----------------------------
// use oai's since the inputs are active-low.
wire g0to7, g4to11, g8to15,
	    p3to10, p7to14;

oaig_fa16 oaig0 (	.gd_l(g0to3_l), 
		.gu_l(g4to7_l), 
		.pu_l(p3to6_l), 
		.g(g0to7));		//assign g0to7 =  !((g0to3_l | p3to6_l) & g4to7_l);

boai_fa16 boai0 (	.gd_l(g4to7_l), 
		.gu_l(g8to11_l), 
		.pd_l(p3to6_l),
		.pu_l(p7to10_l), 	
		.g(g4to11),		//assign g4to11 = !((g4to7_l | p7to10_l) & g8to11_l);
		.p(p3to10));		//assign p3to10 = !(p3to6_l | p7to10_l);

boai_fa16 boai1 (	.gd_l(g8to11_l), 
		.gu_l(g12to15_l), 
		.pd_l(p7to10_l),
		.pu_l(p11to14_l), 	
		.g(g8to15),		//assign g8to15 = !((g8to11_l | p11to14_l) & g12to15_l);
		.p(p7to14));		//assign p7to14 = !(p7to10_l | p11to14_l);	



// -------------------- carry tree level 5 ----------------------------
// use aoi's to make group generates
wire g0to11_l, g0to15_l;

aoig_fa16 aoig5_0 (	.gd(~g0to3_l), 
		.gu(g4to11), 
		.pu(p3to10), 
		.g_l(g0to11_l));	//assign g0to11_l = !((~g0to3_l & p3to10) | g4to11);	

aoig_fa16 aoig5_1 (	.gd(g0to7), 
		.gu(g8to15), 
		.pu(p7to14), 
		.g_l(g0to15_l));	//assign g0to15_l = !((g0to7    & p7to14) | g8to15);	



// -------------------- sum, and cout ----------------------------

assign cout = !g0to15_l & !p15_l;  // recover cout by anding p15 with the 
				   //       pseudo-generate

wire [15:0] suma, sumb;            // local sums before carry select mux

sum4_fa16 sum0to3 (.g1(~gen0_l), .g2(~g1_l), .g3(~g2_l), .g4(~g3_l),
                .p0(1'b1), .p1(~p0_l), .p2(~p1_l), .p3(~p2_l), .p4(~p3_l),
                .sum1a(suma[0]), .sum2a(suma[1]), .sum3a(suma[2]), .sum4a(suma[3]),
                .sum1b(sumb[0]), .sum2b(sumb[1]), .sum3b(sumb[2]), .sum4b(sumb[3]));
sum4_fa16 sum4to7 (.g1(~g4_l), .g2(~g5_l), .g3(~g6_l), .g4(~g7_l),
                .p0(~p3_l), .p1(~p4_l), .p2(~p5_l), .p3(~p6_l), .p4(~p7_l),
                .sum1a(suma[4]), .sum2a(suma[5]), .sum3a(suma[6]), .sum4a(suma[7]),
                .sum1b(sumb[4]), .sum2b(sumb[5]), .sum3b(sumb[6]), .sum4b(sumb[7]));
sum4_fa16 sum8to11 (.g1(~g8_l), .g2(~g9_l), .g3(~g10_l), .g4(~g11_l),
                .p0(~p7_l), .p1(~p8_l), .p2(~p9_l), .p3(~p10_l), .p4(~p11_l),
                .sum1a(suma[8]), .sum2a(suma[9]), .sum3a(suma[10]), .sum4a(suma[11]),
                .sum1b(sumb[8]), .sum2b(sumb[9]), .sum3b(sumb[10]), .sum4b(sumb[11]));
sum4_fa16 sum12to15 (.g1(~g12_l), .g2(~g13_l), .g3(~g14_l), .g4(~g15_l),
                .p0(~p11_l), .p1(~p12_l), .p2(~p13_l), .p3(~p14_l), .p4(~p15_l),
                .sum1a(suma[12]), .sum2a(suma[13]), .sum3a(suma[14]), .sum4a(suma[15]),
                .sum1b(sumb[12]), .sum2b(sumb[13]), .sum3b(sumb[14]), .sum4b(sumb[15]));


/**********  mux to select sum using G*  signals from carry tree *****/

selsum4_fa16 selsum0to3 (  .sum1a(suma[0]), .sum2a(suma[1]), .sum3a(suma[2]), .sum4a(suma[3]), 
		  .sum1b(sumb[0]), .sum2b(sumb[1]), .sum3b(sumb[2]), .sum4b(sumb[3]), 
		  .sel(c), 
		  .sum1(sum[0]), .sum2(sum[1]), .sum3(sum[2]), .sum4(sum[3]));
selsum4_fa16 selsum4to7 (  .sum1a(suma[4]), .sum2a(suma[5]), .sum3a(suma[6]), .sum4a(suma[7]), 
		  .sum1b(sumb[4]), .sum2b(sumb[5]), .sum3b(sumb[6]), .sum4b(sumb[7]), 
		  .sel(~g0to3_l), 
		  .sum1(sum[4]), .sum2(sum[5]), .sum3(sum[6]), .sum4(sum[7]));
selsum4_fa16 selsum8to11 (  .sum1a(suma[8]), .sum2a(suma[9]), .sum3a(suma[10]), .sum4a(suma[11]), 
		  .sum1b(sumb[8]), .sum2b(sumb[9]), .sum3b(sumb[10]), .sum4b(sumb[11]), 
		  .sel(g0to7), 
		  .sum1(sum[8]), .sum2(sum[9]), .sum3(sum[10]), .sum4(sum[11]));
selsum4_fa16 selsum12to15 (  .sum1a(suma[12]), .sum2a(suma[13]), .sum3a(suma[14]), .sum4a(suma[15]), 
		  .sum1b(sumb[12]), .sum2b(sumb[13]), .sum3b(sumb[14]), .sum4b(sumb[15]), 
		  .sel(~g0to11_l), 
		  .sum1(sum[12]), .sum2(sum[13]), .sum3(sum[14]), .sum4(sum[15]));

endmodule




// -------------------- selsum4 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selsum4_fa16 (sel, sum1, sum2, sum3, sum4,
	     sum1a, sum2a, sum3a, sum4a,
	     sum1b, sum2b, sum3b, sum4b);

input sum1a, sum2a, sum3a, sum4a,
	sum1b, sum2b, sum3b, sum4b, sel;
output sum1, sum2, sum3, sum4;
wire sum1, sum2, sum3, sum4;

assign sum1 = sel ? sum1a : sum1b;
assign sum2 = sel ? sum2a : sum2b;
assign sum3 = sel ? sum3a : sum3b;
assign sum4 = sel ? sum4a : sum4b;

endmodule


// -------------------- sum  ----------------------------
// we need to recover the real gernerates
//       after the ling modification used in level 2.
// we also are replacing the a,b with p,g to reduce loading
//       of the a,b inputs.  (a ^ b = p & !g)
// send out two sets of sums to be selected with mux at last stage


module sum4_fa16 (g1, g2, g3, g4, p0, p1, p2, p3, p4, 
	     sum1a, sum2a, sum3a, sum4a,
	     sum1b, sum2b, sum3b, sum4b);

output sum1a, sum2a, sum3a, sum4a,
	sum1b, sum2b, sum3b, sum4b;	// sum outputs.
input  g1, g2, g3, g4;  		// individual generate inputs.
input  p0, p1, p2, p3, p4;  		// individual propagate inputs.
//input  G;    		        	// global carry input. (pseudo-generate)
wire	sum1a, sum2a, sum3a, sum4a,
	sum1b, sum2b, sum3b, sum4b;

assign      sum1a = (p1 & (~g1)) ^ p0;
assign      sum2a = (p2 & (~g2)) ^ (g1 | (p1 & p0));
assign      sum3a = (p3 & (~g3)) ^ (g2 | ((g1 | (p1 & p0)) & p2));
assign      sum4a = (p4 & (~g4)) ^ (g3 | ((g2 | ((g1 | (p1 & p0)) & p2)) & p3));
assign      sum1b = p1 & (~g1);
assign      sum2b = (p2 & (~g2)) ^ g1;
assign      sum3b = (p3 & (~g3)) ^ (g2 | (g1 & p2));
assign      sum4b = (p4 & (~g4)) ^ (g3 | (g2 | (g1 & p2)) & p3);

endmodule


// -------------------- pgnx ----------------------------
module pgnx_fa16 (a, b, g_l, p_l); // level 1 propagate and generate signals

input a, b;
output g_l, p_l;

assign g_l = !(a & b);	//nand to make 2bit pseudo generate
assign p_l = !(a | b);	//nor to make 2bit pseudo propagate

endmodule


// -------------------- pg2lg ----------------------------
// ling modification stage, generate only

module pg2lg_fa16 (gd_l, gu_l, g); 

input gd_l, gu_l;
output g;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate

endmodule


// -------------------- pg2l ----------------------------
// ling modification stage, psuedo group generate and propagate

module pg2l_fa16 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pd_l, pu_l;
output g, p;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate
assign p = !(pd_l | pu_l);	//nor to make pseudo generate

endmodule


// -------------------- aoig ----------------------------
// aoi for carry tree generates

module aoig_fa16 (gd, gu, pu, g_l); 

input gd, gu, pu;
output g_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate

endmodule

// -------------------- oaig ----------------------------
// aoi for carry tree generates

module oaig_fa16 (gd_l, gu_l, pu_l, g); 

input gd_l, gu_l, pu_l;
output g;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate

endmodule


// -------------------- baoi ----------------------------
// aoi for carry tree generates + logic for propagate

module baoi_fa16 (gd, gu, pd, pu, g_l, p_l); 

input gd, gu, pd, pu;
output g_l, p_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate
assign p_l = ~(pd & pu); // nand to make group prop

endmodule


// -------------------- boai ----------------------------
// aoi for carry tree generates

module boai_fa16 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pu_l, pd_l;
output g, p;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate
assign p = ~(pu_l | pd_l);  // nor to make group prop

endmodule

// ------------------- 9) 16-bit bit_wise comparator -----------------------

module cmp16_e (ai, bi, a_eql_b);  
  
input  [15:0]  ai;
input  [15:0]  bi;
output         a_eql_b;         // ai equal to   bi.
 
/* Logic
assign a_eql_b = ( ai[15:0] == bi[15:0] ) ; 
*/

wire    [15:0] ben;             // bit-wise equal_not output
wire    [7:0]  lv1;             // 8-equal     output
wire    [3:0]  lv2;             // 4-equal_not output
wire    [1:0]  lv3;             // 2-equal     output

/* Behaviral model's performence is at 1.14 ns.*/

assign ben[15:0] = ai[15:0] ^ bi[15:0] ;        // 16 2-in exor, g10p "eo".
assign lv1[3] = !(|ben[15:12]);         // 1 4-in "nr4".
assign lv1[2] = !(|ben[11:8]);          // 1 4-in "nr4".
assign lv1[1] = !(|ben[7:4]);           // 1 4-in "nr4".
assign lv1[0] = !(|ben[3:0]);           // 1 4-in "nr4".
assign lv2[1] = !(&lv1[3:2]);           // 1 2-in "nd2".
assign lv2[0] = !(&lv1[1:0]);           // 1 2-in "nd2".
assign a_eql_b =    !(|lv2[1:0]);               // 1 2-in "nr2".

endmodule


// -------------------10) 16-bit all_zero comparator -----------------------

module cmp16zero (ai, a_eql_z);  
  
input  [15:0]  ai;
output         a_eql_z;         // ai equal to all_zero.
 
/* Logic
assign a_eql_z = ( ai[15:0] == 16'b0 ) ; 
*/

/*Behaviral model's performence is at 1.28 ns.*/

wire    [15:0]  bit_eql;        // bit-wise equal output
wire    [ 3:0]  level_1;                // 8-equal_not output
wire    [ 1:0]  level_2;                // 4-equal
assign bit_eql[15:0] = ~ai[15:0] ;              // 16 "n1a".
assign level_1[3] = !(&bit_eql[15:12]);         // 1 4-in "nd4".
assign level_1[2] = !(&bit_eql[11:8]);          // 1 4-in "nd4".
assign level_1[1] = !(&bit_eql[7:4]);           // 1 4-in "nd4".
assign level_1[0] = !(&bit_eql[3:0]);           // 1 4-in "nd4".
assign level_2[1] = !(|level_1[3:2]);           // 1 2-in "nr2".
assign level_2[0] = !(|level_1[1:0]);           // 1 2-in "nr2".
assign a_eql_z =    (&level_2[1:0]);            // 1 2-in "and4".

endmodule


// --11) Leading zero detector block, continous leading zeros numbers output --

module lbd32 (zr_num, di);  
  
output [ 5:0]  zr_num;
input  [31:0]  di;

reg   [3:0]   b3_num, b2_num, b1_num, b0_num;
reg           w5, w4, w3, w2, w1, w0;

/* Logic */
always @ ( di )
    begin
        casex (di[31:24])        //synopsys parallel_case
        8'b00000000: b3_num = 4'b1000 ; // 8 zeros
        8'b00000001: b3_num = 4'b0111 ; // 7 zeros
        8'b0000001x: b3_num = 4'b0110 ; // 6 zeros
        8'b000001xx: b3_num = 4'b0101 ; // 5 zeros
        8'b00001xxx: b3_num = 4'b0100 ; // 4 zeros
        8'b0001xxxx: b3_num = 4'b0011 ; // 3 zeros
        8'b001xxxxx: b3_num = 4'b0010 ; // 2 zeros
        8'b01xxxxxx: b3_num = 4'b0001 ; // 1 zero
        8'b1xxxxxxx: b3_num = 4'b0000 ; // none
        default:     b3_num = 4'bxxxx ;
        endcase

        casex (di[23:16])        //synopsys parallel_case
        8'b00000000: b2_num = 4'b1000 ;
        8'b00000001: b2_num = 4'b0111 ;
        8'b0000001x: b2_num = 4'b0110 ;
        8'b000001xx: b2_num = 4'b0101 ;
        8'b00001xxx: b2_num = 4'b0100 ;
        8'b0001xxxx: b2_num = 4'b0011 ;
        8'b001xxxxx: b2_num = 4'b0010 ;
        8'b01xxxxxx: b2_num = 4'b0001 ;
        8'b1xxxxxxx: b2_num = 4'b0000 ;
        default:     b2_num = 4'bxxxx ;
        endcase

        casex (di[15:8])         //synopsys parallel_case
        8'b00000000: b1_num = 4'b1000 ;
        8'b00000001: b1_num = 4'b0111 ;
        8'b0000001x: b1_num = 4'b0110 ;
        8'b000001xx: b1_num = 4'b0101 ;
        8'b00001xxx: b1_num = 4'b0100 ;
        8'b0001xxxx: b1_num = 4'b0011 ;
        8'b001xxxxx: b1_num = 4'b0010 ;
        8'b01xxxxxx: b1_num = 4'b0001 ;
        8'b1xxxxxxx: b1_num = 4'b0000 ;
        default:     b1_num = 4'bxxxx ;
        endcase

        casex (di[7:0])         //synopsys parallel_case
        8'b00000000: b0_num = 4'b1000 ; // 8 zero
        8'b00000001: b0_num = 4'b0111 ; // 7 zero
        8'b0000001x: b0_num = 4'b0110 ; // 6 zero
        8'b000001xx: b0_num = 4'b0101 ; // 5 zero
        8'b00001xxx: b0_num = 4'b0100 ; // 4 zero
        8'b0001xxxx: b0_num = 4'b0011 ; // 3 zero
        8'b001xxxxx: b0_num = 4'b0010 ; // 2 zero
        8'b01xxxxxx: b0_num = 4'b0001 ; // 1 zero
        8'b1xxxxxxx: b0_num = 4'b0000 ; // 0 zero
        default:     b0_num = 4'bxxxx ;
        endcase
    end


always @ ( b3_num or b2_num or b1_num or b0_num )
    begin 
        casex ({~b3_num[3],~b2_num[3],~b1_num[3],~b0_num[3]})  //synopsys parallel_case
        4'b0000: begin
                 {w5,w4,w3,w2,w1,w0} = 6'b100000 ;      // select b3_num same as b0_num. both 0
                 end
        4'b0001: begin
                 {w5,w4,w3} = 3'b011 ;                  // select b0_num
                 {w2,w1,w0} = b0_num[2:0] ;             // 0
                 end
        4'b001x: begin
                 {w5,w4,w3} = 3'b010 ;                  // select b1_num
                 {w2,w1,w0} = b1_num[2:0] ;             // 1
                 end
        4'b01xx: begin
                 {w5,w4,w3} = 3'b001 ;                  // select b2_num
                 {w2,w1,w0} = b2_num[2:0] ;             // 2
                 end
        4'b1xxx: begin
                 {w5,w4,w3} = 3'b000 ;                  // select b3_num
                 {w2,w1,w0} = b3_num[2:0] ;             // 3
                 end
        default: {w5,w4,w3,w2,w1,w0} = 6'bxxxxxx ;
        endcase
    end

assign zr_num[5:0] = {w5,w4,w3,w2,w1,w0} ; // pack outputs

endmodule



// -------------------12)  28-bit full adder -----------------------------------
// ------------------- Kogge-Stone style -----------------------------------

module fa28 (ai, bi, cin, sum, cout);  
  
input  [27:0]  ai, bi;
input          cin;
output [27:0]  sum;
output         cout;
 
wire    [27:0]  gi_l;   // bit-wise generate carry output
wire    [27:0]  pi_l;   // bit-wise propgate carry output
wire    gen1_l;
wire    g27_26, g25_24, g23_22, g21_20, g19_18, g17_16, g15_14,
        g13_12, g11_10, g9_8, g7_6, g5_4, g3_2, g1_0;
wire    p26_25, p24_23, p22_21, p20_19, p18_17, p16_15, p14_13,
        p12_11, p10_9, p8_7, p6_5, p4_3, p2_1;
wire    g27_24_l, g23_20_l, g19_16_l, g15_12_l, g11_8_l, g7_4_l, g3_0_l;
wire    p26_23_l, p22_19_l, p18_15_l, p14_11_l, p10_7_l, p6_3_l;
wire    g27_20, g23_16, g19_12, g15_8, g11_4, g7_0;
wire    p26_19, p22_15, p18_11, p14_7, p10_3;
wire    g27_12_l, g23_8_l, g19_4_l, g15_0_l, g11_0_l;
wire    p26_11_l, p22_7_l, p18_3_l;
wire    g27_0, g23_0, g19_0;
wire    w2_3_0, w3i_7_0, w3i_3_0, w4_15_0, w4_11_0, w4_7_0, w4_3_0;
wire    [27:0] in, inb;
wire    [27:0] sum;


assign gen1_l     = ~ (ai[0] & bi[0]);

pgnx28 pg_27 ( .gen_l(gi_l[27]), .pro_l(pi_l[27]), .ain(ai[27]), .bin(bi[27]));
pgnx28 pg_26 ( .gen_l(gi_l[26]), .pro_l(pi_l[26]), .ain(ai[26]), .bin(bi[26]));
pgnx28 pg_25 ( .gen_l(gi_l[25]), .pro_l(pi_l[25]), .ain(ai[25]), .bin(bi[25]));
pgnx28 pg_24 ( .gen_l(gi_l[24]), .pro_l(pi_l[24]), .ain(ai[24]), .bin(bi[24]));
pgnx28 pg_23 ( .gen_l(gi_l[23]), .pro_l(pi_l[23]), .ain(ai[23]), .bin(bi[23]));
pgnx28 pg_22 ( .gen_l(gi_l[22]), .pro_l(pi_l[22]), .ain(ai[22]), .bin(bi[22]));
pgnx28 pg_21 ( .gen_l(gi_l[21]), .pro_l(pi_l[21]), .ain(ai[21]), .bin(bi[21]));
pgnx28 pg_20 ( .gen_l(gi_l[20]), .pro_l(pi_l[20]), .ain(ai[20]), .bin(bi[20]));
pgnx28 pg_19 ( .gen_l(gi_l[19]), .pro_l(pi_l[19]), .ain(ai[19]), .bin(bi[19]));
pgnx28 pg_18 ( .gen_l(gi_l[18]), .pro_l(pi_l[18]), .ain(ai[18]), .bin(bi[18]));
pgnx28 pg_17 ( .gen_l(gi_l[17]), .pro_l(pi_l[17]), .ain(ai[17]), .bin(bi[17]));
pgnx28 pg_16 ( .gen_l(gi_l[16]), .pro_l(pi_l[16]), .ain(ai[16]), .bin(bi[16]));
pgnx28 pg_15 ( .gen_l(gi_l[15]), .pro_l(pi_l[15]), .ain(ai[15]), .bin(bi[15]));
pgnx28 pg_14 ( .gen_l(gi_l[14]), .pro_l(pi_l[14]), .ain(ai[14]), .bin(bi[14]));
pgnx28 pg_13 ( .gen_l(gi_l[13]), .pro_l(pi_l[13]), .ain(ai[13]), .bin(bi[13]));
pgnx28 pg_12 ( .gen_l(gi_l[12]), .pro_l(pi_l[12]), .ain(ai[12]), .bin(bi[12]));
pgnx28 pg_11 ( .gen_l(gi_l[11]), .pro_l(pi_l[11]), .ain(ai[11]), .bin(bi[11]));
pgnx28 pg_10 ( .gen_l(gi_l[10]), .pro_l(pi_l[10]), .ain(ai[10]), .bin(bi[10]));
pgnx28 pg_9  ( .gen_l(gi_l[9]), .pro_l(pi_l[9]), .ain(ai[9]), .bin(bi[9]));
pgnx28 pg_8  ( .gen_l(gi_l[8]), .pro_l(pi_l[8]), .ain(ai[8]), .bin(bi[8]));
pgnx28 pg_7  ( .gen_l(gi_l[7]), .pro_l(pi_l[7]), .ain(ai[7]), .bin(bi[7]));
pgnx28 pg_6  ( .gen_l(gi_l[6]), .pro_l(pi_l[6]), .ain(ai[6]), .bin(bi[6]));
pgnx28 pg_5  ( .gen_l(gi_l[5]), .pro_l(pi_l[5]), .ain(ai[5]), .bin(bi[5]));
pgnx28 pg_4  ( .gen_l(gi_l[4]), .pro_l(pi_l[4]), .ain(ai[4]), .bin(bi[4]));
pgnx28 pg_3  ( .gen_l(gi_l[3]), .pro_l(pi_l[3]), .ain(ai[3]), .bin(bi[3]));
pgnx28 pg_2  ( .gen_l(gi_l[2]), .pro_l(pi_l[2]), .ain(ai[2]), .bin(bi[2]));
pgnx28 pg_1  ( .gen_l(gi_l[1]), .pro_l(pi_l[1]), .ain(ai[1]), .bin(bi[1]));
pgnl28 pg_0  ( .gen_l(gi_l[0]), .pro_l(pi_l[0]), .ain(ai[0]), .bin(bi[0]), .carryin(cin));


/* pg2 stage */


pg2_fa28 pg_27_26 ( .g_u_d(g27_26),
               .p_u_d(p26_25),
               .g_l_in(gi_l[27:26]),
               .p_l_in(pi_l[26:25]));

pg2_fa28 pg_25_24 ( .g_u_d(g25_24),
               .p_u_d(p24_23),
               .g_l_in(gi_l[25:24]),
               .p_l_in(pi_l[24:23]));

pg2_fa28 pg_23_22 ( .g_u_d(g23_22),
               .p_u_d(p22_21),
               .g_l_in(gi_l[23:22]),
               .p_l_in(pi_l[22:21]));

pg2_fa28 pg_21_20 ( .g_u_d(g21_20),
               .p_u_d(p20_19),
               .g_l_in(gi_l[21:20]),
               .p_l_in(pi_l[20:19]));

pg2_fa28 pg_19_18 ( .g_u_d(g19_18),
               .p_u_d(p18_17),
               .g_l_in(gi_l[19:18]),
               .p_l_in(pi_l[18:17]));

pg2_fa28 pg_17_16 ( .g_u_d(g17_16),
               .p_u_d(p16_15),
               .g_l_in(gi_l[17:16]),
               .p_l_in(pi_l[16:15]));

pg2_fa28 pg_15_14 ( .g_u_d(g15_14),
               .p_u_d(p14_13),
               .g_l_in(gi_l[15:14]),
               .p_l_in(pi_l[14:13]));

pg2_fa28 pg_13_12 ( .g_u_d(g13_12),
               .p_u_d(p12_11),
               .g_l_in(gi_l[13:12]),
               .p_l_in(pi_l[12:11]));

pg2_fa28 pg_11_10 ( .g_u_d(g11_10),
               .p_u_d(p10_9),
               .g_l_in(gi_l[11:10]),
               .p_l_in(pi_l[10:9]));

pg2_fa28 pg_9_8 (   .g_u_d(g9_8),
               .p_u_d(p8_7),
               .g_l_in(gi_l[9:8]),
               .p_l_in(pi_l[8:7]));

pg2_fa28 pg_7_6 (   .g_u_d(g7_6),
               .p_u_d(p6_5),
               .g_l_in(gi_l[7:6]),
               .p_l_in(pi_l[6:5]));

pg2_fa28 pg_5_4 (   .g_u_d(g5_4),
               .p_u_d(p4_3),
               .g_l_in(gi_l[5:4]),
               .p_l_in(pi_l[4:3]));

pg2_fa28 pg_3_2 (   .g_u_d(g3_2),
               .p_u_d(p2_1),
               .g_l_in(gi_l[3:2]),
               .p_l_in(pi_l[2:1]));

assign g1_0 =   ~ (gi_l[1] & gi_l[0]);



/* b1 stage */


b1aoi_fa28 pg_27_24 ( .ggrp_l(g27_24_l),
                .pgrp_l(p26_23_l),
                .gu_in(g27_26),
                .pu_in(p26_25),
                .gd_in(g25_24),
                .pd_in(p24_23));


b1aoi_fa28 pg_23_20 ( .ggrp_l(g23_20_l),
                .pgrp_l(p22_19_l),
                .gu_in(g23_22),
                .pu_in(p22_21),
                .gd_in(g21_20),
                .pd_in(p20_19));


b1aoi_fa28 pg_19_16 ( .ggrp_l(g19_16_l),
                .pgrp_l(p18_15_l),
                .gu_in(g19_18),
                .pu_in(p18_17),
                .gd_in(g17_16),
                .pd_in(p16_15));

b1aoi_fa28 pg_15_12 ( .ggrp_l(g15_12_l),
                .pgrp_l(p14_11_l),
                .gu_in(g15_14),
                .pu_in(p14_13),
                .gd_in(g13_12),
                .pd_in(p12_11));

b1aoi_fa28 pg_11_8 (  .ggrp_l(g11_8_l),
                .pgrp_l(p10_7_l),
                .gu_in(g11_10),
                .pu_in(p10_9),
                .gd_in(g9_8),
                .pd_in(p8_7));

b1aoi_fa28 pg_7_4 (   .ggrp_l(g7_4_l),
                .pgrp_l(p6_3_l),
                .gu_in(g7_6),
                .pu_in(p6_5),
                .gd_in(g5_4),
                .pd_in(p4_3));

g1aoi_fa28 g_3_0 (   .ggrp_l(g3_0_l),
                .gu_in(g3_2),
                .pu_in(p2_1),
                .gd_in(g1_0));



/* b2 stage */


b2oai_fa28 pg_27_20 ( .ggrp(g27_20),
                .pgrp(p26_19),
                .gu_in(g27_24_l),
                .pu_in(p26_23_l),
                .gd_in(g23_20_l),
                .pd_in(p22_19_l));

b2oai_fa28 pg_23_16 ( .ggrp(g23_16),
                .pgrp(p22_15),
                .gu_in(g23_20_l),
                .pu_in(p22_19_l),
                .gd_in(g19_16_l),
                .pd_in(p18_15_l));

b2oai_fa28 pg_19_12 ( .ggrp(g19_12),
                .pgrp(p18_11),
                .gu_in(g19_16_l),
                .pu_in(p18_15_l),
                .gd_in(g15_12_l),
                .pd_in(p14_11_l));

b2oai_fa28 pg_15_8 (  .ggrp(g15_8),
                .pgrp(p14_7),
                .gu_in(g15_12_l),
                .pu_in(p14_11_l),
                .gd_in(g11_8_l),
                .pd_in(p10_7_l));


b2oai_fa28 pg_11_4 (  .ggrp(g11_4),
                .pgrp(p10_3),
                .gu_in(g11_8_l),
                .pu_in(p10_7_l),
                .gd_in(g7_4_l),
                .pd_in(p6_3_l));

g2oai_fa28 g_7_0 (   .ggrp(g7_0),
                .gu_in(g7_4_l),
                .pu_in(p6_3_l),
                .gd_in(g3_0_l));

assign w2_3_0 = ~ g3_0_l;



/* b3 stage */

b3aoi_fa28 pg_27_12 ( .ggrp_l(g27_12_l),
                .pgrp_l(p26_11_l),
                .gu_in(g27_20),
                .pu_in(p26_19),
                .gd_in(g19_12),
                .pd_in(p18_11));

b3aoi_fa28 pg_23_8 (  .ggrp_l(g23_8_l),
                .pgrp_l(p22_7_l),
                .gu_in(g23_16),
                .pu_in(p22_15),
                .gd_in(g15_8),
                .pd_in(p14_7));

b3aoi_fa28 pg_19_4 (  .ggrp_l(g19_4_l),
                .pgrp_l(p18_3_l),
                .gu_in(g19_12),
                .pu_in(p18_11),
                .gd_in(g11_4),
                .pd_in(p10_3));

g3aoi_fa28 g_15_0 (   .ggrp_l(g15_0_l),
                .gu_in(g15_8),
                .pu_in(p14_7),
                .gd_in(g7_0));


g3aoi_fa28 g_11_0 (   .ggrp_l(g11_0_l),
                .gu_in(g11_4),
                .pu_in(p10_3),
                .gd_in(w2_3_0));

assign w3i_7_0 = ~ g7_0;

assign w3i_3_0 = ~ w2_3_0;



/* g4 stage */

g4oai_fa28 g_27_0 (   .ggrp(g27_0),
                .gu_in(g27_12_l),
                .pu_in(p26_11_l),
                .gd_in(g11_0_l));

g4oai_fa28 g_23_0 (   .ggrp(g23_0),
                .gu_in(g23_8_l),
                .pu_in(p22_7_l),
                .gd_in(w3i_7_0));

g4oai_fa28 g_19_0 (   .ggrp(g19_0),
                .gu_in(g19_4_l),
                .pu_in(p18_3_l),
                .gd_in(w3i_3_0));

assign w4_15_0 = ~ g15_0_l;
assign w4_11_0 = ~ g11_0_l;
assign w4_7_0  = ~ w3i_7_0;
assign w4_3_0  = ~ w3i_3_0;



/* Local Sum, Carry-select stage */

                
presum_fa28 psum27_24 (.g1(~gi_l[24]), .g2(~gi_l[25]), .g3(~gi_l[26]), .g4(~gi_l[27]),
                .p0(~pi_l[23]), .p1(~pi_l[24]), .p2(~pi_l[25]), .p3(~pi_l[26]), .p4(~pi_l[27]),
                .s1(in[24]), .s2(in[25]), .s3(in[26]), .s4(in[27]),
                .s1b(inb[24]), .s2b(inb[25]), .s3b(inb[26]), .s4b(inb[27]));

presum_fa28 psum23_20 (.g1(~gi_l[20]), .g2(~gi_l[21]), .g3(~gi_l[22]), .g4(~gi_l[23]),
                .p0(~pi_l[19]), .p1(~pi_l[20]), .p2(~pi_l[21]), .p3(~pi_l[22]), .p4(~pi_l[23]),
                .s1(in[20]), .s2(in[21]), .s3(in[22]), .s4(in[23]),
                .s1b(inb[20]), .s2b(inb[21]), .s3b(inb[22]), .s4b(inb[23]));

presum_fa28 psum19_16 (.g1(~gi_l[16]), .g2(~gi_l[17]), .g3(~gi_l[18]), .g4(~gi_l[19]),
                .p0(~pi_l[15]), .p1(~pi_l[16]), .p2(~pi_l[17]), .p3(~pi_l[18]), .p4(~pi_l[19]),
                .s1(in[16]), .s2(in[17]), .s3(in[18]), .s4(in[19]),
                .s1b(inb[16]), .s2b(inb[17]), .s3b(inb[18]), .s4b(inb[19]));

presum_fa28 psum15_12 (.g1(~gi_l[12]), .g2(~gi_l[13]), .g3(~gi_l[14]), .g4(~gi_l[15]),
                .p0(~pi_l[11]), .p1(~pi_l[12]), .p2(~pi_l[13]), .p3(~pi_l[14]), .p4(~pi_l[15]),
                .s1(in[12]), .s2(in[13]), .s3(in[14]), .s4(in[15]),
                .s1b(inb[12]), .s2b(inb[13]), .s3b(inb[14]), .s4b(inb[15]));

presum_fa28 psum11_8 (.g1(~gi_l[8]), .g2(~gi_l[9]), .g3(~gi_l[10]), .g4(~gi_l[11]),
                .p0(~pi_l[7]), .p1(~pi_l[8]), .p2(~pi_l[9]), .p3(~pi_l[10]), .p4(~pi_l[11]),
                .s1(in[8]), .s2(in[9]), .s3(in[10]), .s4(in[11]),
                .s1b(inb[8]), .s2b(inb[9]), .s3b(inb[10]), .s4b(inb[11]));

presum_fa28 psum7_4 (.g1(~gi_l[4]), .g2(~gi_l[5]), .g3(~gi_l[6]), .g4(~gi_l[7]),
                .p0(~pi_l[3]), .p1(~pi_l[4]), .p2(~pi_l[5]), .p3(~pi_l[6]), .p4(~pi_l[7]),
                .s1(in[4]), .s2(in[5]), .s3(in[6]), .s4(in[7]),
                .s1b(inb[4]), .s2b(inb[5]), .s3b(inb[6]), .s4b(inb[7]));

presum_fa28 psum3_0 (.g1(~gen1_l), .g2(~gi_l[1]), .g3(~gi_l[2]), .g4(~gi_l[3]),
                .p0(1'b1), .p1(~pi_l[0]), .p2(~pi_l[1]), .p3(~pi_l[2]), .p4(~pi_l[3]),
                .s1(in[0]), .s2(in[1]), .s3(in[2]), .s4(in[3]),
                .s1b(inb[0]), .s2b(inb[1]), .s3b(inb[2]), .s4b(inb[3]));



/* Sum stage */

sum4s_fa28 sum27_24 (.csel(g23_0), .sin1(in[24]), .sin2(in[25]), .sin3(in[26]), .sin4(in[27]),
                .sin1b(inb[24]), .sin2b(inb[25]), .sin3b(inb[26]), .sin4b(inb[27]),
                .sum1(sum[24]), .sum2(sum[25]), .sum3(sum[26]), .sum4(sum[27]));

sum4s_fa28 sum23_20 (.csel(g19_0), .sin1(in[20]), .sin2(in[21]), .sin3(in[22]), .sin4(in[23]),
                .sin1b(inb[20]), .sin2b(inb[21]), .sin3b(inb[22]), .sin4b(inb[23]),
                .sum1(sum[20]), .sum2(sum[21]), .sum3(sum[22]), .sum4(sum[23]));

sum4s_fa28 sum19_16 (.csel(w4_15_0), .sin1(in[16]), .sin2(in[17]), .sin3(in[18]), .sin4(in[19]),
                .sin1b(inb[16]), .sin2b(inb[17]), .sin3b(inb[18]), .sin4b(inb[19]),
                .sum1(sum[16]), .sum2(sum[17]), .sum3(sum[18]), .sum4(sum[19]));

sum4s_fa28 sum15_12 (.csel(w4_11_0), .sin1(in[12]), .sin2(in[13]), .sin3(in[14]), .sin4(in[15]),
                .sin1b(inb[12]), .sin2b(inb[13]), .sin3b(inb[14]), .sin4b(inb[15]),
                .sum1(sum[12]), .sum2(sum[13]), .sum3(sum[14]), .sum4(sum[15]));

sum4s_fa28 sum11_8 (.csel(w4_7_0), .sin1(in[8]), .sin2(in[9]), .sin3(in[10]), .sin4(in[11]),
                .sin1b(inb[8]), .sin2b(inb[9]), .sin3b(inb[10]), .sin4b(inb[11]),
                .sum1(sum[8]), .sum2(sum[9]), .sum3(sum[10]), .sum4(sum[11]));

sum4s_fa28 sum7_4 (.csel(w4_3_0), .sin1(in[4]), .sin2(in[5]), .sin3(in[6]), .sin4(in[7]),
                .sin1b(inb[4]), .sin2b(inb[5]), .sin3b(inb[6]), .sin4b(inb[7]),
                .sum1(sum[4]), .sum2(sum[5]), .sum3(sum[6]), .sum4(sum[7]));

sum4s_fa28 sum3_0 (.csel(cin), .sin1(in[0]), .sin2(in[1]), .sin3(in[2]), .sin4(in[3]),
                .sin1b(inb[0]), .sin2b(inb[1]), .sin3b(inb[2]), .sin4b(inb[3]),
                .sum1(sum[0]), .sum2(sum[1]), .sum3(sum[2]), .sum4(sum[3]));


assign cout = (~pi_l[27]) & g27_0;

endmodule


/* pgnx28 */
module pgnx28 (gen_l, pro_l, ain, bin);

output gen_l;
output pro_l;
input ain;
input bin;

assign gen_l = ~ (ain & bin);
assign pro_l = ~ (ain | bin);

endmodule


/* pgnl28 */
module pgnl28 (gen_l, pro_l, ain, bin, carryin);

output gen_l;
output pro_l;
input ain;
input bin;
input carryin;

assign gen_l = ~ ((ain & bin) | (carryin & (ain | bin)));
assign pro_l = ~ (ain | bin);

endmodule


/* pg2 stage */
module pg2_fa28 (g_u_d, p_u_d, g_l_in, p_l_in);

output g_u_d;                   // carry_generated.
output p_u_d;                   // carry_propgated. lower 1-bit
input  [1:0]  g_l_in;           // generate inputs.
input  [1:0]  p_l_in;           // propgate inputs. lower 1-bit

/* Ling modification used here */
assign g_u_d =  ~ (g_l_in[1] & g_l_in[0]);      // 2-bit pseudo generate.

assign p_u_d =  ~ (p_l_in[1] | p_l_in[0]);         // 2-bit pseudo propagate.

endmodule


/* g2 stage */
module g2_fa28 (g_u_d, g_l_in);

output g_u_d;                   // carry_generated.
input  [1:0]  g_l_in;           // generate inputs.

/* Ling modification used here */
assign g_u_d =  ~ (g_l_in[1] & g_l_in[0]);      // 2-bit pseudo generate.

endmodule


/* B1AOI stage */
module b1aoi_fa28 (ggrp_l, pgrp_l, gu_in, pu_in, gd_in, pd_in);

output ggrp_l;          // group generate.
output pgrp_l;          // group propgate. lower 1-bit
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.
input  pd_in;           // lower propgate input. lower 1-bit

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

assign pgrp_l =  ~ (pu_in & pd_in);              // group propagate. lower 1-bit

endmodule


/* G1AOI stage */
module g1aoi_fa28 (ggrp_l, gu_in, pu_in, gd_in);

output ggrp_l;          // group generate.
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

endmodule


/* B3AOI stage */
module b3aoi_fa28 (ggrp_l, pgrp_l, gu_in, pu_in, gd_in, pd_in);

output ggrp_l;          // group generate.
output pgrp_l;          // group propgate. lower 1-bit
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.
input  pd_in;           // lower propgate input. lower 1-bit

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

assign pgrp_l =  ~ (pu_in & pd_in);              // group propagate. lower 1-bit

endmodule


/* G3AOI stage */
module g3aoi_fa28 (ggrp_l, gu_in, pu_in, gd_in);

output ggrp_l;          // group generate.
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | (pu_in & gd_in));    // group generate.

endmodule



/* B2OAI stage */
module b2oai_fa28 (ggrp, pgrp, gu_in, pu_in, gd_in, pd_in);

output ggrp;            // group generate.
output pgrp;            // group propgate. lower 1-bit
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.
input  pd_in;           // lower propgate input. lower 1-bit

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & (pu_in | gd_in));     // group generate.

assign pgrp =  ~ (pu_in | pd_in);               // group propagate. lower 1-bit

endmodule


/* G2OAI stage */
module g2oai_fa28 (ggrp, gu_in, pu_in, gd_in);

output ggrp;            // group generate.
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & (pu_in | gd_in));     // group generate.

endmodule

/* G4OAI stage */
module g4oai_fa28 (ggrp, gu_in, pu_in, gd_in);

output ggrp;            // group generate.
input  gu_in;           // upper generate input.
input  pu_in;           // upper propgate input. lower 1-bit
input  gd_in;           // lower generate input.

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & (pu_in | gd_in));     // group generate.

endmodule


/* Sum stage logic. Carry-select approach is used */
module sum4s_fa28 (csel, sin1, sin2, sin3, sin4, sin1b, sin2b, sin3b, sin4b, sum1, sum2, sum3, sum4);

output sum1, sum2, sum3, sum4;          // sum outputs.
input  sin1, sin2, sin3, sin4;          // sel inputs assuming csel=1
input  sin1b, sin2b, sin3b, sin4b;      // sel_l inputs assuming csel=0
input  csel;                            // global carry input.

/* carry-select approach used here */

      assign sum1 = csel == 1 ? sin1 : sin1b;
      assign sum2 = csel == 1 ? sin2 : sin2b;
      assign sum3 = csel == 1 ? sin3 : sin3b;
      assign sum4 = csel == 1 ? sin4 : sin4b;

endmodule


module presum_fa28 (g1, g2, g3, g4, p0, p1, p2, p3, p4, s1, s2, s3, s4, s1b, s2b, s3b, s4b);

input g1, g2, g3, g4, p0, p1, p2, p3, p4;
output s1, s2, s3, s4;
output s1b, s2b, s3b, s4b;

      assign s1 = (p1 & (~g1)) ^ p0;
      assign s2 = (p2 & (~g2)) ^ (g1 | (p1 & p0));
      assign s3 = (p3 & (~g3)) ^ (g2 | ((g1 | (p1 & p0)) & p2));
      assign s4 = (p4 & (~g4)) ^ (g3 | ((g2 | ((g1 | (p1 & p0)) & p2)) & p3));
      assign s1b = p1 & (~g1);
      assign s2b = (p2 & (~g2)) ^ g1;
      assign s3b = (p3 & (~g3)) ^ (g2 | (g1 & p2));
      assign s4b = (p4 & (~g4)) ^ (g3 | (g2 | (g1 & p2)) & p3);
endmodule


// --13)  Left shifter, 63-bit input, 0~31 positions, output 32-bit --

module lsft31_63i_32o (lsf_out, hi, lo, lsa);  
  
output [31:0]  lsf_out;
input  [31:0]  hi;
input  [31:1]  lo;
input   [4:0]  lsa; 

/* Logic
assign lsf[62:0] = {hi[31:0],lo[31:1]} << lsa[4:0] ;
assign lsf_out[31:0] = lsf[62:31];
*/

// The following module has indentical functionality as above assignment.
// It should be used in circuit design. 
// Only lvl_0[46:16] portion is two loads to inputs and the other two portions
// has one loading to previous stage.
// If inverting mux provides better timing and area than non_inverting one,the 
// inverting type mux should be used, and a row of inverting output buffer 
// should be provided. 
// Total of 47+39+35+33+32 = 186 2:1 muxs.
// Implementation tips: lev_1 through lev_5 indicates 5-level of two_to_one mux 
// structure which can be implemented differently by using 4:1 or even 8:1 mux 
// if over all area and timing can be improved. Circuit group have the  
// flexibility to implemente it differently. Adequate buffering should be 
// provided on lsa pins, especially on rsa[4] and rsa[3] pins.

wire    [62:0]  lvl_0;  // level 0 wiring.
wire    [46:0]  lvl_1;  // level_1 47-bit 2:1 mux output
wire    [38:0]  lvl_2;  // level_2 39-bit 2:1 mux output
wire    [34:0]  lvl_3;  // level_3 35-bit 2:1 mux output
wire    [32:0]  lvl_4;  // level_4 33-bit 2:1 mux output
wire    [31:0]  lvl_5;  // level_5 32-bit 2:1 mux output
wire    [ 4:0]  mux_sel; // internal buffering;

assign mux_sel[4:0] = ~lsa[4:0] ; // inverting & buffering once for left shift.

// wiring lvl_0.
assign lvl_0[62:0] = {hi[31:0],lo[31:1]};
assign lvl_1 = ~((mux_sel[4]) ? (lvl_0[62:16]) : (lvl_0[46:0]) );
assign lvl_2 = ~((mux_sel[3]) ? (lvl_1[46: 8]) : (lvl_1[38:0]) );
assign lvl_3 = ~((mux_sel[2]) ? (lvl_2[38: 4]) : (lvl_2[34:0]) );
assign lvl_4 = ~((mux_sel[1]) ? (lvl_3[34: 2]) : (lvl_3[32:0]) );
assign lvl_5 = ~((mux_sel[0]) ? (lvl_4[32: 1]) : (lvl_4[31:0]) );
assign lsf_out[31:0] = ~lvl_5;

endmodule


//-14)Right shifter, 63-bit input, 0~31 positions, output 32-bit,with sticky --

module rsft31_63i_32o (rsf_out, gbit, sticky, nxstin, hi, lo, rsa, stin);  
  
output [31:0]  rsf_out;
output         gbit;    // 1 bit below LSB of result.
output         sticky;  // 2-bit below LSB 
output         nxstin;  // Or of GBIT and STICKY

input  [30:0]  hi;
input  [31:0]  lo;
input   [4:0]  rsa;
input          stin;    // Input from prevoius STICKY

assign   gbit = 1'b0;   // no connection for now.
assign nxstin = 1'b0;   // no connection for now.

/* Logic
assign rsf_out[31:0] = {hi[30:0],lo[31:0]} >> rsa[4:0] ;
assign sticky        = rsa[4]&(| lo[14:0])    |
                       rsa[3]&(| lvl_1[ 6:0]) |
                       rsa[2]&(| lvl_2[ 2:0]) |
                       rsa[1]&(| lvl_3[ 0:0]) |
                       rsa[0]&(         1'b0) | stin;          
assing gbit =   (rsa[0]) ? lvl_4[0] :
                (rsa[1]) ? lvl_3[1] :
                (rsa[2]) ? lvl_2[3] :
                (rsa[3]) ? lvl_1[7] :
                (rsa[4]) ?   lo[15] : 1'b0;
assign nxstin = gbit | sticky;
*/

// The following module has indentical functionality as above assignment.
// It should be used in circuit design. 
// Only lvl_0[46:16] portion is two loads to inputs and the other two portions
// has one loading to previous stage.
// If inverting mux provides better timing and area than non_inverting one, the 
// inverting type mux should be used, and a row of inverting output buffer 
// should be provided. 
// Total of 47+39+35+33+32 = 186 2:1 muxs.
// Total 186 x 8 = 1488 CU.

// Implementation tips: lev_1 through lev_5 indicates 5-level of two_to_one mux 
// structure which can be implemented differently by using 4:1 or even 8:1 mux 
// if over all area and timing can be improved. Circuit group have the  
// flexibility to implemente it differently. Adequate buffering should be 
// provided on rsa pins, especially on rsa[4] and rsa[3] pins.

wire    [62:0]  lvl_0;  // level 0 wiring.
wire    [46:0]  lvl_1;  // level_1 47-bit 2:1 mux output
wire    [38:0]  lvl_2;  // level_2 39-bit 2:1 mux output
wire    [34:0]  lvl_3;  // level_3 35-bit 2:1 mux output
wire    [32:0]  lvl_4;  // level_4 33-bit 2:1 mux output
wire    [31:0]  lvl_5;  // level_5 32-bit 2:1 mux output
wire    [ 4:0]  mux_sel; // internal buffering;
wire            sticky_1, sticky_2, sticky_3, sticky_4, sticky_5;
wire            sticky_even, sticky_odd;

assign mux_sel[4:0] = ~rsa[4:0] ; // inverting & buffering twice. or none

// wiring lvl_0.
assign lvl_0[62:0] = {hi[30:0],lo[31:0]};
assign lvl_1 = ~((~mux_sel[4]) ? (lvl_0[62:16]) : (lvl_0[46:0])) ;
assign lvl_2 = ~((~mux_sel[3]) ? (lvl_1[46: 8]) : (lvl_1[38:0])) ;
assign lvl_3 = ~((~mux_sel[2]) ? (lvl_2[38: 4]) : (lvl_2[34:0])) ;
assign lvl_4 = ~((~mux_sel[1]) ? (lvl_3[34: 2]) : (lvl_3[32:0])) ;
assign lvl_5 = ~((~mux_sel[0]) ? (lvl_4[32: 1]) : (lvl_4[31:0])) ;

assign rsf_out[31:0] = ~lvl_5;

/* sticky portion. Use even and odd path to speed up. */
assign sticky_1 =   | lvl_0[15:0] ;
assign sticky_2 = ~(& lvl_1[ 7:0]) ;    // lvl_1 is reversed
assign sticky_3 =   | lvl_2[ 3:0] ;
assign sticky_4 = ~(& lvl_3[ 1:0]) ;    // lvl_3 is reversed
assign sticky_5 =   | lvl_4[   0] ;

assign sticky_even = (~mux_sel[4])&sticky_1 | (~mux_sel[2])&sticky_3 |
                     (~mux_sel[0])&sticky_5 | stin ;                    // prev.stage.
assign sticky_odd  = (~mux_sel[3])&sticky_2 | (~mux_sel[1])&sticky_4 ;
assign sticky      = ~(!sticky_even & !sticky_odd) ; // nd2 <= nr2 + nr3 

endmodule


// ------------------- 15) 32-bit bit_wise comparator --------------------------
// ------------------- Kogge-Stone style -----------------------------------
// ------------------- a less than b only ----------------------------------

module cmp32_ks_lt (ai, bi, a_ltn_b);  
  
input  [31:0]  ai;
input  [31:0]  bi;
output         a_ltn_b;		// ai less_than bi.
 
/* Logic
assign a_ltn_b = ( ai[31:0]  < bi[31:0] ) ;
*/

// a_ltn_b portion below
wire    [31:0]  bi_invert;	// bit-wise invert output
wire    [31:0]  gi;	// bit-wise generate carry output
wire    [31:0]  pi;	// bit-wise propgate carry output

wire    p30_27, g31_28;	// 7th's group_pseudo_P* and G*
wire    p26_23, g27_24;	// 6th
wire    p22_19, g23_20;	// 5th
wire    p18_15, g19_16;	// 4th
wire    g15_12, g11_8, g7_4, g3_0; // 3~0th
wire 	p14_11, p10_7, p6_3, p2_0; // 3~0th

wire   p30_15, g31_16, g15_0;		// second level P* and G*.
wire   NC; 				// no connection wire.


assign bi_invert =  ~ bi ;
assign gi[31:1] = ai[31:1] & bi_invert[31:1] ;
assign pi[31:1] = ai[31:1] | bi_invert[31:1] ;
assign gi[0]    = ai[0] | bi_invert[0]; // insert c_in here.
assign pi[0]    = 1'b1;			// not used.

pg4bt_lt32 i_pg_31_28 ( 	.gs_3_0(g31_28),
			.ps_2_n1(p30_27),
			.g_in(gi[31:28]),
			.p_in(pi[30:28]),
			.pn_3(pi[27]));

pg4bt_lt32 i_pg_27_24 ( 	.gs_3_0(g27_24),
			.ps_2_n1(p26_23),
			.g_in(gi[27:24]),
			.p_in(pi[26:24]),
			.pn_3(pi[23]));

pg4bt_lt32 i_pg_23_20 ( 	.gs_3_0(g23_20),
			.ps_2_n1(p22_19),
			.g_in(gi[23:20]),
			.p_in(pi[22:20]),
			.pn_3(pi[19]));

pg4bt_lt32 i_pg_19_16 ( 	.gs_3_0(g19_16),
			.ps_2_n1(p18_15),
			.g_in(gi[19:16]),
			.p_in(pi[18:16]),
			.pn_3(pi[15]));

pg4bt_lt32 i_pg_15_12 ( 	.gs_3_0(g15_12),
			.ps_2_n1(p14_11),
			.g_in(gi[15:12]),
			.p_in(pi[14:12]),
			.pn_3(pi[11]));

pg4bt_lt32 i_pg_11_8  ( 	.gs_3_0(g11_8),
			.ps_2_n1(p10_7),
			.g_in(gi[11:8]),
			.p_in(pi[10:8]),
			.pn_3(pi[7]));

pg4bt_lt32 i_pg_7_4   ( 	.gs_3_0(g7_4),
			.ps_2_n1(p6_3),
			.g_in(gi[7:4]),
			.p_in(pi[6:4]),
			.pn_3(pi[3]));

pg4bt_lt32 i_pgs_3_0   ( 	.gs_3_0(g3_0),
			.ps_2_n1(p2_0),		
			.g_in(gi[3:0]),
			.p_in({pi[2:0]}),
			.pn_3(1'b1));

pg2nd_lt32 i_pg_31_16 ( 	.G_3_0(g31_16),
			.P_3_0(p30_15),
			.g_in({g31_28,g27_24,g23_20,g19_16}),
			.p_in({p30_27,p26_23,p22_19,p18_15}));

pg2nd_lt32 i_pg_15_0  ( 	.G_3_0(g15_0),
			.P_3_0(NC),		// .ps_2_n1(p14_0), no connec.
			.g_in({g15_12,g11_8,g7_4,g3_0}),
			.p_in({p14_11,p10_7,p6_3,p2_0}));		

assign a_ltn_b = ~(pi[31] & (g31_16 | p30_15&g15_0)) ;	// pg_last to Carry_out

endmodule

module pg4bt_lt32 (gs_3_0, ps_2_n1, g_in, p_in, pn_3);

output gs_3_0;			// carry_generated.
output ps_2_n1;			// carry_propgated. lower 1-bit
input  [3:0]  g_in;		// generate inputs.
input  [2:0]  p_in;		// propgate inputs. lower 1-bit
input         pn_3;		// next lower bit prop input.

/* or use this Brent-Kung stage, Ling's mods to save gates:*/
assign gs_3_0 =   g_in[3] 		// Pseudo Generate
		| g_in[2] 
		| p_in[2] & g_in[1] 
		| p_in[2] & p_in[1] & g_in[0] ;
assign ps_2_n1 =  p_in[2] & p_in[1] & p_in[0] & pn_3 ; // Pseudo Prop.


/* conventional approach uses much more gates 
assign G_3_0 = 	  gi[3] 		// conventional g.
		| pi[3] & gi[2] 
		| pi[3] & pi[2] & gi[1] 
		| pi[3] & pi[2] & pi[1] & gi[0] ;

assign P_3_0 =    pi[3] & pi[2] & pi[1] & pi[0] ; // all prop.
*/

endmodule

module pg2nd_lt32 (G_3_0, P_3_0, g_in, p_in);

output G_3_0;			// carry_generated.
output P_3_0;			// carry_propgated. lower 1-bit
input  [3:0]  g_in;		// generate inputs.
input  [3:0]  p_in;		// propgate inputs. lower 1-bit

/* conventional approach must be used at second level */
assign G_3_0 = 	  g_in[3] 		// conventional g.
		| p_in[3] & g_in[2] 
		| p_in[3] & p_in[2] & g_in[1] 
		| p_in[3] & p_in[2] & p_in[1] & g_in[0] ;

assign P_3_0 =    p_in[3] & p_in[2] & p_in[1] & p_in[0] ; // all prop.

endmodule

/*******************************************************************************
 *
 * 16) Module:	cmp_legs_32
 * 
 * This module contains the 32-bit comparator that can handle both signed
 * and unsigned comparisons.
 * 
 ******************************************************************************/
module cmp_legs_32(gt,
	      eq,
	      lt,
	      in1,
	      in2,
	      sign);
   input [31:0]		in1;	// Operand on the LHS to be compared
   input [31:0]		in2;	// Operand on the RHS to be compared
   input 		sign;	// 0: unsigned comparison, 1: signed comparison
   output 		gt;	// in1 >  in2
   output 		eq;	// in1 == in2
   output 		lt;	// in1 <  in2

wire msel, lt1, eq1, gt1 ;
/*
   reg 			cmp_gt;	// Intermediate result, in1 > in2
   reg 			cmp_eq;	// Intermediate result, in1 == in2
   reg 			cmp_lt;	// Intermediate result, in1 < in2
   reg [31:0] 		tmp1;	// 2's complement of in1
   reg [31:0] 		tmp2;	// 2's complement of in2

   always @(in1 or in2 or sign)
      begin
	 if (sign == 0)
	    begin
	       cmp_gt = (in1 > in2);
	       cmp_eq = (in1 == in2);
	       cmp_lt = (in1 < in2);
	    end // if (sign == 0)
	 else
	    begin
	       case ({in1[31], in2[31]})
		 2'b00:
		    begin
		       cmp_gt = (in1 > in2);
		       cmp_eq = (in1 == in2);
		       cmp_lt = (in1 < in2);
		    end // case: 2'b00
		 2'b01:
		    begin
		       cmp_gt = 1;
		       cmp_eq = 0;
		       cmp_lt = 0;
		    end // case: 2'b01
		 2'b10:
		    begin
		       cmp_gt = 0;
		       cmp_eq = 0;
		       cmp_lt = 1;
		    end // case: 2'b10
		 2'b11:
		    begin
		       tmp1 = (~in1) + 1;
		       tmp2 = (~in2) + 1;
		       cmp_gt = (tmp1 < tmp2);
		       cmp_eq = (in1 == in2);
		       cmp_lt = (tmp1 > tmp2);
		    end // case: 2'b11
	       endcase // case({in1[31], in2[31]})
	    end // else: !if(sign == 0)
      end // always @ (in1 or in2 or sign)

   assign gt = cmp_gt;
   assign eq = cmp_eq;
   assign lt = cmp_lt;

*/

assign msel = ( ~sign | ~(in1[31] ^ in2[31]) );

cmp3s_32_leg comp_32_leg (.ai(in1), .bi(in2), .a_ltn_b(lt1), .a_eql_b(eq1), .a_gtn_b(gt1)
			);

mj_h_mux2_3    res_mux ( .mx_out({lt,eq,gt}), 
		         .in0({in1[31],1'b0,in2[31]}), 
		         .in1({lt1,eq1,gt1}), 
		         .sel(msel),
		         .sel_l(~msel)
		  );

endmodule // cmp_32


/*******************************************************************************
 *
 * 17) Module:	shift_64
 * 
 * This module contains the 64-bit shifter that handles:
 * 1. Left shift
 * 2. Right logical shift
 * 3. Right arithmetic shift
 * 
 ******************************************************************************/
module shift_64(msw_in,
		lsw_in,
		count,
		dir,
		arith,
		word_sel,
		out);
   input [31:0]		msw_in;		// MSW of the operand, or [63:32]
   input [31:0]		lsw_in;		// LSW of the operand, or [31:0]
   input [5:0] 		count;		// 6-bit shift count
   input 		dir;		// 0: shift left, 1: shift right
   input 		arith;		// 0: logical, 1: arithmetic
   input 		word_sel;	// 0: LSW, 1: MSW
   output [31:0] 	out;		// 32-bit result
   wire 		sgn;
   wire[5:0]		mux_sel;

/*

   reg [127:0] 		src_bus;	// 128-bit source bus
   reg [127:0] 		dst_bus;	// 128-bit destination bus
   reg [63:0] 		result;		// 64-bit output of the shifter

   // This is just a behavioral implementation.
   always @(msw_in or lsw_in or count or dir or arith or word_sel)
      begin
	 if (dir == 0)
	    begin
	       src_bus = {msw_in, lsw_in, 64'h0};
	       dst_bus = src_bus << count;
	       result  = dst_bus[127:64];
	    end // if (dir == 0)
	 else
	    begin
	       if (arith == 1)
		  src_bus[127:64] = {64{msw_in[31]}};
	       else
		  src_bus[127:64] = 64'h0;
	       src_bus[63:0] = {msw_in, lsw_in};
	       dst_bus = src_bus >> count;
	       result  = dst_bus[63:0];
	    end // else: !if(dir == 0)
      end // always @ (msw_in or lsw_in or count or dir or arith or word_sel)

*/

wire    [63:0]  lev_0;  // level_0 32-bit 2:1 mux output
wire    [63:0]  lev_1;  // level_1 32-bit 2:1 mux output
wire    [63:0]  lev_2;  // level_2 32-bit 2:1 mux output
wire    [63:0]  lev_3;  // level_3 32-bit 2:1 mux output
wire    [63:0]  lev_4;  // level_4 32-bit 2:1 mux output
wire    [63:0]  lev_5;  // level_5 32-bit 2:1 mux output
wire    [63:0]  lev_6;
wire    [63:0]  result;  // level_5 32-bit 2:1 mux output
wire    [63:0]  sft_in,rev_sft_in,rev_lev_6;


assign sgn = dir & arith & msw_in[31];
assign sft_in = {msw_in,lsw_in};
assign mux_sel = ~count;

mx21_64_l  mx_0(.mx_out(lev_0), .sel(~dir), .in0(sft_in[63:0]),
.in1(rev_sft_in[63:0]) );

assign rev_sft_in = {
sft_in[0],sft_in[1],sft_in[2],sft_in[3],sft_in[4],sft_in[5],sft_in[6],sft_in[7],
sft_in[8],sft_in[9],sft_in[10],sft_in[11],sft_in[12],sft_in[13],sft_in[14],sft_in[15],
sft_in[16], sft_in[17], sft_in[18], sft_in[19], sft_in[20], sft_in[21], sft_in[22], sft_in[23], sft_in[24], sft_in[25], sft_in[26],sft_in[27], sft_in[28], sft_in[29],
sft_in[30], sft_in[31], sft_in[32] , sft_in[33], sft_in[34] , sft_in[35], sft_in[36], sft_in[37], sft_in[38], sft_in[39],sft_in[40], sft_in[41], sft_in[42], sft_in[43],
sft_in[44], sft_in[45], sft_in[46], sft_in[47], sft_in[48], sft_in[49],
sft_in[50], sft_in[51], sft_in[52], sft_in[53], sft_in[54], sft_in[55], sft_in[56], sft_in[57], sft_in[58], sft_in[59],sft_in[60], sft_in[61], sft_in[62], sft_in[63] }  ;


mx21_64_l  mx_1 (.mx_out(lev_1), .sel(mux_sel[5]), .in0({{32{~sgn}},lev_0[63:32]}),
.in1(lev_0[63:0]) );
mx21_64_l  mx_2 (.mx_out(lev_2), .sel(mux_sel[4]), .in0({{16{sgn}},lev_1[63:16]}),
.in1(lev_1[63:0]) );
mx21_64_l  mx_3(.mx_out(lev_3), .sel(mux_sel[3]), .in0({{ 8{~sgn}},lev_2[63: 8]}),
.in1(lev_2[63:0]) );
mx21_64_l mx_4(.mx_out(lev_4), .sel(mux_sel[2]), .in0({{ 4{sgn}},lev_3[63: 4]}),
.in1(lev_3[63:0]) );
mx21_64_l mx_5(.mx_out(lev_5), .sel(mux_sel[1]), .in0({{2{~sgn}},lev_4[63:2]}),
.in1(lev_4[63:0]) );
mx21_64_l mx_6(.mx_out(lev_6), .sel(mux_sel[0]), .in0({{1{sgn}},lev_5[63:1]}),
.in1(lev_5[63:0]) );

mx21_64_l mx_7(.mx_out(result), .sel(~dir), .in0(lev_6[63:0]),
.in1(rev_lev_6[63:0]) );


assign rev_lev_6 =   {  lev_6[0],lev_6[1],lev_6[2],lev_6[3],lev_6[4],lev_6[5],lev_6[6],lev_6[7],
lev_6[8],lev_6[9],lev_6[10],lev_6[11],lev_6[12],lev_6[13],lev_6[14],lev_6[15],
lev_6[16],lev_6[17],lev_6[18],lev_6[19],lev_6[20],lev_6[21],lev_6[22],lev_6[23],
lev_6[24],lev_6[25],lev_6[26],lev_6[27],lev_6[28],lev_6[29],lev_6[30],lev_6[31],
lev_6[32],lev_6[33],lev_6[34],lev_6[35],lev_6[36],lev_6[37],lev_6[38],lev_6[39],
lev_6[40],lev_6[41],lev_6[42],lev_6[43],lev_6[44],lev_6[45],lev_6[46],lev_6[47],
lev_6[48],lev_6[49],lev_6[50],lev_6[51],lev_6[52],lev_6[53],lev_6[54],lev_6[55],
lev_6[56],lev_6[57],lev_6[58],lev_6[59],lev_6[60],lev_6[61],lev_6[62],lev_6[63]  };


assign out = (word_sel == 1'b0) ? result[31:0] : result[63:32];

endmodule // shift_64

module mx21_64_l (mx_out, sel, in0, in1);

output [63:0] mx_out;
input         sel;
input  [63:0] in0 , in1 ;
wire   [63:0] sel_not, mux_sel;
assign sel_not = {64{~sel}};
assign mux_sel = {64{ sel}};
assign mx_out  = ~(mux_sel & in1 | sel_not & in0) ;

endmodule

// ------------------- 18) 8-bit adder --------------------------

module fa8 (a, b, c, sum, cout);  
  
input  [7:0]  a;
input  [7:0]  b;
output  [7:0]  sum;

input		c;		// carry in
output		cout;		// carry out


// -------------------- carry tree level 1 ----------------------------
// produce the generate for the least significant bit (sch: glsbs)

wire g0_l = !(((a[0] | b[0]) & c) | (a[0] &b[0]));

// produce the propagates and generates for the other bits

wire gen0_l, p0_l, g1_l, p1_l, g2_l, p2_l, g3_l, p3_l, g4_l, p4_l, 
	g5_l, p5_l, g6_l, p6_l, g7_l, p7_l;

pgnx_fa8 pgnx0 (a[0], b[0], gen0_l, p0_l);	// gen0_l is used only for sum[0] calc.
pgnx_fa8 pgnx1 (a[1], b[1], g1_l, p1_l);
pgnx_fa8 pgnx2 (a[2], b[2], g2_l, p2_l);
pgnx_fa8 pgnx3 (a[3], b[3], g3_l, p3_l);
pgnx_fa8 pgnx4 (a[4], b[4], g4_l, p4_l);
pgnx_fa8 pgnx5 (a[5], b[5], g5_l, p5_l);
pgnx_fa8 pgnx6 (a[6], b[6], g6_l, p6_l);
pgnx_fa8 pgnx7 (a[7], b[7], g7_l, p7_l);


// -------------------- carry tree level 2 ----------------------------
// produce group propagates/generates for sets of 2 bits (sch: pg2l)
// this stage contains the ling modification, which simplifies
//      this stage, but the outputs are Pseudo-generates, which
//      later need to be recovered by anding.

wire g0to1, g1to2, g2to3, g4to5, g6to7, p0to1, p1to2, p3to4, p5to6;

pg2lg_fa8 pg2lg (	.gd_l(g0_l), 
		.gu_l(g1_l), 
		.g(g0to1));	//assign g0to1 =  !(g0_l & g1_l);

pg2l_fa8 p2gl0 (	.gd_l(g1_l), 
		.gu_l(g2_l), 
		.pd_l(p0_l), 
		.pu_l(p1_l),
		.g(g1to2),	//assign g1to2 =  !(g1_l & g2_l);
		.p(p0to1));	//assign p0to1 =  !(p0_l | p1_l);

pg2l_fa8 p2gl1 (	.gd_l(g2_l), 
		.gu_l(g3_l), 
		.pd_l(p1_l), 
		.pu_l(p2_l),
		.g(g2to3),	//assign g2to3 =  !(g2_l & g3_l);
		.p(p1to2));	//assign p1to2 =  !(p1_l | p2_l);

pg2l_fa8 p2gl2 (	.gd_l(g4_l), 
		.gu_l(g5_l), 
		.pd_l(p3_l), 
		.pu_l(p4_l),
		.g(g4to5),	//assign g4to5 =  !(g4_l & g5_l);
		.p(p3to4));	//assign p3to4 =  !(p3_l | p4_l);


pg2l_fa8 p2gl3 (	.gd_l(g6_l), 
		.gu_l(g7_l), 
		.pd_l(p5_l), 
		.pu_l(p6_l),
		.g(g6to7),	
		.p(p5to6));	





// -------------------- carry tree level 3 ----------------------------
// use aoi to make group generates

wire g0to2_l, g0to3_l, g2to5_l, g4to7_l, p1to4_l, p3to6_l;

aoig_fa8 aoig0 (	.gd(~g0_l), 
		.gu(g1to2), 
		.pu(p0to1), 
		.g_l(g0to2_l));		//assign g0to2_l = !((!g0_l & p0to1) | g1to2);

aoig_fa8 aoig1 (	.gd(g0to1), 
		.gu(g2to3), 
		.pu(p1to2), 
		.g_l(g0to3_l));		//assign g0to3_l = !((g0to1 & p1to2) | g2to3);

baoi_fa8 baoi0 (	.gd(g2to3), 
		.gu(g4to5), 
		.pd(p1to2), 
		.pu(p3to4),
		.g_l(g2to5_l),		//assign g2to5_l = !((g2to3 & p3to4) | g4to5);
		.p_l(p1to4_l));		//assign p1to4_l = !(p1to2 & p3to4);	

baoi_fa8 baoi1 (	.gd(g4to5), 
		.gu(g6to7), 
		.pd(p3to4), 
		.pu(p5to6),
		.g_l(g4to7_l),		
		.p_l(p3to6_l));		



// -------------------- carry tree level 4 ----------------------------
// use oai's since the inputs are active-low.
wire g0to5, g0to7;

oaig_fa8 oaig0 (	.gd_l(~g0to1), 
		.gu_l(g2to5_l), 
		.pu_l(p1to4_l), 
		.g(g0to5));   		//assign g0to5 = !((!g0to1 | p1to4_l) & g2to5_l);

oaig_fa8 oaig1 (	.gd_l(g0to3_l), 
		.gu_l(g4to7_l), 
		.pu_l(p3to6_l), 
		.g(g0to7));


// -------------------- sum, and cout ----------------------------

assign cout = g0to7 & !p7_l;  // recover cout by anding p7 with the pseudo-generate

wire [7:0] suma, sumb;            // local sums before carry select mux

sum2_fa8 sum0to1 (.g1(~gen0_l), .g2(~g1_l),
                .p0(1'b1), .p1(~p0_l), .p2(~p1_l),
                .sum1a(suma[0]), .sum2a(suma[1]),
                .sum1b(sumb[0]), .sum2b(sumb[1]));
sum2_fa8 sum2to3 (.g1(~g2_l), .g2(~g3_l),
                .p0(~p1_l), .p1(~p2_l), .p2(~p3_l),
                .sum1a(suma[2]), .sum2a(suma[3]),
                .sum1b(sumb[2]), .sum2b(sumb[3]));
sum2_fa8 sum4to5 (.g1(~g4_l), .g2(~g5_l),
                .p0(~p3_l), .p1(~p4_l), .p2(~p5_l),
                .sum1a(suma[4]), .sum2a(suma[5]),
                .sum1b(sumb[4]), .sum2b(sumb[5]));
sum2_fa8 sum6to7 (.g1(~g6_l), .g2(~g7_l),
                .p0(~p5_l), .p1(~p6_l), .p2(~p7_l),
                .sum1a(suma[6]), .sum2a(suma[7]),
                .sum1b(sumb[6]), .sum2b(sumb[7]));


/**********  mux to select sum using G*  signals from carry tree *****/

selsum2_fa8 selsum0to1 (  .sum1a(suma[0]), .sum2a(suma[1]),
		      .sum1b(sumb[0]), .sum2b(sumb[1]),
		      .sel(c), 
		      .sum1(sum[0]), .sum2(sum[1]));
selsum2_fa8 selsum2to3 (  .sum1a(suma[2]), .sum2a(suma[3]),
		      .sum1b(sumb[2]), .sum2b(sumb[3]),
		      .sel(g0to1), 
		      .sum1(sum[2]), .sum2(sum[3]));
selsum2_fa8 selsum4to5 (  .sum1a(suma[4]), .sum2a(suma[5]),
		      .sum1b(sumb[4]), .sum2b(sumb[5]),
		      .sel(~g0to3_l), 
		      .sum1(sum[4]), .sum2(sum[5]));
selsum2_fa8 selsum6to7 (  .sum1a(suma[6]), .sum2a(suma[7]),
		      .sum1b(sumb[6]), .sum2b(sumb[7]),
		      .sel(g0to5), 
		      .sum1(sum[6]), .sum2(sum[7]));
endmodule




// -------------------- selsum2 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selsum2_fa8 (sel, sum1, sum2,
	     sum1a, sum2a,
	     sum1b, sum2b);

input sum1a, sum2a,
	sum1b, sum2b, sel;
output sum1, sum2;
wire sum1, sum2;

assign sum1 = sel ? sum1a : sum1b;
assign sum2 = sel ? sum2a : sum2b;

endmodule


// -------------------- sum  ----------------------------
// we need to recover the real gernerates
//       after the ling modification used in level 2.
// we also are replacing the a,b with p,g to reduce loading
//       of the a,b inputs.  (a ^ b = p & !g)
// send out two sets of sums to be selected with mux at last stage

module sum2_fa8 (g1, g2, p0, p1, p2, 
	     sum1a, sum2a,
	     sum1b, sum2b);

output sum1a, sum2a,
	sum1b, sum2b;	// sum outputs.
input  g1, g2;  		// individual generate inputs.
input  p0, p1, p2;  		// individual propagate inputs.
//input  G;    		        	// global carry input. (pseudo-generate)
wire	sum1a, sum2a,
	sum1b, sum2b;

assign      sum1a = (p1 & (~g1)) ^ p0;
assign      sum2a = (p2 & (~g2)) ^ (g1 | (p1 & p0));
assign      sum1b = p1 & (~g1);
assign      sum2b = (p2 & (~g2)) ^ g1;



endmodule



// -------------------- pgnx ----------------------------
module pgnx_fa8 (a, b, g_l, p_l); // level 1 propagate and generate signals

input a, b;
output g_l, p_l;

assign g_l = !(a & b);	//nand to make initial generate
assign p_l = !(a | b);	//nor to make initial propagate

endmodule


// -------------------- pg2lg ----------------------------
// ling modification stage, generate only

module pg2lg_fa8 (gd_l, gu_l, g); 

input gd_l, gu_l;
output g;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate

endmodule


// -------------------- pg2l ----------------------------
// ling modification stage, psuedo group generate and propagate

module pg2l_fa8 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pd_l, pu_l;
output g, p;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate
assign p = !(pd_l | pu_l);	//nor to make pseudo generate

endmodule


// -------------------- aoig ----------------------------
// aoi for carry tree generates

module aoig_fa8 (gd, gu, pu, g_l); 

input gd, gu, pu;
output g_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate

endmodule

// -------------------- oaig ----------------------------
// aoi for carry tree generates

module oaig_fa8 (gd_l, gu_l, pu_l, g); 

input gd_l, gu_l, pu_l;
output g;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate

endmodule

// -------------------- baoi ----------------------------
// aoi for carry tree generates + logic for propagate

module baoi_fa8 (gd, gu, pd, pu, g_l, p_l); 

input gd, gu, pd, pu;
output g_l, p_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate
assign p_l = ~(pd & pu); // nand to make group prop

endmodule


// ------------------- 19) 10-bit adder --------------------------

module fa10 (a, b, c, sum, cout);  
  
input  [9:0]  a;
input  [9:0]  b;
output  [9:0]  sum;

input		c;		// carry in
output		cout;		// carry out


// -------------------- carry tree level 1 ----------------------------
// produce the generate for the least significant bit (sch: glsbs)

wire g0_l = !(((a[0] | b[0]) & c) | (a[0] &b[0]));

// produce the propagates and generates for the other bits

wire gen0_l, p0_l, g1_l, p1_l, g2_l, p2_l, g3_l, p3_l, g4_l, p4_l, 
	g5_l, p5_l, g6_l, p6_l, g7_l, p7_l, g8_l, p8_l, g9_l, p9_l;

pgnx_fa10 pgnx0 (a[0], b[0], gen0_l, p0_l);	// gen0_l is used only for sum[0] calc.
pgnx_fa10 pgnx1 (a[1], b[1], g1_l, p1_l);
pgnx_fa10 pgnx2 (a[2], b[2], g2_l, p2_l);
pgnx_fa10 pgnx3 (a[3], b[3], g3_l, p3_l);
pgnx_fa10 pgnx4 (a[4], b[4], g4_l, p4_l);
pgnx_fa10 pgnx5 (a[5], b[5], g5_l, p5_l);
pgnx_fa10 pgnx6 (a[6], b[6], g6_l, p6_l);
pgnx_fa10 pgnx7 (a[7], b[7], g7_l, p7_l);
pgnx_fa10 pgnx8 (a[8], b[8], g8_l, p8_l);
pgnx_fa10 pgnx9 (a[9], b[9], g9_l, p9_l);


// -------------------- carry tree level 2 ----------------------------
// produce group propagates/generates for sets of 2 bits (sch: pg2l)
// this stage contains the ling modification, which simplifies
//      this stage, but the outputs are Pseudo-generates, which
//      later need to be recovered by anding.

wire g0to1, g1to2, g2to3, g4to5, g6to7, g8to9, p0to1, p1to2, p3to4, 
		p5to6, p7to8;

pg2lg_fa10 pg2lg (	.gd_l(g0_l), 
		.gu_l(g1_l), 
		.g(g0to1));	//assign g0to1 =  !(g0_l & g1_l);

pg2l_fa10 p2gl0 (	.gd_l(g1_l), 
		.gu_l(g2_l), 
		.pd_l(p0_l), 
		.pu_l(p1_l),
		.g(g1to2),	//assign g1to2 =  !(g1_l & g2_l);
		.p(p0to1));	//assign p0to1 =  !(p0_l | p1_l);

pg2l_fa10 p2gl1 (	.gd_l(g2_l), 
		.gu_l(g3_l), 
		.pd_l(p1_l), 
		.pu_l(p2_l),
		.g(g2to3),	//assign g2to3 =  !(g2_l & g3_l);
		.p(p1to2));	//assign p1to2 =  !(p1_l | p2_l);

pg2l_fa10 p2gl2 (	.gd_l(g4_l), 
		.gu_l(g5_l), 
		.pd_l(p3_l), 
		.pu_l(p4_l),
		.g(g4to5),	//assign g4to5 =  !(g4_l & g5_l);
		.p(p3to4));	//assign p3to4 =  !(p3_l | p4_l);


pg2l_fa10 p2gl3 (	.gd_l(g6_l), 
		.gu_l(g7_l), 
		.pd_l(p5_l), 
		.pu_l(p6_l),
		.g(g6to7),	
		.p(p5to6));	


pg2l_fa10 p2gl4 (	.gd_l(g8_l), 
		.gu_l(g9_l), 
		.pd_l(p7_l), 
		.pu_l(p8_l),
		.g(g8to9),	
		.p(p7to8));



// -------------------- carry tree level 3 ----------------------------
// use aoi to make group generates

wire g0to3_l, g2to5_l, g4to7_l, g6to9_l, p1to4_l, p3to6_l, p5to8_l;

aoig_fa10 aoig1 (	.gd(g0to1), 
		.gu(g2to3), 
		.pu(p1to2), 
		.g_l(g0to3_l));		//assign g0to3_l = !((g0to1 & p1to2) | g2to3);

baoi_fa10 baoi0 (	.gd(g2to3), 
		.gu(g4to5), 
		.pd(p1to2), 
		.pu(p3to4),
		.g_l(g2to5_l),		//assign g2to5_l = !((g2to3 & p3to4) | g4to5);
		.p_l(p1to4_l));		//assign p1to4_l = !(p1to2 & p3to4);	

baoi_fa10 baoi1 (	.gd(g4to5), 
		.gu(g6to7), 
		.pd(p3to4), 
		.pu(p5to6),
		.g_l(g4to7_l),		
		.p_l(p3to6_l));	

baoi_fa10 baoi2 (	.gd(g6to7), 
		.gu(g8to9), 
		.pd(p5to6), 
		.pu(p7to8),
		.g_l(g6to9_l),		
		.p_l(p5to8_l));		



// -------------------- carry tree level 4 ----------------------------
// use oai's since the inputs are active-low.
wire g0to5, g0to7, g2to9, p1to8;

oaig_fa10 oaig0 (	.gd_l(~g0to1), 
		.gu_l(g2to5_l), 
		.pu_l(p1to4_l), 
		.g(g0to5));   		//assign g0to5 = !((!g0to1 | p1to4_l) & g2to5_l);

oaig_fa10 oaig1 (	.gd_l(g0to3_l), 
		.gu_l(g4to7_l), 
		.pu_l(p3to6_l), 
		.g(g0to7));

boai_fa10 boai0 (	.gd_l(g2to5_l), 
		.gu_l(g6to9_l), 
		.pd_l(p1to4_l), 
		.pu_l(p5to8_l),
		.g(g2to9),		
		.p(p1to8));

// -------------------- carry tree level 5 ----------------------------
// use aoi's to make group generates
wire g0to9_l;

aoig_fa10 aoiglev5 (	.gd(g0to1), 
		.gu(g2to9), 
		.pu(p1to8), 
		.g_l(g0to9_l));


// -------------------- sum, and cout ----------------------------

assign cout = !g0to9_l & !p9_l;  // recover cout by anding p9 with the pseudo-generate

wire [9:0] suma, sumb;            // local sums before carry select mux

sum2_fa10 sum0to1 (.g1(~gen0_l), .g2(~g1_l),
                .p0(1'b1), .p1(~p0_l), .p2(~p1_l),
                .sum1a(suma[0]), .sum2a(suma[1]),
                .sum1b(sumb[0]), .sum2b(sumb[1]));
sum2_fa10 sum2to3 (.g1(~g2_l), .g2(~g3_l),
                .p0(~p1_l), .p1(~p2_l), .p2(~p3_l),
                .sum1a(suma[2]), .sum2a(suma[3]),
                .sum1b(sumb[2]), .sum2b(sumb[3]));
sum2_fa10 sum4to5 (.g1(~g4_l), .g2(~g5_l),
                .p0(~p3_l), .p1(~p4_l), .p2(~p5_l),
                .sum1a(suma[4]), .sum2a(suma[5]),
                .sum1b(sumb[4]), .sum2b(sumb[5]));
sum2_fa10 sum6to7 (.g1(~g6_l), .g2(~g7_l),
                .p0(~p5_l), .p1(~p6_l), .p2(~p7_l),
                .sum1a(suma[6]), .sum2a(suma[7]),
                .sum1b(sumb[6]), .sum2b(sumb[7]));
sum2_fa10 sum8to9 (.g1(~g8_l), .g2(~g9_l),
                .p0(~p7_l), .p1(~p8_l), .p2(~p9_l),
                .sum1a(suma[8]), .sum2a(suma[9]),
                .sum1b(sumb[8]), .sum2b(sumb[9]));


/**********  mux to select sum using G*  signals from carry tree *****/

selsum2_fa10 selsum0to1 (  .sum1a(suma[0]), .sum2a(suma[1]),
		      .sum1b(sumb[0]), .sum2b(sumb[1]),
		      .sel(c), 
		      .sum1(sum[0]), .sum2(sum[1]));
selsum2_fa10 selsum2to3 (  .sum1a(suma[2]), .sum2a(suma[3]),
		      .sum1b(sumb[2]), .sum2b(sumb[3]),
		      .sel(g0to1), 
		      .sum1(sum[2]), .sum2(sum[3]));
selsum2_fa10 selsum4to5 (  .sum1a(suma[4]), .sum2a(suma[5]),
		      .sum1b(sumb[4]), .sum2b(sumb[5]),
		      .sel(~g0to3_l), 
		      .sum1(sum[4]), .sum2(sum[5]));
selsum2_fa10 selsum6to7 (  .sum1a(suma[6]), .sum2a(suma[7]),
		      .sum1b(sumb[6]), .sum2b(sumb[7]),
		      .sel(g0to5), 
		      .sum1(sum[6]), .sum2(sum[7]));
selsum2_fa10 selsum8to9 (  .sum1a(suma[8]), .sum2a(suma[9]),
		      .sum1b(sumb[8]), .sum2b(sumb[9]),
		      .sel(g0to7), 
		      .sum1(sum[8]), .sum2(sum[9]));
endmodule




// -------------------- selsum2 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selsum2_fa10 (sel, sum1, sum2,
	     sum1a, sum2a,
	     sum1b, sum2b);

input sum1a, sum2a,
	sum1b, sum2b, sel;
output sum1, sum2;
wire sum1, sum2;

assign sum1 = sel ? sum1a : sum1b;
assign sum2 = sel ? sum2a : sum2b;

endmodule


// -------------------- sum  ----------------------------
// we need to recover the real gernerates
//       after the ling modification used in level 2.
// we also are replacing the a,b with p,g to reduce loading
//       of the a,b inputs.  (a ^ b = p & !g)
// send out two sets of sums to be selected with mux at last stage

module sum2_fa10 (g1, g2, p0, p1, p2, 
	     sum1a, sum2a,
	     sum1b, sum2b);

output sum1a, sum2a,
	sum1b, sum2b;	// sum outputs.
input  g1, g2;  		// individual generate inputs.
input  p0, p1, p2;  		// individual propagate inputs.
//input  G;    		        	// global carry input. (pseudo-generate)
wire	sum1a, sum2a,
	sum1b, sum2b;

assign      sum1a = (p1 & (~g1)) ^ p0;
assign      sum2a = (p2 & (~g2)) ^ (g1 | (p1 & p0));
assign      sum1b = p1 & (~g1);
assign      sum2b = (p2 & (~g2)) ^ g1;



endmodule



// -------------------- pgnx ----------------------------
module pgnx_fa10 (a, b, g_l, p_l); // level 1 propagate and generate signals

input a, b;
output g_l, p_l;

assign g_l = !(a & b);	//nand to make initial generate
assign p_l = !(a | b);	//nor to make initial propagate

endmodule


// -------------------- pg2lg ----------------------------
// ling modification stage, generate only

module pg2lg_fa10 (gd_l, gu_l, g); 

input gd_l, gu_l;
output g;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate

endmodule


// -------------------- pg2l ----------------------------
// ling modification stage, psuedo group generate and propagate

module pg2l_fa10 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pd_l, pu_l;
output g, p;

assign g = !(gd_l & gu_l);	//nand to make pseudo generate
assign p = !(pd_l | pu_l);	//nor to make pseudo generate

endmodule


// -------------------- aoig ----------------------------
// aoi for carry tree generates

module aoig_fa10 (gd, gu, pu, g_l); 

input gd, gu, pu;
output g_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate

endmodule

// -------------------- oaig ----------------------------
// aoi for carry tree generates

module oaig_fa10 (gd_l, gu_l, pu_l, g); 

input gd_l, gu_l, pu_l;
output g;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate

endmodule

// -------------------- baoi ----------------------------
// aoi for carry tree generates + logic for propagate

module baoi_fa10 (gd, gu, pd, pu, g_l, p_l); 

input gd, gu, pd, pu;
output g_l, p_l;

assign g_l = ~((gd & pu) | gu);	//aoi to make group generate
assign p_l = ~(pd & pu); // nand to make group prop

endmodule


// -------------------- boai ----------------------------
// aoi for carry tree generates

module boai_fa10 (gd_l, gu_l, pd_l, pu_l, g, p); 

input gd_l, gu_l, pu_l, pd_l;
output g, p;

assign g = ~((gd_l | pu_l) & gu_l);	//aoi to make group generate
assign p = ~(pu_l | pd_l);  // nor to make group prop

endmodule




// -------------------20) 6-bit decrementer --------------------------

module dec6 (data, sum);  
  
input  [5:0]  data;
output  [5:0]  sum;

wire p0, p0to1, p0to2, p0to3, p0to4;

assign p0    = data[0];
assign p0to1 = data[0] | data[1];
assign p0to2 = data[0] | data[1] | data[2];
assign p0to3 = data[0] | data[1] | data[2] | data[3];
assign p0to4 = data[0] | data[1] | data[2] | data[3] | data[4];


assign sum[0] = ~data[0];
assign sum[1] = ~p0    ? ~data[1] : data[1];
assign sum[2] = ~p0to1 ? ~data[2] : data[2];
assign sum[3] = ~p0to2 ? ~data[3] : data[3];
assign sum[4] = ~p0to3 ? ~data[4] : data[4];
assign sum[5] = ~p0to4 ? ~data[5] : data[5];

endmodule


// ------------------- 21) mj_s_dcd8to256 --------------------------

module mj_s_dcd8to256 (data, decodeout);  
  
input  [7:0]  data;
output  [255:0]  decodeout;


wire [15:0] sel, bottom; 
wire [255:0] decodeout_l;

// decode top order bits

wire [7:0] data_l = ~data;

mj_s_dcd4to16 decodeupper(	.data(data[7:4]),
				.data_l(data_l[7:4]),
				.decodeout_l(sel[15:0]));

// decode lower order bits
 
mj_s_dcd4to16 decodelower(	.data(data[3:0]),
				.data_l(data_l[3:0]),
				.decodeout_l(bottom[15:0]));

// now use the top order bits to select the proper lower order bits

finalsel finalsel15(		.sel(~sel[15]),
				.sel2(~sel[15]),
				.data(~bottom[15:0]),
				.out(decodeout_l[255:240]));

finalsel finalsel14(		.sel(~sel[14]),
				.sel2(~sel[14]),
				.data(~bottom[15:0]),
				.out(decodeout_l[239:224]));

finalsel finalsel13(		.sel(~sel[13]),
				.sel2(~sel[13]),
				.data(~bottom[15:0]),
				.out(decodeout_l[223:208]));

finalsel finalsel12(		.sel(~sel[12]),
				.sel2(~sel[12]),
				.data(~bottom[15:0]),
				.out(decodeout_l[207:192]));

finalsel finalsel11(		.sel(~sel[11]),
				.sel2(~sel[11]),
				.data(~bottom[15:0]),
				.out(decodeout_l[191:176]));

finalsel finalsel10(		.sel(~sel[10]),
				.sel2(~sel[10]),
				.data(~bottom[15:0]),
				.out(decodeout_l[175:160]));

finalsel finalsel9(		.sel(~sel[9]),
				.sel2(~sel[9]),
				.data(~bottom[15:0]),
				.out(decodeout_l[159:144]));

finalsel finalsel8(		.sel(~sel[8]),
				.sel2(~sel[8]),
				.data(~bottom[15:0]),
				.out(decodeout_l[143:128]));

finalsel finalsel7(		.sel(~sel[7]),
				.sel2(~sel[7]),
				.data(~bottom[15:0]),
				.out(decodeout_l[127:112]));

finalsel finalsel6(		.sel(~sel[6]),
				.sel2(~sel[6]),
				.data(~bottom[15:0]),
				.out(decodeout_l[111:96]));

finalsel finalsel5(		.sel(~sel[5]),
				.sel2(~sel[5]),
				.data(~bottom[15:0]),
				.out(decodeout_l[95:80]));

finalsel finalsel4(		.sel(~sel[4]),
				.sel2(~sel[4]),
				.data(~bottom[15:0]),
				.out(decodeout_l[79:64]));

finalsel finalsel3(		.sel(~sel[3]),
				.sel2(~sel[3]),
				.data(~bottom[15:0]),
				.out(decodeout_l[63:48]));

finalsel finalsel2(		.sel(~sel[2]),
				.sel2(~sel[2]),
				.data(~bottom[15:0]),
				.out(decodeout_l[47:32]));

finalsel finalsel1(		.sel(~sel[1]),
				.sel2(~sel[1]),
				.data(~bottom[15:0]),
				.out(decodeout_l[31:16]));

finalsel finalsel0(		.sel(~sel[0]),
				.sel2(~sel[0]),
				.data(~bottom[15:0]),
				.out(decodeout_l[15:0]));


assign decodeout = ~decodeout_l;


endmodule

// ***********end of decoder top module ************


// -------------------- finalsel -----------------------
module finalsel (sel, sel2, data, out);

input sel, sel2;  	// sel2 is provided as a 2nd port
			//   to "help" synopsys synthesize.
			// the load here is large and 2 ports
			//   "adds" fanout.
input [15:0] data;
output [15:0] out;

assign out[15] = ~(data[15] & sel2);
assign out[14] = ~(data[14] & sel2);
assign out[13] = ~(data[13] & sel2);
assign out[12] = ~(data[12] & sel2);
assign out[11] = ~(data[11] & sel2);
assign out[10] = ~(data[10] & sel2);
assign out[9] = ~(data[9] & sel2);
assign out[8] = ~(data[8] & sel2);
assign out[7] = ~(data[7] & sel);
assign out[6] = ~(data[6] & sel);
assign out[5] = ~(data[5] & sel);
assign out[4] = ~(data[4] & sel);
assign out[3] = ~(data[3] & sel);
assign out[2] = ~(data[2] & sel);
assign out[1] = ~(data[1] & sel);
assign out[0] = ~(data[0] & sel);

endmodule


// ------------------- mj_s_dcd4to16 --------------------------

// note output is actually active-low (decodeout_l)

module mj_s_dcd4to16 (data, data_l, decodeout_l);  
  
input  [3:0]  data, data_l;
output  [15:0]  decodeout_l;


wire [3:0] sel, bottom; 
//wire [15:0] decodeout_l;


// decode top order bits

decode2to4 decodeupper	(	.datain(data[3:2]),
				.datain_l(data_l[3:2]),
				.dataout(sel[3:0]));

// decode lower order bits
 
decode2to4 decodelower	(	.datain(data[1:0]),
				.datain_l(data_l[1:0]),
				.dataout(bottom[3:0]));

// now use the top order bits to select the proper lower order bits


finalsel4 finalsel4_3(		.sel(~sel[3]),
				.data(~bottom[3:0]),
				.out(decodeout_l[15:12]));

finalsel4 finalsel4_2(		.sel(~sel[2]),
				.data(~bottom[3:0]),
				.out(decodeout_l[11:8]));

finalsel4 finalsel4_1(		.sel(~sel[1]),
				.data(~bottom[3:0]),
				.out(decodeout_l[7:4]));

finalsel4 finalsel4_0(		.sel(~sel[0]),
				.data(~bottom[3:0]),
				.out(decodeout_l[3:0]));


endmodule

// ***********end of decoder top module ************


// -------------------- decode2to4 -----------------------
module decode2to4 (datain, datain_l, dataout);

input [1:0] datain, datain_l;
output [3:0] dataout;


assign dataout[3]  = ~( datain[1]  &   datain[0]);   // 11
assign dataout[2]  = ~( datain[1]  &   datain_l[0]); // 10
assign dataout[1]  = ~( datain_l[1] &  datain[0]);   // 01
assign dataout[0]  = ~( datain_l[1] &  datain_l[0]); // 00

endmodule


// -------------------- finalsel -----------------------
module finalsel4 (sel, data, out);

input sel;
input [3:0] data;
output [3:0] out;


assign out[3] = ~(data[3] & sel);
assign out[2] = ~(data[2] & sel);
assign out[1] = ~(data[1] & sel);
assign out[0] = ~(data[0] & sel);

endmodule


//-------------------------------------------------------------------------
//
// 22) fram32_8.v  32-bit wide, 8 deep fifo ram
//
//-////////////////////////////////////////////////////////////////////-/

module fram32_8 (
   clk,
   write_n,   // Write enable
   write_ptr, // Write Address
   read_ptr,  // Read Address
   data_in,   // Write Data
   data_out   // Read Data
);

parameter
	f_width=32,	//fifo data with
	p_width=3,	//fifo pointer with
	f_depth=8;	//fifo data depth
    input         clk;
    input         write_n;
    input   [p_width-1:0] write_ptr;
    input   [p_width-1:0] read_ptr;
    input  [f_width-1:0] data_in;

    output [f_width-1:0] data_out;
    reg    [f_width-1:0] data_out;

    reg    [f_width-1:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
    wire    [p_width-1:0] write_ptr;
    
// verilint 69 off
// 69: Case statement without default clause
/*
// synopsys translate_off
//-------------------
    initial begin
    reg0 = 0;
    reg1 = 0;
    reg2 = 0;
    reg3 = 0;
    reg4 = 0;
    reg5 = 0;
    reg6 = 0;
    reg7 = 0;
    end
//-------------------
// synopsys translate_on
*/
    // Continuous output of Read Ptr location
    always @(read_ptr or reg0 or reg1 or reg2 or reg3 or reg4 or reg5 or reg6 or reg7)
       case (read_ptr)
          3'b000 : data_out = reg0;
          3'b001 : data_out = reg1;
          3'b010 : data_out = reg2;
          3'b011 : data_out = reg3;
          3'b100 : data_out = reg4;
          3'b101 : data_out = reg5;
          3'b110 : data_out = reg6;
          3'b111 : data_out = reg7;
       endcase

    // Update RAM on a write pulse
    always @(posedge clk) 
       if( !write_n)
       case (write_ptr)
          3'b000   : reg0  <= data_in;
          3'b001   : reg1  <= data_in;
          3'b010   : reg2  <= data_in;
          3'b011   : reg3  <= data_in;
          3'b100   : reg4  <= data_in;
          3'b101   : reg5  <= data_in;
          3'b110   : reg6  <= data_in;
          3'b111   : reg7  <= data_in;
       endcase
// 69: Case statement without default clause
// verilint 69 on

endmodule

//--23) fram37_8.v	37-bit wide, 8 deep fifo ram --

module fram37_8 (
   clk,
   write_n,   // Write enable
   write_ptr, // Write Address
   read_ptr,  // Read Address
   data_in,   // Write Data
   data_out   // Read Data
);

parameter
	f_width=37,	//fifo data with
	p_width=3,	//fifo pointer with
	f_depth=8;	//fifo data depth
    input         clk;
    input         write_n;
    input   [p_width-1:0] write_ptr;
    input   [p_width-1:0] read_ptr;
    input  [f_width-1:0] data_in;

    output [f_width-1:0] data_out;
    reg    [f_width-1:0] data_out;

    reg    [f_width-1:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
    wire    [p_width-1:0] write_ptr;
    
// verilint 69 off
// 69: Case statement without default clause
/*
// synopsys translate_off
//-------------------
    initial begin
    reg0 = 0;
    reg1 = 0;
    reg2 = 0;
    reg3 = 0;
    reg4 = 0;
    reg5 = 0;
    reg6 = 0;
    reg7 = 0;
    end
//-------------------
// synopsys translate_on
*/

    // Continuous output of Read Ptr location
    always @(read_ptr or reg0 or reg1 or reg2 or reg3 or reg4 or reg5 or reg6 or reg7)
       case (read_ptr)
          3'b000 : data_out = reg0;
          3'b001 : data_out = reg1;
          3'b010 : data_out = reg2;
          3'b011 : data_out = reg3;
          3'b100 : data_out = reg4;
          3'b101 : data_out = reg5;
          3'b110 : data_out = reg6;
          3'b111 : data_out = reg7;
       endcase

    // Update RAM on a write pulse
    always @(posedge clk) 
       if( !write_n)
       case (write_ptr)
          3'b000   : reg0  <= data_in;
          3'b001   : reg1  <= data_in;
          3'b010   : reg2  <= data_in;
          3'b011   : reg3  <= data_in;
          3'b100   : reg4  <= data_in;
          3'b101   : reg5  <= data_in;
          3'b110   : reg6  <= data_in;
          3'b111   : reg7  <= data_in;
       endcase
// 69: Case statement without default clause
// verilint 69 on

endmodule


//--24) fram48_8.v	48-bit wide, 8 deep fifo ram --

module fram48_8 (
   clk,
   write_n,   // Write enable
   write_ptr, // Write Address
   read_ptr,  // Read Address
   data_in,   // Write Data
   data_out   // Read Data
);

parameter
	f_width=48,	//fifo data with
	p_width=3,	//fifo pointer with
	f_depth=8;	//fifo data depth
    input         clk;
    input         write_n;
    input   [p_width-1:0] write_ptr;
    input   [p_width-1:0] read_ptr;
    input  [f_width-1:0] data_in;

    output [f_width-1:0] data_out;
    reg    [f_width-1:0] data_out;

    reg    [f_width-1:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;
    wire    [p_width-1:0] write_ptr;
    
// verilint 69 off
// 69: Case statement without default clause
/*
// synopsys translate_off
//-------------------
    initial begin
    reg0 = 0;
    reg1 = 0;
    reg2 = 0;
    reg3 = 0;
    reg4 = 0;
    reg5 = 0;
    reg6 = 0;
    reg7 = 0;
    end
//-------------------
// synopsys translate_on
*/
    // Continuous output of Read Ptr location
    always @(read_ptr or reg0 or reg1 or reg2 or reg3 or reg4 or reg5 or reg6 or reg7)
       case (read_ptr)
          3'b000 : data_out = reg0;
          3'b001 : data_out = reg1;
          3'b010 : data_out = reg2;
          3'b011 : data_out = reg3;
          3'b100 : data_out = reg4;
          3'b101 : data_out = reg5;
          3'b110 : data_out = reg6;
          3'b111 : data_out = reg7;
       endcase

    // Update RAM on a write pulse
    always @(posedge clk) 
       if( !write_n)
       case (write_ptr)
          3'b000   : reg0  <= data_in;
          3'b001   : reg1  <= data_in;
          3'b010   : reg2  <= data_in;
          3'b011   : reg3  <= data_in;
          3'b100   : reg4  <= data_in;
          3'b101   : reg5  <= data_in;
          3'b110   : reg6  <= data_in;
          3'b111   : reg7  <= data_in;
       endcase
// 69: Case statement without default clause
// verilint 69 on

endmodule

//------------------------------------------------------------------------
//
// 25) @(#)fram58_4.v	 32-bit wide, 8 deep fifo ram
//
//-////////////////////////////////////////////////////////////////////-/

module fram58_4 (
   clk,
   write_n,   // Write enable
   write_ptr, // Write Address
   read_ptr,  // Read Address
   data_in,   // Write Data
   data_out   // Read Data
);
parameter
	f_width=58,	//fifo data with
	p_width=2,	//fifo pointer with
	f_depth=4;	//fifo data depth
    input         clk;
    input         write_n;
    input   [p_width-1:0] write_ptr;
    input   [p_width-1:0] read_ptr;
    input  [f_width-1:0] data_in;

    output [f_width-1:0] data_out;
    reg    [f_width-1:0] data_out;

    reg    [f_width-1:0] reg0, reg1, reg2, reg3;
    wire    [p_width-1:0] write_ptr;
    
// verilint 69 off
// 69: Case statement without default clause
/*
// synopsys translate_off
//-------------------
    initial begin
    reg0 = 0;
    reg1 = 0;
    reg2 = 0;
    reg3 = 0;
    end
//-------------------
// synopsys translate_on
*/

    // Continuous output of Read Ptr location
    always @(read_ptr or reg0 or reg1 or reg2 or reg3)
       case (read_ptr)
          2'b00 : data_out = reg0;
          2'b01 : data_out = reg1;
          2'b10 : data_out = reg2;
          2'b11 : data_out = reg3;
       endcase

    // Update RAM on a write pulse
    always @(posedge clk) 
       if( !write_n)
       case (write_ptr)
          2'b00   : reg0  <= data_in;
          2'b01   : reg1  <= data_in;
          2'b10   : reg2  <= data_in;
          2'b11   : reg3  <= data_in;
       endcase
// 69: Case statement without default clause
// verilint 69 on

endmodule


// -------------------26) 32-bit decrementer ---------------------------------
// ------------------- Kogge-Stone style -----------------------------------

module dec32 (ai, sum);  
  
input  [31:0]  ai;
output [31:0]  sum;
 
wire    [31:0]  gi_l;	// bit-wise generate carry output
wire    gen1_l;
wire    g31_30, g29_28, g27_26, g25_24, g23_22, g21_20, g19_18, g17_16, g15_14,
        g13_12, g11_10, g9_8, g7_6, g5_4, g3_2, g1_0;
wire    g31_28_l, g27_24_l, g23_20_l, g19_16_l, g15_12_l, g11_8_l, g7_4_l, g3_0_l;
wire 	g31_24, g27_20, g23_16, g19_12, g15_8, g11_4, g7_0;
wire    g31_16_l, g27_12_l, g23_8_l, g19_4_l, g15_0_l, g11_0_l;
wire    g31_0, g27_0, g23_0, g19_0;
wire    w2_3_0, w3i_7_0, w3i_3_0, w4_15_0, w4_11_0, w4_7_0, w4_3_0;
wire    [31:0] in, inb;
wire    [31:0] sum;

assign gi_l[31:0] = ~ai[31:0];
assign gen1_l     = ~ai[0];


/* g0_dec32 stage */

g0_dec32 pg_31_30 ( .g_u_d(g31_30), 
               .g_l_in(gi_l[31:30]));

g0_dec32 pg_29_28 ( .g_u_d(g29_28),
               .g_l_in(gi_l[29:28]));

g0_dec32 pg_27_26 ( .g_u_d(g27_26),
               .g_l_in(gi_l[27:26]));

g0_dec32 pg_25_24 ( .g_u_d(g25_24),
               .g_l_in(gi_l[25:24]));

g0_dec32 pg_23_22 ( .g_u_d(g23_22),
               .g_l_in(gi_l[23:22]));

g0_dec32 pg_21_20 ( .g_u_d(g21_20),
               .g_l_in(gi_l[21:20]));

g0_dec32 pg_19_18 ( .g_u_d(g19_18),
               .g_l_in(gi_l[19:18]));

g0_dec32 pg_17_16 ( .g_u_d(g17_16),
               .g_l_in(gi_l[17:16]));

g0_dec32 pg_15_14 ( .g_u_d(g15_14),
               .g_l_in(gi_l[15:14]));

g0_dec32 pg_13_12 ( .g_u_d(g13_12),
               .g_l_in(gi_l[13:12]));

g0_dec32 pg_11_10 ( .g_u_d(g11_10),
               .g_l_in(gi_l[11:10]));

g0_dec32 pg_9_8 (   .g_u_d(g9_8),
               .g_l_in(gi_l[9:8]));

g0_dec32 pg_7_6 (   .g_u_d(g7_6),
               .g_l_in(gi_l[7:6]));

g0_dec32 pg_5_4 (   .g_u_d(g5_4),
               .g_l_in(gi_l[5:4]));

g0_dec32 pg_3_2 (   .g_u_d(g3_2),
               .g_l_in(gi_l[3:2]));

g0_dec32 g_1_0 (     .g_u_d(g1_0),
               .g_l_in(gi_l[1:0]));



/* g1 stage */

g1_dec32 pg_31_28 ( .ggrp_l(g31_28_l),
                .gu_in(g31_30),
                .gd_in(g29_28));


g1_dec32 pg_27_24 ( .ggrp_l(g27_24_l),
                .gu_in(g27_26),
                .gd_in(g25_24));


g1_dec32 pg_23_20 ( .ggrp_l(g23_20_l),
                .gu_in(g23_22),
                .gd_in(g21_20));


g1_dec32 pg_19_16 ( .ggrp_l(g19_16_l),
                .gu_in(g19_18),
                .gd_in(g17_16));


g1_dec32 pg_15_12 ( .ggrp_l(g15_12_l),
                .gu_in(g15_14),
                .gd_in(g13_12));


g1_dec32 pg_11_8 (  .ggrp_l(g11_8_l),
                .gu_in(g11_10),
                .gd_in(g9_8));


g1_dec32 pg_7_4 (   .ggrp_l(g7_4_l),
                .gu_in(g7_6),
                .gd_in(g5_4));


g1_dec32 g_3_0 (   .ggrp_l(g3_0_l),
                .gu_in(g3_2),
                .gd_in(g1_0));




/* g2 stage */

g2_dec32 pg_31_24 ( .ggrp(g31_24),
                .gu_in(g31_28_l),
                .gd_in(g27_24_l));


g2_dec32 pg_27_20 ( .ggrp(g27_20),
                .gu_in(g27_24_l),
                .gd_in(g23_20_l));


g2_dec32 pg_23_16 ( .ggrp(g23_16),
                .gu_in(g23_20_l),
                .gd_in(g19_16_l));


g2_dec32 pg_19_12 ( .ggrp(g19_12),
                .gu_in(g19_16_l),
                .gd_in(g15_12_l));


g2_dec32 pg_15_8 (  .ggrp(g15_8),
                .gu_in(g15_12_l),
                .gd_in(g11_8_l));


g2_dec32 pg_11_4 (  .ggrp(g11_4),
                .gu_in(g11_8_l),
                .gd_in(g7_4_l));


g2_dec32 g_7_0 (   .ggrp(g7_0),
                .gu_in(g7_4_l),
                .gd_in(g3_0_l));


assign w2_3_0 = ~ g3_0_l;



/* g3 stage */

g3_dec32 pg_31_16 ( .ggrp_l(g31_16_l),
                .gu_in(g31_24),
                .gd_in(g23_16));


g3_dec32 pg_27_12 ( .ggrp_l(g27_12_l),
                .gu_in(g27_20),
                .gd_in(g19_12));


g3_dec32 pg_23_8 (  .ggrp_l(g23_8_l),
                .gu_in(g23_16),
                .gd_in(g15_8));


g3_dec32 pg_19_4 (  .ggrp_l(g19_4_l),
                .gu_in(g19_12),
                .gd_in(g11_4));


g3_dec32 g_15_0 (   .ggrp_l(g15_0_l),
                .gu_in(g15_8),
                .gd_in(g7_0));


g3_dec32 g_11_0 (   .ggrp_l(g11_0_l),
                .gu_in(g11_4),
                .gd_in(w2_3_0));

assign w3i_7_0 = ~ g7_0;

assign w3i_3_0 = ~ w2_3_0;



/* g4 stage */

g4_dec32 g_31_0 (   .ggrp(g31_0),
                .gu_in(g31_16_l),
                .gd_in(g15_0_l));

g4_dec32 g_27_0 (   .ggrp(g27_0),
                .gu_in(g27_12_l),
                .gd_in(g11_0_l));

g4_dec32 g_23_0 (   .ggrp(g23_0),
                .gu_in(g23_8_l),
                .gd_in(w3i_7_0));

g4_dec32 g_19_0 (   .ggrp(g19_0),
                .gu_in(g19_4_l),
                .gd_in(w3i_3_0));

assign w4_15_0 = ~ g15_0_l;
assign w4_11_0 = ~ g11_0_l;
assign w4_7_0  = ~ w3i_7_0;
assign w4_3_0  = ~ w3i_3_0;


/* Local Sum, Carry-select stage */

presum_dec32 psum31_28 (.g1(~gi_l[28]), .g2(~gi_l[29]), .g3(~gi_l[30]), .g4(~gi_l[31]),
                .s1(in[28]), .s2(in[29]), .s3(in[30]), .s4(in[31]),
                .s1b(inb[28]), .s2b(inb[29]), .s3b(inb[30]), .s4b(inb[31]));
                
presum_dec32 psum27_24 (.g1(~gi_l[24]), .g2(~gi_l[25]), .g3(~gi_l[26]), .g4(~gi_l[27]),
                .s1(in[24]), .s2(in[25]), .s3(in[26]), .s4(in[27]),
                .s1b(inb[24]), .s2b(inb[25]), .s3b(inb[26]), .s4b(inb[27]));

presum_dec32 psum23_20 (.g1(~gi_l[20]), .g2(~gi_l[21]), .g3(~gi_l[22]), .g4(~gi_l[23]),
                .s1(in[20]), .s2(in[21]), .s3(in[22]), .s4(in[23]),
                .s1b(inb[20]), .s2b(inb[21]), .s3b(inb[22]), .s4b(inb[23]));

presum_dec32 psum19_16 (.g1(~gi_l[16]), .g2(~gi_l[17]), .g3(~gi_l[18]), .g4(~gi_l[19]),
                .s1(in[16]), .s2(in[17]), .s3(in[18]), .s4(in[19]),
                .s1b(inb[16]), .s2b(inb[17]), .s3b(inb[18]), .s4b(inb[19]));

presum_dec32 psum15_12 (.g1(~gi_l[12]), .g2(~gi_l[13]), .g3(~gi_l[14]), .g4(~gi_l[15]),
                .s1(in[12]), .s2(in[13]), .s3(in[14]), .s4(in[15]),
                .s1b(inb[12]), .s2b(inb[13]), .s3b(inb[14]), .s4b(inb[15]));

presum_dec32 psum11_8 (.g1(~gi_l[8]), .g2(~gi_l[9]), .g3(~gi_l[10]), .g4(~gi_l[11]),
                .s1(in[8]), .s2(in[9]), .s3(in[10]), .s4(in[11]),
                .s1b(inb[8]), .s2b(inb[9]), .s3b(inb[10]), .s4b(inb[11]));

presum_dec32 psum7_4 (.g1(~gi_l[4]), .g2(~gi_l[5]), .g3(~gi_l[6]), .g4(~gi_l[7]),
                .s1(in[4]), .s2(in[5]), .s3(in[6]), .s4(in[7]),
                .s1b(inb[4]), .s2b(inb[5]), .s3b(inb[6]), .s4b(inb[7]));

presum_dec32 psum3_0 (.g1(~gen1_l), .g2(~gi_l[1]), .g3(~gi_l[2]), .g4(~gi_l[3]),
                .s1(in[0]), .s2(in[1]), .s3(in[2]), .s4(in[3]),
                .s1b(inb[0]), .s2b(inb[1]), .s3b(inb[2]), .s4b(inb[3]));


/* Sum stage */

sum4s_dec32 sum31_28 (.csel(g27_0), .sin1(in[28]), .sin2(in[29]), .sin3(in[30]), .sin4(in[31]),
                .sin1b(inb[28]), .sin2b(inb[29]), .sin3b(inb[30]), .sin4b(inb[31]),
                .sum1(sum[28]), .sum2(sum[29]), .sum3(sum[30]), .sum4(sum[31]));

sum4s_dec32 sum27_24 (.csel(g23_0), .sin1(in[24]), .sin2(in[25]), .sin3(in[26]), .sin4(in[27]),
                .sin1b(inb[24]), .sin2b(inb[25]), .sin3b(inb[26]), .sin4b(inb[27]),
                .sum1(sum[24]), .sum2(sum[25]), .sum3(sum[26]), .sum4(sum[27]));

sum4s_dec32 sum23_20 (.csel(g19_0), .sin1(in[20]), .sin2(in[21]), .sin3(in[22]), .sin4(in[23]),
                .sin1b(inb[20]), .sin2b(inb[21]), .sin3b(inb[22]), .sin4b(inb[23]),
                .sum1(sum[20]), .sum2(sum[21]), .sum3(sum[22]), .sum4(sum[23]));

sum4s_dec32 sum19_16 (.csel(w4_15_0), .sin1(in[16]), .sin2(in[17]), .sin3(in[18]), .sin4(in[19]),
                .sin1b(inb[16]), .sin2b(inb[17]), .sin3b(inb[18]), .sin4b(inb[19]),
                .sum1(sum[16]), .sum2(sum[17]), .sum3(sum[18]), .sum4(sum[19]));

sum4s_dec32 sum15_12 (.csel(w4_11_0), .sin1(in[12]), .sin2(in[13]), .sin3(in[14]), .sin4(in[15]),
                .sin1b(inb[12]), .sin2b(inb[13]), .sin3b(inb[14]), .sin4b(inb[15]),
                .sum1(sum[12]), .sum2(sum[13]), .sum3(sum[14]), .sum4(sum[15]));

sum4s_dec32 sum11_8 (.csel(w4_7_0), .sin1(in[8]), .sin2(in[9]), .sin3(in[10]), .sin4(in[11]),
                .sin1b(inb[8]), .sin2b(inb[9]), .sin3b(inb[10]), .sin4b(inb[11]),
                .sum1(sum[8]), .sum2(sum[9]), .sum3(sum[10]), .sum4(sum[11]));

sum4s_dec32 sum7_4 (.csel(w4_3_0), .sin1(in[4]), .sin2(in[5]), .sin3(in[6]), .sin4(in[7]),
                .sin1b(inb[4]), .sin2b(inb[5]), .sin3b(inb[6]), .sin4b(inb[7]),
                .sum1(sum[4]), .sum2(sum[5]), .sum3(sum[6]), .sum4(sum[7]));

sum4s_dec32 sum3_0 (.csel(1'b0), .sin1(in[0]), .sin2(in[1]), .sin3(in[2]), .sin4(in[3]),
                .sin1b(inb[0]), .sin2b(inb[1]), .sin3b(inb[2]), .sin4b(inb[3]),
                .sum1(sum[0]), .sum2(sum[1]), .sum3(sum[2]), .sum4(sum[3]));

endmodule


/* g0_dec32 stage */
module g0_dec32 (g_u_d, g_l_in);

output g_u_d;			// carry_generated.
input  [1:0]  g_l_in;		// generate inputs.

/* Ling modification used here */
assign g_u_d = 	~ (g_l_in[1] & g_l_in[0]); 	// 2-bit pseudo generate.

endmodule


/* G1AOI stage */
module g1_dec32 (ggrp_l, gu_in, gd_in);

output ggrp_l;		// group generate.
input  gu_in;  		// upper generate input.
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | gd_in);    // group generate.

endmodule


/* G3AOI stage */
module g3_dec32 (ggrp_l, gu_in, gd_in);

output ggrp_l;		// group generate.
input  gu_in;  		// upper generate input.
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp_l =  ~ (gu_in | gd_in);    // group generate.

endmodule


/* G2OAI stage */
module g2_dec32 (ggrp, gu_in, gd_in);

output ggrp;		// group generate.
input  gu_in;  		// upper generate input.
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & gd_in);     // group generate.

endmodule


/* G4OAI stage */
module g4_dec32 (ggrp, gu_in, gd_in);

output ggrp;		// group generate.
input  gu_in;  		// upper generate input.
input  gd_in;  		// lower generate input.

/* conevntional approach used here */
assign ggrp =  ~ (gu_in & gd_in);     // group generate.

endmodule


/* Sum stage logic. Carry-select approach is used */
module sum4s_dec32 (csel, sin1, sin2, sin3, sin4, sin1b, sin2b, sin3b, sin4b, sum1, sum2, sum3, sum4);

output sum1, sum2, sum3, sum4;		// sum outputs.
input  sin1, sin2, sin3, sin4;  	// sel inputs assuming csel=1
input  sin1b, sin2b, sin3b, sin4b;	// sel_l inputs assuming csel=0
input  csel;    		        // global carry input.

/* carry-select approach used here */

      assign sum1 = csel == 1 ? sin1 : sin1b;
      assign sum2 = csel == 1 ? sin2 : sin2b;
      assign sum3 = csel == 1 ? sin3 : sin3b;
      assign sum4 = csel == 1 ? sin4 : sin4b;

endmodule


module presum_dec32 (g1, g2, g3, g4, s1, s2, s3, s4, s1b, s2b, s3b, s4b);

input g1, g2, g3, g4;
output s1, s2, s3, s4;
output s1b, s2b, s3b, s4b;

      assign s1 = g1;
      assign s2 = g2;
      assign s3 = g3;
      assign s4 = g4;
      assign s1b = (~g1);
      assign s2b = (~g2) ^ g1;
      assign s3b = (~g3) ^ (g2 | g1);
      assign s4b = (~g4) ^ (g3 | g2 | g1);
endmodule


// ------------------- 27 ) 10-bit incrementer --------------------------

module inc10 (data, sum);  
  
input  [9:0]  data;
output  [9:0]  sum;


// use Kogge-Stone to design the logic

// -------------------- and tree level 1 ----------------------------

wire p0to2_l, p3to5_l;

lev1and lev1a (data[0], data[1], data[2], p0to2_l);
lev1and lev1b (data[3], data[4], data[5], p3to5_l);


// -------------------- and tree level 2 ----------------------------

wire p0to5;

lev2and lev2a (p0to2_l, p3to5_l, p0to5);	



// -------------------- local propagates ---------------------------

wire [9:0] outa;

local3_inc10 local0to2 (	.in1(data[0]),
			.in2(data[1]),
			.in3(data[2]),
			.out1a(outa[0]),
			.out2a(outa[1]),
			.out3a(outa[2]));

local3_inc10 local3to5 (	.in1(data[3]),
			.in2(data[4]),
			.in3(data[5]),
			.out1a(outa[3]),
			.out2a(outa[4]),
			.out3a(outa[5]));

local4_inc10 local6to9 (.in1(data[6]),
			.in2(data[7]),
			.in3(data[8]),
			.in4(data[9]),
			.out1a(outa[6]),
			.out2a(outa[7]),
			.out3a(outa[8]),
			.out4a(outa[9]));


// -------------------- select output ---------------------------

selout3_inc10 selout0to2 (	.sel_l(1'b0), 
			.out1(sum[0]), .out2(sum[1]), .out3(sum[2]),
			.out1a(outa[0]), .out2a(outa[1]), .out3a(outa[2]),
			.out1b(data[0]), .out2b(data[1]), .out3b(data[2]));
selout3_inc10 selout3to5 (	.sel_l(p0to2_l), 
			.out1(sum[3]), .out2(sum[4]), .out3(sum[5]),
			.out1a(outa[3]), .out2a(outa[4]), .out3a(outa[5]),
			.out1b(data[3]), .out2b(data[4]), .out3b(data[5]));
selout4_inc10 selout6to9 (	.sel_l(~p0to5), 
			.out1(sum[6]), .out2(sum[7]), .out3(sum[8]), .out4(sum[9]),
			.out1a(outa[6]), .out2a(outa[7]), .out3a(outa[8]), .out4a(outa[9]),
			.out1b(data[6]), .out2b(data[7]), .out3b(data[8]), .out4b(data[9]));


endmodule

// ***********end of inccrementer top module ************


// -------------------- lev1and -----------------------
module lev1and (in1, in2, in3, out);

input in1, in2, in3;
output out;

wire out;

assign out = ~(in1 & in2 & in3);

endmodule

// -------------------- lev2and -----------------------
module lev2and (in1, in2, out);

input in1, in2;
output out;

wire out;

assign out = ~(in1 | in2);

endmodule



// -------------------- local3_inc10 -----------------------

module local3_inc10 (in1, in2, in3,
		out1a, out2a, out3a);

input in1, in2, in3;
output out1a, out2a, out3a;

wire out1a, out2a, out3a;

assign out1a = ~in1;
assign out2a = in1 ^ in2;
assign out3a = (in1 & in2) ^ in3;

endmodule

// -------------------- local4_inc10 -----------------------

module local4_inc10 (in1, in2, in3, in4,
		out1a, out2a, out3a, out4a);

input in1, in2, in3, in4;
output out1a, out2a, out3a, out4a;

wire out1a, out2a, out3a, out4a;

assign out1a = ~in1;
assign out2a = in1 ^ in2;
assign out3a = (in1 & in2) ^ in3;
assign out4a = (in1 & in2 & in3) ^ in4;

endmodule


// -------------------- selout3_inc10 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selout3_inc10 (sel_l, out1, out2, out3,
		out1a, out2a, out3a,
		out1b, out2b, out3b);

input out1a, out2a, out3a,
	out1b, out2b, out3b,
	sel_l;
output out1, out2, out3;
wire out1, out2, out3;

assign out1 = ~sel_l ? out1a : out1b;
assign out2 = ~sel_l ? out2a : out2b;
assign out3 = ~sel_l ? out3a : out3b;

endmodule

// -------------------- selout4_inc10 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selout4_inc10 (sel_l, out1, out2, out3, out4,
		out1a, out2a, out3a, out4a,
		out1b, out2b, out3b, out4b);

input out1a, out2a, out3a, out4a,
	out1b, out2b, out3b, out4b,
	sel_l;
output out1, out2, out3, out4;
wire out1, out2, out3, out4;

assign out1 = ~sel_l ? out1a : out1b;
assign out2 = ~sel_l ? out2a : out2b;
assign out3 = ~sel_l ? out3a : out3b;
assign out4 = ~sel_l ? out4a : out4b;

endmodule

/***********28) OR7 gate *******************************/

module mj_s_or7 (in, out);
input [6:0] in;
output 	    out;

assign out = |in[6:0];

endmodule

/***********29) OR5 gate *******************************/

module mj_s_or5 (in, out);
input [4:0] in;
output 	    out;

assign out = |in[4:0];

endmodule

/***********30) OR12 gate *******************************/
module mj_s_or12 (in, out);
input [11:0] in;
output 	    out;

assign out = |in[11:0];

endmodule

/***********31) OR12 gate *******************************/

module mj_s_and6 (in, out);
input [5:0] in;
output 	    out;

assign out = &in[5:0];

endmodule


// ----------30) 30-bit bit_wise comparator -----------------------

module cmp30_e (ai, bi, a_eql_b);  
  
input  [29:0]  ai;
input  [29:0]  bi;
output	       a_eql_b;		// ai equal to bi.
 
assign a_eql_b = ( ai[29:0] == bi[29:0] ) ; 

endmodule
// ----------32) 32-bit bit_wise comparator -----------------------

module cmp32_e (ai, bi, a_eql_b);  
  
input  [31:0]  ai;
input  [31:0]  bi;
output	       a_eql_b;		// ai equal to bi.
 
/* Logic
assign a_eql_b = ( ai[31:0] == bi[31:0] ) ; 
*/

wire    [31:0]  bit_eql;	// bit-wise equal output
wire    [7:0]  level_1;		// 8-equal_not output
wire    [3:0]  level_2;		// 4-equal
assign bit_eql[31:0] = ai[31:0] ^~ bi[31:0] ;	// 32 2-in exnor, g10p "en".
assign level_1[7] = !(&bit_eql[31:28]);		// 1 4-in "nd4".
assign level_1[6] = !(&bit_eql[27:24]);		// 1 4-in "nd4".
assign level_1[5] = !(&bit_eql[23:20]);		// 1 4-in "nd4".
assign level_1[4] = !(&bit_eql[19:16]);		// 1 4-in "nd4".
assign level_1[3] = !(&bit_eql[15:12]);		// 1 4-in "nd4".
assign level_1[2] = !(&bit_eql[11:8]);		// 1 4-in "nd4".
assign level_1[1] = !(&bit_eql[7:4]);		// 1 4-in "nd4".
assign level_1[0] = !(&bit_eql[3:0]);		// 1 4-in "nd4".
assign level_2[3] = !(|level_1[7:6]);		// 1 2-in "nr2".
assign level_2[2] = !(|level_1[5:4]);		// 1 2-in "nr2".
assign level_2[1] = !(|level_1[3:2]);		// 1 2-in "nr2".
assign level_2[0] = !(|level_1[1:0]);		// 1 2-in "nr2".
assign a_eql_b =   (&level_2[3:0]);		// 1 2-in "and4".

endmodule


module  comp_ge_8       (
        in1,
        in2,
        ge );

input   [7:0]   in1;
input   [7:0]   in2;
output          ge;

assign  ge = (in1 >= in2 );

endmodule


/******Shells**********/

module cla_adder_32 (

	in1,
	in2,
	cin,
	sum,
	cout
);

input	[31:0]	in1;
input	[31:0]	in2;
input		cin;
output	[31:0]	sum;
output		cout;

/*assign {cout,sum} = in1 + in2 + cin;*/

fa32  i_fa32(.ai(in1),
           .bi(in2),
           .cin(cin),
           .sum(sum),
           .cout(cout)
          );


endmodule


module comp_gle_32 (

	in1,
	in2,
	gr,
	ls,
	eq
);

input	[31:0]	in1;
input	[31:0]	in2;
output		gr;
output		ls;
output		eq;
/*
assign	gr = (in1 >  in2)?1'b1:1'b0;
assign	ls = (in1 <  in2)?1'b1:1'b0;
assign	eq = (in1 == in2)?1'b1:1'b0;
*/

cmp3s_32_leg    i_cmp3s_32_leg (.ai(in1), .bi(in2),
               .a_ltn_b(ls), .a_eql_b(eq), .a_gtn_b(gr) );


endmodule


module cla_adder_16 (

	in1,
	in2,
	cin,
	sum,
	cout
);

input	[15:0]	in1;
input	[15:0]	in2;
input		cin;
output	[15:0]	sum;
output		cout;

/*assign {cout,sum} = in1 + in2 + cin;*/

fa16 	i_fa16 ( .sum(sum), .cout(cout),
	    .a(in1), .b(in2), .c(cin));

endmodule


module cla_adder_28 (

        in1,
        in2,
        cin,
        sum,
        cout
);

input   [27:0]   in1;
input   [27:0]   in2;
input           cin;
output  [27:0]   sum;
output          cout;

/*assign {cout,sum} = in1 + in2 + cin;*/

fa28   i_fa28_dp ( .sum(sum), .cout(cout),
             .ai(in1),  .bi(in2), .cin(cin) );


endmodule

module comp_eq_32 (

        in1,
        in2,
        eq
);

input   [31:0]  in1;
input   [31:0]  in2;
output          eq;

/*assign        eq = (in1==in2)?1'b1:1'b0;*/

cmp32_e i_cmp32_e (.ai(in1), .bi(in2), .a_eql_b(eq)
                 );


endmodule

// -------------------- increment_23 ------------------------------

module increment_23(cout,sum,in);

 input   [22:0]  in;

 output  [22:0]  sum;
 output          cout;

inc23  f_dpcl_inc23(.cout(cout),.sum(sum),.data(in));
// miss from dp_cells.v
// assign  {cout,sum} = in + 1'h1;

endmodule

// ------------------- 23-bit incrementer --------------------------

module inc23 (data, sum, cout);  
  
input  [22:0]  data;
output  [22:0]  sum;
output          cout;


// use Kogge-Stone to design the logic

// -------------------- and tree level 1 ----------------------------

wire p22_20, p19_16, p15_12, p11_8, p7_4, p3_0_i;

lev1inc23 lev1tree (    .datain(data),
                        .propout({p22_20,
                                  p19_16,
                                  p15_12,
                                  p11_8,
                                  p7_4,
                                  p3_0_i})
                        );


// -------------------- and tree level 2 ----------------------------

wire p22_12_l, p19_8_l, p15_4_l, p11_0_l, p7_0_l, p3_0;

lev2inc23 lev2tree (    .datain({p22_20,
                                  p19_16,
                                  p15_12,
                                  p11_8,
                                  p7_4,
                                  p3_0_i}),
                        .propout({p22_12_l,
                                  p19_8_l,
                                  p15_4_l,
                                  p11_0_l,
                                  p7_0_l,
                                  p3_0})
                        );


// -------------------- and tree level 3 ----------------------------

wire p22_0_l, p19_0_l, p15_0_l;

lev3inc23 lev3tree (    .datain({~p22_12_l,
                                  ~p19_8_l,
                                  ~p15_4_l,
                                  ~p11_0_l,
                                  ~p7_0_l,
                                  p3_0}),
                        .propout({p22_0_l,
                                  p19_0_l,
                                  p15_0_l})
                        );

 

// -------------------- local propagates ---------------------------

wire [22:0] outa;

local4_inc23 local0to3 (        .in1(data[0]),
                        .in2(data[1]),
                        .in3(data[2]),
                        .in4(data[3]),
                        .out1a(outa[0]),
                        .out2a(outa[1]),
                        .out3a(outa[2]),
                        .out4a(outa[3]));

local4_inc23 local4to7 (        .in1(data[4]),
                        .in2(data[5]),
                        .in3(data[6]),
                        .in4(data[7]),
                        .out1a(outa[4]),
                        .out2a(outa[5]),
                        .out3a(outa[6]),
                        .out4a(outa[7]));

local4_inc23 local8to11 (       .in1(data[8]),
                        .in2(data[9]),
                        .in3(data[10]),
                        .in4(data[11]),
                        .out1a(outa[8]),
                        .out2a(outa[9]),
                        .out3a(outa[10]),
                        .out4a(outa[11]));

local4_inc23 local12to15 (      .in1(data[12]),
                        .in2(data[13]),
                        .in3(data[14]),
                        .in4(data[15]),
                        .out1a(outa[12]),
                        .out2a(outa[13]),
                        .out3a(outa[14]),
                        .out4a(outa[15]));

local4_inc23 local16to19 (      .in1(data[16]),
                        .in2(data[17]),
                        .in3(data[18]),
                        .in4(data[19]),
                        .out1a(outa[16]),
                        .out2a(outa[17]),
                        .out3a(outa[18]),
                        .out4a(outa[19]));

local3_inc23 local20to22 (      .in1(data[20]),
                        .in2(data[21]),
                        .in3(data[22]),
                        .out1a(outa[20]),
                        .out2a(outa[21]),
                        .out3a(outa[22]));

// -------------------- select output ---------------------------


selout4_inc23 selout3to0 (      .sel_l(1'b0), 
                          .out1(sum[0]),   .out2(sum[1]),   .out3(sum[2]),   .out4(sum[3]),
                        .out1a(outa[0]), .out2a(outa[1]), .out3a(outa[2]), .out4a(outa[3]),
                        .out1b(data[0]), .out2b(data[1]), .out3b(data[2]), .out4b(data[3]));

selout4_inc23 selout7to4 (      .sel_l(~p3_0), 
                          .out1(sum[4]),   .out2(sum[5]),   .out3(sum[6]),   .out4(sum[7]),
                        .out1a(outa[4]), .out2a(outa[5]), .out3a(outa[6]), .out4a(outa[7]),
                        .out1b(data[4]), .out2b(data[5]), .out3b(data[6]), .out4b(data[7]));

selout4_inc23 selout11to8 (     .sel_l(p7_0_l), 
                          .out1(sum[8]),   .out2(sum[9]),   .out3(sum[10]),   .out4(sum[11]),
                        .out1a(outa[8]), .out2a(outa[9]), .out3a(outa[10]), .out4a(outa[11]),
                        .out1b(data[8]), .out2b(data[9]), .out3b(data[10]), .out4b(data[11]));

selout4_inc23 selout12to15 (    .sel_l(p11_0_l), 
                          .out1(sum[12]),   .out2(sum[13]),   .out3(sum[14]),   .out4(sum[15]),
                        .out1a(outa[12]), .out2a(outa[13]), .out3a(outa[14]), .out4a(outa[15]),
                        .out1b(data[12]), .out2b(data[13]), .out3b(data[14]), .out4b(data[15]));

selout4_inc23 selout16to19 (    .sel_l(p15_0_l), 
                          .out1(sum[16]),   .out2(sum[17]),   .out3(sum[18]),   .out4(sum[19]),
                        .out1a(outa[16]), .out2a(outa[17]), .out3a(outa[18]), .out4a(outa[19]),
                        .out1b(data[16]), .out2b(data[17]), .out3b(data[18]), .out4b(data[19]));

selout3_inc23 selout20to22 (    .sel_l(p19_0_l), 
                          .out1(sum[20]),   .out2(sum[21]),   .out3(sum[22]),
                        .out1a(outa[20]), .out2a(outa[21]), .out3a(outa[22]),
                        .out1b(data[20]), .out2b(data[21]), .out3b(data[22]));

assign cout = ~p22_0_l;


endmodule

// ***********end of incrementer top module ************


// -------------------- lev1-----------------------
module lev1inc23 (datain, propout);

input  [22:0] datain;
output [5:0] propout;

wire [5:0] propout;

assign propout[0] = (datain[0] & datain[1] & datain[2] & datain[3]);
assign propout[1] = (datain[4] & datain[5] & datain[6] & datain[7]);
assign propout[2] = (datain[8] & datain[9] & datain[10] & datain[11]);
assign propout[3] = (datain[12] & datain[13] & datain[14] & datain[15]);
assign propout[4] = (datain[16] & datain[17] & datain[18] & datain[19]);
assign propout[5] = (datain[20] & datain[21] & datain[22]);

endmodule

// -------------------- lev2 -----------------------
module lev2inc23 (datain, propout);

input  [5:0] datain;
output [5:0] propout;

wire [5:0] propout;

assign propout[0] = datain[0];
assign propout[1] = ~(datain[0] & datain[1]);
assign propout[2] = ~(datain[0] & datain[1] & datain[2]);
assign propout[3] = ~(datain[1] & datain[2] & datain[3]);
assign propout[4] = ~(datain[2] & datain[3] & datain[4]);
assign propout[5] = ~(datain[3] & datain[4] & datain[5]);

endmodule

// -------------------- lev3and -----------------------
module lev3inc23 (datain, propout);

input  [5:0] datain;
output [2:0] propout;

wire [2:0] propout;

assign propout[0] = ~(datain[0] & datain[3]);
assign propout[1] = ~(datain[1] & datain[4]);
assign propout[2] = ~(datain[2] & datain[5]);

endmodule


// -------------------- local3_inc23 -----------------------

module local3_inc23 (in1, in2, in3,
                out1a, out2a, out3a);

input in1, in2, in3;
output out1a, out2a, out3a;

wire out1a, out2a, out3a;

assign out1a = ~in1;
assign out2a = in1 ^ in2;
assign out3a = (in1 & in2) ^ in3;

endmodule

// -------------------- local4_inc23 -----------------------

module local4_inc23 (in1, in2, in3, in4,
                out1a, out2a, out3a, out4a);

input in1, in2, in3, in4;
output out1a, out2a, out3a, out4a;

wire out1a, out2a, out3a, out4a;

assign out1a = ~in1;
assign out2a = in1 ^ in2;
assign out3a = (in1 & in2) ^ in3;
assign out4a = (in1 & in2 & in3) ^ in4;

endmodule


// -------------------- selout3_inc23 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selout3_inc23 (sel_l, out1, out2, out3,
                out1a, out2a, out3a,
                out1b, out2b, out3b);

input out1a, out2a, out3a,
        out1b, out2b, out3b,
        sel_l;
output out1, out2, out3;
wire out1, out2, out3;

assign out1 = ~sel_l ? out1a : out1b;
assign out2 = ~sel_l ? out2a : out2b;
assign out3 = ~sel_l ? out3a : out3b;

endmodule

// -------------------- selout4_inc23 -----------------------
// new module just to make synopsys synthesize with a mux at end

module selout4_inc23 (sel_l, out1, out2, out3, out4,
                out1a, out2a, out3a, out4a,
                out1b, out2b, out3b, out4b);

input out1a, out2a, out3a, out4a,
        out1b, out2b, out3b, out4b,
        sel_l;
output out1, out2, out3, out4;
wire out1, out2, out3, out4;

assign out1 = ~sel_l ? out1a : out1b;
assign out2 = ~sel_l ? out2a : out2b;
assign out3 = ~sel_l ? out3a : out3b;
assign out4 = ~sel_l ? out4a : out4b;

endmodule


module comp_ls_32 (

        in1,
        in2,
        less
);

input   [31:0]  in1;
input   [31:0]  in2;
output          less;

/*assign        less = (in1<in2)?1'b1:1'b0; */

cmp32_ks_lt i_cmp32_ks_lt (     .ai(in1),
                                .bi(in2),
                                .a_ltn_b(less)
                                );

endmodule


module comp_gr_6 (
        in1,
        in2,
        gr
);
 
input   [5:0]   in1;
input   [5:0]   in2;
output          gr;
wire    [5:0]   in2_l;
 
/*assign gr = (in1 > in2);*/

gr6 i_gr6 ( .gr(gr),
          .a(in1), .b(in2_l)
                );

assign	in2_l = ~in2 ;

endmodule



module cla_adder_6 (

        in1,
        in2,
        cin,
        sum,
        cout
);

input   [5:0]   in1;
input   [5:0]   in2;
input           cin;
output  [5:0]   sum;
output          cout;

/*assign {cout,sum} = in1 + in2 + cin;*/

fa6   i_fa6 ( .sum(sum), .cout(cout),
             .a(in1),  .b(in2), .c(cin) );

endmodule


module comp_gr_32 (

        in1,
        in2,
        gr
);

input   [31:0]  in1;
input   [31:0]  in2;
output          gr;

/* assign        gr = (in1>in2)?1'b1:1'b0; */

cmp32_ks_lt  i_comp_gr_32 (	.ai(in2), 
				.bi(in1), 
				.a_ltn_b(gr)
				);

endmodule


module incr_32 (

        in,
        out
);


input   [31:0]  in;
output  [31:0]  out;

/* assign out = in + 1; */

inc32  i_incr_32 (	.ai(in), 
			.sum(out)
			);

endmodule


module  dec_32 (
        in,
        out
);
 
input   [31:0]  in;
output  [31:0]  out;
 
/* assign  out = in - 1; */

dec32  i_dec_32 (	.ai(in),
			.sum(out)
			);  

 
endmodule


module pencoder_16( trap_vec_c, ptrap_in_c);
input [15:0] trap_vec_c;
output [15:0] ptrap_in_c;

encoder16  i_pencoder_16 (	.ptrap_in_e(ptrap_in_c),
				.trap_vec_e(trap_vec_c)
				);

/**********************************************
reg [15:0] ptrap_in_c;
always @(trap_vec_c) begin
  casex (trap_vec_c[15:0])
    16'b1xxxxxxxxxxxxxxx : ptrap_in_c=16'h8000;
    16'b01xxxxxxxxxxxxxx : ptrap_in_c=16'h4000;
    16'b001xxxxxxxxxxxxx : ptrap_in_c=16'h2000;
    16'b0001xxxxxxxxxxxx : ptrap_in_c=16'h1000;
    16'b00001xxxxxxxxxxx : ptrap_in_c=16'h0800;
    16'b000001xxxxxxxxxx : ptrap_in_c=16'h0400;
    16'b0000001xxxxxxxxx : ptrap_in_c=16'h0200;
    16'b00000001xxxxxxxx : ptrap_in_c=16'h0100;
    16'b000000001xxxxxxx : ptrap_in_c=16'h0080;
    16'b0000000001xxxxxx : ptrap_in_c=16'h0040;
    16'b00000000001xxxxx : ptrap_in_c=16'h0020;
    16'b000000000001xxxx : ptrap_in_c=16'h0010;
    16'b0000000000001xxx : ptrap_in_c=16'h0008;
    16'b00000000000001xx : ptrap_in_c=16'h0004;
    16'b000000000000001x : ptrap_in_c=16'h0002;
    16'b0000000000000001 : ptrap_in_c=16'h0001;
   default               : ptrap_in_c=16'h0000;
  endcase
end
**********************************************/

endmodule


/*******************************************************************************
 *
 * Module:      cmp_32
 * 
 * This module contains the 32-bit comparator that can handle both signed
 * and unsigned comparisons.
 * 
 ******************************************************************************/
module cmp_32(in1,
              in2,
              sign,
              gt,
              eq,
              lt);

   input [31:0]         in1;    // Operand on the LHS to be compared
   input [31:0]         in2;    // Operand on the RHS to be compared
   input                sign;   // 0: unsigned comparison, 1: signed comparison
   output               gt;     // in1 >  in2
   output               eq;     // in1 == in2
   output               lt;     // in1 <  in2

cmp_legs_32  i_cmp_32 (	.gt(gt),
			.eq(eq),
              		.lt(lt),
              		.in1(in1),
              		.in2(in2),
              		.sign(sign)
			);

/******************************************************************
   reg                  cmp_gt; // Intermediate result, in1 > in2
   reg                  cmp_eq; // Intermediate result, in1 == in2
   reg                  cmp_lt; // Intermediate result, in1 < in2
   reg [31:0]           tmp1;   // 2's complement of in1
   reg [31:0]           tmp2;   // 2's complement of in2

   always @(in1 or in2 or sign)
      begin
         if (sign == 0)
            begin
               cmp_gt = (in1 > in2);
               cmp_eq = (in1 == in2);
               cmp_lt = (in1 < in2);
            end // if (sign == 0)
         else
            begin
               case ({in1[31], in2[31]})
                 2'b00:
                    begin
                       cmp_gt = (in1 > in2);
                       cmp_eq = (in1 == in2);
                       cmp_lt = (in1 < in2);
                    end // case: 2'b00
                 2'b01:
                    begin
                       cmp_gt = 1;
                       cmp_eq = 0;
                       cmp_lt = 0;
                    end // case: 2'b01
                 2'b10:
                    begin
                       cmp_gt = 0;
                       cmp_eq = 0;
                       cmp_lt = 1;
                    end // case: 2'b10
                 2'b11:
                    begin
                       tmp1 = (~in1) + 1;
                       tmp2 = (~in2) + 1;
                       cmp_gt = (tmp1 < tmp2);
                       cmp_eq = (in1 == in2);
                       cmp_lt = (tmp1 > tmp2);
                    end // case: 2'b11
               endcase // case({in1[31], in2[31]})
            end // else: !if(sign == 0)
      end // always @ (in1 or in2 or sign)

   assign gt = cmp_gt;
   assign eq = cmp_eq;
   assign lt = cmp_lt;

******************************************************************/

endmodule // cmp_32


/*******************************************************************************
 *
 * Module:      cmp_eq_19
 * 
 * This module implements 19-bit equality comparator
 * 
 ******************************************************************************/
module cmp_eq_19(in1,
                 in2,
                 eq
                 );
   input [18:0] in1;            // Operand 1 to be compared
   input [18:0] in2;            // Operand 2 to be compared
   output       eq;             // 1 if in1 == in2, 0 otherwise

/*   assign eq = (in1 == in2) ? 1'b1 : 1'b0; */

cmp20_e  i_cmp_eq_19 (	.ai({1'b0,in1}), 
			.bi({1'b0,in2}), 
			.a_eql_b(eq)
			);

endmodule // cmp_eq_19


/*******************************************************************************
 *
 * Module:      ucmp_16
 * 
 * This module implements unsigned 16-bit comparator with gt, eq, and lt outputs
 * 
 ******************************************************************************/
module ucmp_16(in1,
               in2,
               gt,
               eq,
               lt);

   input [15:0] in1;            // Operand 1 to be compared
   input [15:0] in2;            // Operand 2 to be compared
   output       gt;             // in1 > in2
   output       eq;             // in1 = in2
   output       lt;             // in1 < in2

cmp3s_32_leg  i_cmp3s_32_leg (	.ai({16'b0,in2}), 
				.bi({16'b0,in1}), 
				.a_ltn_b(gt), 
				.a_eql_b(eq), 
				.a_gtn_b(lt)
				);

/*******************************************************
   wire [16:0]  op1;            // in1 with leading 0
   wire [16:0]  op2;            // in2 with leading 0

   assign op1 = {1'b0, in1};
   assign op2 = {1'b0, in2};
   assign gt  = (op1 > op2)  ? 1'b1 : 1'b0;
   assign eq  = (op1 == op2) ? 1'b1 : 1'b0;
   assign lt  = (op1 < op2)  ? 1'b1 : 1'b0;
*******************************************************/
           
endmodule // ucmp_16


/*******************************************************************************
 *
 * Module:      cmp_eq_8
 * 
 * This module implements 8-bit equality comparator
 * 
 ******************************************************************************/
module cmp_eq_8(in1,
                in2,
                eq
                );
   input [7:0] in1;             // Operand 1 to be compared
   input [7:0] in2;             // Operand 2 to be compared
   output      eq;              // 1 if in1 == in2, 0 otherwise

/*   assign eq = (in1 == in2) ? 1'b1 : 1'b0; */

cmp16_e  i_cmp_eq_8 (	.ai({8'b0,in1}), 
			.bi({8'b0,in2}), 
			.a_eql_b(eq)
			);

endmodule // cmp_eq_8


/*******************************************************************************
 *
 * Module:      cla_adder_8
 * 
 * This module implements an 8-bit adder
 * 
 ******************************************************************************/
module cla_adder_8(in1,
                   in2,
                   cin,
                   sum,
                   cout
                   );

   input [7:0]  in1;
   input [7:0]  in2;
   input        cin;
   output [7:0] sum;
   output       cout;

/*   assign {cout,sum} = in1 + in2 + cin; */

fa8 i_fa8 (	.a(in1),
		.b(in2),
		.c(cin),
		.sum(sum),
		.cout(cout)
		);  

endmodule // cla_adder_8

// Use the following cells with caution
// These may not be available as megacells

module comp_le_32 (
 
        in1,
        in2,
        le
);
 
input   [31:0]  in1;
input   [31:0]  in2;
output          le;

wire		gr;

/* assign  le = (in1<=in2)?1'b1:1'b0; */

comp_gr_32  i_comp_le_32 (	.in1(in1),
				.in2(in2),
				.gr(gr)
				);
assign le = ~gr ;

endmodule

module comp_ge_32 (

        in1,
        in2,
        ge
);
 
input   [31:0]  in1;
input   [31:0]  in2;
output          ge;

wire		lt;

/* assign  ge = (in1>=in2)?1'b1:1'b0; */

cmp32_ks_lt  i_comp_ge_32 (	.ai(in1),
				.bi(in2), 
				.a_ltn_b(lt)
				);
assign	 ge = ~lt ;

endmodule

module mx21_32_l (mx_out, sel, in0, in1);
output [31:0] mx_out;
input         sel;
input  [31:0] in0 , in1 ;

wire   [31:0] sel_not, mux_sel;

assign sel_not = {32{~sel}};
assign mux_sel = {32{ sel}};
assign mx_out  = ~(mux_sel & in1 | sel_not & in0) ;

endmodule

module compare_lt_32(out,in0,in1);
 
 input  [31:0]  in0,in1;
 output         out;
 
/* assign out = (in0 < in1) ? 1'h1 : 1'h0; */

cmp32_ks_lt  i_compare_lt_32 (	.ai(in0),
				.bi(in1),
				.a_ltn_b(out)
				);
endmodule

module pri_encode(out,in);
// Leading zero output: if all 32 bits are zero output 32.
 
 input  [31:0] in;
 output  [5:0]  out;
 
lbd32 f_dpcl_lbd32(.zr_num(out),.di(in));
 
endmodule


module rshifter(rshiftout,high,low,stin,sticky,saout);
 
  input  [31:0] low;
  input  [30:0] high;
  input         stin;   // Input from prevoius STICKY
  input   [4:0] saout;  // Shift Amount.
 
  output [31:0] rshiftout;
  output        sticky;  // Or of all bits below the GBIT.
 
rsft31_63i_32o fpu_dp_cells_rshift(.rsf_out(rshiftout),.hi(high),.lo(low),
                 .stin(stin),.sticky(sticky),.rsa(saout), .gbit(), .nxstin());
 
endmodule

module lshift(out,high,low,shifta);
// performs the 32-bit Left Shift.
 
 input  [31:0]  high;
 input  [30:0]  low;  // high 31 bits of the m0out bus.
 input  [4:0]   shifta;
 output [31:0]  out;
 
lsft31_63i_32o f_dpcl_lshift(.lsf_out(out),.hi(high),.lo(low),.lsa(shifta));
 
endmodule

module cmp_zro_16(out,in);
input [15:0]  in;
output        out;
 
cmp16zero f_dpcl_cmp16zero(.a_eql_z(out),.ai(in));
 
endmodule


module compare_zero_32(out,in);
//  Performs an EQUALITY comparision to zero:
input [31:0]  in;
output        out;
 
cmp32zero f_dpcl_cmp32zero(.a_eql_z(out),.ai(in));
endmodule

module compare_16(out,in0,in1);
//  Performs an EQUALITY comparision
input [15:0]  in0,in1;
output        out;
 
cmp16_e f_dpcl_cmp16_e(.a_eql_b(out),.ai(in0),.bi(in1));
endmodule


module encoder16( ptrap_in_e ,trap_vec_e);

output [15:0] ptrap_in_e;
input [15:0] trap_vec_e;
wire [3:0] ptrap_in_e1, ptrap_in_e2;
wire [3:0] ptrap_in_e3;
wire [3:0] ptrap_in_e0;
wire e2,e1,e0;
wire c2,c1;

/*always @(trap_vec_e[15:0]) begin
  casex (trap_vec_e[15:0])
    16'b1xxxxxxxxxxxxxxx : ptrap_in_e=16'h8000;
    16'b01xxxxxxxxxxxxxx : ptrap_in_e=16'h4000;
    16'b001xxxxxxxxxxxxx : ptrap_in_e=16'h2000;
    16'b0001xxxxxxxxxxxx : ptrap_in_e=16'h1000;
    16'b00001xxxxxxxxxxx : ptrap_in_e=16'h0800;
    16'b000001xxxxxxxxxx : ptrap_in_e=16'h0400;
    16'b0000001xxxxxxxxx : ptrap_in_e=16'h0200;
    16'b00000001xxxxxxxx : ptrap_in_e=16'h0100;
    16'b000000001xxxxxxx : ptrap_in_e=16'h0080;
    16'b0000000001xxxxxx : ptrap_in_e=16'h0040;
    16'b00000000001xxxxx : ptrap_in_e=16'h0020;
    16'b000000000001xxxx : ptrap_in_e=16'h0010;
    16'b0000000000001xxx : ptrap_in_e=16'h0008;
    16'b00000000000001xx : ptrap_in_e=16'h0004;
    16'b000000000000001x : ptrap_in_e=16'h0002;
    16'b0000000000000001 : ptrap_in_e=16'h0001;
   default               : ptrap_in_e=16'h0000;
  endcase
end
*/

assign e0 = (&(~(trap_vec_e[15:12])));
assign e1 = (&(~(trap_vec_e[11:8])));
assign e2 = (&(~(trap_vec_e[7:4])));

trp  trap3( .ptrap_in(ptrap_in_e3[3:0]),
	     .trap_v(trap_vec_e[15:12])
           );
trp  trap2( .ptrap_in(ptrap_in_e2[3:0]),
	     .trap_v(trap_vec_e[11:8])
           );
trp  trap1( .ptrap_in(ptrap_in_e1[3:0]),
	     .trap_v(trap_vec_e[7:4])
           );
trp  trap0( .ptrap_in(ptrap_in_e0[3:0]),
	     .trap_v(trap_vec_e[3:0])
           );

assign ptrap_in_e[15:12] = ptrap_in_e3[3:0];
assign ptrap_in_e[11:8] = ({4{e0}} & ptrap_in_e2[3:0]);
assign ptrap_in_e[7:4] = ({4{c1}} & ptrap_in_e1[3:0]);
assign ptrap_in_e[3:0] = ({4{c2}} & ptrap_in_e0[3:0]);

assign c1 = (e0 & e1) ;
assign c2 = (c1 & e2) ;

endmodule

module trp(ptrap_in,trap_v);
output[3:0] ptrap_in;
input[3:0] trap_v;
reg [3:0] ptrap_in;  
always @(trap_v)
begin
casex(trap_v[3:0])
     4'b1xxx : ptrap_in=4'h8;
     4'b01xx : ptrap_in=4'h4;
     4'b001x : ptrap_in=4'h2;
     4'b0001 : ptrap_in=4'h1;
       default : ptrap_in=4'h0;
endcase
end

endmodule


module buf_64 ( out,in );
output [63:0] out;
input [63:0]  in;

assign out = in ;

endmodule


module multor7 (in, out);
input [6:0] in;
output 	    out;

assign out = |in[6:0];

endmodule


module multfa (ai, bi, ci, so, co);
input 	ai, bi, ci;
output	so, co;

assign {co,so} = ai + bi + ci;

endmodule



module multha (ai, bi, so, co);
input 	ai, bi;
output	so, co;

assign {co,so} = ai + bi;

endmodule


module mppartial (	P0, P1, P2, P3,
			LO, RI,
			SBN, SB, SL0, SL1,
			A0, A1, A2, A3,
			B0, B1, B2, B3);

output P0,P1,P2,P3,LO;
input A0,B0,A1,B1,A2,B2,A3,B3,SBN,SB,RI,SL0,SL1;

reg P0,P1,P2,P3;
wire A3_OUT = SB ? B3:A3;
wire A2_OUT = SB ? B2:A2;
wire A1_OUT = SB ? B1:A1;
wire A0_OUT = SB ? B0:A0;
 
always @(SL0 or SL1 or A3_OUT or A2_OUT or A1_OUT or A0_OUT or RI) begin
  case ({SL0,SL1})
        2'b01:  {P0,P1,P2,P3} = {~RI, ~A0_OUT, ~A1_OUT, ~A2_OUT};
        2'b10:  {P0,P1,P2,P3} = {~A0_OUT, ~A1_OUT, ~A2_OUT, ~A3_OUT};
        2'b00:  {P0,P1,P2,P3} = 4'b1111;
        2'b11:  begin
                   P0 = (A0_OUT | RI) ? 1'b0 : 1'b1;
                   P1 = (A1_OUT | A0_OUT) ? 1'b0 : 1'b1;
                   P2 = (A2_OUT | A1_OUT) ? 1'b0 : 1'b1;
                   P3 = (A3_OUT | A2_OUT) ? 1'b0 : 1'b1;
                end
  endcase
  end
 
assign LO = A3_OUT;
endmodule
 

module adder_33 (op_a, op_b, cin, sum, cout);
 
input  [32:0]  op_a;
input  [32:0]  op_b;
input          cin;
output [32:0]  sum;
output         cout;
 
wire   [32:0]  sum;
 
  assign {cout, sum} = op_a + op_b + cin;
 
endmodule
 


module incre_32 (inp, out);
 
input  [31:0]  inp;
output [31:0]  out;
 
wire   [31:0]  out;
 
  assign out = inp + 1;
 
endmodule
 

module inc16 (ai, sum);
 
input  [15:0]  ai;
output [15:0]  sum;
 
assign  sum[15:0]=ai[15:0]+ 1'b1;
endmodule
 

module inc8 (ai, sum);
 
input  [7:0]  ai;
output [7:0]  sum;
 
assign  sum[7:0]=ai[7:0]+ 1'b1;
endmodule
 
module inc9 (ai, sum);
 
input  [8:0]  ai;
output [8:0]  sum;
 
assign  sum[8:0]=ai[8:0]+ 1'b1;
endmodule
 
 
module fa9 (a, b, c, sum, cout);
 
input  [8:0]  a;
input  [8:0]  b;
output  [8:0]  sum;
 
input           c;              // carry in
output          cout;           // carry out
 
assign {cout,sum} = a + b + c;
 
 
endmodule
 

module buf10_drv_32 (

	in,
	out

);

input	[31:0]	in;
output	[31:0]	out;

	assign	out = in;

endmodule

module inv10_drv_32 (

	in,
	out

);

input	[31:0]	in;
output	[31:0]	out;

	assign	out = ~in;

endmodule

module inv4_drv_32 (

	in,
	out

);

input	[31:0]	in;
output	[31:0]	out;

	assign	out = ~in;

endmodule
