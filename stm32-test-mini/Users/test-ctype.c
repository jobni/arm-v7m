# include "test-ctype.h"

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
