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

import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.Vector;

/**
 * This class is used to parse Jasm statements and expressions.
 * The result is a parse tree.<p>
 *
 * This class implements an operator precedence parser. Errors are
 * reported to the Environment object, if the error can't be
 * resolved immediatly, a SyntaxError exception is thrown.<p>
 *
 * Error recovery is implemented by catching SyntaxError exceptions
 * and discarding input tokens until an input token is reached that
 * is possibly a legal continuation.<p>
 *
 * The parse tree that is constructed represents the input
 * exactly (no rewrites to simpler forms). This is important
 * if the resulting tree is to be used for code formatting in
 * a programming environment. Currently only documentation comments
 * are retained.<p>
 *
 */

/**
 * Syntax errors, should always be caught inside the
 * parser for error recovery.
 */
class SyntaxError extends Error {
}

public class Parser extends Scanner implements Constants {

  Vector Classes=new Vector();
  ClassData cd;
  MethodData curMetohod;
  String pkg=null, pkgPrefix="";

  /**
   * Create a parser
   */
  protected Parser(SourceFile sf) throws IOException {
	super(sf);
  }

  /**
   * Parse the modifiers
   */
  protected int scanModifiers(int allowed) throws IOException {
	int mod = 0, nextmod;

	while (true) {
	    switch (token) {
	      case PUBLIC: 		nextmod = M_PUBLIC; 	        break;
	      case PRIVATE:		nextmod = M_PRIVATE; 	        break;
	      case PROTECTED: 	        nextmod = M_PROTECTED; 	        break;
	      case STATIC: 		nextmod = M_STATIC; 	        break;
	      case FINAL: 		nextmod = M_FINAL; 	        break;
	      case SYNCHRONIZED:        nextmod = M_SYNCHRONIZED;	break;
	      case VOLATILE: 	        nextmod = M_VOLATILE;	        break;
	      case TRANSIENT: 	        nextmod = M_TRANSIENT; 		break;
	      case NATIVE: 		nextmod = M_NATIVE; 		break;
	      case INTERFACE: 	        nextmod = M_INTERFACE; 	        break;
	      case ABSTRACT: 	        nextmod = M_ABSTRACT; 		break;
	      default:
			return mod;
	    }
	    if ((nextmod & ~allowed) != 0) {
			env.error(pos, "warn.invalid.modifier");
		}
	    if ((mod & nextmod) != 0) {
			env.error(pos, "repeated.modifier");
	    } else {
			mod |= nextmod;
		}
	    scan();
	}
  }

  protected int scanModifiers() throws IOException {
	return scanModifiers(0xFFFF);
  }

  /**
   * Expect a token, return its value, scan the next token or
   * throw an exception.
   */
  protected final void expect(int t) throws SyntaxError, IOException {
	if (token != t) {
env.traceln("expect:"+t+" instead of "+token);
	    switch (t) {
	      case IDENT:
		env.error(pos, "identifier.expected");
		break;
	      default:
		env.error(pos, "token.expected", opNames[t]);
		break;
	    }
		throw new SyntaxError();
	}
	scan();
  }

  /**
   * Parse an internal name: identifier.
   */
  protected String parseIdent() throws SyntaxError, IOException {
	String	v=idValue;
	expect(IDENT);
	return v;
  }

  /**
   * Parse a local variable
   */
  protected void parseLocVarDef() throws SyntaxError, IOException {
	if (token==INTVAL) {
	    int v = intValue;
		scan();
		curMetohod.LocVarDataDef(v);
	} else {
		String name=stringValue, type;
		expect(IDENT);
		if (token==COLON) {
			scan();
			type=parseIdent();
		} else {
			type="int";                  // TBD
		}
		curMetohod.LocVarDataDef(name, cd.FindCellAsciz("int"));
	}
  }

  protected Argument parseLocVarRef() throws SyntaxError, IOException {
	if (token==INTVAL) {
	    int v = intValue;
            if ( sign == -1) {
               env.error(pos,"byte.expected");
               throw new SyntaxError();
            }
	    scan();
	    return new Argument(v);
	} else {
		String name=stringValue;
		expect(IDENT);
		return curMetohod.LocVarDataRef(name);
	}
  }

