local MODULE_NAME = "Groups"

local function OnFuncSuccess()
    IADM:SyncUserGroupsToClients()
end

function IADM:AddGroup(name, powerlevel, isadmin, issuperadmin, createdby)
    if IsValid(createdby) then createdby = createdby:GetIADMSteamID64()
    elseif type(createdby) ~= "string" then return false, "Invalid caller!" end

    local ostime = os.time()
    local tbl = {
        powerlevel = powerlevel,
        createdby = createdby,
        isadmin = isadmin,
        issuperadmin = issuperadmin,
        lastmodified = ostime,
        lastmodifiedby = createdby,
        timecreated = ostime,
        timemodified = ostime,
    }
    IADM.UserGroups[name] = tbl

    sql.QueryTyped("INSERT INTO "..(IADM.DatabaseDir.."_groups").."(name, powerlevel, isadmin, issuperadmin, createdby, lastmodifiedby, lastmodified, timecreated, timemodified) VALUES(?, ?, ?, ?, ?, ?, ?)",
        name,
        powerlevel,
        isadmin,
        issuperadmin,
        createdby,
        tbl.lastmodifiedby,
        tbl.lastmodified,
        tbl.timecreated,
        tbl.timemodified
    )

    OnFuncSuccess()

    return true
end

function IADM:RemoveGroup(name, caller)
    if IsValid(caller) then caller = caller:GetIADMSteamID64()
    elseif type(caller) ~= "string" then return false, "Invalid caller!" end

    if !IADM.UserGroups[name] then return false, "This group doesn't exist!" end
    IADM.UserGroups[name] = nil
    for _,ply in ipairs(player.GetAll()) do
        if !ply:IsUserGroup(name) then continue end
        ply:SetUserGroup("user")
    end

    local db = IADM.DatabaseDir.."_groups"
    sql.QueryTyped("DELETE FROM "..db.." WHERE name=?", name)

    local db = IADM.DatabaseDir.."_players"
    sql.QueryTyped("UPDATE "..db.." SET groupname='user' WHERE groupname=?", name)

    OnFuncSuccess()

    return true
end

function IADM:ModifyGroup(name, key, value, caller)
    if IsValid(caller) then caller = caller:GetIADMSteamID64()
    elseif type(caller) ~= "string" then return false, "Invalid caller!" end

    if not IADM.UserGroups[name] then return false, "Invalid group!" end

    if key == "powerlevel" then
        if isnumber(tonumber(value)) then
            IADM.UserGroups[name].powerlevel = tonumber(value)
            OnFuncSuccess()
            return true
        else
            return false, "Invalid number!"
        end
    end

    if key == "isadmin" then
        if isnumber(tonumber(value)) then
            IADM.UserGroups[name].powerlevel = tonumber(value)
            OnFuncSuccess()
            return true
        else
            return false, "Invalid number!"
        end
    end

    if key == "issuperadmin" then
        if isnumber(tonumber(value)) then
            IADM.UserGroups[name].powerlevel = tonumber(value)
            OnFuncSuccess()
            return true
        else
            return false, "Invalid number!"
        end
    end

    return false, "Invalid key!"
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
    local db = (IADM.DatabaseDir.."_"..id)

    sql.QueryTyped("CREATE TABLE IF NOT EXISTS "..db.." ("..
        "name CHAR(63) PRIMARY KEY, "..
        "powerlevel SMALLINT, "..
        "isadmin BOOLEAN, "..
        "issuperadmin BOOLEAN, "..
        "createdby BIGINT, "..
        "lastmodifiedby BIGINT, "..
        "lastmodified INT UNSIGNED, "..
        "timecreated INT UNSIGNED, "..
        "timemodified INT UNSIGNED"..
    ")")

    local ostime = os.time()
    local t = sql.QueryTyped("SELECT * FROM "..db)
    for id, tbl in pairs(IADM.UserGroups) do
        local shouldcreate = true
        for i=1,#t do
            if t[i] and t[i].name ~= id then continue end
            if t[i] and t[i].name == id then shouldcreate = false break end
        end

        if !shouldcreate then continue end

        sql.QueryTyped("INSERT INTO "..db.."(name, powerlevel, createdby, lastmodifiedby, lastmodified, timecreated, timemodified) "..
            "VALUES(?, ?, ?, ?, ?, ?, ?)",
            id,
            tbl.powerlevel,
            tbl.createdby or "0",
            tbl.lastmodifiedby or "0",
            tbl.lastmodified or ostime,
            tbl.timecreated or ostime,
            tbl.timemodified or ostime
        )
    end
end)

IADM:AddLoadSQL("groups", function(id)
    for count,rank in ipairs(sql.QueryTyped("SELECT * FROM "..(IADM.DatabaseDir.."_"..id))) do
        local r = rank.name
        rank.name = nil
        IADM.UserGroups[r] = rank
    end
end)

function IADM:SyncUserGroupsToClients(plys)
    local id
    local usergroups = {}
    plys = plys or player.GetHumans()

    for i,tbl in ipairs(IADM.RegisteredSyncData) do
        if tbl.id == "groups" then
            id = tbl.id
            break
        end
    end

    for name,group in pairs(IADM.UserGroups) do
        usergroups[name] = {
            powerlevel = group.powerlevel,
            isadmin = tobool(group.isadmin),
            issuperadmin = tobool(group.issuperadmin)
        }
    end

    if !id then return end

    net.Start("iadm_syncdata")
    net.WriteString(id)
    net.WriteTable(usergroups)
    net.Send(plys)
end

IADM:RegisterInitDataSync("groups", function(tbl, pl, ...)
    IADM:SyncUserGroupsToClients(pl)
end)

IADM:RegisterDataSync("groups", function(tbl, pl, ...)
    IADM:SyncUserGroupsToClients(pl)
end)
