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

module ucode_dpath (
                    index_byte1_e,
                    index_byte2_e,
                    ie_stall_ucode,
                    ie_kill_ucode,
                    iu_optop,
                    alu_data,
                    archi_data,
                    ucode_addr_d,
                    rs1,
                    rs1_b,
                    rs2,
                    dreg,
                    nxt_ucode_cnt,
                    sel_fxx_default,
                    u_abt_cur,
                    te_ieu_rom,
                    ieu_in_powerdown,
                    sm,
                    sin,
                    reset_l,
                    clk,
                    so,
                    u_addr_st_rd,
                    u_areg0,
                    ucode_porta,
                    ucode_portb,
                    ucode_portc,
                    ialu_a,
                    m_adder_porta,
                    m_adder_portb,
                    a_oprd,
                    a_oprd_0_l,
                    b_oprd,
                    reg5_31,
                    u_f00,
                    u_f01,
                    u_f02,
                    u_f03,
                    u_f04,
                    u_f05,
                    u_f07,
                    u_f08,
                    u_f17,
                    u_f18,
                    u_f19,
                    u_f21,
                    u_f22,
                    u_f23 
                   );

input    [7:0] index_byte1_e;      // E_stage, index_indexbyte1_offest
input    [7:0] index_byte2_e;      // E_stage, nargm_indexbyte2_offest+1
input          ie_stall_ucode;     // IE unit holds off ucode execution
input          ie_kill_ucode;      // IU kill current operation in ucode

input   [31:0] iu_optop;           // the optop IU sent to start ucode
input   [31:0] alu_data;           // ieu_alu data output
input   [31:0] archi_data;         // architecture register output
input   [31:0] ucode_addr_d;       // memory_adder output
 
input   [31:0] rs1;                // always  rs1  = reg[nxt_rs1]
input   [31:0] rs1_b;              // always  rs1  = reg[nxt_rs1], buffered
input   [31:0] rs2;                // Initial rs2  = reg[nxt_rs2]
input   [31:0] dreg;               // always  dreg = reg{d_cache[ucode_addr_d]}

input    [8:0] nxt_ucode_cnt;      // next_state of_the ucode sequencer

input          sel_fxx_default;    // an ucode exception to squash all ucode ctrls
input          u_abt_cur;          // abort current read/write requested by ucode
 
input          te_ieu_rom;         // test enable  for ieu_rom
input          ieu_in_powerdown;   // power down. 0=power_down

input          sm;                 // register scan mode
input          sin;                // register scan_input
input          reset_l;            // reset
input          clk;                // clock

output         so;                 // register scan_output

output  [31:0] u_addr_st_rd;       // ucode to stack_cache  read_address
output  [31:0] u_areg0;            // ucode output of the areg0 register

output  [31:0] ucode_porta;        // ucode output data to ie       porta
output  [31:0] ucode_portb;        // ucode output data to ie       portb
output  [31:0] ucode_portc;        // ucode output data to stcak_/data_cache
 
output  [31:0] ialu_a;             // ucode output data to ie_alu's porta
output  [31:0] m_adder_porta;      // ucode output data to imem_adder's porta
output  [31:0] m_adder_portb;      // ucode output data to imem_adder's portb
 
output  [31:0] a_oprd;             // a_oprd[31:0]
output         a_oprd_0_l;         // a_oprd[0], active low
output  [31:0] b_oprd;             // b_oprd[31:0]
output         reg5_31;            // Temp_reg5[31]

output   [1:0] u_f00;              // field_00: IU_zero_comparator
output   [2:0] u_f01;              // Field_01: Ucode and StacK         WT
output   [1:0] u_f02;              // Field_02: Ucode and Stack         RD
output   [1:0] u_f03;              // Field_03: Ucode and Data_cache
output   [6:0] u_f04;              // Field_04: Ucode and Architech_reg RD
output   [2:0] u_f05;              // Field_05: Ucode and Architech_reg WT
output   [2:0] u_f07;              // Field_07: Integer Unit ALU b_operand
output   [2:0] u_f08;              // Field_08: Read_port_A of temp_regs
output   [1:0] u_f17;              // field_17: IU_adder operations
output  [11:0] u_f18;              // field_18: Branching in ucode
output   [3:0] u_f19;              // field_19: Mem_adder a_operand
output   [1:0] u_f21;              // Field_21: Memory_adder operations
output         u_f22;              // field_22: Sel stack_cache address
output   [1:0] u_f23;              // field_23: Sel alu_adder input port_a