  protected void parseLocVarEnd() throws SyntaxError, IOException {
	if (token==INTVAL) {
	    int v = intValue;
		scan();
		curMetohod.LocVarDataEnd(v);
	} else {
		String name=stringValue;
		expect(IDENT);
		curMetohod.LocVarDataEnd(name);
	}
  }

  /**
   * Parse a label instruction argument
   */
  protected Argument parseLabelRef() throws SyntaxError, IOException {
	switch (token) { 
	  case INTVAL: {
	    int v = intValue;
		scan();
		return new Argument(v);
	  }
	  case IDENT: {
		String label=stringValue;
		scan();
		return curMetohod.LabelRef(label);
	  }
	 }
	env.error("label.expected");
	throw new SyntaxError();
  }

  /**
   * Parse an external name: CPINDEX, string, or identifier.
   */
  protected ConstCell parseName() throws SyntaxError, IOException {
	String v;
	switch (token) {
	  case CPINDEX: {
		int cpx=intValue;
		scan();
		return cd.getCell(cpx);
	  }
	  case STRINGVAL:
		v=stringValue;
	    scan();
		return cd.FindCellAsciz(v);
	  case IDENT:
		v=idValue;
	    scan();
		return cd.FindCellAsciz(v);
	  default:
		env.error(prevPos, "name.expected");
		throw new SyntaxError();
	}
  }

  protected ConstCell parseClassName(boolean uncond) 
  throws SyntaxError, IOException {
env.traceln("parseClassName:"+uncond);
	String v, vprime;
        char c[] = null;

	switch (token) {
	  case CPINDEX: {
		int cpx=intValue;
		scan();
		return cd.getCell(cpx);
	  }
	  case STRINGVAL:
		v=stringValue;
	    scan();
		return cd.FindCellAsciz(v);
       	  case IDENT: case METHODREF: case FIELDREF:
		v=idValue;
	    scan();
		if (uncond||(token==FIELD)) {
			if ((v.indexOf("/")==-1) // class ident doesn't
			                         // contain "/" 
			 && (v.indexOf("[")==-1) // class ident doesn't 
			                         // contain "["
			){
env.traceln("parseClassName:"+pkgPrefix+" + "+v);
				v=pkgPrefix+v; // add package
			}
		}

                if (v.startsWith("[]/", 0)) {
                   c = new char[v.length() - 3];
                   v.getChars(3, v.length(), c, 0);
                   vprime = new String(c);
                   return cd.FindCellAsciz(vprime);
                }
		return cd.FindCellAsciz(v);
	  default:
		env.error(prevPos, "name.expected");
		throw new SyntaxError();
	}
  }

