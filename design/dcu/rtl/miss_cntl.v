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


module miss_cntl( 	
			dc_req,
			dc_idle,
			miss_wait,
			miss_idle,
			first_fill_cyc,
			last_fill_cyc,
			fill_cyc_active,
			dc_wr_cyc123,
			zeroline_busy,
			zeroline_cyc,
		        dc_error,
	
			// INPUTS
			normal_ack,
	 		zeroline_c,
			repl_start,
			error_ack,
			req_outstanding,
			dcu_miss_c,
			smu_na_st_c,
			nc_xaction,
			clk,
			so,
			sin,
			sm,
			reset_l
			 );



output		dc_idle		;	// miss state m/c is in idle state
output		dc_req		;	// waiting for first ack 
output		last_fill_cyc	;	// The cycle of cache fill operation
output		first_fill_cyc	;	// first write to cache of the cache fill operation
output		fill_cyc_active	;	// cache fill cycle . data written into cache next cycle
output		zeroline_busy;		// zeroline instruction in progress
output		zeroline_cyc	;	// fill operation of zeroline active
output		dc_wr_cyc123	;	// the first 3 cycles of cache fill data written into cache.
output		miss_wait	;	// wait until first ack is back
output		miss_idle	;	// miss state machine is in idle state 
output		dc_error	;	// Erroneous transaction occurred
input		req_outstanding ;	// There is an outstanding memory request
input		repl_start	;	// need to replace line

input		dcu_miss_c	;	// Cache miss in c stage
input		smu_na_st_c	;	// Not allocating Cache line
input		zeroline_c	;	// zeroline instruction in C stage
input		normal_ack	;	// Normal acknowledge from memory. data valid in cycle
input		nc_xaction	;	// Noncacheable transaction
input		error_ack	;	// Erroneous transaction
input		reset_l		;	// Reset
input		clk		;	// Clock
input		sin		;	// Scan Input
output		so		;	// Scan Output
input		sm		;	// Scan Enable


wire	[5:0]		miss_state;
wire			dc_error;
wire                    dc_wr_cyc1 ;
wire                    dc_wr_cyc2 ;
wire                    dc_wr_cyc3 ;
wire	[5:0]		next_miss_state;
wire			zero_idle;
wire			zero_last_cyc;
wire			zero_first_cyc;
wire			zero_fill_cyc;
wire	[5:0]		next_zero_state;
wire	[5:0]		zero_state;


// Cache fill write cycles

// Generation of miss_wait -- release pipe only when this is low.
// release pipe once the first word has been returned or there is
// an error.
assign 		miss_wait 	=  dc_req ;
assign          last_fill_cyc   = dc_wr_cyc3&normal_ack |zero_last_cyc;
assign          first_fill_cyc  = dc_req &(normal_ack|error_ack) | zero_first_cyc ;
assign          fill_cyc_active = !miss_idle& (normal_ack |error_ack) | zero_fill_cyc ;
assign          dc_wr_cyc123    = normal_ack&(dc_req | dc_wr_cyc1 | dc_wr_cyc2 ) | zero_fill_cyc&!zero_last_cyc;
assign		dc_idle		=  miss_idle & zero_idle ;

/********************************  MISS STATE MACHINE ***************************************/
assign          miss_idle         = miss_state[0];
assign          dc_req          = miss_state[1];
assign          dc_wr_cyc1      = miss_state[2];
assign          dc_wr_cyc2      = miss_state[3];
assign          dc_wr_cyc3      = miss_state[4];
assign          dc_error        = miss_state[5];

		
assign	next_miss_state[5:0]	=	miss_state_fn(miss_state[5:0],
					req_outstanding,
					dcu_miss_c&!zeroline_c&!smu_na_st_c,
					normal_ack,
					nc_xaction,
					error_ack );

ff_sr_5        miss_state_reg( .out(miss_state[5:1]),
                                .din(next_miss_state[5:1]),
                                .clk(clk),
                                .reset_l(reset_l));

ff_s		miss_state_reg_0(.out(miss_state[0]),
				.din(!reset_l | next_miss_state[0]),
				.clk(clk));


/********************************* ZEROLINE STATE MACHINE ************************************/


