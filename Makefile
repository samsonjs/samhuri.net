JAVASCRIPTS=$(shell echo assets/js/*.js)
STYLESHEETS=$(shell echo assets/css/*.css)
POSTS=$(shell echo _blog/published/*.html) $(shell echo _blog/published/*.md)

all: proj blog combine

proj: projects.json templates/proj/index.html templates/proj/project.html
	@echo
	./bin/projects.js projects.json public/proj

blog: _blog/blog.json templates/blog/index.html templates/blog/post.html $(POSTS)
	@echo
	cd _blog && git pull
	./bin/blog.rb _blog public

minify: $(JAVASCRIPTS) $(STYLESHEETS)
	@echo
	./bin/minify.sh

combine: minify $(JAVASCRIPTS) $(STYLESHEETS)
	@echo
	./bin/combine.sh

publish_assets: combine
	@echo
	./bin/publish.sh --delete public/css public/images public/js
	./bin/publish.sh public/f

publish_blog: blog publish_assets
	@echo
	./bin/publish.sh --delete public/blog
	scp public/blog/posts.json bohodev.net:discussd/posts.json
	scp discussd/discussd.js bohodev.net:discussd/discussd.js
	scp public/s42/.htaccess samhuri.net:s42.ca/.htaccess
	ssh bohodev.net bin/restart-discussd.sh

publish_proj: proj publish_assets
	@echo
	./bin/publish.sh --delete public/proj

publish_index: public/index.html
	@echo
	./bin/publish.sh public/index.html

publish: publish_index publish_blog publish_proj
	@echo
	./bin/publish.sh public/.htaccess
	./bin/publish.sh public/favicon.ico

clean:
	rm -rf public/proj/*
	rm -rf public/blog/*
	rm public/css/*.css
	rm public/js/*.js

.PHONY: proj blog
