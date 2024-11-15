def window_to_prev_group(qtile):
    i = qtile.groups.index(qtile.current_group)

    if qtile.current_window and i != 0:
        group = qtile.groups[i - 1].name
        qtile.current_window.togroup(group, switch_group=True)

def window_to_next_group(qtile):
    i = qtile.groups.index(qtile.current_group)

    if qtile.current_window and i != len(qtile.groups):
        group = qtile.groups[i + 1].name
        qtile.current_window.togroup(group, switch_group=True)

##### KILL ALL WINDOWS #####

def kill_all_windows(qtile):
    for window in qtile.current_group.windows:
        window.kill()

def kill_all_windows_minus_current(qtile):
    for window in qtile.current_group.windows:
        if window != qtile.current_window:
            window.kill()


class PWA:
    """Start applications directly."""
    
    def __init__(self):
        pass

    @staticmethod
    def rofi():
        return "rofi -show run"

    @staticmethod
    def spotify():
        return "spotify"
    
    @staticmethod
    def whatsapp():
        return "xdg-open 'https://web.whatsapp.com/'"
    
    @staticmethod
    def stmcubeide():
        return "~/st/stm32cubeide_1.16.0/stm32cubeide"

if __name__ == "__main__":
    print("This is an utilities module")
