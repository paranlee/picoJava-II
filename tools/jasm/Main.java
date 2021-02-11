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

import java.util.*;
import java.io.*;

public class Main implements Constants {
    /**
     * Name of the program.
     */
    String program;

    /**
     * The stream where error message are printed.
     */
    PrintStream out;

	int nerrors=0;

  /**
   * Constructor.
   */
  public Main(PrintStream out, String program) {
	this.out = out;
	this.program = program;
  }

  /**
   * Top level error message
   */
  public void error(String msg) {
	nerrors++;
	out.println(program + ": " + msg);
  }
    
  /**
   * Usage
   */
  public void usage() {
	out.println("Usage: " + program + " [options] file.jasm...");
	out.println("where options are: ");
	out.println("     -g           add debug information");
	out.println("     -nowrite     do not write resulting .class files");
	out.println("     -d destdir   directory to place resulting .class files");
  }
    
  /**
   * Run the compiler
   */
  public synchronized boolean compile(String argv[]) {
	File destDir = null;
	boolean traceFlag = false;
	boolean debugInfoFlag = false;
        boolean mayaFlag = false;
	long tm = System.currentTimeMillis();
	Vector v = new Vector();
	boolean nowrite = false;
	String props = null;
	int nwarnings=0;

	// Parse arguments
	for (int i = 0 ; i < argv.length ; i++) {
	    if (argv[i].equals("-v")) {
			traceFlag = true;
	    } else if (argv[i].equals("-g")) {
			debugInfoFlag = true;
            } else if (argv[i].equals("-maya")) {
                        mayaFlag = true;
	    } else if (argv[i].equals("-nowrite")) {
			nowrite = true;
	    } else if (argv[i].equals("-d")) {
			if ((i + 1) < argv.length) {
			    destDir = new File(argv[++i]);
			    if (!destDir.exists()) {
					error(destDir.getPath() + " does not exist");
					return false;
			    }
			} else {
			    error("-d requires argument");
			    usage();
			    return false;
			}
	    } else if (argv[i].startsWith("-")) {
			error("invalid flag: " + argv[i]);
			usage();
			return false;
	    } else {
			v.addElement(argv[i]);
	    }
	}
	if (v.size() == 0) {
	    usage();
	    return false;
	}
	    // compile all input files
	try{ for (Enumeration e = v.elements(); e.hasMoreElements();) {
		String inpname = (String)e.nextElement();
		SourceFile sf;
		Jasm p;
		try {
			sf=new SourceFile(new File(inpname), out);
			sf.traceFlag=traceFlag;
			sf.debugInfoFlag=debugInfoFlag;
                        sf.mayaFlag=mayaFlag;
			p = new Jasm(sf);
			p.parse();
			sf.closeInp();
		} catch(FileNotFoundException ex) {
		    error("cannot read "+inpname);
			continue;
		}
		nerrors+=sf.nerrors;
		nwarnings+=sf.nwarnings;
		if (nowrite||(nerrors > 0)) continue;
		try {
			p.write(destDir);
		} catch(FileNotFoundException ex) {
		    error("cannot write "+ex.getMessage());
		}
	}} catch (Error ee) {
	    ee.printStackTrace();
	    error("fatal error");
	} catch (Exception ee) {
	    ee.printStackTrace();
	    error("fatal exception");
	}

	boolean errs = nerrors > 0;
	boolean warns = nwarnings > 0;
	if (!errs && !warns) {
		return true;
	}
	out.println(errs?(nerrors>1? (nerrors+" errors"):"1 error"):""
	    +((errs&&warns)?", ":"")
	    +(warns?(nwarnings>1? (nwarnings+" warnings"):"1 warning"):"")
	   );
	return !errs;
  }

  /**
   * main program
   */
  public static void main(String argv[]) {
	Main compiler = new Main(System.out, "jasm");
	System.exit(compiler.compile(argv) ? 0 : 1);
  }

}

