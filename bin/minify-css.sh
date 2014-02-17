#!/bin/sh

DIR=$(dirname "$0")
JAR_FILENAME="$DIR/yuicompressor-2.4.8.jar"

function minify() {
  INPUT="$1"
  java -jar "$JAR_FILENAME" "$INPUT"
}

if [[ "$1" != "" ]]; then
  minify "$1"
else
  echo "usage: $0 [input file]"
  exit 1
fi
