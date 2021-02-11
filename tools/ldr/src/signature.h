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




#ifndef _SIGNATURE_H_
#define _SIGNATURE_H_

#pragma ident "@(#)signature.h 1.6 Last modified 10/06/98 11:34:19 SMI"

/*
 * The keyletters used in type signatures
 */

#define SIGNATURE_ANY		'A'
#define SIGNATURE_ARRAY		'['
#define SIGNATURE_BYTE		'B'
#define SIGNATURE_CHAR		'C'
#define SIGNATURE_CLASS		'L'
#define SIGNATURE_ENDCLASS	';'
#define SIGNATURE_ENUM		'E'
#define SIGNATURE_FLOAT		'F'
#define SIGNATURE_DOUBLE        'D'
#define SIGNATURE_FUNC		'('
#define SIGNATURE_ENDFUNC	')'
#define SIGNATURE_INT		'I'
#define SIGNATURE_LONG		'J'
#define SIGNATURE_SHORT		'S'
#define SIGNATURE_VOID		'V'
#define SIGNATURE_BOOLEAN	'Z'

#define SIGNATURE_ANY_STRING		"A"
#define SIGNATURE_ARRAY_STRING		"["
#define SIGNATURE_BYTE_STRING		"B"
#define SIGNATURE_CHAR_STRING		"C"
#define SIGNATURE_CLASS_STRING		"L"
#define SIGNATURE_ENDCLASS_STRING	";"
#define SIGNATURE_ENUM_STRING		"E"
#define SIGNATURE_FLOAT_STRING		"F"
#define SIGNATURE_DOUBLE_STRING       	"D"
#define SIGNATURE_FUNC_STRING		"("
#define SIGNATURE_ENDFUNC_STRING	")"
#define SIGNATURE_INT_STRING		"I"
#define SIGNATURE_LONG_STRING		"J"
#define SIGNATURE_SHORT_STRING		"S"
#define SIGNATURE_VOID_STRING		"V"
#define SIGNATURE_BOOLEAN_STRING	"Z"

#endif /* !_SIGNATURE_H_ */
