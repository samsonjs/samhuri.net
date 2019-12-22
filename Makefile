all: blog

debug: gensite
	@echo
	./bin/gensite . www http://localhost:8000

beta: gensite
	@echo
	./bin/gensite . www https://beta.samhuri.net

release: gensite
	@echo
	./bin/gensite . www

publish: release
	@echo
	./bin/publish --delete www/

publish_beta: beta
	@echo
	./bin/publish --beta --delete www/

gensite:
	@echo
	./bin/build-gensite

.PHONY: blog publish publish_beta gensite
