#!/usr/bin/env zsh

echo "request,showdown,strftime,tmpl,jquery-serializeObject,blog -> assets/blog-all.min.js"
cat assets/{request,showdown,strftime,tmpl,jquery-serializeObject,blog}.min.js >|assets/blog-all.min.js

echo "gitter.storage-polyfill,store,proj -> assets/proj-all.min.js"
cat assets/{gitter,storage-polyfill,store,proj}.min.js >|assets/proj-all.min.js
