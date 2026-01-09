# Changelogs for IADM


## v0.4 beta4 (#17)
+ Status command now also displays on which operating system the server runs on.
+ Added monitorlogs command, toggles monitoring for displaying any new logs into the console.

/ Changed viewfulllogs command functionality a little bit




## Fixes (#16)
+ Added IADM:ProcessArgs function

/ Adjusted loading sql for config a bit

* Fixed config sql data not loading

## v0.4 beta3 (#15)
+ Added new argtype value IADM_ARGTYPE_TBL altho it will be fully implemented in the future
+ Made config possible to edit and is viewable
+ Added logging config
+ Added SQL for config (be aware that this only accepts non-identical id's even from different categories!)
+ Logging for certain types can now be toggled!
+ Added IADM:GetSteamID64 function (in case if the player using the command is not valid when trying to grab steamid64)

- Remove the lastmodified key from iadm_groups SQL table (Duplicate of timemodified)

* Fixed sql error on (key case differences)


## v0.4 beta2 (#14)
+ Added IADM_GROUP_POWER_GODMODE, set at 1 million powerlevel. Commands with this powerlevel requirement require you to have IADM GODMODE ENABLED.
+ Added a Chat Mute check for players.
+ Added load time check for players.

+ Expanded "viewlogs" command, now allows you to view recently logged events by action
+ Added "viewfulllogs" command, allows you to view any logged events that took place on the server, even outside the current session.
+ Added "deletelogs" command. Currently, this deletes the entire logs. Only if you want to save some space and don't care about the history.
+ Added "cleardecals" command, cleans up all clientside decals and ragdolls.

+ Added table for RecentLogsByAction. Same as RecentLogs, except it also logs.
+ Added svstart logging event, logs every time when the server starts up/loads a new map.
+ Added svstop logging event, logs every time when the server shuts down. WARNING: It is not logged if the server is force closed or if the server crashes.
+ Added botspawn logging event, same as plrconnect but for bots only.
+ Added plrinitspawn logging event, logs once the player spawns in the first time in their current session.
+ Added plrloadingend logging event, logs once the player has fully loaded!
+ Added botkick logging event, logs once the bot player is kicked from the server!

/ ArgType TIME should work now, but don't expect it to be functional as intended<br>
/ ArgType BOOL now works<br>
/ IADM:LogAction will be registered as an empty function if the logs module is not enabled.<br>
/ Foreign Keys should now always remain enabled (I hope this works)<br>
/ Changed some text for concommand iadm_reset_database<br>
/ Changed logs table column from "type" to "action"<br>
/ Changed playerdeath logging event a bit<br>
/ Changed plrconnect event to only log for non-bot players<br>
/ Changed plrdisconnect event to only log for non-bot players<br>

* Fixed Module ID's having ".lua" at the end
* Fixed being unable to target yourself with commands that usually require higher power level to use
* Fixed carg.min and carg.max not working
* Fixed SQL table issue on sv_hooks.lua:19
* Fixed the setgroup command
* Fixed ban command not working
* (Temporary fix) Fixed ban reasons not displaying bannedbyname and bannedbyid correctly.
* Fixed being able to demote yourself, which could result in losing important permissions!


## v0.4 beta1 (#13)
+ Added logs module, a real-time logging module tracking player actions. Currently it logs the following: 
player deaths, player connect, player disconnect, player say, 
spawnprop, spawnragdoll, spawneffect, spawnnpc, spawnsent, spawnvehicle, spawnswep, giveswep 
and toolgun usage<br>
+ Add viewlogs command, lets you view recently logged events that took place in current session<br>
+ Added 3 global echocolors, mostly for logging.<br>

/ Changed Godmode text a bit<br>

* Fixed suggesting unavailable commands upon attempting to run an unknown command<br>
* Fixed groups module not working as intended<br>
* Fixed being able to delete "user" group<br>


! WARNING: Srlion's Hook Library is required for this module, otherwise expect lua errors and logging events failing!<br>


# v0.3.1 (#12)
+ Added 2 echo colors (warn, timestamp)<br>
+ Added a text on help command if a command is Dangerous (Mostly server management commands counts, or something that can give player pretty much ability to control nearly the entire server)<br>
+ Added IADM GodMode (Allows the player to use commands without any powerlevel restrictions. Only usable by the server host.)<br>
+ Added 1 alias for kill and skill command<br>

/ Updated the DOCUMENTATION.md and README.md file (on github)<br>
/ Changed the behavior of loading modules a bit. (for devs: you no longer need to put MODULE.ID everytime in a module file but you must return the MODULE table)<br>
/ Improved autocomplete on iadm concommand, again. Should work correctly now<br>
/ Bring command now only targets 1 player.<br>

* Fixed groupmodify command only changing the powerlevel attribute<br>


### v0.3 Hotfix2 (#11)
* Fix the "iadm" concommand not working (bruh)<br>

### v0.3 Hotfix1 (#10)
+ Added few additional checks for IADM:CmdCanTarget function<br>
+ Add CanTarget checks to autocomplete function in "iadm" console command<br>

* Fixed being unable to target yourself while using a command<br>

# v0.3 (#9)
+ Added groupslist commmand, prints out a list of groups in descending order of powerlevel<br>
+ Added goto commmand, teleports to the player.<br>

+ Added data networking between server and client<br>
+ Added PLAYER:GetGroupPowerLevel() function for checking player group's power level<br>


* Fixed IADM:Message function on client when trying to print a message in chat<br>
* Fixed PLAYER:GetIADMSessionTime() returning a negative value<br>

/ Significantly improved autocomplete results for console command "iadm"<br>

! Lua folder total size -> 66.6 KB<br>

## v0.3 beta4 (#8):
+ Added infammo command, gives a target infinite ammo by setting their ammo equal to weapon's clip size if ammo reserve is lower than clip size, or also constantly setting weapon's ammo to the max.<br>
+ Added groupdel command, deletes an usergroup.<br>
+ Added groupmodify command, edits an usergroup.<br>
+ Added setgroup command, sets an usergroup for another player.<br>
+ Added map command (again)<br>

+ Added BOOL arg type for commands<br>

/ Data loading from SQL should fully work now.<br>


## v0.3 beta3 (#7):
+ Added groupadd command, adds a group with name and powerlevel specified.

+ Added PowerLevel and usergroups management. Determines the power level for the user/group.
+ Added PLAYER:GetIADMSteamID64(), function only added just in case of any player bots being used for the admin mod.

/ Group module is now fully usable.
/ Commands now need to have a minimum reached amount of power level in order to use them.
/ Small changes to core "iadm" console command.
/ iadm_reset_database should work correctly now, also added a pass check that randomizes itself.

## v0.3 beta2 (#6):
+ Added SQL loading functionality.
+ Added PLAYER:GetIADMSessionTime() function
+ Added iadm_reset_database console command, it only restarts the map. Only usable by the server host.
In the future version, this concommand deletes the entire database and restarts the map.

- Removed bhop

/ PlayerInit is no longer called for player bots.
/ On server shutdown/map change, save player data.

## v0.3 beta1 (#5):
+ Added explode command, explodes the target. Violently.
+ Added strip command, removes all weapons from the target.
+ Added bring command, brings the target to you.
+ Added ban command, bans the target for specified amount.
+ Added steamid command, prints out the target's steamid and steamid64.
+ Added time arg type for commands, unfortunately doesn't do anything *yet*

+ Added a new prefix (/)
+ Added config
+ Added SQL Database (players, bans, groups)
+ Added bans
+ Added bhop (mistake)

- Removed map command (mistake again)

/ Slightly modified the status command
/ Improved ents arg type now

! Changes made by mistake were not meant to be included in the admin mod.
! Bhop is reverted in v0.3 beta2, map command deletion is reverted in v0.3 beta3.

### v0.2 hotfix 1 (#4):
* Fixed version

# Update v0.2 (#3):
+ Added 4 new commands: hp, entinfo, restart, map
+ Added globals

* Vastly improved and fixed command usages via console and chat


# HOTFIX 1 (#2):
* Fix errors for commands not being executed if received net message for using command from client
* Fix the version

Initial Release - v0.1
+ Basic commands functionality
+ Basic permissions command check system
+ 13 commands, including: help, status, lua, kill, skill, ignite, unignite, teleport, kick, tsay, csay, noclip and cleanup
+ Usable commands from chat

! There is no database nor any kind of usergroup management yet.
! This will be added in v0.3 release.

