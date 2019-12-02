all: compile

compile:
	@echo
	./bin/compile . www

publish: compile
	@echo
	./bin/publish --delete

publish_beta: compile
	@echo
	./bin/publish --beta --delete

test:
	@echo
	./bin/test

.PHONY: compile publish publish_beta test
