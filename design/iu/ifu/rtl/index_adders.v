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

module index1_add (

operand,
sum
);

input	[3:0]	operand;
output	[7:0]	sum;


assign	sum[7] = 1'b0;
assign	sum[6] = 1'b0;
assign	sum[5] = 1'b0;
assign	sum[1] = 1'b0;

assign	sum[4] =  operand[3];
assign	sum[3] =  operand[2];
assign	sum[2] =  operand[1];

// If the operand is zero i.e 4'b0001, then sum should also be
// zero i.e 7'b0000001

assign	sum[0] =  operand[0];

endmodule


module index2_add (

operand,
sum
);

input	[3:0]	operand;
output	[7:0]	sum;


assign	sum[7] = 1'b0;
assign	sum[6] = 1'b0;
assign	sum[2] = 1'b0;
assign	sum[1] = 1'b0;

assign	sum[5] =  operand[3];
assign	sum[4] =  operand[2];
assign	sum[3] =  operand[1];

// If the operand is zero i.e 4'b0001, then sum should also be
// zero i.e 7'b0000001

assign	sum[0] =  operand[0];

endmodule

module index3_add (

operand,
sum
);

input	[3:0]	operand;
output	[7:0]	sum;


assign	sum[7] = 1'b0;
assign	sum[3] = 1'b0;
assign	sum[2] = 1'b0;
assign	sum[1] = 1'b0;

assign	sum[6] =  operand[3];
assign	sum[5] =  operand[2];
assign	sum[4] =  operand[1];

// If the operand is zero i.e 4'b0001, then sum should also be
// zero i.e 7'b0000001

assign	sum[0] =  operand[0];

endmodule


module index4_add (

operand,
sum
);

input	[3:0]	operand;
output	[7:0]	sum;


assign	sum[4] = 1'b0;
assign	sum[3] = 1'b0;
assign	sum[2] = 1'b0;
assign	sum[1] = 1'b0;

assign	sum[7] =  operand[3];
assign	sum[6] =  operand[2];
assign	sum[5] =  operand[1];

// If the operand is zero i.e 4'b0001, then sum should also be
// zero i.e 7'b0000001

assign	sum[0] =   operand[0];

endmodule


module index5_add (

operand,
sum
);

input	[3:0]	operand;
output	[7:0]	sum;


assign	sum[5] = 1'b0;
assign	sum[4] = 1'b0;
assign	sum[3] = 1'b0;
assign	sum[2] = 1'b0;
assign	sum[1] = 1'b0;

assign	sum[7] =  operand[2];
assign	sum[6] =  operand[1];

// If the operand is zero i.e 4'b0001, then sum should also be
// zero i.e 7'b0000001

assign	sum[0] =  !(operand[2] | operand[1]);

endmodule


module index6_add (

operand,
sum
);

input	[3:0]	operand;
output	[7:0]	sum;


assign	sum[6] = 1'b0;
assign	sum[5] = 1'b0;
assign	sum[4] = 1'b0;
assign	sum[3] = 1'b0;
assign	sum[2] = 1'b0;
assign	sum[1] = 1'b0;

assign	sum[7] =  operand[1];

// If the operand is zero i.e 4'b0001, then sum should also be
// zero i.e 7'b0000001

assign	sum[0] =  !operand[1];

endmodule
