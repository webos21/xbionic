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
#                    BuildX - libc                   #
#----------------------------------------------------#
# File    : buildx.mk                                #
# Version : 1.0.0                                    #
# Desc    : For building the libc.                   #
#----------------------------------------------------#
# History)                                           #
#   - 2022/01/10 : Created by cmjo                   #
######################################################

LOCAL_PATH := $(call my-dir)

# Variables : libc_common_src_files
libc_common_src_files =          \
    bionic/ether_aton.c          \
    bionic/ether_ntoa.c          \
    bionic/exit.cpp              \
    bionic/fts.c                 \
    bionic/initgroups.c          \
    bionic/isatty.c              \
    bionic/sched_cpualloc.c      \
    bionic/sched_cpucount.c      \
    stdio/fmemopen.cpp           \
    stdio/parsefloat.c           \
    stdio/refill.c               \
    stdio/stdio.cpp              \
    stdio/stdio_ext.cpp          \
    stdio/vfscanf.cpp            \
    stdio/vfwscanf.c

# Variables : libc_common_src_files_32
libc_common_src_files_32 =           \
    bionic/legacy_32_bit_support.cpp \
    bionic/time64.c

# Variables : libc_common_src_files_32
libc_common_flags = \
    -D_LIBC=1                       \
    -D__BIONIC_LP32_USE_STAT64      \
    -Wall                           \
    -Wextra                         \
    -Wunused                        \
    -Wno-char-subscripts            \
    -Wno-deprecated-declarations    \
    -Wno-gcc-compat                 \
    -Wframe-larger-than=2048        \
    -Werror=pointer-to-int-cast     \
    -Werror=int-to-pointer-cast     \
    -Werror=type-limits             \
    -Werror                         \
    -Wexit-time-destructors
ifneq ($(TARGET_ARCH),x86_64)
libc_common_flags += \
    -fno-emulated-tls
endif

# Variables : libc_defaults
libc_defaults = \
        $(libc_common_flags)             \
        -I.                              \
        -Iinclude                        \
        -Iasync_safe/include             \
        -Iplatform                       \
        -Ikernel/uapi                    \
        -Ikernel/android/uapi            \
        -I$(basedir)/logging-platform-12.0.0_r1/liblog/include \
		-I$(basedir)/jemalloc-android11-platform-release/include
ifeq ($(TARGET_ARCH),arm64)
libc_defaults += \
        -Ikernel/uapi/asm-arm64
endif
ifeq ($(TARGET_ARCH),x86_64)
libc_defaults += \
        -Ikernel/uapi/asm-x86
endif


libc_jemalloc_wrapper =  bionic/jemalloc_wrapper.cpp

libc_bootstrap_src_files =                 \
    bionic/__libc_init_main_thread.cpp     \
    bionic/__stack_chk_fail.cpp            \
    bionic/bionic_call_ifunc_resolver.cpp  \
    bionic/getauxval.cpp
ifeq ($(TARGET_ARCH),arm64)
libc_bootstrap_src_files += arch-arm64/bionic/__set_tls.c
endif
ifeq ($(TARGET_ARCH),x86_64)
libc_bootstrap_src_files += arch-x86_64/bionic/__set_tls.c
endif

libc_init_static = bionic/libc_init_static.cpp
libc_init_dynamic = bionic/libc_init_dynamic.cpp

libc_tzcode = \
    $(wildcard tzcode/*.c)    \
    tzcode/bionic.cpp         \
    upstream-openbsd/lib/libc/time/wcsftime.c


libc_bootstrap_src_files = \
    bionic/__libc_init_main_thread.cpp       \
    bionic/__stack_chk_fail.cpp              \
    bionic/bionic_call_ifunc_resolver.cpp    \
    bionic/getauxval.cpp
ifeq ($(TARGET_ARCH),x86_64)
libc_bootstrap_src_files += \
    arch-x86_64/bionic/__set_tls.c
endif
ifeq ($(TARGET_ARCH),arm64)
libc_bootstrap_src_files += \
    arch-arm64/bionic/__set_tls.c
endif



#-----------------------------------------------------------------------
# libc_bootstrap.a - -fno-stack-protector and -ffreestanding
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_bootstrap
LOCAL_CFLAGS    += $(libc_defaults) -fno-stack-protector -ffreestanding
LOCAL_SRC_FILES := $(libc_bootstrap_src_files)

include $(BUILD_STATIC_LIBRARY)
