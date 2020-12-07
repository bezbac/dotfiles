#!/bin/sh

export $(grep -v '^#' ~/Documents/Dev/dotfiles/secrets/backup.env | xargs)

restic backup $BACKUP_FOLDER