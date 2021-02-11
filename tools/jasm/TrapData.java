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

class TrapData {
static final int NotSet=-1;
  Trap trap;
  int handler_pc;
  Argument catchType;

  public TrapData(Trap trap, int handler_pc, Argument catchType) {
	this.trap=trap;
	this.handler_pc=handler_pc;
	this.catchType=catchType;
  }

  public void write(DataOutputStream out, SourceFile env) throws IOException {
env.traceln("   TrapData:#"+trap.start_pc+":"+trap.end_pc+":"+handler_pc);
	out.writeShort(trap.start_pc);
	out.writeShort(trap.end_pc);
	out.writeShort(handler_pc);
	out.writeShort(catchType.arg);
  }
}  // end TrapData


