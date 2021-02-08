# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting last-working-dir autojump docker docker-compose)

source $ZSH/oh-my-zsh.sh

# Override unwanted oh-my-zsh defaults
unsetopt share_history

# User configuration

export HISTFILE="$HOME/.zsh_history"
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000

setopt HIST_IGNORE_ALL_DUPS

# Starship
eval "$(starship init zsh)"

# Thefuck
eval $(thefuck --alias)

# Aliases
source "$HOME/.aliases"

# Paths
source "$HOME/.path"

## Setup pyenv
eval "$(pyenv init -)"

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