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




static char *sccsid = "@(#)statistics.c 1.6 Last modified 10/06/98 11:37:11 SMI";

#include <stdio.h>
#include <float.h>

#include "statistics.h"

void vInitStatistics (StatisticsObject *ps)

{
#if 0
printf ("initstats called\n");
#endif
    ps->min = DBL_MAX;
	ps->max = -DBL_MIN;
	ps->average = 0.0;      /* shd actually be a Nan */
	ps->nSamples = 0;
	ps->which_max = ps->which_min = 0;
}

void vNewSample(StatisticsObject *ps, double sample)

{
#if 0
printf ("sample called with %d\n", (int) sample);
#endif
     if (sample < ps->min)
	 {
	     ps->min = sample;
		 ps->which_min = ps->nSamples+1;
	 }
     if (sample > ps->max)
	 {
	     ps->max = sample;
		 ps->which_max = ps->nSamples+1;
     }
     ps->average = (ps->average * ps->nSamples + sample)/(ps->nSamples+1);
	 ps->nSamples++;
}

unsigned int getnSamples (StatisticsObject *ps)

{
    return ps->nSamples;
}

double getAverage (StatisticsObject *ps)

{
    return ps->average;
}

double getSum (StatisticsObject *ps)

{
    return (ps->average * ps->nSamples);
}

double getMaxSample (StatisticsObject *ps)

{
    return ps->max;
}

double getMinSample (StatisticsObject *ps)

{
    return ps->min;
}

unsigned int getWhichSampleMax (StatisticsObject *ps)

{
    return ps->which_max;
}

unsigned int getWhichSampleMin (StatisticsObject *ps)

{
    return ps->which_min;
}
