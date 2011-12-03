#!/bin/bash

bail() {
    echo fail: $*
    exit 1
}

# exit on errors
set -e

publish_host=samhuri.net
publish_dir=samhuri.net/public/

# test
if [[ "$1" = "-t" ]]; then
    prefix=echo
    shift
fi

# --delete, passed to rsync
if [[ "$1" = "--delete" ]]; then
    delete="--delete"
    shift
fi

if [[ $# -eq 0 ]]; then
    if [[ "$delete" != "" ]]; then
        bail "no paths given, cowardly refusing to publish everything with --delete"
    fi
    $prefix rsync -aKv $delete public/* "$publish_host":"${publish_dir}"
else
    $prefix rsync -aKv $delete "$@" "$publish_host":"${publish_dir}"
fi
