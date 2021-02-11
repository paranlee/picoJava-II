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




module exponent_cntl(priout_l, topsign, le, morethree, 
		     rs32, rsge64, fmulovf, aexpout, saout,
		     addtcin, addlcin, mux1ad, mux2ad, muxbed,
		     muxlimd, muxsad_a, muxsad_b, muxaed, 
		     aexp_sel, bexp_sel, muxpaed_a, fpuhold,
		     mux2bd, expfunc, safunc, movf, clk, reset_l,
		     dprec, cyc0_type, erop, nx_expfunc_rom0, nx_expfunc_rom1,
		     priout, sa, addtop, addlow, muxpaed_b, muxpaed_c,
		     bele, aele, azle, bzle, aexp, bexp, or_out, romsel,sm, sin, so);

input	[3:0]	expfunc, nx_expfunc_rom0, nx_expfunc_rom1;
input	[2:0]	safunc;
input	[1:0]   romsel;
input	[2:0]	cyc0_type;
input	[5:0]	priout;
input		movf, dprec, erop, clk, reset_l, fpuhold;
input	[15:0]	sa, aexp, bexp, addtop, addlow;
input		aele, bele, azle, bzle, topsign;
input		sm,sin;

output		so;
output		le, morethree, rs32, rsge64, fmulovf,
		addtcin, addlcin, muxbed, or_out;
output	[10:0]	aexpout;
output	[4:0]	saout;
output	[5:0]	priout_l;
output	[1:0]	mux1ad, mux2ad;
output	[1:0]	aexp_sel, bexp_sel, muxaed, muxpaed_a, muxpaed_b, 
		muxpaed_c, muxsad_a, muxsad_b;
output	[1:0]	muxlimd, mux2bd;


wire	[5:0]	priout_l;
wire	[10:0]	aexpout;
wire		or_out_top, or_out_low;

wire    fpuhold_l = ~fpuhold;
assign priout_l = ~priout;

//*****************************************************************************
// Do the exponent decode section (synthesis)***********************************


 exptop_dec exptop(	.mux1ad(mux1ad),
			.mux2ad(mux2ad),
			.mux2bd(mux2bd),
                   	.addtcin(addtcin),
			.addlcin(addlcin),
			.ef(expfunc),
			.ef_rom0(nx_expfunc_rom0),
			.ef_rom1(nx_expfunc_rom1),
			.romsel(romsel),
			.clk(clk),
			.reset_l(reset_l),
			.fpuhold_l(fpuhold_l),
			.saf(safunc),
			.sm(),
			.sin(),
			.so());

 expbot_dec expbot(	
	//		.or_out_top(or_out_top),    
	//		.or_out_low(or_out_low),   
			.muxlimd(muxlimd),
			.muxsad_a(muxsad_a),
			.muxsad_b(muxsad_b),
			.muxpaed_a(muxpaed_a),
			.muxpaed_b(muxpaed_b),
			.muxpaed_c(muxpaed_c),
                	.muxbed(muxbed),
			.muxaed(muxaed),
			.ef(expfunc),
			.safunc(safunc),
                	.topsign(topsign),
			.movf(movf),
	//		.eadd(eadd),		
	//		.rsovf(rsovf),		
        //        	.amsb(amsb),		
			.erop(erop));

 exple_dec expcomp(	.le(le),
			.topsign(topsign),
			.bele(bele),
			.aele(aele),
			.azle(azle),
                     	.bzle(bzle),
			.expfunc(expfunc));

 expreg_dec expreg(	.cyc0_type(cyc0_type),
			.aexp_sel(aexp_sel),
                  	.bexp_sel(bexp_sel));

 assign rsge64 = (| sa[15:6]);
 assign rs32   = (rsge64 || sa[5]);
 assign fmulovf = (aexp >= 16'h170) || (aexp < 16'h80);
 
 assign or_out_top = (| addtop[15:6]) || (~dprec && addtop[5]);
 assign or_out_low = (| addlow[15:6]) || (~dprec && addlow[5]);

wire or_out = (topsign) ? or_out_low : or_out_top;

//************************end decode section of exponent******************
//************************************************************************

// First do the EXponent CONstant calculation.  These are 16-bit
// constants used in the exponent calculation.

 assign saout       = sa[4:0];
 assign aexpout     = aexp[10:0];

 assign morethree = ((& aexp[7:3]) || (& bexp[7:3]) || ~(| aexp[7:6])
                    || ~(| bexp[7:6]));

endmodule


module expreg_dec(cyc0_type,aexp_sel,bexp_sel);

input [2:0]  cyc0_type;

output [1:0] aexp_sel,bexp_sel;

