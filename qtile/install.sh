#!/bin/bash
# ============================================================
# Qtile config dependency installer (Ubuntu / Debian)
# Tested on Ubuntu 25.10
# ============================================================
set -e

# ---- helpers -----------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }

require_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (sudo $0)"
        exit 1
    fi
}

require_root

# ---- apt packages ------------------------------------------
info "Updating package lists..."
apt-get update -q

APT_PACKAGES=(
    # Compositor & display
    picom
    nitrogen
    feh
    x11-xserver-utils          # xrandr

    # Terminal
    alacritty

    # Launcher
    rofi

    # Audio
    pavucontrol
    pulseaudio-utils            # pactl

    # Brightness
    brightnessctl

    # Screen lock
    i3lock
    x11-utils                   # xdpyinfo

    # Image manipulation (lock.sh uses ImageMagick; Ubuntu 25+ ships IM7 as 'magick')
    imagemagick

    # Notifications
    dunst

    # Clipboard
    xfce4-clipman

    # Screenshots
    xfce4-screenshooter

    # File manager
    thunar

    # Media
    playerctl

    # Power management (enables powerprofilesctl — no root needed for profile switching)
    power-profiles-daemon

    # Network management GUI
    network-manager-gnome    # provides nm-connection-editor

    # GTK theme switcher
    lxappearance

    # Utilities
    bat
    git
    make
    curl

    # Fonts
    fonts-ubuntu
    fonts-dejavu-core

    # Polkit (package renamed from 'policykit-1' in Ubuntu 23.10+)
    polkit

    # Python
    python3-psutil
    python3-pip
)

info "Installing apt packages..."
# Install packages individually so one failure doesn't abort everything
FAILED=()
for pkg in "${APT_PACKAGES[@]}"; do
    # Strip inline comments
    pkg="${pkg%% #*}"
    pkg="${pkg%%	#*}"
    [[ -z "$pkg" ]] && continue
    if ! apt-get install -y "$pkg" &>/dev/null; then
        warn "Failed to install '$pkg' — skipping"
        FAILED+=("$pkg")
    fi
done

if [[ ${#FAILED[@]} -gt 0 ]]; then
    warn "The following packages could not be installed: ${FAILED[*]}"
fi

# ---- bat symlink -------------------------------------------
# On Debian/Ubuntu the binary may be called "batcat"
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
    info "Creating 'bat' symlink -> batcat"
    ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# ---- pulseaudio-ctl ----------------------------------------
if ! command -v pulseaudio-ctl &>/dev/null; then
    info "Installing pulseaudio-ctl from GitHub..."
    TMP_DIR=$(mktemp -d)
    git clone --depth=1 https://github.com/graysky2/pulseaudio-ctl "$TMP_DIR/pulseaudio-ctl"
    make -C "$TMP_DIR/pulseaudio-ctl" install
    rm -rf "$TMP_DIR"
else
    info "pulseaudio-ctl already installed, skipping."
fi

# ---- rofi-power-menu ---------------------------------------
if ! command -v rofi-power-menu &>/dev/null; then
    info "Installing rofi-power-menu from GitHub..."
    curl -fsSL https://raw.githubusercontent.com/jluttine/rofi-power-menu/master/rofi-power-menu \
        -o /usr/local/bin/rofi-power-menu
    chmod +x /usr/local/bin/rofi-power-menu
else
    info "rofi-power-menu already installed, skipping."
fi

# ---- play-pause script -------------------------------------
QTILE_SCRIPTS_DIR="$(dirname "$(realpath "$0")")/scripts"
if [[ -f "$QTILE_SCRIPTS_DIR/play-pause.sh" ]]; then
    info "Installing play-pause script..."
    ln -sf "$QTILE_SCRIPTS_DIR/play-pause.sh" /usr/local/bin/play-pause
    chmod +x "$QTILE_SCRIPTS_DIR/play-pause.sh"
fi

# ---- uv (Python environment manager) ----------------------
# Qtile is managed via a uv venv at ~/.config/qtile/.venv
QTILE_DIR="$(dirname "$(realpath "$0")")"
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

if ! command -v uv &>/dev/null && [[ ! -x "$REAL_HOME/.local/bin/uv" ]]; then
    info "Installing uv for user '$REAL_USER'..."
    sudo -u "$REAL_USER" bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
else
    info "uv already installed, skipping."
fi

UV_BIN="$REAL_HOME/.local/bin/uv"

if [[ -x "$UV_BIN" ]]; then
    info "Setting up qtile venv with uv..."
    sudo -u "$REAL_USER" "$UV_BIN" venv "$QTILE_DIR/.venv" --python 3.12
    sudo -u "$REAL_USER" "$UV_BIN" pip install --python "$QTILE_DIR/.venv/bin/python" qtile psutil
    info "Qtile installed at $QTILE_DIR/.venv/bin/qtile"
else
    warn "uv not found after install attempt — falling back to pip"
    pip3 install --break-system-packages qtile psutil
fi

# ---- done --------------------------------------------------
echo
info "Installation complete!"
echo
warn "The following applications are NOT in apt and must be installed manually:"
echo "  - megasync   : https://mega.io/desktop"
echo "  - gammy      : https://github.com/Fijxu/gammy/releases"
echo "  - spotify    : https://www.spotify.com/download/linux/"
echo "  - brave      : https://brave.com/linux/"
echo "  - zoom       : https://zoom.us/download"
echo "  - pycharm    : https://www.jetbrains.com/pycharm/download/"
echo "  - obs        : https://obsproject.com/download"
echo
warn "Polkit KDE agent (used in scripts/autostart.sh):"
echo "  Install via: sudo apt install kde-polkit"
echo
warn "Lock screen logo:"
echo "  Copy your logo to: ~/Pictures/Logo/Logo_white_text_transparent.png"
echo
warn "Qtile session entry (for display managers like LightDM/SDDM):"
echo "  Set Exec to: $QTILE_DIR/.venv/bin/qtile start"
echo "  Or update /usr/share/xsessions/qtile.desktop"
echo
