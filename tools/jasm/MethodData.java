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
import java.util.Enumeration;
import java.util.Vector;
import java.util.Hashtable;

class MethodData implements Constants {
  ClassData cls;
  SourceFile env;
  int access;
  ConstValue nape;
  Argument Code_cell, LineNumberTable_cell
	, LocalVariableTable_cell, ExcTable_cell;
  Argument max_stack, max_locals;
  int num_locvars=0;
  Instr zeroInstr, lastInstr;
  int cur_pc=0;
  Vector exc_table;
  Vector trap_table=new Vector(0); // TrapData
  Vector attrs;  // AttrData
  Vector lin_num_tb; //LineNumData
  Vector loc_var_tb;  // LocVarData

  public MethodData(ClassData cls, int access
			, ConstValue nape, Vector exc_table) {
	this.cls=cls;
	this.env=cls.env;
	this.access=access;
	this.nape=nape;
	if (exc_table!=null) {
		ExcTable_cell=cls.FindCellAsciz("Exceptions");
	}
	this.exc_table=exc_table;
  }

  public void startCode() {
	lastInstr=zeroInstr=new Instr();
	Code_cell=cls.FindCellAsciz("Code"); // reserve cell containing this 
	                                     // string
	trap_table=new Vector(0); // TrapData
	attrs=new Vector(0);  // AttrData
	lin_num_tb=new Vector(0); //LineNumData
	loc_var_tb=new Vector(0);  // LocVarData
  }

  public void setStack(Argument max_stack) {
	this.max_stack=max_stack;
  }

  public void setLocals(Argument max_locals) {
	this.max_locals=max_locals;
  }

  void Close() {
	checkLocals();
	checkTraps();
  }

/* -------------------------------------- Locals */
  Hashtable localsHash = new Hashtable(10);

  void checkLocals() {
	for (Enumeration e=localsHash.elements(); e.hasMoreElements();) {
		Object local=e.nextElement();
		if (local instanceof Label) {
		// check that every label is declared
			Label label=(Label)local;
			if (!label.isSet()) 
                                env.error("label.undecl", label.name);
		} else if (local instanceof LocVarData) {
			LocVarData locvar=(LocVarData)local;
			if (locvar.refd==false) {
				env.error("warn.locvar.unused", locvar.name);
			}
		// set end of scope, if not set
			if (slots.data[locvar.arg]==1) {
				locvar.length=(short)(cur_pc-locvar.start_pc);
				slots.data[locvar.arg]=0;
			}
		}
	}
  }

  void checkTraps() {
	int siz=trap_table.size();
	for (int i=0; i<siz; i++) {
		TrapData line=(TrapData)trap_table.elementAt(i);
		Trap trap=line.trap;
		if (trap.start_pc==Trap.NotSet) { 
			env.error(trap.pos, "warn.trap.nostart", trap.name);
			trap.start_pc=0;
		}
		if (trap.end_pc==Trap.NotSet) {
			env.error(trap.pos, "warn.trap.noend", trap.name);
			trap.end_pc=cur_pc;
		}
	}
  }

/* -------------------------------------- Traps */
  void beginTrap(int pos, String name) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new Trap(pos, name);
		localsHash.put(name, local);
	} else if (!(local instanceof Trap) ) {
		env.error("local.redecl", name);
		return;
	}
	Trap trap=(Trap)local;
	if (trap.start_pc!=Trap.NotSet) {
		env.error("local.redecl", name);
		return;
	}
	trap.start_pc=cur_pc;
  }

  void endTrap(int pos, String name) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new Trap(pos, name);
		localsHash.put(name, local);
	} else if (!(local instanceof Trap) ) {
		env.error("local.redecl", name);
		return;
	}
	Trap trap=(Trap)local;
	if (trap.end_pc!=Trap.NotSet) {
		env.error("local.redecl", name);
		return;
	}
	trap.end_pc=cur_pc;
  }

  void trapHandler(int pos, String name, Argument type) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new Trap(pos, name);
		localsHash.put(name, local);
	} else if (!(local instanceof Trap) ) {
		env.error("local.redecl", name);
		return;
	}
	Trap trap=(Trap)local;
	trap_table.addElement(new TrapData(trap, cur_pc, type));
  }

