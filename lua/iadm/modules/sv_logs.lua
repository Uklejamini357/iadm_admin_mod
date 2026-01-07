local MODULE_NAME = "Logs"

if !IADM_MODULE_SHOULDINCLUDE then return end

if not IADM.RecentLogs then
    IADM.RecentLogs = {}
    IADM.RecentLogsByAction = {}
    IADM.LogFunc = {}
    IADM.LoggingEnabled = true
end

local cfg = IADM:AddConfigCategory("logs_options", "Logs", IADM_GROUP_POWER_SUPERADMIN)

local function IsLogEnabled(id)
    return cfg:GetConfigValue("log_toggle_"..id)
end

function IADM:LogAction(action, ...)
    if !self.LogFunc[action] then return end
    if !IsLogEnabled(action) then return end

    local strortbl = {self.LogFunc[action](...)}
    if #strortbl == 1 then
        strortbl = strortbl[1]
    end

    local str = ""
    if istable(strortbl) then
        for id,txt in pairs(strortbl) do
            if !isstring(txt) then
                local ply = txt -- might be player
                if IsValid(ply) then
                    local s
                    if ply:IsPlayer() then
                        s = string.format("%s (%s)", ply:Nick(), ply:GetIADMSteamID64())
                    else
                        s = string.format("%s [%d]", ply:GetClass(), ply:EntIndex())
                    end

                    strortbl[id] = s
                    str = str..s
                end
                continue
            end
            str = str..txt
        end

        MsgC(IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%H:%M:%S"), IADM_ECHOCOLOR_LOGTEXT, " LOG ", IADM_ECHOCOLOR_LOGTYPE, action, IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, unpack(strortbl))
        MsgN()
        table.insert(self.RecentLogs, {time = os.time(), svcurtime = SysTime(), action = action, text = str})
        table.insert(self.RecentLogsByAction[action], {time = os.time(), svcurtime = SysTime(), action = action, text = str})
    else
        MsgC(IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%H:%M:%S"), IADM_ECHOCOLOR_LOGTEXT, " LOG ", IADM_ECHOCOLOR_LOGTYPE, action, IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, strortbl)
        MsgN()
        table.insert(self.RecentLogs, {time = os.time(), svcurtime = SysTime(), action = action, text = strortbl})
        table.insert(self.RecentLogsByAction[action], {time = os.time(), svcurtime = SysTime(), action = action, text = str})
    end

    sql.QueryTyped("INSERT INTO iadm_logs(action, str, time) "..
        "VALUES (?, ?, ?)",
        action,
        str,
        os.time()
    )
end

function IADM:RegisterLogAction(action, callback, name, desc, default)
    self.LogFunc[action] = callback
    self.RecentLogsByAction[action] = self.RecentLogsByAction[action] or {}

    cfg:AddConfigOption("log_toggle_"..action, name, desc, default, IADM_ARGTYPE_BOOL)

    return self.LogFunc[action]
end

IADM:AddSQLDatabase("logs", function(id)
    local db = IADM.DatabaseDir.."_"..id

    sql.QueryTyped("CREATE TABLE IF NOT EXISTS "..db.." ("..
        "id INTEGER PRIMARY KEY AUTOINCREMENT, ".. -- idk why tf AUTO_INCREMENT doesn't work here
        "action CHAR(63), "..
        "str VARCHAR(1024), "..
        "time INT UNSIGNED"..
    ")")
end)

IADM:RegisterLogAction("svstart", function(map)
    return IADM_ECHOCOLOR_TEXT, "Server initialized! Current map: ", IADM_ECHOCOLOR_ARG1, map
end, "Server start", "Logs the server startup", true)

IADM:AddHook("Initialize", "LogSvStart", function()
    if !IsLogEnabled("svstart") then return end
    IADM:LogAction("svstart", game.GetMap())
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("svstop", function(map)
    return IADM_ECHOCOLOR_TEXT, "Server is closing (or changing map)"
end, "Server stop", "Logs the server stop", true)

IADM:AddHook("ShutDown", "LogSvStop", function()
    if !IsLogEnabled("svstop") then return end
    IADM:LogAction("svstop")
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("playerdeath", function(pl, attacker, inflictor)
    if pl == attacker then
        if inflictor ~= attacker then
            return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " suicided! (using ", IADM_ECHOCOLOR_ARG3, inflictor, IADM_ECHOCOLOR_TEXT, ")"
        else
            return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " suicided!"
        end
    end

    if attacker ~= inflictor then
        return IADM_ECHOCOLOR_ARG1, pl, " was killed by ", IADM_ECHOCOLOR_ARG2, attacker, IADM_ECHOCOLOR_TEXT, " (using ", IADM_ECHOCOLOR_ARG3, inflictor, IADM_ECHOCOLOR_TEXT, ")"
    end
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " was killed by ", IADM_ECHOCOLOR_ARG2, attacker
end, "Player death", "Logs player deaths.", true)

IADM:AddHook("DoPlayerDeath", "LogPlrDeath", function(pl, attacker, dmginfo)
    if !IsLogEnabled("playerdeath") then return end
    local inflictor = dmginfo:GetInflictor()

    IADM:LogAction("playerdeath", pl, attacker, inflictor)
end)


-- Sandbox logs

IADM:RegisterLogAction("plrspawneffect", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned prop effect ", IADM_ECHOCOLOR_ARG2, model
end, "Player spawn prop effect", "Logs player spawning prop effects", true)

IADM:AddHook("PlayerSpawnedEffect", "LogSpawnEffect", function(pl, model, ent)
    if !IsLogEnabled("plrspawneffect") then return end
    IADM:LogAction("plrspawneffect", pl, model)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnnpc", function(pl, ent)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned NPC ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]", ent:GetClass(), ent:EntIndex())
end, "Player spawn NPC", "desc", true)

IADM:AddHook("PlayerSpawnedNPC", "LogSpawnNPC", function(pl, ent)
    if !IsLogEnabled("plrspawnnpc") then return end
    IADM:LogAction("plrspawnnpc", pl, ent)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnprop", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned prop ", IADM_ECHOCOLOR_ARG2, model
end, "Player spawn prop", "desc", true)

IADM:AddHook("PlayerSpawnedProp", "LogSpawnProp", function(pl, model, ent)
    if !IsLogEnabled("plrspawnprop") then return end
    IADM:LogAction("plrspawnprop", pl, model)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnragdoll", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned prop ragdoll ", IADM_ECHOCOLOR_ARG2, model
end, "Player spawn ragdoll", "desc", true)

IADM:AddHook("PlayerSpawnedRagdoll", "LogSpawnRagdoll", function(pl, model, ent)
    if !IsLogEnabled("plrspawnragdoll") then return end
    IADM:LogAction("plrspawnragdoll", pl, model)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnsent", function(pl, ent)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned SENT ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]", ent:GetClass(), ent:EntIndex())
end, "Player spawn SENT", "desc", true)

IADM:AddHook("PlayerSpawnedSENT", "LogSpawnSENT", function(pl, ent)
    if !IsLogEnabled("plrspawnsent") then return end
    IADM:LogAction("plrspawnsent", pl, ent)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnswep", function(pl, ent)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned SWEP ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]", ent:GetClass(), ent:EntIndex())
end, "Player spawn SWEP", "desc", true)

IADM:AddHook("PlayerSpawnedSWEP", "LogSpawnSWEP", function(pl, ent)
    if !IsLogEnabled("plrspawnswep") then return end
    IADM:LogAction("plrspawnswep", pl, ent)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrgiveswep", function(pl, weapon)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " gave ", IADM_ECHOCOLOR_ARG2, weapon, IADM_ECHOCOLOR_TEXT, " to themselves"
end, "Player give SWEP", "desc", true)

IADM:AddHook("PlayerGiveSWEP", "LogGiveSWEP", function(tbl, pl, weapon)
    if !IsLogEnabled("plrgiveswep") then return end
    if not tbl[2] then return end
    if pl:HasWeapon(weapon) then return end
    IADM:LogAction("plrgiveswep", pl, weapon)
end, POST_HOOK)

IADM:RegisterLogAction("plrspawnvehicle", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned vehicle ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]"), IADM_ECHOCOLOR_TEXT, " with model ", IADM_ECHOCOLOR_ARG3, ent:GetModel()
end, "Player spawn vehicle", "desc", true)

