#!/bin/bash

if command -v brew -v &> /dev/null
then
    echo "Homebrew seems to be already installed"
else
    echo "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    brew update
    brew analytics off
fi