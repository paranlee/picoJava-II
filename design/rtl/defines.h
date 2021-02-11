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

/*
 * D cache Definitions
 * By default, Dcache size is 16KB. Since it is a 2way set associative cache,
 * it can be considered as 2 8KB caches. By changing the definitions below,
 * the cache sizes can be changed depending on user's requirements.
 */

/* dt_addr_msb is the msb of the tag which is stored in the tag rams for
   the D$ and I$ (see also it_addr_msb below)
   the tag rams are actually required to store only bit 29 downwards of the address  
   since the address space for pico is only 30 bits wide. to avoid storing 2 extra bits
   in the tag ram, the dr_addr_msb and it_addr_msb shd ideally be set to 29.

   however, in order to retain compatibility with earlier picojava megacell specs, 
   the default continues to be dt_addr_msb = it_addr_msb = 31. We recommend that 
   new implementations based on picoJava set these defines to 29 and reduce the size
   of the tag rams.

   the priv_read/write_icache/dcache_tag instructions are not affected by not
   storing address bits 31 and 30 in the tags, since the top 2 bits of data 
   read/written by these instructions is specified as undefined by the PRM.
*/

`define		dt_addr_msb	31	// MSB of DCU address being stored in Tag RAM. 
// `define		dt_addr_msb	29	// MSB of DCU address being stored in Tag RAM. 


/**
  The following five variables are used to defined D cache size.
  dc_size         Size of 1 way of Cache Ram
  dc_msb          MSB of Address Bus needed to index into the cache .
  dt_msb          MSB of Dcache Tag Field (Used for storing tag of a cache line)
  dt_index        MSB of Tag address used to index tag of a cache.
  dt_mxblks       Number of Blocks in the cache
**/

// 16KB D-cache:
`define	dc_size		8191
`define	dc_msb		12
`define	dt_msb		18
`define	dt_index	8	
`define	dt_mxblks	511
`define	HCR_DCS_POR_VALUE	3'h5

// 8KB D-cache:
//`define	dc_size		4095
//`define	dc_msb		11
//`define	dt_msb		19
//`define	dt_index	7
//`define	dt_mxblks	255
//`define	HCR_DCS_POR_VALUE	3'h4

// 4KB D-cache:
//`define	dc_size		2047
//`define	dc_msb		10
//`define	dt_msb		20
//`define	dt_index	6
//`define	dt_mxblks	127
//`define	HCR_DCS_POR_VALUE	3'h3

// 2KB D-cache:
//`define	dc_size		1023
//`define	dc_msb		9
//`define	dt_msb		21
//`define	dt_index	5
//`define	dt_mxblks	63
//`define	HCR_DCS_POR_VALUE	3'h2

// 1KB D-cache:
//`define	dc_size		511
//`define	dc_msb		8
//`define	dt_msb		22
//`define	dt_index	4
//`define	dt_mxblks	31
//`define	HCR_DCS_POR_VALUE	3'h1

// Comment out the next 3 defines if not using a D cache and uncomment
// all 10 defines under 0KB D-cache 
`define DCU_MODULE dcu
`define DTAG_MODULE dtag_shell
`define DCRAM_MODULE dcram_shell

// 0KB D-cache:
//`define	dc_size		0
//`define	dc_msb		4	// needs to be 4
//`define	dt_msb		0
//`define	dt_index	0
//`define	dt_mxblks	0
//`define	HCR_DCS_POR_VALUE	3'h0
//`define NO_DCACHE
//`define DCU_MODULE dcu_nocache
//`define DTAG_MODULE dtag_dummy
//`define DCRAM_MODULE dcram_dummy

// I cache Definitions

// see note for dt_addr_msb above
`define		it_addr_msb	31	// MSB of ICU address being stored in Tag RAM. 
// `define		it_addr_msb	29	// MSB of ICU address being stored in Tag RAM. 

/*
  By default, Icache size is 16KB. it is a direct mapped cache. 
  The following five variables are used to defined I cache size.
  ic_size         Size of 1 way of Cache Ram
  ic_msb          MSB of Address Bus needed to index into the cache .
  it_msb          MSB of Icache Tag Field (Used for storing tag of a cache line)
  it_index        MSB of Tag address used to index tag of a cache.
  it_mxblks       Number of Blocks in the cache
*/

