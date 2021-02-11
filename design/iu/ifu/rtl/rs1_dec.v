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
module rs1_dec (

	opcode,
	valid,
	valid_rs1,
	offset_sel_rs1,
	mem_op,
	help_rs1,
	type,
	lv_rs1,
	lvars_acc_rs1,
	reverse_ops,
	st_index_op,
	update_optop
);

input	[15:0]	opcode;
input	[2:0]	valid;
output		valid_rs1;
output	[4:0]	offset_sel_rs1;	// used to select offsets 0..3 and byte while acce-
				// sing stack cache
output		mem_op;		// indicates that there's a mem op and long store
				// op in rs1; used to determine valid for rsd
output		help_rs1;	// indicates that there's a  multi-rstage operation in rs1

output  [7:0]	type;		// indicates whether the long op in rs1 is either
				// type[0] = long or double load
				// type[1] = long or double store
				// type[2] = long add, and, sub, or, xor or neg operation	
				// type[3] = double add, sub, rem, mul, div or compare operation	
				// type[4] = long shift left operation
				// type[5] = long shift right operation
				// type[6] = priv write operations
				// type[7] = long compares

output		lv_rs1;		// indicates that theres a pure lv operation in rs1
				// Useful to determine whether to access tos or
				// next tos in rs2 
output		lvars_acc_rs1;  // This signal is asserted for all operations which access
				// scache using lvars reg. in RS1
output		reverse_ops;	// Used to fix an xface pr. between  FPU and IU
output		st_index_op;	// This will be assertde whenver there are st_*_index ops
output		update_optop;	// priv update operation

	

wire		mem_rs1;
wire		read_gl0, read_gl1, read_gl2, read_gl3;
wire		write_gl0, write_gl1, write_gl2, write_gl3;
wire		write_vars,write_frame,write_optop,write_const_pool;
wire		priv_wr_psr, priv_wr_trapbase, priv_wr_lockcount0;
wire		priv_wr_lockcount1, priv_wr_lockaddr0, priv_wr_lockaddr1;
wire		priv_wr_userrange1, priv_wr_gc_config, priv_wr_brk1a;
wire		priv_wr_brk2a, priv_wr_brk12c, priv_wr_userrange2;
wire		priv_wr_sc_bottom, priv_wr_oplim;
wire		read_icache_tag,read_icache_data;

reg		aconst_null;
reg  		iconst_m1;
reg		iconst_0;
reg		iconst_1;
reg		iconst_2;
reg		iconst_3;
reg		iconst_4;
reg		iconst_5;
reg		fconst_0;
reg		fconst_1;
reg		fconst_2;
reg		iload_0;
reg		iload_1;
reg		iload_2;
reg		iload_3;
reg		fload_0;
reg		fload_1;
reg		fload_2;
reg		fload_3;
reg		aload_0;
reg		aload_1;
reg		aload_2;
reg		aload_3;
reg		sipush;
reg		bipush;
reg		iload;
reg		fload;
reg		aload;
reg		istore;
reg		fstore;
reg		astore;
reg		istore_0;
reg		istore_1;
reg		istore_2;
reg		istore_3;
reg		fstore_0;
reg		fstore_1;
reg		fstore_2;
reg		fstore_3;
reg		astore_0;
reg		astore_1;
reg		astore_2;
reg		astore_3;
reg		i2f;
reg		f2i;
reg 		i2d;
reg 		f2l;
reg		lload;
reg		dload;
reg		lload_0;
reg		lload_1;
reg		lload_2;
reg		lload_3;
reg		dload_0;
reg		dload_1;
reg		dload_2;
reg		dload_3;
reg		lstore;
reg		dstore;
reg		lstore_0;
reg		lstore_1;
reg		lstore_2;
reg		lstore_3;
reg		dstore_0;
reg		dstore_1;
reg		dstore_2;
reg		dstore_3;
reg		ladd;
reg		dadd;
reg		lsub;
reg		dsub;
reg		dmul;
reg		ddiv;
reg		drem;
reg		lneg;
reg		lshl;
reg		lshr;
reg		lushr;
reg		land;
reg		lor;
reg		lxor;
reg		f2d;
reg		l2f;
reg		l2d;
reg		d2i;
reg		d2l;
reg		d2f;
reg		lcmp;
reg		dcmpl;
reg		dcmpg;
reg		lconst_0;
reg	 	lconst_1;
reg	 	dconst_0;
reg		dconst_1;
reg		iinc;
reg		ret;
reg		ld_wd_index;
reg		ld_sh_index;
reg		ld_ch_index;
reg		ld_by_index;
reg		ld_ub_index;
reg		st_wd_index;
reg		nast_wd_index;
reg		st_sh_index;
reg		st_by_index;
reg		ext_byte_code;
reg		undefined_opcode;

