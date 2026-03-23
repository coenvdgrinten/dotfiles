#!/bin/sh
set -x

# Use autorandr for automatic display configuration
# It will detect connected monitors and apply the appropriate profile
./screen_setup.sh

# Setup picom
picom --config ~/.config/picom.conf &

# Set wallpaper with feh (more reliable than nitrogen)
sleep 1
feh --bg-fill ~/.config/qtile/wallpaper.png &

# 1. Brave Browser
brave-browser &

# 2. Google Gemini (PWA)
# This uses the specific App ID we found earlier
brave-browser --profile-directory=Default --app-id=crx_gdfaincndogidkdcdkhapmbffkckdkhn &

# 3. Spotify
spotify &

# 4. Zulip
~/Applications/Zulip-*.AppImage &

# 5. VS Code
code &

# 6. Antigravity
antigravity &

nitrogen --restore &
