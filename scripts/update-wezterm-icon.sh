#!/bin/bash

set -eo pipefail

echo "Updating WezTerm icon"

app_path=/Applications/WezTerm.app
if [ ! -d "$app_path" ]; then
  echo "Can't find WezTerm.app. Make sure it is installed"
  exit 1
fi

icon_path=/Applications/WezTerm.app/Contents/Resources/terminal.icns
if [ -f "$icon_path" ]; then
  echo "Backing up existing icon"
  hash="$(shasum $icon_path | head -c 10)"
  mv "$icon_path" "$icon_path.backup-$hash"
  exit 1
fi

echo "Downloading replacement icon"
png_url=https://user-images.githubusercontent.com/18397/186718396-1e30e59b-a954-4e21-9af6-8fb401acc026.png
curl $png_url > /tmp/wezterm.png

echo "Converting to icns"
mkdir -p /tmp/wezterm-icns
sips -s format icns -z 512 512 /tmp/wezterm.png -o /tmp/wezterm-icns/wezterm.icns
rm /tmp/wezterm.png

echo "Installing new icon"
mv /tmp/wezterm-icns/wezterm.icns "$icon_path"
rm -rf ./tmp/wezterm-icns

touch /Applications/WezTerm.app
killall Finder
killall Dock
