#! /bin/sh
#
# Test stript.
#
# This basically starts the

###############################
# INIT

dir="`dirname "$0"`"
. "$dir"/common.sh

###############################
# HELPER

node_modules/wintersmith/bin/wintersmith build
