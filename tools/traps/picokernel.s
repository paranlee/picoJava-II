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




 
// Memory Allocator implemented as a small picoJava kernel service routine
// Class Resolution routine is implemented as the 2nd kernel service
// The heap starts at 0x100000, where the heap_managing data structure starts.
// The actual data storage starts('heap_starts') at 0x100100.

// The 'Object_Heap' is defined by a structure:
//
//	struct Object_Heap {
//		unsigned int heap_start;	/* absolute base of the heap */
//		unsigned int heap_end;		/* absolute end of the heap */
//		unsigned int stat_dyn_allocation_end; /* end of stat_dyn_end */
//		unsigned int heap_allocation_end;/* end of heap-allocated */
//		unsigned int num_of_objects;
//		unsigned int obj_tab_start;
//		}

// (stack at entry time)..., argument(num_of_words), service_number, return_addr
// (stack at exit time) ..., argument(num_of_words), return_value, return_addr

#include	"struct.h"

PicoKernel:
//------0123456789-----
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 16;	// ..., arg, service_num, return_address
	  iadd;
	 write_vars;	// Modify VARS, the 'arg' is the local var 0

// ..., argument, service_number, return_address, old_VARS(local 3)
//------0123456789-----
	 iload_1;		// load the service request number posted
	  bipush 22;		// #22: object OR array creation
	if_icmpeq PicoAllocateObject;

	 iload_1;		// load the service request number posted
	  bipush 23;		// #23: 3-words, dynamic static var storage
	if_icmpeq PicoAllocateLongStatic;

	 iload_1;		// load the service request number posted
	  bipush 24;		// #24: static storage alloc, requested words
	if_icmpeq PicoAllocateStaticWord;

	 iload_1;		// load the service request number posted
	  bipush 31;		// #31: Resolve the class with name pointer
	if_icmpeq PicoResolveClass;
	// more checks can go here later for other service request...
	  goto PicoUnimplemented_Request;

// Allocate requested object in the heap.  Obtain a slot in the object table.
// if a handled allocation is in effect.
// No GC is currently assumed, sequential table slot allocation, MAX=4778.
PicoAllocateObject:
//------0123456789-----
	 sipush 0xFFEC;		// 'trap_use_location'
	 sethi 0x0;
	 load_ubyte;
	  bipush 0xF;
	 iand;
	ifne HeapAllocate;
//------0123456789-----
	iinc 0, 2;		// need 2 more words for non-handled objects

HeapAllocate:
//------0123456789-----
	 sipush HEAP_STRUCT_BASE_L;
	 sethi HEAP_STRUCT_BASE_H; // base of the heap_structure, local var4

//------0123456789-----
	 iload 4;
	  bipush 12;	// 'allocation_end' is the 4th item
	 iadd;
	  dup;		// save it to update after allocating new object
	  load_word;	// 'allocation_end'

// Calculate the base address of newly created object, using 'allocation_end'
//------0123456789-----
	   dup;		// ptr_allocation_end, allocation_end, allocation_end
	    iconst_4;
	   iadd;	// start location of new object
	  istore_1;	// store into the Service Req # location
	   iload_0;	// load the size again, in num of words
	    iconst_2;
	   ishl;	// num_of_bytes to be allocated
	  iadd;		// allocation_end + num_of_bytes_allocated

// Check if the new_allocation_end collides with the upper bound: 0x1F0000
// Return null if so.
//------0123456789-----
	   dup;
	    sipush HEAP_STRUCT_END_L;
	    sethi HEAP_STRUCT_END_H;
	  if_icmpgt HeapOverflow;  
	  swap;		// new_allocation_end, ptr_allocation_end
	store_word;	// update 'allocation_end' field of the Heap_Structure

// Clear off the allocated storage - 'null' initialization
//------0123456789-----
	 iload_1;	// start of the allocated heap storage, local 5
NullInitLoop:
//------0123456789-----
	  iload_0;
	 ifeq CheckHandle;
	  aconst_null;
	   iload 5;
	 store_word;
	 iinc 5, 4;
	 iinc 0, -1;
	 goto NullInitLoop;

// Check if handled-obj allocation is in effect
CheckHandle:
//------0123456789-----
	pop;
	 sipush 0xFFEC;
	 sethi 0x0;
	 load_ubyte;
	  bipush 0xF;
	 iand;
	ifne HandledObject;
	iinc 1, 4;	// to have objref point to the MVB word
	goto IncrementObjCounter;

// Allocate handled object.  Obtain a object table slot first.
HandledObject:
//------0123456789-----
	 iload 4;	// base of the 'Object_Heap'
	  bipush 16;	// 'num_of_objects' is the 5th item
	 iadd;
	 load_word;	// slot to be allocated
	  bipush 12;	// each slot is 12 bytes long
	 imul;
	  iconst_0;
	  sethi 0x1F;	// base of object table
	 iadd;
