#!/bin/bash

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install tools
brew install git
brew install fish
brew install wget
brew install htop

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
brew install oni

# Flutter
git clone -b master https://github.com/flutter/flutter.git /Users/ben/Library/Caches/flutter/