# Copyright 2016 Cheolmin Jo (webos21@gmail.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

######################################################
#                        Linux                       #
#----------------------------------------------------#
# File    : linux.mk                                 #
# Version : 1.0.0                                    #
# Desc    : MK file for LINUX build.                 #
#----------------------------------------------------#
# History)                                           #
#   - 2022/01/10 : Created by cmjo                   #
######################################################

########################
# Host Configuration
########################
HOST_OS       := linux
HOST_ARCH     := x86_64
HOST_TAG      := linux-x86_64
HOST_NUM_CPUS := 4
HOST_CC       := gcc
HOST_CFLAGS   := 
HOST_CXX      := g++
HOST_CXXFLAGS := 
HOST_LD       := ld
HOST_LDFLAGS  := 
HOST_AR       := ar
HOST_ARFLAGS  := 
HOST_EXEEXT   :=
HOST_ECHO     := echo
HOST_ECHO_N   := printf %s



########################
# Toolchain Configuration
########################

TARGET_TOOLCHAIN      := linux
TARGET_ARCH           := x86_64
TARGET_ARCH_ABI       := x86_64
TARGET_PLATFORM_LEVEL := 21
TARGET_PLATFORM       := android-$(TARGET_PLATFORM_LEVEL)
TARGET_ABI            := $(TARGET_PLATFORM)-$(TARGET_ARCH_ABI)

# TARGET_PLATFORM_LEVEL > 21
NDK_PLATFORM_NEEDS_ANDROID_SUPPORT := false

TARGET_PREBUILT_SHARED_LIBRARIES :=

# Define default values for TOOLCHAIN_NAME, this can be overriden in
# the setup file.
TOOLCHAIN_NAME   := $(TARGET_TOOLCHAIN)
TOOLCHAIN_VERSION := 1.0.0

TOOLCHAIN_NAME := aarch64-linux-android
LLVM_TRIPLE := aarch64-none-linux-android

TOOLCHAIN_ROOT := 
LLVM_TOOLCHAIN_PREFIX := $(TOOLCHAIN_ROOT)/bin/

RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT := 
RENDERSCRIPT_TOOLCHAIN_PREFIX := $(RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT)/bin/
RENDERSCRIPT_TOOLCHAIN_HEADER := $(RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT)/clang-include
RENDERSCRIPT_PLATFORM_HEADER := $(RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT)/platform/rs


########################
# Compile Command Definition
########################

# Return the list of object, static libraries and shared libraries as they
# must appear on the final static linker command (order is important).
#
# This can be over-ridden by a specific toolchain. Note that by default
# we always put libgcc _after_ all static libraries and _before_ shared
# libraries. This ensures that any libgcc function used by the final
# executable will be copied into it. Otherwise, it could contain
# symbol references to the same symbols as exported by shared libraries
# and this causes binary compatibility problems when they come from
# system libraries (e.g. libc.so and others).
#
# IMPORTANT: The result must use the host path convention.
#
# $1: object files
# $2: static libraries
# $3: whole static libraries
# $4: shared libraries
#
TARGET-get-linker-objects-and-libraries = \
    $(call host-path, $1) \
    $(call link-whole-archives,$3) \
    $(call host-path, $2) \
    $(PRIVATE_LIBATOMIC) \
    $(call host-path, $4) \

define cmd-build-shared-library
$(PRIVATE_CXX) \
    -Wl,-soname,$(notdir $(LOCAL_BUILT_MODULE)) \
    -shared \
    $(PRIVATE_LINKER_OBJECTS_AND_LIBRARIES) \
    $(GLOBAL_LDFLAGS) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    -o $(call host-path,$(LOCAL_BUILT_MODULE))
endef

# The following -rpath-link= are needed for ld.bfd (default for ARM64) when
# linking executables to supress warning about missing symbol from libraries not
# directly needed. ld.gold (default for all other architectures) doesn't emulate
# this buggy behavior.
define cmd-build-executable
$(PRIVATE_CXX) \
    -Wl,--gc-sections \
    -Wl,-rpath-link=$(call host-path,$(PRIVATE_SYSROOT_API_LIB_DIR)) \
    -Wl,-rpath-link=$(call host-path,$(TARGET_OUT)) \
    $(PRIVATE_LINKER_OBJECTS_AND_LIBRARIES) \
    $(GLOBAL_LDFLAGS) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    -o $(call host-path,$(LOCAL_BUILT_MODULE))
endef

define cmd-build-static-library
$(PRIVATE_AR) $(call host-path,$(LOCAL_BUILT_MODULE)) $(PRIVATE_AR_OBJECTS)
endef

cmd-strip = $(PRIVATE_STRIP) $(PRIVATE_STRIP_MODE) $(call host-path,$1)



########################
# Compile Flags
########################

# These flags are used to ensure that a binary doesn't reference undefined
# flags.
TARGET_NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined

# This flag are used to provide compiler protection against format
# string vulnerabilities.
TARGET_FORMAT_STRING_CFLAGS := -Wformat -Werror=format-security

