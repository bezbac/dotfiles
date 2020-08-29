### --- CLEANING UP HOMEBREW ---
### In order to clean up homebrew run
### brew bundle dump
### Remove all unwanted packages in the generated Brewfile then and run
### brew bundle --force cleanup

#!/bin/bash

# Turn off homebrew google analytics
brew analytics off

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade

# Install basics
brew install git
brew install git-lfs
brew install fish

# Install tools
brew install starship # Fish prompt
brew install make # Makefile support
brew install wget # Download
brew install htop # System dashboard
brew install thefuck # Correct previous commands
brew install fzf # Fuzzy finder
brew install bat # File preview
brew install ripgrep # Search
brew install autojump # File system jumping

# Javascript environment
brew install node
brew install yarn

# Rust environment
brew install rustup

# Python environment
brew install python
brew install pyenv
brew install poetry
python -m pip install 'python-language-server[all]'

# Vim
brew install neovim
pip3 install --user pynvim

# Install apps
brew cask install iterm2
brew cask install firefox
brew cask install visual-studio-code
brew cask install spotify
brew cask install handbrake
brew cask install alacritty
