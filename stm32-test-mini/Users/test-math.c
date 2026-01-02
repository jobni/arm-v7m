#include "test-math.h"

void test_math_float()
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
    
    f_c=acosf(f_v);
    assert(f_c==1.44546854f);
    printf("test float acosf OK\n");
    
    f_c=asinf(f_v);
    assert(f_c==0.125327826f);
    printf("test float asinf OK\n");
    
    f_c=atanf(f_v);
    assert(f_c==0.124354996f);
    printf("test float atanf OK\n");
    
    f_c=atan2f(f_v,1.2356);
    assert(f_c==0.100822411f);
    printf("test float atan2f OK\n");
    
    f_c=cosf(f_v);
    assert(f_c==0.992197692f);
    printf("test float cos OK\n");
    
    f_c=coshf(f_v);
    assert(f_c==1.00782263f);
    printf("test float cosh OK\n");
    
    f_c=sinf(f_v);
    assert(f_c==0.12467473f);
    printf("test float sin OK\n");
    
    f_c=sinhf(f_v);
    assert(f_c==0.125325769f);
    printf("test float sinh OK\n");
    
    f_c=tanf(f_v);
    assert(f_c==0.12565513f);
    printf("test float tanf OK\n");
    
    f_c=tanhf(f_v);
    assert(f_c==0.124352999f);
    printf("test float tanhf OK\n");
    
    f_c=expf(f_v);
    assert(f_c==1.13314843f);
    printf("test float expf OK\n");
    
    f_c=ldexpf(f_v, 25);
    assert(f_c==4194304.0f);
    printf("test float ldexpf OK\n");
    
    f_c=logf(f_v);
    printf("%f",f_c);
    assert(f_c==-2.07944155f);
    printf("test float logf OK\n");
    
    f_c=log10f(f_v);
    assert(f_c==-0.90309f);
    printf("test float log10f OK\n");
    
    f_c=powf(f_v, f_v);
    assert(f_c==0.771105409f);
    printf("test float powf OK\n");
    
    f_c=sqrtf(f_v);
    assert(f_c==0.353553385f);
    printf("test float sqrtf OK\n");
    
    f_c=ceilf(f_v);
    printf("%f",f_c);
    assert(f_c==1.0f);
    printf("test float ceilf OK\n");
    
    f_c=fabsf(f_v);
    printf("%f",f_c);
    assert(f_c==0.125f);
    printf("test float fabsf OK\n");
    
    f_c=floor(f_v);
    printf("%f",f_c);
    assert(f_c==0.0f);
    printf("test float floor OK\n");
    
    f_c=fmodf(f_v, 0.02314f);
    assert(f_c==0.0092999991f);
    printf("test float fmodf OK\n");
}

void test_math_double()
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
    
    d_c=cosh(d_v);
    assert(d_c==1.095661934921631);
    printf("test double cosh OK\n");
    
    d_c=ldexp(d_v, 25);
    assert(d_c==14562351.688598739);
    printf("test double ldexp OK\n");
    
    d_c=fmod(d_v, 0.02314f);
    assert(d_c==0.017471896517239183);
    printf("test double fmod OK\n");
    
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
