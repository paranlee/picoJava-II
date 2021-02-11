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




static char *sccsid = "@(#)commands.c 1.8 Last modified 02/28/99 16:52:07 SMI";

#include <stdlib.h>
#include "dsv.h"
#include "iam.h"
#include "cache.h"
#include "global_regs.h"

int flag_icache_once_inited = 0;
int flag_dcache_once_inited = 0;

/* this file contains routines to support various user commands.
all routines take in argc, argv kind of args.
these routines used to be only in the tcl i/f earlier, now made
part of the backend, because they are required from gdb as well
command usage:
dcache [0|1|2|4|8|16]
icache [0|1|2|4|8|16]
fpu present|absent
scache on|off
dumpDCache <line number>
dumpICache <line number>
*/

static void doICacheCmd (int argc, char **argv)

{
    if (argc == 2) {
    int isize = strtol (argv[1], (char **) NULL, 0);

    switch (isize) {
	case 0:
	 hcr.ics = 0;
	 break;
	case 1:
         hcr.ics = 1;
	 break;
	case 2:
         hcr.ics = 2;
	 break;
	case 4:
         hcr.ics = 3;
	 break;
	case 8:
         hcr.ics = 4;
	 break;
	case 16:
         hcr.ics = 5;
	 break;
	default:
	 printf ("Unknown I-Cache size (should be 0,1,2,4,8,16)\n");
    }

    icacheInit (hcr.ics);

    flag_icache_once_inited = 1;
   }

   printf ("I$ size set to %dK\n", (hcr.ics == 0) ? 0 : 1 << (hcr.ics -1));
}

static void doDCacheCmd (int argc, char **argv)

{
   if (argc == 2) {
    /* D$ */
    int dsize = strtol (argv[1], (char **) NULL, 0);

    switch (dsize) {
	case 0:
	 hcr.dcs = 0;
	 break;
	case 1:
	 hcr.dcs = 1;
	 break;
	case 2:
	 hcr.dcs = 2;
	 break;
	case 4:
	 hcr.dcs = 3;
	 break;
	case 8:
	 hcr.dcs = 4;
	 break;
	case 16:
	 hcr.dcs = 5;
	 break;
	default:
	 printf("Unknown D-Cache size (should be 0,1,2,4,8,16)\n");
    }
    dcacheInit (hcr.dcs);

    flag_dcache_once_inited = 1;
   }

   printf ("D$ size set to %dK\n", (hcr.dcs == 0) ? 0 : 1 << (hcr.dcs -1));
}

static void doFPUCmd (int argc, char **argv)

{
    if (argc == 2)
    {
        if (!strcasecmp ("present", argv[1]))
            hcr.fpp = 1;
        else if (!strcasecmp ("absent", argv[1]))
            hcr.fpp = 0;
        else
            printf ("Invalid argument, FPU command ignored\n");
    }
}

/* configure the core using the commands:
dcache <size>
icache <size>
fpu present|absent
*/

void doConfigureCmd (int argc, char **argv)

{
   if (argc != 2)
   {
       printf ("Current configuration:\n");
       printf ("I-cache size: %dK\n", (hcr.ics == 0) ? 0 : 1 << (hcr.ics - 1));
       printf ("D-cache size: %dK\n", (hcr.dcs == 0) ? 0 : 1 << (hcr.dcs - 1));
       printf ("FPU: %s\n", hcr.fpp ? "present" : "absent");
   }
   else 
   { 
       if (!strcasecmp (argv[0], "dcache"))
           doDCacheCmd (argc, argv);
       else if (!strcasecmp (argv[0], "icache"))
           doICacheCmd (argc, argv);
       else if (!strcasecmp (argv[0], "fpu"))
           doFPUCmd (argc, argv);
       else 
          printf ("Invalid arguments, configure comamnd ignored\n");
   }
}

void doDumpDCacheCmd(int argc, char **argv)

{
   FILE *fp;
   static unsigned i=0;
   static unsigned j=0;

   if (argc == 2) {
    i = strtoul (argv[1], (char **) NULL, 0);
    j = 1;
   }
   else if (argc == 3) { 
    i = strtoul (argv[1], (char **) NULL, 0);
    j = strtoul (argv[2], (char **) NULL, 0);
   }
   else {
    j = 1;
   }

   dCacheDisplayAll(i, i+j, stdout);
   i = i + j;
}

void doDumpICacheCmd (int argc, char **argv)

{
   FILE *fp;
   static unsigned i=0;
   static unsigned j=0;

   if (argc == 2) {
    i = strtoul (argv[1], (char **) NULL, 0);
    j = 1;
   }
   else if (argc == 3) { 
    i = strtoul (argv[1], (char **) NULL, 0);
    j = strtoul (argv[2], (char **) NULL, 0);
   }
   else {
    j = 1;
   }

   iCacheDisplayAll(i, i+j, stdout);
   i = i + j;
}

void doSCacheCmd (int argc, char **argv)

{
    if (argc == 2)
    {
     /* don't call initScache here, that's only done once at poweron */
        ias_scache = (strcasecmp(argv[1], "on") == 0) ? 1 : 0;
    }

    printf("S$ is %s\n", ias_scache ? "ON" : "OFF");
}
