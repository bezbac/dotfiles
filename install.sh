#!/bin/bash

echo "Setting up my mac..."

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

brew update
brew analytics off
brew bundle install -v

# Install node
nvm install stable

# Install rust
rustup install stable
rustup add component rust-analyzer

# Install tools based on cargo
cargo install --git https://github.com/bezbac/git-grab.git

# Install tools based on pnpm
pnpm add -g @github/copilot@0.0.369

# Update submodules
git pull --recurse-submodules

# Compile karabiner rules
deno run --allow-write ./karabiner/karabiner.ts

# Update copilot cli settings
if [ -f $HOME/.copilot/config.json ]; then
  jq '.theme = "light"' $HOME/.copilot/config.json | sponge $HOME/.copilot/config.json
fi

# Symlinks
source ./install_symlinks.sh

# Setup vscode
source ./install_vscode.sh

# Setup userscripts
source ./install_userscripts.sh

# Setup macos defaults
source ./macos/defaults.sh

# Setup macos dock
source ./macos/dock.sh