//------0123456789-----
	  dup;
	   bipush 8;
	  iadd; 	// where the heap storage ptr to be stored
	   iload_1;
	   swap;
	 store_word;	// init the heap stroage ptr in the allocated table
	  iconst_5;
	 iadd;		// including the handle bit
	istore_1;

IncrementObjCounter:
//------0123456789-----
	 iload 4;	// base of the 'Object_Heap'
	  bipush 16;	// 'num_of_objects' is the 5th item
	 iadd;
	  dup;
	  load_word;
	   iconst_1;
	  iadd;
	  swap;
	store_word;	// increment 'num_of_objects' by 1
	goto PicoKernelExit;

HeapOverflow:
//------0123456789-----
	pop2;
	 aconst_null;	// return null when memory overflows
	istore_1;	// return value to be stored into service number area
	goto PicoKernelExit;

// Allocate 3-words dynamic storage for long OR double type static variables
PicoAllocateLongStatic:
//------0123456789-----
	 sipush HEAP_STRUCT_BASE_L;
	 sethi HEAP_STRUCT_BASE_H; // base of the heap_structure, local var4

//------0123456789-----
	 iload 4;
	  bipush 8;	// 'stat_dyn_allocation_end' is the 3rd item
	 iadd;
	  dup;		// save it to update after allocating new object
	  load_word;	// 'stat_dyn_allocation_end'

// Calculate the base address of newly created 3-words storage
//------0123456789-----
	   dup;		// ptr_allocation_end, allocation_end, allocation_end
	    iconst_4;
	   iadd;	// start location of this new storage
	  istore_1;	// store into the Service Req # location
	   bipush 12;	// 12 bytes
	  iadd;		// allocation_end + num_of_bytes_allocated

// Check overflow condition
//------0123456789-----
	   dup;
	    sipush STAT_DYNAMIC_END_L;
	    sethi STAT_DYNAMIC_END_H;
	  if_icmpgt HeapOverflow;  
	  swap;		// new_allocation_end, ptr_allocation_end
	store_word;	// update 'stat_dyn_allocation_end' of Heap_Structure
	goto PicoKernelExit;

// Allocate requested static words
PicoAllocateStaticWord:
//------0123456789-----
	 sipush HEAP_STRUCT_BASE_L;
	 sethi HEAP_STRUCT_BASE_H; // base of the heap_structure, local var4

//------0123456789-----
	 iload 4;
	  bipush 8;	// 'stat_dyn_allocation_end' is the 3rd item
	 iadd;
	  dup;		// save it to update after allocating new object
	  load_word;	// 'stat_dyn_allocation_end'

// Calculate the base address of newly created static storage
//------0123456789-----
	   dup;		// ptr_allocation_end, allocation_end, allocation_end
	    iconst_4;
	   iadd;	// start location of this new storage
	  istore_1;	// store into the Service Req # location
	   iload_0;	// requested number of words
	    iconst_2;
	   ishl;
	  iadd;		// allocation_end + num_of_bytes_allocated

// Check overflow condition
//------0123456789-----
	   dup;
	    sipush STAT_DYNAMIC_END_L;
	    sethi STAT_DYNAMIC_END_H;
	  if_icmpgt HeapOverflow;  
	  swap;		// new_allocation_end, ptr_allocation_end
	store_word;	// update 'stat_dyn_allocation_end' of Heap_Structure
	goto PicoKernelExit;

// Resolve the requested class and return the class structure reference
PicoResolveClass:
//------0123456789-----
	 sipush LOW_CLASSTAB_BASE;
	 sethi HIGH_CLASSTAB_BASE; // base of the class table, local var 4

PicoClassSearchLoop:
//------0123456789-----
	 iload 4;	// ptr to a class table entry
	 load_word;	// a class ptr, to be returned when the name matches
	  dup;		// for extracting the class name ptr
	   dup;	// for checking NULL entry, end of class table
	  ifeq PicoClassSearchFail;	// end of class table -< class not found
	   bipush C_CLASSNAME_4;
	  iadd;
	  load_word;	// ptr to the class name string
	   iload_0;	// class_tab_base, class_name_ptr1, class_name_ptr2
	  jsr DecafStrCmp;
//------0123456789-----
	 ifne PicoClassSearchSucceed;
	pop;
	iinc 4,4;	// to check the next class table entry
	goto PicoClassSearchLoop;

PicoClassSearchSucceed:
//------0123456789-----
	 istore_1;	// return the class_ptr thru service request number area
	 iinc 1, 4;	// to make the ptr C-structure compatible
	 goto PicoKernelExit;

PicoClassSearchFail:
	   iconst_0;	// return 0 when no matching class is found
	  istore_1;	// return value to be stored into service number area
	  goto PicoKernelExit;

PicoUnimplemented_Request:
PicoKernelExit:
//------0123456789-----
	 read_vars;	// read the VARS to reset the OPTOP
	  bipush 12;		// the OPTOP should point to next of returnPC
	 isub;
	  iload_3;		// load the old VARS to be restored
	 write_vars;	// restore VARS
	write_optop;	// reset OPTOP to indicate the return address
	ret_from_sub;
