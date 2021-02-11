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

module ucode_seq (
                  ucode_in_r,
                  rom_addr_l,
                  ie_stall_ucode,
                  ie_kill_ucode,
                  iu_psr_gce,
                  ie_alu_cryout,
                  ie_comp_a_eq0,
                  archi_data,
                  a_oprd,
                  a_oprd_0_l,
                  b_oprd,
                  reg5_31,
                  u_f01,
                  u_f02,
                  u_f08,
                  u_f18,
                  sm,
                  sin,
                  reset_l,
                  clk,
                  so,
                  u_f08_rd_rs1_a,
                  nxt_addr_1,
                  nxt_addr_2,
                  nxt_addr_3,
                  sel_fxx_default,
                  u_f01_wt_stk,
                  u_f02_rd_stk,
                  u_done,
                  u_done_l,
                  u_last,
                  u_abt_rdwt,
                  u_abt_cur,
                  u_ary_ovf,
                  u_ref_null,
                  u_ptr_un_eq,
                  u_gc_notify 
                 );

input          ucode_in_r;         // valid ucode opcode         of R_stage
input    [8:0] rom_addr_l;         // next_state of the ucode sequencer, active low

input          ie_stall_ucode;     // IE unit holds off ucode execution
input          ie_kill_ucode;      // IU kill current operation in ucode
input          iu_psr_gce;         // IU provide Garbage_Collector_Enable
input          ie_alu_cryout;      // the carry-out of the ALU adder
input          ie_comp_a_eq0;      // a_operand compared equal to zero
input   [31:0] archi_data;         // architecture register output
input   [31:0] a_oprd;             // a_oprd[31:0]
input          a_oprd_0_l;         // a_oprd[0}, active low
input   [31:0] b_oprd;             // b_oprd[31:0], sign_bit/reg_gc_conf
input          reg5_31;            // Temp_reg5[31]
input    [2:0] u_f01;              // Field_01: Ucode and StacK         WT
input    [1:0] u_f02;              // Field_02: Ucode and Stack         RD
input    [2:0] u_f08;              // Field_08: Read_port_A of temp_regs
input   [11:0] u_f18;              // field_18: Branching in ucode

input          sm;                 // register scan mode
input          sin;                // register scan_input
input          reset_l;            // reset
input          clk;                // clock

output         so;                 // register scan_output

output         u_f08_rd_rs1_a;     // Field_08: Read_port_A of RS1
output   [8:0] nxt_addr_1;         // ucode calculated rom_addr + 1
output   [8:0] nxt_addr_2;         // ucode calculated rom_addr + 2
output   [8:0] nxt_addr_3;         // ucode calculated rom_addr + 3
output         sel_fxx_default;    // an ucode exception to squash all ucode ctrls
output         u_f01_wt_stk;       // ucode write stack request
output         u_f02_rd_stk;       // ucode  read stack request
output         u_done;         	   // the ucode is done
output         u_done_l;       	   // the ucode is done, active low
output         u_last;             // the last cycle of the ucode
output         u_abt_rdwt;         // abort         read/write requested by ucode
output         u_abt_cur;          // abort current read/write requested by ucode
output         u_ary_ovf;          // array_index exceeds array_length
output         u_ref_null;         // the reference is a null one
output         u_ptr_un_eq;        // the ptr is unqual. used in checkcast_quick
output         u_gc_notify;        // ucode detect gc condition

wire           ucode_done;
wire           ucode_last;
wire           f18_last_cyc;       // default last cycle of ucode, from ROM

wire     [8:0] rom_addr_1, rom_addr_2, rom_addr_3;
wire     [8:0] nxt_addr_1, nxt_addr_2, nxt_addr_3;

wire           nxt_ucode_done,nxt_ucode_last;
wire           nxt_ary_ovf,   nxt_ref_null, nxt_ptr_un_eq, nxt_gc_notify;
wire           nxt_ls_branch, nxt_eq_branch;
wire           nxt_abt_rdwt;       // abort         read/write requested by ucode
wire           nxt_abt_cur;        // abort current read/write requested by ucode
wire           handle_off_done;    // handle is off, same cycle is done

wire           check_ref_null; // check if object/array_ref is a null pointer
wire           check_un_eq;    // check class_pointers. Used in checkcast_quick
wire           check_ary_ovf;  // check if there is an overflow, index > length
wire           check_ary_neg;  // check if there is an overflow, index < 0
wire           check_eq_br;    // check if ptrs are equal. if so, exit microcode
wire           check_ls_br1;   // check if index   < Low_wd. if so, branch
wire           check_ls_br2;   // check if High_wd < index.  if so, branch
wire           check_gc;       // check if the garbage collection condition is met
wire           check_abt_rdwt; // check a_oprd_0=1 abort ucode's rd.wt request
wire           check_1cyc_done;// check 1cycle_done operations, (32bit_handle_off)
wire           check_1cyc_leng;// check 1cycle_done operations for arraylength

wire           reg_enable;     // enable all the control flops.
wire           reg_clear_l;    // clear  all the control flops, active low
wire           u_exception;    // an ucode exception to squash all ucode ctrls

