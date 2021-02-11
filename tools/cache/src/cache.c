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




static char *sccsid = "@(#)cache.c 1.11 Last modified 10/06/98 11:35:31 SMI";

#include <stdio.h>

#include "dsv.h"
#include "decaf.h"
#include "cm.h"
#include "lutil.h"
#include "global_regs.h"
#include "cache.h"

iCacheEntry *I = NULL;
dCacheEntry *D = NULL;

int currentISize, currentDSize; /* these are encoded sizes! */
int numOfIcacheEntries;
int numOfDcacheEntries;

int iCacheLineSize;
int dCacheLineSize;

int iSizeK=0;
int dSizeK=0;

int dCacheSelect(unsigned int addr, unsigned int is_read, unsigned int *index, unsigned int *tag, unsigned char *set);
/* return 0 if success, 1 if failure */

static int open_file (char *path_prefix, char *fname, FILE **fp)

{
    char buf[200];
   
    strcpy (buf, path_prefix);
    /* append fname to end of path_prefix */
    strcat (buf, "/");
    strcat (buf, fname);

    if (((*fp) = fopen (buf, "r")) == NULL)
    {
       fprintf (stderr, "Warning: unable to read file %s\n", buf);
       return 1;
    }

    return 0;
}

/* return 0 if success, 1 if failure */

static int preloadICache (char *path_prefix)

{
    int i, j, tmp;
    FILE *fp1, *fp2;

    if (open_file (path_prefix, "itag", &fp1))
        return 1;

    if (open_file (path_prefix, "iram", &fp2))
        return 1;

    for (i = 0 ; i < numOfIcacheEntries ; i++)
    {
        for (j = 0 ; j < iCacheLineSize ; j++)
        {
	    fscanf (fp2, "%x\n", &tmp);
            I[i].line[j] = tmp;
        }

        fscanf (fp1, "%x\n", &tmp);
        I[i].tag = tmp >> 1;
        I[i].valid = tmp & 1;
    }
    return 0;
}

/* return 0 if success, 1 if failure */

static int preloadDCache (char *path_prefix)

{
    FILE *fp1, *fp2, *fp3;
    int i, tmp;

    if (open_file (path_prefix, "dtag0", &fp1))
        return 1;
    if (open_file (path_prefix, "dtag1", &fp2))
        return 1;
    if (open_file (path_prefix, "dstat", &fp3))
        return 1;

    for (i = 0 ; i < numOfDcacheEntries ; i++)
    {
        fscanf (fp1, "%x\n", &tmp);
        D[i].dSet[0].tag = tmp;
        fscanf (fp2, "%x\n", &tmp);
        D[i].dSet[1].tag = tmp;
        fscanf (fp3, "%x\n", &tmp);

        D[i].dSet[0].valid = tmp & 1;
        D[i].dSet[0].dirty = (tmp >> 1) & 1;
        D[i].dSet[1].valid = (tmp >> 2) & 1; 
        D[i].dSet[1].dirty = (tmp >> 3) & 1;
        D[i].lru = (tmp >> 4) & 1;
    }

    fclose (fp1);
    fclose (fp2);
    fclose (fp3);

    if (open_file (path_prefix, "dram0", &fp1))
        return 1;
    if (open_file (path_prefix, "dram1", &fp2))
        return 1;

    for (i = 0 ; i < numOfDcacheEntries ; i++)
    {
/* WARNING: highly unsafe macro!!!! */
#define READ4BYTES(fp, way, byte) { \
fscanf (fp, "%x\n", &tmp); D[i].dSet[way].line[byte] = tmp; \
fscanf (fp, "%x\n", &tmp); D[i].dSet[way].line[byte+1] = tmp; \
fscanf (fp, "%x\n", &tmp); D[i].dSet[way].line[byte+2] = tmp; \
fscanf (fp, "%x\n", &tmp); D[i].dSet[way].line[byte+3] = tmp; }

        READ4BYTES (fp1, 0, 0)
        READ4BYTES (fp1, 1, 4)
        READ4BYTES (fp1, 0, 8)
        READ4BYTES (fp1, 1, 12)

        READ4BYTES (fp2, 1, 0)
        READ4BYTES (fp2, 0, 4)
        READ4BYTES (fp2, 1, 8)
        READ4BYTES (fp2, 0, 12)
    }
#undef READ4BYTES

    return 0;
}

/* return 0 if success, 1 if failure */

int preloadCaches (char *path_prefix)

{
    if (preloadICache (path_prefix))
        return 1;
    if (preloadDCache (path_prefix))
        return 1;

    return 0;
}

