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
            break
        end
    end

    local s = ""
    for count,arg in pairs(c.Args) do
        s = s..(arg.type == IADM_ARGTYPE_STR and (arg.optional and string.format("[%s]", arg.hint or "text") or string.format("<%s>", arg.hint or "text")) or "")
    end

    IADM:MessageWPrefix(caller, chat, IADM_ECHOCOLOR_TEXT, "# "..(c.Name or cmd)..(c.Name and " ("..cmd..")" or "").."\n",
    IADM_ECHOCOLOR_ARG1, c.Desc or "",
    IADM_ECHOCOLOR_ARG1, c.Help and string.format("\nUsage: %s%s %s", IADM.Prefix, cmd, s) or "")
end)
cmd.Name = "Help"
cmd.Desc = "Understand the function of the command better."
cmd.Help = "iadm help [command]"
cmd.ChatArg = true
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="command", optional=true})


local gm = engine.ActiveGamemode()
local cmd = IADM:AddCommand("status", function(caller, chat)
    local col = Color(176, 237, 92)
    local uptime, realtime = SysTime(), UnPredictedCurTime()
    local players = allplys()
    local admins = 0
    local maxplayers = game.MaxPlayers()

    for _,ply in pairs(players) do
        if ply:IsAdmin() or ply:IsSuperAdmin() then
            admins = admins + 1
        end
    end


    IADM:Message(caller, chat, col, "--- SERVER STATUS ---")
    IADM:Message(caller, chat, col, string.format("Uptime: %02d:%02d:%02d:%02d", (uptime/86400), (uptime/3600)%24, (uptime/60)%60, uptime%60), " ",
    string.format("(%02d:%02d:%02d:%02d on a current map)", (realtime/86400), (realtime/3600)%24, (realtime/60)%60, realtime%60))
    IADM:Message(caller, chat, col, string.format("Players: %d/%d (%d admin%s online)", #players, maxplayers, admins, admins ~= 1 and "s" or ""))
    IADM:Message(caller, chat, col, string.format("Map: %s", game.GetMap()))
    IADM:Message(caller, chat, col, string.format("Gamemode: %s (%s)", GAMEMODE.Name or "Unknown", gm))
end)
cmd.Name = "Status"
cmd.Desc = "Check the server status."
cmd.ChatArg = true

