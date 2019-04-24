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

# Node environment
brew install node
brew install yarn

# Rust environment
brew install rust

# Vim
brew install neovim
brew install oni

# Flutter
git clone -b master https://github.com/flutter/flutter.git /Users/ben/Library/Caches/flutter/