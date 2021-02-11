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




static char *sccsid = "@(#)loader.c 1.13 Last modified 02/28/99 17:05:50 SMI";

#include <stdlib.h>
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <fcntl.h>
#include <errno.h>
#include <stddef.h>
#include <setjmp.h>

#include "dsv.h"
#include "decaf.h"

#include "oobj.h"
#include "tree.h"

#include "traptypes.h"
#include "cm.h"
#include "res.h"
#include "binit.h"
#include "loader.h"

#define ERROR(name) { *(context->detail) = name; \
                        longjmp(context->jump_buffer, 1); }

char *CompiledCodeAttribute = 0;

unsigned short currentStringIndex=0;

int decaf;

int haveClinit = 0;

int ldrNameChange = 0;

static int doRes=0;
/*
* turn java/lang/ObjName to decafObjName
* turn sun/tools/tree/XX to decafXX
*/
void
useDecafRunTimeClass(char *cptr0)
{
   char *cptr1;
   char *cptr;
   char *cptr2;
   int nomore = 0;

   if ((cptr=strstr(cptr0, "sun/")) == NULL) {
    if ((cptr=strstr(cptr0, "java/")) == NULL) {
     return;
    }
   }

   /* cptr points to the begining */
   cptr1 = cptr;
   while (*cptr1 != '\0') {
    if (*cptr1 == ';') break;
    cptr1++;
   }

   if (*cptr1 == '\0') {
    nomore = 1;
    cptr1 = strrchr(cptr, '/');
   }
   else {
   /* cptr1 points to the end of the current identifier */
    cptr2 = cptr1;
    *cptr2 = '\0';
    cptr1 = strrchr(cptr, '/');
    *cptr2 = ';';
   }

   if (cptr1 == NULL) return;
   cptr1++;

   strcpy(cptr, "decaf");
   cptr = strchr(cptr, '\0');

   while (*cptr1 != '\0') {
    *cptr++ = *cptr1++;
   }
   *cptr = '\0';

   if (nomore == 0) useDecafRunTimeClass(cptr0);

   return;
}

/*
 * i < 0 : not found 
 */
findBinClass(char *className)
{
    register int i = -1;

    for (i = nbinclasses; --i >= 0 && strcmp(classname(binclasses[i]), className) != 0;);

    return(i);
}

collectBinClass(ClassClass * cb)
{
    register int i = -1;

    for (i = nbinclasses; --i >= 0 && strcmp(classname(binclasses[i]), classname(cb)) != 0;);

    if (i < 0) {
	if (nbinclasses >= sizebinclasses)
	    if (binclasses == 0)
		binclasses = (ClassClass **)
		    malloc(sizeof(ClassClass *) * (sizebinclasses = 50));
	    else
		binclasses = (ClassClass **)
		    realloc(binclasses, sizeof(ClassClass *)
			    * (sizebinclasses = nbinclasses * 2));
	if (binclasses == 0)
	    return (-1);
	i = nbinclasses;
	nbinclasses++;
    }
    binclasses[i] = cb;
    return(i);
}

void
DelBinClass(ClassClass * cb)
{
    register int i;
    for (i = nbinclasses; --i >= 0; )
	if (binclasses[i] == cb) {
	    binclasses[i] = binclasses[--nbinclasses];
	    break;
	}
}

static unsigned long get1byte(CICcontext *context)
{
    unsigned char *ptr = context->ptr;
    if (context->end_ptr - ptr < 1) {
	ERROR("Truncated class file");
    } else {
	unsigned char *ptr = context->ptr;
	unsigned long value = ptr[0];
	(context->ptr) += 1;
	return value;
    }
}

static unsigned long get2bytes(CICcontext *context)
{
    unsigned char *ptr = context->ptr;
    if (context->end_ptr - ptr < 2) {
	ERROR("Truncated class file");
    } else {
	unsigned long value = (ptr[0] << 8) + ptr[1];
	(context->ptr) += 2;
	return value;
    }
}


static unsigned long get4bytes(CICcontext *context)
{
    unsigned char *ptr = context->ptr;
    if (context->end_ptr - ptr < 4) {
	ERROR("Truncated class file");
    } else {
	unsigned long value = (ptr[0] << 24) + (ptr[1] << 16) + 
	                             (ptr[2] << 8) + ptr[3];
	(context->ptr) += 4;
	return value;
    }
}

