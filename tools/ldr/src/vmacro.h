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




#ifndef _VMACRO_H_
#define _VMACRO_H_

#pragma ident "@(#)vmacro.h 1.6 Last modified 10/06/98 11:34:27 SMI"

#define CHECK_VEC(vec_size, arg, exprinfo, error, routine_name) \
    tf_exprinfo(++arg, &exprinfo); \
    if (exprinfo.expr_type != tf_readwrite) { \
	int vtime = tf_gettime(); \
	error = TRUE; \
	tf_error("<%d> decaf cm ERROR [%s]: Wrong argument type #%d", \
	    vtime, routine_name, arg); \
    } \
    if (exprinfo.expr_vec_size != (vec_size)) { \
	int vtime = tf_gettime(); \
	error = TRUE; \
	tf_error("<%d> decaf cm ERROR [%s]: Error in argument #%d", \
	    vtime, routine_name, arg); \
	io_printf("\tMust be a %d bit vector\n", (vec_size)); \
    } \

#define CHECK_INT(arg, exprinfo, error, routine_name) \
    tf_exprinfo(++arg, &exprinfo); \
    if (exprinfo.expr_type != tf_readwrite) { \
	int vtime = tf_gettime(); \
	error = TRUE; \
	tf_error("<%d> decaf cm ERROR [%s]: Wrong argument type #%d", \
	    vtime, routine_name, arg); \
    } \
    if (exprinfo.expr_vec_size != 32) { \
	int vtime = tf_gettime(); \
	error = TRUE; \
	tf_error("CC ERROR [%s]: Error in argument #%d", \
		 routine_name, arg); \
	io_printf("\tMust be an int\n"); \
    } \

#define CHECK_STRING(arg, exprinfo, error, routine_name) \
    tf_exprinfo(++arg, &exprinfo); \
    if ((exprinfo.expr_type != tf_readwrite) && \
	(exprinfo.expr_type != tf_string)) { \
	int vtime = tf_gettime(); \
	error = TRUE; \
	tf_error("<%d> decaf cm ERROR [%s]: Wrong argument type #%d", \
	    vtime, routine_name, arg); \
    } \

/*
 * GET_INT - macro to extract a Verilog integer.  An error
 * is reported if "unknown" bits are detected.
 */
#define GET_INT(i, expr_value_p, vec_name, error_buffer, routine_name) \
    { \
	(i) = (expr_value_p)->avalbits; \
     } \

#define MASK(size)	(((unsigned) 0xffffffff) >> (32 - (size)))

/* GET_VEC - macro to extract a word of a Verilog vector into an integer */
#define GET_VEC(vec, vec_size, expr_value_p, vec_name, error_buffer, routine_name) \
    { \
        unsigned int	mask_in_macro; \
	if ((vec_size) <= 32) { \
	    mask_in_macro = MASK(vec_size); \
	    vec = ((expr_value_p)->avalbits & mask_in_macro); \
	    if ((expr_value_p)->bvalbits & mask_in_macro) { \
		int vtime = tf_gettime(); \
		sprintf(error_buffer, "\"unknown\" bits (%x) found in %s", \
		    (expr_value_p)->bvalbits & mask_in_macro, (vec_name)); \
		tf_error("<%d> decaf cm ERROR [%s] -- %s", \
		    vtime, routine_name, error_buffer); \
		error = TRUE; \
		return DSV_FAIL; \
	    } \
	} else { \
	 int vtime = tf_gettime(); \
	 sprintf(error_buffer, "size > 32 found in %s", vec_name); \
	 tf_error("<%d> decaf cm ERROR [%s] -- %s",  \
                        vtime, routine_name, error_buffer); \
	 error = TRUE; \
	 return DSV_FAIL; \
	} \
     }

/* PUT_VEC - macro to assign an int into a word of a Verilog vector. */
#define PUT_VEC(vec, vec_size, expr_value_p, arg) \
    { \
	unsigned int	mask_in_macro; \
	(expr_value_p)->avalbits = vec; \
	tf_propagatep(arg); \
    }

#define PUT_INT(i, expr_value_p, arg) \
    { \
	(expr_value_p)->avalbits = i; \
        tf_propagatep(arg); \
    }

#endif /* _VMACRO_H_ */
