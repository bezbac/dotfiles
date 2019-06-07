# Spacefish config
set -g SPACEFISH_TIME_SHOW true

set -g SPACEFISH_PACKAGE_SHOW false
set -g SPACEFISH_NODE_SHOW false
set -g SPACEFISH_JULIA_SHOW false
set -g SPACEFISH_DOCKER_SHOW false
set -g SPACEFISH_RUBY_SHOW false
set -g SPACEFISH_HASKELL_SHOW false
set -g SPACEFISH_AWS_SHOW false
set -g SPACEFISH_CONDA_SHOW false
set -g SPACEFISH_PYENV_SHOW false
set -g SPACEFISH_GOLANG_SHOW false
set -g SPACEFISH_PHP_SHOW false
set -g SPACEFISH_RUST_SHOW false
set -g SPACEFISH_DOTNET_SHOW false
set -g SPACEFISH_KUBECONTEXT_SHOW false
set -g SPACEFISH_BATTERY_SHOW false

# PATH
## Add flutter to PATH
set PATH /Users/ben/Library/Caches/flutter/bin $PATH .
set PATH /Users/ben/.cargo/bin $PATH .

## Add git to PATH
set PATH /usr/local/git/bin $PATH .
set PATH /usr/local/opt/make/libexec/gnubin $PATH .

# ALIASES
## Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

## List
alias la="ls -a"

## Docker
alias dc="docker-compose"

## Git
### Pretty git history
alias glog="git log --graph --pretty='format:%C(red)%d%C(reset) %C(yellow)%h%C(reset) %ar %C(green)%aN%C(reset) %s'"

alias gd="git diff --stat"