// 16KB I-cache:
`define	ic_size		16383
`define	ic_msb		13
`define	it_msb		17
`define	it_index	9	
`define	it_mxblks	1023
`define	HCR_ICS_POR_VALUE	3'h5

// 8KB I-cache:
//`define	ic_size		8192
//`define	ic_msb		12
//`define	it_msb		18
//`define	it_index	8
//`define	it_mxblks	511
//`define	HCR_ICS_POR_VALUE	3'h4

// 4KB I-cache:
//`define	ic_size	  	4095
//`define	ic_msb	  	11
//`define	it_msb	  	19
//`define	it_index	 7
//`define	it_mxblks	255
//`define	HCR_ICS_POR_VALUE	3'h3

// 2KB I-cache:
//`define	ic_size	  	2048
//`define	ic_msb	  	10
//`define	it_msb	  	20
//`define	it_index	 6
//`define	it_mxblks	127
//`define	HCR_ICS_POR_VALUE	3'h2

// 1KB I-cache:
//`define	ic_size	  	1024
//`define	ic_msb	  	9
//`define	it_msb	  	21
//`define	it_index	 5
//`define	it_mxblks	63
//`define	HCR_ICS_POR_VALUE	3'h1

// Comment out the next 3 defines if not using an I cache and uncomment
// all 10 defines under 0KB I-cache 
`define ICU_MODULE icu
`define ITAG_MODULE itag_shell
`define ICRAM_MODULE icram_shell

// 0KB I-cache:
//`define	ic_size	  	0
//`define	ic_msb	  	4	// needs to be 4
//`define	it_msb	  	0
//`define	it_index	0
//`define	it_mxblks	0
//`define	HCR_ICS_POR_VALUE	3'h0
//`define NO_ICACHE
//`define ICU_MODULE icu_nocache
//`define ITAG_MODULE itag_dummy
//`define ICRAM_MODULE icram_dummy

// High and low water marks for the dribbler

`define high_mark	6'b110000
`define low_mark	6'b001000
`define stack_size	7'b1000000

// Some constants used by EX in RTL
`define	VARS_POR_VALUE		30'h003ffffc
`define	OPLIM_POR_VALUE		29'h00000000
`define	OPLIM_ENABLE_POR_VALUE	1'b0
`define	PSR_CAC_POR_VALUE	1'b0
`define	PSR_DRT_POR_VALUE	1'b0
`define	PSR_ACE_POR_VALUE	1'b0
`define	PSR_GCE_POR_VALUE	1'b0
`define	PSR_FPE_POR_VALUE	1'b0
`define	PSR_DCE_POR_VALUE	1'b0
`define	PSR_ICE_POR_VALUE	1'b0
`define	PSR_AEM_POR_VALUE	1'b0
`define	PSR_DRE_POR_VALUE	1'b0
`define	PSR_FLE_POR_VALUE	1'b0
`define	PSR_SU_POR_VALUE	1'b1
`define	PSR_IE_POR_VALUE	1'b0
`define	GC_CONFIG_POR_VALUE	32'h0
`define	BRK12C_HALT_POR_VALUE	1'b0
`define	BRK12C_BRKM2_POR_VALUE	7'h0
`define	BRK12C_BRKM1_POR_VALUE	7'h0
`define	BRK12C_SUBK2_POR_VALUE	1'b0
`define	BRK12C_SRCBK2_POR_VALUE	2'b00
`define	BRK12C_BRKEN2_POR_VALUE	1'b0
`define	BRK12C_SUBK1_POR_VALUE	1'b0
`define	BRK12C_SRCBK1_POR_VALUE	2'b00
`define	BRK12C_BRKEN1_POR_VALUE	1'b0
`define	VERSIONID_POR_VALUE	32'hffffffff
`define	HCR_DCL_POR_VALUE	3'h2
`define	HCR_ICL_POR_VALUE	3'h2
`define	HCR_SRN_POR_VALUE	8'h21
`define	SC_BOTTOM_POR_VALUE	30'h003ffffc


// FPU_MODULE needs to be set to either
// fpu - when the FPU is used in the core
// fpu_dummy - when no FPU is used in the core
// Also, NO_FPU has to be defined when no FPU is used

// When using the fpu in simulations:
`define FPU_MODULE fpu

// When NOT using the fpu in simulations:
//`define FPU_MODULE fpu_dummy
//`define NO_FPU
