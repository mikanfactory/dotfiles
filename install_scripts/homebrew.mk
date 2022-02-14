PYTHON := $(shell which python3)


.PHONY: install
install: install/brew_formulae install/brew_cask_formulae


.PHONY: install/*
install/brew_formulae:
	brew install $(shell $(PYTHON) install_scripts/lib/line_up_lists.py install_scripts/brew_formulae.txt)


install/brew_cask_formulae:
	brew tap homebrew/cask-fonts
	brew install --cask $(shell $(PYTHON) install_scripts/lib/line_up_lists.py install_scripts/brew_cask_formulae.txt)


.PHONY: dump
dump: dump/formulae dump/cask


.PHONY: dump/*
dump/formulae:
	brew leaves > $(shell pwd)/install_scripts/brew_formulae.txt


dump/cask:
	brew list --cask -1 > $(shell pwd)/install_scripts/brew_cask_formulae.txt