  /**
   * Parse  CONSTVALUE
   */
  protected ConstValue parseConstValue(int tag) 
		throws SyntaxError, IOException {
	Object obj;
	switch (tag) { 
	  case CONSTANT_UTF8: {
	    obj = stringValue;
		expect(STRINGVAL);
		break;
	  }
	  case CONSTANT_INTEGER: {
	    int v = intValue*sign;
		expect(INTVAL);
		obj = new Integer(v);
		break;
	  }
	  case CONSTANT_LONG: {
		long v;
		switch (token) {
		  case INTVAL:
		    v = intValue;
			  break;
		  case LONGVAL:
		    v = longValue;
			  break;
		  default:
			env.error(prevPos, "token.expected", "<Integer>");
			throw new SyntaxError();
		}
		obj = new Long(v*sign);
		scan(); break;
	  }
	  case CONSTANT_FLOAT: {
		float v;
		switch (token) {
		  case INTVAL:
		    v = intValue;
			  break;
		  case LONGVAL:
		    v = longValue;
			  break;
		  case FLOATVAL:
		    v = floatValue;
			  break;
		  case DOUBLEVAL:
		    v = (float)doubleValue;
			  break;
		  case IDENT:
		       if (idValue.equals("Infinity")||idValue.equals("Inf")) {
			  v = Float.POSITIVE_INFINITY;
			  break;
		        } else if (idValue.equals("NaN")) {
			  v = Float.NaN;
			  break;
			}
		  default:
env.traceln("token="+token);
			env.error(prevPos, "token.expected", "<Float>");
			throw new SyntaxError();
		}
		obj = new Float(v*sign);
		scan(); break;
	  }
	  case CONSTANT_DOUBLE: {
		double v;
		switch (token) {
		  case INTVAL:
		    v = intValue;
			  break;
		  case LONGVAL:
		    v = longValue;
			  break;
		  case FLOATVAL:
		    v = floatValue;
			  break;
		  case DOUBLEVAL:
		    v = doubleValue;
			  break;
		  case IDENT:
		       if (idValue.equals("Infinity")||idValue.equals("Inf")) {
			  v = Double.POSITIVE_INFINITY;
			  break;
			} else if (idValue.equals("NaN")) {
			  v = Double.NaN;
			  break;
			}
		  default:
			env.error(prevPos, "token.expected", "<Double>");
			throw new SyntaxError();
		}
		obj = new Double(v*sign);
		scan(); break;
	  }
	  case CONSTANT_STRING:
		obj = parseName();
		break;
	  case CONSTANT_CLASS: 
		obj = parseClassName(true);
		break;
	  case CONSTANT_FIELD: 
	  case CONSTANT_INTERFACEMETHOD: 
	  case CONSTANT_METHOD: {
		int prevtoken=token;
		ConstCell firstName=
                  parseClassName(false), ClassCell, NameCell, NapeCell;
		if (token==FIELD) { // DOT
			scan();
			if (prevtoken==CPINDEX) {
				ClassCell=firstName;
			} else {
				ClassCell=
                                  cd.FindCell(CONSTANT_CLASS, firstName);
			}
			NameCell=parseName();
		} else {
			// no class provided - assume current class
			ClassCell=cd.me;
			NameCell=firstName;
		}
		if (token==COLON) {
			// name and type separately
			scan();
			NapeCell=cd.FindCell(CONSTANT_NAMEANDTYPE, 
                                             NameCell, parseName());
		} else {
			// name and type as single name
			NapeCell=NameCell;
		}
		obj = new CellPair(ClassCell, NapeCell, env);
		break;
	  }
	  case CONSTANT_NAMEANDTYPE: {
		ConstCell NameCell=parseName(), TypeCell;
		expect(COLON);
		TypeCell=parseName();
		obj = new CellPair(NameCell, TypeCell, env);
		break;
	  }
	  default:
		throw new CompilerError("Bad Tag:"+tag);
	}
	return new ConstValue(tag, obj, env);
  } // end parseConstValue

  /**
   * Parse  [TAG] CONSTVALUE
   */
  protected ConstValue parseTagConstValue(int defaultTag) 
		throws SyntaxError, IOException {
	int tag=tagValue(idValue);
	if (tag==0) {
		if (defaultTag==0) {
			switch (token) {
			  case INTVAL: tag=CONSTANT_INTEGER; break;
			  case LONGVAL: tag=CONSTANT_LONG; break;
			  case FLOATVAL: tag=CONSTANT_FLOAT; break;
			  case DOUBLEVAL: tag=CONSTANT_DOUBLE; break;
			  case STRINGVAL:
			  case IDENT: tag=CONSTANT_STRING; break;
			  default:
			 System.err.println("NEAR: " + opNames[token]);
				env.error(pos, "value.expected");
				throw new SyntaxError();
			}
		} else {
			tag=defaultTag;
		}
	} else {
		if ((defaultTag!=0) && (tag!=defaultTag)) {
			env.error("warn.wrong.tag", tagName(defaultTag));
		}
		scan();
	}
	return parseConstValue(tag);
  } // end parseTagConstValue

  /**
   * Parse an instruction argument, one of: 
   *   #NUMBER
   *   #NAME
   *   [TAG] CONSTVALUE
   */
  protected ConstCell parseConstRef(int defaultTag) 
		throws SyntaxError, IOException {
	if (token==CPINDEX) {
		int cpx=intValue;
		scan();
		return cd.getCell(cpx);
	} else {
		return cd.FindCell(parseTagConstValue(defaultTag));
	}
  } // end parseConstRef

