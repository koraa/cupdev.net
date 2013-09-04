#! /bin/bash

dir="`dirname "$0"`"
. "$dir/lib/std.sh"

################### Settings #########################

pkgrt="`readlink -f .`"
libs="$pkgrt/node_modules"
meta="$libs/__meta" # TODO: Rename to libs_meta

################### Enviroment #######################

exx PATH <<< "
  ${PWD}/package.d/bin
  ${PWD}/node_modules/.bin
"

exx NODE_PATH <<< "
  ${PWD}/node_modules/
  ${PWD}/config.d/
  ${PWD}/cnt/src/
  ${PWD}/cnt/src/__proto/
"
