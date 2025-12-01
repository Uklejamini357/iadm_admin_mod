local init = IADM

if not IADM then
    IADM = {}
    IADM.Commands = {}
    IADM.Config = {}
    IADM.Modules = {}
    IADM.Hooks = {}
    IADM.Prefix = "!"
    IADM.Version = "0.0"
    IADM.Author = "Uklejamini"
    IADM.DatabaseDir = "iadm"
end
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

function IADM:Message(ply, chat, ...)
    if SERVER then
        if istable(ply) or ply:IsValid() then
            net.Start("iadm_printmsg")
            net.WriteBit(0)
            net.WriteBit(chat and 1 or 0)
            net.WriteTable({...})
            net.Send(ply)
        else
            MsgC(..., "\n")
        end
    elseif CLIENT then
        if chat then
            chat.AddText(...)
        else
            MsgC(..., "\n")
        end
    end
end

function IADM:MessageWPrefix(ply, chat, ...)
    local col_purple = Color(138, 97, 226)
    if SERVER then
        if istable(ply) or ply:IsValid() then
            net.Start("iadm_printmsg")
            net.WriteBit(1)
            net.WriteBit(chat and 1 or 0)
            net.WriteTable({...})
            net.Send(ply)
        else
            MsgC(col_purple, "[IADM] ", color_white, ...)
            MsgN()
        end
    elseif CLIENT then
        if chat then
            chat.AddText(col_purple, "[IADM] ", color_white, ...)
        else
            MsgC(col_purple, "[IADM] ", color_white, ...)
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


