#! /bin/sh
dir="`dirname "$0"`"
. "$dir"/common.sh

."$dir/lib/wgit.sh"

################### Dirs #############################

mkdir -p "$libs" "$meta"

#################### GIT Install ####################
# These repos are cloned manually in order to create
# shallow clones which accellerates the installation
# process enormously

wgithub jnordberg/wintersmith-browserify  wintersmith-browserify
wgithub smebberson/wintersmith-jade  wintersmith-jade
wgithub epeli/underscore.string  underscore.string
NOINSTALL=1 wgithub isagalaev/highlight.js  highlight.js
