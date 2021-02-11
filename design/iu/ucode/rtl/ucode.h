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

// ------------ define control bus ---------

// ----- ucode_cnt ------------------------------------------------------
`define U_IDLE             9'd0       // ucode_cnt
`define ROM_BITS             80       // total bits of the ucode_rom (width)
`define USED_BITS            74       // actually used bits of the ucode_rom

// ----- Field_00: Interger Unit Comparator -------------------- --------
`define F00_DEFAULT        2'b00
`define F00_A_COMP_ZERO    2'b10      // a_oprd compared with zero
`define F00_RS1_COMP_ZERO  2'b01      // IU rs1 compared with zero
`define F00_RS2_COMP_ZERO  2'b11      // IU rs2 compared with zero

// ----- Field_01: Ucode and Stack_cache --------------------------------
`define F01_DEFAULT        3'b000
`define F01_WT_PSR_STK     3'b001     // write reg_PSR     to stack_cache
`define F01_WT_VARS_STK    3'b010     // write reg_VARS    to stack_cache
`define F01_WT_FRAME_STK   3'b011     // write reg_VARS    to stack_cache
`define F01_WT_CONST_P_STK 3'b100     // write reg_CONST_P to stack_cache
`define F01_WT_R236_STK    3'b101     // write t_reg2,3,6  to stack_cache
`define F01_WT_DREG_STK    3'b110     // write dcache      to stack_cache
`define F01_WT_DREG_STK_M8 3'b111     // write dcache[23:0]to stack_cache
 
`define F02_DEFAULT        2'b00
`define F02_RD_STK         2'b01      // read  stack_cache, at areg0
`define F02_RD_STK_REG0    2'b10      // read  stack_cache, at reg0
 
// ----- Field_03: Ucode and Data_cache ---------------------------------
`define F03_DEFAULT        2'b00
`define F03_RD_DCACHE      2'b01      // read  data_cache
`define F03_WT_DCACHE      2'b10      // write data_cache
`define F03_ARY_LD         2'b11      // read  data_cache (only for array lds)

// ----- Field_04: Ucode and Architech_registers ------------------------
`define F04_DEFAULT        7'b0000001
`define F04_RD_PC          7'b0000001 // read  reg_PC
`define F04_RD_VARS        7'b0000010 // read  reg_VARS
`define F04_RD_FRAME       7'b0000100 // read  reg_FRAME
`define F04_RD_CONST_P     7'b0001000 // read  reg_CONST_P
`define F04_RD_PSR         7'b0010000 // read  reg_psr
`define F04_RD_GC_CONF     7'b0100000 // read  reg_gc_conf
`define F04_RD_TBR         7'b1000000 // read  reg_Trap_Base  
 
`define F05_DEFAULT        3'b000
`define F05_WT_A_PC        3'b001     // write a_operand to reg_PC
`define F05_WT_A_VARS      3'b010     // write a_operand to reg_VARS
`define F05_WT_A_FRAME     3'b011     // write a_operand to reg_FRAME
`define F05_WT_A_CONST_P   3'b100     // write a_operand to reg_CONST_P
`define F05_WT_A_OPTOP     3'b101     // write a_operand to reg_OPTOP
`define F05_WT_V_OPTOP     3'b110     // write reg_VARS  to reg_OPTOP
`define F05_WT_A_PSR       3'b111     // write a_operand to reg_PSR 

// ----- Field_06: Integer Unit ALU a_,b_ operand from UCODE ------------
`define F06_DEFAULT        4'b0000
`define F06_A_U_PORTA      4'b0000    // a_operand is from ucode_porta
`define F06_EXTR_16_RSH0   4'b0001    // extract t_reg 16bits rsh0 via a_oprd
`define F06_EXTR_16_RSH16  4'b0010    // extract t_reg 16bits rsh16via a_oprd
`define F06_A_LSH1         4'b0011    // a_operand left_shift by 1
`define F06_A_LSH2         4'b0100    // a_operand left_shift by 2
`define F06_A_LSH3         4'b0101    // a_operand left_shift by 3
`define F06_A_CONST_00     4'b0110    // a_operand is constant  0
`define F06_A_CONST_01     4'b1000    // a_operand is constant  1
`define F06_A_CONST_02     4'b1001    // a_operand is constant  2
`define F06_A_CONST_03     4'b1010    // a_operand is constant  3
`define F06_A_CONST_04     4'b1011    // a_operand is constant  4
`define F06_A_CONST_08     4'b1100    // a_operand is constant  8
`define F06_A_CONST_12     4'b1101    // a_operand is constant 12
`define F06_A_CONST_16     4'b1110    // a_operand is constant 16
`define F06_A_CONST_32     4'b1111    // a_operand is constant 32

