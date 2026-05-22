#!/usr/bin/env bash
# WaybarCava.sh - safer single-instance handling, cleanup, and robustness
# Original concept by JaKooLit; this variant focuses on lifecycle hardening.

set -uo pipefail

# Ensure cava exists
if ! command -v cava >/dev/null 2>&1; then
  echo "cava not found in PATH" >&2
  exit 1
fi

# 0..7 -> block glyphs
bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
bar_length=${#bar}
for ((i = 0; i < bar_length; i++)); do
  dict+=";s/$i/${bar:$i:1}/g"
done

# Single-instance guard - kill ALL stale cava instances from previous waybar runs
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp}"
pidfile="$RUNTIME_DIR/waybar-cava.pid"
if [[ -f "$pidfile" ]]; then
  oldpid="$(cat "$pidfile" 2>/dev/null || true)"
  if [[ -n "$oldpid" ]] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" 2>/dev/null || true
    sleep 0.1 || true
  fi
fi
# Also kill any orphaned cava processes from this script
pkill -f "cava.*waybar-cava\." 2>/dev/null || true
sleep 0.2 || true

printf '%d' $$ >"$pidfile"

# Unique temp config + cleanup on exit
config_file="$(mktemp "$RUNTIME_DIR/waybar-cava.XXXXXX.conf")"
cleanup() {
  rm -f "$config_file" "$pidfile"
  if [[ -n "${CAVA_PID:-}" ]] && kill -0 "$CAVA_PID" 2>/dev/null; then
    kill "$CAVA_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT INT TERM

# Detect available audio source (PipeWire/Pulse)
AUDIO_SOURCE=""
if command -v pactl >/dev/null 2>&1; then
  AUDIO_SOURCE=$(pactl list short sources 2>/dev/null | grep '\.monitor$' | head -1 | awk '{print $2}')
fi

# Fallback: try default source
if [[ -z "$AUDIO_SOURCE" ]]; then
  AUDIO_SOURCE="@DEFAULT_SOURCE@.monitor"
fi

cat >"$config_file" <<EOF
[general]
framerate = 30
bars = 10

[input]
method = pulse
source = ${AUDIO_SOURCE}

[output]
method = raw
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
EOF

# Stream cava output and translate digits 0..7 to bar glyphs
cava -p "$config_file" 2>/dev/null | sed -u "$dict" &
CAVA_PID=$!
wait "$CAVA_PID" 2>/dev/null || true
