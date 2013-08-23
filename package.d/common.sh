#! /bin/bash

################### Settings #########################

pkgrt="`readlink -f .`"
libs="$pkgrt/node_modules"
meta="$libs/__meta" # TODO: Rename to libs_meta

################### Enviroment #######################

exx PATH <<< '
  node_modules/.bin
'

exx NODE_PATH <<< '
  ./node_modules/
  ./config.d/
  ./cnt/src/
  ./cnt/src/__proto/
'
