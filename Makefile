all: compile

compile:
	@echo
	./bin/compile.sh

publish: compile
	@echo
	cp .git/$(cat .git/HEAD | cut -d' ' -f2) public/version.txt
	./bin/publish.sh --delete

publish_beta: compile
	@echo
	cp .git/$(cat .git/HEAD | cut -d' ' -f2) public/version.txt
	./bin/publish.sh --beta --delete

test_blog:
	./bin/create-test-blog.sh server/test-blog

clean:
	rm -rf server/test-blog server/test-blog-origin.git

spec:
	cd server && rspec -f documentation

.PHONY: compile publish publish_beta test_blog spec
