#****************************************************************
#***
#***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
#***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
#***    The contents of this file are subject to the current
#***    version of the Sun Community Source License, picoJava-II
#***    Core ("the License").  You may not use this file except
#***    in compliance with the License.  You may obtain a copy
#***    of the License by searching for "Sun Community Source
#***    License" on the World Wide Web at http://www.sun.com.
#***    See the License for the rights, obligations, and
#***    limitations governing use of the contents of this file.
#***
#***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
#***    trademarks and logos, Java, picoJava, and all Java-based
#***    trademarks and logos are trademarks or registered trademarks
#***    of Sun Microsystems, Inc. in the United States and other
#***    countries.
#***
#*****************************************************************
#
proc quit {} {
exit
}

proc usage {} {
 puts "picoJava Instruction Accurate Simulator"
 puts "Initial rc file: .iasrc in the current directory "
 puts ""
 puts "Commands supported:"
 puts "bmemfile <filename> : load binary memory file (in .binit file format)"
 puts "brk \[list|exec|read|write|enable|disable|ignore\] ... : breakpoint commands "
 puts "checkpoint <filename> : store state of simulator to specified file"
 puts "configure : Show current core configuration"
 puts "configure icache \[0|1|2|4|8|16\] : Configure core by specifying icache size "
 puts "configure dcache \[0|1|2|4|8|16\] : Configure core by specifying dcache size "
 puts "configure fpu \[present|absent\] : Configure core by specifying if FPU is present"
 puts "cont : continue execution of a program from the current PC"
 puts "dis : print disassembled instructions starting from current PC"
 puts "dsTrap trapName len : disassemble a trap handler up to len bytes"
 puts "disAsmAddr address : disassemble at specified address "
 puts "disAsm className methodName : disassemble specified method "
 puts "ds addr len : disassemble from addr to addr + len"
 puts "dumpClass \[className\], default all : dump class structure"
 puts "dumpDcache \[line \[count\]\] : dump data cache from line"
 puts "dumpIcache \[line \[count\]\] : dump instruction cache from line"
 puts "dumpMethod className methodName : dump method structure"
 puts "dumpReg \[regName\], default all : dump registers"
 puts "dumpStack \[depth\], default 8 : dump stack contents from top of stack"
 puts "dumpStats <optional filename> : dump statistics" 

 puts "intr \[repeat|disable\] \[count\] \[irl\] : schedule/disable an interrupt"
 puts "itrace \[on|off|level\] : set tracing level (0-9), on = 3"
 puts "loadClass class1 class2 ...: load class files"
 puts "loadCache <path> : load state of D$ and I$ from files in the given path"
 puts "loadRT : load a standard subset of runtime classes"
 puts "loadElf objFile objFile...: load elf files"
 puts "memfile <filename>  : load memory file (like a .init file)"
 puts "memPeek address : Peek at the contents of the address, thru caches "
 puts "memPeekDirect address : Peek at the content of the address, bypassing caches "
 puts "memPoke address data : currently same as memPokeDirect "
 puts "memPokeDirect address data : Poke the memory into the address, bypassing caches"
 puts "memOR address data  : OR data value to the memory location"
 puts "profile create <id> : create a profile"
 puts "profile enable|disable <id> : enable/disable a profile"
 puts "profile freeze|unfreeze <id> : freeze/unfreeze a profile"
 puts "profile switch <id> : switch to a profile"
 puts "profile close <id>  : close a profile"
 puts "profile print <id>  : print a profile"
 puts "profile markenter   : mark an entry into a new block in the current profile"
 puts "profile markexit    : mark exit from the topmost block in the current profile"
 puts "profile list        : list status of all available profiles"
 puts "readMemory address length : display program memory (lookup caches)"
 puts "readMemoryDirect address length : display main memory (ignoring caches)"
 puts "reset : reset the processor"
 puts "restart <filename> : restore state of simulator from specified file"
 puts "run \[numOfSteps\], default non-stop : start to run from PC 0"
 puts "run2 target_pc : step and trace until target PC is reached"
 puts "s : single step, diassemble the next instruction and display registers "
 puts "scache \[on | off\]: Assume stack cache is present or absent"
 puts "set dumpFile <filename>, default stdout : re-direct output for dump* commands"
 puts "steps \[numOfSteps\], default 1 : continue to run numOfSteps"
 puts "usage : print out this message"
 puts "where : print out current register values and the next instruction"
 puts "writeMemory address value : write value (byte) into memory address"
}

