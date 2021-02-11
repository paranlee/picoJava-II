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


module fold_monitor(
	clk
/*	ibuff_0,
	ibuff_1,
	ibuff_2,
	ibuff_3,
	ibuff_4,
	ibuff_5,
	ibuff_6, 
	accum_len0,
	accum_len1,
	accum_len2,
	inst_1_type,
	inst_2_type,
	inst_3_type,
	inst_4_type,  */
	);

input 	clk;
/* input	[7:0] ibuff_0;
input	[7:0] ibuff_1;
input	[7:0] ibuff_2;
input	[7:0] ibuff_3;
input	[7:0] ibuff_4;
input	[7:0] ibuff_5;
input	[7:0] ibuff_6;
input	[7:0] accum_len0;
input	[7:0] accum_len1;
input	[7:0] accum_len2;
input	[5:0] inst_1_type;
input	[5:0] inst_2_type;
input	[5:0] inst_3_type;
input	[5:0] inst_4_type; */

integer trap_count, fold_num, fold_enable, debug;
integer inst0_type, inst1_type,inst2_type,inst3_type, inst4_type;
reg[15:0] gr1_cnt, gr2_cnt, gr3_cnt, gr4_cnt, gr5_cnt, gr6_cnt, gr7_cnt, gr8_cnt, gr9_cnt;
reg[15:0] gr1_mcnt, gr2_mcnt, gr3_mcnt, gr4_mcnt, gr5_mcnt, gr6_mcnt, gr7_mcnt, gr8_mcnt, gr9_mcnt;
reg[15:0] gr1_fle, gr2_fle, gr3_fle, gr4_fle, gr5_fle, gr6_fle, gr7_fle, gr8_fle, gr9_fle;
reg[15:0] gr1_drty, gr2_drty, gr3_drty, gr4_drty, gr5_drty, gr6_drty, gr7_drty, gr8_drty, gr9_drty;
reg[15:0] gr1_smiss, gr2_smiss, gr3_smiss, gr4_smiss, gr5_smiss, gr6_smiss, gr7_smiss, gr8_smiss, gr9_smiss;
reg[15:0] gr1_squash, gr2_squash, gr3_squash, gr4_squash, gr5_squash, gr6_squash, gr7_squash, gr8_squash, gr9_squash;
reg[15:0] gr1_dec, gr2_dec, gr3_dec, gr4_dec, gr5_dec, gr6_dec, gr7_dec, gr8_dec, gr9_dec;

reg [31:0] inst0_typestr;
reg [31:0] inst1_typestr;
reg [31:0] inst2_typestr;
reg [31:0] inst3_typestr;
reg [31:0] inst4_typestr;
reg [128:0] fold_str;


reg [5:0] F0;
reg [5:0] F1;
reg [5:0] F2;
reg [5:0] F3;

reg V0;
reg V1;
reg V2;
reg V3;

reg            gr1_tmp;
reg            gr2_tmp;
reg            gr3_tmp;
reg            gr4_tmp;
reg            gr5_tmp;
reg            gr6_tmp;
reg            gr7_tmp;
reg            gr8_tmp;
reg            gr9_tmp;

reg            gr1;
reg            gr2;
reg            gr3;
reg            gr4;
reg            gr5;
reg            gr6;
reg            gr7;
reg            gr8;
reg            gr9;

reg	     FOE;
reg	     notvalid;

reg          fold1;
reg          fold2;
reg          fold3;
reg          fold4;

reg	fle;
reg	smiss;
reg	drty;
reg	squash;
reg	dec;

reg	hold_r, hold_d, hold_e, hold_c;

reg [3:0]	dec_valid;

