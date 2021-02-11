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

class FieldData implements Constants {
  ClassData cls;
  int access;
  ConstValue nape;
  Argument value_cpx, SourceFile_cpx;

  public FieldData(ClassData cls, int access, ConstValue nape) {
	this.cls=cls;
	this.access=access;
	this.nape=nape;
  }

  public void SetValue(Argument value_cpx) {
	this.value_cpx=value_cpx;
	this.SourceFile_cpx=cls.FindCellAsciz("ConstantValue");
  }

  public void write(DataOutputStream out) 
		 throws IOException, CompilerError {
	out.writeShort(access);
	out.writeShort(nape.left().arg);
	out.writeShort(nape.right().arg);

	if (value_cpx==null) {
		out.writeShort(0); // natt
	} else {
		out.writeShort(1); // natt
		out.writeShort(SourceFile_cpx.arg);
		out.writeInt(2); // attr len
		out.writeShort(value_cpx.arg);
	}
  }

} // end FieldData

