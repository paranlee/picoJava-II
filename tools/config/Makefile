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



# site dependent macros 
VLOG = $(VLOG_PATH)

# Default settings
UNAME = solaris
LIB_DIR = $(DSVHOME)/lib
BIN_DIR = $(DSVHOME)/bin
ETC_DIR = $(DSVHOME)/etc
CLASS_DIR = $(DSVHOME)/class

# special CC include directory for makedepend 
TEST_ENV_INCLUDE = $(PICOJAVAHOME)/$(PROJECT)/sim/include
INCLUDE_DIR = -I.. -I$(DSVHOME)/include $(CCC_INCLUDE_DIR) -I$(TEST_ENV_INCLUDE)
GLOBAL_MACROS = $(TEST_ENV_INCLUDE)/macro.inc


DEPEND_FILE = .depend
# if you want to use gcc, use:
# gcc -export-dynamic if using gnu linker, or:
# gcc -Xlinker -E if using native linker (works at least for hpux)
CC= $(CC_NAME)
CCC=CC
LOCAL_CFLAGS =
LOCAL_CCFLAGS =
LOCAL_CPPFLAGS = 
# DEBUG = -g
# WARNING: Do not include compiler switches here which might introduce 
# non-ieee compliant FP options (e.g. -fast or -fns) since ias requires
# precise ieee compliance to model the picoJava FPU accurately
DEBUG = $(CC_FLAGS)
# DEBUG = -O -xchip=ultra -xarch=v8plusa

# overwrite the default settings
include ./Makefile.in

# macro replacement
INCL = $(EXPORT_INCLUDES:%.h=$(DSVHOME)/include/%.h)
BIN_SCRIPTS = $(SCRIPTS:%=$(BIN_DIR)/%)

CLASS_OBJ = $(JAVA_SRC:%.java=$(CLASS_DIR)/%.class)
CLASS_OBJ_FROM_JASM = $(JASM_SRC:%.jasm=$(CLASS_DIR)/%.class)
CLASS_OBJ_FROM_CODE = $(CODE_SRC:%.code=$(CLASS_DIR)/%.class)

ALL_SRC = $(BIN1_SRC) $(BIN2_SRC) $(BIN3_SRC) $(BIN4_SRC) \
          $(LIB1_SRC) $(LIB2_SRC) $(LIB3_SRC) $(LIB4_SRC)

BIN1_OBJ_TMP = $(BIN1_SRC:%.c=$(UNAME)/%.o)
BIN2_OBJ_TMP = $(BIN2_SRC:%.c=$(UNAME)/%.o)
BIN3_OBJ_TMP = $(BIN3_SRC:%.c=$(UNAME)/%.o)
BIN4_OBJ_TMP = $(BIN4_SRC:%.c=$(UNAME)/%.o)

BIN1_OBJ = $(BIN1_OBJ_TMP:%.C=$(UNAME)/%.o)
BIN2_OBJ = $(BIN2_OBJ_TMP:%.C=$(UNAME)/%.o)
BIN3_OBJ = $(BIN3_OBJ_TMP:%.C=$(UNAME)/%.o)
BIN4_OBJ = $(BIN4_OBJ_TMP:%.C=$(UNAME)/%.o)

BIN1_REAL = $(BIN1)
BIN2_REAL = $(BIN2)
BIN3_REAL = $(BIN3)
BIN4_REAL = $(BIN4)

BIN1_TARGET = $(BIN1_REAL:%=$(BIN_DIR)/%)
BIN2_TARGET = $(BIN2_REAL:%=$(BIN_DIR)/%)
BIN3_TARGET = $(BIN3_REAL:%=$(BIN_DIR)/%)
BIN4_TARGET = $(BIN4_REAL:%=$(BIN_DIR)/%)

LIB1_OBJ_TMP = $(LIB1_SRC:%.c=$(UNAME)/%.o)
LIB2_OBJ_TMP = $(LIB2_SRC:%.c=$(UNAME)/%.o)
LIB3_OBJ_TMP = $(LIB3_SRC:%.c=$(UNAME)/%.o)
LIB4_OBJ_TMP = $(LIB4_SRC:%.c=$(UNAME)/%.o)

LIB1_OBJ = $(LIB1_OBJ_TMP:%.C=$(UNAME)/%.o)
LIB2_OBJ = $(LIB2_OBJ_TMP:%.C=$(UNAME)/%.o)
LIB3_OBJ = $(LIB3_OBJ_TMP:%.C=$(UNAME)/%.o)
LIB4_OBJ = $(LIB4_OBJ_TMP:%.C=$(UNAME)/%.o)

