#!/bin/bash

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Install VSCode Extensions
# extensions.list contains the output from "code --list-extensions"
while read EXTENSION
do
    case $EXTENSION in
       ''|\#*) continue ;;
    esac
    echo "Install VSCode Extension: $EXTENSION"
    code --install-extension $EXTENSION
done < $DOTFILE_ROOT/vscode/extensions.list

# Build Dance from source
cd $DOTFILE_ROOT/vscode/extensions/dance
yarn install
yarn run package

cd $DOTFILE_ROOT/vscode/extensions/dance/extensions/helix
yarn install
yarn run package

DANCE_EXTENSION=$(find $DOTFILE_ROOT/vscode/extensions/dance -type f -iname "*.vsix" | head -n 1)
DANCE_HELIX_EXTENSION=$(find $DOTFILE_ROOT/vscode/extensions/dance/extensions/helix -type f -iname "*.vsix" | head -n 1)

code --install-extension "$DANCE_EXTENSION"
code --install-extension "$DANCE_HELIX_EXTENSION"

# Return to dotfile root
cd $DOTFILE_ROOT
