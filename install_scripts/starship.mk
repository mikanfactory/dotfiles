PROJECT_ROOT := $(HOME)/code/dotfiles
DOT_CONFIG_SRC := $(PROJECT_ROOT)/.config


.PHONY: install
install: link


.PHONY: link
link:
	ln -s $(DOT_CONFIG_SRC)/startship.toml $(HOME)/.config/starship.toml

