DOT_CONFIG_SRC := $(HOME)/code/dotfiles


.PHONY: install
install: link


.PHONY: link
link:
	ln -s $(DOT_CONFIG_SRC)/zsh/.zshenv $(HOME)/.zshenv
	ln -s $(DOT_CONFIG_SRC)/zsh/.zshrc $(HOME)/.zshrc
	ln -s $(DOT_CONFIG_SRC)/zsh/ $(HOME)/zsh

