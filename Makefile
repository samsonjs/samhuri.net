JSON=harp.json $(shell echo public/*.json) $(shell echo public/*/*.json)
EJS=$(shell echo public/*.ejs) $(shell echo public/*/*.ejs)
JAVASCRIPTS=$(shell echo public/js/*.js)
STYLESHEETS=$(shell echo public/css/*.css)
POSTS=$(shell echo public/posts/*.html) $(shell echo public/posts/*.md)

all: compile

compile: posts
	@echo
	./bin/compile.sh

posts: $(POSTS)
	@echo
	./bin/posts.rb public public

publish: compile
	@echo
	./bin/publish.sh --delete public/

.PHONY: publish
