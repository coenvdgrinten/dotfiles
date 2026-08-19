#!/usr/bin/env bash
#
# scratchpad.sh - Toggle a persistent scratchpad terminal
# Uses Hyprland's special workspace feature
#

set -euo pipefail

SCRATCHPAD_WS="scratchpad"
SPECIAL_NAME="special:scratchpad"
TERM="kitty"  # Change to your preferred terminal

# Address of the first window living on the special workspace (empty if none).
scratchpad_addr() {
    hyprctl clients -j 2>/dev/null \
        | jq -r --arg ws "$SPECIAL_NAME" '.[] | select(.workspace.name == $ws) | .address' \
        | head -n1 || true
}

# True if the special workspace is currently shown on any monitor.
is_visible() {
    hyprctl monitors -j 2>/dev/null \
        | jq -e --arg ws "$SPECIAL_NAME" '.[] | .specialWorkspace | select(.name == $ws)' \
        > /dev/null 2>&1 || true
}

addr="$(scratchpad_addr)"

if [[ -z "$addr" ]]; then
    # No terminal yet: open one directly on the special workspace, then focus it.
    hyprctl dispatch togglespecialworkspace "$SCRATCHPAD_WS"
    hyprctl dispatch exec "[workspace special:scratchpad] $TERM --class scratchpad-term"
    # Wait for the window to map (up to ~3s).
    for _ in $(seq 1 60); do
        addr="$(scratchpad_addr)"
        if [[ -n "$addr" ]]; then break; fi
        sleep 0.05
    done
    # Explicitly take focus — follow_mouse=1 would otherwise leave it on the
    # window under the cursor until the mouse moves.
    if [[ -n "$addr" ]]; then
        hyprctl dispatch focuswindow "address:$addr" || true
    fi
else
    # Terminal already exists: toggle its visibility.
    if is_visible; then
        # Shown -> hide it.
        hyprctl dispatch togglespecialworkspace "$SCRATCHPAD_WS"
    else
        # Hidden -> show it and give it focus.
        hyprctl dispatch togglespecialworkspace "$SCRATCHPAD_WS"
        hyprctl dispatch focuswindow "address:$addr" || true
    fi
fi
