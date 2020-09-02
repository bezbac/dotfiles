#!/bin/bash
require homebrew

if command -v thefuck -v &> /dev/null
then
    echo "make seems to be already installed"
else
    echo "Installing thefuck"
    brew install thefuck
fi