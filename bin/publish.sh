#!/bin/bash

# exit on errors
set -e

bail() {
    echo fail: $*
    exit 1
}

publish_host="samhuri.net"
publish_dir="samhuri.net/public/"
prefix=""
delete=""

break_while=0
while [[ $# > 1 ]]; do

  arg="$1"

  case "$arg" in

    -t|--test)
      prefix=echo
      dryrun="--dry-run"
      shift
      ;;

    -d|--delete)
      # passed to rsync
      delete="--delete"
      shift
      ;;

    # we're at the paths, no more options
    *)
      break_while=1
      break
      ;;

  esac

  [[ $break_while -eq 1 ]] && break

done

if [[ $# -eq 0 ]]; then
    if [[ "$delete" != "" ]]; then
        bail "no paths given, cowardly refusing to publish everything with --delete"
    fi
    $prefix rsync -aKv $dryrun $delete www/* "$publish_host":"${publish_dir}"
else
    $prefix rsync -aKv $dryrun $delete "$@" "$publish_host":"${publish_dir}"
fi
