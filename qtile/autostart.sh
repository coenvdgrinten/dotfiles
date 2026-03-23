#!/bin/sh
set -x

# Setup screens
$HOME/.config/qtile/screen_setup.sh

# Setup picom and nitrogen
picom --config ~/.config/picom.conf &
nitrogen --restore &
