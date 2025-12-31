if not IADM then
    IADM = {}
    IADM.Commands = {}
    IADM.Config = {}
    IADM.Modules = {}
    IADM.Hooks = {}
    IADM.SQLDatabases = {}
    IADM.SQLDatabasesLoad = {}

    IADM.BannedPlayers = {}
    IADM.DatabaseDir = "iadm"

    IADM.RegisteredSyncData = {}
    IADM.InitSyncData = {}
end

IADM.Prefix = {"!", "/"}
IADM.Version = "0.4 beta2"
IADM.UpdateVer = 14
IADM.Author = "Uklejamini"

local IADM = IADM
local string_lower = string.lower

local m = {}
local meta = {}
meta.__index = m

function m:AddArgument(t)
    table.insert(self.Args, t)
end
meta.AddArgument = m.AddArgument


function IADM:AddCommand(cmd, func, t)
    -- if IADM.Commands[cmd] then
        -- MsgN("Command "..cmd.." already exists, overriding.")
    -- end

    cmd = string_lower(cmd)

    local tbl = {}
    tbl = setmetatable(tbl, meta)
    IADM.Commands[cmd] = tbl
    IADM.Commands[cmd].Func = func
    IADM.Commands[cmd].Args = {}
    table.Merge(IADM.Commands[cmd], t or {})

    return IADM.Commands[cmd]
end

function IADM:AddConfig(id, name, category, configtype, default, desc)
    id = string_lower(id)

    IADM.Config[category] = {}
    IADM.Config[category][name] = {}
    local tbl = IADM.Config[category][name]

    tbl.category = category
    tbl.desc = desc
    tbl.default = default
    tbl.configtype = configtype


    return tbl
end

function IADM:GetPrefix()
    local p = IADM.Prefix
    return istable(p) and p[1] or p
end

function IADM:Message(ply, tochat, ...)
    if SERVER then
        if istable(ply) or ply:IsValid() then
            net.Start("iadm_printmsg")
            net.WriteBit(0)
            net.WriteBit(tochat and 1 or 0)
            net.WriteTable({...})
            net.Send(ply)
        else
            MsgC(...)
            MsgN()
        end
    elseif CLIENT then
        if tochat then
            chat.AddText(...)
        else
            MsgC(...)
            MsgN()
        end
    end
end

function IADM:MessageWPrefix(ply, tochat, ...)
    if SERVER then
        if istable(ply) or ply:IsValid() then
            net.Start("iadm_printmsg")
            net.WriteBit(1)
            net.WriteBit(tochat and 1 or 0)
            net.WriteTable({...})
            net.Send(ply)
        else
            MsgC(IADM_ECHOCOLOR_PREFIX, "[IADM] ", color_white, ...)
            MsgN()
        end
    elseif CLIENT then
        if tochat then
            chat.AddText(IADM_ECHOCOLOR_PREFIX, "[IADM] ", color_white, ...)
        else
            MsgC(IADM_ECHOCOLOR_PREFIX, "[IADM] ", color_white, ...)
            MsgN()
        end
    end
end

function IADM:AddHook(eventname, identifier, func, order)
    if not IADM.Hooks[eventname] then IADM.Hooks[eventname] = {} end

    identifier = "IADM."..eventname.."."..identifier
    IADM.Hooks[eventname][identifier] = func
    hook.Add(eventname, identifier, func, order)

    return func
end

function IADM:AddSQLDatabase(id, func)
    IADM.SQLDatabases[id] = func
end

function IADM:AddLoadSQL(id, func)
    IADM.SQLDatabasesLoad[id] = func
end

-- Register each for client and server separately!!
function IADM:RegisterDataSync(id, func, ...)
    local tbl = {
        id = id,
        Func = func,
        args = {...}
    }

    for i,tbl in ipairs(IADM.RegisteredSyncData) do
        if table.HasValue(tbl, id) then
            IADM.RegisteredSyncData[i] = tbl
            return
        end
    end

    table.insert(IADM.RegisteredSyncData, tbl)
end

function IADM:RegisterInitDataSync(id, func, ...)
    local tbl = {
        id = id,
        Func = func,
        args = {...}
    }

    for i,tbl in ipairs(IADM.InitSyncData) do
        if table.HasValue(tbl, id) then
            IADM.InitSyncData[i] = tbl
            return
        end
    end

    table.insert(IADM.InitSyncData, tbl)
end

function IADM:PerformDataSync(id, pl, ...)
    local tbl = {...}


end

