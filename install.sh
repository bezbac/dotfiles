#!/bin/bash

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew analytics off
brew bundle install -v

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Symlinks
ln -s $DOTFILE_ROOT/.aliases $HOME/.aliases
ln -s $DOTFILE_ROOT/.path $HOME/.path
ln -s $DOTFILE_ROOT/.editorconfig $HOME/.editorconfig
ln -s $DOTFILE_ROOT/.gitconfig $HOME/.gitconfig
ln -s $DOTFILE_ROOT/nvim $HOME/.config/nvim
ln -s $DOTFILE_ROOT/starship/starship.toml $HOME/.config/starship.toml
ln -s $DOTFILE_ROOT/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
ln -s $DOTFILE_ROOT/vscode/snippets $HOME/Library/Application\ Support/Code/User/snippets
ln -s $DOTFILE_ROOT/zsh/.zshrc $HOME/.zshrc
mkdir $HOME/.config/sheldon && ln -s $DOTFILE_ROOT/sheldon/plugins.toml $HOME/.config/sheldon/plugins.toml
ln -s $DOTFILE_ROOT/bash/.bashrc $HOME/.bashrc
ln -s $DOTFILE_ROOT/scripts $HOME/scripts

# Setup macos defaults
source ./macos/defaults.sh

# Install VSCode Extensions
# extensions.list contains the output from "code --list-extensions"
while read EXTENSION
do
    echo_info "Install VSCode Extension: $EXTENSION"
    code --install-extension $EXTENSION
done < $DOTFILE_ROOT/vscode/extensions.list
