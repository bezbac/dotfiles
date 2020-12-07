#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Superchat Environment
# @raycast.mode silent
# @raycast.packageName Environment

# Optional parameters:
# @raycast.icon 🚀

tell application "iTerm"
    activate
    set hasNoWindows to ((count of windows) is 0)
    if hasNoWindows then
        create window with default profile
    end if
    select first window

    tell the first window
        if hasNoWindows is false then
            create tab with default profile
        end if

        tell current session
            write text "cd ~/Documents/Dev/superchat/sc-platform"
            write text "code ."

            split vertically with same profile
            split vertically with same profile
        end tell
        
        tell second session of current tab
            write text "cd ~/Documents/Dev/superchat/sc-platform/conversation-service"
            split horizontally with same profile
        end tell

        tell fourth session of current tab
            write text "cd ~/Documents/Dev/superchat/sc-platform/webapp"
            split horizontally with same profile
        end tell

        tell fourth session of current tab
            write text "cd ~/Documents/Dev/superchat/sc-platform/conversation-service"
        end tell

        tell fifth session of current tab
            write text "cd ~/Documents/Dev/superchat/sc-platform/webapp"
        end tell
    end tell
end tell