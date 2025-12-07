local MODULE_NAME = "Groups"
local MODULE = {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.ID = "groups"
MODULE.Name = MODULE_NAME
MODULE.Description = "Main module for managing groups"
MODULE.Required = true

if !IADM_MODULE_SHOULDINCLUDE then return end

if !SERVER then return end

IADM.UserGroups = {
    ["superadmin"] = {powerlevel = IADM_GROUP_POWER_SUPERADMIN},
    ["admin"] = {powerlevel = IADM_GROUP_POWER_ADMIN},
    ["user"] = {powerlevel = IADM_GROUP_POWER_USER}
}

IADM:AddSQLDatabase("groups", function(id)
    sql.QueryTyped("CREATE TABLE IF NOT EXISTS "..(IADM.DatabaseDir.."_"..id).." ("..
        "name CHAR(63) PRIMARY KEY, "..
        "powerlevel SMALLINT, "..
        "createdby BIGINT, "..
        "lastmodifiedby BIGINT, "..
        "timecreated INT, "..
        "timemodified INT "..
    ")")
end)
