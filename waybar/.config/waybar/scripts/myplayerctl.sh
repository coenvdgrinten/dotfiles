#!/usr/bin/env bash
#
# myplayerctl.sh - Wrapper around playerctl that respects selected player
# Usage: myplayerctl.sh [playerctl arguments...]
#
# If ~/.cache/selected_player exists and contains a player name,
# commands are sent to that player only. Otherwise, -a (all) is used.
#

PLAYER_STATE_FILE="$HOME/.cache/selected_player"
SELECTED_PLAYER=$(cat "$PLAYER_STATE_FILE" 2>/dev/null || echo "auto")

# Build playerctl command
if [[ "$SELECTED_PLAYER" != "auto" && -n "$SELECTED_PLAYER" ]]; then
    exec playerctl --player="$SELECTED_PLAYER" "$@"
else
    exec playerctl -a "$@"
fi
