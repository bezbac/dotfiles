#!/usr/bin/env zsh

# rust
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$(rustc --print sysroot)/bin:$PATH"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# poetry
export PATH="$HOME/.poetry/bin:$PATH"

# scripts
export PATH="$HOME/scripts:$PATH"

# pnpm
export PNPM_HOME="$HOME/.pnpm"
export PATH="$HOME/.pnpm:$PATH"

# proto
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
