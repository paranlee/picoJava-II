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




static char *sccsid = "@(#)cm.c 1.33 Last modified 02/26/99 18:36:31 SMI";

#include <stdio.h>
#include <setjmp.h>
#include "dsv.h"
#include "decaf.h"
#include "oobj.h"
#include "tree.h"
#include "zlib.h"
#include "loader.h"
#include "traptypes.h"
#include "syscall.h"
#include "cm.h"

/*
#define CM_DBG
*/

char *commonMemory = NULL;
char *scratchMemory = NULL;
proc_type_t proc_type;

/*
** Initial values for Class table and trap table.
*/
int	decafClassTableCount;	/* # of elements in the decaf class table */
char **decafTrapTable = (char **)TRAP_ADDRESS;
decafClass_for_classLoader **decafClass_for_classLoaderTable = (decafClass_for_classLoader **)CLASS_ADDRESS;
decafClass_for_classLoader **decafClassHashTable = (decafClass_for_classLoader **)CLASS_HASHTABLE_ADDR;

/* This initialization is for outside use */
decafClass **decafClassTable = (decafClass **)CLASS_ADDRESS;

char *minStartingAddress;
char *startingAddress;
char *currentAddress;

unsigned int CM_SIZE = 0x1000000; /* default CM_SIZE = 16M */

/* this in the input buffer from console */
#define MAX_INPUT_BUFFER 128
char inputBuffer[MAX_INPUT_BUFFER] = "";
int  iBufferReadIndex = 0;

/* this function sets the processor type */
set_proc_type ()

{
    char *s;

    /* default proc_type = picoJava-II */
    proc_type = pico2dot1;

    if (((s = (char *) getenv ("PROC_TYPE")) != NULL) &&
        !strcasecmp (s, "pico"))
    {
        printf ("Environment variable PROC_TYPE set to %s, running in picoJava-I mode\n", s);
        proc_type = pico;    
    }
    else if (((s = (char *) getenv ("PROC_TYPE")) != NULL) &&
        !strcasecmp (s, "maya"))
    {
        printf ("Environment variable PROC_TYPE set to %s, running in picoJava-II.0 mode\n", s);
        proc_type = maya;    
    }
}

/*
 * if addr is null, use default value
 * We also need to fill in the trap table, its handlers, class table, and
 * run-time support classes
 *  1. decaf class
 *  2. exception class
 */
cmInit (char *addr)
{
   int cm_dbg;
   char *cptr;
   int *iptr;
   int i, j;
   char *s;

   if (commonMemory != NULL) {
    return(DSV_SUCCESS);
   }

   /* first find out what is the processor type */
   set_proc_type ();

   if ((s = (char *)getenv("PICOJAVA_MEMORY_SIZE")) != NULL) 
   {
       unsigned int mb = (unsigned int) strtoul (s, (char **) NULL, 0);
       if (mb != 0)
       {
           printf ("PICOJAVA_MEMORY_SIZE set to %d MB\n", mb);
           CM_SIZE = mb * 0x100000;
       }
       else
       {
           printf ("Warning: Environment variable PICOJAVA_MEMORY_SIZE set to "
                   "an invalid value: %s\nReverting to default memory size\n",
                    s);
       }
   }

   commonMemory = (char *) malloc(CM_SIZE);
   if (commonMemory == NULL) {
    printf("Fatal Error : Out of memory\n");
    return(DSV_FAIL);
   }

   /* initialize memory */
   iptr = (int *)commonMemory;
   j = CM_SIZE / 4;
   for (i=0; i < j; i++) { 
    *iptr++ = 0xdeadbeef;
   }

   scratchMemory = (char *)malloc(SCRATCH_SIZE);
   if (scratchMemory == NULL) {
    printf("Fatal Error : Out of memory\n");
    return(DSV_FAIL);
   }
   /* initialize memory */
   iptr = (int *)scratchMemory;
   j = SCRATCH_SIZE / 4;
   for (i=0; i < j; i++) { 
    *iptr++ = 0xdeadbeef;
   }

   iptr = (int *)getAbsAddr(FLUSH_LOCATION);
   *iptr = 0;
   iptr = (int *)getAbsAddr(TRAP_USE_LOCATION);
   *iptr = 0;
   iptr = (int *)getAbsAddr(WATERMARK_LOCATION);
   *iptr = 0;

   memset((void *)getScratchAbsAddr(BAD_MEMORY_START), 0xff, BAD_SIZE);
   memset((void *)getScratchAbsAddr(BAD_IO_START), 0xff, BAD_SIZE);

   memset((void *)getAbsAddr(TRAP_ADDRESS), 0, NUM_OF_TRAPS*2*4);

/*
   printf("bad memory start BAD_MEMORY_START, abs %xh\n", getScratchAbsAddr(BAD_MEMORY_START));
*/

   cptr = (char *)getenv("DSV_DBG");
   if ((cptr != NULL) && (strcasecmp(cptr, "CM_DBG")==0)) {
    cm_dbg = 1;
   }
   else {
    cm_dbg = 0;
   }

   if (cm_dbg) {
    printf("common memory at %xh, abs %xh\n", getRelAddr(commonMemory), commonMemory);
    printf("trap table at %xh, abs %xh, size %xh bytes\n", decafTrapTable, getAbsAddr(decafTrapTable), decafTrapTableSize*sizeof(char *));
   }

   /* initialize the trap table */
   memset((void *)getAbsAddr(decafTrapTable), 0, decafTrapTableSize);

   /* initialize the class table */
   memset((void *)getAbsAddr(decafClass_for_classLoaderTable), 0, decafClassTableSize);

   /* initialize the class hashtable */
   
   memset((void *)getAbsAddr(decafClassHashTable), 0, decafClassHashTblSize); 

   if (cm_dbg) {
    printf("class table at %xh, abs %xh, size %xh bytes \n", decafClass_for_classLoaderTable, getAbsAddr(decafClass_for_classLoaderTable), decafClassTableSize*sizeof(void*));

    printf("class hash table at %xh, abs %xh, size %xh bytes \n", decafClassHashTable, getAbsAddr(decafClassHashTable), decafClassHashTblSize*sizeof(void*));
   }

   minStartingAddress = (char *)decafClassHashTable + decafClassHashTblSize*sizeof(decafClass_for_classLoader*);

   if (addr == NULL) {
    addr = minStartingAddress;
   }

   if (addr < minStartingAddress) {
    printf("Fatal Error : starting address much greater than %xh\n", minStartingAddress);
    return(DSV_FAIL);
   }

   startingAddress = addr;
   currentAddress = startingAddress;
   
   if (cm_dbg) {
    printf("class loading at %xh, abs %xh\n", currentAddress, getAbsAddr(currentAddress));
   }

/*
   printf("Class hashtable address = 0x%x\n", CLASS_HASHTABLE_ADDR);
*/
   sleep(3);
   init_syscall_library ();

   return(DSV_SUCCESS);
}

