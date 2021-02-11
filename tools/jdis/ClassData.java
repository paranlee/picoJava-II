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

import com.sun.picojava.jasm.Tables;
import java.util.*;
import java.io.*;

/**
 * Central data repository of the Java Disassembler
 */

class ClassData implements com.sun.picojava.jasm.Constants {
  String pkgPrefix=""; int pkgPrefixLen=0;
  byte types[];
  Object cpool[];
  protected int length; //The number of elements in the buffer
  Hashtable indexHashAscii = new Hashtable();

  short minor_version, version;
  short access;
  short this_cpx;
  short super_cpx;
  short source_cpx=0;
  short[] interfaces;
  Vector fields; //FieldData
  Vector methods; // MethodData
  Vector attrs; // AttrData
  public boolean DebugFlag=false;
  public boolean mayaFlag=false;

  public static final int PR_CP=1; // print Constant Pool
  public static final int PR_LNT=2; // print Line Number table
  public static final int PR_PC=4;  // print Program Counter - for all instr
  public static final int PR_LABS=8;  // print Labels (as identifiers)
  public static final int PR_CPX=16;  // print CP indeX along with arguments
  public static final int PR_SRC=32;  // print Source Line as comment

  public ClassData() {
  }

  public ClassData(DataInputStream in) throws IOException {
	read(in);
  }

  public ClassData(InputStream in) throws IOException {
	this(new DataInputStream(in));
  }

  public ClassData(File in) throws IOException {
	this(new FileInputStream(in));
  }

  public ClassData(String in) throws IOException {
	this(new FileInputStream(in));
  }

/*-------------------------------------------------------- Constant Pool */

  /**
   * get a string
   */
  public String getString(int n) {
	return (n == 0) ? null : (String)cpool[n];
  }

  /**
   * get the type of constant given an index
   */
  public byte getTag(int n) {
	try{
		return types[n];
	} catch (ArrayIndexOutOfBoundsException e) {
		return (byte)100;
	}
  }

  public String TagString (int tag) {
	String res=Tables.tagName(tag);
	if (res==null)	return "BOGUS_TAG:"+tag;
	return res;
  }

  public String StringTag(int cpx) {
	byte tag=0;
	String str=null;
	try {
		if (cpx==0) throw new IndexOutOfBoundsException();
		tag=types[cpx];
		return	TagString(tag);
	} catch (IndexOutOfBoundsException e) {
		str="Incorrect CP index:"+cpx;
	}
	return str;
  }

  public String getName(int cpx) {
	try {
		return ((String)cpool[cpx]); //.replace('/','.');
	} catch (ArrayIndexOutOfBoundsException e) {
		return "<invalid constant pool index:"+cpx+">";
	} catch (ClassCastException e) {
		return "<invalid constant pool ref:"+cpx+">";
	}
  }

  public String getClassName(int cpx) {
	if (cpx==0) {
		return "#0";
	}
	int scpx;
	try {
		if (types[cpx]!=CONSTANT_CLASS) {
			return "<CP["+cpx+"] is not a Class> ";
		}
		scpx=((CPX)cpool[cpx]).cpx;
	} catch (ArrayIndexOutOfBoundsException e) {
		return "#"+cpx+"// invalid constant pool index";
	} catch (ClassCastException e) {
		return "#"+cpx+"// ERROR IN DISASSEMBLER";
	}
	String name;
	try {
		name=((String)cpool[scpx]);
	} catch (ArrayIndexOutOfBoundsException e) {
		return "class #"+scpx+"// invalid constant pool index";
	} catch (ClassCastException e) {
		return "class #"+scpx+"// invalid constant pool reference";
	}
	if (name.startsWith(pkgPrefix)) {
		return name.substring(pkgPrefixLen);
	}
	if (name.lastIndexOf(";")==-1) {
		return name;
	}
	return "\""+name+"\"";
  }