static void getNbytes(CICcontext *context, int count, char *buffer) 
{
    unsigned char *ptr = context->ptr;
    if (context->end_ptr - ptr < count)
	ERROR("Truncated class file");
    if (buffer != NULL) 
	memcpy(buffer, ptr, count);
    (context->ptr) += count;
}


static char *getAsciz(CICcontext *context) 
{
    ClassClass *cb = context->cb;
    union cp_item_type *constant_pool = cb->constantpool;
    int nconstants = cb->constantpool_count;
    unsigned char *type_table = constant_pool[CONSTANT_POOL_TYPE_TABLE_INDEX].p;

    int value = get2bytes(context);
    if ((value == 0) || (value >= nconstants) || 
	   type_table[value] != (CONSTANT_Utf8 | CONSTANT_POOL_ENTRY_RESOLVED))
     {
	printf("Error: constant pool index is  0 < %d < %d\n", value, nconstants);
	printf("Error: type_table[value] is %d, %d, %d\n", type_table[value], CONSTANT_Utf8, CONSTANT_POOL_ENTRY_RESOLVED);
	ERROR("Illegal constant pool index");
     }

    currentStringIndex = value;

    return constant_pool[value].cp;
}

static char *getAscizFromClass(CICcontext *context, int value) 
{
    ClassClass *cb = context->cb;
    union cp_item_type *constant_pool = cb->constantpool;
    int nconstants = cb->constantpool_count;
    unsigned char *type_table = constant_pool[CONSTANT_POOL_TYPE_TABLE_INDEX].p;
    if ((value <= 0) || (value >= nconstants) 
	|| (type_table[value] != CONSTANT_Class)) {
	printf("Error: constant pool index is  0 < %d < %d\n", value, nconstants);
	printf("Error: type_table[value] is %d, %d, %d\n", type_table[value], CONSTANT_Utf8, CONSTANT_POOL_ENTRY_RESOLVED);
	ERROR("Illegal constant pool index");
    }
    value = constant_pool[value].i;

    currentStringIndex = value;

    if ((value <= 0) || (value >= nconstants) ||
	 (type_table[value] != (CONSTANT_Utf8 | CONSTANT_POOL_ENTRY_RESOLVED))) {
	printf("Error: constant pool index is  0 < %d < %d\n", value, nconstants);
	printf("Error: type_table[value] is %d, %d, %d\n", type_table[value], CONSTANT_Utf8, CONSTANT_POOL_ENTRY_RESOLVED);
	ERROR("Illegal constant pool index");
    }
    return constant_pool[value].cp;
}

/* In certain cases, we only need a class's name.  We don't want to resolve
 * the class reference if it isn't, already. 
 */

char *GetClassConstantClassName(cp_item_type *constant_pool, int index)
{
    unsigned char *type_table = constant_pool[CONSTANT_POOL_TYPE_TABLE_INDEX].p;
    switch(type_table[index]) {
        case CONSTANT_Class | CONSTANT_POOL_ENTRY_RESOLVED: {
	    ClassClass *cb = constant_pool[index].p;
	    return classname(cb);
	}

        case CONSTANT_Class: {
	    int name_index = constant_pool[index].i;
	    return constant_pool[name_index].cp;
	}
	    
	default:
	    return (char *)0;
    }
}

static void ReadLineTable(CICcontext *context, struct methodblock *mb)
{
    struct lineno *ln;
    int attribute_length = get4bytes(context);
    unsigned char *end_ptr = context->ptr  + attribute_length;
    int i;

    if ((mb->line_number_table_length = get2bytes(context)) > 0) {
     ln = (struct lineno *)malloc(mb->line_number_table_length * sizeof(struct lineno));
	mb->line_number_table = ln;
	for (i = mb->line_number_table_length; --i >= 0; ln++) {
	    ln->pc = get2bytes(context);
	    ln->line_number = get2bytes(context);
	}
    }
    if (context->ptr != end_ptr)
	ERROR("Line number table was wrong length?");
}	

static void ReadLocalVars(CICcontext *context, struct methodblock *mb)
{
    int attribute_length = get4bytes(context);
    unsigned char *end_ptr = context->ptr  + attribute_length;
    int i;
    if ((mb->localvar_table_length = get2bytes(context)) > 0) {
     struct localvar *lv;
     lv = (struct localvar *)malloc(mb->localvar_table_length * sizeof(struct localvar));
	mb->localvar_table = lv;
	for (i = mb->localvar_table_length; --i >= 0; lv++) {
	    lv->pc0 = get2bytes(context);
	    lv->length = get2bytes(context);
	    lv->nameoff = get2bytes(context);
	    lv->sigoff = get2bytes(context);
	    lv->slot = get2bytes(context);
	}
    }
    if (context->ptr != end_ptr)
	ERROR("Local variables table was wrong length?");
}	