/*
 * return the current Address
 */
char *cmCalloc(int n, int size)
{
   char *cptr;

   cptr = currentAddress;
   currentAddress += n * size;

   if (CM_SIZE < (int)currentAddress) {
    return(NULL);
   }

   /* printf("@@ cm alloated address %08x, length %x\n", cptr, n*size); */

   return(cptr);
}

/*
 * return from the current Address
 */
char *cmMalloc(int size)
{
   char *cptr;

   /* always align to 4 byte boundary */
   size = (size + 3) & 0xfffffffc;

   cptr = currentAddress;
   currentAddress += size;

   if (CM_SIZE < (int)currentAddress) {
    return(NULL);
   }

   /* printf("@@ cm alloated address %08x, length %x\n", cptr, size); */

   return(cptr);
}

cmDump(FILE *fp)
{
   fprintf(fp,"Trap table :\n");
   fprintf(fp,"\tsize : %d\n", decafTrapTableSize);

   fprintf(fp,"Class table :\n");
   fprintf(fp,"\tsize : %d\n", decafClassTableSize);
}

void cmRewind()
{
   currentAddress = startingAddress;

   return;
}


/*
 * Enter class address in object class table.
 * DSV sets it so we need abs address 
 */
void cmSetClassTable(decafClass_for_classLoader *classPtr, int mainMethod)
{
   decafClass_for_classLoader **table;
   decafClass_for_classLoader **hashTable;
   decafClass_for_classLoader *temp, *absClsPtr;
   static int i=0;
   int index;
   decafString* name;

   if (DEBUG_LOADER) 
   printf("Entering cmSetClassTable\n"); 

   table = (decafClass_for_classLoader **)getAbsAddr(decafClass_for_classLoaderTable);

   absClsPtr = (decafClass_for_classLoader *)getAbsAddr(classPtr);
   hashTable = (decafClass_for_classLoader **)getAbsAddr(decafClassHashTable);
   name = (decafString*) getAbsAddr(absClsPtr->name);
   index = name->key % (decafClassHashTblSize/4 - ARRAY_FOOTER);
   
   /*printf("%s, name->key = 0x%x, index = 0x%x\n", &(name->cp), name->key, index);*/

   /*
   ** classPtr points to the MVB field of the class object - FY  
   */

   if (hashTable[index] == NULL) {
      hashTable[index] = classPtr;
   }
   else {
      temp = hashTable[index];
      absClsPtr->next = temp;
      hashTable[index] = classPtr;
   }


    table[i] = classPtr;
    i++;
    decafClassTableCount = i;

   if (DEBUG_LOADER) 
   printf("Exiting cmSetClassTable\n"); 
   return;
}


/*
 * Extract i'th class address from object class table.
 * DSV sets it so we need abs address 
 */
decafClass_for_classLoader * cmGetClassTable(int idx)
{
   decafClass_for_classLoader **table;
   decafClass_for_classLoader * decafClass_ptr;

   table = (decafClass_for_classLoader **)getAbsAddr(decafClass_for_classLoaderTable);
   if (table[idx] != NULL) 
   {

      /* No need for pointer adjustment if C-struct does not contain monitor */
      /* Simply return a reference to a class object. */
      decafClass_ptr = (decafClass_for_classLoader *)(table[idx]);
   }
   else
	decafClass_ptr = (decafClass_for_classLoader *) NULL;
   return (decafClass_ptr);
}


/*
 * cp is relative
 */
decafClass_for_classLoader *
findClassFromConstantPool(int cp)
{
   int i;
   decafClass_for_classLoader *clsptr;

   if (cp == 0) {
    return(NULL);
   }

   i = 0;
   while ((clsptr = cmGetClassTable(i)) != NULL) 
   {
      clsptr = (decafClass_for_classLoader *)getAbsAddr(clsptr);
      if ( (int) clsptr->constpool + 8 == cp) {
         return(clsptr);
      }
      i++;
   }

   return(NULL);
}

/*
 * cp is relative
 */
findConstanPoolCount(int cp)
{
   decafClass_for_classLoader *clsptr;

   clsptr = findClassFromConstantPool(cp);
   if (clsptr == NULL) {
      return -1;
   }
   return clsptr->constpoolCount;
}

