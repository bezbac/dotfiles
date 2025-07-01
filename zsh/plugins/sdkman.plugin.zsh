#!/usr/bin/env zsh

export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec;

if [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]]; then
    source "${SDKMAN_DIR}/bin/sdkman-init.sh"
fi
