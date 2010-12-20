#!/usr/bin/env zsh

echo "request,showdown,strftime,tmpl,jquery-serializeObject,blog -> assets/blog-all.min.js"
cat assets/{request,showdown,strftime,tmpl,jquery-serializeObject,blog}.min.js >|assets/blog-all.min.js

echo "gitter.store,proj,ghfinder,code_highlighter -> assets/proj-all.min.js"
cat assets/{gitter,store,proj,ghfinder,code_highlighter}.min.js >|assets/proj-all.min.js

echo "style,proj -> assets/proj-all.min.css"
cat assets/{style,proj}.min.css >|assets/proj-all.min.css