always @ (opcode or valid) begin

	aconst_null	= 1'b0;
	iconst_m1	= 1'b0;
	iconst_0	= 1'b0;
	iconst_1	= 1'b0;
	iconst_2	= 1'b0;
	iconst_3	= 1'b0;
	iconst_4	= 1'b0;
	iconst_5	= 1'b0;
	fconst_0	= 1'b0;
	fconst_1	= 1'b0;
	fconst_2	= 1'b0;
	iload_0		= 1'b0;
	iload_1		= 1'b0;
	iload_2		= 1'b0;
	iload_3		= 1'b0;
	fload_0		= 1'b0;
	fload_1		= 1'b0;
	fload_2		= 1'b0;
	fload_3		= 1'b0;
	aload_0		= 1'b0;
	aload_1		= 1'b0;
	aload_2		= 1'b0;
	aload_3		= 1'b0;
	sipush		= 1'b0;
	bipush		= 1'b0;
	iload		= 1'b0;
	fload		= 1'b0;
	aload		= 1'b0;
	istore		= 1'b0;
	fstore		= 1'b0;
	astore		= 1'b0;
	istore_0	= 1'b0;
	istore_1	= 1'b0;
	istore_2	= 1'b0;
	istore_3	= 1'b0;
	fstore_0	= 1'b0;
	fstore_1	= 1'b0;
	fstore_2	= 1'b0;
	fstore_3	= 1'b0;
	astore_0	= 1'b0;
	astore_1	= 1'b0;
	astore_2	= 1'b0;
	astore_3	= 1'b0;
	f2l		= 1'b0;
	i2f		= 1'b0;
	f2i		= 1'b0;
	i2d		= 1'b0;
	lload		= 1'b0;
	dload		= 1'b0;
	lload_0		= 1'b0;
	lload_1		= 1'b0;
	lload_2		= 1'b0;
	lload_3		= 1'b0;
	dload_0		= 1'b0;
	dload_1		= 1'b0;
	dload_2		= 1'b0;
	dload_3		= 1'b0;
	lstore		= 1'b0;
	dstore		= 1'b0;
	lstore_0	= 1'b0;
	lstore_1	= 1'b0;
	lstore_2	= 1'b0;
	lstore_3	= 1'b0;
	dstore_0	= 1'b0;
	dstore_1	= 1'b0;
	dstore_2	= 1'b0;
	dstore_3	= 1'b0;
	ladd		= 1'b0;
	dadd		= 1'b0;
	lsub		= 1'b0;
	dsub		= 1'b0;
	dmul		= 1'b0;
	ddiv		= 1'b0;
	drem		= 1'b0;
	lneg		= 1'b0;
	lshl		= 1'b0;
	lshr		= 1'b0;
	lushr		= 1'b0;
	land		= 1'b0;
	lor		= 1'b0;
	lxor		= 1'b0;
	f2d		= 1'b0;
	l2f		= 1'b0;
	l2d		= 1'b0;
	d2i		= 1'b0;
	d2l		= 1'b0;
	d2f		= 1'b0;
	lcmp		= 1'b0;
	dcmpl		= 1'b0;
	dcmpg		= 1'b0;
	lconst_0	= 1'b0;
 	lconst_1	= 1'b0;
 	dconst_0	= 1'b0;
	dconst_1	= 1'b0;
	iinc		= 1'b0;
	ret		= 1'b0;
	ld_wd_index	= 1'b0;
	ld_sh_index	= 1'b0;
	ld_ch_index	= 1'b0;
	ld_by_index	= 1'b0;
	ld_ub_index	= 1'b0;
	st_wd_index	= 1'b0;
	nast_wd_index	= 1'b0;
	st_sh_index	= 1'b0;
	st_by_index	= 1'b0;
	ext_byte_code	= 1'b0;
	undefined_opcode= 1'b0;

	case(opcode[15:8])

	
		8'd1:	aconst_null = valid[0];	// aconst_null
		8'd2:  	iconst_m1 = valid[0];	// iconst_m1
		8'd3:	iconst_0 = valid[0];	// iconst_0
		8'd4:	iconst_1 = valid[0];	// iconst_1
		8'd5:	iconst_2 = valid[0];	// iconst_2
		8'd6:	iconst_3 = valid[0];	// iconst_3
		8'd7:	iconst_4 = valid[0];	// iconst_4
		8'd8:	iconst_5 = valid[0];	// iconst_5
		8'd11:	fconst_0 = valid[0];	// fconst_0
		8'd12:	fconst_1 = valid[0];	// fconst_1
		8'd13:	fconst_2 = valid[0];	// fconst_2
		8'd26:	iload_0 = valid[0];	// iload_0
		8'd27:	iload_1 = valid[0];	// iload_1
		8'd28:	iload_2 = valid[0];	// iload_2
		8'd29:	iload_3 = valid[0];	// iload_3
		8'd34:	fload_0 = valid[0];	// fload_0
		8'd35:	fload_1 = valid[0];	// fload_1
		8'd36:	fload_2 = valid[0];	// fload_2
		8'd37:	fload_3 = valid[0];	// fload_3	
		8'd42:	aload_0 = valid[0];	// aload_0
		8'd43:	aload_1 = valid[0];	// aload_1
		8'd44:	aload_2 = valid[0];	// aload_2
		8'd45:	aload_3 = valid[0];	// aload_3
		8'd17:	sipush = &(valid[2:0]);	// sipush
		8'd16:	bipush = &(valid[1:0]);	// bipush
		8'd21:	iload = &(valid[1:0]);	// iload
		8'd23:	fload = &(valid[1:0]);	// fload
		8'd25:	aload = &(valid[1:0]);	// aload
		
		8'd54:	istore = &(valid[1:0]);	// istore
		8'd56:	fstore = &(valid[1:0]);	// fstore
		8'd58:	astore = &(valid[1:0]);	// astore
		8'd59:	istore_0 = valid[0];	// istore_0
		8'd60:	istore_1 = valid[0];	// istore_1
		8'd61:	istore_2 = valid[0];	// istore_2
		8'd62:	istore_3 = valid[0];	// istore_3
		8'd67:	fstore_0 = valid[0];	// fstore_0
		8'd68:	fstore_1 = valid[0];	// fstore_1
		8'd69:	fstore_2 = valid[0];	// fstore_2
		8'd70:	fstore_3 = valid[0];	// fstore_3
		8'd75:	astore_0 = valid[0];	// astore_0
		8'd76:	astore_1 = valid[0];	// astore_1
		8'd77:	astore_2 = valid[0];	// astore_2
		8'd78:  astore_3 = valid[0];	// astore_3

		// decoding for long loads
	
		8'd22:	lload = &(valid[1:0]);	// lload
		8'd24:	dload = &(valid[1:0]);	// dload
		8'd30:	lload_0 = valid[0];	// lload_0
		8'd31:	lload_1 = valid[0];	// lload_1
		8'd32:	lload_2 = valid[0];	// lload_2
		8'd33:	lload_3 = valid[0];	// lload_3
		8'd38:	dload_0 = valid[0];	// dload_0
		8'd39:	dload_1 = valid[0];	// dload_1
		8'd40:	dload_2 = valid[0];	// dload_2
		8'd41:	dload_3 = valid[0];	// dload_3

		// decoding for long stores

		8'd55:	lstore = &(valid[1:0]);	// lstore
		8'd57:	dstore = &(valid[1:0]);	// dstore
		8'd63:	lstore_0 = valid[0];	// lstore_0
		8'd64:	lstore_1 = valid[0];	// lstore_1
		8'd65:	lstore_2 = valid[0];	// lstore_2
		8'd66:	lstore_3 = valid[0];	// lstore_3
		8'd71:	dstore_0 = valid[0];	// dstore_0
		8'd72:	dstore_1 = valid[0];	// dstore_1
		8'd73:	dstore_2 = valid[0];	// dstore_2
		8'd74:	dstore_3 = valid[0];	// dstore_3

		// decoding for long ops

		8'd97:	ladd = valid[0];	// ladd
		8'd99:	dadd = valid[0];	// dadd
		8'd101:	lsub = valid[0];	// lsub
		8'd103:	dsub = valid[0];	// dsub
		8'd107:	dmul = valid[0];	// dmul
		8'd111:	ddiv = valid[0];	// ddiv
		8'd115:	drem = valid[0];	// drem
		8'd117:	lneg = valid[0];	// lneg
		8'd121:	lshl = valid[0];	// lshl
		8'd123:	lshr = valid[0];	// lshr
		8'd125:	lushr = valid[0];	// lushr
		8'd127:	land = valid[0];	// land
		8'd129:	lor = valid[0];		// lor
		8'd131:	lxor = valid[0];	// lxor
		8'd134:	i2f = valid[0];		// i2f
		8'd135:	i2d = valid[0];		// i2d
		8'd137:	l2f = valid[0];		// l2f
		8'd138:	l2d = valid[0];		// l2d
		8'd139:	f2i = valid[0];		// f2i
		8'd140:	f2l = valid[0];		// f2l
		8'd141:	f2d = valid[0];		// f2d
		8'd142:	d2i = valid[0];		// d2i
		8'd143:	d2l = valid[0];		// d2l
		8'd144:	d2f = valid[0];		// d2f
		8'd148:	lcmp = valid[0];	// lcmp
		8'd151:	dcmpl = valid[0];	// dcmpl
		8'd152:	dcmpg = valid[0];	// dcmpg

		// decoding for long constants

                8'd9:	lconst_0 = valid[0];   // lconst_0
                8'd10: 	lconst_1 = valid[0]; // lconst_1
                8'd14: 	dconst_0 = valid[0]; // dconst_0
                8'd15: 	dconst_1 = valid[0]; // dconst_1

		// decoding for misc. ops

		8'd132:	iinc = valid[0] & valid[1] & valid[2] ;
		8'd169:	ret = valid[0] & valid[1] ;
		8'd238: ld_wd_index = valid[0] & valid[1] & valid[2];
		8'd239: ld_sh_index = valid[0] & valid[1] & valid[2];
		8'd240: ld_ch_index = valid[0] & valid[1] & valid[2];
		8'd241: ld_by_index = valid[0] & valid[1] & valid[2];
		8'd242: ld_ub_index = valid[0] & valid[1] & valid[2];
		8'd243: st_wd_index = valid[0] & valid[1] & valid[2];
		8'd244: nast_wd_index = valid[0] & valid[1] & valid[2];
		8'd245: st_sh_index = valid[0] & valid[1] & valid[2];
		8'd246: st_by_index = valid[0] & valid[1] & valid[2];

		8'd255: ext_byte_code = valid[0];
		
		default: undefined_opcode = valid[0];
	endcase

