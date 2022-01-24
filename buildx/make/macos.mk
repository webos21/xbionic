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
#                        MacOS                       #
#----------------------------------------------------#
# File    : macos.mk                                 #
# Version : 1.0.0                                    #
# Desc    : MK file for Mac OS X build.              #
#----------------------------------------------------#
# History)                                           #
#   - 2022/01/10 : Created by cmjo                   #
######################################################

########################
# Programs
########################
#include $(basedir)/buildx/make/cmd.mk


########################
# Host Configuration
########################
HOST_OS       := darwin
HOST_ARCH     := arm64
HOST_TAG      := darwin-arm64
HOST_NUM_CPUS := 4
HOST_CC       := gcc
HOST_CFLAGS   := 
HOST_CXX      := g++
HOST_CXXFLAGS := 
HOST_LD       := ld
HOST_LDFLAGS  := 
HOST_AR       := ar
HOST_ARFLAGS  := 

########################
# Toolchain Configuration
########################
TOOLCHAIN_ABIS   := arm64
TOOLCHAIN_NAME   := macos
TOOLCHAIN_PREFIX := 

########################
# Build-Options Configuration
########################
TARGET_TOOLCHAIN := arm-eabi-4.2.1
TARGET_PLATFORM  := macos
TARGET_ARCH_ABI  := arm64
TARGET_ARCH      := arm64

TARGET_ABI := $(TARGET_PLATFORM)-$(TARGET_ARCH_ABI)
# setup sysroot-related variables. The SYSROOT point to a directory
# that contains all public header files for a given platform, plus
# some libraries and object files used for linking the generated
# target files properly.
#
SYSROOT := build/platforms/$(TARGET_PLATFORM)/arch-$(TARGET_ARCH_ABI)
TARGET_CRTBEGIN_STATIC_O  := $(SYSROOT)/usr/lib/crtbegin_static.o
TARGET_CRTBEGIN_DYNAMIC_O := $(SYSROOT)/usr/lib/crtbegin_dynamic.o
TARGET_CRTEND_O           := $(SYSROOT)/usr/lib/crtend_android.o
TARGET_PREBUILT_SHARED_LIBRARIES := 
TARGET_PREBUILT_SHARED_LIBRARIES :=

TARGET_CFLAGS.common := \
    -g -O3 \
    -Wall -Wextra \
    -fPIC -ffunction-sections -fdata-sections \
    -D_DARWIN_C_SOURCE -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
TARGET_arm_release_CFLAGS :=  -O2 \
                              -fomit-frame-pointer \
                              -fstrict-aliasing    \
                              -funswitch-loops     \
                              -finline-limit=300
TARGET_thumb_release_CFLAGS := -mthumb \
                               -Os \
                               -fomit-frame-pointer \
                               -fno-strict-aliasing \
                               -finline-limit=64
# When building for debug, compile everything as arm.
TARGET_arm_debug_CFLAGS := $(TARGET_arm_release_CFLAGS) \
                           -fno-omit-frame-pointer \
                           -fno-strict-aliasing
TARGET_thumb_debug_CFLAGS := $(TARGET_thumb_release_CFLAGS) \
                             -marm \
                             -fno-omit-frame-pointer
TARGET_CC       := $(TOOLCHAIN_PREFIX)gcc
TARGET_CFLAGS   := $(TARGET_CFLAGS.common) -std=gnu99 -Wdeclaration-after-statement
TARGET_CXX      := $(TOOLCHAIN_PREFIX)g++
TARGET_CXXFLAGS := $(TARGET_CFLAGS.common) -std=gnu++17 -fno-exceptions -fno-rtti
TARGET_LD       := $(TOOLCHAIN_PREFIX)ld
TARGET_LDFLAGS  :=
TARGET_AR       := $(TOOLCHAIN_PREFIX)ar
TARGET_ARFLAGS  := crs
TARGET_LIBGCC   := $(shell $(TARGET_CC) -print-libgcc-file-name)
TARGET_LDLIBS   := -Wl,-rpath-link=$(SYSROOT)/usr/lib $(TARGET_LIBGCC)
# The ABI-specific sub-directory that the SDK tools recognize for
# this toolchain's generated binaries
TARGET_ABI_SUBDIR := 
define cmd-build-shared-library
$(TARGET_CC) \
    -nostdlib -Wl,-soname,$(notdir $@) \
    -Wl,-shared,-Bsymbolic \
    $(PRIVATE_OBJECTS) \
    -Wl,--whole-archive \
    $(PRIVATE_WHOLE_STATIC_LIBRARIES) \
    -Wl,--no-whole-archive \
    $(PRIVATE_STATIC_LIBRARIES) \
    $(PRIVATE_SHARED_LIBRARIES) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    -o $@
endef
define cmd-build-executable
$(TARGET_CC) \
    -nostdlib -Bdynamic \
    -Wl,-dynamic-linker,/system/bin/linker \
    -Wl,--gc-sections \
    -Wl,-z,nocopyreloc \
    $(PRIVATE_SHARED_LIBRARIES) \
    $(TARGET_CRTBEGIN_DYNAMIC_O) \
    $(PRIVATE_OBJECTS) \
    $(PRIVATE_STATIC_LIBRARIES) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    $(TARGET_CRTEND_O) \
    -o $@
endef
define cmd-build-static-library
$(TARGET_AR) $(TARGET_ARFLAGS) $@ $(PRIVATE_OBJECTS)
endef
cmd-strip = $(TOOLCHAIN_PREFIX)strip --strip-debug $1
