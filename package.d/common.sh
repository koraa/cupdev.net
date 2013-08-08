#! /bin/bash

################### Settings #########################

pkgrt="`readlink -f .`"
libs="$pkgrt/node_modules"
meta="$libs/__meta"


################### Functions ########################

#
# Set by reference
# Invoke Rset [varname] [value]
Rset() {
  echo >&2 "rset ($0 | $1, $2, $3)"
  eval "$1='$2'"
}

mkcd() {
  mkdir -p "$1"
    cd "$1"
}

