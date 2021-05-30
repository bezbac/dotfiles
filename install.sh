#!/bin/bash

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew analytics off

# Symlinks
ln -s $DOTFILE_ROOT/.aliases $HOME/.aliases
ln -s $DOTFILE_ROOT/.path $HOME/.path
ln -s $DOTFILE_ROOT/.editorconfig $HOME/.editorconfig
ln -s $DOTFILE_ROOT/.gitconfig $HOME/.gitconfig
ln -s $DOTFILE_ROOT/nvim $HOME/.config/nvim
ln -s $DOTFILE_ROOT/starship.toml  $HOME/.config/starship.toml
ln -s $DOTFILE_ROOT/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
ln -s $DOTFILE_ROOT/vscode/snippets/ $HOME/Library/Application\ Support/Code/User
ln -s $DOTFILE_ROOT/.zshrc $HOME/.zshrc

# Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Zotero
echo "Please manually install zotero plugins"
echo "- https://github.com/mronkko/ZoteroQuickLook"
echo "- https://github.com/jlegewie/zotfile"
echo "- https://github.com/argenos/zotero-mdnotes"