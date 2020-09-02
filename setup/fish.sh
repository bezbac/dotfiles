#!/bin/bash
require homebrew starship aliases

if command -v fish -v &> /dev/null
then
    echo "fish seems to be already installed"
else
    echo "Installing fish"
    brew install fish
fi

if [ -e ~/.config/fish/functions ]
then
    echo "fish config seems to be already symlinked"
else
    echo "Symlinking fish config"
    ln -s $DOTFILE_ROOT/fish/functions ~/.config/fish/functions
	ln -s $DOTFILE_ROOT/fish/completions ~/.config/fish/completions
	ln -s $DOTFILE_ROOT/fish/config.fish ~/.config/fish/config.fish
	ln -s $DOTFILE_ROOT/fish/conf.d ~/.config/fish/conf.d
fi