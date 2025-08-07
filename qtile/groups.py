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
            [],  # Workspace 1 - General
            [Match(wm_class=["firefox", "brave-browser", "chromium"])],  # Workspace 2 - Browsers
            [Match(wm_class=["code", "code-oss", "VSCodium"])],  # Workspace 3 - Coding
            [Match(wm_class=["thunar", "dolphin", "nautilus"])],  # Workspace 4 - Files
            [Match(wm_class=["spotify", "vlc", "mpv"])],  # Workspace 5 - Media
            [
                Match(wm_class=["discord", "telegram-desktop", "whatsapp-for-linux"])
            ],  # Workspace 6 - Communication
            [Match(wm_class=["libreoffice", "gimp", "inkscape"])],  # Workspace 7 - Productivity
            [Match(wm_class=["steam", "lutris", "minecraft"])],  # Workspace 8 - Games
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
