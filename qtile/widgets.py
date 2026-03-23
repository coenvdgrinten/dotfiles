import os
from libqtile import bar, widget
from libqtile.lazy import lazy
from libqtile.config import Screen
import subprocess

from functions import PWA

_POWER_PROFILE_SCRIPT = os.path.expanduser("~/.config/qtile/scripts/cycle-power-profile.sh")
_POWER_WIDGET_NAME = "power_mode_indicator"
_NOW_PLAYING_MAX_LEN = 40


def _refresh_power_widget(qtile):
    w = qtile.widgets_map.get(_POWER_WIDGET_NAME)
    if w:
        w.force_update()


def _cycle_power(qtile):
    subprocess.Popen([_POWER_PROFILE_SCRIPT])
    qtile.call_later(1.0, lambda: _refresh_power_widget(qtile))


def _menu_power(qtile):
    subprocess.Popen([_POWER_PROFILE_SCRIPT, "menu"])
    qtile.call_later(1.5, lambda: _refresh_power_widget(qtile))


def get_now_playing():
    """Return currently playing track via playerctl, or empty string."""
    try:
        status = subprocess.check_output(
            ["playerctl", "status"], text=True, stderr=subprocess.DEVNULL
        ).strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""
    if status not in ("Playing", "Paused"):
        return ""
    try:
        meta = subprocess.check_output(
            ["playerctl", "metadata", "--format", "{{artist}} - {{title}}"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""
    icon = "\U000f040a" if status == "Playing" else "\U000f03e4"  # 󰐊 / 󰏤
    if len(meta) > _NOW_PLAYING_MAX_LEN:
        meta = meta[:_NOW_PLAYING_MAX_LEN - 1] + "\u2026"
    return f"{icon} {meta}"


def get_network():
    """Return wifi icon + SSID + signal strength, or wired icon, or disconnected."""
    try:
        # Check for active wifi
        out = subprocess.check_output(
            ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
        for line in out.splitlines():
            parts = line.split(":")
            if parts[0] == "yes" and len(parts) >= 3:
                ssid = parts[1] or "WiFi"
                try:
                    sig = int(parts[2])
                except ValueError:
                    sig = 0
                # Signal strength icon: 󰤯 󰤟 󰤢 󰤥 󰤨
                if sig >= 80:   icon = "\U000f0928"  # 󰤨
                elif sig >= 60: icon = "\U000f0925"  # 󰤥
                elif sig >= 40: icon = "\U000f0922"  # 󰤢
                elif sig >= 20: icon = "\U000f091f"  # 󰤟
                else:           icon = "\U000f092f"  # 󰤯
                return f"{icon} {ssid}"
        # Check for active wired connection
        out2 = subprocess.check_output(
            ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "dev"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
        for line in out2.splitlines():
            parts = line.split(":")
            if len(parts) >= 3 and parts[1] == "ethernet" and parts[2] == "connected":
                return "\U000f059e  Wired"  # 󰖞
        return "\U000f092f  Offline"  # 󰤯
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""


def get_network():
    """Return wifi icon + SSID + signal strength, or wired icon, or disconnected."""
    try:
        # Check for active wifi
        out = subprocess.check_output(
            ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
        for line in out.splitlines():
            parts = line.split(":")
            if parts[0] == "yes" and len(parts) >= 3:
                ssid = parts[1] or "WiFi"
                try:
                    sig = int(parts[2])
                except ValueError:
                    sig = 0
                if sig >= 80:   icon = "\U000f0928"
                elif sig >= 60: icon = "\U000f0925"
                elif sig >= 40: icon = "\U000f0922"
                elif sig >= 20: icon = "\U000f091f"
                else:           icon = "\U000f092f"
                return f"{icon} {ssid}"
        # Check for active wired connection
        out2 = subprocess.check_output(
            ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "dev"],
            text=True, stderr=subprocess.DEVNULL,
        ).strip()
        for line in out2.splitlines():
            parts = line.split(":")
            if len(parts) >= 3 and parts[1] == "ethernet" and parts[2] == "connected":
                return "\U000f059e  Wired"
        return "\U000f092f  Offline"
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""


def get_brightness():
    """Return current brightness as a percentage string."""
    try:
        pct = subprocess.check_output(
            ["brightnessctl", "-m"], text=True, stderr=subprocess.DEVNULL
        ).strip()
        # -m format: device,class,current,max,percentage
        return pct.split(",")[3] if "," in pct else "?"
    except (FileNotFoundError, subprocess.CalledProcessError):
        return "?"


def get_power_profile():
    """Return a nerd-font icon + short label for the current power profile."""
    labels = {
        "performance": "\uf0e7 Perf",
        "balance_performance": "\U000f05d1 Bal",
        "balance_power": "\U000f0079 Saver",
        "power": "\U000f0079 Saver",
        # powerprofilesctl names
        "balanced": "\U000f05d1 Bal",
        "power-saver": "\U000f0079 Saver",
    }
    # Try power-profiles-daemon first
    try:
        profile = subprocess.check_output(
            ["powerprofilesctl", "get"], text=True, stderr=subprocess.DEVNULL
        ).strip()
        return labels.get(profile, "?")
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass
    # Fallback: read energy_performance_preference (works with intel_pstate / amd-pstate)
    try:
        epp = open("/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference").read().strip()
        return labels.get(epp, labels.get("performance") if epp == "default" else "?")
    except OSError:
        pass
    # Last resort: scaling_governor
    try:
        gov = open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor").read().strip()
        return labels.get(gov, "?")
    except OSError:
        return "?"


# widget_defaults = dict(
#     font="Ubuntu Mono",
#     fontsize = 12,
#     padding = 2,
#     background=colors[2]
# )

# extension_defaults = widget_defaults.copy()


class MyWidgets:
    def __init__(self):
        """self.colors = [["#292d3e", "#292d3e"],  # panel background
        # background for current screen tab
        ["#434758", "#434758"],
        ["#ffffff", "#ffffff"],  # font color for group names
        # border line color for current tab
        ["#bc13fe", "#bc13fe"],  # Group down color
        # border line color for other tab and odd widgets
        ["#8d62a9", "#8d62a9"],
        ["#668bd7", "#668bd7"],  # color for the even widgets
        ["#e1acff", "#e1acff"],  # window name

        ["#000000", "#000000"],
        ["#AD343E", "#AD343E"],
        ["#f76e5c", "#f76e5c"],
        ["#F39C12", "#F39C12"],
        ["#F7DC6F", "#F7DC6F"],
        ["#f1ffff", "#f1ffff"],
        ["#4c566a", "#4c566a"], ]"""

        self.colors = {
            "bg": "#4e4c4a",
            "bg_highlight": "#4e4c4a",
            "fg": "#e2d1cf",
            "fg_gutter": "#e2d1cf",
            "black": "#4e4c4a",
            "grey": "#9b9691",
            "white": "#e2d1cf",
            "red": "#fd7b83",
            "orange": "#fda987",
            "yellow": "#fdd48f",
            "blue": "#667586",
        }

    def init_widgets_list(self):
        """
        Function that returns the desired widgets in form of list
        """
        widgets_list = [
            widget.Sep(
                linewidth=0,
                padding=8,
                foreground="#a4a3a9",
                background="#a4a3a9",
            ),
            widget.GroupBox(
                font="Ubuntu Bold",
                fontsize=12,
                margin_y=2,
                margin_x=0,
                padding_y=5,
                padding_x=3,
                borderwidth=3,
                active=self.colors["white"],
                inactive=self.colors["grey"],
                rounded=False,
                # highlight_color=self.colors[9],
                # highlight_method="line",
                highlight_method="block",
                urgent_alert_method="block",
                # urgent_border=self.colors[9],
                this_current_screen_border=self.colors["red"],
                this_screen_border=self.colors["red"],
                other_current_screen_border=self.colors["orange"],
                other_screen_border=self.colors["orange"],
                foreground=self.colors["fg"],
                background=self.colors["bg"],
                disable_drag=True,
            ),
            widget.Prompt(
                prompt=lazy.spawncmd(),
                font="Ubuntu Mono",
                padding=10,
                foreground=self.colors["fg"],
                background=self.colors["bg"],
            ),
            widget.Sep(
                linewidth=0,
                padding=40,
                foreground=self.colors["fg"],
                background=self.colors["bg"],
            ),
            widget.WindowName(
                foreground=self.colors["fg"], background=self.colors["bg"], padding=0
            ),
            widget.GenPollText(
                func=get_now_playing,
                update_interval=0.5,
                foreground=self.colors["fg"],
                background=self.colors["bg"],
                padding=8,
                mouse_callbacks={
                    "Button1": lazy.spawn("playerctl play-pause"),
                    "Button4": lazy.spawn("playerctl next"),
                    "Button5": lazy.spawn("playerctl previous"),
                },
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["blue"],
                background=self.colors["bg"],
                padding=-7,
                fontsize=40,
            ),
            widget.GenPollText(                func=get_network,
                update_interval=5,
                foreground=self.colors["fg"],
                background=self.colors["blue"],
                padding=6,
                mouse_callbacks={
                    "Button1": lazy.spawn("nm-connection-editor"),
                    "Button3": lazy.spawn(
                        "bash -c 'nmcli -t -f SSID dev wifi list | "
                        "sed \"s/^://\" | sort -u | "
                        "rofi -dmenu -i -p \"WiFi\" -theme-str \"window {width: 300px;}\" | "
                        "xargs -I{} nmcli dev wifi connect \"{}\"'"
                    ),
                },
            ),
            widget.GenPollText(                name=_POWER_WIDGET_NAME,
                func=get_power_profile,
                update_interval=1,
                foreground=self.colors["fg"],
                background=self.colors["blue"],
                padding=4,
                fontsize=14,
                mouse_callbacks={
                    "Button1": lazy.function(_cycle_power),
                    "Button3": lazy.function(_menu_power),
                },
            ),
            widget.BatteryIcon(
                foreground=self.colors["fg"],
                background=self.colors["blue"],
                theme_path=os.path.expanduser("~/.config/qtile/icons/battery_theme"),
                update_interval=1,
                padding=2,
                mouse_callbacks={
                    "Button1": lazy.function(_cycle_power),
                    "Button3": lazy.function(_menu_power),
                },
            ),
            widget.Battery(
                foreground=self.colors["fg"],
                background=self.colors["blue"],
                update_interval=1,
                padding=5,
                mouse_callbacks={
                    "Button1": lazy.function(_cycle_power),
                    "Button3": lazy.function(_menu_power),
                },
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["red"],
                background=self.colors["blue"],
                padding=-7,
                fontsize=40,
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["black"],
                background=self.colors["red"],
                padding=4,
                fontsize=14,
            ),
            widget.Memory(
                foreground=self.colors["black"],
                background=self.colors["red"],
                mouse_callbacks={
                    "Button1": lazy.spawn("alacritty -e htop")
                },
                padding=7,
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["orange"],
                background=self.colors["red"],
                padding=-7,
                fontsize=40,
            ),
            widget.TextBox(
                text="  ",
                foreground=self.colors["black"],
                background=self.colors["orange"],
                padding=0,
                mouse_callbacks={"Button1": lazy.spawn("pavucontrol")},
            ),
            widget.Volume(
                foreground=self.colors["black"],
                background=self.colors["orange"],
                padding=5,
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["yellow"],
                background=self.colors["orange"],
                padding=-7,
                fontsize=40,
            ),
            widget.TextBox(
                text=" \U000f00df ",
                foreground=self.colors["black"],
                background=self.colors["yellow"],
                padding=0,
                mouse_callbacks={
                    "Button4": lazy.spawn("brightnessctl set +5%"),
                    "Button5": lazy.spawn("brightnessctl set 5%-"),
                },
            ),
            widget.GenPollText(
                func=get_brightness,
                update_interval=2,
                foreground=self.colors["black"],
                background=self.colors["yellow"],
                padding=2,
                mouse_callbacks={
                    "Button4": lazy.spawn("brightnessctl set +5%"),
                    "Button5": lazy.spawn("brightnessctl set 5%-"),
                },
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["white"],
                background=self.colors["yellow"],
                padding=-7,
                fontsize=40,
            ),
            widget.CurrentLayoutIcon(
                custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
                foreground=self.colors["black"],
                background=self.colors["white"],
                padding=0,
                scale=0.7,
            ),
            widget.CurrentLayout(
                foreground=self.colors["black"],
                background=self.colors["white"],
                padding=5,
            ),
            widget.Clock(
                foreground=self.colors["black"],
                background=self.colors["white"],
                mouse_callbacks={"Button1": lazy.spawn(PWA.calendar())},
                format="%B %d  [ %H:%M ]",
            ),
            widget.Systray(background=self.colors["bg"], padding=5),
            widget.Sep(
                linewidth=0,
                padding=10,
                foreground="#a4a3a9",
                background="#a4a3a9",
            ),
        ]
        return widgets_list

    def init_widgets_screen(self):
        """
        Function that returns the widgets in a list.
        It can be modified so it is useful if you  have a multimonitor system
        """
        widgets_screen = self.init_widgets_list()
        return widgets_screen

    def init_screen(self):
        """
        Init the widgets in the screen dynamically based on connected monitors
        """
        try:
            # Get number of active monitors. The first line from the command is "Monitors: X", so we skip it.
            num_monitors = len(
                subprocess.check_output(["xrandr", "--listactivemonitors"])
                .decode()
                .strip()
                .split("\n")[1:]
            )
        except Exception:
            num_monitors = 1  # Fallback to 1 monitor on error

        screens = [
            Screen(top=bar.Bar(widgets=self.init_widgets_screen(), opacity=1.0, size=22))
            for _ in range(num_monitors)
        ]

        # Remove systray from all but the first screen to avoid issues
        if num_monitors > 1:
            for screen in screens[1:]:
                screen.top.widgets = [
                    w for w in screen.top.widgets if not isinstance(w, widget.Systray)
                ]

        return screens
