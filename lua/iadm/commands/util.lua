local col = Color(176, 237, 92)
local cmd = IADM:AddCommand("kick", function(caller, target, reason)
    reason = reason or "No reason provided"
    target:Kick(Format("Kicked %s.\nReason: \n%s", IsValid(caller) and Format("by %s (%s)", caller:Nick(), caller:SteamID64()) or "from the Server", reason))
    IADM:MessageWPrefix(caller, true, Color(255,0,0), target:Nick(), col, " was ", Color(255,0,0), "kicked", col, "! (", Color(255,128,0), reason, col, ")")
end)
cmd.Name = "Kick"
cmd.Desc = "Kicks the player with a reason."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLR})
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="reason", optional=true, varargs=true})

local cmd = IADM:AddCommand("csay", function(caller, text)
    -- local tbl = string.Explode("%#", text)

    net.Start("iadm_csay")
    net.WriteTable({text})
    net.Broadcast()
end)
cmd.Name = "Csay"
cmd.Desc = "Send a message to everyone displayed on the center screen."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="text", varargs=true})

local cmd = IADM:AddCommand("tsay", function(caller, text)
    -- local tbl = string.Explode("%#", text)

    IADM:Message(player.GetAll(), true, text)
end)
cmd.Name = "Tsay"
cmd.Desc = "Send a message to everyone in chat."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="text", varargs=true})

local cmd = IADM:AddCommand("noclip", function(caller, target)
    local on = caller:GetMoveType() ~= MOVETYPE_NOCLIP

    target:SetMoveType(on and MOVETYPE_NOCLIP or MOVETYPE_WALK)

    IADM:MessageWPrefix(caller, true, col, "Turned "..(on and "on" or "off").." noclip for ", Color(255,0,0), target:Nick(), col, "!")
end)
cmd.Name = "Noclip"
cmd.Desc = "Toggle noclip for players."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLR, default="^"})

local cmd = IADM:AddCommand("cleanup", function(caller)
    game.CleanUpMap(false, nil, function()
        IADM:MessageWPrefix(player.GetAll(), true, Color(255,255,0), caller:Nick(), col, " cleaned up the map!")
    end)
end)
cmd.Name = "Cleanup"
cmd.Desc = "Cleans up the map. This will not restart the round in some gamemodes."
cmd.PermsRequire = "admin"

local RunConsoleCommand = RunConsoleCommand
local cmd = IADM:AddCommand("restart", function(caller)
    IADM:MessageWPrefix(player.GetAll(), true, Color(255,255,0), caller:Nick(), col, " restarted the map!")

    RunConsoleCommand("changelevel", game.GetMap())
end)
cmd.Name = "Restart"
cmd.Desc = "Restarts the current map."
cmd.PermsRequire = "admin"

local cmd = IADM:AddCommand("map", function(caller, map)
    if !file.Exists(string.format("maps/%s.bsp", map), "GAME") then
        IADM:MessageWPrefix(player.GetAll(), true, Color(255,255,0), "Invalid map!")
        return
    end
    IADM:MessageWPrefix(player.GetAll(), true, Color(255,255,0), caller:Nick(), col, " changed the map to ", Color(255,0,0), map, "!")

    RunConsoleCommand("changelevel", map)
end)
cmd.Name = "Map"
cmd.Desc = "Forces the server to change to a specified map."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_STR})
