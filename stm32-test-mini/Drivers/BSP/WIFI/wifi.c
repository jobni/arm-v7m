#include "./BSP/WIFI/wifi.h"

void wifi_init(void)
{
    GPIO_InitTypeDef gpio_init_struct;
    WIFI_GPIO_CLK_ENABLE();                                 /* WIFI时钟使能 */

    gpio_init_struct.Pin = WIFI_GPIO_PIN;                   /* WIFI引脚 */
    gpio_init_struct.Mode = GPIO_MODE_INPUT;            		/* 推挽输出 */
    gpio_init_struct.Pull = GPIO_PULLUP;                    /* 上拉 */
    
    gpio_init_struct.Speed = GPIO_SPEED_FREQ_HIGH;          /* 高速 */
    HAL_GPIO_Init(WIFI_GPIO_PORT, &gpio_init_struct);       /* 初始化WIFI引脚 */
}