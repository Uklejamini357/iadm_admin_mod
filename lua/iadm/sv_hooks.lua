
IADM:AddHook("PlayerInitialSpawn", "PlayerInit", function(ply)
    local isbot = ply:IsBot()
    local id64 = ply:GetIADMSteamID64()

    local tbl = sql.QueryTyped("SELECT * FROM iadm_users WHERE id64=?", id64)[1]
    if tbl then
        if tbl.groupname and IADM.UserGroups[tbl.groupname] then
            ply:SetUserGroup(tbl.groupname)
        end

        ply.IADM_firsttime = tbl.firsttime
        ply.IADM_playtime = tbl.playtime
        ply.IADM_lastseen = os.time()
        
        ply.IADM_spawntime = SysTime() -- using SysTime cuz there's no other way to Calculate CurTime() without timescale 

        if !isbot then
            sql.QueryTyped("UPDATE "..IADM.DatabaseDir.."_users "..
                "SET name=?, lastseen=? WHERE id64=?",
                ply:Name(),
                os.time(),
                id64
            )
        end
    elseif !isbot then
        sql.QueryTyped("INSERT INTO "..IADM.DatabaseDir.."_users(id64, name, groupname, firsttime, playtime, lastseen) VALUES(?, ?, ?, ?, ?, ?)",
            id64,
            ply:Name(),
            ply:IsListenServerHost() and "superadmin" or ply:GetUserGroup(),
            os.time(),
            0,
            os.time()
        )
    end

    if !ply:IsBot() then
        ply.IADM_InitPhase = 1
    end
end, PRE_HOOK)

local function PlayerSave(ply)
    local id64 = ply:GetIADMSteamID64()
    sql.QueryTyped("UPDATE "..IADM.DatabaseDir.."_users "..
        "SET name=?, lastseen=? WHERE id64=?",
        ply:Name(),
        os.time(),
        id64
    )
end

IADM:AddHook("ShutDown", "SavePlayerDatas", function()
    for _,ply in pairs(player.GetHumans()) do
        PlayerSave(ply)
    end
end, HOOK_HIGH)

local NextSave = SysTime()
IADM:AddHook("Think", "PlayerDataPeriodicSave", function()
    if NextSave > SysTime() then return end
    NextSave = SysTime() + 60

    for _,ply in pairs(player.GetHumans()) do
        PlayerSave(ply)
    end
end)

IADM:AddSQLDatabase("users", function(id)
    sql.QueryTyped("CREATE TABLE IF NOT EXISTS iadm_users ("..
        "id64 BIGINT PRIMARY KEY, "..
        "name CHAR(255), "..
        "groupname CHAR(40), "..
        "firsttime INT UNSIGNED, "..
        "playtime INT UNSIGNED, "..
        "lastseen INT UNSIGNED"..
    ")")
end)

IADM:AddSQLDatabase("config", function(id)
    sql.QueryTyped("CREATE TABLE IF NOT EXISTS iadm_config ("..
        "id VARCHAR(40) PRIMARY KEY, "..
        "savedvalue VARCHAR(65535), ".. -- i don't even know which value to set it to, so frick it
        "powerlevel SMALLINT, "..
        "viewpowerlevel SMALLINT, "..
        "lastmodifiedby BIGINT, "..
        "timemodified INT UNSIGNED"..
    ")")
end)

IADM:AddLoadSQL("config", function(id)
    local tbl = sql.QueryTyped("SELECT * FROM iadm_config")

    if !tbl then return end

    -- unoptimal, I know. it's only for what i could have managed for now though.
    for _,v in ipairs(tbl) do
        for _,cfg in pairs(IADM.Config) do
            local dobreak
            for id,_ in pairs(cfg) do
                if v.id == id then
                    cfg.SetValue = tbl.savedvalue
                    cfg.Powerlevel = tbl.powerlevel
                    dobreak = true
                    break
                end
            end
            if dobreak then break end
        end
    end
end)