  public String StringValue(int cpx) {
	if (cpx==0) return "<ZERO>";
    int tag;
	Object x;
	String suffix="";
	try {
		tag=types[cpx];
		x=cpool[cpx];
	} catch (IndexOutOfBoundsException e) {
		return "<Incorrect CP index:"+cpx+">";
	}
	if (x==null) return "<NULL>";
	switch (tag) {
	  case CONSTANT_UTF8: {
		StringBuffer sb=new StringBuffer();
		String s=(String)x;
		sb.append('\"');
		for (int k=0; k<s.length(); k++) {
			char c=s.charAt(k);
			switch (c) {
			  case '\t': sb.append('\\').append('t'); break;
			  case '\n': sb.append('\\').append('n'); break;
			  case '\"': sb.append('\\').append('\"'); break;
			  default: sb.append(c);
			}
		}
		return sb.append('\"').toString();
	  }
	  case CONSTANT_DOUBLE: {
		Double d=(Double)x;
		if (d.isNaN()||d.isInfinite()) {
			return d.toString();
		}
		return d.toString()+"d";
	}
	  case CONSTANT_FLOAT: {
		Float f=(Float)x;
		if (f.isNaN()||f.isInfinite()) {
			return f.toString();
		}
		return f.toString()+"f";
	}
	  case CONSTANT_LONG:
		return ((Long)x).toString()+"L";
	  case CONSTANT_INTEGER:
		return ((Integer)x).toString();
	  case CONSTANT_CLASS:
                String temp;
                temp = getClassName(cpx);
                if (temp.charAt(temp.length()-1)== ';') {
		   return ("\""+temp+"\"");
                }
                else
                   return temp;
	  case CONSTANT_STRING:
		return StringValue(((CPX)x).cpx);
	  case CONSTANT_FIELD:
	  case CONSTANT_METHOD:
	  case CONSTANT_INTERFACEMETHOD:
		return getClassName(((CPX2)x).cpx1)+"."+StringValue(((CPX2)x).cpx2);
	  case CONSTANT_NAMEANDTYPE: 
		return getName(((CPX2)x).cpx1)+":"+StringValue(((CPX2)x).cpx2);
	  default:
		return "UnknownTag"; //TBD
	}
  }

  void PrintConstant(int cpx, PrintStream out) {
	byte tag=0;
	try {
		tag=getTag(cpx);
	} catch (IndexOutOfBoundsException e) {
		out.println("<Incorrect CP index:"+cpx+">");
		return;
	}
	switch (tag) { // & CONSTANT_POOL_ENTRY_TYPEMASK) { Q
      case CONSTANT_METHOD:
	  case CONSTANT_INTERFACEMETHOD:
      case CONSTANT_FIELD: {
		CPX2 x=(CPX2)(cpool[cpx]);
		if (x.cpx1 == this_cpx) {
		 // don't print class part for local references
			cpx=x.cpx2;
		}
	  }
    }
	out.print(TagString(tag)+" "+StringValue(cpx));
  }

  int PrintConstantEntry(int cpx, PrintStream out) {
	int size=1;
	byte tag=0;
	try {
		tag=getTag(cpx);
	} catch (IndexOutOfBoundsException e) {
		out.println("#"+cpx+" = <Incorrect CP index>");
		return 1;
	}
 	out.print("#"+cpx+" = "+StringTag(cpx)+"\t");
	Object x=cpool[cpx];
	if (x==null) {
		switch (tag) {
		  case CONSTANT_LONG:
		  case CONSTANT_DOUBLE:
			size=2;
		}
		out.println("null;");
		return size;
	}
	String str=StringValue(cpx);
	switch (tag) {
	  case CONSTANT_CLASS:
	  case CONSTANT_STRING:
		out.println("#"+(((CPX)x).cpx)+";\t//  "+str);
		break;
	  case CONSTANT_FIELD:
	  case CONSTANT_METHOD:
	  case CONSTANT_INTERFACEMETHOD:
		out.println("#"+((CPX2)x).cpx1+".#"+((CPX2)x).cpx2+";\t//  "+str);
		break;
	  case CONSTANT_NAMEANDTYPE:
		out.println("#"+((CPX2)x).cpx1+":#"+((CPX2)x).cpx2+";\t//  "+str);
		break;
	  case CONSTANT_LONG:
	  case CONSTANT_DOUBLE:
		size=2;
	  default:
		out.println(str+";");
	}
	return size;
  }

