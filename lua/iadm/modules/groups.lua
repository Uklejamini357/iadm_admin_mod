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
        ["superadmin"] = {powerlevel = IADM_GROUP_POWER_SUPERADMIN, isadmin=true, issuperadmin=true},
        ["admin"] = {powerlevel = IADM_GROUP_POWER_ADMIN, isadmin=true, issuperadmin=false},
        ["user"] = {powerlevel = IADM_GROUP_POWER_USER, isadmin=false, issuperadmin=false}
    }
end

function IADM:AddGroup(name, powerlevel, createdby)
    if IsValid(createdby) then createdby = createdby:GetIADMSteamID64()
    elseif type(createdby) ~= "string" then return false, "Invalid caller!" end

    local ostime = os.time()
    local tbl = {
        powerlevel = powerlevel,
        createdby = createdby,
        lastmodified = ostime,
        lastmodifiedby = createdby,
        timecreated = ostime,
        timemodified = ostime,
    }
    IADM.UserGroups[name] = tbl

    sql.QueryTyped("INSERT INTO "..(IADM.DatabaseDir.."_groups").."(name, powerlevel, createdby, lastmodifiedby, lastmodified, timecreated, timemodified) VALUES(?, ?, ?, ?, ?, ?, ?)",
        name,
        powerlevel,
        createdby,
        tbl.lastmodifiedby,
        tbl.lastmodified,
        tbl.timecreated,
        tbl.timemodified
    )
end

function IADM:AddUserToGroup(id64, group, caller)
    local ply
    if !IADM.UserGroups[group] then return false, "This group doesn't exist!" end

    local ply = player.GetBySteamID64(id64)
    local db = IADM.DatabaseDir.."_users"
    if IsValid(ply) then
        ply:SetUserGroup(group)
    else
        local dbply = sql.QueryTyped("SELECT * FROM "..db.." WHERE ID=?", id64)[1]
        if !dbply then return false, "This player does not exist!" end
    end

    sql.QueryTyped("UPDATE "..db.." "..
        "SET groupname=? WHERE id=?",
        group,
        id64
    )
    return true
end

IADM:AddSQLDatabase("groups", function(id)
    sql.QueryTyped("CREATE TABLE IF NOT EXISTS "..(IADM.DatabaseDir.."_"..id).." ("..
        "name CHAR(63) PRIMARY KEY, "..
        "powerlevel SMALLINT, "..
        "createdby BIGINT, "..
        "lastmodifiedby BIGINT, "..
        "lastmodified INT UNSIGNED, "..
        "timecreated INT UNSIGNED, "..
        "timemodified INT UNSIGNED"..
    ")")
end)

IADM:AddLoadSQL("groups", function(id)
    for count,rank in ipairs(sql.QueryTyped("SELECT * FROM "..(IADM.DatabaseDir.."_"..id))) do
        local r = rank.name
        rank.name = nil
        IADM.UserGroups[r] = rank
        print(r)
        PrintTable(rank)
    end
end)
