#!/bin/sh

# bail on errors
set -e

echo "*** bootstrap samhuri.net"

echo "* bundle install"
bundle install

echo "* npm install"
npm install

echo "*** done"
