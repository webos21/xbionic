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
# Programs
########################
include $(basedir)/buildx/make/cmd.mk


########################
# Build Configuration
########################
build_cfg_target  = linux
build_cfg_linux   = 1
build_cfg_posix   = 1
build_cfg_arch    = x86_64


########################
# Directories
########################
build_tool_dir = 


########################
# Program Definition
########################
build_tool_cc     = gcc
build_tool_cxx    = g++
build_tool_linker = g++
build_tool_ar     = ar
build_tool_ranlib = ranlib
# if the $(build_tool_strip) is not "", then emul file will be stripped.
build_tool_strip  =


########################
# Compile Flags
########################
build_run_a       = 1
build_run_so      = 1

build_opt_a_pre   = lib
build_opt_a_ext   = a
build_opt_so_pre  = lib
build_opt_so_ext  = so
build_opt_exe_ext =

build_opt_c       = -g -O3 \
                    -Wall -Wextra -Wdeclaration-after-statement \
                    -fstack-usage -ffunction-sections -fdata-sections \
                    -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
build_opt_cxx     = -g -O3 \
                    -Wall -Wextra \
                    -fstack-usage -ffunction-sections -fdata-sections \
                    -fno-exceptions -fno-rtti \
                    -D_REENTRANT -D_THREAD_SAFE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64
build_opt_ld      = -g \
                    -Wl,--no-undefined \
					-Wl,--gc-sections
build_opt_fPIC    = -fPIC
build_opt_mnocyg  = 
build_opt_libgcc  =
build_opt_libgxx  = 


########################
# Build Flags
########################
build_pbionic_run_libc       = 1
build_pbionic_run_libdl      = 1
build_pbionic_run_fdtrack    = 1
build_pbionic_run_libstdc++  = 1
build_pbionic_run_linker     = 1
