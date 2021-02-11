//****************************************************************
//***
//***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
//***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
//***    The contents of this file are subject to the current
//***    version of the Sun Community Source License, picoJava-II
//***    Core ("the License").  You may not use this file except
//***    in compliance with the License.  You may obtain a copy
//***    of the License by searching for "Sun Community Source
//***    License" on the World Wide Web at http://www.sun.com.
//***    See the License for the rights, obligations, and
//***    limitations governing use of the contents of this file.
//***
//***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
//***    trademarks and logos, Java, picoJava, and all Java-based
//***    trademarks and logos are trademarks or registered trademarks
//***    of Sun Microsystems, Inc. in the United States and other
//***    countries.
//***
//*****************************************************************




package com.sun.picojava.jdis; 

import java.util.*;
import java.io.*;
import com.sun.picojava.jasm.Tables;

class MethodData implements com.sun.picojava.jasm.Constants {
  ClassData cls;
  short access;
  short name_cpx;
  short sig_cpx;
  short max_stack, max_locals;
  byte[] code;
  int[] exc_table=null; // CPX[]
  Vector trap_table=new Vector(0); // TrapData
  Vector attrs=new Vector(0);  // AttrData
  Vector lin_num_tb=new Vector(0); //LineNumData
  Vector loc_var_tb=new Vector(0);  // LocVarData
  Vector other_code_attrs=new Vector(0);  // AttrData
  Hashtable iattrs=new Hashtable();

  public MethodData(ClassData cls) {
	this.cls=cls;
  }

  public MethodData(ClassData cls, DataInputStream in) throws IOException {
	this.cls=cls;
	read(in);
  }

  public iAtt get_iAtt(int pc) {
	Integer PC=new Integer(pc);
	Object res=iattrs.get(PC);
	if (res == null) { 
	    res = new iAtt(cls);
	    iattrs.put(PC, res);
	}
	return (iAtt)res;
  }

  void readLineNumTable (DataInputStream in) throws IOException {
	int len=in.readInt(); // attr_length
	int numlines=in.readShort();
	lin_num_tb=new Vector(numlines);
cls.traceln("  NumTable["+numlines+"] len="+len);
	for (int l = 0; l < numlines; l++) {
		lin_num_tb.addElement(new LineNumData(in));
	}
  }

  void readLocVarTable (DataInputStream in) throws IOException {
	int len=in.readInt(); // attr_length
	int numlines=in.readShort();
	loc_var_tb=new Vector(numlines);
cls.traceln("  LocVarTable["+numlines+"] len="+len);
	for (int l = 0; l < numlines; l++) {
		loc_var_tb.addElement(new LocVarData(in));
	}
  }

  void readTrapTable (DataInputStream in) throws IOException {
	int trap_table_len=in.readShort();
	trap_table=new Vector(trap_table_len);
	for (int l = 0; l < trap_table_len; l++) {
		trap_table.addElement(new TrapData(in, l));
	}
  }

  public void readExceptions(DataInputStream in) throws IOException {
	int fulllen=in.readInt(); // attr_length in prog
	short exc_table_len=in.readShort();
	exc_table=new int[exc_table_len];
	for (int l = 0; l < exc_table_len; l++) {
		int exc=in.readShort();
cls.traceln("       throws:#"+exc);
		exc_table[l]=exc;
	}
  }

  public void readCode(DataInputStream in) throws IOException {
	int fulllen=in.readInt(); // attr_length in prog
	max_stack=in.readShort();
	max_locals=in.readShort();
	int codelen=in.readInt();
cls.traceln(" Codelen="+codelen+" fulllen="+fulllen
		+"max_stack="+max_stack+" max_locals="+max_locals);
	code=new byte[codelen];
	in.read(code, 0, codelen);
	readTrapTable(in);
	short nattr=in.readShort();
cls.traceln(" trap_table.size="+trap_table.size()+" add.attr:"+nattr);
	for (int k = 0 ; k < nattr ; k++) {
		short table_name_cpx=in.readShort();
		if (cls.getTag(table_name_cpx)==CONSTANT_UTF8
			&& cls.getString(table_name_cpx).equals("LineNumberTable")
		){
			readLineNumTable(in);
		} else if (cls.getTag(table_name_cpx)==CONSTANT_UTF8
			&& cls.getString(table_name_cpx).equals("LocalVariableTable")
		){
			readLocVarTable(in);
		} else {
			AttrData attr=new AttrData(cls);
			attr.read(name_cpx, in);
			other_code_attrs.addElement(attr);
		}
	}
  }