// ------------- declarations ---------------------------------------------

wire     [1:0] u_f00;
wire     [2:0] u_f01;
wire     [1:0] u_f02;
wire     [1:0] u_f03;
wire     [6:0] u_f04;
wire     [2:0] u_f05;
wire     [3:0] u_f06;
wire     [2:0] u_f07;
wire     [2:0] u_f08;
wire     [2:0] u_f09;
wire     [2:0] u_f10;
wire     [2:0] u_f11;
wire     [1:0] u_f12;
wire     [1:0] u_f13;
wire     [1:0] u_f14;
wire           u_f15;
wire     [1:0] u_f16;
wire     [1:0] u_f17;
wire    [11:0] u_f18;
wire     [3:0] u_f19;
wire     [3:0] u_f20;
wire     [1:0] u_f21;
wire           u_f22;
wire     [1:0] u_f23;

wire  [(`ROM_BITS -1):0] rom_data; // physical    rom data_out


/*********** Ucode data path section *****************************************/

ucode_dat ucode_dat_0 (
                            .instr_index(index_byte1_e[7:0]),
                            .instr_narg (index_byte2_e[7:0]),
                            .instr_indexbyte1(index_byte1_e[7:0]),
                            .instr_indexbyte2(index_byte2_e[7:0]),
                            .ie_stall_ucode(ie_stall_ucode),
                            .ie_kill_ucode (ie_kill_ucode),
                            .u_f02(u_f02),
                            .u_f06(u_f06),
                            .u_f08(u_f08),
                            .u_f09(u_f09),
                            .u_f10(u_f10),
                            .u_f11(u_f11),
                            .u_f12(u_f12),
                            .u_f13(u_f13),
                            .u_f14(u_f14),
                            .u_f15(u_f15),
                            .u_f16(u_f16),
                            .u_f19(u_f19),
                            .u_f20(u_f20),
                            .iu_optop    (iu_optop[31:0]),
                            .alu_data    (alu_data[31:0]),
                            .archi_data  (archi_data[31:0]),
                            .ucode_addr_d(ucode_addr_d[31:0]),
                            .rs1  (rs1[31:0]),
                            .rs1_b(rs1_b[31:0]),
                            .rs2  (rs2[31:0]),
                            .dreg (dreg[31:0]),
                            .sm     (),
                            .sin    (),
                            .reset_l(reset_l),
                            .clk  (clk),
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
                            .reg5_31(reg5_31)
                      );

ieu_rom ieu_rom_0 (
                            .nxt_ucode_cnt(nxt_ucode_cnt[8:0]),
                            .rom_data(rom_data) 
                  );

ucode_reg ucode_reg_0 (
                            .rom_fxx(rom_data[(`USED_BITS-1):0]),
                            .ie_stall_ucode (ie_stall_ucode),
                            .sel_fxx_default(sel_fxx_default),
                            .u_abt_cur      (u_abt_cur),
                            .sm (),
                            .sin(),
                            .clk(clk),
                            .so (),
                            .test_mode(te_ieu_rom),
                            .u_f00(u_f00),
                            .u_f01(u_f01),
                            .u_f02(u_f02),
                            .u_f03(u_f03),
                            .u_f04(u_f04),
                            .u_f05(u_f05),
                            .u_f06(u_f06),
                            .u_f07(u_f07),
                            .u_f08(u_f08),
                            .u_f09(u_f09),
                            .u_f10(u_f10),
                            .u_f11(u_f11),
                            .u_f12(u_f12),
                            .u_f13(u_f13),
                            .u_f14(u_f14),
                            .u_f15(u_f15),
                            .u_f16(u_f16),
                            .u_f17(u_f17),
                            .u_f18(u_f18),
                            .u_f19(u_f19),
                            .u_f20(u_f20),
                            .u_f21(u_f21),
                            .u_f22(u_f22),
                            .u_f23(u_f23)
                       );

endmodule

