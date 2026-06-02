#!/usr/bin/env bash
#
# fix-pixel-buds.sh - Fix Pixel Buds disconnect/reconnect loop on Hyprland
#
# The disconnect loop is most commonly caused by the kernel putting the
# USB Bluetooth adapter to sleep (USB autosuspend).  The primary fix is
# the btusb.conf kernel module config.
#

set -euo pipefail

echo "=== Pixel Buds Bluetooth Fix ==="
echo ""

# 1. Disable USB autosuspend for Bluetooth adapter (PRIMARY FIX)
echo "[1/2] Disabling USB autosuspend for Bluetooth adapter..."
echo "  This prevents the kernel from putting the BT adapter to sleep."
echo ""
read -p "  Apply btusb.conf? (y/N): " apply_btusb
if [[ "$apply_btusb" =~ ^[Yy] ]]; then
    sudo cp "$(dirname "$0")/../etc/modprobe.d/btusb.conf" /etc/modprobe.d/btusb.conf
    echo "  → /etc/modprobe.d/btusb.conf"
    echo "  Running update-initramfs..."
    sudo update-initramfs -u
    echo "  → initramfs updated"
else
    echo "  Skipping. Manual install:"
    echo "    sudo cp $(dirname "$0")/../etc/modprobe.d/btusb.conf /etc/modprobe.d/btusb.conf"
    echo "    sudo update-initramfs -u"
fi

# 2. Restart Bluetooth
echo ""
echo "[2/2] Restarting Bluetooth service..."
sudo systemctl restart bluetooth || echo "  → BlueZ restart failed (may need sudo)"

echo ""
echo "=== Done ==="
echo ""
echo "A reboot is recommended for the initramfs changes to take full effect."
echo ""
echo "After reboot (or now), reconnect your Pixel Buds:"
echo "  bluetoothctl disconnect 10:D9:A2:4C:12:8F"
echo "  bluetoothctl connect 10:D9:A2:4C:12:8F"
echo "  ~/.local/bin/pixel-buds-a2dp.sh a2dp"
