#!/bin/sh

DIR=$(dirname "$0")
UGLIFY="uglifyjs"

function minify() {
  INPUT="$1"
  "$UGLIFY" --compress --screw-ie8 "$INPUT"
}

if [[ "$1" != "" ]]; then
  minify "$1"
else
  echo "usage: $0 [input file]"
  exit 1
fi
