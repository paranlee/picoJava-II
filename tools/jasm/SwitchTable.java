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
import java.util.Vector;

class SwitchTable {
  Argument deflabel=null;
  Vector labels=new Vector();
  iVector keys=new iVector();
  int pc, pad;
  SourceFile env;

  SwitchTable(SourceFile env) {
	this.env=env;
  }

  void addEntry(int key, Argument label) {
	keys.addElement(key);
	labels.addElement(label);
  }

// for lookupswitch:
  int calcLookupSwitch(int pc) {
	this.pc=pc;
	pad=((3-pc) & 0x3);
	int len=1+pad+(keys.length+1)*8;
	if (deflabel==null) {
		deflabel=new Argument(pc+len);
	}
	return len;
  }

  void writeLookupSwitch(DataOutputStream out) throws IOException {
env.traceln("  writeLookupSwitch: pc="+pc+" pad="+pad+" deflabel="+deflabel.arg);
	int k;
	for (k=0; k<pad; k++) out.writeByte(0);
	out.writeInt(deflabel.arg-pc);
	out.writeInt(keys.length);
	for (k=0; k<keys.length; k++) {
		out.writeInt(keys.data[k]);
		out.writeInt(((Argument)labels.elementAt(k)).arg-pc);
	}
  }

// for tableswitch:
  Argument[] resLabels;  
  int high, low;

  int recalcTableSwitch(int pc) {
	int k;
	int numpairs=keys.length;
	int high=Integer.MIN_VALUE, low=Integer.MAX_VALUE;
	int numslots=0;
	if  (numpairs>0) {
		for (k=0; k<numpairs; k++) {
			int key=keys.data[k];
			if (key>high) high=key;
			if (key<low) low=key;
		}
		numslots=high-low+1;
	}
env.traceln("  recalcTableSwitch: low="+low+" high="+high);
	this.pc=pc;
	pad=((3-pc) & 0x3);
	int len=1+pad+(numpairs+3)*4;
	if (deflabel==null) {
		deflabel=new Argument(pc+len);
	}
	Argument[] resLabels=new Argument[numslots];
	for (k=0; k<numslots; k++) resLabels[k]=deflabel;
	for (k=0; k<numpairs; k++) {
env.traceln("   keys.data["+k+"]="+keys.data[k]);
		resLabels[keys.data[k]-low]=(Argument)labels.elementAt(k);
	}
	this.resLabels=resLabels;
	this.labels=null;
	this.keys=null;
	this.high=high;
	this.low=low;
	return len;
  }
		
  void writeTableSwitch(DataOutputStream out) throws IOException {
	int k;
	for (k=0; k<pad; k++) out.writeByte(0);
	out.writeInt(deflabel.arg-pc);
	out.writeInt(low);
	out.writeInt(high);
	for (k=0; k<resLabels.length; k++) {
		out.writeInt(resLabels[k].arg-pc);
	}
  }

}



