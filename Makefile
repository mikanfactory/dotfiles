PROJECT_ROOT := $(shell pwd)
makefiles = git.mk homebrew.mk hyper.mk nvim.mk starship.mk tmux.mk zsh.mk

.PHONY: install
install:
	for target in $(makefiles) ; do \
    $(MAKE) -f install_scripts/$$target install PROJECT_ROOT=$(PROJECT_ROOT); \
	done
