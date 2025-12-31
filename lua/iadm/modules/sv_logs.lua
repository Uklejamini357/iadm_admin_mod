local MODULE_NAME = "Logs"

if !IADM_MODULE_SHOULDINCLUDE then return end

if not IADM.RecentLogs then
    IADM.RecentLogs = {}
    IADM.RecentLogsByAction = {}
    IADM.LogFunc = {}
    IADM.LoggingEnabled = true
end

function IADM:LogAction(action, ...)
    if !self.LogFunc[action] then return end
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

function IADM:RegisterLogAction(action, callback)
    self.LogFunc[action] = callback
    self.RecentLogsByAction[action] = self.RecentLogsByAction[action] or {}

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
end)

IADM:AddHook("Initialize", "LogSvStart", function()
    IADM:LogAction("svstart", game.GetMap())
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("svstop", function(map)
    return IADM_ECHOCOLOR_TEXT, "Server is closing (or changing map)"
end)

IADM:AddHook("ShutDown", "LogSvStop", function()
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
end)

IADM:AddHook("DoPlayerDeath", "LogPlrDeath", function(pl, attacker, dmginfo)
    local inflictor = dmginfo:GetInflictor()

    IADM:LogAction("playerdeath", pl, attacker, inflictor)
end)


-- Sandbox logs

IADM:RegisterLogAction("plrspawneffect", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned prop effect ", IADM_ECHOCOLOR_ARG2, model
end)

IADM:AddHook("PlayerSpawnedEffect", "LogSpawnEffect", function(pl, model, ent)
    IADM:LogAction("plrspawneffect", pl, model)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnnpc", function(pl, ent)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned NPC ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]", ent:GetClass(), ent:EntIndex())
end)

IADM:AddHook("PlayerSpawnedNPC", "LogSpawnNPC", function(pl, ent)
    IADM:LogAction("plrspawnnpc", pl, ent)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnprop", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned prop ", IADM_ECHOCOLOR_ARG2, model
end)

IADM:AddHook("PlayerSpawnedProp", "LogSpawnProp", function(pl, model, ent)
    IADM:LogAction("plrspawnprop", pl, model)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnragdoll", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned prop ragdoll ", IADM_ECHOCOLOR_ARG2, model
end)

IADM:AddHook("PlayerSpawnedRagdoll", "LogSpawnRagdoll", function(pl, model, ent)
    IADM:LogAction("plrspawnragdoll", pl, model)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnsent", function(pl, ent)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned SENT ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]", ent:GetClass(), ent:EntIndex())
end)

IADM:AddHook("PlayerSpawnedSENT", "LogSpawnSENT", function(pl, ent)
    IADM:LogAction("plrspawnsent", pl, ent)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrspawnswep", function(pl, ent)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned SWEP ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]", ent:GetClass(), ent:EntIndex())
end)

IADM:AddHook("PlayerSpawnedSWEP", "LogSpawnSWEP", function(pl, ent)
    IADM:LogAction("plrspawnswep", pl, ent)
end, HOOK_MONITOR_HIGH)

IADM:RegisterLogAction("plrgiveswep", function(pl, weapon)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " gave ", IADM_ECHOCOLOR_ARG2, weapon, IADM_ECHOCOLOR_TEXT, " to themselves"
end)

IADM:AddHook("PlayerGiveSWEP", "LogGiveSWEP", function(tbl, pl, weapon)
    if not tbl[2] then return end
    if pl:HasWeapon(weapon) then return end
    IADM:LogAction("plrgiveswep", pl, weapon)
end, POST_HOOK)

IADM:RegisterLogAction("plrspawnvehicle", function(pl, model)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " spawned vehicle ", IADM_ECHOCOLOR_ARG2, string.format("%s [%d]"), IADM_ECHOCOLOR_TEXT, " with model ", IADM_ECHOCOLOR_ARG3, ent:GetModel()
end)

