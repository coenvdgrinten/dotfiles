#!/bin/sh

qtile_dir="$HOME/.config/qtile"
LOCK="/tmp/qtile-screen-setup.lock"

# Prevent re-entrant execution (xrandr changes fire screen_change hooks)
if [ -f "$LOCK" ]; then
    exit 0
fi
touch "$LOCK"
trap 'rm -f "$LOCK"' EXIT

# Detect office monitors on either DP-2-x or DP-3-x (dock port can vary)
xrandr_out=$(xrandr)
if echo "$xrandr_out" | grep -q "DP-2-1 connected" && \
   echo "$xrandr_out" | grep -q "DP-2-2 connected" && \
   echo "$xrandr_out" | grep -q "DP-2-3 connected"; then
    PREFIX="DP-2"
elif echo "$xrandr_out" | grep -q "DP-3-1 connected" && \
     echo "$xrandr_out" | grep -q "DP-3-2 connected" && \
     echo "$xrandr_out" | grep -q "DP-3-3 connected"; then
    PREFIX="DP-3"
else
    PREFIX=""
fi

if [ -n "$PREFIX" ]; then
    # Turn off all outputs first to free CRTCs (avoids "Configure crtc N failed")
    xrandr --output eDP-1 --off \
           --output HDMI-1 --off \
           --output DP-1 --off \
           --output DP-2 --off \
           --output DP-3 --off \
           --output DP-4 --off \
           --output "${PREFIX}-1" --off \
           --output "${PREFIX}-2" --off \
           --output "${PREFIX}-3" --off
    sleep 1
    # Enable office layout (85Hz is the max the MST hub supports with 3 monitors)
    xrandr --output "${PREFIX}-1" --mode 1920x1080 --pos 0x0 --rotate left \
           --output "${PREFIX}-2" --primary --mode 2560x1440 --rate 84.98 --pos 1080x240 --rotate normal \
           --output "${PREFIX}-3" --mode 1920x1080 --pos 3640x420 --rotate normal
else
    # Turn off any DP-2-x / DP-3-x outputs that might exist
    for port in $(xrandr | grep -oE 'DP-[23]-[0-9]+' | sort -u); do
        xrandr --output "$port" --off 2>/dev/null
    done
    xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
           --output HDMI-1 --off \
           --output DP-1 --off \
           --output DP-2 --off \
           --output DP-3 --off \
           --output DP-4 --off
fi

# Set wallpaper
sleep 0.5
feh --bg-fill "$qtile_dir/wallpaper.png"