#!/usr/bin/env bash
#
# restore-session.sh - Restore workspace layout from ~/.cache/hypr-session.json
#

SESSION_FILE="$HOME/.cache/hypr-session.json"

if [[ ! -f "$SESSION_FILE" ]]; then
    notify-send "Session restore" "No saved session found"
    echo "No saved session found at $SESSION_FILE"
    exit 1
fi

echo "Restoring session..."

# Read each window from the session file and launch it
WINDOW_COUNT=0
while IFS= read -r line; do
    CLASS=$(echo "$line" | jq -r '.class')
    WORKSPACE=$(echo "$line" | jq -r '.workspace')

    if [[ -n "$CLASS" && "$CLASS" != "null" ]]; then
        # Switch to the correct workspace first
        hyprctl dispatch workspace "$WORKSPACE" 2>/dev/null

        # Launch the application
        case "$CLASS" in
            *firefox*|*Firefox*) firefox & ;;
            *brave*|*Brave*) brave-browser & ;;
            *chrome*|*Chrome*) google-chrome & ;;
            *code*|*vscode*|*VSCode*) code & ;;
            *code-insiders*) code-insiders & ;;
            *kitty*) kitty & ;;
            *alacritty*|*Alacritty*) alacritty & ;;
            *spotify*|*Spotify*) spotify & ;;
            *zulip*|*Zulip*) zulip & ;;
            *thunar*|*Thunar*) thunar & ;;
            *nautilus*|*Nautilus*) nautilus & ;;
            *)
                # Try to launch using the class name directly
                $CLASS & 2>/dev/null || echo "Could not launch: $CLASS"
                ;;
        esac

        WINDOW_COUNT=$((WINDOW_COUNT + 1))
        sleep 0.5  # Small delay between launches
    fi
done < <(jq -c '.[]' "$SESSION_FILE")

echo "Restored $WINDOW_COUNT windows"
notify-send "Session restored" "$WINDOW_COUNT windows restored"
