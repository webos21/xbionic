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
# ====================================================================
#
# Define the main configuration variables, and read the host-specific
# configuration file that is normally generated by build/host-setup.sh
#
# ====================================================================

basedir = ..

# ====================================================================
# build-local.mk : Directory Setting 
# ====================================================================

# Don't output to stdout if we're being invoked to dump a variable
DUMP_VAR := $(patsubst DUMP_%,%,$(filter DUMP_%,$(MAKECMDGOALS)))
ifneq (,$(DUMP_VAR))
    NDK_NO_INFO := 1
    NDK_NO_WARNINGS := 1
endif

NDK_ROOT := $(basedir)

ifeq ($(NDK_LOG),1)
    $(info Android NDK: NDK installation path auto-detected: '$(NDK_ROOT)')
endif
ifneq ($(words $(NDK_ROOT)),1)
    $(info Android NDK: Your NDK installation path contains spaces.)
    $(info Android NDK: Please re-install to a different location to fix the issue !)
    $(error Aborting.)
endif

# ====================================================================
# init.mk : BEGIN
# ====================================================================

# Disable GNU Make implicit rules

# this turns off the suffix rules built into make
.SUFFIXES:

# this turns off the RCS / SCCS implicit rules of GNU Make
% : RCS/%,v
% : RCS/%
% : %,v
% : s.%
% : SCCS/s.%

# If a rule fails, delete $@.
.DELETE_ON_ERROR:

# Define NDK_LOG=1 in your environment to display log traces when
# using the build scripts. See also the definition of ndk_log below.
#
NDK_LOG := $(strip $(NDK_LOG))
ifeq ($(NDK_LOG),true)
    override NDK_LOG := 1
endif

# Check that we have at least GNU Make 3.81
# We do this by detecting whether 'lastword' is supported
#
MAKE_TEST := $(lastword a b c d e f)
ifneq ($(MAKE_TEST),f)
    $(error Android NDK: GNU Make version $(MAKE_VERSION) is too low (should be >= 3.81))
endif
ifeq ($(NDK_LOG),1)
    $(info Android NDK: GNU Make version $(MAKE_VERSION) detected)
endif

# NDK_ROOT *must* be defined and point to the root of the NDK installation
NDK_ROOT := $(strip $(NDK_ROOT))
ifndef NDK_ROOT
    $(error ERROR while including init.mk: NDK_ROOT must be defined !)
endif
ifneq ($(words $(NDK_ROOT)),1)
    $(info,The Android NDK installation path contains spaces: '$(NDK_ROOT)')
    $(error,Please fix the problem by reinstalling to a different location.)
endif

# --------------------------------------------------------------------
#
# Define a few useful variables and functions.
# More stuff will follow in definitions.mk.
#
# --------------------------------------------------------------------

# Used to output warnings and error from the library, it's possible to
# disable any warnings or errors by overriding these definitions
# manually or by setting NDK_NO_WARNINGS or NDK_NO_ERRORS

__ndk_name    := Android NDK
__ndk_info     = $(info $(__ndk_name): $1 $2 $3 $4 $5)
__ndk_warning  = $(warning $(__ndk_name): $1 $2 $3 $4 $5)
__ndk_error    = $(error $(__ndk_name): $1 $2 $3 $4 $5)

ifdef NDK_NO_INFO
__ndk_info :=
endif
ifdef NDK_NO_WARNINGS
__ndk_warning :=
endif
ifdef NDK_NO_ERRORS
__ndk_error :=
endif

# --------------------------------------------------------------------
# Function : ndk_log
# Arguments: 1: text to print when NDK_LOG is defined to 1
# Returns  : None
# Usage    : $(call ndk_log,<some text>)
# --------------------------------------------------------------------
ifeq ($(NDK_LOG),1)
ndk_log = $(info $(__ndk_name): $1)
else
ndk_log :=
endif

# --------------------------------------------------------------------
# Host and Toolchain Setting 
# --------------------------------------------------------------------

ifeq ($(TARGET),)
$(call __ndk_info,Warning : you are here without proper command!!!!)
include $(basedir)/buildx/make/project.mk
include $(basedir)/buildx/make/$(project_def_target).mk
TARGET = $(project_def_target)
else
include $(basedir)/buildx/make/project.mk
include $(basedir)/buildx/make/$(TARGET).mk
endif

NDK_ALL_ARCHS := x86_64 arm64
NDK_ALL_TOOLCHAINS := aarch64-linux-android-clang x86_64-clang

NDK_ARCH.arm64.abis := arm64-v8a
NDK_ARCH.x86_64.abis := x86_64

NDK_ABI.arm64-v8a.arch = arm64
NDK_ABI.x86_64.arch = x86_64

NDK_ABI.arm64-v8a.toolchains = aarch64-linux-android-clang
NDK_ABI.x86_64.toolchains = x86_64-clang

NDK_TOOLCHAIN.aarch64-linux-android-clang.abis := arm64-v8a
NDK_TOOLCHAIN.x86_64-clang.abis := x86_64


# --------------------------------------------------------------------
# Load definitions.mk 
# --------------------------------------------------------------------

# The location of the build system files
BUILD_SYSTEM := $(basedir)/buildx/make/ndk

# Include common definitions
include $(BUILD_SYSTEM)/definitions.mk


# --------------------------------------------------------------------
# ABI and PLATFORM settings 
# --------------------------------------------------------------------

# checkbuild.py generates these two files from the files in $NDK/meta.
include $(BUILD_SYSTEM)/abis.mk
include $(BUILD_SYSTEM)/platforms.mk

