#!/bin/bash

# bail on errors
set -e

DIR=$(dirname "$0")
HARP="$DIR/../node_modules/.bin/harp"
TARGET="${1:-www}"

function main() {
  echo "* compile rss feed"
  compile_rss

  echo "* harp compile . $TARGET"
  rm -rf "$TARGET"
  "$HARP" compile . "$TARGET"

  echo "* mungle html to make it available without the extension"
  munge_html

  echo "* minify js"
  minify_js

  echo "* minify css"
  minify_css
}

function compile_rss() {
  $DIR/rss.rb public
}

function munge_html() {
  for FILE in "$TARGET"/*.html "$TARGET"/posts/*.html "$TARGET"/projects/*.html; do
    [[ "${FILE##*/}" = "index.html" ]] && continue

    # make posts available without an .html extension
    FILE_DIR="${FILE%.html}"
    mkdir -p "$FILE_DIR"
    mv "$FILE" "$FILE_DIR/index.html"
  done
}

function minify_js() {
  for FILE in "$TARGET"/js/*.js; do
    $DIR/minify-js.sh "$FILE" > /tmp/minified.js && mv /tmp/minified.js "$FILE" || echo "* failed to minify $FILE"
  done
}

function minify_css() {
  for FILE in "$TARGET"/css/*.css; do
    $DIR/minify-css.sh "$FILE" > /tmp/minified.css && mv /tmp/minified.css "$FILE" || echo "* failed to minify $FILE"
  done
}

main
