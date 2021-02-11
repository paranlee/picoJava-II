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


module del1_1 (inp, out);

input         inp;
output        out;

  assign out = inp;

endmodule

module del1_16 (inp, out);

input  [15:0] inp;
output [15:0] out;

wire   [15:0] out;

  assign out = inp[15:0];

endmodule

module del1_32 (inp, out);

input  [31:0] inp;
output [31:0] out;

wire   [31:0] out;

  assign out = inp[31:0];

endmodule

// --------- invertor         1 bit  wide --------------------------
module inv_b_1 (inp, out_l);
 
input         inp;           
output        out_l;
 
  assign out_l = ~inp;
 
endmodule  

// --------- invertor       1 bit  wide --------------------------
module inv_d_1 (inp, out_l);
 
input         inp;           
output        out_l;
 
  assign out_l = ~inp;
 
endmodule  

// --------- invertor       1 bit  wide --------------------------
module inv_e_1 (inp, out_l);

input         inp;
output        out_l;

  assign out_l = ~inp;

endmodule

// --------- invertor       32 bits wide --------------------------
module inv_a_32 (inp, out_l);

input  [31:0] inp;
output [31:0] out_l;

wire   [31:0] out_l;

  assign out_l = ~inp[31:0];

endmodule

// --------- invertor     32 bits wide --------------------------
module inv_b_32 (inp, out_l);

input  [31:0] inp; 
output [31:0] out_l;

wire   [31:0] out_l;

  assign out_l = ~inp[31:0];

endmodule

// --------- invertor       32 bits wide --------------------------
module inv_c_32 (inp, out_l);
 
input  [31:0] inp;
output [31:0] out_l;
 
wire   [31:0] out_l;
 
  assign out_l = ~inp[31:0];
 
endmodule

// --------- invertor     32 bits wide --------------------------
module inv_d_32 (inp, out_l);
 
input  [31:0] inp;
output [31:0] out_l;
 
wire   [31:0] out_l;
 
  assign out_l = ~inp[31:0];
 
endmodule

// --------- invertor   32 bits wide --------------------------
module inv_e_32 (inp, out_l);
 
input  [31:0] inp;
output [31:0] out_l;
 
wire   [31:0] out_l;
 
  assign out_l = ~inp[31:0];
 
endmodule

// --------- invertor       32 bits wide --------------------------
module inv_f_32 (inp, out_l);
 
input  [31:0] inp;
output [31:0] out_l;
 
wire   [31:0] out_l;
 
  assign out_l = ~inp[31:0];
 
endmodule

// --------- buffer   32 bits wide --------------------------
module buf_cf_32 (inp, out);   
 
input  [31:0] inp;
output [31:0] out;
 
wire   [31:0] out; 
 
  assign out = inp[31:0];
 
endmodule

// --------- mux3,                    1 bit  wide --------------------------
module mx3_1 (inp, sel, out);

input   [2:0]  inp;
input   [1:0]  sel;
output         out;

reg            out;

  always @(inp or sel)
    case (sel)
      2'b00: out = inp[0];
      2'b01: out = inp[0];
      2'b10: out = inp[1];
      2'b11: out = inp[2];
// remove for coverage:      default: out = inp[0];
    endcase

endmodule

// --------- mux3,                    9 bit  wide --------------------------
module mx3_9 (inp1, inp2, inp3, sel, out);
 
input   [8:0]  inp1;
input   [8:0]  inp2;
input   [8:0]  inp3;
input   [1:0]  sel;
output  [8:0]  out;
 
wire    [8:0]  out;
 
mx3_1 U00 (.inp({inp3[0], inp2[0], inp1[0] }),.sel(sel),.out(out[0]));
mx3_1 U01 (.inp({inp3[1], inp2[1], inp1[1] }),.sel(sel),.out(out[1]));
mx3_1 U02 (.inp({inp3[2], inp2[2], inp1[2] }),.sel(sel),.out(out[2]));
mx3_1 U03 (.inp({inp3[3], inp2[3], inp1[3] }),.sel(sel),.out(out[3]));
mx3_1 U04 (.inp({inp3[4], inp2[4], inp1[4] }),.sel(sel),.out(out[4]));
mx3_1 U05 (.inp({inp3[5], inp2[5], inp1[5] }),.sel(sel),.out(out[5]));
mx3_1 U06 (.inp({inp3[6], inp2[6], inp1[6] }),.sel(sel),.out(out[6]));
mx3_1 U07 (.inp({inp3[7], inp2[7], inp1[7] }),.sel(sel),.out(out[7]));
mx3_1 U08 (.inp({inp3[8], inp2[8], inp1[8] }),.sel(sel),.out(out[8]));
 
endmodule

// --------- branch_bit for branch select --------------ucode_dec.v --------
module branch_bit (u_f18_6, u_f18_5, u_f08_rd_rs1_a, rs1_0_l, rs2_0_l,
                   bit1, bit0);
 
input          u_f18_6;
input          u_f18_5;
input          u_f08_rd_rs1_a;     // Field_08: Read_port_A of RS1
input          rs1_0_l;            // rs1[0], active low, from IU
input          rs2_0_l;            // rs2[0], active low, from IU
output         bit1;
output         bit0;
 
wire           a_oprd_0;
wire           check_handle2, check_handle, check_handle_p;
 
  assign a_oprd_0        = !(u_f08_rd_rs1_a ? rs1_0_l : rs2_0_l);
 
  assign check_handle2   = (!u_f18_6   &&  u_f18_5 );  // jump_2
  assign check_handle    = ( u_f18_6   && !u_f18_5 );  // jump_3, [0]=0
  assign check_handle_p  = ( u_f18_6   &&  u_f18_5 );  // jump_3, [0]=1
 
  assign bit1 = (check_handle   && !a_oprd_0) ||
                (check_handle_p &&  a_oprd_0) ||
                (check_handle2  &&  a_oprd_0);
 
  assign bit0 = (check_handle   && !a_oprd_0) ||
                (check_handle_p &&  a_oprd_0) ||
               !(check_handle2  &&  a_oprd_0);

endmodule

