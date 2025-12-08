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
end

IADM.Prefix = {"!", "/"}
IADM.Version = "0.3 beta 2"
IADM.UpdateVer = 6
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

function IADM:Message(ply, chat, ...)
    if SERVER then
        if istable(ply) or ply:IsValid() then
            net.Start("iadm_printmsg")
            net.WriteBit(0)
            net.WriteBit(chat and 1 or 0)
            net.WriteTable({...})
            net.Send(ply)
        else
            MsgC(...)
            MsgN()
        end
    elseif CLIENT then
        if chat then
            chat.AddText(...)
        else
            MsgC(...)
            MsgN()
        end
    end
end

function IADM:MessageWPrefix(ply, chat, ...)
    if SERVER then
        if istable(ply) or ply:IsValid() then
            net.Start("iadm_printmsg")
            net.WriteBit(1)
            net.WriteBit(chat and 1 or 0)
            net.WriteTable({...})
            net.Send(ply)
        else
            MsgC(IADM_ECHOCOLOR_PREFIX, "[IADM] ", color_white, ...)
            MsgN()
        end
    elseif CLIENT then
        if chat then
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
                    for _,ent in pairs(ents.FindByClass(a)) do
                        table.insert(tbl, ent)
                    end
                end
                
                for _,ply in pairs(player.GetAll()) do
                    if string.find(string_lower(ply:Nick()), string_lower(v)) then
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
                    math.max(carg.min, a)
                end

                if carg.max then
                    math.min(carg.max, a)
                end
            else
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", IADM_ECHOCOLOR_ERROR_ARGVAR, count, Color(255,0,0), " error: ", Color(255,128,0), "Invalid number!")
                return
            end
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
    if (pl == NULL or pl:IsListenServerHost()) then return true end
    local ctbl = IADM.Commands[cmd]
    if not ctbl then return false end

    if (ctbl.PermsRequire == "admin" and !pl:IsAdmin()) then
        return false
    elseif (ctbl.PermsRequire == "superadmin" and !pl:IsSuperAdmin()) then
        return false
    end

    return true
end


concommand.Add("iadm", function(pl, cmd, args, str)
    local prefix = "[IADM] "
    if #args == 0 then
        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "No command selected. Currently available commands: ", IADM_ECHOCOLOR_ARG1, table.Count(IADM.Commands), "\n")
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
            MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "Invalid command ", IADM_ECHOCOLOR_ARG1, cmd, IADM_ECHOCOLOR_TEXT, ". Maybe you meant: ", IADM_ECHOCOLOR_ARG1, k, IADM_ECHOCOLOR_TEXT, "?\n")
            return
        end

        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "Invalid command ", IADM_ECHOCOLOR_ARG1, cmd, IADM_ECHOCOLOR_TEXT, ".\n")
        return
    end

