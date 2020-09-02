#!/bin/bash
require homebrew

if command -v fzf --help &> /dev/null
then
    echo "fzf seems to be already installed"
else
    echo "Installing fzf"
    brew install fzf
fi
