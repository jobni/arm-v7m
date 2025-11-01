/**
 ****************************************************************************************************
 * @file        gtim.h
 * @author      正点原子团队(ALIENTEK)
 * @version     V1.0
 * @date        2023-08-01
 * @brief       通用定时器 驱动代码
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


#ifndef __GTIM_H
#define __GTIM_H

#include "./SYSTEM/sys/sys.h"
#include "./SYSTEM/usart/usart.h"
#include "./BSP/LED/led.h"
#include "./BSP/PID/pid.h"

/* 通用定时器定义 */
#define GTIM_TIMX_CAP_CHY_GPIO_PORT            GPIOA
#define GTIM_TIMX_CAP_CHY_GPIO_PIN1             GPIO_PIN_0
#define GTIM_TIMX_CAP_CHY_GPIO_PIN2             GPIO_PIN_1
#define GTIM_TIMX_CAP_CHY_GPIO_CLK_ENABLE()    do{ __HAL_RCC_GPIOA_CLK_ENABLE(); }while(0)   /* PA口时钟使能 */

#define GTIM_TIMX_CAP                          TIM2                       
#define GTIM_TIMX_CAP_IRQn                     TIM2_IRQn
#define GTIM_TIMX_CAP_IRQHandler               TIM2_IRQHandler
#define GTIM_TIMX_CAP_CHY1                     TIM_CHANNEL_1                                 /* 通道Y,  1<= Y <=4 */
#define GTIM_TIMX_CAP_CHY_CCRX1                TIM2->CCR1                                    /* 通道Y的输出比较寄存器 */
#define GTIM_TIMX_CAP_CHY2                     TIM_CHANNEL_2                                 /* 通道Y,  1<= Y <=4 */
#define GTIM_TIMX_CAP_CHY_CCRX2                TIM2->CCR2                                    /* 通道Y的输出比较寄存器 */
#define GTIM_TIMX_CAP_CHY_CLK_ENABLE()         do{ __HAL_RCC_TIM2_CLK_ENABLE(); }while(0)    /* TIM2 时钟使能 */

/* 函数声明 */
void gtim_timx_cap_chy_init(uint16_t arr, uint16_t psc);                                    /* 通用定时器 输入捕获初始化函数 */

/*********************************以下是通用定时器PWM输出实验相关宏定义*************************************/

/* TIMX PWM输出定义 
 * 这里输出的PWM控制LED0(RED)的亮度 (需要一根杜邦线连接 PA1 和 PA8 !!!)
 * 默认是针对TIM2~TIM4
 * 注意: 
 * 1, 通过修改这几个宏定义,可以支持TIM1~TIM8任意一个定时器,任意一个IO口输出PWM
 * 1, TIM2_CH1通过PA0输出PWM, 但是我们的LED0接在PA8上, 所以需要用杜邦线链接 PA0 和 PA8, 从而控制LED0亮度
 */
#define GTIM_TIMY_PWM_CHY_GPIO_PORT         GPIOA
#define GTIM_TIMY_PWM_CHY_GPIO_PIN1         GPIO_PIN_6
#define GTIM_TIMY_PWM_CHY_GPIO_PIN2         GPIO_PIN_7
#define GTIM_TIMY_PWM_CHY_GPIO_CLK_ENABLE() do{ __HAL_RCC_GPIOA_CLK_ENABLE(); }while(0)   /* PA口时钟使能 */

#define GTIM_TIMY_PWM                       TIM3 
#define GTIM_TIMY_PWM_CHY1                  TIM_CHANNEL_1                                /* 通道Y,  1<= Y <=4 */
#define GTIM_TIMY_PWM_CHY_CCRX1             GTIM_TIMY_PWM->CCR1                          /* 通道Y的输出比较寄存器 */
#define GTIM_TIMY_PWM_CHY2                  TIM_CHANNEL_2                                /* 通道Y,  1<= Y <=4 */
#define GTIM_TIMY_PWM_CHY_CCRX2             GTIM_TIMY_PWM->CCR2                          /* 通道Y的输出比较寄存器 */
#define GTIM_TIMY_PWM_CHY_CLK_ENABLE()      do{ __HAL_RCC_TIM3_CLK_ENABLE(); }while(0)   /* TIM3 时钟使能 */

#define GTIM_TIMY_INT_IRQn                  TIM3_IRQn
#define GTIM_TIMY_INT_IRQHandler            TIM3_IRQHandler

extern PID_State pid_state_handle1;
extern PID_State pid_state_handle2;
//当前转数
extern double pwm_rpm1;
extern double pwm_rpm2;
//输出功率
extern double pwm_pulse1;
extern double pwm_pulse2;
//每圈转数
extern uint8_t rpm_cnt;

void gtim_timy_pwm_chy_init(uint16_t arr, uint16_t psc);    /* 通用定时器 PWM初始化函数 */
void gtim_timy_init(uint16_t arr, uint16_t psc);        /* 通用定时器 定时中断初始化函数 */

void gtim_pid_init(double kp,double ki,double kd, uint16_t target_rpm1, uint16_t target_rpm2);
void update_pwm_pulse1(int pwm_pulse);
void update_pwm_pulse2(int pwm_pulse);
void calc_pid1(double actual, double time_delta);
void calc_pid2(double actual, double time_delta);
#endif