  /**
   * Parse a integer.
   */
  protected Argument parseInt() throws SyntaxError, IOException {
	int arg;
	if (token==INTVAL) {
		arg=intValue*sign;
	 } else {
		env.error(pos, "int.expected");
		throw new SyntaxError();
	}
    scan();
	return new Argument(arg);
  }

  /**
   * Parse constant declaration
   */
  protected void parseConstDef() throws IOException {
	for (;;) {
		if (token==CPINDEX) {
			int cpx=intValue;
			scan();
			expect(ASSIGN);
			cd.setCell(cpx, parseConstRef(0));
		} else {
			env.error("const.def.expected");
			throw new SyntaxError();
		}
		if (token != COMMA) {
			expect(SEMICOLON);
			return;
		}
		scan(); // COMMA
	}
  }

  /**
   * Parse a Switch Table.
   * return value: SwitchTable.
   */
  protected SwitchTable parseSwitchTable() throws SyntaxError, IOException {
	expect(LBRACE);
	Argument label;
	int numpairs=0, key;
	SwitchTable table=new SwitchTable(env);
  tableScan: {
	while (numpairs<1000) {
		if (token==RBRACE) break tableScan;
		if (token==DEFAULT) {
			scan();
			expect(COLON);
			table.deflabel=parseLabelRef();
			if (token==SEMICOLON) scan();
			expect(RBRACE);			
			break tableScan;
		}
		key=intValue*sign;
		expect(INTVAL);
		expect(COLON);
		table.addEntry(key, parseLabelRef());
		numpairs++;
		if (token!=SEMICOLON) {
			expect(RBRACE);
			break tableScan;
		}
		scan();
	}
	env.error("long.switchtable", "1000");
  }
	return table;
  } // end parseSwitchTable

