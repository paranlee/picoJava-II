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
                  ../rtl/hold_logic.v \
                } 

/* Define high level module name */ 
current_design {hold_logic}

first_design_list = current_design + find(-hierarchy design, "*")
 
second_design_list = {hold_logic}

dont_touch_list = first_design_list - second_design_list

set_dont_touch dont_touch_list

current_design {hold_logic}

/* set transition time of any cells or nets */
set_max_transition MAX_TRANSITION current_design

/* set operation conditions */
set_operating_conditions "WCCOM" -library TARLIB

/* set clock period and set don't touch of clock network */ 
create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}

/* add the default driving / loading condition */
set_drive DRIVE_OF_INV3 all_inputs()
set_load LOAD_20_INV all_outputs()

/* read in input delay and load, output delay and load constraint */
include constraint_hold_logic.con

set_dont_touch_network clk
set_drive DRIVE_STRENGTH_CLK {clk, reset_l, sin, sm}
set_input_delay -clock clk SET_INPUT_DELAY_CLK {clk, reset_l, sin, sm}
 
/* Optimization effort */
set_structure true
set_flatten false
group_path -name "pin" -critical_range PIN_GROUP -to all_outputs()
compile_ok_to_buffer_during_inplace_opt = false
compile_ignore_area_during_inplace_opt = true

sh date
compile -map_effort high
sh date

/* print out a report file for area and timing violations */
report_area > db/hold_logic_area.rpt
report_timing -path end -delay max -max_paths PATHS_END -nosplit > db/hold_logic_maxend.rpt
report_timing -path full -delay max -max_paths PATHS_FULL > db/hold_logic_maxtim.rpt
report_timing -path end -nets -delay max -max_paths PATHS_END -nosplit > db/hold_logic_violators.rpt
report_constraints -all_violators -verbose >> db/hold_logic_violators.rpt

/* write out the results */
write -f db -h -o db/hold_logic.db {hold_logic} 
write -f verilog -h -o db/hold_logic.vSyn {hold_logic} 

sh date
quit
