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
    -Werror                         
ifneq ($(TARGET_ARCH),x86_64)
libc_common_flags +=        \
    -Wexit-time-destructors \
    -fno-emulated-tls
endif

# Variables : libc_defaults
libc_defaults = \
        $(libc_common_flags)                 \
        -I$(LOCAL_PATH)                      \
        -I$(LOCAL_PATH)/include              \
        -I$(LOCAL_PATH)/async_safe/include   \
        -I$(LOCAL_PATH)/platform             \
        -I$(LOCAL_PATH)/kernel/uapi          \
        -I$(LOCAL_PATH)/kernel/android/uapi  \
        -I$(basedir)/libcutils-android12-release/include         \
        -I$(basedir)/logging-platform-12.0.0_r1/liblog/include   \
		-I$(basedir)/jemalloc-android11-platform-release/include
ifeq ($(TARGET_ARCH),arm64)
libc_defaults += \
        -I$(LOCAL_PATH)/kernel/uapi/asm-arm64
endif
ifeq ($(TARGET_ARCH),x86_64)
libc_defaults += \
        -I$(LOCAL_PATH)/kernel/uapi/asm-x86
endif


libc_jemalloc_wrapper =  bionic/jemalloc_wrapper.cpp



#-----------------------------------------------------------------------
# libc_jemalloc_wrapper
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE     := libc_jemalloc_wrapper
LOCAL_CFLAGS     := $(libc_defaults) -fvisibility=hidden
LOCAL_SRC_FILES  := bionic/jemalloc_wrapper.cpp

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_bootstrap.a - -fno-stack-protector and -ffreestanding
#-----------------------------------------------------------------------

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

include $(CLEAR_VARS)

LOCAL_MODULE     := libc_bootstrap
LOCAL_CFLAGS     := $(libc_defaults) -fno-stack-protector -ffreestanding
LOCAL_SRC_FILES  := $(libc_bootstrap_src_files)

include $(BUILD_STATIC_LIBRARY)

#-----------------------------------------------------------------------
# libc_init_static.a - -fno-stack-protector and -ffreestanding
#-----------------------------------------------------------------------


include $(CLEAR_VARS)

LOCAL_MODULE     := libc_init_static
LOCAL_CFLAGS     := $(libc_defaults) -fno-stack-protector -ffreestanding
LOCAL_SRC_FILES  := bionic/libc_init_static.cpp

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_init_dynamic.a - -fno-stack-protector
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_init_dynamic
LOCAL_CFLAGS    := $(libc_defaults) -fno-stack-protector
LOCAL_SRC_FILES := bionic/libc_init_dynamic.cpp

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_tzcode.a - upstream 'tzcode' code
#-----------------------------------------------------------------------

libc_tzcode_src_files =      \
    $(patsubst $(LOCAL_PATH)/%,%,$(wildcard $(LOCAL_PATH)/tzcode/*.c)) \
    tzcode/bionic.cpp        \
    upstream-openbsd/lib/libc/time/wcsftime.c

include $(CLEAR_VARS)

LOCAL_MODULE     := libc_tzcode
LOCAL_CFLAGS     := $(libc_defaults)      \
    -Wno-unused-parameter                \
    -DALL_STATE                          \
    -DSTD_INSPIRED                       \
    -DTHREAD_SAFE                        \
    -DTM_GMTOFF=tm_gmtoff                \
    -DTZDIR="/system/usr/share/zoneinfo" \
    -DHAVE_POSIX_DECLS=0                 \
    -DUSG_COMPAT=1                       \
    -DWILDABBR="\"\""                    \
    -DNO_RUN_TIME_WARNINGS_ABOUT_YEAR_2000_PROBLEMS_THANK_YOU \
    -Dlint
LOCAL_C_INCLUDES := \
    $(LOCAL_PATH)/tzcode
LOCAL_SRC_FILES  := $(libc_tzcode_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_dns.a - modified NetBSD DNS code
#-----------------------------------------------------------------------

libc_dns_src_files =  \
    $(patsubst $(LOCAL_PATH)/%,%,$(wildcard $(LOCAL_PATH)/dns/**/*.c*)) \
    upstream-netbsd/lib/libc/isc/ev_streams.c \
    upstream-netbsd/lib/libc/isc/ev_timers.c

