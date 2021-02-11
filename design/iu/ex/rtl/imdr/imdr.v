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

module imdr (
             ie_mul_d,
             ie_div_d,
             ie_rem_d,
             kill_inst_e,
             ie_dataA_d,
             ie_dataB_d,
             pj_hold,
             reset_l,
             sm,
             sin,
	     so,
             clk,
             imdr_done_e,
             imdr_div0_e,
             imdr_data_out
            );

input         ie_mul_d;            // imul request, validate operands
input         ie_div_d;            // idiv request, validate operands
input         ie_rem_d;            // irem request, validate operands
input	      kill_inst_e;	   // kill the instruction in E stage
input  [31:0] ie_dataA_d;          // a_operand, multiplicand or dividend
input  [31:0] ie_dataB_d;          // b_operand, multiplier   or divisor 
input         pj_hold;             // hold 
input         reset_l;            // reset 
input         sm;                  // register scan mode
input         sin;                 // register scan_input
output	      so;		   // scan out port  
input         clk;              // clock 

output        imdr_done_e;         // imul or idiv or irem done
output        imdr_div0_e;         // a zero divisor is detected
output [31:0] imdr_data_out;       // imdr resulting data back to stack

// -------------- Ports of the 33-bit adder ------------------------------
wire  [32:0] ie_aop_add;          // a-operand       of the 33-bit adder
wire  [32:0] ie_bop_add;          // b-operand[31:0] of the 33-bit adder
wire         ie_cin;              // carry-in        of the 33-bit adder
wire         ie_use_dpath = 1'b0;        // ie uses the adder

wire [32:0] imdr_sum;            // sum             of the 33-bit adder
wire        imdr_cout;           // carry-out       of the 33-bit adder

// -------------- Internal buses -----------------------------------------
wire    [1:0] sel_rac, sel_ra, sel_rb;

wire          clr_rac, clr_ra2, clr_rb, clr_rbb;
wire          clr_aop_, sel_rem_a, sel_mag_a;
wire    [3:0] sel_rsh_b;
wire          sel_rb_b, sel_neg_b;
wire          sel_sum_a, sel_compl_a, sel_sum;
wire          cyc_compare;
wire          ld_a_oprd0, ld_b_oprd0, ld_leading0;
wire          clr_a_oprd0, clr_b_oprd0, clr_leading0;
wire          ain_is0, bin_is0, div_ovf, leading0_r;
wire          ld_sign, clr_sign, bin_sign, out_sign, out_sign_r;
wire          cin, mask32_, mul_cmp, div_cmp, rem_cmp, cout;
wire          extreme_1, extreme_2, rem_sum32;
wire          nxt_booth_0, booth_neg, cur_rbb1;

// -------------- imdr datapath ------------------------------------------
imdr_dpath imdr_dpath_0 (
                   .ie_dataA_d(ie_dataA_d),
                   .ie_dataB_d(ie_dataB_d),
                   .sm(),
                   .sin(),
		   .so(),
                   .clk(clk),
                   .imdr_data_out(imdr_data_out),

                   .ie_aop_add(ie_aop_add),
                   .ie_bop_add(ie_bop_add),
                   .ie_cin(ie_cin),
                   .ie_use_dpath(ie_use_dpath),
                   .imdr_sum(imdr_sum),
                   .imdr_cout(imdr_cout),

                   .sel_rac(sel_rac),
                   .sel_ra(sel_ra),
                   .sel_rb(sel_rb),
                   .clr_rac(clr_rac),
                   .clr_ra2(clr_ra2),
                   .clr_rb(clr_rb),
                   .clr_rbb(clr_rbb),
                   .clr_aop_(clr_aop_),
                   .sel_rem_a(sel_rem_a),
                   .sel_mag_a(sel_mag_a),
                   .sel_rsh_b(sel_rsh_b),
                   .sel_rb_b(sel_rb_b),
                   .sel_neg_b(sel_neg_b),
                   .sel_sum_a(sel_sum_a),
                   .sel_compl_a(sel_compl_a),
                   .sel_sum(sel_sum),
                   .cyc_compare(cyc_compare),
                   .ld_a_oprd0(ld_a_oprd0),
                   .ld_b_oprd0(ld_b_oprd0),
                   .ld_leading0(ld_leading0),
                   .clr_a_oprd0(clr_a_oprd0),
                   .clr_b_oprd0(clr_b_oprd0),
                   .clr_leading0(clr_leading0),
                   .ain_is0(ain_is0),
                   .bin_is0(bin_is0),
                   .div_ovf(div_ovf),
                   .leading0_r(leading0_r),
                   .ld_sign(ld_sign),
                   .clr_sign(clr_sign),
                   .bin_sign(bin_sign),
                   .out_sign(out_sign),
                   .out_sign_r(out_sign_r),
                   .cin(cin),
                   .mask32_(mask32_),
                   .mul_cmp(mul_cmp),
                   .div_cmp(div_cmp),
                   .rem_cmp(rem_cmp),
                   .sum_32(sum_32),
                   .cout(cout),
                   .extreme_1(extreme_1),
                   .extreme_2(extreme_2),
                   .rem_sum32(rem_sum32),
                   .nxt_booth_0(nxt_booth_0),
                   .booth_neg(booth_neg),
                   .cur_rbb1(cur_rbb1) 
                  );