#define BIT_6 0x40
void dumpRelConstantPool(unsigned int cnt, cpArray *cp, FILE *fp)
{
   int i, res, array;
   unsigned char *type_table;
   short *sptr;
   long *lptr;
   double *dptr;
   unsigned int *key;
   cpArray *abscp;
   tarArray *tarptr, *abstarptr;
   int *intptr;
   decafCpItemType *item, *absitem;

   fprintf(fp,"Constant Pool Table (Arrayref = 0x%x):\n", cp);
   abscp = (cpArray *)getAbsAddr(cp);

   intptr = (int *)abscp - MONPTR_SIZE;
   fprintf(fp,"   Monitor = 0x%x\n", *intptr);
   fprintf(fp,"   Method Vector Base = 0x%x\n", (int)abscp->methodVectorBase &
           SIZE_OF_ELEMENT_MASK);
   fprintf(fp,"   Array Size: %d\n", abscp->arraySize);
   fprintf(fp,"   ElementSize: %d\n", (int)abscp->methodVectorBase & 
           ~(SIZE_OF_ELEMENT_MASK));

   item = cp->items;
   absitem = (decafCpItemType *)getAbsAddr(item);

   tarptr = (tarArray *)(absitem[CONSTANT_POOL_TYPE_TABLE_INDEX].p);
      /*
      ** Based on new design, if item is a aray object,
      ** Constant pool entry must point to first element of
      ** the class object (as opposed to MVB address)
      ** That is using MVB+8 for array objects.
      */
   tarptr = (tarArray *)((int)tarptr - 8); /* Adjust for pointer to item */

   /* dump type and resolution array header */
   fprintf(fp,"   CP[0] = Type & Resolution Arrayref: 0x%x\n", tarptr);
   abstarptr = (tarArray *)getAbsAddr(tarptr);
   intptr = (int *)abstarptr - MONPTR_SIZE;
   fprintf(fp,"      Monitor = %xh\n", *intptr);
   fprintf(fp,"      Method Vector Base = 0x%x\n", 
           (int)abstarptr->methodVectorBase & SIZE_OF_ELEMENT_MASK);
   fprintf(fp,"      Array Size: %d\n", abstarptr->arraySize);
   fprintf(fp,"      Element Size: %d\n", (int) abstarptr->methodVectorBase & 
           ~(SIZE_OF_ELEMENT_MASK));

   type_table = abstarptr->type; 
   for (i=CONSTANT_POOL_UNUSED_INDEX; i < cnt; i++) {
    /* Bit 7 is for resolution */
    res = (int)((CONSTANT_POOL_TYPE_TABLE_GET(type_table,i) & 
                CONSTANT_POOL_ENTRY_RESOLVED)>>7);
    /* Bit 6 is for array classes */
    array = (int)(CONSTANT_POOL_TYPE_TABLE_GET(type_table,i) & BIT_6);
    
    if (!array) {
      switch (CONSTANT_POOL_TYPE_TABLE_GET_TYPE(type_table,i)) {
      case CONSTANT_Utf8:
        key = (unsigned int *)getAbsAddr(absitem[i].dp);
        fprintf(fp,"   CP[%d] = Type: Utf8*, Res: %d, Addr: %xh, Key: %xh, Value: %s\n", i, res, absitem[i].dp, *key, (char *)getAbsAddr((char *)absitem[i].dp+4));
        break;
      case CONSTANT_Class:
        if(res == 0) 
          fprintf(fp,"   CP[%d] = Type: Class, Res: %d, Name_Index: %d\n", 
                  i, res, absitem[i].i);
        else
          fprintf(fp,"   CP[%d] = Type: Class, Res: %d, Addr: 0x%x\n", i, 
                  res, absitem[i].p);        
        break;
      case CONSTANT_String:
        if(res == 0)
          fprintf(fp,"   CP[%d] = Type: String, Res: %d, String_Index: %d\n", i,
                  res, absitem[i].i);
        else {
          key = (unsigned int *)getAbsAddr(absitem[i].dp);
          fprintf(fp,"   CP[%d] = Type: String, Res: %d, Addr: %xh, Key: %xh, Value: %s\n", i, res, absitem[i].dp, *key, (char *)getAbsAddr((char *)absitem[i].dp+4));
        }
        break;
      case CONSTANT_Fieldref:
        if(res == 0) {
          sptr = (short *)(&absitem[i]);
          fprintf(fp,"   CP[%d] = Fieldref, Res: %d, Class_Index: %d, NameType_Index: %d\n", i, res, sptr[0], sptr[1]);
        }
        else
          fprintf(fp,"   CP[%d] = Fieldref, Res: %d, Addr: 0x%x\n", i, res,
                  absitem[i].p);
        break;
      case CONSTANT_Methodref:
        if(res == 0) {
          sptr = (short *)(&absitem[i]);
          fprintf(fp,"   CP[%d] = Methodref, Res: %d, Class_Index: %d, NameType_Index: %d\n", i, res, sptr[0], sptr[1]);
        }
        else
         fprintf(fp,"   CP[%d] = Methodref, Res: %d, Addr: 0x%x\n", i, res,
                 absitem[i].p);
        break;
      case CONSTANT_InterfaceMethodref:
        if(res == 0) {
          sptr = (short *)(&absitem[i]);
          fprintf(fp,"   CP[%d] = InterfaceMethodref, Res: %d, Class_Index: %d, NameType_Index: %d\n", i, res, sptr[0], sptr[1]);
        }
        else
          fprintf(fp,"   CP[%d] = InterfaceMethodref, Res: %d, Addr: 0x%x\n",
          i, res, absitem[i].p);
        break;
      case CONSTANT_NameAndType:
        sptr = (short *)&(absitem[i]);
        fprintf(fp,"   CP[%d] = NameAndType, Res: %d, Name_Index %d, Type_Index: %d\n", i, res, sptr[0], sptr[1]);
        break;
      case CONSTANT_Integer:
        fprintf(fp,"   CP[%d] = Integer, Res: %d, Value: %d 0x%x\n", i, res, 
                absitem[i].i, absitem[i].i);
        break;
      case CONSTANT_Float:
        fprintf(fp,"   CP[%d] = Float, Res: %d, Value %f\n", 
                i, res, absitem[i].f);
        break;
      case CONSTANT_Long:
        lptr = (long *)&(absitem[i]);
        /* Long is 64 bit */
        fprintf(fp, "   CP[%d] = Long, Res: %d, Value: 0x%8x %8x\n", i, res, 
                lptr[0], lptr[1]);
        i++;
        break;
      case CONSTANT_Double:
        dptr = (double *)&(absitem[i]);
        fprintf(fp,"   CP[%d] = Double, Res: %d, Value: %f\n", i, dptr[0]);
        i++;
        break;
      default:
        fprintf(fp,"   CP[%d] = Illegal constant pool type %d\n", i, 
        type_table[i]);
        break;
      }
    }
    else {
       fprintf(fp,"   CP[%d] = ArrayClass, Res: %d, Class Pointer: 0x%x, Dimensions: %d\n", i, res, absitem[i].i&0x3FFFFFFC, ((absitem[i].i&0xC0000000)>>24)|(type_table[i]&0x3F));        
    }
   }
   fprintf(fp,"\n");

   return;
}


