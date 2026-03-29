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
pnpm env use --global lts

# Install rust
rustup-init -y
rustup install stable
rustup component add rust-analyzer

# Install tools based on cargo
if test ! $(which git-grab); then
  cargo install --git https://github.com/bezbac/git-grab.git
fi
if test ! $(which wt); then
  cargo install worktrunk
fi

# Install tools based on pnpm
pnpm add -g @github/copilot@0.0.369
pnpm add -g @openai/codex@0.98.0

# Init & update submodules
git submodule update --init --recursive
git pull --recurse-submodules

# Compile karabiner rules
deno run --allow-env --allow-read --allow-write ./karabiner/karabiner.ts

# Update copilot cli settings
if [ -f $HOME/.copilot/config.json ]; then
  jq '.theme = "light"' $HOME/.copilot/config.json | sponge $HOME/.copilot/config.json
fi

# Copy opencode-notifier.json.template to opencode-notifier.json and replace $DOTFILE_ROOT with the actual path
sed "s|\$DOTFILE_ROOT|$DOTFILE_ROOT|g" $DOTFILE_ROOT/opencode/opencode-notifier.json.template > $DOTFILE_ROOT/opencode/opencode-notifier.json

# Symlinks
source ./install_symlinks.sh

# Setup vscode
source ./install_vscode.sh

# Setup resources
source ./install_resources.sh

# Setup macos defaults
source ./macos/defaults.sh

# Setup macos dock
source ./macos/dock.sh
