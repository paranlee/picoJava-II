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




 
`define   MEM_ERROR_ADDR_HIGH	32'h2FFFBADF 
`define   MEM_ERROR_ADDR_LOW 	32'h2FFFBAD0	

`define   IO_ERROR_ADDR_HIGH 	32'h3000BADF	
`define   IO_ERROR_ADDR_LOW 	32'h3000BAD0	

`define   NC_ADDR_HIGH 		32'h3000FFFF	
`define   NC_ADDR_LOW		32'h30000000	

`define	ICACHE_LOAD		3'h0
`define	ICACHE_NC_LOAD		3'h2
`define	DCACHE_LOAD		3'h4
`define	WRITE_BACK		3'h5
`define	DCACHE_NC_LOAD		3'h6
`define	DCACHE_NC_STORE	3'h7
/*
`define	DRIBBLE_LOAD		4'h8
`define	DRIBBLE_STORE		4'h9	
*/

`define	IDLE_ACK			2'b00
`define	NORMAL_ACK		2'b01
`define	MEM_ERROR_ACK		2'b10
`define	IO_ERROR_ACK		2'b11

`define	BYTE				2'b00	
`define	HALFWORD			2'b01
`define	WORD				2'b10

`define	READ				1'b1
`define	WRITE			1'b0

`define	MAX_MEM_LATENCY	5

// Memory access latency for 4 word burst transfer...

`define MEM_LATENCY_X1		12
`define MEM_LATENCY_X2		4
`define MEM_LATENCY_X3		4
`define MEM_LATENCY_X4		4
