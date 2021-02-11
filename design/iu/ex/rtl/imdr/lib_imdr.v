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

// --------- Right shift 16 ~ 1, 32 bits wide ----------------------------

module rsh16_33 (hi, lo,
                 rsh, out);  
  
input  [32:0]  hi;
input  [31:0]  lo;
input   [3:0]  rsh; 
output [32:0]  out; 
 
/*  Logic 
  always @(hi or lo or rsh)
    case (rsh)   
      4'b0000: out = {hi[32:0]           };
      4'b0001: out = {hi[30:0], lo[31:30]};
      4'b0010: out = {hi[28:0], lo[31:28]};
      4'b0011: out = {hi[26:0], lo[31:26]};
      4'b0100: out = {hi[24:0], lo[31:24]};
      4'b0101: out = {hi[22:0], lo[31:22]};
      4'b0110: out = {hi[20:0], lo[31:20]};
      4'b0111: out = {hi[18:0], lo[31:18]};
      4'b1000: out = {hi[16:0], lo[31:16]};
      4'b1001: out = {hi[14:0], lo[31:14]};
      4'b1010: out = {hi[12:0], lo[31:12]};
      4'b1011: out = {hi[10:0], lo[31:10]};
      4'b1100: out = {hi[8:0],  lo[31:8]};
      4'b1101: out = {hi[6:0],  lo[31:6]};
      4'b1110: out = {hi[4:0],  lo[31:4]};
      4'b1111: out = {hi[2:0],  lo[31:2]};
    endcase
*/

  mx16_1 mx16_1_32 (
       .i15(hi[2]    ), .i14(hi[4]    ), .i13(hi[6]    ), .i12(hi[8]    ),
       .i11(hi[10]   ), .i10(hi[12]   ), .i9(hi[14]   ),  .i8(hi[16]   ),    
       .i7(hi[18]   ),  .i6(hi[20]   ),  .i5(hi[22]   ),  .i4(hi[24]   ),
       .i3(hi[26]   ),  .i2(hi[28]   ),  .i1(hi[30]   ),  .i0(hi[32]   ),
                    .sel(rsh),    
                    .out(out[32]   )
                   );

  mx16_2 mx16_2_30 (
       .i15(hi[1:0]  ), .i14(hi[3:2]  ), .i13(hi[5:4]  ), .i12(hi[7:6]  ),   
       .i11(hi[9:8]  ), .i10(hi[11:10]), .i9(hi[13:12]),  .i8(hi[15:14]),    
       .i7(hi[17:16]),  .i6(hi[19:18]),  .i5(hi[21:20]),  .i4(hi[23:22]),    
       .i3(hi[25:24]),  .i2(hi[27:26]),  .i1(hi[29:28]),  .i0(hi[31:30]),    
                    .sel(rsh),   
                    .out(out[31:30])
                   );

  mx16_2 mx16_2_28 (
       .i15(lo[31:30]), .i14(hi[1:0]  ), .i13(hi[3:2]  ), .i12(hi[5:4]  ),   
       .i11(hi[7:6]  ), .i10(hi[9:8]  ), .i9(hi[11:10]),  .i8(hi[13:12]),   
       .i7(hi[15:14]),  .i6(hi[17:16]),  .i5(hi[19:18]),  .i4(hi[21:20]),   
       .i3(hi[23:22]),  .i2(hi[25:24]),  .i1(hi[27:26]),  .i0(hi[29:28]),   
                    .sel(rsh),  
                    .out(out[29:28])
                   );

  mx16_2 mx16_2_26 (
       .i15(lo[29:28]), .i14(lo[31:30]), .i13(hi[1:0]  ), .i12(hi[3:2]  ),  
       .i11(hi[5:4]  ), .i10(hi[7:6]  ), .i9(hi[9:8]  ),  .i8(hi[11:10]),  
       .i7(hi[13:12]),  .i6(hi[15:14]),  .i5(hi[17:16]),  .i4(hi[19:18]),  
       .i3(hi[21:20]),  .i2(hi[23:22]),  .i1(hi[25:24]),  .i0(hi[27:26]),  
                    .sel(rsh), 
                    .out(out[27:26])
                   );

  mx16_2 mx16_2_24 (
       .i15(lo[27:26]), .i14(lo[29:28]), .i13(lo[31:30]), .i12(hi[1:0]  ), 
       .i11(hi[3:2]  ), .i10(hi[5:4]  ), .i9(hi[7:6]  ),  .i8(hi[9:8]  ), 
       .i7(hi[11:10]),  .i6(hi[13:12]),  .i5(hi[15:14]),  .i4(hi[17:16]), 
       .i3(hi[19:18]),  .i2(hi[21:20]),  .i1(hi[23:22]),  .i0(hi[25:24]), 
                    .sel(rsh),
                    .out(out[25:24])
                   );

  mx16_2 mx16_2_22 (
       .i15(lo[25:24]), .i14(lo[27:26]), .i13(lo[29:28]), .i12(lo[31:30]),
       .i11(hi[1:0]  ), .i10(hi[3:2]  ), .i9(hi[5:4]  ),  .i8(hi[7:6]  ),
       .i7(hi[9:8]  ),  .i6(hi[11:10]),  .i5(hi[13:12]),  .i4(hi[15:14]),
       .i3(hi[17:16]),  .i2(hi[19:18]),  .i1(hi[21:20]),  .i0(hi[23:22]),
                    .sel(rsh),
                    .out(out[23:22])
                   );

  mx16_2 mx16_2_20 (
       .i15(lo[23:22]), .i14(lo[25:24]), .i13(lo[27:26]), .i12(lo[29:28]),
       .i11(lo[31:30]), .i10(hi[1:0]  ), .i9(hi[3:2]  ),  .i8(hi[5:4]  ),    
       .i7(hi[7:6]  ),  .i6(hi[9:8]  ),  .i5(hi[11:10]),  .i4(hi[13:12]),
       .i3(hi[15:14]),  .i2(hi[17:16]),  .i1(hi[19:18]),  .i0(hi[21:20]),    
                    .sel(rsh),     
                    .out(out[21:20])
                   );

  mx16_2 mx16_2_18 (
       .i15(lo[21:20]), .i14(lo[23:22]), .i13(lo[25:24]), .i12(lo[27:26]),   
       .i11(lo[29:28]), .i10(lo[31:30]), .i9(hi[1:0]  ),  .i8(hi[3:2]  ),   
       .i7(hi[5:4]  ),  .i6(hi[7:6]  ),  .i5(hi[9:8]  ),  .i4(hi[11:10]),    
       .i3(hi[13:12]),  .i2(hi[15:14]),  .i1(hi[17:16]),  .i0(hi[19:18]),   
                    .sel(rsh),    
                    .out(out[19:18])
                   );

  mx16_2 mx16_2_16 (
       .i15(lo[19:18]), .i14(lo[21:20]), .i13(lo[23:22]), .i12(lo[25:24]),  
       .i11(lo[27:26]), .i10(lo[29:28]), .i9(lo[31:30]),  .i8(hi[1:0]  ),  
       .i7(hi[3:2]  ),  .i6(hi[5:4]  ),  .i5(hi[7:6]  ),  .i4(hi[9:8]  ),   
       .i3(hi[11:10]),  .i2(hi[13:12]),  .i1(hi[15:14]),  .i0(hi[17:16]),   
                    .sel(rsh),   
                    .out(out[17:16])
                   );

  mx16_2 mx16_2_14 (
       .i15(lo[17:16]), .i14(lo[19:18]), .i13(lo[21:20]), .i12(lo[23:22]), 
       .i11(lo[25:24]), .i10(lo[27:26]), .i9(lo[29:28]),  .i8(lo[31:30]),  
       .i7(hi[1:0]  ),  .i6(hi[3:2]  ),  .i5(hi[5:4]  ),  .i4(hi[7:6]  ),  
       .i3(hi[9:8]  ),  .i2(hi[11:10]),  .i1(hi[13:12]),  .i0(hi[15:14]),  
                    .sel(rsh),
                    .out(out[15:14])
                   );

  mx16_2 mx16_2_12 (
       .i15(lo[15:14]), .i14(lo[17:16]), .i13(lo[19:18]), .i12(lo[21:20]), 
       .i11(lo[23:22]), .i10(lo[25:24]), .i9(lo[27:26]),  .i8(lo[29:28]), 
       .i7(lo[31:30]),  .i6(hi[1:0]  ),  .i5(hi[3:2]  ),  .i4(hi[5:4]  ), 
       .i3(hi[7:6]  ),  .i2(hi[9:8]  ),  .i1(hi[11:10]),  .i0(hi[13:12]), 
                    .sel(rsh), 
                    .out(out[13:12]) 
                   );

  mx16_2 mx16_2_10 (
       .i15(lo[13:12]), .i14(lo[15:14]), .i13(lo[17:16]), .i12(lo[19:18]),
       .i11(lo[21:20]), .i10(lo[23:22]), .i9(lo[25:24]),  .i8(lo[27:26]),
       .i7(lo[29:28]),  .i6(lo[31:30]),  .i5(hi[1:0]  ),  .i4(hi[3:2]  ),
       .i3(hi[5:4]  ),  .i2(hi[7:6]  ),  .i1(hi[9:8]  ),  .i0(hi[11:10]),
                    .sel(rsh),
                    .out(out[11:10])
                   );

  mx16_2 mx16_2_08 (
       .i15(lo[11:10]), .i14(lo[13:12]), .i13(lo[15:14]), .i12(lo[17:16]),
       .i11(lo[19:18]), .i10(lo[21:20]), .i9(lo[23:22]),  .i8(lo[25:24]),
       .i7(lo[27:26]),  .i6(lo[29:28]),  .i5(lo[31:30]),  .i4(hi[1:0]  ),
       .i3(hi[3:2]  ),  .i2(hi[5:4]  ),  .i1(hi[7:6]  ),  .i0(hi[9:8]),
                    .sel(rsh),
                    .out(out[9:8])
                   );

  mx16_2 mx16_2_06 (
       .i15(lo[9:8]  ), .i14(lo[11:10]), .i13(lo[13:12]), .i12(lo[15:14]),
       .i11(lo[17:16]), .i10(lo[19:18]), .i9(lo[21:20]),  .i8(lo[23:22]),
       .i7(lo[25:24]),  .i6(lo[27:26]),  .i5(lo[29:28]),  .i4(lo[31:30]),
       .i3(hi[1:0]  ),  .i2(hi[3:2]  ),  .i1(hi[5:4]  ),  .i0(hi[7:6]),
                    .sel(rsh),  
                    .out(out[7:6])
                   );

  mx16_2 mx16_2_04 (
       .i15(lo[7:6]  ), .i14(lo[9:8]  ), .i13(lo[11:10]), .i12(lo[13:12]), 
       .i11(lo[15:14]), .i10(lo[17:16]), .i9(lo[19:18]),  .i8(lo[21:20]), 
       .i7(lo[23:22]),  .i6(lo[25:24]),  .i5(lo[27:26]),  .i4(lo[29:28]), 
       .i3(lo[31:30]),  .i2(hi[1:0]  ),  .i1(hi[3:2]  ),  .i0(hi[5:4]),
                    .sel(rsh), 
                    .out(out[5:4])
                   );

  mx16_2 mx16_2_02 (
       .i15(lo[5:4]  ), .i14(lo[7:6]  ), .i13(lo[9:8]  ), .i12(lo[11:10]),
       .i11(lo[13:12]), .i10(lo[15:14]), .i9(lo[17:16]),  .i8(lo[19:18]),
       .i7(lo[21:20]),  .i6(lo[23:22]),  .i5(lo[25:24]),  .i4(lo[27:26]),
       .i3(lo[29:28]),  .i2(lo[31:30]),  .i1(hi[1:0]  ),  .i0(hi[3:2]),
                    .sel(rsh),
                    .out(out[3:2])
                   );

  mx16_2 mx16_2_00 (
       .i15(lo[3:2]  ), .i14(lo[5:4]  ), .i13(lo[7:6]  ), .i12(lo[9:8]  ),
       .i11(lo[11:10]), .i10(lo[13:12]), .i9(lo[15:14]),  .i8(lo[17:16]),
       .i7(lo[19:18]),  .i6(lo[21:20]),  .i5(lo[23:22]),  .i4(lo[25:24]),
       .i3(lo[27:26]),  .i2(lo[29:28]),  .i1(lo[31:30]),  .i0(hi[1:0]),
                    .sel(rsh), 
                    .out(out[1:0])
                   );
 
