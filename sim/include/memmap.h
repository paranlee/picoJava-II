/*

Define the memory map.
This file should be the only place where these memory locations are
defined.

*/

#define CM_SIZE 0x01000000              /* 16M bytes for now */
#define SCRATCH_START 0x2fff0000
#define SCRATCH_SIZE 0x20000
#define C_START SCRATCH_START           /* cacheable memory scratch area */
#define C_SIZE 0x10000                  /* cacheable memory size */
#define NC_START 0x30000000             /* noncacheable scratch area */
#define NC_SIZE C_SIZE                  /* noncacheable memory size */
#define IO_START NC_START               /* io scratch area = noncacheable */
#define IO_SIZE NC_SIZE                 /* io size = nc size */
#define BAD_MEMORY_START 0x2fffbad0
#define BAD_IO_START 0x3000bad0
#define BAD_SIZE 16
#define CONSOLE_ADDR 0x2f0000c0
#define DEBUGGER_SERIAL_PORT_ADDRESS 0x2f0000e0
#define RESET_ADDRESS 0x0
#define TRAP_ADDRESS  0x00010000
#define CLASS_ADDRESS 0x00020000
#define FLUSH_LOCATION 0x0000fff0
#define TRAP_USE_LOCATION 0x0000ffec
#define WATERMARK_LOCATION 0x0000ffec
#define COSIM_LOCATION 0x0000ffe0
