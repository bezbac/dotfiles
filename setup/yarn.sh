#!/bin/bash
require homebrew

if command -v yarn -v &> /dev/null
then
    echo "yarn seems to be already installed"
else
    echo "Installing yarn"
    brew install yarn
fi
