#!/usr/bin/env bash
# install-hyprland-deps.sh
# Installs all dependencies for the JaKooLit Hyprland dotfiles on Ubuntu LTS.
# Run with: sudo bash install-hyprland-deps.sh
#
# Usage:
#   sudo bash install-hyprland-deps.sh              # Install everything
#   sudo bash install-hyprland-deps.sh --no-nvidia  # Skip NVIDIA drivers
#   sudo bash install-hyprland-deps.sh --no-optional # Skip optional packages
#   sudo bash install-hyprland-deps.sh --dry-run    # List packages without installing

set -euo pipefail

# --- Configuration ---
INSTALL_NVIDIA=true
INSTALL_OPTIONAL=true
DRY_RUN=false
SUDO=""

# --- Parse arguments ---
for arg in "$@"; do
  case "$arg" in
    --no-nvidia)   INSTALL_NVIDIA=false ;;
    --no-optional) INSTALL_OPTIONAL=false ;;
    --dry-run)     DRY_RUN=true ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --no-nvidia      Skip NVIDIA driver installation"
      echo "  --no-optional    Skip optional packages (quickshell, ags, hyprsunset, cava, mpvpaper)"
      echo "  --dry-run        Print commands without executing"
      echo "  --help           Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Use --help for usage."
      exit 1
      ;;
  esac
done