void dumpRelConstantPoolIndex(unsigned int index, decafCpItemType *cp, FILE *fp)
{
   
   int i;
   unsigned char *type_table;
   short *sptr;
   long *lptr;
   double *dptr;
   unsigned int *key;
   int res, array, cpcount;
   decafCpItemType *relcp;

   relcp = cp;
   cp = (decafCpItemType *)getAbsAddr(cp);
   type_table = (unsigned char *)getAbsAddr(cp[CONSTANT_POOL_TYPE_TABLE_INDEX].p); 

   i = index;
   cpcount = (*((int* )getAbsAddr((int)relcp-4)));
   if ( (i <= 0) || (i >= cpcount) ) {
      printf("dumpRelConstantPoolIndex: Illegal Constant Pool Index, %d\n", i);
      return;
   }

   /* Bit 7 is for resolution */
   res = (int)((CONSTANT_POOL_TYPE_TABLE_GET(type_table,i) & 
                CONSTANT_POOL_ENTRY_RESOLVED)>>7);

   /* Bit 6 is for array classes */
   array = (int)(CONSTANT_POOL_TYPE_TABLE_GET(type_table,i) & BIT_6);

   if (!array) {
     switch (CONSTANT_POOL_TYPE_TABLE_GET_TYPE(type_table,i)) {
     case CONSTANT_Utf8:
      key = (unsigned int *)getAbsAddr(cp[i].dp);
      fprintf(fp,"CP[%d] = Type: Utf8*, Res: %d, Addr: %xh, Key: %xh, Value: %s\n", i, res, cp[i].dp, *key, (char *)getAbsAddr((char *)cp[i].dp+4));
      break;
     case CONSTANT_Class:
         if(res == 0) {
             fprintf(fp,"CP[%d] = Type: Class, Res: %d, Name_Index: %d\n", 
                     i, res, cp[i].i);
             dumpRelConstantPoolIndex(cp[i].i, relcp, fp);
         }
         else
             fprintf(fp,"CP[%d] = Type: Class, Res: %d, Addr: 0x%x\n", i, res,
                     cp[i].p);        
      break;
     case CONSTANT_String:
         if(res == 0) {
            fprintf(fp,"CP[%d] = Type: String, Res: %d, String_Index: %d\n", i,
                    res, cp[i].i);
            dumpRelConstantPoolIndex(cp[i].i, relcp, fp);
         }
         else {
            key = (unsigned int *)getAbsAddr(cp[i].dp);
            fprintf(fp,"CP[%d] = Type: String, Res: %d, Addr: %xh, Key: %xh, Value: %s\n", i, res, cp[i].dp, *key, (char *)getAbsAddr((char *)cp[i].dp+4));
	 }
         break;
     case CONSTANT_Fieldref:
         if(res == 0) {
            sptr = (short *)(&cp[i]);
            fprintf(fp,"CP[%d] = Fieldref, Res: %d, Class_Index: %d, NameType_Index: %d\n", i, res, sptr[0], sptr[1]);
            dumpRelConstantPoolIndex(sptr[0], relcp, fp);
            dumpRelConstantPoolIndex(sptr[1], relcp, fp);
	 }
         else
            fprintf(fp,"CP[%d] = Fieldref, Res: %d, Addr: 0x%x\n", i, res,
                    cp[i].p);
      break;
     case CONSTANT_Methodref:
         if(res == 0) {
            sptr = (short *)(&cp[i]);
            fprintf(fp,"CP[%d] = Methodref, Res: %d, Class_Index: %d, NameType_Index: %d\n", i, res, sptr[0], sptr[1]);
            dumpRelConstantPoolIndex(sptr[0], relcp, fp);
            dumpRelConstantPoolIndex(sptr[1], relcp, fp);
	 }
         else
            fprintf(fp,"CP[%d] = Methodref, Res: %d, Addr: 0x%x\n", i, res,
                    cp[i].p);
         break;
     case CONSTANT_InterfaceMethodref:
         if(res == 0) {
            sptr = (short *)(&cp[i]);
            fprintf(fp,"CP[%d] = InterfaceMethodref, Res: %d, Class_Index: %d, NameType_Index: %d\n", i, res, sptr[0], sptr[1]);
            dumpRelConstantPoolIndex(sptr[0], relcp, fp);
            dumpRelConstantPoolIndex(sptr[1], relcp, fp);
	 }
         else
            fprintf(fp,"CP[%d] = InterfaceMethodref, Res: %d, Addr: 0x%x\n", 
                    i, res, cp[i].p);
         break;
     case CONSTANT_NameAndType:
         sptr = (short *)&(cp[i]);
         fprintf(fp,"CP[%d] = NameAndType, Res: %d, Name_Index %d, Type_Index: %d\n", i, res, sptr[0], sptr[1]);
         dumpRelConstantPoolIndex(sptr[0], relcp, fp);
         dumpRelConstantPoolIndex(sptr[1], relcp, fp);
         break;
     case CONSTANT_Integer:
         fprintf(fp,"CP[%d] = Integer, Res: %d, Value: %d 0x%x\n", i, res, 
                 cp[i].i, cp[i].i);
         break;
     case CONSTANT_Float:
         fprintf(fp,"CP[%d] = Float, Res: %d, Value %f\n", i, res, cp[i].f);
         break;
     case CONSTANT_Long:
         lptr = (long *)&(cp[i]);
         /* Long is 64 bit */
         fprintf(fp, "CP[%d] = Long, Res: %d, Value: 0x%8x %8x\n", i, res, 
                 lptr[0], lptr[1]);
         i++;
         break;
     case CONSTANT_Double:
         dptr = (double *)&(cp[i]);
         fprintf(fp,"CP[%d] = Double, Res: %d, Value: %f\n", i, dptr[0]);
         i++;
         break;
     default:
         fprintf(fp,"CP[%d] = Illegal constant pool type %d\n", i, 
                 type_table[i]);
         break;
     }
   }
   else {
     fprintf(fp,"   CP[%d] = ArrayClass, Res: %d, Class Pointer: 0x%x, Dimensions: %d\n", i, res, cp[i].i&0x3FFFFFFC, ((cp[i].i&0xC0000000)>>24)|(type_table[i]&0x3F));        
   }
   return;
}



void
dumpRelField(int cnt, fieldArray *faptr, FILE *fp)
{
   int i;
   unsigned int *key;
   int *intptr;
   fieldArray *absfaptr;
   decafField_for_classLoader **field, *absfield;

   fprintf(fp,"Field Count: %d\n", cnt);
   fprintf(fp, "Fields (Arrayref = 0x%x)\n", faptr);
   absfaptr = (fieldArray *)getAbsAddr(faptr);

   intptr = (int *)absfaptr - MONPTR_SIZE;
   fprintf(fp,"   Monitor = 0x%x\n", *intptr);
   fprintf(fp,"   Method Vector Base = 0x%x\n", 
           (int) absfaptr->methodVectorBase & SIZE_OF_ELEMENT_MASK);
   fprintf(fp,"   Array Size: %d\n", absfaptr->arraySize);
   fprintf(fp,"   Element Size: %d\n", (int) absfaptr->methodVectorBase &
           ~(SIZE_OF_ELEMENT_MASK)); 
   
   field = absfaptr->field;

   for (i=0; i < cnt; i++) {
    absfield = (decafField_for_classLoader *)getAbsAddr(field[i]);

    fprintf(fp,"\tMethod Vector Base = 0x%x\n", absfield->methodVectorBase);
    fprintf(fp,"\tField class = 0x%x\n", absfield->class);

    key = (unsigned int *)getAbsAddr(absfield->name);
    fprintf(fp,"\tField name = Address: 0x%x, Key: 0x%x, Value: %s\n", 
    absfield->name, *key, getAbsAddr((char *)absfield->name+4));

    key = (unsigned int *)getAbsAddr(absfield->signature);
    fprintf(fp,"\tField signature = Address: 0x%x, Key: 0x%x, Value: %s\n", 
    absfield->signature, *key, getAbsAddr((char *)absfield->signature+4));
    if (absfield->access & ACC_STATIC) {
     fprintf(fp,"\tField access =  0x%x (static)\n", absfield->access);
    }
    else {
     fprintf(fp,"\tField access =  0x%x (instance)\n", absfield->access);
    }
    fprintf(fp,"\tField object = 0x%lx\n", absfield->object);
    fprintf(fp,"\n");
   }

   return;
}

void
dumpRelMethod(int cnt, methodArray *maptr, FILE *fp)
{
   int i;
   int *intptr;
   methodArray *absmaptr;
   decafMethod_for_classLoader **method, *absmethod;

   fprintf(fp,"Method Count: %d\n", cnt);
   fprintf(fp,"Methods (Arrayref = 0x%x)\n", maptr);
   absmaptr = (methodArray *)getAbsAddr(maptr);

   intptr = (int *)absmaptr - MONPTR_SIZE;
   fprintf(fp,"   Monitor = 0x%x\n", *intptr);
   fprintf(fp,"   Method Vector Base = 0x%x\n", 
           (int) absmaptr->methodVectorBase & SIZE_OF_ELEMENT_MASK);
   fprintf(fp,"   Array Size: %d\n", absmaptr->arraySize);
   fprintf(fp,"   Element Size: %d\n", (int) absmaptr->methodVectorBase &
           ~(SIZE_OF_ELEMENT_MASK));

   method = absmaptr->method;

   for (i=0; i < cnt; i++) {
    dumpOneMethod(method[i], fp);
   }

   return;
}

