.PHONY: install
install: link


.PHONY: link
link:
	ln -s $(shell pwd)/.hyper.js $(HOME)/.hyper.js

