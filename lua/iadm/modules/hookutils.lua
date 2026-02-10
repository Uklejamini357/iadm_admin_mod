MODULE.ID = "hookutils"
MODULE.Name = "Hook utils"
MODULE.Description = "Groups"
MODULE.Required = true

return MODULE, function(MODULE)
    IADM:AddHook("PhysgunPickup", "PlayerPickup", function(pl, ent)
        if pl:IsAdmin() and ent:IsPlayer() then
            return true
        end
    end, HOOK_HIGH)

    IADM:AddHook("OnPhysgunPickup", "PlayerPickup", function(pl, ent)
        if ent:IsPlayer() then
            ent:SetMoveType(MOVETYPE_NONE)
            ent:SetVelocity(-ent:GetVelocity())
        end
    end)

    IADM:AddHook("PhysgunDrop", "PlayerDrop", function(pl, ent)
        if ent:IsPlayer() then
            ent:SetMoveType(MOVETYPE_WALK)
        end
    end)
end