unsigned Signature2ArgsSize(char *method_signature)
{
    char *p;
    int args_size = 0;
    for (p = method_signature; *p != SIGNATURE_ENDFUNC; p++) {
	switch (*p) {
	  case SIGNATURE_BOOLEAN:
	  case SIGNATURE_BYTE:
	  case SIGNATURE_CHAR:
	  case SIGNATURE_SHORT:
	  case SIGNATURE_INT:
	  case SIGNATURE_FLOAT:
	    args_size += 1;
	    break;
	  case SIGNATURE_CLASS:
	    args_size += 1;
	    while (*p != SIGNATURE_ENDCLASS) p++;
	    break;
	  case SIGNATURE_ARRAY:
	    args_size += 1;
	    while ((*p == SIGNATURE_ARRAY)) p++;
	    /* If an array of classes, skip over class name, too. */
	    if (*p == SIGNATURE_CLASS) { 
		while (*p != SIGNATURE_ENDCLASS) 
		  p++;
	    } 
	    break;
	  case SIGNATURE_DOUBLE:
	  case SIGNATURE_LONG:
	    args_size += 2;
	    break;
	  case SIGNATURE_FUNC:	/* ignore initial (, if given */
	    break;
	  default:
	    /* Indicate an error. */
	    return 0;
	}
    }
    return args_size;
}

static void ReadInCode(CICcontext *context, struct methodblock *mb)
{
    int attribute_length = get4bytes(context);
    unsigned char *end_ptr = context->ptr + attribute_length;
    int attribute_count;
    int code_length;
    int i;

    if (context->cb->minor_version <= 2) { 
	mb->maxstack = get1byte(context);
	mb->nlocals = get1byte(context);
	code_length = mb->code_length = get2bytes(context);
    } else { 
	mb->maxstack = get2bytes(context);
	mb->nlocals = get2bytes(context);
	code_length = mb->code_length = get4bytes(context);
    }
    mb->code = (unsigned char *)malloc(code_length);

    getNbytes(context, code_length, (char *)mb->code);
    if ((mb->exception_table_length = get2bytes(context)) > 0) {
	unsigned exception_table_size = mb->exception_table_length 
	                                  * sizeof(struct CatchFrame);
	mb->exception_table = (struct CatchFrame *)malloc(exception_table_size);
	for (i = 0; i < (int)mb->exception_table_length; i++) {
	    mb->exception_table[i].start_pc = get2bytes(context);
	    mb->exception_table[i].end_pc = get2bytes(context);		
	    mb->exception_table[i].handler_pc = get2bytes(context); 
	    mb->exception_table[i].catchType = get2bytes(context);
            mb->exception_table[i].compiled_CatchFrame = NULL;
	}
    }
    attribute_count = get2bytes(context);
    for (i = 0; i < attribute_count; i++) {
	char *name = getAsciz(context);
	if (strcmp(name, "LineNumberTable") == 0) {
	    ReadLineTable(context, mb);
	} else if (strcmp(name, "LocalVariableTable") == 0) {
	    ReadLocalVars(context, mb);
	} else {
	    int length = get4bytes(context);
	    getNbytes(context, length, NULL);
	}
    }
    if (context->ptr != end_ptr) 
	ERROR("Code segment was wrong length");
}

