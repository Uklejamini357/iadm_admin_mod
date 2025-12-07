util.AddNetworkString("iadm_command")
util.AddNetworkString("iadm_printmsg")
util.AddNetworkString("iadm_csay")
util.AddNetworkString("iadm_playerusecmd")

net.Receive("iadm_command", function(len, pl)
    local cmd = net.ReadString()
    local args = net.ReadTable()
	
	local ctbl = IADM.Commands[cmd]
	if !ctbl then return end
    if !pl:IsValid() then return end

    if !IADM:CanUseCommand(pl, cmd) then
        IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "Insufficient permissions! Need ", IADM_ECHOCOLOR_ERROR_ARGVAR, ctbl.PermsRequire, IADM_ECHOCOLOR_ERROR, " rank!")
        pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
        return ""
    end

    args = IADM:ProcessCmdArgs(pl, inchat, ctbl, args)

    if ctbl.ChatArg then
	    ctbl.Func(pl, false, unpack(args))
    else
    	ctbl.Func(pl, unpack(args))
    end
end)


IADM:AddHook("PlayerInitialSpawn", "PlayerInit", function(ply)
    local tbl = sql.QueryTyped("SELECT * FROM iadm_users WHERE id64=?", ply:SteamID64())

    if table.Count(tbl) > 0 then
        if tbl.groupname and IADM.UserGroups[tbl.groupname] then
            ply:SetUserGroup(tbl.groupname)
        end

        ply.IADM_firsttime = tbl.firsttime
        ply.IADM_playtime = tbl.playtime
        ply.IADM_lastseen = tbl.lastseen
    else

        sql.QueryTyped("INSERT INTO "..IADM.DatabaseDir.."_users(id64, name, groupname, firsttime, playtime, lastseen) VALUES(?, ?, ?, ?, ?, ?)",
            ply:SteamID64(),
            ply:Name(),
            ply:GetUserGroup(),
            os.time(),
            0,
            os.time()
        )
    end
end, PRE_HOOK)

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

IADM:AddHook("Initialize", "SQLDatabases", function()
    for id,func in pairs(IADM.SQLDatabases) do
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
        for _,c in pairs(IADM.Commands) do
            if !c.Aliases then continue end
            if table.HasValue(c.Aliases, cmd) then
                ctbl = c
                break
            end
        end

        if !ctbl then return end
    end

    local silent = string.sub(text, 1, 1) == "/" or ctbl.Silent

    if !IADM:CanUseCommand(pl, cmd) then
        msg(false, IADM_ECHOCOLOR_ERROR, "Insufficient permissions! Need ", IADM_ECHOCOLOR_ERROR_ARGVAR, ctbl.PermsRequire, IADM_ECHOCOLOR_ERROR, " rank!")
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
end, HOOK_NORMAL)
