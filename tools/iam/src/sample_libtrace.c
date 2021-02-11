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



#include "stdio.h"
#include "tracing.h"

pjsim_trace_init ()

{
    fprintf (stderr, "pjsim_trace_init called\n");
}

pjsim_trace_finalize ()

{
    fprintf (stderr, "pjsim_trace_finalize called\n");
}

pjsim_trace_emit_insn_record (insn_trace_record_t insn_trace_record)

{
    if (insn_trace_record.trap_taken)
	{
	    fprintf (stderr, "Trap taken, type %d\n", insn_trace_record.trap_type);
	}
	else
	{
	    fprintf (stderr, "Old pc = 0x%x, Old Optop = 0x%x, New pc = 0x%x, New Optop = 0x%x\n", insn_trace_record.begin_pc, insn_trace_record.begin_optop, insn_trace_record.end_pc, insn_trace_record.end_optop);
	}
}

pjsim_trace_emit_mem_record (mem_trace_record_t mem_trace_record)

{
    if (mem_trace_record.rnotw)
	{
	    fprintf (stderr, "Mem read: address 0x%x, tag '%c'\n", mem_trace_record.addr, mem_trace_record.tag);
	}
	else
	{
	    fprintf (stderr, "Mem write: address 0x%x, size %d, data 0x%x, tag '%c'\n", mem_trace_record.addr, mem_trace_record.size, mem_trace_record.data, mem_trace_record.tag);
	}
}

