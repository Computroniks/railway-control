# SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
# SPDX-License-Identifier: MIT

# Usage:
# stm32_parse_part(
#   STM32F103C8
#   OUT_TYPE        # F
#   OUT_SUBFAMILY   # 103
#   OUT_SERIES      # F1
#   OUT_CORE        # M3
#   OUT_PIN_CODE    # C
#   OUT_FLASH_CODE  # 8
#   OUT_FLASH_KB    # 64
# )
function(stm32_parse_part PART_NUMBER
    OUT_TYPE
    OUT_SUBFAMILY
    OUT_SERIES
    OUT_CORE
    OUT_PIN_CODE
    OUT_FLASH_CODE
    OUT_FLASH_KB
)
    string(STRIP "${PART_NUMBER}" PART_NUMBER)  
    string(TOUPPER "${PART_NUMBER}" PART)

    # Match: STM32<type letter><subfamily><pin count><flash>
    # Example: STM32F103C8
    if (NOT "${PART}" MATCHES "^STM32([A-Z])([0-9][0-9][0-9])([A-Z])([A-Z0-9])$")
        message(FATAL_ERROR "Invalid STM32 part number: ${PART_NUMBER}")
    endif()

    set(TYPE "${CMAKE_MATCH_1}")
    set(SUBFAMILY   "${CMAKE_MATCH_2}")
    set(PIN_CODE   "${CMAKE_MATCH_3}")
    set(FLASH_CODE "${CMAKE_MATCH_4}")

    # Determine core from family+type
    string(SUBSTRING ${SUBFAMILY} 0 1 SERIES_NUMBER)
    set(CORE "")
    if (TYPE STREQUAL "C")
        set(CORE "M0+")
    elseif (TYPE STREQUAL "F")
        if (SERIES_NUMBER STREQUAL "1")
            set(CORE "M3")
        elseif (SERIES_NUMBER STREQUAL "3")
            set(CORE "M4")
        elseif (SERIES_NUMBER STREQUAL "4")
            set(CORE "M4")
        endif()
    endif()

    if (CORE STREQUAL "")
        message(FATAL_ERROR "Unable to determine core for ${PART_NUMBER}. Is it supported?")
    endif()

    # Flash size mapping (KB)
    set(FLASH_KB "")
    if (FLASH_CODE STREQUAL "4")
        set(FLASH_KB 16)
    elseif (FLASH_CODE STREQUAL "6")
        set(FLASH_KB 32)
    elseif (FLASH_CODE STREQUAL "8")
        set(FLASH_KB 64)
    elseif (FLASH_CODE STREQUAL "B")
        set(FLASH_KB 128)
    elseif (FLASH_CODE STREQUAL "C")
        set(FLASH_KB 256)
    elseif (FLASH_CODE STREQUAL "D")
        set(FLASH_KB 384)
    elseif (FLASH_CODE STREQUAL "E")
        set(FLASH_KB 512)
    elseif (FLASH_CODE STREQUAL "F")
        set(FLASH_KB 768)
    elseif (FLASH_CODE STREQUAL "G")
        set(FLASH_KB 1024)
    elseif (FLASH_CODE STREQUAL "H")
        set(FLASH_KB 1536)
    elseif (FLASH_CODE STREQUAL "I")
        set(FLASH_KB 2048)
    else()
        message(FATAL_ERROR "Unknown flash size code: ${FLASH_CODE}")
    endif()

    set(${OUT_TYPE} "${TYPE}" PARENT_SCOPE)
    set(${OUT_SUBFAMILY} "${SUBFAMILY}" PARENT_SCOPE)
    set(${OUT_SERIES} "${TYPE}${SERIES_NUMBER}" PARENT_SCOPE)
    set(${OUT_CORE} "${CORE}" PARENT_SCOPE)
    set(${OUT_PIN_CODE} "${PIN_CODE}" PARENT_SCOPE)
    set(${OUT_FLASH_CODE} "${FLASH_CODE}" PARENT_SCOPE)
    set(${OUT_FLASH_KB} "${FLASH_KB}" PARENT_SCOPE)
endfunction()

# Function: map MCU part to define
# Usage:
#   get_stm32_define(MCU_NAME OUT_VAR)
# Example:
#   get_stm32_define("STM32F103C8" MCU_DEFINE)
#   message("MCU define is ${MCU_DEFINE}")

function(get_stm32_define MCU_NAME OUT_VAR)
    string(TOUPPER "${MCU_NAME}" MCU_UPPER)

    # Default empty
    set(DEFINE_NAME "")

    # STM32F100 series
    if(MCU_UPPER MATCHES "STM32F100(C4|R4|C6|R6|C8|R8|V8|CB|RB|VB)")
        set(DEFINE_NAME "STM32F100xB")
    elseif(MCU_UPPER MATCHES "STM32F100(RC|VC|ZC|RD|VD|ZD|RE|VE|ZE)")
        set(DEFINE_NAME "STM32F100xE")

    # STM32F101 series
    elseif(MCU_UPPER MATCHES "STM32F101(C4|R4|T4|C6|R6|T6)")
        set(DEFINE_NAME "STM32F101x6")
    elseif(MCU_UPPER MATCHES "STM32F101(C8|R8|T8|V8|CB|RB|TB|VB)")
        set(DEFINE_NAME "STM32F101xB")
    elseif(MCU_UPPER MATCHES "STM32F101(RC|VC|ZC|RD|VD|ZD|RE|VE|ZE)")
        set(DEFINE_NAME "STM32F101xE")
    elseif(MCU_UPPER MATCHES "STM32F101(RF|VF|ZF|RG|VG|ZG)")
        set(DEFINE_NAME "STM32F101xG")

    # STM32F102 series
    elseif(MCU_UPPER MATCHES "STM32F102(C4|R4|C6|R6)")
        set(DEFINE_NAME "STM32F102x6")
    elseif(MCU_UPPER MATCHES "STM32F102(C8|R8|CB|RB)")
        set(DEFINE_NAME "STM32F102xB")

    # STM32F103 series
    elseif(MCU_UPPER MATCHES "STM32F103(C4|R4|T4|C6|R6|T6)")
        set(DEFINE_NAME "STM32F103x6")
    elseif(MCU_UPPER MATCHES "STM32F103(C8|R8|T8|V8|CB|RB|TB|VB)")
        set(DEFINE_NAME "STM32F103xB")
    elseif(MCU_UPPER MATCHES "STM32F103(RC|VC|ZC|RD|VD|ZD|RE|VE|ZE)")
        set(DEFINE_NAME "STM32F103xE")
    elseif(MCU_UPPER MATCHES "STM32F103(RF|VF|ZF|RG|VG|ZG)")
        set(DEFINE_NAME "STM32F103xG")

    # STM32F105 series
    elseif(MCU_UPPER MATCHES "STM32F105(R8|V8|RB|VB|RC|VC)")
        set(DEFINE_NAME "STM32F105xC")
    else()
        message(FATAL_ERROR "Unknown MCU part: ${MCU_NAME}")
    endif()

    # Return result
    set(${OUT_VAR} "${DEFINE_NAME}" PARENT_SCOPE)
endfunction()
