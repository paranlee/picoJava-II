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

module ucode (
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
              dreg,
              rs1,
              rs2,
              rs1_0_l,
              rs2_0_l,
              iu_optop,
              alu_data,
              archi_data,
              ucode_addr_d,
              te_ieu_rom,
              ieu_in_powerdown,
              sm,
              sin,
              reset_l,
              clk,
              so,
              u_f01_wt_stk,
              u_f02_rd_stk,
              u_addr_st_rd,
              u_areg0,
              ucode_porta,
              ucode_portb,
              ucode_portc,
              ialu_a,
              m_adder_porta,
              m_adder_portb,
              u_f00,
              u_f01,
              u_f02,
              u_f03,
              u_f04,
              u_f05,
              u_f07,
              u_f17,
              u_f19,
              u_f21,
              u_f22,
              u_f23,
              u_done,
              udone_l,
              u_last,
              u_abt_rdwt,
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
input          ie_alu_cryout;      // the carry-out of the ALU adder
input          iu_hold_e;          // IU unit hold E_stage information(registers)
input          iu_psr_gce;         // IU provide Garbage_Collector_Enable
input          ie_comp_a_eq0;      // a_operand compared equal to zero
input          ie_kill_ucode;      // IU kill current operation in ucode
input   [31:0] dreg;               // read_data_cache data,[31:0]
input   [31:0] rs1;                // first  of the top of the stack_cache
input   [31:0] rs2;                // second of the top of the stack_cache
input          rs1_0_l;            // rs1[0], active low, from IU
input          rs2_0_l;            // rs2[0], active low, from IU

input   [31:0] iu_optop;           // the optop IU sent to start ucode
input   [31:0] alu_data;           // ieu_alu data output
input   [31:0] archi_data;         // architecture register output
input   [31:0] ucode_addr_d;       // memory_adder output

input          te_ieu_rom;         // test enable  for ieu_rom
input          ieu_in_powerdown;   // power down. 0=power_down

input          sm;                 // register scan mode
input          sin;                // register scan_input
input          reset_l;            // reset
input          clk;                // clock

output         so;                 // register scan_output

output         u_f01_wt_stk;       // ucode write stack request
output         u_f02_rd_stk;       // ucode  read stack request
output  [31:0] u_addr_st_rd;       // ucode to stack_cache  read_address
output  [31:0] u_areg0;            // ucode output of the areg0 register
output  [31:0] ucode_porta;        // ucode output data to ie       porta
output  [31:0] ucode_portb;        // ucode output data to ie       portb
output  [31:0] ucode_portc;        // ucode output data to stcak_/data_cache
output  [31:0] ialu_a;             // ucode output data to ie_alu's porta
output  [31:0] m_adder_porta;      // ucode output data to imem_adder's porta
output  [31:0] m_adder_portb;      // ucode output data to imem_adder's portb

output   [1:0] u_f00;              // field_00: IU_zero_comparator
output   [2:0] u_f01;              // Field_01: Ucode and StacK         WT
output   [1:0] u_f02;              // Field_02: Ucode and Stack         RD
output   [1:0] u_f03;              // Field_03: Ucode and Data_cache
output   [6:0] u_f04;              // Field_04: Ucode and Architech_reg RD
output   [2:0] u_f05;              // Field_05: Ucode and Architech_reg WT
output   [2:0] u_f07;              // Field_07: Integer Unit ALU b_operand
output   [1:0] u_f17;              // field_17: IU_adder operations
output   [3:0] u_f19;              // field_19: Mem_adder a_operand
output   [1:0] u_f21;              // field_21: Mem_adder operations
output         u_f22;              // field_22: Sel stack_cache address
output   [1:0] u_f23;              // field_23: Sel alu_adder input port_a

output         u_done;         	   // the ucode is done
output         udone_l;       	   // the ucode is done, active low
output         u_last;             // the last cycle of the ucode
output         u_abt_rdwt;         // abort read and/or write requested by ucode
output         u_ary_ovf;          // array_index exceeds array_length
output         u_ref_null;         // the reference is a null one
output         u_ptr_un_eq;        // the ptr is unqual. used in checkcast_quick
output         u_gc_notify;        // ucode detect gc condition

// ------------- declarations ---------------------------------------------
wire     [7:0] index_byte1_e;      // E_stage, index_indexbyte1_offest
wire     [7:0] index_byte2_e;      // E_stage, nargm_indexbyte2_offest+1

wire           sel_fxx_default;    // an ucode exception to squash all ucode ctrls
wire     [8:0] rom_addr;           // next_state of the ucode sequencer

wire    [31:0] a_oprd;             // a_oprd[31:0]
wire    [31:0] b_oprd;             // b_oprd[31:0]
wire           a_oprd_0_l;         // a_oprd[0], active low
wire           reg5_31;            // Temp_reg5[31]

wire     [1:0] u_f00;              // field_00: IU_zero_comparator
wire     [2:0] u_f01;              // Field_01: Ucode and StacK         WT
wire     [1:0] u_f02;              // Field_02: Ucode and Stack         RD
wire     [1:0] u_f03;              // Field_03: Ucode and Data_cache
wire     [6:0] u_f04;              // Field_04: Ucode and Architech_reg RD
wire     [2:0] u_f05;              // Field_05: Ucode and Architech_reg WT
wire     [2:0] u_f07;              // Field_07: Integer Unit ALU b_operand
wire     [2:0] u_f08;              // Field_08: Read_port_A of temp_regs
wire     [1:0] u_f17;              // field_17: IU_adder operations
wire    [11:0] u_f18;              // field_18: Branching in ucode
wire     [3:0] u_f19;              // field_19: Mem_adder a_operand
wire     [1:0] u_f21;              // field_21: Mem_adder operations
wire           u_f22;              // field_22: Sel stack_cache address
wire     [1:0] u_f23;              // field_23: Integer Unit ALU a_operand

wire    [31:0] rs1_l, rs1_b;       // buffering rs1
wire           u_abt_cur;
wire           udone_l;
wire           rs1_0, rs2_0;

/*********** Ucode control section *******************************************/

  inv_a_32 inv_a_32_0 ( .inp(rs1[31:0]),   .out_l(rs1_l[31:0]) );
  inv_c_32 inv_c_32_0 ( .inp(rs1_l[31:0]), .out_l(rs1_b[31:0]) );

  inv_e_1  inv_e_1_0  ( .inp(u_done),      .out_l(udone_l)     );

  inv_b_1  inv_b_1_0  ( .inp(rs1_0_l),     .out_l(rs1_0)       );
  inv_b_1  inv_b_1_1  ( .inp(rs2_0_l),     .out_l(rs2_0)       );

  ucode_ctrl ucode_ctrl_0 (
                           .opcode_1_op_r(opcode_1_op_r[7:0]),
                           .opcode_2_op_r(opcode_2_op_r[7:0]),
                           .opcode_3_op_r(opcode_3_op_r[7:0]),
                           .valid_op_r   (valid_op_r),
                           .iu_trap_r    (iu_trap_r),
                           .ie_stall_ucode(ie_stall_ucode),
                           .ie_kill_ucode (ie_kill_ucode),
                           .iu_hold_e     (iu_hold_e),
                           .iu_psr_gce    (iu_psr_gce),
                           .ie_alu_cryout (ie_alu_cryout),
                           .ie_comp_a_eq0 (ie_comp_a_eq0),
                           .rs1_0_l(rs1_0_l),
                           .rs2_0_l(rs2_0_l),
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
                           .index_byte1_e(index_byte1_e[7:0]),
                           .index_byte2_e(index_byte2_e[7:0]),
                           .rom_addr(rom_addr[8:0]),
                           .sel_fxx_default(sel_fxx_default),
                           .u_f01_wt_stk(u_f01_wt_stk),
                           .u_f02_rd_stk(u_f02_rd_stk),
                           .u_done(u_done),
                           .u_last(u_last),
                           .u_abt_rdwt (u_abt_rdwt),
                           .u_abt_cur  (u_abt_cur),
                           .u_ary_ovf  (u_ary_ovf),
                           .u_ref_null (u_ref_null),
                           .u_ptr_un_eq(u_ptr_un_eq),
                           .u_gc_notify(u_gc_notify)
                          );


/*********** Ucode datapath section ******************************************/

  ucode_dpath ucode_dpath_0 (
                             .index_byte1_e(index_byte1_e[7:0]),
                             .index_byte2_e(index_byte2_e[7:0]),
                             .ie_stall_ucode(ie_stall_ucode),
                             .ie_kill_ucode (ie_kill_ucode),
                             .iu_optop    (iu_optop[31:0]),
                             .alu_data    (alu_data[31:0]),
                             .archi_data  (archi_data[31:0]),
                             .ucode_addr_d(ucode_addr_d[31:0]),
                             .rs1  ({rs1[31:1],rs1_0}),
                             .rs1_b(rs1_b[31:0]),
                             .rs2  ({rs2[31:1],rs2_0}),
                             .dreg (dreg[31:0]),
                             .nxt_ucode_cnt(rom_addr[8:0]),
                             .sel_fxx_default(sel_fxx_default),
                             .u_abt_cur  (u_abt_cur),
                             .te_ieu_rom(/*te_ieu_rom*/ 1'b0 ),
                             .ieu_in_powerdown(ieu_in_powerdown),
                             .sm     (),
                             .sin    (),
                             .reset_l(reset_l),
                             .clk    (clk),
                             .so     (),
                             .u_addr_st_rd(u_addr_st_rd[31:0]),
                             .u_areg0     (u_areg0[31:0]),
                             .ucode_porta (ucode_porta[31:0]),
                             .ucode_portb (ucode_portb[31:0]),
                             .ucode_portc (ucode_portc[31:0]),
                             .ialu_a(ialu_a[31:0]),
                             .m_adder_porta(m_adder_porta[31:0]),
                             .m_adder_portb(m_adder_portb[31:0]),
                             .a_oprd(a_oprd[31:0]),
                             .a_oprd_0_l(a_oprd_0_l),
                             .b_oprd(b_oprd[31:0]),
                             .reg5_31(reg5_31),
                             .u_f00(u_f00),
                             .u_f01(u_f01),
                             .u_f02(u_f02),
                             .u_f03(u_f03),
                             .u_f04(u_f04),
                             .u_f05(u_f05),
                             .u_f07(u_f07),
                             .u_f08(u_f08),
                             .u_f17(u_f17),
                             .u_f18(u_f18),
                             .u_f19(u_f19),
                             .u_f21(u_f21),
                             .u_f22(u_f22),
                             .u_f23(u_f23)
                            );

endmodule
