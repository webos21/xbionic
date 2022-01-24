# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# this file is included repeatedly from build/core/setup-toolchain.mk
# and is used to prepare for app-specific build rules.
#
$(call assert-defined,_app)
# the location of generated files for this app
HOST_OUT    := $(NDK_APP_OUT)/$(_app)/$(HOST_TAG)
HOST_OBJS   := $(HOST_OUT)/objs
TARGET_OUT  := $(NDK_APP_OUT)/$(_app)/$(TARGET_ABI)
TARGET_OBJS := $(TARGET_OUT)/objs
TARGET_GDB_SETUP := $(TARGET_OUT)/setup.gdb

# ok, let's parse all Android.mk source files in order to build
# the modules for this app.
#
# Restore the APP_XXX variables just for this pass as NDK_APP_XXX
#
NDK_APP_NAME           := $(_app)
NDK_APP_APPLICATION_MK := $(NDK_APP.$(_app).Application.mk)
$(foreach __name,$(NDK_APP_VARS),\
  $(eval NDK_$(__name) := $(NDK_APP.$(_app).$(__name)))\
)
# set release/debug build flags
#
ifeq ($(NDK_APP_OPTIM),debug)
  NDK_APP_CPPFLAGS := -O0 -g $(NDK_APP_CPPFLAGS)
else
  NDK_APP_CPPFLAGS := -O2 -DNDEBUG -g $(NDK_APP_CPPFLAGS)
endif

# compute NDK_APP_DEST as the destination directory for the generated files
NDK_APP_DEST := $(NDK_APP_PROJECT_PATH)/libs/$(TARGET_ABI_SUBDIR)

$(call __ndk_info,NDK_APP_DEST = '$(NDK_APP_DEST)')

# make the application depend on the modules it requires
.PHONY: ndk-app-$(_app)
ndk-app-$(_app): $(NDK_APP_MODULES)
all: ndk-app-$(_app)
# free the dictionary of LOCAL_MODULE definitions
$(call modules-clear)
