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

module imdr_ctrl (
                  ie_mul_raw_d,
                  ie_div_raw_d,
                  ie_rem_raw_d,
		  kill_inst_e,
                  ie_dataA_d_31,
                  ie_dataB_d_31,
                  pj_hold,
                  reset_l,
                  sm,
                  sin,
		  so,
                  clk,
                  imdr_done_e,
                  imdr_div0_e,

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

input         ie_mul_raw_d;            // imul request, validate operands
input         ie_div_raw_d;            // idiv request, validate operands
input         ie_rem_raw_d;            // irem request, validate operands
input		kill_inst_e;	   // kill the instruction in E stage
input         ie_dataA_d_31;       // ie_data_a_operand bit 31
input         ie_dataB_d_31;       // ie_data_b_operand bit 31
input         pj_hold;             // hold 
input         reset_l;            // reset
input         sm;                  // register scan mode
input         sin;                 // register scan_input
output	      so;		   // register scan output
input         clk;              // clock 
output        imdr_done_e;         // imul or idiv or irem done
output        imdr_div0_e;         // a zero divisor is detected

output  [1:0] sel_rac;             // sel next regster_ac's input
output  [1:0] sel_ra;              // sel next regster_a's  input
output  [1:0] sel_rb;              // sel next regster_b's  input(and rbb)

output        clr_rac;             // clear regster_ac   in next cycle
output        clr_ra2;             // clear regster_a    in next cycle
output        clr_rb;              // clear regster_b    in next cycle
output        clr_rbb;             // clear regster_bb   in next cycle

output        clr_aop_;            // force aop to zroe, active low
output        sel_rem_a;           // select partail remainder as aop
output        sel_mag_a;           // select magnitude of a    as aop

output  [3:0] sel_rsh_b;           // select r_shift amount   for bop
output        sel_rb_b;            // select rb                as bop
output        sel_neg_b;           // select negating the bop

output        sel_sum_a;           // select ra to be complemented 
output        sel_compl_a;         // select    to do complement 
output        sel_sum;             // select sum as the final data output

output        cyc_compare;         // the cycle comparing dataA,B
output        ld_a_oprd0;          // update the a_oprd0  in next cycle
output        ld_b_oprd0;          // update the b_oprd0  in next cycle
output        ld_leading0;         // update the leading0 in next cycle
output        clr_a_oprd0;         // force a_oprd0  = 0
output        clr_b_oprd0;         // force b_oprd0  = 0
output        clr_leading0;        // force leading0 = 0

input         ain_is0;             // a_input from D_stage is 0
input         bin_is0;             // b_input from D_stage is 0
input         div_ovf;             // divide   is overflow
input         leading0_r;          // leading bits of b_operand are 0, reg

output        ld_sign;             // update the leading0 in next cycle
output        clr_sign;            // force aop/bop/out_sign = 0
input         bin_sign;            // b_input sign
input         out_sign;            // final output result sign
input         out_sign_r;          // final output result sign, registered

output        cin;                 // carry-in  for the adder
output        mask32_;             // masking off bop_add[32], active low
output        mul_cmp;             // bufferd mul_e, at the compare cycle
output        div_cmp;             // bufferd rem_e, at the compare cycle
output        rem_cmp;             // bufferd rem_e, at the compare cycle
input         sum_32;              // carray-out of the adder
input         cout;                // carry-out from the adder
input         extreme_1;           // 
input         extreme_2;           // 
input         rem_sum32;           // sum32 && rem_cmp
input         nxt_booth_0;         // Booth recoder value = 0
input         booth_neg;           // Booth recoder negate
input         cur_rbb1;            // current rbb[1]

// -------------- Non-scalable parameters --------------------------------
parameter
  IDLE      = 5'b00001,            // imdr idle
  R_ADDBACK = 5'b00010,            // Remainder last add-back
  L_SUB     = 5'b00100,            // Div/Rem   left-shift by 1, then sub
  L_ADD     = 5'b01000,            // Div/Rem   left-shift by 1, then add
  R_ADD     = 5'b01100,            // multiply  right-shift by 2, then add
  D_POST    = 5'b10100,            // Divide    post complement
  M_POST    = 5'b11000,            // multiply  post complement,  aligned
  PRE_COMPL = 5'b11100;            // data pre-complemented and swapped

parameter
  LAST      = 5'b11111;            // last bit iteration of div/rem.

// -------------- Internal buses -----------------------------------------
wire    [4:0] st;
wire    [4:0] cnt;
reg     [4:0]      nxt_st;
reg     [4:0]      nxt_cnt;

wire          mul_e, div_e, rem_e;
wire		ie_mul_d,ie_div_d,ie_rem_d;

reg     [1:0] sel_rac;
reg     [1:0] sel_ra;
reg     [1:0] sel_rb;

reg           nxt_mul_e, nxt_div_e, nxt_rem_e;

wire	      st_0_l;
wire          d_extreme;
wire          r_extreme;
//  wire          extreme_1;
//  wire          extreme_2;
//  wire          extreme_2;
//  wire          rem_sum32;

wire          r_extreme_r, nxt_r_extreme_r;
wire          d_extreme_r, nxt_d_extreme_r;

wire          nxt_div0_e;
wire          imdr_div0_e;

wire              clr_aop_, sel_rem_a, sel_mag_a, sel_sum_a, sel_compl_a;
wire          nxt_clr_aop_, nxt_rem_a, nxt_mag_a, nxt_sum_a, nxt_compl_a;

wire    [3:0] sel_rsh_b;
wire    [3:0] nxt_rsh_b;

wire          sel_rb_b, sel_neg_b;
wire          nxt_rb_b, nxt_neg_b;
wire		imdr_div0_e_raw;


assign	ie_mul_d = ie_mul_raw_d&~kill_inst_e ;
assign	ie_rem_d = ie_rem_raw_d&~kill_inst_e ;
assign	ie_div_d = ie_div_raw_d&~kill_inst_e ;

// -------------- pipe register input selects ----------------------------
  always @ (reset_l or
            ie_mul_d   or ie_div_d or ie_rem_d or
               mul_e   or    div_e or    rem_e or
            rem_sum32  or
            st         or nxt_st
           ) begin
    if (~reset_l) begin
      sel_rac = 2'b00;
      sel_ra  = 2'b00;
      sel_rb  = 2'b00;
    end // end if
    else begin
      sel_rac =((st==PRE_COMPL) || (/*nxt_st==R_ADDBACK*/nxt_st[1])) &&
                                            (   div_e ||    rem_e) ? 2'b11 :
               !(st==R_ADDBACK) &&          (   div_e ||    rem_e) ? 2'b10 :
               !(st==M_POST)    && (mul_e)                         ? 2'b01 :
                                                                     2'b00;

      sel_ra  = (st==IDLE)   && (ie_mul_d || ie_div_d || ie_rem_d) ? 2'b11 :
                (st==PRE_COMPL) && (mul_e ||    div_e ||rem_sum32) ? 2'b10 :
               ((st==L_SUB) || (st==L_ADD)) && (div_e ||    rem_e) ? 2'b01 :
                                                                     2'b00;
       
      sel_rb  = (st==IDLE)   && (ie_mul_d || ie_div_d || ie_rem_d) ? 2'b11 :
                (st==PRE_COMPL) && (mul_e ||    div_e ||    rem_e) ? 2'b10 :
               !(st==M_POST)    && (mul_e)                         ? 2'b01 :
                                                                     2'b00;
    end // end else
  end // end the always

  assign d_extreme = (st==PRE_COMPL) && div_e &&
                       (div_ovf || bin_is0 || !sum_32);

  assign r_extreme = (st==PRE_COMPL) && rem_e &&
                       (div_ovf || bin_is0 || !sum_32);

//  datapath  assign extreme_1 = (!mul_e && !sum_32);
//  datapath  assign extreme_2 = (!mul_e && div_ovf) || ain_is0 || bin_is0;

//  datapath  assign rem_sum32 = sum_32 && rem_e;

  assign nxt_d_extreme_r = (st==PRE_COMPL) ? d_extreme :
                                             !(st==IDLE)&&d_extreme_r;
  assign nxt_r_extreme_r = (st==PRE_COMPL) ? r_extreme :
                                             !(st==IDLE)&&r_extreme_r;

  assign clr_rac = ~reset_l ||
                   (mul_e ?  (st==PRE_COMPL) : (st==IDLE) );

  assign clr_ra2 = ~reset_l ||
                   (st==PRE_COMPL) &&
                        (bin_is0 ||
//  in datapath      div_e && !sum_32 ||
                         rem_e && div_ovf);

  assign clr_rb  = ~reset_l ||
                   (st==PRE_COMPL) && ain_is0 ||
                   (/*nxt_st==R_ADDBACK*/nxt_st[1]) && cout; // this stage can cut

  assign clr_rbb = ~reset_l;

// -------------- E_stage, A_oprand path ---------------------------------
  assign nxt_clr_aop_  = !(nxt_booth_0 || (nxt_st==M_POST) );
  assign nxt_rem_a     =  (nxt_div_e   ||  nxt_rem_e);
  assign nxt_mag_a     =  (nxt_st==PRE_COMPL);

// -------------- E_stage, B_oprand path ---------------------------------
  assign nxt_rsh_b = (nxt_st==M_POST) ? nxt_cnt[3:0] : 4'b0000;

  assign nxt_rb_b  = (nxt_st==PRE_COMPL)      ||
                     (nxt_div_e || nxt_rem_e) ||
                     (nxt_st==M_POST) && nxt_cnt[4];

  assign nxt_neg_b = (nxt_st==PRE_COMPL) && !ie_dataB_d_31 ||
                     (nxt_st==M_POST)    &&  out_sign && !nxt_rem_e ||
                     (nxt_st==L_SUB);

// -------------- E_stage, final data out --------------------------------
  assign nxt_sum_a   = (nxt_st==R_ADDBACK);

  assign nxt_compl_a = (nxt_st==PRE_COMPL) ? ie_dataA_d_31 :
                       (nxt_div_e && !(d_extreme || d_extreme_r) ||
                        nxt_rem_e && !(r_extreme || r_extreme_r)) && out_sign;

  assign sel_sum     = mul_e ||
                       rem_e && !(st==R_ADDBACK) && !r_extreme_r;

// -------------- E_stage, A, B_operand zero detect ----------------------
//  dpath  assign sel_swap     = (st==PRE_COMPL) && mul_e && !sum_32;
  assign cyc_compare  = (st==PRE_COMPL);
  assign ld_a_oprd0   = (st==PRE_COMPL);
  assign ld_b_oprd0   = (st==PRE_COMPL);
  assign ld_leading0  = (st==PRE_COMPL) || mul_e;
  assign clr_a_oprd0  = (st==IDLE) || ~reset_l;
  assign clr_b_oprd0  = (st==IDLE) || ~reset_l;
  assign clr_leading0 = (st==IDLE) || ~reset_l;

// -------------- E_stage, Booth recoder ---------------------------------
// -------------- E_stage, mag_a,b to a,b_oprd, 32 bits wide -------------
// -------------- Sign bit -----------------------------------------------
  assign ld_sign  = ~reset_l || (st==PRE_COMPL);
  assign clr_sign = ain_is0 || bin_is0 || ~reset_l;
  assign mul_cmp  = (st==PRE_COMPL) && mul_e;
  assign div_cmp  = (st==PRE_COMPL) && div_e;
  assign rem_cmp  = (st==PRE_COMPL) && rem_e;

// -------------- output to ieu ------------------------------------------
// fix timing problem. remove hold from done equation
//  assign imdr_done_e =  (nxt_st[0]);
    assign imdr_done_e =  (st==D_POST) || (st==M_POST) || (st==R_ADDBACK) ||
			  !(ie_mul_raw_d |ie_div_raw_d |ie_rem_raw_d)&&(st==IDLE);

  assign nxt_div0_e  = !(nxt_st==IDLE) && (div_e || rem_e) && bin_is0;

// -------------- carry-in and carry-out for the adder -------------------
  assign cin = (st==PRE_COMPL) && !bin_sign ||            // need early
               (st==R_ADD)  && booth_neg ||
               (st==M_POST) && out_sign_r ||
               (st==L_SUB);
  assign mask32_ = !( (st==M_POST) || (st==PRE_COMPL) );

// -------------- imul/idiv/irem state machine ---------------------------
  always @ (st         or cnt      or cout     or pj_hold or
            ie_mul_d   or ie_div_d or ie_rem_d or 
               mul_e   or    div_e or rem_e    or
            extreme_1 or extreme_2 or
            leading0_r or cur_rbb1) begin 

    nxt_st    = st;
    nxt_cnt   = cnt;
    nxt_mul_e = mul_e;
    nxt_div_e = div_e;
    nxt_rem_e = rem_e;

    case (st)   //synopsys parallel_case
      IDLE     : begin
                   nxt_st    = (ie_mul_d || ie_div_d || ie_rem_d) ?
                                PRE_COMPL : IDLE;
                   nxt_mul_e = ie_mul_d;
                   nxt_div_e = ie_div_d;
                   nxt_rem_e = ie_rem_d;
                 end

      PRE_COMPL: begin
                   nxt_st = (extreme_1 || extreme_2) ? M_POST :
                            (mul_e ? R_ADD : L_SUB); 
                   nxt_cnt =       5'b1;
                 end

      R_ADD    : begin
                   nxt_st = (leading0_r && !cur_rbb1) ? M_POST : R_ADD;
                   nxt_cnt = cnt + !(leading0_r && !cur_rbb1);
                 end

      M_POST   : begin
                   nxt_st    = pj_hold ? M_POST : IDLE;
                 end

      L_SUB    : begin           //if cout=1, R_ADDBACK can be skipped
                   nxt_st = (cnt==LAST) ? (div_e ? D_POST : R_ADDBACK) :
                                          (cout  ? L_SUB  : L_ADD);
                   nxt_cnt = cnt + 5'b1;
                 end

      L_ADD    : begin           //if cout=1, R_ADDBACK can be skipped
                   nxt_st = (cnt==LAST) ? (div_e ? D_POST : R_ADDBACK) :
                                          (cout  ? L_SUB  : L_ADD);
                   nxt_cnt = cnt + 5'b1;
                 end

      D_POST   : begin
                   nxt_st    = pj_hold ? D_POST : IDLE;
                 end

      R_ADDBACK: begin 
                   nxt_st    = pj_hold ? R_ADDBACK : IDLE;
                 end

      default  : begin
                   nxt_st = IDLE;
// synopsys translate_off
/* 
                   if (!($time   ==0))
                     $display("Warning @ %d, imdr_ctrl.v: st reached default!",
                               $time); 
*/
// synopsys translate_on
                 end
    endcase 

  end // end the always, the state machine

// -------------- registers ----------------------------------------------

 ff_sr  ff_ss_0   (
                    .out(sel_mag_a),
                    .din(nxt_mag_a),
                    .reset_l(reset_l),
                    .clk(clk)
                   );

 ff_sr  ff_ss_1   (
                    .out(st_0_l),
                    .din(~nxt_st[0]),
                    .reset_l(reset_l),
                    .clk(clk)
                   );
assign	st[0] = !st_0_l;

 ff_sr_4 ff_sr_4_0 (
                    .out(st[4:1]),
                    .din(nxt_st[4:1]),
                    .reset_l(reset_l),
                    .clk(clk)
                   );

 ff_sr_5 ff_sr_5_0 (
                    .out(cnt),
                    .din(nxt_cnt),
                    .reset_l(reset_l),
                    .clk(clk)
                   );

 ff_sr_3 ff_sr_3_1 ( 
                    .out({    mul_e,    div_e,    rem_e}),
                    .din({nxt_mul_e,nxt_div_e,nxt_rem_e}),
                    .reset_l(reset_l),  
                    .clk(clk)
                   );

 ff_sr_3 ff_sr_3_2 ( 
                    .out({    r_extreme_r,    d_extreme_r,imdr_div0_e_raw}),
                    .din({nxt_r_extreme_r,nxt_d_extreme_r, nxt_div0_e}),
                    .reset_l(reset_l),  
                    .clk(clk)
                   );

assign	imdr_div0_e = imdr_div0_e_raw&(ie_div_d|ie_rem_d);

 ff_sr_4 ff_sr_4_1 (
                    .out({    clr_aop_,sel_rem_a,sel_sum_a,sel_compl_a}),
                    .din({nxt_clr_aop_,nxt_rem_a,nxt_sum_a,nxt_compl_a}),
                    .reset_l(reset_l),
                    .clk(clk)
                   );

 ff_sr_6 ff_sr_6_0 (
                    .out({sel_rsh_b,sel_rb_b,sel_neg_b}),
                    .din({nxt_rsh_b,nxt_rb_b,nxt_neg_b}),
                    .reset_l(reset_l),
                    .clk(clk)
                   );

endmodule