dCacheNAWrite(unsigned int addr, unsigned int data, unsigned int size)
{
    unsigned int index;
    unsigned int ltag;
    unsigned char set;
    unsigned int lindex;
    unsigned int waddr;
    unsigned int i;
    unsigned char *cptr;
    unsigned char *cptr1;

    index = getFieldValue(addr, DINDEX_L, DINDEX_R);
    if ((int) index >= numOfDcacheEntries)
        return DSV_SUCCESS;

    ltag = getFieldValue(addr, LTAG, DRTAG);

    if ((D[index].dSet[0].valid == 1) && (D[index].dSet[0].tag == ltag))
        set = 0;
    else if ((D[index].dSet[1].valid == 1) && (D[index].dSet[1].tag == ltag))
        set = 1;
    else 
    {
      /* it's a miss, send the write to memory and forget about it */
        cmSetPJType (DCACHE_NC_STORE);
 	if (cmMemoryWrite(addr, data, size) == DSV_FAIL)
        {
	    printf ("Warning : Can not do cmMemoryWrite()\n");
	    return DSV_FAIL;
	}
	return DSV_SUCCESS;
    }

    /* hit in the D$ */

    waddr = addr & 0xfffffffc; /* word alignment */
    lindex = getFieldValue(waddr, DINDEX_R-1, 0);

    i = addr & 0x00000003;

    cptr = &D[index].dSet[set].line[lindex];
    cptr1 = (unsigned char *) &data;

    switch (size) {
      case 0: /* byte */
       cptr[i] = cptr1[3];
       break;
      case 1: /* short */
       if ((i==1) || (i==3)) {
	printf ("Error : alignment error\n");
       }
       cptr[i++] = cptr1[2];
       cptr[i] = cptr1[3];
       break;
      case 2:
       if (i != 0) {
	printf ("Error : alignment error\n");
       }
       cptr[i++] = cptr1[0];
       cptr[i++] = cptr1[1];
       cptr[i++] = cptr1[2];
       cptr[i] = cptr1[3];
       break;
      default:
       printf ("Error : size can not be greater than 32 bits\n");
       return (DSV_FAIL);
    }

    D[index].dSet[set].dirty = 1;
    if (set == 0) {
     D[index].lru = 1;
    }
    else {
     D[index].lru = 0;
    }

    return DSV_SUCCESS;
}

dCacheWrite(unsigned int addr, unsigned int data, unsigned int size)
{
   unsigned int index;
   unsigned int tag;
   unsigned char set;
   unsigned int lindex;
   unsigned int waddr;
   unsigned int i;
   unsigned char *cptr;
   unsigned char *cptr1;

   if (dCacheSelect(addr, 0, &index, &tag, &set) == DSV_FAIL) {
    return DSV_FAIL;
   }
   if ((int)index >= numOfDcacheEntries) {
    cmSetPJType(DCACHE_NC_STORE);
    if (cmMemoryWrite(addr, data, size) == DSV_FAIL) {
     printf("Warning : Can not do cmMemoryWrite()\n");
     return(DSV_FAIL);
    }
    return DSV_SUCCESS;
   }

   waddr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(waddr, DINDEX_R-1, 0);

   i = addr & 0x00000003;

   cptr = &D[index].dSet[set].line[lindex];
   cptr1 = (unsigned char *)&data;

   switch (size) {
     case 0: /* byte */
      cptr[i] = cptr1[3];
      break;
     case 1: /* short */
      if ((i==1) || (i==3)) {
       printf("Error : alignment error\n");
      }
      cptr[i++] = cptr1[2];
      cptr[i] = cptr1[3];
      break;
     case 2:
      if (i != 0) {
       printf("Error : alignment error\n");
      }
      cptr[i++] = cptr1[0];
      cptr[i++] = cptr1[1];
      cptr[i++] = cptr1[2];
      cptr[i] = cptr1[3];
      break;
     default:
      printf("Error : size can not be greater than 32 bits.\n");
      return(DSV_FAIL);
   }

   D[index].dSet[set].dirty = 1;
   if (set == 0) {
    D[index].lru = 1;
   }
   else {
    D[index].lru = 0;
   }
   
   return DSV_SUCCESS;
}

dCacheRead(unsigned int addr, unsigned int *data)
{
   unsigned int index;
   unsigned int tag;
   unsigned char set;
   unsigned int lindex;

   if (dCacheSelect(addr, 1, &index, &tag, &set) == DSV_FAIL) {
    return DSV_FAIL;
   }
   if ((int)index >= numOfDcacheEntries) {
    cmSetPJType(DCACHE_NC_LOAD);
    if (cmMemoryRead(addr, data, 2) == DSV_FAIL) {
     printf("Warning : Can not do cmMemoryRead()\n");
     return(DSV_FAIL);
    }
    return DSV_SUCCESS;
   }

   addr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(addr, DINDEX_R-1, 0);

   memcpy(data, &D[index].dSet[set].line[lindex], 4);

   return DSV_SUCCESS;
}

