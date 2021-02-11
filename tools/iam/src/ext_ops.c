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
 ***
 *****************************************************************/




static char *sccsid = "@(#)ext_ops.c 1.17 Last modified 01/14/99 12:10:39 SMI";

#include <sys/types.h>
#include <string.h> 
#include <stdio.h>
#include    <stdarg.h> 

#include    "dsv.h"
#include    "cm.h"          /* for debugger serial port addr */
#include    "sim_config.h"
#include    "serial_port.h"
#include    "traps.h"
#include    "iam.h"
#include    "typedefs.h"
#include    "javamem.h"
#include    "dprint.h"
#include    "object_ops.h"
#include    "global_regs.h"
#include    "profiler.h"
#include    "tracing.h"
#include    "ext_ops.h"

char *ext_hw_opcode_names[128] = {
        "load_ubyte",
        "load_byte",
        "load_char",
        "load_short",
        "load_word",
        "priv_ret_from_trap",
        "priv_read_dcache_tag",
        "priv_read_dcache_data",
        "null",
        "null",
        "load_char_oe",
        "load_short_oe",
        "load_word_oe",
        "return0",
        "priv_read_icache_tag",
        "priv_read_icache_data",
        "ncload_ubyte",
        "ncload_byte",
        "ncload_char",
        "ncload_short",
        "ncload_word",
        "iucmp",
        "priv_powerdown",
        "cache_invalidate",
        "null",
        "null",
        "ncload_char_oe",
        "ncload_short_oe",
        "ncload_word_oe",
        "return1",
        "cache_flush",
        "cache_index_flush",
        "store_byte",
        "null",
        "store_short",
        "null",
        "store_word",
        "soft_trap",
        "priv_write_dcache_tag",
        "priv_write_dcache_data",
        "null",
        "null",
        "store_short_oe",
        "null",
        "store_word_oe",
        "return2",
        "priv_write_icache_tag",
        "priv_write_icache_data",
        "ncstore_byte",
        "null",
        "ncstore_short",
        "null",
        "ncstore_word",
        "null",
        "priv_reset",
        "get_current_class",
        "null",
        "null",
        "ncstore_short_oe",
        "null",
        "ncstore_word_oe",
        "call",
        "zero_line",
        "priv_update_optop",
        "read_pc",
        "read_vars",
        "read_frame",
        "read_optop",
        "priv_read_oplim",
        "read_constpool",
        "priv_read_psr",
        "priv_read_trapbase",
        "priv_read_lockcnt0",
        "priv_read_lockcnt1",
        "null",
        "null",
        "priv_read_lockaddr0",
        "priv_read_lockaddr1",
        "null",
        "null",
        "priv_read_userrange1",
        "priv_read_gc_config",
        "priv_read_brk1a",
        "priv_read_brk2a",
        "priv_read_brk12c",
        "priv_read_userrange2",
        "null",
        "priv_read_version_id",
        "priv_read_hcr",
        "priv_read_sc_bottom",
        "read_global0",
        "read_global1",
        "read_global2",
        "read_global3",
        "null",
        "null",
        "write_pc",
        "write_vars",
        "write_frame",
        "write_optop",
        "priv_write_oplim",
        "write_constpool",
        "priv_write_psr",
        "priv_write_trapbase",
        "priv_write_lockcnt0",
        "priv_write_lockcnt1",
        "null",
        "null",
        "priv_write_lockaddr0",
        "priv_write_lockaddr1",
        "null",
        "null",
        "priv_write_userrange1",
        "priv_write_gc_config",
        "priv_write_brk1a",
        "priv_write_brk2a",
        "priv_write_brk12c",
        "priv_write_userrange2",
        "null",
        "null", 
        "null", 
        "priv_write_sc_bottom",
        "write_global0",
        "write_global1",
        "write_global2",
        "write_global3",
        "null",
        "null",
};

void vDoExtOp (unsigned char ext_opcode)

