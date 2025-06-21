.PHONY: packages install-brew install-zsh brew-packages cask-apps softlink

SHELL = /bin/bash
DOTFILES_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell uname -s)
BREW_EXISTING:=$(shell type -p brew || echo 'false')

# Make sure we are in the same directory as the Makefile
BASE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ZSH_PATH := $(shell which zsh)

packages: brew-packages cask-apps

install-brew:
	@if ! command -v brew &>/dev/null; then \
		echo "Installing Homebrew..."; \
		curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /bin/bash; \
	else \
		echo "Homebrew already installed."; \
	fi

install-zsh:
	@if ! command -v zsh &>/dev/null; then \
		echo "Installing Zsh..."; \
		brew install zsh; \
	else \
		echo "Zsh already installed."; \
	fi
	@if [ -n "$(ZSH_PATH)" ]; then \
		echo "Setting Zsh as default shell for user '$$USER'..."; \
		chsh -s $(ZSH_PATH); \
	else \
		echo "Zsh path not found. Skipping chsh."; \
	fi
	@zsh --version

install-ohmyzsh: install-zsh
	@if [ ! -d "$$HOME/.oh-my-zsh" ]; then \
		echo "Installing Oh My Zsh..."; \
		sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
	else \
		echo "Oh My Zsh already installed."; \
	fi

install-p10k: install-ohmyzsh
	@if [ ! -d "$$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then \
		echo "Installing Powerlevel10k..."; \
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
			$$HOME/.oh-my-zsh/custom/themes/powerlevel10k; \
	else \
		echo "Powerlevel10k already installed."; \
	fi
	@echo "Setting Powerlevel10k theme in .zshrc..."
	@sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $$HOME/.zshrc || true

brew-packages: install-brew
	@brew bundle --file=$(DOTFILES_DIR)/install/Brewfile || true

cask-apps: install-brew
	@brew bundle --file=$(DOTFILES_DIR)/install/Caskfile || true

npm: brew-packages
	@fnm install --lts

softlink:
	@ln -s -f $(BASE_DIR).zshrc ~/.zshrc
	@ln -s -f $(BASE_DIR).aliases.zsh ~/.aliases.zsh
	@ln -s -f $(BASE_DIR).p10k.zsh ~/.p10k.zsh
	@ln -s -f $(BASE_DIR).vimrc ~/.vimrc
	@ln -s -f $(BASE_DIR).tmux.conf ~/.tmux.conf
	@ln -s -f $(BASE_DIR).gitconfig ~/.gitconfig
	@ln -s -f $(BASE_DIR).git-commit-msg-tmpl ~/.gitmessage
	@ln -s -f $(BASE_DIR)nvim ~/.config/nvim
