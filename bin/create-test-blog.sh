#!/bin/zsh

set -e # bail on errors

BLOG_PATH="$1"
ORIGIN_BLOG_PATH="${BLOG_PATH}-origin.git"
if [[ -e "$BLOG_PATH" ]]; then
  echo ">>> Refusing to clobber $BLOG_PATH"
else
  if [[ ! -e "$ORIGIN_BLOG_PATH" ]]; then
    echo ">>> Mirroring local origin..."
    git clone --mirror . "$ORIGIN_BLOG_PATH"
  fi
  echo ">>> Cloning test blog from local origin..."
  git clone "$ORIGIN_BLOG_PATH" "$BLOG_PATH"
fi