LIB1_REAL = $(LIB1)
LIB2_REAL = $(LIB2)
LIB3_REAL = $(LIB3)
LIB4_REAL = $(LIB4)

LIB1_TARGET = $(LIB1_REAL:%=$(LIB_DIR)/%)
LIB2_TARGET = $(LIB2_REAL:%=$(LIB_DIR)/%)
LIB3_TARGET = $(LIB3_REAL:%=$(LIB_DIR)/%)
LIB4_TARGET = $(LIB4_REAL:%=$(LIB_DIR)/%)

# libraries to build executables
BIN1_LIBNAME = $(BIN1_LIB:-l%=$(LIB_DIR)/lib%.a)
BIN2_LIBNAME = $(BIN2_LIB:-l%=$(LIB_DIR)/lib%.a)
BIN3_LIBNAME = $(BIN3_LIB:-l%=$(LIB_DIR)/lib%.a)
BIN4_LIBNAME = $(BIN4_LIB:-l%=$(LIB_DIR)/lib%.a)

# etc files
ETC_TARGET1 = $(ETC1:%=$(ETC_DIR)/$(PACKAGE)/%)
ETC_TARGET2 = $(ETC2:%=$(ETC_DIR)/$(PACKAGE)/%)
ETC_TARGET3 = $(ETC3:%=$(ETC_DIR)/$(PACKAGE)/%)
ETC_TARGET4 = $(ETC4:%=$(ETC_DIR)/$(PACKAGE)/%)
ETC_TARGET5 = $(ETC5:%=$(ETC_DIR)/$(PACKAGE)/%)
ETC_TARGET6 = $(ETC6:%=$(ETC_DIR)/$(PACKAGE)/%)

# standard compiler flags
CFLAGS = $(DEBUG) -D$(UNAME) $(LOCAL_CFLAGS)
CCFLAGS = $(DEBUG) -D$(UNAME) $(LOCAL_CCFLAGS)
CPPFLAGS = $(INCLUDE_DIR) $(LOCAL_CPPFLAGS)
OUTPUT_OPTION =

COMPILE.c=$(CC) $(CFLAGS) $(CPPFLAGS) -c

$(UNAME)/%.o: %.c 
	cd $(UNAME); $(COMPILE.c) $(OUTPUT_OPTION) ../$< 

COMPILE.C=$(CCC) $(CCFLAGS) $(CPPFLAGS)  -c

$(UNAME)/%.o: %.C 
	cd $(UNAME); $(COMPILE.C) $(OUTPUT_OPTION) ../$<

# java language section
JAVAC = javac
JAVAP = javap
JAVAFLAGS =
COMPILE.java = $(JAVAC) $(JAVAFLAGS)
$(CLASS_DIR)/%.class: %.java
	$(COMPILE.java) -d $(CLASS_DIR) $<

# java com.sun.picojava.jasm.Main <filename>.jasm
$(CLASS_DIR)/%.class: %.jasm
	cd $(CLASS_DIR); \
	cpp -B -C -P $(INCLUDE_DIR) $(JAVA_DIR)/$< > tmp1; \
	cat $(GLOBAL_MACROS) tmp1 > tmp2; \
	grep -v '.compile_all' tmp2 > tmp1.m4; \
	m4 tmp1.m4 > tmp1.jasm; \
        java com.sun.picojava.jasm.Main -maya tmp1.jasm; \
        rm -f tmp1 tmp2 tmp1.m4 tmp1.jasm
 

# This is only used for basic tests
$(CLASS_DIR)/%.class: %.code
	cd $(CLASS_DIR); ../mk_test `basename ../$< .code`

install : makeDir libraries jasm java executables scripts examples etcs

makeDir :
	@if [ ! -d $(UNAME) ]; then mkdir -p  $(UNAME); fi;
	@if [ ! -d $(DSVHOME) ]; then mkdir -p  $(DSVHOME); fi;
	@if [ ! -d $(LIB_DIR) ]; then mkdir -p  $(LIB_DIR); fi;
	@if [ ! -d $(BIN_DIR) ]; then mkdir -p  $(BIN_DIR); fi;
	@if [ ! -d $(ETC_DIR) ]; then mkdir -p  $(ETC_DIR); fi;
	@if [ ! -d $(CLASS_DIR) ]; then mkdir -p  $(CLASS_DIR); fi;
	@if [ ! -d $(DSVHOME)/include ]; then mkdir -p  $(DSVHOME)/include; fi;

