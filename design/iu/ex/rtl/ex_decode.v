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

module ex_decode( 

// Input from IFU
        opcode_1_op_r,
        opcode_2_op_r,

// Input from decode8to256
	decodeout_1,
	decodeout_2,

// Output to ex_ctl 
	invalid_op_r,
	illegal_op_r
);

  // Input signals from IU
   input  [7:0]         opcode_1_op_r;  // 1st byte of the opcode
   input  [7:0]         opcode_2_op_r;  // 2nd byte of the opcode

   output [255:0] decodeout_1;		// JVM opcodes 
   output [255:0] decodeout_2;		// Exented bytecodes

   output  invalid_op_r;		// Unused JVM opcodes 
   output  illegal_op_r;		// Usused extended bytecodes

  // The R-Stage decoder.
  mj_s_dcd8to256 decode8to256_1(
           .data (opcode_1_op_r[7:0]),
           .decodeout   (decodeout_1[255:0]));
 
//   assign invalid_op_r= decodeout_1[186] | decodeout_1[220] |
  assign invalid_op_r= decodeout_1[186] |
			decodeout_1[219] |
			decodeout_1[247] | decodeout_1[248] |
			decodeout_1[249] | decodeout_1[250] |
			decodeout_1[251] | decodeout_1[252] |
			decodeout_1[253] | decodeout_1[254];

  // The D-Stage decoder.
  mj_s_dcd8to256 decode8to256_2(
           .data (opcode_2_op_r[7:0]),
           .decodeout   (decodeout_2[255:0]));

  assign illegal_op_r=  decodeout_1[255] & ! (decodeout_2[0] | 
			decodeout_2[1] | decodeout_2[2] |
			decodeout_2[3] | decodeout_2[4] |
			decodeout_2[5] | decodeout_2[6] |
			decodeout_2[7] | decodeout_2[10] |
			decodeout_2[11] | decodeout_2[12] |
			decodeout_2[13] | decodeout_2[14] |
			decodeout_2[15] | decodeout_2[16] |
			decodeout_2[17] | decodeout_2[18] |
			decodeout_2[19] | decodeout_2[20] |
			decodeout_2[21] | decodeout_2[22] |
			decodeout_2[23] | decodeout_2[26] |
			decodeout_2[27] | decodeout_2[28] |
			decodeout_2[29] | decodeout_2[30] |
			decodeout_2[31] | decodeout_2[32] |
			decodeout_2[34] | decodeout_2[36] |
			decodeout_2[37] | decodeout_2[38] |
			decodeout_2[39] | decodeout_2[42] |
			decodeout_2[44] | decodeout_2[45] |
			decodeout_2[46] | decodeout_2[47] |
			decodeout_2[48] | decodeout_2[50] | 
			decodeout_2[52] | 
			decodeout_2[54] | decodeout_2[55] |
			decodeout_2[58] | decodeout_2[60] |
			decodeout_2[61] | decodeout_2[62] |
			decodeout_2[63] | decodeout_2[64] |
			decodeout_2[65] | decodeout_2[66] |
			decodeout_2[67] | decodeout_2[68] |
			decodeout_2[69] | decodeout_2[70] |
			decodeout_2[71] | decodeout_2[72] |
			decodeout_2[73] | decodeout_2[76] |
			decodeout_2[77] | decodeout_2[80] |
			decodeout_2[81] | decodeout_2[82] |
			decodeout_2[83] | decodeout_2[84] |
			decodeout_2[85] | decodeout_2[87] |
			decodeout_2[88] | decodeout_2[89] |
			decodeout_2[90] | decodeout_2[91] |
			decodeout_2[92] | decodeout_2[93] |
			decodeout_2[96] | decodeout_2[97] |
			decodeout_2[98] | decodeout_2[99] |
			decodeout_2[100] | decodeout_2[101] |
			decodeout_2[102] | decodeout_2[103] |
			decodeout_2[104] | decodeout_2[105] |
			decodeout_2[108] | decodeout_2[109] |
			decodeout_2[112] | decodeout_2[113] |
			decodeout_2[114] | decodeout_2[115] |
			decodeout_2[116] | decodeout_2[117] |
			decodeout_2[121] | decodeout_2[122] |
			decodeout_2[123] | decodeout_2[124] |
			decodeout_2[125]);

  