endmodule

// --------- complementor, 32 bits wide ----------------------------------
module compl_32 (inp, compl, out_);

input  [31:0]  inp;
input          compl;
output [31:0]  out_;

wire   [31:0]  out_;
wire   [31:0]  incre;

  incre_32 incre_32_0 (
                       .inp(~inp),
                       .out(incre)
                      );

/*  Logic 
  assign out_ = ~(compl ? incre : inp);
*/

  mx2i_32 mx2i_32_a (
                     .inp1(incre),
                     .inp0(inp),
                     .sel(compl),
                     .out_(out_)
                    );
  
endmodule

// --------- mux2, complementor, 32 bits wide ----------------------------
module mx2_compl_32 (inp1, inp0, sel, compl, out_);
 
input  [31:0]  inp1;
input  [31:0]  inp0;
input          sel;
input          compl;
output [31:0]  out_;
 
wire   [31:0]  out_; 
wire   [31:0]  mux_1_;
wire   [31:0]  incre;

/*  Logic 
  assign mux_1_ = ~(sel ? inp1 : inp0); 
*/

  mx2i_b_32 mx2i_b_32_a (
                     .inp1(inp1),
                     .inp0(inp0),
                     .sel(sel),
                     .out_(mux_1_)
                    );

  incre_32 incre_32_0 (
                       .inp(mux_1_),
                       .out(incre)
                      );
 
