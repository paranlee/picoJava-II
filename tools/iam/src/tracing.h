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




#ifndef _TRACING_H_
#define _TRACING_H_

#pragma ident "@(#)tracing.h 1.6 Last modified 10/06/98 11:37:14 SMI"

typedef struct {
unsigned int trap_taken, trap_type;
unsigned int begin_pc, begin_optop, end_pc, end_optop;
unsigned int begin_vars, end_vars;
unsigned char insnbyte0, insnbyte1;
unsigned int top0, top1, top2, top3; /* top 4 entries in S$ at begin of this insn */
unsigned int opcode, ext_opcode;
} insn_trace_record_t;

typedef struct {
unsigned int addr, data, rnotw, size;
unsigned char tag;
} mem_trace_record_t;

/* this function is called for init - loads the functions from the
DL and sets up the fn. ptrs etc */

extern int init_trace_lib ();

/* pointers to interface funcs for tracing, dynamically loaded
   from the library in env-var PJSIM_TRACE_LIB */

extern int (*p_pjsim_trace_init) ();
extern int (*p_pjsim_trace_finalize) ();
extern int (*p_pjsim_trace_emit_insn_record) (insn_trace_record_t);
extern int (*p_pjsim_trace_emit_mem_record) (mem_trace_record_t);

#endif /* _TRACING_H_ */
