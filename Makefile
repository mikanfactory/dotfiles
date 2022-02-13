makefiles = git.mk tmux.mk zsh.mk nvim.mk font.mk

.PHONY: install
install:
	for target in $(makefiles) ; do \
    $(MAKE) -f install_scripts/$$target install; \
	done
