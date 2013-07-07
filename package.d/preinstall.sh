#! /bin/sh
dir="`dirname "$0"`"
. "$dir"/common.sh

################### Dirs #############################

mkdir -p "$libs" "$meta"

################### highlight.js #####################

(
  hljs="$meta/highlight.js"
  hljs_repo="https://github.com/isagalaev/highlight.js.git"

  # Update
  if test -d "$hljs"; then
      cd "$hljs"
      git pull origin master
  else
    git clone "$hljs_repo" "$hljs" --depth 1
  fi

  # Compile
  cd "$hljs"
  python3 tools/build.py -tnode apache bash coffeescript cpp css diff http javascript java python xml tex

  # Install
  cd "$pkgrt"
  npm install "$hljs/build"
)


