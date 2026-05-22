#!/usr/bin/env bash
# Force laptop to use only the internal display (eDP-1)
# Useful when undocking from multi-monitor setup results in a black screen.
# Also runs on startup to detect if no external monitors are connected.
#
# Reads monitors.conf to discover configured external monitors, so it stays
# in sync with whatever nwg-displays generates.

MONITORS_CONF="$HOME/.config/hypr/monitors.conf"

# Get list of connected monitors from Hyprland
connected_monitors=$(hyprctl monitors -j 2>/dev/null)

# Check if any external monitor (non-eDP, non-virtual) is actually connected
has_external=$(echo "$connected_monitors" | grep -oP '"name":"[^"]*"' | grep -iv "eDP" | grep -iv "virtual" | head -1)

if [ -z "$has_external" ]; then
    # No external monitors detected — enable laptop display only
    hyprctl keyword monitor "eDP-1, preferred, auto, 1"

    # Discover all external monitors referenced in monitors.conf and disable them.
    # This keeps the script in sync with whatever nwg-displays generates.
    if [ -f "$MONITORS_CONF" ]; then
        grep -oP '^\s*monitor\s*=\s*\K[^,]+' "$MONITORS_CONF" \
            | grep -iv "eDP" \
            | grep -iv "virtual" \
            | sort -u \
            | while read -r name; do
                hyprctl keyword "monitor=$name, disable" 2>/dev/null
            done
    fi

    notify-send -u critical "Display" "No external monitors detected — using laptop display only"
else
    # External monitors present — nothing to fix
    notify-send "Display" "External monitor(s) detected"
fi

# Move cursor to center of screen to help reinitialize
hyprctl cursor move center 0 2>/dev/null
