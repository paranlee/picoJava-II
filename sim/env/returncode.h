/****************************************************************
 ---------------------------------------------------------------
     Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
     Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
     The contents of this file are subject to the current
     version of the Sun Community Source License, picoJava-II
     Core ("the License").  You may not use this file except
     in compliance with the License.  You may obtain a copy
     of the License by searching for "Sun Community Source
     License" on the World Wide Web at http://www.sun.com.
     See the License for the rights, obligations, and
     limitations governing use of the contents of this file.

     Sun, Sun Microsystems, the Sun logo, and all Sun-based
     trademarks and logos, Java, picoJava, and all Java-based
     trademarks and logos are trademarks or registered trademarks 
     of Sun Microsystems, Inc. in the United States and other
     countries.
 ----------------------------------------------------------------
******************************************************************/




 
// This file defines the return code from simulation
// A return value is an integer
// The upper 16 bit is for identifying a subsystem
// The lower 16 bit is for a specific error
//
// Subsystem identifier
//   'h0000 -- top level
//   'h0001 -- IU


`define SUCCESS			32'h00000000
`define INITIAL_VALUE		32'h00000001
`define FAIL_AT_END		32'h00000002
`define LOOP_FOREVER		32'h00000003
`define DETECTED_LAST_INST	32'h00000004
`define RANDOM_TEST_RETURN      32'h00000005
`define BAD_POR_VALUE           32'h00000006
