#!/bin/bash

echo "Setting up my mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew analytics off
brew bundle install -v

# Install visual studio code @ 1.93.1
brew uninstall --cask visual-studio-code
wget https://raw.githubusercontent.com/Homebrew/homebrew-cask/b8fe6ebdd59af89dde443ff34fdc0fb57c655458/Casks/v/visual-studio-code.rb
brew install --cask ./visual-studio-code.rb
rm ./visual-studio-code.rb

# Install node
nvm install stable

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Create Folders
mkdir -p $HOME/.config
mkdir -p $HOME/.config/sheldon
mkdir -p $HOME/.config/wezterm

# Compile karabiner rules
deno run --allow-write ./karabiner/karabiner.ts

# Symlinks
ln -sfn $DOTFILE_ROOT/.aliases $HOME/.aliases
ln -sfn $DOTFILE_ROOT/.path $HOME/.path
ln -sfn $DOTFILE_ROOT/.editor $HOME/.editor
ln -sfn $DOTFILE_ROOT/.editorconfig $HOME/.editorconfig
ln -sfn $DOTFILE_ROOT/.gitconfig $HOME/.gitconfig
ln -sfn $DOTFILE_ROOT/ssh/config $HOME/.ssh/config
ln -sfn $DOTFILE_ROOT/ssh/rc $HOME/.ssh/rc
ln -sfn $DOTFILE_ROOT/nvim $HOME/.config/nvim
ln -sfn $DOTFILE_ROOT/starship/starship.toml $HOME/.config/starship.toml
ln -sfn $DOTFILE_ROOT/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
ln -sfn $DOTFILE_ROOT/vscode/keybindings.json $HOME/Library/Application\ Support/Code/User/keybindings.json
ln -sfn $DOTFILE_ROOT/vscode/custom.css $HOME/Library/Application\ Support/Code/User/custom.css
ln -sfn $DOTFILE_ROOT/vscode/snippets $HOME/Library/Application\ Support/Code/User/snippets
ln -sfn $DOTFILE_ROOT/zsh/.zshrc $HOME/.zshrc
ln -sfn $DOTFILE_ROOT/sheldon/plugins.toml $HOME/.config/sheldon/plugins.toml
ln -sfn $DOTFILE_ROOT/bash/.bashrc $HOME/.bashrc
ln -sfn $DOTFILE_ROOT/scripts $HOME/scripts
ln -sfn $DOTFILE_ROOT/helix $HOME/.config/helix
ln -sfn $DOTFILE_ROOT/zellij $HOME/.config/zellij
ln -sfn $DOTFILE_ROOT/atuin $HOME/.config/atuin
ln -sfn $DOTFILE_ROOT/wezterm/.wezterm.lua $HOME/.wezterm.lua
ln -sfn $DOTFILE_ROOT/wezterm/themes $HOME/.config/wezterm/colors
ln -sfn $DOTFILE_ROOT/karabiner/karabiner.json $HOME/.config/karabiner/karabiner.json

# Install VSCode Extensions
# extensions.list contains the output from "code --list-extensions"
while read EXTENSION
do
    [[ "$line" =~ ^#.*$ ]] && continue
    echo "Install VSCode Extension: $EXTENSION"
    code --install-extension $EXTENSION
done < $DOTFILE_ROOT/vscode/extensions.list

# Install global npm modules
while read PGK
do
    [[ "$line" =~ ^#.*$ ]] && continue
    echo "Install global pnpm package: $PKG"
    pnpm add -g $PGK
done < $DOTFILE_ROOT/npm.list

# Setup macos defaults
source ./macos/defaults.sh

# Setup macos dock
source ./macos/dock.sh
