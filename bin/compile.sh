#!/bin/bash

# bail on errors
set -e

DIR=$(dirname "$0")
HARP="harp"
TARGET="${1:-www}"

function main() {
  echo "* compile rss feed"
  compile_rss

  echo "* harp compile . $TARGET"
  rm -rf "$TARGET"
  "$HARP" compile . "$TARGET"

  echo "* munge html files to make them available without an extension"
  munge_html

  echo "* inline CSS"
  $DIR/inline-css.rb "$TARGET"

  echo "* minify js"
  minify_js
}

function compile_rss() {
  $DIR/rss.rb public
}

function munge_html() {
  for FILE in "$TARGET"/*.html "$TARGET"/posts/*/*/*.html "$TARGET"/projects/*.html; do
    [[ "${FILE##*/}" = "index.html" ]] && continue

    # make posts available without an .html extension
    FILE_DIR="${FILE%.html}"
    mkdir -p "$FILE_DIR"
    mv "$FILE" "$FILE_DIR/index.html"
  done

  # stupid harp
  for FILE in "$TARGET"/projects/mojo.el "$TARGET"/projects/samhuri.net "$TARGET"/projects/cheat.el; do
    mv "$FILE" "$FILE.tmp"
    FILE_DIR="${FILE%.html}"
    mkdir -p "$FILE_DIR"
    mv "$FILE.tmp" "$FILE_DIR/index.html"
  done
}

function minify_js() {
  for FILE in "$TARGET"/js/*.js; do
    $DIR/minify-js.sh "$FILE" > /tmp/minified.js && mv /tmp/minified.js "$FILE" || echo "* failed to minify $FILE"
  done
}

main
