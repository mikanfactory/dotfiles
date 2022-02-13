.PHONY: install
install: link


.PHONY: link
link:
	ln -s $(shell pwd)/.gitconfig $(HOME)/.gitconfig
	ln -s $(shell pwd)/.gitignore_global $(HOME)/.gitignore_global