//
// DecafStrCmp- compare 2 decaf strings on the top of the operand stack.
//	     Returns 1 if the strings match each other, or 0 otherwise.
//
//	Operand stack should contain the following when this routine is entered:
//
//	 	|			|
//		+-----------------------+
//		|   decaf string ptr1	|
//		+-----------------------+
//		|   decaf string ptr2	|
//		+-----------------------+
//		|     return address	|
//		+-----------------------+
//	OPTOP->	|	  ....		|   
//

//	And the stack will be changed during the execution of this subroutine:
//
//	 	|			|
//		+-----------------------+
//	VARS ->	|   decaf string ptr1	|	local 0
//		+-----------------------+
//		|   decaf string ptr2   |	local 1
//		+-----------------------+
//		|     return address	|	local 2
//		+-----------------------+
//		|       old VARS	|	local 3
//		+-----------------------+
//	OPTOP->	|			|   
//

//	Prior to return, the stack should be(after restoring the old VARS)
//
//	 	|			|
//		+-----------------------+
//		|      return value	|	(==0: no match, ==1: match)
//		+-----------------------+
//		|     return address	|
//		+-----------------------+
//	OPTOP->	|      			|

DecafStrCmp:
//------0123456789------
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 16;		// string ptr1 is at 4-words below
	  iadd;
	 write_vars;	// modify VARS to access the argument as locals

	 iload_0;		// decaf string ptr1
	 load_word;		// the decaf string size and signature
	  dup;
	   iload_1;		// decaf string ptr2
	   load_word;
	 if_icmpne MatchFail;	// match the string signature first
	  bipush 16;
	 ishr;			// upper 16-bits is the string size,local var 4
	 iinc 0, 4;		// the ptr to the actual string 1
	 iinc 1, 4;		// the ptr to the actual string 2
	  
MatchLoop:
//------0123456789------
	 iload 4;		// load the string size
	ifeq MatchSuccess;
	 iload_0;		// ptr to the string 1
	 load_ubyte;
	  iload_1;		// ptr to the string 2
	  load_ubyte;
	if_icmpne MatchFail;
	iinc 0, 1;
	iinc 1, 1;
	iinc 4, -1;		// decrement the string size
	goto MatchLoop;
MatchSuccess:
//------0123456789------
	 iconst_1;		// return value
	istore_0;		// return value should be in the local var 0
	goto Exit_DecafStrCmp;

MatchFail:
//------0123456789------
	 iconst_0;		// return value
	istore_0;		// return value should be in the local var 0

Exit_DecafStrCmp:
//------0123456789------
	 iload_2;		// return address
	istore_1;		// return address should be in the local var 1
	 read_vars;	// VARS
	  bipush 8;
	 isub;			// value to be stored into OPTOP
	  iload_3;		// old VARS
	 write_vars;	// restore VARS
	write_optop;	// OPTOP points to next word of return address
	ret_from_sub;

//
// FindMethodFromClass - 
// 		Search for a method specified by both the name and signature
//		of the referenced method, from a Method Block array whose class
//		pointer is passed as the 3rd argument in the stack.
//		This routine is to support traps such as  'invokestatic' and
//		'invokespecial', where the method is to be searched from the
//		target class's Method Block array.
//
//		This routine supports searching of both instance and static
//		methods, as a Method Block array contains both methods.
//
//		Before returning to the caller, this routine pops off the 4
//		passed arguments, and pushes a return value and the return
//		address.  When a matching method block is found, it returns
//		the method_block ptr at as its return value.  When no method
//		is found, it returns 0.
//
//		Note that the 2 ptrs represent strings, each is in the Decaf
//		string format, where the 1st word(32 bits) is composed of
//		string size(upper 16 bits) and hash value(lower 16 bits) of the
//		string, followed by the string itself, composed of ASCII bytes.
//
// The operand stack should contain the following when this routine is entered:
//		+-----------------------+
//		|    class structure	|
//		+-----------------------+
//		|     signature ptr	|
//		+-----------------------+
//		|       name ptr	|
//		+-----------------------+
//		|     return address	|
//		+-----------------------+
//	OPTOP->	|	  ....		|   

//	And the stack will be changed during the execution of this subroutine:
//		+-----------------------+
//	VARS ->	|    class structure  	|	local 0
//		+-----------------------+
//		|     signature ptr	|	local 1
//		+-----------------------+
//		|       name ptr	|	local 2
//		+-----------------------+
//		|     return address	|	local 3
//		+-----------------------+
//		|       old VARS	|	local 4
//		+-----------------------+
//	OPTOP->	|	  ....		|   

//	Prior to return, the stack should be(after restoring the VARS)
//		+-----------------------+
//		|    ret val(MB_PTR)	|(==0:no such method,!=0:method pointer)
//		+-----------------------+
//		|     return address	|	(local 1)
//		+-----------------------+
//	OPTOP->	|      			|

