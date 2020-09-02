#!/bin/bash

if [ -e ~/.editorconfig ]
then
    echo "Editorconfig seems to be already symlinked"
else
    echo "Symlinking editorconfig"
    ln -s $DOTFILE_ROOT/.editorconfig ~/.editorconfig
fi