#!/bin/bash
require homebrew

if command -v node -v &> /dev/null
then
    echo "node seems to be already installed"
else
    echo "Installing node"
    brew install node
fi
