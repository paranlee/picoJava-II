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
import java.util.Hashtable;
import java.util.Vector;

public class Tables implements Constants {
  /**
   * Define mnemocodes table.
   */
  static  Hashtable mnemocodes = new Hashtable(301, 0.5f);
  static  String opcExtNamesTab[]=new String[128];

  static  void defineExt(int opc, String mnem) {
      mnemocodes.put(opcExtNamesTab[opc]=mnem, 
                     new Integer(opc_extended*256+opc));
  }

  static { int k;
	for (k=0; k<opc_wide; k++) {
		mnemocodes.put(opcNamesTab[k], new Integer(k));
	}
	for (k=opc_wide+1; k<opcNamesTab.length; k++) {
		mnemocodes.put(opcNamesTab[k], new Integer(k));
	}
	mnemocodes.put("invokenonvirtual", new Integer(opc_invokespecial));

	mnemocodes.put("iload_w", new Integer(opc_iload_w));
	mnemocodes.put("lload_w", new Integer(opc_lload_w));
	mnemocodes.put("fload_w", new Integer(opc_fload_w));
	mnemocodes.put("dload_w", new Integer(opc_dload_w));
	mnemocodes.put("aload_w", new Integer(opc_aload_w));
	mnemocodes.put("istore_w", new Integer(opc_istore_w));
	mnemocodes.put("lstore_w", new Integer(opc_lstore_w));
	mnemocodes.put("fstore_w", new Integer(opc_fstore_w));
	mnemocodes.put("dstore_w", new Integer(opc_dstore_w));
	mnemocodes.put("astore_w", new Integer(opc_astore_w));
	mnemocodes.put("ret_w", new Integer(opc_ret_w));
	mnemocodes.put("iinc_w", new Integer(opc_iinc_w));

	//Extended bytecodes for picoJava 
     mnemocodes.put("extended", new Integer(opc_extended));
     mnemocodes.put("exit_sync_method", new Integer(opc_exit_sync_method));
     mnemocodes.put("sethi", new Integer(opc_sethi));
     mnemocodes.put("load_word_index", new Integer(opc_load_word_index));
     mnemocodes.put("load_short_index", new Integer(opc_load_short_index));
     mnemocodes.put("load_char_index", new Integer(opc_load_char_index));
     mnemocodes.put("load_byte_index", new Integer(opc_load_byte_index));
     mnemocodes.put("load_ubyte_index", new Integer(opc_load_ubyte_index));
     mnemocodes.put("store_word_index", new Integer(opc_store_word_index));
     mnemocodes.put("nastore_word_index", new Integer(opc_nastore_word_index));
     mnemocodes.put("store_short_index", new Integer(opc_store_short_index));
     mnemocodes.put("store_byte_index", new Integer(opc_store_byte_index));


	defineExt(0, "load_ubyte");
	defineExt(1, "load_byte");
	defineExt(2, "load_char");
	defineExt(3, "load_short");
	defineExt(4, "load_word");
	defineExt(5, "priv_ret_from_trap");
 	defineExt(6, "priv_read_dcache_tag");     
 	defineExt(7, "priv_read_dcache_data");

	defineExt(10, "load_char_oe");
	defineExt(11, "load_short_oe");
	defineExt(12, "load_word_oe");
        defineExt(13, "return0");
 	defineExt(14, "priv_read_icache_tag");
 	defineExt(15, "priv_read_icache_data");
	defineExt(16, "ncload_ubyte");
	defineExt(17, "ncload_byte");
	defineExt(18, "ncload_char");
	defineExt(19, "ncload_short");
	defineExt(20, "ncload_word");
	defineExt(21, "iucmp");

        defineExt(22, "priv_powerdown");
        defineExt(23, "cache_invalidate");

	defineExt(26, "ncload_char_oe");
	defineExt(27, "ncload_short_oe");
	defineExt(28, "ncload_word_oe");
        defineExt(29, "return1");
	defineExt(30, "cache_flush");
	defineExt(31, "cache_index_flush");
	defineExt(32, "store_byte");
	defineExt(34, "store_short");
	defineExt(36, "store_word");
        defineExt(37, "soft_trap");
 	defineExt(38, "priv_write_dcache_tag");
 	defineExt(39, "priv_write_dcache_data");

	defineExt(42, "store_short_oe");
	defineExt(44, "store_word_oe");
        defineExt(45, "return2");
 	defineExt(46, "priv_write_icache_tag");
 	defineExt(47, "priv_write_icache_data");

	defineExt(48, "ncstore_byte");
	defineExt(50, "ncstore_short");
	defineExt(52, "ncstore_word");
        
 	defineExt(54, "priv_reset");
        defineExt(55, "get_current_class");

	defineExt(58, "ncstore_short_oe");
	defineExt(60, "ncstore_word_oe");
        defineExt(61, "call");
	defineExt(62, "zero_line");
	defineExt(63, "priv_update_optop");        
        defineExt(64, "read_pc");
        defineExt(65, "read_vars");
        defineExt(66, "read_frame");
        defineExt(67, "read_optop");
        defineExt(68, "priv_read_oplim");
        defineExt(69, "read_const_pool");
        defineExt(70, "priv_read_psr");
        defineExt(71, "priv_read_trapbase");
        defineExt(72, "priv_read_lockcount0");
        defineExt(73, "priv_read_lockcount1");


        defineExt(76, "priv_read_lockaddr0");
        defineExt(77, "priv_read_lockaddr1");

        defineExt(80, "priv_read_userrange1");
        defineExt(81, "priv_read_gc_config");
        defineExt(82, "priv_read_brk1a");
        defineExt(83, "priv_read_brk2a");
        defineExt(84, "priv_read_brk12c");
        defineExt(85, "priv_read_userrange2");

        defineExt(87, "priv_read_versionid");
        defineExt(88, "priv_read_hcr");
        defineExt(89, "priv_read_sc_bottom");
        defineExt(90, "read_global0");
        defineExt(91, "read_global1");
        defineExt(92, "read_global2");
        defineExt(93, "read_global3");

        defineExt(96, "ret_from_sub");
        defineExt(97, "write_vars");
        defineExt(98, "write_frame");
        defineExt(99, "write_optop");
        defineExt(100,"priv_write_oplim");
        defineExt(101,"write_const_pool");
        defineExt(102,"priv_write_psr");
        defineExt(103,"priv_write_trapbase");
        defineExt(104,"priv_write_lockcount0");
        defineExt(105,"priv_write_lockcount1");

        defineExt(108,"priv_write_lockaddr0");
        defineExt(109,"priv_write_lockaddr1");

        defineExt(112,"priv_write_userrange1");
        defineExt(113,"priv_write_gc_config");

        defineExt(114,"priv_write_brk1a");
        defineExt(115,"priv_write_brk2a");
        defineExt(116,"priv_write_brk12c");
        defineExt(117,"priv_write_userrange2");

        defineExt(121,"priv_write_sc_bottom");
        defineExt(122,"write_global0");
        defineExt(123,"write_global1");
        defineExt(124,"write_global2");
        defineExt(125,"write_global3");
 }

