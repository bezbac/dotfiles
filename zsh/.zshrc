#!/usr/bin/env zsh

# Enable completions
autoload -Uz compinit && compinit -i

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
bindkey '^r' _atuin_search_widget

## Setup pyenv
eval "$(pyenv init -)"

# Autosuggestions
bindkey '^[[Z' autosuggest-accept

# Setup substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

bindkey '^k' history-substring-search-up
bindkey '^j' history-substring-search-down

# Setup mac-OS keyboard navigation (⌥ + ← / → and ⌘ + ← / →)
bindkey "[D" backward-word
bindkey "[C" forward-word
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

### Fix slowness of pastes with zsh-syntax-highlighting.zsh
# Source: https://gist.github.com/magicdude4eva/2d4748f8ef3e6bf7b1591964c201c1ab
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic # I wonder if you'd need `.url-quote-magic`?
}

pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish
### Fix slowness of pastes

# This loads nvm
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"

# This loads nvm bash_completion
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

# This loads pnpm completions
[[ -f ~/.config/tabtab/zsh/__tabtab.zsh ]] && . ~/.config/tabtab/zsh/__tabtab.zsh || true

# Eval trick to allow running command but not exiting afterwards
# https://superuser.com/a/230090
if [[ $1 == eval ]]
then
    "$@"
set --
fi
