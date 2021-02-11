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

 ***   Sun, Sun Microsystems, the Sun logo, and all Sun-based
 ***    trademarks and logos, Java, picoJava, and all Java-based
 ***    trademarks and logos are trademarks or registered trademarks
 ***    of Sun Microsystems, Inc. in the United States and other
 ***    countries.
 *****************************************************************/




#ifndef _TRAPTYPES_H_
#define _TRAPTYPES_H_

#pragma ident "@(#)traptypes.h 1.2 Last modified 10/06/98 11:34:22 SMI"

 /* define the trap table */
#define NUM_OF_TRAPS 256

#define POWERON_RESET			0x0
#define ASYNC_ERROR			0x1
#define MEM_PROTECTION_ERROR            0x2
#define DATA_ACCESS_MEM_ERROR		0x3
#define INSTRUCTION_ACCESS_MEM_ERROR	0x4
#define PRIVILEGED_INSTRUCTION 		0x5
#define ILLEGAL_INSTRUCTION 		0x6
#define BREAKPOINT1 			0x7
#define BREAKPOINT2 			0x8
#define MEM_ADDRESS_NOT_ALIGNED		0x9
#define DATA_ACCESS_IO_ERROR		0xa
#define INSTRUCTION_ACCESS_IO_ERROR	0xb
#define OPLIM_TRAP			0xc
#define SOFT_TRAP			0xd

/* No traps from 0xD to 0x11 */

#define LDC				0x12
#define LDC_W				0x13
#define LDC2_W				0x14

/* Nop trap for 0x15 */

#define RUNTIME_ARITHMETIC		0x16
#define RUNTIME_CLASSCAST		0x17
#define RUNTIME_ILLEGALMONITORSTATE	0x18
#define RUNTIME_INDEXOUTOFBNDS		0x19
#define RUNTIME_NEGARRAYSIZE		0x1A
#define RUNTIME_NULLPTR			0x1B
#define RUNTIME_SECURITY		0x1C
#define RUNTIME_ARRAYSTORE		0x1D
#define MEM_PROTECTION_FAULT		0x1E
#define VM_STACKOVERFLOW		0x1F
#define VM_UNKNOWNERROR			0x20
#define VM_OUTOFMEMORYERROR		0x21
#define VM_INTERNALERROR		0x22
#define LOCKCOUNTOVERFLOW		0x23
#define LOCKENTERMISSTRAP		0x24
#define LOCKRELEASETRAP			0x25
#define LOCKEXITMISSTRAP		0x26
#define GC_NOTIFY			0x27
#define GC_TAG_TRAP			0x28
#define ZEROLINETRAP			0x29

/* No trap for 0x29 */

#define NMI				0x30 
#define IRL1				0x31
#define IRL2				0x32
#define IRL3				0x33
#define IRL4				0x34
#define IRL5				0x35
#define IRL6				0x36
#define IRL7				0x37
#define IRL8				0x38
#define IRL9				0x39
#define IRL10				0x3a
#define IRL11				0x3b
#define IRL12				0x3c
#define IRL13				0x3d
#define IRL14				0x3e
#define IRL15				0x3f

#define AASTORE				0x53
#define FADD				0x62
#define DADD				0x63
#define FSUB				0x66
#define DSUB				0x67
#define FMUL				0x6a
#define DMUL				0x6b
#define FDIV				0x6e
#define DDIV				0x6f
#define FREM				0x72
#define DREM_				0x73
#define I2F				0x86
#define I2D				0x87
#define L2F				0x89
#define L2D				0x8a
#define F2I				0x8b
#define F2L				0x8c
#define D2I				0x8e
#define F2D				0x8d
#define D2L				0x8f
#define D2F				0x90
#define FCMPL				0x95
#define FCMPG				0x96
#define DCMPL				0x97
#define DCMPG				0x98

#define LMUL				0x69
#define LDIV				0x6d
#define LREM				0x71

#define LOOKUPSWITCH			0xab
#define GETSTATIC			0xb2
#define PUTSTATIC			0xb3
#define GETFIELD			0xb4
#define PUTFIELD			0xb5
#define NEW				0xbb
#define NEWARRAY			0xbc
#define ANEWARRAY			0xbd
#define CHECKCAST			0xc0
#define INSTANCEOF			0xc1
#define WIDE				0xc4
#define MULTIANEWARRAY                  0xc5
#define BREAKPOINT			0xca
#define NEW_QUICK			0xdd
#define INVOKEVIRTUAL			0xb6
#define INVOKESPECIAL   		0xb7
#define INVOKESTATIC			0xb8
#define INVOKEINTERFACE 		0xb9
#define ATHROW				0xbf
#define INVOKEINTERFACE_QUICK		0xda
#define NEW_QUICK			0xdd
#define ANEWARRAY_QUICK			0xde
#define MULTIANEWARRAY_QUICK		0xdf
#define CHECKCAST_QUICK			0xe0
#define INSTANCEOF_QUICK		0xe1
#define GETFIELD_QUICK_W		0xe3
#define PUTFIELD_QUICK_W		0xe4

#define UNIMPLEMENTED_INSTR_0 		0xba
#define UNIMPLEMENTED_INSTR_1		0xdb
#define UNIMPLEMENTED_INSTR_2		0xdc
#define UNIMPLEMENTED_INSTR_3		0xee
#define UNIMPLEMENTED_INSTR_4		0xef
#define UNIMPLEMENTED_INSTR_5		0xf0
#define UNIMPLEMENTED_INSTR_6		0xf1
#define UNIMPLEMENTED_INSTR_7		0xf2
#define UNIMPLEMENTED_INSTR_8		0xf3
#define UNIMPLEMENTED_INSTR_9		0xf4
#define UNIMPLEMENTED_INSTR_10		0xf5
#define UNIMPLEMENTED_INSTR_11		0xf6
#define UNIMPLEMENTED_INSTR_12		0xf7
#define UNIMPLEMENTED_INSTR_13		0xf8
#define UNIMPLEMENTED_INSTR_14		0xf9
#define UNIMPLEMENTED_INSTR_15		0xfa
#define UNIMPLEMENTED_INSTR_16		0xfb
#define UNIMPLEMENTED_INSTR_17		0xfc
#define UNIMPLEMENTED_INSTR_18		0xfd
#define UNIMPLEMENTED_INSTR_19		0xfe

#endif /* _TRAPTYPES_H_ */