clean :
	rm -f $(DEPEND_FILE)
	rm -f $(UNAME)/*.o
	rm -f class/*.class

cleanclass :
	rm -rf $(CLASS_DIR)/*.class

java : $(CLASS_OBJ)

jasm : $(CLASS_OBJ_FROM_JASM) $(CLASS_OBJ_FROM_CODE)

libraries : lnincludes $(LIB1_TARGET) $(LIB2_TARGET) $(LIB3_TARGET) $(LIB4_TARGET)
 
executables : $(BIN1_TARGET) $(BIN2_TARGET) $(BIN3_TARGET) $(BIN4_TARGET)
 
scripts : $(BIN_SCRIPTS)

$(BIN_SCRIPTS) : $(SCRIPTS)
	rm -f $@; cp `basename $@` $(BIN_DIR)
 
#examples : $(DSVHOME)/examples/Makefile $(EXAMPLE_TARGET)

examples :
 
etcs : $(ETC_TARGET1) $(ETC_TARGET2) $(ETC_TARGET3) $(ETC_TARGET4) \
       $(ETC_TARGET5) $(ETC_TARGET6)

depend : $(DEPEND_FILE)

lnincludes : $(INCL)

$(INCL) :
	@F=`pwd`; \
        echo $@; \
        cd $(DSVHOME)/include; \
	rm -f $${d:=`basename $@`} ; \
	ln -s $$F/$${d:=`basename $@`}

$(BIN1_TARGET) : $(BIN1_OBJ) $(BIN1_LIBNAME)
	rm -f $@; $(LINK.c) -o $@ $(STATIC) $(BIN1_OBJ) -L$(LIB_DIR) $(BIN1_LIB) $(EXTRA_LIB)

$(BIN2_TARGET) : $(BIN2_OBJ) $(BIN2_LIBNAME)
	rm -f $@; $(LINK.c) -o $@ $(STATIC) $(BIN2_OBJ) -L$(LIB_DIR) $(BIN2_LIB) $(EXTRA_LIB)

$(BIN3_TARGET) : $(BIN3_OBJ) $(BIN3_LIBNAME)
	rm -f $@; $(LINK.c) -o $@ $(STATIC) $(BIN3_OBJ) -L$(LIB_DIR) $(BIN3_LIB) $(EXTRA_LIB)

$(BIN4_TARGET) : $(BIN4_OBJ) $(BIN4_LIBNAME)
	rm -f $@; $(LINK.c) -o $@ $(STATIC) $(BIN4_OBJ) -L$(LIB_DIR) $(BIN4_LIB) $(EXTRA_LIB)

$(LIB1_TARGET) : $(LIB1_OBJ) 
	rm -f $@; ar -r  $@ $(LIB1_OBJ)

$(LIB2_TARGET) : $(LIB2_OBJ) 
	rm -f $@; ar -r  $@ $(LIB2_OBJ)

$(LIB3_TARGET) : $(LIB3_OBJ) 
	rm -f $@; ar -r  $@ $(LIB3_OBJ)

$(LIB4_TARGET) : $(LIB4_OBJ) 
	rm -f $@; ar -r  $@ $(LIB4_OBJ)

$(ETC_TARGET1) : $(ETC1)
	@if [ ! -d $(ETC_DIR)/$(PACKAGE) ];then mkdir -p $(ETC_DIR)/$(PACKAGE); fi;
	rm -f $@; cp $(ETC1) $@

pure1: $(BIN1_OBJ)
	purify $(PURIFY_OPTION) $(CCC) -o $(BIN1) $(BIN1_OBJ)

pure2: $(BIN2_OBJ)
	purify $(PURIFY_OPTION) $(CCC) -o $(BIN2) $(BIN2_OBJ)

pure3: $(BIN3_OBJ)
	purify $(PURIFY_OPTION) $(CCC) -o $(BIN3) $(BIN3_OBJ)

pure4: $(BIN4_OBJ)
	purify $(PURIFY_OPTION) $(CCC) -o $(BIN4) $(BIN4_OBJ)

# include file dependencies
$(DEPEND_FILE) : $(ALL_SRC)
	@touch $@.tmp
	@makedepend $(CFLAGS) $(CPPFLAGS) -f $@.tmp $(ALL_SRC) 2>/dev/null
	@sed -e '3,$$s/^/$(UNAME)\//' $@.tmp > $@
	@rm -f $@.tmp $@.tmp.bak
 
include $(DEPEND_FILE)

