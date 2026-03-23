import re
import os
from libqtile.config import Group, ScratchPad, DropDown, Match

class CreateGroups:
    def __init__(self):
        # 1. Define IDs/Names for easier exclusion logic
        self.gemini_id = "crx_gdfaincndogidkdcdkhapmbffkckdkhn"
        self.personal_profile_name = "Personal"  # This must match your Brave Profile name

        self.group_config = [
            {
                "name": "a", 
                "label": "A  ", 
                "layout": "monadtall", 
                "matches": [
                ]
            },
            {
                "name": "b", 
                "label": "B 󰨞 ", 
                "layout": "treetab", 
                "matches": [
                    Match(wm_class=re.compile(r"^(code|code-oss|VSCodium|Code)$")),
                ]
            },
            {
                "name": "c", 
                "label": "C  ", 
                "layout": "treetab", 
                "matches": [
                    Match(wm_class=re.compile(r"^(alacritty|Alacritty|terminator)$")),
                ]
            },
            {
                "name": "d", 
                "label": "D  ", 
                "layout": "monadtall", 
                "matches": [
                    Match(wm_class=re.compile(r"^(vlc|VLC|mpv|MPV)$")),
                ]
            },
            {
                "name": "e", 
                "label": "E 󰓇 ", 
                "layout": "monadtall", 
                "matches": [
                    Match(wm_class=re.compile(r"^(spotify|Spotify)$")),
                ]
            },
            {
                "name": "f", 
                "label": "F  ", 
                "layout": "monadtall", 
                "matches": [
                    Match(wm_class=re.compile(r"^(firefox|Firefox)$")),
                ]
            },
            {
                "name": "g", 
                "label": "G  ", 
                "layout": "monadtall", 
                "matches": [
                    Match(wm_class=re.compile(r"^(thunar|Thunar|nautilus)$")),
                ]
            },
            {
                "name": "h", 
                "label": "H  ", 
                "layout": "monadtall", 
                "matches": [
                    # Match Gemini App
                    Match(wm_class=self.gemini_id),
                    Match(title="Google Gemini"),
                ]
            },
            {
                "name":"i",
                "label": "I 󰭹 ", 
                "layout": "monadtall", 
                "matches": [
                    Match(title="Zulip"),
                ]
            }
        ]

    def init_groups(self):
        groups = []
        for config in self.group_config:
            groups.append(Group(
                name=config["name"],
                label=config["label"],
                layout=config["layout"],
                matches=config.get("matches", None)
            ))

        groups.append(
            ScratchPad(
                "scratchpad",
                [
                    DropDown(
                        "term",
                        f"alacritty --config-file {os.path.expanduser('~/.config/qtile/scratchpad_alacritty.toml')}",
                        width=0.7,
                        height=0.6,
                        x=0.15,
                        y=0.0,
                        opacity=0.85,
                    ),
                ],
            )
        )

        return groups