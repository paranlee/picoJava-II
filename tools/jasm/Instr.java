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



package com.sun.picojava.jasm; 

import java.io.*;

class Instr implements Constants {
	Instr next=null;
	int pc;
	int pos;
	int opc;
	Argument arg;
	Object arg2; // second or unusual argument

  public Instr(int pc, int pos, int opc, Argument arg, Object arg2) {
	this.pc=pc; this.pos=pos; this.opc=opc;
	this.arg=arg; this.arg2=arg2;
  }

  public Instr() { }

  public void write(DataOutputStream out, SourceFile env) throws IOException {

	switch (opc>>8) {
	  case 0: {
		if (opc==opc_bytecode) {
			out.writeByte(arg.arg);
			return;
		}

                if (opc==opc_exit_sync_method) {
                        out.writeByte(opc);
                        return;
                }

                if ((opc==opc_sethi) || (opc==opc_load_word_index)
                || (opc==opc_load_short_index) || (opc==opc_load_char_index)
                || (opc==opc_load_byte_index) || (opc==opc_load_ubyte_index)
                || (opc==opc_store_word_index) || (opc==opc_nastore_word_index)
                || (opc==opc_store_short_index) || (opc==opc_store_byte_index))
                {
                        out.writeByte(opc);
                        out.writeShort(arg.arg);
                        return;       
                }

		out.writeByte(opc);
		int opcLen=opcLengthsTab[opc];
		if (opcLen==1)	return;

		switch(opc) {
		  case opc_tableswitch:
			((SwitchTable)arg2).writeTableSwitch(out);
			return;
		  case opc_lookupswitch:
			((SwitchTable)arg2).writeLookupSwitch(out);
			return;
		}

		int iarg;
try{
		iarg=arg.arg;
} catch (NullPointerException e) {
	throw new CompilerError("null arg for "+opcNamesTab[opc]);
}
//env.traceln("instr:"+opcNamesTab[opc]+" len="+opcLen+" arg:"+iarg);
		switch(opc) {
		  case opc_jsr: case opc_goto:
		  case opc_ifeq: case opc_ifge: case opc_ifgt:
		  case opc_ifle: case opc_iflt: case opc_ifne:
		  case opc_if_icmpeq: case opc_if_icmpne: case opc_if_icmpge:
		  case opc_if_icmpgt: case opc_if_icmple: case opc_if_icmplt:
		  case opc_if_acmpeq: case opc_if_acmpne:
		  case opc_ifnull: case opc_ifnonnull:
		  case opc_jsr_w:
		  case opc_goto_w:
			iarg=iarg-pc;
			break;
		  case opc_iinc:
			iarg= (iarg<<8)|(((Argument)arg2).arg&0xFF);
			break;
		  case opc_invokeinterface: 
			iarg=((iarg<<8)|(((Argument)arg2).arg&0xFF))<<8;
			break;
		  case opc_ldc: 
			if ((iarg&0xFFFFFF00)!=0) throw new CompilerError(
				"Too long argument of "+Scanner.opcName(opc)+": "+iarg
			);
			break;
		}
		switch (opcLen) {
		  case  1:
			return;
		  case  2:
			out.writeByte(iarg);
			return;
		  case 	3:
			out.writeShort(iarg);
			return;
		  case 	4: // opc_multianewarray only
			out.writeShort(iarg);
			iarg=((Argument)arg2).arg;
			out.writeByte(iarg);
			return;
		  case 	5:
			out.writeInt(iarg);
			return;
		  default:
			throw new CompilerError("Wrong opcLength("+Scanner.opcName(opc)+")");
		}
	  }
	  case opc_wide:
		out.writeByte(opc_wide);
		out.writeByte(opc&0xFF);
		out.writeShort(arg.arg);
		if (opc==opc_iinc_w) out.writeShort(((Argument)arg2).arg&0xFFFF);
		return;
	  case opc_extended:
		out.writeByte(opc>>8);
		out.writeByte(opc&0xFF);
		return;
	  default:
		throw new CompilerError("Wrong opcLength("+Scanner.opcName(opc)+")");
	} // end writeSpecCode

  }
} // end Instr