/*  Logic 
  assign out_   = ~( compl ? incre : (~mux_1_) ); 
*/

  mx2i_b_32 mx2i_b_32_b (
                     .inp1(incre),
                     .inp0(~mux_1_),
                     .sel(compl),
                     .out_(out_)
                    );
   
endmodule

// --------- mux2, negate, 33 bits wide ----------------------------------
module mx2_neg_33 (inp1, inp0,
                   sel,  neg,  out);
 
input  [32:0]  inp1;
input  [32:0]  inp0;
input          sel;
input          neg;
output [32:0]  out;
 
wire   [32:0]  out; 
wire   [32:0]  mux_1_;
 
/*  Logic 
  assign mux_1_ = ~(sel ?   inp1  : inp0);
  assign out    = ~(neg ? ~mux_1_ : mux_1_);
*/

  mx2i_33 mx2i_33_a (
                     .inp1(inp1),
                     .inp0(inp0),
                     .sel(sel),
                     .out_(mux_1_)
                    );

  mx2i_33 mx2i_33_b (  
                     .inp1(~mux_1_),
                     .inp0(mux_1_),
                     .sel(neg),
                     .out_(out)
                    );
 
endmodule  

// --------- mux4, clear, register, 33 bits wide -------------------------
module mx4_clr_reg_33 (inp3, inp2, inp1, inp0,
                       sel,  clr,  clk,  out);
 
