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





module biu_dpath (
	icu_addr,
	dcu_addr,
	dcu_dataout,
	biu_data,
	pj_addr,
	pj_data_in,
	pj_data_out,
	arb_select
	);

input     [31:0]    icu_addr;
input     [31:0]    dcu_addr;
input   	[31:0]    dcu_dataout;
output  	[31:0]    biu_data;
output  	[31:0]    pj_addr;
input   	[31:0]    pj_data_in;
output  	[31:0]    pj_data_out;
input			arb_select;

mux2_32   biu_addr_mux(.out(pj_addr[31:0]),
          .in1(icu_addr[31:0]),
          .in0(dcu_addr[31:0]),
          .sel({arb_select,!arb_select}));


assign    pj_data_out[31:0] = dcu_dataout[31:0];
assign    biu_data  = pj_data_in ;

endmodule