  public void printCP(PrintStream out) throws IOException {
	int cpx = 1 ;
	 while (cpx < length) {
		out.print("const ");
		cpx+=PrintConstantEntry(cpx, out);
	}
	out.println();
  }
 
  void readCP(DataInputStream in) throws IOException {
	length=in.readShort();
	types = new byte[length];
	cpool = new Object[length];
traceln("CP len="+length);
	for (int i = 1 ; i < length ; i++) {
	    byte tag = in.readByte();
traceln("CP entry #"+i+" tag="+tag);
	    switch(types[i] = tag) {
	      case CONSTANT_UTF8:
	    String str=in.readUTF();
	    indexHashAscii.put(cpool[i] = str, new Integer(i));
		break;
	      case CONSTANT_INTEGER:
		cpool[i] = new Integer(in.readInt());
		break;
	      case CONSTANT_FLOAT:
		cpool[i] = new Float(in.readFloat());
		break;
	      case CONSTANT_LONG:
		cpool[i++] = new Long(in.readLong());
		break;
	      case CONSTANT_DOUBLE:
		cpool[i++] = new Double(in.readDouble());
		break;
	      case CONSTANT_CLASS:
	      case CONSTANT_STRING:
		cpool[i] = new CPX(in.readShort());
		break;
		
	      case CONSTANT_FIELD:
	      case CONSTANT_METHOD:
	      case CONSTANT_INTERFACEMETHOD:
	      case CONSTANT_NAMEANDTYPE:
		cpool[i] = new CPX2(in.readShort(), in.readShort());
		break;

	      case 0:
	      default:
		throw new ClassFormatError("invalid constant type: " + (int)types[i]);
	    }
	}
  }

/*---------------------------------------------------------------------------*/
  TextLines source=null;

  public String getSrcLine (int lnum) {
	if (source==null) return null;  // impossible call
	String line;
	try {
		line=source.getLine(lnum);
	} catch (ArrayIndexOutOfBoundsException e) {
		line="Line number "+lnum+" is out of bounds";
	}
	return line;
  }

/*---------------------------------------------------------------------------*/
  public void read(DataInputStream in) throws IOException {
	// Read the header
	int magic = in.readInt();
	if (magic != JAVA_MAGIC) {
	    throw new ClassFormatError("wrong magic: " + magic + ", expected " + JAVA_MAGIC);
	}
	minor_version = in.readShort();
	version = in.readShort();
	if (version != JAVA_VERSION) {
	    throw new ClassFormatError("wrong version: " + version + ", expected " + JAVA_VERSION);
	}

	// Read the constant pool
	readCP(in);

	access = in.readShort(); // & MM_CLASS; // Q
	this_cpx = in.readShort();
	super_cpx = in.readShort();
traceln("access="+access+" this_cpx="+this_cpx+" super_cpx="+super_cpx);

	// Read the interface names
	int numinterfaces = in.readShort();
traceln("numinterfaces="+numinterfaces);
	interfaces = new short[numinterfaces];
	for (int i = 0 ; i < numinterfaces ; i++) {
		short intrf_cpx=in.readShort();
traceln("  intrf_cpx["+i+"]="+intrf_cpx);
	    interfaces[i]=intrf_cpx;
	}

	// Read the fields
	int nfields = in.readShort();
traceln("nfields="+nfields);
	fields=new Vector(nfields);
	for (int i = 0 ; i < nfields ; i++) {
		FieldData field=new FieldData(this);
		field.read(in);
		fields.addElement(field);
	}

	// Read the methods
	int nmethods = in.readShort();
traceln("nmethods="+nmethods);
	methods=new Vector(nmethods);
	for (int i = 0 ; i < nmethods ; i++) {
		MethodData method=(MethodData)new MethodData(this);
		method.read(in);
		methods.addElement(method);
	}

	// Read the attributes
	int natt = in.readShort();
traceln("natt="+natt);
	attrs=new Vector(natt);
	for (int i = 0 ; i < natt ; i++) {
		short name_cpx=in.readShort();
		if (getTag(name_cpx)==CONSTANT_UTF8
			&& getString(name_cpx).equals("SourceFile")
		){	if (in.readInt()!=2) 
				throw new ClassFormatError("invalid attr length");
			source_cpx=in.readShort();
		} else {
			AttrData attr=new AttrData(this);
			attr.read(name_cpx, in);
			attrs.addElement(attr);
		}
	}
  } // end ClassData.read()

