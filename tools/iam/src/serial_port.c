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




static char *sccsid = "@(#)serial_port.c 1.4 Last modified 10/06/98 11:37:09 SMI";

#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>

#include "dprint.h"
#include "serial_port.h"

/* Pointers to port handler routines. */
int (*debugger_serial_port_init) (void) = NULL;
unsigned char (*debugger_serial_port_read) (void) = NULL;
void (*debugger_serial_port_write)(unsigned char) = NULL;

static void *get_symbol_address (void *obj_handle, const char *filename, 
                                 const char *symbol_name)
{
    void *addr = dlsym(obj_handle, symbol_name);
    
    if (addr)
        return (addr);
        
    WARN (("\nno symbol \"%s\" in PJSIM_PORT_HANDLER \"%s\": %s\n", symbol_name, filename, dlerror()));
    return (NULL);
}

int init_port_handler()
{
    const char *filename = getenv("PJSIM_PORT_HANDLER");
    void *obj_handle;
        
    if (!filename)
        return (1);  /* success (nothing to do) */
            
    printf ("PJSIM_PORT_HANDLER set, loading port handler from %s ... ", filename);

    /* Open the specified dynamic object. */
    obj_handle = dlopen(filename, RTLD_NOW);
    if (!obj_handle) {
        WARN (("failed dlopen of PJSIM_PORT_HANDLER \"%s\": %s\n", filename, dlerror()));
	    WARN (("unable to load serial port handler library ... continuing without serial port functionality\n"));

        return (0);  /* failure */
    }
    
    /* Get the function addresses. */
    debugger_serial_port_init = (int (*)(void))
        get_symbol_address(obj_handle, filename, "pjsim_port_init");
    debugger_serial_port_read = (unsigned char (*)(void))
        get_symbol_address(obj_handle, filename, "pjsim_port_read");
    debugger_serial_port_write = (void (*)(unsigned char))
        get_symbol_address(obj_handle, filename, "pjsim_port_write");
    
    /* Make sure we got them all, and that it initializes properly. */
    if (debugger_serial_port_init && debugger_serial_port_read && 
	    debugger_serial_port_write && (*debugger_serial_port_init)()) 
	{
		printf ("done\n");
        return (1);  /* success */
    }
    else
    {
        WARN (("unable to load proper functions from serial port library %s ... continuing without serial port functionality\n", filename));
    }

    /* It failed; reset the function pointers so we don't use them. */
    debugger_serial_port_init  = NULL;
    debugger_serial_port_read  = NULL;
    debugger_serial_port_write = NULL;
    return (0);  /* failure */
}

