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

module rs2_dec (

	opcode,
	valid,
	offset_sel_rs2,
	lv_rs2,
	lvars_acc_rs2
);

input	[15:0]	opcode;
input	[2:0]	valid;
output	[4:0]	offset_sel_rs2;
output		lv_rs2;
output		lvars_acc_rs2;


// offset_sel_rs2[0] =  Select 0 as the offset; 
// offset_sel_rs2[1] =  Select 1 as the offset;
// offset_sel_rs2[2] =  Select 2 as the offset;
// offset_sel_rs2[3] =  Select 3 as the offset;
// offset_sel_rs2[4] =  Select nxt_byte as the offset;

wire	iload_0, fload_0, aload_0;
wire	iload_1, iload_2, iload_3;
wire	fload_1, fload_2, fload_3;
wire	aload_1, aload_2, aload_3;
wire	iload, fload, aload, sipush, bipush;
wire	aconst_null, iconst_m1, iconst_0, iconst_1;
wire	iconst_2, iconst_3, iconst_4, iconst_5;
wire	fconst_0, fconst_1, fconst_2;
wire	read_gl0, read_gl1, read_gl2, read_gl3;
wire	ext_opcode;
wire	lload, lload_0, lload_1, lload_2, lload_3;
wire	dload, dload_0, dload_1, dload_2, dload_3;
wire	iinc, ret;

assign	iload_0 = (opcode[15:8] == 8'd26) & valid[0];
assign	iload_1 = (opcode[15:8] == 8'd27) & valid[0];
assign	iload_2 = (opcode[15:8] == 8'd28) & valid[0];
assign	iload_3 = (opcode[15:8] == 8'd29) & valid[0];

assign	fload_0 = (opcode[15:8] == 8'd34) & valid[0];
assign	fload_1 = (opcode[15:8] == 8'd35) & valid[0];
assign	fload_2 = (opcode[15:8] == 8'd36) & valid[0];
assign	fload_3 = (opcode[15:8] == 8'd37) & valid[0];

assign	aload_0 = (opcode[15:8] == 8'd42) & valid[0];
assign	aload_1 = (opcode[15:8] == 8'd43) & valid[0];
assign	aload_2 = (opcode[15:8] == 8'd44) & valid[0];
assign	aload_3 = (opcode[15:8] == 8'd45) & valid[0];

assign	aconst_null = (opcode[15:8] == 8'd1) & valid[0];
assign	iconst_m1   = (opcode[15:8] == 8'd2) & valid[0];
assign	iconst_0    = (opcode[15:8] == 8'd3) & valid[0];
assign	iconst_1    = (opcode[15:8] == 8'd4) & valid[0];
assign	iconst_2    = (opcode[15:8] == 8'd5) & valid[0];
assign	iconst_3    = (opcode[15:8] == 8'd6) & valid[0];
assign	iconst_4    = (opcode[15:8] == 8'd7) & valid[0];
assign	iconst_5    = (opcode[15:8] == 8'd8) & valid[0];

assign	fconst_0  = (opcode[15:8] == 8'd11) & valid[0];
assign	fconst_1  = (opcode[15:8] == 8'd12) & valid[0];
assign	fconst_2  = (opcode[15:8] == 8'd13) & valid[0];

assign	bipush = (opcode[15:8] == 8'd16) & valid[0] & valid[1];
assign	sipush = (opcode[15:8] == 8'd17) & valid[0] & valid[1] & valid[2];
assign	iload  = (opcode[15:8] == 8'd21) & valid[0] & valid[1];
assign	fload  = (opcode[15:8] == 8'd23) & valid[0] & valid[1];
assign	aload  = (opcode[15:8] == 8'd25) & valid[0] & valid[1];

assign	ext_opcode = (opcode[15:8] == 8'd255) & valid[0];
assign  read_gl0 = ext_opcode & (opcode[7:0] == 8'd90) & valid[1];
assign  read_gl1 = ext_opcode & (opcode[7:0] == 8'd91) & valid[1];
assign  read_gl2 = ext_opcode & (opcode[7:0] == 8'd92) & valid[1];
assign  read_gl3 = ext_opcode & (opcode[7:0] == 8'd93) & valid[1];

assign	lload   = (opcode[15:8] == 8'd22) & valid[0] & valid[1];
assign	dload   = (opcode[15:8] == 8'd24) & valid[0] & valid[1];
assign	lload_0 = (opcode[15:8] == 8'd30) & valid[0];
assign	lload_1 = (opcode[15:8] == 8'd31) & valid[0];
assign	lload_2 = (opcode[15:8] == 8'd32) & valid[0];
assign	lload_3 = (opcode[15:8] == 8'd33) & valid[0];
assign	dload_0 = (opcode[15:8] == 8'd38) & valid[0];
assign	dload_1 = (opcode[15:8] == 8'd39) & valid[0];
assign	dload_2 = (opcode[15:8] == 8'd40) & valid[0];
assign	dload_3 = (opcode[15:8] == 8'd41) & valid[0];

assign	iinc = (opcode[15:8] == 8'd132) & valid[0];
assign	ret  = (opcode[15:8] == 8'd169) & valid[0];

assign	offset_sel_rs2[1] =  iload_1 | fload_1 | aload_1;
assign	offset_sel_rs2[2] =  iload_2 | fload_2 | aload_2;
assign	offset_sel_rs2[3] =  iload_3 | fload_3 | aload_3;
assign	offset_sel_rs2[4] =  iload | fload | aload | sipush | bipush;
assign	offset_sel_rs2[0] = !(|offset_sel_rs2[4:1]);

assign	lv_rs2 = aconst_null | iconst_m1 | iconst_0 | iconst_1 | iconst_2 |
                 iconst_3 | iconst_4 | iconst_5 | fconst_0 | fconst_1 |
                 fconst_2 | iload_0 | iload_1 | iload_2 | iload_3 |  fload_0 |
                 fload_1 | fload_2 | fload_3 | aload_0 | aload_1 | aload_2 |
                 aload_3 | sipush | bipush | iload | fload | aload |
                 read_gl0 | read_gl1 | read_gl2 | read_gl3 ;


assign	lvars_acc_rs2 = iload_0 | iload_1 | iload_2 | iload_3 |
                        fload_0 | fload_1 | fload_2 | fload_3 |
                        aload_0 | aload_1 | aload_2 | aload_3 |
                        iload   | fload   | aload   | iinc    |
                        dload_0 | dload_1 | dload_2 | dload_3 |
                        lload_0 | lload_1 | lload_2 | lload_3 |
                        ret ;


endmodule
