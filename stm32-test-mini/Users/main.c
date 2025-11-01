#include <sys.h>
#include "math.h"

#define SOFT_VER 41

#define my_printf(fmt, arg...) printf(fmt, ##arg)
#define my_scanf(str, fmt, arg...) sscanf(str, fmt, ##arg)

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

char x_to_char(uint8_t i)
{
    switch(i){
        case 0:return '0';
        case 1:return '1';
        case 2:return '2';
        case 3:return '3';
        case 4:return '4';
        case 5:return '5';
        case 6:return '6';
        case 7:return '7';
        case 8:return '8';
        case 9:return '9';
        case 10:return 'A';
        case 11:return 'B';
        case 12:return 'C';
        case 13:return 'D';
        case 14:return 'E';
        case 15:return 'F';
        default:return 'X';
    }
}

void fput_x(uint8_t i)
{
    fput_char(x_to_char(i));
}

void print_x(uint32_t val)
{
    fput_char('0');
    fput_char('x');
    fput_x(val>>28);
    fput_x(val>>24 & 0xF);
    fput_x(val>>20 & 0xF);
    fput_x(val>>16 & 0xF);
    fput_x(val>>12 & 0xF);
    fput_x(val>>8 & 0xF);
    fput_x(val>>4 & 0xF);
    fput_x(val & 0xF);
}

void print_u(uint32_t val)
{
    uint8_t start=0;
    if(val>=1000000000u||start){
        fput_x(val/1000000000u);
        val %= 1000000000u;
        start = 1;
    }
    if(val>=100000000u||start){
        fput_x(val/100000000u);
        val %= 100000000u;
        start = 1;
    }
    if(val>=10000000u||start){
        fput_x(val/10000000u);
        val %= 10000000u;
        start = 1;
    }
    if(val>=1000000u||start){
        fput_x(val/1000000u);
        val %= 1000000u;
        start = 1;
    }
    if(val>=100000u||start){
        fput_x(val/100000u);
        val %= 100000u;
        start = 1;
    }
    if(val>=10000u||start){
        fput_x(val/10000u);
        val %= 10000u;
        start = 1;
    }
    if(val>=1000u||start){
        fput_x(val/1000u);
        val %= 1000u;
        start = 1;
    }
    if(val>=100u||start){
        fput_x(val/100u);
        val %= 100u;
        start = 1;
    }
    if(val>=10u||start){
        fput_x(val/10u);
        val %= 10u;
        start = 1;
    }
    fput_x(val);
}

void print_d(int32_t val)
{
    if(val<0){
        fput_char('-');
        print_u(-val);
    }else{
        print_u(val);
    }
}

int xi_printf(const char* format, ...)
{
    int result=0;
    va_list args;
    va_start(args, format);
    while(*format!='\0'){
        if(*format=='%'){
            format++;
            if(*format=='d'){
                print_d(va_arg(args, int32_t));
                result++;
            }else if(*format=='x'||*format=='X'){
                print_x(va_arg(args, uint32_t));
                result++;
            }else if(*format=='u'){
                print_u(va_arg(args, uint32_t));
                result++;
            }else if(*format=='c'){
                fput_char(va_arg(args, uint32_t));
                result++;
            }else if(*format=='s'){
                print_uart(va_arg(args, char*));
                result++;
            }else if(*format=='%'){
                print_uart("%");
                result++;
            }else{
                print_uart("<%error%>");
            }
        }else{
            fput_char(*format);
        }
        format++;
    }
    va_end(args);
    return result;
}

int scan_s(char** scan_str_p, char* val)
{
    return 0;
}

int scan_c(char** scan_str_p, char* val)
{
    if(**scan_str_p!='\0'){
        *val=**scan_str_p;
        (*scan_str_p)++;
        return 1;
    }else{
        return 0;
    }
}

int scan_x(char** scan_str_p, uint32_t* val)
{
    return 0;
}

int scan_u(char** scan_str_p, uint32_t* val)
{
    int result=0;
    uint8_t tmp;
    *val=0;
    while(**scan_str_p>='0'&&**scan_str_p<='9'){
        tmp = (**scan_str_p)-'0';
        *val=(*val)*10;
        *val=*val+tmp;
        result=1;
        (*scan_str_p)++;
    }
    return result;
}

int scan_d(char** scan_str_p, int32_t* val)
{
    if(**scan_str_p=='-'){
        (*scan_str_p)++;
        int result=0;
        result = scan_u(scan_str_p, (uint32_t*)val);
        *val = -*val;
        return result;
    }else if(**scan_str_p=='+'){
        (*scan_str_p)++;
        return scan_u(scan_str_p, (uint32_t*)val);
    }else{
        return scan_u(scan_str_p, (uint32_t*)val);
    }
}

int xi_scanf(const char *format, ...)
{
    va_list args;
    va_start(args, format);
    char* scan_str;
    char** scan_str_p;
    int result=0;
    scan_uart(&read_str[0], sizeof(read_str));
    
    //my_printf("read_str:%s", read_str);
    scan_str_p = &scan_str;
    scan_str = &read_str[0];
    while(*format!='\0'){
        if(*format=='%'){
            format++;
            if(*format=='u'){
                result+=scan_d(scan_str_p, va_arg(args, int32_t*));
            }else if(*format=='d'){
                result+=scan_d(scan_str_p, va_arg(args, int32_t*));
            }else if(*format=='x'){
                result+=scan_x(scan_str_p, va_arg(args, uint32_t*));
            }else if(*format=='c'){
                result+=scan_c(scan_str_p, va_arg(args, char*));
            }else if(*format=='s'){
                result+=scan_s(scan_str_p, va_arg(args, char*));
            }
        }else{
            if(*format!=*scan_str){
                break;
            }
            scan_str++;
        }
        format++;
    }
    va_end(args);
    return result;
}