FindMethodFromClass:
//------0123456789------
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 20;		// class_structure ptr is at 5-words below
	  iadd;
	 write_vars;	// local 0:class_ptr, 1: sig ptr, 2: name ptr
				// local 3:return address, 4: old VARS
// initialize: NumOfMethods, StrSize, NameKey, MVT_base to prepare searching
//------0123456789------
	 iload_0;		// base of class structure
	  bipush C_METHODCNT;
	 iadd;
	 load_word;		// 'methodsCount', local 5
	  iload_0;
	   iconst_4;
	  iadd;
	  load_word;	// ptr to method block array, picoJava array format
	   bipush 8;
	  iadd;		// to bypass the MVB and type/size word
	   iload_2;	// ptr to the referenced method's name string
	   load_word;	// key for the name string, local var 7

NameKeyMatchLoopC:	// ..., oldVars, NumMethods, MbPtr, nameKey, MbPtr 
//------0123456789------
	    iload 5;	// load the counter, 'NumOfMethods' to match for
	   ifeq MethodSearchFailC;// declare fail when the counter reaches 0
	    iload 6;	// ptr to the 1st method block
	    load_word;	// a method block object reference
	     bipush M_METHODNAME_4;
	    iadd;
	    load_word;	// the pointer to the Decaf, method name string
	    load_word;	// key of the method's Decaf name string
	     iload 7;	// key of the referenced method's Decaf name string
	   if_icmpeq NameKeyMatchSuccessC;
NameKeyMatchFailC:
//------0123456789------
	   iinc 5, -1;	// to indicate 1 method block has been compared
	   iinc 6, 4;
	   goto NameKeyMatchLoopC;

NameKeyMatchSuccessC:
//------0123456789------
	    iload 6; 	// ptr to the Method Block matching the referenced name
	    load_word;
	     bipush M_METHODNAME_4;
	    iadd;
	    load_word;	// the pointer to the Decaf, method name string
	     dup;
	     load_word;	// load the key again to extract the size of name string
	      bipush 16;// upper 16bit is the size
	     ishr;	// shift right by 16
//------0123456789------
	     swap;	// local 8 is the string size, local 9:name ptr
	      iconst_4;
	     iadd;	// name str ptr from Method Block, local var 9
	      iload_2;	// Decaf name str ptr of the referenced method
	       iconst_4;
	      iadd;	// ptr to the str of referenced method, local var 10
NameStringMatchLoopC:
//------0123456789------
	       iload 8;	// load the num of chars to be compared
	      ifeq NameStringMatchSuccessC;
	       iload 9;
	       load_ubyte;
	        iload 10;
	        load_ubyte;
	      if_icmpne NameStringMatchFailC;
	      iinc 8, -1;	// To indicate 1 char has been compared
	      iinc 9, 1;	// To compare the next char
	      iinc 10, 1;
	      goto NameStringMatchLoopC;

NameStringMatchFailC:
//------0123456789------
	    pop2;		// remove the 2 string pointers
	   pop;			// remove string size
	   goto NameKeyMatchFailC;// to resume the key matching process

// Found a method block which matches the referenced method name.  Now, start
// matching the signature strings.  If fails, go back to 'NameKeyMatchFail'
// to resume the key matching process.
NameStringMatchSuccessC:
//------0123456789------
	    pop2;
	   pop;

SigKeyMatchC:
//------0123456789------
	    iload 6;
	    load_word;
             bipush M_SIGNATURE_4; 
            iadd;
            load_word;  // the pointer to the Decaf, method signature string
            load_word;  // key of the method's Decaf signature string
             iload_1;   // pointer to the referenced method's signature string
	     load_word;	// key of the signature
           if_icmpne NameKeyMatchFailC;

SigKeyMatchSuccessC:
//------0123456789------
            iload 6;	// ptr to the method block matching the referenced name
	    load_word;
             bipush M_SIGNATURE_4;
            iadd;
	    load_word;	// the pointer to the Decaf, method signature string
             dup;
	     load_word;	// load the key again to extract sigature string size
              bipush 16;// upper 16bit is the size
             ishr;      // shift right by 16
             swap;      // local 8 is the string size, local 9:signature ptr
              iconst_4;
             iadd;      // signature str ptr from Method Block, local var 9
//------0123456789------
              iload_1;  // Decaf siganture str ptr of the referenced method
               iconst_4;
              iadd;     // ptr to the signature of referenced method, local 10
SigStringMatchLoopC:
//------0123456789------
               iload 8; // load the num of chars to be compared
              ifeq SigStringMatchSuccessC;
               iload 9;
               load_ubyte;
                iload 10;
                load_ubyte;
              if_icmpne SigStringMatchFailC;
              iinc 8, -1;       // To indicate 1 char has been compared
              iinc 9, 1;        // To compare the next char
              iinc 10, 1;
              goto SigStringMatchLoopC;
 