  public static int opcLength(int opc) throws ArrayIndexOutOfBoundsException {
	switch (opc>>8) {
	  case 0:
	        switch (opc){
		  case opc_exit_sync_method:
		     return 1; // 1 byte picojava opcode
		  case opc_sethi: case opc_load_word_index:
		  case opc_load_short_index: case opc_load_char_index:
		  case opc_load_byte_index: case opc_load_ubyte_index:
		  case opc_store_word_index: case opc_nastore_word_index:
		  case opc_store_short_index: case opc_store_byte_index: 
		     return 3; // 3 byte picojava opcode
		  default:
		     return opcLengthsTab[opc];
                }
	  case opc_wide:
		switch (opc&0xFF) {
		  case opc_aload: case opc_astore:
		  case opc_fload: case opc_fstore:
		  case opc_iload: case opc_istore:
		  case opc_lload: case opc_lstore:
		  case opc_dload: case opc_dstore:
		  case opc_ret:
			return  4;
		  case opc_iinc:
			return  6;
		  default:
			throw new ArrayIndexOutOfBoundsException();
		}
	  case opc_extended:
             return 2;

	  default:
		throw new ArrayIndexOutOfBoundsException();
	}
  }

  public static String opcName(int opc) {
	try {
		switch (opc>>8) {
		  case 0:
		    switch (opc) {
                      // 1 byte picojava extension
		      case opc_exit_sync_method:
                         return "exit_sync_method";
		      // 3 byte picojava extension
		      case opc_sethi:
                         return "sethi";
  		      case opc_load_word_index:
		         return "load_word_index";
		      case opc_load_short_index:
		         return "load_short_index";
		      case opc_load_char_index:
		         return "load_char_index";
		      case opc_load_byte_index:
		         return "load_byte_index";
		      case opc_load_ubyte_index:
		         return "load_ubyte_index";
		      case opc_store_word_index:
		         return "store_word_index";
		      case opc_nastore_word_index:
		         return "nastore_word_index";
		      case opc_store_short_index:
		         return "store_short_index";
		      case opc_store_byte_index:
		         return "store_byte_index";
		      default:
			return opcNamesTab[opc];
                    }
		  case opc_wide: {
			String mnem=opcNamesTab[opc&0xFF]+"_w";
			if (mnemocodes.get(mnem) == null) 
				return null; // non-existent opcode
			return mnem;
		  }

                  case opc_extended:
			return opcExtNamesTab[opc&0xFF];
		  default:
			return null;
		}
	} catch (ArrayIndexOutOfBoundsException e) {
		switch (opc) {
		  case opc_extended:
                        return "extended";
		  default:
			return null;
		}
	}
  }