IADM:AddHook("PlayerSpawnedVehicle", "LogSpawnVehicle", function(pl, ent)
    if !IsLogEnabled("plrspawnvehicle") then return end
    IADM:LogAction("plrspawnvehicle", pl, ent)
end, HOOK_MONITOR_HIGH)


IADM:RegisterLogAction("plrsaychat", function(pl, text, onteam)
    if onteam then
        return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " said in team chat: ", IADM_ECHOCOLOR_ARG2, text
    end

    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " said in chat: ", IADM_ECHOCOLOR_ARG2, text
end, "Log player chat", "Logs what the players say in chat", true)

-- This is why u need Srlion's hook library, called AFTER the player has said in chat with a value returned.
IADM:AddHook("PlayerSay", "LogPlayerSay", function(tbl, pl, text, onteam)
    if !IsLogEnabled("plrsaychat") then return end
    if tbl[2] == "" then
        return
    end

    IADM:LogAction("plrsaychat", pl, text, onteam)
end, POST_HOOK)

IADM:RegisterLogAction("plrconnect", function(name, steamid64)
    return IADM_ECHOCOLOR_ARG1, string.format("%s (%s)", name, steamid64), IADM_ECHOCOLOR_TEXT, " has connected"
end, "Player connect", "desc", true)

gameevent.Listen("player_connect")
IADM:AddHook("player_connect", "LogPlayerConnect", function(data)
    if !IsLogEnabled("plrconnect") then return end
    if data.bot then return end
    IADM:LogAction("plrconnect", data.name, util.SteamIDTo64(data.networkid))
end)

