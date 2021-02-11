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



`include "fpu.h"

module code_seq_cntl (	reset_l, 
			valid_opcode, 
			fpuhold, 
			fpu_state, 
			opcode_look,
			nx_opcode_look,
                       	fpbusyn, 
			cyc1_rdy, 
			fpkill, 
			clk, 
			romsel, 
			morethree_taken,
                       	rsovfi, 
			rsneg, 
			amsb, 
			incovf, 
			rs2zero, 
			rs32, 
			rsge64, 
			eadd, 
			le, 
                       	manzero, 
			morethree, 
			absign, 
			fmulovf, 
			cyc0_rdy_p, 
			branch, 
			qin,
                       	qmsb, 
			a2func, 
			opcode, 
			cyc0_type, 
			top_fpbin, 
			bsignin, 
			dprec,
			nx_dprec,
			nxcode,
			so,
			sin,
			sm 
			);


  input   [7:0] opcode;
  input   [7:0] nxcode;
  input   [3:0] branch; 
  input   [2:0] a2func;
  input         reset_l, 
		valid_opcode, 
		fpuhold, 
		fpkill, 
		clk, 
		rsovfi, 
		rsneg, 
		amsb,
                incovf, 
		rs2zero, 
		rs32, 
		rsge64, 
		eadd, 
		le, 
		manzero, 
		morethree, 
		absign,
                fmulovf, 
		cyc0_rdy_p, 
		qin, 
		qmsb, 
		top_fpbin;

  input         sm, sin;
  output	so;

  output  [2:0] cyc0_type; 
  output  [1:0] romsel;
  output  [7:0] fpu_state;
  output        opcode_look, nx_opcode_look,
		fpbusyn, 
		cyc1_rdy, 
		morethree_taken, 
		bsignin, 
		dprec, nx_dprec;

//  wire    [7:0] next_fpu_state;
  wire          dp_out, mfinish, two_cycle_in, int_out, 
		long_out, addsub, rem_op, dp_outp, addsubp, 
		dprecp, int_outp, long_outp, rem_opp, conreg_enable,
		cyc0_rdy_p;	

  assign mfinish = ((branch==4'hb) && (nxcode==8'h0));

  fpu_dec fpud(		.dp_out(dp_out),
			.mfinish(mfinish),
			.reset_l(reset_l),
			.clk(clk),
			.valid_opcode(valid_opcode),
             		.two_cycle_in(two_cycle_in),
			.fpuhold(fpuhold),
			.fpkill(fpkill),
			.fpu_state(fpu_state),
			.opcode_look(opcode_look),
			.nx_opcode_look(nx_opcode_look),
             		.int_out(int_out),
			.long_out(long_out),
			.fpbusyn(fpbusyn),
			.cyc1_rdy(cyc1_rdy), 
			.sm(),.sin(),.so());


  branch_dec branchd(	.romsel(romsel),
			.morethree_taken(morethree_taken),
			.rsovfi(rsovfi),
             		.rsneg(rsneg),
			.amsb(amsb),
			.incovf(incovf),
			.rs2zero(rs2zero),
			.rs32(rs32),
             		.rsge64(rsge64),
			.eadd(eadd),
			.le(le),
			.manzero(manzero),
			.morethree(morethree),
             		.absign(absign),
			.fmulovf(fmulovf),
			.fpkill(fpkill),
			.cyc0_rdy_p(cyc0_rdy_p),
			.addsub(addsub),
			.branch(branch),
			.qin(qin),
			.qmsb(qmsb),
			.rem_op(rem_op),
			.a2func(a2func));


  opcode_dec d8(	.opcode(opcode),
			.dp_outp(dp_outp),
			.addsubp(addsubp),
			.two_cycle_in(two_cycle_in),
               		.dprecp(dprecp),
			.int_outp(int_outp),
			.long_outp(long_outp),
			.cyc0_type(cyc0_type),
                	.top_fpbin(top_fpbin),
			.bsignin(bsignin),
			.rem_opp(rem_opp));

//assign conreg_enable = (valid_opcode && opcode_look && !fpuhold);
wire [5:0] conreg_din;
assign conreg_enable = (valid_opcode && opcode_look);
mj_s_mux2_d_6 fpumux( .mx_out(conreg_din),
                        .sel(conreg_enable),
                        .in0({rem_op,long_out,int_out,dp_out,addsub,dprec}),
                        .in1({rem_opp,long_outp,int_outp,dp_outp,addsubp,dprecp}));

assign nx_dprec = (conreg_enable) ? dprecp:dprec;

mj_s_ff_snre_d_6 conreg (.out({rem_op,long_out,int_out,dp_out,addsub,dprec}),
			.din(conreg_din),
			.lenable(!fpuhold),
			.reset_l(reset_l),
			.clk(clk));
endmodule


module opcode_dec(	opcode,
			dp_outp,
			addsubp,
			two_cycle_in,dprecp,
			int_outp,
			long_outp,
			cyc0_type,
                  	top_fpbin,
			bsignin,
			rem_opp );
 
  input  [7:0]   opcode;
  input          top_fpbin;   // Msb of the FPBIN at cyc0_rdy

  output [2:0]   cyc0_type;
  output         dp_outp, addsubp, two_cycle_in, dprecp, int_outp, long_outp, bsignin, rem_opp;

  reg            dprecp,addsubp, dp_outp, two_cycle_in;
  wire   [2:0]   cyc0_type;
  reg		 ncyc0_type0, ncyc0_type2, cyc0_type1;

  assign bsignin = ((opcode==`FSUB) || (opcode==`DSUB)) ? 
					!top_fpbin : top_fpbin;
  assign rem_opp = ((opcode==`FREM) || (opcode==`DREM));

  always @(opcode) begin
     case(opcode)      // synopsys parallel_case
           `FCMPG,
	   `FSUB,
	   `FADD : begin
                    	dprecp=1'h0;  
		    	addsubp= 1'h1; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
           `FCMPL,
	   `FREM,
	   `FMUL,
	   `FDIV : begin
                    	dprecp=1'h0;  
			addsubp= 1'h0; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
           `DCMPG: begin
                    	dprecp=1'h1;  
			addsubp= 1'h1; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h1; 
                  end
           `DCMPL: begin
                    	dprecp=1'h1;  
			addsubp= 1'h0; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h1; 
                  end
           `DSUB,
	   `DADD,
	   `DDIV :begin
                    	dprecp=1'h1;  
			addsubp= 1'h1; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h1; 
                  end
           `DREM,
	   `DMUL :  begin
                    	dprecp=1'h1;  
			addsubp= 1'h0; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h1; 
                  end
           `F2D:   begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h0; 
                  end
           `D2F,
	   `D2I : begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
           `F2I:   begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
           `F2L:   begin
                    	dprecp=1'h1;  
			addsubp= 1'h1; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h0; 
                  end
           `D2L:   begin
                    	dprecp=1'h1;  
			addsubp= 1'h1; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h0; 
                  end
           `I2F:   begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
           `L2F:   begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
           `I2D:   begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h0; 
                  end
           `L2D:   begin
                    	dprecp=1'h0;  
			addsubp= 1'h1; 
			dp_outp= 1'h1; 
			two_cycle_in= 1'h0; 
                  end
      default:    begin
                    	dprecp=1'h0;  
			addsubp= 1'h0; 
			dp_outp= 1'h0; 
			two_cycle_in= 1'h0; 
                  end
    endcase
  end

// Separated the cyc0_type generation from the above case statement

  always @(opcode) begin
      case(opcode)      // synopsys parallel_case
	   `DCMPG,
           `DCMPL,
           `DSUB,
           `DADD,
           `DDIV,
           `DREM,
           `DMUL,
	   `I2F, 
           `I2D, 
           `L2F,
           `L2D:  ncyc0_type0 = 1'b1;
	default:  ncyc0_type0 = 1'b0;
	endcase
  end

assign cyc0_type[0] = !ncyc0_type0;
	 
  always @(opcode) begin
     case(opcode)      // synopsys parallel_case
	   `D2F,
           `D2I,
           `D2L,
           `L2F,
           `L2D: cyc0_type1 = 1'b1;
	default: cyc0_type1 = 1'b0;
      endcase
  end

assign cyc0_type[1] = cyc0_type1;

  always @(opcode) begin
     case(opcode)      // synopsys parallel_case
	   `FCMPG,
           `FSUB,
           `FADD,
           `FCMPL,
           `FREM,
           `FMUL,
           `FDIV,
           `DCMPG,
           `DCMPL,
           `DSUB,
           `DADD,
           `DDIV,
           `DREM,
           `DMUL,
           `D2F,
           `D2I,
           `D2L, 
           `L2F,
           `L2D: ncyc0_type2 = 1'b1;
	default: ncyc0_type2 = 1'b0;
	endcase
  end 

assign cyc0_type[2] = !ncyc0_type2;



  assign int_outp  = ((opcode==`F2I) || (opcode==`D2I) || (opcode==`FCMPL)
                      || (opcode==`FCMPG) || (opcode==`DCMPL) || 
			 (opcode==`DCMPG));

  assign long_outp = ((opcode==`F2L) || (opcode==`D2L));

endmodule


// triquest fsm_begin
module fpu_dec(		dp_out,
			mfinish,
			reset_l,
			valid_opcode,
			two_cycle_in,
			fpuhold,
			fpkill,
               		fpu_state,
			opcode_look,
			nx_opcode_look,
			int_out,
			long_out,
			fpbusyn,
			cyc1_rdy,
			clk,
			so,
			sin,
			sm);

  input		 clk;
  input          dp_out;         //  Indicates that two output cycles are needed.
  input          mfinish;        //  Indicates completion of microcoded calculation stages.
  input          valid_opcode;   // Indicates Valid opcode input.
  input          two_cycle_in;   // Indicates that a two input cycle transaction is needed.
  input          fpuhold, fpkill, reset_l;
  input          int_out, long_out;  // Int and long signals.
  input         sm, sin;
  output	so;
  output  [7:0]  fpu_state;
  output         opcode_look, fpbusyn, cyc1_rdy;
  output         nx_opcode_look;

  reg     [7:0]  next_fpu_state;
  wire	  [7:0]  next_fpu_statep, fpu_state;

//*********************************************************************
// Access State Machine definition
//*********************************************************************

parameter [7:0]  // triquest enum FPU_STATE_ENUM
		S0 =    8'b0000_0001,       // idle
                S1 =    8'b0000_0010,       
                S2 =    8'b0000_0100,     
                S3 =    8'b0000_1000,    
                S4 =    8'b0001_0000,
                S5 =    8'b0010_0000,
                S6 =    8'b0100_0000,
                S7 =    8'b1000_0000;

`define s0 0
`define s1 1
`define s2 2
`define s3 3
`define s4 4
`define s5 5
`define s6 6
`define s7 7


mj_s_mux2_d_8 fpumux( .mx_out(next_fpu_statep),
                        .sel(fpkill),
                        .in0(next_fpu_state),
                        .in1(S0));

//triquest state_vector {fpu_state[7:0]} FPSTATE enum FPU_STATE_ENUM
mj_s_ff_snre_d_8 ff_fpstate (.out(fpu_state),
                        .din(next_fpu_statep),
                        .lenable(!fpuhold),
                        .reset_l(reset_l),
                        .clk(clk));

  always @(dp_out or mfinish or valid_opcode or two_cycle_in
           or fpu_state or int_out or long_out) 
    begin
     case(1'b1)  	// synopsys full_case parallel_case
         fpu_state[`s0]:  begin
                     if(!valid_opcode)              
			next_fpu_state = S0;
                     else if(two_cycle_in)              
			next_fpu_state = S1;
                     else                               
			next_fpu_state = S2;
         end

         fpu_state[`s1]:                      
		     next_fpu_state = S2;

         fpu_state[`s2]:  begin
                  if(mfinish && long_out)  
			next_fpu_state = S6;
                  else if(mfinish && int_out)   
			next_fpu_state = S7;
                  else if(mfinish && dp_out)    
			next_fpu_state = S4;
                  else if(mfinish)              
			next_fpu_state = S3;
                  else                          
			next_fpu_state = S2;
         end

         fpu_state[`s3]:  begin
//              if(valid_opcode && !two_cycle_in)             
//			next_fpu_state = S2;
//              else if(valid_opcode && two_cycle_in)              
//			next_fpu_state = S1;
//              else                               
			next_fpu_state = S0;
         end

         fpu_state[`s4]: next_fpu_state = S5; 

         fpu_state[`s5]:  begin
//                if(valid_opcode && !two_cycle_in)             
//			next_fpu_state = S2;
//                else if(valid_opcode && two_cycle_in)              
//			next_fpu_state = S1;
//                else                               
			next_fpu_state = S0;
         end

         fpu_state[`s6]: next_fpu_state = S7;

         fpu_state[`s7]:  begin
//               if(valid_opcode && !two_cycle_in)             
//			next_fpu_state = S2;
//                else if(valid_opcode && two_cycle_in)              
//			next_fpu_state = S1;
//                else                               
			next_fpu_state = S0;
         end

         default: next_fpu_state = S0;
     endcase
   end

//   assign opcode_look =    fpu_state[`s0] || fpu_state[`s3] ||
//                           fpu_state[`s5] || fpu_state[`s7];
//   assign nx_opcode_look =    next_fpu_state[`s0] || next_fpu_state[`s3] ||
//                           next_fpu_state[`s5] || next_fpu_state[`s7];

   assign opcode_look =    fpu_state[`s0];

   assign nx_opcode_look =    next_fpu_state[`s0];


//   assign fpbusyn     = !(next_fpu_state[`s1] || next_fpu_state[`s2] || 
//			fpu_state[`s1] || (!mfinish && fpu_state[`s2]));
//   assign fpbusyn     = !(fpu_state[`s1] || (!mfinish && fpu_state[`s2]));

   assign fpbusyn     = !(next_fpu_state[`s1] || next_fpu_state[`s2] || 
			fpu_state[`s1] || (fpu_state[`s2]));

   assign cyc1_rdy    = (fpu_state[`s1]);
             
endmodule
// triquest fsm_end


//*********************************************************************

module branch_dec(	romsel,
			morethree_taken,
			rsovfi,
			rsneg,
			amsb,
			incovf,
			rs2zero,
			rs32,
			rsge64,
			eadd,
                  	le,
			manzero,
			morethree,
			absign,
			fmulovf,
			fpkill,
			cyc0_rdy_p,
			addsub,
			branch,
			qin,
			qmsb,
			rem_op,
			a2func);

input         rsovfi, rsneg, incovf, rs2zero, rs32, rsge64, eadd, le, manzero;
input         morethree, absign, fmulovf;
input         fpkill, addsub, amsb, cyc0_rdy_p,  
	      qin, qmsb, rem_op;
input  [2:0]  a2func;
input  [3:0]  branch;

output [1:0]  romsel;   //  Drives the ROM_MUX select--is the microcode branch taken indicator.
output        morethree_taken;  // Indicates that the MORETHREE branch was taken.

// reg           romselp_a, romselp_b;
reg   [1:0]   final_sel;

//wire  [3:0]   fast_selx, final_selx, romselx_sel;
wire          fastout, romsel_a, romsel_b, romsel_c, romsel_d, romselp_a, romselp_b, romselp_c, romselp_d;


branch_decode1 b1(	.romselp_a(romselp_a),
			.branch(branch),
			.morethree(morethree),
			.fmulovf(fmulovf),
			.rsge64(rsge64),
			.absign(absign),
			.addsub(addsub),
			.manzero(manzero),
			.rs32(rs32),
			.eadd(eadd),
			.amsb(amsb),
			.rem_op(rem_op),
			.qmsb(qmsb),
			.a2func(a2func));

branch_decode2 b2(      .romselp_b(romselp_b),
                        .branch(branch),
                        .morethree(morethree),
                        .fmulovf(fmulovf),
                        .rsge64(rsge64),
                        .absign(absign),
                        .addsub(addsub),
                        .manzero(manzero),
                        .rs32(rs32),
                        .eadd(eadd),
                        .amsb(amsb),
                        .rem_op(rem_op),
                        .qmsb(qmsb),
                        .a2func(a2func));

branch_decode3 b3(      .romselp_c(romselp_c),
                        .branch(branch),
                        .morethree(morethree),
                        .fmulovf(fmulovf),
                        .rsge64(rsge64),
                        .absign(absign),
                        .addsub(addsub),
                        .manzero(manzero),
                        .rs32(rs32),
                        .eadd(eadd),
                        .amsb(amsb),
                        .rem_op(rem_op),
                        .qmsb(qmsb),
                        .a2func(a2func));

branch_decode4 b4(      .romselp_d(romselp_d),
                        .branch(branch),
                        .morethree(morethree),
                        .fmulovf(fmulovf),
                        .rsge64(rsge64),
                        .absign(absign),
                        .addsub(addsub),
                        .manzero(manzero),
                        .rs32(rs32),
                        .eadd(eadd),
                        .amsb(amsb),
                        .rem_op(rem_op),
                        .qmsb(qmsb),
                        .a2func(a2func));


//always @(cyc0_rdy_p or branch or fpuhold) 
//	begin
//   	  if(cyc0_rdy_p & !fpuhold)         
//		final_sel = 2'h3;
//   	  else if(branch >= 4'hc)   
//		final_sel = 2'h0;
//    	  else                      
//		final_sel = 2'h1;
//	end


 always @(cyc0_rdy_p or branch) 
	begin
   	  if(cyc0_rdy_p)         
		final_sel = 2'h3;
    	  else if(branch >= 4'hc)   
		final_sel = 2'h0;
    	  else                      
		final_sel = 2'h1;
 	end


mj_s_mux4_d m0(	.mx_out(fastout),
		.sel(branch[1:0]),
		.in0(rsneg),
		.in1(rsovfi),
		.in2(rs2zero),
		.in3(le));


mj_s_mux4_d m1(	.mx_out(romsel_a),
		.sel(final_sel),
		.in0(fastout),
		.in1(romselp_a),
		.in2(1'h1),
		.in3(1'h0));
mj_s_mux4_d m2(  .mx_out(romsel_b),
                .sel(final_sel),
                .in0(fastout),
                .in1(romselp_b),
                .in2(1'h1),
                .in3(1'h0));
mj_s_mux4_d m3( .mx_out(romsel_c),
                .sel(final_sel),
                .in0(fastout),
                .in1(romselp_c),
                .in2(1'h1),
                .in3(1'h0));
mj_s_mux4_d m4( .mx_out(romsel_d),
                .sel(final_sel),
                .in0(fastout),
                .in1(romselp_d),
                .in2(1'h1),
                .in3(1'h0));





 assign morethree_taken = ((branch==4'h1) && morethree);


 wire [1:0] romsel0 = (fpkill) ? 2'b10 : {1'h0,romsel_a};
 wire [1:0] romsel1 = (fpkill) ? 2'b10 : {1'h0,romsel_b};
 wire [1:0] romsel2 = (fpkill) ? 2'b10 : {1'h0,romsel_c};
 wire [1:0] romsel3 = (fpkill) ? 2'b10 : {1'h0,romsel_d};


mj_s_mux4_d_2 romsel_mux(.mx_out(romsel),
			.sel({qin,incovf}),
			.in0(romsel0),
			.in1(romsel1),
			.in2(romsel2),
			.in3(romsel3));


endmodule

//***************************************************************
// qin=0, incovf=0

module branch_decode1(branch, morethree, fmulovf, rsge64, absign, addsub,
		      manzero, rs32, eadd, amsb, rem_op, qmsb,
		      a2func, romselp_a);

output romselp_a;
input [3:0] branch;
input 	morethree,
	fmulovf,
	rsge64,
	absign,
	addsub,
	manzero,
	rs32,
	eadd,
	amsb,
	rem_op,
	qmsb;
input [2:0] a2func;

reg romselp_a;
	
 always @(branch or morethree or fmulovf or rsge64 or absign or
          addsub or manzero or
          rs32 or eadd or amsb or rem_op or qmsb or a2func)
 begin
   case(branch)    // synopsys parallel_case
       4'h0:  romselp_a = 1'h1;
       4'h1:  romselp_a = morethree;
       4'h3:  romselp_a = fmulovf;
       4'h4:  romselp_a = rsge64;
       4'h5:  romselp_a = absign;
       4'h6:  romselp_a = addsub;
       4'h7:  romselp_a = manzero;
       4'h8:  romselp_a = rs32;
       4'h9:  romselp_a = eadd;
       4'ha:  begin
                 if(rem_op) romselp_a = (a2func==3'h6) ? 1'b0  : amsb;
                 else       romselp_a = (a2func==3'h6) ? qmsb : amsb;
              end
       default: romselp_a = 1'h0;
   endcase
 end

endmodule

//***************************************************************
//qin=0, incovf=1

module branch_decode2(branch, morethree, fmulovf, rsge64, absign, addsub,
                      manzero, rs32, eadd, amsb, rem_op, qmsb,
                      a2func, romselp_b);

output romselp_b;
input [3:0] branch;
input   morethree,
        fmulovf,
        rsge64,
        absign,
        addsub,
        manzero,
        rs32,
        eadd,
        amsb,
        rem_op,
        qmsb;
input [2:0] a2func;

reg romselp_b;

 always @(branch or morethree or fmulovf or rsge64 or absign or
          addsub or manzero or
          rs32 or eadd or amsb or rem_op or qmsb or a2func)
 begin
   case(branch)    // synopsys parallel_case
       4'h0,
       4'h2:  romselp_b = 1'h1;
       4'h1:  romselp_b = morethree;
       4'h3:  romselp_b = fmulovf;
       4'h4:  romselp_b = rsge64;
       4'h5:  romselp_b = absign;
       4'h6:  romselp_b = addsub;
       4'h7:  romselp_b = manzero;
       4'h8:  romselp_b = rs32;
       4'h9:  romselp_b = eadd;
       4'ha:  begin
                 if(rem_op) romselp_b = (a2func==3'h6) ? 1'b0  : amsb;
                 else       romselp_b = (a2func==3'h6) ? qmsb : amsb;
              end
       default: romselp_b = 1'h0;
   endcase
 end
endmodule

//***************************************************************
//qin=1, incovf=0

module branch_decode3(branch, morethree, fmulovf, rsge64, absign, addsub,
                      manzero, rs32, eadd, amsb, rem_op, qmsb,
                      a2func, romselp_c);

output romselp_c;
input [3:0] branch;
input   morethree,
        fmulovf,
        rsge64,
        absign,
        addsub,
        manzero,
        rs32,
        eadd,
        amsb,
        rem_op,
        qmsb;
input [2:0] a2func;

reg romselp_c;

 always @(branch or morethree or fmulovf or rsge64 or absign or
          addsub or manzero or
          rs32 or eadd or amsb or rem_op or qmsb or a2func)
 begin
   case(branch)    // synopsys parallel_case
       4'h0:  romselp_c = 1'h1;
       4'h1:  romselp_c = morethree;
       4'h3:  romselp_c = fmulovf;
       4'h4:  romselp_c = rsge64;
       4'h5:  romselp_c = absign;
       4'h6:  romselp_c = addsub;
       4'h7:  romselp_c = manzero;
       4'h8:  romselp_c = rs32;
       4'h9:  romselp_c = eadd;
       4'ha:  begin
                 if(rem_op) romselp_c = (a2func==3'h6) ? 1'b1  : amsb;
                 else       romselp_c = (a2func==3'h6) ? qmsb : amsb;
              end
       default: romselp_c = 1'h0;
   endcase
 end
endmodule

//***************************************************************
//qin=1, incovf=1

module branch_decode4(branch, morethree, fmulovf, rsge64, absign, addsub,
                      manzero, rs32, eadd, amsb, rem_op, qmsb,
                      a2func, romselp_d);

output romselp_d;
input [3:0] branch;
input   morethree,
        fmulovf,
        rsge64,
        absign,
        addsub,
        manzero,
        rs32,
        eadd,
        amsb,
        rem_op,
        qmsb;
input [2:0] a2func;

reg romselp_d;

 always @(branch or morethree or fmulovf or rsge64 or absign or
          addsub or manzero or
          rs32 or eadd or amsb or rem_op or qmsb or a2func)
 begin
   case(branch)    // synopsys parallel_case
       4'h0,
       4'h2:  romselp_d = 1'h1;
       4'h1:  romselp_d = morethree;
       4'h3:  romselp_d = fmulovf;
       4'h4:  romselp_d = rsge64;
       4'h5:  romselp_d = absign;
       4'h6:  romselp_d = addsub;
       4'h7:  romselp_d = manzero;
       4'h8:  romselp_d = rs32;
       4'h9:  romselp_d = eadd;
       4'h9:  romselp_d = eadd;
       4'ha:  begin
                 if(rem_op) romselp_d = (a2func==3'h6) ? 1'b1  : amsb;
                 else       romselp_d = (a2func==3'h6) ? qmsb : amsb;
              end
       default: romselp_d = 1'h0;
   endcase
 end
endmodule