static void LoadConstantPool(CICcontext *context) 
{
    ClassClass *cb = context->cb;
    int nconstants = get2bytes(context);
    unsigned char *initial_ptr = context->ptr;
    cp_item_type *constant_pool;
    unsigned char *type_table;
    char *malloced_space;
    int malloc_size;
    int i;
    Java8 t1;
    
    if (nconstants < CONSTANT_POOL_UNUSED_INDEX) {
	ERROR("Illegal constant pool size");
    }
    
    constant_pool = (cp_item_type *)calloc(nconstants, sizeof(cp_item_type));
    type_table = (unsigned char *)calloc(nconstants, sizeof(char));
    cb->constantpool = constant_pool;
    cb->constantpool_count = nconstants;

    /* CONSTANT_POOL_TYPE_TABLE_INDEX is zero */
    /* which is a reserved location for JVM machine */
    constant_pool[CONSTANT_POOL_TYPE_TABLE_INDEX].p = type_table;

    /* This for-loop calculate the memory space needed (malloc_size) */
    /* CONSTANT_POOL_UNUSED_INDEX is one, of course */
    for (malloc_size = 0, i = CONSTANT_POOL_UNUSED_INDEX; i < nconstants; i++) {
	/* TSC : get the tag byte */
	int type = get1byte(context);
	switch (type) {
	  case CONSTANT_Utf8: {
	      int length = get2bytes(context);
	      malloc_size += length + 1;
	      getNbytes(context, length, NULL);
	      break;
	  }
	    
	  case CONSTANT_Class:
	  case CONSTANT_String:
	      getNbytes(context, 2, NULL);
	      break;

	  case CONSTANT_Fieldref:
	  case CONSTANT_Methodref:
	  case CONSTANT_InterfaceMethodref:
	  case CONSTANT_NameAndType:
	  case CONSTANT_Integer:
	  case CONSTANT_Float:
	      getNbytes(context, 4, NULL);
	      break;

	  case CONSTANT_Long:
	  case CONSTANT_Double: 
	      i++;
	      getNbytes(context, 8, NULL);
	      break;

	  default: 
	      ERROR("Illegal constant pool type");
	}
    }

    malloced_space = (char *)malloc(malloc_size);
    
    context->ptr = initial_ptr;

    /* create the data structure here */
    for (i = CONSTANT_POOL_UNUSED_INDEX; i < nconstants; i++) {
	int type = get1byte(context);

        /* store the tag into type table */
	CONSTANT_POOL_TYPE_TABLE_PUT(type_table, i, type);

        /* printf("type %d\n", type_table[i]); */

	switch (type) {
	  case CONSTANT_Utf8: {
	      int length = get2bytes(context);
	      char *result = malloced_space;
	      getNbytes(context, length, result);
	      malloced_space += (length + 1);
	      constant_pool[i].p = result;
	      result[length] = '\0';
	      CONSTANT_POOL_TYPE_TABLE_SET_RESOLVED(type_table, i);

	      if (strcmp(result, "<clinit>") == 0) {
		printf("<clinit> inside\n");
		haveClinit = 1;
	      }
/*
              if (decaf && ldrNameChange) useDecafRunTimeClass(result);
*/

	      break;
	  }
	
	  case CONSTANT_Class:
	  case CONSTANT_String:
	    constant_pool[i].i = get2bytes(context);
	    break;

	  case CONSTANT_Fieldref:
	  case CONSTANT_Methodref:
	  case CONSTANT_InterfaceMethodref:
	  case CONSTANT_NameAndType:
	    constant_pool[i].i = get4bytes(context);
	    break;
	    
	  case CONSTANT_Integer:
	  case CONSTANT_Float:
	    constant_pool[i].i = get4bytes(context);
	    CONSTANT_POOL_TYPE_TABLE_SET_RESOLVED(type_table, i);
	    break;

	  case CONSTANT_Long:
	  case CONSTANT_Double: {
	      unsigned high = get4bytes(context);
	      unsigned low = get4bytes(context);
	      int64_t value;
	      value = ll_add(ll_shl(uint2ll(high), 32), uint2ll(low));
	      SET_INT64(t1, &constant_pool[i], value);
	      CONSTANT_POOL_TYPE_TABLE_SET_RESOLVED(type_table, i);
	      i++;		/* increment i for loop, too */
	      /* Indicate that the next object in the constant pool cannot
	       * be accessed independently.    */
	      CONSTANT_POOL_TYPE_TABLE_PUT(type_table, i, 0);
	      CONSTANT_POOL_TYPE_TABLE_SET_RESOLVED(type_table, i);
	      break;
	  }

	  default:
	      ERROR("Illegal constant pool type");
	}
    }
}


void ReadInCompiledCode(void *context, struct methodblock *mb, 
			int attribute_length, 
			unsigned long (*get1byte)(), 
			unsigned long (*get2bytes)(), 
			unsigned long (*get4bytes)(), 
			void (*getNbytes)()) { 
}

