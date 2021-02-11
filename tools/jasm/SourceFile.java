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
import java.util.Hashtable;

/**
 * An input stream for java programs. The stream treats either "\n", "\r" 
 * or "\r\n" as the end of a line, it always returns \n. It also parses
 * UNICODE characters expressed as \uffff. However, if it sees "\\", the
 * second slash cannot begin a unicode sequence. It keeps track of the current
 * position in the input stream.
 *
 * An position consists of: ((linenr << OFFSETBITS) | offset)
 * this means that both the line number and the exact offset into
 * the file are encoded in each postion value.<p>
 *
 * @after 	Arthur van Hoff
 */

public class SourceFile implements Constants {

  boolean traceFlag=false;
  boolean debugInfoFlag=false;
  boolean mayaFlag=false;

  /**
   * The increment for each character.
   */
  protected static final int OFFSETINC = 1;

  /**
   * The increment for each line.
   */
  protected static final int LINEINC = 1 << OFFSETBITS;

  File source;
  InputStream in;
  PrintStream out;
  byte data[];
  int pos;

  private int chpos;
  private int pushBack = -1;

  public SourceFile(File source, PrintStream out) throws IOException {
	this.out=out;
	errorFileName=source.getPath();
	this.source=source;

	// Read the file
        InputStream in = new FileInputStream(source);
        data = new byte[in.available()];
	in.read(data);
	in.close();
	this.in=new ByteArrayInputStream(data);
	chpos = LINEINC;
  }

  public String getSource() {
	return source.getPath();
  }

  public void closeInp() {
	try{ in.close();
	} catch (IOException e) {
	}
	flushErrors();
  }

  public int read() throws IOException {
	pos = chpos;
	chpos += OFFSETINC;

	int c = pushBack;
	if (c == -1) {
	    c = in.read();
	} else {
	    pushBack = -1;
	}
	
	// parse special characters
	switch (c) {
	  case -2:
	    // -2 is a special code indicating a pushback of a backslash that
	    // definitely isn't the start of a unicode sequence.
	    return '\\';

	  case '\\':
	    if ((c = in.read()) != 'u') {
		pushBack = (c == '\\' ? -2 : c);
		return '\\';
	    }
	    // we have a unicode sequence
	    chpos += OFFSETINC;
	    while ((c = in.read()) == 'u') {
		chpos += OFFSETINC;
	    }
		
	    // unicode escape sequence
	    int d = 0;
	    for (int i = 0 ; i < 4 ; i++, chpos += OFFSETINC, c = in.read()) {
		switch (c) {
		  case '0': case '1': case '2': case '3': case '4':
		  case '5': case '6': case '7': case '8': case '9':
		    d = (d << 4) + c - '0';
		    break;
		    
		  case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
		    d = (d << 4) + 10 + c - 'a';
		    break;
		    
		  case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
		    d = (d << 4) + 10 + c - 'A';
		    break;
		    
		  default:
		    error(pos, "invalid.escape.char");
		    pushBack = c;
		    return d;
		}
	    }
            pushBack = c;
   	    return d;

	  case '\n':
	    chpos += LINEINC;
	    return '\n';

	  case '\r':
	    if ((c = in.read()) != '\n') {
		pushBack = c;
	    } else {
		chpos += OFFSETINC;
	    }
	    chpos += LINEINC;
	    return '\n';

	  default:
	    return c;
	}
  }

  public int lineNumber(int pos) {
	return pos>>>OFFSETBITS;
  }
  public int lineNumber() {
	return pos>>>OFFSETBITS;
  }

/*-------------------------------------------------------------  Environment */
  /**
   * The number of errors and warnings
   */
  public int nerrors;
  public int nwarnings;
  static Hashtable properties = new Hashtable(40);

