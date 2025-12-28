# Changelogs for IADM

# v0.3 (#9)
+ Added groupslist commmand, prints out a list of groups in descending order of powerlevel
+ Added goto commmand, teleports to the player. Can target everyone.

+ Added data networking between server and client
+ Added PLAYER:GetGroupPowerLevel() function for checking player group's power level


* Fixed IADM:Message function on client when trying to print a message in chat
* Fixed PLAYER:GetIADMSessionTime() returning a negative value

/ Significantly improved autocomplete results for console command "iadm"

! Lua folder total size -> 66.6 KB

## v0.3 beta4 (#8):
+ Added infammo command, gives a target infinite ammo by setting their ammo equal to weapon's clip size if ammo reserve is lower than clip size, or also constantly setting weapon's ammo to the max.
+ Added groupdel command, deletes an usergroup.
+ Added groupmodify command, edits an usergroup.
+ Added setgroup command, sets an usergroup for another player.
+ Added map command (again)

+ Added BOOL arg type for commands

/ Data loading from SQL should fully work now.


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

