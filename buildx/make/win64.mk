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
#                      i.MX6ULL                      #
#----------------------------------------------------#
# File    : imx6ull.mk                               #
# Version : 1.0.0                                    #
# Desc    : MK file for LINUX build.                 #
#----------------------------------------------------#
# History)                                           #
#   - 2020/03/20 : Created by cmjo                   #
######################################################

########################
# Programs
########################
CP = cp
RM = rm -f
MKDIR = mkdir
TAR = tar
CHMOD = chmod


########################
# Build Configuration
########################
build_cfg_target  = imx6ull
build_cfg_linux   = 1
build_cfg_posix   = 1


########################
# Directories
########################
build_tool_dir = /opt/fsl-imx-fb/4.1.15-2.0.1/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi
build_sys_root = /opt/fsl-imx-fb/4.1.15-2.0.1/sysroots/cortexa7hf-neon-poky-linux-gnueabi


########################
# Program Definition
########################
build_tool_cc     = $(build_tool_dir)/arm-poky-linux-gnueabi-gcc
build_tool_cxx    = $(build_tool_dir)/arm-poky-linux-gnueabi-g++
build_tool_linker = $(build_tool_dir)/arm-poky-linux-gnueabi-g++
build_tool_ar     = $(build_tool_dir)/arm-poky-linux-gnueabi-ar
build_tool_ranlib = $(build_tool_dir)/arm-poky-linux-gnueabi-ranlib
build_tool_strip  = $(build_tool_dir)/arm-poky-linux-gnueabi-strip


########################
# Compile Flags
########################
build_run_a       = 1
build_run_so      =

build_opt_a_pre   = lib
build_opt_a_ext   = a
build_opt_so_pre  = lib
build_opt_so_ext  = so
build_opt_exe_ext =

build_opt_c       = -march=armv7ve -mfpu=neon  -mfloat-abi=hard -mcpu=cortex-a7 -g -Wall -Wextra -Wdeclaration-after-statement -O3 -fstack-usage -ffunction-sections -fdata-sections -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 --sysroot=$(build_sys_root)
build_opt_cxx     = -march=armv7ve -mfpu=neon  -mfloat-abi=hard -mcpu=cortex-a7 -g -Wall -Wextra -O3 -fstack-usage -ffunction-sections -fdata-sections -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 --sysroot=$(build_sys_root)
build_opt_ld      = -march=armv7ve -mfpu=neon  -mfloat-abi=hard -mcpu=cortex-a7 -g -Wl,--no-undefined --sysroot=$(build_sys_root)
build_opt_ld_noud = -Wl,--no-undefined -Wl,--gc-sections

build_opt_fPIC    = -fPIC
build_opt_mnocyg  = 
build_opt_libgcc  =
build_opt_libgxx  = 

build_opt_inc     = $(basedir)/include


########################
# Build Flags
########################
build_ext_run_mbedtls        = 1
build_ext_run_mbedtls_compat = 1
build_ext_run_coap           = 1
build_ext_run_mqtt           = 1
build_ext_run_qcbor          = 1

build_example_coap           = 1
build_example_http           = 1
build_example_mqtt           = 1
build_example_websocket      = 1
build_example_iplt           = 1
