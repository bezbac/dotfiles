#!/bin/bash

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

download_and_verify_file() {
    local url=$1
    local output_path=$2
    local expected_checksum=$3
    curl -fsSL "$url" -o "$output_path"
    local actual_checksum=$(sha256sum "$output_path" | awk '{print $1}')
    if [ "$actual_checksum" != "$expected_checksum" ]; then
        echo "Checksum verification failed for $output_path! (expected: $expected_checksum, got: $actual_checksum)"
        rm "$output_path"
        exit 1
    fi
}

# NPM: https://github.com/bluwy/npm-userscript
download_and_verify_file \
    "https://update.greasyfork.org/scripts/559139/Npm%20Userscript.user.js" \
    "$DOTFILE_ROOT/userscripts/npm.user.js" \
    "2536a7b5679cf097b2d219588b750cff9dae6213028558e72e2ee8b2fc3ae53f"
