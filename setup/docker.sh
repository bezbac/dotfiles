#!/bin/bash
require homebrew

if command -v docker -v &> /dev/null
then
    echo "Docker seems to be already installed"
else
    echo "Installing Docker"
    brew cask install docker
fi