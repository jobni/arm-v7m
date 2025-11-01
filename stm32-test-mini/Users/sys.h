#include <stdint.h>
#include <stdarg.h>
#include <stdio.h>

#define SYSTEM_TICK 	        0x40000000
#define SYSTEM_SIGNAL           0x40000004
#define UART1_SR  	            0x40000100
#define UART1_DR	            0x40000104
#define FLASH_WRITE_ADDR	    0x40000200
#define FLASH_VERSION      	    0x40000204
#define CPU_STATUS              0x40000300

extern uint8_t cpu_ver;

uint32_t get_system_time();
void fput_char(char ch);
char fget_char(int32_t timeout);
