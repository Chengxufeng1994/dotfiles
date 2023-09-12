.PHONY: packages brew-packages

SHELL = /bin/bash
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

packages: brew-packages

brew-packages:
	@brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true
