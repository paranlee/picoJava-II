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

read -f verilog { \
                  ../rtl/rcu_dpath.v \
                  ../rtl/rcu_ctl.v \
                  ../rtl/rcu.v \
		  ../../../rtl/spare.v \
                }

current_design {rcu};

first_design_list = current_design + find(-hierarchy design, "*")

second_design_list = {rcu_dpath, rf, cmp_we_32, rcu_ctl, \
                      decode_opcode, dest_decoder, optop_decoder, \
                      cmp_we_4, pri_encod_3, rcu}

dont_touch_list = first_design_list - second_design_list

set_dont_touch dont_touch_list

current_design {rcu}

create_clock clk -period PERIOD -waveform {0.0 FALLING_EDGE}
set_max_transition MAX_TRANSITION current_design
include constraint_rcu.con;
set_operating_conditions "WCCOM" -library TARLIB
uniquify

sh date
compile -map_effort high;
sh date
 
report_timing -path end -delay max -max_paths PATHS_FULL -nosplit > db/rcu_maxend.log
report_timing -path full -delay max -max_paths PATHS_FULL -nosplit > db/rcu_maxtim.log
report_area -nosplit > db/rcu_area.log
 
write -f db -h -o db/rcu.db rcu
write -f verilog -h -o db/rcu.vSyn rcu

sh date
quit