{
    unsigned int ext_address, increment, ext_value; 
    void *memory_ptr;
    unsigned int unsigned_tmp;
    unsigned short short_tmp;
    char char_tmp;

    switch (ext_opcode) 
    {
	  case opc_priv_update_optop:
	  {
        unsigned int oplim_value;

		TRAP_IF_NONPRIV;
   
        /* carry out this update in 3 stages - write to oplim with
           the new value, but oplim trap disabled, then update optop,
           then write the full value to oplim, to enable oplim checking if
           needed. this will cause the oplim-optop condition to be evaluated 
           only after both optop and oplim have their new values */ 

        READ_WORD (OPTOP_OFFSET (2), 'O', oplim_value);
		vUpdateGR (GR_oplim, oplim_value & 0x7FFFFFFF);
		READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
		vUpdateGR (GR_optop, unsigned_tmp);

		vUpdateGR (GR_oplim, oplim_value);
	  }
	  SIZE_AND_STACK_RETURN (2, 0); /* optop already written, don't adjust */

	  case opc_get_current_class:
	  {
		doGetCurrentClass (); 
		/* pc and optop adjustment is done inside GetCurrentClass */
		return;
      }

      case opc_zero_line:
        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);

        if ((CHK_PSR_DCE) && !(IS_NC_ADDRESS (ext_address)))
        {
		    /* check for addr bounds *after* checking if DCE off */
			ext_address &= 0x3FFFFFFF;

/* check for mem prot before breakpoints */
#ifdef MEM_PROTECTION_CHECK
		    if (causes_mem_prot_error (ext_address))
            {
                vSetupException (MEM_PROT_EXCEPTION);
                return;
            }
#endif

#ifdef PICO_BREAKPOINTS
    if (pico_breakpoint_match (1, ext_address, 1, 0))
    { 
         vSetupException (DBR1_EXCEPTION);
         return;
    }
    if (pico_breakpoint_match (2, ext_address, 1, 0))
    {
         vSetupException (DBR2_EXCEPTION);
         return;
    }
#endif /* PICO_BREAKPOINTS */

            if (dCacheZeroLine (ext_address) == DSV_FAIL) 
            {
                printf("IAS warning: zeroline failed \n");
                return;
            }
        }
		else
		{
            LOW_PRIORITY_TRAP (ZeroLineEmulationTrap);
			return;
        }
        SIZE_AND_STACK_RETURN(2,-1);

      case opc_cache_flush:
        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);

        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);

        /* cacheFlush routine takes care of whether PSR.DCE/ICE = 1 */

        if (cacheFlush(ext_address, ext_value, &ext_address) == DSV_FAIL) 
        {
            printf("IAS warning: cacheflush failed \n");
            return;
        }

        /* write address + increment back to ToS */
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_address); 

        SIZE_AND_STACK_RETURN(2, 0);

      case opc_cache_index_flush:
        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);

        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);

        if (cacheIndexFlush (ext_address, ext_value, &ext_address) == DSV_FAIL) 
        {
            printf("IAS warning: cacheindexflush failed \n");
            return;
        }

        /* write address + increment back to ToS */
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_address); 

        SIZE_AND_STACK_RETURN(2, 0);

      case opc_cache_invalidate:
        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);

/* first check for mem_prot, then breakpoints */
#ifdef MEM_PROTECTION_CHECK
		if (causes_mem_prot_error (ext_address))
        {
            vSetupException (MEM_PROT_EXCEPTION);
            return;
        }
#endif

#ifdef PICO_BREAKPOINTS
    if (pico_breakpoint_match (1, ext_address, 1, 0))
    { 
         vSetupException (DBR1_EXCEPTION);
         return;
    }
    if (pico_breakpoint_match (2, ext_address, 1, 0))
    {
         vSetupException (DBR2_EXCEPTION);
         return;
    }
