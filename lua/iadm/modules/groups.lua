local MODULE_NAME = "Groups"
local MODULE = {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.ID = "groups"
MODULE.Name = MODULE_NAME
MODULE.Required = true

-- if !MODULE_INCLUDE then return end

if !SERVER then return end
IADM:AddHook("PlayerInitialSpawn", "PlayerInit", function(pl)
end, PRE_HOOK)

