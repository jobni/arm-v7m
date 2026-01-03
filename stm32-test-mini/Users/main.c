#include "test-ctype.h"
#include "test-math.h"

#define SOFT_VER 46

char read_str[1024]="15*21=";

uint32_t get_flash_write_addr()
{
    volatile uint32_t* flash_write_addr;
    flash_write_addr = (uint32_t*)FLASH_WRITE_ADDR;
    return *flash_write_addr;
}

uint32_t get_flash_ver()
{
    volatile uint32_t* flash_ver;
    flash_ver = (uint32_t*)FLASH_VERSION;
    return *flash_ver;
}

void print_uart(char *ch)
{
    while(*ch)
    {
        fput_char(*ch);
        ch++;
    }
}

void scan_uart(char *ch, uint16_t len)
{
    *ch = fget_char(-1);
    while(*ch)
    {
        ch++;
        *ch = fget_char(100);
    }
}

void sleep(uint32_t sleep_time)
{
    printf("sleep %u ms start >> ", sleep_time);
    uint32_t start_time;
    start_time = get_system_time();
    while(get_system_time()-start_time<sleep_time);
    printf("sleep end\n");
}

void scan_calc_d(){
    uint32_t a;
    uint32_t b;
    char c;
    uint32_t r;
    volatile uint32_t* system_signal;
    printf("please input int +-*/=\n");
    system_signal = (uint32_t*)SYSTEM_SIGNAL;
    *system_signal=1;
    *system_signal=0;
    scan_uart(&read_str[0], sizeof(read_str));
    printf("%s", read_str);
    r = scanf(read_str, "%d%c%d=", &a, &c, &b);
    if(c=='+'){
        printf("%d+%d=%d\n", a,b,a+b);
    }else if(c=='-'){
        printf("%d-%d=%d\n", a,b,a-b);
    }else if(c=='*'){
        printf("%d*%d=%d\n", a,b,a*b);
    }else if(c=='/'){
        printf("%d/%d=%d %% %d\n", a,b,a/b,a%b);
    }else if(c=='&'){
        printf("%x&%x=%x\n", a,b,a&b);
    }else if(c=='|'){
        printf("%x|%x=%x\n", a,b,a|b);
    }else if(c=='^'){
        printf("%x^%x=%x\n", a,b,a^b);
    }else{
        printf("not_support:<%u> <%d><%c><%d>=", r, a, c, b);
    }
}

void scan_calc_f(){
    float a;
    float b;
    char c;
    float r;
    volatile uint32_t* system_signal;
    printf("please input float +-*/=\n");
    system_signal = (uint32_t*)SYSTEM_SIGNAL;
    *system_signal=2;
    *system_signal=0;
    scan_uart(&read_str[0], sizeof(read_str));
    printf("%s", read_str);
    r = scanf(read_str, "%f%c%f=", &a, &c, &b);
    if(c=='+'){
        printf("%f+%f=%f\n", a,b,a+b);
    }else if(c=='-'){
        printf("%f-%f=%f\n", a,b,a-b);
    }else if(c=='*'){
        printf("%f*%f=%f\n", a,b,a*b);
    }else if(c=='/'){
        printf("%f/%f=%f\n", a,b,a/b);
    }else{
        printf("r:%f not support:%f%c%f=", r, a, c, b);
    }
}

void check_cpu(){
    volatile uint32_t* cpu_status;
    cpu_status = (uint32_t*)CPU_STATUS;
    if(*cpu_status==0x20250202){
        cpu_ver = 1;
    }else{
        cpu_ver = 0;
    }
}

void SystemInit (void)
{
    uint32_t* systick_ctrl;
    //¹Ø±ÕµÎ´ð¶¨Ê±Æ÷
    systick_ctrl=(uint32_t*)0xE000E010;
    *systick_ctrl&=~0x01;
    check_cpu();
    printf("SystemInit end!\n");
}

int main(void){
    static uint32_t index;
    static uint32_t flash_ver;
    check_cpu();
    flash_ver=get_flash_ver();
    printf("soft_ver:%u cpu_ver:%u flash_ver:%x\n", SOFT_VER, cpu_ver, flash_ver);
    test_bit_field();
    test_ctype();
    //test_math_float();
    test_math_double();
    sleep(100);
    index = 0;
    
    assert(1==0);
    while(1){
        index++;
        scan_calc_d();
        scan_calc_f();
        printf("scan over index:%d!", index);
    }
}