void
dumpImplements(unsigned int cnt, implementsArray *iaptr, FILE *fp)
{
   implementsArray* absiaptr;
   unsigned int *impAbs;
   int i;
   int* intptr;

   fprintf(fp,"Interface Count: %d\n", cnt);
   if (cnt > 0) {
      fprintf(fp, "Interfaces (Arrayref = 0x%x)\n");
      absiaptr = (implementsArray*)getAbsAddr(iaptr);
      intptr = (int *)absiaptr - MONPTR_SIZE;
      fprintf(fp,"   Monitor = 0x%x\n", *intptr);
      fprintf(fp,"   Method Vector Base = 0x%x\n", 
              (int) absiaptr->methodVectorBase & SIZE_OF_ELEMENT_MASK);
      fprintf(fp,"   Array Size: %d\n", absiaptr->arraySize);
      fprintf(fp,"   Element Size: %d\n", (int) absiaptr->methodVectorBase
              & ~(SIZE_OF_ELEMENT_MASK));

    impAbs = (unsigned int *)getAbsAddr(absiaptr->implement);
    for (i=0; i < cnt; i++) {
     fprintf(fp,"   %d : interface cp index = %d\n", i, impAbs[i]);
    }
   }
   fprintf(fp,"\n");
}

void
dumpObjHintBlk(decafObjectHint_for_classLoader *hint, FILE *fp)
{
   int i, j, elemSize;
   int *intptr;
   decafObjectHint_for_classLoader *abshint;
   decafMethod_for_classLoader **mp;
   decafMethod_for_classLoader *mv;
   decafField_for_classLoader **fbp;
   decafField_for_classLoader *fb;
   decafMethodField *mfb;
   unsigned int *key;
   char *classPtr;
   fieldArray *faptr, *absfaptr;
   methodVector *mvptr, *absmvptr;

   fprintf(fp,"Object Hint Block (Arrayref = 0x%x)\n", (int)hint-8);
   abshint = (decafObjectHint_for_classLoader *)getAbsAddr(hint);

   /* Object hint block is an INT array */
   intptr = (int *)((int) abshint - 12);
   fprintf(fp,"   Monitor = 0x%x\n", *intptr);
   intptr = (int *)((int)intptr + 4);
   fprintf(fp,"   Method Vector Base = 0x%x\n",*intptr & SIZE_OF_ELEMENT_MASK);
   elemSize = *intptr & ~(SIZE_OF_ELEMENT_MASK);
   intptr = (int *)((int)intptr + 4);
   fprintf(fp,"   Array Size: %d\n", *intptr);
   fprintf(fp,"   Element Size: %d\n", elemSize);

   fprintf(fp,"   Object size in words (w/ all superclass fields) = %d\n", 
           abshint->objectSize);
   fprintf(fp,"   Number of instance variables (w/ all superclass fields) = %d\n", abshint->numOfInstVars);

   /* dump instance variables */
   if (abshint->objectSize) {
     faptr = (fieldArray *)abshint->instVars;
     absfaptr = (fieldArray *)getAbsAddr(faptr);
     fbp = absfaptr->field;
     fprintf(fp,"\n   Instance Variables: \n");
     for (i=0; i < abshint->objectSize; i++) {
       if (fbp[i] != NULL) {
         fprintf(fp,"\t   Field (Objref = 0x%x)\n", fbp[i]);
         fb = (decafField_for_classLoader *)getAbsAddr(fbp[i]);
         fprintf(fp,"\t   Method Vector Base = 0x%x\n", fb->methodVectorBase);
         fprintf(fp,"\t   Field class = 0x%x\n", fb->class);

         key = (unsigned int *)getAbsAddr(fb->name);
         fprintf(fp,"\t   Field name: Address = 0x%x, Key = 0x%x, Value = %s\n"
                 , fb->name, *key, getAbsAddr((char *)fb->name+4));

         key = (unsigned int *)getAbsAddr(fb->signature);
         fprintf(fp,"\t   Field signature: Address = 0x%x, Key = 0x%x, Value = %s\n", fb->signature, *key, getAbsAddr((char *)fb->signature+4));
         fprintf(fp,"\t   Field access: 0x%x\n", fb->access);
         fprintf(fp,"\t   Field offset = %d\n", fb->object);
       }
       else {
         fprintf(fp,"\t   *** Skipping offset %d\n", i);
       }
       fprintf(fp,"\n");
     }
   }

   fprintf(fp,"   Class pointer = 0x%x\n", abshint->classPtr);
   fprintf(fp,"   Constant pool pointer = 0x%x\n", abshint->constantpool);
   fprintf(fp,"\n");

   /* dump method vector table */
   fprintf(fp,"   Number of instance methods = %d\n", abshint->numOfInstMethods);

   absmvptr = (methodVector*)&(abshint->methods);
   mvptr = (void *)getRelAddr((void *)absmvptr);
   fprintf(fp,"   Method vector table location = 0x%x\n", mvptr);

   fprintf(fp,"   Methods: \n");        
   for (i=0; i < abshint->numOfInstMethods; i++) {
     /* The method vector table contains C ptrs which must be converted
        back to Java references */
    mv = (decafMethod_for_classLoader *)((int)absmvptr->instMethods[i] - 4);

    fprintf(fp,"\tMethod Object (Objref = 0x%x)\n", mv);
    mv = (decafMethod_for_classLoader *)getAbsAddr(mv);
    fprintf(fp,"\tMethod Vector Base = 0x%x\n", mv->methodVectorBase);
    j = 0xffff0000 &  mv->argsSize;
    fprintf(fp,"\tMethod index = %d\n", j >> 16);
    mfb = &(mv->methodField);
    fprintf(fp,"\tMethod Class = 0x%x\n", mfb->class);
    fprintf(fp,"\tConstantpool = 0x%x\n", mfb->constpool);
    key = (unsigned int *)getAbsAddr(mfb->name);
    fprintf(fp,"\tName: Address = 0x%x, Key = 0x%x, Value = %s\n", 
    mfb->name, *key, getAbsAddr((char *)mfb->name+4));
    key = (unsigned int *)getAbsAddr(mfb->signature);
    fprintf(fp,"\tSignature: Address = 0x%x, Key = 0x%x, Value = %s\n", 
    mfb->signature, *key, getAbsAddr((char *)mfb->signature+4));
    fprintf(fp,"\tAccess: 0x%x\n", mfb->access);
    j = 0x0000ffff &  mv->argsSize;
    fprintf(fp,"\tMethod arg size = %d (%d bytes)\n", j >> 2, j);
    fprintf(fp,"\tMax number of local variables = %d (%d bytes)\n", 
            mv->nlocals >> 2, mv->nlocals);
    fprintf(fp,"\tMax stack = %d (%d bytes)\n", mv->maxstack >> 2, 
            mv->maxstack);
    fprintf(fp,"\tCode location = 0x%x\n", mv->code);
    fprintf(fp,"\tCode length = %d bytes\n", mv->codeLength);
    fprintf(fp,"\tException array address = 0x%x\n", mv->exception);
    fprintf(fp,"\tException table length = %d\n", mv->exceptionTableLength);
    fprintf(fp,"\n");
   }

}