proc dsTrap {name len} {
  global putstatic getstatic ldc ldc_w ldc2_w putfield getfield
  global getfield_quick_w putfield_quick_w
  global new anewarray newarray multianewarray 
  global invokestatic invokevirtual invokespecial invokeinterface
  global data_access_mem_error instruction_access_mem_error 
  global privileged_instruction illegal_instruction
  global breakpoint1 breakpoint2 mem_address_not_aligned data_access_io_error
  global instruction_access_io_error oplim_trap 
  global runtime_arithmetic runtime_indexoutofbnds runtime_nullptr 
  global lockcountoverflow lockentermiss lockrelease lockexitmiss
  global gc_notify lookupswitch 
  global nmi 
  global checkcast instanceof aastore athrow
  global checkcast_quick instanceof_quick 
  global new_quick anewarray_quick multianewarray_quick invokeinterface_quick
  global breakpoint soft_trap

  if { [string compare $name reset] == 0 } {
   ds 0 $len
  } elseif {[string compare $name invokestatic] == 0} {
   ds [memPeek $invokestatic] $len
  } elseif {[string compare $name putstatic] == 0} {
   ds [memPeek $putstatic] $len
  } elseif {[string compare $name getstatic] == 0} {
   ds [memPeek $getstatic] $len
  } elseif {[string compare $name ldc] == 0} {
   ds [memPeek $ldc] $len
  } elseif {[string compare $name ldc_w] == 0} {
   ds [memPeek $ldc_w] $len
  } elseif {[string compare $name ldc2_w] == 0} {
   ds [memPeek $ldc2_w] $len
  } elseif {[string compare $name putfield] == 0} {
   ds [memPeek $putfield] $len
  } elseif {[string compare $name getfield] == 0} {
   ds [memPeek $getfield] $len
  } elseif {[string compare $name new] == 0} {
   ds [memPeek $new] $len
  } elseif {[string compare $name newarray] == 0} {
   ds [memPeek $newarray] $len
  } elseif {[string compare $name anewarray] == 0} {
   ds [memPeek $anewarray] $len
  } elseif {[string compare $name invokevirtual] == 0} {
   ds [memPeek $invokevirtual] $len
  } elseif {[string compare $name invokespecial] == 0} {
   ds [memPeek $invokespecial] $len
  } elseif {[string compare $name invokeinterface] == 0} {
   ds [memPeek $invokeinterface] $len
  } elseif {[string compare $name data_access_mem_error] == 0} {
   ds [memPeek $data_access_mem_error] $len
  } elseif {[string compare $name instruction_access_mem_error] == 0} {
   ds [memPeek $instruction_access_mem_error] $len
  } elseif {[string compare $name privileged_instruction] == 0} {
   ds [memPeek $privileged_instruction] $len
  } elseif {[string compare $name illegal_instruction] == 0} {
   ds [memPeek $illegal_instruction] $len
  } elseif {[string compare $name breakpoint1] == 0} {
   ds [memPeek $breakpoint1] $len
  } elseif {[string compare $name breakpoint2] == 0} {
   ds [memPeek $breakpoint2] $len
  } elseif {[string compare $name mem_address_not_aligned] == 0} {
   ds [memPeek $mem_address_not_aligned] $len
  } elseif {[string compare $name data_access_io_error] == 0} {
   ds [memPeek $data_access_io_error] $len
  } elseif {[string compare $name instruction_access_io_error] == 0} {
   ds [memPeek $instruction_access_io_error] $len
  } elseif {[string compare $name oplim_trap] == 0} {
   ds [memPeek $oplim_trap] $len
  } elseif {[string compare $name runtime_arithmetic] == 0} {
   ds [memPeek $runtime_arithmetic] $len
  } elseif {[string compare $name runtime_indexoutofbnds] == 0} {
   ds [memPeek $runtime_indexoutofbnds] $len
  } elseif {[string compare $name runtime_nullptr] == 0} {
   ds [memPeek $runtime_nullptr] $len
  } elseif {[string compare $name lockcountoverflow] == 0} {
   ds [memPeek $lockcountoverflow] $len
  } elseif {[string compare $name lockrelease] == 0} {
   ds [memPeek $lockbusytrap] $len
  } elseif {[string compare $name lockentermiss] == 0} {
   ds [memPeek $lockbusytrap] $len
  } elseif {[string compare $name lockexitmiss] == 0} {
   ds [memPeek $lockbusytrap] $len
  } elseif {[string compare $name gc_notify] == 0} {
   ds [memPeek $gc_notify] $len
  } elseif {[string compare $name nmi] == 0} {
   ds [memPeek $nmi] $len
  } elseif {[string compare $name aastore] == 0} {
   ds [memPeek $aastore] $len
  } elseif {[string compare $name getfield_quick_w] == 0} {
   ds [memPeek $getfield_quick_w] $len
  } elseif {[string compare $name putfield_quick_w] == 0} {
   ds [memPeek $putfield_quick_w] $len
  } elseif {[string compare $name lookupswitch] == 0} {
   ds [memPeek $lookupswitch] $len
  } elseif {[string compare $name multianewarray] == 0} {
   ds [memPeek $multianewarray] $len
  } elseif {[string compare $name checkcast] == 0} {
   ds [memPeek $checkcast] $len
  } elseif {[string compare $name instanceof] == 0} {
   ds [memPeek $instanceof] $len
  } elseif {[string compare $name soft_trap] == 0} {
   ds [memPeek $soft_trap] $len
  } elseif {[string compare $name athrow] == 0} {
   ds [memPeek $athrow] $len
  } elseif {[string compare $name new_quick] == 0} {
   ds [memPeek $new_quick] $len
  } elseif {[string compare $name anewarray_quick] == 0} {
   ds [memPeek $anewarray_quick] $len
  } elseif {[string compare $name checkcast_quick] == 0} {
   ds [memPeek $checkcast_quick] $len
  } elseif {[string compare $name instanceof_quick] == 0} {
   ds [memPeek $instanceof_quick] $len
  } elseif {[string compare $name multianewarray_quick] == 0} {
   ds [memPeek $multianewarray_quick] $len
  } elseif {[string compare $name invokeinterface_quick] == 0} {
   ds [memPeek $invokeinterface_quick] $len
  } elseif {[string compare $name breakpoint] == 0} {
   ds [memPeek $breakpoint] $len

#  } elseif {[string compare $name XX] == 0} {
#   ds [memPeek $XX] $len
  } else {
   puts "Unknown or unloaded trap handler"
  }
}

