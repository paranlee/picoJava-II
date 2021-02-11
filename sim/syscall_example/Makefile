# Makefile for illustrating syscall feature in ias. 

CLASS_DIR = .
INCLUDE_DIR = -I.

# Location of ias build directory

# C section
CC = cc
CFLAGS = -g -G

#CC = gcc
#CFLAGS = -G
#CFLAGS = -fPIC -shared 

# Java language section
JAVAC = javac

all: pico_io hello    

hello:
	 $(JAVAC) hello.java

pico_io: pico_io.h
	 cpp -B -C -P $(INCLUDE_DIR) PicoIO.jasm > tmp.jasm; \
	 java javasoft.sqe.jasm.Main -d $(CLASS_DIR) tmp.jasm; \
	 /bin/rm -f tmp.jasm; \
	 $(CC) $(CFLAGS) $(DEBUG) $(INCLUDE_DIR) -I$(DSV_HOME)/include -o picoJava_io_lib.so.1 picoJava_io_lib.c   

clean: 
	 /bin/rm -f PicoIO.class hello.class picoJava_io_lib.so.1 
