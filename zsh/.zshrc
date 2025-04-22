#!/usr/bin/env zsh

### ----------------------------
### Defaults
### ----------------------------

# Editor
export VISUAL=hx
export EDITOR=$VISUAL

### ----------------------------
### Add completions path
### ----------------------------
fpath=(~/.zsh/completions $fpath)

### ----------------------------
### Source stuff
### ----------------------------

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

# Auto notify ignored commands
AUTO_NOTIFY_IGNORE+=("pnpm dev")
AUTO_NOTIFY_IGNORE+=("moon dev")
AUTO_NOTIFY_IGNORE+=("p dev")

# Eval trick to allow running command but not exiting afterwards
# https://superuser.com/a/230090
if [[ $1 == eval ]]
then
    "$@"
set --
fi
