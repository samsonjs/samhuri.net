#!/usr/bin/env zsh

### javascript ###

# blog
echo "request,showdown,strftime,tmpl,jquery-serializeObject,blog -> blog-all.min.js"
cat public/js/{request,showdown,strftime,tmpl,jquery-serializeObject,blog}.min.js >|public/js/blog-all.min.js

# project index
echo "gitter,store -> proj-index-all.min.js"
cat public/js/{gitter,store}.min.js >|public/js/proj-index-all.min.js

# projects
echo "gitter,store,proj -> proj-all.min.js"
cat public/js/{gitter,store,proj}.min.js >|public/js/proj-all.min.js


### css ###

# blog
echo "style,blog -> blog-all.min.css"
cat public/css/{style,blog}.min.css >|public/css/blog-all.min.css

# project index
echo "style,proj-common,proj-index -> proj-index-all.min.css"
cat public/css/{style,proj-common,proj-index}.min.css >|public/css/proj-index-all.min.css

# projects
echo "style,proj-common,proj -> proj-all.min.css"
cat public/css/{style,proj-common,proj}.min.css >|public/css/proj-all.min.css
