# CONFIG
## Use Starship
starship init fish | source

## Use Thefuck
eval $(thefuck --alias)

# PATH
## Add rust to PATH
set PATH /Users/ben/.cargo/bin $PATH .

## Add git to PATH
set PATH /usr/local/git/bin $PATH .
set PATH /usr/local/opt/make/libexec/gnubin $PATH .

## Add python modules to PATH
set PATH /Users/ben/Library/Python/2.7/bin/ $PATH .

## Setup poetry
set PATH /Users/ben/.poetry/bin $PATH .

# ALIASES

source /Users/ben/.aliases

## Time Machine
function tmignore
    command find /Users/ben/Documents/Dev -maxdepth 8 -type d -name 'node_modules' | grep -v 'node_modules/' | xargs -n 1 tmutil addexclusion
end

function tmshow
    command mdfind "com_apple_backup_excludeItem = 'com.apple.backupd'"
end

