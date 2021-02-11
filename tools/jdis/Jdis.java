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

/**
 * Main program of the Java Disassembler
 */

public
class Jdis {

  public final int PR_JASM=ClassData.PR_LABS;
  public final int PR_CODE
    = ClassData.PR_CP|ClassData.PR_LNT|ClassData.PR_PC|ClassData.PR_CPX;

  /**
   * Name of the program.
   */
  String program;

  /**
   * The stream where error message are printed.
   */
  PrintStream out;

  boolean DebugFlag=false;
  boolean mayaFlag=false;

  /**
   * Constructor.
   */
  public Jdis(PrintStream out, String program) {
	this.out = out;
	this.program = program;
  }

  /**
   * Output a message.
   */
  public void output(String msg) {
	int len = msg.length();
	for (int i = 0 ; i < len ; i++) {
	   out.write(msg.charAt(i));
	}
	out.write('\n');
  }

  /**
   * Top level error message
   */
  public void error(String msg) {
      output(program + ": " + msg);
  }
    
  /**
   * Usage
   */
  public void usage() {
	output("usage: " + program + " [options] FILE.class... > FILE.jasm");
	output("     -g:  detailed output format");
	output("     -sl: source lines in comments");
  }
    
  /**
   * Run the disassembler
   */
  public synchronized boolean disasm(String argv[]) {
	long tm = System.currentTimeMillis();
	Vector v = new Vector();
	Vector vj= new Vector();
	boolean nowrite = false;
	int printOptions=PR_JASM; // by default
	int addOptions=0;

	// Parse arguments
	for (int i = 0 ; i < argv.length ; i++) {
	  String arg=argv[i];
	  if (arg.equals("-v")) {
		DebugFlag=true;
          } else if (arg.equals("-maya")) {
                mayaFlag=true;
	  } else if (arg.equals("-g")) {
		printOptions=PR_CODE; 
	  } else if (arg.equals("-sl")) {
		addOptions=ClassData.PR_SRC; 
	  } else if (arg.startsWith("-")) {
		error("invalid flag: " + arg);
		usage();
		return false;
	  } else if (arg.endsWith(".class")) {
		v.addElement(arg);
	  } else {
		error("invalid argument: " + arg);
		usage();
		return false;
	  }
	}

	if (v.size() == 0) {
		error("no .class files specified");
	    usage();
	    return false;
	}

	disasm:
	for (Enumeration e=v.elements(); e.hasMoreElements(); ) {
		String inpname=(String)e.nextElement();
		try {
			ClassData cc=new ClassData();
                        cc.mayaFlag=mayaFlag;
			cc.DebugFlag=DebugFlag;
			cc.read(new DataInputStream(new FileInputStream(inpname)));
			cc.print(printOptions|addOptions, out);
			continue disasm;
		} catch (FileNotFoundException ee) {
		    error("cant read "+inpname);
		} catch (Error ee) {
		    ee.printStackTrace();
		    error("fatal error");
		} catch (Exception ee) {
		    ee.printStackTrace();
		    error("fatal exception");
		}
		return false;
	}
	return true;
  }

  /**
   * Main program
   */
  public static void main(String argv[]) {
	Jdis disassembler = new Jdis(System.out, "jdis");
	System.exit(disassembler.disasm(argv) ? 0 : 1);
  }
}
