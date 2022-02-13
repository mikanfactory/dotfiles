.PHONY: install
install: link


.PHONY: link
link:
	ln -s $(shell pwd)/.tmux.conf $(HOME)/.tmux.conf

