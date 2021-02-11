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




static char *sccsid = "@(#)tracing.c 1.4 Last modified 10/06/98 11:37:13 SMI";

#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>

#include "dprint.h"
#include "tracing.h"

/* function pointers */
int (*p_pjsim_trace_init) () = NULL;
int (*p_pjsim_trace_finalize) () = NULL;
int (*p_pjsim_trace_emit_insn_record) (insn_trace_record_t) = NULL;
int (*p_pjsim_trace_emit_mem_record) (mem_trace_record_t) = NULL;

static void *get_symbol_address (void *obj_handle, const char *filename, 
                                 const char *symbol_name)
{
    void *addr = dlsym(obj_handle, symbol_name);
    
    if (addr)
        return (addr);
        
    WARN (("\nno symbol \"%s\" in PJSIM_TRACE_LIB \"%s\": %s\n", symbol_name, filename, dlerror()));
    return (NULL);
}

int init_trace_lib ()

{
    const char *filename = getenv("PJSIM_TRACE_LIB");
    void *obj_handle;
        
    if (!filename)
        return (1);  /* success (nothing to do) */
            
    printf ("PJSIM_TRACE_LIB set, loading pjsim tracing functions from %s ... ", filename);

    /* Open the specified dynamic object. */
    obj_handle = dlopen(filename, RTLD_NOW);
    if (!obj_handle) 
	{
        WARN (("failed dlopen of PJSIM_TRACE_LIB \"%s\": %s\n", filename, dlerror()));
	    WARN (("unable to load trace library ... continuing without tracing functionality\n"));

        return (0);  /* failure */
    }
    
    /* Get the function addresses. */
    p_pjsim_trace_init = (int (*)())
        get_symbol_address(obj_handle, filename, "pjsim_trace_init");
    p_pjsim_trace_finalize = (int (*)())
        get_symbol_address(obj_handle, filename, "pjsim_trace_finalize");
    p_pjsim_trace_emit_insn_record = (int (*)(insn_trace_record_t))
        get_symbol_address(obj_handle, filename, "pjsim_trace_emit_insn_record");
    p_pjsim_trace_emit_mem_record = (int (*)(mem_trace_record_t))
        get_symbol_address(obj_handle, filename, "pjsim_trace_emit_mem_record");
    
    /* Make sure we got them all, and that it initializes properly. */
    if (p_pjsim_trace_init && p_pjsim_trace_finalize &&
	    p_pjsim_trace_emit_insn_record && p_pjsim_trace_emit_mem_record &&
	    (*p_pjsim_trace_init)()) 
	{
		printf ("done\n");
        return (1); 
    }
	else 
	{ 
	    WARN (("unable to load proper functions from trace library %s ... continuing without tracing functionality\n", filename));
	}
    
    /* It failed; reset the function pointers so we don't use them. */
    p_pjsim_trace_init = NULL;
    p_pjsim_trace_finalize = NULL;
    p_pjsim_trace_emit_insn_record = NULL;
    p_pjsim_trace_emit_mem_record = NULL;

    return (0);  /* failure */
}