function IADM:CmdCanTarget(caller, target, ctbl, carg)
    if ctbl.IgnoreCanTarget then return true end
    if ctbl.CanAlwaysSelfTarget and caller == target then return true end

    if ctbl.OverrideCanTarget then
        return ctbl.OverrideCanTarget(caller, target)
    end
    local cantarget = ctbl.CanTarget and ctbl.CanTarget(caller, target) or carg.CanTarget and carg.CanTarget(caller, target)
    if cantarget then return cantarget end

    if caller ~= target and ctbl.RequireHigherPowerLevel or carg.RequireHigherPowerLevel then return target:GetGroupPowerLevel() < caller:GetGroupPowerLevel() end
    if caller == target then return true end
    return target:GetGroupPowerLevel() <= caller:GetGroupPowerLevel()
end

function IADM:ProcessCmdArgs(pl, inchat, ctbl, args)
    for count,v in pairs(args) do
        local carg = ctbl.Args[count]
        if !carg then break end
        if carg.varargs then
            for i=count+1,#args do
                args[count] = args[count].." "..args[i]
            end

            if args[count] == "" then
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", Color(255,128,0), "String cannot be empty!")
                return
            end

            break
        end
        local a = args[count]

        if carg.type == IADM_ARGTYPE_PLR then
            if a == "^" then
                a = pl
            elseif a == "@" then
                a = pl:GetEyeTrace().Entity
            elseif isnumber(tonumber(a)) and Entity(a or 0) and IsValid(Entity(a or 0)) then
                a = Entity(a)
            else
                local tbl = {}
                for _,ply in pairs(player.GetAll()) do
                    if ply:Nick() == v then
                        tbl = {ply}
                        break
                    elseif string.find(string_lower(ply:Nick()), string_lower(v)) then
                        table.insert(tbl, ply)
                    end
                end

                if #tbl > 1 then
                    local s = ""
                    for i=1,#tbl do
                        local nick = tbl[i]:Nick()
                        s=s..(i == 1 and nick or ", "..nick)
                    end
                    IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ",
                    Color(255,128,0), Format("Too many players (%d) to select from! ", #tbl), Color(255,255,0), "Select from:\n",
                    Color(255,128,0), s)
                    return
                end

                a = tbl[1]
            end

            if isstring(a) or !IsValid(a) or !a:IsPlayer() then
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", Color(255,128,0), "Player not found!")
                return
            end

            if !IADM:CmdCanTarget(pl, a, ctbl, carg) then
                IADM:Message(pl, inchat, IADM_ECHOCOLOR_ERROR, "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", IADM_ECHOCOLOR_ERROR_ARGVAR, a:Nick(), IADM_ECHOCOLOR_ERROR, " cannot be targetted!")
                return
            end

            args[count] = a
        elseif carg.type == IADM_ARGTYPE_ENTS or carg.type == IADM_ARGTYPE_PLRS then
            if a == "^" then
                a = {pl}
            elseif a == "@" then
                a = {pl:GetEyeTrace().Entity}
            elseif isnumber(tonumber(a)) and Entity(a or 0) and IsValid(Entity(a or 0)) then
                a = {Entity(a)}
            else
                local tbl = {}
                if carg.type == IADM_ARGTYPE_ENTS then
                    for _,ent in ipairs(ents.FindByClass(a)) do
                        if ent:IsPlayer() then continue end
                        table.insert(tbl, ent)
                    end
                end
                
                for _,ply in ipairs(player.GetAll()) do
                    if string.find(string_lower(ply:Nick()), string_lower(v)) and IADM:CmdCanTarget(pl, ply, ctbl, carg) then
                        table.insert(tbl, ply)
                    end
                end
                a = tbl
            end

            if isstring(a) or !istable(a) and !IsValid(a) then
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", Color(255,128,0), "Could not find an entity!")
                return
            end

            args[count] = a
        elseif carg.type == IADM_ARGTYPE_NUM then
            a = tonumber(a)
            if a then
                if carg.min then
                    a = math.max(carg.min, a)
                end

                if carg.max then
                    a = math.min(carg.max, a)
                end
            else
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", Color(255,128,0), "Invalid number!")
                return
            end
            args[count] = a
        elseif carg.type == IADM_ARGTYPE_TIME then
            a = tonumber(a)
            if a then
                if carg.min then
                    a = math.max(carg.min, a)
                end

                if carg.max then
                    a = math.min(carg.max, a)
                end
            end
            args[count] = a
        elseif carg.type == IADM_ARGTYPE_BOOL then
            a = tobool(a)
            args[count] = a
        elseif carg.type == IADM_ARGTYPE_STR then
            if a == "" then
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", Color(255,128,0), "String cannot be empty!")
                return
            end
        end
    end

    return args
end

function IADM:CanUseCommand(pl, cmd)
    if !pl then return false end
    if pl.IADM_GodMode then return true end
    -- if (pl == NULL or pl:IsListenServerHost()) then return true end
    local ctbl = IADM.Commands[cmd]
    if not ctbl then return false end

    local ugrp = IADM.UserGroups[pl:GetUserGroup()]

    if ugrp.powerlevel and (ctbl.PowerLevelReq or 0) <= ugrp.powerlevel then
        return true
    end

    if !ctbl.PowerLevelReq then
        return true
    end


    return false