IADM:AddHook("Initialize", "SQLDatabaseInit", function()
    sql.QueryTyped("PRAGMA foreign_keys = ON") -- enable it since having it disabled can be an issue

    for id,func in pairs(IADM.SQLDatabases) do
        func(id)
    end

    for id,func in pairs(IADM.SQLDatabasesLoad) do
        func(id)
    end
end, PRE_HOOK)

local string_lower = string.lower
IADM:AddHook("PlayerSay", "PlayerSay", function(pl, text)
    local msg = function(prefix, ...)
        local a = {...}
        timer.Simple(0, function()
            if prefix then
                IADM:MessageWPrefix(pl, true, unpack(a))
            else
                IADM:Message(pl, true, unpack(a))
            end
        end)
    end

    local usedprefix = ""
    if istable(IADM.Prefix) then
        for c,str in ipairs(IADM.Prefix) do
            if string.sub(text, 1, #str) == str then
                usedprefix = str
                break
            end

            if #IADM.Prefix == c then return end
        end
    elseif string.sub(text, 1, #IADM.Prefix) ~= IADM.Prefix then
        return
    end


    local command = string.Explode(" ", text)[1]
    local cmd = string.lower(string.sub(command, 2))
    local ctbl = IADM.Commands[cmd]
    if !ctbl then
        for _cmd,c in pairs(IADM.Commands) do
            if !c.Aliases then continue end
            if table.HasValue(c.Aliases, cmd) then
                cmd = _cmd
                ctbl = c
                break
            end
        end

        if !ctbl then return end
    end

    local silent = string.sub(text, 1, 1) == "/" or ctbl.Silent

    if !IADM:CanUseCommand(pl, cmd) then
        msg(false, IADM_ECHOCOLOR_ERROR, "Insufficient permissions to use ", IADM_ECHOCOLOR_ERROR_ARGVAR, cmd, IADM_ECHOCOLOR_ERROR, " command!")
        pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
        if silent then return "" else return end
    end

    local a = string.Explode("\"", string.sub(text, #command + 1))
    local args = {}
    for k,v in pairs(a) do
        if k%2 == 0 then
            table.insert(args, v)
        else
            for _,v2 in ipairs(string.Explode(" ", v)) do
                if v2=="" then continue end
                table.insert(args, v2)
            end
        end
    end

    local needed = #ctbl.Args
    local defaultargsamt = 0
    for count,argument in ipairs(ctbl.Args) do
        needed = needed - ((argument.default or argument.optional or args[count]) and 1 or 0)
        defaultargsamt = defaultargsamt + ((argument.default or argument.optional) and 1 or 0)
    end

    if #ctbl.Args ~= 0 and #ctbl.Args-defaultargsamt == needed and needed ~= 0 then
        local s = ""
        for count,arg in pairs(ctbl.Args) do
            if arg.type == IADM_ARGTYPE_STR then
                s = s..((arg.optional and string.format("[%s]", arg.hint or "text") or string.format("<%s>", arg.hint or "text")))
            elseif arg.type == IADM_ARGTYPE_NUM then
                s = s..((arg.optional and string.format("[%s]", arg.hint or "number") or string.format("<%s>", arg.hint or "text")))
            end
        end
    
        msg(true, IADM_ECHOCOLOR_TEXT, "# "..(ctbl.Name or cmd)..(ctbl.Name and " ("..usedprefix..cmd..")" or "").."\n",
        IADM_ECHOCOLOR_ARG1, ctbl.Desc or "",
        IADM_ECHOCOLOR_ARG1, ctbl.Help and string.format("\nUsage: %s%s %s\n", usedprefix, cmd, s) or "", "\n")
        if silent then return "" else return end
    elseif needed ~= 0 then
        msg(true, IADM_ECHOCOLOR_TEXT, "Not enough arguments provided!", "\n")
        if silent then return "" else return end
    end

    -- local new_args = {}
    -- for _,text in pairs(args) do
    --     table.insert(new_args, text)
    -- end
    -- args = new_args

    for count,arg in pairs(ctbl.Args) do
        if arg and arg.default and not args[count] then
            args[count] = arg.default
        end
    end

    local inchat = true
    timer.Simple(0, function()
        args = IADM:ProcessCmdArgs(pl, inchat, ctbl, args)

        if !args or (#ctbl.Args ~= 0 and defaultargsamt ~= 0 and needed ~= 0) then return "" end

        if ctbl.ChatArg then
            ctbl.Func(pl, inchat, unpack(args))
        else
            ctbl.Func(pl, unpack(args))
        end
    end)
    if silent then return "" end
end, PRE_HOOK_RETURN)

IADM:AddHook("PlayerSay", "MuteCheck", function(pl, text)
    local timeleft = math.max(pl.IADMChatMuted or 0, pl.IADMMuted or 0) - os.time()
    if timeleft < 0 then return end

    IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "You are ", IADM_ECHOCOLOR_ERROR_ARGVAR, "muted", IADM_ECHOCOLOR_ERROR, "! Time remaining: ", IADM_ECHOCOLOR_ERROR_REASON, string.NiceTime(timeleft))
    return ""
end, HOOK_HIGH)

-- another check if they somehow manage to bypass mute
IADM:AddHook("PlayerSay", "MuteCheck2", function(tbl, pl, text)
    if tbl[2] == "" then return end
    local timeleft = math.max(pl.IADMChatMuted or 0, pl.IADMMuted or 0) - os.time()
    if timeleft < 0 then return end

    IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "You are ", IADM_ECHOCOLOR_ERROR_ARGVAR, "muted", IADM_ECHOCOLOR_ERROR, "! Time remaining: ", IADM_ECHOCOLOR_ERROR_REASON, string.NiceTime(timeleft))
    return ""
end, POST_HOOK_RETURN)


local pass="I want to confirm deletion of the IADM database. "
for i=1,10 do
    pass=pass..string.char(math.random(33,126))
end

concommand.Add("iadm_god_mode", function(pl, cmd, _, str)
    if !pl:IsValid() or !pl:IsListenServerHost() then
        pl:SendLua(string.format([[MsgN("Unknown command: %s")]], cmd))
        return
    end

    if !pl.IADM_GodMode then
        pl.IADM_GodMode = true
        pl:SendLua([[LocalPlayer().IADM_GodMode = true]])
        IADM:Message(pl, true, Color(255,255,155), "[WARNING] ", Color(100,255,255), "You have enabled godmode.")
        IADM:Message(pl, true, Color(100,255,255), "Permission checks are disabled for you..")
    else
        pl.IADM_GodMode = nil
        pl:SendLua([[LocalPlayer().IADM_GodMode = nil]])
        IADM:Message(pl, true, Color(255,255,155), "[WARNING] ", Color(100,255,255), "You have disabled godmode.")
        IADM:Message(pl, true, Color(100,255,255), "Permission checks are enabled again.")
    end

end)


concommand.Add("iadm_reset_database", function(pl, cmd, _, str)
    if pl:IsValid() and !pl:IsListenServerHost() then return end

    local p = pass
    if str ~= pass and str == "" then
        IADM:Message(pl, true, Color(255,255,155), "[WARNING] ", Color(100,255,255), "This command is only for the use of development purposes or if migrating.")
        IADM:Message(pl, true, Color(100,255,255), "In the future, an export/import tool will be added.")
        IADM:Message(pl, true, Color(255,255,55), "To delete your IADM database, type in the following:")
        IADM:Message(pl, true, Color(255,128,0), cmd, " ", pass)
        IADM:Message(pl, true, Color(190,0,0), "[CRITICAL WARNING] This deletes EVERYTHING! BACKUP YOUR sv.db BEFORE DOING IT OR YOU RISK PERMANENT DATA DELETION!")
        return
    elseif str ~= pass and str ~= "" then
        IADM:Message(pl, true, Color(190,0,0), "Invalid.")
        return
    end

    for id,v in pairs(IADM.SQLDatabases) do
        sql.QueryTyped("DROP TABLE "..IADM.DatabaseDir.."_"..id)
    end

    for event,tbl in pairs(IADM.Hooks) do
        for id,_ in pairs(IADM.Hooks[event]) do
            hook.Remove(event, id)
            IADM.Hooks[event][id] = nil
        end
        IADM.Hooks[event] = nil
    end

    RunConsoleCommand("changelevel", game.GetMap())
end)
