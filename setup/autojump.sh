#!/bin/bash
require homebrew

if command -v autojump -v &> /dev/null
then
    echo "autojump seems to be already installed"
else
    echo "Installing autojump"
    brew install autojump
fi