  public void read(DataInputStream in) throws IOException {
	access = in.readShort(); // & MM_METHOD; // Q
	name_cpx=in.readShort();
	sig_cpx =in.readShort();
	int natt = in.readShort();
cls.traceln("MethodData:#"+name_cpx+" natt="+natt);
	for (int i = 0; i < natt; i++) {
		short attr_name_cpx=in.readShort();
cls.traceln("	attr["+i+"] #"+attr_name_cpx);
	  readAttr: {
		if (cls.getTag(attr_name_cpx)==CONSTANT_UTF8) {
			String ans=cls.getString(attr_name_cpx);
			if (ans.equals("Code")){
				readCode (in);
				break readAttr;
			} else if (ans.equals("Exceptions")){
				readExceptions (in);
				break readAttr;
			}
		} 
		AttrData attr=new AttrData(cls);
		attr.read(name_cpx, in);
		attrs.addElement(attr);
	  }
	}
  }

  public int checkForLabelRef (int pc) {
	int opcode = getUbyte(pc);
	switch (opcode) {
	  case opc_tableswitch:{
		int tb=align(pc+1);
		int default_skip = getInt(tb); /* default skip pamount */
		int low = getInt(tb+4);
		int high = getInt(tb+8);
		int count = high - low;
		for (int i = 0; i <= count; i++) 
			get_iAtt(pc+getInt(tb+12+4*i)).referred=true;
		get_iAtt(default_skip + pc).referred=true;
		return tb-pc+16+count*4;
		}
	  case opc_lookupswitch:{
		int tb=align(pc+1);
		int default_skip = getInt(tb); /* default skip pamount */
		int npairs = getInt(tb+4);
		for (int i = 1; i <= npairs; i++) 
			get_iAtt(pc+getInt(tb+4+i*8)).referred=true;
		get_iAtt(default_skip + pc).referred=true;
		return tb-pc+(npairs+1)*8;
	    }
	  case opc_jsr: case opc_goto:
	  case opc_ifeq: case opc_ifge: case opc_ifgt:
	  case opc_ifle: case opc_iflt: case opc_ifne:
	  case opc_if_icmpeq: case opc_if_icmpne: case opc_if_icmpge:
	  case opc_if_icmpgt: case opc_if_icmple: case opc_if_icmplt:
	  case opc_if_acmpeq: case opc_if_acmpne:
	  case opc_ifnull: case opc_ifnonnull:
		get_iAtt(pc + getShort(pc+1)).referred=true;
		return 3;
	  case opc_jsr_w:
	  case opc_goto_w:
		get_iAtt(pc+getInt(pc+1)).referred=true;
		return 5;		

	  case opc_wide:
	  case opc_extended:
		opcode=(opcode<<8)+getUbyte(pc+1);
	}
	try {
		return Tables.opcLength(opcode);
	} catch (ArrayIndexOutOfBoundsException e) {
		return 1; // nonexistent codes is assumed to be 1 byte long
	}
  } // end checkForLabelRef

  void loadLabelTable () {
	for (int pc=0; pc < code.length; ) {
		pc=pc+checkForLabelRef(pc);
	}	
  }

  void loadLineNumTable () {
	int numlines=lin_num_tb.size();
	for (int i=0; i<numlines; i++) {
		LineNumData entry=(LineNumData)lin_num_tb.elementAt(i);
		get_iAtt(entry.start_pc).lnum=entry.line_number;
	}
  }

  void loadLocVarTable () throws IOException {
	int siz=loc_var_tb.size();
	for (int i=0; i<siz; i++) {
		LocVarData entry=(LocVarData)loc_var_tb.elementAt(i);
		get_iAtt(entry.start_pc).add_var(entry);
		get_iAtt(entry.start_pc+entry.length).add_endvar(entry);
	}
  }

  void loadTrapTable () {
	int siz=trap_table.size();
	for (int i=0; i<siz; i++) {
		TrapData entry=(TrapData)trap_table.elementAt(i);
		get_iAtt(entry.start_pc).add_trap(entry);
		get_iAtt(entry.end_pc).add_endtrap(entry);
		get_iAtt(entry.handler_pc).add_handler(entry);
	}
  }


  int getUbyte (int pc) {
	return code[pc]&0xFF;
  }

  int getShort (int pc) {
	return (code[pc]<<8) | (code[pc+1]&0xFF);
  }

  int getInt (int pc) {
	return (getShort(pc)<<16) | (getShort(pc+2)&0xFFFF);
  }

  static int  align (int n) {
	return (n+3) & ~3 ;
  }

  void PrintConstant(int cpx, PrintStream out) {
	out.print("\t");
	cls.PrintConstant(cpx, out);
  }