input  [32:0]  inp3;
input  [32:0]  inp2;
input  [32:0]  inp1;
input  [32:0]  inp0;
input  [1:0]   sel;
input          clr;
input          clk;
output [32:0]  out;

wire   [32:0]  mux_1;
wire   [32:0]  next;
wire   [32:0]  out;
 
/*  Logic 
  always @(inp3 or inp2 or inp1 or inp0 or sel)
    case (sel)
      2'b00: mux_1 = inp0;
      2'b01: mux_1 = inp1;
      2'b10: mux_1 = inp2;
      2'b11: mux_1 = inp3;
      default: mux_1 = inp0;
    endcase  
*/

 mx4_33 mx4_33_a (
                  .inp0(inp0),
                  .inp1(inp1),
                  .inp2(inp2),
                  .inp3(inp3),
                  .sel(sel),
                  .out(mux_1)
                 );

/*  Logic
  assign next = {33{!clr}} & mux_1;
*/

 an2_33 an2_33_a (
                  .inp1(mux_1),
                  .inp0({33{!clr}}),
                  .out(next)
                 );

/*  Logic   
  always @(posedge clk)
     out <= (sm ? {33{sin}} : next);
*/

/*  gate flip-flop */
  ff_s_33 ff_s_33_a (
                     .out(out),
                     .din(next),
                     .clk(clk)
                    );
 
