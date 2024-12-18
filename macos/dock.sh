#!/bin/sh

dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Mail.app"
dockutil --no-restart --add "/Applications/Notes.app"
dockutil --no-restart --add "/Applications/Obsidian.app"
dockutil --no-restart --add "/Applications/WezTerm.app"
dockutil --no-restart --add "/Applications/Figma.app"
dockutil --no-restart --add "/Applications/Spotify.app"
dockutil --no-restart --add "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
dockutil --no-restart --add "/Applications/Slack.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/Linear.app"
dockutil --no-restart --add "/Applications/Beeper.app"
dockutil --no-restart --add "/Applications/Anybox.app"
dockutil --no-restart --add "/Applications/Calendar.app"
dockutil --no-restart --add "/Applications/System Settings.app"

dockutil --no-restart --add ~/Desktop
dockutil --no-restart --add ~/Downloads

killall Dock

echo "Success! Dock is set."
