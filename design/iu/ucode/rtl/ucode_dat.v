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

// --------- Buffer a_oprd, 32 bits wide -------------------------------------

module buf_a_oprd (a_oprd_i, a_oprd, a_oprd_u, ucode_porta, a_oprd_0_l);
 
input  [31:0] a_oprd_i;
output [31:0] a_oprd;
output [31:0] a_oprd_u;
output [31:0] ucode_porta;
output        a_oprd_0_l;
 
wire   [31:0] a_oprd_b, u_porta_l;
 
/* Logic
  assign a_oprd      =  a_oprd_i[31:0];
  assign ucode_porta =  a_oprd_i[31:0];
  assign a_oprd_0_l  = ~a_oprd_i[0];
*/
 
  inv_c_32 inv_c_32_0 ( .inp(a_oprd_i[31:0]), .out_l(a_oprd_b[31:0]) );

  inv_f_32 inv_f_32_0 ( .inp(a_oprd_b[31:0]), .out_l(a_oprd_u[31:0]) );
  inv_e_32 inv_e_32_1 ( .inp(a_oprd_b[31:0]), .out_l(a_oprd[31:0]) );
  inv_c_32 inv_c_32_1 ( .inp(a_oprd[31:0]),   .out_l(u_porta_l[31:0]) );
  inv_f_32 inv_f_32_2 ( .inp(u_porta_l[31:0]),.out_l(ucode_porta[31:0]) );
  inv_d_1  inv_d_1_0  ( .inp(a_oprd_i[0]   ), .out_l(a_oprd_0_l)  );
 
endmodule

// ======== UCODE_DAT =============================================================
module ucode_dat (
                             instr_index,
                             instr_narg,
                             instr_indexbyte1,
                             instr_indexbyte2,
                             ie_stall_ucode,
                             ie_kill_ucode,
                             u_f02,
                             u_f06,
                             u_f08,
                             u_f09,
                             u_f10,
                             u_f11,
                             u_f12,
                             u_f13,
                             u_f14,
                             u_f15,
                             u_f16,
                             u_f19,
                             u_f20,
                             iu_optop,
                             alu_data,
                             archi_data,
                             ucode_addr_d,
                             rs1,
                             rs1_b,
                             rs2,
                             dreg,
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
                             reg5_31 
                   );

//  `include "../../common/ucode.h"

input    [7:0] instr_index;        // index of method vector table, instruc
input    [7:0] instr_narg;         // # of arguments, instruction
input    [7:0] instr_indexbyte1;   // indexbyte1 of the opcode, instruction
input    [7:0] instr_indexbyte2;   // indexbyte2 of the opcode, instruction
input          ie_stall_ucode;     // IE unit holds off ucode execution
input          ie_kill_ucode;      // IE unit kills     ucode execution

input    [1:0] u_f02;              // Field_02: Ucode and Stack         RD
input    [3:0] u_f06;              // Field_06: Integer Unit ALU a_operand
input    [2:0] u_f08;              // Field_08: Read_port_A of temp_regs
input    [2:0] u_f09;              // Field_09: Read_port_B of temp_regs
input    [2:0] u_f10;              // Field_10: Write_port_A of temp_reg SEL
input    [2:0] u_f11;              // Field_11: Write_port_A of temp_reg WT
input    [1:0] u_f12;              // Field_12: Write_port_B0 of temp_reg SEL
input    [1:0] u_f13;              // Field_13: Write_port_B1 of temp_reg SEL
input    [1:0] u_f14;              // Field_14: Write_port_B0 of temp_reg WT
input          u_f15;              // Field_15: Write_port_B1 of temp_reg WT
input    [1:0] u_f16;              // Field_16: Sel reg2/3/6->dat/stk cache
input    [3:0] u_f19;              // field_19: Mem_adder a_operand
input    [3:0] u_f20;              // field_20: Mem_adder b_operand

input   [31:0] iu_optop;           // the optop IU sent to start ucode
input   [31:0] alu_data;           // ieu_alu data output
input   [31:0] archi_data;         // architecture register output
input   [31:0] ucode_addr_d;       // memory_adder output

