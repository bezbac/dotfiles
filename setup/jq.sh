#!/bin/bash
require homebrew

if command -v jq -v &> /dev/null
then
    echo "jq seems to be already installed"
else
    echo "Installing jq"
    brew install jq
fi