NDK_KNOWN_DEVICE_ABIS := $(NDK_KNOWN_DEVICE_ABI64S) $(NDK_KNOWN_DEVICE_ABI32S)

NDK_APP_ABI_ALL_EXPANDED := $(NDK_KNOWN_DEVICE_ABIS)
NDK_APP_ABI_ALL32_EXPANDED := $(NDK_KNOWN_DEVICE_ABI32S)
NDK_APP_ABI_ALL64_EXPANDED := $(NDK_KNOWN_DEVICE_ABI64S)

NDK_MIN_PLATFORM := android-$(NDK_MIN_PLATFORM_LEVEL)
NDK_MAX_PLATFORM := android-$(NDK_MAX_PLATFORM_LEVEL)

$(call ndk_log,Found max platform level: $(NDK_MAX_PLATFORM_LEVEL))

# Allow the user to define NDK_TOOLCHAIN to a custom toolchain name.
# This is normally used when the NDK release comes with several toolchains
# for the same architecture (generally for backwards-compatibility).
#
NDK_TOOLCHAIN := $(strip $(NDK_TOOLCHAIN))
ifdef NDK_TOOLCHAIN
    # check that the toolchain name is supported
    $(if $(filter-out $(NDK_ALL_TOOLCHAINS),$(NDK_TOOLCHAIN)),\
      $(call __ndk_info,NDK_TOOLCHAIN is defined to the unsupported value $(NDK_TOOLCHAIN)) \
      $(call __ndk_info,Please use one of the following values: $(NDK_ALL_TOOLCHAINS))\
      $(call __ndk_error,Aborting)\
    ,)
    $(call ndk_log, Using specific toolchain $(NDK_TOOLCHAIN))
endif

$(call ndk_log, This NDK supports the following target architectures and ABIS:)
$(foreach arch,$(NDK_ALL_ARCHS),\
    $(call ndk_log, $(space)$(space)$(arch): $(NDK_ARCH.$(arch).abis))\
)
$(call ndk_log, This NDK supports the following toolchains and target ABIs:)
$(foreach tc,$(NDK_ALL_TOOLCHAINS),\
    $(call ndk_log, $(space)$(space)$(tc):  $(NDK_TOOLCHAIN.$(tc).abis))\
)

$(call ndk_log,Toolchain Variables)
$(call ndk_log,$(space) TARGET_TOOLCHAIN = '$(TARGET_TOOLCHAIN)')
$(call ndk_log,$(space) TARGET_PLATFORM  = '$(TARGET_PLATFORM)')
$(call ndk_log,$(space) TARGET_ARCH_ABI  = '$(TARGET_ARCH_ABI)')
$(call ndk_log,$(space) TARGET_ABI       = '$(TARGET_ABI)')
$(call ndk_log,$(space) SYSROOT          = '$(SYSROOT)')
$(call ndk_log,$(space) TARGET_CRTBEGIN_STATIC_O         = '$(TARGET_CRTBEGIN_STATIC_O)')
$(call ndk_log,$(space) TARGET_CRTBEGIN_DYNAMIC_O        = '$(TARGET_CRTBEGIN_DYNAMIC_O)')
$(call ndk_log,$(space) TARGET_CRTEND_O                  = '$(TARGET_CRTEND_O)')
$(call ndk_log,$(space) TARGET_PREBUILT_SHARED_LIBRARIES = '$(TARGET_PREBUILT_SHARED_LIBRARIES)')
$(call ndk_log,$(space) TARGET_PREBUILT_SHARED_LIBRARIES = '$(TARGET_PREBUILT_SHARED_LIBRARIES)')

# ====================================================================
# init.mk : END
# ====================================================================


# --------------------------------------------------------------------
# Project Path Definitions 
# --------------------------------------------------------------------

NDK_PROJECT_PATH := .
APP_PROJECT_PATH := .

# Where all generated files will be stored during a build
NDK_OUT := $(basedir)/out

# Where all app-specific generated files will be stored
NDK_APP_OUT := $(NDK_OUT)/apps

# Where all app-libs-specific generated files will be stored
NDK_APP_LIBS_OUT := $(NDK_APP_OUT)/libs

# Where all host-specific generated files will be stored
NDK_HOST_OUT := $(NDK_OUT)/host/$(HOST_TAG)


$(call ndk_log,Output Directories)
$(call ndk_log,$(space) NDK_OUT          = '$(NDK_OUT)')
$(call ndk_log,$(space) NDK_APP_OUT      = '$(NDK_APP_OUT)')
$(call ndk_log,$(space) NDK_APP_LIBS_OUT = '$(NDK_APP_LIBS_OUT)')
$(call ndk_log,$(space) NDK_HOST_OUT     = '$(NDK_HOST_OUT)')


# ====================================================================
# add-application.mk : BEGIN 
# ====================================================================

NDK_APP_VARS := APP_MODULES APP_PROJECT_PATH
NDK_APPLICATION_MK := $(BUILD_SYSTEM)/default-application.mk
NDK_APP_BUILD_SCRIPT := buildx.mk

APP := malloc
APP_PLATFORM_LEVEL := 21

NDK_APPS := $(APP)
NDK_APP_ABI := all64
#NDK_APP_STL := c++_static

NDK_APP_MODULES := jemalloc jemalloc_jet jemalloc_unittest

NDK_ALL_APPS := malloc
$(call set,NDK_APP.malloc,Application.mk,$(basedir)/apps/malloc/Application.mk)
$(call set,NDK_APP.malloc,APP_MODULES,$(NDK_APP_MODULES))
$(call set,NDK_APP.malloc,APP_PROJECT_PATH,$(basedir)/apps/malloc/project)

