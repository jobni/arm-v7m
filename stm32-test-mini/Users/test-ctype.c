# include "test-ctype.h"

struct{
    unsigned int test1 :4;
    signed int test2 :8;
    unsigned int test3:20;
} status = {0, 0, 0};

void test_bit_field()
{
    static uint16_t a;
    a = 4;
    a +=4;
    assert(a==8);
    status.test1 = 5;
    status.test2 = a;
    status.test3 = 1;
    a = status.test1+status.test2;
    assert(a ==13);
    printf("test bit field OK\n");
}

void test_ctype(void)
{
    assert(isalnum('7'));
    assert(isalpha('B'));
    assert(iscntrl('\n'));
    assert(isdigit('5'));
    assert(isgraph('z'));
    assert(islower('v'));
    assert(isprint('@'));
    assert(ispunct('.'));
    assert(isspace(' '));
    assert(isupper('V'));
    assert(isxdigit('F'));
    assert('v'==tolower('V'));
    assert('V'==toupper('v'));
    printf("test ctype OK!");
}
