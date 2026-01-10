local IADM = IADM
local allplys = player.GetAll

local cmd = IADM:AddCommand("help", function(caller, chat, cmd)
    if not isstring(cmd) then
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "---- ", IADM_ECHOCOLOR_ARG2, "Incomprehensibly Advanced Distributed Management Mod", IADM_ECHOCOLOR_TEXT, " ----")
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "This server uses ", IADM_ECHOCOLOR_PREFIX, "IADM", IADM_ECHOCOLOR_TEXT, " Admin Mod (v", IADM_ECHOCOLOR_ARG1, tostring(IADM.Version), IADM_ECHOCOLOR_TEXT, ") by ", IADM_ECHOCOLOR_ARG2, IADM.Author)
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "An admin mod independent from ULX made from scratch.")
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Thank you for using the IADM addon!")

        return
    end

    local c = IADM.Commands[cmd]
    if !c then
        for k,_ in SortedPairs(IADM.Commands) do
            if string.sub(k, 1, #cmd) ~= cmd then continue end
            IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Invalid command. Maybe you meant: ", IADM_ECHOCOLOR_ARG1, k, IADM_ECHOCOLOR_TEXT, "?")
            return
        end

		IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Invalid command.")
		return
    end

    local s = ""
    for count,arg in pairs(c.Args) do
        s = s..(arg.type == IADM_ARGTYPE_STR and (arg.optional and string.format("[%s]", arg.hint or "text") or string.format("<%s>", arg.hint or "text")) or "")
    end

    IADM:MessageWPrefix(caller, chat, IADM_ECHOCOLOR_TEXT, "# "..(c.Name or cmd)..(c.Name and " ("..cmd..")" or "").."\n",
    IADM_ECHOCOLOR_ARG1, c.Desc or "",
    IADM_ECHOCOLOR_ARG1, string.format("\nUsage: %s%s %s", IADM:GetPrefix(), cmd, s),
    IADM_ECHOCOLOR_WARN, c.Dangerous and "\nDangerous command. Only allow this command to members you trust and if necessary." or "")
end)
cmd.Name = "Help"
cmd.Desc = "Understand the function of the command better."
cmd.Help = "iadm help [command]"
cmd.ChatArg = true
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="command", optional=true})


local gm = engine.ActiveGamemode()
local cmd = IADM:AddCommand("status", function(caller, chat)
    local col = IADM_ECHOCOLOR_TEXT
    local uptime, realtime = SysTime(), UnPredictedCurTime()
    local players = allplys()
    local admins = 0
    local bots = #player.GetBots()
    local maxplayers = game.MaxPlayers()
    local operating_os = system.IsWindows() and "Windows" or system.IsLinux() and "Linux" or system.IsOSX() and "OSX" or "NULL" 

    for _,ply in pairs(players) do
        if ply:IsAdmin() or ply:IsSuperAdmin() then
            admins = admins + 1
        end
    end

	local floor = math.floor
    IADM:Message(caller, chat, col, "--- SERVER STATUS ---")
    IADM:Message(caller, chat, col, string.format("OS: %s", operating_os))
    IADM:Message(caller, chat, col, string.format("Uptime: %02d:%02d:%02d:%02d", floor(uptime/86400), floor((uptime/3600)%24), floor((uptime/60)%60), floor(uptime%60)), " ",
    string.format("(%02d:%02d:%02d:%02d on a current map)", floor(realtime/86400), floor((realtime/3600)%24), floor((realtime/60)%60), floor(realtime%60)))
    IADM:Message(caller, chat, col, string.format("Players: %d/%d%s", #players, maxplayers,
    (admins ~= 0 or bots ~= 0) and string.format(" (%s%s)",
    admins ~= 0 and string.format("%d admin%s"..(bots == 0 and " online" or ","), admins, admins ~= 1 and "s" or "") or "",
    bots ~= 0 and string.format((admins == 0 and "" or " ").."%d bot%s online", bots, bots ~= 1 and "s" or "") or "") or "")
    or "") -- how many of the [or ""] do i have to add?!?!?

	IADM:Message(caller, chat, col, string.format("Map: %s", game.GetMap()))
    IADM:Message(caller, chat, col, string.format("Gamemode: %s (%s)", GAMEMODE.Name or "Unknown", gm))
end)
cmd.Name = "Status"
cmd.Desc = "Check the server status."
cmd.ChatArg = true

