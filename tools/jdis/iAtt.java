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

class iAtt { // instruction attributes
  short lnum=0;
  boolean referred=false; // from some other instruction
  Vector vars;
  Vector endvars;
  Vector handlers;
  Vector traps;
  Vector endtraps;
  ClassData cls;

  public iAtt(ClassData cls) {
	this.cls=cls;
 }

  void add_var(LocVarData var) {
	if (vars==null) vars=new Vector(4);
	vars.addElement(var);
  }

  void add_endvar(LocVarData endvar) {
	if (endvars==null) endvars=new Vector(4);
	endvars.addElement(endvar);
  }

  void add_trap(TrapData trap) {
	if (traps==null) traps=new Vector(4);
	traps.addElement(trap);
  }

  void add_endtrap(TrapData endtrap) {
	if (endtraps==null) endtraps=new Vector(4);
	endtraps.addElement(endtrap);
  }

  void add_handler(TrapData endtrap) {
	if (handlers==null) handlers=new Vector(4);
	handlers.addElement(endtrap);
  }

  public void printEnds (PrintStream out) throws IOException {
  // prints additional information for instruction:
  //  end of local variable and trap scopes; 
	int k, len;
	if (endvars!=null) {
		len=endvars.size();
		out.print("\t\tendvar");
		for (k=0; ; ) {
			LocVarData line=(LocVarData)endvars.elementAt(k);
			out.print(" "+line.slot);
			if (++k==len) break;
			out.print(",");
		}
		out.println(";");
	}
	if (endtraps!=null) {
		len=endtraps.size();
		out.print("\t\tendtry");
		for (k=0; ; ) {
			TrapData line=(TrapData)endtraps.elementAt(k);
			out.print(" t"+line.handler_pc);
			if (++k==len) break;
			out.print(",");
		}
		out.println(";");
	}
  }

  public void printBegins (int printLNOptions, PrintStream out)
		 throws IOException {
  // prints additional information for instruction:
  //  source line number;
  //  start of exception handler;
  //  begin of locvar and trap scopes; 
	int k;
	if ((lnum!=0) && (printLNOptions!=0)) {
		if (printLNOptions==(ClassData.PR_LNT|ClassData.PR_SRC)) { 
			out.println("// "+lnum+": "+cls.getSrcLine(lnum));
		} else if ((printLNOptions&ClassData.PR_LNT)!=0) {
			out.print(lnum);
		} else if ((printLNOptions&ClassData.PR_SRC)!=0) {
			out.println("// "+cls.getSrcLine(lnum));
		}
	}
	out.print("\t");
	if (handlers!=null) {
		for (k=0; k<handlers.size(); k++) {
			TrapData line=(TrapData)handlers.elementAt(k);
			out.print("\tcatch t"+line.handler_pc);
			out.print(" "+cls.getClassName(line.catch_cpx)+";\n\t");
		}
	}
	if (traps!=null) {
		int len=traps.size();
		out.print("\ttry");
		for (k=0; ; ) {
			TrapData line=(TrapData)traps.elementAt(k);
			out.print(" t"+line.handler_pc);
			if (++k==len) break;
			out.print(",");
		}
		out.print(";\n\t");
	}
	if (vars!=null) {
		for (k=0; k<vars.size(); k++) {
			LocVarData line=(LocVarData)vars.elementAt(k);
			out.println("\tvar "+line.slot+"; // "+cls.getName(line.name_cpx));
			out.print("\t");
		}
	}
  }

}
