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


// `timescale  1ns / 10ps

module mj_p_mux2 (
    mx_out, 
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in1;
    input in0;
    input sel;
    input sel_l;


reg mx_out;

always @(sel or in1 or in0 )
begin  
    case (sel)
    1'b1: mx_out = in1;
    1'b0: mx_out = in0;
    default: mx_out = 1'bx;
    endcase 
end 

endmodule

module mj_p_mux2l (
    mx_out, 
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in1;
    input in0;
    input sel;
    input sel_l;


reg mx_out;

always @(sel or in1 or in0 )
begin  
    case (sel)
    1'b1: mx_out = ~in1;
    1'b0: mx_out = ~in0;
    default: mx_out = 1'bx;
    endcase 
end 

endmodule

module mj_p_mux3 (
    mx_out, 
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in2;
    input in1;
    input in0;
    input [2:0] sel;
    input [2:0] sel_l;


reg mx_out;
always @(sel or in2 or in1 or in0 )
begin
  case (sel)
    3'b100: mx_out = in2;
    3'b010: mx_out = in1;
    3'b001: mx_out = in0;
    default: mx_out = 1'bx;
    endcase
end 

endmodule

module mj_p_mux4 (
    mx_out, 
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in3;
    input in2;
    input in1;
    input in0;
    input [3:0] sel;
    input [3:0] sel_l;


reg mx_out;
always @(sel or in2 or in1 or in0 or in3)
begin
     case (sel)
    4'b1000: mx_out = in3;
    4'b0100: mx_out = in2;
    4'b0010: mx_out = in1;
    4'b0001: mx_out = in0;
    default: mx_out = 1'bx;
    endcase
end

endmodule

module mj_p_mux6 (
    mx_out, 
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [5:0] sel;
    input [5:0] sel_l;


reg mx_out;
always @(sel or in2 or in1 or in0 or in3 or in4 or in5)
begin
    case (sel)
    6'b100000: mx_out = in5;
    6'b010000: mx_out = in4;
    6'b001000: mx_out = in3;
    6'b000100: mx_out = in2;
    6'b000010: mx_out = in1;
    6'b000001: mx_out = in0;
    default: mx_out = 1'bx;
    endcase
end

endmodule
 
module mj_p_mux8 (
    mx_out, 
    in7,
    in6,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in7;
    input in6;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [7:0] sel;
    input [7:0] sel_l;


reg mx_out;
always @(sel or in2 or in1 or in0 or in3 or in4 or in5 or in6 or in7)
begin
  case (sel)
    8'b10000000: mx_out = in7;
    8'b01000000: mx_out = in6;
    8'b00100000: mx_out = in5;
    8'b00010000: mx_out = in4;
    8'b00001000: mx_out = in3;
    8'b00000100: mx_out = in2;
    8'b00000010: mx_out = in1;
    8'b00000001: mx_out = in0;
    default: mx_out = 1'bx;
    endcase
end

endmodule

module mj_p_mux2_2 (mx_out, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  sel ; input sel_l;

    mj_p_mux2 mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2 mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_2 (mx_out, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_2 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux6_2 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux8_2 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in7; 
    input  [1:0] in6; 
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux2_3 (mx_out, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in1; 
    input  [2:0] in0; 
    input    sel ; input   sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_3 (mx_out, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_3 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux6_3 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux8_3 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in7; 
    input  [2:0] in6; 
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux2_4 (mx_out, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  sel ; input  sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_p_mux2_5 (mx_out, in1, in0, sel, sel_l);
    output [4:0] mx_out;
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  sel ; input  sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_4 (mx_out, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_4 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux6_4 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux8_4 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in7; 
    input  [3:0] in6; 
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux2_6 (mx_out, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in1; 
    input  [5:0] in0; 
    input    sel ; input  sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_6 (mx_out, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_6 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux6_6 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux8_6 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in7; 
    input  [5:0] in6; 
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux2_8 (mx_out, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in1; 
    input  [7:0] in0; 
    input    sel ; input  sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_8 (mx_out, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_6 (.mx_out(mx_out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_7 (.mx_out(mx_out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_8 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux6_8 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_6 (.mx_out(mx_out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_7 (.mx_out(mx_out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux8_8 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in7; 
    input  [7:0] in6; 
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_6 (.mx_out(mx_out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_7 (.mx_out(mx_out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux2_16 (mx_out, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in1; 
    input  [15:0] in0; 
    input    sel ; input   sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_16 (mx_out, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_6 (.mx_out(mx_out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_7 (.mx_out(mx_out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_8 (.mx_out(mx_out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_9 (.mx_out(mx_out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_10 (.mx_out(mx_out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_11 (.mx_out(mx_out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_12 (.mx_out(mx_out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_13 (.mx_out(mx_out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_14 (.mx_out(mx_out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_15 (.mx_out(mx_out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_16 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in3; 
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_8 (.mx_out(mx_out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_9 (.mx_out(mx_out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_10 (.mx_out(mx_out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_11 (.mx_out(mx_out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_12 (.mx_out(mx_out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_13 (.mx_out(mx_out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_14 (.mx_out(mx_out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_15 (.mx_out(mx_out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_p_mux6_16 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in5; 
    input  [15:0] in4; 
    input  [15:0] in3; 
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_6 (.mx_out(mx_out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_7 (.mx_out(mx_out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_8 (.mx_out(mx_out[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_9 (.mx_out(mx_out[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_10 (.mx_out(mx_out[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_11 (.mx_out(mx_out[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_12 (.mx_out(mx_out[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_13 (.mx_out(mx_out[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_14 (.mx_out(mx_out[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_15 (.mx_out(mx_out[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux8_16 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in7; 
    input  [15:0] in6; 
    input  [15:0] in5; 
    input  [15:0] in4; 
    input  [15:0] in3; 
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_6 (.mx_out(mx_out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_7 (.mx_out(mx_out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_8 (.mx_out(mx_out[8]), .in7(in7[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_9 (.mx_out(mx_out[9]), .in7(in7[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_10 (.mx_out(mx_out[10]), .in7(in7[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_11 (.mx_out(mx_out[11]), .in7(in7[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_12 (.mx_out(mx_out[12]), .in7(in7[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_13 (.mx_out(mx_out[13]), .in7(in7[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_14 (.mx_out(mx_out[14]), .in7(in7[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_15 (.mx_out(mx_out[15]), .in7(in7[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_p_mux2_30 (mx_out, in1, in0, sel, sel_l);
    output [29:0] mx_out;
    input  [29:0] in1; 
    input  [29:0] in0; 
    input    sel ; input   sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_16 (.mx_out(mx_out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_17 (.mx_out(mx_out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_18 (.mx_out(mx_out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_19 (.mx_out(mx_out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_20 (.mx_out(mx_out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_21 (.mx_out(mx_out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_22 (.mx_out(mx_out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_23 (.mx_out(mx_out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_24 (.mx_out(mx_out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_25 (.mx_out(mx_out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_26 (.mx_out(mx_out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_27 (.mx_out(mx_out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_28 (.mx_out(mx_out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_29 (.mx_out(mx_out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_p_mux2_32 (mx_out, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in1; 
    input  [31:0] in0; 
    input    sel ; input   sel_l;

    mj_p_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_16 (.mx_out(mx_out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_17 (.mx_out(mx_out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_18 (.mx_out(mx_out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_19 (.mx_out(mx_out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_20 (.mx_out(mx_out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_21 (.mx_out(mx_out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_22 (.mx_out(mx_out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_23 (.mx_out(mx_out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_24 (.mx_out(mx_out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_25 (.mx_out(mx_out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_26 (.mx_out(mx_out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_27 (.mx_out(mx_out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_28 (.mx_out(mx_out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_29 (.mx_out(mx_out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_30 (.mx_out(mx_out[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2  mux_31 (.mx_out(mx_out[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_p_mux2l_32 (mx_out, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in1; 
    input  [31:0] in0; 
    input    sel ; input   sel_l;

    mj_p_mux2l  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_16 (.mx_out(mx_out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_17 (.mx_out(mx_out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_18 (.mx_out(mx_out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_19 (.mx_out(mx_out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_20 (.mx_out(mx_out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_21 (.mx_out(mx_out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_22 (.mx_out(mx_out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_23 (.mx_out(mx_out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_24 (.mx_out(mx_out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_25 (.mx_out(mx_out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_26 (.mx_out(mx_out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_27 (.mx_out(mx_out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_28 (.mx_out(mx_out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_29 (.mx_out(mx_out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_30 (.mx_out(mx_out[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux2l  mux_31 (.mx_out(mx_out[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux3_32 (mx_out, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_p_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_6 (.mx_out(mx_out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_7 (.mx_out(mx_out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_8 (.mx_out(mx_out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_9 (.mx_out(mx_out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_10 (.mx_out(mx_out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_11 (.mx_out(mx_out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_12 (.mx_out(mx_out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_13 (.mx_out(mx_out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_14 (.mx_out(mx_out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_15 (.mx_out(mx_out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_16 (.mx_out(mx_out[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_17 (.mx_out(mx_out[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_18 (.mx_out(mx_out[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_19 (.mx_out(mx_out[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_20 (.mx_out(mx_out[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_21 (.mx_out(mx_out[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_22 (.mx_out(mx_out[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_23 (.mx_out(mx_out[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_24 (.mx_out(mx_out[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_25 (.mx_out(mx_out[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_26 (.mx_out(mx_out[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_27 (.mx_out(mx_out[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_28 (.mx_out(mx_out[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_29 (.mx_out(mx_out[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_30 (.mx_out(mx_out[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux3  mux_31 (.mx_out(mx_out[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_p_mux4_32 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_8 (.mx_out(mx_out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_9 (.mx_out(mx_out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_10 (.mx_out(mx_out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_11 (.mx_out(mx_out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_12 (.mx_out(mx_out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_13 (.mx_out(mx_out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_14 (.mx_out(mx_out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_15 (.mx_out(mx_out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_16 (.mx_out(mx_out[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_17 (.mx_out(mx_out[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_18 (.mx_out(mx_out[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_19 (.mx_out(mx_out[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_20 (.mx_out(mx_out[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_21 (.mx_out(mx_out[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_22 (.mx_out(mx_out[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_23 (.mx_out(mx_out[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_24 (.mx_out(mx_out[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_25 (.mx_out(mx_out[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_26 (.mx_out(mx_out[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_27 (.mx_out(mx_out[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_28 (.mx_out(mx_out[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_29 (.mx_out(mx_out[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_30 (.mx_out(mx_out[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4  mux_31 (.mx_out(mx_out[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 




module mj_p_mux6_32 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_p_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_6 (.mx_out(mx_out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_7 (.mx_out(mx_out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_8 (.mx_out(mx_out[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_9 (.mx_out(mx_out[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_10 (.mx_out(mx_out[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_11 (.mx_out(mx_out[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_12 (.mx_out(mx_out[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_13 (.mx_out(mx_out[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_14 (.mx_out(mx_out[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_15 (.mx_out(mx_out[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_16 (.mx_out(mx_out[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_17 (.mx_out(mx_out[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_18 (.mx_out(mx_out[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_19 (.mx_out(mx_out[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_20 (.mx_out(mx_out[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_21 (.mx_out(mx_out[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_22 (.mx_out(mx_out[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_23 (.mx_out(mx_out[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_24 (.mx_out(mx_out[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_25 (.mx_out(mx_out[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_26 (.mx_out(mx_out[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_27 (.mx_out(mx_out[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_28 (.mx_out(mx_out[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_29 (.mx_out(mx_out[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_30 (.mx_out(mx_out[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux6  mux_31 (.mx_out(mx_out[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_p_mux8_32 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in7; 
    input  [31:0] in6; 
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_p_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_6 (.mx_out(mx_out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_7 (.mx_out(mx_out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_8 (.mx_out(mx_out[8]), .in7(in7[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_9 (.mx_out(mx_out[9]), .in7(in7[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_10 (.mx_out(mx_out[10]), .in7(in7[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_11 (.mx_out(mx_out[11]), .in7(in7[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_12 (.mx_out(mx_out[12]), .in7(in7[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_13 (.mx_out(mx_out[13]), .in7(in7[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_14 (.mx_out(mx_out[14]), .in7(in7[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_15 (.mx_out(mx_out[15]), .in7(in7[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_16 (.mx_out(mx_out[16]), .in7(in7[16]), .in6(in6[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_17 (.mx_out(mx_out[17]), .in7(in7[17]), .in6(in6[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_18 (.mx_out(mx_out[18]), .in7(in7[18]), .in6(in6[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_19 (.mx_out(mx_out[19]), .in7(in7[19]), .in6(in6[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_20 (.mx_out(mx_out[20]), .in7(in7[20]), .in6(in6[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_21 (.mx_out(mx_out[21]), .in7(in7[21]), .in6(in6[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_22 (.mx_out(mx_out[22]), .in7(in7[22]), .in6(in6[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_23 (.mx_out(mx_out[23]), .in7(in7[23]), .in6(in6[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_24 (.mx_out(mx_out[24]), .in7(in7[24]), .in6(in6[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_25 (.mx_out(mx_out[25]), .in7(in7[25]), .in6(in6[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_26 (.mx_out(mx_out[26]), .in7(in7[26]), .in6(in6[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_27 (.mx_out(mx_out[27]), .in7(in7[27]), .in6(in6[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_28 (.mx_out(mx_out[28]), .in7(in7[28]), .in6(in6[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_29 (.mx_out(mx_out[29]), .in7(in7[29]), .in6(in6[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_30 (.mx_out(mx_out[30]), .in7(in7[30]), .in6(in6[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux8  mux_31 (.mx_out(mx_out[31]), .in7(in7[31]), .in6(in6[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 


/************* Encoded Muxes *************/

module mj_s_mux2_d (mx_out, sel, in0, in1);

output  mx_out;
input   sel;
input   in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;


assign selb = ~sel;

mj_p_mux2  mj_p_mux2_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel) ,
		.sel_l(selb)) ;
endmodule

module mj_s_mux2l_d (mx_out, sel, in0, in1);

output  mx_out;
input   sel;
input   in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = ~(mux_sel & in1 | sel_not & in0) ;
*/

wire selb;


assign selb = ~sel;

mj_p_mux2l  mj_p_mux2l_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel) ,
		.sel_l(selb)) ;
endmodule


module mj_s_mux3_d (mx_out, sel, in0, in1,in2);
output  mx_out;
input [1:0] sel;
input  in0 , in1, in2 ;
/*
reg mx_out;
// synopsys infer_mux "mx31"
always @(in2 or in1 or in0 or sel)
begin : mx31
case (sel)
  2'b10 : mx_out= in2;
  2'b01 : mx_out= in1;
  2'b00 : mx_out= in0;
   default :begin
            mx_out = 1'bx;
	    $display("Invalid Input");
	    end
endcase
end
*/

//wire [2:0] select;
reg [2:0] sl;
wire [2:0] slb;


always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    sl = 3'b001;
      2'b01:    sl = 3'b010;
      2'b10:    sl = 3'b100;
      default:  sl = 3'b100;
   endcase
end

assign slb = ~sl;

mj_p_mux3 mj_p_mux3_0 (	.mx_out(mx_out), 
    			.in2(in2),	
    			.in1(in1),
    			.in0(in0),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule

module mj_s_mux4_d (mx_out, sel, in0, in1,in2,in3);
output  mx_out;
input [1:0] sel;
input  in0 , in1, in2, in3  ;
/*
reg mx_out;
// synopsys infer_mux "mx41"
always @(in3 or in2 or in1 or in0 or sel)
begin : mx41
case (sel)
  2'b11 : mx_out= in3;
  2'b10 : mx_out= in2;
  2'b01 : mx_out= in1;
  2'b00 : mx_out= in0;
   default :begin
            mx_out = 1'bx;
	    $display("Invalid Input");
	    end
endcase
end
*/
//wire [3:0] select;

reg [3:0] sl;
wire [3:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    sl = 4'h1;
      2'b01:    sl = 4'h2;
      2'b10:    sl = 4'h4;
      2'b11:    sl = 4'h8;
      default:  sl = 4'h8;
   endcase
end

assign slb = ~sl;

mj_p_mux4 mj_p_mux4_0 ( .mx_out(mx_out), 
    			.in3(in3),
    			.in2(in2),	
    			.in1(in1),
    			.in0(in0),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule


module mj_s_mux6_d (mx_out, sel, in0, in1,in2,in3,in4,in5);
output  mx_out;
input [2:0] sel;
input  in0 , in1, in2, in3, in4 ,in5;
/*
reg mx_out;
// synopsys infer_mux "mx61"
always @(in5 or in4 or in3 or in2 or in1 or in0 or sel)
begin : mx61
case (sel)
  3'b101 : mx_out= in5;
  3'b100 : mx_out= in4;
  3'b011 : mx_out= in3;
  3'b010 : mx_out= in2;
  3'b001 : mx_out= in1;
  3'b000 : mx_out= in0;
   default :begin
            mx_out = 1'bx;
	    $display("Invalid Input");
	    end
endcase
end
*/

//wire [5:0] select;
reg [5:0] sl;
wire [5:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    sl = 6'b000001;
      3'b001:    sl = 6'b000010;   
      3'b010:    sl = 6'b000100;
      3'b011:    sl = 6'b001000;    
      3'b100:    sl = 6'b010000;   
      3'b101:    sl = 6'b100000;   
      default:   sl = 6'b100000;   
   endcase
end

assign slb = ~sl;

mj_p_mux6 mj_p_mux6_0 (	.mx_out(mx_out), 
    			.in5(in5),
    			.in4(in4),
    			.in3(in3),
    			.in2(in2),	
    			.in1(in1),
    			.in0(in0),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule

module mj_s_mux8_d (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output  mx_out;
input [2:0] sel;
input  in0 , in1, in2, in3, in4 ,in5,in6,in7;
/*
reg mx_out;
// synopsys infer_mux "mx81"
always @(in7 or in6 or in5 or in4 or in3 or in2 or in1 or in0 or sel)
begin : mx81
case (sel)
  3'b111 : mx_out= in7;
  3'b110 : mx_out= in6;
  3'b101 : mx_out= in5;
  3'b100 : mx_out= in4;
  3'b011 : mx_out= in3;
  3'b010 : mx_out= in2;
  3'b001 : mx_out= in1;
  3'b000 : mx_out= in0;
   default :begin
            mx_out = 1'bx;
	    $display("Invalid Input");
	    end
endcase
end
*/

//wire [7:0] select;
reg [7:0] sl;
wire [7:0] slb;

always @(sel)  begin
   case (sel)      // synopsys full_case parallel_case
      3'b000:    sl = 8'h1;
      3'b001:    sl = 8'h2;
      3'b010:    sl = 8'h4;
      3'b011:    sl = 8'h8;
      3'b100:    sl = 8'h10;
      3'b101:    sl = 8'h20;
      3'b110:    sl = 8'h40;
      3'b111:    sl = 8'h80;
      default:   sl = 8'h80;
   endcase
end

assign slb = ~sl;

mj_p_mux8 mj_p_mux8_0 (  .mx_out(mx_out), 
    			.in7(in7),
    			.in6(in6),
    			.in5(in5),
    			.in4(in4),	
    			.in3(in3),
    			.in2(in2),	
    			.in1(in1),
    			.in0(in0),
    			.sel(sl),
			.sel_l(slb)
			);
endmodule


module mj_s_mux2_d_2 (mx_out, sel, in0, in1);

output [1:0] mx_out;
input    sel;
input  [1:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;

assign selb = ~sel;
assign sel1 = ~selb;

mj_p_mux2_2  mj_p_mux2_2_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(selb)) ;
endmodule

module mj_s_mux3_d_2 (mx_out, sel, in0, in1,in2);
output [1:0] mx_out;
input [1:0] sel;
input  [1:0] in2; 
input  [1:0] in1; 
input  [1:0] in0; 
//wire [2:0] select;
reg [2:0] sl;
wire [2:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    sl = 3'b001;
      2'b01:    sl = 3'b010;
      2'b10:    sl = 3'b100;
      default:  sl = 3'b100;
   endcase
end

assign slb = ~sl;

mj_p_mux3_2  mj_p_mux3_2_0 (	.mx_out(mx_out), 
				.in2(in2),	
				.in1(in1),
				.in0(in0),
				.sel(sl) ,
				.sel_l(slb) 
				);

endmodule

module mj_s_mux4_d_2 (mx_out, sel, in0, in1,in2,in3);
output [1:0] mx_out;
input [1:0] sel;
input  [1:0] in3;
input  [1:0] in2; 
input  [1:0] in1; 
input  [1:0] in0; 
//wire [3:0] select;
reg [3:0] sl;
wire [3:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    sl = 4'h1;
      2'b01:    sl = 4'h2;
      2'b10:    sl = 4'h4;
      2'b11:    sl = 4'h8;
      default:  sl = 4'h8;
   endcase
end

assign slb = ~sl;

mj_p_mux4_2	mj_p_mux4_2_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux6_d_2 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [1:0] mx_out;
input [2:0] sel;
input  [1:0] in5;
input  [1:0] in4; 
input  [1:0] in3;
input  [1:0] in2; 
input  [1:0] in1; 
input  [1:0] in0; 
//wire [5:0] select;
reg [5:0] sl;
wire [5:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    sl = 6'b000001;
      3'b001:    sl = 6'b000010;   
      3'b010:    sl = 6'b000100;
      3'b011:    sl = 6'b001000;    
      3'b100:    sl = 6'b010000;   
      3'b101:    sl = 6'b100000;   
      default:   sl = 6'b100000;   
   endcase
end

assign slb = ~sl;

mj_p_mux6_2  mj_p_mux6_2_0 (	.mx_out(mx_out),
				.in5(in5),
				.in4(in4),
				.in3(in3), 
				.in2(in2),	
				.in1(in1),
				.in0(in0),
				.sel(sl) ,
				.sel_l(slb)
				);
endmodule

module mj_s_mux8_d_2 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [1:0] mx_out;
input [2:0] sel;
input  [1:0] in7;
input  [1:0] in6;
input  [1:0] in5;
input  [1:0] in4; 
input  [1:0] in3;
input  [1:0] in2; 
input  [1:0] in1; 
input  [1:0] in0; 
//wire [7:0] select;
reg [7:0] sl;
wire [7:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    sl = 8'h1;
      3'b001:    sl = 8'h2;
      3'b010:    sl = 8'h4;
      3'b011:    sl = 8'h8;
      3'b100:    sl = 8'h10;
      3'b101:    sl = 8'h20;
      3'b110:    sl = 8'h40;
      3'b111:    sl = 8'h80;
      default:   sl = 8'h80;
   endcase
end

assign slb = ~sl;

mj_p_mux8_2	mj_p_mux8_2_0 (  .mx_out(mx_out),
    .in7(in7),
    .in6(in6),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux2_d_3 (mx_out, sel, in0, in1);

output [2:0] mx_out;
input    sel;
input  [2:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;

assign selb = ~sel;
assign sel1 = ~selb;

mj_p_mux2_3  mj_p_mux2_3_0 (	.mx_out(mx_out), 
		    		.in1(in1),
		    		.in0(in0),
		    		.sel(sel1) ,
				.sel_l(selb)
				) ;
endmodule

module mj_s_mux3_d_3 (mx_out, sel, in0, in1,in2);
output [2:0] mx_out;
input [1:0] sel;
input  [2:0] in2; 
input  [2:0] in1; 
input  [2:0] in0; 
//wire [2:0] select;
reg [2:0] sl;
wire [2:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    sl = 3'b001;
      2'b01:    sl = 3'b010;
      2'b10:    sl = 3'b100;
      default:  sl = 3'b100;
   endcase
end

assign slb = ~sl;

mj_p_mux3_3  mj_p_mux3_3_0 (	.mx_out(mx_out), 
				.in2(in2),	
				.in1(in1),
				.in0(in0),
				.sel(sl) ,
				.sel_l(slb)
				);
endmodule

module mj_s_mux4_d_3 (mx_out, sel, in0, in1,in2,in3);
output [2:0] mx_out;
input [1:0] sel;
input  [2:0] in3;
input  [2:0] in2; 
input  [2:0] in1; 
input  [2:0] in0; 
//wire [3:0] select;
reg [3:0] sl;
wire [3:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    sl = 4'h1;
      2'b01:    sl = 4'h2;
      2'b10:    sl = 4'h4;
      2'b11:    sl = 4'h8;
      default:  sl = 4'h8;
   endcase
end

assign slb = ~sl;

mj_p_mux4_3  mj_p_mux4_3_0 (	.mx_out(mx_out),
				.in3(in3), 
				.in2(in2),	
				.in1(in1),
				.in0(in0),
				.sel(sl) ,
				.sel_l(slb)
				);
endmodule

module mj_s_mux6_d_3 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [2:0] mx_out;
input [2:0] sel;
input  [2:0] in5;
input  [2:0] in4; 
input  [2:0] in3;
input  [2:0] in2; 
input  [2:0] in1; 
input  [2:0] in0; 
//wire [5:0] select;
reg [5:0] sl;
wire [5:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    sl = 6'b000001;
      3'b001:    sl = 6'b000010;   
      3'b010:    sl = 6'b000100;
      3'b011:    sl = 6'b001000;    
      3'b100:    sl = 6'b010000;   
      3'b101:    sl = 6'b100000;   
      default:   sl = 6'b100000;   
   endcase
end

assign slb = ~sl;

mj_p_mux6_3  mj_p_mux6_3_0 (	.mx_out(mx_out),
				.in5(in5),
				.in4(in4),
				.in3(in3), 
				.in2(in2),	
				.in1(in1),
				.in0(in0),
				.sel(sl) ,
				.sel_l(slb)
				);
endmodule

module mj_s_mux8_d_3 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [2:0] mx_out;
input  [2:0] sel;
input  [2:0] in7;
input  [2:0] in6;
input  [2:0] in5;
input  [2:0] in4; 
input  [2:0] in3;
input  [2:0] in2; 
input  [2:0] in1; 
input  [2:0] in0; 
//wire [7:0] select;
reg [7:0] sl;
wire [7:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    sl = 8'h1;
      3'b001:    sl = 8'h2;
      3'b010:    sl = 8'h4;
      3'b011:    sl = 8'h8;
      3'b100:    sl = 8'h10;
      3'b101:    sl = 8'h20;
      3'b110:    sl = 8'h40;
      3'b111:    sl = 8'h80;
      default:   sl = 8'h80;
   endcase
end

assign slb = ~sl;

mj_p_mux8_3  mj_p_mux8_3_0 (	.mx_out(mx_out),
				.in7(in7),
				.in6(in6),
				.in5(in5),
				.in4(in4),
				.in3(in3), 
				.in2(in2),	
				.in1(in1),
				.in0(in0),
				.sel(sl) ,
				.sel_l(slb)
				);
endmodule

module mj_s_mux2_d_4 (mx_out, sel, in0, in1);

output [3:0] mx_out;
input    sel;
input  [3:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;

assign selb = ~sel;
assign sel1 = ~selb;

mj_p_mux2_4  mj_p_mux2_4_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(selb)) ;
endmodule

module mj_s_mux3_d_4 (mx_out, sel, in0, in1,in2);
output [3:0] mx_out;
input [1:0] sel;
input  [3:0] in2; 
input  [3:0] in1; 
input  [3:0] in0; 
//wire [2:0] select;
reg [2:0] sl;
wire [2:0] slb;


always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    sl = 3'b001;
      2'b01:    sl = 3'b010;
      2'b10:    sl = 3'b100;
      default:  sl = 3'b100;
   endcase
end

assign slb = ~sl;

mj_p_mux3_4	mj_p_mux3_4_0 (  .mx_out(mx_out), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux4_d_4 (mx_out, sel, in0, in1,in2,in3);
output [3:0] mx_out;
input [1:0] sel;
input  [3:0] in3;
input  [3:0] in2; 
input  [3:0] in1; 
input  [3:0] in0; 
//wire [3:0] select;
reg [3:0] sl;
wire [3:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    sl = 4'h1;
      2'b01:    sl = 4'h2;
      2'b10:    sl = 4'h4;
      2'b11:    sl = 4'h8;
      default:  sl = 4'h8;
   endcase
end

assign slb = ~sl;

mj_p_mux4_4	mj_p_mux4_4_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux6_d_4 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [3:0] mx_out;
input [2:0] sel;
input  [3:0] in5;
input  [3:0] in4; 
input  [3:0] in3;
input  [3:0] in2; 
input  [3:0] in1; 
input  [3:0] in0; 
//wire [5:0] select;
reg [5:0] sl;
wire [5:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    sl = 6'b000001;
      3'b001:    sl = 6'b000010;   
      3'b010:    sl = 6'b000100;
      3'b011:    sl = 6'b001000;    
      3'b100:    sl = 6'b010000;   
      3'b101:    sl = 6'b100000;   
      default:   sl = 6'b100000;   
   endcase
end

assign slb = ~sl;

mj_p_mux6_4	mj_p_mux6_4_0 (  .mx_out(mx_out),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux8_d_4 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [3:0] mx_out;
input [2:0] sel;
input  [3:0] in7;
input  [3:0] in6;
input  [3:0] in5;
input  [3:0] in4; 
input  [3:0] in3;
input  [3:0] in2; 
input  [3:0] in1; 
input  [3:0] in0; 
//wire [7:0] select;
reg [7:0] sl;
wire [7:0] slb;

always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    sl = 8'h1;
      3'b001:    sl = 8'h2;
      3'b010:    sl = 8'h4;
      3'b011:    sl = 8'h8;
      3'b100:    sl = 8'h10;
      3'b101:    sl = 8'h20;
      3'b110:    sl = 8'h40;
      3'b111:    sl = 8'h80;
      default:   sl = 8'h80;
   endcase
end

assign slb = ~sl;

mj_p_mux8_4	mj_p_mux8_4_0 (  .mx_out(mx_out),
    .in7(in7),
    .in6(in6),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux2_d_6 (mx_out, sel, in0, in1);

output [5:0] mx_out;
input    sel;
input  [5:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;
wire sel1b;

assign selb = ~sel;
assign sel1 = ~selb;
assign sel1b = ~sel1;

mj_p_mux2_6  mj_p_mux2_6_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(sel1b)) ;
endmodule

module mj_s_mux3_d_6 (mx_out, sel, in0, in1,in2);
output [5:0] mx_out;
input [1:0] sel;
input  [5:0] in2; 
input  [5:0] in1; 
input  [5:0] in0; 
//wire [2:0] select;
wire [2:0] sl;
wire [2:0] slb;

mj_p_muxdec3_8 i_mj_p_muxdec3 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux3_6	mj_p_mux3_6_0 (  .mx_out(mx_out), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux4_d_6 (mx_out, sel, in0, in1,in2,in3);
output [5:0] mx_out;
input [1:0] sel;
input  [5:0] in3;
input  [5:0] in2; 
input  [5:0] in1; 
input  [5:0] in0; 
//wire [3:0] select;
wire [3:0] sl;
wire [3:0] slb;

mj_p_muxdec4_8 i_mj_p_muxdec4 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux4_6	mj_p_mux4_6_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux6_d_6 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [5:0] mx_out;
input [2:0] sel;
input  [5:0] in5;
input  [5:0] in4; 
input  [5:0] in3;
input  [5:0] in2; 
input  [5:0] in1; 
input  [5:0] in0; 
//wire [5:0] select;
wire [5:0] sl;
wire [5:0] slb;

mj_p_muxdec6_8 i_mj_p_muxdec6 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux6_6	mj_p_mux6_6_0 (  .mx_out(mx_out),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux8_d_6 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [5:0] mx_out;
input [2:0] sel;
input  [5:0] in7;
input  [5:0] in6;
input  [5:0] in5;
input  [5:0] in4; 
input  [5:0] in3;
input  [5:0] in2; 
input  [5:0] in1; 
input  [5:0] in0; 
//wire [7:0] select;
wire [7:0] sl;
wire [7:0] slb;

mj_p_muxdec8_8 i_mj_p_muxdec8_8 ( .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux8_6	mj_p_mux8_6_0 (  .mx_out(mx_out),
    .in7(in7),
    .in6(in6),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule


module mj_s_mux2_d_8 (mx_out, sel, in0, in1);

output [7:0] mx_out;
input    sel;
input  [7:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;
wire sel1b;

assign selb = ~sel;
assign sel1 = ~selb;
assign sel1b = ~sel1;


mj_p_mux2_8  mj_p_mux2_8_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(sel1b)) ;
endmodule



module mj_s_mux3_d_8 (mx_out, sel, in0, in1,in2);
output [7:0] mx_out;
input [1:0] sel;
input  [7:0] in2; 
input  [7:0] in1; 
input  [7:0] in0; 
//wire [2:0] select;
wire [2:0] sl;
wire [2:0] slb;

mj_p_muxdec3_8 i_mj_p_muxdec3 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux3_8	mj_p_mux3_8_0 (  .mx_out(mx_out), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux4_d_8 (mx_out, sel, in0, in1,in2,in3);
output [7:0] mx_out;
input [1:0] sel;
input  [7:0] in3;
input  [7:0] in2; 
input  [7:0] in1; 
input  [7:0] in0; 
//wire [3:0] select;
wire [3:0] sl;
wire [3:0] slb;

mj_p_muxdec4_8 i_mj_p_muxdec4 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux4_8	mj_p_mux4_8_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux6_d_8 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [7:0] mx_out;
input [2:0] sel;
input  [7:0] in5;
input  [7:0] in4; 
input  [7:0] in3;
input  [7:0] in2; 
input  [7:0] in1; 
input  [7:0] in0; 
//wire [5:0] select;
wire [5:0] sl;
wire [5:0] slb;

mj_p_muxdec6_8 i_mj_p_muxdec6 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux6_8	mj_p_mux6_8_0 (  .mx_out(mx_out),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux8_d_8 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [7:0] mx_out;
input [2:0] sel;
input  [7:0] in7;
input  [7:0] in6;
input  [7:0] in5;
input  [7:0] in4; 
input  [7:0] in3;
input  [7:0] in2; 
input  [7:0] in1; 
input  [7:0] in0; 
//wire [7:0] select;
wire [7:0] sl;
wire [7:0] slb;

mj_p_muxdec8_8 i_mj_p_muxdec8_8 ( .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux8_8	mj_p_mux8_8_0 (  .mx_out(mx_out),
    .in7(in7),
    .in6(in6),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux2_d_16 (mx_out, sel, in0, in1);

output [15:0] mx_out;
input   sel;
input  [15:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;
wire sel1b;

assign selb = ~sel;
assign sel1 = ~selb;
assign sel1b = ~sel1;


mj_p_mux2_16  mj_p_mux2_16_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(sel1b)) ;
endmodule


module mj_s_mux3_d_16 (mx_out, sel, in0, in1,in2);
output [15:0] mx_out;
input [1:0] sel;
input  [15:0] in2; 
input  [15:0] in1; 
input  [15:0] in0; 
//wire [2:0] select;
wire [2:0] sl;
wire [2:0] slb;

mj_p_muxdec3_16 i_mj_p_muxdec3 (   .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux3_16	mj_p_mux3_16_0 (  .mx_out(mx_out), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux4_d_16 (mx_out, sel, in0, in1,in2,in3);
output [15:0] mx_out;
input [1:0] sel;
input  [15:0] in3;
input  [15:0] in2; 
input  [15:0] in1; 
input  [15:0] in0; 
//wire [3:0] select;
wire [3:0] sl;
wire [3:0] slb;

mj_p_muxdec4_16 i_mj_p_muxdec4 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux4_16	mj_p_mux4_16_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux6_d_16 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [15:0] mx_out;
input [2:0] sel;
input  [15:0] in5;
input  [15:0] in4; 
input  [15:0] in3;
input  [15:0] in2; 
input  [15:0] in1; 
input  [15:0] in0; 
//wire [5:0] select;
wire [5:0] sl;
wire [5:0] slb;

mj_p_muxdec6_16 i_mj_p_muxdec6 (   .decb(slb),
                                  .dec(sl),
                                  .sel(sel)
                                  );

mj_p_mux6_16	mj_p_mux6_16_0 (  .mx_out(mx_out),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux8_d_16 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [15:0] mx_out;
input [2:0] sel;
input  [15:0] in7;
input  [15:0] in6;
input  [15:0] in5;
input  [15:0] in4; 
input  [15:0] in3;
input  [15:0] in2; 
input  [15:0] in1; 
input  [15:0] in0; 
//wire [7:0] select;
wire [7:0] sl;
wire [7:0] slb;

mj_p_muxdec8_16 i_mj_p_muxdec8_8 ( .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux8_16	mj_p_mux8_16_0 (  .mx_out(mx_out),
    .in7(in7),
    .in6(in6),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux2_d_32 (mx_out, sel, in0, in1);

output [31:0] mx_out;
input   sel;
input  [31:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;
wire sel1b;

assign selb = ~sel;
assign sel1 = ~selb;
assign sel1b = ~sel1;


mj_p_mux2_32  mj_p_mux2_32_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(sel1b)) ;
endmodule

module mj_s_mux2l_d_32 (mx_out, sel, in0, in1);

output [31:0] mx_out;
input   sel;
input  [31:0]  in0 , in1 ;
/*
wire    sel_not, mux_sel;
assign sel_not = ~sel;
assign mux_sel =  sel;
assign mx_out  = (mux_sel & in1 | sel_not & in0) ;
*/

wire selb;
wire sel1;
wire sel1b;

assign selb = ~sel;
assign sel1 = ~selb;
assign sel1b = ~sel1;


mj_p_mux2l_32  mj_p_mux2l_32_0 (
    		.mx_out(mx_out), 
    		.in1(in1),
    		.in0(in0),
    		.sel(sel1) ,
		.sel_l(sel1b)) ;
endmodule



module mj_s_mux3_d_32 (mx_out, sel, in0, in1,in2);
output [31:0] mx_out;
input [1:0] sel;
input  [31:0] in2; 
input  [31:0] in1; 
input  [31:0] in0; 
//wire [2:0] select;
wire [2:0] sl;
wire [2:0] slb;

mj_p_muxdec3_32 i_mj_p_muxdec3 (   .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux3_32	mj_p_mux3_32_0 (  .mx_out(mx_out), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux4_d_32 (mx_out, sel, in0, in1,in2,in3);
output [31:0] mx_out;
input [1:0] sel;
input  [31:0] in3;
input  [31:0] in2; 
input  [31:0] in1; 
input  [31:0] in0; 
//wire [3:0] select;
wire [3:0] sl;
wire [3:0] slb;

mj_p_muxdec4_32 i_mj_p_muxdec4 (   .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux4_32	mj_p_mux4_32_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux6_d_32 (mx_out, sel, in0, in1,in2,in3,in4,in5);
output [31:0] mx_out;
input [2:0] sel;
input  [31:0] in5;
input  [31:0] in4; 
input  [31:0] in3;
input  [31:0] in2; 
input  [31:0] in1; 
input  [31:0] in0; 
//wire [5:0] select;
wire [5:0] sl;
wire [5:0] slb;

mj_p_muxdec6_32 i_mj_p_muxdec6 (   .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux6_32	mj_p_mux6_32_0 (  .mx_out(mx_out),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_s_mux8_d_32 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [31:0] mx_out;
input [2:0] sel;
input  [31:0] in7;
input  [31:0] in6;
input  [31:0] in5;
input  [31:0] in4; 
input  [31:0] in3;
input  [31:0] in2; 
input  [31:0] in1; 
input  [31:0] in0; 
//wire [7:0] select;
wire [7:0] sl;
wire [7:0] slb;

mj_p_muxdec8_32 i_mj_p_muxdec8_8 ( .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux8_32	mj_p_mux8_32_0 (  .mx_out(mx_out),
    .in7(in7),
    .in6(in6),
    .in5(in5),
    .in4(in4),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule


/************** One Hot Muxes **************/

module mj_h_mux2 (
    mx_out, 
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in1;
    input in0;
    input sel;
    input sel_l;

    mj_p_mux2  mux_0 (	.mx_out(mx_out), 
			.in1(in1), 
			.in0(in0), 
			.sel(sel), 
			.sel_l(sel_l)
			);

endmodule


module mj_h_mux3 (
    mx_out, 
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in2;
    input in1;
    input in0;
    input [2:0] sel;
    input [2:0] sel_l;


    mj_p_mux3  mux_0 (	.mx_out(mx_out), 
			.in2(in2), 
			.in1(in1), 
			.in0(in0), 
			.sel(sel), 
			.sel_l(sel_l)
			);

endmodule


module mj_h_mux4 (
    mx_out, 
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in3;
    input in2;
    input in1;
    input in0;
    input [3:0] sel;
    input [3:0] sel_l;

    mj_p_mux4  mux_0 (	.mx_out(mx_out), 
			.in3(in3), 
			.in2(in2), 
			.in1(in1), 
			.in0(in0), 
			.sel(sel), 
			.sel_l(sel_l)
			);

endmodule


module mj_h_mux6 (
    mx_out, 
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [5:0] sel;
    input [5:0] sel_l;

    mj_p_mux6  mux_0 (	.mx_out(mx_out),
			.in5(in5), 
			.in4(in4), 
			.in3(in3), 
			.in2(in2), 
			.in1(in1), 
			.in0(in0), 
			.sel(sel), 
			.sel_l(sel_l)
			);

endmodule


module mj_h_mux8 (
    mx_out, 
    in7,
    in6,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in7;
    input in6;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [7:0] sel;
    input [7:0] sel_l;

    mj_p_mux8  mux_0 (	.mx_out(mx_out), 
			.in7(in7), 
			.in6(in6), 
			.in5(in5), 
			.in4(in4), 
			.in3(in3), 
			.in2(in2), 
			.in1(in1), 
			.in0(in0), 
			.sel(sel), 
			.sel_l(sel_l)
			);

endmodule


module mj_h_mux2_2 (mx_out, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  sel ; input sel_l;

    mj_h_mux2 mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2 mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_2 (mx_out, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_2 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux6_2 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux8_2 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [1:0] mx_out;
    input  [1:0] in7; 
    input  [1:0] in6; 
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux2_3 (mx_out, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in1; 
    input  [2:0] in0; 
    input    sel ; input   sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_3 (mx_out, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_3 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux6_3 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux8_3 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [2:0] mx_out;
    input  [2:0] in7; 
    input  [2:0] in6; 
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux2_4 (mx_out, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  sel ; input  sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_h_mux2_5 (mx_out, in1, in0, sel, sel_l);
    output [4:0] mx_out;
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  sel ; input  sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_4 (mx_out, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_4 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux6_4 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux8_4 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [3:0] mx_out;
    input  [3:0] in7; 
    input  [3:0] in6; 
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux2_6 (mx_out, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in1; 
    input  [5:0] in0; 
    input    sel ; input  sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_6 (mx_out, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_6 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux6_6 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux8_6 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [5:0] mx_out;
    input  [5:0] in7; 
    input  [5:0] in6; 
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux2_8 (mx_out, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in1; 
    input  [7:0] in0; 
    input    sel ; input  sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_8 (mx_out, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_6 (.mx_out(mx_out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_7 (.mx_out(mx_out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_8 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux6_8 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_6 (.mx_out(mx_out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_7 (.mx_out(mx_out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux8_8 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [7:0] mx_out;
    input  [7:0] in7; 
    input  [7:0] in6; 
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_6 (.mx_out(mx_out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_7 (.mx_out(mx_out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux2_16 (mx_out, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in1; 
    input  [15:0] in0; 
    input    sel ; input   sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_16 (mx_out, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_6 (.mx_out(mx_out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_7 (.mx_out(mx_out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_8 (.mx_out(mx_out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_9 (.mx_out(mx_out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_10 (.mx_out(mx_out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_11 (.mx_out(mx_out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_12 (.mx_out(mx_out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_13 (.mx_out(mx_out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_14 (.mx_out(mx_out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_15 (.mx_out(mx_out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_16 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in3; 
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_8 (.mx_out(mx_out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_9 (.mx_out(mx_out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_10 (.mx_out(mx_out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_11 (.mx_out(mx_out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_12 (.mx_out(mx_out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_13 (.mx_out(mx_out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_14 (.mx_out(mx_out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_15 (.mx_out(mx_out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_h_mux6_16 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in5; 
    input  [15:0] in4; 
    input  [15:0] in3; 
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_6 (.mx_out(mx_out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_7 (.mx_out(mx_out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_8 (.mx_out(mx_out[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_9 (.mx_out(mx_out[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_10 (.mx_out(mx_out[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_11 (.mx_out(mx_out[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_12 (.mx_out(mx_out[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_13 (.mx_out(mx_out[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_14 (.mx_out(mx_out[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_15 (.mx_out(mx_out[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux8_16 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [15:0] mx_out;
    input  [15:0] in7; 
    input  [15:0] in6; 
    input  [15:0] in5; 
    input  [15:0] in4; 
    input  [15:0] in3; 
    input  [15:0] in2; 
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_6 (.mx_out(mx_out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_7 (.mx_out(mx_out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_8 (.mx_out(mx_out[8]), .in7(in7[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_9 (.mx_out(mx_out[9]), .in7(in7[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_10 (.mx_out(mx_out[10]), .in7(in7[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_11 (.mx_out(mx_out[11]), .in7(in7[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_12 (.mx_out(mx_out[12]), .in7(in7[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_13 (.mx_out(mx_out[13]), .in7(in7[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_14 (.mx_out(mx_out[14]), .in7(in7[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_15 (.mx_out(mx_out[15]), .in7(in7[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_h_mux2_30 (mx_out, in1, in0, sel, sel_l);
    output [29:0] mx_out;
    input  [29:0] in1; 
    input  [29:0] in0; 
    input    sel ; input   sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_16 (.mx_out(mx_out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_17 (.mx_out(mx_out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_18 (.mx_out(mx_out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_19 (.mx_out(mx_out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_20 (.mx_out(mx_out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_21 (.mx_out(mx_out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_22 (.mx_out(mx_out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_23 (.mx_out(mx_out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_24 (.mx_out(mx_out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_25 (.mx_out(mx_out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_26 (.mx_out(mx_out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_27 (.mx_out(mx_out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_28 (.mx_out(mx_out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_29 (.mx_out(mx_out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_h_mux2_32 (mx_out, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in1; 
    input  [31:0] in0; 
    input    sel ; input   sel_l;

    mj_h_mux2  mux_0 (.mx_out(mx_out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_1 (.mx_out(mx_out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_2 (.mx_out(mx_out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_3 (.mx_out(mx_out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_4 (.mx_out(mx_out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_5 (.mx_out(mx_out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_6 (.mx_out(mx_out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_7 (.mx_out(mx_out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_8 (.mx_out(mx_out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_9 (.mx_out(mx_out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_10 (.mx_out(mx_out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_11 (.mx_out(mx_out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_12 (.mx_out(mx_out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_13 (.mx_out(mx_out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_14 (.mx_out(mx_out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_15 (.mx_out(mx_out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_16 (.mx_out(mx_out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_17 (.mx_out(mx_out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_18 (.mx_out(mx_out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_19 (.mx_out(mx_out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_20 (.mx_out(mx_out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_21 (.mx_out(mx_out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_22 (.mx_out(mx_out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_23 (.mx_out(mx_out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_24 (.mx_out(mx_out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_25 (.mx_out(mx_out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_26 (.mx_out(mx_out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_27 (.mx_out(mx_out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_28 (.mx_out(mx_out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_29 (.mx_out(mx_out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_30 (.mx_out(mx_out[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_h_mux2  mux_31 (.mx_out(mx_out[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux3_32 (mx_out, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [2:0] sel; input  [2:0] sel_l;

    mj_h_mux3  mux_0 (.mx_out(mx_out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_1 (.mx_out(mx_out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_2 (.mx_out(mx_out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_3 (.mx_out(mx_out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_4 (.mx_out(mx_out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_5 (.mx_out(mx_out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_6 (.mx_out(mx_out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_7 (.mx_out(mx_out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_8 (.mx_out(mx_out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_9 (.mx_out(mx_out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_10 (.mx_out(mx_out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_11 (.mx_out(mx_out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_12 (.mx_out(mx_out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_13 (.mx_out(mx_out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_14 (.mx_out(mx_out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_15 (.mx_out(mx_out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_16 (.mx_out(mx_out[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_17 (.mx_out(mx_out[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_18 (.mx_out(mx_out[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_19 (.mx_out(mx_out[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_20 (.mx_out(mx_out[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_21 (.mx_out(mx_out[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_22 (.mx_out(mx_out[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_23 (.mx_out(mx_out[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_24 (.mx_out(mx_out[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_25 (.mx_out(mx_out[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_26 (.mx_out(mx_out[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_27 (.mx_out(mx_out[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_28 (.mx_out(mx_out[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_29 (.mx_out(mx_out[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_30 (.mx_out(mx_out[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_h_mux3  mux_31 (.mx_out(mx_out[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 


module mj_h_mux4_32 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_h_mux4  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_8 (.mx_out(mx_out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_9 (.mx_out(mx_out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_10 (.mx_out(mx_out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_11 (.mx_out(mx_out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_12 (.mx_out(mx_out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_13 (.mx_out(mx_out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_14 (.mx_out(mx_out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_15 (.mx_out(mx_out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_16 (.mx_out(mx_out[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_17 (.mx_out(mx_out[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_18 (.mx_out(mx_out[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_19 (.mx_out(mx_out[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_20 (.mx_out(mx_out[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_21 (.mx_out(mx_out[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_22 (.mx_out(mx_out[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_23 (.mx_out(mx_out[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_24 (.mx_out(mx_out[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_25 (.mx_out(mx_out[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_26 (.mx_out(mx_out[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_27 (.mx_out(mx_out[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_28 (.mx_out(mx_out[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_29 (.mx_out(mx_out[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_30 (.mx_out(mx_out[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_h_mux4  mux_31 (.mx_out(mx_out[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 




module mj_h_mux6_32 (mx_out, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [5:0] sel; input  [5:0] sel_l;

    mj_h_mux6  mux_0 (.mx_out(mx_out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_1 (.mx_out(mx_out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_2 (.mx_out(mx_out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_3 (.mx_out(mx_out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_4 (.mx_out(mx_out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_5 (.mx_out(mx_out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_6 (.mx_out(mx_out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_7 (.mx_out(mx_out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_8 (.mx_out(mx_out[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_9 (.mx_out(mx_out[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_10 (.mx_out(mx_out[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_11 (.mx_out(mx_out[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_12 (.mx_out(mx_out[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_13 (.mx_out(mx_out[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_14 (.mx_out(mx_out[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_15 (.mx_out(mx_out[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_16 (.mx_out(mx_out[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_17 (.mx_out(mx_out[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_18 (.mx_out(mx_out[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_19 (.mx_out(mx_out[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_20 (.mx_out(mx_out[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_21 (.mx_out(mx_out[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_22 (.mx_out(mx_out[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_23 (.mx_out(mx_out[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_24 (.mx_out(mx_out[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_25 (.mx_out(mx_out[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_26 (.mx_out(mx_out[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_27 (.mx_out(mx_out[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_28 (.mx_out(mx_out[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_29 (.mx_out(mx_out[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_30 (.mx_out(mx_out[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_h_mux6  mux_31 (.mx_out(mx_out[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 



module mj_h_mux8_32 (mx_out, in7, in6, in5, in4, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in7; 
    input  [31:0] in6; 
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [7:0] sel; input  [7:0] sel_l;

    mj_h_mux8  mux_0 (.mx_out(mx_out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_1 (.mx_out(mx_out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_2 (.mx_out(mx_out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_3 (.mx_out(mx_out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_4 (.mx_out(mx_out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_5 (.mx_out(mx_out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_6 (.mx_out(mx_out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_7 (.mx_out(mx_out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_8 (.mx_out(mx_out[8]), .in7(in7[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_9 (.mx_out(mx_out[9]), .in7(in7[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_10 (.mx_out(mx_out[10]), .in7(in7[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_11 (.mx_out(mx_out[11]), .in7(in7[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_12 (.mx_out(mx_out[12]), .in7(in7[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_13 (.mx_out(mx_out[13]), .in7(in7[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_14 (.mx_out(mx_out[14]), .in7(in7[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_15 (.mx_out(mx_out[15]), .in7(in7[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_16 (.mx_out(mx_out[16]), .in7(in7[16]), .in6(in6[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_17 (.mx_out(mx_out[17]), .in7(in7[17]), .in6(in6[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_18 (.mx_out(mx_out[18]), .in7(in7[18]), .in6(in6[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_19 (.mx_out(mx_out[19]), .in7(in7[19]), .in6(in6[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_20 (.mx_out(mx_out[20]), .in7(in7[20]), .in6(in6[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_21 (.mx_out(mx_out[21]), .in7(in7[21]), .in6(in6[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_22 (.mx_out(mx_out[22]), .in7(in7[22]), .in6(in6[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_23 (.mx_out(mx_out[23]), .in7(in7[23]), .in6(in6[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_24 (.mx_out(mx_out[24]), .in7(in7[24]), .in6(in6[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_25 (.mx_out(mx_out[25]), .in7(in7[25]), .in6(in6[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_26 (.mx_out(mx_out[26]), .in7(in7[26]), .in6(in6[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_27 (.mx_out(mx_out[27]), .in7(in7[27]), .in6(in6[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_28 (.mx_out(mx_out[28]), .in7(in7[28]), .in6(in6[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_29 (.mx_out(mx_out[29]), .in7(in7[29]), .in6(in6[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_30 (.mx_out(mx_out[30]), .in7(in7[30]), .in6(in6[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_h_mux8  mux_31 (.mx_out(mx_out[31]), .in7(in7[31]), .in6(in6[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_s_mux8_d_19 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [18:0] mx_out;
input [2:0] sel;
input  [18:0] in7;
input  [18:0] in6;
input  [18:0] in5;
input  [18:0] in4; 
input  [18:0] in3;
input  [18:0] in2; 
input  [18:0] in1; 
input  [18:0] in0; 
reg [7:0] sl;
wire [7:0] slb;

always @(sel)  begin
   case (sel)      // synopsys full_case parallel_case
      3'b000:    sl = 8'h1;
      3'b001:    sl = 8'h2;
      3'b010:    sl = 8'h4;
      3'b011:    sl = 8'h8;
      3'b100:    sl = 8'h10;
      3'b101:    sl = 8'h20;
      3'b110:    sl = 8'h40;
      3'b111:    sl = 8'h80;
      default:   sl = 8'h80;
   endcase
end

assign slb = ~sl;

mj_p_mux8 mj_p_mux8_0 (  .mx_out(mx_out[0]), 
    			.in7(in7[0]),
    			.in6(in6[0]),
    			.in5(in5[0]),
    			.in4(in4[0]),	
    			.in3(in3[0]),
    			.in2(in2[0]),	
    			.in1(in1[0]),
    			.in0(in0[0]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_1 (  .mx_out(mx_out[1]), 
    			.in7(in7[1]),
    			.in6(in6[1]),
    			.in5(in5[1]),
    			.in4(in4[1]),	
    			.in3(in3[1]),
    			.in2(in2[1]),	
    			.in1(in1[1]),
    			.in0(in0[1]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_2 (  .mx_out(mx_out[2]), 
    			.in7(in7[2]),
    			.in6(in6[2]),
    			.in5(in5[2]),
    			.in4(in4[2]),	
    			.in3(in3[2]),
    			.in2(in2[2]),	
    			.in1(in1[2]),
    			.in0(in0[2]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_3 (  .mx_out(mx_out[3]), 
    			.in7(in7[3]),
    			.in6(in6[3]),
    			.in5(in5[3]),
    			.in4(in4[3]),	
    			.in3(in3[3]),
    			.in2(in2[3]),	
    			.in1(in1[3]),
    			.in0(in0[3]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_4 (  .mx_out(mx_out[4]), 
    			.in7(in7[4]),
    			.in6(in6[4]),
    			.in5(in5[4]),
    			.in4(in4[4]),	
    			.in3(in3[4]),
    			.in2(in2[4]),	
    			.in1(in1[4]),
    			.in0(in0[4]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_5 (  .mx_out(mx_out[5]), 
    			.in7(in7[5]),
    			.in6(in6[5]),
    			.in5(in5[5]),
    			.in4(in4[5]),	
    			.in3(in3[5]),
    			.in2(in2[5]),	
    			.in1(in1[5]),
    			.in0(in0[5]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_6 (  .mx_out(mx_out[6]), 
    			.in7(in7[6]),
    			.in6(in6[6]),
    			.in5(in5[6]),
    			.in4(in4[6]),	
    			.in3(in3[6]),
    			.in2(in2[6]),	
    			.in1(in1[6]),
    			.in0(in0[6]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_7 (  .mx_out(mx_out[7]), 
    			.in7(in7[7]),
    			.in6(in6[7]),
    			.in5(in5[7]),
    			.in4(in4[7]),	
    			.in3(in3[7]),
    			.in2(in2[7]),	
    			.in1(in1[7]),
    			.in0(in0[7]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_8 (  .mx_out(mx_out[8]), 
    			.in7(in7[8]),
    			.in6(in6[8]),
    			.in5(in5[8]),
    			.in4(in4[8]),	
    			.in3(in3[8]),
    			.in2(in2[8]),	
    			.in1(in1[8]),
    			.in0(in0[8]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_9 (  .mx_out(mx_out[9]), 
    			.in7(in7[9]),
    			.in6(in6[9]),
    			.in5(in5[9]),
    			.in4(in4[9]),	
    			.in3(in3[9]),
    			.in2(in2[9]),	
    			.in1(in1[9]),
    			.in0(in0[9]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_10 (  .mx_out(mx_out[10]), 
    			.in7(in7[10]),
    			.in6(in6[10]),
    			.in5(in5[10]),
    			.in4(in4[10]),	
    			.in3(in3[10]),
    			.in2(in2[10]),	
    			.in1(in1[10]),
    			.in0(in0[10]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_11 (  .mx_out(mx_out[11]), 
    			.in7(in7[11]),
    			.in6(in6[11]),
    			.in5(in5[11]),
    			.in4(in4[11]),	
    			.in3(in3[11]),
    			.in2(in2[11]),	
    			.in1(in1[11]),
    			.in0(in0[11]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_12 (  .mx_out(mx_out[12]), 
    			.in7(in7[12]),
    			.in6(in6[12]),
    			.in5(in5[12]),
    			.in4(in4[12]),	
    			.in3(in3[12]),
    			.in2(in2[12]),	
    			.in1(in1[12]),
    			.in0(in0[12]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_13 (  .mx_out(mx_out[13]), 
    			.in7(in7[13]),
    			.in6(in6[13]),
    			.in5(in5[13]),
    			.in4(in4[13]),	
    			.in3(in3[13]),
    			.in2(in2[13]),	
    			.in1(in1[13]),
    			.in0(in0[13]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_14 (  .mx_out(mx_out[14]), 
    			.in7(in7[14]),
    			.in6(in6[14]),
    			.in5(in5[14]),
    			.in4(in4[14]),	
    			.in3(in3[14]),
    			.in2(in2[14]),	
    			.in1(in1[14]),
    			.in0(in0[14]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_15 (  .mx_out(mx_out[15]), 
    			.in7(in7[15]),
    			.in6(in6[15]),
    			.in5(in5[15]),
    			.in4(in4[15]),	
    			.in3(in3[15]),
    			.in2(in2[15]),	
    			.in1(in1[15]),
    			.in0(in0[15]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_16 (  .mx_out(mx_out[16]), 
    			.in7(in7[16]),
    			.in6(in6[16]),
    			.in5(in5[16]),
    			.in4(in4[16]),	
    			.in3(in3[16]),
    			.in2(in2[16]),	
    			.in1(in1[16]),
    			.in0(in0[16]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_17 (  .mx_out(mx_out[17]), 
    			.in7(in7[17]),
    			.in6(in6[17]),
    			.in5(in5[17]),
    			.in4(in4[17]),	
    			.in3(in3[17]),
    			.in2(in2[17]),	
    			.in1(in1[17]),
    			.in0(in0[17]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_18 (  .mx_out(mx_out[18]), 
    			.in7(in7[18]),
    			.in6(in6[18]),
    			.in5(in5[18]),
    			.in4(in4[18]),	
    			.in3(in3[18]),
    			.in2(in2[18]),	
    			.in1(in1[18]),
    			.in0(in0[18]),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule

module mj_s_mux8_d_10 (mx_out, sel, in0, in1,in2,in3,in4,in5,in6,in7);
output [9:0] mx_out;
input [2:0] sel;
input  [9:0] in7;
input  [9:0] in6;
input  [9:0] in5;
input  [9:0] in4; 
input  [9:0] in3;
input  [9:0] in2; 
input  [9:0] in1; 
input  [9:0] in0; 
reg [7:0] sl;
wire [7:0] slb;

always @(sel)  begin
   case (sel)      // synopsys full_case parallel_case
      3'b000:    sl = 8'h1;
      3'b001:    sl = 8'h2;
      3'b010:    sl = 8'h4;
      3'b011:    sl = 8'h8;
      3'b100:    sl = 8'h10;
      3'b101:    sl = 8'h20;
      3'b110:    sl = 8'h40;
      3'b111:    sl = 8'h80;
      default:   sl = 8'h80;
   endcase
end

assign slb = ~sl;

mj_p_mux8 mj_p_mux8_0 (  .mx_out(mx_out[0]), 
    			.in7(in7[0]),
    			.in6(in6[0]),
    			.in5(in5[0]),
    			.in4(in4[0]),	
    			.in3(in3[0]),
    			.in2(in2[0]),	
    			.in1(in1[0]),
    			.in0(in0[0]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_1 (  .mx_out(mx_out[1]), 
    			.in7(in7[1]),
    			.in6(in6[1]),
    			.in5(in5[1]),
    			.in4(in4[1]),	
    			.in3(in3[1]),
    			.in2(in2[1]),	
    			.in1(in1[1]),
    			.in0(in0[1]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_2 (  .mx_out(mx_out[2]), 
    			.in7(in7[2]),
    			.in6(in6[2]),
    			.in5(in5[2]),
    			.in4(in4[2]),	
    			.in3(in3[2]),
    			.in2(in2[2]),	
    			.in1(in1[2]),
    			.in0(in0[2]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_3 (  .mx_out(mx_out[3]), 
    			.in7(in7[3]),
    			.in6(in6[3]),
    			.in5(in5[3]),
    			.in4(in4[3]),	
    			.in3(in3[3]),
    			.in2(in2[3]),	
    			.in1(in1[3]),
    			.in0(in0[3]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_4 (  .mx_out(mx_out[4]), 
    			.in7(in7[4]),
    			.in6(in6[4]),
    			.in5(in5[4]),
    			.in4(in4[4]),	
    			.in3(in3[4]),
    			.in2(in2[4]),	
    			.in1(in1[4]),
    			.in0(in0[4]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_5 (  .mx_out(mx_out[5]), 
    			.in7(in7[5]),
    			.in6(in6[5]),
    			.in5(in5[5]),
    			.in4(in4[5]),	
    			.in3(in3[5]),
    			.in2(in2[5]),	
    			.in1(in1[5]),
    			.in0(in0[5]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_6 (  .mx_out(mx_out[6]), 
    			.in7(in7[6]),
    			.in6(in6[6]),
    			.in5(in5[6]),
    			.in4(in4[6]),	
    			.in3(in3[6]),
    			.in2(in2[6]),	
    			.in1(in1[6]),
    			.in0(in0[6]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_7 (  .mx_out(mx_out[7]), 
    			.in7(in7[7]),
    			.in6(in6[7]),
    			.in5(in5[7]),
    			.in4(in4[7]),	
    			.in3(in3[7]),
    			.in2(in2[7]),	
    			.in1(in1[7]),
    			.in0(in0[7]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_8 (  .mx_out(mx_out[8]), 
    			.in7(in7[8]),
    			.in6(in6[8]),
    			.in5(in5[8]),
    			.in4(in4[8]),	
    			.in3(in3[8]),
    			.in2(in2[8]),	
    			.in1(in1[8]),
    			.in0(in0[8]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux8 mj_p_mux8_9 (  .mx_out(mx_out[9]), 
    			.in7(in7[9]),
    			.in6(in6[9]),
    			.in5(in5[9]),
    			.in4(in4[9]),	
    			.in3(in3[9]),
    			.in2(in2[9]),	
    			.in1(in1[9]),
    			.in0(in0[9]),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule

module mj_s_mux3_d_17 (mx_out, sel, in0, in1,in2);
output [16:0] mx_out;
input [1:0] sel;
input  [16:0] in2; 
input  [16:0] in1; 
input  [16:0] in0; 
reg [2:0] sl;
wire [2:0] slb;

always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    sl = 3'b001;
      2'b01:    sl = 3'b010;
      2'b10:    sl = 3'b100;
      default:  sl = 3'b100;
   endcase
end

assign slb = ~sl;

mj_p_mux3 mj_p_mux3_0 (  .mx_out(mx_out[0]), 
    			.in2(in2[0]),	
    			.in1(in1[0]),
    			.in0(in0[0]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_1 (  .mx_out(mx_out[1]), 
    			.in2(in2[1]),	
    			.in1(in1[1]),
    			.in0(in0[1]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_2 (  .mx_out(mx_out[2]), 
    			.in2(in2[2]),	
    			.in1(in1[2]),
    			.in0(in0[2]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_3 (  .mx_out(mx_out[3]), 
    			.in2(in2[3]),	
    			.in1(in1[3]),
    			.in0(in0[3]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_4 (  .mx_out(mx_out[4]), 
    			.in2(in2[4]),	
    			.in1(in1[4]),
    			.in0(in0[4]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_5 (  .mx_out(mx_out[5]), 
    			.in2(in2[5]),	
    			.in1(in1[5]),
    			.in0(in0[5]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_6 (  .mx_out(mx_out[6]), 
    			.in2(in2[6]),	
    			.in1(in1[6]),
    			.in0(in0[6]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_7 (  .mx_out(mx_out[7]), 
    			.in2(in2[7]),	
    			.in1(in1[7]),
    			.in0(in0[7]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_8 (  .mx_out(mx_out[8]), 
    			.in2(in2[8]),	
    			.in1(in1[8]),
    			.in0(in0[8]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_9 (  .mx_out(mx_out[9]), 
    			.in2(in2[9]),	
    			.in1(in1[9]),
    			.in0(in0[9]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_10 (  .mx_out(mx_out[10]), 
    			.in2(in2[10]),	
    			.in1(in1[10]),
    			.in0(in0[10]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_11 (  .mx_out(mx_out[11]), 
    			.in2(in2[11]),	
    			.in1(in1[11]),
    			.in0(in0[11]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_12 (  .mx_out(mx_out[12]), 
    			.in2(in2[12]),	
    			.in1(in1[12]),
    			.in0(in0[12]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_13 (  .mx_out(mx_out[13]), 
    			.in2(in2[13]),	
    			.in1(in1[13]),
    			.in0(in0[13]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_14 (  .mx_out(mx_out[14]), 
    			.in2(in2[14]),	
    			.in1(in1[14]),
    			.in0(in0[14]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_15 (  .mx_out(mx_out[15]), 
    			.in2(in2[15]),	
    			.in1(in1[15]),
    			.in0(in0[15]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux3 mj_p_mux3_16 (  .mx_out(mx_out[16]), 
    			.in2(in2[16]),	
    			.in1(in1[16]),
    			.in0(in0[16]),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule

module mj_s_mux2_d_10 (mx_out, sel, in0, in1);
output [9:0] mx_out;
input        sel;
input  [9:0] in1; 
input  [9:0] in0; 
wire sl;
wire slb;

assign slb = ~sel;
assign sl = ~slb;

mj_p_mux2 mj_p_mux2_0 (  .mx_out(mx_out[0]), 
    			.in1(in1[0]),
    			.in0(in0[0]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_1 (  .mx_out(mx_out[1]), 
    			.in1(in1[1]),
    			.in0(in0[1]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_2 (  .mx_out(mx_out[2]), 
    			.in1(in1[2]),
    			.in0(in0[2]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_3 (  .mx_out(mx_out[3]), 
    			.in1(in1[3]),
    			.in0(in0[3]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_4 (  .mx_out(mx_out[4]), 
    			.in1(in1[4]),
    			.in0(in0[4]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_5 (  .mx_out(mx_out[5]), 
    			.in1(in1[5]),
    			.in0(in0[5]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_6 (  .mx_out(mx_out[6]), 
    			.in1(in1[6]),
    			.in0(in0[6]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_7 (  .mx_out(mx_out[7]), 
    			.in1(in1[7]),
    			.in0(in0[7]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_8 (  .mx_out(mx_out[8]), 
    			.in1(in1[8]),
    			.in0(in0[8]),
    			.sel(sl),
			.sel_l(slb)
			);

mj_p_mux2 mj_p_mux2_9 (  .mx_out(mx_out[9]), 
    			.in1(in1[9]),
    			.in0(in0[9]),
    			.sel(sl),
			.sel_l(slb)
			);

endmodule



module mux2 (
    out,
    in1,
    in0,
    sel
    );

    output out;
    input in1;
    input in0;
    input [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mj_p_mux2  mux_0 (  .mx_out(out),
                        .in1(in1),
                        .in0(in0),
                        .sel(sl[1]),
                        .sel_l(sl[0])
                        );

endmodule

module mux3 (
    out,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in2;
    input in1;
    input in0;
    input [2:0] sel;
    wire  [2:0] slb;
    wire  [2:0] sl;		

mj_p_muxpri3 mj_p_muxpri3_i0 (.sl(sel),.slb(slb));
assign sl = ~slb;

mj_p_mux3      mux_0 (  .mx_out(out),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sl),
                        .sel_l(slb)
                        );

endmodule


module mux4 (
    out,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in3;
    input in2;
    input in1;
    input in0;
    input [3:0] sel;
    wire  [3:0] slb;
    wire  [3:0] sl;		

mj_p_muxpri4 mj_p_muxpri4_i0 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mj_p_mux4  mux_0 (  .mx_out(out),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sl),
                        .sel_l(slb)
                        );

endmodule


module mux5 (
    out,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [4:0] sel;
    wire  [5:0] slb;
    wire  [5:0] sl;		

mj_p_muxpri6 mj_p_muxpri6_i0 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mj_p_mux6  mux_0 (  .mx_out(out),
                        .in5(1'b0),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel({1'b0,sl[4:0]}),
                        .sel_l({1'b1,slb[4:0]})
                        );

endmodule


module mux6 (
    out,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [5:0] sel;
    wire  [5:0] slb;
    wire  [5:0] sl;		

mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mj_p_mux6  mux_0 (  .mx_out(out),
                        .in5(in5),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sl),
                        .sel_l(slb)
                        );

endmodule


module mux7 (
    out,
    in6,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in6;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [6:0] sel;
    wire  [7:0] slb;
    wire  [7:0] sl;		

mj_p_muxpri8 mj_p_muxpri8_i0 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mj_p_mux8  mux_0 (  .mx_out(out),
                        .in7(1'b0),
                        .in6(in6),
                        .in5(in5),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel({1'b0,sl[6:0]}),
                        .sel_l({1'b1,slb[6:0]})
                        );


endmodule


module mux8 (
    out,
    in7,
    in6,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in7;
    input in6;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [7:0] sel;
    wire  [7:0] slb;
    wire  [7:0] sl;	

mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mj_p_mux8  mux_0 (  .mx_out(out),
                        .in7(in7),
                        .in6(in6),
                        .in5(in5),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sl),
                        .sel_l(slb)
                        );

endmodule



module mux2p (
    out,
    in1,
    in0,
    sel
    );

    output out;
    input in1;
    input in0;
    input [1:0] sel;

    mj_p_mux2  mux_0 (  .mx_out(out),
                        .in1(in1),
                        .in0(in0),
                        .sel(sel[1]),
                        .sel_l(sel[0])
                        );

endmodule


module mux3p (
    out,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in2;
    input in1;
    input in0;
    input [2:0] sel;

    mj_p_mux3  mux_0 (  .mx_out(out),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sel),
                        .sel_l(~sel)
                        );

endmodule


module mux4p (
    out,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in3;
    input in2;
    input in1;
    input in0;
    input [3:0] sel;

    mj_p_mux4  mux_0 (  .mx_out(out),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sel),
                        .sel_l(~sel)
                        );

endmodule


module mux5p (
    out,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [4:0] sel;

    mj_p_mux6  mux_0 (  .mx_out(out),
                        .in5(1'b0),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel({1'b0,sel}),
                        .sel_l(~{1'b0,sel})
                        );

endmodule


module mux6p (
    out,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [5:0] sel;

    mj_p_mux6  mux_0 (  .mx_out(out),
                        .in5(in5),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sel),
                        .sel_l(~sel)
                        );

endmodule


module mux7p (
    out,
    in6,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in6;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [6:0] sel;

    mj_p_mux8  mux_0 (  .mx_out(out),
                        .in7(1'b0),
                        .in6(in6),
                        .in5(in5),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel({1'b0,sel}),
                        .sel_l(~{1'b0,sel})
                        );


endmodule


module mux8p (
    out,
    in7,
    in6,
    in5,
    in4,
    in3,
    in2,
    in1,
    in0,
    sel
    );

    output out;
    input in7;
    input in6;
    input in5;
    input in4;
    input in3;
    input in2;
    input in1;
    input in0;
    input [7:0] sel;

    mj_p_mux8  mux_0 (  .mx_out(out),
                        .in7(in7),
                        .in6(in6),
                        .in5(in5),
                        .in4(in4),
                        .in3(in3),
                        .in2(in2),
                        .in1(in1),
                        .in0(in0),
                        .sel(sel),
                        .sel_l(~sel)
                        );

endmodule

module mux2_2 (out, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));

endmodule 


module mux3_2 (out, in2, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));

endmodule 


module mux4_2 (out, in3, in2, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));

endmodule 


module mux5_2 (out, in4, in3, in2, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;

    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));

endmodule 


module mux6_2 (out, in5, in4, in3, in2, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));

endmodule 


module mux7_2 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in6; 
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));

endmodule 


module mux8_2 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [1:0] out;
    input  [1:0] in7; 
    input  [1:0] in6; 
    input  [1:0] in5; 
    input  [1:0] in4; 
    input  [1:0] in3; 
    input  [1:0] in2; 
    input  [1:0] in1; 
    input  [1:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));

endmodule 


module mux2_3 (out, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));

endmodule 


module mux3_3 (out, in2, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));

endmodule 


module mux4_3 (out, in3, in2, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));

endmodule 


module mux5_3 (out, in4, in3, in2, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;

    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));

endmodule 


module mux6_3 (out, in5, in4, in3, in2, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));

endmodule 


module mux7_3 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in6; 
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));

endmodule 


module mux8_3 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [2:0] out;
    input  [2:0] in7; 
    input  [2:0] in6; 
    input  [2:0] in5; 
    input  [2:0] in4; 
    input  [2:0] in3; 
    input  [2:0] in2; 
    input  [2:0] in1; 
    input  [2:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));

endmodule 


module mux2_4 (out, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));

endmodule 


module mux3_4 (out, in2, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));

endmodule 


module mux4_4 (out, in3, in2, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));

endmodule 


module mux5_4 (out, in4, in3, in2, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));
    mux5p  mux_3 (.out(out[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[4:0]));

endmodule 


module mux6_4 (out, in5, in4, in3, in2, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux6p  mux_3 (.out(out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));

endmodule 


module mux7_4 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in6; 
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));
    mux7p  mux_3 (.out(out[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel));

endmodule 


module mux8_4 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [3:0] out;
    input  [3:0] in7; 
    input  [3:0] in6; 
    input  [3:0] in5; 
    input  [3:0] in4; 
    input  [3:0] in3; 
    input  [3:0] in2; 
    input  [3:0] in1; 
    input  [3:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));

endmodule 


module mux2_5 (out, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));

endmodule 


module mux3_5 (out, in2, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in2; 
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));

endmodule 


module mux4_5 (out, in3, in2, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in3; 
    input  [4:0] in2; 
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));

endmodule 


module mux5_5 (out, in4, in3, in2, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in4; 
    input  [4:0] in3; 
    input  [4:0] in2; 
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));
    mux5p  mux_3 (.out(out[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[4:0]));
    mux5p  mux_4 (.out(out[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl[4:0]));

endmodule 


module mux6_5 (out, in5, in4, in3, in2, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in5; 
    input  [4:0] in4; 
    input  [4:0] in3; 
    input  [4:0] in2; 
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux6p  mux_3 (.out(out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux6p  mux_4 (.out(out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));

endmodule 


module mux7_5 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in6; 
    input  [4:0] in5; 
    input  [4:0] in4; 
    input  [4:0] in3; 
    input  [4:0] in2; 
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));
    mux7p  mux_3 (.out(out[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel));
    mux7p  mux_4 (.out(out[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel));

endmodule 


module mux8_5 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [4:0] out;
    input  [4:0] in7; 
    input  [4:0] in6; 
    input  [4:0] in5; 
    input  [4:0] in4; 
    input  [4:0] in3; 
    input  [4:0] in2; 
    input  [4:0] in1; 
    input  [4:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux8p  mux_4 (.out(out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));

endmodule 


module mux2_6 (out, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));

endmodule 


module mux3_6 (out, in2, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux3p  mux_5 (.out(out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));

endmodule 


module mux4_6 (out, in3, in2, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux4p  mux_5 (.out(out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));

endmodule 


module mux5_6 (out, in4, in3, in2, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));
    mux5p  mux_3 (.out(out[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[4:0]));
    mux5p  mux_4 (.out(out[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl[4:0]));
    mux5p  mux_5 (.out(out[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl[4:0]));

endmodule 


module mux6_6 (out, in5, in4, in3, in2, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux6p  mux_3 (.out(out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux6p  mux_4 (.out(out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux6p  mux_5 (.out(out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));

endmodule 


module mux7_6 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in6; 
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));
    mux7p  mux_3 (.out(out[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel));
    mux7p  mux_4 (.out(out[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel));
    mux7p  mux_5 (.out(out[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel));

endmodule 


module mux8_6 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [5:0] out;
    input  [5:0] in7; 
    input  [5:0] in6; 
    input  [5:0] in5; 
    input  [5:0] in4; 
    input  [5:0] in3; 
    input  [5:0] in2; 
    input  [5:0] in1; 
    input  [5:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux8p  mux_4 (.out(out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux8p  mux_5 (.out(out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));

endmodule 


module mux2_7 (out, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));

endmodule 


module mux3_7 (out, in2, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in2; 
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux3p  mux_5 (.out(out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux3p  mux_6 (.out(out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));

endmodule 


module mux4_7 (out, in3, in2, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in3; 
    input  [6:0] in2; 
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux4p  mux_5 (.out(out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux4p  mux_6 (.out(out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));

endmodule 


module mux5_7 (out, in4, in3, in2, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in4; 
    input  [6:0] in3; 
    input  [6:0] in2; 
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));
    mux5p  mux_3 (.out(out[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[4:0]));
    mux5p  mux_4 (.out(out[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl[4:0]));
    mux5p  mux_5 (.out(out[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl[4:0]));
    mux5p  mux_6 (.out(out[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl[4:0]));

endmodule 


module mux6_7 (out, in5, in4, in3, in2, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in5; 
    input  [6:0] in4; 
    input  [6:0] in3; 
    input  [6:0] in2; 
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux6p  mux_3 (.out(out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux6p  mux_4 (.out(out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux6p  mux_5 (.out(out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux6p  mux_6 (.out(out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));

endmodule 


module mux7_7 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in6; 
    input  [6:0] in5; 
    input  [6:0] in4; 
    input  [6:0] in3; 
    input  [6:0] in2; 
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));
    mux7p  mux_3 (.out(out[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel));
    mux7p  mux_4 (.out(out[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel));
    mux7p  mux_5 (.out(out[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel));
    mux7p  mux_6 (.out(out[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel));

endmodule 


module mux8_7 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [6:0] out;
    input  [6:0] in7; 
    input  [6:0] in6; 
    input  [6:0] in5; 
    input  [6:0] in4; 
    input  [6:0] in3; 
    input  [6:0] in2; 
    input  [6:0] in1; 
    input  [6:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux8p  mux_4 (.out(out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux8p  mux_5 (.out(out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux8p  mux_6 (.out(out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));

endmodule 


module mux2_8 (out, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));

endmodule 


module mux3_8 (out, in2, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux3p  mux_5 (.out(out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux3p  mux_6 (.out(out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux3p  mux_7 (.out(out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));

endmodule 


module mux4_8 (out, in3, in2, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux4p  mux_5 (.out(out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux4p  mux_6 (.out(out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux4p  mux_7 (.out(out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));

endmodule 


module mux5_8 (out, in4, in3, in2, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [4:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));
    mux5p  mux_3 (.out(out[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[4:0]));
    mux5p  mux_4 (.out(out[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl[4:0]));
    mux5p  mux_5 (.out(out[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl[4:0]));
    mux5p  mux_6 (.out(out[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl[4:0]));
    mux5p  mux_7 (.out(out[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl[4:0]));

endmodule 


module mux6_8 (out, in5, in4, in3, in2, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [5:0] sel;
wire  [5:0] slb;
wire  [5:0] sl;
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux6p  mux_3 (.out(out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux6p  mux_4 (.out(out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux6p  mux_5 (.out(out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux6p  mux_6 (.out(out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux6p  mux_7 (.out(out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));

endmodule 


module mux7_8 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in6; 
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [6:0] sel;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));
    mux7p  mux_3 (.out(out[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel));
    mux7p  mux_4 (.out(out[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel));
    mux7p  mux_5 (.out(out[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel));
    mux7p  mux_6 (.out(out[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel));
    mux7p  mux_7 (.out(out[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel));

endmodule 


module mux8_8 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [7:0] out;
    input  [7:0] in7; 
    input  [7:0] in6; 
    input  [7:0] in5; 
    input  [7:0] in4; 
    input  [7:0] in3; 
    input  [7:0] in2; 
    input  [7:0] in1; 
    input  [7:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux8p  mux_4 (.out(out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux8p  mux_5 (.out(out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux8p  mux_6 (.out(out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux8p  mux_7 (.out(out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));

endmodule 


module mux2_16 (out, in1, in0, sel);
    output [15:0] out;
    input  [15:0] in1; 
    input  [15:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux2p  mux_8 (.out(out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux2p  mux_9 (.out(out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux2p  mux_10 (.out(out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux2p  mux_11 (.out(out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux2p  mux_12 (.out(out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux2p  mux_13 (.out(out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux2p  mux_14 (.out(out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux2p  mux_15 (.out(out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));

endmodule 

module mux2_24 (out, in1, in0, sel);
    output [23:0] out;
    input  [23:0] in1; 
    input  [23:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;
    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel));
    mux2p  mux_8 (.out(out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel));
    mux2p  mux_9 (.out(out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel));
    mux2p  mux_10 (.out(out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel));
    mux2p  mux_11 (.out(out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel));
    mux2p  mux_12 (.out(out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel));
    mux2p  mux_13 (.out(out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel));
    mux2p  mux_14 (.out(out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel));
    mux2p  mux_15 (.out(out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel));
    mux2p  mux_16 (.out(out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel));
    mux2p  mux_17 (.out(out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel));
    mux2p  mux_18 (.out(out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel));
    mux2p  mux_19 (.out(out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel));
    mux2p  mux_20 (.out(out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel));
    mux2p  mux_21 (.out(out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel));
    mux2p  mux_22 (.out(out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel));
    mux2p  mux_23 (.out(out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel));

endmodule 


module mux3_24 (out, in2, in1, in0, sel);
    output [23:0] out;
    input  [23:0] in2; 
    input  [23:0] in1; 
    input  [23:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;	
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux3p  mux_5 (.out(out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux3p  mux_6 (.out(out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux3p  mux_7 (.out(out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux3p  mux_8 (.out(out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux3p  mux_9 (.out(out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux3p  mux_10 (.out(out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux3p  mux_11 (.out(out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux3p  mux_12 (.out(out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux3p  mux_13 (.out(out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux3p  mux_14 (.out(out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux3p  mux_15 (.out(out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux3p  mux_16 (.out(out[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux3p  mux_17 (.out(out[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux3p  mux_18 (.out(out[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux3p  mux_19 (.out(out[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux3p  mux_20 (.out(out[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux3p  mux_21 (.out(out[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux3p  mux_22 (.out(out[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux3p  mux_23 (.out(out[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));

endmodule 


module mux4_24 (out, in3, in2, in1, in0, sel);
    output [23:0] out;
    input  [23:0] in3; 
    input  [23:0] in2; 
    input  [23:0] in1; 
    input  [23:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;	
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux4p  mux_5 (.out(out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux4p  mux_6 (.out(out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux4p  mux_7 (.out(out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux4p  mux_8 (.out(out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux4p  mux_9 (.out(out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux4p  mux_10 (.out(out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux4p  mux_11 (.out(out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux4p  mux_12 (.out(out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux4p  mux_13 (.out(out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux4p  mux_14 (.out(out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux4p  mux_15 (.out(out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux4p  mux_16 (.out(out[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux4p  mux_17 (.out(out[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux4p  mux_18 (.out(out[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux4p  mux_19 (.out(out[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux4p  mux_20 (.out(out[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux4p  mux_21 (.out(out[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux4p  mux_22 (.out(out[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux4p  mux_23 (.out(out[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));

endmodule 


module mux8_24 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [23:0] out;
    input  [23:0] in7; 
    input  [23:0] in6; 
    input  [23:0] in5; 
    input  [23:0] in4; 
    input  [23:0] in3; 
    input  [23:0] in2; 
    input  [23:0] in1; 
    input  [23:0] in0; 
    input  [7:0] sel;
wire  [7:0] slb;
wire  [7:0] sl;	
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux8p  mux_4 (.out(out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux8p  mux_5 (.out(out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux8p  mux_6 (.out(out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux8p  mux_7 (.out(out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux8p  mux_8 (.out(out[8]), .in7(in7[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux8p  mux_9 (.out(out[9]), .in7(in7[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux8p  mux_10 (.out(out[10]), .in7(in7[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux8p  mux_11 (.out(out[11]), .in7(in7[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux8p  mux_12 (.out(out[12]), .in7(in7[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux8p  mux_13 (.out(out[13]), .in7(in7[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux8p  mux_14 (.out(out[14]), .in7(in7[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux8p  mux_15 (.out(out[15]), .in7(in7[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux8p  mux_16 (.out(out[16]), .in7(in7[16]), .in6(in6[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux8p  mux_17 (.out(out[17]), .in7(in7[17]), .in6(in6[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux8p  mux_18 (.out(out[18]), .in7(in7[18]), .in6(in6[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux8p  mux_19 (.out(out[19]), .in7(in7[19]), .in6(in6[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux8p  mux_20 (.out(out[20]), .in7(in7[20]), .in6(in6[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux8p  mux_21 (.out(out[21]), .in7(in7[21]), .in6(in6[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux8p  mux_22 (.out(out[22]), .in7(in7[22]), .in6(in6[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux8p  mux_23 (.out(out[23]), .in7(in7[23]), .in6(in6[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));

endmodule 

module mux2_29 (out, in1, in0, sel);
    output [28:0] out;
    input  [28:0] in1; 
    input  [28:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux2p  mux_8 (.out(out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux2p  mux_9 (.out(out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux2p  mux_10 (.out(out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux2p  mux_11 (.out(out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux2p  mux_12 (.out(out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux2p  mux_13 (.out(out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux2p  mux_14 (.out(out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux2p  mux_15 (.out(out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux2p  mux_16 (.out(out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux2p  mux_17 (.out(out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux2p  mux_18 (.out(out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux2p  mux_19 (.out(out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux2p  mux_20 (.out(out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux2p  mux_21 (.out(out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux2p  mux_22 (.out(out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux2p  mux_23 (.out(out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux2p  mux_24 (.out(out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux2p  mux_25 (.out(out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux2p  mux_26 (.out(out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux2p  mux_27 (.out(out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux2p  mux_28 (.out(out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));

endmodule 


module mux2_30 (out, in1, in0, sel);
    output [29:0] out;
    input  [29:0] in1; 
    input  [29:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux2p  mux_8 (.out(out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux2p  mux_9 (.out(out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux2p  mux_10 (.out(out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux2p  mux_11 (.out(out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux2p  mux_12 (.out(out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux2p  mux_13 (.out(out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux2p  mux_14 (.out(out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux2p  mux_15 (.out(out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux2p  mux_16 (.out(out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux2p  mux_17 (.out(out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux2p  mux_18 (.out(out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux2p  mux_19 (.out(out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux2p  mux_20 (.out(out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux2p  mux_21 (.out(out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux2p  mux_22 (.out(out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux2p  mux_23 (.out(out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux2p  mux_24 (.out(out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux2p  mux_25 (.out(out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux2p  mux_26 (.out(out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux2p  mux_27 (.out(out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux2p  mux_28 (.out(out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux2p  mux_29 (.out(out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));

endmodule 


module mux3_30 (out, in2, in1, in0, sel);
    output [29:0] out;
    input  [29:0] in2; 
    input  [29:0] in1; 
    input  [29:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;	
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux3p  mux_5 (.out(out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux3p  mux_6 (.out(out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux3p  mux_7 (.out(out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux3p  mux_8 (.out(out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux3p  mux_9 (.out(out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux3p  mux_10 (.out(out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux3p  mux_11 (.out(out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux3p  mux_12 (.out(out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux3p  mux_13 (.out(out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux3p  mux_14 (.out(out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux3p  mux_15 (.out(out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux3p  mux_16 (.out(out[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux3p  mux_17 (.out(out[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux3p  mux_18 (.out(out[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux3p  mux_19 (.out(out[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux3p  mux_20 (.out(out[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux3p  mux_21 (.out(out[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux3p  mux_22 (.out(out[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux3p  mux_23 (.out(out[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux3p  mux_24 (.out(out[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux3p  mux_25 (.out(out[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux3p  mux_26 (.out(out[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux3p  mux_27 (.out(out[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux3p  mux_28 (.out(out[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux3p  mux_29 (.out(out[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));

endmodule 


module mux4_30 (out, in3, in2, in1, in0, sel);
    output [29:0] out;
    input  [29:0] in3; 
    input  [29:0] in2; 
    input  [29:0] in1; 
    input  [29:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;	
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux4p  mux_5 (.out(out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux4p  mux_6 (.out(out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux4p  mux_7 (.out(out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux4p  mux_8 (.out(out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux4p  mux_9 (.out(out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux4p  mux_10 (.out(out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux4p  mux_11 (.out(out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux4p  mux_12 (.out(out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux4p  mux_13 (.out(out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux4p  mux_14 (.out(out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux4p  mux_15 (.out(out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux4p  mux_16 (.out(out[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux4p  mux_17 (.out(out[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux4p  mux_18 (.out(out[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux4p  mux_19 (.out(out[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux4p  mux_20 (.out(out[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux4p  mux_21 (.out(out[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux4p  mux_22 (.out(out[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux4p  mux_23 (.out(out[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux4p  mux_24 (.out(out[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux4p  mux_25 (.out(out[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux4p  mux_26 (.out(out[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux4p  mux_27 (.out(out[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux4p  mux_28 (.out(out[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux4p  mux_29 (.out(out[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));

endmodule 

module mux2_32 (out, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;
    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux2p  mux_8 (.out(out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux2p  mux_9 (.out(out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux2p  mux_10 (.out(out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux2p  mux_11 (.out(out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux2p  mux_12 (.out(out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux2p  mux_13 (.out(out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux2p  mux_14 (.out(out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux2p  mux_15 (.out(out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux2p  mux_16 (.out(out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux2p  mux_17 (.out(out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux2p  mux_18 (.out(out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux2p  mux_19 (.out(out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux2p  mux_20 (.out(out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux2p  mux_21 (.out(out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux2p  mux_22 (.out(out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux2p  mux_23 (.out(out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux2p  mux_24 (.out(out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux2p  mux_25 (.out(out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux2p  mux_26 (.out(out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux2p  mux_27 (.out(out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux2p  mux_28 (.out(out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux2p  mux_29 (.out(out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));
    mux2p  mux_30 (.out(out[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl));
    mux2p  mux_31 (.out(out[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl));

endmodule 


module mux3_32 (out, in2, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [2:0] sel;
wire  [2:0] slb;
wire  [2:0] sl;	
mj_p_muxpri3 mj_p_muxpri3_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux3p  mux_0 (.out(out[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux3p  mux_1 (.out(out[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux3p  mux_2 (.out(out[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux3p  mux_3 (.out(out[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux3p  mux_4 (.out(out[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux3p  mux_5 (.out(out[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux3p  mux_6 (.out(out[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux3p  mux_7 (.out(out[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux3p  mux_8 (.out(out[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux3p  mux_9 (.out(out[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux3p  mux_10 (.out(out[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux3p  mux_11 (.out(out[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux3p  mux_12 (.out(out[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux3p  mux_13 (.out(out[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux3p  mux_14 (.out(out[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux3p  mux_15 (.out(out[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux3p  mux_16 (.out(out[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux3p  mux_17 (.out(out[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux3p  mux_18 (.out(out[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux3p  mux_19 (.out(out[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux3p  mux_20 (.out(out[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux3p  mux_21 (.out(out[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux3p  mux_22 (.out(out[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux3p  mux_23 (.out(out[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux3p  mux_24 (.out(out[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux3p  mux_25 (.out(out[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux3p  mux_26 (.out(out[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux3p  mux_27 (.out(out[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux3p  mux_28 (.out(out[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux3p  mux_29 (.out(out[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));
    mux3p  mux_30 (.out(out[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl));
    mux3p  mux_31 (.out(out[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl));

endmodule 


module mux4_32 (out, in3, in2, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [3:0] sel;
wire  [3:0] slb;
wire  [3:0] sl;	
mj_p_muxpri4 mj_p_muxpri4_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux4p  mux_0 (.out(out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux4p  mux_1 (.out(out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux4p  mux_2 (.out(out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux4p  mux_3 (.out(out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux4p  mux_4 (.out(out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux4p  mux_5 (.out(out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux4p  mux_6 (.out(out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux4p  mux_7 (.out(out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux4p  mux_8 (.out(out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux4p  mux_9 (.out(out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux4p  mux_10 (.out(out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux4p  mux_11 (.out(out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux4p  mux_12 (.out(out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux4p  mux_13 (.out(out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux4p  mux_14 (.out(out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux4p  mux_15 (.out(out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux4p  mux_16 (.out(out[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux4p  mux_17 (.out(out[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux4p  mux_18 (.out(out[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux4p  mux_19 (.out(out[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux4p  mux_20 (.out(out[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux4p  mux_21 (.out(out[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux4p  mux_22 (.out(out[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux4p  mux_23 (.out(out[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux4p  mux_24 (.out(out[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux4p  mux_25 (.out(out[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux4p  mux_26 (.out(out[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux4p  mux_27 (.out(out[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux4p  mux_28 (.out(out[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux4p  mux_29 (.out(out[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));
    mux4p  mux_30 (.out(out[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl));
    mux4p  mux_31 (.out(out[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl));

endmodule 


module mux5_32 (out, in4, in3, in2, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [4:0] sel;

wire  [5:0] slb;
wire  [5:0] sl;	
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;


    mux5p  mux_0 (.out(out[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[4:0]));
    mux5p  mux_1 (.out(out[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[4:0]));
    mux5p  mux_2 (.out(out[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[4:0]));
    mux5p  mux_3 (.out(out[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[4:0]));
    mux5p  mux_4 (.out(out[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl[4:0]));
    mux5p  mux_5 (.out(out[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl[4:0]));
    mux5p  mux_6 (.out(out[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl[4:0]));
    mux5p  mux_7 (.out(out[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl[4:0]));
    mux5p  mux_8 (.out(out[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl[4:0]));
    mux5p  mux_9 (.out(out[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl[4:0]));
    mux5p  mux_10 (.out(out[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl[4:0]));
    mux5p  mux_11 (.out(out[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl[4:0]));
    mux5p  mux_12 (.out(out[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl[4:0]));
    mux5p  mux_13 (.out(out[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl[4:0]));
    mux5p  mux_14 (.out(out[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl[4:0]));
    mux5p  mux_15 (.out(out[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl[4:0]));
    mux5p  mux_16 (.out(out[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl[4:0]));
    mux5p  mux_17 (.out(out[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl[4:0]));
    mux5p  mux_18 (.out(out[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl[4:0]));
    mux5p  mux_19 (.out(out[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl[4:0]));
    mux5p  mux_20 (.out(out[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl[4:0]));
    mux5p  mux_21 (.out(out[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl[4:0]));
    mux5p  mux_22 (.out(out[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl[4:0]));
    mux5p  mux_23 (.out(out[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl[4:0]));
    mux5p  mux_24 (.out(out[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl[4:0]));
    mux5p  mux_25 (.out(out[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl[4:0]));
    mux5p  mux_26 (.out(out[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl[4:0]));
    mux5p  mux_27 (.out(out[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl[4:0]));
    mux5p  mux_28 (.out(out[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl[4:0]));
    mux5p  mux_29 (.out(out[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl[4:0]));
    mux5p  mux_30 (.out(out[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl[4:0]));
    mux5p  mux_31 (.out(out[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl[4:0]));

endmodule 


module mux6_32 (out, in5, in4, in3, in2, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [5:0] sel;

wire  [5:0] slb;
wire  [5:0] sl;	
mj_p_muxpri6 mj_p_muxpri6_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;


    mux6p  mux_0 (.out(out[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux6p  mux_1 (.out(out[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux6p  mux_2 (.out(out[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux6p  mux_3 (.out(out[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux6p  mux_4 (.out(out[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux6p  mux_5 (.out(out[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux6p  mux_6 (.out(out[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux6p  mux_7 (.out(out[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux6p  mux_8 (.out(out[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux6p  mux_9 (.out(out[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux6p  mux_10 (.out(out[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux6p  mux_11 (.out(out[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux6p  mux_12 (.out(out[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux6p  mux_13 (.out(out[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux6p  mux_14 (.out(out[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux6p  mux_15 (.out(out[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux6p  mux_16 (.out(out[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux6p  mux_17 (.out(out[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux6p  mux_18 (.out(out[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux6p  mux_19 (.out(out[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux6p  mux_20 (.out(out[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux6p  mux_21 (.out(out[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux6p  mux_22 (.out(out[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux6p  mux_23 (.out(out[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux6p  mux_24 (.out(out[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux6p  mux_25 (.out(out[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux6p  mux_26 (.out(out[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux6p  mux_27 (.out(out[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux6p  mux_28 (.out(out[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux6p  mux_29 (.out(out[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));
    mux6p  mux_30 (.out(out[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl));
    mux6p  mux_31 (.out(out[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl));

endmodule 


module mux7_32 (out, in6, in5, in4, in3, in2, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in6; 
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [6:0] sel;

wire  [7:0] slb;
wire  [7:0] sl;	
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl({1'b0,sel}),.slb(slb));
assign sl = ~slb;

    mux7p  mux_0 (.out(out[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl[6:0]));
    mux7p  mux_1 (.out(out[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl[6:0]));
    mux7p  mux_2 (.out(out[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl[6:0]));
    mux7p  mux_3 (.out(out[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl[6:0]));
    mux7p  mux_4 (.out(out[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl[6:0]));
    mux7p  mux_5 (.out(out[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl[6:0]));
    mux7p  mux_6 (.out(out[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl[6:0]));
    mux7p  mux_7 (.out(out[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl[6:0]));
    mux7p  mux_8 (.out(out[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl[6:0]));
    mux7p  mux_9 (.out(out[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl[6:0]));
    mux7p  mux_10 (.out(out[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl[6:0]));
    mux7p  mux_11 (.out(out[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl[6:0]));
    mux7p  mux_12 (.out(out[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl[6:0]));
    mux7p  mux_13 (.out(out[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl[6:0]));
    mux7p  mux_14 (.out(out[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl[6:0]));
    mux7p  mux_15 (.out(out[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl[6:0]));
    mux7p  mux_16 (.out(out[16]), .in6(in6[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl[6:0]));
    mux7p  mux_17 (.out(out[17]), .in6(in6[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl[6:0]));
    mux7p  mux_18 (.out(out[18]), .in6(in6[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl[6:0]));
    mux7p  mux_19 (.out(out[19]), .in6(in6[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl[6:0]));
    mux7p  mux_20 (.out(out[20]), .in6(in6[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl[6:0]));
    mux7p  mux_21 (.out(out[21]), .in6(in6[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl[6:0]));
    mux7p  mux_22 (.out(out[22]), .in6(in6[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl[6:0]));
    mux7p  mux_23 (.out(out[23]), .in6(in6[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl[6:0]));
    mux7p  mux_24 (.out(out[24]), .in6(in6[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl[6:0]));
    mux7p  mux_25 (.out(out[25]), .in6(in6[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl[6:0]));
    mux7p  mux_26 (.out(out[26]), .in6(in6[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl[6:0]));
    mux7p  mux_27 (.out(out[27]), .in6(in6[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl[6:0]));
    mux7p  mux_28 (.out(out[28]), .in6(in6[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl[6:0]));
    mux7p  mux_29 (.out(out[29]), .in6(in6[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl[6:0]));
    mux7p  mux_30 (.out(out[30]), .in6(in6[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl[6:0]));
    mux7p  mux_31 (.out(out[31]), .in6(in6[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl[6:0]));

endmodule 


module mux8_32 (out, in7, in6, in5, in4, in3, in2, in1, in0, sel);
    output [31:0] out;
    input  [31:0] in7; 
    input  [31:0] in6; 
    input  [31:0] in5; 
    input  [31:0] in4; 
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [7:0] sel;
    
wire  [7:0] slb;
wire  [7:0] sl;	
mj_p_muxpri8 mj_p_muxpri8_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux8p  mux_0 (.out(out[0]), .in7(in7[0]), .in6(in6[0]), .in5(in5[0]), .in4(in4[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux8p  mux_1 (.out(out[1]), .in7(in7[1]), .in6(in6[1]), .in5(in5[1]), .in4(in4[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux8p  mux_2 (.out(out[2]), .in7(in7[2]), .in6(in6[2]), .in5(in5[2]), .in4(in4[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux8p  mux_3 (.out(out[3]), .in7(in7[3]), .in6(in6[3]), .in5(in5[3]), .in4(in4[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux8p  mux_4 (.out(out[4]), .in7(in7[4]), .in6(in6[4]), .in5(in5[4]), .in4(in4[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux8p  mux_5 (.out(out[5]), .in7(in7[5]), .in6(in6[5]), .in5(in5[5]), .in4(in4[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux8p  mux_6 (.out(out[6]), .in7(in7[6]), .in6(in6[6]), .in5(in5[6]), .in4(in4[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux8p  mux_7 (.out(out[7]), .in7(in7[7]), .in6(in6[7]), .in5(in5[7]), .in4(in4[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux8p  mux_8 (.out(out[8]), .in7(in7[8]), .in6(in6[8]), .in5(in5[8]), .in4(in4[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux8p  mux_9 (.out(out[9]), .in7(in7[9]), .in6(in6[9]), .in5(in5[9]), .in4(in4[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux8p  mux_10 (.out(out[10]), .in7(in7[10]), .in6(in6[10]), .in5(in5[10]), .in4(in4[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux8p  mux_11 (.out(out[11]), .in7(in7[11]), .in6(in6[11]), .in5(in5[11]), .in4(in4[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux8p  mux_12 (.out(out[12]), .in7(in7[12]), .in6(in6[12]), .in5(in5[12]), .in4(in4[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux8p  mux_13 (.out(out[13]), .in7(in7[13]), .in6(in6[13]), .in5(in5[13]), .in4(in4[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux8p  mux_14 (.out(out[14]), .in7(in7[14]), .in6(in6[14]), .in5(in5[14]), .in4(in4[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux8p  mux_15 (.out(out[15]), .in7(in7[15]), .in6(in6[15]), .in5(in5[15]), .in4(in4[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux8p  mux_16 (.out(out[16]), .in7(in7[16]), .in6(in6[16]), .in5(in5[16]), .in4(in4[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux8p  mux_17 (.out(out[17]), .in7(in7[17]), .in6(in6[17]), .in5(in5[17]), .in4(in4[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux8p  mux_18 (.out(out[18]), .in7(in7[18]), .in6(in6[18]), .in5(in5[18]), .in4(in4[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux8p  mux_19 (.out(out[19]), .in7(in7[19]), .in6(in6[19]), .in5(in5[19]), .in4(in4[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux8p  mux_20 (.out(out[20]), .in7(in7[20]), .in6(in6[20]), .in5(in5[20]), .in4(in4[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux8p  mux_21 (.out(out[21]), .in7(in7[21]), .in6(in6[21]), .in5(in5[21]), .in4(in4[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux8p  mux_22 (.out(out[22]), .in7(in7[22]), .in6(in6[22]), .in5(in5[22]), .in4(in4[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux8p  mux_23 (.out(out[23]), .in7(in7[23]), .in6(in6[23]), .in5(in5[23]), .in4(in4[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux8p  mux_24 (.out(out[24]), .in7(in7[24]), .in6(in6[24]), .in5(in5[24]), .in4(in4[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux8p  mux_25 (.out(out[25]), .in7(in7[25]), .in6(in6[25]), .in5(in5[25]), .in4(in4[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux8p  mux_26 (.out(out[26]), .in7(in7[26]), .in6(in6[26]), .in5(in5[26]), .in4(in4[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux8p  mux_27 (.out(out[27]), .in7(in7[27]), .in6(in6[27]), .in5(in5[27]), .in4(in4[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux8p  mux_28 (.out(out[28]), .in7(in7[28]), .in6(in6[28]), .in5(in5[28]), .in4(in4[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux8p  mux_29 (.out(out[29]), .in7(in7[29]), .in6(in6[29]), .in5(in5[29]), .in4(in4[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));
    mux8p  mux_30 (.out(out[30]), .in7(in7[30]), .in6(in6[30]), .in5(in5[30]), .in4(in4[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl));
    mux8p  mux_31 (.out(out[31]), .in7(in7[31]), .in6(in6[31]), .in5(in5[31]), .in4(in4[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl));

endmodule 


module mux2_40 (out, in1, in0, sel);
    output [39:0] out;
    input  [39:0] in1; 
    input  [39:0] in0; 
    input  [1:0] sel;
wire  [1:0] slb;
wire  [1:0] sl;
mj_p_muxpri2 mj_p_muxpri2_i1 (.sl(sel),.slb(slb));
assign sl = ~slb;

    mux2p  mux_0 (.out(out[0]), .in1(in1[0]), .in0(in0[0]), .sel(sl));
    mux2p  mux_1 (.out(out[1]), .in1(in1[1]), .in0(in0[1]), .sel(sl));
    mux2p  mux_2 (.out(out[2]), .in1(in1[2]), .in0(in0[2]), .sel(sl));
    mux2p  mux_3 (.out(out[3]), .in1(in1[3]), .in0(in0[3]), .sel(sl));
    mux2p  mux_4 (.out(out[4]), .in1(in1[4]), .in0(in0[4]), .sel(sl));
    mux2p  mux_5 (.out(out[5]), .in1(in1[5]), .in0(in0[5]), .sel(sl));
    mux2p  mux_6 (.out(out[6]), .in1(in1[6]), .in0(in0[6]), .sel(sl));
    mux2p  mux_7 (.out(out[7]), .in1(in1[7]), .in0(in0[7]), .sel(sl));
    mux2p  mux_8 (.out(out[8]), .in1(in1[8]), .in0(in0[8]), .sel(sl));
    mux2p  mux_9 (.out(out[9]), .in1(in1[9]), .in0(in0[9]), .sel(sl));
    mux2p  mux_10 (.out(out[10]), .in1(in1[10]), .in0(in0[10]), .sel(sl));
    mux2p  mux_11 (.out(out[11]), .in1(in1[11]), .in0(in0[11]), .sel(sl));
    mux2p  mux_12 (.out(out[12]), .in1(in1[12]), .in0(in0[12]), .sel(sl));
    mux2p  mux_13 (.out(out[13]), .in1(in1[13]), .in0(in0[13]), .sel(sl));
    mux2p  mux_14 (.out(out[14]), .in1(in1[14]), .in0(in0[14]), .sel(sl));
    mux2p  mux_15 (.out(out[15]), .in1(in1[15]), .in0(in0[15]), .sel(sl));
    mux2p  mux_16 (.out(out[16]), .in1(in1[16]), .in0(in0[16]), .sel(sl));
    mux2p  mux_17 (.out(out[17]), .in1(in1[17]), .in0(in0[17]), .sel(sl));
    mux2p  mux_18 (.out(out[18]), .in1(in1[18]), .in0(in0[18]), .sel(sl));
    mux2p  mux_19 (.out(out[19]), .in1(in1[19]), .in0(in0[19]), .sel(sl));
    mux2p  mux_20 (.out(out[20]), .in1(in1[20]), .in0(in0[20]), .sel(sl));
    mux2p  mux_21 (.out(out[21]), .in1(in1[21]), .in0(in0[21]), .sel(sl));
    mux2p  mux_22 (.out(out[22]), .in1(in1[22]), .in0(in0[22]), .sel(sl));
    mux2p  mux_23 (.out(out[23]), .in1(in1[23]), .in0(in0[23]), .sel(sl));
    mux2p  mux_24 (.out(out[24]), .in1(in1[24]), .in0(in0[24]), .sel(sl));
    mux2p  mux_25 (.out(out[25]), .in1(in1[25]), .in0(in0[25]), .sel(sl));
    mux2p  mux_26 (.out(out[26]), .in1(in1[26]), .in0(in0[26]), .sel(sl));
    mux2p  mux_27 (.out(out[27]), .in1(in1[27]), .in0(in0[27]), .sel(sl));
    mux2p  mux_28 (.out(out[28]), .in1(in1[28]), .in0(in0[28]), .sel(sl));
    mux2p  mux_29 (.out(out[29]), .in1(in1[29]), .in0(in0[29]), .sel(sl));
    mux2p  mux_30 (.out(out[30]), .in1(in1[30]), .in0(in0[30]), .sel(sl));
    mux2p  mux_31 (.out(out[31]), .in1(in1[31]), .in0(in0[31]), .sel(sl));
    mux2p  mux_32 (.out(out[32]), .in1(in1[32]), .in0(in0[32]), .sel(sl));
    mux2p  mux_33 (.out(out[33]), .in1(in1[33]), .in0(in0[33]), .sel(sl));
    mux2p  mux_34 (.out(out[34]), .in1(in1[34]), .in0(in0[34]), .sel(sl));
    mux2p  mux_35 (.out(out[35]), .in1(in1[35]), .in0(in0[35]), .sel(sl));
    mux2p  mux_36 (.out(out[36]), .in1(in1[36]), .in0(in0[36]), .sel(sl));
    mux2p  mux_37 (.out(out[37]), .in1(in1[37]), .in0(in0[37]), .sel(sl));
    mux2p  mux_38 (.out(out[38]), .in1(in1[38]), .in0(in0[38]), .sel(sl));
    mux2p  mux_39 (.out(out[39]), .in1(in1[39]), .in0(in0[39]), .sel(sl));

endmodule 



module mj_p_muxdec8_8 (decb, dec, sel);

input [2:0] sel;
output [7:0] dec;
output [7:0] decb;

 reg    [7:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    out = 8'h1;
      3'b001:    out = 8'h2;
      3'b010:    out = 8'h4;
      3'b011:    out = 8'h8;
      3'b100:    out = 8'h10;
      3'b101:    out = 8'h20;
      3'b110:    out = 8'h40;
      3'b111:    out = 8'h80;
      default: out = 8'hx;
   endcase
 end
assign dec = out;
assign decb = ~out;

endmodule

module mj_p_muxdec8_32 (decb, dec, sel);

input [2:0] sel;
output [7:0] dec;
output [7:0] decb;

reg    [7:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    out = 8'h1;
      3'b001:    out = 8'h2;
      3'b010:    out = 8'h4;
      3'b011:    out = 8'h8;
      3'b100:    out = 8'h10;
      3'b101:    out = 8'h20;
      3'b110:    out = 8'h40;
      3'b111:    out = 8'h80;
      default: out = 8'hx;
   endcase
 end
assign dec = out;
assign decb = ~out;


endmodule
module mj_p_muxdec8_16 (decb, dec, sel);

input [2:0] sel;
output [7:0] dec;
output [7:0] decb;

reg    [7:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    out = 8'h1;
      3'b001:    out = 8'h2;
      3'b010:    out = 8'h4;
      3'b011:    out = 8'h8;
      3'b100:    out = 8'h10;
      3'b101:    out = 8'h20;
      3'b110:    out = 8'h40;
      3'b111:    out = 8'h80;
      default: out = 8'hx;
   endcase
 end
assign dec = out;
assign decb = ~out;


endmodule
module mj_p_muxdec8 (decb, dec, sel);

input [2:0] sel;
output [7:0] decb, dec;

reg    [7:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      3'b000:    out = 8'h1;
      3'b001:    out = 8'h2;
      3'b010:    out = 8'h4;
      3'b011:    out = 8'h8;
      3'b100:    out = 8'h10;
      3'b101:    out = 8'h20;
      3'b110:    out = 8'h40;
      3'b111:    out = 8'h80;
      default: out = 8'hx;
   endcase
 end
assign dec = out;
assign decb = ~out;


endmodule
module mj_p_muxdec6_8 (decb, dec, sel);

input [2:0] sel;
output [5:0] dec;
output [5:0] decb;

 reg    [5:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    out = 6'b000001;
      3'b001:    out = 6'b000010;   
      3'b010:    out = 6'b000100;
      3'b011:    out = 6'b001000;    
      3'b100:    out = 6'b010000;   
      3'b101:    out = 6'b100000;   
      3'b110:    out = 6'b010000;
        default: out = 6'b100000;
   endcase
 end
assign decb = ~out;
assign dec = out;
endmodule


module mj_p_muxdec6_32 (decb, dec, sel);

input [2:0] sel;
output [5:0] dec;
output [5:0] decb;

 reg    [5:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    out = 6'b000001;
      3'b001:    out = 6'b000010;   
      3'b010:    out = 6'b000100;
      3'b011:    out = 6'b001000;    
      3'b100:    out = 6'b010000;   
      3'b101:    out = 6'b100000;   
      3'b110:    out = 6'b010000;
        default: out = 6'b100000;
   endcase
 end
assign decb = ~out;
assign dec = out;


endmodule
module mj_p_muxdec6_16 (decb, dec, sel);

input [2:0] sel;
output [5:0] dec;
output [5:0] decb;

 reg    [5:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    out = 6'b000001;
      3'b001:    out = 6'b000010;   
      3'b010:    out = 6'b000100;
      3'b011:    out = 6'b001000;    
      3'b100:    out = 6'b010000;   
      3'b101:    out = 6'b100000;   
      3'b110:    out = 6'b010000;
        default: out = 6'b100000;
   endcase
 end
assign decb = ~out;
assign dec = out;



endmodule
module mj_p_muxdec6 (decb, dec, sel);

input [2:0] sel;
output [5:0] decb, dec;

 reg    [5:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      3'b000:    out = 6'b000001;
      3'b001:    out = 6'b000010;   
      3'b010:    out = 6'b000100;
      3'b011:    out = 6'b001000;    
      3'b100:    out = 6'b010000;   
      3'b101:    out = 6'b100000;   
      3'b110:    out = 6'b010000;
        default: out = 6'b100000;
   endcase
 end
assign decb = ~out;
assign dec = out;


endmodule
module mj_p_muxdec4_8 (decb, dec, sel);

input [1:0] sel;
output [3:0] dec;
output [3:0] decb;

 reg    [3:0]  out; 

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    out = 4'h1;
      2'b01:    out = 4'h2;
      2'b10:    out = 4'h4;
      2'b11:    out = 4'h8;
      default: out = 4'hx;
   endcase
 end
assign decb = ~out;
assign dec  = out;


endmodule
module mj_p_muxdec4_32 (decb, dec, sel);

input [1:0] sel;
output [3:0] dec;
output [3:0] decb;

 reg    [3:0]  out; 

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    out = 4'h1;
      2'b01:    out = 4'h2;
      2'b10:    out = 4'h4;
      2'b11:    out = 4'h8;
      default: out = 4'hx;
   endcase
 end
assign decb = ~out;
assign dec  = out;


endmodule
module mj_p_muxdec4_16 (decb, dec, sel);

input [1:0] sel;
output [3:0] dec;
output [3:0] decb;

 reg    [3:0]  out; 

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    out = 4'h1;
      2'b01:    out = 4'h2;
      2'b10:    out = 4'h4;
      2'b11:    out = 4'h8;
      default: out = 4'hx;
   endcase
 end
assign decb = ~out;
assign dec  = out;


endmodule
module mj_p_muxdec4 (decb, dec, sel);

input [1:0] sel;
output [3:0] decb, dec;

 reg    [3:0]  out; 

 always @(sel)  begin
   case(sel)      // synopsys full_case parallel_case
      2'b00:    out = 4'h1;
      2'b01:    out = 4'h2;
      2'b10:    out = 4'h4;
      2'b11:    out = 4'h8;
      default: out = 4'hx;
   endcase
 end
assign decb = ~out;
assign dec  = out;


endmodule
module mj_p_muxdec3_8 (decb, dec, sel);

input [1:0] sel;
output [2:0] dec;
output [2:0] decb;

reg    [2:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    out = 3'b001;
      2'b01:    out = 3'b010;
      2'b10:    out = 3'b100;
      default:  out = 3'b100;
   endcase
 end
assign decb = ~out;
assign dec = out;


endmodule
module mj_p_muxdec3_32 (decb, dec, sel);

input [1:0] sel;
output [2:0] dec;
output [2:0] decb;

reg    [2:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    out = 3'b001;
      2'b01:    out = 3'b010;
      2'b10:    out = 3'b100;
      default:  out = 3'b100;
   endcase
 end
assign decb = ~out;
assign dec = out;


endmodule
module mj_p_muxdec3_16 (decb, dec, sel);

input [1:0] sel;
output [2:0] dec;
output [2:0] decb;

reg    [2:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    out = 3'b001;
      2'b01:    out = 3'b010;
      2'b10:    out = 3'b100;
      default:  out = 3'b100;
   endcase
 end
assign decb = ~out;
assign dec = out;

endmodule
module mj_p_muxdec3 (decb, dec, sel);

input [1:0] sel;
output [2:0] decb, dec;

reg    [2:0]  out;

 always @(sel)  begin
   case(sel)      // synopsys parallel_case
      2'b00:    out = 3'b001;
      2'b01:    out = 3'b010;
      2'b10:    out = 3'b100;
      default:  out = 3'b100;
   endcase
 end
assign decb = ~out;
assign dec = out;


endmodule

module mj_s_mux11_d_32 (mx_out,sel,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10);
output [31:0] mx_out;
input   [3:0] sel;
input  [31:0] in10;
input  [31:0] in9;
input  [31:0] in8;
input  [31:0] in7;
input  [31:0] in6;
input  [31:0] in5;
input  [31:0] in4;
input  [31:0] in3;
input  [31:0] in2;
input  [31:0] in1;
input  [31:0] in0;
//wire   [11:0] sl;
wire   [11:0] slb;
wire   [31:0] in10_7;
 
reg    [11:0] sl;
 
always @(sel)  begin
   case (sel)      // synopsys full_case parallel_case
      4'b0000:    sl = 12'h1;
      4'b0001:    sl = 12'h2;
      4'b0010:    sl = 12'h4;
      4'b0011:    sl = 12'h8;
      4'b0100:    sl = 12'h10;
      4'b0101:    sl = 12'h20;
      4'b0110:    sl = 12'h40;
      4'b0111:    sl = 12'h180;
      4'b1000:    sl = 12'h280;
      4'b1001:    sl = 12'h480;
      4'b1010:    sl = 12'h880;
      default:    sl = 12'h880;
   endcase
end
 
assign slb = ~sl;
 
mj_p_mux8_32  mj_p_mux8_32_0 (  .mx_out(mx_out),
                                .in7(in10_7),
                                .in6(in6),
                                .in5(in5),
                                .in4(in4),
                                .in3(in3),
                                .in2(in2),
                                .in1(in1),
                                .in0(in0),
                                .sel(sl[7:0]),
                                .sel_l(slb[7:0])
                                );
 
mj_p_mux4_32  mj_p_mux4_32_0 (  .mx_out(in10_7),
                                .in3(in10),
                                .in2(in9),
                                .in1(in8),
                                .in0(in7),
                                .sel(sl[11:8]),
                                .sel_l(slb[11:8])
                                );
 
endmodule
 
module mj_s_mux15_d_32 (mx_out,sel,in0,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,
in11,in12,in13,in14);
output [31:0] mx_out;
input   [3:0] sel;
input  [31:0] in14;
input  [31:0] in13;
input  [31:0] in12;
input  [31:0] in11;
input  [31:0] in10;
input  [31:0] in9;
input  [31:0] in8;
input  [31:0] in7;
input  [31:0] in6;
input  [31:0] in5;
input  [31:0] in4;
input  [31:0] in3;
input  [31:0] in2;
input  [31:0] in1;
input  [31:0] in0;
//wire   [15:0] sl;
wire   [15:0] slb;
wire   [31:0] in14_7;
 
reg    [15:0] sl;
 
always @(sel)  begin
   case (sel)      // synopsys full_case parallel_case
      4'b0000:    sl = 16'h1;
      4'b0001:    sl = 16'h2;
      4'b0010:    sl = 16'h4;
      4'b0011:    sl = 16'h8;
      4'b0100:    sl = 16'h10;
      4'b0101:    sl = 16'h20;
      4'b0110:    sl = 16'h40;
      4'b0111:    sl = 16'h180;
      4'b1000:    sl = 16'h280;
      4'b1001:    sl = 16'h480;
      4'b1010:    sl = 16'h880;
      4'b1011:    sl = 16'h1080;
      4'b1100:    sl = 16'h2080;
      4'b1101:    sl = 16'h4080;
      4'b1111:    sl = 16'h8080;
      default:    sl = 16'h8080;
   endcase
end
 
assign slb = ~sl;
 
mj_p_mux8_32  mj_p_mux8_32_up ( .mx_out(mx_out),
                                .in7(in14_7),
                                .in6(in6),
                                .in5(in5),
                                .in4(in4),
                                .in3(in3),
                                .in2(in2),
                                .in1(in1),
                                .in0(in0),
                                .sel(sl[7:0]),
                                .sel_l(slb[7:0])
                                );
 
mj_p_mux8_32  mj_p_mux8_32_lo ( .mx_out(in14_7),
                                .in7(in14),
                                .in6(in13),
                                .in5(in12),
                                .in4(in11),
                                .in3(in10),
                                .in2(in9),
                                .in1(in8),
                                .in0(in7),
                                .sel(sl[15:8]),
                                .sel_l(slb[15:8])
                                );
 
endmodule

module mx2_32 (inp1, inp0, sel, out);
 
input  [31:0]  inp1;
input  [31:0]  inp0;
input          sel;
output [31:0]  out;
 
wire   [31:0]  out;

  assign out = (sel ? inp1 : inp0);

endmodule

module mx2_33 (inp1, inp0, sel, out);
 
input  [32:0]  inp1;
input  [32:0]  inp0;
input          sel;
output [32:0]  out;
 
wire   [32:0]  out;
 
  assign out = (sel ? inp1 : inp0);

endmodule

module mx2i_32 (inp1, inp0, sel, out_);
 
input  [31:0]  inp1;
input  [31:0]  inp0;
input          sel;
output [31:0]  out_;
 
wire   [31:0]  out_;
 
  assign out_ = ~(sel ? inp1 : inp0);

endmodule

module mx2i_b_32 (inp1, inp0, sel, out_);
 
input  [31:0]  inp1;
input  [31:0]  inp0;
input          sel;
output [31:0]  out_;
 
wire   [31:0]  out_;
 
  assign out_ = ~(sel ? inp1 : inp0);

endmodule

module mx2i_33 (inp1, inp0, sel, out_);
 
input  [32:0]  inp1;
input  [32:0]  inp0;
input          sel;
output [32:0]  out_;
 
wire   [32:0]  out_;
 
  assign out_ = ~(sel ? inp1 : inp0);

endmodule

module mx2i_b_33 (inp1, inp0, sel, out_);
 
input  [32:0]  inp1;
input  [32:0]  inp0;
input          sel;
output [32:0]  out_;
 
wire   [32:0]  out_;
 
  assign out_ = ~(sel ? inp1 : inp0);

endmodule

module mx4_1 (inp, sel, out);
 
input   [3:0]  inp;
input   [1:0]  sel;
output         out;
 
reg            out;
 
  always @(inp or sel)
    case (sel)
      2'b00: out = inp[0];
      2'b01: out = inp[1];
      2'b10: out = inp[2];
      2'b11: out = inp[3];
    endcase

endmodule

module mx16_1 (i15, i14, i13, i12,
               i11, i10, i9,  i8,
               i7,  i6,  i5,  i4,
               i3,  i2,  i1,  i0,
               sel, out);
 
input          i15, i14, i13, i12;
input          i11, i10, i9,  i8;
input          i7,  i6,  i5,  i4;
input          i3,  i2,  i1,  i0;
input   [3:0]  sel;
output         out;
 
wire           o_0, o_1, o_2, o_3;
 
  mx4_1 mx4_1_3 (.inp({i15,i14,i13,i12}), .sel(sel[1:0]), .out(o_3));
  mx4_1 mx4_1_2 (.inp({i11,i10,i9, i8}),  .sel(sel[1:0]), .out(o_2));
  mx4_1 mx4_1_1 (.inp({i7, i6, i5, i4}),  .sel(sel[1:0]), .out(o_1));
  mx4_1 mx4_1_0 (.inp({i3, i2, i1, i0}),  .sel(sel[1:0]), .out(o_0));
 
  mx4_1 mx4_1_4 (.inp({o_3,o_2,o_1,o_0}), .sel(sel[3:2]), .out(out));
 
endmodule

module mx16_2 (i15, i14, i13, i12,
               i11, i10, i9,  i8,
               i7,  i6,  i5,  i4,
               i3,  i2,  i1,  i0,
               sel, out);
 
input   [1:0]  i15, i14, i13, i12;
input   [1:0]  i11, i10, i9,  i8;
input   [1:0]  i7,  i6,  i5,  i4;
input   [1:0]  i3,  i2,  i1,  i0;
input   [3:0]  sel;
output  [1:0]  out;
 
  mx16_1 mx16_1_1 (
                   .i15(i15[1]), .i14(i14[1]), .i13(i13[1]), .i12(i12[1]),
                   .i11(i11[1]), .i10(i10[1]), .i9(i9[1]),   .i8(i8[1]),
                   .i7(i7[1]),   .i6(i6[1]),   .i5(i5[1]),   .i4(i4[1]),
                   .i3(i3[1]),   .i2(i2[1]),   .i1(i1[1]),   .i0(i0[1]),
                   .sel(sel),    .out(out[1]));

  mx16_1 mx16_1_0 (
                   .i15(i15[0]), .i14(i14[0]), .i13(i13[0]), .i12(i12[0]),
                   .i11(i11[0]), .i10(i10[0]), .i9(i9[0]),   .i8(i8[0]),
                   .i7(i7[0]),   .i6(i6[0]),   .i5(i5[0]),   .i4(i4[0]),
                   .i3(i3[0]),   .i2(i2[0]),   .i1(i1[0]),   .i0(i0[0]),
                   .sel(sel),    .out(out[0]));
 
endmodule 

module mx4_32 (inp0, inp1, inp2, inp3, sel, out);
 
input  [31:0]  inp0;
input  [31:0]  inp1;
input  [31:0]  inp2;
input  [31:0]  inp3;
input   [1:0]  sel;
output [31:0]  out;
 
reg    [31:0]  out;
 
  always @(inp0 or inp1 or inp2 or inp3 or sel)
    case (sel)
      2'b00: out = inp0;
      2'b01: out = inp1;
      2'b10: out = inp2;
      2'b11: out = inp3;
    endcase

endmodule

module mx4_33 (inp0, inp1, inp2, inp3, sel, out);
 
input  [32:0]  inp0;
input  [32:0]  inp1;
input  [32:0]  inp2;
input  [32:0]  inp3;
input   [1:0]  sel;
output [32:0]  out;
 
reg    [32:0]  out;
 
  always @(inp0 or inp1 or inp2 or inp3 or sel)
    case (sel)
      2'b00: out = inp0;
      2'b01: out = inp1;
      2'b10: out = inp2;
      2'b11: out = inp3;
    endcase

endmodule

module mj_p_muxpri2(sl,slb);
output[1:0] slb;
input [1:0] sl;

assign slb[1] = ~sl[1];
assign slb[0] = ~(~sl[1] & sl[0]);

endmodule


module mj_p_muxpri3(sl,slb);
output[2:0] slb;
input [2:0] sl;

assign slb[2] = ~sl[2];
assign slb[1] = ~(~sl[2] & sl[1]);
assign slb[0] = ~(~sl[2] & ~sl[1] & sl[0]);

endmodule


module mj_p_muxpri4(sl,slb);
output[3:0] slb;
input [3:0] sl;

assign slb[3] = ~sl[3];
assign slb[2] = ~(~sl[3] & sl[2]);
assign slb[1] = ~(~sl[3] & ~sl[2] & sl[1]);
// assign slb[0] = ~(~sl[3] & ~sl[2] & ~sl[1] & sl[0]);
assign slb[0] = ~(~sl[3] & ~sl[2] & ~sl[1]);

endmodule

module mj_p_muxpri6(sl,slb);
output[5:0] slb;
input [5:0] sl;
wire x00;
wire y00;

assign slb[5] = ~sl[5];
assign slb[4] = ~(~sl[5] & sl[4]);
assign slb[3] = ~(~sl[5] & ~sl[4] & sl[3]);
assign slb[2] = ~(~sl[5] & ~sl[4] & ~sl[3] & sl[2]);
assign x00 = (~sl[5] & ~sl[4] & ~sl[3] & ~sl[2]);
assign slb[1] = ~(x00 & sl[1] );
assign slb[0] = ~(x00 & ~sl[1] & sl[0]);

endmodule

module mj_p_muxpri8(sl,slb);
output[7:0] slb;
input [7:0] sl;
wire x00;
wire y00;

assign slb[7] = ~sl[7];
assign slb[6] = ~(~sl[7] & sl[6]);
assign slb[5] = ~(~sl[7] & ~sl[6] & sl[5]);
assign slb[4] = ~(~sl[7] & ~sl[6] & ~sl[5] & sl[4]);
assign x00 = (~sl[7] & ~sl[6] & ~sl[5]);
assign y00 = (~sl[4] & ~sl[3] & ~sl[2]);
assign slb[3] = ~(x00 & sl[3] & ~sl[4]);
assign slb[2] = ~(x00 & ~sl[3] & sl[2] & ~sl[4]);
assign slb[1] = ~(x00 &  y00 & sl[1]);
assign slb[0] = ~(x00 &  y00 & ~sl[1] & sl[0]);


endmodule




module mj_s_mux4l_d_32 (mx_out, sel, in0, in1,in2,in3);
output [31:0] mx_out;
input [1:0] sel;
input  [31:0] in3;
input  [31:0] in2; 
input  [31:0] in1; 
input  [31:0] in0; 
wire [3:0] sl;
wire [3:0] slb;

mj_p_muxdec4_32 i_mj_p_muxdec4 (   .decb(slb),
                                   .dec(sl),
                                   .sel(sel)
                                   );

mj_p_mux4l_32	mj_p_mux4_32_0 (  .mx_out(mx_out),
    .in3(in3), 
    .in2(in2),	
    .in1(in1),
    .in0(in0),
    .sel(sl) ,.sel_l(slb) );

endmodule

module mj_p_mux4l_32 (mx_out, in3, in2, in1, in0, sel, sel_l);
    output [31:0] mx_out;
    input  [31:0] in3; 
    input  [31:0] in2; 
    input  [31:0] in1; 
    input  [31:0] in0; 
    input  [3:0] sel; input  [3:0] sel_l;

    mj_p_mux4l  mux_0 (.mx_out(mx_out[0]), .in3(in3[0]), .in2(in2[0]), .in1(in1[0]), .in0(in0[0]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_1 (.mx_out(mx_out[1]), .in3(in3[1]), .in2(in2[1]), .in1(in1[1]), .in0(in0[1]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_2 (.mx_out(mx_out[2]), .in3(in3[2]), .in2(in2[2]), .in1(in1[2]), .in0(in0[2]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_3 (.mx_out(mx_out[3]), .in3(in3[3]), .in2(in2[3]), .in1(in1[3]), .in0(in0[3]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_4 (.mx_out(mx_out[4]), .in3(in3[4]), .in2(in2[4]), .in1(in1[4]), .in0(in0[4]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_5 (.mx_out(mx_out[5]), .in3(in3[5]), .in2(in2[5]), .in1(in1[5]), .in0(in0[5]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_6 (.mx_out(mx_out[6]), .in3(in3[6]), .in2(in2[6]), .in1(in1[6]), .in0(in0[6]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_7 (.mx_out(mx_out[7]), .in3(in3[7]), .in2(in2[7]), .in1(in1[7]), .in0(in0[7]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_8 (.mx_out(mx_out[8]), .in3(in3[8]), .in2(in2[8]), .in1(in1[8]), .in0(in0[8]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_9 (.mx_out(mx_out[9]), .in3(in3[9]), .in2(in2[9]), .in1(in1[9]), .in0(in0[9]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_10 (.mx_out(mx_out[10]), .in3(in3[10]), .in2(in2[10]), .in1(in1[10]), .in0(in0[10]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_11 (.mx_out(mx_out[11]), .in3(in3[11]), .in2(in2[11]), .in1(in1[11]), .in0(in0[11]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_12 (.mx_out(mx_out[12]), .in3(in3[12]), .in2(in2[12]), .in1(in1[12]), .in0(in0[12]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_13 (.mx_out(mx_out[13]), .in3(in3[13]), .in2(in2[13]), .in1(in1[13]), .in0(in0[13]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_14 (.mx_out(mx_out[14]), .in3(in3[14]), .in2(in2[14]), .in1(in1[14]), .in0(in0[14]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_15 (.mx_out(mx_out[15]), .in3(in3[15]), .in2(in2[15]), .in1(in1[15]), .in0(in0[15]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_16 (.mx_out(mx_out[16]), .in3(in3[16]), .in2(in2[16]), .in1(in1[16]), .in0(in0[16]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_17 (.mx_out(mx_out[17]), .in3(in3[17]), .in2(in2[17]), .in1(in1[17]), .in0(in0[17]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_18 (.mx_out(mx_out[18]), .in3(in3[18]), .in2(in2[18]), .in1(in1[18]), .in0(in0[18]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_19 (.mx_out(mx_out[19]), .in3(in3[19]), .in2(in2[19]), .in1(in1[19]), .in0(in0[19]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_20 (.mx_out(mx_out[20]), .in3(in3[20]), .in2(in2[20]), .in1(in1[20]), .in0(in0[20]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_21 (.mx_out(mx_out[21]), .in3(in3[21]), .in2(in2[21]), .in1(in1[21]), .in0(in0[21]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_22 (.mx_out(mx_out[22]), .in3(in3[22]), .in2(in2[22]), .in1(in1[22]), .in0(in0[22]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_23 (.mx_out(mx_out[23]), .in3(in3[23]), .in2(in2[23]), .in1(in1[23]), .in0(in0[23]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_24 (.mx_out(mx_out[24]), .in3(in3[24]), .in2(in2[24]), .in1(in1[24]), .in0(in0[24]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_25 (.mx_out(mx_out[25]), .in3(in3[25]), .in2(in2[25]), .in1(in1[25]), .in0(in0[25]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_26 (.mx_out(mx_out[26]), .in3(in3[26]), .in2(in2[26]), .in1(in1[26]), .in0(in0[26]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_27 (.mx_out(mx_out[27]), .in3(in3[27]), .in2(in2[27]), .in1(in1[27]), .in0(in0[27]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_28 (.mx_out(mx_out[28]), .in3(in3[28]), .in2(in2[28]), .in1(in1[28]), .in0(in0[28]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_29 (.mx_out(mx_out[29]), .in3(in3[29]), .in2(in2[29]), .in1(in1[29]), .in0(in0[29]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_30 (.mx_out(mx_out[30]), .in3(in3[30]), .in2(in2[30]), .in1(in1[30]), .in0(in0[30]), .sel(sel), .sel_l(sel_l));
    mj_p_mux4l  mux_31 (.mx_out(mx_out[31]), .in3(in3[31]), .in2(in2[31]), .in1(in1[31]), .in0(in0[31]), .sel(sel), .sel_l(sel_l));

endmodule 

module mj_p_mux4l (
    mx_out, 
    in3,
    in2,
    in1,
    in0,
    sel,
    sel_l ) ;

    output mx_out;
    input in3;
    input in2;
    input in1;
    input in0;
    input [3:0] sel;
    input [3:0] sel_l;


reg mx_out;
always @(sel or in2 or in1 or in0 or in3)
begin
     case (sel)
    4'b1000: mx_out = ~in3;
    4'b0100: mx_out = ~in2;
    4'b0010: mx_out = ~in1;
    4'b0001: mx_out = ~in0;
    default: mx_out = 1'bx;
    endcase
end

endmodule

