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

class AttrData {
  short name_cpx;
  byte data[];
  ClassData cls;

  public AttrData (ClassData cls) {
	this.cls=cls;
  }

  public void read(short name_cpx, DataInputStream in) throws IOException {
	this.name_cpx=name_cpx;
	int datalen=in.readInt();
	data=new byte[datalen];
	in.readFully(data);
  }

}

