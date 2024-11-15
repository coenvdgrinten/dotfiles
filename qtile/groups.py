from libqtile.config import Group
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
        ]
    } 

    def init_groups(self):
        """
        Return the groups of Qtile
        """
        #### First and last
        groups = [Group(name, layout="monadtall", spawn=self.groups["spawns"][idx]) if name == self.groups["icons"][0]
                  else Group(name, layout="monadtall", spawn=self.groups["spawns"][idx])
                  for idx, name in enumerate(self.groups["icons"])]
        return groups

