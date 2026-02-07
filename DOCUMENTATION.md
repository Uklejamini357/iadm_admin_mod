# Documentation for using IADM


Welcome to IADM! An independent, versatile, yet powerful admin mod.
This documentation helps you understand how to use this admin mod.
Please keep in mind that IADM is in early development stage and may still have issues. It is currently not recommended to use for public servers yet.



## 1. Commands
The commands are one of the key elements to this admin mod. These allow users, especially admins to execute specific action on the server. 

### CORE
- iadm help [command] - Shows instructions for the specified command. If not specified, shows the intro command.
- iadm status - Displays server information (Uptime, players, current map and gamemode)

### Dev
- [!] iadm lua [string] - Executes a lua code on the server.
- iadm entinfo [ent] - Gets information about the targetted entity (classname, hp/maxhp, weapon + ammo)

### Fun
- iadm kill [players] - Kills targets.
- iadm explode [players] [explosionlevel default=1] - Explodes players. Higher values result in much more violent explosion.
- iadm skill [players] - Silently kills targets.
- iadm strip [players] - Removes weapons for the target(s).
- iadm hp [players] [hp] - Sets target(s) health to the specified amount.
- iadm ignite [entities] [duration default=300] - Ignites targets.
- iadm unignite [entities] - Extinguishes targets.
- iadm infammo [players] [mode] - Gives the player infinite ammo.\nModes: 0 - disable, 1 - infinite reserve ammo, 2 - infinite reserve + clip ammo

### Groups
- iadm groupadd [name] [powerlevel] [isadmin] [issuperadmin] - Adds a new usergroup.
- [!] iadm groupdel [name] - Deletes an existing usergroup.
- iadm groupmodify [name] [key] [value] - Changes usergroup's attribute.
- iadm setgroup [player] [groupname] - Assigns a player to a new group.
- iadm groupslist - Displays a list of usergroups.

### Logs
- iadm viewlogs [logtype, default="all"] [page, default=1] - Views recent logs in the current session
- iadm viewfulllogs [logtype, default="all"] [page, default=1] - Views all the logs, even from different sessions.
- [!] iadm deletelogs [confirm] - Irreversibly deletes ALL logs. Cannot be used by anyone except the user in godmode and the server console.
- iadm monitorlogs [logtype] [toggle {on/off}] - Monitors logs. This command does not work for server host or server console.

### Teleport
- iadm teleport [player] - Teleports a player
- iadm goto [player] - Teleports to a player.
- iadm bring [players] - Changes usergroup's attribute.

### Util
- iadm kick [player] [reason] - Kicks a player.
- iadm ban [player] [time] [reason] - Bans a player for specified amount of time.
- iadm csay [text] - Displays a text on the center screen to everyone.
- iadm tsay [text] - Displays a chat message to everyone.
- iadm noclip [player] - Toggles noclip for the target.
- iadm map [map] - Cleans up the map.
- iadm restart - Restarts the map.
- iadm [player] - Prints out a player's steamid.

## 2. Config
Configuring the can be quite complex. Currently, it's quite limited too. In future there may be more configuration options.<br><br>

The command goes like this:<br>
> iadm_config [config category] [config option] [value]


## 3. UserGroups

UserGroups are a vital part of the admin mod. It helps especially who is a part of the staff team, etc. Thanks to the usergroup powerlevel system, it is more simple to use in general.

Note: While you can use commands on targetted player with equal to or lower than your power level, you can't target players with certain commands (especially kick, ban, mute, etc.) with their power level equal to or higher than yours.
