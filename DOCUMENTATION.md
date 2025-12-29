# Documentation for using IADM



## Commands
### CORE
iadm help [command] - Shows instructions for the specified command. If not specified, shows the intro command.
iadm status - Displays server information (Uptime, players, current map and gamemode)

### Dev
[!] iadm lua [string] - Executes a lua code on the server.
iadm entinfo [ent] - Gets information about the targetted entity (classname, hp/maxhp, weapon + ammo)

### Fun
iadm kill [players] - Kills targets.
iadm explode [players] [explosionlevel default=1] - Explodes players. Higher values result in much more violent explosion.
iadm skill [players] - Silently kills targets.
iadm strip [players] - Removes weapons for the target(s).
iadm hp [players] [hp] - Sets target(s) health to the specified amount.
iadm ignite [entities] [duration default=300] - Ignites targets.
iadm unignite [entities] - Extinguishes targets.
iadm infammo [players] [mode] - Gives the player infinite ammo.\nModes: 0 - disable, 1 - infinite reserve ammo, 2 - infinite reserve + clip ammo

### Groups
iadm groupadd [name] [powerlevel] [isadmin] [issuperadmin] - Adds a new usergroup.
iadm groupdel [name] - Deletes an existing usergroup.
iadm groupmodify [name] [key] [value] - Changes usergroup's attribute.
iadm setgroup [player] [groupname] - Assigns a player to a new group.
iadm groupslist - Displays a list of usergroups.

### Teleport
iadm teleport [player] - Teleports a player
iadm goto [player] - Teleports to a player.
iadm bring [players] - Changes usergroup's attribute.

### Util
iadm kick [player] [reason] - Kicks a player.
iadm ban [player] [time] [reason] - Bans a player for specified amount of time.
iadm csay [text] - Displays a text on the center screen to everyone.
iadm tsay [text] - Displays a chat message to everyone.
iadm noclip [player] - Toggles noclip for the target.
iadm map [map] - Cleans up the map.
iadm restart - Restarts the map.
iadm [player] - Prints out a player's steamid.

