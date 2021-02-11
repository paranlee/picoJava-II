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

module ucode_ctrl (
                   opcode_1_op_r,
                   opcode_2_op_r,
                   opcode_3_op_r,
                   valid_op_r,
                   iu_trap_r,
                   ie_stall_ucode,
                   ie_kill_ucode,
                   iu_hold_e,
                   iu_psr_gce,
                   ie_alu_cryout,
                   ie_comp_a_eq0,
                   rs1_0_l,
                   rs2_0_l,
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
                   index_byte1_e,
                   index_byte2_e,
                   rom_addr,
                   sel_fxx_default,
                   u_f01_wt_stk,
                   u_f02_rd_stk,
                   u_done,
                   u_last,
                   u_abt_rdwt,
                   u_abt_cur,
                   u_ary_ovf,
                   u_ref_null,
                   u_ptr_un_eq,
                   u_gc_notify 
                  );

input    [7:0] opcode_1_op_r;      // top first  byte of ibuffer of R_stage
input    [7:0] opcode_2_op_r;      // top second byte of ibuffer of R_stage
input    [7:0] opcode_3_op_r;      // top third  byte of ibuffer of R_stage
input          valid_op_r;         // the opcode is valid        of R_stage
input          iu_trap_r;          // IU issue trap operation    of R_stage

input          ie_stall_ucode;     // IE unit holds off ucode execution
input          ie_kill_ucode;      // IU kill current operation in ucode
input          iu_hold_e;          // IU unit hold E_stage information(registers)
input          iu_psr_gce;         // IU provide Garbage_Collector_Enable
input          ie_alu_cryout;      // the carry-out of the ALU adder
input          ie_comp_a_eq0;      // a_operand compared equal to zero
input          rs1_0_l;            // rs1[0], active low, from IU
input          rs2_0_l;            // rs2[0], active low, from IU
input   [31:0] archi_data;         // architecture register output
input   [31:0] a_oprd;             // a_oprd[31:0]
input          a_oprd_0_l;         // a_oprd[0], active low
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

output   [7:0] index_byte1_e;      // E_stage, index_indexbyte1_offest
output   [7:0] index_byte2_e;      // E_stage, nargm_indexbyte2_offest+1

output   [8:0] rom_addr;           // next_state of the ucode sequencer
output         sel_fxx_default;    // an ucode exception to squash all ucode ctrls
output         u_f01_wt_stk;       // ucode write stack request
output         u_f02_rd_stk;       // ucode  read stack request
output         u_done;         	   // the ucode is done
output         u_last;             // the last cycle of the ucode
output         u_abt_rdwt;         // abort         read/write requested by ucode
output         u_abt_cur;          // abort current read/write requested by ucode
output         u_ary_ovf;          // array_index exceeds array_length
output         u_ref_null;         // the reference is a null one
output         u_ptr_un_eq;        // the ptr is unqual. used in checkcast_quick
output         u_gc_notify;        // ucode detect gc condition

wire           sel_wd_inc_r;       // select {index_byte1,index_byte2} + 1
wire           sel_offset_add1_r;  // select (offset+1) as the offset
wire     [7:0] index_byte1_e;      // E_stage, index_indexbyte1_offest
wire     [7:0] index_byte2_e;      // E_stage, nargm_indexbyte2_offest+1

wire     [8:0] rom_addr, rom_addr_l;
wire     [8:0] nxt_addr_1, nxt_addr_2, nxt_addr_3;
wire           ucode_in_r;
wire           u_done_l;
wire           u_f08_rd_rs1_a;     // Field_08: Read_port_A of RS1

/*********** Index bytes from the R_stage to E_stage *************************/

  ucode_ind ucode_ind_0 (
                         .opcode_2_op_r(opcode_2_op_r[7:0]),
                         .opcode_3_op_r(opcode_3_op_r[7:0]),
                         .iu_hold_e    (iu_hold_e),
                         .sel_wd_inc_r     (sel_wd_inc_r),
                         .sel_offset_add1_r(sel_offset_add1_r),
                         .sm     (),
                         .sin    (),
                         .reset_l(reset_l),
                         .clk    (clk),
                         .so     (),
                         .index_byte1_e(index_byte1_e[7:0]),
                         .index_byte2_e(index_byte2_e[7:0])
                        );

/*********** Decode ucode instructions to rom address ************************/

  ucode_add ucode_add_0 (
                         .opcode_1_op_r(opcode_1_op_r[7:0]),
                         .opcode_2_op_r(opcode_2_op_r[7:0]),
                         .valid_op_r   (valid_op_r),
                         .iu_trap_r    (iu_trap_r),
                         .nxt_addr_1   (nxt_addr_1[8:0]),
                         .nxt_addr_2   (nxt_addr_2[8:0]),
                         .nxt_addr_3   (nxt_addr_3[8:0]),
                         .u_f18_6      (u_f18[6]),
                         .u_f18_5      (u_f18[5]),
                         .u_f08_rd_rs1_a(u_f08_rd_rs1_a),
                         .rs1_0_l      (rs1_0_l),
                         .rs2_0_l      (rs2_0_l),
                         .u_done_l     (u_done_l),
                         .rom_addr         (rom_addr[8:0]),
                         .rom_addr_l       (rom_addr_l[8:0]),
                         .ucode_in_r       (ucode_in_r),
                         .sel_wd_inc_r     (sel_wd_inc_r),
                         .sel_offset_add1_r(sel_offset_add1_r)
                        );

/*********** Calculate the rom address and control interface signals *********/

  ucode_seq ucode_seq_0 (
                         .ucode_in_r(ucode_in_r),
                         .rom_addr_l(rom_addr_l[8:0]),
                         .ie_stall_ucode(ie_stall_ucode),
                         .ie_kill_ucode (ie_kill_ucode),
                         .iu_psr_gce    (iu_psr_gce),
                         .ie_alu_cryout(ie_alu_cryout),
                         .ie_comp_a_eq0(ie_comp_a_eq0),
                         .archi_data(archi_data[31:0]),
                         .a_oprd(a_oprd[31:0]),
                         .a_oprd_0_l(a_oprd_0_l),
                         .b_oprd(b_oprd[31:0]),
                         .reg5_31(reg5_31),
                         .u_f01(u_f01),
                         .u_f02(u_f02),
                         .u_f08(u_f08),
                         .u_f18(u_f18),
                         .sm     (),
                         .sin    (),
                         .reset_l(reset_l),
                         .clk    (clk),
                         .so     (),
                         .u_f08_rd_rs1_a(u_f08_rd_rs1_a),
                         .nxt_addr_1(nxt_addr_1[8:0]),
                         .nxt_addr_2(nxt_addr_2[8:0]),
                         .nxt_addr_3(nxt_addr_3[8:0]),
                         .sel_fxx_default(sel_fxx_default),
                         .u_f01_wt_stk(u_f01_wt_stk),
                         .u_f02_rd_stk(u_f02_rd_stk),
                         .u_done     (u_done),
                         .u_done_l   (u_done_l),
                         .u_last     (u_last),
                         .u_abt_rdwt (u_abt_rdwt),
                         .u_abt_cur  (u_abt_cur),
                         .u_ary_ovf  (u_ary_ovf),
                         .u_ref_null (u_ref_null),
                         .u_ptr_un_eq(u_ptr_un_eq),
                         .u_gc_notify(u_gc_notify)
                         );

endmodule
