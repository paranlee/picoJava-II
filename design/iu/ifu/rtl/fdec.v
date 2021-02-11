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

module fdec (
opcode,
type
);

input	[15:0]	opcode;
output	[5:0]	type;

reg		type5;
reg		type4;
reg		type3;
reg		type2;
reg		type1;
reg		type0;
reg		ext_type5;
reg		ext_type4;
reg		ext_type3;
reg		ext_type2;
reg		ext_type1;
reg		ext_type0;
wire	[1:0]	type_sel;

// type0 =  Non Foldable
// type1 =  Local Variable
// type2 =  Operation
// type3 =  Break Group2
// type4 =  Break Group1
// type5 =  Memory Store

always @(opcode) begin

	{type0,type1,type2,type3,type4,type5} = 6'b000000;

	case (opcode[15:8])

		8'd0:	type0 = 1'b1;	// nop
		8'd1:	type1 = 1'b1;	// aconst_null
		8'd2:	type1 = 1'b1;	// iconst_m1
		8'd3:	type1 = 1'b1;	// iconst_0
		8'd4:	type1 = 1'b1;	// iconst_1
		8'd5:	type1 = 1'b1;	// iconst_2
		8'd6:	type1 = 1'b1;	// iconst_3
		8'd7:	type1 = 1'b1;	// iconst_4
		8'd8:	type1 = 1'b1;	// iconst_5
		8'd9:	type0 = 1'b1;	// lconst_0
		8'd10:	type0 = 1'b1;	// lconst_1
		8'd11:	type1 = 1'b1;	// fconst_0
		8'd12:	type1 = 1'b1;	// fconst_1
		8'd13:	type1 = 1'b1;	// fconst_2
		8'd14:	type0 = 1'b1;	// dconst_0
		8'd15:	type0 = 1'b1;	// dconst_1
		8'd16:	type1 = 1'b1;	// bipush
		8'd17:	type1 = 1'b1;	// sipush
		8'd18:	type0 = 1'b1;	// ldc
		8'd19:	type0 = 1'b1;	// ldc_w
		8'd20:	type0 = 1'b1;	// ldc2_w
		8'd21:	type1 = 1'b1;	// iload
		8'd22:	type0 = 1'b1;	// lload
		8'd23:	type1 = 1'b1;	// fload
		8'd24:	type0 = 1'b1;	// dload
		8'd25:	type1 = 1'b1;	// aload
		8'd26:	type1 = 1'b1;	// iload_0
		8'd27:	type1 = 1'b1;	// iload_1
		8'd28:	type1 = 1'b1;	// iload_2
		8'd29:	type1 = 1'b1;	// iload_3
		8'd30:	type0 = 1'b1;	// lload_0
		8'd31:	type0 = 1'b1;	// lload_1
		8'd32:	type0 = 1'b1;	// lload_2
		8'd33:	type0 = 1'b1;	// lload_3
		8'd34:	type1 = 1'b1;	// fload_0
		8'd35:	type1 = 1'b1;	// fload_1
		8'd36:	type1 = 1'b1;	// fload_2
		8'd37:	type1 = 1'b1;	// fload_3
		8'd38:	type0 = 1'b1;	// dload_0
		8'd39:	type0 = 1'b1;	// dload_1
		8'd40:	type0 = 1'b1;	// dload_2
		8'd41:	type0 = 1'b1;	// dload_3
		8'd42:	type1 = 1'b1;	// aload_0
		8'd43:	type1 = 1'b1;	// aload_1
		8'd44:	type1 = 1'b1;	// aload_2
		8'd45:	type1 = 1'b1;	// aload_3
		8'd46:	type3 = 1'b1;	// iaload 
		8'd47:	type3 = 1'b1;	// laload
		8'd48:	type3 = 1'b1;	// faload
		8'd49:	type3 = 1'b1;	// daload
		8'd50:	type3 = 1'b1;	// aaload
		8'd51:	type3 = 1'b1;	// baload
		8'd52:	type3 = 1'b1;	// caload
		8'd53:	type3 = 1'b1;	// saload
		8'd54:	type5 = 1'b1;	// istore
		8'd55:	type0 = 1'b1;	// lstore
		8'd56:	type5 = 1'b1;	// fstore
		8'd57:	type0 = 1'b1;	// dstore
		8'd58:	type5 = 1'b1;	// astore
		8'd59:	type5 = 1'b1;	// istore_0
		8'd60:	type5 = 1'b1;	// istore_1
		8'd61:	type5 = 1'b1;	// istore_2
		8'd62:	type5 = 1'b1;	// istore_3
		8'd63:	type0 = 1'b1;	// lstore_0
		8'd64:	type0 = 1'b1;	// lstore_1
		8'd65:	type0 = 1'b1;	// lstore_2
		8'd66:	type0 = 1'b1;	// lstore_3
		8'd67:	type5 = 1'b1;	// fstore_0
		8'd68:	type5 = 1'b1;	// fstore_1
		8'd69:	type5 = 1'b1;	// fstore_2
		8'd70:	type5 = 1'b1;	// fstore_3
		8'd71:	type0 = 1'b1;	// dstore_0
		8'd72:	type0 = 1'b1;	// dstore_1
		8'd73:	type0 = 1'b1;	// dstore_2
		8'd74:	type0 = 1'b1;	// dstore_3
		8'd75:	type5 = 1'b1;	// astore_0
		8'd76:	type5 = 1'b1;	// astore_1
		8'd77:	type5 = 1'b1;	// astore_2
		8'd78:	type5 = 1'b1;	// astore_3
		8'd79:	type3 = 1'b1;	// iastore
		8'd80:	type3 = 1'b1;	// lastore
		8'd81:	type3 = 1'b1;	// fastore
		8'd82:	type3 = 1'b1;	// dastore
		8'd83:	type0 = 1'b1;	// aastore
		8'd84:	type3 = 1'b1;	// bastore
		8'd85:	type3 = 1'b1;	// castore
		8'd86:	type3 = 1'b1;	// sastore
		8'd87:	type0 = 1'b1;	// pop
		8'd88:	type0 = 1'b1;	// pop2
		8'd89:	type0 = 1'b1;	// dup
		8'd90:	type3 = 1'b1;	// dup_x1
		8'd91:	type3 = 1'b1;	// dup_x2
		8'd92:	type0 = 1'b1;	// dup2
		8'd93:	type3 = 1'b1;	// dup2_x1
		8'd94:	type3 = 1'b1;	// dup2_x2
		8'd95:	type3 = 1'b1;	// swap
		8'd96:	type2 = 1'b1;	// iadd
		8'd97:	type0 = 1'b1;	// ladd
		8'd98:	type2 = 1'b1;	// fadd
		8'd99:	type0 = 1'b1;	// dadd
		8'd100:	type2 = 1'b1;	// isub
		8'd101:	type0 = 1'b1;	// lsub
		8'd102:	type2 = 1'b1;	// fsub
		8'd103:	type0 = 1'b1;	// dsub
		8'd104:	type2 = 1'b1;	// imul
		8'd105:	type0 = 1'b1;	// lmul
		8'd106:	type2 = 1'b1;	// fmul
		8'd107:	type0 = 1'b1;	// dmul
		8'd108:	type2 = 1'b1;	// idiv
		8'd109:	type0 = 1'b1;	// ldiv
		8'd110:	type2 = 1'b1;	// fdiv
		8'd111:	type0 = 1'b1;	// ddiv
		8'd112:	type2 = 1'b1;	// irem
		8'd113:	type0 = 1'b1;	// lrem
		8'd114:	type2 = 1'b1;	// frem
		8'd115:	type0 = 1'b1;	// drem
		8'd116:	type4 = 1'b1;	// ineg
		8'd117:	type0 = 1'b1;	// lneg
		8'd118:	type4 = 1'b1;	// fneg
		8'd119:	type0 = 1'b1;	// dneg
		8'd120:	type2 = 1'b1;	// ishl
		8'd121:	type0 = 1'b1;	// lshl
		8'd122:	type2 = 1'b1;	// ishr
		8'd123:	type0 = 1'b1;	// lshr
		8'd124:	type2 = 1'b1;	// iushr
		8'd125:	type0 = 1'b1;	// lushr
		8'd126:	type2 = 1'b1;	// iand
		8'd127:	type0 = 1'b1;	// land
		8'd128:	type2 = 1'b1;	// ior
		8'd129:	type0 = 1'b1;	// lor
		8'd130:	type2 = 1'b1;	// ixor
		8'd131:	type0 = 1'b1;	// lxor
		8'd132:	type0 = 1'b1;	// iinc
		8'd133:	type0 = 1'b1;	// i2l
		8'd134:	type0 = 1'b1;	// i2f
		8'd135:	type0 = 1'b1;	// i2d
		8'd136:	type0 = 1'b1;	// l2i
		8'd137:	type0 = 1'b1;	// l2f
		8'd138:	type0 = 1'b1;	// l2d
		8'd139:	type0 = 1'b1;	// f2i
		8'd140:	type0 = 1'b1;	// f2l
		8'd141:	type0 = 1'b1;	// f2d
		8'd142:	type0 = 1'b1;	// d2i
		8'd143:	type0 = 1'b1;	// d2l
		8'd144:	type0 = 1'b1;	// d2f
		8'd145:	type4 = 1'b1;	// i2b
		8'd146:	type4 = 1'b1;	// i2c
		8'd147:	type4 = 1'b1;	// i2s
		8'd148:	type0 = 1'b1;	// lcmp
		8'd149:	type2 = 1'b1;	// fcmpl
		8'd150:	type2 = 1'b1;	// fcmpg
		8'd151:	type0 = 1'b1;	// dcmpl
		8'd152:	type0 = 1'b1;	// dcmpg
		8'd153:	type4 = 1'b1;	// ifeq
		8'd154:	type4 = 1'b1;	// ifne
		8'd155:	type4 = 1'b1;	// iflt
		8'd156:	type4 = 1'b1;	// ifge
		8'd157:	type4 = 1'b1;	// ifgt
		8'd158:	type4 = 1'b1;	// ifle
		8'd159:	type3 = 1'b1;	// if_icmpeq
		8'd160:	type3 = 1'b1;	// if_icmpne
		8'd161:	type3 = 1'b1;	// if_icmplt
		8'd162:	type3 = 1'b1;	// if_icmpge
		8'd163:	type3 = 1'b1;	// if_icmpgt
		8'd164:	type3 = 1'b1;	// if_icmple
		8'd165:	type3 = 1'b1;	// if_acmpeq
		8'd166:	type3 = 1'b1;	// if_acmpne
		8'd167:	type0 = 1'b1;	// goto
		8'd168:	type0 = 1'b1;	// jsr
		8'd169:	type0 = 1'b1;	// ret
		8'd170:	type0 = 1'b1;	// tableswitch
		8'd171:	type0 = 1'b1;	// lookupswitch
		8'd172:	type4 = 1'b1;	// ireturn
		8'd173:	type0 = 1'b1;	// lreturn
		8'd174:	type4 = 1'b1;	// freturn
		8'd175:	type0 = 1'b1;	// dreturn
		8'd176:	type4 = 1'b1;	// areturn
		8'd177:	type0 = 1'b1;	// return
		8'd178:	type0 = 1'b1;	// getstatic
		8'd179:	type0 = 1'b1;	// putstatic
		8'd180:	type0 = 1'b1;	// getfield
		8'd181:	type0 = 1'b1;	// putfield
		8'd182:	type0 = 1'b1;	// invokevirtual
		8'd183:	type0 = 1'b1;	// invokespecial
		8'd184:	type0 = 1'b1;	// invokestatic
		8'd185:	type0 = 1'b1;	// invokeinterface
		8'd186:	type0 = 1'b1;	// Undefined
		8'd187:	type0 = 1'b1;	// new
		8'd188:	type0 = 1'b1;	// newarray
		8'd189:	type0 = 1'b1;	// anewarray
		8'd190:	type4 = 1'b1;	// arraylength
		8'd191:	type0 = 1'b1;	// athrow
		8'd192:	type0 = 1'b1;	// checkcast
		8'd193:	type0 = 1'b1;	// instanceof
		8'd194:	type0 = 1'b1;	// monitorenter
		8'd195:	type0 = 1'b1;	// monitorexit
		8'd196:	type0 = 1'b1;	// wide
		8'd197:	type0 = 1'b1;	// multianewarray
		8'd198:	type4 = 1'b1;	// ifnull
		8'd199:	type4 = 1'b1;	// ifnonnull
		8'd200:	type0 = 1'b1;	// goto_w
		8'd201:	type0 = 1'b1;	// jsr_w
		8'd202:	type0 = 1'b1;	// breakpoint
		8'd203:	type0 = 1'b1;	// ldc_quick
		8'd204:	type0 = 1'b1;	// ldc_w_quick
		8'd205:	type0 = 1'b1;	// ldc2_w_quick
		8'd206:	type4 = 1'b1;	// getfield_quick
		8'd207:	type3 = 1'b1;	// putfield_quick
		8'd208:	type4 = 1'b1;	// getfield2_quick
		8'd209:	type0 = 1'b1;	// putfield2_quick
		8'd210:	type0 = 1'b1;	// getstatic_quick
		8'd211:	type4 = 1'b1;	// putstatic_quick
		8'd212:	type0 = 1'b1;	// getstatic2_quick
		8'd213:	type0 = 1'b1;	// putstatic2_quick
		8'd214:	type0 = 1'b1;	// invokevirtual_quick
		8'd215:	type0 = 1'b1;	// invokenonvirtual_quick
		8'd216:	type0 = 1'b1;	// invokesuper_quick
		8'd217:	type0 = 1'b1;	// invokestatic_quick
		8'd218:	type0 = 1'b1;	// invokeinterface_quick
		8'd219:	type0 = 1'b1;	// invokevirtualobject_quick
		8'd220:	type3 = 1'b1;	// aastore_quick
		8'd221:	type0 = 1'b1;	// new_quick
		8'd222:	type0 = 1'b1;	// anewarray_quick
		8'd223:	type0 = 1'b1;	// multianewarray_quick
		8'd224:	type0 = 1'b1;	// checkcast_quick
		8'd225:	type0 = 1'b1;	// instanceof_quick
		8'd226:	type0 = 1'b1;	// invokevirtual_quick_w
		8'd227:	type0 = 1'b1;	// getfield_quick_w
		8'd228:	type0 = 1'b1;	// putfield_quick_w
		8'd229:	type4 = 1'b1;	// nonnull_quick
		8'd230:	type4 = 1'b1;	// agetfield_quick
		8'd231:	type3 = 1'b1;	// aputfield_quick
		8'd232:	type0 = 1'b1;	// agetstatic_quick
		8'd233:	type4 = 1'b1;	// aputstatic_quick
		8'd234:	type0 = 1'b1;	// aldc_quick
		8'd235:	type0 = 1'b1;	// aldc_w_quick
		8'd236:	type0 = 1'b1;	// exit_sync_method
		8'd237:	type4 = 1'b1;	// sethi
		8'd238:	type0 = 1'b1;	// load_word_index
		8'd239:	type0 = 1'b1;	// load_short_index
		8'd240:	type0 = 1'b1;	// load_char_index
		8'd241:	type0 = 1'b1;	// load_byte_index
		8'd242:	type0 = 1'b1;	// load_ubyte_index
		8'd243:	type0 = 1'b1;	// store_word_index
		8'd244:	type0 = 1'b1;	// nastore_word_index
		8'd245:	type0 = 1'b1;	// store_hort_index
		8'd246:	type0 = 1'b1;	// store_byte_index

		default: {type5,type4,type3,type2,type1,type0} = 6'b000001;
		
	endcase

