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

class CellPair {
  ConstCell left, right;
  SourceFile env;

  CellPair(ConstCell left, ConstCell right, SourceFile env) {
	this.left=left;
	this.right=right;
	this.env=env;
  }

  public int hashCode() {
	return left.hashCode()*right.hashCode();
  }

  public boolean equals(Object obj) {
	if (obj == null) 	return false;
	if (!(obj instanceof CellPair)) return false;
	CellPair dobj=(CellPair)obj;
	boolean res = (dobj.left==left)&&(dobj.right==right);
	return res;
  }

  public String toString() {
	return "{"+left+","+right+"}";
  }

}

