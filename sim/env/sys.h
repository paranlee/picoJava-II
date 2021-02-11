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




 // memory map definition
`define RESET_ADDRESS			30'h0
`define PROFILER_CMD_ADDR               30'h0000ffc0
`define PROFILER_DATA_ADDR              30'h0000ffc4
`define PERF_COUNTER_ADDRESS		30'h0000ffdc
`define COSIM_LOCATION			30'h0000ffe0
`define WATERMARK_LOCATION		30'h0000ffe4
`define RESETCODE_USE_LOCATION		30'h0000ffe8
`define TRAP_USE_LOCATION		30'h0000ffec
`define FLUSH_LOCATION			30'h0000fff0
`define END_LOCATION			30'h0000fffc
`define PENDING_REGISTER		30'h0000fff8
`define STOP_RANDOM_INTERRUPT		30'h0000fff4
`define TRAP_ADDRESS			30'h00010000
`define CLASS_ADDRESS			30'h00020000
`define HEAP_ADDRESS                    30'h00100000
`define STACK_BASE			30'h00400000
`define SCRATCH_CACHABLE_START		30'h2fff0000
`define SCRATCH_NON_CACHABLE_START	30'h30000000
`define SCRATCH_SIZE			30'h20000
`define BAD_MEMORY_START		30'h2fffbad0
`define BAD_SIZE			30'h10
`define BAD_IO_START			30'h3000bad0

// supporting environment variables

`define SLEEP 1
`define WAKEUP 0

`define FPU 0
`define NOFPU 1

`define SCANOFF 0
`define SCANON 1
`define SCAN_IN 1

`define BOOT8ON 1
`define BOOT8OFF 0

// clock parameters
// in tick
`define CLK_HALF_PERIOD 10
`define RESET_START 3
// 5*(2*`CLK_HALF_PERIOD)
`define RESET_END 120
`define END_OF_SIMULATION_DELAY (100*(2*`CLK_HALF_PERIOD))

`timescale 1ns/10ps

// top of the hierarchy
`define PICOJAVAII picoJavaII
`define DESIGN cpu

// Random SMU hold seed...
`define RAND_HOLD_SEED   2
`define RAND_HOLD_SEED_2 4
`define RAND_HOLD_SEED_3 6

`define MIN_HOLD_GAP 1

// undefine to use DAI's Signalscan
// `define SIGNALSCAN
