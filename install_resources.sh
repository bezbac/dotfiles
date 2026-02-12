#!/bin/bash

# Set dotfile root to directory of this script
DOTFILE_ROOT=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Download https://youtu.be/YD2aq2MbboE into $DOTFILE_ROOT/resources/adjutant.opus using yt-dlp.
mkdir -p "$DOTFILE_ROOT/resources"
if [ ! -f "$DOTFILE_ROOT/resources/adjutant.opus" ]; then
  uvx yt-dlp -x https://youtu.be/YD2aq2MbboE -o "$DOTFILE_ROOT/resources/adjutant"
else
  echo "adjutant.opus already exists; skipping download."
fi

# Split the opus files into following segments:
# 0:00 - 0:02 ("not enough minerals")
# 0:18 - 0:20 ("research complete")

ffmpeg -y -i "$DOTFILE_ROOT/resources/adjutant.opus" -ss 00:00:00 -to 00:00:01.900 -c:a pcm_s16le "$DOTFILE_ROOT/resources/adjutant_insufficient_minerals.wav"
ffmpeg -y -i "$DOTFILE_ROOT/resources/adjutant.opus" -ss 00:00:18.500 -to 00:00:20.100 -c:a pcm_s16le "$DOTFILE_ROOT/resources/adjutant_research_complete.wav"
