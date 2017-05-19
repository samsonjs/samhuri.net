#!/bin/bash

DIR=$(dirname "$0")
UGLIFY="node_modules/uglify-js/bin/uglifyjs"

function minify() {
  INPUT="$1"
  "$UGLIFY" "$INPUT"
}

if [[ "$1" != "" ]]; then
  minify "$1"
else
  echo "usage: $0 [input file]"
  exit 1
fi