$(call ndk_log,App Settings)
$(call ndk_log,$(space) APP              = '$(APP)')
$(call ndk_log,$(space) NDK_APPS         = '$(NDK_APPS)')
$(call ndk_log,$(space) NDK_APP_ABI      = '$(NDK_APP_ABI)')
$(call ndk_log,$(space) NDK_ALL_APPS     = '$(NDK_ALL_APPS)')
$(call ndk_log,$(space) NDK_APP_VARS     = '$(NDK_APP_VARS)')
$(call ndk_log,$(space) NDK_APP.malloc.Application.mk   = '$(call get,NDK_APP.malloc,Application.mk)')
$(call ndk_log,$(space) NDK_APP.malloc.APP_MODULES      = '$(call get,NDK_APP.malloc,APP_MODULES)')
$(call ndk_log,$(space) NDK_APP.malloc.APP_PROJECT_PATH = '$(call get,NDK_APP.malloc,APP_PROJECT_PATH)')

$(call __ndk_info,Building for application '$(NDK_APPS)')

# ====================================================================
# add-application.mk : END 
# ====================================================================

# If a goal is DUMP_xxx then we dump a variable xxx instead
# of building anything
#
MAKECMDGOALS := $(filter-out DUMP_$(DUMP_VAR),$(MAKECMDGOALS))


# ====================================================================
# ignore : setup-imports.mk
# ====================================================================


# ====================================================================
# build-all.mk : BEGIN
# ====================================================================

# These phony targets are used to control various stages of the build
.PHONY: \
    all \
    host_libraries \
    host_executables \
    installed_modules \
    executables libraries \
    static_libraries \
    shared_libraries \
    clean clean-objs-dir \
    clean-executables clean-libraries \
    clean-installed-modules \
    clean-installed-binaries \
    clang_tidy_rules \

# These macros are used in Android.mk to include the corresponding
# build script that will parse the LOCAL_XXX variable definitions.
#
CLEAR_VARS                := $(BUILD_SYSTEM)/clear-vars.mk
BUILD_HOST_EXECUTABLE     := $(BUILD_SYSTEM)/build-host-executable.mk
BUILD_HOST_STATIC_LIBRARY := $(BUILD_SYSTEM)/build-host-static-library.mk
BUILD_STATIC_LIBRARY      := $(BUILD_SYSTEM)/build-static-library.mk
BUILD_SHARED_LIBRARY      := $(BUILD_SYSTEM)/build-shared-library.mk
BUILD_EXECUTABLE          := $(BUILD_SYSTEM)/build-executable.mk
PREBUILT_SHARED_LIBRARY   := $(BUILD_SYSTEM)/prebuilt-shared-library.mk
PREBUILT_STATIC_LIBRARY   := $(BUILD_SYSTEM)/prebuilt-static-library.mk

ANDROID_MK_INCLUDED := \
  $(CLEAR_VARS) \
  $(BUILD_HOST_EXECUTABLE) \
  $(BUILD_HOST_STATIC_LIBRARY) \
  $(BUILD_STATIC_LIBRARY) \
  $(BUILD_SHARED_LIBRARY) \
  $(BUILD_EXECUTABLE) \
  $(PREBUILT_SHARED_LIBRARY) \

# the first rule
all: installed_modules host_libraries host_executables clang_tidy_rules


# ====================================================================
# setup-app.mk : BEGIN
# ====================================================================

_app = $(APP)

$(call assert-defined,_app)

_map := NDK_APP.$(_app)

# ok, let's parse all Android.mk source files in order to build
# the modules for this app.
#

# Restore the APP_XXX variables just for this pass as NDK_APP_XXX
#
NDK_APP_NAME           := $(_app)
NDK_APP_APPLICATION_MK := $(call get,$(_map),Application.mk)

$(foreach __name,$(NDK_APP_VARS),\
  $(eval NDK_$(__name) := $(call get,$(_map),$(__name)))\
)

# make the application depend on the modules it requires
.PHONY: ndk-app-$(_app)
ndk-app-$(_app): $(NDK_APP_MODULES)
all: ndk-app-$(_app)

# The ABI(s) to use
NDK_APP_ABI := $(subst $(comma),$(space),$(strip $(NDK_APP_ABI)))
ifndef NDK_APP_ABI
    NDK_APP_ABI := $(NDK_DEFAULT_ABIS)
endif

NDK_ABI_FILTER := $(strip $(NDK_ABI_FILTER))
ifdef NDK_ABI_FILTER
    $(eval $(NDK_ABI_FILTER))
endif

# If APP_ABI is 'all', then set it to all supported ABIs
# Otherwise, check that we don't have an invalid value here.
#
ifeq ($(NDK_APP_ABI),all)
    NDK_APP_ABI := $(NDK_APP_ABI_ALL_EXPANDED)
else ifeq ($(NDK_APP_ABI),all32)
    NDK_APP_ABI := $(NDK_APP_ABI_ALL32_EXPANDED)
else ifeq ($(NDK_APP_ABI),all64)
    NDK_APP_ABI := $(NDK_APP_ABI_ALL64_EXPANDED)