SigStringMatchFailC:
//------0123456789------
            pop2;               // remove the 2 string pointers
           pop;                 // remove string size
           goto NameKeyMatchFailC;// to resume the key matching process

MethodSearchFailC:
//------0123456789------
	    iconst_0;		// load 0 to indicate "No Such Method"
	   istore_0;		// store into the return value area
	   goto Exit_FindMethodFromClassC;

SigStringMatchSuccessC:
// Now found a method whose name and signature both match with the referenced
// method's identity.
//------0123456789------
	    pop2;
	   pop;
	    iload 6;		// ptr to Method Block matching the method name
	    load_word;
	   istore_0;
	   iinc 0, 4;		// to make it C-compatible struct ptr

Exit_FindMethodFromClassC:
//------0123456789------
	    iload_3;		// load the return address
	   istore_1;		// store where the return address should go
	    read_vars;	// VARS
             bipush 8;
            isub;		// value to restored into OPTOP
             iload 4;		// old VARS
            write_vars;	// restore VARS
           write_optop;	// OPTOP points to next word of return address
           ret_from_sub;

//
// FindMethodFromObjectHint- 
// 		Search for a method specified by both the name and signature
//		of the referenced method, from an ObjectHintBlock whose class
//		pointer is passed as the 3rd argument in the stack.
//		This routine is to support traps such as  'invokevirtual' and
//		'invokespecial', where the method is to be searched from the
//		object's Method Vector Table, rather than Method Block Array.
//
//		This routine supports searching only an instance method,
//		as a Method Vector Table contains instance methods only.
//
//		When a method block is found, it returns the method_block ptr
//		at the top of operand stack, and the index of the method_blk
//		in Method Vector Table at the 2nd stack-word location.
//		When no such method is found, it returns 0 at top of the stack.
//
//		Note that the 2 ptrs represent strings, each is in the Decaf
//		string format, where the 1st word(32 bits) is composed of
//		string size(upper 16 bits) and hash value(lower 16 bits) of the
//		string, followed by the string itself, composed of ASCII bytes.
//
// The operand stack should contain the following when this routine is entered:
//		+-----------------------+
//		|    class structure	|
//		+-----------------------+
//		|     signature ptr	|
//		+-----------------------+
//		|       name ptr	|
//		+-----------------------+
//		|     return address	|
//		+-----------------------+
//	OPTOP->	|	  ....		|   

//	And the stack will be changed during the execution of this subroutine:
//		+-----------------------+
//	VARS ->	|    class structure  	|	local 0
//		+-----------------------+
//		|     signature ptr	|	local 1
//		+-----------------------+
//		|       name ptr	|	local 2
//		+-----------------------+
//		|     return address	|	local 3
//		+-----------------------+
//		|       old VARS	|	local 4
//		+-----------------------+
//	OPTOP->	|	  ....		|   

//	Prior to return, the stack should be(after restoring the VARS)
//		+-----------------------+
//		|    ret val_1(INDEX)	|	local 0
//		+-----------------------+
//		|    ret val_2(MB_PTR)	|(==0:no such method,!=0:method pointer)
//		+-----------------------+
//		|     return address	|	local 2
//		+-----------------------+
//	OPTOP->	|      			|

FindMethodFromObjectHint:
//------0123456789------
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 20;		// class_structure ptr is at 5-words below
	  iadd;
	 write_vars;	// modify VARS to access the argument as locals

// Prepare the searching by init: NumOfMethods, StrSize, NameKey, MVT_base, etc
//------0123456789------
	 iload_0;		// base of class structure
	  bipush C_OBJHINTBLK;
	 iadd;
	 load_word;		// ptr to the ObjHintBlk
	  dup;
	   bipush O_NUMINSTMETHOD;
	  iadd;
	  load_word;		// 'NumInstanceMethods'
	  swap;		// ..., oldVars, NumMethods, ObjHintBlk
	   bipush O_INSTMETHODPTR;
	  iadd;		// ..., oldVars, NumMethods, MVT_base
	   iload_2;	// ptr to the referenced method's name string
	   load_word;	// key for the name string, local var 7
//------0123456789------
	    iload 6;	// base of the Method Vector Table
	    load_word;	// ptr to the 1st method block
NameKeyMatchLoop:	// ..., oldVars, NumMethods, MVT_base, nameKey, MbPtr 
//------0123456789------
	     iload 5;	// load the counter, 'NumOfMethods' to go for
	    ifeq MethodSearchFail;// declare fail when the counter reaches 0
	     bipush M_METHODNAME;
	    iadd;
	    load_word;	// the pointer to the Decaf, method name string
	    load_word;	// key of the method's Decaf name string
	     iload 7;	// key of the referenced method's Decaf name string
	   if_icmpeq NameKeyMatchSuccess;
