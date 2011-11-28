#!/usr/bin/env zsh

setopt extendedglob

for js (assets/*.js~*.min.js) {
    target=${js%.js}.min.js
    if [ ! -f $target ] || [ $js -nt $target ]; then
    echo "$js -> $target"
    closure < $js >| $target
    fi
}

for css (assets/*.css~*.min.css) {
    target=${css%.css}.min.css
    if [ ! -f $target ] || [ $css -nt $target ]; then
    echo "$css -> $target"
    yui-compressor $css $target
    fi
}