--[[
    for cmd,arg in pairs(IADM.Commands) do
        if arg.Aliases then

        end
    end
]]

    local inchat = false
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

        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "# "..(ctbl.Name or cmd)..(ctbl.Name and " ("..cmd..")" or "").."\n",
        IADM_ECHOCOLOR_ARG1, ctbl.Desc or "",
        IADM_ECHOCOLOR_ARG1, ctbl.Help and string.format("\nUsage: %s%s %s\n", IADM:GetPrefix(), cmd, s) or "", "\n")
        return
    elseif needed ~= 0 then
        MsgC(IADM_ECHOCOLOR_PREFIX, prefix, IADM_ECHOCOLOR_TEXT, "Not enough arguments provided!", "\n")
        return
    end

    for count,arg in pairs(ctbl.Args) do
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
            IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "Insufficient permissions! Need ", IADM_ECHOCOLOR_ERROR_ARGVAR, ctbl.PermsRequire, IADM_ECHOCOLOR_ERROR, " rank!")
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
    local t = {}
    local arg1 = string_lower(args[1] or "")

    local ctbl = IADM.Commands[arg1]

    local next = string.sub(argstr, -1, -1) == " " and 1 or 0
    if ctbl and (#args + next) >= 2 then
        local i = false
        local s = ""
        local str
        for count,carg in pairs(ctbl.Args) do
            if count >= (#args + next) then break end

            if !str then
                str = cmd.." "..arg1..s
            end
            s = s.." "

            local arg = args[count + 1]

            if arg then
                -- s = s..arg
                if carg.type == IADM_ARGTYPE_STR then
                    s = s..arg
                    table.insert(t, str..s)
                elseif carg.type == IADM_ARGTYPE_PLR or carg.type == IADM_ARGTYPE_PLRS then
                    for _,ply in pairs(player.GetAll()) do
                        if string.find(string_lower(ply:Nick()), string_lower(arg)) then
                            table.insert(t, str..s..(string.format("\"%s\"", ply:Nick())))
                        end
                    end
                    break
                end
            else
                if carg.type == IADM_ARGTYPE_STR then
                    s = s ..((args[count + 1] or (carg.optional and string.format("[%s]", carg.hint or "text") or string.format("<%s>", carg.hint or "text"))))
                    table.insert(t, str..s)
                    break
                elseif carg.type == IADM_ARGTYPE_PLR or carg.type == IADM_ARGTYPE_PLRS then
                    for _,ply in pairs(player.GetAll()) do
                        table.insert(t, str..s..(string.format("\"%s\"", ply:Nick())))
                    end
                    break
                end
            end
        end
    elseif (#args + next) < 2 then
        local times = 0
        for k,_ in SortedPairs(IADM.Commands) do
            if string.sub(k, 1, #arg1) ~= arg1 then continue end
            if !IADM:CanUseCommand(CLIENT and LocalPlayer() or NULL, k) then continue end
            table.insert(t, cmd.." "..k)
            if times >= 50 then break end
        end
    end

    return t
end, "nil", 0)

concommand.Add("iadm_changelogs", function(pl)
    if not (SERVER and (pl == NULL or pl:IsListenServerHost()) or CLIENT) then return end

    local col_add = Color(155, 244, 110)
    local col_del = Color(244, 54, 44)
    local col_warn = Color(255, 0, 0)
    local col_fix = Color(86, 209, 239)
    local change_notes = [[]]

    local tbl = {}
    for i,v in pairs(string.Explode("\n", change_notes)) do
        if string.sub(v, 1, 1) == "+" then
            tbl[i] = {col_add, v.."\n"}
        elseif string.sub(v, 1, 1) == "-" then
            tbl[i] = {col_del, v.."\n"}
        elseif string.sub(v, 1, 1) == "!" then
            tbl[i] = {col_warn, v.."\n"}
        elseif string.sub(v, 1, 1) == "*" then
            tbl[i] = {col_fix, v.."\n"}
        else
            tbl[i] = {color_white, v.."\n"}
        end
    end

    for i=1,#tbl do
        local t = tbl[i]
        MsgC(t[1], t[2])
    end
end)


local files = file.Find("iadm/modules/*.lua", "LUA", "sortasc")
for _,file in ipairs(files) do
    if string.StartsWith(file, "sv_") then continue end
    IADM_MODULE_SHOULDINCLUDE = true
    include("iadm/modules/"..file)
    IADM_MODULE_SHOULDINCLUDE = nil
end

files = file.Find("iadm/modules/sv_*.lua", "LUA", "sortasc")
for _,file in ipairs(files) do
    IADM_MODULE_SHOULDINCLUDE = true
    include("iadm/modules/"..file)
    IADM_MODULE_SHOULDINCLUDE = nil
end

files = file.Find("iadm/commands/*.lua", "LUA", "sortasc")
for _,file in ipairs(files) do
    AddCSLuaFile("iadm/commands/"..file)
    include("iadm/commands/"..file)
end
