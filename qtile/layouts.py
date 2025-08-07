from libqtile import layout


class Layouts:
    def __init__(self):
        self.default = {
            "border_width": 2,
            "margin": 8,
            "border_focus": "#fd7b83",
            "border_normal": "#9b9691",
        }

    def init_layouts(self):
        """
        Returns the layouts variable
        """
        layouts = [
            layout.Max(**self.default),
            layout.MonadTall(**self.default),
            layout.floating.Floating(**self.default),
            layout.TreeTab(
                font="Ubuntu",
                fontsize=10,
                sections=["FIRST", "SECOND", "THIRD", "FOURTH"],
                section_fontsize=10,
                border_width=2,
                bg_color="#4e4c4a",  # Your bg color
                active_bg="#fd7b83",  # Your red color for active/focused tab
                active_fg="#4e4c4a",  # Your bg color for active text (contrast)
                inactive_bg="#9b9691",  # Your grey color for inactive tabs
                inactive_fg="#e2d1cf",  # Your fg color for inactive text
                urgent_bg="#fda987",  # Your orange color for urgent tabs
                urgent_fg="#4e4c4a",  # Your bg color for urgent text
                padding_left=0,
                padding_x=0,
                padding_y=4,
                section_top=6,
                section_bottom=6,
                level_shift=5,
                vspace=3,
                panel_width=140,
                margin=8,
            ),
            # layout.Stack(num_stacks=2),
            # Try more layouts by unleashing below layouts.
            # layout.Bsp(),
            # layout.Columns(),
            # layout.Matrix(),
            # layout.MonadWide(**self.default),
            # layout.RatioTile(),
            # layout.Tile(),
            # layout.VerticalTile(),
            # layout.Zoomy(),
        ]
        return layouts
