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



module multmod_cntl ( nx_multfunc_rom0, nx_multfunc_rom1,  
    		      romsel, nx_cyc0_rdy,
		      clk, reset_l, nx_multdec_muxcntl);

input  [3:0] nx_multfunc_rom0, nx_multfunc_rom1;
input  [1:0] romsel;
input  nx_cyc0_rdy; 
input  clk; 
input  reset_l;


output [17:0] nx_multdec_muxcntl;

wire [17:0]   nx_multdec_muxcntl_rom0, nx_multdec_muxcntl_rom1, nx_multdec_muxcntl_0;

   mult_dec muldec_rom0(.multfunc(nx_multfunc_rom0),
			.cyc0_rdy(nx_cyc0_rdy),
			.nx_multdec_muxcntl(nx_multdec_muxcntl_rom0));

   mult_dec muldec_rom1(.multfunc(nx_multfunc_rom1),
			.cyc0_rdy(nx_cyc0_rdy),
			.nx_multdec_muxcntl(nx_multdec_muxcntl_rom1));

   mult_dec muldec_0(.multfunc(4'b0),
			.cyc0_rdy(nx_cyc0_rdy),
			.nx_multdec_muxcntl(nx_multdec_muxcntl_0));

//  wire [2:0] romselx;

mj_s_mux3_d_16 selmultdectop_17_2(.mx_out(nx_multdec_muxcntl[17:2]), 
			.in2(nx_multdec_muxcntl_0[17:2]), 
			.in1(nx_multdec_muxcntl_rom1[17:2]), 
			.in0(nx_multdec_muxcntl_rom0[17:2]), 
			.sel(romsel) );
mj_s_mux3_d_2 selmultdec_1_0(.mx_out(nx_multdec_muxcntl[1:0]), 
			.in2(nx_multdec_muxcntl_0[1:0]), 
			.in1(nx_multdec_muxcntl_rom1[1:0]), 
			.in0(nx_multdec_muxcntl_rom0[1:0]), 
			.sel(romsel) );
 

endmodule


module mult_dec(multfunc, cyc0_rdy, nx_multdec_muxcntl);

 input   [3:0]   multfunc;	// actually nx_multfunc
 input           cyc0_rdy;	// actually nx_cyc0_rdy

output [17:0] nx_multdec_muxcntl;

 reg [2:0]  multsel;
 reg [1:0]  mout_sel,lo_sel,hi_sel,stop_sel, mcansel;
 wire         mctsel,hi_add,hi,dp_hi, dpmul;

assign nx_multdec_muxcntl = {mout_sel, dpmul, multsel, mcansel, hi_sel, lo_sel, stop_sel, mctsel, hi_add, dp_hi, hi};

 always @(multfunc or cyc0_rdy)
         if(cyc0_rdy)
                lo_sel = 2'h0;  /* zero. */
         else if((multfunc==4'h1) || (multfunc==4'h2) ||
           (multfunc[0] && (multfunc >= 4'h4) && (multfunc < 4'hc)))
                lo_sel = 2'h1;  /* update. */
         else if((multfunc >= 4'h4) && (multfunc < 4'hc))
                lo_sel = 2'h2;  /* hold value. */
         else
                lo_sel = 2'h0;  /* zero. */

 always @(multfunc or cyc0_rdy)
         if(cyc0_rdy)
                hi_sel = 2'h0;  /* zero. */
         else if(!multfunc[0] && (multfunc >= 4'h4) && (multfunc < 4'hc))
                hi_sel = 2'h1; /* update.  */
         else if((multfunc >= 4'h4) && (multfunc < 4'hc) && multfunc[0])
                hi_sel = 2'h2; /* hold.  */
         else if(multfunc==4'hc)
                hi_sel = 2'h2; /* hd hi dp_add1 */
         else
                hi_sel = 2'h0; /* zero.  */

 always @(multfunc or cyc0_rdy)
         if(cyc0_rdy)
                stop_sel = 2'h0;  /* zero. */
         else if((!multfunc[0] && (multfunc >= 4'h4) && (multfunc < 4'hc))
                   || (multfunc==4'h1) || (multfunc==4'h2))
                stop_sel = 2'h1; /* update.  */
         else if((multfunc >= 4'h4) && (multfunc < 4'hc) && multfunc[0])
                stop_sel = 2'h2; /* hold.  */
         else if(multfunc==4'hc)
                stop_sel = 2'h2; /* hd hi dp_add1 */
         else
                stop_sel = 2'h0; /* zero.  */


 assign mctsel = (multfunc[0]) && (multfunc >= 4'h4);   /* DP mcanlo's   */

 assign hi = ((!multfunc[0] && (multfunc >= 4'h4)) ||
              (multfunc==4'h1) || (multfunc==4'h2));   /* DP/SP mcanhi's */
 
 assign dp_hi = (!multfunc[0] && (multfunc >= 4'h4));

  
 assign hi_add = (multfunc == 4'hd);        /* add the hi (couth,south) parts in DP.  */

 assign dpmul = (multfunc >= 4'h4) && (multfunc < 4'he);
  
 always @(multfunc)
   begin
     case(multfunc)      // synopsys parallel_case
          4'he:     mout_sel = 2'h3;  /* SP_ADD (SP not rounded case.) */
          4'hc:     mout_sel = 2'h2;  /* first  DMUL output: LS. */
          4'hd:     mout_sel = 2'h1;  /* second DMUL output: MS. */
          default:  mout_sel = 2'h0;  /* FMUL output.      */
     endcase
   end

 always @(multfunc) begin
         if((multfunc==4'h1) || (multfunc==4'h2))      mcansel = 2'h3;  /* SP mcanhi.  */
    else if(multfunc[0])                               mcansel = 2'h2;  /* DP mcanlo   */
    else if((multfunc >= 4'h4) && (multfunc < 4'hc))   mcansel = 2'h1;  /* DP mcanhi   */
    else                                               mcansel = 2'h0;  /* default zero. */


     case(multfunc)      // synopsys parallel_case
         4'ha,4'hb,4'h2:    multsel = 3'h3;
         4'h8,4'h9:         multsel = 3'h2;                   
         4'h6,4'h7:         multsel = 3'h1;
         4'h4,4'h5:         multsel = 3'h4;
         4'h1:              multsel = 3'h5;
         default:           multsel = 3'h0;
     endcase
 end
		

endmodule
