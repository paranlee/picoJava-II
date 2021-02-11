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




#ifndef _STATISTICS_H_
#define _STATISTICS_H_

#pragma ident "@(#)statistics.h 1.5 Last modified 10/06/98 11:37:12 SMI"

typedef struct {
double average;
double min;
double max;
int nSamples;
int which_max; /* which part. sample had the min value */
int which_min; /* which part. sample had the max value */
} StatisticsObject;

/* interface functions */
void vInitStatistics (StatisticsObject *s);
void vNewSample(StatisticsObject *s, double sample);

unsigned int getnSamples (StatisticsObject *s);
double getAverage (StatisticsObject *s);
double getSum (StatisticsObject *s);
double getMaxSample (StatisticsObject *s);
double getMinSample (StatisticsObject *s);
unsigned int getWhichSampleMax (StatisticsObject *s);
unsigned int getWhichSampleMin (StatisticsObject *s);

#endif /* _STATISTICS_H_ */
