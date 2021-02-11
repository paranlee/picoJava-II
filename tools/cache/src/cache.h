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




#ifndef _CACHE_H_
#define _CACHE_H_

#pragma ident "@(#)cache.h 1.13 Last modified 02/28/99 08:43:16 SMI"

#include <stdio.h>

#include "checkpoint_types.h"

#define MAYA_ILINESIZE 4
#define PICO_ILINESIZE 3
#define DLINESIZE 4

int IINDEX_L;
int IINDEX_R;

int DINDEX_L;
#define DINDEX_R 4

#define LTAG 31
int DRTAG;
int IRTAG;

/* I$ */
/* direct map */
typedef struct iCacheEntry {
   unsigned char line[1 << MAYA_ILINESIZE];	/* 16 bytes, use only 8 for pico */
   unsigned int tag:22;			/* 20 bits */
/* for 1-way i$ size of 1k, # of tag bits = 20 */
   unsigned char valid:1;		/* 1 bit */
} iCacheEntry;

/* D$ */
/* two-way set associate */
/* write back */
/* write allocate */
typedef struct dCacheSet {
   unsigned char line[1 << DLINESIZE];	/* 16 bytes */
   unsigned int  tag:23;		/* 21 bits */
/* changed for 21 to 23 bits of tag because RTL unfortunately
   keeps around bit 31 and bit 30 of the address in the tag */
/* so we have to keep it around too (though we don't need it)
   in order to match RTL.
   Therefore:
   tag bits corresponding to address space bits 30 and 31 are 
   stored in RAM when tag writes are performed. however, they
   are stripped off when the tag is read for a normal D$ lookup.
   bit when a read_dacache_tag is performed they return those
   bits as well.
 */

/* for 2-way d$ size of 1k, # of tag bits = 21 */
   unsigned char valid:1;		/* 1 bit */
   unsigned char dirty:1;		/* 1 bit */
} dCacheSet;

typedef struct dCacheEntry {
   dCacheSet dSet[2];
   unsigned char lru;			/* 1 bit */
   
} dCacheEntry;

extern iCacheEntry *I;
extern dCacheEntry *D;


extern int iCacheLineSize;
extern int dCacheLineSize;
extern int numOfIcacheEntries;
extern int numOfDcacheEntries;

extern int dCacheDisplayLine(unsigned int line, FILE *fp, unsigned int header);
extern int dCacheDisplayAll(unsigned int f, unsigned int t, FILE *fp);
extern int iCacheDisplayLine(unsigned int line, FILE *fp, unsigned int header);
extern int iCacheDisplayAll(unsigned int f, unsigned int t, FILE *fp);
extern int iCacheSelect(unsigned int addr, unsigned int *index, unsigned int *tag);


/* interface functions */
extern int icacheInit(unsigned int iSize);
extern int dcacheInit(unsigned int dSize);
extern int cacheDSizeK();
extern int cacheISizeK();
extern int dCacheZeroLine();
extern int cacheFlush(unsigned int addr, unsigned int incr, unsigned int *resultAddr);
extern int cacheIndexFlush(unsigned int addr, unsigned int incr, unsigned int *resultAddr);

extern int readDcacheTag(unsigned int addr, unsigned int *data);
extern int writeDcacheTag(unsigned int addr, unsigned int data);
extern int readDcacheData(unsigned int addr, unsigned int *data);
extern int writeDcacheData(unsigned int addr, unsigned int data);

extern int writeIcacheTag(unsigned int addr, unsigned int data);
extern int readIcacheTag(unsigned int addr, unsigned int *data);
extern int writeIcacheData(unsigned int addr, unsigned int data);
extern int readIcacheData(unsigned int addr, unsigned int *data);
extern int cacheInvalidate (unsigned int addr, unsigned int incr, unsigned int *resultAddr);

/* size : 0 (byte), 1 (short), 2 (word) */
/* data is the one in the stack without modification */
extern int dCacheWrite(unsigned int addr, unsigned int data, unsigned int size);
extern int dCacheRead(unsigned int addr, unsigned int *data);
extern int iCacheRead(unsigned int addr, unsigned int *data);

/* debug_dCacheRead is a non-intrusive dcache read. i.e. it picks up
the data from dcache/memory as appropriate, but does not affect the
state of the cache by causing replacements, etc. useful to get the
programmer view of a given memory location without bothering whether
it is in D-cache or not, without perturbing the state of the cache.
*/

extern int debug_dCacheRead (unsigned int addr, unsigned int *data);

int cache_checkpoint (CPR_REQUEST_T req, FILE *fp);
int preloadCaches (char *path_prefix);

#endif /* _CACHE_H_ */
