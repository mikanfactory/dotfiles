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

simlink_ipython:
	mkdir -p $(HOME)/.ipython/profile_default && \
	mkdir -p $(HOME)/.jupyter/custom && \
	ln -s $(shell pwd)/jupyter_configs/startup $(HOME)/.ipython/profile_default && \
	ln -s $(shell pwd)/jupyter_configs/custom $(HOME)/.jupyter/custom && \
	touch simlink_ipython