iCacheRead(unsigned int addr, unsigned int *data)
{
   unsigned int index;
   unsigned int tag;
   unsigned int lindex;

   if (iCacheSelect(addr, &index, &tag) == DSV_FAIL) {
    return DSV_FAIL;
   }
   if ((int)index >= numOfIcacheEntries) {
    addr = addr & 0xfffffffc; /* word alignment */
    cmSetPJType(ICACHE_NC_LOAD);
    if (cmMemoryRead(addr, data, 2) == DSV_FAIL) {
     printf("Warning : Can not do cmMemoryRead()\n");
     return(DSV_FAIL);
    }
    return DSV_SUCCESS;
   }

   addr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(addr, IINDEX_R-1, 0);

   memcpy(data, &I[index].line[lindex], 4);
   
   return DSV_SUCCESS;
}

/*
 * read icache data
 */
readIcacheData(unsigned int addr, unsigned int *data)
{
   unsigned int index;
   unsigned char set;
   unsigned int lindex;
   char *cptr;
   unsigned int i;

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);
   if ((int)index >= numOfIcacheEntries) return DSV_SUCCESS;

   addr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(addr, IINDEX_R-1, 0);


   *data = 0;
   cptr = (char *)data;
   for (i=0; i < 4; i++) {
    if (lindex < iCacheLineSize) *cptr++ = I[index].line[lindex++];
   }

   return DSV_SUCCESS;
}

/*
 * write icache data
 */
writeIcacheData(unsigned int addr, unsigned int data)
{
   unsigned int index;
   unsigned char set;
   unsigned int lindex;
   char *cptr;
   unsigned int i;

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);
   if ((int)index >= numOfIcacheEntries) return DSV_SUCCESS;

   addr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(addr, IINDEX_R-1, 0);


   cptr = (char *)&data;
   for (i=0; i < 4; i++) {
    if (lindex < iCacheLineSize) I[index].line[lindex++] = *cptr++;
   }

   return DSV_SUCCESS;
}

/*
 * write icache tag
 */
writeIcacheTag(unsigned int addr, unsigned int data)
{
   unsigned int index;
   unsigned char set;
   unsigned int itag;

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);

   if ((int)index >= numOfIcacheEntries) return DSV_SUCCESS;

   itag = getFieldValue(data, LTAG, IRTAG);
   I[index].tag = itag;

   if (data & 0x00000001) {
    I[index].valid = 1;
   }
   else {
    I[index].valid = 0;
   }

   return DSV_SUCCESS;
}

/*
 * read icache tag
 */
readIcacheTag(unsigned int addr, unsigned int *data)
{
   unsigned int index;
   unsigned char set;

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);
   if ((int)index >= numOfIcacheEntries) return DSV_SUCCESS;

   *data = 0;
   *data = I[index].tag << IRTAG;;

   if (I[index].valid == 1) {
    *data = *data | 0x1;
   }

   return DSV_SUCCESS;
}

/*
 * read dcache data
 */
readDcacheData(unsigned int addr, unsigned int *data)
{
   unsigned int index;
   unsigned char set;
   unsigned int dtag;
   unsigned int lindex;
   char *cptr;
   unsigned int i;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   if (addr & 0x80000000) {
    set = 1;
   }
   else {
    set = 0;
   }
   addr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(addr, DINDEX_R-1, 0);
   *data = 0;
   cptr = (char *)data;
   for (i=0; i < 4; i++) {
    if (lindex < dCacheLineSize) *cptr++ = D[index].dSet[set].line[lindex++];
   }

   return DSV_SUCCESS;
}
/*
 * write dcache data
 */
writeDcacheData(unsigned int addr, unsigned int data)
{
   unsigned int index;
   unsigned char set;
   unsigned int lindex;
   char *cptr;
   unsigned int i;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   if (addr & 0x80000000) {
    set = 1;
   }
   else {
    set = 0;
   }
   addr = addr & 0xfffffffc; /* word alignment */
   lindex = getFieldValue(addr, DINDEX_R-1, 0);
   cptr = (char *)&data;
   for (i=0; i < 4; i++) {
    if (lindex < dCacheLineSize) D[index].dSet[set].line[lindex++] = *cptr++;
   }

   return DSV_SUCCESS;
}

/*
 * write dcache tag
 */
writeDcacheTag(unsigned int addr, unsigned int data)
{
   unsigned int index;
   unsigned char set;
   unsigned int dtag;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   if (addr & 0x80000000) {
    set = 1;
   }
   else {
    set = 0;
   }

   dtag = getFieldValue(data, LTAG, DRTAG);
   D[index].dSet[set].tag = dtag;

   if (data & 0x00000004) {
    D[index].lru = 1;
   }
   else {
    D[index].lru = 0;
   }
   if (data & 0x00000002) {
    D[index].dSet[set].dirty = 1;
   }
   else {
    D[index].dSet[set].dirty = 0;
   }
   if (data & 0x00000001) {
    D[index].dSet[set].valid = 1;
   }
   else {
    D[index].dSet[set].valid = 0;
   }

   return DSV_SUCCESS;
}