`define F07_DEFAULT        3'b000
`define F07_B_RS2          3'b000     // b_operand is rs2 -- default
`define F07_B_U_PORTB      3'b001     // b_operand is from ucode_portb
`define F07_B_RS1          3'b010     // b_operand is rs1
`define F07_B_ARCH         3'b011     // b_operand is architecure register
`define F07_B_OPTOP        3'b100     // b_operand is iu_optop
`define F07_B_RS1_M2       3'b101     // b_operand is {rs1[31:2],2'b0}
`define F07_B_ARCH_M2      3'b110     // b_operand is {arch[31:2],2'b0}
`define F07_B_CONST_00     3'b111     // b_operand is constant  0
// ----- Field_08: Read_port_A of temp_registers ------------------------
`define F08_DEFAULT        3'b000
`define F08_RD_REG0_A      3'b000     // read  t_reg0      via a_oprd 
`define F08_RD_REG1_A      3'b001     // read  t_reg1      via a_oprd 
`define F08_RD_REG2_A      3'b010     // read  t_reg2      via a_oprd 
`define F08_RD_REG3_A      3'b011     // read  t_reg3      via a_oprd 
`define F08_RD_REG5_A      3'b100     // read  t_reg5      via a_oprd 
`define F08_RD_RS1_A       3'b101     // read  stack_cache via a_oprd
`define F08_RD_RS2_A       3'b110     // read  stack_rs2   via a_oprd
`define F08_RD_DCACHE_A    3'b111     // read  dcache      via a_oprd

// ----- Field_09: Read_port_B of temp_registers ------------------------
`define F09_DEFAULT        3'b000
`define F09_RD_AREG0_B     3'b000     // read  t_areg0       via b_oprd 
`define F09_RD_REG5_B      3'b001     // read  t_reg5        via b_oprd 
`define F09_RD_REG6_B      3'b010     // read  t_reg6        via b_oprd 
`define F09_RD_ARCH_B      3'b011     // read  archit_regs   via b_oprd
`define F09_RD_RS1_B       3'b100     // read  stack_cache   via b_oprd
`define F09_RD_DCACHE_B    3'b101     // read  dcache        via b_oprd
`define F09_RD_DCACHE_BM2  3'b110     // read  dcache[31:2],2'b0 b_oprd
`define F09_RD_DCACHE_BM8  3'b111     // read  8'b0,dcache[23:0] b_oprd

// ----- Field_10: Write_port_A of temp_registers -----------------------
`define F10_DEFAULT        3'b000
`define F10_SEL_ALU_A      3'b000     // select ALU     wt to t_regs as a_oprd
`define F10_SEL_DCACHE_A   3'b001     // select dcache  wt to t_regs as a_oprd
`define F10_SEL_RS1_A      3'b010     // select stack   wt to t_regs as a_oprd
`define F10_SEL_RS2_A      3'b011     // select stk_rs2 wt to t_regs as a_oprd
`define F10_SEL_MA_A       3'b100     // select MAdder  wt to t_regs as a_oprd

`define F11_DEFAULT        3'b000
`define F11_WT_REG0_A      3'b001     // write t_reg0   via a_oprd 
`define F11_WT_REG1_A      3'b010     // write t_reg1   via a_oprd 
`define F11_WT_REG2_A      3'b011     // write t_reg2   via a_oprd 
`define F11_WT_REG3_A      3'b100     // write t_reg3   via a_oprd

// ----- Field_12: Write_port_B of temp_registers -----------------------
`define F12_DEFAULT        2'b00
`define F12_SEL_ALU_B0     2'b00      // select ALU    wt to t_regs as b0_oprd
`define F12_SEL_RS1_B0     2'b01      // select stack  wt to t_regs as b0_oprd
`define F12_SEL_DCACHE_B0  2'b10      // select dcache wt to t_regs as b0_oprd
`define F12_SEL_RS2_B0     2'b11      // select rs2    wt to t_regs as b0_oprd

`define F13_DEFAULT        2'b00
`define F13_SEL_ALU_B1     2'b00      // select ALU    wt to areg0
`define F13_SEL_PASS_A_B1  2'b01      // select reg0   wt to areg0
`define F13_SEL_MA_B1      2'b10      // select MAdder wt to areg0

`define F14_DEFAULT        2'b00
`define F14_WT_REG5_B0     2'b01      // write t_reg5   via b_oprd 
`define F14_WT_REG6_B0     2'b10      // write t_reg6   via b_oprd 

