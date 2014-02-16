#!/bin/bash

bin/rss.rb public

mkdir -p www
harp compile public www

for FILENAME in www/*.html www/posts/*.html www/projects/*.html; do
  [[ "$FILENAME" = "index.html" ]] && continue

  DIRNAME="${FILENAME%.html}"
  mkdir -p "$DIRNAME"
  mv "$FILENAME" "$DIRNAME/index.html"
done
