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



module mantissa_dec(b0sel_a,b0sel_b,a_small,a1sel,a0sel,a0psel,
		    altb,expsame,ae_small,b1sel,
                    a0func,a1func,fp_out_sel,fpu_state,b1msb,b1msbin,
		    b1psel, a1psel,a2sel,eadd,a2func,morethree_taken,
		    cyc0_rdy,cyc0_type, cyc1_rdy,a1comp,a0comp,b1comp,
		    b0comp,mconfunc,amsb,manzero,
		    a1zzsel,b1_cyc0sel,cyc0_sel);

  input   [2:0]  a2func,a1func,a0func,cyc0_type;
  input   [7:0]  fpu_state;
  input   [1:0]  mconfunc;
  input          altb,expsame,ae_small;
  input          b1msb,eadd,morethree_taken;
  input          cyc0_rdy,cyc1_rdy,amsb,a1comp,a0comp,b1comp,b0comp;

  output    [2:0]  a0psel;
  output    [2:0]  fp_out_sel;
  output    [2:0]  a1sel;  
  output    [1:0]  b0sel_a,b0sel_b,b1sel,a1psel,a2sel;
  output    [1:0]  cyc0_sel;
  output           b1psel,b1msbin,manzero,a_small,a1zzsel,b1_cyc0sel;
  output    [2:0]  a0sel;

  wire             a_small,a1top,b1_cyc0sel;

`define s0 0
`define s1 1
`define s2 2
`define s3 3
`define s4 4
`define s5 5
`define s6 6
`define s7 7


  reg     [2:0]  fp_out_sel, a0selz;
  reg     [1:0]  a2sel,b1sel,cyc0_sel;
  reg            manzero,a1zzsel;
  wire	  [2:0]  a1selz, a0psel, a0psel_0, a0psel_1;
  wire	  [1:0]  a1psel;
  wire	  [2:0]  a0pselz;
  wire		 a0pselz_0, a_small0, a_small1;
  

