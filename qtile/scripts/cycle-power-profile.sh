#!/usr/bin/env bash
#
# cycle-power-profile.sh
# Left-click : cycle to next profile
# Right-click: open rofi menu for direct selection  (pass "menu" as $1)
#
# Preferred backend: power-profiles-daemon (powerprofilesctl)
#   NixOS: services.power-profiles-daemon.enable = true;
#
# Fallback backend: cpupower (requires a polkit rule for passwordless use)
#   Example /etc/polkit-1/rules.d/10-cpupower.rules:
#     polkit.addRule(function(action, subject) {
#       if (action.id == "org.freedesktop.policykit.exec" &&
#           subject.isInGroup("wheel")) { return polkit.Result.YES; }
#     });

NOTIFY_ICON="battery"
SET_EPP_SCRIPT="$(dirname "$0")/set-epp.sh"

# ── helpers ──────────────────────────────────────────────────────────────────

EPP_PATH="/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference"

apply_profile() {
    local new="$1" label="$2" icon="$3"
    local ok=0
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl set "$new" && ok=1
    elif [[ -f "$EPP_PATH" ]]; then
        # intel_pstate / amd-pstate: single sudo call for all CPUs
        # Requires: echo "$USER ALL=(root) NOPASSWD: $SET_EPP_SCRIPT" | sudo tee /etc/sudoers.d/qtile-set-epp && sudo chmod 440 /etc/sudoers.d/qtile-set-epp
        local epp
        case "$new" in
            performance)  epp="performance" ;;
            balanced)     epp="balance_performance" ;;
            power-saver)  epp="balance_power" ;;
            *)            epp="balance_performance" ;;
        esac
        sudo "$SET_EPP_SCRIPT" "$epp" && ok=1
    else
        # Legacy: cpupower governor
        local gov
        case "$new" in
            power-saver) gov="powersave" ;;
            *)           gov="$new" ;;
        esac
        sudo cpupower frequency-set -g "$gov" &>/dev/null && ok=1
    fi
    if [[ "$ok" -eq 1 ]]; then
        notify-send -i "$NOTIFY_ICON" "Power Profile" "$icon  $label"
    else
        notify-send -i "$NOTIFY_ICON" "Power Profile" "❌  Failed to set $label"
    fi
}

get_current() {
    if command -v powerprofilesctl &>/dev/null; then
        powerprofilesctl get
    elif [[ -f "$EPP_PATH" ]]; then
        local epp
        epp=$(cat "$EPP_PATH" 2>/dev/null)
        case "$epp" in
            performance)         echo "performance" ;;
            balance_performance) echo "balanced" ;;
            balance_power|power) echo "power-saver" ;;
            *)                   echo "balanced" ;;
        esac
    else
        local gov
        gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
        [[ "$gov" == "performance" ]] && echo "performance" || echo "power-saver"
    fi
}

# ── rofi menu (right-click) ──────────────────────────────────────────────────

if [[ "$1" == "menu" ]]; then
    CURRENT=$(get_current)

    mark() { [[ "$CURRENT" == "$1" ]] && echo "● " || echo "  "; }

    if command -v powerprofilesctl &>/dev/null; then
        OPTIONS="$(mark performance)  Performance\n$(mark balanced)󰗑  Balanced\n$(mark power-saver)  Power Saver"
    else
        OPTIONS="$(mark performance)  Performance\n$(mark power-saver)  Power Saver"
    fi

    CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Power Profile" \
        -no-custom -theme-str 'window {width: 280px;}')

    case "$CHOICE" in
        *Performance*)   apply_profile "performance" "Performance" "" ;;
        *Balanced*)      apply_profile "balanced"    "Balanced"    "󰗑" ;;
        *"Power Saver"*) apply_profile "power-saver" "Power Saver" ""  ;;
    esac
    exit 0
fi

# ── left-click: cycle to next profile ────────────────────────────────────────

CURRENT=$(get_current)
if command -v powerprofilesctl &>/dev/null; then
    case "$CURRENT" in
        performance)  apply_profile "balanced"    "Balanced"    "󰗑" ;;
        balanced)     apply_profile "power-saver" "Power Saver" "" ;;
        power-saver)  apply_profile "performance" "Performance" "" ;;
        *)            apply_profile "balanced"    "Balanced"    "󰗑" ;;
    esac
else
    case "$CURRENT" in
        performance)  apply_profile "power-saver" "Power Saver" "" ;;
        *)            apply_profile "performance" "Performance" "" ;;
    esac
fi
