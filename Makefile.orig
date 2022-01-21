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
#                     Base Make                      #
#----------------------------------------------------#
# File    : Makefile                                 #
# Version : 1.0.0                                    #
# Desc    : Base makefile.                           #
#----------------------------------------------------#
# History)                                           #
#   - 2016/02/01 : Created by cmjo                   #
######################################################

# directories
basedir = .
destdir = out

# shell commands
include $(basedir)/buildx/make/cmd.mk

# Android Bionic Source Directory
xbionic_src = platform_bionic-android-vts-12.0_r2

# Android Logging Source Directory
xlogging_src = logging-platform-12.0.0_r1

# Android Jemalloc Source Directory
jemalloc_src = jemalloc-android11-platform-release


# make targets
all: usage

linux:
	@$(MKDIR) -p "$(destdir)/$@"
	$(MAKE) -C $(xbionic_src) -f buildx.mk TARGET=$@

macos:
	@$(MKDIR) -p "$(destdir)/$@"
	$(MAKE) -C $(xbionic_src) -f buildx.mk TARGET=$@

win64:
	@$(MKDIR) -p "$(destdir)/$@"
	$(MAKE) -C $(xbionic_src) -f buildx.mk TARGET=$@

clean:
	@$(RM) -rf $(basedir)/out/*

usage:
	@echo "####################################################"
	@echo "#                 xbionic Makefile                 #"
	@echo "#--------------------------------------------------#"
	@echo "# We only support below command.                   #"
	@echo "#                                                  #"
	@echo "#   - make linux   : make the Linux binary         #"
	@echo "#   - make macosx  : make the MacOS binary         #"
	@echo "#   - make win64   : make the Windows binary       #"
	@echo "#   - make clean   : clean the source tree         #"
	@echo "####################################################"