createInternalClass(unsigned char *ptr, unsigned char *end_ptr, ClassClass *cb)
{
    int i, j;
    union cp_item_type *constant_pool;
    unsigned char *type_table;
    int attribute_count;
    unsigned fields_count;
    struct methodblock *mb;
    struct fieldblock *fb;
    struct CICcontext context_block;
    struct CICcontext *context = &context_block;
    char *detail = 0;

    context->ptr = ptr;
    context->end_ptr = end_ptr;
    context->cb = cb;
    context->detail = &detail;

    if (setjmp(context->jump_buffer)) {
     printf("%s\n", *context->detail);
     return(DSV_FAIL);
    }
    
    if (get4bytes(context) != JAVA_CLASSFILE_MAGIC) {
     ERROR("Bad magic number");
    }

    cb->minor_version = get2bytes(context);
    cb->major_version = get2bytes(context);
    if (cb->major_version != JAVA_VERSION) {
     ERROR("Bad major version number");
    }

    /* load constant pool */
    LoadConstantPool(context);
    constant_pool = cb->constantpool;
    type_table = constant_pool[CONSTANT_POOL_TYPE_TABLE_INDEX].p;

    /* access flag */
    cb->access = get2bytes(context) & ACC_WRITTEN_FLAGS;

    /* Get the name of the class */
    i = get2bytes(context);	/* index in constant pool of class */
    cb->name = getAscizFromClass(context, i);

    cb->nameIndex = currentStringIndex;

    /* add itself into the pool */
    /* itself is a pointer, instead of the index ? */
    constant_pool[i].p = cb;
    CONSTANT_POOL_TYPE_TABLE_SET_RESOLVED(type_table, i);

    /* Get the super class name. */
    i = get2bytes(context);	/* index in constant pool of class */
    if (i > 0) { 
     cb->super_name = getAscizFromClass(context, i);
     cb->superNameIndex = currentStringIndex;
    }
    else {
     cb->super_name = cb->name;
     cb->superNameIndex = cb->nameIndex;
    }


    i = cb->implements_count = get2bytes(context);
    if (i > 0) {
	unsigned j;
	cb->implements = (short *)calloc(i, sizeof(short));
	for (j = 0; j < i; j++) {
	    cb->implements[j] = get2bytes(context);
	}
    }

    /* fields are used to set fb->static_address or &(fb->static_value) */
    /* They are static variables, including static classes */
    fields_count = cb->fields_count = get2bytes(context);
	/* added to get rid of purify UMR in the case
	   when field_count is 0, otherwise cb->fields remains uninit'ed */
	cb->fields = NULL;
    if (fields_count > 0) 
        cb->fields = (struct fieldblock *)
	       calloc(cb->fields_count, sizeof(struct fieldblock));
    for (i = fields_count, fb = cb->fields; --i >= 0; fb++) {
	fieldclass(fb) = cb;
	fb->access = get2bytes(context) & ACC_WRITTEN_FLAGS;

	fb->name = getAsciz(context);
        /* for string reuse */
	fb->nameIndex = currentStringIndex;

	fb->signature = getAsciz(context);
        /* for string reuse */
	fb->sigIndex = currentStringIndex;

	attribute_count = get2bytes(context);
	for (j = 0; j < (int)attribute_count; j++) {
	    char *name = getAsciz(context);
	    int length = get4bytes(context);
	    if ((fb->access & ACC_STATIC) 
		 && strcmp(name, "ConstantValue") == 0) {
		if (length != 2) 
		    ERROR("Wrong size for VALUE attribute");
		fb->access |= ACC_VALKNOWN;
		/* we'll change this below */
		fb->u.offset = get2bytes(context); 
	    } else {
		getNbytes(context, length, NULL);
	    }
	}
    }

    if ((cb->methods_count = get2bytes(context)) > 0) 
	cb->methods = (struct methodblock *)
	            calloc(cb->methods_count, sizeof(struct methodblock));
    for (i = cb->methods_count, mb = cb->methods; --i >= 0; mb++) {
	fieldclass(&mb->fb) = cb;
	mb->fb.access = get2bytes(context) & ACC_WRITTEN_FLAGS;
	mb->fb.name = getAsciz(context);
        /* for string reuse */
	mb->fb.nameIndex = currentStringIndex;

	mb->fb.signature = getAsciz(context);
        /* for string reuse */
	mb->fb.sigIndex = currentStringIndex;

	mb->args_size = Signature2ArgsSize(mb->fb.signature) 
	                + ((mb->fb.access & ACC_STATIC) ? 0 : 1);
	attribute_count = get2bytes(context);
	for (j = 0; j < attribute_count; j++) {
	    extern char *CompiledCodeAttribute;
	    char *name = getAsciz(context);
	    if (CompiledCodeAttribute != NULL 
		     && strcmp(name, CompiledCodeAttribute) == 0
		     && cbLoader(cb) == 0) {
		int attribute_length = get4bytes(context);
		ReadInCompiledCode(context, mb, attribute_length, 
				   get1byte, get2bytes, get4bytes, getNbytes);
	    } else if ((strcmp(name, "Code") == 0) 
		       && ((mb->fb.access & (ACC_NATIVE | ACC_ABSTRACT))==0)) {
		ReadInCode(context, mb);
	    } else {
		int length = get4bytes(context);
		getNbytes(context, length, NULL);
	    }
	}
    }

    /* See if there are class attributes */
    attribute_count = get2bytes(context); 
    for (j = 0; j < attribute_count; j++) {
	char *name = getAsciz(context);
	int length = get4bytes(context);
	if (strcmp(name, "SourceFile") == 0) {
	    if (length != 2) {
		ERROR("Wrong size for VALUE attribute");
	    }
	    cb->source_name = getAsciz(context);
	} else {
	    getNbytes(context, length, NULL);
	}
    }

    return DSV_SUCCESS;
}