proc ds {addr len} {
 disAsmAddr [format "0x%x" $addr] $len
}

proc dis {} {
 global pc
 disAsmAddr [format "0x%x" $pc] 30
}

proc where {} {
 global pc psr optop vars frame cp trapbase 
 puts [format "PC=%08x PSR=%08x Optop=%08x Vars=%08x Frame=%08x Constpool=%08X Trapbase=%08x" $pc $psr $optop $vars $frame $cp $trapbase]
 disAsmAddr [format "0x%x" $pc]
}

proc s {} {
 global pc psr optop vars oplim userrange trapbase id frame cp
 steps 1
 puts [format "Next instruction"]
 where
}

#
# memOR <address> <value>
#
proc memOR {addr value} {
    set oldvalue [memPeek $addr]
    set newvalue [expr $oldvalue | $value]
    memPoke $addr $newvalue
    return [format "0x%08x" $newvalue]
}

#
# run2 <target_pc>
#
proc run2 x {
    global pc

    while {$pc != $x} {
	steps 1
    }
}

# dispLV is not officially documented
proc dispLV {index} {
    global vars

    # Error checking
    if {$index < 0} return

    set AlignedVars [expr $vars & 0xfffffffc]
    set LocalVarAddr [expr $AlignedVars - ($index << 2)]
    if {$LocalVarAddr > 0} {
	set LocalVarValue [memPeek [format "0x%x" $LocalVarAddr]]
    }
    puts -nonewline "Addr: "
    puts -nonewline [format "0x%x" $LocalVarAddr]
    puts -nonewline ", Value: "
    puts [format "0x%x" $LocalVarValue]
}

proc loadRT {} {
#
# ias first looks for the class file under current directory, then it looks
# for it under $DSVHOME/class.
#
# WARNING: DO NOT CHANGE THE ORDER OF THESE FILES. THESE MUST BE THE SAME
# AS IN THE COSIM SCRIPTS (it, invokeonetest).

    loadClass java/lang/Float
    loadClass java/lang/Double
    loadClass java/lang/String
    loadClass java/util/Dictionary
    loadClass java/util/Hashtable
    loadClass java/util/HashtableEntry
    loadClass java/lang/Throwable
    loadClass java/lang/Exception
    loadClass java/lang/RuntimeException
    loadClass java/lang/NullPointerException
    loadClass java/lang/IndexOutOfBoundsException
    loadClass java/lang/ArrayIndexOutOfBoundsException
    loadClass java/lang/ArithmeticException
    loadClass java/lang/Error
    loadClass java/lang/LinkageError
    loadClass java/lang/NoClassDefFoundError
    loadClass java/lang/ClassCastException
    loadClass java/lang/NegativeArraySizeException
	loadClass java/lang/IncompatibleClassChangeError
	loadClass java/lang/NoSuchFieldError
	loadClass java/lang/NoSuchMethodError
	loadClass java/lang/IllegalAccessError
	loadClass java/lang/AbstractMethodError
	loadClass java/lang/UnsatisfiedLinkError
	loadClass java/lang/ArrayStoreException
}

