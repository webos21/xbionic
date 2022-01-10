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

# PREPARE : set base
basedir = ../..
destdir = out

# PREPARE : shell commands
include $(basedir)/buildx/make/cmd.mk

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

# PREPARE : Directories
# Base
current_dir_abs        = $(CURDIR)
current_dir_rel        = $(notdir $(current_dir_abs))
# Base
module_dir_target      = $(basedir)/$(destdir)/$(build_cfg_target)/pbionic/$(current_dir_rel)
module_dir_object      = $(module_dir_target)/object
# Output
module_dir_output_base = $(basedir)/$(destdir)/$(build_cfg_target)/emul
module_dir_output_bin  = $(module_dir_output_base)/bin
module_dir_output_inc  = $(module_dir_output_base)/include
module_dir_output_lib  = $(module_dir_output_base)/lib
module_dir_output_res  = $(module_dir_output_base)/res
module_dir_output_test = $(module_dir_output_base)/test

# PREPARE : Build Options
module_build_cflags    = \
        -fno-emulated-tls                \
		-fno-stack-protector             \
		-ffreestanding                   \
        -I.                              \
		-Ibionic/libc/async_safe/include \
		-Ibionic/libc/platform           \
		-Isystem/core/libcutils/include  \
		-Ikernel/uapi                    \
		-Ikernel/android/uapi            \
        -Iinclude
ifeq ($(build_cfg_arch),arm64)
module_build_cflags += -Ikernel/uapi/asm-arm64
endif
ifeq ($(build_cfg_arch),x86_64)
module_build_cflags += -Ikernel/uapi/asm-x86
endif

module_build_ldflags   = 


# PREPARE : Source Variables
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

libc_jemalloc_wrapper =  bionic/jemalloc_wrapper.cpp

libc_bootstrap_src_files =                 \
    bionic/__libc_init_main_thread.cpp     \
    bionic/__stack_chk_fail.cpp            \
    bionic/bionic_call_ifunc_resolver.cpp  \
    bionic/getauxval.cpp
ifeq ($(build_cfg_arch),arm64)
libc_bootstrap_src_files += arch-arm64/bionic/__set_tls.c
endif
ifeq ($(build_cfg_arch),x86_64)
libc_bootstrap_src_files += arch-x86_64/bionic/__set_tls.c
endif

libc_init_static = bionic/libc_init_static.cpp
libc_init_dynamic = bionic/libc_init_dynamic.cpp

