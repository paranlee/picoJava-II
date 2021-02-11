.compile_all cpp -B -C -P -I$PICOJAVAHOME/picoJava-II/sim/include
.compile_all m4
divert(-1)dnl
changecom(//)dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	IPush16()
//-
//- Parameter:
//-	$1	- The unsigned 16-bit number to be pushed onto the top of stack
//-		  Only the lower 16 bits are examined, and it's unsigned.
//-	$2	- If specified, bit 15 is not checked.	This is mainly a speed-
//-		  up for IPush() macro.
//-
//- Description:
//-	This macro pushes a 16-bit number onto the stack, using different
//-	instruction sequences depending on the value.  Because sipush does
//-	sign extension, so when bit 15 is 1, we have to shift the lower 16 bits
//-	by 1 to avoid the sign big, then get bit 0 back.
//-
//- Examples:
//-	IPush16(0x00);
//-	IPush16(32768);
//-	IPush16(0xffff);
//-
//------------------------------------------------------------------------------
define(`IPush16', `
	ifelse(eval($1 & 0xffff), 0, iconst_0,
	eval($1 & 0xffff), 1, iconst_1,
	eval($1 & 0xffff), 2, iconst_2,
	eval($1 & 0xffff), 3, iconst_3,
	eval($1 & 0xffff), 4, iconst_4,
	eval($1 & 0xffff), 5, iconst_5,
	eval($1 & 0xff80), 0, `bipush `0x'eval($1 & 0xff, 16)',
	eval($1 & 0x8000), 0, `sipush `0x'eval($1 & 0xffff, 16)',
	ifelse($#, 1, `sipush `0x'eval(($1 & 0xffff) >> 1, 16);
	iconst_1;
	ifelse(eval($1 & 1), 0, ishl,
	`ishl;
	iconst_1;
	ior')',
	`
	sipush	`0x'eval($1 & 0xffff, 16)'));
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	IPush_Old()
//-
//- Parameter:
//-	$1	- The unsigned 32-bit number to be pushed onto the top of stack
//-
//- Description:
//-	This macro pushes the 32-bit number onto the stack, using different
//-	instruction sequences depending on the value.  Because sipush does
//-	sign extension, so when bit 15 is 1, we have to shift the lower 16 bits
//-	by 1 to avoid the sign big, then get bit 0 back.
//-
//------------------------------------------------------------------------------
define(`IPush_Old', `
	ifelse(eval($1), -1, iconst_m1;,
	eval($1 & 0xffff0000), 0, `IPush16($1)',
	eval(($1 >> 4) & 0xffffff8,16), ffffff8, `bipush `0x'eval($1&0xff,16);',
	eval(($1 >> 4) & 0xffffff8,16), FFFFFF8, `bipush `0x'eval($1&0xff,16);',
	eval(($1 >> 12) & 0xffff8,16), ffff8, `sipush `0x'eval($1&0xffff, 16);',
	eval(($1 >> 12) & 0xffff8,16), FFFF8, `sipush `0x'eval($1&0xffff, 16);',
	`IPush16(`0x'eval(($1 >> 16) & 0xffff, 16), 1)
	bipush	16;
	ifelse(eval($1 & 0xffff), 0, ishl,
	`ishl;
	IPush16(`0x'eval($1 & 0xffff, 16))
	ior');') ')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	IPush()
//-
//- Parameter:
//-	$1	- The unsigned 32-bit number to be pushed onto the top of stack
//-
//- Description:
//-	This macro pushes the 32-bit number onto the stack, using different
//-	instruction sequences depending on the value.  Because sipush does
//-	sign extension, so when bit 15 is 1, we have to shift the lower 16 bits
//-	by 1 to avoid the sign big, then get bit 0 back.
//-
//------------------------------------------------------------------------------
define(`IPush', `
	ifelse(eval($1), -1, iconst_m1;,
	eval($1 & 0xffff0000), 0, `IPush16($1)',
	eval(($1 >> 4) & 0xffffff8,16), ffffff8, `bipush `0x'eval($1&0xff,16);',
	eval(($1 >> 4) & 0xffffff8,16), FFFFFF8, `bipush `0x'eval($1&0xff,16);',
	eval(($1 >> 12) & 0xffff8,16), ffff8, `sipush `0x'eval($1&0xffff, 16);',
	eval(($1 >> 12) & 0xffff8,16), FFFF8, `sipush `0x'eval($1&0xffff, 16);',
	`IPush16(`0x'eval($1 & 0xffff, 16), 1)
	sethi	`0x'eval(($1 >> 16) & 0xffff, 16);')
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	LPush32()
//-
//- Parameter:
//-	$1	- The lower 32 bits of the long value
//-
//- Description:
//-	This macro creates a long value on the top of the stack with the higher
//-	32 bits zero.  It takes care of the sign extension of i2l, and even
//-	tries to optimize the instruction sequence when the pattern is simple.
//-
//------------------------------------------------------------------------------
define(`LPush32', `
	ifelse(eval($1), 0, lconst_0,
	eval($1), 1, lconst_1,
	eval(($1 >> 31) & 1), 0,
	`IPush($1)
	i2l',
	`IPush(`0x'eval(($1 >> 1) & 0x7fffffff, 16))
	i2l;
	iconst_1;
	ifelse(eval($1 & 1), 0, lshl,
	`lshl;
	lconst_1;
	lor')');
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	LPush()
//-
//- Parameter:
//-	$1	- The higher 32 bits of the long value
//-	$2	- The lower 32 bits of the long value
//-
//- Description:
//-	Pushes any long value onto the stack.  Certain optimizations are done
//-	when the first word is 0 or -1.	 This macro is type safe.
//-
//------------------------------------------------------------------------------
define(`LPush', `
	ifelse(eval($1), 0, `LPush32($2)',
	eval($1), -1,
	ifelse(eval(($2 >> 31) & 1), 1,
	`IPush($2)
	i2l',
	`IPush($1)
	i2l;
	bipush	32;
	ifelse(eval($2), 0, lshl,
	`lshl;
	LPush32($2)
	lor')');,
	`IPush($1)
	i2l;
	bipush	32;
	ifelse(eval($2), 0, lshl,
	`lshl;
	LPush32($2)
	lor');')
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	FPush()
//-
//- Parameter:
//-	$1	- The unsigned 32-bit number to be pushed onto the top of stack
//-
//- Description:
//-	This macro uses IPush to push the value onto the stack, so it's not
//-	type safe.
//-
//------------------------------------------------------------------------------
define(`FPush', `
	ifelse($1, 0, fconst_0;,
	$1, 1, fconst_1;,
	$1, 2, fconst_2;,
	IPush($1))
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	DPush()
//-
//- Parameter:
//-	$1	- The higher 32 bits of the double value
//-	$2	- The lower 32 bits of the double value
//-
//- Description:
//-	This macro uses IPush to push the value onto the stack, so it's not
//-	type safe.
//-
//------------------------------------------------------------------------------
define(`DPush', `
	ifelse($1, 0,
	ifelse($2, 0, dconst_0,
	$2, 1, dconst_1,
	`IPush($2)
	iconst_0');,
	`IPush($2)
	IPush($1)')
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	RPush()
//-
//- Parameter:
//-	$1	- The unsigned 32-bit number to be pushed onto the top of stack
//-
//- Description:
//-	This macro uses IPush to push the value onto the stack, so it's not
//-	type safe.
//-
//------------------------------------------------------------------------------
define(`RPush', `
	ifelse($1, 0, aconst_null;,
	IPush($1))
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	ISetLocal()
//-
//- Parameter:
//-	$1	- The local variable number to be setup
//-	$2	- The 32-bit value to be assigned to the local variable
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`ISetLocal', `
	IPush($2)
	ifelse($1, 0, istore_0,
	$1, 1, istore_1,
	$1, 2, istore_2,
	$1, 3, istore_3,
	istore	$1);
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	LSetLocal()
//-
//- Parameter:
//-	$1	- The local variable number to be setup
//-	$2	- The upper 32 bits of the long value to be assigned
//-	$3	- The lower 32 bits of the long value to be assigned
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`LSetLocal', `
	LPush($2, $3)
	ifelse($1, 0, lstore_0,
	$1, 1, lstore_1,
	$1, 2, lstore_2,
	$1, 3, lstore_3,
	lstore	$1);
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	FSetLocal()
//-
//- Parameter:
//-	$1	- The local variable number to be setup
//-	$2	- The 32-bit value to be assigned to the local variable
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`FSetLocal', `
	FPush($2)
	ifelse($1, 0, fstore_0,
	$1, 1, fstore_1,
	$1, 2, fstore_2,
	$1, 3, fstore_3,
	fstore	$1);
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	DSetLocal()
//-
//- Parameter:
//-	$1	- The local variable number to be setup
//-	$2	- The upper 32 bits of the double value to be assigned
//-	$3	- The lower 32 bits of the double value to be assigned
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`DSetLocal', `
	DPush($2, $3)
	ifelse($1, 0, dstore_0,
	$1, 1, dstore_1,
	$1, 2, dstore_2,
	$1, 3, dstore_3,
	dstore	$1);
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	RSetLocal()
//-
//- Parameter:
//-	$1	- The local variable number to be setup
//-	$2	- The 32-bit value to be assigned to the local variable
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`RSetLocal', `
	RPush($2)
	ifelse($1, 0, astore_0,
	$1, 1, astore_1,
	$1, 2, astore_2,
	$1, 3, astore_3,
	astore	$1);
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	InitLoop()
//-
//- Parameter:
//-	$1	- Iteration count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`InitLoop', `
	ISetLocal(0, $1)
Begin_Test:
	read_vars;
	iconst_4;
	isub;
	write_vars;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	LoopTest()
//-
//- Parameter:	None
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`LoopTest', `
	read_vars;
	iconst_4;
	iadd;
	write_vars;
	IPush(0x2ffffc)
	write_optop;
	iinc	0, -1;
	iload_0;
	ifeq	End_Test;
	goto	Begin_Test;
End_Test:
	')dnl

//******************************************************************************
//*
//* Macro name:	DisableIntr()
//*
//* Parameter:
//*	$1	- 1: need to do 'breakpoint' instruction to set PSR.SU to 1
//*		  0: don't need to
//*
//* Description:
//*
//******************************************************************************
define(`DisableIntr', `// begin DisableIntr($1)
	ifelse(eval($1), 1,
	`breakpoint;		// Set PSR.SU to 1',
	`// PSR.SU should be 1, no need to do breakpoint')
	// priv_read_psr;
	// IPush(0xffffffef)
	// iand;
	// priv_write_psr;		// Set PSR.IE bit 0 to ignore NMI/IRL
	iconst_0;
	IPush(0x0000fff4)		// Address to stop external NMI/IRL
	dup_x1;
	ncstore_word;
	ncload_word;			// This read blocks the execution so
					// the store can be guaranteed to go out
	pop;
	// end DisableIntr($1)')dnl

//******************************************************************************
//*
//* Macro name:	FlushSCache()
//*
//* Parameter:
//*	$1	- # of entries between OPTOP and SC_BOTTOM
//*
//* Description:
//*
//******************************************************************************
define(`FlushSCache', `// begin FlushSCache($1)
	read_optop;
	IPush(`0x'eval($1 << 2, 16))
	isub;
	write_optop;
	// end FlushSCache($1)')dnl

//******************************************************************************
//*
//* Macro name:	FlushDCache()
//*
//* Parameter:	None
//*
//* Description:
//*	This macro flushes the DCache line by line using cache_index_flush.
//*	It is based on the following assumptions:
//*
//*	1. The DCL bits are HCR[29:27]
//*	   0 -	 4 bytes
//*	   1 -	 8 bytes
//*	   2 -	16 bytes (default)
//*	   3 -	32 bytes
//*	   4 -	64 bytes
//*	   5 - 128 bytes
//*	2. The DCS bits are HCR[23:21]
//*	   0 -	0K
//*	   1 -	1K
//*	   2 -	2K
//*	   3 -	4K
//*	   4 -	8K (default)
//*	   5 - 16K
//*	3. The DCache is 2 ways set associative
//*	4. Bit 31 controls which way to flush
//*
//******************************************************************************
define(`FlushDCache', `// begin FlushDCache()
	IPush(0xfff0)
        ncload_word;
        bipush 0x0F;
        iand;
        bipush 0x0F;
	if_icmpne NoFlush2;

	priv_read_hcr;		// Read HCR register to obtain DCL and DCS
	dup;			// Save a copy
	bipush	27;		// DCL bits are in 29:27
	ishr;
	bipush	7;
	iand;			// Preserve the DCL bits
	iconst_2;
	iadd;			// Shift count for line size is DCL + 2
	dup;
	istore_2;		// Store the shift count to local var #2
	iconst_1;
	swap;			// top2 is 1, top1 is shift count
	ishl;			// Now top1 is line size in bytes
	ineg;			// Use negative line size to decrement

	swap;			// top2 is negative line size, top1 is HCR value
	bipush	21;		// DCS is in bit 23:21 of HCR
	ishr;
	bipush	7;
	iand;			// Preserve the DCS bits
	dup;
	ifeq	NoFlush;	// No need to flush is DCS is 0K
	bipush	8;
	iadd;			// top1 = DCS + 8
	iload_2;		// Load shift count of line size
	isub;			// top1 = DCS + 8 - (shift count of line size)
	iconst_1;
	swap;
	ishl;
	iconst_1;
	isub;			// top1 is the index of the last line
	iload_2;		// Load shift count of line size
	ishl;			// top1 is the address to flush the last line
				// top2 is the decrement value
	dup;
	IPush(0x80000000)
	ior;			// Address to flush the last line of way 1
	dup_x2;
	pop;			// top1 is the address to flush the last line
				//	of way 0
				// top2 is the decrement value -- the negative
				//	line size
				// top3 is the address to flush the last line
				//	of way 1
way_0_loop:
	cache_index_flush;
	dup;
	ifge	way_0_loop;

	pop;
	swap;			// top1 is the address to flush the last line of
				//	way 1
				// top2 is the decrement value
way_1_loop:
	cache_index_flush;
	dup;
	iflt	way_1_loop;
NoFlush:
	pop2;
NoFlush2:
	// end FlushDCache()')dnl

//------------------------------------------------------------------------------
// Public macros used in the random tests
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_iadd()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_iadd', `
	IPush($1)
	iadd;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_iadd()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_iadd', `
	IPush($1)
	IPush($2)
	iadd;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_isub()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_isub', `
	IPush($1)
	isub;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_isub()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_isub', `
	IPush($1)
	IPush($2)
	isub;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_imul()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_imul', `
	IPush($1)
	imul;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_imul()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_imul', `
	IPush($1)
	IPush($2)
	imul;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_idiv()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_idiv', `
	IPush($1)
	idiv;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_idiv()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_idiv', `
	IPush($1)
	IPush($2)
	idiv;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_irem()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_irem', `
	IPush($1)
	irem;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_irem()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_irem', `
	IPush($1)
	IPush($2)
	irem;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ineg()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ineg', `
	IPush($1)
	ineg;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ishl()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ishl', `
	IPush($1)
	ishl;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_ishl()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_ishl', `
	IPush($1)
	IPush($2)
	ishl;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ishr()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ishr', `
	IPush($1)
	ishr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_ishr()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_ishr', `
	IPush($1)
	IPush($2)
	ishr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_iushr()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_iushr', `
	IPush($1)
	iushr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_iushr()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_iushr', `
	IPush($1)
	IPush($2)
	iushr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_iand()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_iand', `
	IPush($1)
	iand;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_iand()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_iand', `
	IPush($1)
	IPush($2)
	iand;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ior()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ior', `
	IPush($1)
	ior;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_ior()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_ior', `
	IPush($1)
	IPush($2)
	ior;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ixor()
//-
//- Parameter:
//-	$1	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ixor', `
	IPush($1)
	ixor;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_ixor()
//-
//- Parameter:
//-	$1	- The first operand
//-	$2	- The second operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_ixor', `
	IPush($1)
	IPush($2)
	ixor;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ladd()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ladd', `
	LPush($1, $2)
	ladd;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_ladd()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_ladd', `
	LPush($1, $2)
	LPush($3, $4)
	ladd;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lsub()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lsub', `
	LPush($1, $2)
	lsub;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lsub()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lsub', `
	LPush($1, $2)
	LPush($3, $4)
	lsub;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lmul()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lmul', `
	LPush($1, $2)
	lmul;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lmul()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lmul', `
	LPush($1, $2)
	LPush($3, $4)
	lmul;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_ldiv()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_ldiv', `
	LPush($1, $2)
	ldiv;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_ldiv()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_ldiv', `
	LPush($1, $2)
	LPush($3, $4)
	ldiv;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lrem()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lrem', `
	LPush($1, $2)
	lrem;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lrem()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lrem', `
	LPush($1, $2)
	LPush($3, $4)
	lrem;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lneg()
//-
//- Parameter:
//-	$1	- The upper 32 bits of the long operand
//-	$2	- The lower 32 bits of the long operand
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lneg', `
	LPush($1, $2)
	lneg;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lshl()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lshl', `
	IPush($1)
	lshl;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lshl()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lshl', `
	LPush($1, $2)
	IPush($3)
	lshl;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lshr()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lshr', `
	IPush($1)
	lshr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lshr()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lshr', `
	LPush($1, $2)
	IPush($3)
	lshr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lushr()
//-
//- Parameter:
//-	$1	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lushr', `
	IPush($1)
	lushr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lushr()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The integer shift count
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lushr', `
	LPush($1, $2)
	IPush($3)
	lushr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_land()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_land', `
	LPush($1, $2)
	land;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_land()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_land', `
	LPush($1, $2)
	LPush($3, $4)
	land;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lor()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lor', `
	LPush($1, $2)
	lor;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lor()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lor', `
	LPush($1, $2)
	LPush($3, $4)
	lor;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lxor()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m1_lxor', `
	LPush($1, $2)
	lxor;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lxor()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lxor', `
	LPush($1, $2)
	LPush($3, $4)
	lxor;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m1_lcmp()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`s1_lcmp', `
	LPush($1, $2)
	lcmp;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name:	m2_lcmp()
//-
//- Parameter:
//-	$1	- The upper 32 bits of long operand 1
//-	$2	- The lower 32 bits of long operand 1
//-	$3	- The upper 32 bits of long operand 2
//-	$4	- The lower 32 bits of long operand 2
//-
//- Description:
//-
//------------------------------------------------------------------------------
define(`m2_lcmp', `
	LPush($1, $2)
	LPush($3, $4)
	lcmp;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name: set_hwm()
//-
//- Parameters:
//-	$1 new high watermark (entry #)
//-
//- Description:
//-  sets the high watermark to entry number $1; $1 must be multiple of 4
//------------------------------------------------------------------------------
define(`set_hwm', `
	priv_read_psr;
	IPush(0xffc7ffff)
	iand;
	IPush(eval((($1 >> 3) & 0x7) << 19))
	ior;
	priv_write_psr;
	')dnl

//------------------------------------------------------------------------------
//-
//- Macro name: set_lwm()
//-
//- Parameters:
//-	$1 new low watermark (entry #)
//-
//- Description:
//-  sets the low watermark to entry number $1; $1 must be multiple of 4
//------------------------------------------------------------------------------
define(`set_lwm', `
	priv_read_psr;
	IPush(0xfff8ffff)
	iand;
	IPush(eval((($1 >> 3) & 0x7) << 16))
	ior;
	priv_write_psr;
	')dnl

//
//  Macro name: Fib()
//
//  Parameters:
//     $1 : the index in the fibonacci series to calculate.
// 
//  Description:
//    calculates the `$1'th fibonacci number.  Used in a stack manager test.
//
define(`Fib',`
  ifelse(eval($1), 1, 1,
	 eval($1), 2, 1,
	 `eval(eval(Fib(eval($1 - 1))) + eval(Fib(eval($1 - 2))))')')

//  Macro name: assemble_psr()
//
//  Parameters: none
// 
//  Description:
//    Assembles the value for PSR by using the values contained in the
//    PSR_HWM, PSR_LWM, PSR_BM8, PSR_ACE, PSR_GCE, PSR_FPE, PSR_DCE,
//    PSR_ICE, PSR_AEM, PSR_DRE, PSR_FLE, PSR_SU, PSR_IE, and PSR_PIL
//    macros.
//

define(`assemble_psr', `eval((((PSR_HWM >> 3) & 0x7) << 19) |
			   (((PSR_LWM >> 3) & 0x7) << 16) |
			    ((PSR_BM8 & 1) << 14) |
			    ((PSR_ACE & 1) << 13) |
			    ((PSR_GCE & 1) << 12) |
			    ((PSR_FPE & 1) << 11) |
			    ((PSR_DCE & 1) << 10) |
			    ((PSR_ICE & 1) << 9) |
			    ((PSR_AEM & 1) << 8) |
			    ((PSR_DRE & 1) << 7) |
			    ((PSR_FLE & 1) << 6) |
			    ((PSR_SU & 1) << 5) |
			    ((PSR_IE & 1) << 4) |
			    (PSR_PIL & 0xf))')')

// End Macros.
//--------------------------------------------------------------------------
//
// Default definitions.	 Will be used/overwritten in
// code/test_config/reset code.

// PSR register fields... The user can set any of these fields, and they
//    will be assembled into the PSR.  If the user sets the value of the
//    entire PSR register (by defining PSR_REG), we ignore these fields.
define(`PSR_BM8', 0)
define(`PSR_ACE', 0)
define(`PSR_GCE', 0)
define(`PSR_FPE', 0)
define(`PSR_DCE', 1)
define(`PSR_ICE', 1)
define(`PSR_AEM', 0)
define(`PSR_DRE', 1)
define(`PSR_FLE', 1)
define(`PSR_SU', 1)
define(`PSR_IE', 1)
define(`PSR_PIL', 0)

// Watermarks.	Note that the watermark values indicate number of entries,
// and NOT the value of the bit-fields in the PSR.
define(`PSR_HWM', 48)
define(`PSR_LWM', 16)

#include "memmap.h"

// Restore the output bin
//
divert(0)dnl
