# SPDX-FileCopyrightText: 2026 STMicroelectronics
# SPDX-License-Identifier: MIT

include(${CMAKE_CURRENT_LIST_DIR}/stm32-utils.cmake)


# Problem: CMake runs toolchain files multiple times, but can't read cache variables on some runs.
# Workaround: On first run (in which cache variables are always accessible), set an intermediary environment variable.

if (MCU)
    # Environment variables are always preserved.
    set(ENV{_MCU} "${MCU}")
else ()
    set(MCU "$ENV{_MCU}")
endif ()

set(CMAKE_SYSTEM_NAME               Generic)
set(CMAKE_SYSTEM_PROCESSOR          arm)

set(CMAKE_C_COMPILER_ID GNU)
set(CMAKE_CXX_COMPILER_ID GNU)

# Some default GCC settings
# arm-none-eabi- must be part of path environment
set(TOOLCHAIN_PREFIX                arm-none-eabi-)

set(CMAKE_C_COMPILER                ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER              ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER              ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_LINKER                    ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_OBJCOPY                   ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE                      ${TOOLCHAIN_PREFIX}size)

set(CMAKE_EXECUTABLE_SUFFIX_ASM     ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_C       ".elf")
set(CMAKE_EXECUTABLE_SUFFIX_CXX     ".elf")

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

stm32_parse_part(
    ${MCU}
    MCU_TYPE
    MCU_SUBFAMILY
    MCU_SERIES
    MCU_CORE
    MCU_PIN_CODE
    MCU_FLASH_CODE
    MCU_FLASH_KB
)

set(MCU_DEVICE "STM32${MCU_TYPE}${MCU_SUBFAMILY}${MCU_PIN_CODE}${MCU_FLASH_CODE}")
string(TOLOWER "${MCU_DEVICE}" MCU_DEVICE_LOWER)

set(MCPU_FLAG_VAL "")
if (MCU_CORE STREQUAL "M0+")
    set(MCPU_FLAG_VAL "cortex-m0plus")
elseif (MCU_CORE STREQUAL "M3")
    set(MCPU_FLAG_VAL "cortex-m3")
elseif (MCU_CORE STREQUAL "M4")
    set(MCPU_FLAG_VAL "cortex-m4")
endif()

if (MCPU_FLAG_VAL STREQUAL "")
    message(FATAL_ERROR "Unable to determine -mcpu value")
endif()

# MCU specific flags
set(TARGET_FLAGS "-mcpu=${MCPU_FLAG_VAL} ")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${TARGET_FLAGS}")
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp -MMD -MP")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -fdata-sections -ffunction-sections")

set(CMAKE_C_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_C_FLAGS_RELEASE "-Os -g0")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g3")
set(CMAKE_CXX_FLAGS_RELEASE "-Os -g0")

set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fno-rtti -fno-exceptions -fno-threadsafe-statics")

set(FLASH_SCRIPT "${CMAKE_SOURCE_DIR}/mcu/${MCU_DEVICE_LOWER}/flash.ld")
message(STATUS "Flash setup: ${FLASH_SCRIPT}")

set(CMAKE_EXE_LINKER_FLAGS "${TARGET_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -T \"${FLASH_SCRIPT}\"")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --specs=nano.specs")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-Map=${CMAKE_PROJECT_NAME}.map -Wl,--gc-sections")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--print-memory-usage")
set(TOOLCHAIN_LINK_LIBRARIES "m")
