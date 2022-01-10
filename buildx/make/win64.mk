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
#                      Windows 64bit                 #
#----------------------------------------------------#
# File    : win64.mk                                 #
# Version : 1.0.0                                    #
# Desc    : MK file for LINUX build.                 #
#----------------------------------------------------#
# History)                                           #
#   - 2022/01/10 : Created by cmjo                   #
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
build_cfg_target  = win64
build_cfg_linux   = 1
build_cfg_posix   = 1
build_cfg_arch    = x86_64


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
build_run_so      = 1

build_opt_a_pre   = 
build_opt_a_ext   = a
build_opt_so_pre  = 
build_opt_so_ext  = dll
build_opt_exe_ext =

build_opt_c       = -g -Wall -Wextra -Wdeclaration-after-statement -O3 -nostdinc -fstack-usage -ffunction-sections -fdata-sections -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 --sysroot=$(build_sys_root)
build_opt_cxx     = -g -Wall -Wextra -O3 -nostdinc -fstack-usage -ffunction-sections -fdata-sections -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 --sysroot=$(build_sys_root)
build_opt_ld      = -g -Wl,--no-undefined -Wl,--gc-sections

build_opt_fPIC    = -fPIC
build_opt_mnocyg  = 
build_opt_libgcc  =
build_opt_libgxx  = 

build_opt_inc     = $(basedir)/include


########################
# Build Flags
########################
build_pbionic_run_libc       = 1
build_pbionic_run_libdl      = 1
build_pbionic_run_fdtrack    = 1
build_pbionic_run_libstdc++  = 1
build_pbionic_run_linker     = 1
