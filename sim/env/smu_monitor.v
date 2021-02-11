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

module smu_monitor(
	pj_clk,
	pj_reset,
	und_flw_bit,
	num_entries,
	fill_d,
	spill_d,
	und_flw_d,
	ovr_flw_d,
	low_mark,
	high_mark,
	less_than_6,
	dribble_stall,
	smu_st,
	smu_data,
	smu_data_vld,
	dcu_data,
	spill,
	fill,
	iu_int,
	dcu_smu_st,
	dcu_smu_data,
	smu_monitor_end_sim,
	smu_sbase,
	smu_sbase_we,
	smu_we,
	load_w,
	squash_fill
	);

input 		pj_clk;
input		pj_reset;
input		und_flw_bit;
input	[29:0]	num_entries;
input		fill_d;
input		spill_d;
input		und_flw_d;
input		ovr_flw_d;
input	[5:0]	low_mark;
input	[5:0]	high_mark;
input		less_than_6;
input		dribble_stall;
input		smu_st;
input	[31:0]	smu_data;
input		smu_data_vld;
input	[31:0]	dcu_data;
input		spill;
input		fill;
input		iu_int;
input		dcu_smu_st;
input	[31:0]	dcu_smu_data;
input	[31:0]	smu_sbase;
input		smu_sbase_we;
input		smu_we;
input		load_w;
input		squash_fill;
output		smu_monitor_end_sim;

reg		smu_monitor_end_sim;

initial begin
  smu_monitor_end_sim = 'b0;
end

always @(posedge pj_clk) begin
  #2;
  if(pj_reset == 1'b0) begin
    if( (und_flw_bit == 1'b0) && (num_entries >= 6'd60))  begin
      $display ($stime," SMU rtl: there are more than 60 (%d) entries in stack cache\n", num_entries);
    end
  end
  if(fill_d == 1'b1) begin
    if((und_flw_d == 1'b0) && (pj_reset == 1'b0)) begin
      if(num_entries >= low_mark) begin
        $display($stime," ERROR: fill is asserted with %d entries\n",
                          num_entries);
      end
    end
  end
  if(spill_d == 1'b1) begin
    if((ovr_flw_d == 1'b0) && (pj_reset == 1'b0)) begin
      if(num_entries <= high_mark) begin
        $display($stime," ERROR: spill is asserted with %d entries\n",
                          num_entries);
      end
    end
  end
  if (less_than_6 == 1'b1) begin
    if (dribble_stall != 1'b1) begin
      $display ($stime, " ERROR: IU is not stalled when less than 6 S$ entries.");
    end
  end
  if (smu_st == 1'b1) begin
    if (^smu_data == 1'bx) begin
      $display ($stime, " ERROR: smu_st is asserted when smu_data = %h",
                         smu_data);
    end
  end
  if (smu_data_vld == 1'b1) begin
    if (^dcu_data == 1'bx) begin
      $display ($stime, " ERROR: dcu writing xx's to s$. dcu_data = %h",
                         dcu_data);
    end
  end
  if (spill == 1'b1) begin
    if (fill == 1'b1) begin
      $display ($stime, " ERROR: spill and fill asserted at the same time.");
    end
  end

`ifdef VERBOSE_SMU_MON

  if (iu_int == 1'b1) begin
    $display($stime, " iu_int asserted.");
  end
  if(num_entries > high_mark) begin
    $display($stime," num_entries = %d", num_entries);
  end
  if(num_entries < low_mark) begin
    $display($stime," num_entries = %d", num_entries);
  end

`endif
 
  if ((dcu_smu_st == 1'b1) && (^dcu_smu_data === 1'bx)) begin
    $display ("SMU:ERROR: Xs being written to Data cache by smu , %h",
               dcu_smu_data);
    smu_monitor_end_sim = 'b1;
  end
end


reg [31:0] mem_data,smu_ld_data;
integer dsv_status;

 always @(posedge pj_clk) begin

if ($test$plusargs("smu_check")) begin


	if (squash_fill & smu_sbase_we & smu_we)
		$display("\nSmu Monitor: WARNING: Clk: %d: Data being written to S$ during update of SC_Bottom = Optop\n",`PICOJAVAII.clk_count);

	if (!`PICOJAVAII.`DESIGN.dcu.iu_psr_dce & smu_sbase_we & !squash_fill & load_w) begin

		mem_data = 32'h0;
		$decaf_cm_read(smu_sbase,mem_data, 2'b10,dsv_status);
		smu_ld_data = `PICOJAVAII.`DESIGN.iu.rcu.rcu_dpath.smu_data;

		if (dsv_status && (mem_data !== smu_ld_data)) begin
			$display("\nSmu Monitor: Error: Data Mismatch for smu fills\n");
			$display("Clk: %d\tExpected Data: %x\tRTL data: %x\n",`PICOJAVAII.clk_count,mem_data,smu_ld_data);
		end
	end		
end
end

endmodule

