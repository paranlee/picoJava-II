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

`include "defines.h"

module ex_regs(data_in,			// Input
	       pc_r,
	       pc_e,
	       pc_c,
	       optop_c,
	       smu_addr,
	       iu_addr_c,
	       iu_addr_e,
	       hold_e,
	       hold_c,
	       inst_valid,
	       fold_c,
	       priv_update_optop,
	       reg_rd_mux_sel,
	       reg_wr_mux_sel,
	       ucode_reg_data_mux_sel,
	       lc0_din_mux_sel,
	       lc1_din_mux_sel,
	       lc0_count_reg_we,
	       lc1_count_reg_we,
	       lock0_cache,
	       lock1_cache,
	       lock0_uncache,
	       lock1_uncache,
	       smu_sbase,
	       smu_sbase_we,
	       pj_boot8_e,
	       pj_no_fpu_e,
	       tbase_tt_e,
	       tbase_tt_we_e,

	       data_out,		// Output
	       ucode_reg_data,
	       vars_out,
	       psr_out,
	       brk12c_out,
	       sc_bottom_out,
	       range1_l_cmp1_lt,
	       range1_h_cmp1_gt,
	       range1_h_cmp1_eq,
	       range2_l_cmp1_lt,
	       range2_h_cmp1_gt,
	       range2_h_cmp1_eq,
	       range1_l_cmp2_lt,
	       range1_h_cmp2_gt,
	       range1_h_cmp2_eq,
	       range2_l_cmp2_lt,
	       range2_h_cmp2_gt,
	       range2_h_cmp2_eq,
	       data_brk1_31_13_eq,
	       data_brk1_11_4_eq,
	       data_brk1_misc_eq,
	       data_brk2_31_13_eq,
	       data_brk2_11_4_eq,
	       data_brk2_misc_eq,
	       inst_brk1_31_13_eq,
	       inst_brk1_11_4_eq,
	       inst_brk1_misc_eq,
	       inst_brk2_31_13_eq,
	       inst_brk2_11_4_eq,
	       inst_brk2_misc_eq,
	       oplim_trap_c,
	       la0_hit,
	       lc0_eq_255,
	       lc0_eq_0,
	       lc0_m1_eq_0,
	       lockwant0,
	       lc0_co_bit,
	       la0_null_e,
	       la1_hit,
	       lc1_eq_255,
	       lc1_eq_0,
	       lc1_m1_eq_0,
	       lockwant1,
	       lc1_co_bit,
	       la1_null_e,

	       reset_l,			// Global
	       clk,
	       sm,
	       sin,
	       so
	       );
   input [31:0]	 data_in;		// Value to write into selected register
   input [31:0]  pc_r;			// R stage PC value from pipe control
   input [31:0]  pc_e;			// E stage PC value from pipe control
   input [31:0]  pc_c;			// C stage PC value from pipe control
   input [31:0]  optop_c;		// C stage OPTOP value from pipe control
   input [29:14] smu_addr;		// SMU address from CPU level
   input [31:0]  iu_addr_c;		// Latched iu_addr_e from ex_dpath
   input [31:0]  iu_addr_e;		// iu_addr_e from ex_dpath
   input 	 hold_e;		// Hold off R->E transition
   input 	 hold_c;		// Hold off register write in E stage
   input [1:1] 	 inst_valid;		// Valid bits of the pipe, bit 1 for C
   input 	 fold_c;		// Not folded, from pipe.v
   input 	 priv_update_optop;	// Indicates a priv_update_optop in R
   input [20:0]  reg_rd_mux_sel;	/* bit 20, 0x100000: SC_BOTTOM
					 * bit 19, 0x080000: HCR
					 * bit 18, 0x040000: VERSIONID
					 * bit 17, 0x020000: USERRANGE2
					 * bit 16, 0x010000: BRK12C
					 * bit 15, 0x008000: BRK2A
					 * bit 14, 0x004000: BRK1A
					 * bit 13, 0x002000: GC_CONFIG
					 * bit 12, 0x001000: USERRANGE1
					 * bit 11, 0x000800: LOCKADDR1
					 * bit 10, 0x000400: LOCKADDR0
					 * bit  9, 0x000200: LOCKCOUNT1
					 * bit  8, 0x000100: LOCKCOUNT0
					 * bit  7, 0x000080: TRAPBASE
					 * bit  6, 0x000040: PSR
					 * bit  5, 0x000020: CONST_POOL
					 * bit  4, 0x000010: OPLIM
					 * bit  3, 0x000008: OPTOP
					 * bit  2, 0x000004: FRAME
					 * bit  1, 0x000002: VARS
					 * bit  0, 0x000001: PC
					 */
   input [18:0]  reg_wr_mux_sel;	/* bit 18, 0x40000: SC_BOTTOM
					 * bit 17, 0x20000: USERRANGE2
					 * bit 16, 0x10000: BRK12C
					 * bit 15, 0x08000: BRK2A
					 * bit 14, 0x04000: BRK1A
					 * bit 13, 0x02000: GC_CONFIG
					 * bit 12, 0x01000: USERRANGE1
					 * bit 11, 0x00800: LOCKADDR1
					 * bit 10, 0x00400: LOCKADDR0
					 * bit  9, 0x00200: LOCKCOUNT1
					 * bit  8, 0x00100: LOCKCOUNT0
					 * bit  7, 0x00080: TRAPBASE
					 * bit  6, 0x00040: PSR
					 * bit  5, 0x00020: CONST_POOL
					 * bit  4, 0x00010: OPLIM
					 * bit  3, 0x00008: OPTOP
					 * bit  2, 0x00004: FRAME
					 * bit  1, 0x00002: VARS
					 * bit  0, 0x00001: PC
					 */
   input [6:0] 	 ucode_reg_data_mux_sel;/* bit 6, 0x40: TRAPBASE
					 * bit 5, 0x20: GC_CONFIG
					 * bit 4, 0x10: PSR
					 * bit 3, 0x08: CONST_POOL
					 * bit 2, 0x04: FRAME
					 * bit 1, 0x02: VARS
					 * bit 0, 0x01: PC (C stage)
					 */
   input [3:0] 	 lc0_din_mux_sel;	/* 4: lc0_p1
					 * 2: lc0_m1
					 * 1: data_in
					 */
   input [3:0] 	 lc1_din_mux_sel;	/* 4: lc1_p1
					 * 2: lc1_m1
					 * 1: data_in
					 */
   input 	 lc0_count_reg_we;	// Write enable of lockcount0 register
   input 	 lc1_count_reg_we;	// Write enable of lockcount1 register
   input	 lock0_cache;		// control signal to cache a lock in lock pair 0
   input	 lock1_cache;		// control signal to cache a lock in lock pair 1
   input	 lock0_uncache;		// control signal to uncache a lock in lock pair 0
   input	 lock1_uncache;		// control signal to uncache a lock in lock pair 1
   input [31:2]  smu_sbase;		// SC_BOTTOM value from SMU
   input 	 smu_sbase_we;		// Write-enable for SC_BOTTOM from SMU
   input 	 pj_boot8_e;		// Input pin pj_boot8
   input 	 pj_no_fpu_e;		// Input pin pj_no_fpu
   input [7:0] 	 tbase_tt_e;		// Input to the tt field of TRAPBASE
   input 	 tbase_tt_we_e;		// Write enable of the tt field

   output [31:0] data_out;		// Output of the register mux
   output [31:0] ucode_reg_data;	// Output bus for ucode register read
   output [31:0] vars_out;		// Output of the VARS register
   output [31:0] psr_out;		// Output of the PSR register
   output [31:0] brk12c_out;		// Output of the BRK12C register
   output [31:0] sc_bottom_out;		// Output of the SC_BOTTOM register
   output 	 range1_l_cmp1_lt;	// iu_addr_c < userrange1.userlow
   output 	 range1_h_cmp1_gt;	// iu_addr_c > userrange1.userhigh
   output 	 range1_h_cmp1_eq;	// iu_addr_c = userrange1.userhigh
   output 	 range2_l_cmp1_lt;	// iu_addr_c < userrange2.userlow
   output 	 range2_h_cmp1_gt;	// iu_addr_c > userrange2.userhigh
   output 	 range2_h_cmp1_eq;	// iu_addr_c = userrange2.userhigh
   output 	 range1_l_cmp2_lt;	// optop_c < userrange1.userlow
   output 	 range1_h_cmp2_gt;	// optop_c > userrange1.userhigh
   output 	 range1_h_cmp2_eq;	// optop_c = userrange1.userhigh
   output 	 range2_l_cmp2_lt;	// optop_c < userrange2.userlow
   output 	 range2_h_cmp2_gt;	// optop_c > userrange2.userhigh
   output 	 range2_h_cmp2_eq;	// optop_c = userrange2.userhigh
   output 	 data_brk1_31_13_eq;	// iu_addr_c[31:13] == brk1a[31:13]
   output 	 data_brk1_11_4_eq;	// iu_addr_c[11:4]  == brk1a[11:4]
   output [4:0]	 data_brk1_misc_eq;	// iu_addr_c[12,3:0]== brk1a[12,3:0]
   output 	 data_brk2_31_13_eq;	// iu_addr_c[31:13] == brk2a[31:13]
   output 	 data_brk2_11_4_eq;	// iu_addr_c[11:4]  == brk2a[11:4]
   output [4:0]	 data_brk2_misc_eq;	// iu_addr_c[12,3:0]== brk2a[12,3:0]
   output 	 inst_brk1_31_13_eq;	// pc_r[31:13] == brk1a[31:13]
   output 	 inst_brk1_11_4_eq;	// pc_r[11:4]  == brk1a[11:4]
   output [4:0]	 inst_brk1_misc_eq;	// pc_r[12,3:0]== brk1a[12,3:0]
   output 	 inst_brk2_31_13_eq;	// pc_r[31:13] == brk2a[31:13]
   output 	 inst_brk2_11_4_eq;	// pc_r[11:4]  == brk2a[11:4]
   output [4:0]	 inst_brk2_misc_eq;	// pc_r[12,3:0]== brk2a[12,3:0]
   output 	 oplim_trap_c;		// optop < oplim in C stage
   output 	 la0_hit;		// 1 if lockaddr0 == objref in data_in
   output 	 lc0_eq_255;		// 1 if lockcount0   == 255, 0 otherwise
   output 	 lc0_eq_0;		// 1 if lockcount0   ==   0, 0 otherwise
   output 	 lc0_m1_eq_0;		// 1 if lockcount0-1 ==   0, 0 otherwise
   output 	 lockwant0;		// Bit 14 of lockcount0 register
   output	 lc0_co_bit;		// Bit 15 of lockcount0 register
   output        la0_null_e;		// 1 if lockaddr0 == 0, 0 otherwise
   output 	 la1_hit;		// 1 if lockaddr1 == objref in data_in
   output 	 lc1_eq_255;		// 1 if lockcount1   == 255, 0 otherwise
   output 	 lc1_eq_0;		// 1 if lockcount1   ==   0, 0 otherwise
   output 	 lc1_m1_eq_0;		// 1 if lockcount1-1 ==   0, 0 otherwise
   output 	 lockwant1;		// Bit 14 of lockcount1 register
   output	 lc1_co_bit;		// Bit 15 of lockcount0 register
   output        la1_null_e;		// 1 if lockaddr1 == 0, 0 otherwise
   
   input 	 reset_l;			// Global reset signal
   input 	 clk;			// Global clock signal
   input 	 sm;			// Scan enable
   input 	 sin;			// Scan input of this module
   output 	 so;			// Scan output of this module

   // Internal signals
   wire [31:2] 	 vars_din;		// Input to the VARS register
   wire [31:2] 	 oplim_din;		// Input to the OPLIM register
   wire 	 psr_cac_din;		// Input to the CAC bit of PSR
   wire 	 psr_drt_din;		// Input to the DRT bit of PSR
   wire 	 psr_bm8_din;		// Input to the BM8 bit of PSR
   wire 	 psr_ace_din;		// Input to the ACE bit of PSR
   wire 	 psr_gce_din;		// Input to the GCE bit of PSR
   wire 	 psr_fpe_din;		// Input to the FPE bit of PSR
   wire 	 psr_dce_din;		// Input to the DCE bit of PSR
   wire 	 psr_ice_din;		// Input to the ICE bit of PSR
   wire 	 psr_aem_din;		// Input to the AEM bit of PSR
   wire 	 psr_dre_din;		// Input to the DRE bit of PSR
   wire 	 psr_fle_din;		// Input to the FLE bit of PSR
   wire 	 psr_su_din;		// Input to the SU  bit of PSR
   wire 	 psr_ie_din;		// Input to the IE  bit of PSR
   wire [7:0] 	 lc0_count_din;		// Input to the COUNT bits of LOCKCOUNT0
   wire [7:0] 	 lc1_count_din;		// Input to the COUNT bits of LOCKCOUNT1
   wire [31:0] 	 gc_config_din;		// Input to the GC_CONFIG register
   wire 	 brk12c_halt_din;	// Input to the HALT bit of BRK12C
   wire [6:0] 	 brk12c_brkm2_din;	// Input to the BRKM2 bit of BRK12C
   wire [6:0] 	 brk12c_brkm1_din;	// Input to the BRKM1 bit of BRK12C
   wire 	 brk12c_subk2_din;	// Input to the SUBK2 bit of BRK12C
   wire [1:0] 	 brk12c_srcbk2_din;	// Input to the SRCBK2 bit of BRK12C
   wire 	 brk12c_brken2_din;	// Input to the BRKEN2 bit of BRK12C
   wire 	 brk12c_subk1_din;	// Input to the SUBK1 bit of BRK12C
   wire [1:0] 	 brk12c_srcbk1_din;	// Input to the SRCBK1 bit of BRK12C
   wire 	 brk12c_brken1_din;	// Input to the BRKEN1 bit of BRK12C
   wire [31:2] 	 sc_bottom_din;		// Input to the SC_BOTTOM register

   wire [2:0] 	 oplim_din_31_mux_sel;	/* 4: Select 0 when there's a oplim trap
					 * 2: Select POR value
					 * 1: Select data_in[31]
					 */
   wire [2:0] 	 sc_bottom_din_mux_sel;	/* 4: Select POR value
					 * 2: Select smu_sbase
					 * 1: Select data_in
					 */
   wire 	 vars_we;		// Write-enable signal of VARS reg.
   wire 	 oplim_we;		// Write-enable signal of OPLIM reg.
   wire 	 oplim_31_we;		// Write-enable signal of OPLIM[31] reg.
   wire 	 const_pool_we;		// Write-enable signal of CONST_POOL reg
   wire 	 psr_we;		// Write-enable signal of PSR reg.
   wire 	 gc_config_we;		// Write-enable signal of GC_CONFIG reg.
   wire 	 brk12c_we;		// Write-enable signal of BRK12C reg.
   wire 	 sc_bottom_we;		// Write-enable signal of SC_BOTTOM reg.

   wire [31:0] 	 frame_out;		// Output of the FRAME register
   wire [31:0] 	 oplim_out;		// Output of the OPLIM register
   wire [31:0] 	 const_pool_out;	// Output of the CONST_POOL register
   wire [31:0] 	 trapbase_out;		// Output of the TRAPBASE register
   wire [31:0] 	 lockcount0_out;	// Output of the LOCKCOUNT0 register
   wire [31:0] 	 lockcount1_out;	// Output of the LOCKCOUNT1 register
   wire [31:0] 	 lockaddr0_out;		// Output of the LOCKADDR0 register
   wire [31:0] 	 lockaddr1_out;		// Output of the LOCKADDR1 register
   wire [31:0] 	 userrange1_out;	// Output of the USERRANGE1 register
   wire [31:0] 	 gc_config_out;		// Output of the GC_CONFIG register
   wire [31:0] 	 brk1a_out;		// Output of the BRK1A register
   wire [31:0] 	 brk2a_out;		// Output of the BRK2A register
   wire [31:0] 	 userrange2_out;	// Output of the USERRANGE2 register
   wire [31:0] 	 versionid_out;		// Output of the VERSIONID register
   wire [31:0] 	 hcr_out;		// Output of the HCR register

   wire [31:0] 	 pc_w;			// W stage PC register
   wire [31:0] 	 vars_w;		// W stage VARS register
   wire [31:0] 	 frame_w;		// W stage FRAME register
   wire [31:0] 	 optop_w;		// W stage OPTOP register
   wire [31:0] 	 oplim_w;		// W stage OPLIM register
   wire [31:0] 	 const_pool_w;		// W stage CONST_POOL register
   wire [31:0] 	 psr_w;			// W stage PSR register
   wire [31:0] 	 trapbase_w;		// W stage TRAPBASE register
   wire [31:0] 	 lockcount0_w;		// W stage LOCKCOUNT0 register
   wire [31:0] 	 lockcount1_w;		// W stage LOCKCOUNT1 register
   wire [31:0] 	 lockaddr0_w;		// W stage LOCKADDR0 register
   wire [31:0] 	 lockaddr1_w;		// W stage LOCKADDR1 register
   wire [31:0] 	 userrange1_w;		// W stage USERRANGE1 register
   wire [31:0] 	 gc_config_w;		// W stage GC_CONFIG register
   wire [31:0] 	 brk1a_w;		// W stage BRK1A register
   wire [31:0] 	 brk2a_w;		// W stage BRK2A register
   wire [31:0] 	 brk12c_w;		// W stage BRK12C register
   wire [31:0] 	 userrange2_w;		// W stage USERRANGE2 register
   wire [31:0] 	 versionid_w;		// W stage VERSIONID register
   wire [31:0] 	 hcr_w;			// W stage HCR register
   wire [31:0] 	 sc_bottom_w;		// W stage SC_BOTTOM register

   wire [29:14]	 smu_addr_d1;		// Latched version of smu_addr
   wire 	 priv_update_optop_e;	// Latched version of priv_update_optop
   wire 	 range1_l_cmp1_gt;	// in1 > in2 in range1_l_cmp1
   wire 	 range1_l_cmp1_eq;	// in1 = in2 in range1_l_cmp1
   wire 	 range1_h_cmp1_lt;	// in1 < in2 in range1_h_cmp1
   wire 	 range2_l_cmp1_gt;	// in1 > in2 in range2_l_cmp1
   wire 	 range2_l_cmp1_eq;	// in1 = in2 in range2_l_cmp1
   wire 	 range2_h_cmp1_lt;	// in1 < in2 in range2_h_cmp1
   wire 	 range1_l_cmp2_gt;	// in1 > in2 in range1_l_cmp2
   wire 	 range1_l_cmp2_eq;	// in1 = in2 in range1_l_cmp2
   wire 	 range1_h_cmp2_lt;	// in1 < in2 in range1_h_cmp2
   wire 	 range2_l_cmp2_gt;	// in1 > in2 in range2_l_cmp2
   wire 	 range2_l_cmp2_eq;	// in1 = in2 in range2_l_cmp2
   wire 	 range2_h_cmp2_lt;	// in1 < in2 in range2_h_cmp2
   wire 	 oplim_gt;		// optop_c > oplim_out
   wire 	 oplim_eq;		// optop_c = oplim_out
   wire 	 oplim_lt;		// optop_c < oplim_out
   wire [7:0] 	 lc0_p1;		// lockcount0 value plus one
   wire [7:0] 	 lc0_m1;		// lockcount0 value minus one
   wire [7:0] 	 lc1_p1;		// lockcount1 value plus one
   wire [7:0] 	 lc1_m1;		// lockcount1 value minus one
   wire 	 lc0_m1_adder_cout;	// Carry output of lc0_m1_adder, ignored
   wire 	 lc1_m1_adder_cout;	// Carry output of lc1_m1_adder, ignored
   wire		 la0_reg_we;		// write enable for lockaddr0 register
   wire		 la1_reg_we;		// write enable for lockaddr1 register
   wire	[29:0]   la0_reg_din;		// input to the lockaddr0 register
   wire [29:0]   la1_reg_din;		// input to the lockaddr1 register 
   wire [29:0]   objref_c;		// object reference in C stage
   wire 	 la0_objref_sel;	// select objref_c for the input of lockaddr0 register
   wire 	 la1_objref_sel;	// select objref_c for the input of lockaddr1 register
   wire		 lc0_one_sel;		// select 1 to be the input to lockcount0 register
   wire		 lc1_one_sel;		// select 1 to be the input to lockcount1 register
   wire		 lc0_co_reset_l;	// reset signal of the cache-on bit of the lockcount0 register
   wire		 lc1_co_reset_l;	// reset signal of the cache-on bit of the lockcount1 register
   wire [31:0]   la0_w_reg_din;         // input to the lockaddress0 register in W stage
   wire [31:0]   la1_w_reg_din;         // input to the lockaddress1 register in W stage
   wire [31:0]   lc0_w_reg_din;         // input to the lockcount0 register in W stage
   wire [31:0]   lc1_w_reg_din;         // input to the lockcount1 register in W stage
   wire		 lc0_cacheon_din;       // input to the lockcount0 CO bit register
   wire		 lc1_cacheon_din;       // input to the lockcount1 CO bit register
   wire		 lc0_co_reg_en;	        // enable signal to the lockcount0 CO bit register
   wire		 lc1_co_reg_en;	        // enable signal to the lockcount1 CO bit register
   
   

   /* bit 0 selects PC, but it's an input from pipe */

   /**********  bit  1: VARS  *************************************************/
   assign vars_we = ~reset_l | (reg_wr_mux_sel[1] & ~hold_c);
   mux2_30 vars_din_mux(.out (vars_din[31:2]),
			.in1 (`VARS_POR_VALUE >> 2),
			.in0 (data_in[31:2]),
			.sel ({~reset_l, reset_l})
			);
   ff_se_30 vars_reg(.out    (vars_out[31:2]),
		     .din    (vars_din[31:2]),
		     .enable (vars_we),
		     .clk    (clk)
		     );
   assign vars_out[1:0] = 2'b00;		// Always word aligned

   /**********  bit  2: FRAME  ************************************************/
   ff_se_30 frame_reg(.out    (frame_out[31:2]),
		      .din    (data_in[31:2]),
		      .enable (reg_wr_mux_sel[2] & ~hold_c),
		      .clk    (clk)
		      );
   assign frame_out[1:0] = 2'b00;		// Always word aligned

   /**********  bit  4: OPLIM  ************************************************/
   assign oplim_we    = ~reset_l | reg_wr_mux_sel[4];
   /*
    * fold_c is asserted when in the folded group.  It is used to kill
    * the oplim trap as the inst. will be reissued. 
    */
   assign oplim_31_we = oplim_we | (oplim_trap_c & ~fold_c);
   assign oplim_din_31_mux_sel[2] = oplim_trap_c & ~fold_c & reset_l;
   assign oplim_din_31_mux_sel[1] = ~reset_l;
   assign oplim_din_31_mux_sel[0] = ~(|oplim_din_31_mux_sel[2:1]);
   mux3 oplim_din_31_mux(.out (oplim_din[31]),
			 .in2 (1'b0),
			 .in1 (`OPLIM_ENABLE_POR_VALUE),
			 .in0 (data_in[31]),
			 .sel (oplim_din_31_mux_sel[2:0])
			 );
   ff_se oplim_31_reg(.out    (oplim_out[31]),
		      .din    (oplim_din[31]),
		      .enable (oplim_31_we),
		      .clk    (clk)
		      );
   mux2_29 oplim_din_mux(.out (oplim_din[30:2]),
			 .in1 (`OPLIM_POR_VALUE >> 2),
			 .in0 (data_in[30:2]),
			 .sel ({~reset_l, reset_l})
			 );
   ff_se_29 oplim_reg(.out    (oplim_out[30:2]),
		      .din    (oplim_din[30:2]),
		      .enable (oplim_we),
		      .clk    (clk)
		      );
   assign oplim_out[1:0] = 2'b00;		// Always word aligned

   /**********  bit  5: CONST_POOL  *******************************************/
   assign const_pool_we = reg_wr_mux_sel[5] & ~hold_c;
   ff_se_30 const_pool_reg(.out	   (const_pool_out[31:2]),
			   .din	   (data_in[31:2]),
			   .enable (const_pool_we),
			   .clk	   (clk)
			   );
   assign const_pool_out[1:0] = 2'b00;

   /**********  bit  6: PSR  **************************************************/
   assign psr_we = ~reset_l | reg_wr_mux_sel[6];
   assign psr_out[31:23] = 9'b000000000;		// Bit 31:23
   mux2 psr_cac_mux(.out(psr_cac_din),			// Bit 22
		    .in1(`PSR_CAC_POR_VALUE),
		    .in0(data_in[22]),
		    .sel({~reset_l, reset_l}));
   ff_se psr_cac_reg(.out    (psr_out[22]),
		     .din    (psr_cac_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   ff_se_6 psr_dbh_dbl_reg(.out	   (psr_out[21:16]),	// Bit 21:16
			   .din	   (data_in[21:16]),
			   .enable (reg_wr_mux_sel[6]),
			   .clk	   (clk)
			   );
   /* 
    * DRT bit is made writable so it's the same as pico and ias.
    */
   mux2 psr_drt_mux(.out (psr_drt_din),			// Bit 15
		    .in1 (`PSR_DRT_POR_VALUE),
		    .in0 (data_in[15]),
		    .sel ({~reset_l, reset_l}));
   ff_se psr_drt_reg(.out    (psr_out[15]),
		     .din    (psr_drt_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   ff_sre psr_bm8_reg(.out    (psr_bm8_din),		// Bit 14
		      .din    (~data_in[14]),
		      .enable (reg_wr_mux_sel[6]),
		      .reset_l (reset_l),
		      .clk    (clk)
		      );
   assign psr_out[14] = pj_boot8_e & ~psr_bm8_din;
   mux2 psr_ace_din_mux(.out(psr_ace_din),		// Bit 13
			.in1(`PSR_ACE_POR_VALUE),
			.in0(data_in[13]),
			.sel({~reset_l, reset_l}));
   ff_se psr_ace_reg(.out    (psr_out[13]),
		     .din    (psr_ace_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_gce_din_mux(.out(psr_gce_din),		// Bit 12
			.in1(`PSR_GCE_POR_VALUE),
			.in0(data_in[12]),
			.sel({~reset_l, reset_l}));
   ff_se psr_gce_reg(.out    (psr_out[12]),
		     .din    (psr_gce_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_fpe_din_mux(.out(psr_fpe_din),		// Bit 11
			.in1(`PSR_FPE_POR_VALUE),
			.in0(data_in[11]),
			.sel({~reset_l, reset_l}));
   ff_se psr_fpe_reg(.out    (psr_out[11]),
		     .din    (psr_fpe_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_dce_din_mux(.out(psr_dce_din),		// Bit 10
			.in1(`PSR_DCE_POR_VALUE),
			.in0(data_in[10]),
			.sel({~reset_l, reset_l}));
   ff_se psr_dce_reg(.out    (psr_out[10]),
		     .din    (psr_dce_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_ice_din_mux(.out(psr_ice_din),		// Bit 9
			.in1(`PSR_ICE_POR_VALUE),
			.in0(data_in[9]),
			.sel({~reset_l, reset_l}));
   ff_se psr_ice_reg(.out    (psr_out[9]),
		     .din    (psr_ice_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_aem_din_mux(.out(psr_aem_din),		// Bit 8
			.in1(`PSR_AEM_POR_VALUE),
			.in0(data_in[8]),
			.sel({~reset_l, reset_l}));
   ff_se psr_aem_reg(.out    (psr_out[8]),
		     .din    (psr_aem_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_dre_din_mux(.out(psr_dre_din),		// Bit 7
			.in1(`PSR_DRE_POR_VALUE),
			.in0(data_in[7]),
			.sel({~reset_l, reset_l}));
   ff_se psr_dre_reg(.out    (psr_out[7]),
		     .din    (psr_dre_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_fle_din_mux(.out(psr_fle_din),		// Bit 6
			.in1(`PSR_FLE_POR_VALUE),
			.in0(data_in[6]),
			.sel({~reset_l, reset_l}));
   ff_se psr_fle_reg(.out    (psr_out[6]),
		     .din    (psr_fle_din),
		     .enable (psr_we),
		     .clk    (clk)
		     );
   mux2 psr_su_din_mux(.out(psr_su_din),		// Bit 5
		       .in1(`PSR_SU_POR_VALUE),
		       .in0(data_in[5]),
		       .sel({~reset_l, reset_l}));
   ff_se psr_su_reg(.out    (psr_out[5]),
		    .din    (psr_su_din),
		    .enable (psr_we),
		    .clk    (clk)
		    );
   mux2 psr_ie_din_mux(.out(psr_ie_din),		// Bit 4
		       .in1(`PSR_IE_POR_VALUE),
		       .in0(data_in[4]),
		       .sel({~reset_l, reset_l}));
   ff_se psr_ie_reg(.out    (psr_out[4]),
		    .din    (psr_ie_din),
		    .enable (psr_we),
		    .clk    (clk)
		    );
   ff_se_4 psr_pil_reg(.out    (psr_out[3:0]),		// Bit 3:0
		       .din    (data_in[3:0]),
		       .enable (reg_wr_mux_sel[6]),
		       .clk    (clk)
		       );

   /**********  bit  7: TRAPBASE  *********************************************/
   ff_se_21 trapbase_tba_reg(.out    (trapbase_out[31:11]),
			     .din    (data_in[31:11]),
			     .enable (reg_wr_mux_sel[7]),
			     .clk    (clk)
			     );
   // reset bit [10:3] to 0
   ff_sre_8 trapbase_tt_reg(.out    (trapbase_out[10:3]),
			    .din    (tbase_tt_e[7:0]),
			    .enable (tbase_tt_we_e),
			    .reset_l (reset_l),
			    .clk    (clk)
			    );
   assign trapbase_out[2:0] = 3'b000;

   /**********  bit  8: LOCKCOUNT0  *******************************************/
   assign lockcount0_out[31:16] = 16'h0;		// Reserved
   assign lc0_co_reset_l = ~lock0_uncache & reset_l;
   assign lc0_co_reg_en = lock0_cache | reg_wr_mux_sel[8];	

   ff_sre lockcount0_cacheon_reg(.out	 (lockcount0_out[15]),
				 .din	 (lc0_cacheon_din),
				 .enable (lc0_co_reg_en),
				 .reset_l(lc0_co_reset_l), 
				 .clk	 (clk)
				 );
   
   ff_se lockcount0_lockwant_reg(.out	 (lockcount0_out[14]),
				 .din	 (data_in[14]),
				 .enable (reg_wr_mux_sel[8]),
				 .clk	 (clk)
				 );
   assign lockcount0_out[13:8] = 6'h0;			// Reserved
   ff_se_8 lockcount0_count_reg(.out	(lockcount0_out[7:0]),
				.din	(lc0_count_din[7:0]),
				.enable (lc0_count_reg_we),
				.clk	(clk)
   				);
   assign lc0_co_bit = lockcount0_out[15];				
   assign lockwant0 = lockcount0_out[14];

   /**********  bit  9: LOCKCOUNT1  *******************************************/
   assign lockcount1_out[31:16] = 16'h0;		// Reserved
   assign lc1_co_reset_l = ~lock1_uncache & reset_l; 
   assign lc1_co_reg_en = lock1_cache | reg_wr_mux_sel[9];
   ff_sre lockcount1_cacheon_reg(.out	 (lockcount1_out[15]),
				 .din	 (lc1_cacheon_din),
				 .enable (lc1_co_reg_en),
				 .reset_l(lc1_co_reset_l), 
				 .clk	 (clk)
				 );
   ff_se lockcount1_lockwant_reg(.out	 (lockcount1_out[14]),
				 .din	 (data_in[14]),
				 .enable (reg_wr_mux_sel[9]),
				 .clk	 (clk)
				 );				 
   assign lockcount1_out[13:8] = 6'h0;			// Reserved
   ff_se_8 lockcount1_count_reg(.out	(lockcount1_out[7:0]),
				.din	(lc1_count_din[7:0]),
				.enable (lc1_count_reg_we),
				.clk	(clk)
				);
   assign lc1_co_bit = lockcount1_out[15];				
   assign lockwant1 = lockcount1_out[14];

   /**********  bit 10: LOCKADDR0  ********************************************/
   
   assign la0_reg_we = lock0_cache | reg_wr_mux_sel[10];
   
   ff_sre_30 lockaddr0_reg(.out	  (lockaddr0_out[31:2]),
			   .din	  (la0_reg_din[29:0]),
			   .enable (la0_reg_we),
			   .reset_l(~lock0_uncache),
			   .clk	  (clk)
			   );
   assign lockaddr0_out[1:0] = 2'b00;

   /**********  bit 11: LOCKADDR1  ********************************************/
   assign la1_reg_we = lock1_cache | reg_wr_mux_sel[11];

   ff_sre_30 lockaddr1_reg(.out	  (lockaddr1_out[31:2]),
			   .din	  (la1_reg_din[29:0]),
			   .enable (la1_reg_we),
			   .reset_l(~lock1_uncache),
			   .clk	  (clk)
			   );
   assign lockaddr1_out[1:0] = 2'b00;

   /**********  bit 12: USERRANGE1  *******************************************/
   ff_se_32 userrange1_reg(.out	   (userrange1_out[31:0]),
			   .din	   (data_in[31:0]),
			   .enable (reg_wr_mux_sel[12]),
			   .clk	   (clk)
			   );

   /**********  bit 13: GC_CONFIG  ********************************************/
   assign gc_config_we = ~reset_l | reg_wr_mux_sel[13];
   mux2_32 gc_config_din_mux(.out(gc_config_din[31:0]),
			     .in1(`GC_CONFIG_POR_VALUE),
			     .in0(data_in[31:0]),
			     .sel({~reset_l, reset_l}));
   ff_se_32 gc_config_reg(.out	  (gc_config_out[31:0]),
			  .din	  (gc_config_din[31:0]),
			  .enable (gc_config_we),
			  .clk	  (clk)
			  );

   /**********  bit 14: BRK1A  ************************************************/
   ff_se_32 brk1a_reg(.out    (brk1a_out[31:0]),
		      .din    (data_in[31:0]),
		      .enable (reg_wr_mux_sel[14]),
		      .clk    (clk)
		      );

   /**********  bit 15: BRK2A  ************************************************/
   ff_se_32 brk2a_reg(.out    (brk2a_out[31:0]),
		      .din    (data_in[31:0]),
		      .enable (reg_wr_mux_sel[15]),
		      .clk    (clk)
		      );

   /**********  bit 16: BRK12C  ***********************************************/
   assign brk12c_we = ~reset_l | reg_wr_mux_sel[16];
   mux2 brk12c_halt_din_mux(.out (brk12c_halt_din),
			    .in1 (`BRK12C_HALT_POR_VALUE),
			    .in0 (data_in[31]),
			    .sel ({~reset_l, reset_l})
			    );
   ff_se brk12c_halt_reg(.out    (brk12c_out[31]),
			 .din    (brk12c_halt_din),
			 .enable (brk12c_we),
			 .clk    (clk)
			 );
   mux2_7 brk12c_brkm2_din_mux(.out (brk12c_brkm2_din[6:0]),
			       .in1 (`BRK12C_BRKM2_POR_VALUE),
			       .in0 (data_in[30:24]),
			       .sel ({~reset_l, reset_l})
			       );
   ff_se_7 brk12c_brkm2_reg(.out    (brk12c_out[30:24]),
			    .din    (brk12c_brkm2_din[6:0]),
			    .enable (brk12c_we),
			    .clk    (clk)
			    );
   assign brk12c_out[23] = 1'b0;
   mux2_7 brk12c_brkm1_din_mux(.out (brk12c_brkm1_din[6:0]),
			       .in1 (`BRK12C_BRKM1_POR_VALUE),
			       .in0 (data_in[22:16]),
			       .sel ({~reset_l, reset_l})
			       );
   ff_se_7 brk12c_brkm1_reg(.out    (brk12c_out[22:16]),
			    .din    (brk12c_brkm1_din[6:0]),
			    .enable (brk12c_we),
			    .clk    (clk)
			    );
   assign brk12c_out[15:12] = 4'h0;
   mux2 brk12c_subk2_din_mux(.out(brk12c_subk2_din),
			     .in1(`BRK12C_SUBK2_POR_VALUE),
			     .in0(data_in[11]),
			     .sel({~reset_l, reset_l}));
   ff_se brk12c_subk2_reg(.out    (brk12c_out[11]),
			  .din    (brk12c_subk2_din),
			  .enable (brk12c_we),
			  .clk    (clk)
			  );
   mux2_2 brk12c_srcbk2_din_mux(.out (brk12c_srcbk2_din[1:0]),
				.in1 (`BRK12C_SRCBK2_POR_VALUE),
				.in0 (data_in[10:9]),
				.sel ({~reset_l, reset_l})
				);
   ff_se_2 brk12c_srcbk2_reg(.out    (brk12c_out[10:9]),
			     .din    (brk12c_srcbk2_din[1:0]),
			     .enable (brk12c_we),
			     .clk    (clk)
			     );
   mux2 brk12c_brken2_din_mux(.out (brk12c_brken2_din),
			      .in1 (`BRK12C_BRKEN2_POR_VALUE),
			      .in0 (data_in[8]),
			      .sel ({~reset_l, reset_l})
			      );
   ff_se brk12c_brken2_reg(.out	   (brk12c_out[8]),
			   .din	   (brk12c_brken2_din),
			   .enable (brk12c_we),
			   .clk	   (clk)
			   );
   assign brk12c_out[7:4] = 4'h0;
   mux2 brk12c_subk1_din_mux(.out (brk12c_subk1_din),
			     .in1 (`BRK12C_SUBK1_POR_VALUE),
			     .in0 (data_in[3]),
			     .sel ({~reset_l, reset_l})
			     );
   ff_se brk12c_subk1_reg(.out	  (brk12c_out[3]),
			  .din	  (brk12c_subk1_din),
			  .enable (brk12c_we),
			  .clk	  (clk)
			  );
   mux2_2 brk12c_srcbk1_din_mux(.out (brk12c_srcbk1_din[1:0]),
				.in1 (`BRK12C_SRCBK1_POR_VALUE),
				.in0 (data_in[2:1]),
				.sel ({~reset_l, reset_l})
				);
   ff_se_2 brk12c_srcbk1_reg(.out    (brk12c_out[2:1]),
			     .din    (brk12c_srcbk1_din[1:0]),
			     .enable (brk12c_we),
			     .clk    (clk)
			     );
   mux2 brk12c_brken1_din_mux(.out (brk12c_brken1_din),
			      .in1 (`BRK12C_BRKEN1_POR_VALUE),
			      .in0 (data_in[0]),
			      .sel ({~reset_l, reset_l})
			      );
   ff_se brk12c_brken1_reg(.out	   (brk12c_out[0]),
			   .din	   (brk12c_brken1_din),
			   .enable (brk12c_we),
			   .clk	   (clk)
			   );

   /**********  bit 17: USERRANGE2  *******************************************/
   ff_se_32 userrange2_reg(.out	   (userrange2_out[31:0]),
			   .din	   (data_in[31:0]),
			   .enable (reg_wr_mux_sel[17]),
			   .clk	   (clk)
			   );

   /**********  bit 18: VERSIONID  ********************************************/
   assign versionid_out[31:0] = `VERSIONID_POR_VALUE;

   /**********  bit 19: HCR  **************************************************/
   assign hcr_out[31:30] = 2'b00;
   assign hcr_out[29:27] = `HCR_DCL_POR_VALUE;
   assign hcr_out[26:24] = `HCR_ICL_POR_VALUE;
   assign hcr_out[23:21] = `HCR_DCS_POR_VALUE;
   assign hcr_out[20:18] = `HCR_ICS_POR_VALUE;
   assign hcr_out[17]    = ~pj_no_fpu_e;
   assign hcr_out[16:8]  = 9'h0;
   assign hcr_out[7:0]   = `HCR_SRN_POR_VALUE;

   /**********  bit 20: SC_BOTTOM  ********************************************/
   /*
    * priv_write_sc_bottom should not be executed once PSR.DRE is set to 1,
    * because SMU and IU could be writing to SC_BOTTOM at the same time, and
    * we don't handle that.
    */
   assign sc_bottom_din_mux_sel[2] = ~reset_l;
   assign sc_bottom_din_mux_sel[1] = reset_l & smu_sbase_we;
   assign sc_bottom_din_mux_sel[0] = reset_l & ~smu_sbase_we;
   assign sc_bottom_we = ~reset_l | reg_wr_mux_sel[18] | smu_sbase_we;
   mux3_30 sc_bottom_din_mux(.out(sc_bottom_din[31:2]),
			     .in2(`SC_BOTTOM_POR_VALUE >> 2),
			     .in1(smu_sbase[31:2]),
			     .in0(data_in[31:2]),
			     .sel(sc_bottom_din_mux_sel[2:0]));
   ff_se_30 sc_bottom_reg(.out	  (sc_bottom_out[31:2]),
			  .din	  (sc_bottom_din[31:2]),
			  .enable (sc_bottom_we),
			  .clk	  (clk)
			  );
   assign sc_bottom_out[1:0] = 2'b00;

   // Instantiate the register output mux
   mux21_32 reg_rd_mux(.out  (data_out[31:0]),
		       .in20 (sc_bottom_out[31:0]),
		       .in19 (hcr_out[31:0]),
		       .in18 (versionid_out[31:0]),
		       .in17 (userrange2_out[31:0]),
		       .in16 (brk12c_out[31:0]),
		       .in15 (brk2a_out[31:0]),
		       .in14 (brk1a_out[31:0]),
		       .in13 (gc_config_out[31:0]),
		       .in12 (userrange1_out[31:0]),
		       .in11 (lockaddr1_out[31:0]),
		       .in10 (lockaddr0_out[31:0]),
		       .in9  (lockcount1_out[31:0]),
		       .in8  (lockcount0_out[31:0]),
		       .in7  (trapbase_out[31:0]),
		       .in6  (psr_out[31:0]),
		       .in5  (const_pool_out[31:0]),
		       .in4  (oplim_out[31:0]),
		       .in3  (optop_c[31:0]),
		       .in2  (frame_out[31:0]),
		       .in1  (vars_out[31:0]),
		       .in0  (pc_e[31:0]),
		       .sel  (reg_rd_mux_sel[20:0])
		       );

   // Read port for ucode
   mux7_32 ucode_reg_data_mux(.out (ucode_reg_data[31:0]),
			      .in6 (trapbase_out[31:0]),
			      .in5 (gc_config_out[31:0]),
			      .in4 (psr_out[31:0]),
			      .in3 (const_pool_out[31:0]),
			      .in2 (frame_out[31:0]),
			      .in1 (vars_out[31:0]),
			      .in0 (pc_e[31:0]),
			      .sel (ucode_reg_data_mux_sel[6:0])
			      );

   // Latch all registers into W stage for cosim to check
   // synopsys translate_off
   ff_s_32 pc_w_reg(.out (pc_w[31:0]),
		    .din (pc_c[31:0]),
		    .clk (clk)
		    );
   ff_s_32 vars_w_reg(.out (vars_w[31:0]),
		      .din (vars_out[31:0]),
		      .clk (clk)
		      );
   ff_s_32 frame_w_reg(.out (frame_w[31:0]),
		       .din (frame_out[31:0]),
		       .clk (clk)
		       );
   ff_s_32 optop_w_reg(.out (optop_w[31:0]),
		       .din (optop_c[31:0]),
		       .clk (clk)
		       );
   ff_s_32 oplim_w_reg(.out (oplim_w[31:0]),
		       .din (oplim_out[31:0]),
		       .clk (clk)
		       );
   ff_s_32 const_pool_w_reg(.out (const_pool_w[31:0]),
			    .din (const_pool_out[31:0]),
			    .clk (clk)
			    );
   ff_s_32 psr_w_reg(.out (psr_w[31:0]),
		     .din (psr_out[31:0]),
		     .clk (clk)
		     );
   ff_s_32 trapbase_w_reg(.out (trapbase_w[31:0]),
			  .din (trapbase_out[31:0]),
			  .clk (clk)
			  );

   ff_s_32 lockcount0_w_reg(.out (lockcount0_w[31:0]),
			    .din (lockcount0_out[31:0]),
			    .clk (clk)
			    );

   
   ff_s_32 lockcount1_w_reg(.out (lockcount1_w[31:0]),
			    .din (lockcount1_out[31:0]),
			    .clk (clk)
			    );

			
   ff_s_32 lockaddr0_w_reg(.out (lockaddr0_w[31:0]),
			   .din (lockaddr0_out[31:0]),
			   .clk (clk)
			   );

   ff_s_32 lockaddr1_w_reg(.out (lockaddr1_w[31:0]),
			   .din (lockaddr1_out[31:0]),
			   .clk (clk)
			   );
   ff_s_32 userrange1_w_reg(.out (userrange1_w[31:0]),
			    .din (userrange1_out[31:0]),
			    .clk (clk)
			    );
   ff_s_32 gc_config_w_reg(.out (gc_config_w[31:0]),
			   .din (gc_config_out[31:0]),
			   .clk (clk)
			   );
   ff_s_32 brk1a_w_reg(.out (brk1a_w[31:0]),
		       .din (brk1a_out[31:0]),
		       .clk (clk)
		       );
   ff_s_32 brk2a_w_reg(.out (brk2a_w[31:0]),
		       .din (brk2a_out[31:0]),
		       .clk (clk)
		       );
   ff_s_32 brk12c_w_reg(.out (brk12c_w[31:0]),
			.din (brk12c_out[31:0]),
			.clk (clk)
			);
   ff_s_32 userrange2_w_reg(.out (userrange2_w[31:0]),
			    .din (userrange2_out[31:0]),
			    .clk (clk)
			    );
   ff_s_32 versionid_w_reg(.out (versionid_w[31:0]),
			   .din (versionid_out[31:0]),
			   .clk (clk)
			   );
   ff_s_32 hcr_w_reg(.out (hcr_w[31:0]),
		     .din (hcr_out[31:0]),
		     .clk (clk)
		     );
   ff_s_32 sc_bottom_w_reg(.out (sc_bottom_w[31:0]),
			   .din (sc_bottom_out[31:0]),
			   .clk (clk)
			   );
   // synopsys translate_on

   /****************************************************************************
    * mem_protection_error
    ***************************************************************************/

   // Check extended ld/st using iu_addr_c
   ucmp_16 range1_l_cmp1(.in1 (iu_addr_c[29:14]),
			 .in2 (userrange1_out[15:0]),
			 .gt  (range1_l_cmp1_gt),
			 .eq  (range1_l_cmp1_eq),
			 .lt  (range1_l_cmp1_lt)
			 );
   ucmp_16 range1_h_cmp1(.in1 (iu_addr_c[29:14]),
			 .in2 (userrange1_out[31:16]),
			 .gt  (range1_h_cmp1_gt),
			 .eq  (range1_h_cmp1_eq),
			 .lt  (range1_h_cmp1_lt)
			 );
   ucmp_16 range2_l_cmp1(.in1 (iu_addr_c[29:14]),
			 .in2 (userrange2_out[15:0]),
			 .gt  (range2_l_cmp1_gt),
			 .eq  (range2_l_cmp1_eq),
			 .lt  (range2_l_cmp1_lt)
			 );
   ucmp_16 range2_h_cmp1(.in1 (iu_addr_c[29:14]),
			 .in2 (userrange2_out[31:16]),
			 .gt  (range2_h_cmp1_gt),
			 .eq  (range2_h_cmp1_eq),
			 .lt  (range2_h_cmp1_lt)
			 );

   /****************************************************************************
    * asynchronous_error due to smu access
    ***************************************************************************/
   // Check stack access using smu_addr
   ff_sr_16 smu_addr_reg(.out	  (smu_addr_d1[29:14]),
			 .din	  (smu_addr[29:14]),
			 .reset_l (reset_l),
			 .clk	  (clk)
			 );
   ucmp_16 range1_l_cmp2(.in1 (smu_addr_d1[29:14]),
			 .in2 (userrange1_out[15:0]),
			 .gt  (range1_l_cmp2_gt),
			 .eq  (range1_l_cmp2_eq),
			 .lt  (range1_l_cmp2_lt)
			 );
   ucmp_16 range1_h_cmp2(.in1 (smu_addr_d1[29:14]),
			 .in2 (userrange1_out[31:16]),
			 .gt  (range1_h_cmp2_gt),
			 .eq  (range1_h_cmp2_eq),
			 .lt  (range1_h_cmp2_lt)
			 );
   ucmp_16 range2_l_cmp2(.in1 (smu_addr_d1[29:14]),
			 .in2 (userrange2_out[15:0]),
			 .gt  (range2_l_cmp2_gt),
			 .eq  (range2_l_cmp2_eq),
			 .lt  (range2_l_cmp2_lt)
			 );
   ucmp_16 range2_h_cmp2(.in1 (smu_addr_d1[29:14]),
			 .in2 (userrange2_out[31:16]),
			 .gt  (range2_h_cmp2_gt),
			 .eq  (range2_h_cmp2_eq),
			 .lt  (range2_h_cmp2_lt)
			 );

   /****************************************************************************
    * breakpoint1 and breakpoint2
    ***************************************************************************/
   cmp_eq_19 data_brk1_31_13_cmp(.in1 ({2'b00,iu_addr_e[29:13]}),
				 .in2 (brk1a_out[31:13]),
				 .eq  (data_brk1_31_13_eq)
				 );
   cmp_eq_8 data_brk1_11_4_cmp(.in1 (iu_addr_e[11:4]),
			       .in2 (brk1a_out[11:4]),
			       .eq  (data_brk1_11_4_eq)
			       );
   assign data_brk1_misc_eq[4]   = ~(iu_addr_e[12]  ^ brk1a_out[12]);
   assign data_brk1_misc_eq[3:0] = ~(iu_addr_e[3:0] ^ brk1a_out[3:0]);
   cmp_eq_19 data_brk2_31_13_cmp(.in1 ({2'b00,iu_addr_e[29:13]}),
				 .in2 (brk2a_out[31:13]),
				 .eq  (data_brk2_31_13_eq)
				 );
   cmp_eq_8 data_brk2_11_4_cmp(.in1 (iu_addr_e[11:4]),
			       .in2 (brk2a_out[11:4]),
			       .eq  (data_brk2_11_4_eq)
			       );
   assign data_brk2_misc_eq[4]   = ~(iu_addr_e[12]  ^ brk2a_out[12]);
   assign data_brk2_misc_eq[3:0] = ~(iu_addr_e[3:0] ^ brk2a_out[3:0]);
   cmp_eq_19 inst_brk1_31_13_cmp(.in1 (pc_r[31:13]),
				 .in2 (brk1a_out[31:13]),
				 .eq  (inst_brk1_31_13_eq)
				 );
   cmp_eq_8 inst_brk1_11_4_cmp(.in1 (pc_r[11:4]),
			       .in2 (brk1a_out[11:4]),
			       .eq  (inst_brk1_11_4_eq)
			       );
   assign inst_brk1_misc_eq[4]   = ~(pc_r[12]  ^ brk1a_out[12]);
   assign inst_brk1_misc_eq[3:0] = ~(pc_r[3:0] ^ brk1a_out[3:0]);
   cmp_eq_19 inst_brk2_31_13_cmp(.in1 (pc_r[31:13]),
				 .in2 (brk2a_out[31:13]),
				 .eq  (inst_brk2_31_13_eq)
				 );
   cmp_eq_8 inst_brk2_11_4_cmp(.in1 (pc_r[11:4]),
			       .in2 (brk2a_out[11:4]),
			       .eq  (inst_brk2_11_4_eq)
			       );
   assign inst_brk2_misc_eq[4]   = ~(pc_r[12]  ^ brk2a_out[12]);
   assign inst_brk2_misc_eq[3:0] = ~(pc_r[3:0] ^ brk2a_out[3:0]);

   /****************************************************************************
    * oplim_trap
    ***************************************************************************/
   cmp_32 oplim_cmp(.in1  (optop_c[31:0]),
		    .in2  ({1'b0, oplim_out[30:0]}),
		    .sign (1'b0),
		    .gt   (oplim_gt),
		    .eq   (oplim_eq),
		    .lt   (oplim_lt)
		    );
   ff_se priv_update_optop_reg(.out    (priv_update_optop_e),
			       .din    (priv_update_optop),
			       .enable (~hold_e),
			       .clk    (clk)
			       );
   assign oplim_trap_c = oplim_lt & inst_valid[1] & oplim_out[31] &
			 ~priv_update_optop_e;

   /****************************
    * runtime_NullPtrException *
    ****************************/

   /************************************************************************
    *									   *
    * Lock related exceptions:						   *
    *	LockCountOverflowTrap, LockEnterMissTrap, LockExitMissTrap, and	   *
    *	LockReleaseTrap.						   *
    *									   *
    * Notice: We don't handle the case where objref in data_in equals both *
    *	      lockaddr0 and lockaddr1.					   *
    *									   *
    ************************************************************************/
   
   /******************** monitor caching change  *****************/
      
   compare_zero_32 la0_null_cmp(.in({4'h0, lockaddr0_out[29:2]}),
			.out(la0_null_e));
   compare_zero_32 la1_null_cmp(.in({4'h0, lockaddr1_out[29:2]}),
			.out(la1_null_e));
   
   // data_in in E stage to become objref_c in C stage
   
   ff_se_30 objref_c_reg(.out	(objref_c[29:0]),
   			 .din	(data_in[31:2]),
   			 .enable(~hold_c),
   			 .clk	(clk)
   			 );
   			 
   // muxes to select the din of la0 and la1 registers
   
   assign la0_objref_sel = lock0_cache & ~reg_wr_mux_sel[10];
   
   mux2_30 la0_reg_din_mux(.out	(la0_reg_din[29:0]),
   			   .in1	(objref_c[29:0]),
   			   .in0 (data_in[31:2]),
   			   .sel ({la0_objref_sel, reg_wr_mux_sel[10]})
   			   );
   			 
   assign la1_objref_sel = lock1_cache & ~reg_wr_mux_sel[11];
   
   mux2_30 la1_reg_din_mux(.out	(la1_reg_din[29:0]),
   			   .in1	(objref_c[29:0]),
   			   .in0 (data_in[31:2]),
   			   .sel ({la1_objref_sel, reg_wr_mux_sel[11]})
   			   );
   			 	
   
   comp_eq_32 la0_cmp(.in1 ({4'h0, lockaddr0_out[29:2]}),
		      .in2 ({4'h0, data_in[29:2]}),
		      .eq  (la0_hit)
		      );
   comp_eq_32 la1_cmp(.in1 ({4'h0, lockaddr1_out[29:2]}),
		      .in2 ({4'h0, data_in[29:2]}),
		      .eq  (la1_hit)
		      );
   cmp_eq_8 lc0_cmp(.in1 (lockcount0_out[7:0]),
		    .in2 (8'h00),
		    .eq  (lc0_eq_0)
		    );
   cmp_eq_8 lc1_cmp(.in1 (lockcount1_out[7:0]),
		    .in2 (8'h00),
		    .eq  (lc1_eq_0)
		    );
   // The carry output of these 8-bit adders are not needed
   cla_adder_8 lc0_p1_adder(.in1  (lockcount0_out[7:0]),
			    .in2  (8'h1),
			    .cin  (1'b0),
			    .sum  (lc0_p1[7:0]),
			    .cout (lc0_eq_255)
			    );
   cla_adder_8 lc0_m1_adder(.in1  (lockcount0_out[7:0]),
			    .in2  (8'hff),
			    .cin  (1'b0),
			    .sum  (lc0_m1[7:0]),
			    .cout (lc0_m1_adder_cout)
			    );
   cla_adder_8 lc1_p1_adder(.in1  (lockcount1_out[7:0]),
			    .in2  (8'h1),
			    .cin  (1'b0),
			    .sum  (lc1_p1[7:0]),
			    .cout (lc1_eq_255)
			    );
   cla_adder_8 lc1_m1_adder(.in1  (lockcount1_out[7:0]),
			    .in2  (8'hff),
			    .cin  (1'b0),
			    .sum  (lc1_m1[7:0]),
			    .cout (lc1_m1_adder_cout)
			    );
   cmp_eq_8 lc0_m1_cmp(.in1 (lc0_m1[7:0]),
		       .in2 (8'h0),
		       .eq  (lc0_m1_eq_0)
		       );
   cmp_eq_8 lc1_m1_cmp(.in1 (lc1_m1[7:0]),
		       .in2 (8'h0),
		       .eq  (lc1_m1_eq_0)
		       );
   /******************** monitor caching change  *****************/
   
   mux4_8 lc0_din_mux(.out (lc0_count_din[7:0]),
   		      .in3 (8'h1),
		      .in2 (lc0_p1[7:0]),
		      .in1 (lc0_m1[7:0]),
		      .in0 (data_in[7:0]),
		      .sel (lc0_din_mux_sel[3:0])
		      );
   // set and reset lc0 CO bit
   
   mux2 lc0_cacheon_din_mux(.out (lc0_cacheon_din),
   			    .in1 (1'b1),
   			    .in0 (data_in[15]),
   			    .sel ({lock0_cache, ~lock0_cache})
   			    );

   mux4_8 lc1_din_mux(.out (lc1_count_din[7:0]),
		      .in3 (8'h1),	
		      .in2 (lc1_p1[7:0]),
		      .in1 (lc1_m1[7:0]),
		      .in0 (data_in[7:0]),
		      .sel (lc1_din_mux_sel[3:0])
		      );

   // set and reset lc1 CO bit
   
   mux2 lc1_cacheon_din_mux(.out (lc1_cacheon_din),
   			    .in1 (1'b1),
   			    .in0 (data_in[15]),
   			    .sel ({lock1_cache, ~lock1_cache})
   			    );
endmodule // ex_regs

/*******************************************************************************
 *
 * Module:	mux21_32
 * 
 * This module implements the 21:1 32-bit mux
 * 
 ******************************************************************************/
module mux21_32(out,
		in20,
		in19,
		in18,
		in17,
		in16,
		in15,
		in14,
		in13,
		in12,
		in11,
		in10,
		in9,
		in8,
		in7,
		in6,
		in5,
		in4,
		in3,
		in2,
		in1,
		in0,
		sel);

   input [31:0]	in20;		// Input data bus
   input [31:0] in19;		// Input data bus
   input [31:0] in18;		// Input data bus
   input [31:0] in17;		// Input data bus
   input [31:0] in16;		// Input data bus
   input [31:0] in15;		// Input data bus
   input [31:0] in14;		// Input data bus
   input [31:0] in13;		// Input data bus
   input [31:0]	in12;		// Input data bus
   input [31:0]	in11;		// Input data bus
   input [31:0]	in10;		// Input data bus
   input [31:0]	in9;		// Input data bus
   input [31:0]	in8;		// Input data bus
   input [31:0]	in7;		// Input data bus
   input [31:0]	in6;		// Input data bus
   input [31:0]	in5;		// Input data bus
   input [31:0]	in4;		// Input data bus
   input [31:0]	in3;		// Input data bus
   input [31:0]	in2;		// Input data bus
   input [31:0]	in1;		// Input data bus
   input [31:0] in0;		// Input data bus
   input [20:0] sel;		// Input select signal
   output [31:0] out;		// Output data bus

   wire [31:0] 	mux1_out;	// Output data of the 1st 4:1 mux
   wire [31:0] 	mux2_out;	// Output data of the 2nd 4:1 mux
   wire [31:0] 	mux3_out;	// Output data of the 3rd 4:1 mux
   wire [31:0] 	mux4_out;	// Output data of the 4th 4:1 mux
   wire [31:0] 	mux5_out;	// Output data of the 5th 5:1 mux
   wire 	mux1_sel;	// Select signal for mux1 output
   wire 	mux2_sel;	// Select signal for mux2 output
   wire 	mux3_sel;	// Select signal for mux3 output
   wire 	mux4_sel;	// Select signal for mux4 output
   wire 	mux5_sel;	// Select signal for mux5 output

   /*
    * It's the responsibility of the control logic to ensure that no more than
    * one register select signal is active at a time to protect the muxes.
    * Structure of the mux is: 4:1 4:1 4:1 4:1 5:1
    *				       5:1
    */
   // First stage muxes
   mux4_32 kmux1(.out(mux1_out[31:0]),
		 .in3(in3[31:0]),
		 .in2(in2[31:0]),
		 .in1(in1[31:0]),
		 .in0(in0[31:0]),
		 .sel(sel[3:0]));
   mux4_32 kmux2(.out(mux2_out[31:0]),
		 .in3(in7[31:0]),
		 .in2(in6[31:0]),
		 .in1(in5[31:0]),
		 .in0(in4[31:0]),
		 .sel(sel[7:4]));
   mux4_32 kmux3(.out(mux3_out[31:0]),
		 .in3(in11[31:0]),
		 .in2(in10[31:0]),
		 .in1(in9[31:0]),
		 .in0(in8[31:0]),
		 .sel(sel[11:8]));
   mux4_32 kmux4(.out(mux4_out[31:0]),
		 .in3(in15[31:0]),
		 .in2(in14[31:0]),
		 .in1(in13[31:0]),
		 .in0(in12[31:0]),
		 .sel(sel[15:12]));
   mux5_32 kmux5(.out(mux5_out[31:0]),
		 .in4(in20[31:0]),
		 .in3(in19[31:0]),
		 .in2(in18[31:0]),
		 .in1(in17[31:0]),
		 .in0(in16[31:0]),
		 .sel(sel[20:16]));
   assign mux1_sel = |sel[3:0];
   assign mux2_sel = |sel[7:4];
   assign mux3_sel = |sel[11:8];
   assign mux4_sel = |sel[15:12];
   assign mux5_sel = |sel[20:16];

   // Second stage 5:1 mux
   mux5_32 kmux(.out(out[31:0]),
		.in4(mux5_out[31:0]),
		.in3(mux4_out[31:0]),
		.in2(mux3_out[31:0]),
		.in1(mux2_out[31:0]),
		.in0(mux1_out[31:0]),
		.sel({mux5_sel, mux4_sel, mux3_sel, mux2_sel, mux1_sel}));

endmodule // mux21_32
