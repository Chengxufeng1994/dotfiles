.PHONY: packages install-brew brew-packages cask-apps softlink

SHELL = /bin/bash
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell uname -s)
BREW_EXISTING:=$(shell type -p brew || echo 'false')

# Make sure we are in the same directory as the Makefile
BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

packages: brew-packages cask-apps

install-brew:
ifeq ($(BREW_EXISTING),'false')
	@curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash
endif

brew-packages: install-brew
	@brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

cask-apps: install-brew
	@brew bundle --file=$(DOTFILES_DIR)/install/Caskfile || true

npm: brew-packages
	@fnm install --lts

softlink:
	@ln -s -f $(BASE_DIR).zshrc ~/.zshrc
	@ln -s -f $(BASE_DIR).p10k.zsh ~/.p10k.zsh
	@ln -s -f $(BASE_DIR).vimrc ~/.vimrc