/*
 * For dumping common memory,  cls points to true start 
 * of the class structure 
 *
 */
void
dumpClass(decafClass_for_classLoader *cls, FILE *fp)
{
   unsigned int *key;
   decafClass_for_classLoader *super;
   decafObjectHint_for_classLoader *ohptr, *absohptr;
   int* intptr;

   fprintf(fp,"Class (Objref =  0x%x)\n", cls);
   cls = (decafClass_for_classLoader *)getAbsAddr(cls);
   intptr = (int *)cls - MONPTR_SIZE;
   fprintf(fp,"Monitor = 0x%x\n", *intptr);
   fprintf(fp,"Method Vector Base = 0x%x\n", cls->methodVectorBase);

   key = (unsigned int *)getAbsAddr(cls->name);
   fprintf(fp,"Name: Key = 0x%x, Value = %s\n", *key, getAbsAddr((char *)cls->name+4));

   super = (decafClass_for_classLoader *)getAbsAddr(cls->superClass);
   key = (unsigned int *)getAbsAddr(super->name);
   fprintf(fp,"Superclass: Objref = 0x%x, Key = 0x%x, Value = %s\n", cls->superClass, *key, getAbsAddr((char *)super->name+4));

   fprintf(fp,"Access: 0x%x\n", cls->access);
   dumpRelConstantPool(cls->constpoolCount, cls->constpool, fp);
   dumpRelField(cls->fieldsCount, cls->fields, fp);
   dumpRelMethod(cls->methodsCount, cls->methods, fp);
   dumpImplements(cls->implementsCount, cls->implements, fp);

   /* ohptr points to the beginning of the decafObjectHint structure */
   ohptr = (decafObjectHint_for_classLoader *)((int)cls->objHintBlk + 8);
   dumpObjHintBlk(ohptr, fp);

   fflush(fp);
}

disAsmMethod(decafMethod_for_classLoader *m, FILE *fp)
{
   
   m = (decafMethod_for_classLoader *)getAbsAddr(m);

   disAssembly(m->code, m->codeLength, fp);

   return(DSV_SUCCESS);
}

void
dumpOneMethod(decafMethod_for_classLoader *m, FILE *fp)
{
   int j;
   int *intptr;
   unsigned char *cptr;
   decafExceptionBlock *eptr, *abseptr;
   unsigned int *key;
   exceptionArray *exceptionPtr, *absexPtr;

    fprintf(fp,"\tMethod Object (Objref = 0x%x)\n", m);
    m = (decafMethod_for_classLoader *)getAbsAddr(m);
    intptr = (int *)m - MONPTR_SIZE;
    fprintf(fp,"\tMonitor = 0x%x\n", *intptr);
    fprintf(fp,"\tMethod Vector Base = 0x%x\n", m->methodVectorBase);
    key = (unsigned int *)getAbsAddr(m->methodField.name);
    fprintf(fp,"\tMethod name: Address = 0x%x, Key = 0x%x, Value = %s\n", 
    m->methodField.name, *key, getAbsAddr((char *)m->methodField.name+4));

    key = (unsigned int *)getAbsAddr(m->methodField.signature);
    fprintf(fp,"\tSignature: Address = 0x%x, Key = 0x%x, Value = %s\n",
    m->methodField.signature, *key, getAbsAddr((char *)m->methodField.signature+4));

    fprintf(fp,"\tAccess Flag: 0x%x\n", m->methodField.access);
    if (m->methodField.access & ACC_STATIC) {
     fprintf(fp,"\tMethod Type: Static\n");
    }
    else {
     fprintf(fp,"\tMethod Type: Instance, Index into MethodVectorTable: %d\n",
     (m->argsSize) >> 16);
    }

    j = 0xffff0000 & m->argsSize;
    fprintf(fp,"\tMethod index = %d \n", j >> 16);
    j = 0x0000ffff & m->argsSize;
    fprintf(fp,"\tMethod arg size = %d (%d bytes)\n", j >> 2, j);
    fprintf(fp,"\tCode length = %d bytes\n", m->codeLength);

    fprintf(fp,"\tCode @ 0x%x:\n", m->code);
    cptr = (unsigned char *)getAbsAddr(m->code);
    for (j=0; j< m->codeLength; j++) {
     fprintf(fp,"\t   0x%x : 0x%x\n", j, *cptr++);
    }

    fprintf(fp,"\tException Table Count = %d\n", m->exceptionTableLength);
    if (m->exceptionTableLength) {
      exceptionPtr = m->exception;

      /* dump exception array */
      fprintf(fp,"\tException Table (Arrayref = 0x%x)\n", exceptionPtr);
      absexPtr = (exceptionArray *)getAbsAddr(exceptionPtr);
      intptr = (int *)absexPtr - MONPTR_SIZE;
      fprintf(fp,"\t   Monitor = 0x%x\n", *intptr);
      fprintf(fp,"\t   Method Vector Base = 0x%x\n", 
              (int)absexPtr->methodVectorBase & SIZE_OF_ELEMENT_MASK);
      fprintf(fp,"\t   Array Size: %d\n", absexPtr->arraySize);
      fprintf(fp,"\t   Element Size: %d\n", 
              (int)absexPtr->methodVectorBase & ~(SIZE_OF_ELEMENT_MASK));


      /* dump each exception block */
      for (j=0; j < m->exceptionTableLength; j++) {
       eptr = (decafExceptionBlock *)absexPtr->entry[j];
       fprintf(fp,"\t  Exception Block (Objref = 0x%x)\n", eptr);
       abseptr = (decafExceptionBlock *)getAbsAddr(eptr);
       fprintf(fp,"\t    Method Vector Base = 0x%x\n", abseptr->methodVectorBase);
       fprintf(fp,"\t    startPc = 0x%x\n", abseptr->startPc);
       fprintf(fp,"\t    endPc = 0x%x\n", abseptr->endPc);
       fprintf(fp,"\t    handlerPc = 0x%x\n", abseptr->handlerPc);
       fprintf(fp,"\t    catch Object = 0x%x\n", abseptr->catchObject);
      }
    }

    fprintf(fp,"\tMax number of local variables = %d (%d bytes)\n", m->nlocals >> 2, m->nlocals);
    fprintf(fp,"\tMax stack = %d (%d bytes)\n", m->maxstack >> 2, m->maxstack);
    fprintf(fp,"\n");

    fflush(fp);
}


