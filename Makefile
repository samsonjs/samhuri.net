all: compile

compile:
	@echo
	./bin/compile.sh .

publish: compile
	@echo
	./bin/publish.sh --delete

publish_beta: compile
	@echo
	./bin/publish.sh --beta --delete

.PHONY: compile publish publish_beta
