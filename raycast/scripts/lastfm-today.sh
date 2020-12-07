#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title LastFM Today's Scrobbles
# @raycast.mode inline
# @raycast.packageName LastFM

# Optional parameters:
# @raycast.icon 🌐

date=$(date '+%Y-%m-%d')
curl -s https://www.last.fm/de/user/BitmasterBen/library\?from\=$date\&rangetype\=1day\ | pup '#mantle_skin > div:nth-child(3) > div > div.col-main > ul > li > p text{}'
