#!/bin/sh
if $($"xrandr" | $(grep -q "eDP-1 connected")) && $($"xrandr" | $(grep -q "DP-2 connected")) && $($"xrandr" | $(grep -q "DP-3-5 connected")) && $($"xrandr" | $(grep -q "DP-3-6 connected")); then
# Work setup with two monitors
echo "Two monitors detected"
xrandr --output eDP-1 --off --output HDMI-1 --off --output DP-1 --off --output DP-2 --mode 1920x1080 --pos 1080x591 --rotate normal --output DP-3 --off --output DP-4 --off --output DP-3-5 --mode 1920x1080 --pos 0x0 --rotate right --output DP-3-6 --mode 1920x1080 --pos 3000x591 --rotate normal
else
# Any other setup, only the laptop screen will be used. Screen can be setup with arandr.
echo "Using Setup with only the laptop screen"
xrandr --output XWAYLAND0 --primary --mode 1920x1080 --pos 0x0 --rotate normal
fi

# Set wallpaper
qtile_dir="$HOME/.config/qtile"
feh --bg-fill "$qtile_dir/wallpaper.png"