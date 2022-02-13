.PHONY: install

.PHONY: dump
dump: dump/formulae dump/cask


.PHONY: dump/*
dump/formulae:
	brew leaves > $(shell pwd)/install_scripts/brew_formulae.txt


dump/cask:
	brew list --cask -1 > $(shell pwd)/install_scripts/brew_cask_formulae.txt

