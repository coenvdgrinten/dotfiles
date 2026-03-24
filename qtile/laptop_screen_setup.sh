#!/bin/sh
set -x

echo "Setting output to laptop screen only"
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output HDMI-1 --off \
       --output DP-1 --off \
       --output DP-2 --off \
       --output DP-3 --off \
       --output DP-4 --off

# Turn off any DP-2-x / DP-3-x outputs that might exist
for port in $(xrandr | grep -oE 'DP-[23]-[0-9]+' | sort -u); do
    xrandr --output "$port" --off 2>/dev/null
done

# Set wallpaper
qtile_dir="$HOME/.config/qtile"
feh --bg-fill "$qtile_dir/wallpaper.png"
