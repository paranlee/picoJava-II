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




#ifndef	_TYPEDEFS_H_
#define	_TYPEDEFS_H_

#pragma ident "@(#)typedefs.h 1.7 Last modified 02/26/99 18:36:35 SMI"

#include "typedefs_md.h"	/* for int64_t */

/*
 * Macros to deal with the JavaVM's stack alignment. Many machines
 * require doublewords to be double aligned.  This union is used by
 * code in math.h as a more portable way do alingnment on machines
 * that require it.  This union and the macros that use it came from
 * Netscape.
 */

typedef union Java8Str {
    int32_t x[2];
    double d;
    int64_t l;
    void *p;
} Java8;


#ifndef HAVE_ALIGNED_LONGLONGS
#define GET_INT64(_t,_addr) ( ((_t).x[0] = ((int32_t*)(_addr))[0]), \
                              ((_t).x[1] = ((int32_t*)(_addr))[1]), \
                              (_t).l )
#define SET_INT64(_t, _addr, _v) ( (_t).l = (_v),                    \
                                   ((int32_t*)(_addr))[0] = (_t).x[0], \
                                   ((int32_t*)(_addr))[1] = (_t).x[1] )
#else
#define GET_INT64(_t,_addr) (*(int64_t*)(_addr))
#define SET_INT64(_t, _addr, _v) (*(int64_t*)(_addr) = (_v))
#endif

/* If double's must be aligned on doubleword boundaries then define this */
#ifdef HAVE_ALIGNED_DOUBLES
#define GET_DOUBLE(_t,_addr) ( ((_t).x[0] = ((int32_t*)(_addr))[0]), \
                               ((_t).x[1] = ((int32_t*)(_addr))[1]), \
                               (_t).d )
#define SET_DOUBLE(_t, _addr, _v) ( (_t).d = (_v),                    \
                                    ((int32_t*)(_addr))[0] = (_t).x[0], \
                                    ((int32_t*)(_addr))[1] = (_t).x[1] )
#else
#define GET_DOUBLE(_t,_addr) (*(double*)(_addr))
#define SET_DOUBLE(_t, _addr, _v) (*(double*)(_addr) = (_v))
#endif

/* If pointers are 64bits then define this */
#ifdef HAVE_64BIT_POINTERS
#define GET_HANDLE(_t,_addr) ( ((_t).x[0] = ((int32_t*)(_addr))[0]), \
                               ((_t).x[1] = ((int32_t*)(_addr))[1]), \
                               (_t).p )
#define SET_HANDLE(_t, _addr, _v) ( (_t).p = (_v),                    \
                                    ((int32_t*)(_addr))[0] = (_t).x[0], \
                                    ((int32_t*)(_addr))[1] = (_t).x[1] )
#else
#define GET_HANDLE(_t,_addr) (*(JHandle*)(_addr))
#define SET_HANDLE(_t, _addr, _v) (*(JHandle*)(_addr) = (_v))
#endif


#endif	/* !_TYPEDEFS_H_ */
