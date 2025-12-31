util.AddNetworkString("iadm_command")
util.AddNetworkString("iadm_printmsg")
util.AddNetworkString("iadm_csay")
util.AddNetworkString("iadm_playerusecmd")
util.AddNetworkString("iadm_groups")
util.AddNetworkString("iadm_playerinit")
util.AddNetworkString("iadm_syncdata")

net.Receive("iadm_command", function(len, pl)
    local cmd = net.ReadString()
    local args = net.ReadTable()
	
	local ctbl = IADM.Commands[cmd]
	if !ctbl then return end
    if !pl:IsValid() then return end

    if !IADM:CanUseCommand(pl, cmd) then
        IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "Insufficient permissions to use ", IADM_ECHOCOLOR_ERROR_ARGVAR, cmd, IADM_ECHOCOLOR_ERROR, " command!")
        pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
        return ""
    end

    args = IADM:ProcessCmdArgs(pl, inchat, ctbl, args)

    if ctbl.ChatArg then
	    ctbl.Func(pl, false, unpack(args))
    else
    	ctbl.Func(pl, unpack(args))
    end
end)


if not IADM.ServerStartTime then
    IADM.ServerStartTime = SysTime()
end

IADM:AddHook("Initialize", "TrackServerStartTime", function()
    IADM.ServerInitTime = SysTime()
end, HOOK_MONITOR_HIGH)

local loadingsteamid64 = {}
gameevent.Listen("player_connect")
IADM:AddHook("player_connect", "OnPlayerConnectSteamID64", function(data)
    if data.bot then return end
    loadingsteamid64[util.SteamIDTo64(data.networkid)] = SysTime()
end)

gameevent.Listen("player_disconnect")
IADM:AddHook("player_disconnect", "OnPlayerDisconnectSteamID64", function(data)
    if data.bot then return end
    loadingsteamid64[util.SteamIDTo64(data.networkid)] = nil
end)

-- Player Initialization
net.Receive("iadm_playerinit", function(len, pl)
    local phasetoload = net.ReadUInt(8)

    if pl.IADM_InitPhase == 1 then
        hook.Run("IADMPlrInit", pl, math.Round(SysTime() - (loadingsteamid64[pl:SteamID64()] or IADM.ServerInitTime), 2), math.Round(SysTime() - IADM.ServerStartTime, 2))

        loadingsteamid64[pl:SteamID64()] = nil
    end
    if pl.IADM_InitPhase and pl.IADM_InitPhase == phasetoload then
        net.Start("iadm_playerinit")
        net.WriteUInt(phasetoload, 8)
        net.Send(pl)

        pl.IADM_InitPhase = phasetoload + 1
    end
end)

-- Data Syncing for players
net.Receive("iadm_syncdata", function(len, pl)
    local datatosync = net.ReadString()

    if datatosync and IADM.RegisteredSyncData[datatosync] then
        IADM.RegisteredSyncData[datatosync](ply, len)
    end
end)
