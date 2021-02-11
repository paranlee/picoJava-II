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

module imdr_dpath (
                   ie_dataA_d,
                   ie_dataB_d,
                   sm,
                   sin,
		   so,
                   clk,
                   imdr_data_out,

                   ie_aop_add,
                   ie_bop_add,
                   ie_cin,
                   ie_use_dpath,
                   imdr_sum,
                   imdr_cout,

                   sel_rac,
                   sel_ra,
                   sel_rb,
                   clr_rac,
                   clr_ra2,
                   clr_rb,
                   clr_rbb,
                   clr_aop_,
                   sel_rem_a,
                   sel_mag_a,
                   sel_rsh_b,
                   sel_rb_b,
                   sel_neg_b,
                   sel_sum_a,
                   sel_compl_a,
                   sel_sum,
                   cyc_compare,
                   ld_a_oprd0,
                   ld_b_oprd0,
                   ld_leading0,
                   clr_a_oprd0,
                   clr_b_oprd0,
                   clr_leading0,
                   ain_is0,
                   bin_is0,
                   div_ovf,
                   leading0_r,
                   ld_sign,
                   clr_sign,
                   bin_sign,
                   out_sign,
                   out_sign_r,
                   cin,
                   mask32_,
                   mul_cmp,
                   div_cmp,
                   rem_cmp,
                   sum_32,
                   cout,
                   extreme_1,
                   extreme_2,
                   rem_sum32,
                   nxt_booth_0,
                   booth_neg,
                   cur_rbb1 
                  );

input  [31:0] ie_dataA_d;          // a_operand, multiplicand or dividend
input  [31:0] ie_dataB_d;          // b_operand, multiplier   or divisor 
input         sm;                  // register scan mode
input         sin;                 // register scan_input
output	      so;		   //  scan out port
input         clk;              // clock 
output [31:0] imdr_data_out;       // imdr resulting data back to stack

// -------------- Ports of the 33-bit adder ------------------------------
input  [32:0] ie_aop_add;          // a-operand       of the 33-bit adder
input  [32:0] ie_bop_add;          // b-operand[31:0] of the 33-bit adder
input         ie_cin;              // carry-in        of the 33-bit adder
input         ie_use_dpath;        // ie uses the adder

output [32:0] imdr_sum;            // sum             of the 33-bit adder
output        imdr_cout;           // carry-out       of the 33-bit adder
// -----------------------------------------------------------------------

input   [1:0] sel_rac;             // sel next regster_ac's input
input   [1:0] sel_ra;              // sel next regster_a's  input
input   [1:0] sel_rb;              // sel next regster_b's  input(and rbb)

input         clr_rac;             // clear regster_ac   in next cycle
input         clr_ra2;             // clear regster_a    in next cycle
input         clr_rb;              // clear regster_b,   in next cycle
input         clr_rbb;             // clear regster_bb   in next cycle

input         clr_aop_;            // force aop to zroe, active low
input         sel_rem_a;           // select partail remainder as aop
input         sel_mag_a;           // select magnitude of a    as aop

input   [3:0] sel_rsh_b;           // select r_shift amount   for bop
input         sel_rb_b;            // select rb                as bop
input         sel_neg_b;           // select negating the bop

input         sel_sum_a;           // select sum to be complemented 
input         sel_compl_a;         // select     to do complement 
input         sel_sum;             // select sum as the final data output

input         cyc_compare;         // the cycle comparing dataA,B
input         ld_a_oprd0;          // update the a_oprd0  in next cycle
input         ld_b_oprd0;          // update the b_oprd0  in next cycle
input         ld_leading0;         // update the leading0 in next cycle
input         clr_a_oprd0;         // force a_oprd0  = 0
input         clr_b_oprd0;         // force b_oprd0  = 0
input         clr_leading0;        // force leading0 = 0

