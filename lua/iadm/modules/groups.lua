local MODULE_NAME = "Groups"
local MODULE = {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.Name = MODULE_NAME
MODULE.Description = "Main module for managing groups"
MODULE.Required = true

if !IADM_MODULE_SHOULDINCLUDE then return MODULE end


if not IADM.UserGroups then
    IADM.UserGroups = {
        ["superadmin"] = {powerlevel = IADM_GROUP_POWER_SUPERADMIN, isadmin=true, issuperadmin=true},
        ["admin"] = {powerlevel = IADM_GROUP_POWER_ADMIN, isadmin=true, issuperadmin=false},
        ["user"] = {powerlevel = IADM_GROUP_POWER_USER, isadmin=false, issuperadmin=false}
    }
end


if CLIENT then
    IADM:RegisterInitDataSync("groups", function(_, pl, tbl)
        IADM.UserGroups = tbl
    end)

    IADM:RegisterDataSync("groups", function(_, pl, tbl)
        IADM.UserGroups = tbl
    end)
end




local player = FindMetaTable("Player")
if not player then return end

function player:IsAdmin()
    local usergroup = IADM.UserGroups[self:GetUserGroup()]
    return usergroup.isadmin or self:IsSuperAdmin()
end

function player:IsSuperAdmin()
    local usergroup = IADM.UserGroups[self:GetUserGroup()]
    return usergroup.issuperadmin
end

return MODULE
