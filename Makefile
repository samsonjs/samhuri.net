all: debug

debug:
	@echo
	bin/build-gensite
	bin/gensite . www http://localhost:8000

ocean:
	@echo
	bin/build-gensite
	bin/gensite . www http://ocean.gurulogic.ca:8000

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
	rm -rf $HOME/Library/Developer/Xcode/DerivedData/gensite-ewvaffkhpgybjtfpkcxyucwdpmfl
	rm -rf SiteGenerator/.build
	rm -rf $HOME/Library/Developer/Xcode/DerivedData/SiteGenerator-ftomcgvdmmvedteooctyccrevcyn
	rm -rf samhuri.net/.build
	rm -rf $HOME/Library/Developer/Xcode/DerivedData/samhuri-fvrlgfanofqywqevrqijjltaldjd

serve:
	@echo
	cd www && python -m SimpleHTTPServer

watch:
	bin/watch

.PHONY: debug ocean beta release publish publish_beta clean clean_blog clean_swift serve watch
