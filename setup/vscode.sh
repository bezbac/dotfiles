#!/bin/bash
require homebrew

if command -v vscode -v &> /dev/null
then
    echo "VSCode seems to be already installed"
else
    echo "Installing VSCode"
    brew cask install visual-studio-code
fi

if [ -e ~/Library/Application\ Support/Code/User/settings.json ]
then
    echo "VSCode config seems to be already symlinked"
else
    echo "Symlinking VSCode config"
    ln -s $DOTFILE_ROOT/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
    ln -s $DOTFILE_ROOT/vscode/snippets/ ~/Library/Application\ Support/Code/User
fi

