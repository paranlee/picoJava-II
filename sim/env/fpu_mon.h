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


`define CLK_PERIOD 50
`define HALF_PERIOD (`CLK_PERIOD/2)

`define FCMPG 8'h96
`define FCMPL 8'h95
`define DCMPG 8'h98
`define DCMPL 8'h97
`define DADD 8'h63
`define DMUL 8'h6b
`define FADD 8'h62
`define FMUL 8'h6a
`define FDIV 8'h6e
`define FREM 8'h72
`define DSUB 8'h67
`define DDIV 8'h6f
`define DREM 8'h73
`define FSUB 8'h66
`define F2D  8'h8d
`define D2F  8'h90
`define F2I  8'h8b
`define F2L  8'h8c
`define D2I  8'h8e
`define D2L  8'h8f
`define I2F  8'h86
`define I2D  8'h87
`define L2F  8'h89
`define L2D  8'h8a


`define	IN1		3'b000
`define	IN2_OPR1	3'b001
`define	IN2_OPR2	3'b010
`define	EXEC		3'b011
`define	OUT1		3'b100

`define MAX_OPERANDS	1500

`define MAX_BSY_LENGTH 2000