// -------------- imdr control -------------------------------------------
imdr_ctrl imdr_ctrl_0 (
                  .ie_mul_raw_d(ie_mul_d),
                  .ie_div_raw_d(ie_div_d),
                  .ie_rem_raw_d(ie_rem_d),
		  .kill_inst_e(kill_inst_e),
                  .ie_dataA_d_31(ie_dataA_d[31]),
                  .ie_dataB_d_31(ie_dataB_d[31]),
                  .pj_hold(pj_hold),
                  .reset_l(reset_l),
                  .sm(),
                  .sin(),
                  .so(),
                  .clk(clk),
                  .imdr_done_e(imdr_done_e), 
                  .imdr_div0_e(imdr_div0_e),
 
                  .sel_rac(sel_rac),
                  .sel_ra(sel_ra),
                  .sel_rb(sel_rb),
                  .clr_rac(clr_rac),
                  .clr_ra2(clr_ra2),
                  .clr_rb(clr_rb),
                  .clr_rbb(clr_rbb),
                  .clr_aop_(clr_aop_),
                  .sel_rem_a(sel_rem_a),
                  .sel_mag_a(sel_mag_a),
                  .sel_rsh_b(sel_rsh_b),
                  .sel_rb_b(sel_rb_b),
                  .sel_neg_b(sel_neg_b),
                  .sel_sum_a(sel_sum_a),
                  .sel_compl_a(sel_compl_a),
                  .sel_sum(sel_sum),
                  .cyc_compare(cyc_compare),
                  .ld_a_oprd0(ld_a_oprd0),
                  .ld_b_oprd0(ld_b_oprd0),
                  .ld_leading0(ld_leading0),
                  .clr_a_oprd0(clr_a_oprd0),
                  .clr_b_oprd0(clr_b_oprd0),
                  .clr_leading0(clr_leading0),
                  .ain_is0(ain_is0),
                  .bin_is0(bin_is0),
                  .div_ovf(div_ovf),
                  .leading0_r(leading0_r),
                  .ld_sign(ld_sign),
                  .clr_sign(clr_sign),
                  .bin_sign(bin_sign),
                  .out_sign(out_sign),
                  .out_sign_r(out_sign_r),
                  .cin(cin),
                  .mask32_(mask32_),
                  .mul_cmp(mul_cmp),
                  .div_cmp(div_cmp),
                  .rem_cmp(rem_cmp),
                  .sum_32(sum_32),
                  .cout(cout),
                  .extreme_1(extreme_1),
                  .extreme_2(extreme_2),
                  .rem_sum32(rem_sum32),
                  .nxt_booth_0(nxt_booth_0),
                  .booth_neg(booth_neg),
                  .cur_rbb1(cur_rbb1) 
                  );

endmodule