output        ain_is0;             // a_input from D_stage is 0
output        bin_is0;             // b_input from D_stage is 0
output        div_ovf;             // divede   is overflow
output        leading0_r;          // leading bits of b_operand are 0, reg

input         ld_sign;             // update the leading0 in next cycle
input         clr_sign;            // force aop/bop/out_sign = 0
output        bin_sign;            // b_input sign
output        out_sign;            // final output result sign
output        out_sign_r;          // final output result sign, registered

input         cin;                 // carry-in  for the adder
input         mask32_;             // masking off bop_add[32], active low
input         mul_cmp;             // bufferd mul_e, at the compare cycle
input         div_cmp;             // bufferd div_e, at the compare cycle
input         rem_cmp;             // bufferd rem_e, at the compare cycle
output        sum_32;              // carry-out of the adder
output        cout;                // carry-out from the adder
output        extreme_1;           //
output        extreme_2;           //
output        rem_sum32;           // sum32 && rem_cmp
output        nxt_booth_0;         // Booth recoder value = 0
output        booth_neg;           // Booth recoder negate
output        cur_rbb1;            // current rbb[1]

// -------------- Internal buses -----------------------------------------
wire   [32:0] rac;
wire   [31:0]          ra,     rb,rbb, nxt_rbb;
wire   [32:0] sum          ;
wire   [31:0]          sum_;
wire   [31:0] a_oprd,  b_oprd;

wire   [32:0] aop_1x, ra_booth, a_mcand, aop_, aop_add;

wire   [32:0] bop_rsh;
wire   [31:0] bop_add;

wire   [31:0] mag_a, mag_b, mag_a_, mag_b_;

wire          mask_b32;

wire   [32:0] inp3_rac;

wire          inp3_rac1;

wire          booth_2, bop_add32;

wire          sel_swap;            // swap dataA,B

wire          sum_32;

wire          clr_ra;

wire          extreme_1, extreme_2, rem_sum32;

wire          sel_sum_a_buf;

// -------------- Muxing ie and imul/idiv/irem of the adder --------------
wire   [32:0] mux_bop_add;
wire          mux_cin;
 
  assign mux_cin     = ie_use_dpath ? ie_cin     : cin;
 
  assign imdr_sum    = sum;
  assign imdr_cout   = cout;
// -----------------------------------------------------------------------

// -------------- E_stage pipe registers ---------------------------------
  assign inp3_rac1 = mag_a[31];