  public int printInstr (int pc, int printOptions, PrintStream out)
			 throws IOException {
	String lP = ((printOptions&ClassData.PR_LABS)!=0)?"L":"";// labelPrefix
	boolean pr_cpx=(printOptions&ClassData.PR_CPX)!=0;
	int opcode = getUbyte(pc), opcode2;
	String mnem;
	switch (opcode) {
  	  case opc_sethi:
            mnem = Tables.opcName(opcode);
            out.print(mnem + "\t" + (getShort(pc+1)&0xFFFF));
            return 3;
	  case opc_load_word_index: case opc_load_short_index:
	  case opc_load_char_index: case opc_load_byte_index:
	  case opc_load_ubyte_index: case opc_store_word_index:
	  case opc_nastore_word_index: case opc_store_short_index:
	  case opc_store_byte_index:
            if (cls.mayaFlag) {
            mnem = Tables.opcName(opcode);
	    out.print(mnem + "\t"+getUbyte(pc+1)+", "+getUbyte(pc+2));
            }
            return 3;
	  case opc_extended:
	    opcode2 = getUbyte(pc+1);
		mnem=Tables.opcName((opcode<<8)+opcode2);
                if ((opcode2==21) && (!cls.mayaFlag)) return 2;
		if (mnem==null) 
                // assume all (even nonexistent) priv and nonpriv instructions
                // that start with 0xff are 2 bytes long
			mnem=Tables.opcName(opcode)+" "+opcode2;

		out.print(mnem);
		return 2;
	  case opc_wide: {
	    opcode2 = getUbyte(pc+1);
		mnem=Tables.opcName((opcode<<8)+opcode2);
		if (mnem==null) {
                // nonexistent opcode - but we have to print something
			out.print("bytecode "+opcode);
			return 1;
		}
		out.print(mnem+" "+getShort(pc+2));
		if (opcode2==opc_iinc) {
			out.print(", "+getShort(pc+4));
			return 6;
		}
		return 4;
	  }
	}
	mnem=Tables.opcName(opcode);
	if (mnem==null) {
        // nonexistent opcode - but we have to print something
		out.print("bytecode "+opcode);
		return 1;
	}
	out.print(Tables.opcName(opcode));
	switch (opcode) {
	  case opc_aload: case opc_astore:
	  case opc_fload: case opc_fstore:
	  case opc_iload: case opc_istore:
	  case opc_lload: case opc_lstore:
	  case opc_dload: case opc_dstore:
	  case opc_ret:
		out.print("\t"+getUbyte(pc+1));
		return  2;
	  case opc_iinc:
		out.print("\t"+getUbyte(pc+1)+", "+getUbyte(pc+2));
		return  3;
	  case opc_tableswitch:{
		int tb=align(pc+1);
		int default_skip = getInt(tb); /* default skip pamount */
		int low = getInt(tb+4);
		int high = getInt(tb+8);
		int count = high - low;
		out.print("{ //"+low+" to "+high);
		for (int i = 0; i <= count; i++) 
		    out.print( "\n\t\t" + (i+low) + ": "+lP+(pc+getInt(tb+12+4*i))+";");
		out.print("\n\t\tdefault: "+lP+(default_skip + pc) + " }");
		return tb-pc+16+count*4;
		}

	  case opc_lookupswitch:{
		int tb=align(pc+1);
		int default_skip = getInt(tb);
		int npairs = getInt(tb+4);
		out.print("{ //"+npairs);
		for (int i = 1; i <= npairs; i++) 
		    out.print("\n\t\t"+getInt(tb+i*8)
				+": "+lP+(pc+getInt(tb+4+i*8))+";"
			);
		out.print("\n\t\tdefault: "+lP+(default_skip + pc) + " }");
		return tb-pc+(npairs+1)*8;
	    }
	  case opc_newarray:
		int type=getUbyte(pc+1);
		switch (type) {
		    case T_BOOLEAN:out.print(" boolean");break;
		    case T_BYTE:   out.print(" byte");   break;
		    case T_CHAR:   out.print(" char");   break;
		    case T_SHORT:  out.print(" short");  break;
		    case T_INT:    out.print(" int");    break;
		    case T_LONG:   out.print(" long");   break;
		    case T_FLOAT:  out.print(" float");  break;
		    case T_DOUBLE: out.print(" double"); break;
		    case T_CLASS: out.print(" class"); break;
		    default:       out.print(" BOGUS TYPE:"+type);
		}
		return 2;

	   case opc_anewarray: {
		int index =  getShort(pc+1);
		if (pr_cpx) out.print("\t#"+index+"; //");
		PrintConstant(index, out);
		return 3;
	  }
  
	  case opc_sipush:
		out.print("\t"+getShort(pc+1));
		return 3;

	  case opc_bipush:
		out.print("\t"+getUbyte(pc+1));
		return 2;

	  case opc_ldc: {
		int index = getUbyte(pc+1);
		if (pr_cpx) out.print("\t#"+index+"; //");
		PrintConstant(index, out);
		return 2;
	  }

	  case opc_ldc_w: case opc_ldc2_w:
	  case opc_instanceof: case opc_checkcast:
	  case opc_new:
	  case opc_putstatic: case opc_getstatic:
	  case opc_putfield: case opc_getfield:
	  case opc_invokevirtual:
	  case opc_invokespecial:
	  case opc_invokestatic: {
		int index = getShort(pc+1);
		if (pr_cpx) out.print("\t#"+index+"; //");
		PrintConstant(index, out);
		return 3;
	  }

	  case opc_invokeinterface: {
		int index = getShort(pc+1);
		if (pr_cpx) {
			out.print("\t#"+index+",  "+getUbyte(pc+3)+"; //"); 
			PrintConstant(index, out);
		} else {
			PrintConstant(index, out);
			out.print(",  "+getUbyte(pc+3)); // args count
		}
		getUbyte(pc+4); // reserved byte
		return 5;
	  }

	  case opc_multianewarray: {
		int index = getShort(pc+1);
		if (pr_cpx) {
			out.print("\t#"+index+",  "+getUbyte(pc+3)+"; //"); 
			PrintConstant(index, out);
		} else {
			PrintConstant(index, out);
			out.print(",  "+getUbyte(pc+3)); // dimensions count
		}
		return 4;
	  }

	  case opc_jsr: case opc_goto:
	  case opc_ifeq: case opc_ifge: case opc_ifgt:
	  case opc_ifle: case opc_iflt: case opc_ifne:
	  case opc_if_icmpeq: case opc_if_icmpne: case opc_if_icmpge:
	  case opc_if_icmpgt: case opc_if_icmple: case opc_if_icmplt:
	  case opc_if_acmpeq: case opc_if_acmpne:
	  case opc_ifnull: case opc_ifnonnull:
		out.print("\t"+lP+(pc + getShort(pc+1)) );
		return 3;

	  case opc_jsr_w:
	  case opc_goto_w:
		out.print("\t"+lP+(pc + getInt(pc+1)));
		return 5;
		
	  default:
		return 1;
	}
  } // end printInstr

