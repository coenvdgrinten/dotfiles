#!/bin/sh
set -x

if xrandr | grep -q "DP-3-1 connected" && xrandr | grep -q "DP-3-2 connected" && xrandr | grep -q "DP-3-3 connected"; then
echo "Office monitors detected"

# First, turn off all outputs except one to free up CRTCs
xrandr --output eDP-1 --off \
       --output HDMI-1 --off \
       --output DP-1 --off \
       --output DP-2 --off \
       --output DP-3 --off \
       --output DP-4 --off

sleep 1

# Configure primary monitor first
xrandr --output DP-3-2 --primary --mode 2560x1440 --rate 100 --pos 1080x0 --rotate normal

sleep 5

# Add left monitor
xrandr --output DP-3-1 --mode 1920x1080 --pos 0x0 --rotate left

sleep 5

# Add right monitor
xrandr --output DP-3-3 --mode 1920x1080 --pos 3640x0 --rotate normal

elif xrandr | grep -q "DP-2-1 connected" && xrandr | grep -q "DP-2-2 connected" && xrandr | grep -q "DP-2-3 connected"; then
echo "Office monitors detected"

xrandr --output eDP-1 --off --output HDMI-1 --off --output DP-1 --off --output DP-2 --off --output DP-3 --off --output DP-4 --off --output DP-3-1 --off --output DP-3-2 --off --output DP-3-3 --off --output DP-2-1 --mode 1920x1080 --pos 0x0 --rotate left --output DP-2-2 --mode 2560x1440 --rate 100 --pos 1080x240 --rotate normal --output DP-2-3 --mode 1920x1080 --pos 3640x362 --rotate normal

else
echo "Using Setup with only the laptop screen"
xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
       --output HDMI-1 --off \
       --output DP-1 --off \
       --output DP-2 --off \
       --output DP-3 --off \
       --output DP-4 --off \
       --output DP-3-1 --off \
       --output DP-3-2 --off \
       --output DP-3-3 --off
fi

# Set wallpaper
qtile_dir="$HOME/.config/qtile"
feh --bg-fill "/home/cvdgrinten/.config/qtile/wallpaper.png"
