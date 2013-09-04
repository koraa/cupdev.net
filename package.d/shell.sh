
#! /bin/sh
#
# Run the user's default shell with the enviroment for all the build scripts.

###############################
# INIT

dir="`dirname "$0"`"
. "$dir"/common.sh

###############################
# HELPER

shell="$(awk -F: "/^$USER/{print \$NF}" /etc/passwd)"

"$shell"
