#!/bin/bash
require homebrew

if command -v tldr -v &> /dev/null
then
    echo "tealdeer (tldr) seems to be already installed"
else
    echo "Installing tealdeer"
    brew install tldr
fi