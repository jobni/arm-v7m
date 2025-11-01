/**
 ****************************************************************************************************
 * @file        gtim.c
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

#include "./BSP/TIM/gtim.h"

TIM_HandleTypeDef g_timx_cap_chy_handle;      	/* 定时器x句柄 */
TIM_HandleTypeDef g_timy_pwm_chy_handle;     		/* 定时器y句柄 */
PID_Calibration pid_calibration_handle; 				/* pid参数 */
PID_State pid_state_handle1;										/* pid状态 */
PID_State pid_state_handle2;										/* pid状态 */

double pwm_rising_time1;
double pwm_rising_time2;
uint32_t pwm_rising_start_time1;
uint32_t pwm_rising_start_time2;
double pwm_rpm1;
double pwm_rpm2;
double pwm_pulse1;
double pwm_pulse2;
uint8_t pwm_rising_cnt1;
uint16_t pwm_rising_cnt1_all;
uint8_t pwm_rising_cnt2;
uint16_t pwm_rising_cnt2_all;
uint8_t rpm_cnt;

/* 输入捕获状态(g_timxchy_cap_sta)
 * [7]  :0,没有成功的捕获;1,成功捕获到一次.
 * [6]  :0,还没捕获到高电平;1,已经捕获到高电平了.
 * [5:0]:捕获高电平后溢出的次数,最多溢出63次,所以最长捕获值 = 63*65536 + 65535 = 4194303
 *       注意:为了通用,我们默认ARR和CCRy都是16位寄存器,对于32位的定时器(如:TIM5),也只按16位使用
 *       按1us的计数频率,最长溢出时间为:4194303 us, 约4.19秒
 *
 *      (说明一下：正常32位定时器来说,1us计数器加1,溢出时间:4294秒)
 */
uint32_t g_timxchy_cap_sta = 0;    /* 输入捕获状态 */

/**
 * @brief       通用定时器TIMX 通道Y 输入捕获 初始化函数
 * @note
 *              通用定时器的时钟来自APB1,当PPRE1 ≥ 2分频的时候
 *              通用定时器的时钟为APB1时钟的2倍, 而APB1为36M, 所以定时器时钟 = 72Mhz
 *              定时器溢出时间计算方法: Tout = ((arr + 1) * (psc + 1)) / Ft us.
 *              Ft=定时器工作频率,单位:Mhz
 *
 * @param       arr: 自动重装值
 * @param       psc: 时钟预分频数
 * @retval      无
 */
void gtim_timx_cap_chy_init(uint16_t arr, uint16_t psc)
{
    TIM_IC_InitTypeDef timx_ic_cap_chy = {0};

    g_timx_cap_chy_handle.Instance = GTIM_TIMX_CAP;                     /* 定时器2 */
    g_timx_cap_chy_handle.Init.Prescaler = psc;                         /* 定时器分频 */
    g_timx_cap_chy_handle.Init.CounterMode = TIM_COUNTERMODE_UP;        /* 递增计数模式 */
    g_timx_cap_chy_handle.Init.Period = arr;                            /* 自动重装载值 */
    HAL_TIM_IC_Init(&g_timx_cap_chy_handle);

    timx_ic_cap_chy.ICPolarity = TIM_ICPOLARITY_RISING;                 /* 上升沿捕获 */
    timx_ic_cap_chy.ICSelection = TIM_ICSELECTION_DIRECTTI;             /* 映射到TI1上 */
    timx_ic_cap_chy.ICPrescaler = TIM_ICPSC_DIV1;                       /* 配置输入分频，不分频 */
    timx_ic_cap_chy.ICFilter = 7;                                       /* 配置输入滤波器，不滤波 */
    HAL_TIM_IC_ConfigChannel(&g_timx_cap_chy_handle, &timx_ic_cap_chy, GTIM_TIMX_CAP_CHY1);  /* 配置TIM2通道1 */
    HAL_TIM_IC_ConfigChannel(&g_timx_cap_chy_handle, &timx_ic_cap_chy, GTIM_TIMX_CAP_CHY2);  /* 配置TIM2通道1 */

    __HAL_TIM_ENABLE_IT(&g_timx_cap_chy_handle, TIM_IT_UPDATE);         /* 使能更新中断 */
    HAL_TIM_IC_Start_IT(&g_timx_cap_chy_handle, GTIM_TIMX_CAP_CHY1);     /* 开始捕获TIM2的通道1 */
    HAL_TIM_IC_Start_IT(&g_timx_cap_chy_handle, GTIM_TIMX_CAP_CHY2);     /* 开始捕获TIM2的通道1 */
}