  /**
   * Parse an instruction.
   */
  protected void  parseInstr() 
			throws SyntaxError, IOException  {
        // ignore possible line numbers after java disassembler
	if (token==INTVAL) scan();
        // ignore possible numeric labels after java disassembler
	if (token==INTVAL) scan();
	if (token==COLON) scan();

	String mnemocode;
	int mnenoc_pos;
	for (;;) { // read labels
		mnemocode=idValue;
		mnenoc_pos=pos;
		expect(IDENT);
		if (token!=COLON) break;
		// actually it was a label
		scan();
		curMetohod.LabelDef(mnemocode);
	}
	int opc=opcode(mnemocode);
	Argument arg=null;
	Object arg2=null;
	switch (opc>>8) {
	  case 0:
		switch (opc&0xFF) {
	          case opc_sethi:
                        arg = parseInt();
                        arg.arg = (arg.arg & 0xFFFF);
                        break;
		  case opc_load_word_index: case opc_load_short_index:
		  case opc_load_char_index: case opc_load_byte_index:
		  case opc_load_ubyte_index: case opc_store_word_index:
		  case opc_nastore_word_index: case opc_store_short_index:
		  case opc_store_byte_index:
		    if (env.mayaFlag) {
                        arg = parseInt();
                        if ( (arg.arg > 255) || (arg.arg < 0) ) {
                         // throw syntax error
                         env.error(pos,"byte.expected");
                         throw new SyntaxError();
                        }
                        expect(COMMA);
                        arg2 = parseInt();
                        if ( ( ((Argument)arg2).arg < -128) || 
                             ( ((Argument)arg2).arg > 127)  ) {
                         // throw syntax error
                         env.error(pos,"sbyte.expected");
                         throw new SyntaxError();
                        }
                        arg.arg = ((arg.arg & 0xFF) << 8) | 
                                  (((Argument)arg2).arg & 0xFF);
		    }
                    else {
                        env.error(prevPos, "wrong.mnemocode");
		        throw new SyntaxError();
		    }
                        break;
		  case opc_bytecode:
			for (;;) {
				curMetohod.addInstr(opc_bytecode, parseInt());
				if (token != COMMA) return;
				scan();
			}

		  case opc_try:
			for (;;) {
				curMetohod.beginTrap(pos, parseIdent());
				if (token != COMMA) return;
				scan();
			}
		  case opc_endtry:
			for (;;) {
				curMetohod.endTrap(pos, parseIdent());
				if (token != COMMA) return;
				scan();
			}
		  case opc_catch:
			curMetohod.trapHandler(pos, parseIdent(), parseConstRef(CONSTANT_CLASS));
			return;
		  case opc_var:
			for (;;) {
				parseLocVarDef();
				if (token != COMMA) return;
				scan();
			}
		  case opc_endvar:
			for (;;) {
				parseLocVarEnd();
				if (token != COMMA) return;
				scan();
			}
		  case opc_aload: case opc_astore:
		  case opc_fload: case opc_fstore:
		  case opc_iload: case opc_istore:
		  case opc_lload: case opc_lstore:
		  case opc_dload: case opc_dstore:
		  case opc_ret:
		       // loc var
                       arg=parseLocVarRef();
                       if ( (arg.arg > 255) || (arg.arg < 0) ) {
                         // throw syntax error
                         env.error(pos,"byte.expected");
                         throw new SyntaxError();
                       }
                       break;
		  case opc_aload_w: case opc_astore_w:
		  case opc_fload_w: case opc_fstore_w:
		  case opc_iload_w: case opc_istore_w:
		  case opc_lload_w: case opc_lstore_w:
		  case opc_dload_w: case opc_dstore_w:
		  case opc_ret_w:
			// loc var
			arg=parseLocVarRef();
			break;
		  case opc_iinc: // loc var, const  
			arg=parseLocVarRef();
                        if ( (arg.arg > 255) || (arg.arg < 0) ) {
                         // throw syntax error
                         env.error(pos,"byte.expected");
                         throw new SyntaxError();
                        }
			expect(COMMA);
			arg2=parseInt();
			break;
                  case opc_iinc_w: // loc var, const
			arg=parseLocVarRef();
			expect(COMMA);
			arg2=parseInt();
			break;
		  case opc_tableswitch:
		  case opc_lookupswitch:
			arg2=parseSwitchTable();
			break;
		  case opc_newarray: {
			int type;
			if (token==INTVAL) {
				type=intValue;
			} else	if ((type=typeValue(idValue))==-1) { 
				env.error(pos, "type.expected");
				throw new SyntaxError();
			}
			scan();
			arg=new Argument(type);
			  break;
		  }
		  case opc_new:
		  case opc_anewarray: 
			arg = parseConstRef(CONSTANT_CLASS);
			break;
	  
		  case opc_sipush:
		  case opc_bipush:
			arg=parseInt();
			break;
		  case opc_ldc:
		  case opc_ldc_w: case opc_ldc2_w:
		  case opc_instanceof: case opc_checkcast:
			arg=parseConstRef(0);
			break;
		  case opc_putstatic: case opc_getstatic:
		  case opc_putfield: case opc_getfield:
			arg=parseConstRef(CONSTANT_FIELD);
			break;
		  case opc_invokevirtual:
		  case opc_invokenonvirtual:
		  case opc_invokestatic:
			arg=parseConstRef(CONSTANT_METHOD);
			break;
		  case opc_jsr: case opc_goto:
		  case opc_ifeq: case opc_ifge: case opc_ifgt:
		  case opc_ifle: case opc_iflt: case opc_ifne:
		  case opc_if_icmpeq: case opc_if_icmpne: case opc_if_icmpge:
		  case opc_if_icmpgt: case opc_if_icmple: case opc_if_icmplt:
		  case opc_if_acmpeq: case opc_if_acmpne:
		  case opc_ifnull: case opc_ifnonnull:
		  case opc_jsr_w:
		  case opc_goto_w:
			arg=parseLabelRef();
			break;
			
		  case opc_invokeinterface: 
			arg=parseConstRef(CONSTANT_INTERFACEMETHOD);
			expect(COMMA);
			arg2=parseInt();
			break;
	
		  case opc_multianewarray:
			arg=parseConstRef(CONSTANT_CLASS);
			expect(COMMA);
			arg2=parseInt();
			break;
		  case opc_wide:
		  case opc_extended:
			opc=(opc<<8)|parseInt().arg;
			break;
		}
		break;
	  case opc_wide:
		arg=parseLocVarRef();
		if (opc==opc_iinc_w) { // loc var, const
			expect(COMMA);
			arg2=parseInt();
		}
		break;

	  case opc_extended:
                if ((opc==0xff15)&&(!env.mayaFlag)){
		   env.error(prevPos, "wrong.mnemocode");
		   throw new SyntaxError();
		}                        
		break;

	  default:
		env.error(prevPos, "wrong.mnemocode");
		throw new SyntaxError();
	}
	if (env.debugInfoFlag) curMetohod.addLineNumber(env.lineNumber(mnenoc_pos));
	curMetohod.addInstr(opc, arg, arg2);
  } //end parseInstr

