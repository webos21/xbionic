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
#                    BuildX - jemalloc               #
#----------------------------------------------------#
# File    : buildx.mk                                #
# Version : 1.0.0                                    #
# Desc    : For building the jemalloc.               #
#----------------------------------------------------#
# History)                                           #
#   - 2022/01/10 : Created by cmjo                   #
######################################################

LOCAL_PATH := $(call my-dir)

$(call __ndk_info,buildx.mk is included!!!)

common_cflags = \
    -D_REENTRANT           \
    -O3                    \
    -funroll-loops         \
    -fvisibility=hidden    \
    -Werror                \
    -Wno-unused-parameter  \
    -Wno-type-limits

# Default to a single arena for svelte configurations to minimize
#  PSS. This will be overridden by android_product_variables for
#  non-svelte configs.
android_common_cflags = \
    -DANDROID_MAX_ARENAS=1                  \
    -DANDROID_LG_TCACHE_MAXCLASS_DEFAULT=16

common_c_local_includes = \
    -Isrc                 \
    -Iinclude

android_product_variables = \
    -UANDROID_MAX_ARENAS                  \
    -DANDROID_MAX_ARENAS=2                \
    -DJEMALLOC_TCACHE                     \
    -DANDROID_TCACHE_NSLOTS_SMALL_MAX=8   \
    -DANDROID_TCACHE_NSLOTS_LARGE=16

jemalloc_defaults = \
    $(android_common_cflags)        \
    -DANDROID_LG_CHUNK_DEFAULT=21   \
	-include android/include/log.h  \
	$(android_product_variables)    \
	$(common_c_local_includes)

lib_src_files = \
    src/arena.c        \
    src/atomic.c       \
    src/base.c         \
    src/bitmap.c       \
    src/chunk.c        \
    src/chunk_dss.c    \
    src/chunk_mmap.c   \
    src/ckh.c          \
    src/ctl.c          \
    src/extent.c       \
    src/hash.c         \
    src/huge.c         \
    src/jemalloc.c     \
    src/mb.c           \
    src/mutex.c        \
    src/nstime.c       \
    src/pages.c        \
    src/prng.c         \
    src/prof.c         \
    src/quarantine.c   \
    src/rtree.c        \
    src/spin.c         \
    src/stats.c        \
    src/tcache.c       \
    src/ticker.c       \
    src/tsd.c          \
    src/util.c         \
    src/witness.c


jemalloc_testlib_srcs = \
    test/src/btalloc.c      \
    test/src/btalloc_0.c    \
    test/src/btalloc_1.c    \
    test/src/math.c         \
    test/src/mq.c           \
    test/src/mtx.c          \
    test/src/SFMT.c         \
    test/src/test.c         \
    test/src/thd.c          \
    test/src/timer.c


unit_tests = \
    test/unit/a0.c                  \
    test/unit/arena_reset.c         \
    test/unit/atomic.c              \
    test/unit/bitmap.c              \
    test/unit/ckh.c                 \
    test/unit/decay.c               \
    test/unit/fork.c                \
    test/unit/hash.c                \
    test/unit/junk.c                \
    test/unit/junk_alloc.c          \
    test/unit/junk_free.c           \
    test/unit/lg_chunk.c            \
    test/unit/mallctl.c             \
    test/unit/math.c                \
    test/unit/mq.c                  \
    test/unit/mtx.c                 \
    test/unit/nstime.c              \
    test/unit/pack.c                \
    test/unit/pages.c               \
    test/unit/prng.c                \
    test/unit/prof_accum.c          \
    test/unit/prof_active.c         \
    test/unit/prof_gdump.c          \
    test/unit/prof_idump.c          \
    test/unit/prof_reset.c          \
    test/unit/prof_thread_name.c    \
    test/unit/ql.c                  \
    test/unit/qr.c                  \
    test/unit/quarantine.c          \
    test/unit/rb.c                  \
    test/unit/rtree.c               \
    test/unit/run_quantize.c        \
    test/unit/SFMT.c                \
    test/unit/size_classes.c        \
    test/unit/smoothstep.c          \
    test/unit/stats.c               \
    test/unit/ticker.c              \
    test/unit/tsd.c                 \
    test/unit/util.c                \
    test/unit/witness.c             \
    test/unit/zero.c



#-----------------------------------------------------------------------
# jemalloc static library
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := libjemalloc
LOCAL_CFLAGS    += $(jemalloc_defaults)
LOCAL_SRC_FILES := $(lib_src_files)

include $(BUILD_STATIC_LIBRARY)

#-----------------------------------------------------------------------
# jemalloc static jet library
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := libjemalloc_jet
LOCAL_CFLAGS    += $(jemalloc_defaults) -DJEMALLOC_JET
LOCAL_SRC_FILES := $(lib_src_files)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# jemalloc unit test library
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := libjemalloc_unittest
LOCAL_CFLAGS    += $(jemalloc_defaults) -DJEMALLOC_UNIT_TEST -Itest/src -Itest/include
LOCAL_SRC_FILES := $(jemalloc_testlib_srcs)

include $(BUILD_STATIC_LIBRARY)


#-----------------------------------------------------------------------
# jemalloc unit test library
#-----------------------------------------------------------------------

include $(CLEAR_VARS)

LOCAL_MODULE    := jemalloc_unittests
LOCAL_CFLAGS    += $(jemalloc_defaults) -DJEMALLOC_UNIT_TEST -Itest/src -Itest/include
LOCAL_SRC_FILES := $(unit_tests)

include $(BUILD_STATIC_LIBRARY)