/**
 * @brief       通用定时器输入捕获初始化接口
                HAL库调用的接口，用于配置不同的输入捕获
 * @param       htim:定时器句柄
 * @note        此函数会被HAL_TIM_IC_Init()调用
 * @retval      无
 */
void HAL_TIM_IC_MspInit(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == GTIM_TIMX_CAP)                                /*输入通道捕获*/
    {
        GPIO_InitTypeDef gpio_init_struct;
        GTIM_TIMX_CAP_CHY_CLK_ENABLE();                                 /* 使能TIMx时钟 */
        GTIM_TIMX_CAP_CHY_GPIO_CLK_ENABLE();                            /* 开启捕获IO的时钟 */

        gpio_init_struct.Mode = GPIO_MODE_INPUT;                        /* 复用输入 */
        gpio_init_struct.Pull = GPIO_PULLUP;                          /* 上拉 */
        gpio_init_struct.Speed = GPIO_SPEED_FREQ_HIGH;                  /* 高速 */
			
        gpio_init_struct.Pin = GTIM_TIMX_CAP_CHY_GPIO_PIN1;              /* 输入捕获的GPIO口 */
        HAL_GPIO_Init(GTIM_TIMX_CAP_CHY_GPIO_PORT, &gpio_init_struct);
        gpio_init_struct.Pin = GTIM_TIMX_CAP_CHY_GPIO_PIN2;              /* 输入捕获的GPIO口 */
        HAL_GPIO_Init(GTIM_TIMX_CAP_CHY_GPIO_PORT, &gpio_init_struct);

        HAL_NVIC_SetPriority(GTIM_TIMX_CAP_IRQn, 1, 3);                 /* 抢占1，子优先级3 */
        HAL_NVIC_EnableIRQ(GTIM_TIMX_CAP_IRQn);                         /* 开启ITMx中断 */
    }
}

void restart_ic1(){
		pwm_rising_cnt1 = 0;
		pwm_rising_cnt1_all = 0;
		g_timxchy_cap_sta = 0;
}

void restart_ic2(){
		pwm_rising_cnt2 = 0;
		pwm_rising_cnt2_all = 0;
}

/**
 * @brief       定时器中断服务函数
 * @param       无
 * @retval      无
 */
void GTIM_TIMX_CAP_IRQHandler(void)
{
    HAL_TIM_IRQHandler(&g_timx_cap_chy_handle);  /* 定时器HAL库共用处理函数 */
}

/**
 * @brief       定时器输入捕获中断处理回调函数
 * @param       htim:定时器句柄指针
 * @note        该函数在HAL_TIM_IRQHandler中会被调用
 * @retval      无
 */