  /**
   * Parse a field.
   */
  protected void parseField() throws SyntaxError, IOException {
	// Empty fields are allowed
	if (token == SEMICOLON) {
	    scan();
	    return;
	}

	// Optional doc comment
	String doc = docComment;

	ConstCell name, type;

	// The start of the field
	int p = pos;

	// Parse the modifiers
	int mod = scanModifiers();

	// Check the field keyword: var or method
	switch (token) {
	  case METHODREF:
	    if ((mod & ~MM_METHOD) != 0) 
              env.error(pos, "warn.invalid.modifier");
	    // It is a method declaration
	    scan();
		name = parseName();
		expect(COLON);
		type = parseName();
		// Parse throws clause
		Vector exc_table = null;
		if (token == THROWS) {
		    scan();
			exc_table = new Vector();
			for (;;) {
			    Argument exc=parseConstRef(CONSTANT_CLASS);
				if (exc_table.contains(exc)) {
				    env.error(p, "exc.repeated", exc);
				} else {
				    exc_table.addElement(exc);
env.traceln("THROWS:"+exc.arg);
				}
				if (token != COMMA) break;
				scan();
			}
		}
		curMetohod=cd.StartMethod(mod, name, type, exc_table);
		if (token==STACK) {
			scan();
			curMetohod.setStack(parseInt());
		}
		if (token==LOCAL) {
			scan();
			curMetohod.setLocals(parseInt());
		}
		if (token==SEMICOLON) {
			scan();
		} else {
			expect(LBRACE);
			curMetohod.startCode();
			while ((token != EOF) && (token != RBRACE)) {
					parseInstr();
					if (token==RBRACE) break;
					expect(SEMICOLON);
			}
			expect(RBRACE);
		}
		cd.EndMethod();
		break;
	  case FIELDREF:  // It is a list of instance variables
	    if ((mod & ~MM_FIELD) != 0) 
              env.error(pos, "warn.invalid.modifier");
	while (true) {
	    scan();
	    p = pos;		// get the current position
		name = parseName();
		expect(COLON);
		type = parseName();

	    // Define the variable
		FieldData glob_var=cd.addField(mod, name, type);

	    // Parse the optional initializer
	    if (token == ASSIGN) {
			scan();
			glob_var.SetValue(parseConstRef(0));
	    }

	    // If the next token is a comma, then there is more
	    if (token != COMMA) {
			expect(SEMICOLON);
			return;
	    }
	}  // end while
	  default:
		env.error(pos, "field.expected");
		throw new SyntaxError();
	}  // end switch
  }  // end parseField

  /**
   * Recover after a syntax error in a field. This involves
   * discarding tokens until an EOF or a possible legal
   * continutation is encountered.
   */
  protected void recoverField() throws SyntaxError, IOException {
	while (true) {
	    switch (token) {
	      case EOF:
	      case STATIC:
	      case FINAL:
	      case PUBLIC:
	      case PRIVATE:
	      case SYNCHRONIZED:
	      case TRANSIENT:
	      case PROTECTED:
	      case VOLATILE: 
	      case NATIVE:
     //	      case INTERFACE: see below
	      case ABSTRACT: 
		// possible begin of a field, continue
		return;

	      case LBRACE:
		match(LBRACE, RBRACE);
		scan();
		break;

	      case LPAREN:
		match(LPAREN, RPAREN);
		scan();
		break;

	      case LSQBRACKET:
		match(LSQBRACKET, RSQBRACKET);
		scan();
		break;

	      case RBRACE:
	      case INTERFACE:
	      case CLASS:
	      case IMPORT:
	      case PACKAGE:
		// begin of something outside a class, panic more
		endClass(pos);
		throw new SyntaxError();

	      default:
		// don't know what to do, skip
		scan();
		break;
	    }
	}
  }