function IADM:ProcessCmdArgs(pl, inchat, ctbl, args)
    for count,v in pairs(args) do
        local carg = ctbl.Args[count]
        if !carg then break end
        if carg.varargs then
            for i=count+1,#args do
                print(i, a)
                args[count] = args[count].." "..args[i]
            end
            break
        end
        local a = args[count]

        if carg.type == "PlrArg" then
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
                    IADM:Message(pl, inchat, Color(255,0,0), "Arg #", Color(255,160,0), count, Color(255,0,0), " error: ",
                    Color(255,128,0), Format("Too many players (%d) to select from! ", #tbl), Color(255,255,0), "Select from:\n",
                    Color(255,128,0), s)
                    return
                end

                a = tbl[1]
            end

            if isstring(a) or !IsValid(a) or !a:IsPlayer() then
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", Color(255,160,0), count, Color(255,0,0), " error: ", Color(255,128,0), "Player not found!")
                return
            end

            args[count] = a
        elseif carg.type == "EntsArg" then
            if a == "^" then
                a = {pl}
            elseif a == "@" then
                a = {pl:GetEyeTrace().Entity}
            elseif isnumber(tonumber(a)) and Entity(a or 0) and IsValid(Entity(a or 0)) then
                a = {Entity(a)}
            else
                local tbl = {}
                for _,ent in pairs(ents.FindByClass(a)) do
                    table.insert(tbl, ent)
                end
                
                for _,ply in pairs(player.GetAll()) do
                    if string.find(string_lower(ply:Nick()), string_lower(v)) then
                        table.insert(tbl, ply)
                    end
                end
                a = tbl
            end

            if isstring(a) or !istable(a) and !IsValid(a) then
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", Color(255,160,0), count, Color(255,0,0), " error: ", Color(255,128,0), "Could not find an entity!")
                return
            end

            args[count] = a
        elseif carg.type == "NumArg" then
            a = tonumber(a)
            if a then
                if carg.min then
                    math.max(carg.min, a)
                end

                if carg.max then
                    math.min(carg.max, a)
                end
            else
                IADM:Message(pl, inchat, Color(255,0,0), "Arg #", Color(255,160,0), count, Color(255,0,0), " error: ", Color(255,128,0), "Invalid number!")
                return
            end
            args[count] = a
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
    local maincol = Color(147, 107, 226)
    local col1 = Color(127, 207, 126)
    local col2 = Color(83, 234, 196)
    if #args == 0 then
        MsgC(maincol, prefix, col1, "No command selected. Currently available commands: ", col2, table.Count(IADM.Commands), "\n")
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
            MsgC(maincol, prefix, col1, "Invalid command ", col2, cmd, col1, ". Maybe you meant: ", col2, k, col1, "?\n")
            return
        end

        MsgC(maincol, prefix, col1, "Invalid command ", col2, cmd, col1, ".\n")
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
    local needed_default = #ctbl.Args
    local defaultargsamt = #ctbl.Args
    for count,argument in ipairs(ctbl.Args) do
        needed = needed - ((argument.default or argument.optional or args[count]) and 1 or 0)
        needed_default = needed_default - ((argument.default or argument.optional) and 1 or 0)
    end

    if #ctbl.Args ~= 0 and #ctbl.Args-needed_default == needed then
        local s = ""
        for count,arg in pairs(ctbl.Args) do
            if arg.type == "StrArg" then
                s = s..((arg.optional and string.format("[%s]", arg.hint or "text") or string.format("<%s>", arg.hint or "text")))
            elseif arg.type == "NumArg" then
                s = s..((arg.optional and string.format("[%s]", arg.hint or "number") or string.format("<%s>", arg.hint or "text")))
            end
        end

        MsgC(maincol, prefix, col1, "# "..(ctbl.Name or cmd)..(ctbl.Name and " ("..cmd..")" or "").."\n",
        col2, ctbl.Desc or "",
        col2, ctbl.Help and string.format("\nUsage: %s%s %s\n", IADM.Prefix, cmd, s) or "", "\n")
        return
    elseif needed ~= 0 then
        MsgC(maincol, prefix, col1, "Not enough arguments provided!", "\n")
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
            local col_error = Color(255,0,0)
            IADM:Message(pl, true, col_error, "Insufficient permissions! Need ", Color(255,160,0), ctbl.PermsRequire, col_error, " rank!")
            pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
            return ""
        end

        args = IADM:ProcessCmdArgs(pl, inchat, ctbl, args)

        if !args then return end

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
                if carg.type == "StrArg" then
                    s = s..arg
                    table.insert(t, str..s)
                elseif carg.type == "PlrArg" then
                    for _,ply in pairs(player.GetAll()) do
                        if string.find(string_lower(ply:Nick()), string_lower(arg)) then
                            table.insert(t, str..s..(string.format("\"%s\"", ply:Nick())))
                        end
                    end
                    break
                end
            else
                if carg.type == "StrArg" then
                    s = s ..((args[count + 1] or (carg.optional and string.format("[%s]", carg.hint or "text") or string.format("<%s>", carg.hint or "text"))))
                    table.insert(t, str..s)
                    break
                elseif carg.type == "PlrArg" then
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
    local change_notes = [[Initial Release - v0.1
+ Basic commands functionality
+ Basic permissions command check system
+ 13 commands, including: help, status, lua, kill, skill, ignite, unignite, teleport, kick, tsay, csay, noclip and cleanup
+ Usable commands from chat

! There is no database nor any kind of usergroup management yet.
! This will be added in v0.2 release.]]

    local tbl = {}
    for i,v in pairs(string.Explode("\n", change_notes)) do
        if string.sub(v, 1, 1) == "+" then
            tbl[i] = {col_add, v.."\n"}
        elseif string.sub(v, 1, 1) == "-" then
            tbl[i] = {col_del, v.."\n"}
        elseif string.sub(v, 1, 1) == "!" then
            tbl[i] = {col_warn, v.."\n"}
        else
            tbl[i] = {color_white, v.."\n"}
        end
    end

    for i=1,#tbl do
        local t = tbl[i]
        MsgC(t[1], t[2])
    end
end)


for _,file in ipairs(file.Find("iadm/commands/*.lua", "LUA", "sortasc")) do
    AddCSLuaFile("iadm/commands/"..file)
    include("iadm/commands/"..file)
end

for _,file in ipairs(file.Find("iadm/modules/*.lua", "LUA", "sortasc")) do
    include("iadm/modules/"..file)
end
