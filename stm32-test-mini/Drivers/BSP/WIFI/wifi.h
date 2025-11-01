#ifndef __WIFI_H
#define __WIFI_H
#include "./SYSTEM/sys/sys.h"


/******************************************************************************************/
/* 引脚 定义 */

#define WIFI_GPIO_PORT                  GPIOA
#define WIFI_GPIO_PIN                   GPIO_PIN_4
#define WIFI_GPIO_CLK_ENABLE()          do{ __HAL_RCC_GPIOA_CLK_ENABLE(); }while(0)             /* PA口时钟使能 */


/* LED取反定义 */
#define WIFI_IS_ON()   HAL_GPIO_ReadPin(WIFI_GPIO_PORT, WIFI_GPIO_PIN) == GPIO_PIN_RESET			  /* 判断WIFI连接成功 */

#define BLUETOOTH_IS_ON() HAL_GPIO_ReadPin(WIFI_GPIO_PORT, WIFI_GPIO_PIN) == GPIO_PIN_SET			  /* 判断bluetooth连接成功 */

/******************************************************************************************/
/* 外部接口函数*/
void wifi_init(void);                                                                           /* 初始化 */

#endif
