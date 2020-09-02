#!/bin/bash
require homebrew

if command -v make -v &> /dev/null
then
    echo "make seems to be already installed"
else
    echo "Installing make"
    brew install make
fi

if command -v htop -v &> /dev/null
then
    echo "htop seems to be already installed"
else
    echo "Installing htop"
    brew install htop
fi

if command -v bat -V &> /dev/null
then
    echo "bat seems to be already installed"
else
    echo "Installing bat"
    brew install bat
fi