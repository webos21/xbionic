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
#          BuildX - Android Platform Bionic          #
#----------------------------------------------------#
# File    : buildx.mk                                #
# Version : 1.0.0                                    #
# Desc    : For building the Android Platform Bionic.#
#----------------------------------------------------#
# History)                                           #
#   - 2022/01/10 : Created by cmjo                   #
######################################################

# PREPARE : set base
basedir = ..
destdir = out

# PREPARE : Check Environment
ifeq ($(TARGET),)
need_warning = "Warning : you are here without proper command!!!!"
include $(basedir)/buildx/make/project.mk
include $(basedir)/buildx/make/$(project_def_target).mk
TARGET = $(project_def_target)
else
need_warning = ""
include $(basedir)/buildx/make/project.mk
include $(basedir)/buildx/make/$(TARGET).mk
endif

# PREPARE : get current directory
bx_pbionic_abs   = $(CURDIR)
#bx_pbionic_rel   = $(notdir $(bx_pbionic_abs))
bx_pbionic_rel   = pbionic

# PREPARE : set target directory
bx_pbionic_target = $(basedir)/$(destdir)/$(build_cfg_target)/$(bx_pbionic_rel)


###################
# make targets
###################

all: prepare do_build

prepare:
	@echo $(need_warning)
	@$(MKDIR) -p "$(bx_pbionic_target)"
	@echo "================================================================"
	@echo "                  Android Platform Bionic Build"
	@echo "================================================================"
	@echo "TARGET                  : $(TARGET)"
	@echo "----------------------------------------------------------------"
	@echo "bx_pbionic_abs         : $(bx_pbionic_abs)"
	@echo "bx_pbionic_rel         : $(bx_pbionic_rel)"
	@echo "----------------------------------------------------------------"
	@echo "bx_pbionic_target      : $(bx_pbionic_target)"	
	@echo "================================================================"


do_build:
	$(TEST_VAR) "$(build_pbionic_run_libc)" $(TEST_EQ) "1" $(TEST_THEN) \
		$(MAKE) -C libc -f buildx.mk TARGET=$(TARGET) \
	$(TEST_END)
	$(TEST_VAR) "$(build_pbionic_run_libdl)" $(TEST_EQ) "1" $(TEST_THEN) \
		$(MAKE) -C libdl -f buildx.mk TARGET=$(TARGET) \
	$(TEST_END)
	$(TEST_VAR) "$(build_pbionic_run_fdtrack)" $(TEST_EQ) "1" $(TEST_THEN) \
		$(MAKE) -C libfdtrack -f buildx.mk TARGET=$(TARGET) \
	$(TEST_END)
	$(TEST_VAR) "$(build_pbionic_run_libstdc++)" $(TEST_EQ) "1" $(TEST_THEN) \
		$(MAKE) -C libstdc++ -f buildx.mk TARGET=$(TARGET) \
	$(TEST_END)
	$(TEST_VAR) "$(build_pbionic_run_linker)" $(TEST_EQ) "1" $(TEST_THEN) \
		$(MAKE) -C linker -f buildx.mk TARGET=$(TARGET) \
	$(TEST_END)

clean: prepare
	$(RM) -rf "$(bx_pbionic_target)"
