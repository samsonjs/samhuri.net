JAVASCRIPTS=assets/blog.js assets/gitter.js assets/jquery-serializeObject.js assets/proj.js \
	    assets/request.js assets/showdown.js assets/storage-polyfill.js assets/store.js \
	    assets/strftime.js assets/tmpl.js

MIN_JAVASCRIPTS=assets/blog.min.js assets/gitter.min.js assets/jquery-serializeObject.min.js assets/proj.min.js \
		assets/request.min.js assets/showdown.min.js assets/storage-polyfill.min.js assets/store.min.js \
		assets/strftime.min.js assets/tmpl.min.js

STYLESHEETS=assets/style.css assets/blog.css assets/proj.css

MIN_STYLESHEETS=assets/style.min.css assets/blog.min.css assets/proj.min.css

POSTS=$(shell echo _blog/published/*.html)

all: proj blog combine

proj: projects.json templates/proj/index.html templates/proj/proj/index.html
	./build.js

blog: _blog/blog.json templates/blog/index.html templates/blog/post.html $(POSTS)
	@echo
	./blog.rb _blog blog

minify: $(JAVASCRIPTS) $(STYLESHEETS)
	@echo
	./minify.sh

combine: minify $(MIN_JAVASCRIPTS) $(MIN_STYLESHEETS)
	@echo
	./combine.sh

publish_blog: blog combine
	publish assets
	publish blog
	scp blog/posts.json bohodev.net:discussd/posts.json

publish_proj: proj combine
	publish assets
	publish proj

publish: publish_blog publish_proj index.html
	publish index.html
	publish .htaccess

clean:
	rm -rf proj/*
	rm -rf blog/*
	rm assets/*.min.js
	rm assets/*.min.css

.PHONY: proj blog