# These functions are used to compare the simulation result
# sc_bottom_min
proc compareMemory {addr data} {
   global sc_bottom_min sc_bottom_max

   set addr [format "0x%08s" $addr]
   set data [format "0x%08s" $data]

   set ldata [memPeekDirect $addr]

   if { $ldata == $data } {
    # puts [format "memory address %08x EQUAL ias:%08x rtl:%08x" $addr $ldata $data]
   } else {
    puts [format " min:%08x max:%08x" $sc_bottom_min $sc_bottom_max]
    if { $addr >= ($sc_bottom_min - 256) && $addr <= ($sc_bottom_max + 4) } {
     # not real mismatch
     puts [format "Warning: memory address %08x, ias:%08x rtl:%08x" $addr $ldata $data]
    } else {
     puts [format "memory address %08x NOT EQUAL ias:%08x rtl:%08x" $addr $ldata $data]
    }
   }

   return
}

proc compareResults {result} {
# expanded for full global compare,
  global pc psr optop vars oplim userrange trapbase id frame cp
  global lockaddr0 lockaddr1 lockcount0 lockcount1 
  global global0 global1 global2 global3 userrange1 userrange2
  global brk1a brk2a brk12c gc_config versionid hcr
  global regName stackTop1 stackTop2 stackTop3 stackTop4 stackTop5 
  global not_count not_count_limit
  global cosimLocation smallCompareReg

  set current_pc $pc
  set numInst [lindex $result 29]
#  puts $result
#  puts [format "numinst = %d\n" $numInst]
  set i 1
  steps 1
  while { $i < $numInst } {
   ds $pc 1
   steps 1
   set i [expr $i + 1]
  }
  
  flush stdout

# if there is trap, no comparison
  set reg [lindex $result 0]
  if { [string compare $reg "00000000" ] == 0 } {
   return
  }
#  This causes expr command to overflow, do not use expr here

# now not ignoring top1..top5 if they were 'X' - ignoring
# them if they were a magic value deeddeed

  set top1 [lindex $result 24]
  if {[string compare $top1 "deeddeed"] != 0 } {
   set top1 [format "%08x" $stackTop1]
  }
  set top2 [lindex $result 25]
  if {[string compare $top2 "deeddeed"] != 0 } {
   set top2 [format "%08x" $stackTop2]
  }
  set top3 [lindex $result 26]
  if {[string compare $top3 "deeddeed"] != 0 } {
   set top3 [format "%08x" $stackTop3]
  }
  set top4 [lindex $result 27]
  if {[string compare $top4 "deeddeed"] != 0 } {
   set top4 [format "%08x" $stackTop4]
  }
  set top5 [lindex $result 28]
  if {[string compare $top5 "deeddeed"] != 0 } {
   set top5 [format "%08x" $stackTop5]
  }

  set localResult [list [format "%08x" $optop] \
                        [format "%08x" $vars] \
                        [format "%08x" $current_pc] \
                        [format "%08x" $psr] \
                        [format "%08x" $oplim] \
                        [format "%08x" $trapbase] \
                        [format "%08x" $frame] \
                        [format "%08x" $cp] \
                        [format "%08x" $lockaddr0] \
                        [format "%08x" $lockaddr1] \
                        [format "%08x" $lockcount0] \
                        [format "%08x" $lockcount1] \
                        [format "%08x" $global0] \
                        [format "%08x" $global1] \
                        [format "%08x" $global2] \
                        [format "%08x" $global3] \
                        [format "%08x" $userrange1] \
                        [format "%08x" $userrange2] \
                        [format "%08x" $brk1a] \
                        [format "%08x" $brk2a] \
                        [format "%08x" $brk12c] \
                        [format "%08x" $gc_config] \
                        [format "%08x" $versionid] \
                        [format "%08x" $hcr] \
                        $top1 $top2 $top3 $top4 $top5 \
                        [format "%08x" $numInst] \
                  ]

#  puts $localResult
#  puts $result
 
  set i 0
  set fullCompare [memPeekDirect $cosimLocation]
  if { $fullCompare == 0 }  { 
     puts "Warning: only small compare being done!"
  }
  foreach rtlReg $result {
   set reg [lindex $localResult $i]
   if { [string compare $reg $rtlReg ] == 0 } {
# matches, no need to worry further
    #puts [format "$regName($i) EQUAL ias:%08s rtl:%08s" $reg $rtlReg]
   } else {
# check if true mismatch
    set noCompare 0
    if { $fullCompare == 0 } {
     if { $smallCompareReg($i) == 0 } { set noCompare 1 }
    }

    if { $noCompare == 0 } {
# disable global comparison 
    if { (($i < 12) || ($i > 15)) } {    
# disable global comparison and also disable top1-5 comparison for benchmark runs
     puts [format "$regName($i) NOT EQUAL ias:%08s rtl:%08s" $reg $rtlReg]
     set not_count [expr $not_count + 1]
     if { $not_count > $not_count_limit } {
      puts [format "ERROR : Mismatches over the limit %d" $not_count_limit]
      quit
     }
    } else { 
     puts [format "Warning: $regName($i) ias:%08s rtl:%08s" $reg $rtlReg]
    }
   } else {
#     puts [format "Warning: $regName($i) ias:%08s rtl:%08s" $reg $rtlReg]
    }
   }
   set i [expr $i + 1]
  }
 return 
}