void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == GTIM_TIMX_CAP)
    {
				if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_1){
						pwm_rising_cnt1++;
						pwm_rising_cnt1_all++;
						uint32_t g_timxchy_cap_val1 = HAL_TIM_ReadCapturedValue(&g_timx_cap_chy_handle, GTIM_TIMX_CAP_CHY1);  /* 获取当前的捕获值 */
						if (pwm_rising_cnt1 > 1)                           /* 捕获到一个上升沿 */
						{
								pwm_rising_time1 = ((g_timxchy_cap_sta<<16) + g_timxchy_cap_val1 - pwm_rising_start_time1)/pwm_rising_cnt1;
								pwm_rpm1 = 60000000.0/(pwm_rising_time1 * rpm_cnt);
								//printf("pwm_rising_time1:%d pwm_rpm:%d g_timxchy_cap_sta:%X pwm_rising_start_time1:%d \r\n", (int)pwm_rising_time1, (int)pwm_rpm1, g_timxchy_cap_sta, pwm_rising_start_time1);
						}
						else /* 还未开始,第一次捕获上升沿 */
						{
								pwm_rising_start_time1 = (g_timxchy_cap_sta<<16) + g_timxchy_cap_val1;
						}
				}
				if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_2){
						pwm_rising_cnt2++;
						pwm_rising_cnt2_all++;
						uint32_t g_timxchy_cap_val2 = HAL_TIM_ReadCapturedValue(&g_timx_cap_chy_handle, GTIM_TIMX_CAP_CHY2);  /* 获取当前的捕获值 */
						if (pwm_rising_cnt2 > 1)                           /* 捕获到一个上升沿 */
						{
								pwm_rising_time2 = ((g_timxchy_cap_sta<<16) + g_timxchy_cap_val2 - pwm_rising_start_time2)/pwm_rising_cnt2;
								pwm_rpm2 = 60000000.0/(pwm_rising_time2 * rpm_cnt);
								//printf("pwm_rising_time2:%d pwm_rpm:%d g_timxchy_cap_sta:%X pwm_rising_start_time2:%d \r\n", (int)pwm_rising_time2, (int)pwm_rpm2, g_timxchy_cap_sta, pwm_rising_start_time2);
						}
						else /* 还未开始,第一次捕获上升沿 */
						{
								pwm_rising_start_time2 = (g_timxchy_cap_sta<<16) + g_timxchy_cap_val2;
						}
				}
    }
}

/**
 * @brief       定时器更新中断回调函数
 * @param        htim:定时器句柄指针
 * @note        此函数会被定时器中断函数共同调用的
 * @retval      无
 */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == GTIM_TIMX_CAP)
    {
				g_timxchy_cap_sta++;
    }else if(htim->Instance == GTIM_TIMY_PWM)
		{
				static uint16_t led_count = 0;
				led_count++;
				if(led_count==1){
					__HAL_TIM_DISABLE(&g_timx_cap_chy_handle);          /* 关闭定时器5 */
					__HAL_TIM_SET_COUNTER(&g_timx_cap_chy_handle, 0);   /* 定时器5计数器清零 */
					restart_ic1();
					restart_ic2();
					g_timxchy_cap_sta = 0;
					__HAL_TIM_ENABLE(&g_timx_cap_chy_handle);           /* 使能定时器5 */
				}
				if(led_count%10==0){
					usart_check();
				}
				if(led_count%500==0){
					LED0_TOGGLE();
					if(pwm_rising_cnt1>=3){
//						printf("led_count1:%d pwm_rising_cnt1:%d pwm_rpm1:%d\r\n", led_count, pwm_rising_cnt1, (int)pwm_rpm1);
						calc_pid1(pwm_rpm1, 1);
						pwm_rising_cnt1=0;
					}
					if(pwm_rising_cnt2>=3){
						//printf("led_count2:%d pwm_rising_cnt2:%d pwm_rpm2:%d\r\n", led_count, pwm_rising_cnt2, (int)pwm_rpm2);
						calc_pid2(pwm_rpm2, 1);
						pwm_rising_cnt2=0;
					}
					//printf("led_count3:%d pwm_rpm1:%d pwm_rpm2:%d\r\n", led_count, (int)pwm_rpm1, (int)pwm_rpm2);
				}
				if(led_count>1000){
					led_count=0;
					if (pwm_rising_cnt1_all==0){
						pwm_rpm1 = 0.0;
					}
					if (pwm_rising_cnt2_all==0){
						pwm_rpm2 = 0.0;
					}
				}
		}
}


