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




/*
 * Solaris-dependent types for Green threads
 */

#ifndef _SOLARIS_TYPES_MD_H_
#define _SOLARIS_TYPES_MD_H_

#pragma ident "@(#)typedefs_md.h 1.7 Last modified 01/14/99 12:20:57 SMI"

#include <sys/types.h>
#include <sys/stat.h>
#include "bool.h"

#ifndef	_UINT64_T
#define	_UINT64_T
typedef unsigned long long uint64_t;
#define _UINT32_T
typedef unsigned int uint32_t;
#endif

#ifndef	_INT64_T
#define	_INT64_T
typedef long long int64_t;
#define _INT32_T
typedef int int32_t;
#endif


/* use these macros when the compiler supports the long long type */

#define ll_high(a)	((long)((a)>>32))
#define ll_low(a)	((long)(a))
#define int2ll(a)	((int64_t)(a))
#define ll2int(a)	((int)(a))
#define ll_add(a, b)	((a) + (b))
#define ll_and(a, b)	((a) & (b))
#define ll_div(a, b)	((a) / (b))
#define ll_mul(a, b)	((a) * (b))
#define ll_neg(a)	(-(a))
#define ll_not(a)	(~(a))
#define ll_or(a, b)	((a) | (b))
#define ll_shl(a, n)	((a) << (n))
#define ll_shr(a, n)	((a) >> (n))
#define ll_sub(a, b)	((a) - (b))
#define ll_ushr(a, n)	((unsigned long long)(a) >> (n))
#define ll_xor(a, b)	((a) ^ (b))
#define uint2ll(a)	((uint64_t)(unsigned long)(a))
#define ll_rem(a,b)	((a) % (b))

#define float2ll(f)	((int64_t) (f))
#define ll2float(a)	((float) (a))
#define ll2double(a)	((double) (a))
#define double2ll(f)	((int64_t) (f))

/* comparison operators */
#define ll_ltz(ll)	((ll)<0)
#define ll_gez(ll)	((ll)>=0)
#define ll_eqz(a)	((a) == 0)
#define ll_eq(a, b)	((a) == (b))
#define ll_ne(a,b)	((a) != (b))
#define ll_ge(a,b)	((a) >= (b))
#define ll_le(a,b)	((a) <= (b))
#define ll_lt(a,b)	((a) < (b))
#define ll_gt(a,b)	((a) > (b))

#define ll_zero_const	((int64_t) 0)
#define ll_one_const	((int64_t) 1)

extern void ll2str(int64_t a, char *s, char *limit);

#endif /* !_SOLARIS_TYPES_MD_H_ */
