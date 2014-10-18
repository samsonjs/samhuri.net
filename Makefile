all: compile

compile:
	@echo
	./bin/compile.sh

publish: compile
	@echo
	./bin/publish.sh --delete

publish_beta: compile
	@echo
	./bin/publish.sh --beta --delete

test_blog:
	./bin/create-test-blog.sh server/spec/test-blog

spec:
	cd server && rspec -f documentation

.PHONY: compile publish publish_beta test_blog spec
