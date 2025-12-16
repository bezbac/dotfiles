#!/bin/zsh

# If there are not exactly two windows, exit
if [ $(aerospace list-windows --workspace focused --count) -ne 2 ]; then
    exit 0
fi

MONITOR_DATA=$(system_profiler SPDisplaysDataType -json)
MONITOR_NAME=$(aerospace list-monitors --focused --format '%{monitor-name}')

# Check if there are multiple monitors connected
NUM_MONITORS=$(echo $MONITOR_DATA | jq '.[][0]["spdisplays_ndrvs"] | length')

if [ "$NUM_MONITORS" -gt 1 ]; then
    MONITOR_RESOLUTION_STR=$(echo $MONITOR_DATA | jq -r '.[][0]["spdisplays_ndrvs"] | .[] | select(._name == "'$MONITOR_NAME'") | ._spdisplays_resolution')
else
    MONITOR_RESOLUTION_STR=$(echo $MONITOR_DATA | jq -r '.[][0]["spdisplays_ndrvs"] | .[] | ._spdisplays_resolution')
fi

MONITOR_RESOLUTION=$(echo $MONITOR_RESOLUTION_STR | grep -oE '[0-9]+ x [0-9]+' | head -n 1 | tr -d ' ')
MONITOR_WIDTH=$(echo $MONITOR_RESOLUTION | cut -d'x' -f1)
MONITOR_HEIGHT=$(echo $MONITOR_RESOLUTION | cut -d'x' -f2)

# 1/3 2/3 split
# DESIRED_WINDOW_WIDTH=$((MONITOR_WIDTH / 3 * 1))

# 50/50 split
DESIRED_WINDOW_WIDTH=$((MONITOR_WIDTH / 2))

aerospace layout h_tiles
aerospace focus --dfs-index 0
aerospace resize width $DESIRED_WINDOW_WIDTH
