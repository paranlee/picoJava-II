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

public class TextLines {
  byte data[];
  // ends[k] points to the end of k-th line
  iVector ends=new iVector (60);
  public int length;

  public TextLines () {
  }

  public TextLines (String textfilename) throws IOException {
	read(textfilename);
  }

  public void read(String textfilename) throws IOException {
	FileInputStream in = new FileInputStream(textfilename);
	data = new byte[in.available()];
	in.read(data);
	in.close();
	ends.addElement(-1);
	for (int k=0; k<data.length; k++) {
		if (data[k]=='\n') ends.addElement(k);
	}
	length=ends.size(); // but if text is empty??
  }

  public String getLine(int linenumber) {
	int start=ends.elementAt(linenumber-1)+1;
	int end;
	searchEnd:
	for (end=start; end<data.length; end++) {
	  switch (data[end]) {
		case '\n': case '\r': break searchEnd;
	  }
	}
	return new String(data, start, end-start);
  }

}

