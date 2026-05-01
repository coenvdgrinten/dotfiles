#!/usr/bin/env bash
#
# pixel-buds-a2dp.sh - Force Pixel Buds to high-quality A2DP (stereo) profile
#
# Usage:
#   pixel-buds-a2dp.sh          # Switch to A2DP (high-quality audio)
#   pixel-buds-a2dp.sh hfp      # Switch to HFP (hands-free, enables mic)
#   pixel-buds-a2dp.sh status   # Show current profile
#

set -euo pipefail

MAC="10:D9:A2:4C:12:8F"
DEVICE_NAME="Pixel Buds Pro 2"

get_device_id() {
    # Get the WirePlumber device ID for the Pixel Buds
    # Look for the device in the Devices section (has [bluez5] marker)
    wpctl status 2>/dev/null | grep "$DEVICE_NAME" | grep "\[bluez5\]" | grep -oP '\d+(?=\.)' | head -1
}

get_current_profile() {
    # Check the actual sink format to determine the real profile
    # A2DP sink has ".1" suffix and 2ch stereo, HFP has ".0" suffix and MONO
    SINK_INFO=$(pactl list sinks short 2>/dev/null | grep "bluez_output.${MAC//:/_}" | head -1)
    if [[ -z "$SINK_INFO" ]]; then
        echo "disconnected"
        return
    fi
    if echo "$SINK_INFO" | grep -q "\.1"; then
        echo "a2dp (stereo)"
    else
        echo "hfp (mono/hands-free)"
    fi
}

switch_profile() {
    local target="$1"
    DEVICE_ID=$(get_device_id)
    if [[ -z "$DEVICE_ID" ]]; then
        echo "Error: $DEVICE_NAME is not connected."
        exit 1
    fi

    # If wpctl set-profile doesn't work (profile shows "off"), do a reconnect
    wpctl set-profile "$DEVICE_ID" "$target" 2>/dev/null
    sleep 1

    # Verify the switch worked
    CURRENT=$(get_current_profile)
    if [[ "$target" == "a2dp_sink" && ! "$CURRENT" == *"a2dp"* ]]; then
        echo "Profile switch didn't take effect. Reconnecting Bluetooth..."
        echo "disconnect $MAC" | bluetoothctl 2>/dev/null
        sleep 2
        echo "connect $MAC" | bluetoothctl 2>/dev/null
        sleep 3
    fi
}

case "${1:-a2dp}" in
    a2dp)
        echo "Switching $DEVICE_NAME to A2DP (high-quality stereo)..."
        switch_profile "a2dp_sink"
        echo "Done! Audio is now high-quality stereo."
        echo "Note: Microphone will use your laptop's built-in mic."
        ;;
    hfp)
        echo "Switching $DEVICE_NAME to HFP (hands-free with mic)..."
        switch_profile "headset_head_unit"
        echo "Done! Microphone is now using $DEVICE_NAME."
        echo "Note: Audio quality is reduced (mono) while mic is active."
        ;;
    status)
        PROFILE=$(get_current_profile)
        if [[ "$PROFILE" == "disconnected" ]]; then
            echo "$DEVICE_NAME is not connected."
            exit 1
        fi
        echo "$DEVICE_NAME profile: $PROFILE"
        ;;
    *)
        echo "Usage: $0 [a2dp|hfp|status]"
        exit 1
        ;;
esac
