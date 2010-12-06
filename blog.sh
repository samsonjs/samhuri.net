#!/bin/sh

if [[ ! -d _blog ]]; then
    git clone git://github.com/samsonjs/blog.git _blog
else
    cd _blog
    git pull
    cd ..
fi

./blog.rb _blog