set dumpFile stdout

# for trap handlers
# (not interrupt handlers, exceptions)
set trapAddress 0x00010000

set data_access_mem_error [format "0x%08x" [expr $trapAddress | ( 0x03 << 3)]]
set instruction_access_mem_error [format "0x%08x" [expr $trapAddress | ( 0x04 << 3)]]
set privileged_instruction [format "0x%08x" [expr $trapAddress | ( 0x05 << 3)]]
set illegal_instruction [format "0x%08x" [expr $trapAddress | ( 0x06 << 3)]]
set breakpoint1 [format "0x%08x" [expr $trapAddress | ( 0x07 << 3)]]
set breakpoint2 [format "0x%08x" [expr $trapAddress | ( 0x08 << 3)]]
set mem_address_not_aligned [format "0x%08x" [expr $trapAddress | ( 0x09 << 3)]]
set data_access_io_error [format "0x%08x" [expr $trapAddress | ( 0x0A << 3)]]
set instruction_access_io_error [format "0x%08x" [expr $trapAddress | ( 0x0B << 3)]]
set oplim_trap [format "0x%08x" [expr $trapAddress | ( 0x0C << 3)]]

set runtime_arithmetic [format "0x%08x" [expr $trapAddress | ( 0x16 << 3)]]
set runtime_indexoutofbnds [format "0x%08x" [expr $trapAddress | ( 0x19 << 3)]]
set runtime_nullptr [format "0x%08x" [expr $trapAddress | ( 0x1b << 3)]]

set lockcountoverflow [format "0x%08x" [expr $trapAddress | ( 0x23 << 3)]]
set lockentermiss [format "0x%08x" [expr $trapAddress | ( 0x24 << 3)]]
set lockreleasetrap [format "0x%08x" [expr $trapAddress | ( 0x25 << 3)]]
set lockexitmiss [format "0x%08x" [expr $trapAddress | ( 0x26 << 3)]]

set gc_notify [format "0x%08x" [expr $trapAddress | ( 0x28 << 3)]]
set nmi [format "0x%08x" [expr $trapAddress | ( 0x30 << 3)]]

