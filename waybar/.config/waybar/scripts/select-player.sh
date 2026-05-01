#!/usr/bin/env bash
#
# select-player.sh - Show rofi menu to select which media player to control
# Stores selection in ~/.cache/selected_player for other scripts to use
#

PLAYER_STATE_FILE="$HOME/.cache/selected_player"

# Get list of active players
PLAYERS=$(playerctl -l 2>/dev/null)

if [[ -z "$PLAYERS" ]]; then
    notify-send "No active players" "No media players are currently playing"
    exit 0
fi

# Get current selected player
CURRENT_PLAYER=$(cat "$PLAYER_STATE_FILE" 2>/dev/null || echo "auto")

# Format players for rofi menu
MENU_ITEMS=""
while IFS= read -r player; do
    if [[ "$player" == "$CURRENT_PLAYER" ]]; then
        MENU_ITEMS+="✓ $player\n"
    else
        MENU_ITEMS+="  $player\n"
    fi
done <<< "$PLAYERS"

# Add "Auto (all players)" option
if [[ "$CURRENT_PLAYER" == "auto" ]]; then
    MENU_ITEMS="✓ Auto (all players)\n$MENU_ITEMS"
else
    MENU_ITEMS="  Auto (all players)\n$MENU_ITEMS"
fi

# Show rofi menu
SELECTED=$(echo -e "$MENU_ITEMS" | rofi -dmenu -i -p "Select Player" -width 30 -lines 5 -fuzzy \
    -theme-str 'window { width: 300px; }' \
    -theme-str 'listview { lines: 5; }' \
    2>/dev/null)

if [[ -z "$SELECTED" ]]; then
    exit 0
fi

# Clean up selection (remove checkmark and leading spaces)
SELECTED=$(echo "$SELECTED" | sed 's/^[✓ ]* //')

# Save selection
if [[ "$SELECTED" == "Auto (all players)" ]]; then
    echo "auto" > "$PLAYER_STATE_FILE"
    notify-send "Player selected" "Controlling all players"
else
    echo "$SELECTED" > "$PLAYER_STATE_FILE"
    notify-send "Player selected" "Controlling: $SELECTED"
fi