input   [31:0] rs1;                // always  rs1  = reg[nxt_rs1]
input   [31:0] rs1_b;              // always  rs1  = reg[nxt_rs1] buffered
input   [31:0] rs2;                // Initial rs2  = reg[nxt_rs2]
input   [31:0] dreg;               // always  dreg = reg{d_cache[ucode_addr_d]}

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

// ------------- declarations ---------------------------------------------
wire    [31:0] ucode_porta;        // ucode output data to ie       porta
wire    [31:0] ucode_portb;        // ucode output data to ie       portb
wire    [31:0] ucode_portc;        // ucode output data to stcak_/data_cache
wire    [31:0] u_addr_st_rd;       // ucode to stack_cache  read_address
wire    [31:0] u_areg0;            // ucode output of the areg0 register

wire    [31:0] ialu_a;             // ucode output data to ie_alu's porta
wire    [31:0] m_adder_porta;      // ucode output data to imem_adder's porta
wire    [31:0] m_adder_portb;      // ucode output data to imem_adder's portb

wire    [31:0] areg0;
wire    [31:0]  reg0;
wire    [31:0]  reg1;
wire    [31:0]  reg2;
wire    [31:0]  reg3;
wire    [31:0]  reg5;
wire    [31:0]  reg6;

wire    [31:0] d_areg0;
wire    [31:0] d_reg0;
wire    [31:0] d_reg1;
wire    [31:0] d_reg2;
wire    [31:0] d_reg3;
wire    [31:0] d_reg5;
wire    [31:0] d_reg6;

wire    [31:0] nxt_areg0;
wire    [31:0] nxt_reg0;
wire    [31:0] nxt_reg1;
wire    [31:0] nxt_reg2;
wire    [31:0] nxt_reg3;
wire    [31:0] nxt_reg5;
wire    [31:0] nxt_reg6;

wire    [31:0] w_mx_a,    w_mx_b0, w_mx_b1;
wire    [31:0] a_oprd,    b_oprd;  // ucode temp_reg output a,b
wire    [31:0] r236;               // reg1/2/3/6 data = ucode_portc

wire    [31:0] a_oprd_i,   a_oprd_u;
wire           a_oprd_0_l;

wire           reg_clear_l;

wire     [2:0] sel_u_f20;          // select u_f20's 8_to_1 flat_mux
reg     [31:0] const_mb;           // 8 constants for      mem_adder's portb
wire     [2:0] sel_u_f06;          // select u_f06's 8_to_1 flat_mux
reg     [31:0] const_ia;           // 8 constants for ialu_a



/*
// ------------- initial registers ----------------------------------------
initial begin
          areg0        = 32'b0;
           reg0        = 32'b0;
           reg1        = 32'b0;
           reg2        = 32'b0;
           reg3        = 32'b0;
           reg5        = 32'b0;
           reg6        = 32'b0;
        end
*/

/*********** Ucode_dat section ***********************************************/

