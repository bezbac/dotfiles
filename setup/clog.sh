#!/bin/bash
require homebrew

if command -v cloc --help &> /dev/null
then
    echo "cloc seems to be already installed"
else
    echo "Installing cloc"
    brew install cloc
fi