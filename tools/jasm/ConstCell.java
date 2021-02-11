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

class ConstCell extends Argument {
  ConstValue ref;
  String name;
  int rank=2; // 0 - highest - ref from ldc, 1 - any ref, 2 - no ref

  ConstCell(int arg, ConstValue ref) {
	this.arg=arg;
	this.ref=ref;
  }
  ConstCell(ConstValue ref) {
	this(NotSet, ref);
  }
  ConstCell(int arg) {
	this(arg, null);
  }

  public void setRank(int rank) {
	this.rank=rank;
  }

  public void set(ConstValue cv) { //throws CompilerError {
        // check:  is empty or its value equals new one
	if (ref==null) {
		ref=cv;
	} else if (!ref.equals(cv)) {
		throw new CompilerError("Constant redeclared");  //TBD
	}
  }

  public int hashCode() {
	if (arg==NotSet) return ref.hashCode();
	return arg;
  }

  public boolean equals(Object obj) {
	if (obj==null) return false;
	return obj==this;
  }


  Object value() {
	return ref.value;
  }

  public String toString() {
	return "#"+arg+"="+ref;
  }

}



