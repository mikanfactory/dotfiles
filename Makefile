.PHONY: install
install: install/vim-plugin

.PHONY: install/*
install/vim-plugin: simlink
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
	sh ./installer.sh ~/.cache/dein
	rm ./installer.sh
	vim +":silent call dein#install()" +:q
	mkdir -p ~/.vim/colors
	cp ~/.cache/dein/repos/github.com/jpo/vim-railscasts-theme/colors/railscasts.vim ~/.vim/colors/
	cd ~/.cache/dein/repos/github.com/Shougo/vimproc.vim && make
	pip3 install --upgrade neovim

simlink:
	ln -s $(shell pwd)/.gitconfig $(HOME)/.gitconfig && \
	ln -s $(shell pwd)/.tmux.conf $(HOME)/.tmux.conf && \
	ln -s $(shell pwd)/.vimrc $(HOME)/.vimrc && \
	ln -s $(shell pwd)/.zshrc $(HOME)/.zshrc && \
	touch simlink

download/colorschema:
	mkdir -p ~/.config/nvim/colors/
	curl https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -o ~/.config/nvim/colors/hybrid.vim