endmodule

// --------- mux4, clear, register, 32 bits wide -------------------------
module mx4_clr_reg_32 (inp3, inp2, inp1, inp0,
                       sel,  clr, clk,  out);
 
input  [31:0]  inp3;
input  [31:0]  inp2;
input  [31:0]  inp1;
input  [31:0]  inp0;
input  [1:0]   sel;
input          clr;
input          clk;
output [31:0]  out;

wire   [31:0]  mux_1;
wire   [31:0]  next;
wire   [31:0]  out;
 
/*  Logic 
  always @(inp3 or inp2 or inp1 or inp0 or sel)
    case (sel)
      2'b00: mux_1 = inp0;
      2'b01: mux_1 = inp1;
      2'b10: mux_1 = inp2;
      2'b11: mux_1 = inp3;
      default: mux_1 = inp0;
    endcase  
*/

 mx4_32 mx4_32_1 (
                  .inp0(inp0),
                  .inp1(inp1),
                  .inp2(inp2),
                  .inp3(inp3),
                  .sel(sel),
                  .out(mux_1)
                 );

/*  Logic
  assign next = {32{!clr}} & mux_1;
*/

 an2_32 an2_32_a (
                  .inp1(mux_1),
                  .inp0({32{!clr}}),
                  .out(next)
                 );

/*  Logic   
  always @(posedge clk)
     out <= (sm ? {32{sin}} : next); 
*/

/*  gate flip-flop */
  ff_s_32 ff_s_32_a ( 
                     .out(out),  
                     .din(next), 
                     .clk(clk)
                    );
 
endmodule

// --------- mux4, clear, register, next, 32 bits wide -------------------
module mx4_clr_reg_nxt_32 (inp3, inp2, inp1, inp0,
                           sel,  clr,  clk, out, nxt_out);
 
input  [31:0]  inp3;
input  [31:0]  inp2;
input  [31:0]  inp1;
input  [31:0]  inp0;
input  [1:0]   sel;
input          clr;
input          clk;
output [31:0]  out;
output [31:0]  nxt_out;

wire   [31:0]  mux_1;
wire   [31:0]  nxt_out;
wire   [31:0]  out;
 
/*  logic
  always @(inp3 or inp2 or inp1 or inp0 or sel)
    case (sel)
      2'b00: mux_1 = inp0;
      2'b01: mux_1 = inp1;
      2'b10: mux_1 = inp2;
      2'b11: mux_1 = inp3;
      default: mux_1 = inp0;
    endcase  
*/

 mx4_32 mx4_32_1 (
                  .inp0(inp0),
                  .inp1(inp1),
                  .inp2(inp2),
                  .inp3(inp3),
                  .sel(sel),
                  .out(mux_1)
                 );

