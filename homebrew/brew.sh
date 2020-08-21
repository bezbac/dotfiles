#!/bin/bash

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install basics
brew install git
brew install git-lfs
brew install fish

# Install tools
brew install make
brew install wget
brew install htop
brew install hyperfine

# Javascript environment
brew install node
brew install yarn

# Rust environment
brew install rustup

# Python environment
brew install python
python -m pip install 'python-language-server[all]'

# Vim
brew install neovim

# Install apps
brew cask install iterm2
brew cask install alacritty