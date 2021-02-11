# ****************************************************************
# ***
# ***    Copyright 1999 Sun Microsystems, Inc., 901 San Antonio
# ***    Road, Palo Alto, CA 94303, U.S.A.  All Rights Reserved.
# ***    The contents of this file are subject to the current
# ***    version of the Sun Community Source License, picoJava-II
# ***    Core ("the License").  You may not use this file except
# ***    in compliance with the License.  You may obtain a copy
# ***    of the License by searching for "Sun Community Source
# ***    License" on the World Wide Web at http://www.sun.com.
# ***    See the License for the rights, obligations, and
# ***    limitations governing use of the contents of this file.
# ***
# ***    Sun, Sun Microsystems, the Sun logo, and all Sun-based
# ***    trademarks and logos, Java, picoJava, and all Java-based
# ***    trademarks and logos are trademarks or registered trademarks
# ***    of Sun Microsystems, Inc. in the United States and other
# ***    countries.
# *****************************************************************



DEFINES =

ias:
	(cd $(DSVHOME)/dsv/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/ldr/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/cache/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/iam/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/sim/src; $(MAKE) lnincludes; cd ../..)
	(cd dsv/src; $(MAKE) "LOCAL_CFLAGS = $(DEFINES)"; cd ../..)
	(cd ldr/src; $(MAKE) "LOCAL_CFLAGS = $(DEFINES)"; cd ../..)
	(cd cache/src; $(MAKE) clean; $(MAKE) "LOCAL_CFLAGS = $(DEFINES)"; cd ../..)
	(cd iam/src; $(MAKE) "LOCAL_CFLAGS = $(DEFINES)"; cd ../..)
	(cd sim/src; $(MAKE) "LOCAL_CFLAGS = $(DEFINES)"; cd ../..)

pj2vlog: 
	(cd $(DSVHOME)/dsv/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/ldr/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/tam/src; $(MAKE) lnincludes; cd ../..)
	(cd dsv/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)
	(cd ldr/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)
	(cd tam/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)
	(cd verilog/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)

pj2vcs:
	(cd $(DSVHOME)/dsv/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/ldr/src; $(MAKE) lnincludes; cd ../..)
	(cd $(DSVHOME)/tam/src; $(MAKE) lnincludes; cd ../..)
	(cd dsv/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)
	(cd ldr/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)
	(cd tam/src; $(MAKE) "LOCAL_FLAGS = $(DEFINES)"; cd ../..)
	(cd bin; vcsc)

clean:
	(cd dsv/src; $(MAKE) clean; cd ../..)
	(cd ldr/src; $(MAKE) clean; cd ../..)
	(cd cache/src; $(MAKE) clean; cd ../..)
	(cd iam/src; $(MAKE) clean; cd ../..)
	(cd sim/src; $(MAKE) clean; cd ../..)
	(cd tam/src; $(MAKE) clean; cd ../..)
	(cd verilog/src; $(MAKE) clean; cd ../..)

realclean: clean
	($(RM) bin/pj2vlog bin/pj2vcs bin/ias lib/libcache.a lib/libiam.a lib/libloader.a lib/libtamv.a)