reg    [1:0] aexp_sel_a,bexp_sel_a;
wire    [1:0] aexp_sel,bexp_sel;

  always @(cyc0_type) 
             if((cyc0_type==3'h0) || (cyc0_type==3'h3))
                aexp_sel_a = 2'h2;  // double exp.
             else if((cyc0_type==3'h1) || (cyc0_type==3'h5))
                aexp_sel_a = 2'h1;  // single exp.
             else        
                aexp_sel_a = 2'h3;

  always @(cyc0_type)
             if(cyc0_type[2:1]==2'b00)
                bexp_sel_a = {!cyc0_type[0],cyc0_type[0]};  // double exp.
                					  // single exp.
             else        
                bexp_sel_a = 2'h3;

/*********** OLD CODE -   *******
  assign aexp_sel = cyc0_rdy ? aexp_sel_a : 2'h0;
  assign bexp_sel = cyc0_rdy ? bexp_sel_a : 2'h0;
*********** END OF OLD CODE *****************/

//********* NEW CODE -    ******* 

  assign aexp_sel = aexp_sel_a;
  assign bexp_sel = bexp_sel_a;

//******** END OF NEW CODE **********************

endmodule


module exple_dec(le,topsign,bele,aele,azle,bzle,expfunc);

input [3:0]  expfunc;
input        topsign,bele,aele,azle,bzle;

output       le;
reg          le;

always @(expfunc or topsign or bele or aele or azle or bzle) begin
   case(expfunc)       // synopsys parallel_case
     4'h2,4'hf:  le = ~topsign;
     4'ha:       le = aele;
     4'hb:       le = (aele || bele);
     4'hc:       le = bele;
     4'hd,4'he:  le = (aele || bele || azle || bzle);
     default:    le = 1'h0;      
   endcase
end

endmodule


module exptop_dec(mux1ad,mux2ad,mux2bd,addtcin,addlcin,ef,ef_rom0,ef_rom1,
		  romsel,saf,clk,reset_l,fpuhold_l,sm,sin,so);

input [3:0] ef, ef_rom0, ef_rom1;
input [2:0] saf;
input [1:0] romsel;
input       clk, reset_l, fpuhold_l;
input		sm,sin;

output		so;
output addtcin,addlcin;
output [1:0] mux2bd;
output [1:0] mux1ad,mux2ad;

reg [1:0] mux2ad,mux2bd,mux1ad_rom0, mux1ad_rom1;
wire       addtcin,addlcin;
wire [1:0] mux1ad, nx_mux1ad;

always @(ef_rom0)
        if(ef_rom0==4'hd)
                mux1ad_rom0 = 2'h2;  // bexp.
        else if((ef_rom0[3:1]==3'b100) || (ef_rom0==4'h3))
                mux1ad_rom0 = 2'h1;  // excon.
        else
                mux1ad_rom0 = 2'h0;  // ~excon. good

always @(ef_rom1)
        if(ef_rom1==4'hd)
                mux1ad_rom1 = 2'h2;  // bexp.
        else if((ef_rom1[3:1]==3'b100) || (ef_rom1==4'h3))
                mux1ad_rom1 = 2'h1;  // excon.
        else
                mux1ad_rom1 = 2'h0;  // ~excon. good

mj_s_mux3_d_2 mux1ad_mux(	.mx_out(nx_mux1ad),
				.sel(romsel),
				.in0(mux1ad_rom0),
				.in1(mux1ad_rom1),
				.in2(2'h0));


mj_s_ff_snre_d_2 mux1ad_ff(	.out(mux1ad),
				.din(nx_mux1ad),
				.reset_l(reset_l),
				.clk(clk),
				.lenable(fpuhold_l));


always @(ef or saf)
        if(saf==3'h2)
                mux2ad = 2'h1;  // sa
        else if((ef==4'h8) || ( & ef) || (ef==4'ha))
                mux2ad = 2'h2;  // aexp
        else
                mux2ad = 2'h0;  // excon.

always @(ef or saf)
        if((saf==3'h3) || (saf==3'h6) || (saf==3'h1))
                mux2bd = 2'h1;  // ~aexp.
        else if(& ef)
                mux2bd = 2'h2;  // for aexp++
        else if(ef==4'ha)
                mux2bd = 2'h3;  // for aexp--
        else
                mux2bd = 2'h0;  // ~excon.

// ef==7:  will perform aexp-bexp to determine the AE_small signal(TOPSIGN=1) // means AEXP < BEXP.

assign addtcin = !((ef[0] & ef[1] & !ef[2] & !ef[3]) || 
                   (ef[3] & !ef[2] & !ef[1]) || 
                   (ef[0] & !ef[1] & ef[2] & ef[3]));

assign addlcin = !((&ef) || (!ef[0] & ef[1] & !ef[2] & ef[3]));

endmodule

//****************************************************************

module expbot_dec(muxlimd,muxsad_a,muxsad_b,
		  muxpaed_a, muxpaed_b, muxpaed_c, muxbed,muxaed,ef,
		  safunc, topsign,movf,erop);

input       erop,topsign,movf;
input [3:0] ef;
input [2:0] safunc;

output [1:0] muxlimd;
output [1:0] muxaed, muxpaed_a, muxpaed_b, muxpaed_c, muxsad_a, muxsad_b;
output 	     muxbed;

wire  [1:0]   muxlimd,muxsad_a,muxsad_b,muxaed,muxpaed_a,muxpaed_b,
	      muxpaed_c;
wire          muxbed;

 //  Below TOPSIGN is eqivalent to AE_SMALL indicator.
expbot_muxlimd expbot0(.safunc(safunc), .muxlimd(muxlimd));

expbot_muxsad  expbot1(.muxsad_b(muxsad_b), 
		       .muxsad_a(muxsad_a), 
		       .safunc(safunc));

expbot_muxaed  expbot2(.muxaed(muxaed), 
		       .ef(ef), 
		       .topsign(topsign), 
		       .movf(movf), 
		       .erop(erop));

expbot_muxpaed  expbot3(.muxpaed_a(muxpaed_a), 
		        .muxpaed_b(muxpaed_b), 
			.muxpaed_c(muxpaed_c), 
			.ef(ef));


assign muxbed = ((ef==4'h7) && topsign) || (ef==4'h5);   // aexp.

endmodule

//****************************************************************
module expbot_muxlimd(safunc, muxlimd);

output [1:0] muxlimd;
input  [2:0] safunc;
reg [1:0] muxlimd;

always @(safunc)
           if(safunc==3'h2)
              muxlimd = 2'h1;  // pick addlow
           else if(& safunc)
              muxlimd = 2'h0;  // pick 0.
           else if(safunc==3'h0)
              muxlimd = 2'h2;  // sa.
	   else
              muxlimd = 2'h3; 

endmodule

//****************************************************************
module expbot_muxsad(muxsad_b, muxsad_a, safunc);

output [1:0] muxsad_a;
output [1:0] muxsad_b;
input  [2:0] safunc;

reg [1:0] muxsad_a, muxsad_b;

always @(safunc)
        if((safunc==3'h1) || (safunc==3'h6))
            muxsad_a = 2'h0;  // pick {dprec,31}
	else if(safunc==3'h5)
            muxsad_a = 2'h1;  // priout.
        else if(safunc==3'h4)
            muxsad_a = 2'h2;  // excon.
        else
	    muxsad_a = 2'h3;  // other

always @(safunc)
        if(safunc==3'h5)
            muxsad_b = 2'h1;  // priout.
        else if(safunc==3'h4)
            muxsad_b = 2'h2;  // excon.
        else
            muxsad_b = 2'h3;  // other.

endmodule

//****************************************************************
module expbot_muxaed(muxaed, ef, topsign, movf, erop);

input [3:0] ef;
input movf, erop, topsign;
output [1:0] muxaed;

reg [1:0] muxaed_0, muxaed_1;

always @(ef or topsign or erop)
         if((ef==4'h1) || (ef==4'h5)
                       || ((ef==4'h7) && topsign))
             muxaed_1 = 2'h1; // excon.
        else if(((ef==4'h3)) ||(ef==4'h6)
                       || (ef[3] & ef[0] & !ef[1]))
             muxaed_1 = 2'h2; //add,sub
        else if((ef==4'h8) || (& ef) || (ef==4'h4) ||
                          ((ef==4'ha) && erop))
             muxaed_1 = 2'h3; // muxpae.
        else
             muxaed_1 = 2'h0; // aexp.

always @(ef or topsign or erop)
         if((ef==4'h1) || (ef==4'h5)
                       || ((ef==4'h7) && topsign))
             muxaed_0 = 2'h1; // excon.
        else if((ef==4'h6)
                       || (ef[3] & ef[0] & !ef[1]))
             muxaed_0 = 2'h2; //add,sub
        else if((ef==4'h8) || (& ef) || (ef==4'h4) ||
                          ((ef==4'ha) && erop))
             muxaed_0 = 2'h3; // muxpae.
        else
             muxaed_0 = 2'h0; // aexp.


mj_s_mux2_d_2 movfmux( .mx_out(muxaed),
                        .sel(movf),
                        .in0(muxaed_0),
                        .in1(muxaed_1));

endmodule

//****************************************************************

module expbot_muxpaed (muxpaed_a, muxpaed_b, muxpaed_c, ef);

input [3:0] ef;
output [1:0] muxpaed_a,
	     muxpaed_b,
	     muxpaed_c;

reg [1:0] muxpaed_a,
          muxpaed_b,
          muxpaed_c;

always @(ef)
        if(ef==4'h4)
              muxpaed_a = 2'h3; // priadd.
        else if(ef==4'h8)
              muxpaed_a = 2'h0;
	else
	      muxpaed_a = 2'h1;

always @(ef)
        if(ef==4'h4)
              muxpaed_b = 2'h3; // priadd.
        else if(ef==4'h8)
              muxpaed_b = 2'h2;
        else
              muxpaed_b = 2'h1;

always @(ef)			
        if(ef==4'h4)
              muxpaed_c = 2'h3; // priadd.
	else 
	      muxpaed_c = 2'h1;

endmodule
