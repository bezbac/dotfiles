#!/bin/sh

array=(
    "commands/media/spotify/images/spotify-logo.png"
    "commands/media/spotify/spotify-next-track.applescript"
    "commands/media/spotify/spotify-previous-track.applescript"
    "commands/media/spotify/spotify-play-pause.applescript"
    "commands/media/spotify/spotify-now-playing-url.applescript"

    "commands/developer-utils/ping.sh"

    "commands/navigation/open-desktop.sh"
    "commands/navigation/open-documents.sh"
    "commands/navigation/open-home.sh"
    "commands/navigation/open-home.sh"

    "commands/dashboard/system-activity.sh"

    "commands/web-searches/npmjs.sh"
    "commands/web-searches/images/npmjs.png"

    "commands/conversions/hex-to-rgba.sh"
    "commands/conversions/hex-to-rgb.sh"

    "commands/system/sample-colour.swift"
)
for i in "${array[@]}"
do
    dlpath="$i"

    prefixes=(
        "commands/media/spotify/"
        "commands/developer-utils/"
        "commands/navigation/"
        "commands/dashboard/"
        "commands/web-searches/"
        "commands/conversions/"
        "commands/system/"
    )

    for prefix in "${prefixes[@]}"
    do
        dlpath="${dlpath#$prefix}"
    done

    dlpath="scripts/remote/$dlpath"

	echo "Downloading $i to $dlpath"
    
    curl --create-dirs https://raw.githubusercontent.com/raycast/script-commands/master/$i --output $dlpath
    chmod +x $dlpath
done

echo 'remote/' > scripts/.gitignore
