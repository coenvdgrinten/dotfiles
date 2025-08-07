#!/bin/sh
set -x

if xrandr | grep -q "DP-3-1 connected" && xrandr | grep -q "DP-3-2 connected" && xrandr | grep -q "DP-3-3 connected"; then
# Work setup with three monitors
echo "Office monitors detected"
xrandr --output eDP-1 --off \
       --output HDMI-1 --off \
       --output DP-1 --off \
       --output DP-2 --off \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-3-1 --mode 1920x1080 --pos 0x0 --rotate left \
       --output DP-3-2 --primary --mode 2560x1440 --rate 60 --pos 1080x0 --rotate normal \
       --output DP-3-3 --mode 1920x1080 --pos 3640x0 --rotate normal
else
# Any other setup, only the laptop screen will be used.
echo "Using Setup with only the laptop screen"
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-3-1 --off --output DP-3-2 --off --output DP-3-3 --off
fi

# Set wallpaper
qtile_dir="$HOME/.config/qtile"
feh --bg-fill "$qtile_dir/wallpaper.png"