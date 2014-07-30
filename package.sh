#!/bin/sh

dir="`dirname "$0"`"


#
# Echo to stderr
debg() {
  echo "[DEBUG] $@" >&2
}

#
# Set by reference
# Invoke Rset [varname] [value]
Rset() {
  debg "rset ($0 | $1, $2, $3)"
  eval "$1='$2'"
}

#
# Extend the given path and export it
# while implementing linewise-tokens
# Stripping can  be suppressed with colons
exx() {
  debg "rxx ($0 | $1, $2, $3)"
  local ref OL NU filter

  filter='
              s/^\s*//    # STRIP start of line
              s/\s*$//    # STRIP end of line

              s/:/\n/     # colon to newline

          2,$ s/^/:/      # Prepend colon to all lines but first and last

    /[^:\s*]/ p           # Filter empty lines
  '

  ref="$1"
  OL="${!ref}"

  # Apply transformations to STDIN
  NU="$(sed -n "$filter" | tr -d '\n')"

  # Write to var
  Rset "$ref" "${NU}${OL}"
  export "$ref"
  
  # DEBUG
  debg "Extend env: ${ref}=${!ref}"
}

mkcd() {
  mkdir -p "$1"
  cd "$1"
}

watchr() {
  local pid cmd
  cmd="$1"; shift

  while true; do
    sh -c "$cmd" & pid=$!

    inotifywait "$@"
    kill $pid
  done
}

# $ libmeta_install [name]
#
# Install a dir from $meta
libmeta_install() {(
  debg "libmeta_install $@"

  cd "$base"
  test -n "$NOINSTALL" && return 0
  npm install "$meta/$1" # TODO: BETTER!
)}

# $ libmeta_clean "$name"
#
# Remove a given directory from $meta
libmeta_clean() {(
  debg "libmeta_clean $@"

  cd "$meta"
  rm -Rfv "$1"
)}

# $ wgit_curbranch [name]
wgit_curbranch() {(
  cd "$meta/$1"

  ref=$(git symbolic-ref HEAD 2> /dev/null)           \
    || ref=$(git rev-parse --short HEAD 2> /dev/null) \
    && echo "${ref#refs/heads/}"
)}


# $ wgit_clone [url] [name]
wgit_clone() {(
  debg "wgit_clone $@"
  cd "$meta"
  git clone --depth 1 "$1" "$2"
)}


# $ wgit_up [name]
wgit_up() {(
  debg "wgit_up $@"
  cd "$meta/$name"
  git pull origin "$(wgit_curbranch "$1")"
)}

#
# Git wrapper
# $ wgit [url] [name]
#
# Make shure the given repo is
# cloned, installed and up-to-date.
wgit() {(
  debg "wgit $@"
  url="$1" name="$2" dir="$meta/$name"

  test -d "$dir"                    \
    && test -d "$dir/.git"          \
    && wgit_up "$name"              \
    && libmeta_install "$name"      \
    || {
      libmeta_clean "$name"         \
      && wgit_clone "$url" "$name"  \
      && libmeta_install "$name"
    }

)}

#
# Git wrapper
# $ github [user]/[repo name] [local name]
#
# Install a repo from github
wgithub() {
  local n="$2"
  test -n "$n" || n="`basename "$1"`"
  wgit "https://github.com/${1}.git" "$2"
}
# INIT
###############################
# HELPER

node_modules/wintersmith/bin/wintersmith build

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

rm -Rf build
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

################### Dirs #############################

mkdir -p "$libs" "$meta"

preinstall() {
# These repos are cloned manually in order to create
wgithub jnordberg/wintersmith-browserify
wgithub smebberson/wintersmith-jade
wgithub epeli/underscore.string
wgithub twbs/bootstrap
wgithub LearnBoost/node-canvas
wgithub koraa/wintersmith-less
NOINSTALL=1 wgithub isagalaev/highlight.js  highlight.js
}

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


################################
## MAIN

test() {
  watchr 'wintersmith preview' \
    -r config*                 \
    -e modify,create,delete,delete_self,unmount,move,move_self
}