IADM:RegisterLogAction("botspawn", function(name)
    return IADM_ECHOCOLOR_ARG1, name, IADM_ECHOCOLOR_TEXT, " has spawned"
end, "Bot spawn", "desc", false)

IADM:AddHook("PlayerInitialSpawn", "LogBotSpawn", function(pl)
    if !IsLogEnabled("botspawn") then return end
    if !pl:IsBot() then return end
    IADM:LogAction("botspawn", pl:Name())
end, PRE_HOOK)

IADM:RegisterLogAction("plrinitspawn", function(pl)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " has spawned"
end, "Player first session spawns", "desc", true)

IADM:AddHook("PlayerInitialSpawn", "LogPlayerInitSpawn", function(pl)
    if !IsLogEnabled("plrinitspawn") then return end
    if pl:IsBot() then return end
    IADM:LogAction("plrinitspawn", pl)
end, PRE_HOOK)

IADM:RegisterLogAction("plrloadingend", function(pl, time)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " has finished loading! (took ", IADM_ECHOCOLOR_ARG2, time.." seconds", IADM_ECHOCOLOR_TEXT, ")"
end, "Player ready", "desc", true)

IADM:AddHook("IADMPlrInit", "LogPlayerFullyLoaded", function(pl, time)
    if !IsLogEnabled("plrloadingend") then return end
    IADM:LogAction("plrloadingend", pl, time)
end)

IADM:RegisterLogAction("plrdisconnect", function(name, steamid64, reason)
    return IADM_ECHOCOLOR_ARG1, string.format("%s (%s)", name, steamid64), IADM_ECHOCOLOR_TEXT, " has disconnected (", IADM_ECHOCOLOR_ARG2, reason, IADM_ECHOCOLOR_TEXT, ")"
end, "Player disconnect", "desc", true)

IADM:RegisterLogAction("botkick", function(name, steamid64, reason)
    return IADM_ECHOCOLOR_ARG1, string.format("%s (%s)", name, steamid64), IADM_ECHOCOLOR_TEXT, " has disconnected (", IADM_ECHOCOLOR_ARG2, reason, IADM_ECHOCOLOR_TEXT, ")"
end, "Bot kicks", "desc", false)

gameevent.Listen("player_disconnect")
IADM:AddHook("player_disconnect", "LogPlayerDisonnect", function(data)
    if tobool(data.bot) then
        if !IsLogEnabled("botkick") then return end
        IADM:LogAction("botkick", data.name, util.SteamIDTo64(data.networkid), data.reason)
    else
        if !IsLogEnabled("plrdisconnect") then return end
        IADM:LogAction("plrdisconnect", data.name, util.SteamIDTo64(data.networkid), data.reason)
    end
end)

IADM:RegisterLogAction("plrusetool", function(pl, tool)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " used tool ", IADM_ECHOCOLOR_ARG2, tool
end, "Use tool", "desc", true)

IADM:AddHook("CanTool", "LogToolgunUse", function(tbl, pl, tr, toolname, tool, button)
    if !IsLogEnabled("plrusetool") then return end
    if !tbl[2] then return end -- only if other hooks don't block this

    IADM:LogAction("plrusetool", pl, toolname)
end, POST_HOOK)
