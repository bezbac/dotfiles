#!/usr/bin/env bash
set -euo pipefail

readonly PAGE_URL="https://www.raycast.com/new"
readonly DOWNLOAD_DIR="$HOME/Downloads"

case "$(uname -m)" in
    arm64)
        readonly ARCH="arm64"
        ;;
    x86_64)
        readonly ARCH="x86_64"
        ;;
    *)
        printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2
        exit 1
        ;;
esac

page="$(mktemp)"
dmg_path=""
mount_point=""

cleanup() {
    # Eject the DMG if it is still mounted.
    if [[ -n "$mount_point" ]]; then
        hdiutil detach "$mount_point" >/dev/null 2>&1 || true
    fi

    # Remove temporary files.
    rm -f "$page"

    # Remove the downloaded DMG.
    if [[ -n "$dmg_path" ]]; then
        rm -f "$dmg_path"
    fi
}

trap cleanup EXIT

printf 'Resolving latest Raycast beta for %s…\n' "$ARCH"

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --output "$page" \
    "$PAGE_URL"

url="$(
    grep -oE 'https://x-r2\.raycast-releases\.com/Raycast_Beta_[^"]+_'$ARCH'\.dmg' "$page" |
        head -n 1
)"

if [[ -z "$url" ]]; then
    printf 'Could not find a Raycast beta download URL for %s\n' "$ARCH" >&2
    exit 1
fi

filename="${url##*/}"
dmg_path="$DOWNLOAD_DIR/$filename"

mkdir -p "$DOWNLOAD_DIR"

printf 'Downloading %s…\n' "$filename"

curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --output "$dmg_path" \
    "$url"

printf 'Downloaded to: %s\n' "$dmg_path"

printf 'Mounting DMG…\n'

mount_point="$(
    hdiutil attach "$dmg_path" -nobrowse -readonly |
        awk -F '\t' '$NF ~ /^\/Volumes\// { print $NF; exit }'
)"

if [[ -z "$mount_point" ]]; then
    printf 'Could not determine DMG mount point\n' >&2
    exit 1
fi

app_path="$(
    find "$mount_point" \
        -maxdepth 1 \
        -type d \
        -name '*.app' \
        -print \
        -quit
)"

if [[ -z "$app_path" ]]; then
    printf 'No application found in the downloaded DMG\n' >&2
    exit 1
fi

app_name="$(basename "$app_path")"
destination="/Applications/$app_name"

printf 'Found application: %s\n' "$app_name"

printf 'Verifying code signature…\n'

if ! codesign --verify --deep --strict --verbose=2 "$app_path"; then
    printf 'Code-signature verification failed. Nothing was installed.\n' >&2
    exit 1
fi

printf 'Checking with Gatekeeper…\n'

if ! spctl --assess --type execute --verbose=2 "$app_path"; then
    printf 'Gatekeeper rejected the application. Nothing was installed.\n' >&2
    exit 1
fi

printf 'Verification passed.\n'

# IMPORTANT:
# Copy the application while the DMG is still mounted.
printf 'Installing %s…\n' "$app_name"

ditto "$app_path" "$destination"

printf 'Installed: %s\n' "$destination"

# Now that the application has been copied, eject the DMG.
printf 'Ejecting DMG…\n'

hdiutil detach "$mount_point" >/dev/null
mount_point=""

# Remove the downloaded DMG from ~/Downloads.
printf 'Cleaning up downloaded DMG…\n'

rm -f "$dmg_path"
dmg_path=""

printf 'Opening %s…\n' "$app_name"

open "$destination"

printf 'Done.\n'
