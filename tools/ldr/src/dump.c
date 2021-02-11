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




static char *sccsid = "@(#)dump.c 1.7 Last modified 10/06/98 11:34:10 SMI";

#include <stdio.h>
#include <setjmp.h>

#include "dsv.h"
#include "decaf.h"

#include "oobj.h"
#include "tree.h"
#include "loader.h"

void dumpMethodTable(unsigned short count, struct methodtable *mtable)
{

  int i;
  struct methodblock *mb;

   printf("instance methods count %d\n", count);
   for (i=0; i < count; i++) {
    mb = mtable->methods[i];
    printf("\tmethod name : %s\n", mb->fb.name);
    printf("\tlocated class : %s\n", (mb->fb).clazz->name);

   }

   printf("\n");

}

void dumpSlotTable(unsigned short count, struct fieldblock **slottable)
{
   int i;
   struct fieldblock *fb;
   int size;

   printf("instance variables total offset count %d\n", count);
   for (i=0; i< count; i++) {
    fb = slottable[i];

    printf("\tfield name : %s\n", fb->name);
    printf("\tlocated class : %s\n", fb->clazz->name);
    printf("\tfield signature : %s\n", fb->signature);
    printf("\tfield access :  %xh(instance)\n", fb->access);
    printf("\tfield ID : %d\n", fb->ID);
    printf("\tfield static value, address, or offset : %d\n", fb->u.offset);
    printf("\n");

    if ((fb->signature[0] == SIGNATURE_LONG) ||
        (fb->signature[0] == SIGNATURE_DOUBLE)) {
     i++;
    }
   }

   printf("\n");
}

void dumpConstantPool(unsigned short count, cp_item_type *cp)
{
   int i;
   unsigned char *type_table;
   short *sptr;
   long *lptr;
   double *dptr;

   printf("constant pool count %d\n", count);

   type_table = (unsigned char *)cp[CONSTANT_POOL_TYPE_TABLE_INDEX].p; 
   for (i=CONSTANT_POOL_UNUSED_INDEX; i < count; i++) {
    /* The 8 bit is for resolution */
    switch (CONSTANT_POOL_TYPE_TABLE_GET_TYPE(type_table,i)) {
     case CONSTANT_Utf8:
      printf("\t%d, Utf8, location %xh, value %s\n", i, cp[i].cp, cp[i].cp);
      break;
     case CONSTANT_Class:
      printf("\t%d, Class (%d), index %d %xh\n", i, (int)((CONSTANT_POOL_TYPE_TABLE_GET(type_table,i) & CONSTANT_POOL_ENTRY_RESOLVED)>>7), cp[i].i, cp[i].p);
      break;
     case CONSTANT_String:
      printf("\t%d, String, index %d\n", i, cp[i].i);
      break;
     case CONSTANT_Fieldref:
      sptr = (short *)(&cp[i]);
      printf("\t%d, Fieldref, class index %d, nameType index %d\n", i, sptr[0], sptr[1]);
      break;
     case CONSTANT_Methodref:
      sptr = (short *)&(cp[i]);
      printf("\t%d, Methodref, class index %d, nameType index %d\n", i, sptr[0], sptr[1]);
      break;
     case CONSTANT_InterfaceMethodref:
      sptr = (short *)&(cp[i]);
      printf("\t%d, InterfaceMethodref, class index %d, nameType index %d\n", i, sptr[0], sptr[1]);
      break;
     case CONSTANT_NameAndType:
      sptr = (short *)&(cp[i]);
      printf("\t%d, NameAndType, name index %d, descriptor index %d\n", i, sptr[0], sptr[1]);
      break;
     case CONSTANT_Integer:
      printf("\t%d, Integer, value %d\n", i, cp[i].i);
      break;
     case CONSTANT_Float:
      printf("\t%d, Float, value %f\n", i, cp[i].f);
      break;
     case CONSTANT_Long:
      lptr = (long *)&(cp[i]);
	/* Long is 64 bit */
      printf("\t%d, Long, value %08x %8x\n", i, lptr[0], lptr[1]);
      i++;
      break;
     case CONSTANT_Double:
      dptr = (double *)&(cp[i]);
      printf("\t%d, Double, value %f\n", i, dptr[0]);
      i++;
      break;
     default:
      printf("Illegal constant pool type %d\n", type_table[i]);
      break;
    }
   }

   return;
}

