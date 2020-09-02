#!/bin/bash
require homebrew

if command -v rustup -V &> /dev/null
then
    echo "rustup seems to be already installed"
else
    echo "Installing rustup"
    brew install rustup
fi
