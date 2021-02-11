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



module fp_roms(rom_en,adr,clk,do1,do0,te,tadr,me, tm);

  input  [7:0]  adr;
  input  [7:0]  tadr;
  input         clk, rom_en;
  input         te, tm;
  input         me;
  output [63:0] do1,do0;

  reg    [63:0] mem0[191:0];
  reg    [63:0] mem1[191:0];
  reg    [63:0] do1,do0;

wire    [7:0]   int_adr;
// synopsys translate_off

assign int_adr = tm ? tadr:adr ;
wire int_enable = tm ? te : (rom_en & me);


/* Initialize rom from this file */
initial $readmemh("picoJava-II/design/fpu/rtl/fp_rom0.data", mem0);
initial $readmemh("picoJava-II/design/fpu/rtl/fp_rom1.data", mem1);

wire [63:0] din0, din1;

always @(posedge clk) begin
        do0 <= (int_enable) ? mem0[int_adr]: do0;
        do1 <= (int_enable) ? mem1[int_adr]: do1;
end

// synopsys translate_on

endmodule
