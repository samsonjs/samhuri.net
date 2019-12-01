#!/bin/bash

set -e

for site in Tests/test-*; do
  bin/compile.sh "$site/in" "$site/actual" >/dev/null
  diff -r "$site/expected" "$site/actual"
  rm -r "$site/actual"
done
