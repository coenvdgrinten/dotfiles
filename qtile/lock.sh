#!/bin/bash

# Path to your logo
LOGO="/home/coen/Pictures/Logo/Logo_white_text_transparent.png"
TEMP_BG="/tmp/lock_screen.png"
TEMP_LOGO="/tmp/lock_logo.png"

# Get total screen resolution (all monitors combined)
RESOLUTION=$(xdpyinfo | grep dimensions | awk '{print $2}')

# Resize logo to reasonable size (800px width, maintaining aspect ratio)
convert $LOGO -resize 800x $TEMP_LOGO

# Create a black background with the full resolution
convert -size $RESOLUTION xc:black $TEMP_BG

# Get individual monitor positions and sizes
# This matches outputs like "DP-3-1 connected" or "eDP-1 connected"
xrandr --query | grep ' connected' | while read -r line; do
    # Extract the geometry part (e.g., "1920x1080+0+0" or "2560x1440+1080+0")
    GEOMETRY=$(echo "$line" | grep -oE '[0-9]+x[0-9]+\+[0-9]+\+[0-9]+' | head -1)
    
    if [ -n "$GEOMETRY" ]; then
        # Parse geometry: WIDTHxHEIGHT+X+Y
        WIDTH=$(echo $GEOMETRY | cut -d'x' -f1)
        HEIGHT=$(echo $GEOMETRY | cut -d'x' -f2 | cut -d'+' -f1)
        X_OFFSET=$(echo $GEOMETRY | cut -d'+' -f2)
        Y_OFFSET=$(echo $GEOMETRY | cut -d'+' -f3)
        
        echo "Monitor detected: ${WIDTH}x${HEIGHT} at +${X_OFFSET}+${Y_OFFSET}"
        
        # Calculate center position for this monitor
        CENTER_X=$((X_OFFSET + WIDTH / 2 - 400)) # Subtract half the logo's width (800/2)
        CENTER_Y=$((Y_OFFSET + HEIGHT / 2 - 100))
        
        # Add logo centered on this monitor
        convert $TEMP_BG $TEMP_LOGO \
            -geometry +${CENTER_X}+${CENTER_Y} \
            -composite $TEMP_BG
        
        # Add "LOCKED" text below the logo on each monitor
        TEXT_Y=$((CENTER_Y + 250))
        convert $TEMP_BG \
            -fill white \
            -pointsize 36 \
            -font DejaVu-Sans-Bold \
            -draw "text $((CENTER_X + 323)),$TEXT_Y 'LOCKED'" \
            $TEMP_BG
    fi
done

# Lock the screen (standard i3lock has minimal options)
i3lock -i $TEMP_BG \
    --nofork \
    --ignore-empty-password

# Clean up
rm -f $TEMP_BG $TEMP_LOGO