#!/usr/bin/env bash

# This script is derived from @mathiasbynens
# ~/.osx — http://mths.be/osx

# Set dotfile root
SCRIPT_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
DOTFILE_ROOT=$(realpath "$SCRIPT_ROOT/../")

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Set languages
defaults write NSGlobalDomain AppleLanguages -array "en" "de"
defaults write NSGlobalDomain AppleLocale -string "de_DE@currency=EUR"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Hide desktop icons
defaults write com.apple.finder CreateDesktop false

###############################################################################
# Keyboard                                                                    #
###############################################################################

# Make sure keyboard repeat is disabled (required for vim mode in IntelliJ)
# See: https://stackoverflow.com/a/78219050
defaults write -g ApplePressAndHoldEnabled -bool false

# Set keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable smart quotes and dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

###############################################################################
# Dock, Dashboard, Hot Corners and Menubar                                    #
###############################################################################

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Enable magnification
defaults write com.apple.dock magnification -bool true

# Set the icon size of Dock items to 64 pixels
defaults write com.apple.dock tilesize -int 64

# Set the icon size of magnified Dock items to 80 pixels
defaults write com.apple.dock largesize -int 80

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Hot Corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# 13: Lock Screen

# Top right screen corner → Mission Control
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0

# Position menubar icons more densely
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 10
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 10

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Enable narrow tabs
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari EnableNarrowTabs -bool true

# Set homepage
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari HomePage -string ""

# Set new tab behavior
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari NewTabBehavior -int 0

# Display preferences
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari ShowFavoritesBar -bool false
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari "ShowFavoritesBar-v2" -bool true
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari ShowFrequentlyVisitedSites -bool false

# Enable the Develop menu and the Web Inspector in Safari
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# Disable AutoFill
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoFillFromAddressBook -bool false
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoFillPasswords -bool false
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoFillCreditCardData -bool false
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Enable “Do Not Track”
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write ~/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show sidebar
defaults write com.apple.finder ShowSidebar -bool true

# Show path bar
defaults write com.apple.finder "ShowPathbar" -bool "true"

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

###############################################################################
# TextEdit                                                                    #
###############################################################################

# Set default file format to txt
defaults write com.apple.TextEdit "RichText" -bool "false"

###############################################################################
# Mail                                                                        #
###############################################################################

# Copy email addresses as `foo@example.com` instead of `Foo Bar <foo@example.com>` in Mail.app
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

# Disable automatic spell checking
defaults write com.apple.mail SpellCheckingBehavior -string "NoSpellCheckingEnabled"

# Mark all messages as read when opening a conversation
defaults write com.apple.mail ConversationViewMarkAllAsRead -bool true

###############################################################################
# Time Machine                                                                #
###############################################################################

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Calendar                                                                    #
###############################################################################

# Show week numbers
defaults write com.apple.iCal "Show Week Numbers" -bool true

# Week starts on Monday
defaults write com.apple.iCal "first day of week" -int 2

# Show 15 hours in week view
defaults write com.apple.iCal "number of hours displayed" -int 15

# Day starts at 9:00
defaults write com.apple.iCal "first minute of work hours" -int 540

# Day ends at 18:00
defaults write com.apple.iCal "last minute of work hours" -int 1080

###############################################################################
# Raycast                                                                     #
###############################################################################

# Set emoji picker skin tone to default
defaults write com.raycast.macos "emojiPicker_skinTone" -string "default"

# Set onboarding completed
defaults write com.raycast.macos onboardingCompleted -bool true

# Hide getting started
defaults write com.raycast.macos showGettingStartedLink -bool false

# Set global hotkey to Command-Space
defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"

# Set pop to root timeout to "Immediately"
defaults write com.raycast.macos popToRootTimeout -int 0

###############################################################################
# Anybox                                                                      #
###############################################################################

# Hide menubar icon
defaults write cc.anybox.Anybox showMenuBarIcon -int 0

# Hide dock icon
defaults write cc.anybox.Anybox showDockIcon -int 0

# Warn before quitting
defaults write cc.anybox.Anybox warnBeforeQuiting -int 1

###############################################################################
# Ice                                                                         #
###############################################################################

defaults write com.jordanbaird.Ice AutoRehide -int 1
defaults write com.jordanbaird.Ice ShowIceIcon -int 1
defaults write com.jordanbaird.Ice ShowOnClick -int 1
defaults write com.jordanbaird.Ice ShowOnHover -int 0
defaults write com.jordanbaird.Ice ShowOnScroll -int 0
defaults write com.jordanbaird.Ice UseIceBar -int 0

###############################################################################
# Leader-Key                                                                  #
###############################################################################

defaults write com.brnbw.Leader-Key alwaysShowCheatsheet -int 1
defaults write com.brnbw.Leader-Key showInMenubar -int 1

# Set config directory
defaults write com.brnbw.Leader-Key configDir -string "~/Documents/Dev/dotfiles/leader-key"

# Set global hotkey to F12
defaults write com.brnbw.Leader-Key "KeyboardShortcuts_activate" -string "{\\"carbonKeyCode\\":111,\\"carbonModifiers\\":0}"

###############################################################################
# Velja                                                                       #
###############################################################################

defaults write com.sindresorhus.Velja showLastOpenedLink -int 0
defaults write com.sindresorhus.Velja hideMenuBarIcon -int 1

# Set default browser
defaults write com.sindresorhus.Velja defaultBrowser -string "com.sindresorhus.Velja.promptMarker"
defaults write com.sindresorhus.Velja alternativeBrowser -string "com.apple.Safari"

# Set apps
defaults write com.sindresorhus.Velja spotifyApp -string "com.spotify.client"
defaults write com.sindresorhus.Velja linearApp -string "com.linear"
defaults write com.sindresorhus.Velja notionApp -string "notion.id"
defaults write com.sindresorhus.Velja figmaApp -string "com.figma.Desktop"

# Set rules
defaults write com.sindresorhus.Velja rules -array
for rule in "$DOTFILE_ROOT/velja/rules/"*.json; do
    defaults write com.sindresorhus.Velja rules -array-add "$(jq -c < "$rule" | jq -R -s)"
done
