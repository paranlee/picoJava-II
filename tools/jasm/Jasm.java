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

/**
 *  Compiles just 1 source file
 */
class Jasm extends Parser {

  public Jasm (SourceFile sf) throws IOException {
	super(sf);
  }

  public void parse () {
	Classes=super.parseFile();
  }  // end parse()

  /**
   * Writes the class
   */
  public void write (File destdir) throws IOException {
    for (Enumeration en = Classes.elements(); en.hasMoreElements();) {
	ClassData cls=(ClassData)en.nextElement();
	String myname=cls.name();
	if (myname==null) {
		env.error("cannot.write", null);
		return;
	}
env.traceln("writing class "+myname);
	File outfile;
	if (destdir == null) {
		int startofname=myname.lastIndexOf("/");
		if (startofname != -1) {
			myname=myname.substring(startofname+1);
		}
		outfile=new File(myname+".class");
	} else {
env.traceln("writing -d "+destdir.getPath());
		outfile=new File(destdir, myname+".class");
		File outdir=new File(outfile.getParent());
		if (!outdir.exists() && !outdir.mkdirs()) {
			env.error("cannot.write", outdir.getPath());
			return;
		}
	}

	OutputStream out=
           new BufferedOutputStream(new FileOutputStream(outfile));
	cls.write(out);
	try{ out.close();
	} catch (IOException e) {
	}
    }
  }  // end write()

} // end Jasm

