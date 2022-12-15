# Starship
eval "$(starship init bash)"

# Atuin
eval "$(atuin init bash)"

# Aliases
source "$HOME/.aliases"

# Paths
source "$HOME/.path"
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
