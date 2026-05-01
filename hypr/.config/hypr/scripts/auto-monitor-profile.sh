#!/usr/bin/env bash
#
# auto-monitor-profile.sh - Automatically detect and apply monitor profiles
# Runs on monitor connect/disconnect events
#

set -euo pipefail

SCRIPTS_DIR="$HOME/.config/hypr/scripts"
PROFILE_DIR="$HOME/.config/hypr/Monitor_Profiles"

# Get current monitor layout
get_monitor_layout() {
    hyprctl monitors -j 2>/dev/null | jq -r '.[].name' | sort | tr '\n' ',' | sed 's/,$//'
}

# Detect if laptop is docked (external monitor connected)
is_docked() {
    local monitors=$(get_monitor_layout)
    # If we have more than one monitor, assume docked
    [[ $(echo "$monitors" | tr ',' '\n' | wc -l) -gt 1 ]]
}

# Apply docked profile
apply_docked_profile() {
    echo "Docked profile detected - applying external monitor layout"

    # Example: Set external monitor as primary, disable laptop screen
    # Customize these commands based on your monitor setup
    hyprctl keyword "monitor=,prefer,auto,auto" 2>/dev/null
    hyprctl keyword "monitor=eDP-1,disable" 2>/dev/null  # Disable laptop screen
    hyprctl keyword "monitor=DP-1,1920x1080@144,0x0,1.5" 2>/dev/null  # External monitor

    notify-send "Monitor Profile" "Docked profile applied"
}

# Apply undocked profile (laptop only)
apply_undocked_profile() {
    echo "Undocked profile detected - applying laptop layout"

    # Enable laptop screen, disable external monitors
    hyprctl keyword "monitor=eDP-1,prefer,auto,auto" 2>/dev/null  # Laptop screen
    hyprctl keyword "monitor=DP-1,disable" 2>/dev/null  # Disable external
    hyprctl keyword "monitor=HDMI-A-1,disable" 2>/dev/null  # Disable HDMI

    notify-send "Monitor Profile" "Undocked profile applied"
}

# Main logic
if is_docked; then
    apply_docked_profile
else
    apply_undocked_profile
fi
