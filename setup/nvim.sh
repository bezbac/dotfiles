#!/bin/bash
require homebrew python fzf

if command -v nvim -v &> /dev/null
then
    echo "NeoVim seems to be already installed"
else
    echo "Installing NeoVim"
    brew install neovim
    pip3 install --user pynvim
fi

if [ -e ~/.config/nvim ]
then
    echo "NeoVim config seems to be already symlinked"
else
    echo "Symlinking NeoVim config"
    ln -s $DOTFILE_ROOT/nvim ~/.config/nvim
fi