// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

/**
 ******************************************************************************
 * @file    stm32f1xx_it.h
 * @brief   This file contains the headers of the interrupt handlers.
 ******************************************************************************
 */

#ifndef DRIVERS_PLATFORM_STM32F1XX_STM32F1XX_IT_H_
#define DRIVERS_PLATFORM_STM32F1XX_STM32F1XX_IT_H_

#ifdef __cplusplus
extern "C"
{
#endif
    void NMI_Handler(void);
    void HardFault_Handler(void);
    void MemManage_Handler(void);
    void BusFault_Handler(void);
    void UsageFault_Handler(void);
    void SVC_Handler(void);
    void DebugMon_Handler(void);
    void PendSV_Handler(void);
    void SysTick_Handler(void);
#ifdef __cplusplus
}
#endif

#endif // DRIVERS_PLATFORM_STM32F1XX_STM32F1XX_IT_H_
