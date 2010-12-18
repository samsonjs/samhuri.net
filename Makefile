JAVASCRIPTS=assets/blog.js assets/gitter.js assets/jquery-serializeObject.js assets/proj.js \
	    assets/request.js assets/showdown.js assets/storage-polyfill.js assets/store.js \
	    assets/strftime.js assets/tmpl.js

MIN_JAVASCRIPTS=assets/blog.min.js assets/gitter.min.js assets/jquery-serializeObject.min.js assets/proj.min.js \
		assets/request.min.js assets/showdown.min.js assets/storage-polyfill.min.js assets/store.min.js \
		assets/strftime.min.js assets/tmpl.min.js

POSTS=$(shell echo _blog/*.html)

all: proj blog combine

proj: projects.json templates/proj/index.html templates/proj/proj/index.html
	./build.js

blog: _blog/posts.json templates/blog/index.html templates/blog/post.html $(POSTS)
	@echo
	./blog.rb _blog blog

minify: $(JAVASCRIPTS)
	@echo
	./minify.sh

combine: minify $(MIN_JAVASCRIPTS)
	@echo
	./combine.sh

publish_blog: blog combine
	publish blog

publish_proj: proj combine
	publish proj

publish: publish_blog publish_proj index.html
	publish index.html
	publish assets
	publish blog
	publish proj

clean:
	rm -rf proj/*
	rm -rf blog/*
	rm assets/*.min.js

.PHONY: blog
