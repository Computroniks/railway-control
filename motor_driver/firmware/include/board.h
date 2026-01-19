// SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
// SPDX-License-Identifier: MIT

#ifndef BOARD_H_
#define BOARD_H_

// HAL Selection
#if defined(STM32F1xx)
#include "stm32f1xx_hal.h"
#else
#error "You must specify the target MCU"
#endif

#if defined(STM32F1xx)
#define LED_GPIO_PORT GPIOC
#define LED_GPIO_PIN GPIO_PIN_13
#endif

#endif // BOARD_H_