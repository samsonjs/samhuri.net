all: blog

blog: sitegen
	@echo
	rm -rf www
	./bin/sitegen . www

publish: blog
	@echo
	./bin/publish --delete www/

publish_beta:
	@echo
	./bin/build-sitegen
	rm -rf www
	./bin/sitegen . www "https://beta.samhuri.net"
	./bin/publish --beta --delete www/

sitegen:
	@echo
	./bin/build-sitegen

test: sitegen
	@echo
	./bin/test

.PHONY: blog publish publish_beta sitegen test
