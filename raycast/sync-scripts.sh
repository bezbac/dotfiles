#!/bin/sh

array=(
    "commands/developer-utils/ping.sh"

    "commands/system/sample-colour.swift"
)
for i in "${array[@]}"
do
    dlpath="$i"

    prefixes=(
        "commands/developer-utils/"
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