#endif /* PICO_BREAKPOINTS */

        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);

        if (cacheInvalidate (ext_address, ext_value, &ext_address) == DSV_FAIL) 
        {
            printf("IAS warning: cache invalidate failed \n");
            return;
        }

        /* write address + increment back to ToS */
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_address); 

        SIZE_AND_STACK_RETURN(2, 0);

      case opc_soft_trap:
        LOW_PRIORITY_TRAP (soft_trap);
        return;

      case opc_priv_read_dcache_tag:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        if (readDcacheTag(ext_address, &ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: readDcachetag failed \n");
            return;
        }
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_value);
        SIZE_AND_STACK_RETURN(2, 0);

      case opc_priv_write_dcache_tag:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);
        if (writeDcacheTag(ext_address, ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: writeDcachetag failed \n");
            return; 
        }
        SIZE_AND_STACK_RETURN(2, -2);

      case opc_priv_read_dcache_data:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        if (readDcacheData (ext_address, &ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: readDcachetag failed \n");
            return; 
        }
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_value);
        SIZE_AND_STACK_RETURN(2, 0);

      case opc_priv_write_dcache_data:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);
        if (writeDcacheData (ext_address, ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: writedcachedata failed \n");
            return; 
        }
        SIZE_AND_STACK_RETURN(2, -2);

      case opc_priv_read_icache_tag:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        if (readIcacheTag (ext_address, &ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: readIcachetag failed \n");
            return; 
        }
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_value);
        SIZE_AND_STACK_RETURN(2, 0);

      case opc_priv_write_icache_tag:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);
        if (writeIcacheTag (ext_address, ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: writeIcachetag failed \n");
            return; 
        }
        SIZE_AND_STACK_RETURN(2, -2);

      case opc_priv_read_icache_data:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        if (readIcacheData (ext_address, &ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: readIcachedata failed \n");
            return; 
        }
        WRITE_WORD (OPTOP_OFFSET (1), 'O', ext_value);
        SIZE_AND_STACK_RETURN(2, 0);

      case opc_priv_write_icache_data:
        TRAP_IF_NONPRIV;   

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        READ_WORD (OPTOP_OFFSET (2), 'O', ext_value);
        if (writeIcacheData (ext_address, ext_value) == DSV_FAIL) 
        {
            printf("IAS warning: writeIcachedata failed \n");
            return; 
        }
        SIZE_AND_STACK_RETURN(2, -2);

      case opc_priv_ret_from_trap: 
        TRAP_IF_NONPRIV;

        {
            unsigned char *oldpc;
			unsigned int optop_tmp, psr_tmp, vars_tmp;

            oldpc = pc;
            READ_WORD (FRAME_OFFSET (1), 'F', psr_tmp);
            READ_WORD (FRAME_OFFSET (0), 'F', unsigned_tmp);
            pc = (unsigned char *) unsigned_tmp;

            DPRINTF (TRAP_DBG_LVL, ("privileged return from trap at 0x%x, branching to 0x%x\n", oldpc, pc));

            optop_tmp = (int) vars;

            READ_WORD (FRAME_OFFSET (-1), 'F', vars_tmp);
            READ_WORD (FRAME_OFFSET (-2), 'F', unsigned_tmp);
            frame = (stack_item *) unsigned_tmp;

            vars = (stack_item *) vars_tmp;
            vUpdateGR (GR_psr, psr_tmp);
            vUpdateGR (GR_optop, optop_tmp);
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif
            return;
        }

      case opc_read_pc:
        unsigned_tmp = (unsigned int) pc;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_vars:
        unsigned_tmp = (int) vars;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_frame:
        unsigned_tmp = (int) frame;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_optop:
        unsigned_tmp = (int) optop;    /* get rel addr */
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_oplim:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = (int) oplim;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_const_pool:
        unsigned_tmp = (int) const_pool;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);
			  
      case opc_priv_read_psr:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = psr;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_trapbase:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = (unsigned int) trapbase;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_lockcount0:
      case opc_priv_read_lockcount1:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = lockCount[ext_opcode-opc_priv_read_lockcount0];
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_lockaddr0:
      case opc_priv_read_lockaddr1:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = lockAddr[ext_opcode-opc_priv_read_lockaddr0];
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_userrange1:
        TRAP_IF_NONPRIV;   
        WRITE_WORD (OPTOP_OFFSET(0), 'O', userrange1);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_userrange2:
        TRAP_IF_NONPRIV;   
        WRITE_WORD (OPTOP_OFFSET(0), 'O', userrange2);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_gc_config:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = gcConfig;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_brk1a:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = brk1a;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_brk2a:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = brk2a;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_brk12c:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = *((unsigned int *) (&brk12c));
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_versionid:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = versionId;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_hcr:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = *((unsigned int *) (&hcr));
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_priv_read_sc_bottom:
        TRAP_IF_NONPRIV;   
        unsigned_tmp = (int) scBottom;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_global0:
        unsigned_tmp = global0;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_global1:
        unsigned_tmp = global1;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_global2:
        unsigned_tmp = global2;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_read_global3:
        unsigned_tmp = global3;
        WRITE_WORD (OPTOP_OFFSET(0), 'O', unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, 1);

      case opc_write_pc: 
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        DPRINTF (JSR_DBG_LVL, ("write_pc at 0x%x, branching to 0x%x\n", (unsigned int) pc, unsigned_tmp));
        pc = (unsigned char*) unsigned_tmp;
        SIZE_AND_STACK_RETURN(0, -1);

      case opc_write_vars:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        vars = (stack_item *) (unsigned_tmp & 0xFFFFFFFC);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_frame:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        frame = (stack_item *) (unsigned_tmp & 0xFFFFFFFC);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_optop:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        vUpdateGR (GR_optop, (int) (unsigned_tmp & 0xFFFFFFFC));
        SIZE_AND_STACK_RETURN(2, 0);

      case opc_priv_write_oplim:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        vUpdateGR (GR_oplim, (int) (unsigned_tmp & 0xFFFFFFFC));
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_const_pool:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        const_pool = (decafCpItemType *) (unsigned_tmp & 0xFFFFFFFC);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_psr:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        vUpdateGR (GR_psr, unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_trapbase:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
		/* maintain the old TT field, write 0 into lower 3 bits */
        trapbase = (int) (unsigned_tmp & 0xFFFFF800) | (trapbase & 0x7F8);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_lockcount0:
      case opc_priv_write_lockcount1:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        lockCount[ext_opcode-opc_priv_write_lockcount0] = unsigned_tmp & 0xC0FF;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_lockaddr0:
      case opc_priv_write_lockaddr1:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        lockAddr[ext_opcode-opc_priv_write_lockaddr0] = (unsigned_tmp & 0xFFFFFFFC);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_userrange1:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        userrange1 = unsigned_tmp;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_userrange2:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        userrange2 = unsigned_tmp;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_gc_config:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        gcConfig = (unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_brk1a:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        brk1a = (unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_brk2a:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        brk2a = (unsigned_tmp);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_brk12c:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        *((unsigned int *) (&brk12c)) = (unsigned_tmp);
		brk12c.res0 = brk12c.res1 = brk12c.res2 = 0;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_priv_write_sc_bottom:
		TRAP_IF_NONPRIV;
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        vUpdateGR (GR_sc_bottom, unsigned_tmp & 0xFFFFFFFC);
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_global0:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        global0 = unsigned_tmp;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_global1:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        global1 = unsigned_tmp;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_global2:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        global2 = unsigned_tmp;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_write_global3:
        READ_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);
        global3 = unsigned_tmp;
        SIZE_AND_STACK_RETURN(2, -1);

      case opc_call:
	  { unsigned int nargs, target_pc, return_pc;
	   
		READ_WORD (OPTOP_OFFSET (1), 'O', nargs);
		READ_WORD (OPTOP_OFFSET (2), 'O', target_pc);
		WRITE_WORD (OPTOP_OFFSET (2), 'O', vars);
		return_pc = ((unsigned int) pc) + 2;
		WRITE_WORD (OPTOP_OFFSET (1), 'O', return_pc);

		vars = (stack_item *) (((unsigned int) optop) + nargs * 4);
		pc = (unsigned char *) target_pc;
#ifdef PROFILING
        mark_block_enter (current_profile_id, "C-function", FALSE, FALSE);
#endif
		return;
	  }

      case opc_return0:
	  { unsigned int return_pc, return_vars;

		READ_WORD (OPTOP_OFFSET (1), 'O', return_pc);
		READ_WORD (OPTOP_OFFSET (2), 'O', return_vars);
        pc = (unsigned char *) return_pc;
		vUpdateGR (GR_optop, (unsigned int) vars);
        vars = (stack_item *) return_vars;
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif
		return;
      }

      case opc_return1:
	  { unsigned int return_pc, return_vars, return_val;

		READ_WORD (OPTOP_OFFSET (1), 'O', return_val);
		READ_WORD (OPTOP_OFFSET (2), 'O', return_pc);
		READ_WORD (OPTOP_OFFSET (3), 'O', return_vars);
        pc = (unsigned char *) return_pc;
		vUpdateGR (GR_optop, ((unsigned int) vars)-JAVAWORDSIZE); 
        vars = (stack_item *) return_vars;
		WRITE_WORD (OPTOP_OFFSET (1), 'O', return_val);
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif
		return;
      }

      case opc_return2:
	  { unsigned int return_pc, return_vars, return_val1, return_val0;

		READ_WORD (OPTOP_OFFSET (1), 'O', return_val1);
		READ_WORD (OPTOP_OFFSET (2), 'O', return_val0);
		READ_WORD (OPTOP_OFFSET (3), 'O', return_pc);
		READ_WORD (OPTOP_OFFSET (4), 'O', return_vars);
        pc = (unsigned char *) return_pc;
		vUpdateGR (GR_optop, ((unsigned int) vars)-2*JAVAWORDSIZE); 
        vars = (stack_item *) return_vars;
		WRITE_WORD (OPTOP_OFFSET (1), 'O', return_val1);
		WRITE_WORD (OPTOP_OFFSET (2), 'O', return_val0);
#ifdef PROFILING
        mark_block_exit (current_profile_id);
#endif
		return;
      }

      case opc_priv_reset:
		TRAP_IF_NONPRIV;
		initPico ();
		pc = (unsigned char *) 0;
		return;

      case opc_priv_powerdown:
		TRAP_IF_NONPRIV;
        bPowerDownState = 1;
		SIZE_AND_STACK_RETURN (2, 0);

      case opc_load_ubyte:
      case opc_load_byte:
      case opc_ncload_byte:
      case opc_ncload_ubyte:
      {
		int non_cacheable;

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        
		non_cacheable = ((ext_opcode == opc_ncload_byte) || 
						 (ext_opcode == opc_ncload_ubyte)|| 
						 (IS_NC_ADDRESS (ext_address)));

        /* zero the top 2 bits of the address */
        ext_address &= 0x3FFFFFFF;

        if (non_cacheable)
        {
		    if (ext_address == DEBUGGER_SERIAL_PORT_ADDRESS)
			{
			     if (debugger_serial_port_read != NULL)
				     char_tmp = (*debugger_serial_port_read) ();
			}
			else
			{
                READ_BYTE (ext_address, 'N', char_tmp)
			}
        }
        else
        {
            READ_BYTE (ext_address, 'Z', char_tmp)
        }
        
        if ((ext_opcode == opc_load_byte) || 
            (ext_opcode == opc_ncload_byte))
            unsigned_tmp = (char) char_tmp;
        else
            unsigned_tmp = (unsigned char) char_tmp;

        WRITE_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

        SIZE_AND_STACK_RETURN(2, 0);
      }

      case opc_load_char:
      case opc_load_short:
      case opc_ncload_char:
      case opc_ncload_short: 
      case opc_load_char_oe:
      case opc_load_short_oe:
      case opc_ncload_char_oe:
      case opc_ncload_short_oe: 
      {
        int opposite_endian_inst, little_endian_addr, little_endian;
		int non_cacheable;

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        CHECK_ADDRESS_ALIGNMENT(ext_address, 0x1);

        opposite_endian_inst = ((ext_opcode == opc_load_char_oe) || 
                                (ext_opcode == opc_load_short_oe) || 
                                (ext_opcode == opc_ncload_char_oe) ||
                                (ext_opcode == opc_ncload_short_oe)) ? 1 : 0;
        little_endian_addr = IS_LE_ADDRESS (ext_address);

        little_endian = opposite_endian_inst ^ little_endian_addr;

        non_cacheable = ((ext_opcode == opc_ncload_short) || 
                         (ext_opcode == opc_ncload_char) ||
                         (ext_opcode == opc_ncload_short_oe) ||
                         (ext_opcode == opc_ncload_char_oe) ||
						 (IS_NC_ADDRESS (ext_address)));

        /* zero the top 2 bits of the address */
        ext_address &= 0x3FFFFFFF;

        if (non_cacheable)
        {
            READ_SHORT(ext_address, 'N', short_tmp)
        }
        else
        {
            READ_SHORT(ext_address, 'Z', short_tmp)
        }
         
        if (little_endian)
            SWAP_SHORT (short_tmp);

        if ((ext_opcode == opc_load_short) || 
            (ext_opcode == opc_ncload_short) ||
            (ext_opcode == opc_load_short_oe) || 
            (ext_opcode == opc_ncload_short_oe))
        {
            unsigned_tmp = (short) short_tmp;
        }
        else
        {
            unsigned_tmp = (unsigned short) short_tmp;
        }
            
        WRITE_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

        SIZE_AND_STACK_RETURN(2, 0);
      }

      case opc_load_word:
      case opc_ncload_word:
      case opc_load_word_oe:
      case opc_ncload_word_oe:
      {
        int opposite_endian_inst, little_endian_addr, little_endian;
		int non_cacheable;

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        CHECK_ADDRESS_ALIGNMENT(ext_address, 0x2);

        opposite_endian_inst = ((ext_opcode == opc_load_word_oe) || 
                                (ext_opcode == opc_ncload_word_oe)) ? 1 : 0;
        little_endian_addr = IS_LE_ADDRESS (ext_address);

        little_endian = opposite_endian_inst ^ little_endian_addr;

        non_cacheable = ((ext_opcode == opc_ncload_word) || 
                         (ext_opcode == opc_ncload_word_oe) ||
						 (IS_NC_ADDRESS (ext_address)));

        /* zero the top 2 bits of the address */
        ext_address &= 0x3FFFFFFF;

        if (non_cacheable)
        {
            READ_WORD (ext_address, 'N', unsigned_tmp);
        }
        else
        {
            READ_WORD (ext_address, 'Z', unsigned_tmp);
        }

        if (little_endian)
            SWAP_WORD (unsigned_tmp);

        WRITE_WORD (OPTOP_OFFSET (1), 'O', unsigned_tmp);

        SIZE_AND_STACK_RETURN(2, 0);
      }

      /* there is no store_ubyte etc since difference between byte and 
         ubyte is only for loads (sign extn. while widening) */

      case opc_store_byte:
      case opc_ncstore_byte:
      {
		int non_cacheable;

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);

        non_cacheable = ((ext_opcode == opc_ncstore_byte) || 
						 (IS_NC_ADDRESS (ext_address)));

        /* zero the top 2 bits of the address */
        ext_address &= 0x3FFFFFFF;

        READ_WORD (OPTOP_OFFSET (2), 'O', unsigned_tmp);
        char_tmp = (char) unsigned_tmp;
        if (non_cacheable)
        {
		    if (ext_address == DEBUGGER_SERIAL_PORT_ADDRESS)
			{
			     if (debugger_serial_port_write != NULL)
				     (*debugger_serial_port_write) (char_tmp);
			}
			else
			{
                WRITE_BYTE (ext_address, 'N', char_tmp);
			}
        }
        else
        {
            WRITE_BYTE (ext_address, 'Z', char_tmp);
        }

        SIZE_AND_STACK_RETURN(2, -2);
      }

      /* there is no store_char etc since difference between char and 
         short is only for loads (sign extn. while widening) */

      case opc_store_short:
      case opc_ncstore_short:
      case opc_store_short_oe:
      case opc_ncstore_short_oe:
      {
        int opposite_endian_inst, little_endian_addr, little_endian;
		int non_cacheable;

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);

        CHECK_ADDRESS_ALIGNMENT(ext_address, 0x1);

        opposite_endian_inst = ((ext_opcode == opc_store_short_oe) || 
                                (ext_opcode == opc_ncstore_short_oe)) ? 1 : 0;
        little_endian_addr = IS_LE_ADDRESS (ext_address);

        little_endian = opposite_endian_inst ^ little_endian_addr;

        non_cacheable = ((ext_opcode == opc_ncstore_short) || 
                         (ext_opcode == opc_ncstore_short_oe) ||
						 (IS_NC_ADDRESS (ext_address)));

        /* zero the top 2 bits of the address */
        ext_address &= 0x3FFFFFFF;

        READ_WORD (OPTOP_OFFSET (2), 'O', unsigned_tmp);
        short_tmp = (short) unsigned_tmp; 
        if (little_endian)
            SWAP_SHORT (short_tmp);

        if (non_cacheable)
        {
            WRITE_SHORT (ext_address, 'N', short_tmp);
        }
        else
        {
            WRITE_SHORT (ext_address, 'Z', short_tmp);
        }

        SIZE_AND_STACK_RETURN(2, -2);
      }

      case opc_store_word:
      case opc_ncstore_word:
      case opc_store_word_oe:
      case opc_ncstore_word_oe:
      {
        int opposite_endian_inst, little_endian_addr, little_endian;
		int non_cacheable;

        READ_WORD (OPTOP_OFFSET (1), 'O', ext_address);
        CHECK_ADDRESS_ALIGNMENT(ext_address, 0x2);

        opposite_endian_inst = ((ext_opcode == opc_store_word_oe) || 
                                (ext_opcode == opc_ncstore_word_oe)) ? 1 : 0;
        little_endian_addr = IS_LE_ADDRESS (ext_address);

        little_endian = opposite_endian_inst ^ little_endian_addr;

        non_cacheable = ((ext_opcode == opc_ncstore_word) || 
                         (ext_opcode == opc_ncstore_word_oe) ||
						 (IS_NC_ADDRESS (ext_address)));

        /* zero the top 2 bits of the address */
        ext_address &= 0x3FFFFFFF;

        READ_WORD (OPTOP_OFFSET (2), 'O', unsigned_tmp);
        if (little_endian)
            SWAP_WORD (unsigned_tmp);

        if (non_cacheable)
        {
            WRITE_WORD (ext_address, 'N', unsigned_tmp);
        }
        else
        {
            WRITE_WORD (ext_address, 'Z', unsigned_tmp);
        }

        if ((ext_opcode == opc_ncstore_word) ||
            (ext_opcode == opc_ncstore_word_oe))
        {
            if ((ext_address == END_ADDRESS) || 
                (ext_address == END_ADDRESS1))
            {
				end_of_simulation = 1;
				program_exit_code = unsigned_tmp;
                reportStatus (unsigned_tmp);
#ifdef TRACING
                if (p_pjsim_trace_finalize)
                    (*p_pjsim_trace_finalize) ();
#endif
            }
            else if (ext_address == EOI_ADDRESS)
            {   
			    /* write to this mailbox implies reset interrupts */
                uIRLState = 0;
                bNMIState = 0;
            }
            else if (ext_address == PROFILER_CMD_ADDR)
            {
                int profile_id;
                READ_WORD (PROFILER_DATA_ADDR, 'G', profile_id);
                if (profile_id == -1)
                    profile_id = current_profile_id;
 
                switch (unsigned_tmp)
                {
                  case PROFILE_CREATE_CMD:
                    profile_create (profile_id);
                    break;
                  case PROFILE_RESET_CMD:
                    profile_reset (profile_id);
                    break;
                  case PROFILE_FREEZE_CMD:
                    profile_freeze (profile_id, TRUE);
                    break;
                  case PROFILE_UNFREEZE_CMD:
                    profile_freeze (profile_id, FALSE);
                    break;
                  case PROFILE_ENABLE_CMD:
                    profile_enable (profile_id, TRUE);
                    break;
                  case PROFILE_DISABLE_CMD:
                    profile_enable (profile_id, FALSE);
                    break;
                  case PROFILE_SWITCH_CMD:
                    profile_switch (profile_id);
                    break;
                  case PROFILE_PRINT_CMD:
                    profile_print (profile_id, stdout);
                    break;
                  case PROFILE_CLOSE_CMD:
                    profile_close (profile_id);
                    break;
                  case PROFILE_MARK_BLOCK_ENTER_CMD:
                    mark_block_enter (profile_id, "USER_DEFINED_BLOCK", 
                                      FALSE, FALSE);
                    break;
                  case PROFILE_MARK_BLOCK_EXIT_CMD:
                    mark_block_exit (profile_id);
                    break;
                  default:
                    fprintf (stderr, "Warning: unknown command (%d) written to profiler "
                                     "command address, ignored\n", unsigned_tmp);
                }

            }
        }
        SIZE_AND_STACK_RETURN(2, -2);
      }

    }

    if (proc_type != pico)
    {
        switch (ext_opcode)
        {
          case opc_iucmp:
            {
              unsigned int v1, v2;
              int m1 = -1, one = 1, zero = 0;
  
              READ_WORD (OPTOP_OFFSET (1), 'O', v2);
              READ_WORD (OPTOP_OFFSET (2), 'O', v1);
             
              if (v1 == v2)
              {
                  WRITE_WORD (OPTOP_OFFSET (2), 'O', zero);
              }
              else if (v1 < v2)
              {
                  WRITE_WORD (OPTOP_OFFSET (2), 'O', m1);
              }
              else
              {
                  WRITE_WORD (OPTOP_OFFSET (2), 'O', one);
              }
            }
            SIZE_AND_STACK_RETURN (2, -1);
        }
    }

    /* if it falls thru here, it's an unknown extended opcode */

    fprintf (stderr, "Warning: ias seeing unimplemented (extended) instruction\
, extended opcode = 0x%x\n", (unsigned int) ext_opcode);
    LOW_PRIORITY_TRAP (illegal_instr);
    return;
}