endmodule

 // Seperate the large case statement for speed/synopsys.
/****
module decode8to256( opcode_1_op_r, decodeout); 

input  [7:0]  opcode_1_op_r;
output [255:0] decodeout;

reg [255:0] decodeout;

 // Decode all the instructions
always @(opcode_1_op_r) begin
 // Reset the output's first
  decodeout[255:0]=256'b0; 

case (opcode_1_op_r[7:0]) // synopsys full_case parallel_case
 8'h0:decodeout[0] = 1'b1;	//1 Nop (nop)
 //
 8'd1:decodeout[1] = 1'b1;  //1 push null object (aconst_null)
 8'd2:decodeout[2] = 1'b1;  //1 push integer constant -1 (iconst_m1)
 8'd3:decodeout[3] = 1'b1;  //1 push integer constant 0 (iconst_0)
 8'd4:decodeout[4] = 1'b1;  //1 push integer constant 1 (iconst_1)
 8'd5:decodeout[5] = 1'b1;  //1 push integer constant 2 (iconst_2)
 8'd6:decodeout[6] = 1'b1;  //1 push integer constant 3 (iconst_3)
 8'd7:decodeout[7] = 1'b1;  //1 push integer constant 4 (iconst_4)
 8'd8:decodeout[8] = 1'b1;  //1 push integer constant 5 (iconst_5)
 8'd9:decodeout[9] = 1'b1;  //1 push long 0L (lconst0)
 8'd10:decodeout[10] = 1'b1;  //1 push long 1L (lconst_1)
 8'd11:decodeout[11] = 1'b1;  //1 push float constant 0.0 (fconst_0) 
 8'd12:decodeout[12] = 1'b1;  //1 push float constant 1.0 (fconst_1)
 8'd13:decodeout[13] = 1'b1;  //1 push float constant 2.0 (fconst_2)
 8'd14:decodeout[14] = 1'b1;  //1 push double float constant 0.0d (dconst_0)
 8'd15:decodeout[15] = 1'b1;  //1 push double float constant 1.0d (dconst_1)
 8'd16:decodeout[16] = 1'b1;  //2 push byte-sized value (bipush)
 8'd17:decodeout[17] = 1'b1;  //3 push two-byte value (sipush)
//
 8'd18:decodeout[18] = 1'b1;  //2 load a const from const table (ldc)
 8'd19:decodeout[19] = 1'b1;  //3 (ldc_w)
 8'd20:decodeout[20] = 1'b1;  //3 load a 2-word constant (ldc2_w) 
 8'd21:decodeout[21] = 1'b1;  //2 load local integer variable (iload)
 8'd22:decodeout[22] = 1'b1;  //2 load local long variable (lload)
 8'd23:decodeout[23] = 1'b1;  //2 load local floating variable (fload)
 8'd24:decodeout[24] = 1'b1;  //2 load local double variable (dload)
 8'd25:decodeout[25] = 1'b1;  //2 load local object variable (aload)
 8'd26:decodeout[26] = 1'b1;  //1 load local integer variable #0 (iload_0)
 8'd27:decodeout[27] = 1'b1;  //1 load local integer variable #1 (iload_1) 
 8'd28:decodeout[28] = 1'b1;  //1 load local integer variable #2 (iload_2)
 8'd29:decodeout[29] = 1'b1;  //1 load local integer variable #3 (iload_3)
 8'd30:decodeout[30] = 1'b1;  //1 load local long variable #0 (lload_0)
 8'd31:decodeout[31] = 1'b1;  //1 load local long variable #1 (lload_1)
 8'd32:decodeout[32] = 1'b1;  //1 load local long variable #2 (lload_2)
 8'd33:decodeout[33] = 1'b1;  //1 load local long variable #3 (lload_3)
 8'd34:decodeout[34] = 1'b1;  //1 load local float variable #0 (fload_0)
 8'd35:decodeout[35] = 1'b1;  //1 load local float variable #1 (fload_1)
 8'd36:decodeout[36] = 1'b1;  //1 load local float variable #2 (fload_2)
 8'd37:decodeout[37] = 1'b1;  //1 load local float variable #3 (fload_3)
 8'd38:decodeout[38] = 1'b1;  //1 load double float variable #0 (dload_0)
 8'd39:decodeout[39] = 1'b1;  //1 load double float variable #1 (dload_1)
 8'd40:decodeout[40] = 1'b1;  //1 load double float variable #2 (dload_2)
 8'd41:decodeout[41] = 1'b1;  //1 load double float variable #3 (dload_3)
 8'd42:decodeout[42] = 1'b1;  //1 load local object variable #0 (aload_0)
 8'd43:decodeout[43] = 1'b1;  //1 load local object variable #1 (aload_1)
 8'd44:decodeout[44] = 1'b1;  //1 load local object variable #2 (aload_2)
 8'd45:decodeout[45] = 1'b1;  //1 load local object variable #3 (aload_3)
//
 8'd46:decodeout[46] = 1'b1;  //1 load from array of integer (iaload)
 8'd47:decodeout[47] = 1'b1;  //1 load from array of long (laload)
 8'd48:decodeout[48] = 1'b1;  //1 load from array of float (faload)
 8'd49:decodeout[49] = 1'b1;  //1 load from array of double (daload)
 8'd50:decodeout[50] = 1'b1;  //1 load from array of object (aaload)
 8'd51:decodeout[51] = 1'b1;  //1 load from array of signed bytes (baload)
 8'd52:decodeout[52] = 1'b1;  //1 load from array of chars (caload)
 8'd53:decodeout[53] = 1'b1;  //1 load from array of signed shorts (saload)

 8'd54:decodeout[54] = 1'b1;  //2 store local integer variable (istore)   
 8'd55:decodeout[55] = 1'b1;  //2 store local long variable (lstore)
 8'd56:decodeout[56] = 1'b1;  //2 store local float variable (fstore)
 8'd57:decodeout[57] = 1'b1;  //2 store local double variable (dstore)
 8'd58:decodeout[58] = 1'b1;  //2 store local object variable (astore)
 8'd59:decodeout[59] = 1'b1;  //  store local integer variable #0 (istore_0)
 8'd60:decodeout[60] = 1'b1;  //  store local integer variable #1 (istore_1)
 8'd61:decodeout[61] = 1'b1;  //  store local integer variable #2 (istore_2)
 8'd62:decodeout[62] = 1'b1;  //  store local integer variable #3 (istore_3)
 8'd63:decodeout[63] = 1'b1;  //  store local long variable #0 (lstore_0)
 8'd64:decodeout[64] = 1'b1;  //  store local long variable #1 (lstore_1)
 8'd65:decodeout[65] = 1'b1;  //  store local long variable #2 (lstore_2)
 8'd66:decodeout[66] = 1'b1;  //  store local long variable #3 (lstore_3)
 8'd67:decodeout[67] = 1'b1;  //  store local float variable #0 (fstore_0)
 8'd68:decodeout[68] = 1'b1;  //  store local float variable #1 (fstore_1)
 8'd69:decodeout[69] = 1'b1;  //  store local float variable #2 (fstore_2)
 8'd70:decodeout[70] = 1'b1;  //  store local float variable #3 (fstore_3)
 8'd71:decodeout[71] = 1'b1;  //  store lcl double variable #0 (dstore_0)
 8'd72:decodeout[72] = 1'b1;  //  store lcl double variable #1 (dstore_1)
 8'd73:decodeout[73] = 1'b1;  //  store lcl double variable #2 (dstore_2)
 8'd74:decodeout[74] = 1'b1;  //  store lcl double variable #3 (dstore_3)
 8'd75:decodeout[75] = 1'b1;  //  store local object variable #0 (astore_0)
 8'd76:decodeout[76] = 1'b1;  //  store local object variable #1 (astore_1)
 8'd77:decodeout[77] = 1'b1;  //  store local object variable #2 (astore_2)
 8'd78:decodeout[78] = 1'b1;  //  store local object variable #3 (astore_3)
//
 8'd79:decodeout[79] = 1'b1;  //1 store into array of int (iastore)
 8'd80:decodeout[80] = 1'b1;  //1 store into array of long (lastore)
 8'd81:decodeout[81] = 1'b1;  //1 store into array of float (fastore)
 8'd82:decodeout[82] = 1'b1;  //1 store into array of double float (dastore)
 8'd83:decodeout[83] = 1'b1;  //1 store into array of object (aastore)
 8'd84:decodeout[84] = 1'b1;  //1 store into array of signed bytes (bastore)
 8'd85:decodeout[85] = 1'b1;  //1 store into array of chars (castore)
 8'd86:decodeout[86] = 1'b1;  //1 store into array of signed shorts (sastore)
//
 8'd87:decodeout[87] = 1'b1;  //1 pop top element (pop)
 8'd88:decodeout[88] = 1'b1;  //1 pop top two elements (pop2)
 8'd89:decodeout[89] = 1'b1;  //1 dup top element (dup)
 8'd90:decodeout[90] = 1'b1;  //1 dup top element. Skip one (dup_x1)
 8'd91:decodeout[91] = 1'b1;  //1 dup top element. Skip two (dup_x2)
 8'd92:decodeout[92] = 1'b1;  //1 dup top two elements.  (dup2) 
 8'd93:decodeout[93] = 1'b1;  //1 dup top 2 elements.  Skip one (dup2_x1)
 8'd94:decodeout[94] = 1'b1;  //1 dup top 2 elements.  Skip two (dup2_x2)
 8'd95:decodeout[95] = 1'b1;  //1 swap top two elements of stack. (swap)
//
 8'd96:decodeout[96] = 1'b1;  //1 integer add (iadd)
 8'd97:decodeout[97] = 1'b1;  //1 long add (ladd)
 8'd98:decodeout[98] = 1'b1;  //1 floating add (fadd)
 8'd99:decodeout[99] = 1'b1;  //1 double float add (dadd)
 8'd100:decodeout[100] = 1'b1;     //1 integer subtract (isub)
 8'd101:decodeout[101] = 1'b1;      //1 long subtract (lsub)
 8'd102:decodeout[102] = 1'b1;      //1 floating subtract (fsub)
 8'd103:decodeout[103] = 1'b1;      //1 floating double subtract (dsub)
 8'd104:decodeout[104] = 1'b1;      //1 integer multiply (imul)
 8'd105:decodeout[105] = 1'b1;      //1 long multiply (lmul)
 8'd106:decodeout[106] = 1'b1;      //1 floating multiply (fmul)
 8'd107:decodeout[107] = 1'b1;      //1 double float multiply (dmul)
 8'd108:decodeout[108] = 1'b1;      //1 integer divide (idiv)
 8'd109:decodeout[109] = 1'b1;      //1 long divide (ldiv)
 8'd110:decodeout[110] = 1'b1;      //1 floating divide (fdiv)
 8'd111:decodeout[111] = 1'b1;      //1 double float divide (ddiv)
 8'd112:decodeout[112] = 1'b1;      //1 integer mod (irem)
 8'd113:decodeout[113] = 1'b1;      //1 long mod (lrem)
 8'd114:decodeout[114] = 1'b1;      //1 floating mod (frem)
 8'd115:decodeout[115] = 1'b1;      //1 double float mod (drem)
 8'd116:decodeout[116] = 1'b1;      //1 integer negate (ineg)
 8'd117:decodeout[117] = 1'b1;      //1 long negate (lneg)
 8'd118:decodeout[118] = 1'b1;      //1 floating negate (fneg)
 8'd119:decodeout[119] = 1'b1;      //1 double float negate (dneg)
 8'd120:decodeout[120] = 1'b1;      //1 shift left (ishl)
 8'd121:decodeout[121] = 1'b1;      //1 long shift left (lshl)
 8'd122:decodeout[122] = 1'b1;      //1 shift right (ishr)
 8'd123:decodeout[123] = 1'b1;      //1 long shift right (lshr)
 8'd124:decodeout[124] = 1'b1;      //1 unsigned shift right (iushr)
 8'd125:decodeout[125] = 1'b1;      //1 long unsigned shift right (lushr)
 8'd126:decodeout[126] = 1'b1;      //1 boolean and (iand)
 8'd127:decodeout[127] = 1'b1;      //1 long boolean and (land)
 8'd128:decodeout[128] = 1'b1;      //1 boolean or (ior)
 8'd129:decodeout[129] = 1'b1;      //1 long boolean or l(or)
 8'd130:decodeout[130] = 1'b1;      //1 boolean xor (ixor)
 8'd131:decodeout[131] = 1'b1;      //1 long boolean xor (lxor)
//
 8'd132:decodeout[132] = 1'b1;      //3 increment lcl variable by constant (iinc)
//
 8'd133:decodeout[133] = 1'b1;      //1 integer to long (i2l)
 8'd134:decodeout[134] = 1'b1;      //1 integer to float (i2f)
 8'd135:decodeout[135] = 1'b1;      //1 integer to double (i2d)
 8'd136:decodeout[136] = 1'b1;      //1 long to integer (l2i)
 8'd137:decodeout[137] = 1'b1;      //1 long to float (l2f)
 8'd138:decodeout[138] = 1'b1;      //1 long to double (l2d)
 8'd139:decodeout[139] = 1'b1;      //1 float to integer (f2i)
 8'd140:decodeout[140] = 1'b1;      //1 float to long (f2l)
 8'd141:decodeout[141] = 1'b1;      //1 float to double (f2d)
 8'd142:decodeout[142] = 1'b1;      //1 double to integer (d2i)
 8'd143:decodeout[143] = 1'b1;      //1 double to long (d2l)
 8'd144:decodeout[144] = 1'b1;      //1 double to float (d2f)
 8'd145:decodeout[145] = 1'b1;      //1 integer to byte (i2b int2byte)
 8'd146:decodeout[146] = 1'b1;      //1 integer to character (i2c int2char)
 8'd147:decodeout[147] = 1'b1;      //1 integer to signed short (i2s int2short)
//
 8'd148:decodeout[148] = 1'b1;    //1 long compare (lcmp)
 8'd149:decodeout[149] = 1'b1;    //1 float compare. -1 on incomparable (fcmpl)
 8'd150:decodeout[150] = 1'b1;    //1 float compare.  1 on incomparable (fcmpg)
 8'd151:decodeout[151] = 1'b1;    //1 dbl floating cmp. -1 on incomp (dcmpl)
 8'd152:decodeout[152] = 1'b1;    //1 dbl floating cmp.  1 on incomp (dcmpg)
//
 8'd153:decodeout[153] = 1'b1;    //3 if equal (ifeq) 
 8'd154:decodeout[154] = 1'b1;    //3 if not equal (ifne)
 8'd155:decodeout[155] = 1'b1;    //3 if less than (iflt)
 8'd156:decodeout[156] = 1'b1;    //3 if greater than or equal (ifge)
 8'd157:decodeout[157] = 1'b1;    //3 if greater than (ifgt)
 8'd158:decodeout[158] = 1'b1;    //3 if less than or equal (ifle)
//
 8'd159:decodeout[159] = 1'b1;    //3 cmp top two elements of stack (if_icmpeq)
 8'd160:decodeout[160] = 1'b1;    //3 cmp top two elements of stack (if_icmpne)
 8'd161:decodeout[161] = 1'b1;    //3 cmp top two elements of stack (if_icmplt)
 8'd162:decodeout[162] = 1'b1;    //3 cmp top two elements of stack (if_icmpge)
 8'd163:decodeout[163] = 1'b1;    //3 cmp top two elements of stack (if_icmpgt)
 8'd164:decodeout[164] = 1'b1;    //3 cmp top two elements of stack (if_icmple)
 8'd165:decodeout[165] = 1'b1;    //3 cmp top two objects of stack (if_acmpeq)
 8'd166:decodeout[166] = 1'b1;    //3 cmp top two objects of stack (if_acmpne)
 8'd167:decodeout[167] = 1'b1;    //3 unconditional goto (goto)
 8'd168:decodeout[168] = 1'b1;    //3 jump subroutine (jsr)
//
 8'd169:decodeout[169] = 1'b1;    //2 return from subroutine (ret)
//
 8'd170:decodeout[170] = 1'b1;    //99 (tableswitch)
 8'd171:decodeout[171] = 1'b1;    //99 (lookupswitch)
//
 8'd172:decodeout[172] = 1'b1;    //1 return integer from procedure (ireturn)
 8'd173:decodeout[173] = 1'b1;    //1 return long from procedure (lreturn)
 8'd174:decodeout[174] = 1'b1;    //1 return float from procedure (freturn)
 8'd175:decodeout[175] = 1'b1;    //1 return double from procedure (dreturn)
 8'd176:decodeout[176] = 1'b1;    //1 return object from procedure (areturn)
 8'd177:decodeout[177] = 1'b1;    //1 return (void) from procedure (return)
//
 8'd178:decodeout[178] = 1'b1;    //3 get static field value. (getstatic)
 8'd179:decodeout[179] = 1'b1;    //3 assign static field value (putstatic)
 8'd180:decodeout[180] = 1'b1;    //3 get field value from object. (getfield)
 8'd181:decodeout[181] = 1'b1;    //3 assign field value to object. (putfield)
//
 8'd182:decodeout[182] = 1'b1;    //3 call method, object. (invokevirtual)
 8'd183:decodeout[183] = 1'b1;    //3 call method, ~object. (invokenonvirtual)
 8'd184:decodeout[184] = 1'b1;    //3 call static method. (invokestatic)
 8'd185:decodeout[185] = 1'b1;    //5 call interface method (invokeinterface)
//
 8'd186:decodeout[186] = 1'b1;    // unused opcode 187 0xba
//
 8'd187:decodeout[187] = 1'b1;    //3 Create new object (new)
 8'd188:decodeout[188] = 1'b1;    //2 Create new array of ~objects (newarray)
 8'd189:decodeout[189] = 1'b1;    //3 Create new array of objects (anewarray)
 8'd190:decodeout[190] = 1'b1;    //1 get length of array (arraylength)
 8'd191:decodeout[191] = 1'b1;    //1 throw an exception (athrow)
 8'd192:decodeout[192] = 1'b1;    //3 err if object not of type (checkcast)
 8'd193:decodeout[193] = 1'b1;    //3 is object of given type? (instanceof)
//
 8'd194:decodeout[194] = 1'b1;    //1 enter a monitor region of code (monitorenter)
 8'd195:decodeout[195] = 1'b1;    //1 exit a monitor region of code (monitorexit)
//
 8'd196:decodeout[196] = 1'b1;    //0 prefix operation. (wide)
 8'd197:decodeout[197] = 1'b1;    //4 create multidim array (multianewarray)
 8'd198:decodeout[198] = 1'b1;    //3 goto if null (ifnull)
 8'd199:decodeout[199] = 1'b1;    //3 goto if not null (ifnonnull)
 8'd200:decodeout[200] = 1'b1;    //5 unconditional goto. 4b offset (goto_w)
 8'd201:decodeout[201] = 1'b1;    //5 jump subroutine.  4b offset (jsr_w)
//
 8'd202:decodeout[202] = 1'b1;    //1 call breakpoint handler (breakpoint)
// _quick opcodes
// The compiler will not generate any of the following instrs.
// These are created by the interpreter from non _quick versions.
 8'd203:decodeout[203] = 1'b1;    //2 (ldc_quick)
 8'd204:decodeout[204] = 1'b1;    //3 (ldc_w_quick)
 8'd205:decodeout[205] = 1'b1;    //3 (ldc2_w_quick)
 8'd206:decodeout[206] = 1'b1;    //3 (getfield_quick)
 8'd207:decodeout[207] = 1'b1;    //3 (putfield_quick)
 8'd208:decodeout[208] = 1'b1;    //3 (getfield2_quick)
 8'd209:decodeout[209] = 1'b1;    //3 (putfield2_quick)
 8'd210:decodeout[210] = 1'b1;    //3 (getstatic_quick)
 8'd211:decodeout[211] = 1'b1;    //3 (putstatic_quick)
 8'd212:decodeout[212] = 1'b1;    //3 (getstatic2_quick)
 8'd213:decodeout[213] = 1'b1;    //3 (putstatic2_quick)
 8'd214:decodeout[214] = 1'b1;    //3 (invokevirtual_quick)
 8'd215:decodeout[215] = 1'b1;    //3 (invokenonvirtual_quick)
 8'd216:decodeout[216] = 1'b1;    //3 (invokesuper_quick)
 8'd217:decodeout[217] = 1'b1;    //3 (invokestatic_quick)
 8'd218:decodeout[218] = 1'b1;    //5 (invokeinterface_quick)
 8'd219:decodeout[219] = 1'b1;    //3 (invokevirtualobject_quick)
 8'd220:decodeout[220] = 1'b1;    // Unused 
 8'd221:decodeout[221] = 1'b1;    //3 (new_quick)
 8'd222:decodeout[222] = 1'b1;    //3 (anewarray_quick)
 8'd223:decodeout[223] = 1'b1;    //4 (multianewarray_quick)
 8'd224:decodeout[224] = 1'b1;    //3 (checkcast_quick)
 8'd225:decodeout[225] = 1'b1;    //3 (instanceof_quick)
// These 3 are generated when offset is bigger than 255
 8'd226:decodeout[226] = 1'b1;    //3 (invokevirtual_quick_w)
 8'd227:decodeout[227] = 1'b1;    //3 (getfield_quick_w)
 8'd228:decodeout[228] = 1'b1;    //3 (putfield_quick_w)
//
 8'd229:decodeout[229] = 1'b1;    //3 (nonnull_quick)
 8'd230:decodeout[230] = 1'b1;    //3 (agetfield_quick)
 8'd231:decodeout[231] = 1'b1;    //3 (aputfield_quick)
 8'd232:decodeout[232] = 1'b1;    //3 (agetstatic_quick)
 8'd233:decodeout[233] = 1'b1;    //3 (aputstatic_quick)
 8'd234:decodeout[234] = 1'b1;    //3 (aldc_quick)
 8'd235:decodeout[235] = 1'b1;    //3 (aldc_w_quick)
 8'd236:decodeout[236] = 1'b1;    //3 (exit_sync_method)
 8'd237:decodeout[237] = 1'b1;    // (sethi)
 8'd238:decodeout[238] = 1'b1;    // (load_word_index)
 8'd239:decodeout[239] = 1'b1;    // (load_short_index)
 8'd240:decodeout[240] = 1'b1;    // (load_char_index)
 8'd241:decodeout[241] = 1'b1;    // (load_byte_index)
 8'd242:decodeout[242] = 1'b1;    // (load_ubyte_index)
 8'd243:decodeout[243] = 1'b1;    // (store_word_index)
 8'd244:decodeout[244] = 1'b1;    // (nastore_word_index)
 8'd245:decodeout[245] = 1'b1;    // (store_short_index)
 8'd246:decodeout[246] = 1'b1;    // (store_byte_index)
// Reserved opcodes, need to trap on these!
 8'd247:decodeout[247] = 1'b1;    // Unused 
 8'd248:decodeout[248] = 1'b1;    // Unused 
 8'd249:decodeout[249] = 1'b1;    // Unused 
 8'd250:decodeout[250] = 1'b1;    // Unused
 8'd251:decodeout[251] = 1'b1;    // Unused 
 8'd252:decodeout[252] = 1'b1;    // Unused 
 8'd253:decodeout[253] = 1'b1;    // Unused
 8'd254:decodeout[254] = 1'b1;    // Unused 
//
 8'd255: decodeout[255] = 1'b1;    // Exented bytecodes

 endcase
end
endmodule
**/
