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
import java.util.Vector;
import java.util.Hashtable;
import java.util.Enumeration;

class ClassData implements Constants {
  short minor_version=3,  // TBD
	version;
  int access;
  Argument source_cell=null, SourceFile_cell;

  Vector interfaces;
  Vector fields=new Vector(); //FieldData
  Vector methods=new Vector(); // MethodData
  Vector attrs=new Vector(); // AttrData

  ConstCell me, father;
  SourceFile env;

  public void init (int access, ConstCell me, ConstCell father, Vector interfaces) {
	this.access=access;
	this.me=me;
	if (father==null) {
		father=FindCellClassByName("java/lang/Object");
	}
	this.father=father;
	this.interfaces=interfaces;
  }

  public ClassData (SourceFile env) {
	this.env=env;
  }

  public ClassData (SourceFile env,
		int access, ConstCell me, ConstCell father, Vector impls) {
	this(env);
	init(access, me, father, impls);
  }

  public final boolean isInterface() {
	return (access&ACC_INTERFACE)!=0;
  }

  public final String name() {
	try {
		ConstValue v = ((ConstCell)me).ref;
		ConstCell ascicell=(ConstCell)(v.value);
		return (String)(ascicell.ref.value);
	} catch (NullPointerException e) {
		return null;
	} catch (ClassCastException e) {
		return null;
	} 
  }

  /*-------------------------------------------------------- CPool */

  // by value
  Hashtable cpoolHashByValue = new Hashtable(40);

  public ConstCell FindCell(ConstValue ref)  {
	if (ref==null) throw new CompilerError("ConstCell.value=null??");
	ConstCell pconst=(ConstCell)cpoolHashByValue.get(ref);
	if (pconst != null) {
		ConstValue value=pconst.ref;
		if (!value.equals(ref)) 
                   throw new CompilerError("Values not eq");
		return pconst;
	}
	pconst = new ConstCell(ref);
	cpoolHashByValue.put(ref, pconst);
	return pconst;
  }

  // by index
  Vector pool = new Vector(20);
  private ConstCell cpool_get(int cpx) {
	if (cpx >= pool.size()) {
		return null;
	}
	return (ConstCell)pool.elementAt(cpx);
  }
  private void cpool_set(int cpx, ConstCell cell) {
	if (cpx >= pool.size()) {
		pool.setSize(cpx+1);
	}
	pool.setElementAt(cell, cpx);
  }
  private int find_1(int cpx) {
	find: {
		while (cpx < pool.size()) {
			if (pool.elementAt(cpx)==null) break find;
			cpx++;
		}
		pool.setSize(cpx+1);
	}
	return cpx;
  }
  private int find_2(int cpx) {
	find: {
		while (cpx < pool.size()) {
			if  ( (pool.elementAt(cpx)==null) 
				&&(pool.elementAt(cpx+1)==null) ) break find;
			cpx++;
		}
		pool.setSize(cpx+2);
	}
	return cpx;
  }

  public ConstCell getCell(int cpx)  { // by index
	ConstCell cell=cpool_get(cpx);
	if (cell!=null) return cell;
	cell = new ConstCell(cpx, null);
	return cell;
  }

  public void setCell(int cpx, ConstCell cell)  {
	if (cpool_get(cpx)!=null) {
		String name=(new Integer(cpx)).toString();
		env.error("const.redecl", name);
		return;			
	}
	if (cell.isSet()) {
		cell=new ConstCell(cpx, cell.ref);
	} else {
		cell.arg=cpx;
	}
	cpool_set(cpx, cell);
  }

  protected void  NumberizePool() {
	Enumeration e;
	int cpx1=1, cpx2=1;
	ConstCell dummyCell=new ConstCell(null);
	for (int rank=0; rank<3; rank++) {
		for (e=cpoolHashByValue.elements(); e.hasMoreElements(); ) {
			ConstCell cell=(ConstCell)e.nextElement();
			if (cell.rank!=rank) continue;
			if (cell.isSet()) continue;
			ConstValue value=cell.ref;
			if (value==null) {
				throw new CompilerError(
				"Cell without value in cpoolHashByValue");
			}
			if (value.size()==1) {	
				cpx1=find_1(cpx1);
				cell.arg=cpx1;
				cpool_set(cpx1, cell);
			} else { //	if (value.size()==2) {	
				cpx2=find_2(cpx2);
				cell.arg=cpx2;
				cpool_set(cpx2, cell);
				cpool_set(cpx2+1, dummyCell);
			}
		}
	}
  }

  ConstValue ConstValue0
     = new ConstValue(CONSTANT_INTEGER, new Integer(0), env);

  protected void  CheckGlobals() {
	for (int cpx=1; cpx<pool.size(); cpx++) {
		ConstCell cell=(ConstCell)pool.elementAt(cpx);
		if (cell==null) { // gap 
			cell=new ConstCell(cpx, ConstValue0);
			pool.setElementAt(cell, cpx);
		}
		ConstValue value=cell.ref;
		if ( (value==null) || (value.value==null) ) {
			String name=(new Integer(cpx)).toString();
			env.error("const.undecl", name);
		}
	}
  }

