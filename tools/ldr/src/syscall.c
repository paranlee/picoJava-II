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




static char *sccsid = "@(#)syscall.c 1.3 Last modified 10/06/98 11:34:20 SMI";

#include <stdio.h>

#ifdef hpux
#include <dl.h>
#else
#include <dlfcn.h>
#endif /* hpux */

#include "syscall.h"

/* this code is repeated in iam/src/tracing.c */
static void *get_symbol_address (void *obj_handle, const char *filename,
                                 const char *symbol_name)
{
    void *addr;
#ifdef hpux
    shl_findsym ((shl_t *) obj_handle, symbol_name, TYPE_PROCEDURE, &addr);
#else
    addr = dlsym (obj_handle, symbol_name);
#endif
 
    if (addr)
        return (addr);

#ifdef hpux
    fprintf (stderr, "Warning: no symbol \"%s\" in PICOJAVA_SYSCALL_LIB "
                     "\"%s\" ", symbol_name, filename);
    perror ("");
#else
    fprintf (stderr, "Warning: no symbol \"%s\" in PICOJAVA_SYSCALL_LIB "
                     "\"%s\": %s\n", symbol_name, filename, dlerror ());
#endif
    return (NULL);
}

static void (*p_syscall_handler_fn) ();

void init_syscall_library ()

{
    char *filename = (char *) getenv ("PICOJAVA_SYSCALL_LIB");
    void *obj_handle;
    int (*p_syscall_library_init_fn) ();
        
    if (!filename)
        return;  /* success (nothing to do) */
            
    fprintf (stderr, "PICOJAVA_SYSCALL_LIB set, loading picojava syscall "
            "functions from %s ... ", filename);

    /* Open the specified dynamic object. */
#ifdef hpux
    obj_handle = shl_load (filename, BIND_IMMEDIATE, 0L);
#else
    obj_handle = dlopen(filename, RTLD_NOW);
#endif

    if (!obj_handle)
    {
#ifdef hpux
        fprintf (stderr, "failed dlopen of PICOJAVA_SYSCALL_LIB\"%s\" ", 
                         filename);
        perror ("");
#else
        fprintf (stderr, "failed dlopen of PICOJAVA_SYSCALL_LIB\"%s\": %s\n", 
                         filename, dlerror());
#endif
	fprintf (stderr, "unable to load syscall library ... continuing "
                         "without syscall functionality\n");
        return;
    }
    
    /* Get the function addresses */
    p_syscall_library_init_fn = (int (*)())
        get_symbol_address (obj_handle, filename, "picojava_syscall_init");
    p_syscall_handler_fn = (void (*)())
        get_symbol_address(obj_handle, filename, "picojava_syscall");

    /* check whether we have both functions, and that the syscall library
       initialises ok */
    if (p_syscall_library_init_fn && p_syscall_handler_fn &&
        (*p_syscall_library_init_fn) ())
    {
	fprintf (stderr, "done\n"); 
        return;
    }
    else 
    { 
	    fprintf (stderr, "unable to load proper functions from syscall "
                             "library %s ... continuing without syscall "
                             "functionality\n", filename);
    }
    
    /* It failed; reset the function pointers so we don't use them. */
    p_syscall_library_init_fn = NULL;
    p_syscall_handler_fn = NULL;
}

void handle_syscall ()

{
    if (p_syscall_handler_fn)
        (*p_syscall_handler_fn) ();
    else
        fprintf (stderr, "Warning: syscall ignored, since system "
                         "call handler library is not loaded\n");
}

