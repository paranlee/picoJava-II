/****************************************************************
 ***
 ***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
 ***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
 ***    The contents of this file are subject to the current
 ***    version of the Sun Community Source License, picoJava-II
 ***    Core ("the License").  You may not use this file except
 ***    in compliance with the License.  You may obtain a copy
 ***    of the License by searching for "Sun Community Source
 ***    License" on the World Wide Web at http://www.sun.com.
 ***    See the License for the rights, obligations, and
 ***    limitations governing use of the contents of this file.
 ***
 ***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 *****************************************************************/




#ifndef _DECAF_H_
#define _DECAF_H_

#pragma ident "@(#)decaf.h 1.13 Last modified 10/06/98 11:34:07 SMI"

/*
 * The minimum object has no instance variables
 */

#define DEBUG_LOADER 0
#define DECAF_MIN_OBJECT_SIZE 8
#define	SET_OBJHINTPTR_IN_CLASS_OBJ	0

struct decafClass_for_classLoader;
typedef long decafObject;

typedef struct decafString {
  unsigned int key;
  char *cp;
} decafString;

typedef union decafCpItemType {
    int i;
    void *p;
    float f;
    decafString *dp;
} decafCpItemType;


/*--------------------------------------------------------------------*/
/* JAVA ARRAY FORMAT:                                                 */
/*                                                                    */
/* ------------                                                       */
/* MONITOR_REF                                                        */
/* ------------                                                       */
/* MVB       |S  <---- ArrayRef                                       */
/* ------------                                                       */
/* ArraySize                                                          */
/* ------------                                                       */
/* Element 0                                                          */
/* ------------                                                       */
/* .     .     .                                                      */
/* ------------                                                       */
/* Element N-1                                                        */
/* ------------                                                       */
/* Dimensions                                                         */
/* ------------                                                       */
/* Classptr/Type                                                      */
/* ------------                                                       */
/*                                                                    */
/*--------------------------------------------------------------------*/

#define ARRAY_HEADER	3	/* 3 WORDS (MONITOR_REF, MVB, arraySize) */
#define ARRAY_FOOTER    2       /* 2 WORDS (Dimensions, Class/Type) */
#define MONPTR_SIZE	1	/* 1 WORD  (MONITOR_REF) */
#define ARRAY_ITEM0	2	/* First item is 2 words into array */

/* S = Array element sizes in bytes expressed as a power of 2 */
#define SIZEP_OF_BOOLEAN    0
#define SIZEP_OF_BYTE       0
#define SIZEP_OF_SHORT      1
#define SIZEP_OF_CHAR       1
#define SIZEP_OF_INT        2
#define SIZEP_OF_FLOAT      2
#define SIZEP_OF_OBJREF     2
#define SIZEP_OF_LONG       3
#define SIZEP_OF_DOUBLE     3
#define SIZE_OF_ELEMENT_MASK	0xFFFFFFFC

/* Array element sizes in bytes */
#define SIZEB_OF_BOOLEAN    1
#define SIZEB_OF_BYTE       1
#define SIZEB_OF_SHORT      2
#define SIZEB_OF_CHAR       2
#define SIZEB_OF_INT        4
#define SIZEB_OF_FLOAT      4
#define SIZEB_OF_OBJREF     4
#define SIZEB_OF_LONG       8
#define SIZEB_OF_DOUBLE     8

/* Array Types */
#define SIGC_BOOLEAN    'Z'
#define SIGC_BYTE       'B'
#define SIGC_SHORT      'S'
#define SIGC_CHAR       'C'
#define SIGC_INT        'I'
#define SIGC_FLOAT      'F'
#define SIGC_LONG       'J'
#define SIGC_DOUBLE     'D'



struct cpArray;
struct decafField_for_classLoader;
struct decafMethod_for_classLoader;
struct decafExceptionBlock;


typedef struct monitorBlock {
    int 	threadID;
    int 	lockCount;
    int 	lockQueue;
    int		waitNotifyQueue;
} monitorBlock;


typedef struct methodVector {
                                           /* word-2 = class pointer */
                                           /* word-1 = constant pool pointer */
   struct decafMethod_for_classLoader *instMethods[1]; 
                                           /* array of instMethod pointers */
} methodVector;


typedef struct cpArray {
                                           /* word-1 = monitor reference */
   methodVector 	*methodVectorBase; /* ptr to collection of methods */
   int			 arraySize;	   /* size of array */		
   decafCpItemType 	 items[1];	   /* array of cp items */ 
} cpArray;


typedef struct exceptionArray {
                                           /* word-1 = monitor reference */
   methodVector 	*methodVectorBase; /* ptr to collection of methods */
   int			 arraySize;	   /* size of array */	  
   struct decafExceptionBlock *entry[1];   /* array of entry pointers */
} exceptionArray;


typedef struct fieldArray {
                                	   /* word-1 = monitor reference */
   methodVector 	*methodVectorBase; /* ptr to collection of methods */
   int			 arraySize;			
   struct decafField_for_classLoader	*field[1]; /* array of field ptrs */
} fieldArray;

typedef struct implementsArray {
                                	   /* word-1 = monitor reference */
   methodVector 	*methodVectorBase; /* ptr to collection of methods */
   int			 arraySize;			
   unsigned int		implement[1];	   /* array of field pointers */
} implementsArray;


typedef struct methodArray {
                                	   /* word-1 = monitor reference */
   methodVector 	*methodVectorBase; /* ptr to collection of methods */
   int			 arraySize;			
   struct decafMethod_for_classLoader	*method[1]; /* array of method ptrs */
} methodArray;