  /**
   * Parse a class or interface declaration.
   */
  protected void parseClass() throws IOException {
	cd=new ClassData(env);

	String doc = docComment;

	// Parse the modifiers
	int mod = scanModifiers(MM_CLASS);

	// Parse the class name
	int p = pos;
	ConstCell nm = parseConstRef(CONSTANT_CLASS);

	// Parse extends clause
	Vector ext = new Vector();
	if (token == EXTENDS) {
	    scan();
		for (;;) {
		    ext.addElement(parseConstRef(CONSTANT_CLASS));
			if (token != COMMA) break;
			scan();
		}
	}

	// Parse implements clause
	Vector impl = new Vector();
	if (token == IMPLEMENTS) {
	    scan();
		for (;;) {
		    Argument intf=parseConstRef(CONSTANT_CLASS);
			if (impl.contains(intf)) {
			    env.error(p, "intf.repeated", intf);
			} else {
			    impl.addElement(intf);
			}
			if (token != COMMA) break;
			scan();
		}
	}

	// Decide which is the super class
	ConstCell sup = null;
	if ((mod & M_INTERFACE) != 0) {
	    if (impl.size() > 0) {
			env.error(p, "intf.impl.intf");
	    }
	    impl = ext;
	} else if (ext.size() > 0) {
		if (ext.size() > 1) {
		    env.error(p, "multiple.inherit");
		}
		sup = (ConstCell)ext.elementAt(0);
	}
	expect(LBRACE);

	// Begin a new class
	cd.init(mod, nm, sup, impl);

	// Parse fields
	while ((token != EOF) && (token != RBRACE)) {
	    try {
			if (token==CONST) {
				scan();
				parseConstDef();
			} else {
				parseField();
			}
	    } catch (SyntaxError e) {
			recoverField();
	    }
	}
	expect(RBRACE);

	// End the class
	endClass(prevPos);
  } // end parseClass

    /**
     * Recover after a syntax error in the file.
     * This involves discarding tokens until an EOF
     * or a possible legal continuation is encountered.
     */
    protected void recoverFile() throws IOException {
	while (true) {
	    switch (token) {
	      case CLASS:
	      case INTERFACE:
		// Start of a new source file statement, continue
		return;
		
	      case LBRACE:
		match(LBRACE, RBRACE);
		scan();
		break;

	      case LPAREN:
		match(LPAREN, RPAREN);
		scan();
		break;

	      case LSQBRACKET:
		match(LSQBRACKET, RSQBRACKET);
		scan();
		break;

	      case EOF:
		return;
		
	      default:
		// Don't know what to do, skip
		scan();
		break;
	    }
	}
    }

  /**
   * End class
   */
  protected void endClass(int where) {
	cd.endClass();
	env.flushErrors();
	Classes.addElement(cd);
	cd = null;
  }

  /**
   * Parse an Jasm file.
   */
  public Vector parseFile() {
	try{
	    try {
			if (token == PACKAGE) {
			    // Package statement
			    int where = scan();
			    String id = parseIdent();
			    expect(SEMICOLON);
		    	if (pkg == null) {
					pkg = id;
					pkgPrefix=id+"/";
		    	} else {
					env.error(where, "package.repeated");
		    	}
			}
	    } catch (SyntaxError e) {
			recoverFile();
	    }
		while (token != EOF) {
		try {
		    switch (token) {
		      case FINAL:
		      case PUBLIC:
		      case PRIVATE:
		      case ABSTRACT:
		      case CLASS:
		      case INTERFACE:
			// Start of a class
			parseClass();
			break;

		      case SEMICOLON:
			// Bogus semi colon
			scan();
			break;

		      case EOF:
			// The end
			return Classes;

		      default:
			// Oops
env.traceln("token="+token);
			env.error(pos, "toplevel.expected");
			throw new SyntaxError();
		    }
		} catch (SyntaxError e) {
		    recoverFile();
		}
	}} catch (IOException e) {
	    env.error(pos, "io.exception", env.getSource());
	    return Classes;
	}
	return Classes;
  } //end parseFile

}  //end Parser






