/* Trigger address for call to syscall lib */
#define PICO_IO_CALL_ADDR_L 0xffe8
#define PICO_IO_CALL_ADDR_H 0x0000

/* 1-byte operation code, written into the trigger address */
#define CONSOLE_OPERATION   0x0
#define FILE_OPERATION      0x1

/* High address (for all operations other than trigger address writes) */
#define PICO_IO_ADDR_H      0x2fff

/* Low Addresses for picoJava I/O print utilities args */
#define CONSOLE_TYPE_ADDR   0x0000 
#define CONSOLE_DATA_ADDR_1 0x0004
#define CONSOLE_DATA_ADDR_2 0x0008  

/* Low Addresses for picoJava I/O file utilites */
#define FILE_OPERATION_ADDR 0x0000

