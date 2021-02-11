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
 ***
 *****************************************************************/




static char *sccsid = "@(#)array_ops.c 1.5 Last modified 10/07/98 14:29:50 SMI";

#include "jvm_ops.h"
#include "array_ops.h"

void doArrayLength ()

{
    unsigned int arrayRef, arrayLen, arrayStorage;
    READ_WORD (OPTOP_OFFSET (1), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);

    READ_WORD (arrayStorage, 'M', arrayLen);

    MASK_ARRAY_LENGTH (arrayLen);

    WRITE_WORD (OPTOP_OFFSET (1), 'O', arrayLen);

    SIZE_AND_STACK_RETURN (1, 0);
}

void do32bArrayLoad ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;

    READ_WORD (OPTOP_OFFSET (2), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);

    READ_WORD (OPTOP_OFFSET (1), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (arrayStorage + (index+1)*4, 'M', tmp);
    WRITE_WORD (OPTOP_OFFSET(2), 'O', tmp);

    SIZE_AND_STACK_RETURN (1, -1);
}
    
void do32bArrayStore ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;

    READ_WORD (OPTOP_OFFSET (3), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (2), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (OPTOP_OFFSET(1), 'O', tmp); 
    WRITE_WORD (arrayStorage + (index+1)*4, 'M', tmp);

    SIZE_AND_STACK_RETURN (1, -3);
}
    
void do64bArrayLoad ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;

    READ_WORD (OPTOP_OFFSET (2), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef); /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (1), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (arrayStorage + 4+(index)*8, 'M', tmp);
    WRITE_WORD (OPTOP_OFFSET(1), 'O', tmp);
    READ_WORD (arrayStorage + 8+(index)*8, 'M', tmp);
    WRITE_WORD (OPTOP_OFFSET(2), 'O', tmp);

    SIZE_AND_STACK_RETURN (1, 0);
}
    
void do64bArrayStore ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;

    READ_WORD (OPTOP_OFFSET (4), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (3), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (OPTOP_OFFSET(1), 'O', tmp);
    WRITE_WORD (arrayStorage + 4+(index)*8, 'M', tmp);
    READ_WORD (OPTOP_OFFSET(2), 'O', tmp);
    WRITE_WORD (arrayStorage + 8+(index)*8, 'M', tmp);

    SIZE_AND_STACK_RETURN (1, -4);
}

void doBaload ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;
    signed char c;

    READ_WORD (OPTOP_OFFSET (2), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (1), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_BYTE (arrayStorage+4+index, 'M', c);
    tmp = (unsigned int) c;
    WRITE_WORD (OPTOP_OFFSET (2), 'O', tmp);

    SIZE_AND_STACK_RETURN (1, -1);
}

void doBastore ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;
    signed char c;

    READ_WORD (OPTOP_OFFSET (3), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (2), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (OPTOP_OFFSET(1), 'O', tmp);
    c = (signed char) tmp;
    WRITE_BYTE (arrayStorage+4+index, 'M', c);

    SIZE_AND_STACK_RETURN (1, -3);
}

void doSaload ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;
    signed short s;

    READ_WORD (OPTOP_OFFSET (2), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (1), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_SHORT (arrayStorage+4+index*2, 'M', s);
    tmp = (unsigned int) s;
    WRITE_WORD (OPTOP_OFFSET (2), 'O', tmp);

    SIZE_AND_STACK_RETURN (1, -1);
}

void doSastore ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;
    signed short s;

    READ_WORD (OPTOP_OFFSET (3), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (2), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index)

    READ_WORD (OPTOP_OFFSET(1), 'O', tmp);
    s = (signed short) tmp;
    WRITE_SHORT (arrayStorage+4+index*2, 'M', s);

    SIZE_AND_STACK_RETURN (1, -3);
}
    
void doCaload ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;
    unsigned short s;

    READ_WORD (OPTOP_OFFSET (2), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (1), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_SHORT (arrayStorage+4+index*2, 'M', s);
    tmp = (unsigned int) s;
    WRITE_WORD (OPTOP_OFFSET (2), 'O', tmp);

    SIZE_AND_STACK_RETURN (1, -1);
}

void doCastore ()

{
    unsigned int arrayRef, index, arrayStorage, tmp;
    unsigned short s;

    READ_WORD (OPTOP_OFFSET (3), 'O', arrayRef);

    TRAP_IF_ARRAYREF_NULL (arrayRef);
    GET_ARRAY_STORAGE_ADDR (arrayRef, arrayStorage);
    MASK_ARRAYREF (arrayRef);  /* zero MSB, 2 LSBs */

    READ_WORD (OPTOP_OFFSET (2), 'O', index);

    CHECK_ARRAY_BOUNDS (arrayStorage, index);

    READ_WORD (OPTOP_OFFSET(1), 'O', tmp);
    s = (unsigned short) tmp;
    WRITE_SHORT (arrayStorage+4+index*2, 'M', s);

    SIZE_AND_STACK_RETURN (1, -3);
}
