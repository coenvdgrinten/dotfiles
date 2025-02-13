import os
from libqtile import bar, widget
from libqtile.lazy import lazy
from libqtile.config import Screen

from functions import PWA
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

        self.termite = "termite"

    def init_widgets_list(self):
        '''
        Function that returns the desired widgets in form of list
        '''
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
                highlight_method='block',
                urgent_alert_method='block',
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
                foreground=self.colors["fg"],
                background=self.colors["bg"],
                padding=0
            ),
            widget.TextBox(
                text='',
                foreground=self.colors["blue"],
                background=self.colors["bg"],
                padding=-7,
                fontsize=40
            ),
            widget.BatteryIcon(
                foreground=self.colors["fg"],
                background=self.colors["blue"],
                theme_path="/home/coen/.config/qtile/icons/battery_theme",
                update_interval=5,
                padding=2,
            ),
            widget.Battery(
                foreground=self.colors["fg"],
                background=self.colors["blue"],
                update_interval=5,
                padding=5,
            ),
            widget.TextBox(
                text='',
                foreground=self.colors["red"],
                background=self.colors["blue"],
                padding=-7,
                fontsize=40
            ),
            widget.TextBox(
                text="",
                foreground=self.colors["black"],
                background=self.colors["red"],
                padding=4,
                fontsize=14
            ),
            widget.Memory(
                foreground=self.colors["black"],
                background=self.colors["red"],
                mouse_callbacks={'Button1': lambda qtile: qtile.cmd_spawn(
                    self.termite + ' -e htop')},
                padding=7
            ),
            widget.TextBox(
                text='',
                foreground=self.colors["orange"],
                background=self.colors["red"],
                padding=-7,
                fontsize=40
            ),
            widget.TextBox(
                text="  ",
                foreground=self.colors["black"],
                background=self.colors["orange"],
                padding=0,
                mouse_callbacks={
                    "Button1": lambda qtile: qtile.cmd_spawn("pavucontrol")}
            ),
            widget.Volume(
                foreground=self.colors["black"],
                background=self.colors["orange"],
                padding=5
            ),
            widget.TextBox(
                text='',
                foreground=self.colors["yellow"],
                background=self.colors["orange"],
                padding=-7,
                fontsize=40
            ),
            widget.CurrentLayoutIcon(
                custom_icon_paths=[os.path.expanduser(
                    "~/.config/qtile/icons")],
                foreground=self.colors["black"],
                background=self.colors["yellow"],
                padding=0,
                scale=0.7
            ),
            widget.CurrentLayout(
                foreground=self.colors["black"],
                background=self.colors["yellow"],
                padding=5
            ),
            widget.TextBox(
                text='',
                foreground=self.colors["white"],
                background=self.colors["yellow"],
                padding=-7,
                fontsize=40
            ),
            widget.Clock(
                foreground=self.colors["black"],
                background=self.colors["white"],
                mouse_callbacks={
                    "Button1": lambda qtile: qtile.cmd_spawn(PWA.calendar())},
                format="%B %d  [ %H:%M ]"
            ),
            widget.Sep(
                linewidth=0,
                padding=10,
                foreground="#a4a3a9",
                background="#a4a3a9",
            ),
        ]
        return widgets_list

    def init_widgets_screen(self):
        '''
        Function that returns the widgets in a list.
        It can be modified so it is useful if you  have a multimonitor system
        '''
        widgets_screen = self.init_widgets_list()
        return widgets_screen

    def init_widgets_screen2(self):
        '''
        Function that returns the widgets in a list.
        It can be modified so it is useful if you  have a multimonitor system
        '''
        widgets_screen2 = self.init_widgets_screen()
        return widgets_screen2

    def init_screen(self):
        '''
        Init the widgets in the screen
        '''
        return [Screen(top=bar.Bar(widgets=self.init_widgets_screen(), opacity=1.0, size=22)),
                Screen(top=bar.Bar(
                    widgets=self.init_widgets_screen(), opacity=1.0, size=22))
                ]
