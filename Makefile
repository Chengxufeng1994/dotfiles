.PHONY: packages brew-packages cask-apps

SHELL = /bin/bash
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

packages: brew-packages cask-apps

brew-packages:
	@brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

cask-apps:
	@brew bundle --file=$(DOTFILES_DIR)/install/Caskfile || true
