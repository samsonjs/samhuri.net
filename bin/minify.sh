#!/usr/bin/env zsh

setopt extendedglob

[[ ! -d public/js ]] && mkdir public/js
for js (assets/js/*.js) {
    target=public/js/${${js:t}%.js}.min.js
    if [ ! -f $target ] || [ $js -nt $target ]; then
    echo "$js -> $target"
    closure < $js >| $target
    fi
}

[[ ! -d public/css ]] && mkdir public/css
for css (assets/css/*.css) {
    target=public/css/${${css:t}%.css}.min.css
    if [ ! -f $target ] || [ $css -nt $target ]; then
    echo "$css -> $target"
    yui-compressor $css $target
    fi
}