  public void read(File in) throws IOException {
	read(new DataInputStream(new FileInputStream(in)));
  }

  public void read(String in) throws IOException {
	read(new DataInputStream(new FileInputStream(in)));
  }

/*---------------------------------------------------------------------------*/
  void printAccess(int access, PrintStream out) {
	out.print(
		((access & ACC_PUBLIC)    !=0? "public " : "") +
		((access & ACC_PRIVATE)   !=0? "private " : "") +
		((access & ACC_PROTECTED) !=0? "protected " : "") +
		((access & ACC_STATIC)    !=0? "static " : "") +
		((access & ACC_TRANSIENT) !=0? "transient " : "") +
		((access & ACC_SYNCHRONIZED) !=0? "synchronized " : "") +
		((access & ACC_ABSTRACT)  !=0? "abstract " : "") +
		((access & ACC_NATIVE)    !=0? "native " : "") +
		((access & ACC_VOLATILE)  !=0? "volatile " : "") +
		((access & ACC_FINAL)     !=0? "final " : "" )+
		((access & ACC_INTERFACE) !=0? "interface " : "" )+
		((access & ACC_VOLATILE)  !=0? "volatile " : "") );
  }

  public void print(int printOptions, PrintStream out) throws IOException {
	int k,l,m,n;

        // Write the header
	String classname=getClassName(this_cpx);
	pkgPrefixLen=classname.lastIndexOf("/")+1;
	if (pkgPrefixLen!=0) {
		pkgPrefix=classname.substring(0,pkgPrefixLen);
		out.println("package  "+pkgPrefix.substring(0,pkgPrefixLen-1)+";\n");
		classname=getClassName(this_cpx);
	}
        access=(short)(access & 0xFFDF); // Mask out ACC_SUPER - FY 09/22/97 //
	printAccess(access, out); // & MM_CLASS; // Q
	out.print("class "+classname);
	if (super_cpx!=0) {
		String superclassname=getClassName(super_cpx);
		if (!superclassname.equals("java/lang/Object")) {
			out.print(" extends "+superclassname);
		}
	}
	l=interfaces.length;
	if (l>0) {
		out.print("\n\timplements ");
		for (k=0; k<l; k++) {
			out.print(getClassName(interfaces[k]));
			if (k<l-1) out.print(", ");
		}
		out.println();
	} else {
		out.print(" ");
	}
	out.println("{");

	if (source_cpx!=0) {
		String source_name=getName(source_cpx);
		out.println("\t// Compiled from "+source_name);
		try {
			source = new TextLines(source_name);
		} catch (IOException e) {
		}
	}
	out.println("\t// Compiler version "+minor_version+"."+version+";");
	out.println();


	// Print the constant pool
	if ((printOptions&PR_CP)!=0) printCP(out);

	// Print the fields
	for (int i = 0 ; i < fields.size() ; i++) {
		((FieldData)fields.elementAt(i)).print(printOptions, out);
	}

	// Print the methods
	for (int i = 0 ; i < methods.size() ; i++) {
		((MethodData)methods.elementAt(i)).print(printOptions, out);
	}

	out.println();
	out.println("} // end Class "+classname);

  } // end ClassData.print()


/*---------------------------------------------------------------------------*/
  public void trace(String s) {
	if (!DebugFlag) return;
	System.out.print(s);
  }
  public void traceln(String s) {
	if (!DebugFlag) return;
	System.out.println(s);
  }

}// end class ClassData
