local allplys = player.GetAll

local cmd = IADM:AddCommand("teleport", function(caller, target)
    if target:Alive() then
        target:SetPos(caller:GetEyeTrace().HitPos+Vector(0,0,20))
        target:DropToFloor()
        target:SetVelocity(-target:GetVelocity())
        if caller ~= target then
            IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Teleported ", Color(255,0,0), target:Nick(), IADM_ECHOCOLOR_TEXT, "!")
        end
    else
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, Format("%s are dead!", caller == target and "You" or target:Nick()))
    end
end)
cmd.Name = "Teleport"
cmd.Desc = "Teleports the player to where you are looking."
cmd.Aliases = {"tp", "tele"}
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLR, default="^"})

local cmd = IADM:AddCommand("bring", function(caller, target)
    if caller == target then
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_ERROR, "Error: ", IADM_ECHOCOLOR_ERROR_REASON, "You cannot bring ", IADM_ECHOCOLOR_ERROR_ARGVAR, "yourself", IADM_ECHOCOLOR_ERROR_REASON, "!")
        return
    end
    if target:Alive() then
        local aim = caller:GetAimVector()
        local ang = caller:EyeAngles()
        aim.z = 0
        ang.pitch = 0
        ang.yaw = ang.yaw - 180
        aim:Normalize()
        target:SetPos(caller:GetPos()+aim*50)
        target:SetVelocity(-target:GetVelocity())
        target:SetEyeAngles(ang)
        if caller ~= target then
            IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Teleported ", Color(255,0,0), target:Nick(), IADM_ECHOCOLOR_TEXT, "!")
        end
    else
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, Format("%s dead!", caller == target and "You are" or target:Nick().." is"))
    end
end)
cmd.Name = "Bring"
cmd.Desc = "Brings the target to you."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS, default="^"})