NameKeyMatchFail:
//------0123456789------
	   iinc 5, -1;	// to indicate 1 method block has been compared
	   iinc 6, 4;	// increment Method Vector Table base by 4
	    iload 6;
	    load_word;	// ptr to the next method block to be compared
	    goto NameKeyMatchLoop;

NameKeyMatchSuccess:
//------0123456789------
	    iload 6;
	    load_word;	// ptr to the method block matching the referenced name
	     bipush M_METHODNAME;
	    iadd;
	    load_word;	// the pointer to the Decaf, method name string
	     dup;
	     load_word;	// load the key again to extract the size of name string
	      bipush 16;// upper 16bit is the size
	     ishr;	// shift right by 16
	     swap;	// local 8 is the string size, local 9:name ptr
	      iconst_4;
	     iadd;	// name str ptr from MVT, local var 9
//------0123456789------
	      iload_2;	// Decaf name str ptr of the referenced method
	       iconst_4;
	      iadd;	// ptr to the str of referenced method, local var 10
NameStringMatchLoop:
//------0123456789------
	       iload 8;	// load the num of chars to be compared
	      ifeq NameStringMatchSuccess;
	       iload 9;
	       load_ubyte;
	        iload 10;
	        load_ubyte;
	      if_icmpne NameStringMatchFail;
	      iinc 8, -1;	// To indicate 1 char has been compared
	      iinc 9, 1;	// To compare the next char
	      iinc 10, 1;
	      goto NameStringMatchLoop;

NameStringMatchFail:
//------0123456789------
	    pop2;		// remove the 2 string pointers
	   pop;			// remove string size
	   goto NameKeyMatchFail;// to resume the key matching process

// Found a method block which matches the referenced method name.  Now, start
// matching the signature strings.  If fails, go back to 'NameKeyMatchFail'
// to resume the key matching process.
NameStringMatchSuccess:
//------0123456789------
	    pop2;
	   pop;
	    iload 6;
            load_word;  // ptr to the method block matching the referenced name
SigKeyMatch:       // ..., oldVars, NumMethods, MVT_base, nameKey, MbPtr
//------0123456789------
             bipush M_SIGNATURE;
            iadd;
            load_word;  // the pointer to the Decaf, method signature string
            load_word;  // key of the method's Decaf signature string
             iload_1;   // pointer to the referenced method's signature string
	     load_word;	// key of the signature
           if_icmpne NameKeyMatchFail;

SigKeyMatchSuccess:
//------0123456789------
            iload 6;
            load_word;  // ptr to the method block matching the referenced name
             bipush M_SIGNATURE;
            iadd;
	    load_word;	// the pointer to the Decaf, method signature string
	     dup;
	     load_word;	// load the key again to extract sigature string size
              bipush 16;// upper 16bit is the size
             ishr;      // shift right by 16
             swap;      // local 8 is the string size, local 9:signature ptr
              iconst_4;
             iadd;      // signature str ptr from MVT, local var 9
//------0123456789------
              iload_1;  // Decaf siganture str ptr of the referenced method
               iconst_4;
              iadd;     // ptr to the signature of referenced method, local 10
SigStringMatchLoop:
//------0123456789------
               iload 8; // load the num of chars to be compared
              ifeq SigStringMatchSuccess;
               iload 9;
               load_ubyte;
                iload 10;
                load_ubyte;
              if_icmpne SigStringMatchFail;
              iinc 8, -1;       // To indicate 1 char has been compared
              iinc 9, 1;        // To compare the next char
              iinc 10, 1;
              goto SigStringMatchLoop;
 
SigStringMatchFail:
//------0123456789------
            pop2;               // remove the 2 string pointers
           pop;                 // remove string size
           goto NameKeyMatchFail;// to resume the key matching process

SigStringMatchSuccess:
// Now found a method whose name and signature both match with the referenced
// method's identity. Calculate the index of the method within the Method Vector
// Table and push to the stack with the method block pointer, to return.
//------0123456789------
	    pop2;
	   pop;
	    iload 6;		// ptr to MVT entry matching the method name
	     iload_0;		// base of class structure
	      bipush C_OBJHINTBLK;
	     iadd;
	     load_word;
	      bipush O_INSTMETHODPTR;
	     iadd;		// base of the MVT
	    isub;		// MVT_ptr - MVT_base
	     iconst_2;
	    ishr;		// word index
//------0123456789------
	   istore_0;		// return val2: INDEX of the MVT
	    iload 6;
	    load_word;		// ptr to the method_block
	   istore_1;		// return val1: PTR to the MethodBlk
	   goto Exit_FindMethodFromObjectHint;

MethodSearchFail:
//------0123456789------
	    iconst_0;		// load 0 to indicate "No Such Method"
	   istore_1;		// store into the return value area

Exit_FindMethodFromObjectHint:
//------0123456789------
	    iload_3;		// load the return address
	   istore_2;		// store where the return address should go
	    read_vars;	// VARS
             bipush 12;
            isub;		// value to be stored into OPTOP
             iload 4;		// old VARS
            write_vars;	// restore VARS
           write_optop;	// OPTOP points to next word of return address
           ret_from_sub;