end


concommand.Add("iadm", function(pl, cmd, args, str)
    local prefix = "[IADM] "
    if #args == 0 then
        local c = 0
        for cmd,ctbl in pairs(IADM.Commands) do
            if IADM:CanUseCommand(pl, cmd) then
                c = c + 1
            end
        end

        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "No command selected. Currently available commands: ", IADM_ECHOCOLOR_ARG1, c, "\n")
        return
    end

    local cmd = string_lower(args[1] or "")
    args[1] = nil

    local new_args = {}
    for _,text in pairs(args) do
        table.insert(new_args, text)
    end
    args = new_args

    local ctbl = IADM.Commands[cmd]
    if !ctbl then
        for k,_ in SortedPairs(IADM.Commands) do
            if string.sub(k, 1, #cmd) ~= cmd then continue end
            if !IADM:CanUseCommand(pl) then continue end
            MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "Invalid command ", IADM_ECHOCOLOR_ARG1, cmd, IADM_ECHOCOLOR_TEXT, ". Maybe you meant: ", IADM_ECHOCOLOR_ARG1, k, IADM_ECHOCOLOR_TEXT, "?\n")
            return
        end

        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "Invalid command ", IADM_ECHOCOLOR_ARG1, cmd, IADM_ECHOCOLOR_TEXT, ".\n")
        return
    end

    local inchat = false
    local needed = #ctbl.Args
    local defaultargsamt = 0
    for count,argument in ipairs(ctbl.Args) do
        needed = needed - ((argument.default or argument.optional or args[count]) and 1 or 0)
        defaultargsamt = defaultargsamt + ((argument.default or argument.optional) and 1 or 0)
    end

    if #ctbl.Args ~= 0 and #ctbl.Args-defaultargsamt == needed and needed ~= 0 then
        local s = ""
        for count,arg in ipairs(ctbl.Args) do
            if arg.type == IADM_ARGTYPE_STR then
                s = s..((arg.optional and string.format("[%s]", arg.hint or "text") or string.format("<%s>", arg.hint or "text")))
            elseif arg.type == IADM_ARGTYPE_NUM then
                s = s..((arg.optional and string.format("[%s]", arg.hint or "number") or string.format("<%s>", arg.hint or "text")))
            end
        end

        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "# "..(ctbl.Name or cmd)..(ctbl.Name and " ("..cmd..")" or "").."\n",
        IADM_ECHOCOLOR_ARG1, ctbl.Desc or "",
        IADM_ECHOCOLOR_ARG1, ctbl.Help and string.format("\nUsage: %s%s %s\n", IADM:GetPrefix(), cmd, s) or "",
        IADM_ECHOCOLOR_WARN, ctbl.Dangerous and "\nDangerous command. Only allow this command to members you trust and if it's necessary." or "", "\n")
        return
    elseif needed ~= 0 then
        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "Not enough arguments provided!", "\n")
        return
    end

    for count,arg in ipairs(ctbl.Args) do
        if arg and arg.default and not args[count] then
            args[count] = arg.default
        end
    end

    if CLIENT then
        net.Start("iadm_command")
        net.WriteString(cmd)
        net.WriteTable(args)
        net.SendToServer()

    elseif SERVER then
        if !IADM:CanUseCommand(pl, cmd) then
            IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "Insufficient permissions to use ", IADM_ECHOCOLOR_ERROR_ARGVAR, cmd, IADM_ECHOCOLOR_ERROR, " command!")
            pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
            return ""
        end

        args = IADM:ProcessCmdArgs(pl, inchat, ctbl, args)

        if !args or (#ctbl.Args ~= 0 and defaultargsamt ~= 0 and needed ~= 0) then return end

        if ctbl.ChatArg then
            ctbl.Func(pl, false, unpack(args))
        else
            ctbl.Func(pl, unpack(args))
        end
    end
end, function(cmd, argstr, args)
    local pl = CLIENT and LocalPlayer() or !game.IsDedicated() and player.GetAll()[1] or NULL
    local t = {}
    local arg1 = string_lower(args[1] or "")

    local ctbl = IADM.Commands[arg1]

    local next = string.sub(argstr, -1, -1) == " " and 1 or 0
    local currentarg = #args + next

    local islast = true
    local function add_to_results(...)
        if islast then
            table.insert(t, ...)
        end
    end

    if ctbl and currentarg >= 2 then
        local i = false
        local s = ""
        local str
        for count,carg in ipairs(ctbl.Args) do
            if count >= currentarg then break end

            if !str then
                str = cmd.." "..arg1..s
            end
            s = s.." "

            local arg = args[count + 1]
            islast = (count+1)==currentarg

            if (count+1) == currentarg then
                if arg then
                    -- s = s..arg

                    if carg.type == IADM_ARGTYPE_STR then
                       s = s..arg
                       add_to_results(str..s)
                    elseif carg.type == IADM_ARGTYPE_PLR or carg.type == IADM_ARGTYPE_PLRS then
                        if arg == "^" then
                            add_to_results(str..s..(string.format("\"%s\"", pl:Nick())))
                        else
                            for _,ply in ipairs(player.GetAll()) do
                                if string.find(string_lower(ply:Nick()), string_lower(arg)) and IADM:CmdCanTarget(pl, ply, ctbl, carg) then
                                    add_to_results(str..s..(string.format("\"%s\"", ply:Nick())))
                                end
                            end
                        end
                        -- break
                    end
                else
                    if carg.type == IADM_ARGTYPE_PLR or carg.type == IADM_ARGTYPE_PLRS then
                        for _,ply in ipairs(player.GetAll()) do
                            if !IADM:CmdCanTarget(pl, ply, ctbl, carg) then continue end
                            add_to_results(str..s..(string.format("\"%s\"", ply:Nick())))
                        end
                        -- break
                    else
                        local defaulthint = carg.type == IADM_ARGTYPE_NUM and "number" or carg.type == IADM_ARGTYPE_BOOL and "true/false" or "string"
                    
                        s = s ..((args[count + 1] or (carg.optional and string.format("[%s]", carg.hint or defaulthint) or string.format("<%s>", carg.hint or defaulthint))..
                        (carg.type == IADM_ARGTYPE_BOOL and " [1/0, true/false]" or "")))
                        add_to_results(str..s)
                    end
                end
            end

            if args[count+1] and not (carg.type == IADM_ARGTYPE_NUM and carg.type == IADM_ARGTYPE_BOOL) then
                args[count+1] = "\""..args[count+1].."\""
            end

            if arg then
                s=s..arg
            end
        end
    elseif currentarg < 2 then
        local times = 0
        for k,_ in pairs(IADM.Commands) do
            if string.sub(k, 1, #arg1) ~= arg1 then continue end
            if !IADM:CanUseCommand(pl, k) then continue end
            add_to_results(cmd.." "..k)
            if times >= 50 then break end
        end
    end

    return t
end, "nil", 0)

concommand.Add("iadm_changelogs", function(pl)
    if not (SERVER and (pl == NULL or pl:IsListenServerHost()) or CLIENT) then return end

    local col_h1 = Color(255, 224, 224)
    local col_h2 = Color(255, 240, 240)
    local col_add = Color(155, 244, 110)
    local col_del = Color(244, 54, 44)
    local col_warn = Color(255, 0, 0)
    local col_change = Color(255, 255, 120)
    local col_fix = Color(86, 209, 239)
    local change_notes = [[## v0.4 beta1 (#13)
+ Added logs module, a real-time logging module tracking player actions. Currently it logs the following:
player deaths, player connect, player disconnect, player say,
spawnprop, spawnragdoll, spawneffect, spawnnpc, spawnsent, spawnvehicle, spawnswep, giveswep,
toolgun usage
+ Add viewlogs command, lets you view recently logged events that took place in current session
+ Added 3 global echocolors, mostly for logging.

/ Changed Godmode text a bit

* Fixed suggesting unavailable commands upon attempting to run an unknown command
* Fixed groups module not working as intended
* Fixed being able to delete "user" group

! WARNING: Srlion's Hook Library is required for this module, otherwise expect lua errors and logging events failing!
]]

    local tbl = {}
    for i,v in pairs(string.Explode("\n", change_notes)) do
        if string.sub(v, 1, 1) == "+" then
            tbl[i] = {col_add, v.."\n"}
        elseif string.sub(v, 1, 1) == "-" then
            tbl[i] = {col_del, v.."\n"}
        elseif string.sub(v, 1, 1) == "!" then
            tbl[i] = {col_warn, v.."\n"}
        elseif string.sub(v, 1, 1) == "/" then
            tbl[i] = {col_change, v.."\n"}
        elseif string.sub(v, 1, 1) == "*" then
            tbl[i] = {col_fix, v.."\n"}
        elseif string.sub(v, 1, 2) == "##" then
            tbl[i] = {col_h2, v.."\n"}
        elseif string.sub(v, 1, 1) == "#" then
            tbl[i] = {col_h1, v.."\n"}
        else
            tbl[i] = {color_white, v.."\n"}
        end
    end

    for i=1,#tbl do
        local t = tbl[i]
        MsgC(t[1], t[2])
    end
end)

if not IADM.LogAction then
    function IADM:LogAction() -- add an empty function just in case
    end
end
