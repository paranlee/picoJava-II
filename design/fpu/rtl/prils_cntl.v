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




module prils_cntl (lsdprec,m1c,m3c,m0c,m4,m2c,prifunc,incinfunc,
		   nx_prifunc_rom0,nx_prifunc_rom1,romsel,clk,reset_l, fpuhold, sm, sin, so);

output    [1:0]  m1c,m2c,m3c;
output    lsdprec,m0c, m4;
output so;
input sm, sin;
input     [2:0]  prifunc,incinfunc,nx_prifunc_rom0,nx_prifunc_rom1;
input		 clk, reset_l, fpuhold;
input [1:0] romsel;

pri_dec prid(	.m0(m0c),
		.m1(m1c),
		.m2(m2c),
		.m3(m3c),
		.m4(m4),
		.prifunc(prifunc),
		.nx_prifunc_rom0(nx_prifunc_rom0),
		.nx_prifunc_rom1(nx_prifunc_rom1),
		.romsel(romsel),
		.clk(clk),
		.fpuhold(fpuhold),
		.reset_l(reset_l),
		.so(),
		.sin(),
		.sm());

assign lsdprec = (incinfunc==3'h5);

endmodule




module pri_dec(m0,m1,m2,m3,m4,prifunc,nx_prifunc_rom0,nx_prifunc_rom1,
	       romsel, clk, reset_l, fpuhold, so, sin, sm);
// Priority encode and Left Shift func Block.

 input [2:0] prifunc, nx_prifunc_rom0, nx_prifunc_rom1;
 input 	     clk,reset_l, fpuhold;
 input [1:0] romsel;
output so;
input sm, sin;
 output  [1:0] m2,m3,m1;
 output        m0, m4;

reg [1:0] m2,m3,m1_rom0,m1_rom1;
wire [1:0] m1, nx_m1;
wire m0;

wire fpuhold_l = ~fpuhold;


  always @(nx_prifunc_rom0)  
   begin
    casex(nx_prifunc_rom0)     // synopsys full_case parallel_case
      3'b000,
      3'b11x:    m1_rom0=2'h2;
      3'b001,
      3'b010:    m1_rom0=2'h1;
      3'b101:    m1_rom0=2'h3;
      default: m1_rom0=2'h0;
    endcase
   end

  always @(nx_prifunc_rom1)
   begin
    casex(nx_prifunc_rom1)     // synopsys full_case parallel_case
      3'b000,
      3'b11x:    m1_rom1=2'h2;
      3'b001,    
      3'b010:    m1_rom1=2'h1;
      3'b101:    m1_rom1=2'h3;
      default: m1_rom1=2'h0;
    endcase
   end


mj_s_mux3_d_2 m1_mux(	.mx_out(nx_m1),
			.sel(romsel),
			.in0(m1_rom0),
			.in1(m1_rom1),
			.in2(2'h2));

mj_s_ff_snre_d_2 m1_ff(	.out(m1),
			.din(nx_m1),
			.reset_l(reset_l),
			.clk(clk),
                        .lenable(fpuhold_l));
   
assign m0 = ((prifunc==3'h1) || (prifunc==3'h2));

  always @(prifunc)  
     if((prifunc==3'h1) || (prifunc==3'h4))  
	m2 = 2'h2;
     else if((prifunc==3'h2) || (prifunc==3'h3))  
	m2 = 2'h1;
     else                                         
	m2 = 2'h0;

  always @(prifunc)  
     if(prifunc==3'h0)  
	m3 = 2'h0;
     else if(prifunc==3'h6)  
	m3 = 2'h1;
     else                    
	m3 = 2'h2;

  assign m4 = (prifunc==3'h7);
 
endmodule