IADM:AddHook("PlayerSpawnedVehicle", "LogSpawnVehicle", function(pl, ent)
    IADM:LogAction("plrspawnvehicle", pl, ent)
end, HOOK_MONITOR_HIGH)


IADM:RegisterLogAction("plrsaychat", function(pl, text, onteam)
    if onteam then
        return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " said in team chat: ", IADM_ECHOCOLOR_ARG2, text
    end

    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " said in chat: ", IADM_ECHOCOLOR_ARG2, text
end)

-- This is why u need Srlion's hook library, called AFTER the player has said in chat with a value returned.
IADM:AddHook("PlayerSay", "LogPlayerSay", function(tbl, pl, text, onteam)
    if tbl[2] == "" then
        return
    end

    IADM:LogAction("plrsaychat", pl, text, onteam)
end, POST_HOOK)

IADM:RegisterLogAction("plrconnect", function(name, steamid64)
    return IADM_ECHOCOLOR_ARG1, string.format("%s (%s)", name, steamid64), IADM_ECHOCOLOR_TEXT, " has connected"
end)

gameevent.Listen("player_connect")
IADM:AddHook("player_connect", "LogPlayerConnect", function(data)
    if data.bot then return end
    IADM:LogAction("plrconnect", data.name, util.SteamIDTo64(data.networkid))
end)

IADM:RegisterLogAction("botspawn", function(name)
    return IADM_ECHOCOLOR_ARG1, name, IADM_ECHOCOLOR_TEXT, " has spawned"
end)

IADM:AddHook("PlayerInitialSpawn", "LogBotSpawn", function(pl)
    if !pl:IsBot() then return end
    IADM:LogAction("botspawn", pl:Name())
end, PRE_HOOK)

IADM:RegisterLogAction("plrinitspawn", function(pl)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " has spawned"
end)

IADM:AddHook("PlayerInitialSpawn", "LogPlayerInitSpawn", function(pl)
    if pl:IsBot() then return end
    IADM:LogAction("plrinitspawn", pl)
end, PRE_HOOK)

IADM:RegisterLogAction("plrloadingend", function(pl, time)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " has finished loading! (took ", IADM_ECHOCOLOR_ARG2, time.." seconds", IADM_ECHOCOLOR_TEXT, ")"
end)

IADM:AddHook("IADMPlrInit", "LogPlayerFullyLoaded", function(pl, time)
    IADM:LogAction("plrloadingend", pl, time)
end)

IADM:RegisterLogAction("plrdisconnect", function(name, steamid64, reason)
    return IADM_ECHOCOLOR_ARG1, string.format("%s (%s)", name, steamid64), IADM_ECHOCOLOR_TEXT, " has disconnected (", IADM_ECHOCOLOR_ARG2, reason, IADM_ECHOCOLOR_TEXT, ")"
end)

IADM:RegisterLogAction("botkick", function(name, steamid64, reason)
    return IADM_ECHOCOLOR_ARG1, string.format("%s (%s)", name, steamid64), IADM_ECHOCOLOR_TEXT, " has disconnected (", IADM_ECHOCOLOR_ARG2, reason, IADM_ECHOCOLOR_TEXT, ")"
end)

gameevent.Listen("player_disconnect")
IADM:AddHook("player_disconnect", "LogPlayerDisonnect", function(data)
    if tobool(data.bot) then
        IADM:LogAction("botkick", data.name, util.SteamIDTo64(data.networkid), data.reason)
    else
        IADM:LogAction("plrdisconnect", data.name, util.SteamIDTo64(data.networkid), data.reason)
    end
end)

IADM:RegisterLogAction("plrusetool", function(pl, tool)
    return IADM_ECHOCOLOR_ARG1, pl, IADM_ECHOCOLOR_TEXT, " used tool ", IADM_ECHOCOLOR_ARG2, tool
end)

IADM:AddHook("CanTool", "LogToolgunUse", function(tbl, pl, tr, toolname, tool, button)
    if !tbl[2] then return end -- only if other hooks don't block this

    IADM:LogAction("plrusetool", pl, toolname)
end, POST_HOOK)
