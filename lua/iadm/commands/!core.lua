local IADM = IADM
local allplys = player.GetAll

local cmd = IADM:AddCommand("help", function(caller, chat, cmd)
    local col1 = Color(127, 207, 126)
    local col2 = Color(83, 234, 196)
    local col_blue = Color(101, 151, 237)
    local col_purple = Color(138, 97, 226)

    if not isstring(cmd) then
        IADM:Message(caller, chat, col1, "---- ", col_blue, "Incomprehensibly Advanced Distributed Management Mod", col1, " ----")
        IADM:Message(caller, chat, col1, "This server uses ", col_purple, "IADM", col1, " Admin Mod (v", col2, tostring(IADM.Version), col1, ") by ", col_blue, IADM.Author)
        IADM:Message(caller, chat, col1, "An admin mod independent from ULX made from scratch.")
        IADM:Message(caller, chat, col1, "Thank you for using the IADM addon!")

        return
    end

    local c = IADM.Commands[cmd]
    if c then
        local s = ""
        for count,arg in pairs(c.Args) do
            s = s..(arg.type == "StrArg" and (arg.optional and string.format("[%s]", arg.hint or "text") or string.format("<%s>", arg.hint or "text")) or "")
        end

        IADM:MessageWPrefix(caller, chat, col1, "# "..(c.Name or cmd)..(c.Name and " ("..cmd..")" or "").."\n",
        col2, c.Desc or "",
        col2, c.Help and string.format("\nUsage: %s%s %s", IADM.Prefix, cmd, s) or "")
    elseif not c then
        for k,_ in SortedPairs(IADM.Commands) do
            if string.sub(k, 1, #cmd) ~= cmd then continue end
            IADM:Message(caller, chat, col1, "Invalid command. Maybe you meant: ", col2, k, col1, "?")
            break
        end
    end
end)
cmd.Name = "Help"
cmd.Desc = "Understand the function of the command better."
cmd.Help = "iadm help [command]"
cmd.ChatArg = true
cmd:AddArgument({type="StrArg", hint="command", optional=true})


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

