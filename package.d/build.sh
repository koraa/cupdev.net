#! /bin/sh

dir="`dirname "$0"`"
. "$dir"/common.sh

node_modules/.bin/wintersmith build -v