include $(CLEAR_VARS)

LOCAL_MODULE     := libc_dns
LOCAL_CFLAGS     := $(libc_defaults)      \
    -DANDROID_CHANGES                    \
    -DINET6                              \
    -Wno-unused-parameter                \
    -include netbsd-compat.h             \
    -Wframe-larger-than=66000            \
    -include private/bsd_sys_param.h
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/dns/include      \
    $(LOCAL_PATH)/private          \
    $(LOCAL_PATH)/upstream-netbsd/lib/libc/include \
    $(LOCAL_PATH)/upstream-netbsd/android/include
LOCAL_SRC_FILES  := $(libc_dns_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_freebsd.a - upstream FreeBSD C library code
#-----------------------------------------------------------------------

libc_freebsd_src_files = \
    upstream-freebsd/lib/libc/gen/ldexp.c           \
    upstream-freebsd/lib/libc/stdlib/getopt_long.c  \
    upstream-freebsd/lib/libc/stdlib/hcreate.c      \
    upstream-freebsd/lib/libc/stdlib/hcreate_r.c    \
    upstream-freebsd/lib/libc/stdlib/hdestroy_r.c   \
    upstream-freebsd/lib/libc/stdlib/hsearch_r.c    \
    upstream-freebsd/lib/libc/stdlib/qsort.c        \
    upstream-freebsd/lib/libc/stdlib/quick_exit.c   \
    upstream-freebsd/lib/libc/string/wcpcpy.c       \
    upstream-freebsd/lib/libc/string/wcpncpy.c      \
    upstream-freebsd/lib/libc/string/wcscasecmp.c   \
    upstream-freebsd/lib/libc/string/wcscat.c       \
    upstream-freebsd/lib/libc/string/wcschr.c       \
    upstream-freebsd/lib/libc/string/wcscmp.c       \
    upstream-freebsd/lib/libc/string/wcscpy.c       \
    upstream-freebsd/lib/libc/string/wcscspn.c      \
    upstream-freebsd/lib/libc/string/wcsdup.c       \
    upstream-freebsd/lib/libc/string/wcslcat.c      \
    upstream-freebsd/lib/libc/string/wcslen.c       \
    upstream-freebsd/lib/libc/string/wcsncasecmp.c  \
    upstream-freebsd/lib/libc/string/wcsncat.c      \
    upstream-freebsd/lib/libc/string/wcsncmp.c      \
    upstream-freebsd/lib/libc/string/wcsncpy.c      \
    upstream-freebsd/lib/libc/string/wcsnlen.c      \
    upstream-freebsd/lib/libc/string/wcspbrk.c      \
    upstream-freebsd/lib/libc/string/wcsrchr.c      \
    upstream-freebsd/lib/libc/string/wcsspn.c       \
    upstream-freebsd/lib/libc/string/wcsstr.c       \
    upstream-freebsd/lib/libc/string/wcstok.c       \
    upstream-freebsd/lib/libc/string/wmemchr.c      \
    upstream-freebsd/lib/libc/string/wmemcmp.c      \
    upstream-freebsd/lib/libc/string/wmemcpy.c      \
    upstream-freebsd/lib/libc/string/wmemmove.c     \
    upstream-freebsd/lib/libc/string/wmemset.c
ifeq ($(TARGET_ARCH),arm64)
libc_freebsd_src_files := $(filter-out          \
    upstream-freebsd/lib/libc/string/wmemmove.c \
    ,$(libc_freebsd_src_files))
endif
ifeq ($(TARGET_ARCH),x86)
libc_freebsd_src_files := $(filter-out          \
    upstream-freebsd/lib/libc/string/wcschr.c   \
    upstream-freebsd/lib/libc/string/wcscmp.c   \
    upstream-freebsd/lib/libc/string/wcslen.c   \
    upstream-freebsd/lib/libc/string/wcsrchr.c  \
    upstream-freebsd/lib/libc/string/wmemcmp.c  \
    upstream-freebsd/lib/libc/string/wcscat.c   \
    upstream-freebsd/lib/libc/string/wcscpy.c   \
    upstream-freebsd/lib/libc/string/wmemset.c  \
    , $(libc_freebsd_src_files))
endif

include $(CLEAR_VARS)

LOCAL_MODULE     := libc_freebsd
LOCAL_CFLAGS     := $(libc_defaults)     \
    -Wno-sign-compare                    \
    -Wno-unused-parameter                \
    -include freebsd-compat.h
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/upstream-freebsd/android/include
LOCAL_SRC_FILES  := $(libc_freebsd_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_freebsd_large_stack.a - upstream FreeBSD C library code
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_freebsd_large_stack
LOCAL_CFLAGS    := $(libc_defaults)      \
    -Wno-sign-compare                    \
    -include freebsd-compat.h            \
    -Wframe-larger-than=66000
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/upstream-freebsd/android/include
LOCAL_SRC_FILES := upstream-freebsd/lib/libc/gen/glob.c

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_netbsd.a - upstream NetBSD C library code
#-----------------------------------------------------------------------

libc_netbsd_src_files = \
    upstream-netbsd/common/lib/libc/stdlib/random.c  \
    upstream-netbsd/lib/libc/gen/nice.c              \
    upstream-netbsd/lib/libc/gen/psignal.c           \
    upstream-netbsd/lib/libc/gen/utime.c             \
    upstream-netbsd/lib/libc/inet/nsap_addr.c        \
    upstream-netbsd/lib/libc/regex/regcomp.c         \
    upstream-netbsd/lib/libc/regex/regerror.c        \
    upstream-netbsd/lib/libc/regex/regexec.c         \
    upstream-netbsd/lib/libc/regex/regfree.c         \
    upstream-netbsd/lib/libc/stdlib/bsearch.c        \
    upstream-netbsd/lib/libc/stdlib/drand48.c        \
    upstream-netbsd/lib/libc/stdlib/erand48.c        \
    upstream-netbsd/lib/libc/stdlib/jrand48.c        \
    upstream-netbsd/lib/libc/stdlib/lcong48.c        \
    upstream-netbsd/lib/libc/stdlib/lrand48.c        \
    upstream-netbsd/lib/libc/stdlib/mrand48.c        \
    upstream-netbsd/lib/libc/stdlib/nrand48.c        \
    upstream-netbsd/lib/libc/stdlib/_rand48.c        \
    upstream-netbsd/lib/libc/stdlib/rand_r.c         \
    upstream-netbsd/lib/libc/stdlib/reallocarr.c     \
    upstream-netbsd/lib/libc/stdlib/seed48.c         \
    upstream-netbsd/lib/libc/stdlib/srand48.c

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_netbsd
LOCAL_CFLAGS    := $(libc_defaults)      \
    -Wno-sign-compare                    \
    -Wno-unused-parameter                \
    -DPOSIX_MISTAKE                      \
    -include netbsd-compat.h
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/upstream-netbsd/android/include    \
    $(LOCAL_PATH)/upstream-netbsd/lib/libc/include
LOCAL_SRC_FILES := $(libc_netbsd_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_openbsd_ndk.a - upstream OpenBSD C library code
#-----------------------------------------------------------------------

libc_openbsd_src_files = \
    upstream-openbsd/lib/libc/gen/alarm.c              \
    upstream-openbsd/lib/libc/gen/ctype_.c             \
    upstream-openbsd/lib/libc/gen/daemon.c             \
    upstream-openbsd/lib/libc/gen/err.c                \
    upstream-openbsd/lib/libc/gen/errx.c               \
    upstream-openbsd/lib/libc/gen/fnmatch.c            \
    upstream-openbsd/lib/libc/gen/ftok.c               \
    upstream-openbsd/lib/libc/gen/getprogname.c        \
    upstream-openbsd/lib/libc/gen/setprogname.c        \
    upstream-openbsd/lib/libc/gen/verr.c               \
    upstream-openbsd/lib/libc/gen/verrx.c              \
    upstream-openbsd/lib/libc/gen/vwarn.c              \
    upstream-openbsd/lib/libc/gen/vwarnx.c             \
    upstream-openbsd/lib/libc/gen/warn.c               \
    upstream-openbsd/lib/libc/gen/warnx.c              \
    upstream-openbsd/lib/libc/locale/btowc.c           \
    upstream-openbsd/lib/libc/locale/mbrlen.c          \
    upstream-openbsd/lib/libc/locale/mbstowcs.c        \
    upstream-openbsd/lib/libc/locale/mbtowc.c          \
    upstream-openbsd/lib/libc/locale/wcscoll.c         \
    upstream-openbsd/lib/libc/locale/wcstoimax.c       \
    upstream-openbsd/lib/libc/locale/wcstol.c          \
    upstream-openbsd/lib/libc/locale/wcstoll.c         \
    upstream-openbsd/lib/libc/locale/wcstombs.c        \
    upstream-openbsd/lib/libc/locale/wcstoul.c         \
    upstream-openbsd/lib/libc/locale/wcstoull.c        \
    upstream-openbsd/lib/libc/locale/wcstoumax.c       \
    upstream-openbsd/lib/libc/locale/wcsxfrm.c         \
    upstream-openbsd/lib/libc/locale/wctob.c           \
    upstream-openbsd/lib/libc/locale/wctomb.c          \
    upstream-openbsd/lib/libc/net/base64.c             \
    upstream-openbsd/lib/libc/net/htonl.c              \
    upstream-openbsd/lib/libc/net/htons.c              \
    upstream-openbsd/lib/libc/net/inet_lnaof.c         \
    upstream-openbsd/lib/libc/net/inet_makeaddr.c      \
    upstream-openbsd/lib/libc/net/inet_netof.c         \
    upstream-openbsd/lib/libc/net/inet_ntoa.c          \
    upstream-openbsd/lib/libc/net/inet_ntop.c          \
    upstream-openbsd/lib/libc/net/inet_pton.c          \
    upstream-openbsd/lib/libc/net/ntohl.c              \
    upstream-openbsd/lib/libc/net/ntohs.c              \
    upstream-openbsd/lib/libc/net/res_random.c         \
    upstream-openbsd/lib/libc/stdio/fgetln.c           \
    upstream-openbsd/lib/libc/stdio/fgetwc.c           \
    upstream-openbsd/lib/libc/stdio/fgetws.c           \
    upstream-openbsd/lib/libc/stdio/flags.c            \
    upstream-openbsd/lib/libc/stdio/fpurge.c           \
    upstream-openbsd/lib/libc/stdio/fputwc.c           \
    upstream-openbsd/lib/libc/stdio/fputws.c           \
    upstream-openbsd/lib/libc/stdio/fvwrite.c          \
    upstream-openbsd/lib/libc/stdio/fwide.c            \
    upstream-openbsd/lib/libc/stdio/getdelim.c         \
    upstream-openbsd/lib/libc/stdio/gets.c             \
    upstream-openbsd/lib/libc/stdio/makebuf.c          \
    upstream-openbsd/lib/libc/stdio/mktemp.c           \
    upstream-openbsd/lib/libc/stdio/open_memstream.c   \
    upstream-openbsd/lib/libc/stdio/open_wmemstream.c  \
    upstream-openbsd/lib/libc/stdio/rget.c             \
    upstream-openbsd/lib/libc/stdio/setvbuf.c          \
    upstream-openbsd/lib/libc/stdio/ungetc.c           \
    upstream-openbsd/lib/libc/stdio/ungetwc.c          \
    upstream-openbsd/lib/libc/stdio/vasprintf.c        \
    upstream-openbsd/lib/libc/stdio/vdprintf.c         \
    upstream-openbsd/lib/libc/stdio/vsscanf.c          \
    upstream-openbsd/lib/libc/stdio/vswprintf.c        \
    upstream-openbsd/lib/libc/stdio/vswscanf.c         \
    upstream-openbsd/lib/libc/stdio/wbuf.c             \
    upstream-openbsd/lib/libc/stdio/wsetup.c           \
    upstream-openbsd/lib/libc/stdlib/abs.c             \
    upstream-openbsd/lib/libc/stdlib/div.c             \
    upstream-openbsd/lib/libc/stdlib/getenv.c          \
    upstream-openbsd/lib/libc/stdlib/getsubopt.c       \
    upstream-openbsd/lib/libc/stdlib/insque.c          \
    upstream-openbsd/lib/libc/stdlib/imaxabs.c         \
    upstream-openbsd/lib/libc/stdlib/imaxdiv.c         \
    upstream-openbsd/lib/libc/stdlib/labs.c            \
    upstream-openbsd/lib/libc/stdlib/ldiv.c            \
    upstream-openbsd/lib/libc/stdlib/llabs.c           \
    upstream-openbsd/lib/libc/stdlib/lldiv.c           \
    upstream-openbsd/lib/libc/stdlib/lsearch.c         \
    upstream-openbsd/lib/libc/stdlib/recallocarray.c   \
    upstream-openbsd/lib/libc/stdlib/remque.c          \
    upstream-openbsd/lib/libc/stdlib/setenv.c          \
    upstream-openbsd/lib/libc/stdlib/tfind.c           \
    upstream-openbsd/lib/libc/stdlib/tsearch.c         \
    upstream-openbsd/lib/libc/string/memccpy.c         \
    upstream-openbsd/lib/libc/string/strcasecmp.c      \
    upstream-openbsd/lib/libc/string/strcasestr.c      \
    upstream-openbsd/lib/libc/string/strcoll.c         \
    upstream-openbsd/lib/libc/string/strcspn.c         \
    upstream-openbsd/lib/libc/string/strdup.c          \
    upstream-openbsd/lib/libc/string/strndup.c         \
    upstream-openbsd/lib/libc/string/strpbrk.c         \
    upstream-openbsd/lib/libc/string/strsep.c          \
    upstream-openbsd/lib/libc/string/strspn.c          \
    upstream-openbsd/lib/libc/string/strtok.c          \
    upstream-openbsd/lib/libc/string/strxfrm.c         \
    upstream-openbsd/lib/libc/string/wcslcpy.c         \
    upstream-openbsd/lib/libc/string/wcswidth.c

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_openbsd_ndk
LOCAL_CFLAGS    := $(libc_defaults)      \
    -Wno-sign-compare                    \
    -Wno-unused-parameter                \
    -include openbsd-compat.h
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/private                \
    $(LOCAL_PATH)/stdio                  \
    $(LOCAL_PATH)/upstream-openbsd/android/include  \
    $(LOCAL_PATH)/upstream-openbsd/lib/libc/include \
    $(LOCAL_PATH)/upstream-openbsd/lib/libc/gdtoa
LOCAL_SRC_FILES := $(libc_openbsd_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_openbsd_large_stack.a - upstream OpenBSD C library code
#-----------------------------------------------------------------------

libc_openbsd_large_stack_src_files = \
    stdio/vfprintf.cpp               \
    stdio/vfwprintf.cpp              \
    upstream-openbsd/lib/libc/string/memmem.c \
    upstream-openbsd/lib/libc/string/strstr.c

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_openbsd_large_stack
LOCAL_CFLAGS    := $(libc_defaults)      \
    -D_GNU_SOURCE -D__ANDROID_API__=26   \
    -include openbsd-compat.h            \
    -Wno-sign-compare                    \
    -Wframe-larger-than=5000
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/private                            \
    $(LOCAL_PATH)/upstream-openbsd/android/include   \
    $(LOCAL_PATH)/upstream-openbsd/lib/libc/include  \
    $(LOCAL_PATH)/upstream-openbsd/lib/libc/gdtoa    \
    $(LOCAL_PATH)/upstream-openbsd/lib/libc/stdio
LOCAL_SRC_FILES := $(libc_openbsd_large_stack_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_openbsd.a - upstream OpenBSD C library code
#-----------------------------------------------------------------------

libc_openbsd_src_files = \
    upstream-openbsd/lib/libc/crypt/arc4random.c          \
    upstream-openbsd/lib/libc/crypt/arc4random_uniform.c  \
    upstream-openbsd/lib/libc/string/memchr.c             \
    upstream-openbsd/lib/libc/string/memrchr.c            \
    upstream-openbsd/lib/libc/string/stpcpy.c             \
    upstream-openbsd/lib/libc/string/stpncpy.c            \
    upstream-openbsd/lib/libc/string/strcat.c             \
    upstream-openbsd/lib/libc/string/strcpy.c             \
    upstream-openbsd/lib/libc/string/strlcat.c            \
    upstream-openbsd/lib/libc/string/strlcpy.c            \
    upstream-openbsd/lib/libc/string/strncat.c            \
    upstream-openbsd/lib/libc/string/strncmp.c            \
    upstream-openbsd/lib/libc/string/strncpy.c
ifeq ($(TARGET_ARCH),arm)
libc_openbsd_src_files := $(filter-out          \
    upstream-openbsd/lib/libc/string/strcpy.c   \
    upstream-openbsd/lib/libc/string/stpcpy.c   \
    upstream-openbsd/lib/libc/string/strcat.c   \
    ,$(libc_openbsd_src_files))
endif
ifeq ($(TARGET_ARCH),arm64)
libc_openbsd_src_files := $(filter-out          \
    upstream-openbsd/lib/libc/string/memchr.c   \
    upstream-openbsd/lib/libc/string/memrchr.c  \
    upstream-openbsd/lib/libc/string/stpcpy.c   \
    upstream-openbsd/lib/libc/string/strcpy.c   \
    upstream-openbsd/lib/libc/string/strncmp.c  \
    ,$(libc_openbsd_src_files))
endif
ifeq ($(TARGET_ARCH),x86)
libc_openbsd_src_files := $(filter-out          \
    upstream-openbsd/lib/libc/string/memchr.c   \
    upstream-openbsd/lib/libc/string/memrchr.c  \
    upstream-openbsd/lib/libc/string/stpcpy.c   \
    upstream-openbsd/lib/libc/string/stpncpy.c  \
    upstream-openbsd/lib/libc/string/strcat.c   \
    upstream-openbsd/lib/libc/string/strcpy.c   \
    upstream-openbsd/lib/libc/string/strncmp.c  \
    upstream-openbsd/lib/libc/string/strncpy.c  \
    upstream-openbsd/lib/libc/string/strlcat.c  \
    upstream-openbsd/lib/libc/string/strlcpy.c  \
    upstream-openbsd/lib/libc/string/strncat.c  \
    ,$(libc_openbsd_src_files))
endif
ifeq ($(TARGET_ARCH),x86_64)
libc_openbsd_src_files := $(filter-out          \
    upstream-openbsd/lib/libc/string/stpcpy.c   \
    upstream-openbsd/lib/libc/string/stpncpy.c  \
    upstream-openbsd/lib/libc/string/strcat.c   \
    upstream-openbsd/lib/libc/string/strcpy.c   \
    upstream-openbsd/lib/libc/string/strncat.c  \
    upstream-openbsd/lib/libc/string/strncmp.c  \
    upstream-openbsd/lib/libc/string/strncpy.c  \
    ,$(libc_openbsd_src_files))
endif

$(call __ndk_info,libc_openbsd_src_files = '$(libc_openbsd_src_files)')

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_openbsd
LOCAL_CFLAGS    := $(libc_defaults)      \
    -D_GNU_SOURCE -D__ANDROID_API__=26   \
    -Wno-sign-compare                    \
    -Wno-unused-parameter                \
    -include openbsd-compat.h
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/private              \
    $(LOCAL_PATH)/upstream-openbsd/android/include
LOCAL_SRC_FILES := $(libc_openbsd_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_gdtoa.a - upstream OpenBSD C library gdtoa code
#-----------------------------------------------------------------------

libc_gdtoa_src_files = \
    upstream-openbsd/android/gdtoa_support.cpp \
    upstream-openbsd/lib/libc/gdtoa/dmisc.c    \
    upstream-openbsd/lib/libc/gdtoa/dtoa.c     \
    upstream-openbsd/lib/libc/gdtoa/gdtoa.c    \
    upstream-openbsd/lib/libc/gdtoa/gethex.c   \
    upstream-openbsd/lib/libc/gdtoa/gmisc.c    \
    upstream-openbsd/lib/libc/gdtoa/hd_init.c  \
    upstream-openbsd/lib/libc/gdtoa/hdtoa.c    \
    upstream-openbsd/lib/libc/gdtoa/hexnan.c   \
    upstream-openbsd/lib/libc/gdtoa/ldtoa.c    \
    upstream-openbsd/lib/libc/gdtoa/misc.c     \
    upstream-openbsd/lib/libc/gdtoa/smisc.c    \
    upstream-openbsd/lib/libc/gdtoa/strtod.c   \
    upstream-openbsd/lib/libc/gdtoa/strtodg.c  \
    upstream-openbsd/lib/libc/gdtoa/strtof.c   \
    upstream-openbsd/lib/libc/gdtoa/strtord.c  \
    upstream-openbsd/lib/libc/gdtoa/sum.c      \
    upstream-openbsd/lib/libc/gdtoa/ulp.c

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_gdtoa
LOCAL_CFLAGS    := $(libc_defaults)      \
    -Wno-sign-compare                    \
    -include openbsd-compat.h
LOCAL_C_INCLUDES :=  \
    $(LOCAL_PATH)/private              \
    $(LOCAL_PATH)/upstream-openbsd/android/include \
    $(LOCAL_PATH)/upstream-openbsd/lib/libc/include
LOCAL_SRC_FILES := $(libc_gdtoa_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# libc_fortify.a - container for our FORITFY
#-----------------------------------------------------------------------

libc_fortify_src_files = \
    bionic/fortify.cpp
ifeq ($(TARGET_ARCH),arm)
libc_fortify_src_files += \
    arch-arm/generic/bionic/__memcpy_chk.S     \
    arch-arm/cortex-a15/bionic/__strcat_chk.S  \
    arch-arm/cortex-a15/bionic/__strcpy_chk.S  \
    arch-arm/cortex-a7/bionic/__strcat_chk.S   \
    arch-arm/cortex-a7/bionic/__strcpy_chk.S   \
    arch-arm/cortex-a9/bionic/__strcat_chk.S   \
    arch-arm/cortex-a9/bionic/__strcpy_chk.S   \
    arch-arm/krait/bionic/__strcat_chk.S       \
    arch-arm/krait/bionic/__strcpy_chk.S       \
    arch-arm/cortex-a53/bionic/__strcat_chk.S  \
    arch-arm/cortex-a53/bionic/__strcpy_chk.S  \
    arch-arm/cortex-a55/bionic/__strcat_chk.S  \
    arch-arm/cortex-a55/bionic/__strcpy_chk.S
endif
ifeq ($(TARGET_ARCH),arm64)
libc_fortify_src_files += \
    arch-arm64/generic/bionic/__memcpy_chk.S
endif

libc_fortify_cflags = \
    -U_FORTIFY_SOURCE                   \
    -D__BIONIC_DECLARE_FORTIFY_HELPERS
ifeq ($(TARGET_ARCH),arm)
libc_fortify_cflags += \
    -DNO___MEMCPY_CHK      \
    -DRENAME___STRCAT_CHK  \
    -DRENAME___STRCPY_CHK
endif
ifeq ($(TARGET_ARCH),arm64)
libc_fortify_cflags += \
    -DNO___MEMCPY_CHK
endif

include $(CLEAR_VARS)

LOCAL_MODULE    := libc_fortify
LOCAL_CFLAGS    := $(libc_defaults)      \
    $(libc_fortify_cflags)
LOCAL_SRC_FILES := $(libc_fortify_src_files)

include $(BUILD_STATIC_LIBRARY)
