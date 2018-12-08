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

.PHONY: rss compile publish publish_beta
