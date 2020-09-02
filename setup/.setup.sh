#!/bin/bash
BASE_DIR=${BASH_SOURCE%/*}

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

DOTFILE_ROOT="$(basename "$(dirname "$BASE_DIR")")"
DOTFILE_ROOT="$(realpath $DOTFILE_ROOT)"
DOTFILE_ROOT="${DOTFILE_ROOT/\/./}"
DOTFILE_ROOT="${DOTFILE_ROOT/\/setup/}"

if [ $# -eq 0 ]
  then
    echo "Please list all parts you want to install (eg. .setup.sh rust python)"
    echo "Here's a list of all avaliable scripts:"

    for FILENAME in "$BASE_DIR"/*.sh
    do
    FILENAME=${FILENAME/"$BASE_DIR"/} # Remove base path
    FILENAME=${FILENAME/".sh"/} # Remove extension
    FILENAME=${FILENAME#/} # Remove leading slash
    echo "- $FILENAME"
    done
fi

function require {
  for REQUIRED_APPLICATION in "$@"
  do
  echo "--> $REQUIRED_APPLICATION was required as a subscript"
  source "$BASE_DIR/$REQUIRED_APPLICATION.sh"
  done
}

echo "Dotfile directory: $DOTFILE_ROOT"

for APPLICATION in "$@"
do
echo "> Setting up $APPLLICATION"
source "$BASE_DIR/$APPLICATION.sh"
done