#!/bin/sh
set -x

echo "Setting output to laptop screen only"
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output HDMI-1 --off \
       --output DP-1 --off \
       --output DP-2 --off \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-3-1 --off \
       --output DP-3-2 --off \
       --output DP-3-3 --off \
       --output DP-3-4 --off \
       --output DP-3-5 --off \
       --output DP-3-6 --off

# Set wallpaper
qtile_dir="$HOME/.config/qtile"
feh --bg-fill "$qtile_dir/wallpaper.png"
