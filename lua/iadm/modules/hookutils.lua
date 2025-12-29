local MODULE_NAME = "Hook Utils"
local MODULE = {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.Name = MODULE_NAME
MODULE.Required = true

if !IADM_MODULE_SHOULDINCLUDE then return MODULE end
AddCSLuaFile()

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

return MODULE
