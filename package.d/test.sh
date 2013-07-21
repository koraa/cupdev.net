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

watchr() {
  local pid cmd
  cmd="$1"; shift

  while true; do
    sh -c "$cmd" & pid=$!

    inotifywait "$@"
    kill $pid
  done
}

################################
## MAIN

watchr 'NODE_PATH=./node_modules:config.d node_modules/.bin/wintersmith preview' -r config* -e modify,create,delete,delete_self,unmount,move,move_self
