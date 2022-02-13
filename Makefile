DOT_CONFIG_SRC := $(HOME)/code/dotfiles
makefiles = git.mk tmux.mk zsh.mk nvim.mk font.mk

.PHONY: install
install:
	for target in $(makefiles) ; do \
    $(MAKE) -f install_scripts/$$target install DOT_CONFIG_SRC=$(DOT_CONFIG_SRC); \
	done
