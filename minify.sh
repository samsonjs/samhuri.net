#!/usr/bin/env zsh

setopt extendedglob

for js (assets/*.js~*.min.js) {
    target=${js%.js}.min.js
    if [ ! -f $target ] || [ $js -nt $target ]; then
	echo "$js -> $target"
	closure-compiler < $js >| $target
    fi
}
