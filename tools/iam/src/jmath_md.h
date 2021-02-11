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




#ifndef _JMATH_MD_H_
#define _JMATH_MD_H_

#pragma ident "@(#)jmath_md.h 1.4 Last modified 10/06/98 11:36:56 SMI"

#ifndef hpux
#include <ieeefp.h>
#endif

#include <math.h>

#define DREMAINDER(a,b) fmod(a,b)
#define IEEEREM(a,b) remainder(a,b)

#endif /* _JMATH_MD_H_ */
