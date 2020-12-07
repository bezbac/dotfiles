#!/bin/bash
require homebrew

if command -v pup --version &> /dev/null
then
    echo "pup seems to be already installed"
else
    echo "Installing pup"
    brew install pup
fi