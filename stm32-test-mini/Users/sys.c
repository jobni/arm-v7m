#include <sys.h>

__asm(".global __use_no_semihosting\n\t");
uint8_t cpu_ver;
uint16_t read_test_index;
extern char read_str[];

int _ttywrch(int ch)
{
    ch = ch;
    return ch;
}

void _sys_exit(int x)
{
}

FILE __stdout;
FILE __stdin;
uint32_t temp_tck;

uint32_t get_system_time()
{
    volatile uint32_t *system_tick;
    if(cpu_ver==0){
        temp_tck++;
        return temp_tck;
    }else{
        system_tick = (uint32_t*) SYSTEM_TICK;
        return *system_tick;
    }
}

void fput_char(char ch)
{
    uint32_t start_time;
    volatile uint32_t* uart1_sr;
    volatile uint32_t* uart1_dr;
    uart1_sr = (uint32_t*)UART1_SR;
    uart1_dr = (uint32_t*)UART1_DR;
    start_time = get_system_time();
    while((*uart1_sr & 0x40) == 0){
        if(cpu_ver==0)
        {
            break;
        }
    }
    *uart1_dr = ch;
}

char fget_char(int32_t timeout)
{
    uint32_t start_time;
    char ch;
    volatile uint32_t* uart1_sr;
    volatile uint32_t* uart1_dr;
    uart1_sr = (uint32_t*)UART1_SR;
    uart1_dr = (uint32_t*)UART1_DR;
    start_time = get_system_time();
    if(cpu_ver==0){
        if(timeout<0){
            read_test_index = 0;
        }
        ch = read_str[read_test_index];
        read_test_index++;
    }else{
        while((*uart1_sr & 0x20) == 0){
            if(timeout>=0 && get_system_time()-start_time>=timeout)
            {
                return 0;
            }
        }
        ch = *uart1_dr;
        *uart1_sr = 0;
    }
    return ch;
}

int fputc(int ch, FILE *f)
{	
    fput_char(ch);
    return ch;
}

int fgetc(FILE *f)
{
    return fget_char(1000);
}
