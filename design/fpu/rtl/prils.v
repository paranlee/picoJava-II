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

module prils(a1,a0,prifunc,mconfunc,lsround,incinfunc,stin,lsout,saout,priout,
	     multout,nx_prifunc_rom0,nx_prifunc_rom1,romsel,clk,reset_l, fpuhold, so, sin, sm);
// Priority and left-shift module.

input  [31:0]  a1,a0,multout;
input   [2:0]  prifunc,incinfunc,nx_prifunc_rom0,nx_prifunc_rom1;
input   [1:0]  mconfunc, romsel;
input          stin;     // sticky register input.
input	       clk,reset_l, fpuhold;
input   [4:0]  saout;     // Shift amount Input.

output so;
input sm, sin;

output [31:0]  lsout;    // Left Shift module output.
output         lsround;  // Left Shift ROUND output.
output  [5:0]  priout;

wire    [1:0]  m1c,m2c,m3c;
wire           m4,lsdprec,m0c;


prils_cntl  i_prils_cntl(.lsdprec(lsdprec),
			     .m1c(m1c),
			     .m3c(m3c),
			     .m0c(m0c),
			     .m4(m4),
			     .m2c(m2c),
			     .prifunc(prifunc),
			     .incinfunc(incinfunc),
			     .nx_prifunc_rom0(nx_prifunc_rom0),
			     .nx_prifunc_rom1(nx_prifunc_rom1),
			     .clk(clk),
			     .reset_l(reset_l),
			     .fpuhold(fpuhold),
			     .romsel(romsel),
		 		.sm(),
				.sin(),
				.so()	
			 );


prils_dp    i_prils_dp ( .lsout(lsout),
			     .lsround(lsround),
			     .priout(priout),
			     .a1(a1),
			     .a0(a0),
			     .multout(multout),
			     .stin(stin),
			     .m0c(m0c),
			     .m4(m4),
			     .m1c(m1c),
			     .m2c(m2c),
			     .saout(saout),
			     .m3c(m3c),
			     .mconfunc(mconfunc),	
			     .lsdprec(lsdprec)
			 );


endmodule


