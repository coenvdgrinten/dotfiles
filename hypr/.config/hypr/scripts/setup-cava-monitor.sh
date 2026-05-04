#!/usr/bin/env bash
# setup-cava-monitor.sh - Create a null sink that mirrors the default audio output.
#
# When cava captures from a Bluetooth device's monitor source, BlueZ switches
# from A2DP (high-quality stereo) to HFP (mono hands-free). This script creates
# a null sink and uses pw-link to mirror the default sink at the PipeWire graph
# level — which does NOT trigger HFP profile switching (unlike module-loopback
# or any application opening a capture stream).

set -euo pipefail

# Load null sink (creates cava_sink with a .monitor source)
pactl load-module module-null-sink \
    sink_name=cava_sink \
    sink_properties=device.description="Cava_Audio_Monitor" \
    format=s24-32le \
    rate=48000 \
    channels=2 2>/dev/null || true

# Mirror the default sink output into the null sink via pw-link
# This operates at the PipeWire graph level (no capture stream = no HFP switch)
DEFAULT_SINK=$(pactl info 2>/dev/null | grep 'Default Sink' | awk '{print $3}')
if [[ -n "$DEFAULT_SINK" ]]; then
    pw-link "${DEFAULT_SINK}.monitor" "cava_sink" 2>/dev/null || true
    echo "Cava monitor ready: cava_sink.monitor (linked from ${DEFAULT_SINK})"
else
    echo "Warning: Could not determine default sink"
fi
