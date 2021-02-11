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




static char *sccsid = "@(#)util.c 1.4 Last modified 10/06/98 11:35:36 SMI";

#include <stdio.h>

#include "dsv.h"
#include "cache.h"
#include "lutil.h"

unsigned int
getFieldValue(unsigned int value, unsigned int left, unsigned int right)
{
    unsigned int mask;
    unsigned int range;
    unsigned int v;

    range = left - right + 1;
    mask = ((1 << range) - 1) << right;
    v = (value & mask) >> right;

    return v;
    
}

unsigned int
makeDAddr(unsigned int tag, unsigned int index, unsigned int shift)
{
   unsigned int addr;

   addr = (tag << DRTAG) | (index << shift);

   return(addr);

}

unsigned int
makeIAddr(unsigned int tag, unsigned int index, unsigned int shift)
{
   unsigned int addr;

   addr = (tag << IRTAG) | (index << shift);

   return(addr);

}
