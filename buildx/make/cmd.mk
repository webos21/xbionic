# Copyright (c) 2006-2013 Cheolmin Jo (webos21@gmail.com)
# All rights reserved.
#
# This code is released under a BSD-style open source license,
# for more detail, see the copyright notice in LICENSE.
#

######################################################
#                      Commands                      #
#----------------------------------------------------#
# File    : cmd.mk                                   #
# Version : 1.0.0                                    #
# Desc    : MK file for shell commands.              #
#----------------------------------------------------#
# History)                                           #
#   - 2020/03/01 : Created by cmjo                   #
######################################################

ifeq ($(ComSpec),) 
CP = cp
RM = rm -f
MKDIR = mkdir
TAR = tar
CHMOD = chmod
TEST_FILE = if test -f
TEST_DIR = if test -d
TEST_VAR = if test
TEST_EQ = =
TEST_NEQ = !=
TEST_THEN = ; then
TEST_END = ; fi
else
CP = "cp.exe"
RM = "rm.exe" -f
MKDIR = "mkdir.exe"
TAR = "tar.exe"
CHMOD = echo "chmod"
TEST_FILE = if EXIST
TEST_DIR = if EXIST
TEST_VAR = if
TEST_EQ = ==
TEST_NEQ = NEQ
TEST_THEN = 
TEST_END =
endif