`define F15_DEFAULT        1'b0
`define F15_WT_AREG0_B1    1'b1       // write t_areg0  via b_oprd

// ----- Field_16: Select reg1/2/3/6 write to data_ or stack_ cache -----
`define F16_DEFAULT        2'b00
`define F16_SEL_R2_CACHE   2'b00      // select t_reg2 to data_ or stack_ cache
`define F16_SEL_R3_CACHE   2'b01      // select t_reg3 to data_ or stack_ cache
`define F16_SEL_R6_CACHE   2'b10      // select t_reg6 to data_ or stack_ cache
`define F16_SEL_RS1_CACHE  2'b11      // select rs1    to data_ or stack_ cache

// ----- Field_17: Interger Unit Adder and Comparator Operations --------
`define F17_DEFAULT        2'b00
`define F17_IALU_pApB      2'b11      // ucode IU_ALU: +a+b
`define F17_IALU_pAsB      2'b10      // ucode IU_ALU: +a-b
`define F17_IALU_sApB      2'b01      // ucode IU_ALU: -a+b

// ----- Field_18: Branching in ucode -----------------------------------
`define F18_DEFAULT        12'b000000000000
`define F18_U_LAST         12'b000000000001
`define F18_CHK_NULL       12'b000000000010
`define F18_CHK_PTR_TRAP   12'b000000000100
`define F18_CHK_ARY_OVF    12'b000000001000
`define F18_CHK_ARY_NEG    12'b000000010000
`define F18_CHK_HANDLE2    12'b000000100000  // jump_2
`define F18_CHK_HANDLE     12'b000001000000  // jump_3, [0]=0
`define F18_CHK_HANDLE_P   12'b000001100000  // jump_3, [0]=1
`define F18_CHK_EQ_BRANCH  12'b000010000000
`define F18_CHK_LS_BRANCH1 12'b000100000000
`define F18_CHK_LS_BRANCH2 12'b000110000000
`define F18_CHK_GC         12'b001000000000
`define F18_CHK_ABT_RDWT   12'b010000000000 // a_oprd_0=1,abort rd.wt request
`define F18_CHK_1CYC_DONE  12'b100000000000 // a_oprd_0=0,1cyc_done,32bit_handle_of
`define F18_CHK_1CYC_LENG  12'b110000000000 // a_oprd_0=0,1cyc_done, arraylength

// ----- Field_19: Memory_adder     a_,b_ operand from UCODE ------------
`define F19_DEFAULT        4'b0000
`define F19_SEL_DCACHE_MA  4'b0000     // select dcache to Mem_adder as ma_oprd
`define F19_SEL_DCACHE_MA2 4'b0001     // select dcache to Mem_adder, [1:0]=0 
`define F19_SEL_DCACHE_MA3 4'b0010     // select dcache to Mem_adder, [2:0]=0 
`define F19_SEL_AREG0_MA   4'b0011     // select areg0  to Mem_adder
`define F19_SEL_OPTOP_MA   4'b0100     // select OPTOP  to Mem_adder as ma_oprd
`define F19_SEL_PORTC_MA   4'b0101     // select portc  to Mem_adder as ma_oprd
`define F19_SEL_ARCH_MA    4'b0110     // select archit to Mem_adder as ma_oprd
`define F19_SEL_ARCH_MA_54 4'b0111     // select archit, force [5:4]=2'b10
`define F19_SEL_RS1_MA     4'b1001     // select stack  to Mem_adder as ma_oprd
`define F19_SEL_RS1_MA_M2  4'b1010     // select stack  to Mem_adder, [1:0]=0
`define F19_SEL_RS2_MA_M2  4'b1011     // select rs2    to Mem_adder, [1:0]=0

`define F20_DEFAULT        4'b0000
`define F20_SEL_DCACHE_MB  4'b0000    // select dcache to Mem_adder as mb_oprd
`define F20_RD_A8_LSH2_MB  4'b0001    // read  #arg 8bits, lsh2,    as mb_oprd
`define F20_RD_I8_LSH2_MB  4'b0010    // read  indx 8bits, lsh2,    as mb_oprd
`define F20_RD_I16_LSH2_MB 4'b0011    // read  indx16bits, lsh2,    as mb_oprd
`define F20_SEL_PORTC_MB   4'b0100    // select portc  to Mem_adder as mb_oprd
`define F20_MB_CONST_00    4'b0101    // mem_adder's b_operand is constant  0
`define F20_MB_CONST_01    4'b0110    // mem_adder's b_operand is constant  2
`define F20_MB_CONST_02    4'b1000    // mem_adder's b_operand is constant  2
`define F20_MB_CONST_03    4'b1001    // mem_adder's b_operand is constant  3
`define F20_MB_CONST_04    4'b1010    // mem_adder's b_operand is constant  4
`define F20_MB_CONST_08    4'b1011    // mem_adder's b_operand is constant  8
`define F20_MB_CONST_12    4'b1100    // mem_adder's b_operand is constant 12
`define F20_MB_CONST_16    4'b1101    // mem_adder's b_operand is constant 16
`define F20_MB_CONST_20    4'b1110    // mem_adder's b_operand is constant 20
`define F20_MB_CONST_28    4'b1111    // mem_adder's b_operand is constant 28

// ----- Field_21: Memory_adder                       Operations --------
`define F21_DEFAULT        2'b00
`define F21_MADD_pApB      2'b11      // memory_adder: +a+b
`define F21_MADD_pAsB      2'b10      // memory_adder: +a-b

