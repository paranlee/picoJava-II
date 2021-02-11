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
`timescale 1 ns / 10 ps

module ieu_rom (rom_en, adr, clk, tadr, te, tm, me, do );
input  [8:0] adr;
input  [8:0] tadr;
input	     rom_en;
input	     tm;

output [83:0] do;
input  clk, te, me;


IEUROM rom0 (.ADR0(adr[0]), .ADR1(adr[1]), .ADR2(adr[2]), .ADR3(adr[3]), .ADR4(adr[4]), .ADR5(adr[5]), .ADR6(adr[6]), .ADR7(adr[7]), .ADR8(adr[8]),
             .TADR0(tadr[0]), .TADR1(tadr[1]), .TADR2(tadr[2]), .TADR3(tadr[3]), .TADR4(tadr[4]), .TADR5(tadr[5]), .TADR6(tadr[6]), .TADR7(tadr[7]), .TADR8(tadr[8]),
             .CLK(clk), .ME(me), .TE(tm), 
             .DO0(do[0]), .DO1(do[1]), .DO2(do[2]), .DO3(do[3]), .DO4(do[4]), .DO5(do[5]), .DO6(do[6]), .DO7(do[7]),
             .DO8(do[8]), .DO9(do[9]), .DO10(do[10]), .DO11(do[11]), .DO12(do[12]), .DO13(do[13]), .DO14(do[14]), .DO15(do[15]),
             .DO16(do[16]), .DO17(do[17]), .DO18(do[18]), .DO19(do[19]), .DO20(do[20]), .DO21(do[21]), .DO22(do[22]), .DO23(do[23]),
             .DO24(do[24]), .DO25(do[25]), .DO26(do[26]), .DO27(do[27]), .DO28(do[28]), .DO29(do[29]), .DO30(do[30]), .DO31(do[31]),
             .DO32(do[32]), .DO33(do[33]), .DO34(do[34]), .DO35(do[35]), .DO36(do[36]), .DO37(do[37]), .DO38(do[38]), .DO39(do[39]),
             .DO40(do[40]), .DO41(do[41]), .DO42(do[42]), .DO43(do[43]), .DO44(do[44]), .DO45(do[45]), .DO46(do[46]), .DO47(do[47]),
             .DO48(do[48]), .DO49(do[49]), .DO50(do[50]), .DO51(do[51]), .DO52(do[52]), .DO53(do[53]), .DO54(do[54]), .DO55(do[55]),
             .DO56(do[56]), .DO57(do[57]), .DO58(do[58]), .DO59(do[59]), .DO60(do[60]), .DO61(do[61]), .DO62(do[62]), .DO63(do[63]),
             .DO64(do[64]), .DO65(do[65]), .DO66(do[66]), .DO67(do[67]), .DO68(do[68]), .DO69(do[69]), .DO70(do[70]), .DO71(do[71]),
             .DO72(do[72]), .DO73(do[73]), .DO74(do[74]), .DO75(do[75]), .DO76(do[76]), .DO77(do[77]), .DO78(do[78]), .DO79(do[79]),
             .DO80(), .DO81(), .DO82(), .DO83(), .DO84(), .DO85(), .DO86(), .DO87(),
             .DO88(), .DO89(), .DO90(), .DO91(), .DO92(), .DO93(), .DO94(), .DO95());

endmodule
