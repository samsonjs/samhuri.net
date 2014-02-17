all: compile

compile:
	@echo
	./bin/compile.sh

publish: compile
	@echo
	./bin/publish.sh --delete www/

.PHONY: compile publish
