#!/bin/bash

if [ -e ~/.aliases ]
then
    echo "aliases seem to be already symlinked"
else
    echo "Symlinking aliases"
    ln -s $DOTFILE_ROOT/.aliases ~/.aliases
fi