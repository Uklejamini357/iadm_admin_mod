local MODULE_NAME = "Logs"
local MODULE = IADM.Modules[MODULE_NAME] or {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.ID = "logs"
MODULE.Name = MODULE_NAME
MODULE.Description = "Logs actions on the server."
MODULE.Required = false

if !IADM_MODULE_SHOULDINCLUDE and !MODULE.Included then return MODULE end


return MODULE