// GetTrapCP - extract the base address of a CP table allocated a trap
//		specified by the passed argument.
GetTrapCP:
//------0123456789------
	  swap;		// ..., ret_addr, vector_num
	   iconst_3;
	  ishl;		// left shift the vectore number
           priv_read_trapbase;  // TRAPBASE reg, pointing to current vector
	    bipush 11;
           ishr;
            bipush 11;
//------0123456789-----
           ishl;
          iadd;
           iconst_4;
          iadd;         // location of this trap's CP value is stored
          load_word;
	  swap;		// ..., CP_base, ret_addr
	 ret_from_sub;

// Build a temporary decaf string from an ASCII stream.
// The stack has 2 args: ptr to the ASCII stream, length of the ASCII stream
// Returns the tmp DecafStr ptr in the 'length' arg area
BuildTmpDecafStr:
//------0123456789-----
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 16;	// ..., ptr, length , return_address, oldVARS
	  iadd;
	 write_vars;	// Modify VARS, the 'ptr' is the local var 0

//------0123456789------
	 iconst_0;	// hash key, local 4
	  sipush TMP_BUF_BASE_L;
	  sethi TMP_BUF_BASE_H;
	   iconst_4;
	  iadd;		// storage for the decaf string, local 5
	   iconst_0;	// shift counter, local 6

BuildTmpDecafStrLoop:
//------0123456789------
	 iload_0;
	 load_ubyte;
	  dup;
	   iload 5;
	 store_byte;	// copy into the decaf string area
	  iload 6;
	 ishl;
	  iload 4;
	 iadd;
	istore 4;
	iinc 0, 1;
	iinc 6, 1;
	 iload 6;
	  iload_1;	// string length
	if_icmpeq BuildTmpDecafStrDone;
	iinc 5, 1;
	goto BuildTmpDecafStrLoop;

BuildTmpDecafStrDone:
//------0123456789------
	 iload 4;	// summation of all shifted ASCII chars
	  sipush 0xFFFF;
	  sethi 0x0;
	 iand;
	  iload_1;
	   bipush 16;
	  ishl;
	 ior;
//------0123456789------
	  sipush TMP_BUF_BASE_L;
	  sethi TMP_BUF_BASE_H;
	   dup_x1;
	 store_word;	// put the hash key  
	istore_1;

//------0123456789------
	  pop2;		// local 5, 6
	 pop;		// local 4
	write_vars;
	ret_from_sub;


// Build a permanent decaf string from an ASCII stream.
// The stack has 2 args: ptr to the ASCII stream, length of the ASCII stream
// Returns the tmp DecafStr ptr in the 'length' arg area
BuildDecafStr:
//------0123456789-----
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 16;	// ..., ptr, length , return_address, oldVARS
	  iadd;
	 write_vars;	// Modify VARS, the 'ptr' is the local var 0

//------0123456789------
	 iconst_0;	// hash key, local 4
	  iload_1;
	   iconst_2;
	  ishr;		// div by 4
	   dup;
	    iconst_2;
	   ishl;
	    iload_1;
	  if_icmpeq BuildDecafStrNoRemainder;
	   iconst_1;
	  iadd;		// add 1 more word for the remainder byte(s)

BuildDecafStrNoRemainder:
//------0123456789------
	   iconst_1;	// for hasy key word
	  iadd;
	   bipush 24;	// picoKernel service req #
	   jsr PicoKernel;
	   swap;
	  pop;		// allocated storage ptr, local 5
	   iconst_0;	// shift counter, local 6
	    iload 5;
	     iconst_4;
	    iadd;	// storage for the decaf string, local 7

BuildDecafStrLoop:
//------0123456789------
	 iload_0;
	 load_ubyte;
	  dup;
	   iload 7;
	 store_byte;	// copy into the decaf string area
	  iload 6;
	 ishl;
	  iload 4;
	 iadd;
	istore 4;
	iinc 0, 1;
	iinc 6, 1;
	 iload 6;
	  iload_1;
	if_icmpeq BuildDecafStrDone;
	iinc 7, 1;
	goto BuildDecafStrLoop;

BuildDecafStrDone:
//------0123456789------
	 iload 4;	// summation of all shifted ASCII chars
	  sipush 0xFFFF;
	  sethi 0x0;
	 iand;
	  iload_1;
	   bipush 16;
	  ishl;
	 ior;
//------0123456789------
	  iload 5;
	   dup_x1;
	 store_word;	// put the hash key  
	istore_1;

//------0123456789------
	  pop2;		// local 6, 7
	 pop2;		// local 4, 5
	write_vars;
	ret_from_sub;

// Scan the 2 array defn strings until an element type char is found from
// either of the defns.  Returns a integer encoding the scan result, along
// with a class structure pointer or sub-array defn str in the passed arg area.

