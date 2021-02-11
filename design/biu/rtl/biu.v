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



module	biu (
	icu_req,
	icu_addr,
	icu_type,
	icu_size,
	biu_icu_ack,
	biu_data,
	dcu_req,
	dcu_addr,
	dcu_type,
	dcu_size,
	dcu_dataout,
	biu_dcu_ack,
	clk,
	reset_l,
	pj_addr,
	pj_data_out,
	pj_data_in,
	pj_tv,
	pj_size,
	pj_type,
	pj_ack,
	pj_ale,
	sin,
	so,
	sm
	);

input			icu_req;
input	[31:0]	icu_addr;			
input	[3:0]	icu_type;			
input	[1:0]	icu_size;			
output	[1:0]	biu_icu_ack;		
output	[31:0]	biu_data;	
input			dcu_req;
input	[31:0]	dcu_addr;			
input	[3:0]	dcu_type;			
input	[1:0]	dcu_size;			
input	[31:0]	dcu_dataout;		
output	[1:0]	biu_dcu_ack;		
input			clk;
input			reset_l;
output	[29:0]	pj_addr;		
output	[31:0]	pj_data_out;	
input	[31:0]	pj_data_in;		
output			pj_tv;
output	[1:0]	pj_size;		
output	[3:0]	pj_type;		
input	[1:0]	pj_ack;
output			pj_ale;
input			sin;
output			so;
input			sm;

wire		arb_select;
wire [31:0] pj_addr_int;
wire [29:0] pj_addr= pj_addr_int[29:0];

biu_ctl	biu_ctl (
	.icu_req		(icu_req),
	.icu_type		(icu_type[3:0]),
     .icu_size		(icu_size[1:0]),
     .biu_icu_ack	(biu_icu_ack[1:0]),
     .dcu_req		(dcu_req),
     .dcu_type		(dcu_type[3:0]),
     .dcu_size		(dcu_size[1:0]),
     .biu_dcu_ack	(biu_dcu_ack[1:0]),
     .clk			(clk),
     .reset_l		(reset_l),
     .pj_tv		(pj_tv),
     .pj_type		(pj_type[3:0]),
     .pj_size		(pj_size[1:0]),
     .pj_ack		(pj_ack[1:0]),
     .sin		(),
     .so		(),
     .sm		(), 
     .arb_select	(arb_select),
	.pj_ale		(pj_ale)
);

biu_dpath	biu_dpath (
	.icu_addr		(icu_addr[31:0]),
     .dcu_addr		(dcu_addr[31:0]),
     .dcu_dataout	(dcu_dataout[31:0]),
     .biu_data		(biu_data[31:0]),
     .pj_addr		(pj_addr_int[31:0]),
     .pj_data_in	(pj_data_in[31:0]),
     .pj_data_out	(pj_data_out[31:0]),
     .arb_select	(arb_select)
);

endmodule