  static {
	properties.put("err.not.implemented", "Sorry, %s not implemented.");
  // Scanner:
	properties.put("err.invalid.escape.char", "Invalid escape character.");
	properties.put("err.eof.in.comment", "Comment not terminated at end of input.");
	properties.put("err.invalid.number", "Invalid character \'%s\' in number.");
	properties.put("err.invalid.octal.number", "Invalid character in octal number.");	    
	properties.put("err.overflow", "Numeric overflow.");
	properties.put("err.float.format", "Invalid floating point format.");
	properties.put("err.eof.in.string", "String not terminated at end of input.");
	properties.put("err.newline.in.string", "String not terminated at end of line.");
	properties.put("err.invalid.char.constant", "Invalid character constant.");
	properties.put("err.funny.char", "Invalid character in input.");
	properties.put("err.unbalanced.paren", "Unbalanced parentheses.");
  // Parser:
	properties.put("err.package.repeated", "Package statement repeated.");
	properties.put("err.intf.repeated", "Interface %s repeated.");
	properties.put("err.multiple.inherit", "Multiple inheritance is not supported.");
	properties.put("err.intf.impl.intf", "An interface can't implement anything; it can only extend other interfaces.");
	properties.put("err.toplevel.expected", "Class or interface declaration expected.");
	properties.put("err.const.def.expected", "Constant declaration expected.");
	properties.put("err.const.undecl", "Constant #%s not declared.");
	properties.put("err.const.redecl", "Constant %s redeclared.");
	properties.put("warn.const.misused", "Constant %s was assumed to have another tag.");
	properties.put("err.field.expected", "Field or method declaration expected.");
	properties.put("warn.invalid.modifier", "This modifier is not allowed here");
	properties.put("err.repeated.modifier", "Repeated modifier.");
	properties.put("err.token.expected", "'%s' expected.");
	properties.put("err.identifier.expected", "Identifier expected.");
	properties.put("err.missing.term", "Missing term.");
	properties.put("err.name.expected", "Name expected.");
	properties.put("err.tag.expected", "Tag expected.");
	properties.put("err.value.expected", "Value expected.");
	properties.put("err.wrong.mnemocode", "Invalid mnemocode.");
	properties.put("err.class.expected", "'class' or 'interface' keyword expected.");
	properties.put("err.long.switchtable", "Switchtable too long: > %s.");
	properties.put("err.io.exception", "I/O error in %s.");
	properties.put("warn.wrong.tag", "Wrong tag: %s expected.");
        properties.put("err.byte.expected", "Value between 0 and 255 expected.");
        properties.put("err.sbyte.expected", "Value between -128 and 127 expected.");
      
  // Code Gen:
	properties.put("err.local.redecl", "Local identfier %s redeclared.");
	properties.put("err.locvar.undecl", "Local variable %s not declared.");
	properties.put("err.locvar.expected", "Local variable expected.");
	properties.put("err.label.redecl", "Label %s redeclared.");
	properties.put("err.label.undecl", "Label %s not declared.");
	properties.put("err.label.expected", "Label expected.");
	properties.put("err.type.expected", "Type expected.");
	properties.put("err.unt.expected", "Integer expected.");
	properties.put("warn.illslot", "Local variable at Illegal slot %s.");
	properties.put("warn.trap.nostart", "No <try %s> found.");
	properties.put("warn.trap.noend", "No <endtry %s> found.");
	properties.put("err.cannot.write", "Cannot write to %s.");
  }

  static String getProperty(String nm) {
	return (String)properties.get(nm);
  }

  /**
   * Error String
   */
  String errorString(String err, Object arg1, Object arg2, Object arg3) {
	String str = null;

	if (!err.startsWith("warn.")) {
	    err = "err."+err;
	}
	str = getProperty(err);
	if (str == null) {
	    return "error message '" + err + "' not found";
	}
	
	StringBuffer buf = new StringBuffer();
	for (int i = 0 ; i < str.length() ; i++) {
	    char c = str.charAt(i);
	    if ((c == '%') && (i + 1 < str.length())) {
		switch (str.charAt(++i)) {
		  case 's':
		    String arg = arg1.toString();
		    for (int j = 0 ; j < arg.length() ; j++) {
			switch (c = arg.charAt(j)) {
			  case ' ':
			  case '\t':
			  case '\n':
			  case '\r':
			    buf.append((char)c);
			    break;

			  default:
			    if ((c > ' ') && (c <= 255)) {
				buf.append((char)c);
			    } else {
				buf.append('\\');
				buf.append('u');
				buf.append(Integer.toString(c, 16));
			    }
			}
		    }
		    arg1 = arg2;
		    arg2 = arg3;
		    break;
		    
		  case '%':
		    buf.append('%');
		    break;

		  default:
		    buf.append('?');
		    break;
		}
	    } else {
		buf.append((char)c);
	    }
	}
	return buf.toString();
  }

