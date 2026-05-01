#!/usr/bin/env bash
#
# rofi-window-switcher.sh - Window switcher with thumbnails using rofi
#

set -euo pipefail

# Get list of windows with their titles and classes
WINDOWS=$(hyprctl clients -j | jq -r '.[] | select(.mapped == true) | "\(.workspace.name) | \(.class) | \(.title)"')

if [[ -z "$WINDOWS" ]]; then
    notify-send "Window Switcher" "No windows found"
    exit 0
fi

# Format for rofi
FORMATTED=$(echo "$WINDOWS" | while IFS='|' read -r ws class title; do
    # Trim whitespace
    ws=$(echo "$ws" | xargs)
    class=$(echo "$class" | xargs)
    title=$(echo "$title" | xargs)
    
    # Skip empty or special workspaces
    [[ -z "$title" || "$ws" == *"special"* ]] && continue
    
    echo "WS $ws: $title ($class)"
done)

# Show rofi menu
SELECTED=$(echo "$FORMATTED" | rofi -dmenu -i -p "Switch Window" -width 60 -lines 8 -fuzzy \
    -theme-str 'window { width: 600px; }' \
    -theme-str 'listview { lines: 8; }' \
    2>/dev/null)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# Extract window title from selection
WINDOW_TITLE=$(echo "$SELECTED" | sed 's/WS [0-9]*: //' | sed 's/ ([^)]*)$//')

# Focus the window by title
hyprctl dispatch focuswindow "title:$WINDOW_TITLE" 2>/dev/null