/* -------------------------------------- Labels */
  public Label LabelDef(String name) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new Label(name);
		localsHash.put(name, local);
	} else if (!(local instanceof Label) ) {
		env.error("local.redecl", name);
		return null;
	} else if (local.defd) {
		env.error("label.redecl", name);
		return null;
	}
	local.defd=true;
	local.arg=cur_pc;
env.traceln("   LabelDef "+name+" at "+local.arg);
	return (Label)local;
  }

  public Label LabelRef(String name) {
env.traceln("   LabelRef "+name);
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new Label(name);
		localsHash.put(name, local);
	} else if (!(local instanceof Label) ) {
		env.error("local.redecl", name);
		return null;
	}
	local.refd=true;
	return (Label)local;
  }

/* -------------------------------------- Variables */
  iVector slots=new iVector(4);

  public void LocVarDataDef(int slot) {
	if (slot>=num_locvars) num_locvars=slot+1;
	if ((max_locals!=null)&&(max_locals.arg<num_locvars))
		env.error("warn.illslot", new Integer(slot).toString());
	slots.addElement(1, slot);
  }

  public void LocVarDataDef(String name, ConstCell type) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new LocVarData(name);
		localsHash.put(name, local);
	} else if (!(local instanceof LocVarData) ) {
		env.error("local.redecl", name);
		return;
	} else if (local.defd) {
		env.error("local.redecl", name);
		return;
	}
	local.defd=true;
	LocVarData locvar=(LocVarData)local;
	locvar.start_pc=(short)cur_pc;
	locvar.name_cpx=(short)cls.FindCellAsciz(name).arg;
	locvar.sig_cpx=(short)type.arg;
	int k;
	findSlot: {
		for (k=0; k<slots.length; k++) {
			if (slots.data[k]==0) break findSlot;
		}
		k=slots.length;
	}				
	LocVarDataDef(k);
	locvar.arg=k;
	loc_var_tb.addElement(locvar);
  }

  public Argument LocVarDataRef(String name) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		local=new LocVarData(name);
		localsHash.put(name, local);
	} else if (!(local instanceof LocVarData) ) {
		env.error("local.redecl", name);
		return null;
	} else if (!local.defd) {
		env.error("local.undecl", name);
		return null;
	}
	local.refd=true;
	LocVarData locvar=(LocVarData)local;
	if (!locvar.defd
		&& !locvar.refd==false // to avoid repeating errors
	) {
		env.error("locvar.undecl", name);
		return null;
	}
	if (LocalVariableTable_cell==null) 
	       LocalVariableTable_cell=cls.FindCellAsciz("LocalVariableTable");
	locvar.refd=true;
	return locvar;
  }

  public void LocVarDataEnd(int slot) {
	slots.data[slot]=0;
  }

  public void LocVarDataEnd(String name) {
	Local local=(Local)localsHash.get(name);
	if (local==null) {
		env.error("local.undecl", name);
		return;
	} else if (!(local instanceof LocVarData) ) {
		env.error("local.undecl", name);
		return;
	} else if (!local.defd) {
		env.error("local.undecl", name);
		return;
	}
	LocVarData locvar=(LocVarData)local;
	locvar.length=(short)(cur_pc-locvar.start_pc);
	slots.data[locvar.arg]=0;
  }

/* -------------------------------------- Instr */
  void addInstr(int opc, Argument arg, Object arg2) {
	Instr newInstr=new Instr(cur_pc, cls.env.pos, opc, arg, arg2);
	lastInstr.next=newInstr; lastInstr=newInstr;
	int len=Scanner.opcLength(opc);
	switch(opc) {
	  case opc_tableswitch:
		len=((SwitchTable)arg2).recalcTableSwitch(cur_pc);
		break;
	  case opc_lookupswitch:
		len=((SwitchTable)arg2).calcLookupSwitch(cur_pc);
		break;
	  case opc_ldc:
		((ConstCell)arg).setRank(0);
		break;
	  default:
		if (arg instanceof ConstCell) ((ConstCell)arg).setRank(1);
	}
	cur_pc+=len;
  }

  public void addInstr(int opc, Argument arg) {
	addInstr(opc, arg, null);
  }

  public void addInstr(int opc, int iarg) {
	addInstr(opc, new Argument(iarg), null);
  }

  public void addInstr(int opc) {
	addInstr(opc, null, null);
  }