/**
 * @brief       通用定时器TIMX 通道Y PWM输出 初始化函数（使用PWM模式1）
 * @note
 *              通用定时器的时钟来自APB1,当PPRE1 ≥ 2分频的时候
 *              通用定时器的时钟为APB1时钟的2倍, 而APB1为36M, 所以定时器时钟 = 72Mhz
 *              定时器溢出时间计算方法: Tout = ((arr + 1) * (psc + 1)) / Ft us.
 *              Ft=定时器工作频率,单位:Mhz
 *
 * @param       arr: 自动重装值。
 * @param       psc: 时钟预分频数
 * @retval      无
 */
void gtim_timy_pwm_chy_init(uint16_t arr, uint16_t psc)
{
		pwm_pulse1 = arr / 2;
		pwm_pulse2 = arr / 2;
    TIM_OC_InitTypeDef timx_oc_pwm_chy  = {0};                          /* 定时器PWM输出配置 */

    g_timy_pwm_chy_handle.Instance = GTIM_TIMY_PWM;                     /* 定时器 */
    g_timy_pwm_chy_handle.Init.Prescaler = psc;                         /* 定时器分频 */
    g_timy_pwm_chy_handle.Init.CounterMode = TIM_COUNTERMODE_UP;        /* 递增计数模式 */
    g_timy_pwm_chy_handle.Init.Period = arr;                            /* 自动重装载值 */
    HAL_TIM_PWM_Init(&g_timy_pwm_chy_handle);                           /* 初始化PWM */
    timx_oc_pwm_chy.OCMode = TIM_OCMODE_PWM1;                           /* 模式选择PWM1 */
    timx_oc_pwm_chy.OCPolarity = TIM_OCPOLARITY_HIGH;                    /* 输出比较极性为低 */
		
    timx_oc_pwm_chy.Pulse = pwm_pulse1;                                 /* 设置比较值,此值用来确定占空比 */
    HAL_TIM_PWM_ConfigChannel(&g_timy_pwm_chy_handle, &timx_oc_pwm_chy, GTIM_TIMY_PWM_CHY1); /* 配置TIMx通道y */
    HAL_TIM_PWM_Start(&g_timy_pwm_chy_handle, GTIM_TIMY_PWM_CHY1);       /* 开启对应PWM通道 */
		
    timx_oc_pwm_chy.Pulse = pwm_pulse2;                                 /* 设置比较值,此值用来确定占空比 */
    HAL_TIM_PWM_ConfigChannel(&g_timy_pwm_chy_handle, &timx_oc_pwm_chy, GTIM_TIMY_PWM_CHY2); /* 配置TIMx通道y */
    HAL_TIM_PWM_Start(&g_timy_pwm_chy_handle, GTIM_TIMY_PWM_CHY2);       /* 开启对应PWM通道 */
		
    HAL_NVIC_SetPriority(GTIM_TIMY_INT_IRQn, 1, 3);             				/* 设置中断优先级，抢占优先级1，子优先级3 */
    HAL_NVIC_EnableIRQ(GTIM_TIMY_INT_IRQn);                     				/* 开启ITMx中断 */
    HAL_TIM_Base_Start_IT(&g_timy_pwm_chy_handle);                      /* 使能定时器x和定时器x更新中断 */
}

void gtim_pid_init(double kp,double ki,double kd, uint16_t target_rpm1, uint16_t target_rpm2){
		pid_calibration_handle.kp = kp;
		pid_calibration_handle.ki = ki;
		pid_calibration_handle.kd = kd;
		pid_state_handle1.target = target_rpm1;
		pid_state_handle2.target = target_rpm2;
}

void update_pwm_pulse1(int pwm_pulse){
		__HAL_TIM_SET_COMPARE(&g_timy_pwm_chy_handle, GTIM_TIMY_PWM_CHY1, pwm_pulse);	
}

void update_pwm_pulse2(int pwm_pulse){
		__HAL_TIM_SET_COMPARE(&g_timy_pwm_chy_handle, GTIM_TIMY_PWM_CHY2, pwm_pulse);	
}

