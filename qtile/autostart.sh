#!/bin/sh

# Use autorandr for automatic display configuration
# It will detect connected monitors and apply the appropriate profile
./screen_setup.sh

# Compositor
picom --experimental-backend --config ~/.config/picom.conf &

# Wallpaper — wait for the display to settle first
sleep 1 && feh --bg-fill ~/.config/qtile/wallpaper.png &

# --- Applications that live in the background ---
# Stagger launches slightly to avoid hammering disk I/O at boot

# Brave Browser (general browsing, group A)
brave-browser &

sleep 2

# Google Gemini PWA (group H)
brave-browser --profile-directory=Default --app-id=gdfaincndogidkdcdkhapmbffkckdkhn &

sleep 1

# Gmail PWA (group K)
brave-browser --profile-directory=Default --app-id=fmgjjmmmlfnkbppncabfkddbjimcfncm &

sleep 1

# Spotify (group E)
spotify &

sleep 1

# Zulip (group I)
~/Applications/Zulip-*.AppImage &

sleep 1

# VS Code (group B)
# 5. VS Code
code &