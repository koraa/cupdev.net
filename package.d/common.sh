#! /bin/bash

################### Settings #########################

pkgrt="`readlink -f .`"
libs="$pkgrt/node_modules"
meta="$libs/__meta"


################### Functions ########################

mkcd() {
  mkdir -p "$1"
    cd "$1"
}

