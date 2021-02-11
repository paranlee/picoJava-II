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

module fold_logic (

	F0,
	F1,
	F2,
	F3,
	V0,
	V1,
	V2,
	V3,
	FOE,
	notvalid,
	fold1,
	fold2,
	fold3,
	fold4,
	gr1,
	gr2,
	gr3,
	gr4,
	gr5,
	gr6,
	gr7,
	gr8,
	gr9
);

input	[5:0]	F0;
input	[5:0]	F1;
input	[5:0]	F2;
input	[5:0]	F3;
input		V0;
input		V1;
input		V2;
input		V3;
input		FOE;
output		notvalid;
output		fold1;
output		fold2;
output		fold3;
output		fold4;
output		gr1;
output		gr2;
output		gr3;
output		gr4;
output		gr5;
output		gr6;
output		gr7;
output		gr8;
output		gr9;

wire		gr1_tmp;
wire		gr2_tmp;
wire		gr3_tmp;
wire		gr4_tmp;
wire		gr5_tmp;
wire		gr6_tmp;
wire		gr7_tmp;
wire		gr8_tmp;
wire		gr9_tmp;

wire		gr1;
wire		gr2;
wire		gr3;
wire		gr4;
wire		gr5;
wire		gr6;
wire		gr7;
wire		gr8;
wire		gr9;

assign	gr1_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[1] &
				V2&F2[2] & 
				V3&F3[5] );

assign	gr2_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[1] &
				V2&F2[2] );

assign	gr3_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[1] &
				V2&F2[3] );

assign	gr4_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[2] &
				V2&F2[5] );

assign	gr5_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[3] );

assign	gr6_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[4] );

assign	gr7_tmp = 	FOE & ( V0&F0[1] & 
				V1&F1[2] ); 

assign	gr8_tmp = 	FOE & ( V0&F0[1] &
				V1&F1[5] );

assign	gr9_tmp = 	FOE & ( V0&F0[2] &
				V1&F1[5] ); 


assign	gr1 = gr1_tmp;

assign	gr2 = !gr1_tmp & gr2_tmp;

assign	gr3 = gr3_tmp;

assign	gr4 = gr4_tmp;

assign	gr5 = gr5_tmp;

assign	gr6 = gr6_tmp;

assign	gr7 = !gr4_tmp & gr7_tmp;

assign	gr8 = gr8_tmp;

assign	gr9 = gr9_tmp;

assign	fold2 = gr5 | gr6 | gr7 | gr8 | gr9;
assign	fold3 = gr2 | gr3 | gr4;
assign	fold4 = gr1;

assign	fold1 = V0 & (!fold2 & !fold3 & !fold4);
assign	notvalid   = !V0;

endmodule
