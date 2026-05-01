#!/usr/bin/env bash
#
# save-session.sh - Save current workspace layout to ~/.cache/hypr-session.json
#

SESSION_FILE="$HOME/.cache/hypr-session.json"

# Get current workspace and window info
echo "Saving session..."

# Capture all clients with their workspace and class
hyprctl clients -j 2>/dev/null | jq '[.[] | {
    class: .class,
    workspace: .workspace.id,
    title: .title,
    size: .size,
    at: .at
}]' > "$SESSION_FILE"

# Also save current workspace assignments
echo "Workspace assignments saved to $SESSION_FILE"

# Count windows
WINDOW_COUNT=$(jq length "$SESSION_FILE")
echo "Saved $WINDOW_COUNT windows across workspaces"

notify-send "Session saved" "$WINDOW_COUNT windows saved to session"
