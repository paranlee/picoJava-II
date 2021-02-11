/****************************************************************
 ---------------------------------------------------------------
     Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
     Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
     The contents of this file are subject to the current
     version of the Sun Community Source License, picoJava-II
     Core ("the License").  You may not use this file except
     in compliance with the License.  You may obtain a copy
     of the License by searching for "Sun Community Source
     License" on the World Wide Web at http://www.sun.com.
     See the License for the rights, obligations, and
     limitations governing use of the contents of this file.

     Sun, Sun Microsystems, the Sun logo, and all Sun-based
     trademarks and logos, Java, picoJava, and all Java-based
     trademarks and logos are trademarks or registered trademarks 
     of Sun Microsystems, Inc. in the United States and other
     countries.
 ----------------------------------------------------------------
******************************************************************/




 
// CPP macros for defining the memory buffer location
#define         HIGH_BUF_ADDR   0x001F
#define         LOW_BUF_ADDR    0xE000   

#define         HIGH_CLASSTAB_BASE      0x0002
#define         LOW_CLASSTAB_BASE       0x0000

#define		HEAP_STRUCT_BASE_H	0x0010
#define		HEAP_STRUCT_BASE_L	0x0000

#define		HEAP_STRUCT_END_H	0x001E
#define		HEAP_STRUCT_END_L	0xFFFF

#define		OBJ_TABLE_BASE_H	0x001F
#define		OBJ_TABLE_BASE_L	0x0000

#define		TMP_BUF_BASE_H		0x001F
#define		TMP_BUF_BASE_L		0xE000

#define		STAT_DYNAMIC_BASE_H	0x001F
#define		STAT_DYNAMIC_BASE_L	0xE400

#define		STAT_DYNAMIC_END_H	0x001F
#define		STAT_DYNAMIC_END_L	0xFFFF

// Offsets for Class Structure 
#define		C_CONSTPOOL		0
#define		C_CONSTPOOL_4		4
#define		C_METHODPTR		4
#define		C_METHODPTR_4		8
#define		C_FIELDPTR		8
#define		C_FIELDCNT		16
#define		C_METHODCNT		20
#define		C_METHODCNT_4		24
#define		C_OBJHINTBLK		24
#define		C_CLASSNAME		28
#define		C_CLASSNAME_4		32
#define		C_SUPERCLASS		32
#define		C_SUPERCLASS_4		36
#define		C_INTF_IMPTED		36
#define		C_INTF_CNT		40
#define		C_ACCESSFLAG		44

// Offsets for Method Block
#define		M_BLOCKSIZE		48	// a method block is 48 bytes

#define		M_ENTRY_PTR		0
#define		M_NUMOFLOCAL		4
#define		M_NUMOFARGS		8
#define		M_EXPT_BLK		20
#define		M_NUMOFEXPT		24
#define		M_CONSTPOOL		28
#define		M_CLASSPTR		32
#define		M_SIGNATURE		36
#define		M_SIGNATURE_4		40
#define		M_ACCESSFLAG		40
#define		M_METHODNAME		44
#define		M_METHODNAME_4		48

// Offsets for Object Hint Block
//#define		O_INSTMETHODPTR		24
//#define		O_METD_VEC_BASE		24
//#define		O_NUMINSTMETHOD		12

#define		O_INSTMETHODPTR		32
#define		O_METD_VEC_BASE		32
#define		O_NUMINSTMETHOD		20


// Offsets for Field Block
#define		F_BLOCKSIZE		20

#define		F_CLASSPTR		4
#define		F_SIGNATURE		8
#define		F_SIGNATURE_4		12
#define		F_ACCESSFLAG		12
#define		F_NAMEPTR		16
#define		F_NAMEPTR_4		20

// Offsets for Exception Block
#define		E_BLOCKSIZE		16

#define		E_START_PC		0
#define		E_END_PC		4
#define		E_HANDLER_PC		8
#define		E_CATCH_OBJ		12

#define		E_START_PC_4		4
#define		E_END_PC_4		8
#define		E_HANDLER_PC_4		12
#define		E_CATCH_OBJ_4		16

// Offset for Method Vector Table Base pointer
#define		V_CONSTPOOL		4
#define		V_CLASSPTR		8
