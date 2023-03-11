#!/bin/bash

echo "Setting up my mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew analytics off
brew bundle install -v

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create Folders
mkdir -p $HOME/.config
mkdir -p $HOME/.config/sheldon

# Symlinks
ln -sfn $DOTFILE_ROOT/.aliases $HOME/.aliases
ln -sfn $DOTFILE_ROOT/.path $HOME/.path
ln -sfn $DOTFILE_ROOT/.editorconfig $HOME/.editorconfig
ln -sfn $DOTFILE_ROOT/.gitconfig $HOME/.gitconfig
ln -sfn $DOTFILE_ROOT/nvim $HOME/.config/nvim
ln -sfn $DOTFILE_ROOT/starship/starship.toml $HOME/.config/starship.toml
ln -sfn $DOTFILE_ROOT/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
ln -sfn $DOTFILE_ROOT/vscode/keybindings.json $HOME/Library/Application\ Support/Code/User/keybindings.json
ln -sfn $DOTFILE_ROOT/vscode/snippets $HOME/Library/Application\ Support/Code/User/snippets
ln -sfn $DOTFILE_ROOT/zsh/.zshrc $HOME/.zshrc
ln -sfn $DOTFILE_ROOT/sheldon/plugins.toml $HOME/.config/sheldon/plugins.toml
ln -sfn $DOTFILE_ROOT/bash/.bashrc $HOME/.bashrc
ln -sfn $DOTFILE_ROOT/scripts $HOME/scripts
ln -sfn $DOTFILE_ROOT/helix $HOME/.config/helix

# Install VSCode Extensions
# extensions.list contains the output from "code --list-extensions"
while read EXTENSION
do
    echo "Install VSCode Extension: $EXTENSION"
    code --install-extension $EXTENSION
done < $DOTFILE_ROOT/vscode/extensions.list

# Setup macos defaults
source ./macos/defaults.sh

# Setup macos dock
source ./macos/dock.sh
