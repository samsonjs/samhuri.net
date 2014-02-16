#!/bin/bash

# bail on errors
set -e

bin/rss.rb public
harp compile . www

for FILENAME in www/*.html www/posts/*.html www/projects/*.html; do
  [[ "${FILENAME##*/}" = "index.html" ]] && continue

  DIRNAME="${FILENAME%.html}"
  mkdir -p "$DIRNAME"
  mv "$FILENAME" "$DIRNAME/index.html"
done
