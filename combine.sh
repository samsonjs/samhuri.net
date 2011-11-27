#!/usr/bin/env zsh


### javascript ###

# blog
echo "request,showdown,strftime,tmpl,jquery-serializeObject,blog -> assets/blog-all.min.js"
cat assets/{request,showdown,strftime,tmpl,jquery-serializeObject,blog}.min.js >|assets/blog-all.min.js

# project index
echo "gitter,store -> assets/proj-index-all.min.js"
cat assets/{gitter,store}.min.js >|assets/proj-index-all.min.js

# projects
echo "gitter,store,proj -> assets/proj-all.min.js"
cat assets/{gitter,store,proj}.min.js >|assets/proj-all.min.js


### css ###

# blog
echo "style,blog -> assets/blog-all.min.css"
cat assets/{style,blog}.min.css >|assets/blog-all.min.css

# project index
echo "style,proj-common,proj-index -> assets/proj-index-all.min.css"
cat assets/{style,proj-common,proj-index}.min.css >|assets/proj-index-all.min.css

# projects
echo "style,proj-common,proj -> assets/proj-all.min.css"
cat assets/{style,proj-common,proj}.min.css >|assets/proj-all.min.css