loadSuperClass(char *className, int res)
{
   char fn[BUFSIZ];

   /* look for the existing loaded class */
   if (findBinClass(className) >= 0) {
    return(DSV_SUCCESS);
   }

   sprintf(fn, "%s.class", className);

   if (loadClassFile(fn, res) == DSV_FAIL) {
    return(DSV_FAIL);
   }

   return(DSV_SUCCESS);

}

/* returns 0 if no error, non-0 if error */

int initFile (char *fname)

{
    FILE *fp = (FILE *) fopen (fname, "r");
    if (fp == NULL)
        return 1;

    printf ("reading init file: %s\n", fname);
    copyInitFile (fp);
    fclose (fp);
    return 0;
}

/* load the init file corresponding to the class file in path */
static void loadInitFile (char *path)

{
    char fname[BUFSIZ];
    char *cptr;

    /* load .init file if it exists */
    strcpy (fname, path);
    /* get last occurrence of '.' in the path, replace with .init */
    cptr = (char *) strrchr (fname, '.');
    if (cptr != NULL)
    {
        cptr++;
        strcpy (cptr, "init");
        initFile (fname);
    }
}

#undef CHECKING_FREAD
#define CHECKING_FREAD(p1, p2, p3, p4) { \
        size_t n_elts = (p3); \
        if (fread ((p1), (p2), n_elts, (p4)) != n_elts) \
	    { fprintf (stderr, "Error reading initialisation file\n"); \
              return 1; }}

/* returns 0 if no error, non-0 if error */

int bInitFile (char *fname)

{
    unsigned int signature, version;
    FILE *fp = (FILE *) fopen (fname, "r");

    if (fp == NULL) 
        return 1;

    printf ("reading binary init file: %s\n", fname);

    CHECKING_FREAD (&signature, sizeof (signature), 1, fp);
    if (signature != BINIT_SIGNATURE)
    {
        fprintf (stderr, "Warning: Binary initialisation file %s ignored, "
                         "does not have correct signature\n", fname);
        return 1;
    }
    CHECKING_FREAD (&version, sizeof (version), 1, fp);
    if (version != BINIT_VERSION)
    {
        fprintf (stderr, "Warning: Binary initialisation file %s ignored, "
                         "has incorrect version number (%d), needs to "
                         "be %d\n", fname, version, BINIT_VERSION);

        return 1;
    }
    copyBinaryInitFile(fp);
    fclose(fp);
    return 0;
}

/* load the binit file corresponding to the class file in path */
static void loadBinaryInitFile (char *path)

{
    char fname[BUFSIZ];
    char *cptr;
    FILE *fp;

    strcpy (fname, path);
    /* get last occurrence of '.' in the path, replace with .binit */
    cptr = (char *) strrchr (fname, '.');
    if (cptr != NULL) 
    {
        cptr++;
        strcpy (cptr, "binit");
        bInitFile (cptr);
    }
}

/* 
 * relocatable class file loader
 */
loadClassFile(char *fn, int needRes)

