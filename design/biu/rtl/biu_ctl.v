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






module	biu_ctl (
	icu_req,
	icu_type,
	icu_size,
	biu_icu_ack,
	dcu_req,
	dcu_type,
	dcu_size,
	biu_dcu_ack,
	clk,
	reset_l,
	pj_tv,
	pj_type,
	pj_size,
	pj_ack,
	sm,
	sin,
	so,
	arb_select,
	pj_ale
	);


input		icu_req;
input   [3:0]   icu_type; 
input   [1:0]   icu_size;
output	[1:0]	biu_icu_ack;		
input		dcu_req;
input	[3:0]	dcu_type;
input	[1:0]	dcu_size;
output	[1:0]	biu_dcu_ack;		
input		clk;
input		reset_l;
output		pj_tv;
input	[1:0]	pj_ack;
output	[3:0]	pj_type;
output  [1:0]   pj_size;
input		sm;
input		sin;
output		so;
output		arb_select;
output		pj_ale;


wire		arbiter_sel;
wire		temp_arb_sel;
wire		arb_select;
wire		arb_idle;
wire	[4:0]	arb_next_state;
wire	[4:0]	arb_state;
wire		icu_tx;
wire		dcu_tx;
wire	[2:0]	num_acks;
wire	[3:0]	type_state;


assign	pj_tv = ((icu_req | dcu_req) & arb_state[0]) | arb_state[1] ;
assign	icu_tx = !type_state[2];		
assign	dcu_tx = type_state[2];
assign  biu_dcu_ack = {dcu_tx,dcu_tx} & pj_ack;	//2{dcu_tx}
assign  biu_icu_ack = {icu_tx,icu_tx} & pj_ack;
assign	pj_ale = ~(pj_tv & arb_state[0]);

/* muxes for pj_type and pj_size */
mux2_2    biu_size_mux(.out(pj_size[1:0]),
          .in1(icu_size[1:0]),
          .in0(dcu_size[1:0]),
          .sel({arb_select,!arb_select}));

mux2_4    biu_type_mux(.out(pj_type[3:0]),
          .in1(icu_type[3:0]),
          .in0(dcu_type[3:0]),
          .sel({arb_select,!arb_select}));

/*	Generation of select for pj_addr,pj_type and pj_size muxes */
assign    arbiter_sel = icu_req & !dcu_req;

ff_sre	arb_select_state(.out(temp_arb_sel),
			.din(arbiter_sel),
			.clk(clk),
			.reset_l(reset_l),
			.enable(arb_idle));

mux2		arb_select_mux(.out(arb_select),
			.in1(arbiter_sel),
			.in0(temp_arb_sel),
			.sel({arb_idle,!arb_idle}));
	

/*	State machine for Arbiter */

assign	arb_next_state[4:0] =	arbiter(arb_state[4:0],
					pj_ack[0],
					pj_ack[1],
					pj_tv,
					num_acks);

ff_sre_4	arb_state_reg(.out(arb_state[4:1]),
					.din(arb_next_state[4:1]),
					.clk(clk),
					.reset_l(reset_l),
					.enable(1'b1));

ff_s			arb_state_reg_0(.out(arb_state[0]),
			.din(~reset_l | arb_next_state[0]),
			.clk(clk));

//latch pj_type
ff_se_4	type_state_reg(.out(type_state[3:0]), //change
				.din(pj_type[3:0]),
				.clk(clk),
				.enable(arb_idle));


assign	arb_idle = arb_state[0];
assign	num_acks[0] = type_state[1];
assign  num_acks[1] = 1'b0;
assign  num_acks[2] = (type_state[3] | (type_state[2] & (!type_state[1])))|
                      !(type_state[1] | type_state[2] | type_state[3]);

function	[4:0] arbiter;

input	[4:0]	cur_state;
input		normal_ack;
input		error_ack;
input		pj_tv;
input	[2:0]	num_acks;
		
reg	[4:0]	next_state;
parameter
	IDLE		=	5'b00001,
	REQ_ACTIVE	=	5'b00010,
	FILL3		=	5'b00100,
	FILL2		=	5'b01000,
	FILL1		=	5'b10000;
begin

	case (cur_state)
	IDLE: begin
		if (pj_tv) begin
			next_state = REQ_ACTIVE;
		end
		else	next_state = cur_state;
		end
	REQ_ACTIVE: begin
		if ( error_ack | (normal_ack & num_acks[0]))
			next_state = IDLE;
		else if (normal_ack & num_acks[2])
			next_state = FILL3; 
		else if (normal_ack & num_acks[1])
			next_state = FILL1;
		else next_state = cur_state;
		end
	FILL3:begin	
		if (error_ack )  
               next_state = IDLE;
		else if (normal_ack)
			next_state = FILL2;	
		else next_state = cur_state;
		end
	FILL2: begin
		if (error_ack )    
               next_state = IDLE;
		else if (normal_ack)
			next_state = FILL1;
		else next_state = cur_state;
		end
	FILL1:begin
		if (normal_ack | error_ack)
		 next_state = IDLE;
		else next_state = cur_state;
		end
	default:begin
			next_state = 5'bx;
		end
	endcase
arbiter[4:0] = next_state[4:0];
end	
endfunction

endmodule