/*
 * read dcache tag
 */
readDcacheTag(unsigned int addr, unsigned int *data)
{
   unsigned int index;
   unsigned char set;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   if (addr & 0x80000000) {
    set = 1;
   }
   else {
    set = 0;
   }

   *data = 0;
   *data = D[index].dSet[set].tag << DRTAG;

   if (D[index].lru == 1) {
    *data = *data | 0x4;
   }
   if (D[index].dSet[set].dirty == 1) {
    *data = *data | 0x2;
   }
   if (D[index].dSet[set].valid == 1) {
    *data = *data | 0x1;
   }

   return DSV_SUCCESS;
}

/*
 * index flush, invalidate, and incrment address
 * no tag check
 * 
 */
cacheIndexFlush(unsigned int addr, unsigned int incr, unsigned int *resultAddr)
{
   unsigned int index;
   unsigned int tag;
   unsigned char set;
   unsigned int *reladdr;
   unsigned int i;
   unsigned int *data;

   if (CHK_PSR_DCE == 0) goto t1;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;

   if (addr & 0x80000000) {
    set = 1;
   }
   else {
    set = 0;
   }

   if ((D[index].dSet[set].valid == 1) && (D[index].dSet[set].dirty==1)) {
    /* write back */
    reladdr = (unsigned int *)makeDAddr(D[index].dSet[set].tag, index, DINDEX_R);
    i = 0;
    data = (unsigned int *)D[index].dSet[set].line;
    cmSetPJType(WRITE_BACK);
    while (i < dCacheLineSize) {
     /* printf("write %x to %x\n", *data, reladdr); */
     if (cmMemoryWrite(reladdr, *data, 2) == DSV_FAIL) {
      printf("Warning : Can not do cmMemoryWrite()\n");
      return(DSV_FAIL);
     }
     i += 4;
     data += 1;
     reladdr += 1;
    }
   }

   D[index].dSet[set].valid = 0;
   /* D[index].dSet[set].dirty = 0; */
   D[index].lru = set;

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);

   if (index >= numOfIcacheEntries) return DSV_SUCCESS;

   I[index].valid = 0;

t1:

   *resultAddr = addr + incr;

   return(DSV_SUCCESS);
}

/* flush line containing addr from I$ if present */
static int ICacheFlush (unsigned int addr)

{
   unsigned int index;

   if (CHK_PSR_ICE == 0) return(DSV_SUCCESS);

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);

   if ((int)index >= numOfIcacheEntries) return DSV_SUCCESS;

   I[index].valid = 0;

   return(DSV_SUCCESS);
}

/*
 * flush I$, D$, invalidate, and incrment address
 * 
 */
cacheFlush(unsigned int addr, unsigned int incr, unsigned int *resultAddr)
{
   unsigned int index;
   unsigned int tag;
   unsigned char set;
   unsigned int *reladdr;
   unsigned int i;
   unsigned int *data;

   *resultAddr = addr + incr;

   if (CHK_PSR_DCE == 0) goto t1;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   tag = getFieldValue(addr, LTAG, DRTAG);

   if ((D[index].dSet[0].tag == tag) && (D[index].dSet[0].valid == 1)) {
    set = 0;
   }
   else if ((D[index].dSet[1].tag == tag) && (D[index].dSet[1].valid == 1)) {
    set = 1;
   }
   else {
    /* do nothing if tag is not match */
    goto t1;
   }

   if ((D[index].dSet[set].valid == 1) && (D[index].dSet[set].dirty==1)) {
    /* write back */
    reladdr = (unsigned int *)makeDAddr(D[index].dSet[set].tag, index, DINDEX_R);
    i = 0;
    data = (unsigned int *)D[index].dSet[set].line;
    cmSetPJType(WRITE_BACK);
    while (i < dCacheLineSize) {
     /* printf("write %x to %x\n", *data, reladdr); */
     if (cmMemoryWrite(reladdr, *data, 2) == DSV_FAIL) {
      printf("Warning : Can not do cmMemoryWrite()\n");
      return(DSV_FAIL);
     }
     i += 4;
     data += 1;
     reladdr += 1;
    }
   }

   D[index].dSet[set].valid = 0;
   D[index].lru = set;

t1:

   ICacheFlush (addr);

   return(DSV_SUCCESS);
}

/*
 * invalidate, and incrment address
 * 
 */