assign	zero_fill_cyc	= 	zero_state[2] | zero_state[3] | zero_state[4] | zero_state[5] ;
assign	zero_first_cyc	=	zero_state[2] ;
assign	zero_last_cyc	=	zero_state[5] ;
assign	zero_idle	=	zero_state[0] ;
assign	zeroline_busy	=	!zero_idle;
assign	zeroline_cyc	=	zero_fill_cyc ;

assign	next_zero_state[5:0]	=	zero_state_fn(zero_state[5:0],
					zeroline_c,
					repl_start );

ff_sr_5	zero_state_reg( .out(zero_state[5:1]),
				.din(next_zero_state[5:1]),
				.clk(clk),
				.reset_l(reset_l));

ff_s            zero_state_reg_0(.out(zero_state[0]),
                                .din(!reset_l | next_zero_state[0]),
                                .clk(clk));

				
/******************************************************************************************/

function [5:0] miss_state_fn ;
 
input   [5:0]  cur_state ;
input           req_outstanding;
input           dcu_miss ;
input           normal_ack;
input           noncacheable ;
input           error_ack ;
 
reg     [5:0]  next_state;
// State Encoding
parameter 
        IDLE            = 6'b000001,
        REQ_STATE       = 6'b000010 ,
        FILL_CYC1     	= 6'b000100 ,
        FILL_CYC2     	= 6'b001000 ,
        FILL_CYC3     	= 6'b010000 ,
        ERROR_STATE     = 6'b100000 ;
begin
 
case    (cur_state)     // synopsys full_case parallel_case
        IDLE:   begin
                if(!req_outstanding & dcu_miss ) begin
                next_state = REQ_STATE ;
                end
                else    next_state = cur_state ;
        end
        REQ_STATE: begin
                if ( normal_ack & noncacheable ) begin
                next_state = IDLE ;
		end
                else if (normal_ack & !noncacheable) begin
                next_state = FILL_CYC1 ;
                end
                else if (error_ack) begin
                next_state = ERROR_STATE ;
                end
                else next_state = cur_state ;
        end
 
	FILL_CYC1: begin
                if (normal_ack) begin
                next_state = FILL_CYC2 ;
                end
                else if (error_ack) begin
                next_state = ERROR_STATE ;
                end
                else next_state = cur_state ;
        end

        FILL_CYC2: begin
                if (normal_ack) begin
                next_state = FILL_CYC3 ;
		end
                else if (error_ack) begin
                next_state = ERROR_STATE ;
                end
                else next_state = cur_state ;
        end
 
        FILL_CYC3: begin
                if (normal_ack) begin
                next_state = IDLE ;
		end
                else if (error_ack) begin
                next_state = ERROR_STATE ;
                end
                else next_state = cur_state ;
        end

        ERROR_STATE: begin
                next_state = IDLE ;
                end
	default:	next_state = 6'bx;
endcase
miss_state_fn = next_state ;
end
endfunction
	
/**************************************************************************/
function [5:0]	zero_state_fn ;

input [5:0]	cur_state;
input		zeroline_c;
input		repl_start;

reg     [5:0]  next_state;
// State Encoding
parameter
        IDLE         = 6'b000001,
	WAIT	     = 6'b000010,
        FILL_1       = 6'b000100 ,
        FILL_2       = 6'b001000 ,
        FILL_3       = 6'b010000 ,
        FILL_4       = 6'b100000 ;
begin
 
case    (cur_state)     // synopsys full_case parallel_case
        IDLE:   begin
		if(zeroline_c& !repl_start) begin
		next_state = FILL_1 ;
		end
		else if	(zeroline_c& repl_start) begin
		next_state = WAIT ;
		end
		else	next_state = cur_state ;
	end

	WAIT:	begin	
		next_state = FILL_1 ;
		end
	
	FILL_1:	begin
		next_state = FILL_2;
		end

	FILL_2:	begin
		next_state = FILL_3;
		end

	FILL_3:	begin
		next_state = FILL_4;
		end

	FILL_4:	begin
		next_state = IDLE ;
		end
	default: next_state = 6'bx;
endcase

zero_state_fn = next_state ;
end
endfunction
	
mj_spare spare(	.clk(clk),
		.reset_l(reset_l));

endmodule
