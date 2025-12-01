local allplys = player.GetAll

local cmd = IADM:AddCommand("teleport", function(caller, target)
    local col = Color(176, 237, 92)

    if target:Alive() then
        target:SetPos(caller:GetEyeTrace().HitPos+Vector(0,0,20))
        target:DropToFloor()
        target:SetVelocity(-target:GetVelocity())
        if caller ~= target then
            IADM:MessageWPrefix(allplys(), true, col, "Teleported ", Color(255,0,0), target:Nick(), col, "!")
        end
    else
        IADM:MessageWPrefix(allplys(), true, col, Format("%s are dead!", caller == target and "You" or target:Nick()))
    end
end)
cmd.Name = "Teleport"
cmd.Desc = "Teleports the player to where you are looking."
cmd.Aliases = {"tp", "tele"}
cmd.PermsRequire = "admin"
cmd:AddArgument({type="PlrArg", default="^"})