/* -------------------------------------- Line table */
  public void addLineNumber(int number) {
	if (LineNumberTable_cell==null) 
		LineNumberTable_cell=cls.FindCellAsciz("LineNumberTable");
	lin_num_tb.addElement(new LineNumData(cur_pc, number));
  }

/* -------------------------------------- Write */
  public int computeLineNumTableLen() {
	return 8+lin_num_tb.size()*4;
  }

  void writeLineNumTable (DataOutputStream out) 
		throws IOException, CompilerError {
	out.writeShort(LineNumberTable_cell.arg);
	int numlines=lin_num_tb.size();
	out.writeInt(2+numlines*4);
	out.writeShort(numlines);
	for (int i=0; i<numlines; i++) {
		((LineNumData)lin_num_tb.elementAt(i)).write(out);
	}
  }

  public int computeLocVarTableLen() {
	return 8+lin_num_tb.size()*10;
  }

  void writeLocVarTable (DataOutputStream out) 
		throws IOException, CompilerError {
	out.writeShort(LocalVariableTable_cell.arg);
	int siz=loc_var_tb.size();
	out.writeInt(2+siz*10);
	out.writeShort(siz);
	for (int i=0; i<siz; i++) {
env.traceln("   LocVarData:#"+i);
		((LocVarData)loc_var_tb.elementAt(i)).write(out);
	}
  }

  public void writeExceptions(DataOutputStream out) 
		throws IOException, CompilerError {
	out.writeShort(ExcTable_cell.arg);
	int siz=exc_table.size();
	out.writeInt(2+2*siz); // attr len
	out.writeShort(siz);
	for (int k=0; k<siz; k++) {
		int cpx=((Argument)exc_table.elementAt(k)).arg;
env.traceln("   writeExceptions: #"+cpx);
		out.writeShort(cpx);
	}

  }

  public void writeCode(DataOutputStream out) 
		throws IOException, CompilerError {
	out.writeShort(Code_cell.arg);

	int codelen=2+2+4 // for max_stack, max_locals, and cur_pc
		+ cur_pc
		+ 2+trap_table.size()*8
		+ 2		// nattr
		+ (lin_num_tb.isEmpty()? 0 :  computeLineNumTableLen())
		+ (loc_var_tb.isEmpty()? 0 :  computeLocVarTableLen())
	;
env.traceln(" WrCode: len="+cur_pc+" fulllen="+codelen+" CA=#"+Code_cell.arg);
	out.writeInt(codelen); // attr len

	out.writeShort((max_stack!=null)?max_stack.arg:0);
	out.writeShort((max_locals!=null)?max_locals.arg:slots.length);
	out.writeInt(cur_pc);
	for (Instr instr=zeroInstr.next; instr!=null; instr=instr.next) {
		instr.write(out, env);
	}

        //	write ExcTable:
	int siz=trap_table.size();
	out.writeShort(siz);
	for (int i=0; i<siz; i++) {
		((TrapData)trap_table.elementAt(i)).write(out, env);
	}

	short nattr
	       =(short)((lin_num_tb.isEmpty()?0:1)+(loc_var_tb.isEmpty()?0:1));
	out.writeShort(nattr);
	if (!lin_num_tb.isEmpty()) writeLineNumTable(out);
	if (!loc_var_tb.isEmpty()) writeLocVarTable(out);
  }

  public void write(DataOutputStream out) 
		throws IOException, CompilerError {
	out.writeShort(access);
	out.writeShort(nape.left().arg);
	out.writeShort(nape.right().arg);
	int natt=0;
	if (lastInstr!=null) {	natt++;	}
	if (exc_table!=null) {	natt++;	}
	out.writeShort(natt);
	if (lastInstr!=null) {	writeCode(out);	}
	if (exc_table!=null) {	writeExceptions(out); }
  }

} // end MethodData

