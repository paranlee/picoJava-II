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

 ***   Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 *****************************************************************/




#ifndef _RES_H_
#define _RES_H_

#pragma ident "@(#)res.h 1.6 Last modified 10/06/98 11:34:17 SMI"

char *getFieldSignature(cp_item_type *constant_pool, unsigned index);
void changeOpcodeToQuick(ClassClass *cb);
void resolveConstantPool(ClassClass *cb);
void resolveMethods(ClassClass *cb, ClassClass *super);
void resolveMethods(ClassClass *cb, ClassClass *super);

#endif /* _RES_H_ */
