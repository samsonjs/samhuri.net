all: compile

compile:
	@echo
	./bin/compile .

publish: compile
	@echo
	./bin/publish --delete

publish_beta: compile
	@echo
	./bin/publish --beta --delete

.PHONY: compile publish publish_beta