cacheInvalidate (unsigned int addr, unsigned int incr, unsigned int *resultAddr)
{
   unsigned int index;
   unsigned int tag;
   unsigned char set;

   *resultAddr = addr + incr;

   if (CHK_PSR_DCE == 0) goto t1;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   tag = getFieldValue(addr, LTAG, DRTAG);

   if ((D[index].dSet[0].tag == tag) && (D[index].dSet[0].valid == 1)) {
    set = 0;
   }
   else if ((D[index].dSet[1].tag == tag) && (D[index].dSet[1].valid == 1)) {
    set = 1;
   }
   else {
    /* do nothing if tag is not match */
    goto t1;
   }

   D[index].dSet[set].valid = 0;
   D[index].lru = set;

t1:

   if (CHK_PSR_ICE == 0) return(DSV_SUCCESS);

   index = getFieldValue(addr, IINDEX_L, IINDEX_R);

   if ((int)index >= numOfIcacheEntries) return DSV_SUCCESS;

   tag = getFieldValue(addr, LTAG, IRTAG);

   
   I[index].valid = 0;
   I[index].tag = 0;

   return(DSV_SUCCESS);
}

/*
 * If valid and dirty, write back
 * set line to valid, dirty, and zero all the data
 */
dCacheZeroLine(unsigned int addr)
{
   unsigned int index;
   unsigned int tag;
   unsigned char set;
   unsigned int *reladdr;
   unsigned int i;
   unsigned int *data;
   int needwb = 0;

   index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)index >= numOfDcacheEntries) return DSV_SUCCESS;
   tag = getFieldValue(addr, LTAG, DRTAG);

   if ((D[index].dSet[0].tag == tag) && (D[index].dSet[0].valid == 1)) {
    set = 0;
   }
   else if ((D[index].dSet[1].tag == tag) && (D[index].dSet[1].valid == 1)) {
    set = 1;
   }
   else {
    needwb = 1;
    set = D[index].lru;
   }

   if ((needwb == 1) && 
       (D[index].dSet[set].valid == 1) &&
       (D[index].dSet[set].dirty==1)) {
    /* write back */
    reladdr = (unsigned int *)makeDAddr(D[index].dSet[set].tag, index, DINDEX_R);
    i = 0;
    data = (unsigned int *)D[index].dSet[set].line;
    cmSetPJType(WRITE_BACK);
    while (i < dCacheLineSize) {
     /* printf("write %x to %x\n", *data, reladdr); */
     if (cmMemoryWrite(reladdr, *data, 2) == DSV_FAIL) {
      printf("Warning : Can not do cmMemoryWrite()\n");
      return(DSV_FAIL);
     }
     i += 4;
     data += 1;
     reladdr += 1;
    }
   }

   memset(D[index].dSet[set].line, 0, sizeof(char)*dCacheLineSize);

   D[index].dSet[set].tag = tag;
   D[index].dSet[set].valid = 1;
   D[index].dSet[set].dirty = 1;
   if (set == 1) {
    D[index].lru = 0;
   }
   else {
    D[index].lru = 1;
   }

   return(DSV_SUCCESS);
}

/*
 * initialize I$, isize is encoded, NOT
directly size of the cache in KB (see switch below)
 */
icacheInit(unsigned int iSize)
{
   static int icache_init = 0;
   unsigned int i;
   unsigned int j;
   unsigned int ILINESIZE;

   currentISize = iSize;
   if (icache_init == 1) {
    if (I != NULL) free(I);
   }

   ILINESIZE = (proc_type == maya) ? MAYA_ILINESIZE : PICO_ILINESIZE;
   IINDEX_R = (proc_type == maya) ? MAYA_ILINESIZE : PICO_ILINESIZE;

   iCacheLineSize = 1 << ILINESIZE;
 
   switch (iSize) {
     case 0: /* 0k */
	numOfIcacheEntries = -1;
	iSizeK = 0;
	IINDEX_L = 11;
	break;
     case 1: /* 1k */
	numOfIcacheEntries = 1 << (10 - ILINESIZE);
	iSizeK = 1;
	IINDEX_L = 9;
	break;
     case 2: /* 2k */
	numOfIcacheEntries = 1 << (11 - ILINESIZE);
	iSizeK = 2;
	IINDEX_L = 10;
	break;
     case 3: /* 4k */
	numOfIcacheEntries = 1 << (12 - ILINESIZE);
	iSizeK = 4;
	IINDEX_L = 11;
	break;
     case 4: /* 8k */
	numOfIcacheEntries = 1 << (13 - ILINESIZE);
	iSizeK = 8;
	IINDEX_L = 12;
	break;
     case 5: /* 16k */
	numOfIcacheEntries = 1 << (14 - ILINESIZE);
	iSizeK = 16;
	IINDEX_L = 13;
	break;
     default:
	printf("ERROR : unknown I$ size\n");
	return(DSV_FAIL);
   }

   IRTAG = IINDEX_L + 1;

   if (iSize > 0) {
    I = (iCacheEntry *)malloc(sizeof(iCacheEntry)*numOfIcacheEntries);
    if (I == 0) { 
     printf("ERROR : out of memory\n");
     return(DSV_FAIL);
    }
   }
   else {
    I = NULL;
   }

   if (I != NULL) {
    for (i=0; i < numOfIcacheEntries; i++) {
     I[i].tag = 0;
     memset(I[i].line, 0, sizeof(char)*iCacheLineSize);
     I[i].valid = 0;
    }
   }


   icache_init = 1;
   return(DSV_SUCCESS);
}

