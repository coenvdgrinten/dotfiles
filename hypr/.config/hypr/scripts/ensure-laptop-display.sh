#!/usr/bin/env bash
#
# ensure-laptop-display.sh
#
# Runs once at Hyprland startup to recover from the "black screen after
# external monitor session" scenario:
#
#   1. Last session: external monitor active, eDP-1 disabled via nwg-displays
#      or hyprctl keyword (e.g. monitor=eDP-1,disable written to monitors.conf).
#   2. Next boot: external monitor unplugged → Hyprland has zero active outputs
#      → black screen.
#
# This script detects that state and re-enables the laptop panel.
#

# Wait for Hyprland to finish initializing outputs
sleep 2

# Check if the internal laptop panel (eDP-1) is physically present
edp_status=$(cat /sys/class/drm/card*-eDP-1/status 2>/dev/null | head -1)
if [[ "$edp_status" != "connected" ]]; then
    # No eDP-1 connector — not a laptop or unusual setup; nothing to do
    exit 0
fi

# Count how many monitors Hyprland currently considers active
active_count=$(hyprctl monitors -j 2>/dev/null | jq 'length' 2>/dev/null || echo 0)

if [[ "$active_count" -eq 0 ]]; then
    # eDP-1 is physically present but Hyprland has no active outputs.
    # Re-enable the laptop panel.
    hyprctl keyword monitor "eDP-1,preferred,auto,1"
    notify-send "Display Recovery" \
        "Laptop screen was disabled — re-enabled eDP-1" \
        --urgency=normal 2>/dev/null || true
fi
