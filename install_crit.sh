# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Bash installation script for crit
CRIT_VERSION="v0.16.5"
CRIT_BIN_URL="https://github.com/tomasz-tomczyk/crit/releases/download/$CRIT_VERSION/crit-darwin-arm64"
CRIT_BIN_PATH="$HOME/.local/bin/crit"

# Download and install crit binary
mkdir -p $HOME/.local/bin
curl -L $CRIT_BIN_URL -o $CRIT_BIN_PATH
chmod +x $CRIT_BIN_PATH

# Copy crit skill & command
# This is explicitly not copying the crit plugin, as this only handles sharing currently and I'm not interested in that.
# See: https://github.com/tomasz-tomczyk/crit/blob/main/integrations/opencode/plugin/crit.ts
mkdir -p $DOTFILE_ROOT/opencode/command
mkdir -p $DOTFILE_ROOT/opencode/skills/crit
curl -L https://raw.githubusercontent.com/tomasz-tomczyk/crit/main/integrations/opencode/crit.md -o $DOTFILE_ROOT/opencode/command/crit.md
curl -L https://raw.githubusercontent.com/tomasz-tomczyk/crit/main/integrations/opencode/SKILL.md -o $DOTFILE_ROOT/opencode/skills/crit/SKILL.md
