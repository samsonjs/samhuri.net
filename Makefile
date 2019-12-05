all: blog

blog:
	@echo
	./bin/compile . www

publish: compile
	@echo
	./bin/publish --delete

publish_beta: compile
	@echo
	./bin/publish --beta --delete

sitegen:
	@echo
	./bin/build-sitegen

test:
	@echo
	./bin/test

.PHONY: blog publish publish_beta sitegen test