decafMethod_for_classLoader *cmFindMethod(decafClass_for_classLoader *cls, char *methodName)
{
   int i;
   decafMethod_for_classLoader **m_array;
   char *name;
   methodArray *m_array_ptr;
   decafMethod_for_classLoader* m;

   cls = (decafClass_for_classLoader *)getAbsAddr(cls);
   m_array_ptr = (methodArray *)getAbsAddr(cls->methods);
   m_array = m_array_ptr->method;

   for (i=0; i < cls->methodsCount; i++) {
    m = (decafMethod_for_classLoader*)getAbsAddr(m_array[i]);
    name = (char *)getAbsAddr((char *)(m->methodField.name)+4);
    if (strcmp(name, methodName) == 0) {
     break;
    }
   }

   if (i == cls->methodsCount) return NULL;

   return((decafMethod_for_classLoader *)getRelAddr(m));
}

decafClass_for_classLoader *cmFindClass(char *className)
{
   decafClass_for_classLoader *cls;
   decafClass_for_classLoader *clsAbs;
   char *name;
   int i;

   i = 0;

   while ((cls = cmGetClassTable(i)) != NULL)
   { 
      clsAbs = (decafClass_for_classLoader *)getAbsAddr(cls);
      name = (char *)getAbsAddr(clsAbs->name);
      name += 4; /* to skip the key */
      if (strcmp(className, name)==0) break;
      i++;
   }

   return(cls);
}


void
cmClassTableDump(FILE *fp)
{
   decafClass_for_classLoader *cls;
   int i=0;
   int cnt;
   int nomain = 0;

   if (cmGetClassTable(0) == NULL) {
    fprintf(fp,"Warning : There is no main method in any loaded class.\n");
    nomain = 1;
    i = 1;
   }

   while (cmGetClassTable(i) != NULL) {
    i++;
   }

   if ((i==1) && (nomain==1)) {
    fprintf(fp, "Error:no class loaded\n");
    return;
   }

   fprintf(fp, "class table at %x(h)\n", decafClass_for_classLoaderTable);
   fprintf(fp,"  total %d classes\n\n", decafClassTableCount);
   i = 0;
   while ((cls = cmGetClassTable(i)) != NULL)
   { 
      fprintf(fp,"********************\n");
      fprintf(fp,"class %d\n", i);
      fprintf(fp,"********************\n");
      dumpClass((decafClass_for_classLoader *)cls, fp);
      i++;
   }
   fflush(fp);
}

void
dumpCommonMemory(FILE *fp)
{
   /* trape table first */


   cmClassTableDump(fp);
   fflush(fp);
}

/*
 * read the data from the given addr in size bit
 * The data area is prepared by the caller
 */
cmMemoryRead(unsigned int addr, int *data, int size)
{
   char *addrAbs;
   char *cptr;
   int i;
   int inputChar, bufferLen;

   /* read character from CONSOLE */
   /* upper 3 bits of addr are masked off so need to "or" in 0x20000000 */

   if ( (addr | 0x20000000)  == CONSOLE_ADDR ) {
     
     if ( iBufferReadIndex < strlen(inputBuffer) ) {
       /* we have character in buffer already */
       inputChar = inputBuffer[iBufferReadIndex++];
     }
     else {
       fgets(inputBuffer,MAX_INPUT_BUFFER-1,stdin);
       bufferLen = strlen(inputBuffer);

       /* add line feed to string */
       inputBuffer[bufferLen]   = 0xa0;
       inputBuffer[bufferLen+1] = 0x0;       

       iBufferReadIndex = 0;
       inputChar = inputBuffer[iBufferReadIndex++];
     }

     *data = inputChar << 24;
     return(DSV_SUCCESS);

   }

   if (addr > CM_SIZE) {
    if ((addr < (unsigned int)SCRATCH_START) ||
        (addr > (unsigned int)((unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE))) {
     printf("Error: address %08x, data %08x Not in the correct region\n", addr, *data);
     return(DSV_FAIL);
    }

    if (((addr >= BAD_MEMORY_START) &&
         (addr < (unsigned int)BAD_MEMORY_START + (unsigned int)BAD_SIZE)) ||
        ((addr >= BAD_IO_START) &&
         (addr < (unsigned int)BAD_IO_START + (unsigned int)BAD_SIZE))) {
     return(DSV_FAIL);
    }
    addrAbs = getScratchAbsAddr(addr);
   }
   else {
    addrAbs = getAbsAddr(addr);
   }


   i = addr & 0x00000003;
   *data = 0;
   cptr = (char *)data;

   switch (size) {
    case 0:
      cptr[i] = *addrAbs;
      break;
    case 1:
      if ((i==1) || (i==3)) {
       printf("Warning : a alignment error\n");
      }
      cptr[i++] = *addrAbs++;
      cptr[i] = *addrAbs;
      break;
    case 2:
      if (i != 0) {
       printf("Warning : b alignment error\n");
      }
      cptr[0] = *addrAbs++;
      cptr[1] = *addrAbs++;
      cptr[2] = *addrAbs++;
      cptr[3] = *addrAbs;
      break;
    default:
      printf("Error : size can not be greater than 32 bits.\n");
      return(DSV_FAIL);
   }
#ifdef CM_DBG
   if (decaf)
    printf("Read from address %x, data %x, size %d\n", addr, *data, size);
   else
    printf("tam : memory read, address %8x, data %08x, size %08x\n", addr, *data, size);
   fflush(stdout);
#endif
      return(DSV_SUCCESS);
}

/*
 * write the data to the given addr in size bit
 */
cmMemoryWrite(unsigned int addr, int data, int size)
{
   char *addrAbs;
   char *cptr;
   int i;

#ifdef CM_DBG
   if (decaf)
    printf("Write to address %x, data %x, size %d\n", addr, data, size);
   else
    printf("tam : memory write, addr %08x, data %08x, size %d\n", addr, data, size);
   fflush(stdout);
#endif

   /* catch console output first then check for regular mem operation */
   /* we always write the least significant byte out to screen */
 
   if ( (addr | 0x20000000 ) == CONSOLE_ADDR ) {
        switch ( size ) {
        case 0:
                printf("%c",(data & 0xff000000) >> 24);
                break;
        case 1:
                printf("%c",(data & 0x00ff0000) >> 16);
                break;
        case 2:
                printf("%c",data & 0x000000ff);
                break;
        }
        fflush(NULL);
        return(DSV_SUCCESS);
   }

   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x, data %08x Not in the correct region\n", addr, data);
     return(DSV_FAIL);
    }
    /* don't write to the bad area so that we keep the initial value */
    if (((addr >= BAD_MEMORY_START) &&
         (addr < (unsigned int)BAD_MEMORY_START + (unsigned int)BAD_SIZE)) ||
        ((addr >= BAD_IO_START) &&
         (addr < (unsigned int)BAD_IO_START + (unsigned int)BAD_SIZE))) {
/*
     printf("Write to bad address %x\n", addr);
*/
     return(DSV_FAIL);
    }
    addrAbs = getScratchAbsAddr(addr);
   }
   else {
    addrAbs = getAbsAddr(addr);
   }

   cptr = (char *)&data;
   i = addr & 0x00000003;

   switch (size) {
     case 0:
     {
      *addrAbs = cptr[i];
      if (addr == SYSCALL_MAGIC_ADDR)
      {
          handle_syscall ();
      }
      return(DSV_SUCCESS);
     }
     case 1:
      if ((i==1) || (i==3)) {
       printf("Warning : e alignment error\n");
      }
      *addrAbs++ = cptr[i++];
      *addrAbs = cptr[i];
      return(DSV_SUCCESS);
     case 2:
      if (i != 0) {
       printf("Warning : f alignment error\n");
      }
      *addrAbs++ = cptr[0];
      *addrAbs++ = cptr[1];
      *addrAbs++ = cptr[2];
      *addrAbs = cptr[3];
      return(DSV_SUCCESS);
     default:
      printf("Error : size can not be greater than 32 bits.\n");
      return(DSV_FAIL);
   }
}

