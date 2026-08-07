#!/usr/bin/env zsh

export PROTO_HOME="$HOME/.proto"

# Avoid refreshing Proto's cached WASM plugins on every directory change.
export PROTO_CACHE_DURATION=31536000

eval "$(proto activate zsh)"

# TODO: Remove proto from path when leaving a proto project
