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

class TrapData {
  short start_pc, end_pc, handler_pc, catch_cpx;
  int num;

  public TrapData() {}

  public TrapData(DataInputStream in, int num) throws IOException {
	this.num=num;
	read(in);
  }

  public void read(DataInputStream in) throws IOException {
	start_pc = in.readShort();
	end_pc=in.readShort();
	handler_pc=in.readShort();
	catch_cpx=in.readShort();
  }
}
