#!/bin/bash
require homebrew

if command -v pyenv -v &> /dev/null
then
    echo "Pyenv seems to be already installed"
else
    echo "Installing Pyenv"
    brew install pyenv
fi