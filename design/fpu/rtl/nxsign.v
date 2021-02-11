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



module nxsign(asignfunc,ae_small,expsame,altb,morethree_taken,eadd,absign,
	      asign, clk,sin,so,sm,asignin,bsignin,cyc0_rdy,
	      reset_l, fpuhold);


 input [2:0]  asignfunc;
 input        altb,morethree_taken,ae_small;
 input        expsame;
 input        clk,sin,sm, reset_l, fpuhold;
 input        asignin,bsignin,cyc0_rdy;

output so;
 output       eadd,absign,asign;

// wire  [7:0]  asign_mux_selx;
 wire         a_small,asign_3_pick,bsign_3_pick;
 wire         nxasign,bsign,par_asign;

 reg          nxbsign;

 wire fpuhold_l = ~fpuhold;

 assign a_small = (expsame) ? altb : ae_small;

 mj_s_mux8_d as(.mx_out(par_asign),
		.sel(asignfunc),
		.in0(asign),
		.in1(!asign),
		.in2(asign ^ bsign),
           	.in3(asign_3_pick),
		.in4(asign & bsign),
		.in5(1'h0),
		.in6(bsign),
		.in7(1'h1));


 assign asign_3_pick = (a_small && !morethree_taken) ? bsign : asign;
 assign bsign_3_pick = (a_small && !morethree_taken) ? asign : bsign;

 assign  nxasign = (cyc0_rdy) ? asignin : par_asign;

 always @(cyc0_rdy or asignfunc or a_small or morethree_taken or
   	  bsignin or asign or bsign) 
	begin
          if(cyc0_rdy)                                         
		nxbsign = bsignin;
    	  else if((asignfunc==3'h3) && a_small && !morethree_taken) 
		nxbsign = asign;
    	  else if(asignfunc==3'h6)                                  
		nxbsign = asign;
    	  else                                                      
		nxbsign = bsign;
 	end

mj_s_ff_snre_d  abs(.out(asign),
		.in(nxasign),
		.lenable(fpuhold_l),
		.reset_l(reset_l),
		.clk(clk));
 
mj_s_ff_snre_d  abs1(.out(bsign),
                .in(nxbsign),
		.lenable(fpuhold_l),
		.reset_l(reset_l),
                .clk(clk));


 wire eadd_before    = nxasign ^ !nxbsign;
 wire absign_before  = nxasign & nxbsign;

mj_s_ff_snre_d ead(.out(eadd),
                .in(eadd_before),
		.lenable(fpuhold_l),
		.reset_l(reset_l),
                .clk(clk));
  
mj_s_ff_snre_d absig(.out(absign), 
                .in(absign_before),
		.lenable(fpuhold_l), 
		.reset_l(reset_l),
                .clk(clk)); 

endmodule
