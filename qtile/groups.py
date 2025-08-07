from libqtile.config import Group, ScratchPad, DropDown, Match
from icons import group_icons


class CreateGroups:
    groups = {
        "icons": group_icons,
        "spawns": [
            None,
            None,
            None,
            None,
            "spotify",
            None,
            None,
            None,
        ],
        # Define which applications should go to which workspace
        "matches": [
            [  # Workspace 1 - Work Browser (Brave)
                Match(wm_class=["brave-browser", "brave", "Brave-browser"]),
                Match(title=["Brave"]),
            ],
            [  # Workspace 2 - VSCode
                Match(wm_class=["code", "code-oss", "VSCodium", "Code"]),
                Match(title=["Visual Studio Code"]),
            ],
            [  # Workspace 3 - Terminal/Command Line
                Match(wm_class=["alacritty", "Alacritty"]),
                Match(wm_class=["terminator", "Terminator"]),
                Match(wm_class=["gnome-terminal", "Gnome-terminal"]),
                Match(wm_class=["xterm", "XTerm"]),
                Match(wm_class=["kitty", "Kitty"]),
                Match(title=["Terminal"]),
            ],
            [  # Workspace 4 - Videos
                Match(wm_class=["vlc", "VLC"]),
                Match(wm_class=["mpv", "MPV"]),
                Match(wm_class=["totem", "Totem"]),
                Match(wm_class=["mplayer", "MPlayer"]),
                Match(wm_class=["smplayer", "SMPlayer"]),
                Match(title=["VLC media player", "mpv"]),
            ],
            [  # Workspace 5 - Spotify
                Match(wm_class=["spotify", "Spotify"]),
                Match(title=["Spotify"]),
            ],
            [  # Workspace 6 - Personal Browser (Brave - different instance or windows)
                # You might want to use a different browser for personal use
                # or use Brave with different profiles/windows
                Match(wm_class=["firefox", "Firefox"]),
                Match(wm_class=["chromium", "Chromium"]),
                Match(title=["Mozilla Firefox", "Chromium"]),
            ],
            [  # Workspace 7 - File Explorer
                Match(wm_class=["thunar", "Thunar"]),
                Match(wm_class=["dolphin", "Dolphin"]),
                Match(wm_class=["nautilus", "Nautilus"]),
                Match(wm_class=["pcmanfm", "PCManFM"]),
                Match(title=["File Manager", "Files"]),
            ],
            [],  # Workspace 8 - No rules (catch-all for everything else)
        ],
    }

    def init_groups(self):
        """
        Return the groups of Qtile
        """
        groups = []
        for idx, (name, spawn, matches) in enumerate(
            zip(self.groups["icons"], self.groups["spawns"], self.groups["matches"])
        ):
            groups.append(Group(name, layout="monadtall", spawn=spawn, matches=matches))

        # Add scratchpad group
        groups.append(
            ScratchPad(
                "scratchpad",
                [
                    DropDown(
                        "term",
                        "alacritty --config-file /home/coen/.config/qtile/scratchpad_alacritty.toml",
                        width=0.6,
                        height=0.7,
                        x=0.2,
                        y=0.1,
                        opacity=1.0,
                    ),
                ],
            )
        )

        return groups
