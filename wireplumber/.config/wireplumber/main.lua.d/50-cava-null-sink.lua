-- Automatically create a null sink for cava and link the default sink to it.
-- Uses pw-link (PipeWire graph-level linking) which does NOT trigger
-- Bluetooth HFP profile switching, unlike module-loopback or capture streams.

-- Create the null sink via pactl
os.execute([[
    pactl load-module module-null-sink \
        sink_name=cava_sink \
        sink_properties=device.description=Cava_Audio_Monitor \
        format=s24-32le rate=48000 channels=2 2>/dev/null || true
]])

-- Link the default sink's monitor to the null sink
os.execute([[
    DEFAULT_SINK=$(pactl info 2>/dev/null | grep 'Default Sink' | awk '{print $3}')
    if [ -n "$DEFAULT_SINK" ]; then
        pw-link "${DEFAULT_SINK}.monitor" "cava_sink" 2>/dev/null || true
    fi
]])