void calc_pid1(double actual, double time_delta){
		if(pid_calibration_handle.kp == 0.0){
			return;
		}
		pid_state_handle1.time_delta = time_delta;
		pid_state_handle1.actual = actual;
		pid_state_handle1 = pid_iterate(pid_calibration_handle, pid_state_handle1);
		pwm_pulse1 += pid_state_handle1.output;
		if(pwm_pulse1<0.0){
			pid_state_handle1.integral = 0.0;
			pid_state_handle1.previous_error = 0.0;
			pwm_pulse1 = 0.0;
			restart_ic1();
		}else if(pwm_pulse1>1000.0){
			pid_state_handle1.integral = 0.0;
			pid_state_handle1.previous_error = 0.0;
			pwm_pulse1 = 1000.0;
			restart_ic1();
		}
		//printf("pwm_rising_cnt:%d pwm_rising_time:%d actual:%d pwm_pulse:%d output:%f\r\n", pwm_rising_cnt1, (int)pwm_rising_time1,(int)actual, (int)pwm_pulse1, pid_state_handle1.output);
		/* 修改比较值控制占空比 */
		update_pwm_pulse1(pwm_pulse1);
}

void calc_pid2(double actual, double time_delta){
		if(pid_calibration_handle.kp == 0.0){
			return;
		}
		pid_state_handle2.time_delta = time_delta;
		pid_state_handle2.actual = actual;
		pid_state_handle2 = pid_iterate(pid_calibration_handle, pid_state_handle2);
		pwm_pulse2 += pid_state_handle2.output;
		if(pwm_pulse2<0.0){
			pid_state_handle2.integral = 0.0;
			pid_state_handle2.previous_error = 0.0;
			pwm_pulse2 = 0.0;
			restart_ic2();
		}else if(pwm_pulse2>1000.0){
			pid_state_handle2.integral = 0.0;
			pid_state_handle2.previous_error = 0.0;
			pwm_pulse2 = 1000.0;
			restart_ic2();
		}
		//printf("pwm_rising_cnt:%d pwm_rising_time:%d actual:%d pwm_pulse:%d output:%f\r\n", pwm_rising_cnt2, (int)pwm_rising_time2,(int)actual, (int)pwm_pulse2, pid_state_handle2.output);
		/* 修改比较值控制占空比 */
		update_pwm_pulse2(pwm_pulse2);
}

/**
 * @brief       定时器底层驱动，时钟使能，引脚配置
                此函数会被HAL_TIM_PWM_Init()调用
 * @param       htim:定时器句柄
 * @retval      无
 */
void HAL_TIM_PWM_MspInit(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == GTIM_TIMY_PWM)
    {
        GPIO_InitTypeDef gpio_init_struct;
        GTIM_TIMY_PWM_CHY_GPIO_CLK_ENABLE();                            /* 开启通道y的CPIO时钟 */
        GTIM_TIMY_PWM_CHY_CLK_ENABLE();

        gpio_init_struct.Mode = GPIO_MODE_AF_PP;                        /* 复用推挽输出 */
        gpio_init_struct.Pull = GPIO_PULLUP;                            /* 上拉 */
        gpio_init_struct.Speed = GPIO_SPEED_FREQ_HIGH;                  /* 高速 */
			
        gpio_init_struct.Pin = GTIM_TIMY_PWM_CHY_GPIO_PIN1;              /* 通道y的CPIO口 */
        HAL_GPIO_Init(GTIM_TIMY_PWM_CHY_GPIO_PORT, &gpio_init_struct);
			
        gpio_init_struct.Pin = GTIM_TIMY_PWM_CHY_GPIO_PIN2;              /* 通道y的CPIO口 */
        HAL_GPIO_Init(GTIM_TIMY_PWM_CHY_GPIO_PORT, &gpio_init_struct);
    }
}


/**
 * @brief       定时器中断服务函数
 * @param       无
 * @retval      无
 */
void GTIM_TIMY_INT_IRQHandler(void)
{
    HAL_TIM_IRQHandler(&g_timy_pwm_chy_handle);  /* 定时器HAL库共用处理函数 */
}