end

assign	read_gl0 = ext_byte_code & (opcode[7:0] == 8'd90) & valid[1];
assign	read_gl1 = ext_byte_code & (opcode[7:0] == 8'd91) & valid[1];
assign	read_gl2 = ext_byte_code & (opcode[7:0] == 8'd92) & valid[1];
assign	read_gl3 = ext_byte_code & (opcode[7:0] == 8'd93) & valid[1];

assign	write_gl0 = ext_byte_code & (opcode[7:0] == 8'd122) & valid[1];
assign	write_gl1 = ext_byte_code & (opcode[7:0] == 8'd123) & valid[1];
assign	write_gl2 = ext_byte_code & (opcode[7:0] == 8'd124) & valid[1];
assign	write_gl3 = ext_byte_code & (opcode[7:0] == 8'd125) & valid[1];

assign	read_icache_tag 	= ext_byte_code & (opcode[7:0] == 8'd14) & valid[1];
assign	read_icache_data 	= ext_byte_code & (opcode[7:0] == 8'd15) & valid[1];

assign	update_optop 		= ext_byte_code & (opcode[7:0] == 8'd63) & valid[1];
assign	write_vars 		= ext_byte_code & (opcode[7:0] == 8'd97) & valid[1];
assign	write_frame 		= ext_byte_code & (opcode[7:0] == 8'd98) & valid[1];
assign	write_optop 		= ext_byte_code & (opcode[7:0] == 8'd99) & valid[1];
assign	priv_wr_oplim 		= ext_byte_code & (opcode[7:0] == 8'd100) & valid[1];
assign	write_const_pool 	= ext_byte_code & (opcode[7:0] == 8'd101) & valid[1];
assign	priv_wr_psr 		= ext_byte_code & (opcode[7:0] == 8'd102) & valid[1];
assign	priv_wr_trapbase 	= ext_byte_code & (opcode[7:0] == 8'd103) & valid[1];
assign	priv_wr_lockcount0 	= ext_byte_code & (opcode[7:0] == 8'd104) & valid[1];
assign	priv_wr_lockcount1 	= ext_byte_code & (opcode[7:0] == 8'd105) & valid[1];
assign	priv_wr_lockaddr0 	= ext_byte_code & (opcode[7:0] == 8'd108) & valid[1];
assign	priv_wr_lockaddr1 	= ext_byte_code & (opcode[7:0] == 8'd109) & valid[1];
assign	priv_wr_userrange1 	= ext_byte_code & (opcode[7:0] == 8'd112) & valid[1];
assign	priv_wr_gc_config 	= ext_byte_code & (opcode[7:0] == 8'd113) & valid[1];
assign	priv_wr_brk1a 		= ext_byte_code & (opcode[7:0] == 8'd114) & valid[1];
assign	priv_wr_brk2a 		= ext_byte_code & (opcode[7:0] == 8'd115) & valid[1];
assign	priv_wr_brk12c 		= ext_byte_code & (opcode[7:0] == 8'd116) & valid[1];
assign	priv_wr_userrange2 	= ext_byte_code & (opcode[7:0] == 8'd117) & valid[1];
assign	priv_wr_sc_bottom 	= ext_byte_code & (opcode[7:0] == 8'd121) & valid[1];



assign	offset_sel_rs1[1] = iload_1 |  lload_1 | fload_1 | dload_1 | aload_1;
assign	offset_sel_rs1[2] = iload_2 |  lload_2 | fload_2 | dload_2 | aload_2;
assign	offset_sel_rs1[3] = iload_3 |  lload_3 | fload_3 | dload_3 | aload_3;
assign	offset_sel_rs1[4] = bipush | sipush | iload | fload | aload | lload | dload |
			    ret | iinc | ld_wd_index | ld_sh_index | ld_ch_index | 
			    ld_by_index | ld_ub_index | st_wd_index | nast_wd_index | 
			    st_sh_index | st_by_index;
 
assign	offset_sel_rs1[0] = !(|offset_sel_rs1[4:1]);

// Long Loads
assign	type[0]	= lload_0 | lload_1 | lload_2 | lload_3 | lload | 
		  dload_0 | dload_1 | dload_2 | dload_3 | dload ;

// Long Stores
assign	type[1]	= lstore_0 | lstore_1 | lstore_2 | lstore_3 | lstore | 
		  dstore_0 | dstore_1 | dstore_2 | dstore_3 | dstore ;

// Some Long Ops, which need . 	top2 & top4 from stack in 1st cycle and
//				top1 & top3 from stack in 2nd cycle.		

assign	type[2] = ladd | lsub | land | lor | lxor | lneg ;

// Some double Ops, which need . top1 & top3 from stack in 1st cycle and
//				 top2 & top4 from stack in 2nd cycle.		

assign	type[3] = dadd | dsub | dcmpl | dcmpg | drem | dmul | ddiv ;

// Long left shift operation 

assign type[4] = lshl ;

// Long right shift operations 

assign type[5] = lshr | lushr ;

// priv write operations

assign	type[6] = write_vars | write_frame | write_optop |
		  priv_wr_oplim | priv_wr_psr | priv_wr_trapbase |
		  priv_wr_lockcount0 | priv_wr_lockcount1 | priv_wr_lockaddr0 | 
		  priv_wr_lockaddr1 | priv_wr_userrange1 | priv_wr_gc_config | 
		  priv_wr_brk1a | priv_wr_brk2a | priv_wr_brk12c | 
		  priv_wr_userrange2 | priv_wr_sc_bottom | write_const_pool |
		  update_optop;

// lcmp

assign	type[7] = lcmp ;

// Local Var in RS1

assign	lv_rs1 = aconst_null | iconst_m1 | iconst_0 | iconst_1 | iconst_2 |
		 iconst_3 | iconst_4 | iconst_5 | fconst_0 | fconst_1 |
		 fconst_2 | iload_0 | iload_1 | iload_2 | iload_3 |  fload_0 |
		 fload_1 | fload_2 | fload_3 | aload_0 | aload_1 | aload_2 |
		 aload_3 | sipush | bipush | iload | fload | aload |
		 read_gl0 | read_gl1 | read_gl2 | read_gl3 ;


// Mem operation in RS1

assign	mem_rs1 = istore_0 | istore_1 | istore_2 | istore_3 | istore |
		  fstore_0 | fstore_1 | fstore_2 | fstore_3 | fstore |
		  astore_0 | astore_1 | astore_2 | astore_3 | astore |
		  write_gl0 | write_gl1 | write_gl2 | write_gl3 ;

// For iinc also we need to write scache just like we do for istores
assign	mem_op = mem_rs1 | type[1] | iinc;


// Valid bit for rs1 -> LVs + long consts + long loads 

assign	valid_rs1 = lv_rs1 | lconst_0 | lconst_1 | dconst_0 | dconst_1 |
		    type[0];

// multi-rstage operation in rs1

assign help_rs1 = |(type[7:0]) | lconst_0 | lconst_1 | dconst_0 | dconst_1 |
			         f2d | i2d | f2l | d2l | l2d | 
				 read_icache_data | read_icache_tag ;

// For all the operations which access scache using lvars, assert this signal

assign	lvars_acc_rs1 = iload_0 | iload_1 | iload_2 | iload_3 |
			fload_0 | fload_1 | fload_2 | fload_3 |
			aload_0 | aload_1 | aload_2 | aload_3 |
			iload	| fload	  | aload   | iinc    | 
			dload_0 | dload_1 | dload_2 | dload_3 |
			lload_0 | lload_1 | lload_2 | lload_3 |
			ret | ld_wd_index | ld_sh_index | 
			ld_ch_index | ld_by_index | ld_ub_index |
			st_wd_index | nast_wd_index | st_sh_index |
			st_by_index | lload | dload;

assign	st_index_op = (st_wd_index | nast_wd_index | 
			st_sh_index | st_by_index);
	
// For the following operations we need to reverse rs1 and rs1 due
// to some xface problesm between IU and FPU

assign 	reverse_ops = (i2f | i2d | l2f | l2d | f2i | 
			f2l | f2d | d2i | d2l | d2f);


endmodule
