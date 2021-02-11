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




static char *sccsid = "@(#)copy.c 1.23 Last modified 02/26/99 18:36:33 SMI";

#include <stdio.h>
#include <setjmp.h>

#include "dsv.h"
#include "oobj.h"
#include "tree.h"

#include "decaf.h"
#include "loader.h"
#include "cm.h"
#include "opcodes.h"
#include "zlib.h"


#define CREATE_JAVA_OBJ(memsize, objptr, objname, mvb) \
	tmpptr = (int *)cmMalloc(memsize);	\
	abstmpptr = (int *)getAbsAddr(tmpptr);	\
	*abstmpptr = 0;		/* monitor pointer */  \
	objptr = (objname *)(tmpptr + MONPTR_SIZE);  /* points to MVB */ \
	abs##objptr = (objname *)getAbsAddr(objptr); \
	abs##objptr->methodVectorBase = mvb;

#define CREATE_JAVA_ARRAY(memsize, arrptr, arrname, elemsize, cnt, type, mvb) \
	tmpptr = (int *)cmMalloc(memsize);	\
	abstmpptr = (int *)getAbsAddr(tmpptr);	\
	*abstmpptr = 0;	 /* set monitor_ref to null */	\
	arrptr = (arrname *)(tmpptr + MONPTR_SIZE);  /* get ptr to mvb */ \
	abs##arrptr = (arrname *)getAbsAddr(arrptr);	\
	abs##arrptr->methodVectorBase = (methodVector*)(((int)mvb & 0xfffffffc)|elemsize); \
	abs##arrptr->arraySize = cnt; /* set number of elements */ \
        abstmpptr = (int *)((int*)abs##arrptr+((memsize+3)&0xfffffffc)/4 - 3);\
        *abstmpptr = 1; /* set dimensions to 1 */ \
        abstmpptr = (int *)((int*)abs##arrptr+((memsize+3)&0xfffffffc)/4 - 2);\
        *abstmpptr = type; /* set array type */      
         
	


static decafClass_for_classLoader *currentclass;

/* Vars for bootstrapping classes Object, Class, Field, Method ... */
static int bsdone = 0;
static methodVector *mvb_object = 0;          /* mvb of class Object */
static methodVector *mvb_class = 0;	      /* mvb of class Class */
static methodVector *mvb_field = 0;	      /* mvb of class Field */
static methodVector *mvb_method = 0;	      /* mvb of class Method */
static methodVector *mvb_exceptionBlk = 0;    /* mvb of class ExceptionBlk */
static methodVector *mvb_current = 0;	      /* mvb of current class object */
static decafClass   *classptr_object = 0;     /* C ptr to class Object */
static decafClass   *classptr_class = 0;      /* C ptr to class Class */
static decafClass   *classptr_field = 0;      /* C ptr to class Field */
static decafClass   *classptr_method = 0;     /* C ptr to class Method */
static decafClass   *classptr_exceptionBlk = 0; /* C ptr to class ExceptionBlock */


static int mainMethod;
int maincheck = 1;
extern int cmNd;
static int clinit;
static int main;
static int finalizer;

/* Opcode lengths of opcodes specified in "opcode_type" */
/* All opcodes specified in "priv_opcode_type" are 2 bytes */
/* See ldr/src/opcodes.h */
const int opcLengthsTab[] = {
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 2, 3, 3, 2,
	2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 
        3, 3, 3, 3, 3, 3, 3, 3, 2, 99, 99, 1, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 
        3, 3, 5, 0, 3, 2, 3, 1, 1, 3, 3, 1, 1, 0, 4, 3, 3, 5, 5, 1, 2, 3, 3, 
        3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 
        3, 3, 3, 3, 3, 2, 3, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
};



int xreturnReplace(char code[], int start, int length) {

   /* This function replaces all return's with exit_sync_method in the 
   "code" array starting at offset "start" */
   int index;
   int opc1, opc2;
   int xreturn;

   for (index = start; index < (start+length); ) {
      opc1 = code[index] & 0xFF;
      if ((index + 1) < start+length)
         opc2 = code[index+1] & 0xFF;
      else
	 opc2 = 0;
     
      switch (opc1) {
	  case opc_wide:
		switch (opc2) {
		  case opc_aload: case opc_astore:
		  case opc_fload: case opc_fstore:
		  case opc_iload: case opc_istore:
		  case opc_lload: case opc_lstore:
		  case opc_dload: case opc_dstore:
		  case opc_ret:
			index +=  4;
			break;
		  case opc_iinc:
			index +=  6;
			break;
		  default:
			index += 2; /* undefined opcode */
		}
                break;

	  case opc_priv:
                index += 2;
                break;

          case opc_return: case opc_ireturn: case opc_freturn:
          case opc_dreturn: case opc_lreturn: case opc_areturn:
                code[index] = (char)exit_sync_method;
                xreturn = opc1;
                index += 1;
                break;
          case opc_lookupswitch:
	        {  int npairs;
                   index++;
                   while ((index % 4) != 0) { /* skip padding */
                      index++;
                   }
                   index += 4; /* skip default byte */
                   npairs = (code[index]<<24)|(code[index+1]<<16)|
                            (code[index+2]<<8)|code[index+3];
                   index += 4; /* skip npair value */
                   index += (npairs)*4; /* skip npairs */
                   break;
                }	        
                break;
          case opc_tableswitch: 
	        {  int low, high;
                   index++;
                   while ((index % 4) != 0) { /* skip padding */
                      index++;
                   }
                   index += 4; /* skip default byte */
                   low = (code[index]<<24)|(code[index+1]<<16)|
                         (code[index+2]<<8)|code[index+3];
                   index += 4; /* skip low */
                   high = (code[index]<<24)|(code[index+1]<<16)|
                         (code[index+2]<<8)|code[index+3];
                   index += 4; /* skip high */
                   index += (high - low + 1)*4; /* skip offsets */
                   break;
                }
	  default:
		  if ((opc1 >= 0) || (opc1 <  
		  sizeof(opcLengthsTab)/sizeof(int)))
		     index += opcLengthsTab[opc1];
		  else {
                        printf("Undefined opcode found in code stream\n");
		        index += 1;  /* undefined opcode */
		     }

      }

   }

   return xreturn;
}

unsigned int getStringKey(char *str)
{
   unsigned short len;
   unsigned short key;
   unsigned int ret;
   int i;

   len = (unsigned short)strlen(str);

   key = 0;
   for (i=0; i < len; i++) {
    key += str[i] << i;
   }

   ret = len << 16;
   ret = ret | (unsigned int)key;

   return(ret);
}

void
copyObjHintBlk(ClassClass *from, decafObjectHint_for_classLoader *to)
{
   int i;
   int *savto;
   int *tmpptr, *abstmpptr;
   decafMethod_for_classLoader **mvp;
   struct methodblock *mb;
   decafField_for_classLoader **fbp;
   struct fieldblock *fb;
   fieldArray *fAptr, *absfAptr;
   methodVector *mvptr, *absmvptr;

   if (DEBUG_LOADER) 
   printf("Entering copyObjHintBlk\n");

   savto = (int *)to;  
   to = (decafObjectHint_for_classLoader *)getAbsAddr(to);

   /* copy slot table */
   to->objectSize = from->slottbl_size;
   to->numOfInstVars = from->numOfInstVars;

   if (to->objectSize == 0) {
    to->instVars = NULL;
   }
   else {
    /*create field array for instance variables, MVB = MVB of current object */
    CREATE_JAVA_ARRAY(sizeof(int)*(ARRAY_HEADER+to->objectSize+ARRAY_FOOTER), 
                      fAptr, fieldArray, SIZEP_OF_OBJREF, to->objectSize, 
                      (int)classptr_field, mvb_object)
    to->instVars = fAptr;	
    fbp = (decafField_for_classLoader **)getAbsAddr(fAptr->field);
    for (i=0; i < to->objectSize; i++) {
     fb = from->slottable[i];
     if (fb != NULL) {
      fbp[i] = (decafField_for_classLoader *)fb->relfb;
     }
     else {
      fbp[i] = 0 ;
     }
    }
   }


   to->numOfInstMethods = from->methodtable_size;

   /*
   ** Class pointer must point to the location after the MVB
   ** pointer of the class object.  C compatible pointer.
   ** from->relcb points to mvb field.
   */
   to->classPtr = (decafClass *)((int)from->relcb + 4);

   /*
   ** Constant pool pointer must point to the first item of the
   ** constant pool array.  C compatible pointer.
   ** from->relcp points to MVB field.
   */
   to->constantpool = (decafCpItemType *)((int)from->relcp + 8);


   /* copy method table */

   /* Method table is appended to the end of the ObjectHintBlock */
   absmvptr = (methodVector *)&(to->methods);

   for (i=0; i < to->numOfInstMethods; i++) {
    mb = (from->methodtable)->methods[i];
    /*
    ** instMethods points to a location in method table
    ** that contains address of the method.  C style compatible.
    */
    {
	int	* addr;

	/* The location *mb->relmb must point to
	** first element and not MVB of method object.
	*/
	addr = (int *)getAbsAddr(mb->relmb);
        absmvptr->instMethods[i] = (decafMethod_for_classLoader *)(*addr + 4);
        
    }

   }

   if (DEBUG_LOADER) 
   printf("Exiting copyObjHintBlk\n");
}

void
copyConstantPool(int cnt, cp_item_type *from, decafCpItemType *to)
{
   int i;
   int *tmpptr, *abstmpptr;
   decafCpItemType *toAbs;
   tarArray *tarptr, *abstarptr;
   unsigned char *decafTypeTable;
   unsigned char *decafTypeTableAbs;
   unsigned char *typeTable;
   char *cptr;
   char *cptrAbs;
   decafString *dptr;
   unsigned int *iAbs;

   /* create a type and resolution array, MVB = MVB of current object */
   CREATE_JAVA_ARRAY((sizeof(int)*ARRAY_HEADER+sizeof(unsigned char)*cnt+
                      sizeof(int)*ARRAY_FOOTER), tarptr, tarArray, 
                      SIZEP_OF_BYTE, cnt, SIGC_BYTE, mvb_object)

   decafTypeTable =  (unsigned char *)(tarptr->type);
   typeTable = (unsigned char *)from[CONSTANT_POOL_TYPE_TABLE_INDEX].p;

   /* fill in the type table */
   decafTypeTableAbs = (unsigned char *)getAbsAddr(decafTypeTable);
   memcpy(decafTypeTableAbs, typeTable, cnt);

   /* fill in the constant pool */
   toAbs = (decafCpItemType *)getAbsAddr(to);
      /*
      ** Based on new design, if item is a aray object,
      ** Constant pool entry must point to first element of
      ** the class object (as opposed to MVB address)
      ** That is using MVB+8 for array objects.
      */
   toAbs[CONSTANT_POOL_TYPE_TABLE_INDEX].p = (void *)((int)tarptr + 8);
   for (i=CONSTANT_POOL_UNUSED_INDEX; i < cnt; i++) {
    switch (CONSTANT_POOL_TYPE_TABLE_GET_TYPE(decafTypeTableAbs,i)) {
     case CONSTANT_Utf8:
      dptr = (decafString *)cmMalloc(4+strlen(from[i].cp)+1);
      /* Get the length and hash vale */
      /* @@ */
      iAbs = (unsigned int *)getAbsAddr(dptr);
      *iAbs = getStringKey(from[i].cp);
    
      cptrAbs = (char *)getAbsAddr((char *)dptr+4);
      strcpy(cptrAbs, from[i].cp);

      toAbs[i].dp = dptr;
      break;
     case CONSTANT_Class:
      /*
      ** If resolved item is a class object,
      ** the constant pool entry must point to the first field of
      ** the class object (as opposed to the MVB address)
      ** That is MVB+4 for objects and MVB+8 for array objects.
      ** These are objects from item1, item2 etc.
      */
      if (decafTypeTableAbs[i] & CONSTANT_POOL_ENTRY_RESOLVED) {
          /* use our own class pointer */
          toAbs[i].p = (void *)((int)currentclass + 4);
      }
      else {
          /* store object name for later resolution */
          toAbs[i].p = from[i].p;
      }
      break;
     default:
      toAbs[i].p = from[i].p;
      break;
    }
   }
}

void copyFields(int cnt, struct fieldblock *from, decafField_for_classLoader **to)
{
   int i;
   int *tmpptr, *abstmpptr;
   char *cptr;
   char *cptrAbs;
   decafCpItemType *cpAbs;
   decafClass_for_classLoader *clsAbs;
   decafField_for_classLoader **relfb, **absfb;
   decafField_for_classLoader *foptr, *absfoptr;

   relfb = to;
   clsAbs = (decafClass_for_classLoader *)getAbsAddr(currentclass);
   tmpptr = (int *)clsAbs->constpool + ARRAY_ITEM0;
   cpAbs = (decafCpItemType *)getAbsAddr(tmpptr);

   for (i=0; i< cnt; i++) {
    absfb = (decafField_for_classLoader **)getAbsAddr(&relfb[i]);
  
    /* create a field object, MVB = MVB of class field */
    CREATE_JAVA_OBJ(sizeof(decafField_for_classLoader)+sizeof(int)*MONPTR_SIZE,
		foptr, decafField_for_classLoader, mvb_field)
    *absfb = foptr;

    /* string reuse */
    /* signature */
    absfoptr->signature = cpAbs[from[i].sigIndex].dp;

    /* store its own relative location */
    from[i].relfb = (void *)foptr;

    /* This should be currentclass which is a java object */
    absfoptr->class = currentclass;

    /* Object to point to the MVB address and not the actual address */
    /* access */
    absfoptr->access = from[i].access;
    /* object */
    absfoptr->object = from[i].u.static_value;

    /* make use of the string in the constant pool */
    /* name */
    absfoptr->name = cpAbs[from[i].nameIndex].dp;

    if (from[i].access & ACC_STATIC) { /*Initialize static fields */
        if (from[i].u.offset != 0) {
           char* cptr; 
           cptr = getAbsAddr((int)absfoptr->signature + 4);
	   if ((strcmp(cptr,"J")==0) || (strcmp(cptr, "D")==0)) {
              int* iptr = (int*)cmMalloc(SIZEB_OF_INT * 3);
              int* absiptr = (int*)getAbsAddr(iptr);
              *absiptr = cpAbs[from[i].u.offset].i;
              absiptr++;
              *absiptr = cpAbs[from[i].u.offset + 1].i;
              absiptr++;
              *absiptr = (int)foptr;
              absfoptr->object = (int)iptr;
           }
           else {
              absfoptr->object = cpAbs[from[i].u.offset].i;
           }
	}
    }

    if (strcmp(from[i].name, "main") == 0) {
     if (maincheck) mainMethod = 1;
    }
   }

   return;
   
}

void copyMethodFields(int cnt, struct fieldblock *from, decafMethodField *to)
{
   int i;
   int *tmpptr;
   char *cptr;
   char *cptrAbs;
   decafCpItemType *cpAbs;
   decafClass_for_classLoader *clsAbs;
   decafMethodField *relfb;

   relfb = to;
   to = (decafMethodField *)getAbsAddr(to);
   clsAbs = (decafClass_for_classLoader *)getAbsAddr(currentclass);
   tmpptr = (int *)clsAbs->constpool + ARRAY_ITEM0;
   cpAbs = (decafCpItemType *)getAbsAddr(tmpptr);

   for (i=0; i< cnt; i++) {
    /* string reuse */
    /* siganature */
    to[i].signature = cpAbs[from[i].sigIndex].dp;

    /* store its own relative location */
    from[i].relfb = (void *)&relfb[i];

    /* class */
    /* The class field in a method object is a reference to the */
    /* Class object representing the method's class */
    to[i].class = (decafClass_for_classLoader *)((int)currentclass);

    /*
    ** Method object Constant Pointer (CP), must point to
    ** the first item in constant pool array and not the MVB
    ** location.
    */
    to[i].constpool = (int *)((int)(clsAbs->constpool) + 8);
    /* access */
    to[i].access = from[i].access;

#if 0
    /* object */
    to[i].object = from[i].u.static_value;
#endif

    /* make use of the string in the constant pool */
    /* name */
    to[i].name = cpAbs[from[i].nameIndex].dp;

    if (strcmp(from[i].name, "main") == 0) {
     if (maincheck) mainMethod = 1;
    }

    if (strcmp(from[i].name, "main") == 0) main = 1;
    if (strcmp(from[i].name, "<clinit>") == 0) clinit = 1;
    if (strcmp(from[i].name, "finalize") == 0) finalizer = 1;

   }

   return;
   
}

#define SYNC_PROLOGUE_SIZE 12
void copyMethods(int cnt, struct methodblock *from, decafMethod_for_classLoader **to)
{

   int *tmpptr, *abstmpptr;
   int mindex, bindex, offset;
   char *cptr;
   exceptionArray *eaptr, *abseaptr;
   int entries;
   decafExceptionBlock *ebptr, *absebptr;
   decafMethod_for_classLoader **relmb, **absmb;
   decafMethod_for_classLoader *moptr, *absmoptr;
   static int SYNC_METHODS = -1;
   char* s;

   if (DEBUG_LOADER) 
   printf("Entering copyMethods\n");

   if (SYNC_METHODS == -1) {
      if ((s = (char *)getenv("PICOJAVA_SYNC_METHODS")) != NULL) 
      {
          unsigned int mb = (unsigned int) strtoul (s, (char **) NULL, 0);
          if (mb != 0)
          {
              printf ("PICOJAVA_SYNC_METHODS on\n");
              SYNC_METHODS = 1;
          }
          else {
              printf ("PICOJAVA_SYNC_METHODS off\n");
              SYNC_METHODS = 0;
          }
      } else {
          printf ("PICOJAVA_SYNC_METHODS off\n");
          SYNC_METHODS = 0;
      }
   }
   
   relmb = to;

   for (mindex=0; mindex< cnt; mindex++) {
    /* create method objects */
    absmb = (decafMethod_for_classLoader **)getAbsAddr(&relmb[mindex]);
    from[mindex].relmb = (void *)&relmb[mindex];
   
    /* create a method object, MVB = MVB of class method */ 
    CREATE_JAVA_OBJ(sizeof(decafMethod_for_classLoader)+
    sizeof(int)*MONPTR_SIZE, moptr, decafMethod_for_classLoader, mvb_method)
    *absmb = moptr;  /* points to method object MVB area*/


    /* code */
    if (SYNC_METHODS) {
       /* Implemented synchronization scheme for methods */
       if (from[mindex].fb.access & ACC_SYNCHRONIZED) { 
             cptr = (char *) cmMalloc(sizeof(unsigned char) * 
                          (from[mindex].code_length + SYNC_PROLOGUE_SIZE) );
       }
       else {
	 cptr = 
         (char *)cmMalloc(sizeof(unsigned char)*from[mindex].code_length);
       }
    }
    else {
       cptr = (char *)cmMalloc(sizeof(unsigned char)*from[mindex].code_length);
    }

    absmoptr->code = (unsigned char *)cptr;
    from[mindex].relcode = absmoptr->code;
    cptr = (char *)getAbsAddr(cptr);

    if (SYNC_METHODS) {
       if (from[mindex].fb.access & ACC_SYNCHRONIZED) 
       { 
         memcpy((char *)&cptr[SYNC_PROLOGUE_SIZE], (char *)from[mindex].code, 
                (int)from[mindex].code_length);
 
         if(from[mindex].fb.access & ACC_STATIC)
         {
	   /* Add the following code sequence:
              0: get_current_class;
              2: monitorenter; 
              3: jsr +6; 
              6: get_current_class;
              8: monitorexit;
              9: xreturn;
	     10: nop;   padding to avoid problems w/ tableswitch/lookupswitch 
	     11: nop;   padding to avoid problems w/ tableswitch/lookupswitch 
	   */

           cptr[0] = (char)opc_priv; cptr[1] = (char)get_current_class;
           cptr[2] = (char)opc_monitorenter; 
           cptr[3] = (char)opc_jsr; cptr[4] = 0x00; cptr[5] = 0x09;
           cptr[6] = (char)opc_priv; cptr[7] = (char)get_current_class;
           cptr[8] = (char)opc_monitorexit; 
           cptr[9] = xreturnReplace(cptr, SYNC_PROLOGUE_SIZE, 
                                    from[mindex].code_length);
	   cptr[10] = opc_nop;
	   cptr[11] = opc_nop;
         }
         else 
         {
	   /* Add the following code sequence:
              0: aload 0; 
              2: monitorenter; 
              3: jsr +6; 
              6: aload 0; 
              8: monitorexit;
              9: xreturn;
	     10: nop;   padding to avoid problems w/ tableswitch/lookupswitch 
	     11: nop;   padding to avoid problems w/ tableswitch/lookupswitch 
	   */

           cptr[0] = opc_aload; cptr[1] = 0x00;
           cptr[2] = (char)opc_monitorenter; 
           cptr[3] = (char)opc_jsr; cptr[4] = 0x00; cptr[5] = 0x09;
           cptr[6] = opc_aload; cptr[7] = 0x00;
           cptr[8] = (char)opc_monitorexit; 
           cptr[9] = xreturnReplace(cptr, SYNC_PROLOGUE_SIZE, 
                                    from[mindex].code_length);
	   cptr[10] = opc_nop;
	   cptr[11] = opc_nop;
         }
       }
       else {
          memcpy((char *)cptr, (char *)from[mindex].code, 
                 (int)from[mindex].code_length);
       }
    }
    else {
          memcpy((char *)cptr, (char *)from[mindex].code, 
                 (int)from[mindex].code_length);
    }

    if (SYNC_METHODS) {
       if (from[mindex].fb.access & ACC_SYNCHRONIZED)
          absmoptr->codeLength = from[mindex].code_length + SYNC_PROLOGUE_SIZE;
       else
          absmoptr->codeLength = from[mindex].code_length;
    }
    else {
       absmoptr->codeLength = from[mindex].code_length;
    }

    /* create an exception array, MVB = MVB of current object */
    entries = from[mindex].exception_table_length;
    absmoptr->exceptionTableLength = entries;
    if (entries) {
     CREATE_JAVA_ARRAY((sizeof(int)*(ARRAY_HEADER+entries+ARRAY_FOOTER)), 
     eaptr, exceptionArray, SIZEP_OF_OBJREF, entries, 
     (int)classptr_exceptionBlk, mvb_object)
     absmoptr->exception = eaptr;	/* set exception pointer */

     /* create exception blocks */
     tmpptr = (int *)cmMalloc((sizeof(decafExceptionBlock)+4)*entries);
     from[mindex].relextbl = (void *)(tmpptr+4); /* MVB of 1st entry */
      for (bindex=0; bindex < entries; bindex++) {
      offset = ((sizeof(decafExceptionBlock)+4) * bindex) / sizeof(int);
      abstmpptr = (int *)getAbsAddr(tmpptr+offset);
      *abstmpptr = 0; /* monitor pointer */
      /* ebptr points to MVB: */
      ebptr = (decafExceptionBlock *)(tmpptr + offset + MONPTR_SIZE); 
      abseaptr->entry[bindex] = ebptr;

      absebptr = (decafExceptionBlock *)getAbsAddr(ebptr);
      absebptr->methodVectorBase = mvb_exceptionBlk;

      if (SYNC_METHODS) { 
	if (from[mindex].fb.access & ACC_SYNCHRONIZED) {
          absebptr->startPc=from[mindex].exception_table[bindex].start_pc +
                            SYNC_PROLOGUE_SIZE;
          absebptr->endPc=from[mindex].exception_table[bindex].end_pc +
                          SYNC_PROLOGUE_SIZE;
          absebptr->handlerPc=from[mindex].exception_table[bindex].handler_pc +
                              SYNC_PROLOGUE_SIZE;
	}
        else {
          absebptr->startPc=from[mindex].exception_table[bindex].start_pc;
          absebptr->endPc=from[mindex].exception_table[bindex].end_pc;
          absebptr->handlerPc=from[mindex].exception_table[bindex].handler_pc;
        }
      }
      else {
         absebptr->startPc=from[mindex].exception_table[bindex].start_pc;
         absebptr->endPc=from[mindex].exception_table[bindex].end_pc;
         absebptr->handlerPc=from[mindex].exception_table[bindex].handler_pc;
      }
      absebptr->catchObject = (decafObject)from[mindex].exception_table[bindex].catchType;
     }
    }
    else
     absmoptr->exception = 0;		/* set exception pointer */
  
    /* method field */
    from[mindex].relfield = (void *)getRelAddr(&absmoptr->methodField);
    copyMethodFields(1, &from[mindex].fb, (decafMethodField *)getRelAddr(&absmoptr->methodField));

    /* argsSize contains the method index from method array in
    ** its first two bytes, and the lower two bytes contain
    ** number of bytes for method arguments.
    */
    absmoptr->argsSize = (from[mindex].fb.u.offset << 16) 
			  | (from[mindex].args_size << 2);
    if (SYNC_METHODS) {
       if (from[mindex].fb.access & ACC_SYNCHRONIZED) {
          absmoptr->maxstack = (from[mindex].maxstack+1) << 2;
       }
       else {
          absmoptr->maxstack = from[mindex].maxstack << 2;
       }
    }
    else {
       absmoptr->maxstack = from[mindex].maxstack << 2;
    }

    absmoptr->nlocals = from[mindex].nlocals << 2;
   }

   if (DEBUG_LOADER) 
   printf("Exiting copyMethods\n");
}



/* 
 * Construct java data structures for a class object 
 */
decafClass_for_classLoader *
copyOneBinClass(ClassClass *cb)
{
   decafClass_for_classLoader *cls, *clsAbs, *abscls;
   char *cptr;
   int *tmpptr, *abstmpptr;
   decafCpItemType *toAbs;
   decafCpItemType *itemPtr;
   cpArray *cAptr, *abscAptr;
   fieldArray *fAptr, *absfAptr;
   methodArray *mAptr, *absmAptr;
   implementsArray *impAptr, *absimpAptr;

   unsigned int *impAbs, *absohAptr;
   int ohbArraySize;	/* Object hint block array size */
   decafObjectHint_for_classLoader *ohptr, *absohptr;
   int i;
   double *dptr;

   if (DEBUG_LOADER) 
   printf("Entering copyOneBinClass\n");

   mainMethod = 0;

   /* The class should be a Java object! */
   CREATE_JAVA_OBJ(sizeof(decafClass_for_classLoader)+sizeof(int)*MONPTR_SIZE, cls, decafClass_for_classLoader, mvb_class)

   if (cls == NULL) return(NULL);
   currentclass = cls;
   cb->relcb = (void *)(cls);

   clsAbs = abscls;


   /* Set up object hint block as a java array.           
      Allocate space for the ObjectHintBlock and the MethodTable that follows.
      The first entry of the method vector must be double word aligned!!! 
      */
   cptr = (char *)cmMalloc(
        4 + /* 1 extra word for ensuring double word alignment */
        ARRAY_HEADER*sizeof(int) + 
	sizeof(decafObjectHint_for_classLoader) + 
        sizeof(decafMethod_for_classLoader *)*(cb->methodtable_size - 1) +
	ARRAY_FOOTER*sizeof(int) ); 

   /* skip ARRAY_HEADER and extra word allocated for double word alignment */
   cptr = (cptr+ARRAY_HEADER*sizeof(int)+4);
   tmpptr = (int *)((int)cptr & 0xfffffff8);
   cptr =   (char *)tmpptr;
   ohptr = (decafObjectHint_for_classLoader *)tmpptr;	

   /* objHintBlk pointer points to MVB field of the object hint block */
   clsAbs->objHintBlk = (decafObjectHint_for_classLoader *)((int)ohptr - 8);

   tmpptr = tmpptr + 6;	/* 6 int fields to the begining of MVB */
   mvb_current = (methodVector *)tmpptr; /* must be DW aligned */
   if ( (int)mvb_current & 0x07 ) { 	
        printf("\n *** ERROR *** Method vector base address is not double word aligned\n");
   }

   /* Initialize object hint block array header*/
   abstmpptr = (int *)((int)ohptr - ARRAY_HEADER*sizeof(int));
   abstmpptr = (int *)getAbsAddr(abstmpptr); 
   *abstmpptr = 0; /* initialize monitor pointer */
   abstmpptr = (int *)((int)abstmpptr + 4); /* MVB address */
   *abstmpptr = ((int) mvb_object & SIZE_OF_ELEMENT_MASK)|SIZEP_OF_INT; 
   absohAptr = (unsigned int *)((int)abstmpptr + 4); /* arraySize word addr */
   	


   /* copy constant pool information */ 
   clsAbs->constpoolCount = cb->constantpool_count;
   CREATE_JAVA_ARRAY((sizeof(int)*(ARRAY_HEADER+clsAbs->constpoolCount+
                     ARRAY_FOOTER)), cAptr, cpArray, SIZEP_OF_INT,
                     clsAbs->constpoolCount, SIGC_INT, mvb_object)
   clsAbs->constpool = cAptr;   
   cb->relcp = (void *)clsAbs->constpool;
   copyConstantPool(clsAbs->constpoolCount, cb->constantpool, 
                    (decafCpItemType*)(cAptr->items));

   /* name */
   toAbs = (decafCpItemType *)getAbsAddr(cAptr->items);
   clsAbs->name = toAbs[cb->nameIndex].dp;

   /* super name */
   /* clsAbs->superName = toAbs[cb->superNameIndex].dp; */
   clsAbs->superClass = binclasses[cb->super]->relcb;



   /* copy fields */ 
   clsAbs->fieldsCount = cb->fields_count;
   CREATE_JAVA_ARRAY((sizeof(int)*(ARRAY_HEADER+clsAbs->fieldsCount+
                     ARRAY_FOOTER)), fAptr, fieldArray, SIZEP_OF_OBJREF,
                     cb->fields_count, (int)classptr_field, mvb_object)
   clsAbs->fields = fAptr;	
   copyFields(clsAbs->fieldsCount, cb->fields, 
              (decafField_for_classLoader **)(fAptr->field));


   /* copy methods */ 
   clsAbs->methodsCount = cb->methods_count;
   CREATE_JAVA_ARRAY((sizeof(int)*(ARRAY_HEADER+clsAbs->methodsCount+
                     ARRAY_FOOTER)), mAptr, methodArray, SIZEP_OF_OBJREF,
                     cb->methods_count, (int)classptr_method, mvb_object)
   clsAbs->methods = mAptr;

   main = clinit = finalizer = 0;

   copyMethods(clsAbs->methodsCount, cb->methods, 
               (decafMethod_for_classLoader **)(mAptr->method));


   /* implements */
   clsAbs->implementsCount = cb->implements_count;
   if (clsAbs->implementsCount > 0) 
   {
      /* Create a class, return values in impAptr and absimpAptr */
      CREATE_JAVA_ARRAY((sizeof(int)*(ARRAY_HEADER+clsAbs->implementsCount+
                        ARRAY_FOOTER)), impAptr, implementsArray,SIZEP_OF_INT, 
                        cb->implements_count, SIGC_INT, mvb_object)
      clsAbs->implements = impAptr; /* arrayref/relative ptr to MVB */
      for (i=0; i < clsAbs->implementsCount; i++) 
      {
          absimpAptr->implement[i] = cb->implements[i];
      }
   }
   else 
   {
    clsAbs->implements = NULL;
   }


   /* copy objectHintBlock */ 
   if (((int)clsAbs->objHintBlk &  3 ) != 0) {
     printf("ERROR : objHintBlk 0%08x must be double word (%d) aligned.\n", (int)clsAbs->objHintBlk, sizeof(double));
   }

   /* ohptr points to the beginning of the decafObjectHint structure */
   ohptr = (decafObjectHint_for_classLoader *)((int)clsAbs->objHintBlk + 8);
   copyObjHintBlk(cb, ohptr);
   absohptr = (decafObjectHint_for_classLoader *)getAbsAddr((char *)ohptr);
   ohbArraySize = absohptr->numOfInstMethods + 6;	
   *absohAptr = ohbArraySize;  /* initialize arraySize word in array header */
   tmpptr = (int*)((int)absohptr + ohbArraySize*SIZEB_OF_INT);
   *tmpptr = 1; /* set dimensions in array footer */
   tmpptr++;
   *tmpptr = SIGC_INT; /* set element type in array footer */
   
   /* New fields added to class data structure F.Y 06/98 */
   clsAbs->access = cb->access;
   clsAbs->flags = (main << MAIN_BIT_POS) | 
                   (clinit << CLINIT_BIT_POS) | 
                   (finalizer << FINALIZE_BIT_POS); 
   clsAbs->loader = (void*) NULL;
   clsAbs->next   = (decafClass_for_classLoader *) NULL;

   cmSetClassTable(cls, mainMethod);



   /* added to finish bootstrapping of class loader    */
   /* obtain MVB of the fundamental classes as we go along */
   if (!bsdone) {
     cptr = (char *)getAbsAddr((char *)clsAbs->name+4);
     if (!strcmp(cptr, OBJECT_CLASS_NAME)) { 
	mvb_object = mvb_current;
        classptr_object = (decafClass*)((int)cls+4);
     }
     if (!strcmp(cptr, CLASS_CLASS_NAME)) { 
	mvb_class = mvb_current;
        classptr_class = (decafClass*)((int)cls+4);
     } 
     if (!strcmp(cptr, FIELD_CLASS_NAME)) {
	mvb_field = mvb_current;
        classptr_field = (decafClass*)((int)cls+4);
     }
     if (!strcmp(cptr, METHOD_CLASS_NAME)) {
	mvb_method = mvb_current;
        classptr_method = (decafClass*)((int)cls+4);
     }
     if (!strcmp(cptr, EXCEPTIONBLOCK_CLASS_NAME)) {
	mvb_exceptionBlk = mvb_current;
        classptr_exceptionBlk = (decafClass*)((int)cls+4);

        /* all the fundamental classes had been loaded, */
        /* fix them up all at the same time             */
        fixupClass(OBJECT_CLASS_NAME);  
        fixupClass(CLASS_CLASS_NAME);  
        fixupClass(FIELD_CLASS_NAME);  
        fixupClass(METHOD_CLASS_NAME);  
        fixupClass(EXCEPTIONBLOCK_CLASS_NAME);
	fixupClasstable(1);    /* Must be the first call */ 
        bsdone = 1;
     }
   }
   else
	fixupClasstable(0);	/* Not the first call */

   if (DEBUG_LOADER) 
   printf("Exiting copyOneBinClass\n");

   return(cls);
}

/*
 * This is to load reset handler and trap handler
 */
copyOneMethod(ClassClass *cb, int i, int loc)
{
    int j;
    char *cptr;
    struct methodblock *from;

    from = cb->methods;

    /* code */
    cptr = (char *)getAbsAddr(loc);

    memcpy((char *)cptr, (char *)from[i].code, (int)from[i].code_length);

    return((int)from[i].code_length);
}


void
copyInitFile(FILE *fp)
{

   unsigned int addr;
   int value;

/* allow any mem location to be init'ed, not 
just scratch area, by calling cmMemoryWrite  */

   while (fscanf(fp, "%x %x", &addr, &value) != EOF) {
    cmMemoryWrite (addr, value, 2);
   }
}

#undef CHECKING_FREAD
#define CHECKING_FREAD(p1, p2, p3, p4) { \
        size_t n_elts = (p3); \
        if (fread ((p1), (p2), n_elts, (p4)) != n_elts) \
	    { fprintf (stderr, "Error reading initialisation file\n"); \
              return; }}

/* loads all sections of a binary init file into the CM. 
fp shd be pointing to the beginning of a section in the .binit file */

void copyBinaryInitFile(FILE *fp)
{
    unsigned int addr, size;
    char *cm_ptr;
    unsigned long srcLen, destLen;
    unsigned char *buf;

    /* read sections till a read on the address fails */
    while (fread (&addr, sizeof (addr), 1, fp) == 1)
    {
        CHECKING_FREAD (&size, sizeof (size), 1, fp)

        if ((addr+size) <= CM_SIZE)
        {
            cm_ptr = getAbsAddr (addr);
            destLen = CM_SIZE - addr;
        }
        else if ((addr >= SCRATCH_START) &&
            ((addr+size) <= (SCRATCH_START+SCRATCH_SIZE)))
        {
            cm_ptr = getScratchAbsAddr (addr);
            destLen = SCRATCH_START + SCRATCH_SIZE - addr;
        }
        else
        {
            fprintf (stderr, "Error in binary initialisation file\n"
                             "a section attempts to initialises data in "
                             "invalid memory space: addr 0x%x, size 0x%x\n",
                             addr, size);
            fprintf (stderr, "Reading of binary initialisation file aborted\n");
            return;
        }
        /* read in the section data */

        CHECKING_FREAD (&srcLen, sizeof (srcLen), 1, fp)
        buf = (unsigned char *) malloc ((size_t) srcLen);
        CHECKING_FREAD (buf, 1, (size_t) srcLen, fp)

        /* a small risk here in that we are not sure here that destLen 
           will not overrun buf - but for a well-formed .binit file this will
           not happen */
        if (uncompress ((unsigned char *) cm_ptr, &destLen, buf, srcLen) 
            != Z_OK)
        {
              fprintf (stderr, "Warning: error uncompressing main memory for "
                               "restart\n");
              return;
        }
        /* destlen shd be equal to size here */
        free (buf);
    }
}

int
fixupClass(char *className) 
{
   decafClass_for_classLoader *cls, *clsAbs;
   decafCpItemType *toAbs;
   decafCpItemType *itemPtr;
   cpArray *cAptr, *abscAptr;
   tarArray *tarptr, *abstarptr;
   fieldArray *fAptr, *absfAptr;
   decafField_for_classLoader *fptr, *absfptr;
   methodArray *mAptr, *absmAptr;
   decafMethod_for_classLoader *mptr, *absmptr;
   exceptionArray *eAptr, *abseAptr;
   implementsArray *iAptr, *absiAptr;
   decafExceptionBlock *ebptr, *absebptr;
   decafObjectHint_for_classLoader *ohptr, *absohptr;
   int i, j, *iptr;

   cls = cmFindClass(className);
   if (cls) {

     /* class found, perform fix up */
     clsAbs = (decafClass_for_classLoader *)getAbsAddr(cls);
    
     /* fix MVB of object of class Class */
     clsAbs->methodVectorBase = mvb_class;

     /* fix MVB of cp array */
      cAptr = clsAbs -> constpool ; 
      abscAptr = (cpArray *)getAbsAddr(cAptr); 
      abscAptr -> methodVectorBase =  
        (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)| 
        SIZEP_OF_INT);

     /* fix MVB of type and resolution array */
     tarptr = (tarArray *) (abscAptr->items[0].i - 2*SIZEB_OF_INT);
     abstarptr = (tarArray *)getAbsAddr(tarptr); 
     abstarptr -> methodVectorBase = 
       (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)|SIZEP_OF_BYTE);


     /* fix fields array */
     if (clsAbs->fieldsCount) {
        fAptr = clsAbs -> fields ; 
        absfAptr = (fieldArray *)getAbsAddr(fAptr);
        absfAptr -> methodVectorBase = 
        (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)| 
        SIZEP_OF_OBJREF);
        iptr = (int*) ((int)absfAptr + SIZEB_OF_INT*(absfAptr->arraySize+2));
        *iptr = 1;
        iptr++;
        *iptr = (int) classptr_field;
       /* fix MVBs of field objects */
       for (i=0; i < clsAbs->fieldsCount; i++) 
       { 
	 fptr = absfAptr->field[i];
	 absfptr = (decafField_for_classLoader *)getAbsAddr(fptr);
	 absfptr->methodVectorBase = mvb_field;
       }
     }


     if (clsAbs->methodsCount) 
     {
      /* fix methods array */
      mAptr = clsAbs -> methods ; 
      absmAptr = (methodArray *)getAbsAddr(mAptr);
      absmAptr -> methodVectorBase = 
      (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)| 
      SIZEP_OF_OBJREF);
      iptr = (int*) ((int)absmAptr + SIZEB_OF_INT*(absmAptr->arraySize+2));
      *iptr = 1;
      iptr++;
      *iptr = (int) classptr_method;

       /* fix MVBs of method objects */
       for (i=0; i < clsAbs->methodsCount; i++) 
       {
         mptr = absmAptr -> method [ i ] ;
         absmptr = (decafMethod_for_classLoader *)getAbsAddr(mptr);
         absmptr -> methodVectorBase = mvb_method ;
         if (absmptr->exceptionTableLength) 
         {
             /* fix exception array */
            eAptr = absmptr -> exception ; 
            abseAptr = (exceptionArray *)getAbsAddr(eAptr);
            abseAptr -> methodVectorBase = 
            (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)| 
            SIZEP_OF_OBJREF);
            iptr = (int*) ((int)abseAptr+SIZEB_OF_INT*(abseAptr->arraySize+2));
            *iptr = 1;
            iptr++;
            *iptr = (int) classptr_exceptionBlk;
            /* Fix MVBs of exception objects */

           for (j=0; j < absmptr->exceptionTableLength; j++) 
           {
              ebptr = abseAptr -> entry [ j ] ; 
              absebptr = (decafExceptionBlock *)getAbsAddr(ebptr);
              absebptr -> methodVectorBase = mvb_exceptionBlk ;
            }

	 }
       }
     }

      /* fix MVB & field array of object hint block */
     iptr = (int*) getAbsAddr(clsAbs->objHintBlk);
     *iptr = ((int) mvb_object & SIZE_OF_ELEMENT_MASK)|SIZEP_OF_INT;
     ohptr = (decafObjectHint_for_classLoader *)((int)clsAbs->objHintBlk + 8);
     absohptr = (decafObjectHint_for_classLoader *)getAbsAddr(ohptr);
     if (absohptr->objectSize > 0) {
       fAptr = absohptr -> instVars ; 
       absfAptr = (fieldArray *)getAbsAddr(fAptr);
       absfAptr -> methodVectorBase = 
       (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)| 
       SIZEP_OF_OBJREF);
       iptr = (int*) ((int)absfAptr + SIZEB_OF_INT*(absfAptr->arraySize+2));
       *iptr = 1;
       iptr++;
       *iptr = (int) classptr_field;
     }

     /* fix MVB of implements array */ 
     if (clsAbs->implementsCount) {
        iAptr = clsAbs -> implements; 
        absiAptr = (implementsArray *)getAbsAddr(iAptr);
        absiAptr -> methodVectorBase = 
        (methodVector*)(((int)mvb_object & SIZE_OF_ELEMENT_MASK)| 
        SIZEP_OF_INT);
     }
     return 0;
   }
   else
     return 1;
}


