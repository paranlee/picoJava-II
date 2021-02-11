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




 sh ln -s ../rtl/defines.h

/* Set up the library files */
include ../lib_setup/mj_synopsys.setup

read -f db { \
             ../dcu/syn/db/dcu.db \
             ../dcram/syn/db/dcram_shell.db \
             ../dtag/syn/db/dtag_shell.db \
             ../icu/syn/db/icu.db \
             ../icram/syn/db/icram_shell.db \
             ../itag/syn/db/itag_shell.db \
             ../vsu/syn/db/smu.db \
             ../pcsu/syn/db/pcsu.db \
             ../fpu/syn/db/fpu.db \
             ../iu/syn/db/iu.db \
           }

read -f verilog { ../rtl/cpu.v }

current_design {cpu} 

create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}

/* Set don't touch for each individule module */
set_dont_touch {iu, icu, icram_shell, itag_shell, dcu, dcram_shell, \
                dtag_shell, smu, pcsu, fpu}

include constraint_cpu.con 
set_operating_conditions "WCCOM" -library TARLIB

set_dont_touch_network clk
set_drive DRIVE_STRENGTH_CLK {clk, reset_l, sin, sm}
set_input_delay -clock clk SET_INPUT_DELAY_CLK {clk, reset_l, sin, sm}
 
link

set_disable_timing reset_l*
set_disable_timing iu/ex/ex_imdr/imdr_dpath_0/mx2_compl_32_a/inp1[*]
set_disable_timing iu/ex/ex_imdr/imdr_dpath_0/mx2i_32_a/inp1[*]
set_disable_timing iu/ex/ex_imdr/imdr_dpath_0/mx4_clr_reg_nxt_32_bb/nxt_out[*]

set_false_path 	-through {iu/ucode/rs1[*]} \
		-through {iu/ucode/ialu_a[*]} \
		-through {iu/rcu/rcu_dpath/mux_dest_addr_e/out[*]}

set_false_path  -through {iu/ucode/ucode_dpath_0/ucode_dat_0/buf_a_oprd_0/a_oprd_i[*]} \
 		-through {iu/ucode/ialu_a[*]} \ 
 		-through {iu/rcu/rcu_dpath/mux_dest_addr_e/out[*]}

set_false_path  -through {iu/ucode/rs1[*]} \
		-through {iu/ucode/ucode_portb[*]} \
		-through {iu/rcu/rcu_dpath/mux_dest_addr_e/out[*]}

set_false_path  -through {iu/ucode/rs1[*] iu/ucode/rs2[*] iu/ucode/rs1_0_l iu/ucode/rs2_0_l} \
		-through {iu/ucode/ialu_a[*]} \
		-through {iu/rcu/rcu_dpath/mux_dest_addr_e/out[*]} 
		
set_false_path  -through {iu/ex/ex_dpath/rs1_bypass_mux/out*} \
                -through {iu/ucode/ucode_dpath_0/ucode_dat_0/mux6_m_adder_porta/mx_out*}		
                
set_false_path  -through {iu/ex/ex_dpath/rs1_bypass_mux/out*} \
                -through {iu/ucode/ucode_dpath_0/ucode_dat_0/mux8_m_adder_portb/mx_out*}
                
set_false_path  -through {iu/ex/ex_dpath/rs1_bypass_mux/out* iu/ex/ex_dpath/rs2_bypass_mux/out*} \
                -through {iu/ucode/ucode_dpath_0/ucode_dat_0/buf_a_oprd_0/ucode_porta*} \
                -through {iu/ex/ex_regs/la0_cmp/eq* iu/ex/ex_regs/la1_cmp/eq*}
                
set_false_path  -through {iu/ex/ex_dpath/rs2_bypass_mux/out[*]} \
                -through {iu/ucode/ialu_a[*]} \
                -through {iu/ex/ex_dpath/dpath_adder/in1[*]}
               
set_false_path  -through {iu/ex/ex_dpath/rs1_bypass_mux/out* iu/ex/ex_dpath/rs2_bypass_mux/out*} \
                -through {iu/ucode/ucode_dpath_0/ucode_dat_0/buf_a_oprd_0/ucode_porta*} \
                -through {iu/ex/ex_dpath/cmp_porta_mux/out*} \
                -through {iu/ex/ex_ctl/branch_logic/iu_inst*}
                
set_false_path  -through {iu/ucode/ucode_dpath_0/ucode_dat_0/buf_a_oprd_0/a_oprd_i[*]} \
                -through {iu/ex/adder_out_e[*]} \
                -through {iu/rcu/rcu_dpath/mux_dest_addr_e/out[*]}
                
set_false_path  -through {iu/ex/ex_dpath/monitorenter_e} \
	        -through {iu/ex/ex_dpath/iu_addr_e[*]}   
	       
set_false_path  -through {iu/ucode/rs1_0_l iu/ucode/rs2_0_l iu/ucode/rs1[*] iu/ucode/rs2[*]} \
		-through {iu/ucode/ie_alu_cryout} \
		-through {iu/ucode/ucode_ctrl_0/ucode_seq_0/ie_alu_cryout}	       
		

report_area > db/cpu_area.rpt
report_timing -path end -delay max -max_paths PATHS_END -nosplit > db/cpu_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL > db/cpu_maxtim.rpt
report_timing -path end -nets -delay max -max_paths PATHS_END -nosplit > db/cpu_violators.rpt
report_constraints -all_violators -verbose >> db/cpu_violators.rpt

write -f db -h -o db/cpu.db {cpu}
write -f verilog -h -o db/cpu.vSyn {cpu}

sh rm defines.h

exit
