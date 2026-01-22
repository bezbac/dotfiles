#!/bin/bash

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# NPM: https://github.com/bluwy/npm-userscript
curl -fsSL https://update.greasyfork.org/scripts/559139/Npm%20Userscript.user.js -o $DOTFILE_ROOT/userscripts/npm.user.js