//   assign inp3_rac = sel_mag_a ? ({{31{1'b0}},inp3_rac1,mag_a[30]}) : sum;
  mx2_33 mx2_33_a (
                   .inp1({{31{1'b0}},inp3_rac1,mag_a[30]}),
                   .inp0(sum),
                   .sel(sel_mag_a),
                   .out(inp3_rac)
                  );

  mx4_clr_reg_33 mx4_clr_reg_33_ac (
                                    .inp3(inp3_rac),
                                    .inp2({sum[31:0],ra[29]}),
                                    .inp1({{2{sum[32]}},sum[32:2]}),
                                    .inp0(rac),
                                    .sel(sel_rac),
                                    .clr(clr_rac),
                                    .clk(clk),
                                    .out(rac)
                                   );

  mx4_clr_reg_32 mx4_clr_reg_32_a  ( 
                                    .inp3(ie_dataA_d), 
                                    .inp2(a_oprd),
                                    .inp1({1'b0,ra[29:0],cout}),
                                    .inp0(ra),
                                    .sel(sel_ra),    
                                    .clr(clr_ra),
                                    .clk(clk),
                                    .out(ra)
                                   );

  mx4_clr_reg_32 mx4_clr_reg_32_b  ( 
                                    .inp3(ie_dataB_d), 
                                    .inp2(b_oprd), 
                                    .inp1({sum[1:0],rb[31:2]}),
                                    .inp0(rb),
                                    .sel(sel_rb),     
                                    .clr(clr_rb), 
                                    .clk(clk), 
                                    .out(rb)   
                                   );

  mx4_clr_reg_nxt_32 mx4_clr_reg_nxt_32_bb ( 
                                    .inp3({32{1'b0}}),  
                                    .inp2(b_oprd),  
                                    .inp1({2'b0,rbb[31:2]}),
                                    .inp0(rbb),
                                    .sel(sel_rb),      
                                    .clr(clr_rbb),  
                                    .clk(clk),  
                                    .out(rbb),
                                    .nxt_out(nxt_rbb)    
                                   );

// -------------- E_stage, A_oprand path ---------------------------------
//   assign aop_1x = {1'b0, ({32{clr_aop_}}&ra) };
  an2_32 an2_32_0 (.inp1({32{clr_aop_}}), .inp0(ra), .out(aop_1x[31:0]) );

  mx2_33 mx2_33_b (
                   .inp1({ra[31:0],1'b0}),
                   .inp0({1'b0,aop_1x[31:0]}),
                   .sel(booth_2),
                   .out(ra_booth)
                  );

//   assign mux_aop_add = ie_use_dpath ? ie_aop_add : ra_booth;

  mx2_neg_33 mx2_neg_33_a (
                           .inp1(ie_aop_add),
                           .inp0(ra_booth),
                           .sel(ie_use_dpath),
                           .neg(booth_neg),
                           .out(a_mcand)
                          );

//   assign aop_    = ~(sel_rem_a ? rac           : a_mcand); 
//   assign aop_add = ~(sel_mag_a ? {1'b1,mag_a_} : aop_);

  mx2i_33 mx2i_33_a (
                     .inp1(rac),
                     .inp0(a_mcand),
                     .sel(sel_rem_a),
                     .out_(aop_)
                    );

  mx2i_b_33 mx2i_b_33_b (
                     .inp1({1'b1,mag_a_}),
                     .inp0(aop_),
                     .sel(sel_mag_a),
                     .out_(aop_add)
                    );

// -------------- E_stage, B_oprand path ---------------------------------
  rsh16_33 rsh16_33_b (
                       .hi(rac),
                       .lo(rb),
                       .rsh(sel_rsh_b),
                       .out(bop_rsh)
                      );

//   assign mux_bop_add = ie_use_dpath ? ie_bop_add : {mask_b32,bop_add};
  mx2_33 mx2_33_c (
                   .inp1(ie_bop_add),
                   .inp0({1'b0,rb}),
                   .sel(ie_use_dpath),
                   .out(mux_bop_add)
                  );

  mx2_neg_33 mx2_neg_33_b (
                           .inp1(mux_bop_add),
                           .inp0(bop_rsh),
                           .sel(sel_rb_b),
                           .neg(sel_neg_b),
                           .out({bop_add32,bop_add[31:0]})
                          );

// -------------- E_stage, final data out --------------------------------
  assign mask_b32 = mask32_ && bop_add32;

  adder_33 adder_33_0 (
                       .op_a(aop_add),
                       .op_b({mask_b32,bop_add[31:0]}),
                       .cin(mux_cin),
                       .sum(sum),
                       .cout(cout)
                      );

  mx2_compl_32 mx2_compl_32_a (
                               .inp1(sum[31:0]),
                               .inp0(ra),
                               .sel(sel_sum_a_buf),
                               .compl(sel_compl_a),
                               .out_(mag_a_)
                              );

//   assign sum_ = ~sum[31:0];
  inv1_32 inv1_32_a (.inp(sum[31:0]), .out_(sum_) );

//   assign imdr_data_out = ~(sel_sum ? sum_ : mag_a_);
  mx2i_32 mx2i_32_a (
                     .inp1(sum_),
                     .inp0(mag_a_),
                     .sel(sel_sum),
                     .out_(imdr_data_out)
                    );

// -------------- E_stage, A, B_operand zero detect ----------------------

  assign mag_a = ~mag_a_;
  assign mag_b = ~mag_b_;

  zero_det zero_det_0 (
                       .mag_a(mag_a),
                       .mag_b(mag_b),
                       .nxt_rbb(nxt_rbb),
                       .sel_swap(sel_swap),
                       .cyc_compare(cyc_compare),
                       .mul_cmp(mul_cmp),
                       .ld_a_oprd0(ld_a_oprd0),
                       .ld_b_oprd0(ld_b_oprd0),
                       .ld_leading0(ld_leading0),
                       .clr_a_oprd0(clr_a_oprd0),
                       .clr_b_oprd0(clr_b_oprd0),
                       .clk(clk),
                       .ain_is0(ain_is0),
                       .bin_is0(bin_is0),
                       .div_ovf(div_ovf),
                       .extreme_2(extreme_2),
                       .leading0_r(leading0_r)
                      );

// -------------- E_stage, Booth recoder ---------------------------------
  b_recoder b_recoder_0 (
                         .mag_a(mag_a[1:0]),
                         .mag_b(mag_b[1:0]),
                         .nxt_rbb10(nxt_rbb[1:0]),
                         .cur_rbb1(cur_rbb1),
                         .sel_swap(sel_swap),
                         .cyc_compare(cyc_compare),
                         .clr(clr_rb),
                         .clk(clk),
                         .nxt_booth_0(nxt_booth_0),
                         .booth_2(booth_2),
                         .booth_neg(booth_neg)
                        );

// -------------- E_stage, mag_a,b to a,b_oprd, 32 bits wide -------------
  compl_32 compl_32_b (
                       .inp(rb),
                       .compl(bin_sign),
                       .out_(mag_b_)
                      );

//   assign a_oprd = ~(sel_swap ? mag_b_ : mag_a_);
//   assign b_oprd = ~(sel_swap ? mag_a_ : mag_b_);

  mx2i_32 mx2i_32_b (
                     .inp1(mag_b_),
                     .inp0(mag_a_),
                     .sel(sel_swap),
                     .out_(a_oprd)
                    );
 
  mx2i_b_32 mx2i_b_32_c (
                     .inp1(mag_a_),
                     .inp0(mag_b_),
                     .sel(sel_swap),
                     .out_(b_oprd)
                    );

// -------------- Sign bit -----------------------------------------------
sign_bit sign_bit_0 (
                     .ra_31(ra[31]),
                     .rb_31(rb[31]),
                     .ld_sign(ld_sign),
                     .clr_sign(clr_sign),
                     .rem_cmp(rem_cmp),
                     .clk(clk),
                     .bin_sign(bin_sign),
                     .out_sign(out_sign),
                     .out_sign_r(out_sign_r)
                    );

// -------------- Buffered to control ------------------------------------
/*
  assign cur_rbb1      = rbb[1];
  assign sum_32        = sum[32];
  assign sel_sum_a_buf = sel_sum_a;

  assign sel_swap  =  !(sum[32] || !mul_cmp);
  assign rem_sum32 =   (sum[32] &&  rem_cmp);
  assign extreme_1 =  !(sum[32] ||  mul_cmp);
  assign clr_ra    = !((sum[32] || !div_cmp) && !clr_ra2);

*/

dpath_ctrl dpath_ctrl_0 (
                         .sum32(sum[32]),
                         .rbb1(rbb[1]),
                         .mul_cmp(mul_cmp),
                         .div_cmp(div_cmp),
                         .rem_cmp(rem_cmp),
                         .clr_ra2(clr_ra2),
                         .sel_sum_a(sel_sum_a),
                         .sel_swap(sel_swap),
                         .rem_sum32(rem_sum32),
                         .extreme_1(extreme_1),
                         .cur_rbb1(cur_rbb1),
                         .sum_32(sum_32),
                         .clr_ra(clr_ra),
                         .sel_sum_a_buf(sel_sum_a_buf)
                        );

endmodule

