local MODULE_NAME = "Groups"
local MODULE = {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.ID = "groups"
MODULE.Name = MODULE_NAME
MODULE.Description = "Main module for managing groups"
MODULE.Required = true

if !IADM_MODULE_SHOULDINCLUDE then return end

if !SERVER then return end

if not IADM.UserGroups then
    IADM.UserGroups = {
        ["superadmin"] = {powerlevel = IADM_GROUP_POWER_SUPERADMIN},
        ["admin"] = {powerlevel = IADM_GROUP_POWER_ADMIN},
        ["user"] = {powerlevel = IADM_GROUP_POWER_USER}
    }
end

function IADM:AddGroup(name, powerlevel, createdby)
    if !isstring(createdby) or IsValid(createdby) then createdby = createdby:SteamID64() else return end

    local tbl = {
        powerlevel = powerlevel,
        createdby = createdby:SteamID64(),
        lastmodifiedby = os.time(),
        timecreated = os.time(),
        timemodified = os.time(),
    }
    IADM.UserGroups[name] = tbl

    sql.QueryTyped("INSERT INTO "..(IADM.DatabaseDir.."_"..id).."(name, powerlevel, createdby, lastmodifiedby, timecreated, timemodified) VALUES(?, ?, ?, ?, ?, ?)",
        name,
        powerlevel,
        createdby,
        tbl.lastmodifiedby,
        tbl.timecreated,
        tbl.timemodified
    )
end

function IADM:AddUserToGroup(id64, group, caller)
    local ply
    if !IADM.UserGroups[group] then return false, "This group doesn't exist!" end

    local ply = player.GetBySteamID64(id64)
    if IsValid(ply) then
        ply:SetUserGroup(group)
    end
    sql.QueryTyped("UPDATE "..IADM.DatabaseDir.."_users "..
        "SET groupname=? WHERE id=?",
        group,
        id64
    )
end

IADM:AddSQLDatabase("groups", function(id)
    sql.QueryTyped("CREATE TABLE IF NOT EXISTS "..(IADM.DatabaseDir.."_"..id).." ("..
        "name CHAR(63) PRIMARY KEY, "..
        "powerlevel SMALLINT, "..
        "createdby BIGINT, "..
        "lastmodifiedby TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "..
        "timecreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP, "..
        "timemodified TIMESTAMP DEFAULT CURRENT_TIMESTAMP "..
    ")")
end)

IADM:AddLoadSQL("groups", function(id)
    IADM.UserGroups = sql.QueryTyped("SELECT * FROM "..(IADM.DatabaseDir.."_"..id)..")")
end)
