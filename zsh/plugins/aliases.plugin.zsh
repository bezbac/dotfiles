#!/usr/bin/env zsh

## Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

## SSH
alias ssh="TERM=xterm ssh"

## List
alias ls="eza"
alias la="eza -a"

## Vim
alias vim="nvim"
alias vi="nvim"

## Docker
alias dc="docker-compose"

## Git
alias g="git"

## Terraform
alias tf="terraform"

## Zoxide
alias j="z"

## pnpm
alias p="pnpm"

## moon
alias m="moon"

## OpenCode
# Keep agents from inheriting credentials that could bypass push approval.
opencode() {
  env \
    -u GH_TOKEN \
    -u GITHUB_TOKEN \
    -u GH_ENTERPRISE_TOKEN \
    -u GITHUB_ENTERPRISE_TOKEN \
    -u GH_CONFIG_DIR \
    -u GIT_ASKPASS \
    -u SSH_ASKPASS \
    -u GIT_CONFIG_PARAMETERS \
    -u GIT_CONFIG_COUNT \
    opencode "$@"
}
