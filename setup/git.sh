#!/bin/bash
require homebrew

if command -v git -v &> /dev/null
then
    echo "Git seems to be already installed"
else
    echo "Installing Git"
    brew install git
    brew install git-lfs
fi

if [ -e ~/.gitconfig ]
then
    echo "Git config seems to be already symlinked"
else
    echo "Symlinking Git config"
    ln -s $DOTFILE_ROOT/.gitconfig ~/.gitconfig
fi

if command -v gh -v &> /dev/null
then
    echo "GitHub CLI seems to be already installed"
else
    echo "Installing GitHub CLI"
    brew install gh
fi

