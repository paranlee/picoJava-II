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




 sh date

include ../../../lib_setup/mj_synopsys.setup
/* Read in corresponding verilog files to be synthesised */
read -f verilog { \
                  ../rtl/ucode.h \
                  ../rtl/ucode_dat.v \
                  ../rtl/ucode_seq.v \
                  ../rtl/ucode_dec.v \
                  ../rtl/ieu_rom.v \
                  ../rtl/ucode_lib_jet.v \
                  ../rtl/ucode_reg.v \
                  ../rtl/ucode_ind.v \
                  ../rtl/ucode_dpath.v \
                  ../rtl/ucode_ctrl.v \
                  ../rtl/ucode.v \
		  ../../../rtl/spare.v \
                } 

current_design {ucode}

first_design_list = current_design + find(-hierarchy design, "*")

second_design_list = {buf_rs1, buf_a_oprd, ucode_dat, ucode_seq,\
                      ucode_dec, ucode_add, ieu_rom, inv_d_1, \
                      inv_e_1, inv_f_1, inv_a_32, inv_b_32, \
                      inv_c_32, inv_d_32, inv_e_32, inv_f_32, \
                      nand2_a_32, an2_a_e_32, mx3_1, mx3_9, \
                      branch_bit, mux_ialu_b, ucode_reg, ucode_ind \
                      ucode_dpath, ucode_ctrl, ucode, inv_b_1 \
                      }

dont_touch_list = first_design_list - second_design_list

set_dont_touch dont_touch_list

current_design {ucode}

/* Set uniquify name style */ 
uniquify_naming_style = "%s_ucode_%d"

/* set transition time of any cells or nets */
set_max_transition MAX_TRANSITION current_design

/* set operation conditions */
set_operating_conditions "WCCOM" -library TARLIB

/* set clock period and set don't touch of clock network */ 
create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}

/* add default loading / drive */
set_drive DRIVE_OF_INV1 all_inputs()
set_load LOAD_10_INV all_outputs()

/* read in input delay and load, output delay and load constraint */
include constraint_ucode.con

set_dont_touch_network clk
set_drive DRIVE_STRENGTH_CLK {clk, reset_l, sin, sm}
set_input_delay -clock clk SET_INPUT_DELAY_CLK {clk, reset_l, sin, sm}
 
/* Optimization effort */
set_structure true
set_flatten false
group_path -name "pin" -critical_range PIN_GROUP -to all_outputs()
compile_ok_to_buffer_during_inplace_opt = false
compile_ignore_area_during_inplace_opt = true

/* Force synthesis to uniquify all the design cells */
uniquify

sh date
compile -map_effort high 
sh date

/* print out a report file for area and timing violations */

report_area > db/ucode_area.rpt
report_timing -path end -delay max -max_paths PATHS_END -nosplit > db/ucode_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL > db/ucode_maxtim.rpt
report_timing -path end -nets -delay max -max_paths PATHS_END -nosplit > db/ucode_violators.rpt
report_constraints -all_violators -verbose >> db/ucode_violators.rpt

write -f db -h -o db/ucode.db {ucode} 
write -f verilog -h -o db/ucode.vSyn {ucode} 

sh date
quit