void sleep(uint32_t sleep_time)
{
    my_printf("sleep %u ms start >> ", sleep_time);
    uint32_t start_time;
    start_time = get_system_time();
    while(get_system_time()-start_time<sleep_time);
    my_printf("sleep end\r\n");
}

void scan_calc_d(){
    uint32_t a;
    uint32_t b;
    char c;
    uint32_t r;
    volatile uint32_t* system_signal;
    my_printf("please input int +-*/=\r\n");
    system_signal = (uint32_t*)SYSTEM_SIGNAL;
    *system_signal=1;
    *system_signal=0;
    scan_uart(&read_str[0], sizeof(read_str));
    my_printf("%s", read_str);
    r = my_scanf(read_str, "%d%c%d=", &a, &c, &b);
    if(c=='+'){
        my_printf("%d+%d=%d\r\n", a,b,a+b);
    }else if(c=='-'){
        my_printf("%d-%d=%d\r\n", a,b,a-b);
    }else if(c=='*'){
        my_printf("%d*%d=%d\r\n", a,b,a*b);
    }else if(c=='/'){
        my_printf("%d/%d=%d %% %d\r\n", a,b,a/b,a%b);
    }else if(c=='&'){
        my_printf("%x&%x=%x\r\n", a,b,a&b);
    }else if(c=='|'){
        my_printf("%x|%x=%x\r\n", a,b,a|b);
    }else if(c=='^'){
        my_printf("%x^%x=%x\r\n", a,b,a^b);
    }else{
        my_printf("not_support:<%u> <%d><%c><%d>=", r, a, c, b);
    }
}

void scan_calc_f(){
    float a;
    float b;
    char c;
    float r;
    volatile uint32_t* system_signal;
    my_printf("please input float +-*/=\r\n");
    system_signal = (uint32_t*)SYSTEM_SIGNAL;
    *system_signal=2;
    *system_signal=0;
    scan_uart(&read_str[0], sizeof(read_str));
    my_printf("%s", read_str);
    r = my_scanf(read_str, "%f%c%f=", &a, &c, &b);
    if(c=='+'){
        my_printf("%f+%f=%f\r\n", a,b,a+b);
    }else if(c=='-'){
        my_printf("%f-%f=%f\r\n", a,b,a-b);
    }else if(c=='*'){
        my_printf("%f*%f=%f\r\n", a,b,a*b);
    }else if(c=='/'){
        my_printf("%f/%f=%f\r\n", a,b,a/b);
    }else{
        my_printf("r:%f not support:%f%c%f=", r, a, c, b);
    }
}

void test_float()
{
    float f_v1=0.987654321;
    float f_v2=0.123456789;
    float f_v;
    static char str[50];
    uint32_t index=0;
    f_v=f_v1*f_v2;
    sprintf(str,"test float:%f\r\n", f_v);
    my_printf("%s", str);
}

void test_double()
{
    double d_v1=1.23456789987651;
    double d_v2=0.5357924682336;
    double d_v;
    double d_c;
    static char str[50];
    d_v=d_v1*d_v2;
    sprintf(str,"test double1:%.14f\r\n", d_v);
    my_printf("%s", str);
    d_c=acos(d_v);
    sprintf(str,"test double2:%.10f\r\n", d_c);
    my_printf("%s", str);
    
}
void test2()
{
    int32_t a;
    int32_t b;
    char c;
    uint32_t r;
    my_printf("please input ex.:21+35=\r\n");
    while(1)
    {
        scan_calc_d();
    }
}

void test3()
{
    float a=1.234567;
    float b=7.654321;
    float c=0.0;
    printf("test3:");
    c=a/b;
    my_printf("<a/b=%f>", c);
    my_printf("<a:%f><b:%f>", a, b);
    c=a+b;
    my_printf("<a+b=%f>", c);
    c=a-b;
    my_printf("<a-b=%f>", c);
    c=a*b;
    my_printf("<a*b=%f>", c);
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
//    uint32_t* systick_ctrl;
//    //¹Ø±ÕµÎ´ð¶¨Ê±Æ÷
//    systick_ctrl=(uint32_t*)0xE000E010;
//    *systick_ctrl&=~0x01;
    check_cpu();
    my_printf("SystemInit end!\r\n");
}

int main(void){
    uint32_t flash_ver;
    check_cpu();
    flash_ver=get_flash_ver();
    my_printf("soft_ver:%u cpu_ver:%u flash_ver:%x\r\n", SOFT_VER, cpu_ver, flash_ver);
    //test_float();
    test_double();
    sleep(500);
//    scan_calc_d();
//    test3();
//    int32_t a=-3;
//    int32_t b=9;
//    uint32_t c=25;
//    uint32_t d=3;
//    my_printf("a-b=%d a+b=%d", a-b, a+b);
//    my_printf("c*d=%u c/d=%u %% %u\n", c*d, c/d, c%d);
//    my_printf("a*b=%d a/b=%d %% %d\n", a*b, a/b, a%b);
    
    //test2();
    while(1){
        scan_calc_f();
        my_printf("scan over!");
    }
}
