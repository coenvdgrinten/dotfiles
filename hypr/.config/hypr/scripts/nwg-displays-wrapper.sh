#!/usr/bin/env bash
# nwg-displays-wrapper.sh
#
# Works around the broken confirmation dialog in nwg-displays under Hyprland.
#
# Root cause: nwg-displays writes monitors.conf, which triggers Hyprland's
# inotify file-watcher and causes an immediate config reload.  That reload tears
# down all compositor surfaces (including the GTK Layer-Shell OVERLAY window
# nwg-displays just created), killing the confirmation dialog before the user
# can interact with it.
#
# This wrapper:
#   1. Backs up the current monitors.conf.
#   2. Runs nwg-displays normally (changes are applied via Hyprland auto-reload).
#   3. After nwg-displays exits, shows a stable zenity dialog asking to keep or
#      restore the previous configuration.

MONITORS_CONF="$HOME/.config/hypr/monitors.conf"
BACKUP_FILE=$(mktemp /tmp/hypr-monitors-backup.XXXXXX)

# Backup current config
cp "$MONITORS_CONF" "$BACKUP_FILE"

# Run nwg-displays (all CLI arguments are forwarded)
nwg-displays "$@"

# Check whether the config was actually changed
if diff -q "$MONITORS_CONF" "$BACKUP_FILE" >/dev/null 2>&1; then
    # No changes — nothing to do
    rm -f "$BACKUP_FILE"
    exit 0
fi

# Give Hyprland a moment to finish applying the new config
sleep 1

# Show a confirmation dialog
if zenity --question \
    --title="Keep monitor settings?" \
    --text="The monitor configuration has been updated and applied.\n\nKeep the new settings?" \
    --ok-label="Keep" \
    --cancel-label="Restore" \
    --timeout=30 2>/dev/null; then
    notify-send "Monitor Config" "New monitor configuration saved." 2>/dev/null
else
    # Restore the backup and reload Hyprland
    cp "$BACKUP_FILE" "$MONITORS_CONF"
    hyprctl reload >/dev/null 2>&1
    notify-send "Monitor Config" "Previous monitor configuration restored." 2>/dev/null
fi

rm -f "$BACKUP_FILE"