# Detect if running as root
if [[ $EUID -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

# --- Color helpers ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INSTALL]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
step()  { echo -e "${CYAN}[STEP]${NC} $*"; }

# --- Helper: run or print command ---
run() {
  if $DRY_RUN; then
    echo "  [DRY-RUN] $*"
  else
    "$@"
  fi
}

# --- 1. Update package lists ---
step "Updating package lists..."
if ! $DRY_RUN; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
fi

# --- 2. Core Hyprland ecosystem ---
step "Installing core Hyprland packages..."
CORE_HYPRLAND=(
  hyprland
  hypridle
  hyprlock
)

if ! $DRY_RUN; then
  apt-get install -y --install-recommends "${CORE_HYPRLAND[@]}" 2>/dev/null || {
    warn "Some core Hyprland packages may not be in repos (too new). You may need to build from source."
  }
fi

# --- 3. Compositors & display tools ---
step "Installing compositors & display tools..."
COMPOSITORS=(
  swww
  wlogout
  waybar
  swaync
  swappy
)

run apt-get install -y "${COMPOSITORS[@]}"

# --- 4. Launchers & menus ---
step "Installing launchers & menus..."
LAUNCHERS=(
  rofi-wayland
  nwg-displays
)

run apt-get install -y "${LAUNCHERS[@]}"

# --- 5. Clipboard ---
step "Installing clipboard tools..."
CLIPBOARD=(
  cliphist
  wl-clipboard
)

run apt-get install -y "${CLIPBOARD[@]}"

# --- 6. Audio ---
step "Installing audio packages..."
AUDIO=(
  pamixer
  pipewire
  pipewire-pulse
  wireplumber
  pw-link
  libnotify-bin
)

run apt-get install -y "${AUDIO[@]}"

if $INSTALL_OPTIONAL; then
  run apt-get install -y cava || warn "cava not found in repos"
fi

# --- 7. Networking & Bluetooth ---
step "Installing networking & Bluetooth..."
NETWORK=(
  network-manager
  network-manager-gnome
  blueman
  bluetooth
  bluez
)

run apt-get install -y "${NETWORK[@]}"

# --- 8. Theming & colors ---
step "Installing theming packages..."
THEMING=(
  kvantum
  qt5ct
  qt6ct
  gtk2-engines-murrine
  bibata-cursor-theme
)

run apt-get install -y "${THEMING[@]}"

# Flat-Remix GTK theme & icons (may not be in Ubuntu repos)
step "Installing GTK themes & icons..."
GTK_THEMES=(
  flat-remix-gtk
  flat-remix-icon-theme
)

run apt-get install -y "${GTK_THEMES[@]}" || warn "Flat-Remix themes not in repos — install manually or pick an alternative"

# --- 9. Terminal & file manager ---
step "Installing terminal & file manager..."
TERM_FILES=(
  kitty
  thunar
  zsh
)

run apt-get install -y "${TERM_FILES[@]}"

# oh-my-zsh (post-install hook)
if ! $DRY_RUN; then
  if command -v zsh &>/dev/null && [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing oh-my-zsh (may prompt for input)..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || warn "oh-my-zsh install failed"
  fi
fi

# --- 10. System utilities ---
step "Installing system utilities..."
UTILS=(
  brightnessctl
  jq
  polkitd
  polkitd-desktop-agent
  xdg-user-dirs
  xdg-utils
  dbus
  libnotify-bin
)

run apt-get install -y "${UTILS[@]}"

# --- 11. xdg-desktop-portal ---
step "Installing xdg-desktop-portal packages..."
PORTAL=(
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-hyprland
)

run apt-get install -y "${PORTAL[@]}" || warn "xdg-desktop-portal-hyprland not in repos — may need to build from source"

# --- 12. NVIDIA drivers (optional) ---
if $INSTALL_NVIDIA; then
  step "Installing NVIDIA drivers..."
  NVIDIA=(
    libnvidia-egl-wayland
  )

  run apt-get install -y "${NVIDIA[@]}" || warn "Some NVIDIA packages not found"

  if ! $DRY_RUN; then
    # Detect and install the recommended driver
    if command -v ubuntu-drivers &>/dev/null; then
      RECOMMENDED=$(ubuntu-drivers devices 2>/dev/null | grep -oP 'driver\s*=\s*\K\S+' | head -1 || true)
      if [[ -n "$RECOMMENDED" ]]; then
        info "Installing recommended NVIDIA driver: $RECOMMENDED"
        apt-get install -y "$RECOMMENDED" || warn "Failed to install $RECOMMENDED"
      else
        warn "No NVIDIA driver detected. Install manually with: sudo ubuntu-drivers autoinstall"
      fi
    fi
  fi
else
  info "Skipping NVIDIA drivers (--no-nvidia)"
fi

# --- 13. Optional packages ---
if $INSTALL_OPTIONAL; then
  step "Installing optional packages..."
  OPTIONAL=(
    mpv  # for mpvpaper (disabled by default in config)
  )

  run apt-get install -y "${OPTIONAL[@]}" || warn "Some optional packages not found"
else
  info "Skipping optional packages (--no-optional)"
fi

# --- 14. Build from source ---
step "Building packages not in Ubuntu repos..."

if $DRY_RUN; then
  echo "  [DRY-RUN] Would build: hyprcursor, keyd, hyprsunset, wallust"
  exit 0
fi

BUILD_DIR="$HOME/.local/hyprland-build"
mkdir -p "$BUILD_DIR"

build_from_source() {
  local name="$1"
  local repo="$2"
  local build_cmd="${3:-cmake -B build && cmake --build build -j\$(nproc) && sudo cmake --install build}"

  local dir="$BUILD_DIR/$name"
  if [[ -d "$dir" ]]; then
    info "Updating $name..."
    cd "$dir" && git pull || true
  else
    info "Cloning $name..."
    cd "$BUILD_DIR" && git clone "$repo" "$name"
  fi
  cd "$dir"
  info "Building $name..."
  eval "$build_cmd" || warn "Failed to build $name"
  cd - >/dev/null
}

# hyprcursor
build_from_source "hyprcursor" "https://github.com/hyprwm/hyprcursor.git"

# keyd
build_from_source "keyd" "https://github.com/rvaiya/keyd.git" "make -j\$(nproc) && sudo make install"

# hyprsunset
build_from_source "hyprsunset" "https://github.com/hyprwm/hyprsunset.git"

# wallust (Go binary)
if ! command -v wallust &>/dev/null; then
  info "Installing wallust..."
  if command -v go &>/dev/null; then
    go install -v github.com/starkweather/wallust@latest || warn "Failed to install wallust via go install"
  else
    # Download pre-built binary
    LATEST=$(curl -s https://api.github.com/repos/starkweather/wallust/releases/latest | jq -r '.tag_name')
    if [[ -n "$LATEST" && "$LATEST" != "null" ]]; then
      curl -fsSL "https://github.com/starkweather/wallust/releases/download/${LATEST}/wallust-${LATEST}-x86_64.tar.gz" | \
        sudo tar -xz -C /usr/local/bin/ wallust || warn "Failed to download wallust binary"
    else
      warn "Could not determine latest wallust version. Install manually: https://github.com/starkweather/wallust"
    fi
  fi
fi

# --- 15. Enable keyd service ---
if command -v keyd &>/dev/null; then
  info "Enabling keyd service..."
  sudo systemctl enable --now keyd || warn "Failed to enable keyd service"
fi

# --- 16. Post-install: update hwdb (for Logitech G Pro side button) ---
if [[ -f "$HOME/.config/hypr/70-logitech-gpro-side-button.hwdb" ]]; then
  info "Updating udev hwdb for Logitech G Pro..."
  sudo cp "$HOME/.config/hypr/70-logitech-gpro-side-button.hwdb" /etc/udev/hwdb.d/
  sudo udevadm hwdb --update
  sudo udevadm trigger
fi

# --- Done ---
echo ""
step "Installation complete!"
echo ""
echo "Next steps:"
echo "  1. If NVIDIA: reboot to load the new driver"
echo "  2. Copy keyd config: sudo cp ~/.config/keyd/logitech_gpro.conf /etc/keyd/"
echo "  3. Ensure keyd config is referenced in /etc/keyd/keyd.conf"
echo "  4. Reboot or log out and log back in"
echo ""
echo "Packages that may still need manual attention:"
echo "  - quickshell / ags        (desktop overview — check repos or build)"
echo "  - flat-remix-gtk          (GTK theme — may need PPA or manual install)"
echo "  - hyprland/hypridle/hyprlock (if repo versions are too old, build from source)"
echo ""