wire     [3:0] gc_index;
wire    [10:0] region1, region2;
wire     [4:0] car1,    car2;
wire           region_eq, car_un_eq;

wire           u_done_l;
wire           u_f08_rd_rs1_a;
wire     [8:0] r_addr;
wire           cout_add3;
wire           handle_off_done_0, u_last_0;

/*********** Next Sequential Address Logic ***********************************/

/* move to ucode_dec
  assign bit1 = (check_handle   && !a_oprd[0]) ||
                (check_handle_p &&  a_oprd[0]) ||
                (check_handle2  &&  a_oprd[0]); 

  assign bit0 = (check_handle   && !a_oprd[0]) ||
                (check_handle_p &&  a_oprd[0]) ||
               !(check_handle2  &&  a_oprd[0]);  
*/

/* Logic
  assign rom_addr_1 = (~rom_addr_l[8:0]) + 9'h1;
  assign rom_addr_2 = (~rom_addr_l[8:0]) + 9'h2;
  assign rom_addr_3 = (~rom_addr_l[8:0]) + 9'h3;
*/

  assign r_addr = ~rom_addr_l[8:0];

  inc9 inc9_rom_add1 ( .ai(r_addr[8:0]), .sum(rom_addr_1[8:0]) );

  inc8 inc8_rom_add2 ( .ai(r_addr[8:1]), .sum(rom_addr_2[8:1]) );
  assign rom_addr_2[0] = r_addr[0];

  fa9 fa9_rom_add3 ( .a(r_addr[8:0]), .b(9'h3), .c(1'b0),
                     .sum(rom_addr_3[8:0]), .cout(cout_add3) );

/* move to ucode_dec
  always @(bit1 or bit0 or nxt_addr_1 or nxt_addr_2 or nxt_addr_3)
    case({bit1,bit0})                         //synopsys parallel_case
      2'h2:    next_addr = nxt_addr_2[8:0];
      2'h3:    next_addr = nxt_addr_3[8:0];
      default: next_addr = nxt_addr_1[8:0];
    endcase
*/

/* move to dpath
  assign rom_addr[8:0]  = u_done ? rom_start_r[8:0] : next_addr[8:0];
  assign ucode_in_r     = (|rom_start_r[8:0]);
*/

