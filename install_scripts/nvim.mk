PROJECT_ROOT := $(HOME)/code/dotfiles
DOT_CONFIG_SRC := $(PROJECT_ROOT).config


.PHONY: install
install: install/color_schema install/plugins install/neovim link


.PHONY: install/*
install/color_schema:
	mkdir -n ~/.config/nvim/colors
	curl https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -o ~/.config/nvim/colors/hybrid.vim


install/plugins:
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
	sh ./installer.sh ~/.cache/dein
	rm ./installer.sh
	nvim +":silent call dein#install()" +:q


install/neovim:
	pip3 install --upgrade neovim


.PHONY: link
link:
	ln -s $(DOT_CONFIG_SRC)/nvim/init.vim $(HOME)/.config/nvim/init.vim