cmPeek(unsigned int addr)
{
   unsigned int *startAbs;

   addr = addr & 0xfffffffc;
   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x Not in the correct region\n", addr);
     return DSV_FAIL;
    }
    startAbs = (unsigned int *)getScratchAbsAddr(addr);
   }
   else {
    startAbs = (unsigned int *)getAbsAddr(addr);
   }

   return (*startAbs);
}

cmPoke(unsigned int addr, int value)
{
   int *startAbs;
   int i;

   addr = addr & 0xfffffffc;
   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x Not in the correct region\n", addr);
     return DSV_FAIL;
    }
    startAbs = (int *)getScratchAbsAddr(addr);
   }
   else {
    startAbs = (int *)getAbsAddr(addr);
   }

   *startAbs = value;

   return DSV_SUCCESS;

}

cmMemoryDirectDumpNoAddress(unsigned int addr, int cnt, FILE *fp)
{
   unsigned int *startAbs;
   int i;

   unsigned int data0, data1, data2, data3;

   addr = addr & 0xfffffffc;
   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x Not in the correct region\n", addr);
     return DSV_FAIL;
    }
    startAbs = (unsigned int *)getScratchAbsAddr(addr);
   }
   else {
    startAbs = (unsigned int *)getAbsAddr(addr);
   }

   for (i=0; i < cnt; i += 4) {
    if (addressCheck(addr+i) == DSV_FAIL) break;
    data0 = (*startAbs & 0xFF000000) >> 24;
    data1 = (*startAbs & 0x00FF0000) >> 16;
    data2 = (*startAbs & 0x0000FF00) >> 8;
    data3 = *startAbs & 0x000000FF;
    fprintf(fp, "%02X %02X %02X %02X\n",data0, data1, data2, data3);
    startAbs++;
   }

   fflush(fp);

   return DSV_SUCCESS;

}

cmMemoryDirectDump(unsigned int addr, int cnt, FILE *fp)
{
   unsigned int *startAbs;
   int i;

   addr = addr & 0xfffffffc;
   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x Not in the correct region\n", addr);
     return DSV_FAIL;
    }
    startAbs = (unsigned int *)getScratchAbsAddr(addr);
   }
   else {
    startAbs = (unsigned int *)getAbsAddr(addr);
   }

   for (i=0; i < cnt; i += 4) {
    if (addressCheck(addr+i) == DSV_FAIL) break;
    fprintf(fp,"%08x %08x\n", addr+i, *startAbs++);
   }

   fflush(fp);

   return DSV_SUCCESS;

}

cmMemoryDirectWrite(unsigned int addr, char value)
{
   char *startAbs;
   int i;


   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x Not in the correct region\n", addr);
     return DSV_FAIL;
    }
    startAbs = (char *)getScratchAbsAddr(addr);
   }
   else {
    startAbs = (char *)getAbsAddr(addr);
   }

   *startAbs = value;

   return DSV_SUCCESS;

}

addressCheck(unsigned int addr)
{
   if (addr > CM_SIZE) {
    if ((addr < SCRATCH_START) || (addr > (unsigned int)SCRATCH_START + (unsigned int)SCRATCH_SIZE)) {
     printf("Error: address %08x Not in the correct region\n", addr);
     return DSV_FAIL;
    }
   }

   return DSV_SUCCESS;
}

/*
 * only tam use this function
*/
void
cmSetPJType(int type)
{

#if 0
  printf("pj_type %d\n", type);
#endif
  return;
}

int cm_checkpoint (CPR_REQUEST_T req, FILE *fp)

{
    switch (req)
    {
      case CPR_QUERY: 
        break;
      case CPR_CHECKPOINT: 
      {
          unsigned int i;
          unsigned long srcLen, destLen;
          unsigned char *buf;
	  /* write out 2 segments of memory - 
             one for CM, one for scratch mem */ 
          i = 2;   /* no. of segments being written out */
          CHECKING_FWRITE (&i, sizeof (i), 1, fp)

          /* we compress only the Cm main memory */
          srcLen = (unsigned long) CM_SIZE;
          destLen = (unsigned long) CM_SIZE + ((unsigned long) (0.001 * CM_SIZE)) + 13;
          buf = (unsigned char *) malloc (destLen);
          if (compress (buf, &destLen, (unsigned char*) commonMemory, srcLen) 
              != Z_OK)
          {
              fprintf (stderr, "Warning: error compressing main memory for "
                               "checkpoint\n");
              return 1;
          }

          CHECKING_FWRITE (&destLen, sizeof (destLen), 1, fp)
          CHECKING_FWRITE (buf, 1, (size_t) destLen, fp)
          free (buf);

          i = SCRATCH_SIZE;
          CHECKING_FWRITE (&i, sizeof (i), 1, fp)
          CHECKING_FWRITE (scratchMemory, SCRATCH_SIZE, 1, fp)
   
          break;
      }
      case CPR_RESTART: 
      {
        unsigned int i;
        unsigned long srcLen, destLen = CM_SIZE;
        unsigned char *buf;
        
        CHECKING_FREAD (&i, sizeof (i), 1, fp)
        if (i != 2)
            return 1;

        CHECKING_FREAD (&srcLen, sizeof (srcLen), 1, fp)
        buf = (unsigned char *) malloc ((size_t) srcLen);
        CHECKING_FREAD (buf, 1, (size_t) srcLen, fp)

        if (uncompress ((unsigned char *) commonMemory, &destLen, buf, srcLen) 
            != Z_OK)
        {
              fprintf (stderr, "Warning: error uncompressing main memory for "
                               "restart\n");
              return 1;
        }

        free (buf);

        if (destLen != CM_SIZE)
            return 1;

        CHECKING_FREAD (&i, sizeof (i), 1, fp)
        if (i != SCRATCH_SIZE)
            return 1;
        CHECKING_FREAD (scratchMemory, SCRATCH_SIZE, 1, fp)

        break;
      }
    }
    return (0);
}