{
   char path[BUFSIZ];
   int fd;
   struct stat st;
   unsigned char *external_class;
   ClassClass *cb;
   int i;
   decafClass *classPtr;
   FILE *initfp;
   char *cptr;
   int j;
   int *iptr;

   doRes = needRes;
   strcpy (path, fn);
   fd = open(fn, O_RDONLY);
   if ((fd == -1) && (getenv("DSVHOME") != NULL)) {
    sprintf(path, "%s/class/%s", (char *)getenv("DSVHOME"), fn);
    fd = open(path, O_RDONLY);
    if (fd == -1) {
     printf("Warning: Class file %s or %s not found\n", fn, path);
     return(DSV_FAIL);
    }
   }
   /* path now contains the path used to get to the class file */

   /* define the space for commonMemory */
   /* Don't worry, cm is init'ed only once */
   if (cmInit(NULL) == DSV_FAIL) {
    printf("Error: Cannot initialize common memory\n");
    return(DSV_FAIL);
   }

   /* Now, we have the real address to load the class file */

   /* check the size */
   if (fstat(fd, &st) < 0) {
    perror("Error: Cannot fstat()");
    close(fd);
    return(DSV_FAIL);
   }
   if (st.st_size > (CM_SIZE - (int)currentAddress)) {
    /* This checking is not optimal */
    printf("Error: The class file is too big\n");
    close(fd);
    return(DSV_FAIL);
   }

   if((decafClassTableCount + 1) > (decafClassTableSize/4 - ARRAY_FOOTER)) {
      printf("Warning: Maximum class table size exceeded\n");
   } 

   /* read the entire class file */
   external_class = (unsigned char *)malloc(st.st_size);
   if (read(fd, (void *)external_class, st.st_size) != st.st_size) {
    perror("Cannot complete read()");
    close(fd);
    return(DSV_FAIL);
   }

   close(fd);

   /* create the class in common memory */
   /* external_class -> common_memory + address */
   cb = (ClassClass *)malloc(sizeof(ClassClass));
   if (createInternalClass(external_class, external_class + st.st_size, cb) == DSV_FAIL) {
    free(external_class);
    return(DSV_FAIL);
   }

   if (haveClinit == 1) {
    iptr = (int *)getAbsAddr(FLUSH_LOCATION);
    *iptr = *iptr | 0x00000f00;
   }

   free(external_class);

   if ((j=findBinClass(cb->name)) >= 0) {
	/* class is loaded */
    printf("Class %s is already loaded\n", cb->name);
    return(DSV_SUCCESS);
   }

   i = collectBinClass(cb);
   if (i== -1) {
    return(DSV_SUCCESS);
   }

   /* first load the .binit file, then the .init file, then the .class file */

   loadBinaryInitFile (path);
   loadInitFile (path);

   if (decaf) {
    /* look for the existing loaded class */
    if ((j=findBinClass(cb->super_name)) < 0) {
     sprintf(path, "%s.class", cb->super_name);

     if (loadClassFile(path, needRes) == DSV_FAIL) {
      printf("Error: Cannot find the super class %s\n", cb->super_name);
      return(DSV_FAIL);
     }
     j = findBinClass(cb->super_name);
    }

    cb->super = j;
    cb->slottbl_size = 0;
    cb->instance_size = 0;
    cb->slottable = NULL;
    cb->methodtable_size = 0;
    cb->methodtable = NULL;

    resolveFields(cb, binclasses[j]);
    resolveMethods(cb, binclasses[j]);

    /* Now, all the super classes are loaded */
    if (needRes == 1) {
     changeOpcodeToQuick(cb);
     /* @@ */
     resolveConstantPool(cb);
    }

    classPtr = (decafClass *)copyOneBinClass(cb);
    if (classPtr == NULL) {
     return(DSV_FAIL);
    }

   }

   return(DSV_SUCCESS);
}