typedef struct tarArray {		  /* type and resolution array */
                                	  /* word -1 = monitor reference */
   methodVector 	*methodVectorBase;/* ptr to collection of methods */
   int			 arraySize;			
   unsigned char 	 type[1];	  /* array of type bytes */
} tarArray;


typedef struct decafField_for_classLoader {
                                	/* word-1 = monitor reference */
   methodVector	*methodVectorBase;	/* ptr to collection of methods */
   decafObject		object;
   struct decafClass_for_classLoader   *class;   
   decafString         *signature; 	/* same as name structure */
   unsigned int       	access;
   decafString         *name;
} decafField_for_classLoader;


typedef struct decafMethodField {
   int   	       *constpool; 	        /* for object hint block */
   struct decafClass_for_classLoader   *class;  /* loc. 24 in decafMethod */
   decafString         *signature; 	        /* same as name structure */
   unsigned int       	access;
   decafString         *name;
} decafMethodField;

typedef struct decafExceptionBlock {
                       			  /* word -1 = monitor reference */
   methodVector	       *methodVectorBase; /* ptr to collection of methods */
   long       	      	startPc;
   long        	      	endPc;
   long               	handlerPc;
   decafObject        	catchObject;
} decafExceptionBlock;

typedef struct decafMethod_for_classLoader {
                       			  /* word -1 = monitor reference */
   methodVector	       *methodVectorBase; /* ptr to collection of methods */
   unsigned char       *code;
   unsigned int         nlocals;    	/* in bytes */
   unsigned int         argsSize;   	/* in bytes */
   unsigned int         maxstack;   	/* in bytes */
   unsigned long        codeLength;
   exceptionArray      *exception;
   unsigned long        exceptionTableLength;
   decafMethodField     methodField;
} decafMethod_for_classLoader;

typedef struct decafObjectHint_for_classLoader {
   unsigned int        	objectSize; 	/* D and L are 2 words */
   fieldArray          *instVars;
   unsigned int         numOfInstVars;
   unsigned int         numOfInstMethods;
   struct decafClass    *classPtr;     
   decafCpItemType      *constantpool; 
   methodVector         *methods;
} decafObjectHint_for_classLoader;

typedef struct decafClass_for_classLoader {
                                         /* word -1 = monitor reference */
   methodVector        *methodVectorBase;/* ptr to collection of methods */
   cpArray             *constpool;
   methodArray         *methods;	 /* moved for microcode */
   fieldArray          *fields;
   unsigned int         constpoolCount;
   unsigned int         fieldsCount;
   unsigned int         methodsCount;
   decafObjectHint_for_classLoader     *objHintBlk;
   decafString         *name;
   struct decafClass_for_classLoader   *superClass; 
   implementsArray	*implements;
   unsigned int         implementsCount;
   unsigned int         access;
   unsigned int         flags;
   void*                loader;
   struct decafClass_for_classLoader* next;
} decafClass_for_classLoader;

/* Bit positions for flags in decafClass_for_classLoader */
#define MAIN_BIT_POS 2
#define CLINIT_BIT_POS 1
#define FINALIZE_BIT_POS 0

/*---------------------------------------------------------------------------*/

/*
 * The following C-sytle definitions are used by the simulator and RTL.
 */
typedef struct decafObjectHint {
   unsigned int        	objectSize; 	/* D and L are 2 words */
   fieldArray           *instVars;
   unsigned int         numOfInstVars;
   unsigned int         numOfInstMethods;
   struct decafClass    *classPtr;      /* fix location */
   decafCpItemType      *constantpool;  /* fix location, saving one cycle */
   methodVector         *methods;
} decafObjectHint;


typedef struct decafField {
   decafObject		object;
   struct decafClass   *class;     	/* location 24 in decafmethod */
   decafString         *signature; 	/* same as name structure */
   unsigned int       	access;
   decafString         *name;
} decafField;


typedef struct decafMethod {
   unsigned char       *code;
   unsigned int         nlocals;    /* in bytes */
   unsigned int         argsSize;   /* method index <<16 || argsize in bytes */
   unsigned int         maxstack;   /* in bytes */
   unsigned long        codeLength;
   exceptionArray      *exception;
   unsigned long        exceptionTableLength;
   decafMethodField     methodField;
} decafMethod;


typedef struct decafClass {
   cpArray             *constpool;
   methodArray         *methods;    /* moved for microcode */
   fieldArray          *fields;
   unsigned int         constpoolCount;
   unsigned int         fieldsCount;
   unsigned int         methodsCount;
   decafObjectHint     *objHintBlk;
   decafString         *name;
   struct decafClass   *superClass;		
   unsigned int        *implements;
   unsigned int         implementsCount;
   unsigned int         access;
} decafClass;



/* trap table */
/* Each entry is 8 byte, total 256 entries */
#define decafTrapTableSize 512
EXTERN char **decafTrapTable;

/* class table */
EXTERN int        decafClassTableCount;	/* # of elements in system class tbl */
EXTERN decafClass_for_classLoader **decafClass_for_classLoaderTable;
EXTERN decafClass_for_classLoader **decafClassHashTable;

/*
**	Java bootstarp class names from java/lang/...
**	If these names change in the Java system, then we'll 
**	need to also change these names here.  Otherwise bootstrap
**	will not work.
*/

#define		OBJECT_CLASS_NAME		"java/lang/Object"	
#define		CLASS_CLASS_NAME		"java/lang/Class"
#define		FIELD_CLASS_NAME		"java/lang/Field"	
#define		METHOD_CLASS_NAME		"java/lang/Method"	
#define		EXCEPTIONBLOCK_CLASS_NAME	"java/lang/ExceptionBlock"

#endif /* _DECAF_H_ */

