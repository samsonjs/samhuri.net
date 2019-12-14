all: blog

blog: gensite
	@echo
	rm -rf www
	./bin/gensite . www

publish: blog
	@echo
	./bin/publish --delete www/

publish_beta:
	@echo
	./bin/build-gensite
	rm -rf www
	./bin/gensite . www "https://beta.samhuri.net"
	./bin/publish --beta --delete www/

gensite:
	@echo
	./bin/build-gensite

test: gensite
	@echo
	./bin/test

.PHONY: blog publish publish_beta gensite test
