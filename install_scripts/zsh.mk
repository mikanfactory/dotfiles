PROJECT_ROOT := $(HOME)/code/dotfiles
DOT_CONFIG_SRC := $(PROJECT_ROOT).config


.PHONY: install
install: link


.PHONY: link
link:
	ln -s $(PROJECT_ROOT)/.zshenv $(HOME)/.zshenv
	ln -s $(PROJECT_ROOT)/.zshrc $(HOME)/.zshrc
	ln -s $(DOT_CONFIG_SRC)/zsh/ $(HOME)/zsh

