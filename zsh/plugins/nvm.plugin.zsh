#!/usr/bin/env zsh

export NVM_DIR="$(brew --prefix)/opt/nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
fi

if [ -s "$NVM_DIR/bash_completion" ]; then
    source "$NVM_DIR/etc/bash_completion.d/nvm"
fi
