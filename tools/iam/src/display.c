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




static char *sccsid = "@(#)display.c 1.6 Last modified 10/06/98 11:36:41 SMI";

#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include  <stdarg.h>

#include "iam.h"
#include "global_regs.h"

char *GR_names[] = {
    "optop", "vars", "userrange1", "userrange2", "pc", "psr", "oplim", 
	"trapbase", "versionid", "frame", "cp", "sc_bottom", "hcr", 
	"global0", "global1", "global2", "global3", "brk1a", "brk2a", "brk12c",
	"lockaddr0", "lockaddr1", "lockcount0", "lockCount1", "gc_config"};

void DisplayStack(int items, FILE *fp)
{
    int  i;
    unsigned int  optop_t;

    if (items == 0)
		items = 10; /* some default value */

    optop_t = (unsigned int) optop;
    fprintf (fp, "Optop is %x \n", optop);
    optop_t += JAVAWORDSIZE;
    for (i = 0 ; i < items ; i++) 
	{
	    unsigned int utmp;
	    utmp = readProgMem (optop_t);
        fprintf(fp, "Stack location %x     Content %x \n", optop_t, utmp);
        optop_t += JAVAWORDSIZE;
    }   
}

void DisplayReg(char *which, FILE *fp)

{
    int  i;

    if (which == NULL) 
	{
        fprintf(fp, "Optop  = 0x%-8x Trapbase   = 0x%-8x Global0    = 0x%-8x\n", optop, trapbase, global0);

        fprintf(fp, "Vars   = 0x%-8x SC_Bottom  = 0x%-8x Global1    = 0x%-8x\n", vars, scBottom, global1);

        fprintf(fp, "PC     = 0x%-8x Userrange1 = 0x%-8x Global2    = 0x%-8x\n", pc, userrange1, global2);

	    fprintf(fp, "CP     = 0x%-8x Userrange2 = 0x%-8x Global3    = 0x%-8x\n", const_pool, userrange2, global3);

        fprintf(fp, "Frame  = 0x%-8x VersionID  = 0x%-8x LockAddr0  = 0x%-8x\n", frame, versionId, lockAddr[0]);

	    fprintf(fp, "PSR    = 0x%-8x GC_config  = 0x%-8x LockAddr1  = 0x%-8x\n", psr, gcConfig, lockAddr[1]);

	    fprintf(fp, "Oplim  = 0x%-8x Brk1A      = 0x%-8x LockCount0 = 0x%-8x\n", oplim, brk1a, lockCount[0]);

	    fprintf(fp, "HCR    = 0x%-8x Brk2A      = 0x%-8x LockCount1 = 0x%-8x\n", *(unsigned int *) &hcr, brk2a, lockCount[1]);

	    fprintf(fp, "Brk12C = 0x%-8x\n", *(int *) (&brk12c));

    }
    else 
	{
        for (i = 0 ; i < NUMREG ; i++) 
		{
            if (strcasecmp(which, GR_names[i]) == 0)
                break;
        }
        switch(i) 
		{
          case 0: {fprintf(fp, "Optop = 0x%x\n", optop); break; }
          case 1: {fprintf(fp, "Vars = 0x%x\n", vars); break; }
          case 2: {fprintf(fp, "Userrange1 = 0x%x\n", userrange1); break; }
          case 3: {fprintf(fp, "Userrange2 = 0x%x\n", userrange2); break; }
          case 4: {fprintf(fp, "PC = 0x%x\n", pc); break; }
          case 5: {fprintf(fp, "PSR = 0x%x\n",psr); break; }
          case 6: {fprintf(fp, "Oplim = 0x%x\n", oplim); break; }
          case 7: {fprintf(fp, "Trapbase = 0x%x\n", trapbase); break; }
          case 8: {fprintf(fp, "Version_id = 0x%x\n", versionId); break; }
          case 9: {fprintf(fp, "Frame = 0x%x\n", frame); break; }
		  case 10:{fprintf(fp, "Constant pool = 0x%x\n", const_pool);break;}
		  case 11:{fprintf(fp, "SC_Bottom = 0x%x\n", scBottom);break;}
		  case 12:{fprintf(fp, "HCR = 0x%x\n", hcr);break;}

		  case 13:{fprintf(fp, "Global0 = 0x%x\n", global0);break;}
		  case 14:{fprintf(fp, "Global1 = 0x%x\n", global1);break;}
		  case 15:{fprintf(fp, "Global2 = 0x%x\n", global2);break;}
		  case 16:{fprintf(fp, "Global3 = 0x%x\n", global3);break;}

		  case	17:{fprintf(fp, "Brk1A = 0x%x\n", brk1a);break;}
		  case	18:{fprintf(fp, "Brk2A = 0x%x\n", brk2a);break;}
		  case	19:{fprintf(fp, "Brk12C = 0x%x\n", *(int *)(&brk12c));break;}

		  case	20:{fprintf(fp, "LockAddr0 = 0x%x\n", lockAddr[0]); break;}
		  case	21:{fprintf(fp, "LockAddr1 = 0x%x\n", lockAddr[1]); break;}
		  case	22:{fprintf(fp, "LockCount0 = 0x%x\n", lockCount[0]); break;}
		  case	23:{fprintf(fp, "LockCount1 = 0x%x\n", lockCount[1]); break;}

		  case	24:{fprintf(fp, "GC_config = 0x%x\n", gcConfig); break;}

          default:fprintf(fp, "never heard of register %s\n", which);
        }
    }
}
