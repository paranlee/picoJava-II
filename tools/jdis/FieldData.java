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

import java.io.*;
import java.util.*;

class FieldData implements com.sun.picojava.jasm.Constants {
  short access;
  short name_cpx;
  short sig_cpx;
  short value_cpx=0;
  Vector attrs; // AttrData
  ClassData cls;

  public FieldData(ClassData cls) {
	this.cls=cls;
  }

  public void read(DataInputStream in) throws IOException {
	access = in.readShort();
	name_cpx = in.readShort();
	sig_cpx = in.readShort();
	// Read the attributes
	int natt = in.readShort();
cls.traceln(" field: name_cpx="+name_cpx+" sig_cpx="+sig_cpx+" natt="+natt);
	attrs=new Vector(natt);
	for (int i = 0 ; i < natt ; i++) {
		short name_cpx=in.readShort();
		if (cls.getTag(name_cpx)==CONSTANT_UTF8
			&& cls.getString(name_cpx).equals("ConstantValue")
		){	if (in.readInt()!=2) 
			     throw new ClassFormatError("invalid attr length");
cls.traceln("    _init: name_cpx="+name_cpx+" tag="+cls.getTag(name_cpx));
			value_cpx=in.readShort();
		} else {
cls.traceln("    fieldattr: name_cpx="+name_cpx+" tag="+cls.getTag(name_cpx));
			AttrData attr=new AttrData(cls);
			attr.read(name_cpx, in);
			attrs.addElement(attr);
		}
	}
  }  // end read

  public void print(int printOptions, PrintStream out) throws IOException {
	((ClassData)cls).printAccess(access, out);
	out.print("Field ");
	out.print(cls.getName(name_cpx)+":\""+cls.getName(sig_cpx)+"\"");
	if (value_cpx!=0) {
		out.print("\t= "); cls.PrintConstant(value_cpx, out);
	}
	out.println(";");
  }

} // end FieldData