initial
  begin
  trap_count = 0;
  gr1_cnt = 0;
  gr2_cnt = 0;
  gr3_cnt = 0;
  gr4_cnt = 0;
  gr5_cnt = 0;
  gr6_cnt = 0;
  gr7_cnt = 0;
  gr8_cnt = 0;
  gr9_cnt = 0;
  V0 = 1;
  V1 = 1;
  V2 = 1;
  V3 = 1;
  gr1_mcnt = 0;
  gr2_mcnt = 0;
  gr3_mcnt = 0;
  gr4_mcnt = 0;
  gr5_mcnt = 0;
  gr6_mcnt = 0;
  gr7_mcnt = 0;
  gr8_mcnt = 0;
  gr9_mcnt = 0;
  gr1_fle = 0;
  gr2_fle = 0;
  gr3_fle = 0;
  gr4_fle = 0;
  gr5_fle = 0;
  gr6_fle = 0;
  gr7_fle = 0;
  gr8_fle = 0;
  gr9_fle = 0;
  gr1_drty = 0;
  gr2_drty = 0;
  gr3_drty = 0;
  gr4_drty = 0;
  gr5_drty = 0;
  gr6_drty = 0;
  gr7_drty = 0;
  gr8_drty = 0;
  gr9_drty = 0;
  gr1_smiss = 0;
  gr2_smiss = 0;
  gr3_smiss = 0;
  gr4_smiss = 0;
  gr5_smiss = 0;
  gr6_smiss = 0;
  gr7_smiss = 0;
  gr8_smiss = 0;
  gr9_smiss = 0;
  gr1_squash = 0;
  gr2_squash = 0;
  gr3_squash = 0;
  gr4_squash = 0;
  gr5_squash = 0;
  gr6_squash = 0;
  gr7_squash = 0;
  gr8_squash = 0;
  gr9_squash = 0;
  gr1_dec = 0;
  gr2_dec = 0;
  gr3_dec = 0;
  gr4_dec = 0;
  gr5_dec = 0;
  gr6_dec = 0;
  gr7_dec = 0;
  gr8_dec = 0;
  gr9_dec = 0;
  gr1 =0;
  gr2 =0;
  gr3 =0;
  gr4 =0;
  gr5 =0;
  gr6 =0;
  gr7 =0;
  gr8 =0;
  gr9 =0;
  FOE = 1;
  debug = 0;  
          


  end