/*  Logic
  assign nxt_out = {32{!clr}} & mux_1;
*/

 an2_32 an2_32_a (
                  .inp1(mux_1),
                  .inp0({32{!clr}}),
                  .out(nxt_out)
                 );

/*  Logic   
  always @(posedge clk)
     out <= (sm ? {32{sin}} : nxt_out);
*/

/*  gate flip-flop */
  ff_s_32 ff_s_32_a (  
                     .out(out),  
                     .din(nxt_out),  
                     .clk(clk) 
                    );
 
endmodule

// --------- Booth, radix_4 ----------------------------------------------
module booth (inp, inp_pre, b0, b1, b2, neg);

input   [1:0]  inp;
input          inp_pre;
output         b0;
output         b1;
output         b2;
output         neg;

reg            b0, b1, b2, neg;

  always @ (inp or inp_pre)
    case ({inp,inp_pre})   //synopsys parallel_case
      3'b000: {b0,b1,b2,neg} = 4'b1000;
      3'b001: {b0,b1,b2,neg} = 4'b0100;
      3'b010: {b0,b1,b2,neg} = 4'b0100;
      3'b011: {b0,b1,b2,neg} = 4'b0010;
      3'b100: {b0,b1,b2,neg} = 4'b0011;
      3'b101: {b0,b1,b2,neg} = 4'b0101;
      3'b110: {b0,b1,b2,neg} = 4'b0101;
      3'b111: {b0,b1,b2,neg} = 4'b1000;
      default: {b0,b1,b2,neg} = 4'b1000;
    endcase

endmodule

// --------- Booth_recoder, radix_4 --------------------------------------
module b_recoder (mag_a, mag_b, nxt_rbb10, cur_rbb1,
                  sel_swap,  cyc_compare, 
                  clr, clk,
                  nxt_booth_0, booth_2, booth_neg);

input   [1:0]  mag_a;
input   [1:0]  mag_b;
input   [1:0]  nxt_rbb10;         //  may just use cur_rbb[3:2]
input          cur_rbb1;
input          sel_swap;
input          cyc_compare;
input          clr;
input          clk;
output         nxt_booth_0;
output         booth_2;
output         booth_neg;

wire           booth_0, booth_2, booth_neg;
wire    [1:0]  inp_b;
wire           nxt_booth_0,  nxt_booth_2,  nxt_booth_neg;

