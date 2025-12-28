# Documentation for using IADM



## Commands
### CORE
iadm help <command> - Shows instructions for the specified command. If not specified, shows the intro command.
iadm status - Displays server information (Uptime, players, current map and gamemode)

### Dev
[!] iadm lua <code> - Executes a lua code on the server.
iadm entinfo <ent> - Gets information about the targetted entity (classname, hp/maxhp, weapon + ammo)

### Fun
iadm kill <players> - Kills targets.
iadm explode <players> <explosionlevel default=1> - Explodes players. Higher values result in much more violent explosion.
iadm skill <players> - Silently kills targets.
iadm strip <players> - Removes weapons for the target(s).
iadm hp <players> <hp> - Sets target(s) health to the specified amount.
iadm ignite <entities> <duration default=300> - Ignites targets.
iadm unignite <entities> - Extinguishes targets.