always @(posedge `PICOJAVAII.end_of_simulation) begin
  $display("Folding_statistics_begin");
  $display("____________________________________________________________________");
  $display("                              Psr.fle  IB     Stack$  Traps/  Decode");
  $display("              Folded  Missed  Disable  Dirty  Missed  Branch  !valid");
  $display("____________________________________________________________________");
  $display("LV LV OP MEM   %d   %d   %d   %d   %d   %d   %d"
				, gr1_cnt, gr1_mcnt, gr1_fle, gr1_drty, gr1_smiss, gr1_squash, gr1_dec);
  $display("LV LV OP       %d   %d   %d   %d   %d   %d   %d"
				, gr2_cnt, gr2_mcnt, gr2_fle, gr2_drty, gr2_smiss, gr2_squash, gr2_dec);
  $display("LV LV BG2      %d   %d   %d   %d   %d   %d   %d"
				, gr3_cnt, gr3_mcnt, gr3_fle, gr3_drty, gr3_smiss, gr3_squash, gr3_dec);
  $display("LV OP MEM      %d   %d   %d   %d   %d   %d   %d"
				, gr4_cnt, gr4_mcnt, gr4_fle, gr4_drty, gr4_smiss, gr4_squash, gr4_dec);
  $display("LV BG2         %d   %d   %d   %d   %d   %d   %d"
				, gr5_cnt, gr5_mcnt, gr5_fle, gr5_drty, gr5_smiss, gr5_squash, gr5_dec);
  $display("LV BG1         %d   %d   %d   %d   %d   %d   %d"
				, gr6_cnt, gr6_mcnt, gr6_fle, gr6_drty, gr6_smiss, gr6_squash, gr6_dec);
  $display("LV OP          %d   %d   %d   %d   %d   %d   %d"
				, gr7_cnt, gr7_mcnt, gr7_fle, gr7_drty, gr7_smiss, gr7_squash, gr7_dec);
  $display("LV MEM         %d   %d   %d   %d   %d   %d   %d"
				, gr8_cnt, gr8_mcnt, gr8_fle, gr8_drty, gr8_smiss, gr8_squash, gr8_dec);
  $display("OP MEM         %d   %d   %d   %d   %d   %d   %d"
				, gr9_cnt, gr9_mcnt, gr9_fle, gr9_drty, gr9_smiss, gr9_squash, gr9_dec);
  $display("____________________________________________________________________");
  $display("Folding_statistics_end");
  $display("COVERAGE: folding %d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d",
    (gr1_cnt!=0), (gr1_mcnt!=0), (gr1_fle!=0), (gr1_drty!=0),
    (gr1_smiss!=0), (gr1_squash!=0), (gr1_dec!=0),
    (gr2_cnt!=0), (gr2_mcnt!=0), (gr2_fle!=0), (gr2_drty!=0),
    (gr2_smiss!=0), (gr2_squash!=0), (gr2_dec!=0),
    (gr3_cnt!=0), (gr3_mcnt!=0), (gr3_fle!=0), (gr3_drty!=0),
    (gr3_smiss!=0), (gr3_squash!=0), (gr3_dec!=0),
    (gr4_cnt!=0), (gr4_mcnt!=0), (gr4_fle!=0), (gr4_drty!=0),
    (gr4_smiss!=0), (gr4_squash!=0), (gr4_dec!=0),
    (gr5_cnt!=0), (gr5_mcnt!=0), (gr5_fle!=0), (gr5_drty!=0),
    (gr5_smiss!=0), (gr5_squash!=0), (gr5_dec!=0),
    (gr6_cnt!=0), (gr6_mcnt!=0), (gr6_fle!=0), (gr6_drty!=0),
    (gr6_smiss!=0), (gr6_squash!=0), (gr6_dec!=0),
    (gr7_cnt!=0), (gr7_mcnt!=0), (gr7_fle!=0), (gr7_drty!=0),
    (gr7_smiss!=0), (gr7_squash!=0), (gr7_dec!=0),
    (gr8_cnt!=0), (gr8_mcnt!=0), (gr8_fle!=0), (gr8_drty!=0),
    (gr8_smiss!=0), (gr8_squash!=0), (gr8_dec!=0),
    (gr9_cnt!=0), (gr9_mcnt!=0), (gr9_fle!=0), (gr9_drty!=0),
    (gr9_smiss!=0), (gr9_squash!=0), (gr9_dec!=0));
  end

 // fold_dec  monitor
always @(posedge `PICOJAVAII.`DESIGN.clk) begin


	inst1_type = `PICOJAVAII.`DESIGN.iu.ifu.inst_1_type;
	inst2_type = `PICOJAVAII.`DESIGN.iu.ifu.inst_2_type;
	inst3_type = `PICOJAVAII.`DESIGN.iu.ifu.inst_3_type;
	inst4_type = `PICOJAVAII.`DESIGN.iu.ifu.inst_4_type;

	F0 = inst1_type ;
	F1 = inst2_type ;
	F2 = inst3_type ;
	F3 = inst4_type ;

	case (inst1_type) 
	1: inst1_typestr="NF";
	2: inst1_typestr="LV";
	4: inst1_typestr="OP";
	8: inst1_typestr="BG2";
	16: inst1_typestr="BG1";
	32: inst1_typestr="MEM";
	default: inst1_typestr="Err";
	endcase

	case (inst2_type) 
	1: inst2_typestr="NF";
	2: inst2_typestr="LV";
	4: inst2_typestr="OP";
	8: inst2_typestr="BG2";
	16: inst2_typestr="BG1";
	32: inst2_typestr="MEM";
	default: inst2_typestr="Err";
	endcase


	case (inst3_type) 
	1: inst3_typestr="NF";
	2: inst3_typestr="LV";
	4: inst3_typestr="OP";
	8: inst3_typestr="BG2";
	16: inst3_typestr="BG1";
	32: inst3_typestr="MEM";
	default: inst3_typestr="Err";
	endcase

	case (inst4_type) 
	1: inst4_typestr="NF";
	2: inst4_typestr="LV";
	4: inst4_typestr="OP";
	8: inst4_typestr="BG2";
	16: inst4_typestr="BG1";
	32: inst4_typestr="MEM";
	default: inst4_typestr="Err";
	endcase

// Measure ideal folding situation

assign  gr1_tmp =       FOE & ( V0&F0[1] &
				V1&F1[1] &
				V2&F2[2] &
				V3&F3[5] );

 
assign  gr2_tmp =       FOE & ( V0&F0[1] &
				 V1&F1[1] &
				 V2&F2[2] );

assign  gr3_tmp =       FOE & ( V0&F0[1] &
				V1&F1[1] &
				V2&F2[3] );

assign  gr4_tmp =       FOE & ( V0&F0[1] &
				V1&F1[2] &
				V2&F2[5] );

assign  gr5_tmp =       FOE & ( V0&F0[1] &
				V1&F1[3] );
				 
assign  gr6_tmp =       FOE & ( V0&F0[1] &
				V1&F1[4] );
				 
assign  gr7_tmp =       FOE & ( V0&F0[1] &
				V1&F1[2] );
				 
assign  gr8_tmp =       FOE & ( V0&F0[1] &
				V1&F1[5] );
				 
assign  gr9_tmp =       FOE & ( V0&F0[2] &
				V1&F1[5] );
				  
assign  gr1 = gr1_tmp;
 
assign  gr2 = !gr1_tmp & gr2_tmp;
  
assign  gr3 = gr3_tmp;
   
assign  gr4 = gr4_tmp;
    
assign  gr5 = gr5_tmp;
     
assign  gr6 = gr6_tmp;
      
assign  gr7 = !gr4_tmp & gr7_tmp;
       
assign  gr8 = gr8_tmp;
	
assign  gr9 = gr9_tmp;


assign  fold2 = gr5 | gr6 | gr7 | gr8 | gr9;
assign  fold3 = gr2 | gr3 | gr4;
assign  fold4 = gr1;
assign  fold1 = V0 & (!fold2 & !fold3 & !fold4);
assign  notvalid   = !V0;

assign  fle = (!(`PICOJAVAII.`DESIGN.iu.ifu.iu_psr_fle));
assign  smiss = ((`PICOJAVAII.`DESIGN.iu.ifu.scache_miss));
assign  drty = (`PICOJAVAII.`DESIGN.iu.ifu.vld_drty_entries);
assign  squash = (`PICOJAVAII.`DESIGN.iu.ifu.squash_fold);
assign  dec_valid = (`PICOJAVAII.`DESIGN.iu.ifu.dec_valid);
assign  hold_d = (`PICOJAVAII.`DESIGN.iu.ifu.hold_d);
assign  hold_r = (`PICOJAVAII.`DESIGN.iu.ifu.hold_r);
assign  hold_e = (`PICOJAVAII.`DESIGN.iu.ifu.hold_e);
assign  hold_c = (`PICOJAVAII.`DESIGN.iu.ifu.hold_c);


	if ((!hold_r) && (!hold_d) && (!hold_e) && (!hold_c)) begin

	if (gr1) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_1)) begin
					gr1_mcnt= gr1_mcnt +1;
					if (fle) begin gr1_fle = gr1_fle + 1;end 		     
					if (smiss) begin gr1_smiss = gr1_smiss + 1;end	 	     
					if (drty) begin gr1_drty = gr1_drty + 1;end		     
					if (squash) begin gr1_squash = gr1_squash + 1;end		   
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin
						if ((!dec_valid[0])
						|| (!dec_valid[1]) || (!dec_valid[2]) || (!dec_valid[3])) begin gr1_dec = gr1_dec + 1;end
						    else begin $display("Error:  Can't determine why folding cannot occur\n");
								debug = 1;
							 end
						end
					end
					end
	if (gr2) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_2)) begin
					gr2_mcnt= gr2_mcnt +1;
					if (fle) begin gr2_fle = gr2_fle + 1;end 		     
					if (smiss) begin gr2_smiss = gr2_smiss + 1;end	 	     
					if (drty) begin gr2_drty = gr2_drty + 1;end		     
					if (squash) begin gr2_squash = gr2_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin 
						if ((!dec_valid[0])
						|| (!dec_valid[1]) || (!dec_valid[2])) begin gr2_dec = gr2_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
						end

					end
					end
	if (gr3) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_3)) begin 
					gr3_mcnt= gr3_mcnt +1;
					if (fle) begin gr3_fle = gr3_fle + 1;end 		     
					if (smiss) begin gr3_smiss = gr3_smiss + 1;end	 	     
					if (drty) begin gr3_drty = gr3_drty + 1;end		     
					if (squash) begin gr3_squash = gr3_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin
						if ((!dec_valid[0])
						|| (!dec_valid[1]) || (!dec_valid[2])) begin gr3_dec = gr3_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
						end
					end
					end
	if (gr4) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_4)) begin 
					gr4_mcnt= gr4_mcnt +1;
					if (fle) begin gr4_fle = gr4_fle + 1;end 		     
					if (smiss) begin gr4_smiss = gr4_smiss + 1;end	 	     
					if (drty) begin gr4_drty = gr4_drty + 1;end		     
					if (squash) begin gr4_squash = gr4_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin 
						if ((!dec_valid[0]) 
						|| (!dec_valid[1]) || (!dec_valid[2])) begin gr4_dec = gr4_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
						end
					end
					end
	if (gr5) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_5)) begin
					gr5_mcnt= gr5_mcnt +1;
					if (fle) begin gr5_fle = gr5_fle + 1;end 		     
					if (smiss) begin gr5_smiss = gr5_smiss + 1;end	 	     
					if (drty) begin gr5_drty = gr5_drty + 1;end		     
					if (squash) begin gr5_squash = gr5_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin 
						if ((!dec_valid[0])
						|| (!dec_valid[1])) begin gr5_dec = gr5_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
						end		
					end
					end
	if (gr6) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_6)) begin
					gr6_mcnt= gr6_mcnt +1;
					if (fle) begin gr6_fle = gr6_fle + 1;end 		     
					if (smiss) begin gr6_smiss = gr6_smiss + 1;end	 	     
					if (drty) begin gr6_drty = gr6_drty + 1;end		     
					if (squash) begin gr6_squash = gr6_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin
						if ((!dec_valid[0])
						|| (!dec_valid[1])) begin gr6_dec = gr6_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
						end				 
					end
					end
	if (gr7) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_7)) begin
					gr7_mcnt= gr7_mcnt +1;
					if (fle) begin gr7_fle = gr7_fle + 1;end 		     
					if (smiss) begin gr7_smiss = gr7_smiss + 1;end	 	     
					if (drty) begin gr7_drty = gr7_drty + 1;end		     
					if (squash) begin gr7_squash = gr7_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin
						if ((!dec_valid[0])
						|| (!dec_valid[1])) begin gr7_dec = gr7_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
						end
					end
					end
	if (gr8) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_8)) begin
					gr8_mcnt= gr8_mcnt +1;
					if (fle) begin gr8_fle = gr8_fle + 1;end 		     
					if (smiss) begin gr8_smiss = gr8_smiss + 1;end	 	     
					if (drty) begin gr8_drty = gr8_drty + 1;end		     
					if (squash) begin gr8_squash = gr8_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin
						if ((!dec_valid[0])
						|| (!dec_valid[1])) begin gr8_dec = gr8_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
						end			   end
					end
					end
	if (gr9) begin if (!(`PICOJAVAII.`DESIGN.iu.ifu.group_9)) begin
					gr9_mcnt= gr9_mcnt +1;
					if (fle) begin gr9_fle = gr9_fle + 1;end 		     
					if (smiss) begin gr9_smiss = gr9_smiss + 1;end	 	     
					if (drty) begin gr9_drty = gr9_drty + 1;end		     
					if (squash) begin gr9_squash = gr9_squash + 1;end		     
					if ((!fle) && (!smiss) && (!drty) && (!squash)) begin
						if  ((!dec_valid[0])
						|| (!dec_valid[1])) begin gr9_dec = gr9_dec + 1;end
							else begin $display("Error: Can't determine why folding cannot occur\n");
								   debug = 1;
								   end
								   end 
					end
					end

	end



// Use folding logic to determine how many instructions can be folded
// and what group the folded instructions fall into
// group_1 : LV LV MEM OP
// group_2 : LV LV OP
// group_3 : LV LV BG2
// group_4 : LV OP MEM
// group_5 : LV BG2
// group_6 : LV BG1
// group_7 : LV OP
// group_8 : LV MEM
// group_9 : OP MEM

	
	if ((!hold_r) && (!hold_d) && (!hold_e) && (!hold_c)) begin

	if (`PICOJAVAII.`DESIGN.iu.ifu.group_1) begin fold_str = " LV LV MEM OP"; gr1_cnt = gr1_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_2) begin fold_str = " LV LV OP"; gr2_cnt = gr2_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_3) begin fold_str = " LV LV BG2"; gr3_cnt = gr3_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_4) begin fold_str = " LV OP MEM"; gr4_cnt = gr4_cnt+1;  end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_5) begin fold_str = " LV BG2"; gr5_cnt = gr5_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_6) begin fold_str = " LV BG1"; gr6_cnt = gr6_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_7) begin fold_str = " LV OP"; gr7_cnt = gr7_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_8) begin fold_str = " LV MEM"; gr8_cnt = gr8_cnt+1; end
	if (`PICOJAVAII.`DESIGN.iu.ifu.group_9) begin fold_str = " OP MEM"; gr9_cnt = gr9_cnt+1;  end
	if  ((!(`PICOJAVAII.`DESIGN.iu.ifu.group_1)) &&
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_2))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_3))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_4))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_5))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_6))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_7))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_8))&&	
		(!(`PICOJAVAII.`DESIGN.iu.ifu.group_9)))	begin fold_str = "Nothing Folded"; end



	if (`PICOJAVAII.`DESIGN.iu.ifu.fold_1_inst) begin fold_num = 1; end 
	if (`PICOJAVAII.`DESIGN.iu.ifu.fold_2_inst) begin fold_num = 2; end 
	if (`PICOJAVAII.`DESIGN.iu.ifu.fold_3_inst) begin fold_num = 3; end 
	if (`PICOJAVAII.`DESIGN.iu.ifu.fold_4_inst) begin fold_num = 4; end 
	if ( `PICOJAVAII.`DESIGN.iu.ifu.fold_1_inst != 1  && 
		`PICOJAVAII.`DESIGN.iu.ifu.fold_2_inst != 1 && 
		`PICOJAVAII.`DESIGN.iu.ifu.fold_3_inst != 1 && 
		`PICOJAVAII.`DESIGN.iu.ifu.fold_4_inst != 1 )
						 begin fold_num = 0;  end 

	if (`PICOJAVAII.`DESIGN.iu.ifu.fold_enable == 1) begin fold_enable = 1; end else begin
						      fold_enable = 0; end

	if (debug) begin

	$display("______________Folding_monitor_info_________________________"); 
	$display("Cycle:%d      folding:%d hold_r:%d hold_d:%d",`PICOJAVAII.clk_count,fold_enable,
						        `PICOJAVAII.`DESIGN.iu.ifu.hold_r,
						        `PICOJAVAII.`DESIGN.iu.ifu.hold_d,
							);
	$display("		ibuf0  %X %X %X %X %X %X %X",`PICOJAVAII.`DESIGN.iu.ifu.ibuff_0, 
				`PICOJAVAII.`DESIGN.iu.ifu.ibuff_1,
				`PICOJAVAII.`DESIGN.iu.ifu.ibuff_2,
				`PICOJAVAII.`DESIGN.iu.ifu.ibuff_3,
				`PICOJAVAII.`DESIGN.iu.ifu.ibuff_4,
				`PICOJAVAII.`DESIGN.iu.ifu.ibuff_5,
				`PICOJAVAII.`DESIGN.iu.ifu.ibuff_6, );
	$display("		valid  %X  %X  %X  %X  %X  %X  %X",`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[0], 
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[1],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[2],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[3],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[4],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[5],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_valid[6]);
	$display("		drty   %X  %X  %X  %X  %X  %X  %X",`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[0], 
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[1],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[2],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[3],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[4],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[5],
				`PICOJAVAII.`DESIGN.iu.ifu.fetch_drty[6]);

	$display("		type_0 type_1 type_2 type_3");   
	$display("		%s	%s	%s	%s ",inst1_typestr,
								inst2_typestr,
								inst3_typestr,
								inst4_typestr);


	$display("		len0 len1 len2 ");
	$display("		%X   %X   %X   ", `PICOJAVAII.`DESIGN.iu.ifu.accum_len0,
				 `PICOJAVAII.`DESIGN.iu.ifu.accum_len1,
				 `PICOJAVAII.`DESIGN.iu.ifu.accum_len2);


	$display("		Folded insts: %s", fold_str); 
	$display("		Total # Folded insts: %d", fold_num); 

	$display("______________Folding_monitor_end_info_________________________"); 

	debug = 0;

	end 
	end
end


endmodule 
