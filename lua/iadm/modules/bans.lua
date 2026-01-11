local MODULE_NAME = "Bans"
local MODULE = IADM.Modules[MODULE_NAME] or {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.Name = MODULE_NAME
MODULE.Description = "Module for managing user bans"

if !IADM_MODULE_SHOULDINCLUDE and !MODULE.Included then return MODULE end

if !SERVER then return MODULE end

IADM:AddSQLDatabase("bans", function(id)
    sql.QueryTyped("CREATE TABLE IF NOT EXISTS "..(IADM.DatabaseDir.."_"..id).." ("..
        "id64 BIGINT PRIMARY KEY, "..
        "name CHAR(255), "..
        "banstart INT UNSIGNED, "..
        "banend INT UNSIGNED, "..
        "duration BIGINT, "..
        "reason VARCHAR(4096), "..
        "bannedby BIGINT, "..
        "bannedbyname CHAR(255)"..
    ")")
end)


function IADM:CanBeBanned(id64)
    local ply = player.GetBySteamID64(id64)
    if IsValid(ply) and ply:IsListenServerHost() then return false end

    return true
end

function IADM:AddBan(id64, reason, duration, bannedby)
    if IsValid(id64) then id64 = id64:SteamID64()
    elseif type(id64) ~= "string" then return false, "Invalid user!" end
    if IsValid(bannedby) then bannedby = bannedby:GetIADMSteamID64()
    elseif type(bannedby) ~= "string" and bannedby ~= NULL then return false, "Invalid user banning the target!" end

    if id64 == bannedby then return false, "You cannot ban yourself!" end
    if !IADM:CanBeBanned(id64) then return false, "This target is immune to being banned!" end


    local ply = player.GetBySteamID64(id64)
    local isbot = IsValid(ply) and ply:IsBot()

    local start = os.time()
    local endban = duration == 0 and 0 or (start + duration)

    local dbname = IADM.DatabaseDir.."_bans"
    local sqlname = sql.QueryTyped("SELECT * FROM iadm_users WHERE id64=? LIMIT 1", bannedby)
    local banname = IsValid(player.GetBySteamID64(bannedby)) and player.GetBySteamID64(bannedby):Name() or sqlname and sqlname[1].name or "Console"
    local bannedbyid = IsValid(bannedby) and bannedby:SteamID64() or bannedby == NULL and "0" or bannedby
    local tbl = {
        banstart = start,
        banend = endban,
        duration = duration,
        reason = reason,
        bannedby = bannedbyid,
        bannedbyname = banname
    }
    IADM.BannedPlayers[id64] = tbl

    if !ply:IsValid() or !isbot then
        sql.QueryTyped("INSERT INTO "..dbname.." (id64, banstart, banend, duration, reason, bannedby, bannedbyname) VALUES (?, ?, ?, ?, ?, ?, ?)",
            id64,
            start,
            endban,
            duration,
            reason,
            bannedby,
            banname
        )
    end

    if IsValid(ply) then
        ply:Kick(IADM:GetBanReason(id64, true))

        if isbot then -- don't actually ban bots since if they do it can be problematic
            IADM.BannedPlayers[id64] = nil
        end
    end

    return true
end

function IADM:GetBanReason(id64, bypass)
    if !bypass and not IADM:IsPlayerBanned(id64) then return "null" end
    local bantbl = IADM.BannedPlayers[id64]
    local r = [[You are banned!

Reason: %reason%
Banned by: %bannedbyname% (%bannedbyid%)
Unbanned in: %time%]]

    r = string.Replace(r, "%reason%", bantbl.reason)
    r = string.Replace(r, "%time%", bantbl.banend == 0 and "Never" or string.NiceTime(bantbl.banend - os.time()))
    r = string.Replace(r, "%bannedbyname%", bantbl.bannedbyname)
    r = string.Replace(r, "%bannedbyid%", bantbl.bannedby)


    return r
end

function IADM:IsPlayerBanned(id64)
    local bantbl = IADM.BannedPlayers[id64]
    local time = os.time()
    if !bantbl then return end

    return bantbl and (bantbl.banend == 0 or bantbl.banend > time)
end


IADM:AddHook("CheckPassword", "checkBanned", function(steamID64, ipAddress, svPassword, clPassword, name)
    if IADM.BannedPlayers[steamID64] then
        return false, "You are banned!"
    end
end)

return MODULE
