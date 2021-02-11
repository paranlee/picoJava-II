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



module rsadd_dp ( 	a0zero, 
			a0, 
//			a1, 
//			r0md, 
//			r1md,
//			a2, 
			r1out,
			r0out,
			stin, 
			sticky, 
			saout, 
			b1, 
                  	b0, 
			bsmd, 
			aqcin, 
			rsout, 
			rsovfi 
			);

input  [31:0] a0;
input  [31:0] r0out, r1out;
//input   [1:0] r0md, r1md;
//input  [31:0] a1;
//input         a2;
input   [4:0] saout;
input  [31:0] b1;
input  [31:0] b0;
input   [1:0] bsmd;
input         stin, aqcin;
output [31:0] rsout;
output        a0zero, sticky, rsovfi;

wire   [31:0] rshiftout, bsmuxout;
//wire   [31:0] r0out, r1out;


/*****************************
mj_s_mux3_d_32 muxr0 ( 	.mx_out(r0out),
			.in2(32'h0),
			.in1(a1), 
			.in0(a0), 
			.sel(r0md) 
			);
mj_s_mux3_d_32 muxr1 ( 	.mx_out(r1out),
			.in2(32'h0),
			.in1({32{a2}}), 
			.in0(a1), 
			.sel(r1md) 
			);
**********************************/

mj_s_mux3_d_32 muxbs ( 	.mx_out(bsmuxout),
			.in2(b1), 
			.in1(b0), 
			.in0(32'h0),
			.sel(bsmd) 
			);




  compare_zero_32 a0comp (	.out(a0zero), 
				.in(a0) 
				);



  rshifter rshift1 ( 	.rshiftout(rshiftout), 
			.high(r1out[30:0]),
			.low(r0out),
			.stin(stin), 
			.sticky(sticky),
			.saout(saout)
			);


  cla_adder_32 rsadder ( .in1(bsmuxout),
			 .in2(rshiftout),
			 .cin(aqcin),
			 .sum(rsout),
			 .cout(rsovfi)
			 );

endmodule

