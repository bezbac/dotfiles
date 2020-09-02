#!/bin/bash
require homebrew

if command -v starship -V &> /dev/null
then
    echo "Starship seems to be already installed"
else
    echo "Installing Starship"
    brew install starship
fi

if [ -e ~/.config/starship.toml ]
then
    echo "Starship config seems to be already symlinked"
else
    echo "Symlinking Starship config"
    ln -s $DOTFILE_ROOT/starship.toml  ~/.config/starship.toml
fi