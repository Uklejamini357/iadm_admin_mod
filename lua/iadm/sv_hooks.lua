util.AddNetworkString("iadm_command")
util.AddNetworkString("iadm_printmsg")
util.AddNetworkString("iadm_csay")
util.AddNetworkString("iadm_playerusecmd")

net.Receive("iadm_command", function(len, pl)
    local cmd = net.ReadString()
    local args = net.ReadTable()
	
	local ctbl = IADM.Commands[cmd]
	if !ctbl then return end

    if not (pl == NULL or pl:IsListenServerHost()) then
        local col_error = Color(255,0,0)
        if (ctbl.PermsRequire == "admin" and !pl:IsAdmin()) or (ctbl.PermsRequire == "superadmin" and !pl:IsSuperAdmin()) then
            IADM:Message(pl, true, col_error, "Insufficient permissions! Need ", Color(255,160,0), ctbl.PermsRequire, col_error, " rank!")
            pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
            return ""
        end
    end
	
    if ctbl.ChatArg then
	    ctbl.Func(pl, false, args)
    else
    	ctbl.Func(pl, args)
    end
end)

local string_lower = string.lower
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

        if not (pl == NULL or pl:IsListenServerHost()) then
            local col_error = Color(255,0,0)
            if (ctbl.PermsRequire == "admin" and !pl:IsAdmin()) or (ctbl.PermsRequire == "superadmin" and !pl:IsSuperAdmin()) then
                IADM:Message(pl, true, col_error, "Insufficient permissions! Need ", Color(255,160,0), ctbl.PermsRequire, col_error, " rank!")
                pl:SendLua([[surface.PlaySound("buttons/button11.wav")]])
                return ""
            end
        end

        local a = string.Explode("\"", string.sub(text, #command + 1))
        local args = {}
        for k,v in pairs(a) do
            if k%2 == 0 then
                table.insert(args, v)
            else
                for _,v2 in pairs(string.Explode(" ", v)) do
                    table.insert(args, v2)
                end
            end
        end

        local needed = #ctbl.Args
        for count,argument in ipairs(ctbl.Args) do
            needed = needed - ((argument.default or argument.optional or args[count]) and 1 or 0)
        end

        if needed != 0 then return end

        cmd = string.lower(args[1] or "")
        args[1] = nil

        local new_args = {}
        for _,text in pairs(args) do
            table.insert(new_args, text)
        end
        args = new_args

        for count,arg in pairs(ctbl.Args) do
            if arg and arg.default and not args[count] then
                args[count] = arg.default
            end
        end


        local inchat = true
        timer.Simple(0, function()
            args = IADM:ProcessCmdArgs(pl, inchat, ctbl, args)

            if !args then return end

            if ctbl.ChatArg then
                ctbl.Func(pl, inchat, unpack(args))
            else
                ctbl.Func(pl, unpack(args))
            end
        end)
    end
end, HOOK_LOW)
