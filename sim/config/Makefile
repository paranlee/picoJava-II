# Makefile for all

# site dependent macros
VLOG = $(VLOG_PATH)
UNAME = solaris

# Default settings
LIB_DIR = $(DSVHOME)/lib
BIN_DIR = $(DSVHOME)/bin
ETC_DIR = $(DSVHOME)/etc
CLASS_DIR = $(DSVHOME)/class
JAVA_DIR = $(DSVHOME)/java

DEPEND_FILE = .depend
CC = $(CC_NAME)
CCC=CC
LOCAL_CFLAGS =
LOCAL_CCFLAGS =
LOCAL_CPPFLAGS = 
DEBUG = $(CC_FLAGS)

TEST_ENV_INCLUDE = $(PICOJAVAHOME)/$(PROJECT)/sim/include

# INCLUDE_DIR = -I.. -I$(DSVHOME)/include
INCLUDE_DIR = -I.. -I$(DSVHOME)/include -I$(TEST_ENV_INCLUDE)

install : makeDir depend libraries java executables scripts examples etcs

# overwrite the default settings
include ./Makefile.in

# macros for the MakeTest procedure...
RESET_CODE = $(TEST_ENV_INCLUDE)/reset.code
GLOBAL_MACROS = $(TEST_ENV_INCLUDE)/macro.inc
LOCAL_MACROS = $(PWD)/test_config.inc
MAKETEST_ARGS = `basename ../$< .code` $(GLOBAL_MACROS) $(LOCAL_MACROS) $(RESET_CODE)

# macro replacement
INCL = $(EXPORT_INCLUDES:%.h=$(DSVHOME)/include/%.h)

CLASS_OBJ = $(JAVA_SRC:%.java=$(CLASS_DIR)/%.class)
CLASS_OBJ_FROM_JASM = $(JASM_SRC:%.jasm=$(CLASS_DIR)/%.class)
CLASS_OBJ_FROM_CODE = $(CODE_SRC:%.code=$(CLASS_DIR)/%.class)
INIT_MEM_FROM_CODE = $(INIT_SRC:%.init=$(CLASS_DIR)/%.init)
CLASS_OBJ_FROM_M4 = $(M4_SRC:%.m4=$(CLASS_DIR)/%.class)

# special process for random failure tests: compile tmp1.m4 to class
COMPILE_TMP1_M4_TO_CLASS = \
         m4 tmp1.m4 > $(CLASS_DIR)/tmp1.jasm; \
         rm -f tmp1.m4; \
         cd $(CLASS_DIR); \
         java com.sun.picojava.jasm.Main -maya tmp1.jasm; \
         rm -f tmp1.jasm

ALL_SRC = $(BIN1_SRC) $(BIN2_SRC) $(BIN3_SRC) $(BIN4_SRC) \
          $(LIB1_SRC) $(LIB2_SRC) $(LIB3_SRC) $(LIB4_SRC)

BIN1_OBJ = $(BIN1_SRC:%.c=$(UNAME)/%.o)
BIN2_OBJ = $(BIN2_SRC:%.c=$(UNAME)/%.o)
BIN3_OBJ = $(BIN3_SRC:%.c=$(UNAME)/%.o)
BIN4_OBJ = $(BIN4_SRC:%.c=$(UNAME)/%.o)

BIN1_REAL = $(BIN1)
BIN2_REAL = $(BIN2)
BIN3_REAL = $(BIN3)
BIN4_REAL = $(BIN4)

BIN1_TARGET = $(BIN1_REAL:%=$(BIN_DIR)/%)
BIN2_TARGET = $(BIN2_REAL:%=$(BIN_DIR)/%)
BIN3_TARGET = $(BIN3_REAL:%=$(BIN_DIR)/%)
BIN4_TARGET = $(BIN4_REAL:%=$(BIN_DIR)/%)

LIB1_OBJ = $(LIB1_SRC:%.c=$(UNAME)/%.o)
LIB2_OBJ = $(LIB2_SRC:%.c=$(UNAME)/%.o)
LIB3_OBJ = $(LIB3_SRC:%.c=$(UNAME)/%.o)
LIB4_OBJ = $(LIB4_SRC:%.c=$(UNAME)/%.o)

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


# random.class

