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

module rsd_dec (

	opcode,
	valid,
	offset_sel_rsd
);

input	[7:0]	opcode;
input	[2:0]	valid;
output	[4:0]	offset_sel_rsd;


// offset_sel_rsd[0] =  Select 0 as the offset; 
// offset_sel_rsd[1] =  Select 1 as the offset;
// offset_sel_rsd[2] =  Select 2 as the offset;
// offset_sel_rsd[3] =  Select 3 as the offset;
// offset_sel_rsd[4] =  Select nxt_byte as the offset;

wire	istore_1, istore_2, istore_3;
wire	fstore_1, fstore_2, fstore_3;
wire	astore_1, astore_2, astore_3;
wire	lstore_1, lstore_2, lstore_3;
wire	dstore_1, dstore_2, dstore_3;
wire	istore, fstore, astore, dstore, lstore;
wire	iinc;


assign	istore_1 = (opcode[7:0] == 8'h3c) & valid[0];
assign	istore_2 = (opcode[7:0] == 8'h3d) & valid[0];
assign	istore_3 = (opcode[7:0] == 8'h3e) & valid[0];

assign	fstore_1 = (opcode[7:0] == 8'h44) & valid[0];
assign	fstore_2 = (opcode[7:0] == 8'h45) & valid[0];
assign	fstore_3 = (opcode[7:0] == 8'h46) & valid[0];

assign	lstore_1 = (opcode[7:0] == 8'h40) & valid[0];
assign	lstore_2 = (opcode[7:0] == 8'h41) & valid[0];
assign	lstore_3 = (opcode[7:0] == 8'h42) & valid[0];

assign	dstore_1 = (opcode[7:0] == 8'h48) & valid[0];
assign	dstore_2 = (opcode[7:0] == 8'h49) & valid[0];
assign	dstore_3 = (opcode[7:0] == 8'h4a) & valid[0];

assign	astore_1 = (opcode[7:0] == 8'h4c) & valid[0];
assign	astore_2 = (opcode[7:0] == 8'h4d) & valid[0];
assign	astore_3 = (opcode[7:0] == 8'h4e) & valid[0];

assign	istore  = (opcode[7:0] == 8'h36) & valid[0] & valid[1];
assign	fstore  = (opcode[7:0] == 8'h38) & valid[0] & valid[1];
assign	astore  = (opcode[7:0] == 8'h3a) & valid[0] & valid[1];
assign	dstore  = (opcode[7:0] == 8'h39) & valid[0] & valid[1];
assign	lstore  = (opcode[7:0] == 8'h37) & valid[0] & valid[1];

assign	iinc	= (opcode[7:0] == 8'h84) & valid[0] & valid[1] & valid[2];

assign	offset_sel_rsd[1] =  istore_1 | fstore_1 | astore_1 | lstore_1 | dstore_1;
assign	offset_sel_rsd[2] =  istore_2 | fstore_2 | astore_2 | lstore_2 | dstore_2;
assign	offset_sel_rsd[3] =  istore_3 | fstore_3 | astore_3 | lstore_3 | dstore_3;
assign	offset_sel_rsd[4] =  istore | fstore | astore | lstore | dstore | iinc;
assign	offset_sel_rsd[0] = !(|offset_sel_rsd[4:1]);

endmodule