wire           a_b0, a_b1, a_b2, a_neg;
wire           b_b0, b_b1, b_b2, b_neg;

  booth booth_a (
                 .inp(mag_a),
                 .inp_pre(1'b0),
                 .b0(a_b0),
                 .b1(a_b1),
                 .b2(a_b2),
                 .neg(a_neg) 
                );

  assign inp_b = cyc_compare ? mag_b : nxt_rbb10;

  booth booth_b ( 
                 .inp(inp_b),
                 .inp_pre(cur_rbb1),
                 .b0(b_b0),
                 .b1(b_b1), 
                 .b2(b_b2), 
                 .neg(b_neg) 
                );

  assign nxt_booth_0   = !clr && (sel_swap ? a_b0  : b_b0);
  assign nxt_booth_2   = !clr && (sel_swap ? a_b2  : b_b2);
  assign nxt_booth_neg = !clr && (sel_swap ? a_neg : b_neg);

/*  Logic   
  always @ (posedge clk)
    {booth_2,booth_neg} <= (sm ? {2{sin}} : {nxt_booth_2,nxt_booth_neg});
*/

/*  gate flip-flop */
  ff_s_2 ff_s_2_a (
                   .out({    booth_2,    booth_neg}),
                   .din({nxt_booth_2,nxt_booth_neg}),
                   .clk(clk)
                  );

endmodule

// --------- Zero detect on the A_operand side, 32 bits ------------------
module zero_a_32 (inp, zero_31_2, zero32);

input  [31:0]  inp;
output         zero_31_2;
output         zero32;

  cmp32zero cmp32zero (.ai({inp[31:2], 2'b0}), .a_eql_z(zero_31_2));
  assign zero32    = zero_31_2 && (inp[1:0]==2'b00);

endmodule 

// --------- Zero detect on the B_operand side, 32 bits ------------------
module zero_b_32 (inp, mag_a31, zero_31_2, zero32, d_ovf);

input  [31:0]  inp;
input          mag_a31;
output         zero_31_2;
output         zero32;
output         d_ovf;

  cmp32zero cmp32zero (.ai({inp[31:2], 2'b0}), .a_eql_z(zero_31_2));
  assign zero32    = zero_31_2 && (inp[1:0]==2'b00);

  assign d_ovf     = mag_a31 && zero_31_2 && (inp[1:0]==2'b01);

endmodule 

// --------- Zero_detect, 32 bits wide -----------------------------------
module zero_det (mag_a, mag_b, nxt_rbb,
                 sel_swap,  cyc_compare, mul_cmp,
                 ld_a_oprd0,  ld_b_oprd0,  ld_leading0,
                 clr_a_oprd0, clr_b_oprd0,
                 clk,
                 ain_is0, bin_is0, div_ovf, extreme_2, leading0_r);

input  [31:0]  mag_a; 
input  [31:0]  mag_b; 
input  [31:0]  nxt_rbb; 
input          sel_swap; 
input          cyc_compare; 
input          mul_cmp;
input          ld_a_oprd0;
input          ld_b_oprd0;
input          ld_leading0;
input          clr_a_oprd0;
input          clr_b_oprd0;
input          clk;

output         ain_is0;
output         bin_is0;
output         div_ovf;
output         extreme_2;
output         leading0_r;

wire           ain_is0_r, bin_is0_r, div_ovf_r, leading0_r;
wire   [31:0]  inp_b;
wire           zero32_a,    zero32_b;
wire                        bop312_0;
wire           leading0;

wire           zero_31_2_a, zero_31_2_b, d_ovf;

  zero_a_32 zero_a_32_0 (
                         .inp(mag_a),
                         .zero_31_2(zero_31_2_a),
                         .zero32(zero32_a) 
                        );

/*  Logic    
  assign inp_b = cyc_compare ? mag_b : nxt_rbb;
*/

  mx2_32 mx2_32_a (
                   .inp1(mag_b),
                   .inp0(nxt_rbb),
                   .sel(cyc_compare),
                   .out(inp_b)
                  );

  zero_b_32 zero_b_32_0 (
                         .inp(inp_b),
                         .mag_a31(mag_a[31]),
                         .zero_31_2(zero_31_2_b),
                         .zero32(zero32_b),
                         .d_ovf(d_ovf)
                        );

  assign bop312_0 = sel_swap ? zero_31_2_a : zero_31_2_b;

  assign ain_is0  = ld_a_oprd0  ? (!clr_a_oprd0 && zero32_a) : ain_is0_r;
  assign bin_is0  = ld_b_oprd0  ? (!clr_b_oprd0 && zero32_b) : bin_is0_r;
  assign div_ovf  = ld_b_oprd0  ? (!clr_b_oprd0 && d_ovf)    : div_ovf_r;
  assign leading0 = ld_leading0 ? (!clr_b_oprd0 && bop312_0) : leading0_r;

  assign extreme_2 = (!mul_cmp && div_ovf) || ain_is0 || bin_is0;

/*  Logic   
  always @ (posedge clk) begin
    ain_is0_r   <= (sm ? sin : ain_is0);
    bin_is0_r   <= (sm ? sin : bin_is0);
    div_ovf_r   <= (sm ? sin : div_ovf);
    leading0_r  <= (sm ? sin : leading0);
  end
*/

/* gate flip-flop */
  ff_s_4 ff_s_4_0 (
                   .out({ain_is0_r,bin_is0_r,div_ovf_r,leading0_r}),
                   .din({ain_is0,  bin_is0,  div_ovf,  leading0}),
                   .clk(clk)
                  );

endmodule

// --------- Sign bit ----------------------------------------------------
module sign_bit (ra_31, rb_31,
                 ld_sign,
                 clr_sign,
                 rem_cmp,
                 clk,
                 bin_sign, out_sign, out_sign_r);
 
input          ra_31;
input          rb_31;
input          ld_sign;
input          clr_sign;
input          rem_cmp;
input          clk;

output         bin_sign;
output         out_sign;
output         out_sign_r;

wire           ain_sign,   bin_sign,   out_sign;
wire                                   o_sign;

wire           ain_sign_r, bin_sign_r, out_sign_r;

//assign o_sign = rem_cmp ? (ra_31 && !rb_31) : ra_31 ^ rb_31;
  assign o_sign = rem_cmp ?  ra_31            : ra_31 ^ rb_31;

  assign ain_sign = ld_sign ? (ra_31)               : ain_sign_r;
  assign bin_sign = ld_sign ? (rb_31)               : bin_sign_r;
  assign out_sign = ld_sign ? (!clr_sign && o_sign) : out_sign_r;

/*  Logic   
  always @ (posedge clk) begin
    ain_sign_r <= (sm ? sin : ain_sign);
    bin_sign_r <= (sm ? sin : bin_sign);
    out_sign_r <= (sm ? sin : out_sign);
  end
*/

/*  gate flip-flop */
  ff_s_3 ff_s_3_0 (
                   .out({ain_sign_r,bin_sign_r,out_sign_r}),
                   .din({ain_sign,  bin_sign,  out_sign}),
                   .clk(clk)
                  );

endmodule

// -------------- Buffered to control ------------------------------------
module dpath_ctrl (
                   sum32,
                   rbb1,
                   mul_cmp,
                   div_cmp,
                   rem_cmp,
                   clr_ra2,
                   sel_sum_a,
                   sel_swap,
                   rem_sum32,
                   extreme_1,
                   cur_rbb1,
                   sum_32,
                   clr_ra,
                   sel_sum_a_buf 
                   );

input          sum32;
input          rbb1;
input          mul_cmp;
input          div_cmp;
input          rem_cmp;
input          clr_ra2;
input          sel_sum_a;

output         sel_swap;
output         rem_sum32;
output         extreme_1;

output         cur_rbb1;
output         sum_32;
output         clr_ra;
output         sel_sum_a_buf;

wire           sum32_, sel_swap_, rem_sum32_;
wire           mul_cmp_, extreme_1_;
wire           div_s32;

/*  Logic */
  assign cur_rbb1      = rbb1;
  assign sum_32        = sum32;
  assign sel_sum_a_buf = sel_sum_a;

  assign sel_swap  =   (!sum32 &&  mul_cmp);
  assign rem_sum32 =   ( sum32 &&  rem_cmp);
  assign extreme_1 =   (!sum32 && !mul_cmp);
  assign clr_ra    =!(!(!sum32 &&  div_cmp) && !clr_ra2);



endmodule

module inv1_32 (inp, out_);
 
input  [31:0]  inp;
output [31:0]  out_;
 
wire   [31:0]  out_;
 
  assign out_ =  ~inp;
 
endmodule
 
module an2_32 (inp1, inp0, out);
 
input  [31:0]  inp1;
input  [31:0]  inp0;
output [31:0]  out;
 
wire   [31:0]  out;
wire   [31:0]  out_;
 
  assign out =  inp1 & inp0;
 
endmodule
 
module an2_33 (inp1, inp0, out);
 
input  [32:0]  inp1;
input  [32:0]  inp0;
output [32:0]  out;
 
wire   [32:0]  out;
wire   [32:0]  out_;
 
  assign out =  inp1 & inp0;
 
endmodule
