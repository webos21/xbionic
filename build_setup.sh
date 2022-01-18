#!/bin/sh
# -------------------------------------------------------------------------
# Set up the Build Environment for *nix
# -------------------------------------------------------------------------

DIRNAME=`dirname "$0"`
PROGNAME=`basename "$0"`
GREP="grep"

# Use the maximum available, or set MAX_FD != -1 to use that
MAX_FD="maximum"

# OS specific support (must be 'true' or 'false').
cygwin=false;
darwin=false;
linux=false;
case "`uname`" in
    CYGWIN*)
        cygwin=true
        ;;

    Darwin*)
        darwin=true
        ;;

    Linux)
        linux=true
        ;;
esac

# Read an optional running configuration file
if [ "x$BUILD_CONF" = "x" ]; then
    BUILD_CONF="$DIRNAME/build.conf"
fi
if [ -r "$BUILD_CONF" ]; then
    . "$BUILD_CONF"
fi

# Set the Build Path
export PATH=$BUILD_TOOLCHANIN_BIN:$PATH

