#!/bin/bash
require homebrew

if command -v poetry -V &> /dev/null
then
    echo "Poetry seems to be already installed"
else
    echo "Installing Poetry"
    brew install poetry
fi