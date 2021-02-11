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



module	smu (

	iu_optop_in,
	iu_optop_int_we,
	iu_data_in,
	iu_sbase_we,
	smu_addr,
	smu_data,
	smu_sbase,
	smu_sbase_we,
	smu_ld,
	smu_st,
	smu_stall,
	iu_psr_dre,
	iu_int,
	smu_we,
	low_mark,
	high_mark,
	smu_hold,
	smu_data_vld,
	smu_st_c,
	iu_smu_flush,
	smu_rf_addr,
	smu_rf_din,
	iu_rf_dout,
	dcu_data,
	ret_optop_update,
	smu_prty,

	iu_smiss,
	iu_address,
	iu_data,
	smu_na_st,

	clk,
	sm,
	so,
	sin,
	reset_l );


input	[31:0]	iu_optop_in;	// iu_optop_c value at din input of the flop  
input		iu_optop_int_we;// Corresponding wite enable signal
input	[31:0]	iu_data_in;	// sbase value from IU to be writtne onto act sbase value
				// in case of wr_sbase ops, etc
input		iu_sbase_we;	// Corresponding sbase we signal from iu
input	[31:0]	iu_rf_dout ;	// Data from IU 
input		smu_data_vld;	// Data on the dcache data bus is valid
input	[31:0]	dcu_data;	// Data bus from Dcache .
output	[31:0]	smu_rf_din;	// Data bus to IU
input		smu_stall;	// Stall the smu from issuing any ld/st to dcu
input		iu_psr_dre;	// Dribller enable bit from Iu
input		iu_int;		// Input from IU which tells SMU that there is
				// an interrupt while handling overflows/underflows
input	[5:0]	low_mark;
input	[5:0]	high_mark;
input		clk;
input		sin;
input		sm;
input		reset_l;
input		smu_st_c;
input		ret_optop_update;
output		smu_prty;
input		iu_smu_flush;	// Signal from IU which is generated as a result of
                                // IU wanting to write d$ in locations between sb-2 
				// and sb+2.
                                // This will create a RAW and WAW hazards as dribbler
                                // is busy fetching data to these locations in scache
input		iu_smiss;	// Signal from IU which is generated as a result of a 
				// istore miss
input	[31:0]	iu_address;	// istore miss address from IU 
input	[31:0]	iu_data;	// istore miss data from IU

output 	[31:0]	smu_data;	// data to the dcache
output	[31:0]	smu_addr;	// addr to the dcache
output		smu_ld;		// load inst to dcache
output		smu_st;		// store inst to dcache
output		so;	
output		smu_we;		// Write enable to Register file
output	[31:0]	smu_sbase;	// New stackbase to be updated .
output          smu_sbase_we;   // Write Enable to  for stackbase register.
output		smu_hold;	// hold the iu/microcode pipe.
output	[5:0]	smu_rf_addr;	// reg file addr for the port being used by smu
output		smu_na_st;	// Tell DCU that it is a non-allocate store 

wire	[29:0]	num_entries;
wire	[2:0]	iu_sbase_int_sel;
wire		iu_sbase_int_we;
wire		zero_entries_fl;
wire		und_flw_bit;
wire	[1:0]	nxt_sb_sel;
wire	[1:0]	dcache_sb_sel;	
wire	[1:0]	sbase_sel;	
wire		optop_en;
wire		spill;
wire		fill;
wire		sbase_hold;
wire	[1:0]	scache_addr_sel;
wire	[1:0]	smu_data_sel;	


smu_ctl smu_ctl	(
	
.smu_prty(smu_prty),
.iu_sbase_we(iu_sbase_we),
.num_entries(num_entries),
.iu_flush(iu_smu_flush),
.zero_entries_fl(zero_entries_fl),
.und_flw_bit(und_flw_bit),
.low_mark(low_mark),
.high_mark(high_mark),
.clk(clk),
.sm(),
.sin(),
.so(),
.ret_optop_update(ret_optop_update),
.reset_l(reset_l),
.iu_sbase_int_we(iu_sbase_int_we),
.iu_sbase_int_sel(iu_sbase_int_sel),
.nxt_sb_sel(nxt_sb_sel),
.dcache_sb_sel(dcache_sb_sel),
.sbase_sel(sbase_sel),
.scache_addr_sel(scache_addr_sel),
.iu_psr_dre(iu_psr_dre),
.smu_data_vld(smu_data_vld),
.iu_int(iu_int),
.spill(spill),
.fill(fill),
.smu_st_c(smu_st_c),
.dribble_stall(smu_hold),
.smu_we(smu_we),
.smu_ld(smu_ld),
.smu_st(smu_st),
.sbase_hold(sbase_hold),
.smu_sbase_we(smu_sbase_we),
.optop_en(optop_en),

.iu_smiss(iu_smiss),
.smu_data_sel(smu_data_sel),
.dcu_smu_stall(smu_stall),	// New smu_stall = stall signal from DCU 
				// (dcu_smu_stall) and iu_smiss 
.smu_addr(smu_addr[3:2]),
.smu_na_st(smu_na_st)
);


smu_dpath smu_dpath (

.iu_optop_in(iu_optop_in),
.iu_optop_int_we(iu_optop_int_we),
.iu_data_in(iu_data_in),
.smu_sbase(smu_sbase),
.num_entries(num_entries),
.und_flw_bit(und_flw_bit),
.optop_en(optop_en),
.zero_entries_fl(zero_entries_fl),
.sbase_hold(sbase_hold),
.smu_addr(smu_addr),
.smu_rf_addr(smu_rf_addr),
.nxt_sb_sel(nxt_sb_sel),
.iu_sbase_int_we(iu_sbase_int_we),
.iu_sbase_int_sel(iu_sbase_int_sel),
.dcache_sb_sel(dcache_sb_sel),
.sbase_sel(sbase_sel),
.scache_addr_sel(scache_addr_sel),
.smu_data(smu_data),
.dcu_data(dcu_data),
.smu_rf_din(smu_rf_din),
.iu_rf_dout(iu_rf_dout),
.fill(fill),
.spill(spill),

.iu_address(iu_address),
.iu_data(iu_data),
.smu_data_sel(smu_data_sel),

.clk(clk),
.sin(),
.so(),
.sm()

);

endmodule