  /**
   * The filename where the last errors have occurred
   */
  String errorFileName;

  /**
   * List of outstanding error messages
   */
  ErrorMessage errors;

  /**
   * Insert an error message in the list of outstanding error messages.
   * The list is sorted on input position.
   */
  void insertError(int where, String message) {
	ErrorMessage msg = new ErrorMessage(where, message);
	if (errors == null) {
	    errors = msg;
	} else if (errors.where > where) {
	    msg.next = errors;
	    errors = msg;
	} else {
	    ErrorMessage m = errors;
	    for (; (m.next != null) && (m.next.where <= where) ; m = m.next);
	    msg.next = m.next;
	    m.next = msg;
	}
  }

  /**
   * Flush outstanding errors
   */
  public void flushErrors() {
	if (errors == null) {
	    return;
	}
	
    // Report the errors
	for (ErrorMessage msg = errors ; msg != null ; msg = msg.next) {
	    int ln = msg.where >>> OFFSETBITS;
	    int off = msg.where & ((1 << OFFSETBITS) - 1);
	    
	    int i, j;
	    for (i = off ; (i > 0) && (data[i - 1] != '\n') && (data[i - 1] != '\r') ; i--);
	    for (j = off ; (j < data.length) && (data[j] != '\n') && (data[j] != '\r') ; j++);

	    String prefix = errorFileName + ":" + ln + ":";
	    outputln(prefix + " " + msg.message);
	    outputln(new String(data, i, j - i));

	    char strdata[] = new char[(off - i) + 1];
	    for (j = i ; j < off ; j++) {
		strdata[j-i] = (data[j] == '\t') ? '\t' : ' ';
	    }
	    strdata[off-i] = '^';
	    outputln(new String(strdata));
	}
	errors = null;
  }

  /**
   * Output a string. This can either be an error message or something
   * for debugging. This should be used instead of print.
   */
  public void output(String msg) {
	    int len = msg.length();
	    for (int i = 0 ; i < len ; i++) {
			out.write(msg.charAt(i));
	    }
  }

  /**
   * Output a string. This can either be an error message or something
   * for debugging. This should be used instead of println.
   */
  public void outputln(String msg) {
	output(msg);
    out.write('\n');
  }

  /**
   * Issue an error.
   *  source   - the input source, usually a file name string
   *  offset   - the offset in the source of the error
   *  err      - the error number (as defined in this interface)
   *  arg1     - an optional argument to the error (null if not applicable)
   *  arg2     - 2nd optional argument to the error (null if not applicable)
   *  arg3     - 3rd optional argument to the error (null if not applicable)
   */

  public void error(int where, String err, Object arg1, Object arg2, Object arg3) {
	String msg = errorString(err, arg1, arg2, arg3);
 	if (err.startsWith("warn.")) {
		nwarnings++;
	} else {
		nerrors++;
	}
traceln("error:"+msg);
	insertError(where, msg);
 }
  public final void error(int where, String err, Object arg1, Object arg2) {
	error(where, err, arg1, arg2, null);
  }
  public final void error(int where, String err, Object arg1) {
	error(where, err, arg1, null, null);
  }
  public final void error(int where, String err) {
	error(where, err, null, null, null);
  }
  public final void error(String err) {
	error(pos, err, null, null, null);
  }
  public final void error(String err, Object arg1) {
	error(pos, err, arg1, null, null);
  }

/*-------------------------------------------------------------------  trace */
  void trace(String message) {
	if (traceFlag) output(message);
  }

  void traceln(String message) {
	if (traceFlag) outputln(message);
  }

} // end SourceFile