/*
 * initialize D$. dsize is encoded, are NOT
directly size of the cache in KB (see switch below)
 */
dcacheInit(unsigned int dSize)
{
   static int dcache_init = 0;
   unsigned int i;
   unsigned int j;
   
   currentDSize = dSize;
   if (dcache_init == 1) {
    if (D != NULL) free(D);
   }

   dCacheLineSize = 1 << DLINESIZE;
   switch (dSize) {
     case 0: /* 0k */
	numOfDcacheEntries = -1;
	dSizeK = 0;
	DINDEX_L = 11;
	break;
     case 1: /* 1k */
	numOfDcacheEntries = 1 << (10 - DLINESIZE);
	dSizeK = 1;
	DINDEX_L = 8;
	break;
     case 2: /* 2k */
	numOfDcacheEntries = 1 << (11 - DLINESIZE);
	dSizeK = 2;
	DINDEX_L = 9;
	break;
     case 3: /* 4k */
	numOfDcacheEntries = 1 << (12 - DLINESIZE);
	dSizeK = 4;
	DINDEX_L = 10;
	break;
     case 4: /* 8k */
	numOfDcacheEntries = 1 << (13 - DLINESIZE);
	dSizeK = 8;
	DINDEX_L = 11;
	break;
     case 5: /* 16k */
	numOfDcacheEntries = 1 << (14 - DLINESIZE);
	dSizeK = 16;
	DINDEX_L = 12;
	break;
     default:
	printf("ERROR : unknown D$ size\n");
	return(DSV_FAIL);
   }

   DRTAG = DINDEX_L + 1;

   if (dSize > 0) {
    /* two way */
    numOfDcacheEntries = numOfDcacheEntries >> 1;
    D = (dCacheEntry *)malloc(sizeof(dCacheEntry)*numOfDcacheEntries);
    if (D == 0) { 
     printf("ERROR : out of memory\n");
     return(DSV_FAIL);
    }
   }
   else {
    D = NULL;
   }

   if (D != NULL) {
    for (i=0; i < numOfDcacheEntries; i++) {
     for (j=0; j < 2; j++) {
      D[i].dSet[j].tag = 0;
      memset(D[i].dSet[j].line, 0, sizeof(char)*dCacheLineSize);
      D[i].dSet[j].valid = 0;
      D[i].dSet[j].dirty = 0;
     }
     D[i].lru = 0;
    }
   }

   dcache_init = 1;
   return(DSV_SUCCESS);
}


dCacheDisplayLine(unsigned int line, FILE *fp, unsigned int header)
{
   unsigned int i, j;

   if (line >= numOfDcacheEntries) {
    fprintf(fp, "ERROR : line address %d out of bound %d\n", line, dCacheLineSize);
    return(DSV_FAIL);
   }

   /* lineAddress tag line valid dirty lru */

   if (header) {
    fprintf(fp, "Line             : Tag      Data                             v d l\n");
   }

   for (j=0; j < 2; j++) {
    fprintf(fp, "Set 0x%03x, Way %d : ", line, j);
    fprintf(fp, "0x%06x ", D[line].dSet[j].tag);
    for (i=0; i < dCacheLineSize; i++) {
     fprintf(fp, "%02x", D[line].dSet[j].line[i]);
    }
    fprintf(fp, " ");

    fprintf(fp, "%01x ", D[line].dSet[j].valid);
    fprintf(fp, "%01x ", D[line].dSet[j].dirty);
    if (j == 0) 
        fprintf(fp, "%01x ", D[line].lru);
    fprintf (fp, "\n");
   }

   fprintf(fp, "\n");

   return(DSV_SUCCESS);
}

iCacheDisplayLine(unsigned int line, FILE *fp, unsigned int header)
{
   unsigned int i, j;

   if (line >= numOfIcacheEntries) {
    fprintf(fp, "ERROR : line address %d out of bound %d\n", line, iCacheLineSize);
    return(DSV_FAIL);
   }

   /* lineAddress tag line valid */

   if (header) {
    fprintf(fp, "Line   : Tag      Data%13c", ' ');

    if (proc_type == maya)
        fprintf (fp, "%16c", ' ');  /* extra space for maya */

    fprintf (fp, "v\n");
   }

   fprintf(fp, "0x%04x : ", line);
   fprintf(fp, "0x%06x ", I[line].tag);
   for (i=0; i < iCacheLineSize; i++) {
    fprintf(fp, "%02x", I[line].line[i]);
   }
   fprintf(fp, " ");

   fprintf(fp, "%01x", I[line].valid);

   fprintf(fp, "\n");

   return(DSV_SUCCESS);
}

