#!/bin/bash

harp compile public public

for FILENAME in public/posts/*.html public/projects/*.html; do
  [[ "$FILENAME" = "index.html" ]] && continue

  DIRNAME="${FILENAME%.html}"
  mkdir -p "$DIRNAME"
  mv "$FILENAME" "$DIRNAME/index.html"
done