end

always @(opcode) begin

	{ext_type5,ext_type4,ext_type3,ext_type2,ext_type1,ext_type0} = 6'b000000;

	case (opcode[7:0])

		8'd0:	ext_type4 = 1'b1;	// load_ubyte
		8'd1:	ext_type4 = 1'b1;	// load_byte
		8'd2:	ext_type4 = 1'b1;	// load_char
		8'd3:	ext_type4 = 1'b1;	// load_short
		8'd4:	ext_type4 = 1'b1;	// load_word
		8'd5:	ext_type0 = 1'b1;	// priv_ret_from_trap
		8'd6:	ext_type0 = 1'b1;	// priv_read_dcache_tag
		8'd7:	ext_type0 = 1'b1;	// priv_read_dcache_data
		8'd10:	ext_type4 = 1'b1;	// load_char_oe
		8'd11:	ext_type4 = 1'b1;	// load_short_oe
		8'd12:	ext_type4 = 1'b1;	// load_word_oe
		8'd13:	ext_type3 = 1'b1;	// return0
		8'd14:	ext_type0 = 1'b1;	// priv_read_icache_tag
		8'd15:	ext_type0 = 1'b1;	// priv_read_icache_data
		8'd16:	ext_type4 = 1'b1;	// ncload_ubyte
		8'd17:	ext_type4 = 1'b1;	// ncload_byte
		8'd18:	ext_type4 = 1'b1;	// ncload_char
		8'd19:	ext_type4 = 1'b1;	// ncload_short
		8'd20:	ext_type4 = 1'b1;	// ncload_word
		8'd21:	ext_type2 = 1'b1;	// iucmp
		8'd22:	ext_type0 = 1'b1;	// priv_powerdown
		8'd23:	ext_type4 = 1'b1;	// cache_invalidate
		8'd26:	ext_type4 = 1'b1;	// ncload_char_oe
		8'd27:	ext_type4 = 1'b1;	// ncload_short_oe
		8'd28:	ext_type4 = 1'b1;	// ncload_word_oe
		8'd29:	ext_type3 = 1'b1;	// return1
		8'd30:	ext_type4 = 1'b1;	// cache_flush
		8'd31:	ext_type4 = 1'b1;	// cache_index_flush
		8'd32:	ext_type3 = 1'b1;	// store_byte
		8'd34:	ext_type3 = 1'b1;	// store_short
		8'd36:	ext_type3 = 1'b1;	// store_word
		8'd37:	ext_type0 = 1'b1;	// soft_trap
		8'd38:	ext_type0 = 1'b1;	// priv_write_dcache_tag
		8'd39:	ext_type0 = 1'b1;	// priv_write_dcache_data
		8'd42:	ext_type3 = 1'b1;	// store_short_oe
		8'd44:	ext_type3 = 1'b1;	// store_word_oe
		8'd45:	ext_type3 = 1'b1;	// return2
		8'd46:	ext_type0 = 1'b1;	// priv_write_icache_tag
		8'd47:	ext_type0 = 1'b1;	// priv_write_icache_data
		8'd48:	ext_type3 = 1'b1;	// ncstore_byte
		8'd50:	ext_type3 = 1'b1;	// ncstore_short
		8'd52:	ext_type3 = 1'b1;	// ncstore_word
		8'd53:	ext_type0 = 1'b1;	// Undefined
		8'd54:	ext_type0 = 1'b1;	// priv_reset
		8'd55:	ext_type0 = 1'b1;	// get_current_class
		8'd58:	ext_type3 = 1'b1;	// ncstore_short_oe
		8'd60:	ext_type3 = 1'b1;	// ncstore_word_oe
		8'd61:	ext_type3 = 1'b1;	// call
		8'd62:	ext_type4 = 1'b1;	// zero_line
		8'd63:	ext_type0 = 1'b1;	// priv_update_optop
		8'd64:	ext_type0 = 1'b1;	// read_pc
		8'd65:	ext_type0 = 1'b1;	// read_vars
		8'd66:	ext_type0 = 1'b1;	// read_frame
		8'd67:	ext_type0 = 1'b1;	// read_optop
		8'd68:	ext_type0 = 1'b1;	// priv_read_oplim
		8'd69:	ext_type0 = 1'b1;	// read_const_pool
		8'd70:	ext_type0 = 1'b1;	// priv_read_psr
		8'd71:	ext_type0 = 1'b1;	// priv_read_trapbase
		8'd72:	ext_type0 = 1'b1;	// priv_read_lockcount0
		8'd73:	ext_type0 = 1'b1;	// priv_read_lockcount1
		8'd76:	ext_type0 = 1'b1;	// priv_read_lockaddr0
		8'd77:	ext_type0 = 1'b1;	// priv_read_lockaddr1
		8'd80:	ext_type0 = 1'b1;	// priv_read_userrange1
		8'd81:	ext_type0 = 1'b1;	// priv_read_gc_config
		8'd82:	ext_type0 = 1'b1;	// priv_read_brk1a
		8'd83:	ext_type0 = 1'b1;	// priv_read_brk2a
		8'd84:	ext_type0 = 1'b1;	// priv_read_brk12c
		8'd85:	ext_type0 = 1'b1;	// priv_read_userrange2
		8'd87:	ext_type0 = 1'b1;	// priv_read_versionid
		8'd88:	ext_type0 = 1'b1;	// priv_read_hcr
		8'd89:	ext_type0 = 1'b1;	// priv_read_sc_bottom
		8'd90:	ext_type1 = 1'b1;	// read_global0
		8'd91:	ext_type1 = 1'b1;	// read_global1
		8'd92:	ext_type1 = 1'b1;	// read_global2
		8'd93:	ext_type1 = 1'b1;	// read_global3
		8'd96:	ext_type0 = 1'b1;	// write_pc,ret_from_sub
		8'd97:	ext_type0 = 1'b1;	// write_vars
		8'd98:	ext_type0 = 1'b1;	// write_frame
		8'd99:	ext_type0 = 1'b1;	// write_optop
		8'd100:	ext_type0 = 1'b1;	// priv_write_oplim
		8'd101:	ext_type0 = 1'b1;	// write_const_pool
		8'd102:	ext_type0 = 1'b1;	// priv_write_psr
		8'd103:	ext_type0 = 1'b1;	// priv_write_trapbase
		8'd104:	ext_type0 = 1'b1;	// priv_write_lockcount0
		8'd105:	ext_type0 = 1'b1;	// priv_write_lockcount1
		8'd108:	ext_type0 = 1'b1;	// priv_write_lockaddr0
		8'd109:	ext_type0 = 1'b1;	// priv_write_lockaddr1
		8'd112:	ext_type0 = 1'b1;	// priv_write_userrange1
		8'd113:	ext_type0 = 1'b1;	// priv_write_gc_config
		8'd114:	ext_type0 = 1'b1;	// priv_write_brk1a
		8'd115:	ext_type0 = 1'b1;	// priv_write_brk1a
		8'd116:	ext_type0 = 1'b1;	// priv_write_brk12c
		8'd117:	ext_type0 = 1'b1;	// priv_write_userrange2
		8'd121:	ext_type0 = 1'b1;	// priv_write_sc_bottom
		8'd122:	ext_type5 = 1'b1;	// write_global0
		8'd123:	ext_type5 = 1'b1;	// write_global1
		8'd124:	ext_type5 = 1'b1;	// write_global2
		8'd125:	ext_type5 = 1'b1;	// write_global3
		default: {ext_type5,ext_type4,ext_type3,ext_type2,ext_type1,
					ext_type0} = 6'b000001;

	endcase
end

assign	type_sel[1] = &(opcode[15:8]); // if this is an extended opcode
assign 	type_sel[0] = !(type_sel[1]);

mux2_6	mux_type (.out(type),
		.in0 ({type5,type4,type3,type2,type1,type0}),
		.in1 ({ext_type5,ext_type4,ext_type3,ext_type2,ext_type1,ext_type0}),
		.sel(type_sel) );
endmodule