// stack: target_array_defn, src_array_defn, result, ret_address, old_var
//	      local 0		local 1	     local 2    local 3   local 4
Scan2ArrayDefnStr:
//------0123456789-----
	 read_vars;	// save the VARS before modifying
	  read_optop;	// read the OPTOP
	   bipush 20;	// ..., defn1, defn2, result, ret_address, oldVARS
	  iadd;
	 write_vars;	// Modify VARS, the target array defn is local var 0

// Allocate 2 locals
//------0123456789------
	 iload_0;	// target array defn str ptr, local 5
	  iload_1;	// source array defn str ptr, local 6
	 iconst_0;
	istore_2;
	iinc 5, 4;	// copy of target
	iinc 6, 4;	// copy of source

Scan2ArrayDefnLoop:
//------0123456789------
	 iload 5;
	 load_ubyte;
	  iload 6;
	  load_ubyte;
	if_icmpne Scan2ElementType;
	 iload 5;
	 load_ubyte;
	  bipush 0x5B;
	if_icmpne Scan2ElementType;
	iinc 5, 1;
	iinc 6, 1;
	goto Scan2ArrayDefnLoop;

Scan2ElementType:
//------0123456789------
	 iload 5;
	 load_ubyte;
	  bipush 0x5B;
	if_icmpne Scan2IsSourceArray;

// The target is still an array type, while the source yields to a non-array
Scan2TargetIsArray:
//------0123456789------
	 iload_2;
	  sipush 0x1000;
	 ior;
	istore_2;
	goto Scan2GetSrcElementType;

// Target yields to a non-array type. Check if the source is an array.
Scan2IsSourceArray:
//------0123456789------
	 iload 6;
	 load_ubyte;
	  bipush 0x5B;
	if_icmpne Scan2GetTgtElementType;
Scan2SourceIsArray:
//------0123456789------
	 iload_2;
	  sipush 0x0010;
	 ior;
	istore_2;

Scan2GetTgtElementType:
//------0123456789------
	 iload 5;
	 load_ubyte;
Scan2IsTgtObject:
//------0123456789------
          dup;
           bipush 0x4C;         // 'L' : Object
         if_icmpne Scan2TgtIsPrimitive;
	pop;
	 iload 5;
	  iload_0;
	 isub;
	  iconst_2;		// subtract 2 more(4 more - ('L'+';'))
	 isub;
//------0123456789------
	  iload_0;
	  load_word;
	   bipush 16;
	  ishr;
	  swap;
	 isub;			// length of class name string 
//------0123456789------
	  iinc 5, 1;		// bypass 'L'
	  iload 5;
	  swap;
	  jsr BuildTmpDecafStr;
	  swap;
	 pop;
	  bipush 31;		// resolcve class
	  jsr PicoKernel;
//------0123456789------
	 istore_0;		// replace the str ptr with the class ptr
	pop;
	 iload_2;
	  sipush 0x0100; 	// target is an object class
	 ior;
	istore_2;
        goto TgtTypeFound;

Scan2TgtIsPrimitive:
//------0123456789------
	  bipush 8;
	 ishl;			// target's primitive type will be bit15-bit7
	  iload_2;
	 ior;
	istore_2;

TgtTypeFound:
IsSrcTypeDone:
//------0123456789------
	 iload_2;
	  bipush 0x0010;
	 iand;
	ifne Scan2ArrayDefnTypesFound;	// array src type was already detected

Scan2GetSrcElementType:
//------0123456789------
	 iload 6;
	 load_ubyte;
Scan2IsSrcObject:
//------0123456789------
          dup;
           bipush 0x4C;         // 'L' : Object
         if_icmpne Scan2SrcIsPrimitive;
	pop;
	 iload 6;
	  iload_1;
	 isub;
	  iconst_2;		// subtract 2 more(4 more - ('L'+';'))
	 isub;
//------0123456789------
	  iload_1;
	  load_word;
	   bipush 16;
	  ishr;
	  swap;
	 isub;			// length of class name string 
//------0123456789------
	  iinc 6, 1;		// bypass 'L'
	  iload 6;
	  swap;
	  jsr BuildTmpDecafStr;
	  swap;
	 pop;
	  bipush 31;		// resolcve class
	  jsr PicoKernel;
//------0123456789------
	 istore_1;		// replace the str ptr with the class ptr
	pop;
	 iload_2;
	  iconst_1;		// source is an object class
	 ior;
	istore_2;
        goto SrcTypeFound;

Scan2SrcIsPrimitive:
//------0123456789------
	  iload_2;
	 ior;
	istore_2; 

SrcTypeFound:
Scan2ArrayDefnTypesFound:
//------0123456789------
	pop2;		// local 5, 6
	write_vars;
	ret_from_sub;

Scan2ArrayDefnError:
//------0123456789------
	pop;
	pop2;
	 iconst_0;
	istore_2;	// the result 0 means Fatal Error
	write_vars;
	ret_from_sub;
