#!/usr/bin/env bash
#
# scratchpad.sh - Toggle a persistent scratchpad terminal
# Uses Hyprland's special workspace feature
#

set -euo pipefail

SCRATCHPAD_WS="scratchpad"
TERM="kitty"  # Change to your preferred terminal

# Check if scratchpad workspace exists and has a window
if hyprctl workspaces -j | jq -e ".[] | select(.id == -98) | select(.windows > 0)" > /dev/null 2>&1; then
    # Toggle visibility of scratchpad
    hyprctl dispatch togglespecialworkspace "$SCRATCHPAD_WS"
else
    # Create new scratchpad terminal
    hyprctl dispatch togglespecialworkspace "$SCRATCHPAD_WS"
    sleep 0.1
    $TERM --class scratchpad-term &
    hyprctl dispatch movetoworkspacespecial
fi
