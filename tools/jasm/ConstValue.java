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

class ConstValue implements Constants {
  int tag;
  Object value;
  SourceFile env;

  static void check (int tag, Object value) { // throws CompilerError {
	switch (tag) {
	  case CONSTANT_UTF8:
		if (value instanceof String) return;
		break;
	  case CONSTANT_INTEGER:
	  case CONSTANT_FLOAT:
	  case CONSTANT_LONG:
	  case CONSTANT_DOUBLE:
		if (value instanceof Number) return;
		break;
	  case CONSTANT_CLASS:
	  case CONSTANT_STRING:
		if (value instanceof ConstCell) return;
		break;
	  case CONSTANT_FIELD:
	  case CONSTANT_METHOD:
	  case CONSTANT_INTERFACEMETHOD:
	  case CONSTANT_NAMEANDTYPE:
		if (value instanceof CellPair) return;
		break;
	}
	throw new Error("tag and type mismatch");
  }

  public ConstValue (int tag, Object value, SourceFile env) {
	check(tag, value);
	this.tag=tag;
	this.value=value;
	this.env=env;
  }

  public ConstValue (int tag, SourceFile env) {
	this.tag=tag;
	this.value=null;
	this.env=env;
  }

  public ConstValue (int tag, ConstCell left, ConstCell right, SourceFile env){
	this(tag, new CellPair(left, right, env),env);
  }

  public int size() {
	switch (tag) {
	  case CONSTANT_LONG:
	  case CONSTANT_DOUBLE:
		return 2;
	  default:
		return 1;
	}
  }

  public ConstCell left() {
	return ((CellPair)value).left;
  }

  public ConstCell right() {
	return ((CellPair)value).right;
  }

boolean vizited=false;
  public int hashCode() {
	if (value == null) 	return 37;
        if (vizited) throw new CompilerError("CV hash:"+this);
        vizited=true;
	int res = value.hashCode()+tag*1023;
        vizited=false;
	return res;
  }

  /**
   * Compares this object to the specified object.
   * @param obj   the object to compare with
   * @return    true if the objects are the same; false otherwise.
   */
  public boolean equals(Object obj) {
	if (obj == null) 	return false;
	if (!(obj instanceof ConstValue)) return false;
	ConstValue dobj=(ConstValue)obj;
	if (dobj.tag!=tag) return false;
	boolean res = value.equals(dobj.value);
	return res;
  }

  public String TagString (int tag) {
	switch	(tag) {
	  case CONSTANT_UTF8:
		return	"Asciz";
	  case CONSTANT_INTEGER:
		return	"Integer";
	  case CONSTANT_FLOAT:
		return	"Float";
	  case CONSTANT_LONG:
		return	"Long";
	  case CONSTANT_DOUBLE:
		return	"Double";
	  case CONSTANT_CLASS:
		return	"Class";
	  case CONSTANT_STRING:
		return	"String";
	  case CONSTANT_FIELD:
		return	"Field";
	  case CONSTANT_METHOD:
		return	"Method";
	  case CONSTANT_INTERFACEMETHOD:
		return	"InterfaceMathod";
	  case CONSTANT_NAMEANDTYPE:
		return	"NameAndType";
	  default:
		return null;
	}
  }

  public String StringTag() {
	String str=null;
	if ((str=TagString(tag))==null) {
		return "BOGUS_TAG:"+tag;
	}
	return str;
  }

  public String toString() {
	String str=null;
	if ((str=TagString(tag))==null) {
		return "BOGUS_TAG:"+tag;
	}
	return "<"+StringTag()+" "+value+">";
  }

  public void write(DataOutputStream out) throws IOException {
	out.writeByte(tag);
	switch (tag) {
	  case CONSTANT_UTF8:
		out.writeUTF((String) value);
		break;
	  case CONSTANT_INTEGER:
		out.writeInt(((Number)value).intValue());
		break;
	  case CONSTANT_FLOAT:
		out.writeFloat(((Number)value).floatValue());
		break;
	  case CONSTANT_LONG:
		out.writeLong(((Number)value).longValue());
		break;
	  case CONSTANT_DOUBLE:
		out.writeDouble(((Number)value).doubleValue());
		break;
	  case CONSTANT_CLASS:
	  case CONSTANT_STRING:
		out.writeShort(((ConstCell)value).arg);
		break;
	  case CONSTANT_NAMEANDTYPE:
	  case CONSTANT_FIELD:
	  case CONSTANT_METHOD:
	  case CONSTANT_INTERFACEMETHOD:
		CellPair pair = (CellPair)value;
		out.writeShort(pair.left.arg);
		out.writeShort(pair.right.arg);
		break;
	 default:
		throw new CompilerError("tag and value type mismatch");
	 }
	return;
  }
} // end ConstValue