void dumpField(int cnt, struct fieldblock *fields)
{
   int i;

   printf("field count %d\n", cnt);
   for (i=0; i < cnt; i++) {
    printf("\tfield name : %s\n", fields[i].name);
    printf("\tfield signature : %s\n", fields[i].signature);
    if (fields[i].access & ACC_STATIC) {
     printf("\tfield access :  %xh(static)\n", fields[i].access);
    }
    else {
     printf("\tfield access :  %xh(instance)\n", fields[i].access);
    }
    printf("\tfield ID : %d\n", fields[i].ID);

    printf("\tfield static value, address, or offset : %d\n", fields[i].u.offset);
    printf("\n");
   }

   return;
}

void dumpMethod(int cnt, struct methodblock *methods)
{
   int i;
   int j;
   struct lineno *ln;
   struct localvar *lv;
   unsigned char *cptr;

   printf("method count %d\n", cnt);
   for (i=0; i < cnt; i++) {
    printf("\tmethod location : %xh\n", &methods[i]);
    printf("\tmethod name : %s\n", methods[i].fb.name);
    printf("\toffset : %d\n", methods[i].fb.u.offset);
    printf("\tmethod signature : %s\n", methods[i].fb.signature);
    printf("\tmethod arg size : %d\n", methods[i].args_size);
    printf("\tmethod code length : %d bytes\n", methods[i].code_length);
    /* code is not printable */
    printf("\tmethod code :\n");
    cptr = methods[i].code;
    for (j=0; j< methods[i].code_length; j++) {
     printf("\t%xh : %xh\n", j, *cptr++);
    }

    printf("\texception table count %d\n", methods[i].exception_table_length);
    for (j=0; j < methods[i].exception_table_length; j++) {
     printf("\t   start_pc : %xh\n", methods[i].exception_table[j].start_pc);
     printf("\t   end_pc : %xh\n", methods[i].exception_table[j].end_pc);
     printf("\t   handler_pc : %xh\n", methods[i].exception_table[j].handler_pc);
     printf("\t   catch Obj index : %d\n", methods[i].exception_table[j].catchType);
    }

#if 0
    printf("\tline number table count %d\n", methods[i].line_number_table_length);
    for (j=0; j < methods[i].line_number_table_length; j++) {
     printf("\t   pc : %xh, line no : %d\n", methods[i].line_number_table[j].pc, methods[i].line_number_table[j].line_number);
    }
#endif

    printf("\t max number of local variables : %d\n", methods[i].nlocals);
    printf("\t max stack : %d\n", methods[i].maxstack);
    printf("\tlocal variable count %d\n", methods[i].localvar_table_length);
    for (j=0; j < methods[i].localvar_table_length; j++) {
     printf("\t   pc0 : %xh, length : %d, nameoff : %d, sigoff : %d, slot : %d\n", methods[i].localvar_table[j].pc0, methods[i].localvar_table[j].length, methods[i].localvar_table[j].nameoff, methods[i].localvar_table[j].sigoff, methods[i].localvar_table[j].slot);
    }
    printf("\n");
   }

   return;
}

void
dumpImplement(unsigned short count, short *imp)
{
   unsigned short i;

   printf("Implements count %d\n", count);
   for (i=0; i < count; i++) {
    printf("\tindex %d\n", imp[i]);
   }
   printf("\n");
}

void
dumpOneBinClass(ClassClass *cb)
{
    printf("class name : %s\n", cb->name);
    printf("\tmajor version : %d\n", cb->major_version);
    printf("\tminor version : %d\n", cb->minor_version);
    if (cb->super_name != NULL)
     printf("\tsuper class : %s\n", cb->super_name);
    else 
     printf("\tsuper class : NULL\n");

    printf("\tsource name : %s\n", cb->source_name);
    printf("\taccess flag : %xh\n", cb->access);


    dumpConstantPool(cb->constantpool_count, cb->constantpool);

    dumpField(cb->fields_count, cb->fields);

    if (decaf) printf("instance size %d bytes\n", cb->instance_size);
    if (decaf) dumpSlotTable(cb->slottbl_size, cb->slottable);

    dumpMethod(cb->methods_count, cb->methods);

    if (decaf) dumpMethodTable(cb->methodtable_size, cb->methodtable);

    dumpImplement(cb->implements_count, cb->implements);

    return;
}

void dumpAllBinClasses()
{
   int i;

   printf("Total classes %d\n\n", nbinclasses);
   for (i=0; i < nbinclasses; i++) {
    printf("class %d :\n", i);
    dumpOneBinClass(binclasses[i]);
    printf("\n");
   }

   return;
}
