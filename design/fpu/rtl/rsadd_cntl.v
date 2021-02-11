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




module rsadd_cntl (	
//			r0md, 
			bsmd, 
			rsfunc, 
//			romsel,
//			nx_rsfunc_rom0,
//			nx_rsfunc_rom1,
			sticky, 
			a0zero, 
			rs32, 
			out, 
                    	erop, 
			rsout_11_0, 
			incinfunc, 
			lsround, 
			rsovfi,
                    	clk, 
			aqcin, 
			rsout_31_30, 
			rsneg, 
			eadd, 
			rs2zero,
			reset_l,
			fpuhold ,
			sm, 
			sin,
			so
			);

  input    [2:0]   rsfunc;
//  input    [2:0]   nx_rsfunc_rom0, nx_rsfunc_rom1;
  input    [2:0]   incinfunc;
  input  [31:30]   rsout_31_30;
  input   [11:0]   rsout_11_0;
  input   sticky, a0zero, rs32, erop, lsround, rsovfi, eadd, clk, reset_l, fpuhold;
//  input  [1:0]	   romsel; 
//  output   [1:0]   r0md;
  output   [2:0]   out;
  output   [1:0]   bsmd;
  output           aqcin, rsneg, rs2zero;

input sm, sin;
output so;

  wire             acin, nextstin, rsround, incdprec, nxincin;


wire fpuhold_l = ~fpuhold;
 
  rsadd_dec rsadec ( 	
			.bsmd(bsmd),
			.acin(acin), 
			.rsfunc(rsfunc),
			.nextstin(nextstin),
			.nxstin(sticky),
			.a0zero(a0zero),
			.rs32(rs32),
			.stin(out[1]),
			.erop(erop), 
		 	.sm(),
			.sin(),
			.so()
			);

  round_dec rs2 ( 	.roundout(rsround),
			.in(rsout_11_0[11:0]),
			.prec(incdprec), 
        		.gin(1'b0),
			.stin(sticky) 
			);

  incin_dec id0 ( 	.nxincin(nxincin), 
			.incinfunc(incinfunc), 
			.lsround(lsround), 
			.rsround(rsround), 
			.incin(out[2]) 
			);


 mj_s_ff_snre_d_3 ff( 	.out(out), 
			.din({nxincin, nextstin, rsovfi}), 
			.lenable(fpuhold_l),
			.reset_l(reset_l), 
			.clk(clk));




  assign incdprec = (incinfunc==3'h3);
  assign aqcin = (acin & out[0]);
  assign rsneg = ~(rsovfi & ~eadd);
  assign rs2zero = (!eadd && !(| rsout_31_30[31:30]));

endmodule


module incin_dec(	nxincin,
			incinfunc,
			lsround,
			rsround,
			incin);

/* Calculates the next INCIN function.  */

  input  [2:0] incinfunc;
  input        lsround, rsround, incin;

  output       nxincin;

  reg         nxincin;

  always @(incinfunc or rsround or lsround or incin) begin
    casex(incinfunc)     // synopsys parallel_case
      3'b001:   nxincin = 1'h1;
      3'b01x:   nxincin = rsround;  /* single/double prec.  */
      3'b10x:   nxincin = lsround;  /* single prec, double prec.  */
      3'b110:   nxincin = incin;
      default:  nxincin = 1'h0;
    endcase
  end

endmodule


module rsadd_dec(	
		//	r0md,
			bsmd,
			acin,
			rsfunc,
		//	nx_rsfunc_rom0,
		//	nx_rsfunc_rom1,
		//	romsel,
			nextstin,
			nxstin,
                 	a0zero,
			rs32,
			stin,
			erop,
		//	clk,
		//	reset_l,
		//	fpuhold_l,
			sm, 
			sin,
			so
			);

input [2:0]  rsfunc; 		//nx_rsfunc_rom0, nx_rsfunc_rom1;
input        rs32, a0zero, nxstin, erop, stin;  // return from RSHIFT.
//input [1:0]  romsel;
input sm, sin;
output [1:0] bsmd; 		//r0md, 
output       acin, nextstin;
output so;

//wire   [3:0] stmdx;

reg  [1:0]  stmd, bsmd;

/*********************************
wire [1:0]  nx_r0md, r0md;
reg  [1:0]  r0md_rom0, r0md_rom1;

 always @(nx_rsfunc_rom0) 
   begin
      casex(nx_rsfunc_rom0)    // synopsys full_case parallel_case
         3'b000:  r0md_rom0 = 2'h2;
         3'b001,
         3'b010,
         3'b11x:  r0md_rom0 = 2'h0;
         3'b011,
         3'b10x:  r0md_rom0 = 2'h1;
         default: r0md_rom0 = 2'hx;
      endcase
   end

 always @(nx_rsfunc_rom1)
   begin
      casex(nx_rsfunc_rom1)    // synopsys full_case parallel_case
         3'b000:  r0md_rom1 = 2'h2;
         3'b001,
         3'b010,
         3'b11x:  r0md_rom1 = 2'h0;
         3'b011,
         3'b10x:  r0md_rom1 = 2'h1;
         default: r0md_rom1 = 2'hx;
      endcase
   end


mj_s_mux3_d_2 r0md_mux(		.mx_out(nx_r0md),
				.sel(romsel),
				.in0(r0md_rom0),
				.in1(r0md_rom1),
				.in2(2'h2));

mj_s_ff_snre_d_2 r0md_ff(	.out(r0md),
				.din(nx_r0md),
				.reset_l(reset_l),
				.clk(clk),
				.lenable(fpuhold_l));
************************************/

 always @(rsfunc) 
   begin
      casex(rsfunc)    // synopsys full_case parallel_case
         3'b0x0,
         3'b101:  bsmd = 2'h0;
         3'b001,
         3'b11x:  bsmd = 2'h1;
         3'b011,
         3'b100:  bsmd = 2'h2;
         default: bsmd = 2'hx;
       endcase
   end

 assign acin = (rsfunc==3'h3);

always @(rsfunc or a0zero or rs32 or erop or stin) begin
      case(rsfunc)            // synopsys parallel_case
         3'h0:  stmd=2'h1;              // x.stin = 0; 
         3'h3:  stmd = {erop,1'b0};   	// x.stin = s.stin;
         3'h7:  stmd = (!a0zero || stin) ? 2'h2: 2'h1;    // x.stin = (!s.a0) ? 0 : 1;
         3'h6: begin
                  if(rs32) 
		    stmd = (a0zero) ? 2'h1 : 2'h2; // x.stin = (s.a0) ? 1 : 0;
                  else     
		    stmd = 2'h3;                // x.stin = nxstin;  (I)
               end
         default:  stmd = 2'h3;                 // x.stin = nxstin;
      endcase
end



mj_s_mux4_d stinout(	.mx_out(nextstin),
			.sel(stmd),
			.in0(stin),
			.in1(1'h0),
			.in2(1'h1),
			.in3(nxstin));

endmodule


module round_dec(roundout,in,prec,gin,stin);
// Performs the extraction and round for the LS or RS portions.

input [11:0]  in;
input         prec,stin,gin;

output        roundout;

wire          g,l,stickyl,stickyh,s;

assign g       = (in[7] && !prec) || (in[10] && prec);
assign l       = (in[8] && !prec) || (in[11] && prec);
assign stickyl = (| in[6:0]) || gin || stin;
assign stickyh = (| in[9:7]) || stickyl;

assign s = (prec) ? stickyh : stickyl;

assign roundout = ((g && s) || (g && !s && l)) ? 1'h1 : 1'h0;  // round

endmodule
