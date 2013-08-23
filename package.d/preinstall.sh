#! /bin/sh
dir="`dirname "$0"`"
. "$dir"/common.sh

################### Dirs #############################

mkdir -p "$libs" "$meta"

#################### GIT Install ####################
# These repos are cloned manually in order to create
# shallow clones which accellerates the installation
# process enormously

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
  wgit "https://github.com/${1}.git" "$2"
}

wgithub jnordberg/wintersmith-browserify  wintersmith-browserify
wgithub smebberson/wintersmith-jade  wintersmith-jade
wgithub epeli/underscore.string  underscore.string
NOINSTALL=1 wgithub isagalaev/highlight.js  highlight.js