dCacheDisplayAll(unsigned int f, unsigned int t, FILE *fp)
{
   unsigned int i;

   for (i=f; i < t; i++) {
    if (i == f) {
     dCacheDisplayLine(i, fp, 1);
    }
    else {
     dCacheDisplayLine(i, fp, 0);
    }
   }

   return(DSV_SUCCESS);
}

iCacheDisplayAll(unsigned int f, unsigned int t, FILE *fp)
{
   unsigned int i;

   for (i=f; i < t; i++) {
    if (i == f) {
     iCacheDisplayLine(i, fp, 1);
    }
    else {
     iCacheDisplayLine(i, fp, 0);
    }
   }

   return(DSV_SUCCESS);
}

dCacheSelect(unsigned int addr, unsigned int is_read, unsigned int *index, unsigned int *tag, unsigned char *set)
{
   unsigned int *reladdr;
   unsigned int ltag;
   unsigned int *data;
   unsigned int i;

   if (is_read)
       dcache_reads = ll_add (dcache_reads, 1LL);
   else
       dcache_writes = ll_add (dcache_writes, 1LL);

   *index = getFieldValue(addr, DINDEX_L, DINDEX_R);
   if ((int)*index >= numOfDcacheEntries) return DSV_SUCCESS;
    ltag = getFieldValue(addr, LTAG, DRTAG);

   if ((D[*index].dSet[0].valid == 1) && (D[*index].dSet[0].tag == ltag)) {
    *set = 0;
   }
   else if ((D[*index].dSet[1].valid == 1) && (D[*index].dSet[1].tag == ltag)) {
    *set = 1;
   }
   else {
    *set = D[*index].lru;
     if (is_read)
         dcache_read_misses = ll_add (dcache_read_misses, 1LL);
     else
         dcache_write_misses = ll_add (dcache_write_misses, 1LL);
   }

   if (tag != NULL) {
    *tag = ltag;

    if ((ltag != D[*index].dSet[*set].tag) &&
        (D[*index].dSet[*set].valid == 1) && (D[*index].dSet[*set].dirty==1)) {
     /* write back */
     if (is_read)
         dcache_read_misses_causing_wb = ll_add (dcache_read_misses_causing_wb, 1LL);
     else
         dcache_write_misses_causing_wb = ll_add (dcache_write_misses_causing_wb, 1LL);
     reladdr = (unsigned int *)makeDAddr(D[*index].dSet[*set].tag, *index, DINDEX_R);
     i = 0;
     data = (unsigned int *)D[*index].dSet[*set].line;
     cmSetPJType(WRITE_BACK);
     while (i < dCacheLineSize) {
      /* printf("write %x to %x\n", *data, reladdr); */
      if (cmMemoryWrite(reladdr, *data, 2) == DSV_FAIL) {
       printf("Warning : Can not do cmMemoryWrite()\n");
       return(DSV_FAIL);
      }
      i += 4;
      data += 1;
      reladdr += 1;
     }
     D[*index].dSet[*set].valid = 0;
     D[*index].dSet[*set].dirty = 1;
    }

    if ((ltag != D[*index].dSet[*set].tag) || (D[*index].dSet[*set].valid == 0)) {
     /* read the new line */

     D[*index].dSet[*set].tag = ltag;

     reladdr = (unsigned int *)makeDAddr(ltag, *index, DINDEX_R);
     i = 0;
     data = (unsigned int *)D[*index].dSet[*set].line;
     cmSetPJType(DCACHE_LOAD);
     while (i < dCacheLineSize) {
      /* printf("read %x from %x\n", *data, reladdr); */
      if (cmMemoryRead(reladdr, data, 2) == DSV_FAIL) {
       printf("Warning : Can not do cmMemoryRead()\n");
       
       /* reset the valid bit first before bailing out */
       D[*index].dSet[*set].valid = 0; 

       return(DSV_FAIL);
      }
      i += 4;
      data += 1;
      reladdr += 1;
     }

     D[*index].dSet[*set].valid = 1;
     D[*index].dSet[*set].dirty = 0;
     if (*set == 0) {
      D[*index].lru = 1;
     }
     else {
      D[*index].lru = 0;
     }

    }

   }

   return DSV_SUCCESS;
}

