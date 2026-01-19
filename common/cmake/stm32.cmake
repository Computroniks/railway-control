# SPDX-FileCopyrightText: 2026 Zoe Nickson <zoe.nickson@sidingsmedia.com>
# SPDX-License-Identifier: MIT

include(${CMAKE_CURRENT_LIST_DIR}/stm32-utils.cmake)

set(MCU "" CACHE STRING "Target MCU")
set_property(CACHE MCU PROPERTY STRINGS ${SUPPORTED_MCU})

if(MCU STREQUAL "")
    message(FATAL_ERROR
        "Target MCU must be set. Supported MCUs: ${SUPPORTED_MCU}")
endif()

# Validate the value
list(FIND SUPPORTED_MCU "${MCU}" _index)
if(_index EQUAL -1)
    message(FATAL_ERROR
        "Invalid MCU='${MCU}'. Allowed values: ${SUPPORTED_MCU}")
endif()

# Extract STM family (e.g. STM32F4, STM32G4)
string(REGEX MATCH "^stm32([a-z][0-9])" _match "${MCU}")

if(NOT _match)
    message(FATAL_ERROR "Unable to determine STM family from MCU='${MCU}'")
endif()

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

set(MCU_FAMILY "STM32${MCU_SERIES}xx")

message(STATUS "Targeting ${MCU} (Family: ${MCU_FAMILY} Processor: ${MCU_CORE} Flash: ${MCU_FLASH_KB}kb)")

set(MCU_DEVICE "STM32${MCU_TYPE}${MCU_SUBFAMILY}${MCU_PIN_CODE}${MCU_FLASH_CODE}")

get_stm32_define("${MCU_DEVICE}" MCU_DEFINE_TARGET)

string(TOUPPER "${MCU_DEVICE}" MCU_DEVICE_UPPER)
set(DRIVER_DEFINE_SYMS
    USE_HAL_DRIVER
    ${MCU_DEFINE_TARGET}
    $<$<CONFIG:Debug>:DEBUG> 
)

message(STATUS "Driver defines: ${DRIVER_DEFINE_SYMS}")

string(TOLOWER ${MCU_FAMILY} MCU_FAMILY_LOWER)
string(TOLOWER ${MCU_SERIES} MCU_SERIES_LOWER)

set(DRIVER_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/../third-party/drivers/stm32")
get_filename_component(DEVICE_HAL_PATH "${DRIVER_BASE_DIR}/${MCU_FAMILY_LOWER}-hal-driver" ABSOLUTE)
get_filename_component(DEVICE_CMSIS_PATH "${DRIVER_BASE_DIR}/cmsis-device-${MCU_SERIES_LOWER}" ABSOLUTE)

message(STATUS "Found HAL: ${DEVICE_HAL_PATH}")
message(STATUS "Found CMSIS: ${DEVICE_CMSIS_PATH}")

set(DRIVER_INCLUDE_DIR
    ${CMAKE_CURRENT_SOURCE_DIR}/include/platform/${MCU_FAMILY_LOWER}
    ${DEVICE_HAL_PATH}/Inc
    ${DEVICE_HAL_PATH}/Inc/Legacy
    ${DEVICE_CMSIS_PATH}/Include
    ${DRIVER_BASE_DIR}/cmsis-core/Include
)


file(GLOB DRIVER_SRC_UNFILTERED
     "${DEVICE_HAL_PATH}/Src/*.c"
)

set(DRIVER_SRC "")
foreach(f ${DRIVER_SRC_UNFILTERED})
    if(NOT f MATCHES "template\\.c$")
        list(APPEND DRIVER_SRC ${f})
    endif()
endforeach()

set(LINK_LIBRARIES 
    stm32_drivers
    ${TOOLCHAIN_LINK_LIBRARIES}
)

add_library(stm32_interface INTERFACE)
target_include_directories(stm32_interface INTERFACE ${DRIVER_INCLUDE_DIR})
target_compile_definitions(stm32_interface INTERFACE ${DRIVER_DEFINE_SYMS})

add_library(stm32_drivers OBJECT)
target_sources(stm32_drivers PRIVATE ${DRIVER_SRC})
target_link_libraries(stm32_drivers PUBLIC stm32_interface)


target_link_libraries(${CMAKE_PROJECT_NAME} ${LINK_LIBRARIES})
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES ADDITIONAL_CLEAN_FILES ${CMAKE_PROJECT_NAME}.map)

set(MCU_DEVICE "STM32${MCU_TYPE}${MCU_SUBFAMILY}${MCU_PIN_CODE}${MCU_FLASH_CODE}")
string(TOLOWER "${MCU_DEVICE}" MCU_DEVICE_LOWER)

file(GLOB PLATFORM_SRC ${CMAKE_SOURCE_DIR}/src/platform/${MCU_FAMILY_LOWER}/*.c)

message(STATUS "Startup: ${STARTUP_CODE}")
target_sources(${CMAKE_PROJECT_NAME} PRIVATE 
    ${CMAKE_SOURCE_DIR}/mcu/${MCU_DEVICE_LOWER}/startup.s
    ${PLATFORM_SRC}
    ${CMAKE_CURRENT_LIST_DIR}/../sys/syscalls.c
    ${CMAKE_CURRENT_LIST_DIR}/../sys/sysmem.c

)

target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE ${MCU_FAMILY})

if((CMAKE_C_STANDARD EQUAL 90) OR (CMAKE_C_STANDARD EQUAL 99))
    message(ERROR "Generated code requires C11 or higher")
endif()
