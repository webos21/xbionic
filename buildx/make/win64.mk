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
# Desc    : MK file for Win64 build.                 #
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
HOST_OS       := windows
HOST_ARCH     := x86_64
HOST_TAG      := windows-x86_64
HOST_NUM_CPUS := 4
HOST_CC       := gcc
HOST_CFLAGS   := -mno-cygwin
HOST_CXX      := g++
HOST_CXXFLAGS := 
HOST_LD       := ld
HOST_LDFLAGS  := -mno-cygwin
HOST_AR       := ar
HOST_ARFLAGS  := 
HOST_EXEEXT   := .exe
HOST_ECHO     := echo
HOST_ECHO_N   := echo -n