  /*-------------------------------------------------------- API */
  public ConstValue mkNape(ConstCell name, ConstCell sig) {
	return new ConstValue(CONSTANT_NAMEANDTYPE, name, sig, env);
  }
  public ConstValue mkNape(String name, String sig) {
	return mkNape(FindCellAsciz(name), FindCellAsciz(sig));
  }

  public void setSourceFileName (String name) {
	 source_cell=FindCellAsciz(name);
	 SourceFile_cell=FindCellAsciz("SourceFile");
  }

  public FieldData addField (int access, ConstValue nape) {
env.traceln("addField #"+nape.left().arg+":#"+nape.right().arg);
	FieldData res=new FieldData(this, access, nape);
	fields.addElement(res);
	return res;
  }

  public FieldData addField (int access, ConstCell name, ConstCell sig) {
	return addField(access, mkNape(name, sig));
  }

  public FieldData addField(int access, String name, String type) {
	return addField(access, FindCellAsciz(name), FindCellAsciz(type));
  }

  public ConstCell LocalFieldRef(FieldData field) {
	return FindCell(CONSTANT_FIELD, me, FindCell(field.nape));
  }

  public ConstCell LocalFieldRef(ConstValue nape) {
	return FindCell(CONSTANT_FIELD, me, FindCell(nape));
  }

  public ConstCell LocalFieldRef(ConstCell name, ConstCell sig) {
	return LocalFieldRef(mkNape(name, sig));
  }

  public ConstCell LocalFieldRef(String name, String sig) {
	return LocalFieldRef(FindCellAsciz(name), FindCellAsciz(sig));
  }

  MethodData curMethod;

  public MethodData StartMethod (int access, ConstValue nape, Vector exc_table) {
	EndMethod();
env.traceln("StartMethod #"+nape.left().arg+":#"+nape.right().arg);
	curMethod=new MethodData(this, access, nape, exc_table);
	methods.addElement(curMethod);
	return  curMethod;
 }

  public MethodData StartMethod (int access, ConstCell name
			, ConstCell sig, Vector exc_table) {
	return StartMethod(access,  mkNape(name, sig), exc_table);
  }

  public void EndMethod() {
	if (curMethod==null) return;
	curMethod.Close();
	curMethod=null;
  }

  public ConstCell LocalMethodRef(ConstValue nape) {
	return FindCell(CONSTANT_METHOD, me, FindCell(nape));
  }

  public ConstCell LocalMethodRef(ConstCell name, ConstCell sig) {
	return LocalMethodRef(mkNape(name, sig));
  }

  void addLocVarData(int opc, Argument arg) {
  }

  public void endClass() {
	if (source_cell==null) setSourceFileName(env.getSource());
	CheckGlobals();
	NumberizePool();
  }

  /*---------------------------------------- Sugar */
  public ConstCell FindCell(int tag, Object value) {
	return FindCell(new ConstValue(tag, value, env));
  }
  public ConstCell FindCell(int tag, ConstCell left,  ConstCell right) {
	return FindCell(tag, new CellPair(left, right, env));
  }

  public ConstCell FindCell(int tag, ConstValue left,  ConstValue right) {
	return FindCell(tag, new CellPair(FindCell(left), FindCell(right), env));
  }

  public ConstCell FindCellAsciz(String str) {//throws CompilerError  {
	return FindCell(CONSTANT_UTF8, str);
  }
  public ConstCell FindCellClassByName(String name) {//throws CompilerError  {
	return FindCell(CONSTANT_CLASS, FindCellAsciz(name));
  }


 /*---------------------------------------- Write */
  public void write(DataOutputStream out) throws IOException {

	// Write the header
	out.writeInt(JAVA_MAGIC);
	out.writeShort(minor_version);
	out.writeShort(JAVA_VERSION);

	// Write the constant pool
	int length=pool.size();
	out.writeShort(length);
	int i;
env.traceln("wr.pool:size="+pool.size());
	for (i=1; i<pool.size(); ) {
		ConstCell cell=(ConstCell)pool.elementAt(i);
		ConstValue value=cell.ref;
                if (cell.arg!= i) 
                   throw new CompilerError("Cell["+i+"] has #"+cell.arg);
		value.write(out);
		i+=value.size();
	}

	out.writeShort(access); // & MM_CLASS; // Q
	out.writeShort(me.arg);
	out.writeShort(father.arg);

	// Write the interface names
	int interfaces_length=interfaces.size();
	out.writeShort(interfaces_length);
	for (i = 0 ; i < interfaces_length; i++) {
		out.writeShort(((Argument)interfaces.elementAt(i)).arg);
	}

	// Write the fields
	int nfields = fields.size();
	out.writeShort(nfields);
	for (i = 0; i<nfields; i++) {
		((FieldData)fields.elementAt(i)).write(out);
	}

	// Write the methods
	int nmethods = methods.size();
	out.writeShort(nmethods);
	for (i = 0 ; i < nmethods ; i++) {
		((MethodData)methods.elementAt(i)).write(out);
	}

	// Write the attributes
	if (source_cell==null) {
		out.writeShort(0);
	} else {
		out.writeShort(1);
		out.writeShort(SourceFile_cell.arg);
		out.writeInt(2);
		out.writeShort(source_cell.arg);
	}

  } // end ClassData.write()

  public void write(OutputStream out) throws IOException {//, CompilerError {
	write(new DataOutputStream(out));
  }

}// end class ClassData

