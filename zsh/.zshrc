#!/usr/bin/env zsh

### ----------------------------
### Source stuff
### ----------------------------

# Paths
source "$HOME/.path"

# Editor
source "$HOME/.editor"

# Aliases
source "$HOME/.aliases"

# Sheldon
eval "$(sheldon source)"

# Starship
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# Atuin
export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

## Setup pyenv
eval "$(pyenv init -)"

### ----------------------------
### Keybindings
### ----------------------------

# Setup atuin search
bindkey '^r' _atuin_search_widget

# Setup substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Setup mac-OS keyboard navigation (⌥ + ← / → and ⌘ + ← / →)
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

# Enable Ctrl-x-e to edit command line
bindkey '^xe' edit-command-line
bindkey '^x^e' edit-command-line

### ----------------------------
### Misc
### ----------------------------

# Eval trick to allow running command but not exiting afterwards
# https://superuser.com/a/230090
if [[ $1 == eval ]]
then
    "$@"
set --
fi
