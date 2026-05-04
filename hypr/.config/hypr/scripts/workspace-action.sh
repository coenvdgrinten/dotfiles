#!/bin/bash
# Switch to workspace WS on the focused monitor.
# If the workspace lives on a different monitor, pull it here first.
WS=$1

CURRENT_MON=$(hyprctl activeworkspace -j | jq -r '.monitor')
WS_MON=$(hyprctl workspaces -j | jq -r --arg ws "$WS" '.[] | select(.name == $ws) | .monitor')

if [ -n "$WS_MON" ] && [ "$WS_MON" != "$CURRENT_MON" ]; then
    hyprctl dispatch moveworkspacetomonitor "$WS" current
fi

hyprctl dispatch workspace "$WS"