  public static int opcode(String mnem) {
	Integer Val=(Integer)(mnemocodes.get(mnem));
	if (Val == null) return -1;
	return Val.intValue();
  }

  /**
   * Initialized keyword and token Hashtables
   */
  static Hashtable keywords = new Hashtable(40);
  static Vector keywordNames = new Vector(40);
  static {
	// Modifier keywords
	defineKeyword("private", PRIVATE);
	defineKeyword("public",	PUBLIC);
	defineKeyword("protected",	PROTECTED);
	defineKeyword("static", STATIC);
	defineKeyword("transient",	TRANSIENT);
	defineKeyword("synchronized",	SYNCHRONIZED);
	defineKeyword("native",	NATIVE);
	defineKeyword("abstract",	ABSTRACT);
	defineKeyword("volatile", VOLATILE);
	defineKeyword("final",	FINAL);
	defineKeyword("interface",INTERFACE);

	// Declaration keywords
	defineKeyword("package",PACKAGE);
	defineKeyword("class",CLASS);
	defineKeyword("extends",EXTENDS);
	defineKeyword("implements",IMPLEMENTS);
	defineKeyword("throws",THROWS);
	defineKeyword("interface",INTERFACE);
	defineKeyword("Method",METHODREF);
	defineKeyword("Field",FIELDREF);
	defineKeyword("stack",STACK);
	defineKeyword("locals",LOCAL);

	// used in switchtables
	defineKeyword("default",	DEFAULT);

	// reserved keywords
	defineKeyword("const",	CONST);
  }

  private static void defineKeyword(String id, int token) {
	keywords.put(id, new Integer(token));
	if (token>=keywordNames.size()) {
		keywordNames.setSize(token+1);
	}
	keywordNames.setElementAt(id, token);
  }
  public static int keyword(String idValue) {
	Integer Val=(Integer)(keywords.get(idValue));
	if (Val == null) return IDENT;
	return Val.intValue();
  }
  public static String keywordName(int token) {
	if (token==-1) return "EOF";
	if (token>=keywordNames.size()) return null;
	return (String)keywordNames.elementAt(token);
  }

  /**
   * Define tag table.
   */
  private static Vector tagNames = new Vector(10);
  private static Hashtable Tags = new Hashtable(10);
  static {
	defineTag("Asciz",CONSTANT_UTF8);
	defineTag("int",CONSTANT_INTEGER);
	defineTag("float",CONSTANT_FLOAT);
	defineTag("long",CONSTANT_LONG);
	defineTag("double",CONSTANT_DOUBLE);
	defineTag("class",CONSTANT_CLASS);
	defineTag("String",CONSTANT_STRING);
	defineTag("Field",CONSTANT_FIELD);
	defineTag("Method",CONSTANT_METHOD);
	defineTag("InterfaceMethod",CONSTANT_INTERFACEMETHOD);
	defineTag("NameAndType",CONSTANT_NAMEANDTYPE);
  }
  private static void defineTag(String id, int val) {
	Tags.put(id, new Integer(val));
	if (val>=tagNames.size()) {
		tagNames.setSize(val+1);
	}
	tagNames.setElementAt(id, val);
  }
  public static String tagName(int tag) {
	if (tag>=tagNames.size()) return null;
	return (String)tagNames.elementAt(tag);
  }
  public static int tagValue(String idValue) {
	Integer Val=(Integer)(Tags.get(idValue));
	if (Val == null) return 0;
	return Val.intValue();
  }

  /**
   * Define type table. These types used in "newarray" instruction only.
   */
  private static Vector typeNames = new Vector(20);
  static Hashtable Types = new Hashtable(15);
  static {
	defineType("int",T_INT);
	defineType("long",T_LONG);
	defineType("float",T_FLOAT);
	defineType("double",T_DOUBLE);
	defineType("class",T_CLASS);
	defineType("boolean",T_BOOLEAN);
	defineType("char",T_CHAR);
	defineType("byte",T_BYTE);
	defineType("short",T_SHORT);
  }
  private static void defineType(String id, int val) {
	Types.put(id, new Integer(val));
	if (val>=typeNames.size()) {
		typeNames.setSize(val+1);
	}
	typeNames.setElementAt(id, val);
  }
  public static int typeValue(String idValue) {
	Integer Val=(Integer)(Types.get(idValue));
	if (Val == null) return -1;
	return Val.intValue();
  }
  public static String typeName(int type) {
	if (type>=typeNames.size()) return null;
	return (String)typeNames.elementAt(type);
  }
}