/****** Specific Logic for microcode control interface with IU ***************/
  assign u_f01_wt_stk = |u_f01;
  assign u_f02_rd_stk = |u_f02;

  assign u_f08_rd_rs1_a = (u_f08==`F08_RD_RS1_A);

  assign f18_last_cyc    = ( u_f18[0]);
  assign check_ref_null  = ( u_f18[1]);
  assign check_un_eq     = ( u_f18[2]);
  assign check_ary_ovf   = ( u_f18[3]);
  assign check_ary_neg   = ( u_f18[4]);
//   assign check_handle2   = (!u_f18[6]  &&  u_f18[5]);  // jump_2
//   assign check_handle    = ( u_f18[6]  && !u_f18[5]);  // jump_3, [0]=0
//   assign check_handle_p  = ( u_f18[6]  &&  u_f18[5]);  // jump_3, [0]=1
  assign check_eq_br     = (!u_f18[8]  &&  u_f18[7]);
  assign check_ls_br1    = ( u_f18[8]  && !u_f18[7]);
  assign check_ls_br2    = ( u_f18[8]  &&  u_f18[7]);
  assign check_gc        = ( u_f18[9]);
  assign check_abt_rdwt  = (!u_f18[11] &&  u_f18[10]);
  assign check_1cyc_done = ( u_f18[11] && !u_f18[10]);
  assign check_1cyc_leng = ( u_f18[11] &&  u_f18[10]);

  assign gc_index  = {a_oprd[31:30],b_oprd[31:30]};
  assign region1   = (a_oprd[28:18] & archi_data[31:21]);
  assign region2   = (b_oprd[28:18] & archi_data[31:21]);
  assign car1      = (a_oprd[17:13] & archi_data[20:16]);
  assign car2      = (b_oprd[17:13] & archi_data[20:16]);
  assign region_eq =  (region1==region2);
  assign car_un_eq = !(car1==car2);

  assign nxt_ary_ovf   = check_ary_neg  &&  reg5_31 ||
                         check_ary_ovf  && !ie_alu_cryout;
  assign nxt_ref_null  = check_ref_null &&  ie_comp_a_eq0;
  assign nxt_ptr_un_eq = check_un_eq    && !ie_comp_a_eq0;
  assign nxt_eq_branch = check_eq_br    &&  ie_comp_a_eq0;
  assign nxt_gc_notify = check_gc       && (
                                            archi_data & (1'b1<<gc_index[3:0]) ||
                                            iu_psr_gce && region_eq && car_un_eq
                                           );

// check for less than index condition. used by tableswitch
  assign nxt_ls_branch =
            check_ls_br1 && (!ie_alu_cryout && !(a_oprd[31] ^   b_oprd[31]) ||
                                               (!a_oprd[31] &&  b_oprd[31])
                            ) || 
            check_ls_br2 && (!ie_alu_cryout && !(a_oprd[31] ^   b_oprd[31]) ||
                                               ( a_oprd[31] && !b_oprd[31])
                            );

  assign nxt_abt_rdwt      = (check_1cyc_done || check_abt_rdwt)  &&  a_oprd[0];
  assign nxt_abt_cur       = nxt_eq_branch || nxt_ls_branch;

  assign handle_off_done   = (check_1cyc_done || check_1cyc_leng) && !a_oprd[0];
  assign handle_off_done_0 = (check_1cyc_done || check_1cyc_leng) &&  a_oprd_0_l;

// Generate u_exception: On an exception, kill all u_fxx, forced to default
  assign u_exception = !ie_stall_ucode &&
                           (nxt_ary_ovf   ||
                            nxt_ref_null  ||
                            nxt_ptr_un_eq ||
                            nxt_eq_branch ||
                            nxt_ls_branch ||
                            nxt_gc_notify);

// Ucode last cycle
// If there is an ucode exception                          next is the last cycle
// If the last_cyc bit from ucode_rom=1, or hand_off_done, this is the last cycle
  assign nxt_ucode_last = !(ie_stall_ucode || handle_off_done || f18_last_cyc) &&
                           (nxt_ary_ovf   ||
                            nxt_ref_null  ||
                            nxt_ptr_un_eq ||
                            nxt_eq_branch ||
                            nxt_ls_branch ||
                            nxt_gc_notify);

  assign u_last   = f18_last_cyc || ucode_last || handle_off_done;
  assign u_last_0 = f18_last_cyc || ucode_last || handle_off_done_0;

// Logic to generate Ucode_Done
// Ucode_done is by default high.
// If there is a ucode inst in R stage, it goes low. 
// Ucode_Done goes back high if this is the last cycle of ucode or kill by IU

  assign nxt_ucode_done =  u_done && !ucode_in_r     ||
                          !u_done &&  nxt_ucode_last ||
                          ie_kill_ucode              ||
                          !reset_l;   

  assign u_done   =  (ucode_done || u_last_0);
  assign u_done_l = !(ucode_done || u_last_0);

  assign sel_fxx_default = ie_kill_ucode || !reset_l;

/************* Control Registers ********************************************/

  assign reg_enable  = !ie_stall_ucode;
  assign reg_clear_l = !(!reset_l || ie_kill_ucode);

  ff_sre_9 seq_addr1_reg (
                          .out(nxt_addr_1[8:0]),
                          .din(rom_addr_1[8:0]),
                          .enable(reg_enable),
                          .reset_l(reg_clear_l),
                          .clk(clk)
                         );
 
  ff_sre_9 seq_addr2_reg (
                          .out(nxt_addr_2[8:0]),
                          .din(rom_addr_2[8:0]),
                          .enable(reg_enable),
                          .reset_l(reg_clear_l),
                          .clk(clk)
                         );
 
  ff_sre_9 seq_addr3_reg (
                          .out(nxt_addr_3[8:0]),
                          .din(rom_addr_3[8:0]),
                          .enable(reg_enable),
                          .reset_l(reg_clear_l),
                          .clk(clk)
                         );
 
  ff_se	 done_reg (
                   .out(    ucode_done),
                   .din(nxt_ucode_done),
                   .enable(reg_enable || ie_kill_ucode),
                   .clk(clk)
                  );
                  
  ff_sre last_reg (
                   .out(ucode_last),
                   .din(nxt_ucode_last),
                   .enable(reg_enable),
                   .reset_l(reg_clear_l),
                   .clk(clk)
                  );

  ff_sre abt_rdwt_reg (  
                       .out(u_abt_rdwt),
                       .din(nxt_abt_rdwt),
                       .enable(nxt_abt_rdwt || !ie_stall_ucode),
                       .reset_l(reg_clear_l),
                       .clk(clk)
                      );

  ff_sre abt_cur_reg  (  
                       .out(u_abt_cur),
                       .din(nxt_abt_cur),
                       .enable(               !ie_stall_ucode),
                       .reset_l(reg_clear_l),
                       .clk(clk)
                      );

  ff_sre ary_null_reg (
                       .out(u_ref_null),
                       .din(nxt_ref_null),
                       .enable(reg_enable),
                       .reset_l(reg_clear_l),
                       .clk(clk)
                      );

  ff_sre ary_ovf_reg (
                      .out(u_ary_ovf),
                      .din(nxt_ary_ovf),
                      .enable(reg_enable),
                      .reset_l(reg_clear_l),
                      .clk(clk)
                     );

  ff_sre ptr_un_eq_reg (
                        .out(u_ptr_un_eq),
                        .din(nxt_ptr_un_eq),
                        .enable(reg_enable),
                        .reset_l(reg_clear_l),
                        .clk(clk)
                       );

  ff_sre ptr_gc_notify (
                        .out(u_gc_notify),
                        .din(nxt_gc_notify),
                        .enable(reg_enable),
                        .reset_l(reg_clear_l),
                        .clk(clk)
                       );

  mj_spare spare( .clk(clk),
                  .reset_l(reset_l));

endmodule
