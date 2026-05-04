#!/usr/bin/env bash
# pixel-buds-a2dp-enforce.sh - Watch for Pixel Buds connection and force A2DP profile.
#
# BlueZ negotiates HFP during connection before WirePlumber rules take effect.
# This script watches for the device appearing in PipeWire and switches to A2DP.
#
# Run via Hyprland autostart (exec-once in Startup_Apps.conf).

set -euo pipefail

MAC="10:D9:A2:4C:12:8F"
DEVICE_NAME="Pixel Buds Pro 2"
A2DP_PROFILE="a2dp_sink"

echo "[pixel-buds-enforce] Starting watcher for $DEVICE_NAME"

switch_to_a2dp() {
    # Get the WirePlumber device ID for the Pixel Buds (from Devices section)
    DEVICE_ID=$(wpctl status 2>/dev/null | awk '/Devices:/,/Sinks:/' | grep "$DEVICE_NAME" | grep -oP '\d+(?=\.)' | head -1 || true)
    
    if [[ -z "$DEVICE_ID" ]]; then
        echo "[pixel-buds-enforce] Could not find device ID for $DEVICE_NAME"
        return 1
    fi
    
    # Try wpctl set-profile (may disconnect the device)
    wpctl set-profile "$DEVICE_ID" "$A2DP_PROFILE" 2>/dev/null || true
    sleep 2
    
    # If the device disconnected, reconnect
    if ! pactl list sinks short 2>/dev/null | grep -q "bluez_output.${MAC//:/_}"; then
        echo "[pixel-buds-enforce] Device disconnected after profile switch, reconnecting..."
        echo "disconnect $MAC" | bluetoothctl 2>/dev/null || true
        sleep 2
        echo "connect $MAC" | bluetoothctl 2>/dev/null || true
        sleep 5
    fi
    
    # Verify the switch worked
    CURRENT_PROFILE=$(pactl list sinks 2>/dev/null | grep "api.bluez5.profile" | head -1 | awk -F'"' '{print $2}' || true)
    if [[ "$CURRENT_PROFILE" == "a2dp-sink" ]]; then
        echo "[pixel-buds-enforce] Successfully switched to A2DP"
        return 0
    else
        echo "[pixel-buds-enforce] Profile is still ${CURRENT_PROFILE:-unknown}"
        return 1
    fi
}

while true; do
    # Check if the device has an active sink
    if pactl list sinks short 2>/dev/null | grep -q "bluez_output.${MAC//:/_}"; then
        CURRENT_PROFILE=$(pactl list sinks 2>/dev/null | grep "api.bluez5.profile" | head -1 | awk -F'"' '{print $2}' || true)
        
        if [[ "$CURRENT_PROFILE" != "a2dp-sink" ]]; then
            echo "[pixel-buds-enforce] HFP detected (${CURRENT_PROFILE}), attempting A2DP switch..."
            switch_to_a2dp || true
        fi
    fi
    
    # Check every 10 seconds
    sleep 10
done
