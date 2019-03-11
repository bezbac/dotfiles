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