  public void printCode(int printOptions, PrintStream out) throws IOException {
	String lP = ((printOptions&ClassData.PR_LABS)!=0)?"L":"";// labelPrefix
	int printLNOptions=0;
	if (!lin_num_tb.isEmpty()) {
		loadLineNumTable();
		printLNOptions=printOptions&(ClassData.PR_LNT|ClassData.PR_SRC);
	}
	if ((printOptions&ClassData.PR_PC)==0) loadLabelTable();
	loadTrapTable();
	if (!loc_var_tb.isEmpty()) loadLocVarTable();
	iAtt iatt=(iAtt)iattrs.get(new Integer(0));

	out.println();
	out.println("\tstack "+max_stack+" locals "+max_locals);
	out.println("{");
	for (int pc=0; pc < code.length; ) {
		if (iatt != null) {
			iatt.printBegins(printLNOptions, out); 
		} else {
			out.print("\t");
		}
		if ((printOptions&ClassData.PR_PC)!=0) {
			out.print(pc+":\t");
		} else if ((iatt != null) && iatt.referred ) {
			out.print(lP+pc+":\t");
		} else {
			out.print("\t");
		}		
		pc=pc+printInstr(pc, printOptions, out);
		out.println(";");
		iatt=(iAtt)iattrs.get(new Integer(pc));
		if (iatt != null) {
			iatt.printEnds(out);
		}
	}	

	out.println("}");
  }

  public void print(int printOptions, PrintStream out) throws IOException {
	out.println();
	((ClassData)cls).printAccess(access, out);
	out.print("Method ");
//	out.print(" #"+name_cpx+":#"+sig_cpx+" //");
	out.print(cls.getName(name_cpx)+":\""+cls.getName(sig_cpx)+"\"");

	if (exc_table != null) {
		out.print("\n\tthrows ");
		int k,l = exc_table.length;
		for (k=0; k<l; k++) {
			out.print(cls.getClassName(exc_table[k]));
			if (k<l-1) out.print(", ");
		}
	}
	if (code == null) {
		out.println(";");
	} else {
		printCode(printOptions, out);
	}
  }

} // end MethodData
