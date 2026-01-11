local timetoload
hook.Add("InitPostEntity", "IADM.PlayerReady", function()
    timetoload = SysTime()

    net.Start("iadm_playerinit")
    net.WriteUInt(1, 8)
    net.SendToServer()
end, PRE_HOOK)

net.Receive("iadm_playerinit", function(len)
    local pl = LocalPlayer()
    local loadedphase = net.ReadUInt(8)

    local inittbl = IADM.InitSyncData[loadedphase]
    if inittbl then
        IADM:MessageWPrefix(LocalPlayer(), false, IADM_ECHOCOLOR_TEXT, "Received init data packets #", loadedphase)
    else
        IADM:MessageWPrefix(LocalPlayer(), true, IADM_ECHOCOLOR_ERROR, "Error receiving data packets #", IADM_ECHOCOLOR_ERROR_ARGVAR, loadedphase, IADM_ECHOCOLOR_ERROR, "!")
        IADM:MessageWPrefix(LocalPlayer(), true, IADM_ECHOCOLOR_ERROR, "Let the admin or developer know about it because this shouldn't be happening!")
    end

    if IADM.InitSyncData[loadedphase+1] then
        net.Start("iadm_playerinit")
        net.WriteUInt(loadedphase+1, 8)
        net.SendToServer()
    else
        timetoload = SysTime()-timetoload
        IADM:MessageWPrefix(LocalPlayer(), false, IADM_ECHOCOLOR_TEXT, "Took ", IADM_ECHOCOLOR_ARG1, math.Round(timetoload, 3), IADM_ECHOCOLOR_TEXT, "s to load!")
    end
end)