//  wire [2:0] a2seltemp;

    assign a1top = (amsb && (& a2func)); // Special test to top bit.

    always @(mconfunc or a1comp or a0comp or b1comp or b0comp or amsb or 
	     a1top) 
     begin
      case(mconfunc)
        2'h0:    manzero = (a1comp && a0comp && !a1top); 
        2'h1:    manzero = (b1comp && b0comp);
        2'h2:    manzero = (a1comp && !amsb);
        2'h3:    manzero = (a0comp);
        default: manzero = 1'h0;
      endcase
     end


    assign b1msbin = !(a1func==3'h2) & b1msb;
    assign a_small = (expsame) ? altb : ae_small;
    assign a_small0 = (expsame) ? 1'b0 : ae_small;
    assign a_small1 = (expsame) ? 1'b1 : ae_small;


    assign b0sel_a = cyc1_rdy ? 2'h2 : 2'h0;
    assign b0sel_b = cyc1_rdy ? 2'h2 : 2'h1;

    always @(a2func or eadd)  begin
        case(a2func)       // synopsys parallel_case
              3'h1:    a2sel = 2'h1;               /* zero */
              3'h2:    a2sel = {!eadd,eadd};
              3'h3:    a2sel = 2'h2;
              default: a2sel = 2'h0;
        endcase
    end

    always @(fpu_state)  
	begin
	  case(1'b1)         // synopsys full_case parallel_case
	    fpu_state[`s0], 
	    fpu_state[`s1], 
	    fpu_state[`s2]: fp_out_sel = 3'h0;   // zero.
	    fpu_state[`s3]: fp_out_sel = 3'h5;   // single.
	    fpu_state[`s4]: fp_out_sel = 3'h4;   // LSW double.
	    fpu_state[`s5]: fp_out_sel = 3'h3;   // MSW double.
	    fpu_state[`s6]: fp_out_sel = 3'h2;   // Low word of LONG.
	    fpu_state[`s7]: fp_out_sel = 3'h1;   // Top word of INT/LONG.
 	    default: fp_out_sel = 3'hx;
	  endcase
	end


    always @(a0func)
      casex(a0func)       // synopsys  full_case parallel_case
        3'b00x,
        3'b10x,
        3'b110:  a0selz = 3'h3;	
        3'b010:  a0selz = 3'h0;
        3'b011:  a0selz = 3'h1;
        3'b111:  a0selz = 3'h2;
        default: a0selz = 3'hx;
      endcase


assign a0pselz[0] = (a0func[0] & !a0func[1] & a0func[2]) | 
		    (!a0func[0] & a0func[1] & a0func[2]) |
		    (a0func[0] & !a0func[1] & !a0func[2] & !a_small0);

assign a0pselz_0 = (a0func[0] & !a0func[1] & a0func[2]) |
                    (!a0func[0] & a0func[1] & a0func[2]) |
		    (a0func[0] & !a0func[1] & !a0func[2] & !a_small1);

assign a0pselz[1] = (!a0func[0] & a0func[2]);

assign a0pselz[2] = 1'b0;


    assign a0sel = cyc1_rdy ? 3'h3 : a0selz;


assign a0psel_0 = cyc1_rdy ? 3'h4 : a0pselz;
assign a0psel_1 = cyc1_rdy ? 3'h4 : {a0pselz[2:1],a0pselz_0};

assign a0psel = altb ? a0psel_1 : a0psel_0;


   always @(cyc0_type) begin
        if(cyc0_type==3) 
		cyc0_sel = 2'h1;  /* A0 CYC0 double. (one operand)  */
        else if(cyc0_type==2) 
		cyc0_sel = 2'h2;  /* A0 CYC0 long.   (one operand)  */
        else                  
		cyc0_sel = 2'h0;  /* ZERO.  */
   end

assign a1selz[0] = (!a1func[0] & a1func[2]) |
		   (&a1func & a_small & !(morethree_taken | eadd));

assign a1selz[1] = (!a1func[2]) |
		   (a1func[0] & !a1func[1] & a1func[2]) |
		   (!a1func[0] & a1func[1] & a1func[2]) |
		   (&a1func & (morethree_taken | eadd | a_small));

assign a1selz[2] = (!a1func[2]) |
		   (&a1func & (morethree_taken | eadd | !a_small));
		   

   always @(a1func or morethree_taken or a_small or eadd) begin
      casex(a1func)     //  synopsys full_case parallel_case
          3'b000, 
          3'b10x, 		     /* rsout, lsout */
          3'b110: a1zzsel = 1'b0;    /* a1inc */
          3'b001: a1zzsel = {!a_small};
	  3'b01x: a1zzsel = 1'b1;   // {b1msbin,b1[30:0]}
          3'b111: begin
                  if(morethree_taken)
                        a1zzsel = 1'b0;
                  else if(eadd) 
                        a1zzsel = {!a_small};
                  else 
                        a1zzsel = 1'b0;
                end
       	  default: a1zzsel = 1'bx;
      endcase
  end


assign a1psel[0] = ((!cyc0_type[1]) |
		    (cyc0_type[1] & !cyc0_type[2])) & cyc0_type[0];

assign a1psel[1] = (cyc0_type == 3'b100) | (cyc0_type[1] & !cyc0_type[2]);

   assign a1sel = cyc1_rdy ? 3'h5 : a1selz;


 
  wire b1psel = (cyc0_type==0);  /* DOUBLE0. */
  assign b1_cyc0sel = cyc0_rdy;  // b1pre

 always @(a1func or a_small or morethree_taken or cyc1_rdy) begin
      if(cyc1_rdy)      
	b1sel = 2'h3;   /* DOUBLE1. */
      else if(a1func==3'h2)  
	b1sel = 2'h2;
      else
  	b1sel = {1'b0,(((& a1func) && !a_small && !morethree_taken)||
                         ((a1func==3'h1) && !a_small) || (a1func==3'h3))};
 end


endmodule
