#!/bin/sh

# bail on errors
set -e

export PATH="$HOME/.rbenv/shims:$PATH"

echo "*** bootstrap samhuri.net"

echo "* bundle install"
bundle install

echo "* npm install"
npm install

echo "*** done"
