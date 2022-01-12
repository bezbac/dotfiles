#!/usr/bin/osascript

# Raycast Script Command Template
#
# Duplicate this file and remove ".template." from the filename to get started.
# See full documentation here: https://github.com/raycast/script-commands
#
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Zotpick
# @raycast.mode fullOutput
# @raycast.packageName Raycast Scripts
#
# Optional parameters:
# @raycast.icon 📚
# @raycast.currentDirectoryPath ~
# @raycast.needsConfirmation false

tell application "System Events"
	try
		set appName to (the name of every process whose frontmost is true) as string
	on error errMsg
		display alert "Problem" message "Could not get the name of the frontmost application."
		error number -128
	end try
end tell
set zotRunning to do shell script "/usr/bin/curl 'http://localhost:23119/better-bibtex/cayw?probe=probe' 2>/dev/null; exit 0"
if zotRunning is "" then
	display alert "Zotero not running" message "This script will not work unless Zotero is running. Please launch Zotero and try again"
	tell application appName
		activate
	end tell
	error number -128
else if zotRunning is "No endpoint found" then
	display alert "Better BibTeX not installed" message "This script will not work unless Better BibTeX is installed. Please make sure that Better BibTeX is installed in the running instance of Zotero"
	tell application appName
		activate
	end tell
	error number -128
else if zotRunning is "ready" then
	set theReference to do shell script "/usr/bin/curl 'http://localhost:23119/better-bibtex/cayw?format=pandoc' 2>/dev/null; exit 0"
	try
		repeat until application appName is frontmost
			tell application appName to activate
		end repeat
	on error errMsg
		display alert errMsg
	end try
	tell application "System Events"
		try
			keystroke theReference
		on error errMsg
			display alert errMsg
		end try
	end tell
end if
