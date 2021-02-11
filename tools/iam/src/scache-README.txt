/****************************************************************
 ***
 ***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
 ***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
 ***    The contents of this file are subject to the current
 ***    version of the Sun Community Source License, picoJava-II
 ***    Core ("the License").  You may not use this file except
 ***    in compliance with the License.  You may obtain a copy
 ***    of the License by searching for "Sun Community Source
 ***    License" on the World Wide Web at http://www.sun.com.
 ***    See the License for the rights, obligations, and
 ***    limitations governing use of the contents of this file.
 ***
 ***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 *****************************************************************/




Operation of the S$:

the stack cache is a 64 entry register file which caches the 
top few entries of the operand stack.

a few things must be true at ALL times about the S$, both in the
RTL, and in the model of the S$ in the IAS:

1) all memory accesses generated as offsets from OPTOP, VARS or FRAME
are stack accesses - they should first check if the needed location
exists in the S$. all other memory accesses do not go thru the S$, and
go directly to the D$. 
the condition for deciding whether an address is a hit in S$
is (address in the interval (OPTOP-4words, SC_BOTTOM)). 

in the context of IAS, all accesses of type 'O', 'F', or 'V' must go
thru the scache. in addition accesses of type 'G' are debug accesses,
which should also always go thru the S$.

2) memory accesses generated as offsets from OPTOP must ALWAYS hit the
S$, except for accesses from microcode, as noted below.  IAS (and the
RTL) work on the assumption that at all times, the locations
corresponding to the 4 top words in the stack, and the 2 empty words
above ToS are present in the S$. accesses to these locations are
assumed to directly hit in the S$ without the need for a hit/miss
detect. therefore OPTOP offsets are always between 4 and -1, inclusive.  

the dribbling mechanism ensures that the above restriction is always
enforced - in the case of the IAS by the routine vUpdateSCache which
must be called *every* time optop is updated (therefore the *only* way
to update optop must be thru vUpdateGR in global_regs.c - never update
optop anywhere else), and in the case of the RTL by the SMU holding
the pipe whenever this condition is false, until it becomes true (it
will, eventually, due to the dribbling operation). in the IAS, the
dribble required to satisfy this condition happens "instantaneously",
following the instruction which invalidated this condition. however,
in the RTL, this dribble is processed in the background, which can
lead to possible mismatches in the cache state between the IAS and the
RTL. this can't be helped. however, the program visible memory state
between the RTL and the IAS must always be consistent.

aside: an access which is not guaranteed to hit in the S$ (such as an
offset from VARS) performs a (single) lookup in parallel and does not
need an extra cycle in the RTL.

3) the correct satisfaction of the above condition can only happen
when the dribbler is enabled (PSR.DRE = 1). if the dribbler 
is disabled, the SMU never holds the pipe, and the requirement of 4-62
entries in the S$ is not met, nor is the S$ underflow/overflow operation 
handled correctly. operations therefore could potentially
operate on wrong data. the programmer is completely responsible anytime
the dribbler is switched off (including during the reset code, till
PSR.DRE is switched on) - the S$ operation is not transparent to
the program during this time. therefore the dribbler is not just a performance
feature which can be switched off - it's required to be on for correct
program behaviour, unless of course the program understands S$ behaviour
and knows what it's doing.

4) an address which is a hit in the S$ is always stored at the entry
in the S$ corresponding to the 6 LSBs of the address.

5) as documented in the spec, the fill_mark should never be set to 0. setting
it to 0 could cause incorrect program behaviour. if it is set to 0 with the 
dribbler enabled, ias will detect this condition and abort immediately. 

6) the word pointed to by SC_BOTTOM is considered present in the S$.

--

Usage:

the commands 'scache on/off' and 'cache on/off' control the enabling of
the S$ and D$+I$ respectively inside IAS. these can be enabled/disabled
independently of each other. the default is scache on/dcache off.

the scache operation can be disabled completely in ias by setting
'scache off' . this makes instructions operate directly on the program
stack in memory (thru dcache if enabled).

