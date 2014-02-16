all: compile

compile: posts
	@echo
	./bin/compile.sh

posts:
	@echo
	./bin/posts.rb public public

publish: compile
	@echo
	./bin/publish.sh www/.htaccess
	./bin/publish.sh www/favicon.ico
	./bin/publish.sh www/feed.xml
	./bin/publish.sh www/*.html
	./bin/publish.sh www/*.png
	./bin/publish.sh www/f/
	./bin/publish.sh --delete www/Chalk
	./bin/publish.sh --delete www/css
	./bin/publish.sh --delete www/images
	./bin/publish.sh --delete www/js
	./bin/publish.sh --delete www/posts
	./bin/publish.sh --delete www/projects
	./bin/publish.sh --delete www/tweets

.PHONY: compile publish
