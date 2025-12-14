#include <sys.h>
#include <assert.h>
#include "math.h"

#define SOFT_VER 44

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

void test_float()
{
    static float f_v1=0.123456789;
    static float f_v2=0.987654321;
    static float f_v;
    static float f_c;
    static char str[50];
    uint32_t index=0;
    f_v=f_v1*f_v2;
    assert(f_v==0.121932633f);
    printf("test float * OK\n");
    
    f_v=f_v1/f_v2;
    assert(f_v==0.125f);
    printf("test float / OK\n");
    
    f_c=ldexpf(f_v, 25);
    assert(f_c==4194304.0f);
    printf("test float ldexpf OK\n");
    
    f_c=fmodf(f_v, 0.02314f);
    assert(f_c==0.0092999991f);
    printf("test float fmodf OK\n");
    
    f_c=asinf(f_v);
    assert(f_c==0.125327826f);
    printf("test float asinf OK\n");
    
    f_c=acosf(f_v);
    assert(f_c==1.44546854f);
    printf("test float acosf OK\n");
    
    f_c=tanf(f_v);
    assert(f_c==0.12565513f);
    printf("test float tanf OK\n");
    
    f_c=expf(f_v);
    assert(f_c==1.13314843f);
    printf("test float expf OK\n");
    
    f_c=powf(f_v, f_v);
    assert(f_c==0.771105409f);
    printf("test float powf OK\n");
    
    f_c=sqrtf(f_v);
    assert(f_c==0.353553385f);
    printf("test float sqrtf OK\n");
}

void test_double()
{
    static double d_v1=0.5357924682336;
    static double d_v2=1.23456789987651;
    static double d_v;
    static double d_c;
    static char str[50];
    d_v=d_v1*d_v2;
    assert(d_v==0.6614721822768073);
    printf("test double * OK\n");
    
    d_v=d_v1/d_v2;
    assert(d_v==0.43399189974661884);
    printf("test double / OK\n");
    
    d_c=ldexp(d_v, 25);
    assert(d_c==14562351.688598739);
    printf("test float ldexp OK\n");
    
    d_c=fmod(d_v, 0.02314f);
    assert(d_c==0.017471896517239183);
    printf("test float fmod OK\n");
    
    d_c=asin(d_v);
    assert(d_c==0.44891900322483796);
    printf("test double asin OK\n");
    
    d_c=acos(d_v);
    assert(d_c==1.1218773235700588);
    printf("test double acos OK\n");
    
    d_c=tan(d_v);
    assert(d_c==0.46346143984841026);
    printf("test double tan OK\n");
    
    d_c=exp(d_v);
    assert(d_c==1.543406366083217);
    printf("test double exp OK\n");
    
    d_c=pow(d_v, d_v);
    assert(d_c==0.6960973191288687);
    printf("test double powf OK\n");
    
    d_c=sqrtf(d_v);
    assert(d_c==0.6587806344032288);
    printf("test double sqrtf OK\n");
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
    test_float();
    test_double();
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
