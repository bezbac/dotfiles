#!/usr/bin/env zsh

# rust
export PATH="$(rustc --print sysroot)/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

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
export PATH="$HOME/.pnpm/bin:$PATH"

# deno
export PATH="$HOME/.deno/bin:$PATH"

# uv
export PATH="$HOME/.local/bin:$PATH"
