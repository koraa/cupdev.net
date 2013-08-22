#! /bin/sh
dir="`dirname "$0"`"
. "$dir"/common.sh

################### Dirs #############################

mkdir -p "$libs" "$meta"

#################### GIT Install ####################
# These are installed here in order to do shallow
# clones instad of full ones, thereby accellerating
# thereby install process enormously
(
  cd "$meta"
  git clone --depth 1 "https://github.com/twitter/bootstrap.git" twitter-bootstrap
  git clone --depth 1 "https://github.com/jnordberg/wintersmith-browserify.git" wintersmith-browserify
  git clone --depth 1 "https://github.com/smebberson/wintersmith-jade.git" wintersmith-jade
  git clone --depth 1 "https://github.com/isagalaev/highlight.js.git" highlight.js
  git clone --depth 1 "https://github.com/epeli/underscore.string.git" underscore.string

  cd "$pkgrt"
  npm install "$meta/twitter-bootstrap"
  npm install "$meta/wintersmith-browserify"
  npm install "$meta/wintersmith-jade"
  npm install "$meta/underscore.string"
)
