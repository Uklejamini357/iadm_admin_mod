local MODULE_NAME = "Bans"
local MODULE = {}
IADM.Modules[MODULE_NAME] = MODULE

MODULE.ID = "bans"
MODULE.Name = MODULE_NAME
MODULE.Description = "Module for managing user bans"

if !IADM_MODULE_SHOULDINCLUDE then return end

if !SERVER then return end

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
    if IsValid(id64) then id64 = id64:GetIADMSteamID64()
    elseif type(id64) ~= "string" then return false, "Invalid user!" end
    if IsValid(bannedby) then bannedby = bannedby:GetIADMSteamID64()
    elseif type(bannedby) ~= "string" then bannedby = bannedby:GetIADMSteamID64() return false, "Invalid user banning the target!" end

    if id64 == bannedby then return false, "You cannot ban yourself!" end
    if !IADM:CanBeBanned(id64) then return false, "Target is immune to being banned!" end


    local ply = player.GetBySteamID64(id64)
    local isbot = IsValid(ply) and ply:IsBot()

    local start = os.time()
    local endban = duration == 0 and 0 or (start + duration)

    local dbname = IADM.DatabaseDir.."_bans"
    local tbl = {
        banstart = start,
        banend = endban,
        duration = duration,
        reason = reason,
        bannedby = bannedby,
    }
    IADM.BannedPlayers[id64] = tbl

    if !ply:IsValid() or !ply:IsBot() then
        sql.QueryTyped("INSERT INTO "..dbname.." (id64, banstart, banend, duration, reason, bannedby) VALUES (?, ?, ?, ?, ?, ?)",
            id64,
            start,
            endban,
            duration,
            reason,
            bannedby
        )
    end

    if IsValid(ply) then
        ply:Kick(IADM:GetBanReason(id64))

        if isbot then
            IADM.BannedPlayers[id64] = {}
        end
    end

    return true
end

function IADM:GetBanReason(id64)
    if not IADM:IsPlayerBanned(id64) then return "null" end
    local bantbl = IADM.BannedPlayers[id64]
    local r = [[You are banned!

Reason: %reason%
Banned by: %bannedbyname% (%bannedbyid%)
Unbanned in: %time%]]

    r = string.Replace(r, "%reason%", bantbl.reason)
    r = string.Replace(r, "%time%", bantbl.banend == 0 and "Never" or string.NiceTime(bantbl.banend - os.time()))
    -- r = string.Replace(r, "%bannedbyname%", bantbl.bannedby)
    -- r = string.Replace(r, "%bannedbyid%", bantbl.bannedbyname)


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
