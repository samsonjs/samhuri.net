all: blog

blog: sitegen
	@echo
	./bin/compile . www

publish: blog
	@echo
	./bin/publish --delete

publish_beta:
	@echo
	./bin/build-sitegen
	./bin/compile . www "https://beta.samhuri.net"
	./bin/publish --beta --delete

sitegen:
	@echo
	./bin/build-sitegen

test: sitegen
	@echo
	./bin/test

.PHONY: blog publish publish_beta sitegen test