# jasm -> class file
$(CLASS_DIR)/%.class: %.jasm
	cd $(CLASS_DIR); \
	cpp -B -C -P $(INCLUDE_DIR) $(JAVA_DIR)/$< > tmp1; \
	cat $(GLOBAL_MACROS) tmp1 > tmp2; \
	grep -v '.compile_all' tmp2 > tmp1.m4; \
	m4 tmp1.m4 > tmp1.jasm; \
        java com.sun.picojava.jasm.Main -maya tmp1.jasm; \
        rm -f tmp1 tmp2 tmp1.m4 tmp1.jasm

# m4 -> jasm -> class file
$(CLASS_DIR)/%.class: %.m4
	cpp -B -C -P $(INCLUDE_DIR) $< > tmp1.m4; \
	m4 tmp1.m4 > $(CLASS_DIR)/tmp1.jasm; \
	rm -f tmp1.m4; \
	cd $(CLASS_DIR); \
        java com.sun.picojava.jasm.Main -maya tmp1.jasm; \
        rm -f tmp1.jasm

# This is only used for basic tests
$(CLASS_DIR)/%.init: %.init
	cp $< $(CLASS_DIR)/$<

# $(CLASS_DIR)/%.class: %.code $(RESET_CODE) $(GLOBAL_MACROS)
$(CLASS_DIR)/%.class: %.code $(RESET_CODE) $(GLOBAL_MACROS) $(LOCAL_MACROS)
	cd $(CLASS_DIR); $(TEST_ENV_INCLUDE)/MakeTest $(MAKETEST_ARGS)

makeDir :
	@if [ ! -d $(UNAME) ]; then mkdir $(UNAME); fi;
	@if [ ! -d $(DSVHOME) ]; then mkdir $(DSVHOME); fi;
	@if [ ! -d $(LIB_DIR) ]; then mkdir $(LIB_DIR); fi;
	@if [ ! -d $(BIN_DIR) ]; then mkdir $(BIN_DIR); fi;
	@if [ ! -d $(JAVA_DIR) ]; then mkdir $(JAVA_DIR); fi;
	@if [ ! -d $(CLASS_DIR) ]; then mkdir $(CLASS_DIR); fi;
	@if [ ! -d $(DSVHOME)/include ]; then mkdir $(DSVHOME)/include; fi;

clean :
	rm -rf $(UNAME)

cleanclass :
	rm -rf $(CLASS_DIR)/*.class

java : $(CLASS_OBJ) $(CLASS_OBJ_FROM_JASM) $(CLASS_OBJ_FROM_CODE) $(INIT_MEM_FROM_CODE) $(CLASS_OBJ_FROM_M4) $(CLASS_OBJ_FOR_RANDOM_FAILURE)

libraries : lnincludes $(LIB1_TARGET) $(LIB2_TARGET) $(LIB3_TARGET) $(LIB4_TARGET)
 
executables : $(BIN1_TARGET) $(BIN2_TARGET) $(BIN3_TARGET) $(BIN4_TARGET)
 
scripts : $(BIN_SCRIPT1) $(BIN_SCRIPT2) $(BIN_SCRIPT3) $(BIN_SCRIPT4)
 
#examples : $(DSVHOME)/examples/Makefile $(EXAMPLE_TARGET)

examples :
 
etcs : $(ETC_TARGET1) $(ETC_TARGET2) $(ETC_TARGET3) $(ETC_TARGET4) \
       $(ETC_TARGET5) $(ETC_TARGET6)

depend : $(DEPEND_FILE)

lnincludes : $(INCL)

$(INCL) :
	@F=$(PWD); \
        echo $@; \
        cd $(DSVHOME)/include; \
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
	@if [ ! -d $(ETC_DIR)/$(PACKAGE) ];then mkdir $(ETC_DIR)/$(PACKAGE); fi;
	rm -f $@; cp $(ETC1) $@

# include file dependencies
# include file dependencies
$(DEPEND_FILE) : $(ALL_SRC)
	@touch $@.tmp
	@makedepend $(CFLAGS) $(CPPFLAGS) -f $@.tmp $(ALL_SRC)
	@sed -e '3,$$s/^/$(UNAME)\//' $@.tmp > $@
	@rm $@.tmp $@.tmp.bak
 
include $(DEPEND_FILE)