set ldc [format "0x%08x" [expr $trapAddress | ( 0x12 << 3)]]
set ldc_w [format "0x%08x" [expr $trapAddress | ( 0x13 << 3)]]
set ldc2_w [format "0x%08x" [expr $trapAddress | ( 0x14 << 3)]]
set getstatic [format "0x%08x" [expr $trapAddress | ( 0xb2 << 3)]]
set putstatic [format "0x%08x" [expr $trapAddress | ( 0xb3 << 3)]]
set getfield [format "0x%08x" [expr $trapAddress | ( 0xb4 << 3)]]
set putfield [format "0x%08x" [expr $trapAddress | ( 0xb5 << 3)]]
set invokevirtual [format "0x%08x" [expr $trapAddress | ( 0xb6 << 3)]]
set invokespecial [format "0x%08x" [expr $trapAddress | ( 0xb7 << 3)]]
set invokestatic [format "0x%08x" [expr $trapAddress | ( 0xb8 << 3)]]
set invokeinterface [format "0x%08x" [expr $trapAddress | ( 0xb9 << 3)]]
set new [format "0x%08x" [expr $trapAddress | ( 0xbb << 3)]]
set newarray [format "0x%08x" [expr $trapAddress | ( 0xbc << 3)]]
set anewarray [format "0x%08x" [expr $trapAddress | ( 0xbd << 3)]]
set multianewarray [format "0x%08x" [expr $trapAddress | ( 0xc5 << 3)]]
set getfield_quick_w [format "0x%08x" [expr $trapAddress | ( 0xe3 << 3)]]
set putfield_quick_w [format "0x%08x" [expr $trapAddress | ( 0xe4 << 3)]]
set lookupswitch [format "0x%08x" [expr $trapAddress | ( 0xab << 3)]]
set aastore [format "0x%08x" [expr $trapAddress | ( 0x53 << 3)]]
set checkcast [format "0x%08x" [expr $trapAddress | ( 0xc0 << 3)]]
set instanceof [format "0x%08x" [expr $trapAddress | ( 0xc1 << 3)]]
set soft_trap [format "0x%08x" [expr $trapAddress | ( 0x0d << 3)]]
set athrow [format "0x%08x" [expr $trapAddress | ( 0xbf << 3)]]
set new_quick [format "0x%08x" [expr $trapAddress | ( 0xdd << 3)]]
set anewarray_quick [format "0x%08x" [expr $trapAddress | ( 0xde << 3)]]
set checkcast_quick [format "0x%08x" [expr $trapAddress | ( 0xe0 << 3)]]
set instanceof_quick [format "0x%08x" [expr $trapAddress | ( 0xe1 << 3)]]
set multianewarray_quick [format "0x%08x" [expr $trapAddress | ( 0xdf << 3)]]
set invokeinterface_quick [format "0x%08x" [expr $trapAddress | ( 0xda << 3)]]
set breakpoint [format "0x%08x" [expr $trapAddress | ( 0xca << 3)]]

#set XX [format "0x%08x" [expr $trapAddress | ( 0xXX << 3)]]

# for cm init
set endLocation 0x0000fffc
memPoke $endLocation 1

set cosimLocation 0x0000ffe0

# for register id
set regName(0) optop
set regName(1) vars
set regName(2) pc
set regName(3) psr
set regName(4) oplim
set regName(5) trapbase
set regName(6) frame
set regName(7) cp
set regName(8) lockaddr0
set regName(9) lockaddr1
set regName(10) lockcount0
set regName(11) lockcount1
set regName(12) global0
set regName(13) global1
set regName(14) global2
set regName(15) global3
set regName(16) userrange1
set regName(17) userrange2
set regName(18) brk1a
set regName(19) brk2a
set regName(20) brk12c
set regName(21) gc_config
set regName(22) versionid
set regName(23) hcr
set regName(24) top1
set regName(25) top2
set regName(26) top3
set regName(27) top4
set regName(28) top5
set regName(29) numInst

# To compare or not to compare, during a small compare (1 = compare, 0 = don't)
# evthg is compared during a big compare
# small compare is only optop, vars, pc, top1-5
set smallCompareReg(0) 1
set smallCompareReg(1) 1
set smallCompareReg(2) 1
set smallCompareReg(3) 0
set smallCompareReg(4) 0
set smallCompareReg(5) 0
set smallCompareReg(6) 0
set smallCompareReg(7) 0
set smallCompareReg(8) 0
set smallCompareReg(9) 0
set smallCompareReg(10) 0
set smallCompareReg(11) 0
set smallCompareReg(12) 0
set smallCompareReg(13) 0
set smallCompareReg(14) 0
set smallCompareReg(15) 0
set smallCompareReg(16) 0
set smallCompareReg(17) 0
set smallCompareReg(18) 0
set smallCompareReg(19) 0
set smallCompareReg(20) 0
set smallCompareReg(21) 0
set smallCompareReg(22) 0
set smallCompareReg(23) 0
set smallCompareReg(24) 1
set smallCompareReg(25) 1
set smallCompareReg(26) 1
set smallCompareReg(27) 1
set smallCompareReg(28) 1
set smallCompareReg(29) 0

set not_count 0
set not_count_limit 128
