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

local string_lower = string.lower
local maincol = Color(147, 107, 226)
hook.Add("PlayerSay", "IADM.PlayerSay", function(pl, text)
    if string.sub(text, 1, #IADM.Prefix) == IADM.Prefix then
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

        local silent = ctbl.Silent

        if !IADM:CanUseCommand(pl, cmd) then
            IADM:Message(pl, true, IADM_ECHOCOLOR_ERROR, "Insufficient permissions! Need ", IADM_ECHOCOLOR_ERROR_ARGVAR, ctbl.PermsRequire, IADM_ECHOCOLOR_ERROR, " rank!")
            pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
            return ""
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
        
            IADM:MessageWPrefix(pl, true, maincol, prefix, IADM_ECHOCOLOR_TEXT, "# "..(ctbl.Name or cmd)..(ctbl.Name and " ("..IADM.Prefix..cmd..")" or "").."\n",
            IADM_ECHOCOLOR_ARG1, ctbl.Desc or "",
            IADM_ECHOCOLOR_ARG1, ctbl.Help and string.format("\nUsage: %s%s %s\n", IADM.Prefix, cmd, s) or "", "\n")
            return ""
        elseif needed ~= 0 then
            IADM:MessageWPrefix(pl, true, maincol, prefix, IADM_ECHOCOLOR_TEXT, "Not enough arguments provided!", "\n")
            return ""
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

            if !args or (#ctbl.Args ~= 0 and defaultargsamt ~= 0 and needed ~= 0) then return end

            if ctbl.ChatArg then
                ctbl.Func(pl, inchat, unpack(args))
            else
                ctbl.Func(pl, unpack(args))
            end
        end)

        if ctbl.Silent then return "" end
    end
end, HOOK_LOW)
