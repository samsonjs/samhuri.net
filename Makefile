all: debug

debug:
	@echo
	bin/build-gensite
	bin/gensite . www http://localhost:8000

ocean:
	@echo
	bin/build-gensite
	bin/gensite . www https://ocean.samhuri.net

beta: clean_blog
	@echo
	bin/build-gensite
	bin/gensite . www https://beta.samhuri.net

release: clean_blog
	@echo
	bin/build-gensite
	bin/gensite . www

publish: release
	@echo
	bin/publish --delete www/

publish_beta: beta
	@echo
	bin/publish --beta --delete www/

clean: clean_blog

clean_blog:
	@echo
	rm -rf www/* www/.htaccess

clean_swift:
	@echo
	rm -rf gensite/.build
	rm -rf $(HOME)/Library/Developer/Xcode/DerivedData/gensite-*
	rm -rf samhuri.net/.build
	rm -rf $(HOME)/Library/Developer/Xcode/DerivedData/samhuri-*

serve:
	@echo
	cd www && python3 -m http.server --bind localhost

watch:
	bin/watch

.PHONY: debug ocean beta release publish publish_beta clean clean_blog clean_swift serve watch