iCacheSelect(unsigned int addr, unsigned int *index, unsigned int *tag)
{
   unsigned int *reladdr;
   unsigned int *data;
   unsigned int i;

   *index = getFieldValue(addr, IINDEX_L, IINDEX_R);

   if ((int)*index >= numOfIcacheEntries) return DSV_SUCCESS;

   if (tag != NULL) {
    *tag = getFieldValue(addr, LTAG, IRTAG);

     if ((I[*index].tag != *tag) || (I[*index].valid==0)) {
      /* read the line in */

      reladdr = (unsigned int *)makeIAddr(*tag, *index, IINDEX_R);
      i = 0;
      data = (unsigned int *)I[*index].line;
      cmSetPJType(ICACHE_LOAD);
      while (i < iCacheLineSize) {
       /* printf("read %x from %x\n", *data, reladdr); */
       if (cmMemoryRead(reladdr, data, 2) == DSV_FAIL) {
        printf("Warning : Can not do cmMemoryRead()\n");
        return(DSV_FAIL);
       }
       i += 4;
       data += 1;
       reladdr += 1;
      }

      I[*index].valid = 1;
      I[*index].tag = *tag;
    }
   }

   return DSV_SUCCESS;
}

debug_dCacheRead(unsigned int addr, unsigned int *data)

{
    unsigned int tag, index, lindex;

    index = getFieldValue(addr, DINDEX_L, DINDEX_R);
    if ((int)index >= numOfDcacheEntries) {
     *data = cmPeek (addr);
     return DSV_SUCCESS;
    }
    tag = getFieldValue(addr, LTAG, DRTAG);
    lindex = getFieldValue(addr, DINDEX_R-1, 0);

    if ((D[index].dSet[0].valid == 1) && (D[index].dSet[0].tag == tag)) 
    {
	/* hit in way 0 */
	memcpy(data, &D[index].dSet[0].line[lindex], 4);
    }
    else 
    if ((D[index].dSet[1].valid == 1) && (D[index].dSet[1].tag == tag)) 
    {
	/* hit in way 1 */
	memcpy(data, &D[index].dSet[1].line[lindex], 4);
    }
    else
	*data = cmPeek (addr);

    return DSV_SUCCESS;
}

cacheDSizeK()
{
   return dSizeK;
}

cacheISizeK()
{
   return iSizeK;
}

/* checkpointing of the i & d caches.
format written into the checkpoint file:
last_intr_set, next_intr_id, MAX_INTRS, the entire intrs array */

int cache_checkpoint (CPR_REQUEST_T req, FILE *fp)

{
    unsigned int i;

    switch (req)
    {
      case CPR_QUERY:
        break;

      case CPR_CHECKPOINT:
        CHECKING_FWRITE (&currentISize, sizeof (currentISize), 1, fp)
        CHECKING_FWRITE (&currentDSize, sizeof (currentDSize), 1, fp)

        CHECKING_FWRITE (&numOfIcacheEntries, sizeof (numOfIcacheEntries), 1, fp)
        CHECKING_FWRITE (&numOfDcacheEntries, sizeof (numOfDcacheEntries), 1, fp)
        CHECKING_FWRITE (&iCacheLineSize, sizeof (iCacheLineSize), 1, fp)
        CHECKING_FWRITE (&dCacheLineSize, sizeof (dCacheLineSize), 1, fp)
        CHECKING_FWRITE (&iSizeK, sizeof (iSizeK), 1, fp)
        CHECKING_FWRITE (&dSizeK, sizeof (dSizeK), 1, fp)

        CHECKING_FWRITE (I, sizeof (iCacheEntry), numOfIcacheEntries, fp)
        CHECKING_FWRITE (D, sizeof (dCacheEntry), numOfDcacheEntries, fp)

        break;

      case CPR_RESTART:
        CHECKING_FREAD (&currentISize, sizeof (currentISize), 1, fp)
        CHECKING_FREAD (&currentDSize, sizeof (currentDSize), 1, fp)

        /* we reinitialise the cache at this point because the cache sizes
           read from the checkpoint file may be different from the current 
           sizes */
          
        icacheInit (currentISize);
        dcacheInit (currentDSize);

        CHECKING_FREAD (&numOfIcacheEntries, sizeof (numOfIcacheEntries), 1, fp)
        CHECKING_FREAD (&numOfDcacheEntries, sizeof (numOfDcacheEntries), 1, fp)
        CHECKING_FREAD (&iCacheLineSize, sizeof (iCacheLineSize), 1, fp)
        CHECKING_FREAD (&dCacheLineSize, sizeof (dCacheLineSize), 1, fp)
        CHECKING_FREAD (&iSizeK, sizeof (iSizeK), 1, fp)
        CHECKING_FREAD (&dSizeK, sizeof (dSizeK), 1, fp)

        CHECKING_FREAD (I, sizeof (iCacheEntry), numOfIcacheEntries, fp)
        CHECKING_FREAD (D, sizeof (dCacheEntry), numOfDcacheEntries, fp)

        break;
    }

    return 0;
}

