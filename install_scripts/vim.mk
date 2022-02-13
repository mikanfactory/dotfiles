DOT_CONFIG_SRC := $(HOME)/code/dotfiles/.config


.PHONY: install
install: install/color_schema install/plugins install/neovim link


.PHONY: install/*
install/color_schema:
	mkdir -p ~/.vim/colors
	curl https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -o ~/.vim/colors/hybrid.vim


install/plugins:
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
	sh ./installer.sh ~/.cache/dein
	rm ./installer.sh
	vim +":silent call dein#install()" +:q
	cd ~/.cache/dein/repos/github.com/Shougo/vimproc.vim && make


install/neovim:
	pip3 install --upgrade neovim


.PHONY: link
link:
	ln -s $(DOT_CONFIG_SRC)/vim/.vimrc $(HOME)/.vimrc