// ----- Field_22: Sel stack_cache address ------------------------------
`define F22_DEFAULT        1'b0
`define F22_SEL_AREG0      1'b0       // areg0 output as address
`define F22_SEL_IALU       1'b1       // adder output as addr, should only write

// ----- Field_23: Sel alu_adder input port_a ---------------------------
`define F23_DEFAULT        2'b00
`define F23_SEL_IALU_A     2'b01      // select ialu_a           to i_adder_a
`define F23_SEL_RS1_LH2_A  2'b10      // select {rs1[29:0],2'b0} to i_adder_a
`define F23_SEL_RS1_LH3_A  2'b11      // select {rs1[28:0],3'b0} to i_adder_a


// ----- Starting Ucode Rom address for a given instruction -------------
`define ARRAYLENGTH 	9'd1
`define BALOAD          9'd4
`define CALOAD          9'd9 
`define SALOAD          9'd9 
`define IALOAD          9'd14
`define FALOAD          9'd14
`define AALOAD          9'd14
`define LALOAD          9'd19
`define DALOAD          9'd19
`define BASTORE         9'd25
`define CASTORE         9'd32
`define SASTORE         9'd32
`define IASTORE         9'd39
`define FASTORE         9'd39
`define LASTORE         9'd46
`define DASTORE         9'd46

`define INVOKESTATIC_QUICK       9'd54
`define INVOKENONVIRTUAL_QUICK   9'd65
`define INVOKEVIRTUAL_QUICK      9'd78
`define INVOKEVIRTUAL_QUICK_W    9'd93
`define INVOKESUPER_QUICK        9'd112
 
`define RETURN	        9'd133
`define IRETURN	9'd141
`define FRETURN	9'd141
`define ARETURN	9'd141
`define LRETURN	9'd149
`define DRETURN	9'd149

`define CALL                     9'd157
`define RETURN0                  9'd160
`define RETURN1                  9'd164
`define RETURN2                  9'd168

`define TABLESWITCH              9'd173
`define CHECKCAST_QUICK          9'd185
`define INSTANCEOF_QUICK         9'd191
`define EXIT_SYNC_METHOD         9'd198
`define GET_CUR_CLASS            9'd201

`define DUP_X1           9'd204
`define DUP_X2           9'd207
`define DUP2             9'd211
`define DUP2_X1          9'd213
`define DUP2_X2          9'd218
`define SWAP             9'd224

`define LDC_QUICK              9'd226
`define LDC_W_QUICK            9'd227
`define LDC2_W_QUICK           9'd228
`define GET_FIELD_QUICK        9'd230
`define PUT_FIELD_QUICK        9'd234
`define GET_FIELD2_QUICK       9'd238
`define PUT_FIELD2_QUICK       9'd244
`define GET_STATIC_QUICK       9'd251
`define PUT_STATIC_QUICK       9'd254
`define GET_STATIC2_QUICK      9'd257
`define PUT_STATIC2_QUICK      9'd261
`define AGET_FIELD_QUICK       9'd230
`define APUT_FIELD_QUICK       9'd265
`define AGET_STATIC_QUICK      9'd251
`define APUT_STATIC_QUICK      9'd269
`define ALDC_QUICK             9'd226
`define ALDC_W_QUICK           9'd227

`define PRI_RET_FR_TRAP  9'd272
`define IU_TRAP          9'd280
`define AASTORE_QUICK    9'd285
`define MONITORENTER     9'd293

`define DEFAULT_ADDR   9'd0