// ------------- Memory_adder operations from UCODE -----------------------
/* Logic
  always @ (u_f19 or
            rs1   or rs2 or archi_data or iu_optop or
            areg0 or r236 or
            dreg
           ) begin
    case(u_f19)                         // synopsys parallel_case
      `F19_SEL_DCACHE_MA:  m_adder_porta = dreg;
      `F19_SEL_DCACHE_MA2: m_adder_porta = {dreg[31:2],2'b0};
      `F19_SEL_DCACHE_MA3: m_adder_porta = {dreg[31:3],3'b0};
      `F19_SEL_AREG0_MA:   m_adder_porta = areg0;
      `F19_SEL_OPTOP_MA:   m_adder_porta = iu_optop;
      `F19_SEL_PORTC_MA:   m_adder_porta = r236;
      `F19_SEL_ARCH_MA:    m_adder_porta = archi_data;
      `F19_SEL_ARCH_MA_54: m_adder_porta = {archi_data[31:6],2'b10,archi_data[3:0]};
      `F19_SEL_RS1_MA:     m_adder_porta = rs1;
      `F19_SEL_RS1_MA_M2:  m_adder_porta = {rs1[31:2],2'b0};
      `F19_SEL_RS2_MA_M2:  m_adder_porta = {rs2[31:2],2'b0};
      default:             m_adder_porta = dreg;
    endcase
  end
*/

  mj_s_mux6_d_32 mux6_m_adder_porta (
                                      .mx_out(m_adder_porta[31:0]),
                                      .sel(u_f19[2:0]),
                                      .in0(dreg[31:0]),
                                      .in1({dreg[31:2],2'b0}),
                                      .in2({dreg[31:3],3'b0}),
                                      .in3(areg0[31:0]),
                                      .in4(iu_optop[31:0]),
                                      .in5(r236[31:0]) 
                                     );
 
/* Logic
  always @ (u_f20 or
            instr_narg or instr_index or
            instr_indexbyte1 or instr_indexbyte2 or
            r236 or
            dreg
           ) begin
    case(u_f20)                         // synopsys parallel_case
      `F20_SEL_DCACHE_MB:  m_adder_portb = dreg;
      `F20_RD_A8_LSH2_MB:  m_adder_portb = {22'b0,instr_narg, 2'b0};
      `F20_RD_I8_LSH2_MB:  m_adder_portb = {22'b0,instr_index,2'b0};
      `F20_RD_I16_LSH2_MB: m_adder_portb = {14'b0,instr_indexbyte1,
                                                  instr_indexbyte2,2'b0};
      `F20_SEL_PORTC_MB:   m_adder_portb = r236;
      `F20_MB_CONST_00:    m_adder_portb = 32'd0;
      `F20_MB_CONST_01:    m_adder_portb = 32'd1;
      `F20_MB_CONST_02:    m_adder_portb = 32'd2;
      `F20_MB_CONST_03:    m_adder_portb = 32'd3;
      `F20_MB_CONST_04:    m_adder_portb = 32'd4;
      `F20_MB_CONST_08:    m_adder_portb = 32'd8;
      `F20_MB_CONST_12:    m_adder_portb = 32'd12;
      `F20_MB_CONST_16:    m_adder_portb = 32'd16;
      `F20_MB_CONST_20:    m_adder_portb = 32'd20;
      `F20_MB_CONST_28:    m_adder_portb = 32'd28;
      default:             m_adder_portb = dreg;
    endcase
  end
*/

  assign sel_u_f20 = {3{u_f20[3]}} | u_f20[2:0];
 
  mj_s_mux8_d_32 mux8_m_adder_portb (
                                      .mx_out(m_adder_portb[31:0]),
                                      .sel(sel_u_f20[2:0]),
                                      .in0(dreg[31:0]),
                                      .in1({22'b0,instr_narg, 2'b0}),
                                      .in2({22'b0,instr_index,2'b0}),
                                      .in3({14'b0,instr_indexbyte1,
                                                  instr_indexbyte2,2'b0}),
                                      .in4(r236[31:0]),
                                      .in5(32'd0),
                                      .in6(32'd1),
                                      .in7(const_mb[31:0])
                                     );
 
  always @ (u_f20
           ) begin
    case(u_f20)                         // synopsys parallel_case
      `F20_MB_CONST_02:   const_mb = 32'd2;
      `F20_MB_CONST_03:   const_mb = 32'd3;
      `F20_MB_CONST_04:   const_mb = 32'd4;
      `F20_MB_CONST_08:   const_mb = 32'd8;
      `F20_MB_CONST_12:   const_mb = 32'd12;
      `F20_MB_CONST_16:   const_mb = 32'd16;
      `F20_MB_CONST_20:   const_mb = 32'd20;
      `F20_MB_CONST_28:   const_mb = 32'd28;
      default:            const_mb = 32'd2;
    endcase
  end 


// ------------- IU_alu       operations from UCODE -----------------------
/* Logic
  always @ (u_f06 or
            a_oprd_u
           ) begin
    case(u_f06)                         // synopsys parallel_case
      `F06_A_U_PORTA:     ialu_a = a_oprd_u[31:0];
      `F06_EXTR_16_RSH0:  ialu_a = {16'b0,a_oprd_u[15:0] };
      `F06_EXTR_16_RSH16: ialu_a = {16'b0,a_oprd_u[31:16]};
      `F06_A_LSH1:        ialu_a = {a_oprd_u[30:0],1'b0};
      `F06_A_LSH2:        ialu_a = {a_oprd_u[29:0],2'b0};
      `F06_A_LSH3:        ialu_a = {a_oprd_u[28:0],3'b0};
      `F06_A_CONST_00:    ialu_a = 32'd0;
      `F06_A_CONST_01:    ialu_a = 32'd1;
      `F06_A_CONST_02:    ialu_a = 32'd2;
      `F06_A_CONST_03:    ialu_a = 32'd3;
      `F06_A_CONST_04:    ialu_a = 32'd4;
      `F06_A_CONST_08:    ialu_a = 32'd8;
      `F06_A_CONST_12:    ialu_a = 32'd12;
      `F06_A_CONST_16:    ialu_a = 32'd16;
      `F06_A_CONST_32:    ialu_a = 32'd32;
      default:            ialu_a = a_oprd_u;
    endcase
  end 
*/

  assign sel_u_f06 = {3{u_f06[3]}} | u_f06[2:0];
 
  mj_s_mux8_d_32 mux8_ialu_a (
                                     .mx_out(ialu_a[31:0]),
                                     .sel(sel_u_f06[2:0]),
                                     .in0(a_oprd_u[31:0]),
                                     .in1({16'b0,a_oprd_u[15:0] }),
                                     .in2({16'b0,a_oprd_u[31:16]}),
                                     .in3({a_oprd_u[30:0],1'b0}),
                                     .in4({a_oprd_u[29:0],2'b0}),
                                     .in5({a_oprd_u[28:0],3'b0}),
                                     .in6(32'd0),
                                     .in7(const_ia[31:0])
                                    );
 
  always @ (u_f06
           ) begin
    case(u_f06)                         // synopsys parallel_case
      `F06_A_CONST_01:    const_ia = 32'd1;
      `F06_A_CONST_02:    const_ia = 32'd2;
      `F06_A_CONST_03:    const_ia = 32'd3;
      `F06_A_CONST_04:    const_ia = 32'd4;
      `F06_A_CONST_08:    const_ia = 32'd8;
      `F06_A_CONST_12:    const_ia = 32'd12;
      `F06_A_CONST_16:    const_ia = 32'd16;
      `F06_A_CONST_32:    const_ia = 32'd32;
      default:            const_ia = 32'd1;
    endcase
  end

/* Logic
  always @ (u_f07 or ucode_portb or rs1 or archi_data or iu_optop) begin
    case(u_f07)                         // synopsys parallel_case
      `F07_B_U_PORTB:     ialu_b = ucode_portb[31:0];
      `F07_B_RS1:         ialu_b = rs1[31:0];
      `F07_B_ARCH:        ialu_b = archi_data[31:0];
      `F07_B_OPTOP:       ialu_b = iu_optop[31:0]; 
      `F07_B_RS1_M2:      ialu_b = {rs1[31:2],2'b0};
      `F07_B_ARCH_M2:     ialu_b = {archi_data[31:2],2'b0};
      `F07_B_CONST_00:    ialu_b = 32'h0;
      default:            ialu_b = ucode_portb;
    endcase
  end 
*/


// ------------- 7 temp_register read/write -------------------------------
  assign reg5_31   = reg5[31];

/* Logic
  assign u_addr_st_wt = (u_f22==`F22_SEL_IALU) ? alu_data[31:0] : areg0[31:0];
*/
  assign u_addr_st_rd = (u_f02[1] /*u_f02==`F02_RD_STK_REG0*/ ) ?  reg0[31:0] :
                                                                   areg0[31:0];

/* Logic
  assign ucode_porta  =  a_oprd_i[31:0];
  assign a_oprd       =  a_oprd_i[31:0];
  assign a_oprd_0_l   = !a_oprd_i[0];

  assign ucode_portb  =  b_oprd[31:0];
  assign ucode_portc  =  r236[31:0];
  assign u_areg0      =  areg0[31:0];
*/


  buf_a_oprd buf_a_oprd_0 (
                           .a_oprd_i   (a_oprd_i[31:0]),
                           .a_oprd     (a_oprd[31:0]),
                           .a_oprd_u   (a_oprd_u[31:0]),
                           .ucode_porta(ucode_porta[31:0]),
                           .a_oprd_0_l (a_oprd_0_l)
                          );

  buf_cf_32 buf_cf_32_u_ptb ( .inp(b_oprd[31:0]), .out(ucode_portb[31:0]) );
  buf_cf_32 buf_cf_32_u_ptc ( .inp(r236[31:0]),   .out(ucode_portc[31:0]) );
  buf_cf_32 buf_cf_32_u_ar0 ( .inp(areg0[31:0]),  .out(u_areg0[31:0])     );

/* Logic
  always @ (u_f10 or
            dreg or rs1_b or rs2 or ucode_addr_d or
            alu_data) begin
    case(u_f10)                         // synopsys parallel_case
      `F10_SEL_ALU_A:     w_mx_a = alu_data[31:0];
      `F10_SEL_DCACHE_A:  w_mx_a = dreg[31:0];
      `F10_SEL_RS1_A:     w_mx_a = rs1_b[31:0];
      `F10_SEL_RS2_A:     w_mx_a = rs2[31:0];
      `F10_SEL_MA_A:      w_mx_a = ucode_addr_d[31:0];
      default:            w_mx_a = alu_data[31:0];
    endcase
  end
*/

  mj_s_mux6_d_32 mux6_w_mx_a (
                                     .mx_out(w_mx_a[31:0]),
                                     .sel(u_f10[2:0]),
                                     .in0(alu_data[31:0]),
                                     .in1(dreg[31:0]),
                                     .in2(rs1_b[31:0]),
                                     .in3(rs2[31:0]),
                                     .in4(ucode_addr_d[31:0]),
                                     .in5(alu_data[31:0]) 
                                    );

/* Logic
  always @ (u_f12 or
            dreg or rs1_b or rs2 or
            alu_data) begin 
    case(u_f12)                         // synopsys parallel_case
      `F12_SEL_ALU_B0:      w_mx_b0 = alu_data[31:0];
      `F12_SEL_RS1_B0:      w_mx_b0 = rs1_b[31:0];
      `F12_SEL_DCACHE_B0:   w_mx_b0 = dreg[31:0];
      `F12_SEL_RS2_B0:      w_mx_b0 = rs2[31:0];
      default:              w_mx_b0 = alu_data[31:0];
    endcase 
  end
*/
 
  mj_s_mux4_d_32 mux4_w_mx_b0 (
                                      .mx_out(w_mx_b0[31:0]),
                                      .sel(u_f12[1:0]),
                                      .in0(alu_data[31:0]),
                                      .in1(rs1_b[31:0]),
                                      .in2(dreg[31:0]),
                                      .in3(rs2[31:0])
                                     );

/* Logic
  always @ (u_f13 or
            reg0 or ucode_addr_d or
            alu_data) begin 
    case(u_f13)                         // synopsys parallel_case
      `F13_SEL_ALU_B1:      w_mx_b1 = alu_data[31:0];
      `F13_SEL_PASS_A_B1:   w_mx_b1 = reg0[31:0];
      `F13_SEL_MA_B1:       w_mx_b1 = ucode_addr_d[31:0];
      default:              w_mx_b1 = alu_data[31:0];
    endcase 
  end
*/

  mj_s_mux3_d_32 mux3_w_mx_b1 (
                                      .mx_out(w_mx_b1[31:0]),
                                      .sel(u_f13[1:0]),
                                      .in0(alu_data[31:0]),
                                      .in1(d_reg0[31:0]),
                                      .in2(ucode_addr_d[31:0]) 
                                     );

/* Logic
  always @ (u_f08 or
            reg1 or reg2 or reg3 or reg5 or
            dreg or rs1 or rs2 or
            reg0) begin 
    case(u_f08)                         // synopsys parallel_case
      `F08_RD_REG0_A:   a_oprd_i = reg0[31:0];
      `F08_RD_REG1_A:   a_oprd_i = reg1[31:0];
      `F08_RD_REG2_A:   a_oprd_i = reg2[31:0];
      `F08_RD_REG3_A:   a_oprd_i = reg3[31:0];
      `F08_RD_REG5_A:   a_oprd_i = reg5[31:0];
      `F08_RD_RS1_A:    a_oprd_i = rs1[31:0];
      `F08_RD_RS2_A:    a_oprd_i = rs2[31:0];
      `F08_RD_DCACHE_A: a_oprd_i = dreg[31:0];
      default:          a_oprd_i = reg0[31:0];
    endcase 
  end
*/

  mj_s_mux8_d_32 mux8_a_oprd (
                                     .mx_out(a_oprd_i[31:0]),
                                     .sel(u_f08[2:0]),
                                     .in0(reg0[31:0]),
                                     .in1(reg1[31:0]),
                                     .in2(reg2[31:0]),
                                     .in3(reg3[31:0]),
                                     .in4(reg5[31:0]),
                                     .in5(rs1[31:0]),
                                     .in6(rs2[31:0]),
                                     .in7(dreg[31:0]) 
                                    );

/* Logic
  always @ (u_f09 or
            reg5 or reg6 or
            archi_data or rs1 or dreg or
            areg0) begin 
    case(u_f09)                         // synopsys parallel_case
      `F09_RD_AREG0_B:    b_oprd = areg0[31:0];
      `F09_RD_REG5_B:     b_oprd =  reg5[31:0];
      `F09_RD_REG6_B:     b_oprd =  reg6[31:0];
      `F09_RD_ARCH_B:     b_oprd = archi_data[31:0];
      `F09_RD_RS1_B:      b_oprd = rs1[31:0];
      `F09_RD_DCACHE_B:   b_oprd = dreg[31:0];
      `F09_RD_DCACHE_BM2: b_oprd = {dreg[31:2],2'b0};
      `F09_RD_DCACHE_BM8: b_oprd = dreg[31:0]; // data structure change, extend 8 bits
      default:            b_oprd = areg0[31:0];
    endcase 
  end
*/

  mj_s_mux8_d_32 mux8_b_oprd (
                                     .mx_out(b_oprd[31:0]),
                                     .sel(u_f09[2:0]),
                                     .in0(areg0[31:0]),
                                     .in1(reg5[31:0]),
                                     .in2(reg6[31:0]),
                                     .in3(archi_data[31:0]),
                                     .in4(rs1[31:0]),
                                     .in5(dreg[31:0]),
                                     .in6({dreg[31:2],2'b0}),
                                     .in7(dreg[31:0]) 
                                    );

  del1_32 del1_32_areg0 ( .inp(areg0[31:0]), .out(d_areg0[31:0]) );
  del1_32 del1_32_reg0  ( .inp(reg0[31:0]),  .out(d_reg0[31:0])  );
  del1_32 del1_32_reg1  ( .inp(reg1[31:0]),  .out(d_reg1[31:0])  );
  del1_32 del1_32_reg2  ( .inp(reg2[31:0]),  .out(d_reg2[31:0])  );
  del1_32 del1_32_reg3  ( .inp(reg3[31:0]),  .out(d_reg3[31:0])  );
  del1_32 del1_32_reg5  ( .inp(reg5[31:0]),  .out(d_reg5[31:0])  );
  del1_32 del1_32_reg6  ( .inp(reg6[31:0]),  .out(d_reg6[31:0])  );

  assign nxt_areg0 = (u_f15==`F15_WT_AREG0_B1) ? w_mx_b1[31:0]     : d_areg0[31:0];
  assign nxt_reg0  = (u_f11==`F11_WT_REG0_A  ) ? w_mx_a[31:0]      : d_reg0[31:0];
  assign nxt_reg1  = (u_f11==`F11_WT_REG1_A  ) ? w_mx_a[31:0]      : d_reg1[31:0];
  assign nxt_reg2  = (u_f11==`F11_WT_REG2_A  ) ? w_mx_a[31:0]      : d_reg2[31:0];
  assign nxt_reg3  = (u_f11==`F11_WT_REG3_A  ) ? w_mx_a[31:0]      : d_reg3[31:0];
  assign nxt_reg5  = (u_f14[0]/*`F14_WT_REG5_B0*/) ? w_mx_b0[31:0] : d_reg5[31:0];
  assign nxt_reg6  = (u_f14[1]/*`F14_WT_REG6_B0*/) ? w_mx_b0[31:0] : d_reg6[31:0];

/* Logic
  always @ (posedge clk) begin
    if (!reset_l || ie_kill_ucode) begin
      areg0 <= 32'b0;
       reg0 <= 32'b0;
       reg1 <= 32'b0;
       reg2 <= 32'b0;
       reg3 <= 32'b0;
       reg5 <= 32'b0;
       reg6 <= 32'b0;
    end
    else begin
      if (ie_stall_ucode==0) begin
        areg0 <= nxt_areg0;
         reg0 <= nxt_reg0;
         reg1 <= nxt_reg1;
         reg2 <= nxt_reg2;
         reg3 <= nxt_reg3;
         reg5 <= nxt_reg5;
         reg6 <= nxt_reg6;
      end
    end
  end // end the always @ (posedge clk)
*/

  assign reg_clear_l = !(!reset_l || ie_kill_ucode);

  ff_sre_32 reg_areg0 (
                       .out(areg0[31:0]),
                       .din(nxt_areg0[31:0]),
                       .enable(!ie_stall_ucode),
                       .reset_l(reg_clear_l),
                       .clk(clk)
                      );

  ff_sre_32 reg_reg0  ( 
                       .out(reg0[31:0]),
                       .din(nxt_reg0[31:0]),
                       .enable(!ie_stall_ucode), 
                       .reset_l(reg_clear_l), 
                       .clk(clk)
                      ); 

  ff_sre_32 reg_reg1  (
                       .out(reg1[31:0]),
                       .din(nxt_reg1[31:0]),
                       .enable(!ie_stall_ucode),
                       .reset_l(reg_clear_l),
                       .clk(clk)
                      );

  ff_sre_32 reg_reg2  ( 
                       .out(reg2[31:0]),
                       .din(nxt_reg2[31:0]),
                       .enable(!ie_stall_ucode), 
                       .reset_l(reg_clear_l), 
                       .clk(clk)
                      ); 

  ff_sre_32 reg_reg3  ( 
                       .out(reg3[31:0]),
                       .din(nxt_reg3[31:0]),
                       .enable(!ie_stall_ucode), 
                       .reset_l(reg_clear_l), 
                       .clk(clk)
                      ); 

  ff_sre_32 reg_reg5  ( 
                       .out(reg5[31:0]),
                       .din(nxt_reg5[31:0]),
                       .enable(!ie_stall_ucode), 
                       .reset_l(reg_clear_l), 
                       .clk(clk)
                      ); 

  ff_sre_32 reg_reg6  ( 
                       .out(reg6[31:0]),
                       .din(nxt_reg6[31:0]),
                       .enable(!ie_stall_ucode), 
                       .reset_l(reg_clear_l), 
                       .clk(clk)
                      ); 


// ------------- Select reg2/3/6 write to data_ or stack_ cache -----------
/* Logic
  always @ (u_f16 or
            reg3 or reg6 or rs1_b or
            reg2) begin
    case(u_f16)                         // synopsys parallel_case
      `F16_SEL_R2_CACHE: r236 = reg2;
      `F16_SEL_R3_CACHE: r236 = reg3;
      `F16_SEL_R6_CACHE: r236 = reg6;
      `F16_SEL_RS1_CACHE:r236 = rs1_b;
      default:           r236 = reg2;
    endcase
  end
*/

  mj_s_mux4_d_32 mux4_r236 (
                                   .mx_out(r236[31:0]),
                                   .sel(u_f16[1:0]),
                                   .in0(reg2[31:0]),
                                   .in1(reg3[31:0]),
                                   .in2(reg6[31:0]),
                                   .in3(rs1_b[31:0]) 
                                  );

endmodule