loadClassFileMethod(char *fn, int index, int loc)
{
   char path[BUFSIZ];
   char fname[BUFSIZ];
   char classname[BUFSIZ];
   int fd;
   struct stat st;
   unsigned char *external_class;
   ClassClass *cb;
   int i;
   decafClass_for_classLoader *classPtr, *classPtrAbs;
   int *traploc;
   int *cploc;
   static int trapAddress = TRAP_ADDRESS + NUM_OF_TRAPS*8;
   static int trapCodeLength = 0;
   FILE *initfp;
   char *cptr;

   /* printf("decaf = %d, ldNameChange = %d\n", decaf, ldrNameChange); */

   fd = open(fn, O_RDONLY);
   if ((fd == -1) && (getenv("DSVHOME") != NULL)) {
    sprintf(path, "%s/class/%s", (char *)getenv("DSVHOME"), fn);
    fd = open(path, O_RDONLY);
    if (fd == -1) {
     return(DSV_FAIL);
    }
   }

   /* define the space for commonMemory */
   /* Don't worry, init only once */
   if (cmInit(NULL) == DSV_FAIL) {
    printf("ERROR: Cannot initialize cm.\n");
    return(DSV_FAIL);
   }

   /* Now, we have the real address to load the class file */

   /* check the size */
   if (fstat(fd, &st) < 0) {
    printf("ERROR: Cannot execute fstat()");
    close(fd);
    return(DSV_FAIL);
   }
   if (st.st_size > (CM_SIZE - (int)currentAddress)) {
    /* This checking is not optimal */
    printf("ERROR: The class file is too big\n");
    close(fd);
    return(DSV_FAIL);
   }

   /* read the entire class file */
   external_class = (unsigned char *)malloc(st.st_size);
   if (read(fd, (void *)external_class, st.st_size) != st.st_size) {
    printf("ERROR: Cannot complete read()");
    close(fd);
    return(DSV_FAIL);
   }

   close(fd);

   /* create the class in common memory */
   /* external_class -> common_memory + address */
   cb = (ClassClass *)malloc(sizeof(ClassClass));
   if (createInternalClass(external_class, external_class + st.st_size, cb) == DSV_FAIL) {
    free(external_class);
    return(DSV_FAIL);
   }

   free(external_class);

   traploc = (int *)(TRAP_ADDRESS | (loc << 3));
   if ((int)traploc > CLASS_ADDRESS) {
    printf("ERROR: loaded into loc %08xh which is overflow\n", loc);
    return(DSV_FAIL);
   }

   /* printf("trap loc %08x (%08x)\n", traploc, trapAddress); */

   traploc = (int *)getAbsAddr(traploc);

   if (loc == RESET_ADDRESS) {
    /* load .init file if exists */
    strcpy(fname, fn);
    cptr = (char *)strchr(fname, '.');
    if (cptr != NULL) {
     cptr++;
     strcpy(cptr, "init");

     initfp = (FILE *)fopen(fname, "r");
     if ((initfp == NULL) && (getenv("DSVHOME") != NULL)) {
      sprintf(path, "%s/class/%s", (char *)getenv("DSVHOME"), fname);
      initfp = (FILE *)fopen(path, "r");
     }
     if (initfp == NULL) {
      goto end;
     }
     copyInitFile(initfp);
     fclose(initfp);
    }

end:
    copyOneMethod(cb, index, loc);

    strncpy(classname, fn, strlen(fn)-6); /* .class suffix has size 6 */
    classname[strlen(fn)-6] = '\0';    
    classPtr = cmFindClass(classname);/* Is class loaded in system table? */
    if (classPtr == NULL) {        /* If not then need to create CP table */

       /* cploc is rel address */
       cploc = (int *)cmMalloc(sizeof(decafCpItemType)*cb->constantpool_count);
       copyConstantPool(cb->constantpool_count, cb->constantpool, cploc);
    }
    else {
       classPtrAbs = (decafClass_for_classLoader *)getAbsAddr(classPtr);
       cploc = (int*)((int)classPtrAbs->constpool + 8); 
    }

    *traploc = RESET_ADDRESS;   /* Set trap table entry with handler addrs*/
    *(traploc + 1) = (int)cploc;/* Set trap table entry with CP table addrs*/

    return(DSV_SUCCESS);
   }

   /* use malloc so that we don't overflow the trap area */
   trapCodeLength = cb->methods[index].code_length;
   trapAddress = (int)cmMalloc(trapCodeLength);

   *traploc = trapAddress;

   /* printf("trap loaded at %08x\n", trapAddress); */

   if (trapCodeLength != copyOneMethod(cb, index, trapAddress)) {
    printf("ERROR: trap length is not right\n");
    return(DSV_FAIL);
   }

   strncpy(classname, fn, strlen(fn)-6); /* .class suffix has size 6 */    
   classname[strlen(fn)-6] = '\0';
   classPtr = cmFindClass(classname);/* Is class loaded in system table? */   
   if (classPtr == NULL) {        /* If not then need to create CP table */
      cploc = (int *)cmMalloc(sizeof(decafCpItemType)*cb->constantpool_count);
      copyConstantPool(cb->constantpool_count, cb->constantpool, cploc);
   }
   else {
      classPtrAbs = (decafClass_for_classLoader *) getAbsAddr(classPtr);
      cploc = (int*) ((int)classPtrAbs->constpool + 8); 
   }
     
   *(traploc+1) = (int)cploc;

/* 
   dumpRelConstantPool(cb->constantpool_count, cploc, stdout);
*/

   return(DSV_SUCCESS);
}