# This flag disables the above security checks
TARGET_DISABLE_FORMAT_STRING_CFLAGS := -Wno-error=format-security

# arm32 currently uses a linker script in place of libgcc to ensure that
# libunwind is linked in the correct order. --exclude-libs does not propagate to
# the contents of the linker script and can't be specified within the linker
# script. Hide both regardless of architecture to future-proof us in case we
# move other architectures to a linker script (which we may want to do so we
# automatically link libclangrt on other architectures).
TARGET_LIBATOMIC = -latomic
TARGET_LDLIBS := -lc -lm

# IMPORTANT: The following definitions must use lazy assignment because
# the value of TOOLCHAIN_NAME or TARGET_CFLAGS can be changed later by
# the toolchain's setup.mk script.
TOOLCHAIN_PREFIX = $(TOOLCHAIN_ROOT)/bin/$(TOOLCHAIN_NAME)-

# cmjo : edit
#TARGET_CC = $(LLVM_TOOLCHAIN_PREFIX)clang$(HOST_EXEEXT)
#TARGET_CXX = $(LLVM_TOOLCHAIN_PREFIX)clang++$(HOST_EXEEXT)
TARGET_CC = gcc$(HOST_EXEEXT)
TARGET_CXX = g++$(HOST_EXEEXT)

# cmjo : edit
#CLANG_TIDY = $(LLVM_TOOLCHAIN_PREFIX)clang-tidy$(HOST_EXEEXT)
CLANG_TIDY = clang-tidy$(HOST_EXEEXT)

# cmjo : remove from GLOBAL_CFLAGS
#    -target $(LLVM_TRIPLE)$(TARGET_PLATFORM_LEVEL)
GLOBAL_CFLAGS = \
    -fdata-sections \
    -ffunction-sections \
    -fstack-protector-strong \
    -funwind-tables \
    -no-canonical-prefixes \

# This is unnecessary given the new toolchain layout, but Studio will not
# recognize this as an Android build if there is no --sysroot flag.
# TODO: Teach Studio to recognize Android builds based on --target.

# cmjo : commenting
#GLOBAL_CFLAGS += --sysroot $(call host-path,$(NDK_UNIFIED_SYSROOT_PATH))

# Always enable debug info. We strip binaries when needed.
GLOBAL_CFLAGS += -g

# TODO: Remove.
GLOBAL_CFLAGS += \
    -Wno-invalid-command-line-argument \
    -Wno-unused-command-line-argument \

GLOBAL_CFLAGS += -D_FORTIFY_SOURCE=2

# cmjo : remove from GLOBAL_LDFLAGS
#    -target $(LLVM_TRIPLE)$(TARGET_PLATFORM_LEVEL)
GLOBAL_LDFLAGS = \
    -no-canonical-prefixes \

GLOBAL_CXXFLAGS = $(GLOBAL_CFLAGS) -std=gnu++17 -fno-exceptions -fno-rtti

TARGET_CFLAGS =
TARGET_CONLYFLAGS =
TARGET_CXXFLAGS = $(TARGET_CFLAGS)

TARGET_RS_CC    = $(RENDERSCRIPT_TOOLCHAIN_PREFIX)llvm-rs-cc
TARGET_RS_BCC   = $(RENDERSCRIPT_TOOLCHAIN_PREFIX)bcc_compat
TARGET_RS_FLAGS = -Wall -Werror

# cmjo : edit
#TARGET_ASM      = $(TOOLCHAIN_ROOT)/bin/yasm
TARGET_ASM      = as
TARGET_ASMFLAGS =

# cmjo : edit
#TARGET_LD       = $(TOOLCHAIN_ROOT)/bin/ld
TARGET_LD       = ld
TARGET_LDFLAGS :=

# cmjo : edit
#TARGET_AR = $(LLVM_TOOLCHAIN_PREFIX)llvm-ar$(HOST_EXEEXT)
TARGET_AR = ar$(HOST_EXEEXT)
TARGET_ARFLAGS := crs

# cmjo : edit
#TARGET_STRIP = $(LLVM_TOOLCHAIN_PREFIX)llvm-strip$(HOST_EXEEXT)
TARGET_STRIP = strip$(HOST_EXEEXT)

TARGET_OBJ_EXTENSION := .obj
TARGET_LIB_EXTENSION := .lib
TARGET_SONAME_EXTENSION := .dll

TARGET_TOOLCHAIN_ARCH_LIB_DIR := aarch64
TARGET_ASAN_BASENAME := libclang_rt.asan-aarch64-android.so
TARGET_UBSAN_BASENAME := libclang_rt.ubsan_standalone-aarch64-android.so

TARGET_CFLAGS := -fpic

TARGET_arm64_release_CFLAGS := \
    -O2 \
    -DNDEBUG \

TARGET_arm64_debug_CFLAGS := \
    -O0 \
    -UNDEBUG \
    -fno-limit-debug-info \