else
    # check the target ABIs for this application
    _bad_abis = $(strip $(filter-out $(NDK_ALL_ABIS),$(NDK_APP_ABI)))
    ifneq ($(_bad_abis),)
        ifneq ($(filter $(_bad_abis),armeabi-v7a-hard),)
            $(call __ndk_info,armeabi-v7a-hard is no longer supported. Use armeabi-v7a.)
            $(call __ndk_info,See https://android.googlesource.com/platform/ndk/+/master/docs/HardFloatAbi.md)
        else ifneq ($(filter $(_bad_abis),armeabi),)
            $(call __ndk_info,The armeabi ABI is no longer supported. Use armeabi-v7a.)
        else ifneq ($(filter $(_bad_abis),mips mips64),)
            $(call __ndk_info,MIPS and MIPS64 are no longer supported.)
        endif
        $(call __ndk_info,NDK Application '$(_app)' targets unknown ABI(s): $(_bad_abis))
        $(call __ndk_info,Please fix the APP_ABI definition in $(NDK_APP_APPLICATION_MK))
        $(call __ndk_error,Aborting)
    endif
endif

_deprecated_abis := $(filter $(NDK_DEPRECATED_ABIS),$(NDK_APP_ABI))
ifneq ($(_deprecated_abis),)
    $(call __ndk_warning,Application targets deprecated ABI(s): $(_deprecated_abis))
    $(call __ndk_warning,Support for these ABIs will be removed in a future NDK release.)
endif

# Clear all installed binaries for this application. This ensures that if the
# build fails or if you remove a module, you're not going to mistakenly package
# an obsolete version.
#
# Historically this would clear every ABI, meaning that the following workflow
# would leave only x86_64 present in the lib dir on completion:
#
#     for abi in armeabi-v7a arm64-v8a x86 x86_64; do
#         ndk-build APP_ABI=$abi
#     done
#
# This is the workflow used by gradle. They currently override NDK_ALL_ABIS (an
# internal variable) to workaround this behavior. Changing this behavior allows
# them to remove their workaround and stop clobbering our implementation
# details.
ifeq ($(NDK_APP.$(_app).cleaned_binaries),)
    NDK_APP.$(_app).cleaned_binaries := true

clean-installed-binaries::
	$(hide) $(call host-rm,$(NDK_APP_ABI:%=$(NDK_APP_LIBS_OUT)/%/*))
	$(hide) $(call host-rm,$(NDK_APP_ABI:%=$(NDK_APP_LIBS_OUT)/%/gdbserver))
	$(hide) $(call host-rm,$(NDK_APP_ABI:%=$(NDK_APP_LIBS_OUT)/%/gdb.setup))
endif

# Renderscript

RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT := \
    $(NDK_ROOT)/toolchains/renderscript/prebuilt/$(HOST_TAG64)
RENDERSCRIPT_TOOLCHAIN_PREFIX := $(RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT)/bin/
RENDERSCRIPT_TOOLCHAIN_HEADER := $(RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT)/clang-include
RENDERSCRIPT_PLATFORM_HEADER := $(RENDERSCRIPT_TOOLCHAIN_PREBUILT_ROOT)/platform/rs

COMPILE_COMMANDS_JSON := $(call host-path,compile_commands.json)
sub_commands_json :=


# ====================================================================
# setup-abi.mk : BEGIN
# ====================================================================

TARGET_ARCH_ABI := arm64-v8a

$(call ndk_log,Building application '$(NDK_APP_NAME)' for ABI '$(TARGET_ARCH_ABI)')

TARGET_ARCH := $(strip $(NDK_ABI.$(TARGET_ARCH_ABI).arch))
ifndef TARGET_ARCH
    $(call __ndk_info,ERROR: The $(TARGET_ARCH_ABI) ABI has no associated architecture!)
    $(call __ndk_error,Aborting...)
endif

TARGET_OUT := $(NDK_APP_OUT)/$(_app)/$(TARGET_ARCH_ABI)

TARGET_PLATFORM_LEVEL := $(APP_PLATFORM_LEVEL)

# 64-bit ABIs were first supported in API 21. Pull up these ABIs if the app has
# a lower minSdkVersion.
ifneq ($(filter $(NDK_KNOWN_DEVICE_ABI64S),$(TARGET_ARCH_ABI)),)
    ifneq ($(call lt,$(TARGET_PLATFORM_LEVEL),21),)
        TARGET_PLATFORM_LEVEL := 21
    endif
endif

# Not used by ndk-build, but are documented for use by Android.mk files.
TARGET_PLATFORM := android-$(TARGET_PLATFORM_LEVEL)
TARGET_ABI := $(TARGET_PLATFORM)-$(TARGET_ARCH_ABI)

# If we're targeting a new enough platform version, we don't actually need to
# cover any gaps in libc for libc++ support. In those cases, save size in the
# APK by avoiding libandroid_support.
#
# This is also a requirement for static executables, since using
# libandroid_support with a modern libc.a will result in multiple symbol
# definition errors.
NDK_PLATFORM_NEEDS_ANDROID_SUPPORT := true
ifeq ($(call gte,$(TARGET_PLATFORM_LEVEL),21),$(true))
    NDK_PLATFORM_NEEDS_ANDROID_SUPPORT := false
endif

# Separate the debug and release objects. This prevents rebuilding
# everything when you switch between these two modes. For projects
# with lots of C++ sources, this can be a considerable time saver.
ifeq ($(NDK_APP_OPTIM),debug)
TARGET_OBJS := $(TARGET_OUT)/objs-debug
else
TARGET_OBJS := $(TARGET_OUT)/objs
endif

TARGET_GDB_SETUP := $(TARGET_OUT)/setup.gdb

# RS triple
ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
  RS_TRIPLE := armv7-none-linux-gnueabi
endif
ifeq ($(TARGET_ARCH_ABI),armeabi)
  RS_TRIPLE := arm-none-linux-gnueabi
endif
ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
  RS_TRIPLE := aarch64-linux-android
endif
ifeq ($(TARGET_ARCH_ABI),mips)
  RS_TRIPLE := mipsel-unknown-linux
endif
ifeq ($(TARGET_ARCH_ABI),x86)
  RS_TRIPLE := i686-unknown-linux
endif
ifeq ($(TARGET_ARCH_ABI),x86_64)
  RS_TRIPLE := x86_64-unknown-linux
endif

# ====================================================================
# setup-toolchain.mk : END
# ====================================================================


$(call assert-defined,TARGET_PLATFORM_LEVEL TARGET_ARCH TARGET_ARCH_ABI)
#$(call assert-defined,NDK_APPS NDK_APP_STL)

# Check that we have a toolchain that supports the current ABI.
# NOTE: If NDK_TOOLCHAIN is defined, we're going to use it.
ifndef NDK_TOOLCHAIN
    # TODO: Remove all the multiple-toolchain configuration stuff. We only have
    # Clang.

    # This is a sorted list of toolchains that support the given ABI. For older
    # NDKs this was a bit more complicated, but now we just have the GCC and the
    # Clang toolchains with GCC being first (named "*-4.9", whereas clang is
    # "*-clang").
    TARGET_TOOLCHAIN_LIST := \
        $(strip $(sort $(NDK_ABI.$(TARGET_ARCH_ABI).toolchains)))

    ifneq ($(words $(TARGET_TOOLCHAIN_LIST)),1)
        $(call __ndk_error,Expected two items in TARGET_TOOLCHAIN_LIST, \
            found "$(TARGET_TOOLCHAIN_LIST)")
    endif

    ifndef TARGET_TOOLCHAIN_LIST
        $(call __ndk_info,There is no toolchain that supports the $(TARGET_ARCH_ABI) ABI.)
        $(call __ndk_info,Please modify the APP_ABI definition in $(NDK_APP_APPLICATION_MK) to use)
        $(call __ndk_info,a set of the following values: $(NDK_ALL_ABIS))
        $(call __ndk_error,Aborting)
    endif

    # We default to using Clang, which is the last item in the list.
    TARGET_TOOLCHAIN := $(lastword $(TARGET_TOOLCHAIN_LIST))

    $(call ndk_log,Using target toolchain '$(TARGET_TOOLCHAIN)' for '$(TARGET_ARCH_ABI)' ABI)
else # NDK_TOOLCHAIN is not empty
    TARGET_TOOLCHAIN_LIST := $(strip $(filter $(NDK_TOOLCHAIN),$(NDK_ABI.$(TARGET_ARCH_ABI).toolchains)))
    ifndef TARGET_TOOLCHAIN_LIST
        $(call __ndk_info,The selected toolchain ($(NDK_TOOLCHAIN)) does not support the $(TARGET_ARCH_ABI) ABI.)
        $(call __ndk_info,Please modify the APP_ABI definition in $(NDK_APP_APPLICATION_MK) to use)
        $(call __ndk_info,a set of the following values: $(NDK_TOOLCHAIN.$(NDK_TOOLCHAIN).abis))
        $(call __ndk_info,Or change your NDK_TOOLCHAIN definition.)
        $(call __ndk_error,Aborting)
    endif
    TARGET_TOOLCHAIN := $(NDK_TOOLCHAIN)
endif # NDK_TOOLCHAIN is not empty

TARGET_PREBUILT_SHARED_LIBRARIES :=

# Define default values for TOOLCHAIN_NAME, this can be overriden in
# the setup file.
TOOLCHAIN_NAME   := $(TARGET_TOOLCHAIN)
TOOLCHAIN_VERSION := $(call last,$(subst -,$(space),$(TARGET_TOOLCHAIN)))

# We expect the gdbserver binary for this toolchain to be located at its root.
TARGET_GDBSERVER := $(NDK_ROOT)/prebuilt/android-$(TARGET_ARCH)/gdbserver/gdbserver

# compute NDK_APP_DST_DIR as the destination directory for the generated files
NDK_APP_DST_DIR := $(NDK_APP_LIBS_OUT)/$(TARGET_ARCH_ABI)


# ====================================================================
# default-build-commands.mk : BEGIN
# ====================================================================

# These flags are used to ensure that a binary doesn't reference undefined
# flags.
TARGET_NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined


# Return the list of object, static libraries and shared libraries as they
# must appear on the final static linker command (order is important).
#
# This can be over-ridden by a specific toolchain. Note that by default
# we always put libgcc _after_ all static libraries and _before_ shared
# libraries. This ensures that any libgcc function used by the final
# executable will be copied into it. Otherwise, it could contain
# symbol references to the same symbols as exported by shared libraries
# and this causes binary compatibility problems when they come from
# system libraries (e.g. libc.so and others).
#
# IMPORTANT: The result must use the host path convention.
#
# $1: object files
# $2: static libraries
# $3: whole static libraries
# $4: shared libraries
#
TARGET-get-linker-objects-and-libraries = \
    $(call host-path, $1) \
    $(call link-whole-archives,$3) \
    $(call host-path, $2) \
    $(PRIVATE_LIBATOMIC) \
    $(call host-path, $4) \

# This flag are used to provide compiler protection against format
# string vulnerabilities.
TARGET_FORMAT_STRING_CFLAGS := -Wformat -Werror=format-security

# This flag disables the above security checks
TARGET_DISABLE_FORMAT_STRING_CFLAGS := -Wno-error=format-security

define cmd-build-shared-library
$(PRIVATE_CXX) \
    -Wl,-soname,$(notdir $(LOCAL_BUILT_MODULE)) \
    -shared \
    $(PRIVATE_LINKER_OBJECTS_AND_LIBRARIES) \
    $(GLOBAL_LDFLAGS) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    -o $(call host-path,$(LOCAL_BUILT_MODULE))
endef

# The following -rpath-link= are needed for ld.bfd (default for ARM64) when
# linking executables to supress warning about missing symbol from libraries not
# directly needed. ld.gold (default for all other architectures) doesn't emulate
# this buggy behavior.
define cmd-build-executable
$(PRIVATE_CXX) \
    -Wl,--gc-sections \
    -Wl,-rpath-link=$(call host-path,$(PRIVATE_SYSROOT_API_LIB_DIR)) \
    -Wl,-rpath-link=$(call host-path,$(TARGET_OUT)) \
    $(PRIVATE_LINKER_OBJECTS_AND_LIBRARIES) \
    $(GLOBAL_LDFLAGS) \
    $(PRIVATE_LDFLAGS) \
    $(PRIVATE_LDLIBS) \
    -o $(call host-path,$(LOCAL_BUILT_MODULE))
endef

define cmd-build-static-library
$(PRIVATE_AR) $(call host-path,$(LOCAL_BUILT_MODULE)) $(PRIVATE_AR_OBJECTS)
endef

cmd-strip = $(PRIVATE_STRIP) $(PRIVATE_STRIP_MODE) $(call host-path,$1)

# arm32 currently uses a linker script in place of libgcc to ensure that
# libunwind is linked in the correct order. --exclude-libs does not propagate to
# the contents of the linker script and can't be specified within the linker
# script. Hide both regardless of architecture to future-proof us in case we
# move other architectures to a linker script (which we may want to do so we
# automatically link libclangrt on other architectures).
TARGET_LIBATOMIC = -latomic
TARGET_LDLIBS := -lc -lm

TOOLCHAIN_ROOT := $(NDK_ROOT)/toolchains/llvm/prebuilt/$(HOST_TAG64)
LLVM_TOOLCHAIN_PREFIX := $(TOOLCHAIN_ROOT)/bin/


# IMPORTANT: The following definitions must use lazy assignment because
# the value of TOOLCHAIN_NAME or TARGET_CFLAGS can be changed later by
# the toolchain's setup.mk script.
TOOLCHAIN_PREFIX = $(TOOLCHAIN_ROOT)/bin/$(TOOLCHAIN_NAME)-

# cmjo : edit
#TARGET_CC = $(LLVM_TOOLCHAIN_PREFIX)clang$(HOST_EXEEXT)
#TARGET_CXX = $(LLVM_TOOLCHAIN_PREFIX)clang++$(HOST_EXEEXT)
TARGET_CC = gcc$(HOST_EXEEXT)
TARGET_CXX = g++$(HOST_EXEEXT)

# cmjo : edit
#CLANG_TIDY = $(LLVM_TOOLCHAIN_PREFIX)clang-tidy$(HOST_EXEEXT)
CLANG_TIDY = clang-tidy$(HOST_EXEEXT)

# cmjo : remove from GLOBAL_CFLAGS
#    -target $(LLVM_TRIPLE)$(TARGET_PLATFORM_LEVEL) \

GLOBAL_CFLAGS = \
    -fdata-sections \
    -ffunction-sections \
    -fstack-protector-strong \
    -funwind-tables \
    -no-canonical-prefixes \

# This is unnecessary given the new toolchain layout, but Studio will not
# recognize this as an Android build if there is no --sysroot flag.
# TODO: Teach Studio to recognize Android builds based on --target.

# cmjo : commenting
#GLOBAL_CFLAGS += --sysroot $(call host-path,$(NDK_UNIFIED_SYSROOT_PATH))

# Always enable debug info. We strip binaries when needed.
GLOBAL_CFLAGS += -g

# TODO: Remove.
GLOBAL_CFLAGS += \
    -Wno-invalid-command-line-argument \
    -Wno-unused-command-line-argument \

GLOBAL_CFLAGS += -D_FORTIFY_SOURCE=2

GLOBAL_LDFLAGS = \
    -target $(LLVM_TRIPLE)$(TARGET_PLATFORM_LEVEL) \
    -no-canonical-prefixes \

GLOBAL_CXXFLAGS = $(GLOBAL_CFLAGS) -std=gnu++17 -fno-exceptions -fno-rtti

TARGET_CFLAGS =
TARGET_CONLYFLAGS =
TARGET_CXXFLAGS = $(TARGET_CFLAGS)

TARGET_RS_CC    = $(RENDERSCRIPT_TOOLCHAIN_PREFIX)llvm-rs-cc
TARGET_RS_BCC   = $(RENDERSCRIPT_TOOLCHAIN_PREFIX)bcc_compat
TARGET_RS_FLAGS = -Wall -Werror
ifeq (,$(findstring 64,$(TARGET_ARCH_ABI)))
TARGET_RS_FLAGS += -m32
else
TARGET_RS_FLAGS += -m64
endif

# cmjo : edit
#TARGET_ASM      = $(TOOLCHAIN_ROOT)/bin/yasm
TARGET_ASM      = as
TARGET_ASMFLAGS =

# cmjo : edit
#TARGET_LD       = $(TOOLCHAIN_ROOT)/bin/ld
TARGET_LD       = ld
TARGET_LDFLAGS :=

# cmjo : edit
#TARGET_AR = $(LLVM_TOOLCHAIN_PREFIX)llvm-ar$(HOST_EXEEXT)
TARGET_AR = ar$(HOST_EXEEXT)
TARGET_ARFLAGS := crs

# cmjo : edit
#TARGET_STRIP = $(LLVM_TOOLCHAIN_PREFIX)llvm-strip$(HOST_EXEEXT)
TARGET_STRIP = strip$(HOST_EXEEXT)

TARGET_OBJ_EXTENSION := .o
TARGET_LIB_EXTENSION := .a
TARGET_SONAME_EXTENSION := .so

# ====================================================================
# default-build-commands.mk : END
# ====================================================================


# ====================================================================
# now call the toolchain-specific setup script : BEGIN
# ====================================================================

TOOLCHAIN_NAME := aarch64-linux-android
LLVM_TRIPLE := aarch64-none-linux-android

TARGET_TOOLCHAIN_ARCH_LIB_DIR := aarch64
TARGET_ASAN_BASENAME := libclang_rt.asan-aarch64-android.so
TARGET_UBSAN_BASENAME := libclang_rt.ubsan_standalone-aarch64-android.so

TARGET_CFLAGS := -fpic

TARGET_arm64_release_CFLAGS := \
    -O2 \
    -DNDEBUG \

TARGET_arm64_debug_CFLAGS := \
    -O0 \
    -UNDEBUG \
    -fno-limit-debug-info \

# This function will be called to determine the target CFLAGS used to build
# a C or Assembler source file, based on its tags.
#
TARGET-process-src-files-tags = \
$(eval __debug_sources := $(call get-src-files-with-tag,debug)) \
$(eval __release_sources := $(call get-src-files-without-tag,debug)) \
$(call set-src-files-target-cflags, $(__debug_sources), $(TARGET_arm64_debug_CFLAGS)) \
$(call set-src-files-target-cflags, $(__release_sources),$(TARGET_arm64_release_CFLAGS)) \

# ====================================================================
# now call the toolchain-specific setup script : END
# ====================================================================

# Setup sysroot variables.
#
# Note that these are not needed for the typical case of invoking Clang, as
# Clang already knows where the sysroot is relative to itself. We still need to
# manually refer to these in some places because other tools such as yasm and
# the renderscript compiler don't have this knowledge.

# SYSROOT_INC points to a directory that contains all public header files for a
# given platform.
ifndef NDK_UNIFIED_SYSROOT_PATH
    NDK_UNIFIED_SYSROOT_PATH := $(TOOLCHAIN_ROOT)/sysroot
endif

# TODO: Have the driver add the library path to -rpath-link.
SYSROOT_INC := $(NDK_UNIFIED_SYSROOT_PATH)

SYSROOT_LIB_DIR := $(NDK_UNIFIED_SYSROOT_PATH)/usr/lib/$(TOOLCHAIN_NAME)
SYSROOT_API_LIB_DIR := $(SYSROOT_LIB_DIR)/$(TARGET_PLATFORM_LEVEL)

# API-specific library directory comes first to make the linker prefer shared
# libs over static libs.
SYSROOT_LINK_ARG := -L $(SYSROOT_API_LIB_DIR) -L $(SYSROOT_LIB_DIR)

# Architecture specific headers like asm/ and machine/ are installed to an
# arch-$ARCH subdirectory of the sysroot.
SYSROOT_ARCH_INC_ARG := \
    -isystem $(SYSROOT_INC)/usr/include/$(TOOLCHAIN_NAME)

NDK_TOOLCHAIN_RESOURCE_DIR := $(shell $(TARGET_CXX) -print-resource-dir)
NDK_TOOLCHAIN_LIB_DIR := $(strip $(NDK_TOOLCHAIN_RESOURCE_DIR))/lib/linux

clean-installed-binaries::


# ====================================================================
# gdb.mk : BEGIN
# ====================================================================

NDK_APP_GDBSERVER := $(NDK_APP_DST_DIR)/gdbserver
NDK_APP_GDBSETUP := $(NDK_APP_DST_DIR)/gdb.setup

ifeq ($(NDK_APP_DEBUGGABLE),true)
ifeq ($(TARGET_SONAME_EXTENSION),.so)

installed_modules: $(NDK_APP_GDBSERVER)

$(NDK_APP_GDBSERVER): PRIVATE_ABI     := $(TARGET_ARCH_ABI)
$(NDK_APP_GDBSERVER): PRIVATE_NAME    := $(TOOLCHAIN_NAME)
$(NDK_APP_GDBSERVER): PRIVATE_SRC     := $(TARGET_GDBSERVER)
$(NDK_APP_GDBSERVER): PRIVATE_DST     := $(NDK_APP_GDBSERVER)

$(call generate-file-dir,$(NDK_APP_GDBSERVER))

$(NDK_APP_GDBSERVER): clean-installed-binaries
	$(call host-echo-build-step,$(PRIVATE_ABI),Gdbserver) "[$(PRIVATE_NAME)] $(call pretty-dir,$(PRIVATE_DST))"
	$(hide) $(call host-install,$(PRIVATE_SRC),$(PRIVATE_DST))
endif

# Install gdb.setup for both .so and .bc projects
ifneq (,$(filter $(TARGET_SONAME_EXTENSION),.so .bc))
installed_modules: $(NDK_APP_GDBSETUP)

$(NDK_APP_GDBSETUP): PRIVATE_ABI := $(TARGET_ARCH_ABI)
$(NDK_APP_GDBSETUP): PRIVATE_DST := $(NDK_APP_GDBSETUP)
$(NDK_APP_GDBSETUP): PRIVATE_SOLIB_PATH := $(TARGET_OUT)
$(NDK_APP_GDBSETUP): PRIVATE_SRC_DIRS := $(SYSROOT_INC)

$(NDK_APP_GDBSETUP):
	$(call host-echo-build-step,$(PRIVATE_ABI),Gdbsetup) "$(call pretty-dir,$(PRIVATE_DST))"
	$(hide) $(HOST_ECHO) "set solib-search-path $(call host-path,$(PRIVATE_SOLIB_PATH))" > $(PRIVATE_DST)
	$(hide) $(HOST_ECHO) "directory $(call host-path,$(call remove-duplicates,$(PRIVATE_SRC_DIRS)))" >> $(PRIVATE_DST)

$(call generate-file-dir,$(NDK_APP_GDBSETUP))

# This prevents parallel execution to clear gdb.setup after it has been written to
$(NDK_APP_GDBSETUP): clean-installed-binaries
endif
endif

# ====================================================================
# gdb.mk : END
# ====================================================================

# free the dictionary of LOCAL_MODULE definitions
$(call modules-clear)

$(call ndk-stl-select,$(NDK_APP_STL))

# now parse the Android.mk for the application, this records all
# module declarations, but does not populate the dependency graph yet.
include $(NDK_APP_BUILD_SCRIPT)

# Avoid computing sanitizer/wrap.sh things in the DUMP_VAR case because both of
# these will create build rules and we want to avoid that. The DUMP_VAR case
# also doesn't parse the module definitions, so we're missing a lot of the
# information we need.
ifeq (,$(DUMP_VAR))
    # Comes after NDK_APP_BUILD_SCRIPT because we need to know if *any* module
    # has -fsanitize in its ldflags.
# cmjo : commenting
#    include $(BUILD_SYSTEM)/sanitizers.mk
    include $(BUILD_SYSTEM)/openmp.mk

    ifneq ($(NDK_APP_WRAP_SH_$(TARGET_ARCH_ABI)),)
        include $(BUILD_SYSTEM)/install_wrap_sh.mk
    endif
endif

$(call ndk-stl-add-dependencies,$(NDK_APP_STL))

# recompute all dependencies between modules
$(call modules-compute-dependencies)

# for debugging purpose
ifdef NDK_DEBUG_MODULES
$(call modules-dump-database)
endif

# now, really build the modules, the second pass allows one to deal
# with exported values
$(foreach __pass2_module,$(__ndk_modules),\
    $(eval LOCAL_MODULE := $(__pass2_module))\
    $(eval include $(BUILD_SYSTEM)/build-binary.mk)\
)

# Now compute the closure of all module dependencies.
#
# If APP_MODULES is not defined in the Application.mk, we
# will build all modules that were listed from the top-level Android.mk
# and the installable imported ones they depend on
#
ifeq ($(strip $(NDK_APP_MODULES)),)
    WANTED_MODULES := $(call modules-get-all-installable,$(modules-get-top-list))
    ifeq (,$(strip $(WANTED_MODULES)))
        WANTED_MODULES := $(modules-get-top-list)
        $(call ndk_log,[$(TARGET_ARCH_ABI)] No installable modules in project - forcing static library build)
    endif
else
    WANTED_MODULES := $(call module-get-all-dependencies,$(NDK_APP_MODULES))
endif

$(call ndk_log,[$(TARGET_ARCH_ABI)] Modules to build: $(WANTED_MODULES))

WANTED_INSTALLED_MODULES += $(call map,module-get-installed,$(WANTED_MODULES))

# ====================================================================
# setup-toolchain.mk : END
# ====================================================================

# ====================================================================
# setup-abi.mk : END
# ====================================================================


_sub_commands_arg := $(sub_commands_json)

ifeq ($(LOCAL_SHORT_COMMANDS),true)
compile_commands_list_file := $(NDK_APP_OUT)/compile_commands.list
_sub_commands_arg := @$(compile_commands_list_file)
$(compile_commands_list_file): $(sub_commands_json)
$(call generate-list-file,$(sub_commands_json),$(compile_commands_list_file))
endif

$(COMPILE_COMMANDS_JSON): PRIVATE_SUB_COMMANDS := $(_sub_commands_arg)
$(COMPILE_COMMANDS_JSON): $(compile_commands_list_file) $(sub_commands_json)
	$(hide) $(HOST_PYTHON) $(BUILD_PY)/gen_compile_db.py -o $@ \
        $(PRIVATE_SUB_COMMANDS)

# ====================================================================
# setup-app.mk : END
# ====================================================================


# --------------------------------------------------------------------
#
# Now finish the build preparation with a few rules that depend on
# what has been effectively parsed and recorded previously
#
# --------------------------------------------------------------------

clean: clean-intermediates clean-installed-binaries

distclean: clean

installed_modules: clean-installed-binaries libraries $(WANTED_INSTALLED_MODULES)
host_libraries: $(HOST_STATIC_LIBRARIES)
host_executables: $(HOST_EXECUTABLES)

# clang-tidy rules add themselves as dependencies of this phony rule in
# ev-clang-tidy.
clang_tidy_rules:

static_libraries: $(STATIC_LIBRARIES)
shared_libraries: $(SHARED_LIBRARIES)
executables: $(EXECUTABLES)

ifeq ($(GEN_COMPILE_COMMANDS_DB),true)
all: $(COMPILE_COMMANDS_JSON)
endif

libraries: static_libraries shared_libraries

clean-host-intermediates:
	$(hide) $(call host-rm,$(HOST_EXECUTABLES) $(HOST_STATIC_LIBRARIES))

clean-intermediates: clean-host-intermediates
	$(hide) $(call host-rm,$(EXECUTABLES) $(STATIC_LIBRARIES) $(SHARED_LIBRARIES))

# include dependency information
ALL_DEPENDENCY_DIRS := $(patsubst %/,%,$(sort $(ALL_DEPENDENCY_DIRS)))
-include $(wildcard $(ALL_DEPENDENCY_DIRS:%=%/*.d))

# ====================================================================
# build-all.mk : END
# ====================================================================
