all: compile

rss:
	@echo
	ruby -w ./bin/rss.rb public

compile:
	@echo
	./bin/compile.sh .

publish: compile
	@echo
	./bin/publish.sh --delete

publish_beta: compile
	@echo
	./bin/publish.sh --beta --delete

test_blog:
	./bin/create-test-blog.sh server/test-blog

clean:
	rm -rf server/test-blog server/test-blog-origin.git

spec:
	cd server && rspec -f documentation

.PHONY: rss compile publish publish_beta test_blog clean spec
