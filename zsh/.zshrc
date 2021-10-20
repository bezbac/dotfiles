# History
export HISTFILE="$HOME/.zsh_history"
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000

setopt HIST_IGNORE_ALL_DUPS

# Sheldon
eval "$(sheldon source)"

# Starship
eval "$(starship init zsh)"

# Aliases
source "$HOME/.aliases"

# Paths
source "$HOME/.path"

## Setup pyenv
eval "$(pyenv init -)"

# Setup substring search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

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