libc_tzcode = \
        $(wildcard tzcode/*.c)    \
        tzcode/bionic.cpp         \
        upstream-openbsd/lib/libc/time/wcsftime.c

# PREPARE : Set VPATH!!
vpath
vpath %.c bionic stdio arm64/bionic arch-x86_64/bionic tzcode
vpath %.cpp bionic stdio arm64/bionic arch-x86_64/bionic tzcode

# PREPARE : Build Targets
module_build_target_a  = $(build_opt_a_pre)c.$(build_opt_a_ext)
module_build_target_so = $(build_opt_so_pre)c.$(build_opt_so_ext)
module_build_src_mk    =            \
        $(libc_common_src_files)    \
		$(libc_jemalloc_wrapper)    \
		$(libc_bootstrap_src_files) \
		$(libc_init_static)         \
		$(libc_init_dynamic)        \
		$(libc_tzcode)
ifeq ($(build_run_a),1)
module_ostatic_tmp_c   = $(patsubst %.c,%.o,$(module_build_src_mk))
module_objs_static     = $(patsubst %.cpp,%.o,$(module_ostatic_tmp_c))
module_link_a_tmp1     = $(notdir $(module_objs_static))
module_link_static     = $(addprefix $(module_dir_object)/,$(module_link_a_tmp1))
module_target_static   = $(module_build_target_a)
endif
ifeq ($(build_run_so),1)
module_oshared_tmp_c   = $(patsubst %.c,%.lo,$(module_build_src_mk))
module_objs_shared     = $(patsubst %.cpp,%.lo,$(module_oshared_tmp_c))
module_link_so_tmp1    = $(notdir $(module_objs_shared))
module_link_shared     = $(addprefix $(module_dir_object)/,$(module_link_so_tmp1))
module_target_shared   = $(module_build_target_so)
endif


###################
# build-targets
###################

all: prepare $(module_target_static) $(module_target_shared) post

prepare_mkdir_base:
	@$(MKDIR) -p "$(module_dir_target)"
	@$(MKDIR) -p "$(module_dir_object)"

prepare_mkdir_output:
	@$(MKDIR) -p "$(module_dir_output_base)"
	@$(MKDIR) -p "$(module_dir_output_bin)"
	@$(MKDIR) -p "$(module_dir_output_inc)"
	@$(MKDIR) -p "$(module_dir_output_lib)"
	@$(MKDIR) -p "$(module_dir_output_res)"
	@$(MKDIR) -p "$(module_dir_output_test)"

prepare_result:
	@echo "$(need_warning)"
	@echo "================================================================"
	@echo "                           libc"
	@echo "================================================================"
	@echo "TARGET                  : $(TARGET)"
	@echo "----------------------------------------------------------------"
	@echo "current_dir_abs         : $(current_dir_abs)"
	@echo "current_dir_rel         : $(current_dir_rel)"
	@echo "----------------------------------------------------------------"
	@echo "module_dir_target       : $(module_dir_target)"	
	@echo "module_dir_object       : $(module_dir_object)"	
	@echo "module_dir_test         : $(module_dir_test)"	
	@echo "----------------------------------------------------------------"
	@echo "module_dir_output_base  : $(module_dir_output_base)"	
	@echo "module_dir_output_bin   : $(module_dir_output_bin)"	
	@echo "module_dir_output_inc   : $(module_dir_output_inc)"	
	@echo "module_dir_output_lib   : $(module_dir_output_lib)"	
	@echo "module_dir_output_res   : $(module_dir_output_res)"	
	@echo "module_dir_output_test  : $(module_dir_output_test)"	
	@echo "----------------------------------------------------------------"
	@echo "module_build_cflags     : $(module_build_cflags)"	
	@echo "module_build_ldflags    : $(module_build_ldflags)"	
	@echo "module_build_target_a   : $(module_build_target_a)"	
	@echo "module_build_target_so  : $(module_build_target_so)"	
	@echo "----------------------------------------------------------------"
	@echo "module_build_src_mk     : $(module_build_src_mk)"	
	@echo "module_objs_shared      : $(module_objs_shared)"	
	@echo "================================================================"

prepare: prepare_mkdir_base prepare_mkdir_output prepare_result


$(module_build_target_a): $(module_link_static)
	@echo "================================================================"
	@echo "BUILD : $(module_build_target_a)"
	@echo "----------------------------------------------------------------"
	$(build_tool_ar) rcu $(module_dir_target)/$(module_build_target_a) $(module_link_static)
	$(build_tool_ranlib) $(module_dir_target)/$(module_build_target_a)
	@echo "================================================================"


$(module_build_target_so): $(module_link_shared)
	@echo "================================================================"
	@echo "BUILD : $(module_build_target_so)"
	@echo "----------------------------------------------------------------"
	$(build_tool_linker) \
		$(build_opt_ld) \
		$(build_opt_ld_so)$(module_build_target_so) \
		-o $(module_dir_target)/$(module_build_target_so) \
		$(module_link_shared) \
		$(module_build_ldflags) \
		$(build_opt_ld_mgwcc)
	@echo "================================================================"


post:
	@echo "================================================================"
	@echo "OUTPUT : $(current_dir_abs)"
	@echo "----------------------------------------------------------------"
	$(CP) $(current_dir_abs)/include/coap2/*.h $(module_dir_output_inc)
	$(TEST_FILE) $(module_dir_target)/$(CRYPTO_A) $(TEST_THEN) \
		$(CP) $(module_dir_target)/$(CRYPTO_A) $(module_dir_output_lib) \
	$(TEST_END)
	$(TEST_FILE) $(module_dir_target)/$(module_build_target_a) $(TEST_THEN) \
		$(CP) $(module_dir_target)/$(module_build_target_a) $(module_dir_output_lib) \
	$(TEST_END)
	$(TEST_FILE) $(module_dir_target)/$(module_build_target_so) $(TEST_THEN) \
		$(CP) $(module_dir_target)/$(module_build_target_so) $(module_dir_output_lib) \
	$(TEST_END)
	@echo "================================================================"


clean: prepare
	$(RM) -rf "$(module_dir_target)"


###################
# build-rules
###################

$(module_dir_object)/%.o: %.c
	$(build_tool_cc) $(build_opt_c) $(module_build_cflags) -c -o $@ $<

$(module_dir_object)/%.o: %.cpp
	$(build_tool_cxx) $(build_opt_cxx) $(module_build_cflags) -c -o $@ $<

$(module_dir_object)/%.lo: %.c
	$(build_tool_cc) $(build_opt_c) $(build_opt_fPIC) $(module_build_cflags) -c -o $@ $<

$(module_dir_object)/%.lo: %.cpp
	$(build_tool_cxx) $(build_opt_cxx) $(build_opt_fPIC) $(module_build_cflags) -c -o $@ $<


