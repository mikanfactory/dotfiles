.PHONY: install
install: install/color_schema install/plugins


.PHONY: install/*
install/plugins:
	curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
	sh ./installer.sh ~/.cache/dein
	rm ./installer.sh
	nvim +":silent call dein#install()" +:q


install/color_schema:
	curl https://raw.githubusercontent.com/w0ng/vim-hybrid/master/colors/hybrid.vim -o ~/.config/nvim/colors/hybrid.vim


.PHONY: link
link:
	ln -s $(DOT_CONFIG_SRC)/nvim $(HOME)/.config/nvim