/*
 Fix up class table & hashtable as a java array.  See Java array format
 in decaf.h.
*/
int fixupClasstable(int first_time)
{
	cpArray *classtableArray, *absClasstableArray;
        cpArray *classHashArray, *absClassHashArray;
	int *tmpptr, *abstmpptr;
	decafClass_for_classLoader *cls, *clsAbs;
	fieldArray  *fldArray, *absfldArray;
	decafField_for_classLoader *field, *absfield;
	char * name;
	int arraySize, i;
        
        if (DEBUG_LOADER) 
	printf("Entering fixupClasstable\n"); 

	tmpptr = (int *)((int)decafClass_for_classLoaderTable - 12);
	abstmpptr = (int *)getAbsAddr(tmpptr);
	*abstmpptr = 0;	/* set monitor field to NULL */

	classtableArray = (cpArray* )(tmpptr + MONPTR_SIZE);
	absClasstableArray = (cpArray* )getAbsAddr(classtableArray);

	tmpptr = (int *)((int)decafClassHashTable - 12);
	abstmpptr = (int *)getAbsAddr(tmpptr);
	*abstmpptr = 0;		/* set monitor field to NULL */
        
	classHashArray = (cpArray* )(tmpptr + MONPTR_SIZE);
	absClassHashArray = (cpArray* )getAbsAddr(classHashArray);

        /* Set the size of the class table array & hashtable - F. Y 09/98 */
        /* decafClassTableSize & decafClassHashTblSize are in bytes, reserve 
           2 words for dimension & type of the java arrays. */
	absClasstableArray->arraySize = (decafClassTableSize/4-ARRAY_FOOTER);

	absClassHashArray->arraySize = (decafClassHashTblSize/4-ARRAY_FOOTER);

	/* Fix up special fields in class Class to hold address and count
	** of the class table array
	*/
	cls = cmFindClass(CLASS_CLASS_NAME);
	if (cls == (decafClass_for_classLoader *)0) {
		printf("\n Error: failed in fixupClasstable()\n");
		return 0;
	}	

	/* class found, perform fix up */
	clsAbs = (decafClass_for_classLoader *)getAbsAddr(cls);
	fldArray = clsAbs->fields;
	if (fldArray == (fieldArray  *)0) {
		printf("\n Error: failed in fixupClasstable()\n");
		return 0;
	}	
	absfldArray = (fieldArray  *)getAbsAddr(fldArray);
	if (first_time) {
	  absClasstableArray->methodVectorBase = absfldArray->methodVectorBase;
	  absClassHashArray->methodVectorBase = absfldArray->methodVectorBase;

          /* Set 2 array footer words in class tables */
          tmpptr = (int *)((int)decafClass_for_classLoaderTable + 
                           (decafClassTableSize/SIZEB_OF_OBJREF - 1)*
                           SIZEB_OF_OBJREF);
	  abstmpptr = (int *)getAbsAddr(tmpptr);
          /* Set C pointer to class java/lang/Class: */
	  *abstmpptr = (int) ((int)cls & 0x3FFFFFFC) + 4;
 
          tmpptr = (int *)((int)decafClassHashTable + 
                           (decafClassHashTblSize/SIZEB_OF_OBJREF - 1)*
                           SIZEB_OF_OBJREF);
	  abstmpptr = (int *)getAbsAddr(tmpptr);
          /* Set C pointer to class java/lang/Class: */
	  *abstmpptr = (int) ((int)cls & 0x3FFFFFFC) + 4; 

          /* Set 2nd last entry in tables to dimension */
          tmpptr = (int *)((int)decafClass_for_classLoaderTable + 
                           (decafClassTableSize/SIZEB_OF_OBJREF - 2)*
                            SIZEB_OF_OBJREF);
	  abstmpptr = (int *)getAbsAddr(tmpptr);
          /* Set dimension to 1 */
	  *abstmpptr = 1;
 
          tmpptr = (int *)((int)decafClassHashTable + 
                           (decafClassHashTblSize/SIZEB_OF_OBJREF - 2)*
                            SIZEB_OF_OBJREF);
	  abstmpptr = (int *)getAbsAddr(tmpptr);
          /* Set dimension to 1 */
	  *abstmpptr = 1;
        }

	arraySize = absfldArray->arraySize;
	for (i=0; i<arraySize; i++)
	{
                decafString* dstr;
		field = absfldArray->field[i];	/* Field object */
		absfield = (decafField_for_classLoader *)getAbsAddr(field);
                dstr = (decafString*)getAbsAddr(absfield->name);
		name = (char *)&(dstr->cp);
		if (first_time) {
		  if (strcmp(name, "classTable") == 0){
		        /* Set bit 1 for arrayref */
			absfield->object = (decafObject)
                           ((int)classtableArray|0x00000002);
		  }
		  if (strcmp(name, "classHashTable") == 0){
		        /* Set bit 1 for arrayref  */
			absfield->object = (decafObject)
                           ((int)classHashArray|0x00000002);
		  }
		}
		else if (strcmp(name, "classCount") == 0) {
			absfield->object = (decafObject)decafClassTableCount;
                }
	}

        if (DEBUG_LOADER) 
	printf("Exiting fixupClasstable\n");

	return (0);
}





