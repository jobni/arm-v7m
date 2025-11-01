/**
 ****************************************************************************************************
 * @file        adc.h
 * @author      正点原子团队(ALIENTEK)
 * @version     V1.0
 * @date        20223-08-01
 * @brief       ADC 驱动代码
 * @license     Copyright (c) 2020-2032, 广州市星翼电子科技有限公司
 ****************************************************************************************************
 * @attention
 *
 * 实验平台:正点原子 M48Z-M3最小系统板STM32F103版
 * 在线视频:www.yuanzige.com
 * 技术论坛:www.openedv.com
 * 公司网址:www.alientek.com
 * 购买地址:openedv.taobao.com
 *
 ****************************************************************************************************
 */

#ifndef __ADC_H
#define __ADC_H

#include "./SYSTEM/sys/sys.h"
#include "./SYSTEM/delay/delay.h"


/******************************************************************************************/
/* ADC及引脚 定义 */

#define ADC_ADCX_CHY_GPIO_PORT              GPIOA
#define ADC_ADCX_CHY_GPIO_PIN               GPIO_PIN_1
#define ADC_ADCX_CHY_GPIO_CLK_ENABLE()      do{ __HAL_RCC_GPIOA_CLK_ENABLE(); }while(0)         /* PC口时钟使能 */

#define ADC_ADCX                            ADC1 
#define ADC_ADCX_CHY                        ADC_CHANNEL_1                                       /* 通道Y,  0 <= Y <= 17 */ 
#define ADC_ADCX_CHY_CLK_ENABLE()           do{ __HAL_RCC_ADC1_CLK_ENABLE(); }while(0)          /* ADC1 时钟使能 */

/******************************************************************************************/
/* ADC3温度传感器通道 定义 */
#define ADC_TEMPSENSOR_CHX                  ADC_CHANNEL_16

/* 函数声明 */
void adc_init(void);                                                                            /* ADC初始化 */
void adc_channel_set(ADC_HandleTypeDef *adc_handle, uint32_t ch,uint32_t rank, uint32_t stime); /* ADC通道设置 */
uint32_t adc_get_result(uint32_t ch);                                                           /* 获得某个通道值  */
uint32_t adc_get_result_average(uint32_t ch, uint8_t times);                                    /* 得到某个通道给定次数采样的平均值 */

void adc_temperature_init(void);    /* 初始化ADC内部温度传感器 */
int16_t adc_get_temperature(void);  /* 获取内部温度传感器温度值 */

#endif