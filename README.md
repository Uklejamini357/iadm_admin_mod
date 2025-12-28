# IADM - Incomprehensibly Advanced Distributed Management Mod
## Greatly Enhance your server management experience

A very powerful, independent from ULX and open-source administration tool designed for Garry's Mod servers.<br>
This addon aims to provide a great experience for managing servers with a new admin mod.<br>
Development begun in 29th November 2025.

#### Abbreviations:
> NYI: Not yet implemented<br>
> WIP: Work in Progress


### NOTICE:
This mod is currently at very early alpha stage and is not expected to work flawlessly.<br>
Use at your own risk.

### Required Dependencies:
- Srlion's Hook Library ([GitHub](https://github.com/Srlion/Hook-Library/)) ([Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1907060869))

### Features:
- ~~Addons: Any additional commands~~ (NYI)
- ~~Modules: Turn off any unnecessary features. Only the modules you really need!~~ (NYI)
- ~~Advanced logging system~~ (NYI)


### Modules:
- ~~Adverts: Display a repeated sequence of messages being displayed to everyone on the server.~~ (NYI)
- ~~ChatFilter: Prevent players from saying specific keywords and auto-punish them after certain amount of attempts.~~ (NYI)
- ~~Groups: Manage.~~ (NYI)
- HookUtils: Enable specific hook overrides. (WIP)
- ~~Logging: Log every player action in a log file. (Warning: Some logging options may be resource-intensive)~~ (NYI)
- ~~MOTD: Display a welcome message upon loading in successfully.~~ (NYI)
- ~~Teams: Sandbox teams like in ULX, but better!~~ (NYI)


# Questions and Answers

### How do I use this mod?
Simply type in "iadm" in console and add a space after it. You will notice a list of usable commands below the console command prompt.

### Missing permissions when using a command.
The command is likely restricted to be usable for admins only, or you are not superadmin.<br>

### Writing out full player names is a pain in the ass. Any other way to shorten it?
Sure. In most cases, you don't have to write out a full player nickname.<br>
To target yourself, you can always use ^<br>
To target a player under your crosshair, use @ (works on entities as well!)

### Why did you decide to make a new admin mod?
ULX felt too outdated, despite it being , lacked any versatile customization options. SAM, while being a simple mod, is a paid mod. Other alternatives like xAdmin lacked extensibility and FAdmin being DarkRP focused only. IADM on the other hand, will remain highly customizable and extensible with the help of toggleable modules, addons, etc.

### There is no UI for the mod yet. When will UI update be coming?
I have no plans for making UI yet. For now, stick to using console commands and chat commands.

### Why did you choose Srlion's Hook Library as a dependency?
It's super fast and versatile. Claims to be faster than ULib, too.

### Will this addon be paid?
Absolutely not. I have no intentions, nor any plans to make IADM a paid mod, as it will stick to being open source only.


# Roadmap for IADM:
> Note: This roadmap may not be 100% accurate.


v0.3: (CURRENT)
- Add SQL database
- Add UserGroups management
- Override ply:IsAdmin() and ply:IsSuperAdmin() functions
- Make lower ranked players unable to target commands on higher ranked players
- Add OverrideCanTarget and CanTarget extensive functionality
- Add data sync
- Implement more commands

v0.4:
- Add logging system
- Make addon more configurable with the config table
- More commands

v0.5:
- Add leveling module
- Make non-required modules toggleable
- More commands

v0.6:
- Add Whitelist module

v0.7:
- Add votes module
