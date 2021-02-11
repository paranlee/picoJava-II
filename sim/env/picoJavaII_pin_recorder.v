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



`define PICOJAVAII picoJavaII
`define DESIGN cpu

module picoJavaII_pin_recorder;

integer mcd;
integer mcd_out;

event record_trig;

reg record_on;
wire clk = `PICOJAVAII.`DESIGN.clk & record_on;

initial begin

  #1;
  if (record_on == 1'b1) begin  
   mcd = $fopen("picoJavaII_pin.tape");
		 //  123456789012345678901234567890123456789012345
   $fdisplay(mcd,"// ppppppppppppppppppppppppppppppppppppppppppppppp");
   $fdisplay(mcd,"// jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
   $fdisplay(mcd,"// _______________________________________________");
   $fdisplay(mcd,"// aaddddddddddddddddddddddddddddddddhrbniiiinsssr");
   $fdisplay(mcd,"// ccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeoorrrrmtcce");
   $fdisplay(mcd,"// kkttttttttttttttttttttttttttttttttlso_lllliaaas");
   $fdisplay(mcd,"// 10aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaatutf3210 nnne");
   $fdisplay(mcd,"//   ________________________________ m8p     d__t");
   $fdisplay(mcd,"//   iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii e u     bmi ");
   $fdisplay(mcd,"//   nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn         yon ");
   $fdisplay(mcd,"//   33222222222211111111110000000000          d  ");
   $fdisplay(mcd,"//   10987654321098765432109876543210          e  ");

   mcd_out = $fopen("picoJavaII_pout.tape");

   $fdisplay(mcd_out,"// ppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppppp");
   $fdisplay(mcd_out,"// jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj");
   $fdisplay(mcd_out,"// ___________________________________________________________________________");
   $fdisplay(mcd_out,"// sddddddddddddddddddddddddddddddddtttssaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbiisrc");
   $fdisplay(mcd_out,"// uaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaayyyiiddddddddddddddddddddddddddddddrrnntsl");
   $fdisplay(mcd_out,"//  ttttttttttttttttttttttttttttttttpppzzrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrkk_sdtk");
   $fdisplay(mcd_out,"//  aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeeeee22222222221111111111000000000012ht___");
   $fdisplay(mcd_out,"//  _____________________________________987654321098765432109876543210__a_ooo");
   $fdisplay(mcd_out,"//  oooooooooooooooooooooooooooooooo21010                              sslcuuu");
   $fdisplay(mcd_out,"//  uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu                                   yytmttt");
   $fdisplay(mcd_out,"//  tttttttttttttttttttttttttttttttt                                   nn p   ");
   $fdisplay(mcd_out,"//  33222222222211111111110000000000                                   cc     ");
   $fdisplay(mcd_out,"//  10987654321098765432109876543210                                          ");

	//		 123456789012345678901234567890123456789012345678901234567890123456789012345
end


end

// input pins
wire pj_irl3 = `PICOJAVAII.`DESIGN.pj_irl[3]; 
wire pj_irl2 = `PICOJAVAII.`DESIGN.pj_irl[2]; 
wire pj_irl1 = `PICOJAVAII.`DESIGN.pj_irl[1]; 
wire pj_irl0 = `PICOJAVAII.`DESIGN.pj_irl[0]; 
wire pj_datain31 = `PICOJAVAII.pj_datain[31]; 
wire pj_datain30 = `PICOJAVAII.pj_datain[30]; 

wire pj_dcureq = `PICOJAVAII.pj_dcureq; 
wire pj_icureq = `PICOJAVAII.pj_icureq; 
wire pj_icutype = `PICOJAVAII.pj_icutype; 
wire pj_icusize_1 = `PICOJAVAII.pj_icusize[1]; 
wire pj_icusize_0 = `PICOJAVAII.pj_icusize[0]; 

wire pj_dcuack1 = `PICOJAVAII.pj_dcuack[1]; 
wire pj_dcuack0 = `PICOJAVAII.pj_dcuack[0]; 
wire pj_icuack1 = `PICOJAVAII.pj_icuack[1]; 
wire pj_icuack0 = `PICOJAVAII.pj_icuack[0]; 
wire pj_datain_31 = `PICOJAVAII.pj_datain[31]; 
wire pj_datain_30 = `PICOJAVAII.pj_datain[30]; 
wire pj_datain_29 = `PICOJAVAII.pj_datain[29]; 
wire pj_datain_28 = `PICOJAVAII.pj_datain[28]; 
wire pj_datain_27 = `PICOJAVAII.pj_datain[27]; 
wire pj_datain_26 = `PICOJAVAII.pj_datain[26]; 
wire pj_datain_25 = `PICOJAVAII.pj_datain[25]; 
wire pj_datain_24 = `PICOJAVAII.pj_datain[24]; 
wire pj_datain_23 = `PICOJAVAII.pj_datain[23]; 
wire pj_datain_22 = `PICOJAVAII.pj_datain[22]; 
wire pj_datain_21 = `PICOJAVAII.pj_datain[21]; 
wire pj_datain_20 = `PICOJAVAII.pj_datain[20]; 
wire pj_datain_19 = `PICOJAVAII.pj_datain[19]; 
wire pj_datain_18 = `PICOJAVAII.pj_datain[18]; 
wire pj_datain_17 = `PICOJAVAII.pj_datain[17]; 
wire pj_datain_16 = `PICOJAVAII.pj_datain[16]; 
wire pj_datain_15 = `PICOJAVAII.pj_datain[15]; 
wire pj_datain_14 = `PICOJAVAII.pj_datain[14]; 
wire pj_datain_13 = `PICOJAVAII.pj_datain[13]; 
wire pj_datain_12 = `PICOJAVAII.pj_datain[12]; 
wire pj_datain_11 = `PICOJAVAII.pj_datain[11]; 
wire pj_datain_10 = `PICOJAVAII.pj_datain[10]; 
wire pj_datain_9 = `PICOJAVAII.pj_datain[9]; 
wire pj_datain_8 = `PICOJAVAII.pj_datain[8]; 
wire pj_datain_7 = `PICOJAVAII.pj_datain[7]; 
wire pj_datain_6 = `PICOJAVAII.pj_datain[6]; 
wire pj_datain_5 = `PICOJAVAII.pj_datain[5]; 
wire pj_datain_4 = `PICOJAVAII.pj_datain[4]; 
wire pj_datain_3 = `PICOJAVAII.pj_datain[3]; 
wire pj_datain_2 = `PICOJAVAII.pj_datain[2]; 
wire pj_datain_1 = `PICOJAVAII.pj_datain[1]; 
wire pj_datain_0 = `PICOJAVAII.pj_datain[0]; 

// output pins
wire pj_tv = `PICOJAVAII.pj_tv; 
wire pj_ale = `PICOJAVAII.pj_ale; 
wire pj_su = `PICOJAVAII.pj_su; 
wire pj_dataout_31 = `PICOJAVAII.pj_dataout[31]; 
wire pj_dataout_30 = `PICOJAVAII.pj_dataout[30]; 
wire pj_dataout_29 = `PICOJAVAII.pj_dataout[29]; 
wire pj_dataout_28 = `PICOJAVAII.pj_dataout[28]; 
wire pj_dataout_27 = `PICOJAVAII.pj_dataout[27]; 
wire pj_dataout_26 = `PICOJAVAII.pj_dataout[26]; 
wire pj_dataout_25 = `PICOJAVAII.pj_dataout[25]; 
wire pj_dataout_24 = `PICOJAVAII.pj_dataout[24]; 
wire pj_dataout_23 = `PICOJAVAII.pj_dataout[23]; 
wire pj_dataout_22 = `PICOJAVAII.pj_dataout[22]; 
wire pj_dataout_21 = `PICOJAVAII.pj_dataout[21]; 
wire pj_dataout_20 = `PICOJAVAII.pj_dataout[20]; 
wire pj_dataout_19 = `PICOJAVAII.pj_dataout[19]; 
wire pj_dataout_18 = `PICOJAVAII.pj_dataout[18]; 
wire pj_dataout_17 = `PICOJAVAII.pj_dataout[17]; 
wire pj_dataout_16 = `PICOJAVAII.pj_dataout[16]; 
wire pj_dataout_15 = `PICOJAVAII.pj_dataout[15]; 
wire pj_dataout_14 = `PICOJAVAII.pj_dataout[14]; 
wire pj_dataout_13 = `PICOJAVAII.pj_dataout[13]; 
wire pj_dataout_12 = `PICOJAVAII.pj_dataout[12]; 
wire pj_dataout_11 = `PICOJAVAII.pj_dataout[11]; 
wire pj_dataout_10 = `PICOJAVAII.pj_dataout[10]; 
wire pj_dataout_9 = `PICOJAVAII.pj_dataout[9]; 
wire pj_dataout_8 = `PICOJAVAII.pj_dataout[8]; 
wire pj_dataout_7 = `PICOJAVAII.pj_dataout[7]; 
wire pj_dataout_6 = `PICOJAVAII.pj_dataout[6]; 
wire pj_dataout_5 = `PICOJAVAII.pj_dataout[5]; 
wire pj_dataout_4 = `PICOJAVAII.pj_dataout[4]; 
wire pj_dataout_3 = `PICOJAVAII.pj_dataout[3]; 
wire pj_dataout_2 = `PICOJAVAII.pj_dataout[2]; 
wire pj_dataout_1 = `PICOJAVAII.pj_dataout[1]; 
wire pj_dataout_0 = `PICOJAVAII.pj_dataout[0]; 

// wire pj_icutype_0 = `PICOJAVAII.pj_icutype[3];
wire pj_dcutype_2 = `PICOJAVAII.pj_dcutype[2];
wire pj_dcutype_1 = `PICOJAVAII.pj_dcutype[1];
wire pj_dcutype_0 = `PICOJAVAII.pj_dcutype[0];

wire pj_dcusize_1 = `PICOJAVAII.pj_dcusize[1];
wire pj_dcusize_0 = `PICOJAVAII.pj_dcusize[0];

wire pj_dcuaddr_29 = `PICOJAVAII.pj_dcuaddr[29]; 
wire pj_dcuaddr_28 = `PICOJAVAII.pj_dcuaddr[28]; 
wire pj_dcuaddr_27 = `PICOJAVAII.pj_dcuaddr[27]; 
wire pj_dcuaddr_26 = `PICOJAVAII.pj_dcuaddr[26]; 
wire pj_dcuaddr_25 = `PICOJAVAII.pj_dcuaddr[25]; 
wire pj_dcuaddr_24 = `PICOJAVAII.pj_dcuaddr[24]; 
wire pj_dcuaddr_23 = `PICOJAVAII.pj_dcuaddr[23]; 
wire pj_dcuaddr_22 = `PICOJAVAII.pj_dcuaddr[22]; 
wire pj_dcuaddr_21 = `PICOJAVAII.pj_dcuaddr[21]; 
wire pj_dcuaddr_20 = `PICOJAVAII.pj_dcuaddr[20]; 
wire pj_dcuaddr_19 = `PICOJAVAII.pj_dcuaddr[19]; 
wire pj_dcuaddr_18 = `PICOJAVAII.pj_dcuaddr[18]; 
wire pj_dcuaddr_17 = `PICOJAVAII.pj_dcuaddr[17]; 
wire pj_dcuaddr_16 = `PICOJAVAII.pj_dcuaddr[16]; 
wire pj_dcuaddr_15 = `PICOJAVAII.pj_dcuaddr[15]; 
wire pj_dcuaddr_14 = `PICOJAVAII.pj_dcuaddr[14]; 
wire pj_dcuaddr_13 = `PICOJAVAII.pj_dcuaddr[13]; 
wire pj_dcuaddr_12 = `PICOJAVAII.pj_dcuaddr[12]; 
wire pj_dcuaddr_11 = `PICOJAVAII.pj_dcuaddr[11]; 
wire pj_dcuaddr_10 = `PICOJAVAII.pj_dcuaddr[10]; 
wire pj_dcuaddr_9 = `PICOJAVAII.pj_dcuaddr[9]; 
wire pj_dcuaddr_8 = `PICOJAVAII.pj_dcuaddr[8]; 
wire pj_dcuaddr_7 = `PICOJAVAII.pj_dcuaddr[7]; 
wire pj_dcuaddr_6 = `PICOJAVAII.pj_dcuaddr[6]; 
wire pj_dcuaddr_5 = `PICOJAVAII.pj_dcuaddr[5]; 
wire pj_dcuaddr_4 = `PICOJAVAII.pj_dcuaddr[4]; 
wire pj_dcuaddr_3 = `PICOJAVAII.pj_dcuaddr[3]; 
wire pj_dcuaddr_2 = `PICOJAVAII.pj_dcuaddr[2]; 
wire pj_dcuaddr_1 = `PICOJAVAII.pj_dcuaddr[1]; 
wire pj_dcuaddr_0 = `PICOJAVAII.pj_dcuaddr[0]; 

wire pj_icuaddr_29 = `PICOJAVAII.pj_icuaddr[29]; 
wire pj_icuaddr_28 = `PICOJAVAII.pj_icuaddr[28]; 
wire pj_icuaddr_27 = `PICOJAVAII.pj_icuaddr[27]; 
wire pj_icuaddr_26 = `PICOJAVAII.pj_icuaddr[26]; 
wire pj_icuaddr_25 = `PICOJAVAII.pj_icuaddr[25]; 
wire pj_icuaddr_24 = `PICOJAVAII.pj_icuaddr[24]; 
wire pj_icuaddr_23 = `PICOJAVAII.pj_icuaddr[23]; 
wire pj_icuaddr_22 = `PICOJAVAII.pj_icuaddr[22]; 
wire pj_icuaddr_21 = `PICOJAVAII.pj_icuaddr[21]; 
wire pj_icuaddr_20 = `PICOJAVAII.pj_icuaddr[20]; 
wire pj_icuaddr_19 = `PICOJAVAII.pj_icuaddr[19]; 
wire pj_icuaddr_18 = `PICOJAVAII.pj_icuaddr[18]; 
wire pj_icuaddr_17 = `PICOJAVAII.pj_icuaddr[17]; 
wire pj_icuaddr_16 = `PICOJAVAII.pj_icuaddr[16]; 
wire pj_icuaddr_15 = `PICOJAVAII.pj_icuaddr[15]; 
wire pj_icuaddr_14 = `PICOJAVAII.pj_icuaddr[14]; 
wire pj_icuaddr_13 = `PICOJAVAII.pj_icuaddr[13]; 
wire pj_icuaddr_12 = `PICOJAVAII.pj_icuaddr[12]; 
wire pj_icuaddr_11 = `PICOJAVAII.pj_icuaddr[11]; 
wire pj_icuaddr_10 = `PICOJAVAII.pj_icuaddr[10]; 
wire pj_icuaddr_9 = `PICOJAVAII.pj_icuaddr[9]; 
wire pj_icuaddr_8 = `PICOJAVAII.pj_icuaddr[8]; 
wire pj_icuaddr_7 = `PICOJAVAII.pj_icuaddr[7]; 
wire pj_icuaddr_6 = `PICOJAVAII.pj_icuaddr[6]; 
wire pj_icuaddr_5 = `PICOJAVAII.pj_icuaddr[5]; 
wire pj_icuaddr_4 = `PICOJAVAII.pj_icuaddr[4]; 
wire pj_icuaddr_3 = `PICOJAVAII.pj_icuaddr[3]; 
wire pj_icuaddr_2 = `PICOJAVAII.pj_icuaddr[2]; 
wire pj_icuaddr_1 = `PICOJAVAII.pj_icuaddr[1]; 
wire pj_icuaddr_0 = `PICOJAVAII.pj_icuaddr[0]; 

wire pj_brk1_sync = `PICOJAVAII.`DESIGN.pj_brk1_sync;
wire pj_brk2_sync = `PICOJAVAII.`DESIGN.pj_brk2_sync;
wire pj_in_halt = `PICOJAVAII.`DESIGN.pj_in_halt;
wire pj_inst_complete = `PICOJAVAII.`DESIGN.pj_inst_complete;
wire pj_standby_out = `PICOJAVAII.`DESIGN.pj_standby_out;
wire pj_reset_out = `PICOJAVAII.`DESIGN.pj_reset_out;
wire pj_clk_out = `PICOJAVAII.`DESIGN.pj_clk_out;
//wire pj_scan_out = `PICOJAVAII.`DESIGN.so;

/* record pins */
always @(negedge clk) begin
 #4;	//       1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7  
 -> record_trig;

 $fdisplay(mcd,"%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b", 
              pj_dcuack1,pj_dcuack0,pj_icuack1,pj_icuack0,
	      pj_datain_31,pj_datain_30,pj_datain_29,pj_datain_28, 
	      pj_datain_27,pj_datain_26,pj_datain_25,pj_datain_24, 
	      pj_datain_23,pj_datain_22,pj_datain_21,pj_datain_20, 
	      pj_datain_19,pj_datain_18,pj_datain_17,pj_datain_16, 
	      pj_datain_15,pj_datain_14,pj_datain_13,pj_datain_12, 
	      pj_datain_11,pj_datain_10,pj_datain_9,pj_datain_8, 
	      pj_datain_7,pj_datain_6,pj_datain_5,pj_datain_4, 
	      pj_datain_3,pj_datain_2,pj_datain_1,pj_datain_0, 
	      `PICOJAVAII.`DESIGN.pj_halt,`PICOJAVAII.`DESIGN.pj_resume,`PICOJAVAII.`DESIGN.pj_boot8,
	      `PICOJAVAII.`DESIGN.pj_no_fpu,pj_irl3,pj_irl2,pj_irl1,pj_irl0,
	      //`PICOJAVAII.`DESIGN.pj_nmi,`PICOJAVAII.`DESIGN.pj_standby,`PICOJAVAII.`DESIGN.sm,
	      `PICOJAVAII.`DESIGN.pj_nmi,
	      `PICOJAVAII.`DESIGN.reset_l);

 $fdisplay(mcd_out, "%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b%b",
	      /* pj_tv, pj_ale, pj_su, */
	      pj_su,pj_dcureq,pj_icureq,pj_icutype,pj_icusize_1,pj_icusize_0,
              pj_dataout_31,pj_dataout_30,pj_dataout_29,pj_dataout_28,
              pj_dataout_27,pj_dataout_26,pj_dataout_25,pj_dataout_24,
              pj_dataout_23,pj_dataout_22,pj_dataout_21,pj_dataout_20,
              pj_dataout_19,pj_dataout_18,pj_dataout_17,pj_dataout_16,
              pj_dataout_15,pj_dataout_14,pj_dataout_13,pj_dataout_12,
              pj_dataout_11,pj_dataout_10,pj_dataout_9,pj_dataout_8,
              pj_dataout_7,pj_dataout_6,pj_dataout_5,pj_dataout_4,
              pj_dataout_3,pj_dataout_2,pj_dataout_1,pj_dataout_0,
              pj_dcutype_2, pj_dcutype_1, pj_dcutype_0, pj_dcusize_1, pj_dcusize_0,
              pj_dcuaddr_29,pj_dcuaddr_28,
              pj_dcuaddr_27,pj_dcuaddr_26,pj_dcuaddr_25,pj_dcuaddr_24,
              pj_dcuaddr_23,pj_dcuaddr_22,pj_dcuaddr_21,pj_dcuaddr_20,
              pj_dcuaddr_19,pj_dcuaddr_18,pj_dcuaddr_17,pj_dcuaddr_16,
              pj_dcuaddr_15,pj_dcuaddr_14,pj_dcuaddr_13,pj_dcuaddr_12,
              pj_dcuaddr_11,pj_dcuaddr_10,pj_dcuaddr_9,pj_dcuaddr_8,
              pj_dcuaddr_7,pj_dcuaddr_6,pj_dcuaddr_5,pj_dcuaddr_4,
              pj_dcuaddr_3,pj_dcuaddr_2,pj_dcuaddr_1,pj_dcuaddr_0,
              pj_icuaddr_29,pj_icuaddr_28,
              pj_icuaddr_27,pj_icuaddr_26,pj_icuaddr_25,pj_icuaddr_24,
              pj_icuaddr_23,pj_icuaddr_22,pj_icuaddr_21,pj_icuaddr_20,
              pj_icuaddr_19,pj_icuaddr_18,pj_icuaddr_17,pj_icuaddr_16,
              pj_icuaddr_15,pj_icuaddr_14,pj_icuaddr_13,pj_icuaddr_12,
              pj_icuaddr_11,pj_icuaddr_10,pj_icuaddr_9,pj_icuaddr_8,
              pj_icuaddr_7,pj_icuaddr_6,pj_icuaddr_5,pj_icuaddr_4,
              pj_icuaddr_3,pj_icuaddr_2,pj_icuaddr_1,pj_icuaddr_0,
              pj_brk1_sync, pj_brk2_sync, pj_in_halt, pj_inst_complete,
              pj_standby_out, pj_reset_out, pj_clk_out);

end



endmodule

