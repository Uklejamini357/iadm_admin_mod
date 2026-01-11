-- complex, but working code - might need to do the same for viewfulllogs (SQL)
local cmd = IADM:AddCommand("viewlogs", function(caller, chat, logtype, page)
    local logs = logtype == "all" and IADM.RecentLogs or IADM.RecentLogsByAction[logtype]
    if !logs or logtype == "list" then
        if logtype == "list" then
            IADM:Message(caller, true, IADM_ECHOCOLOR_ARG1, "Available log types (prints in console)")
        else
            IADM:Message(caller, true, IADM_ECHOCOLOR_ERROR, "Invalid log type! ", IADM_ECHOCOLOR_ERROR_REASON, "Available log types (prints in console)")
        end
        for _logtype,_ in SortedPairs(IADM.LogFunc) do
            IADM:Message(caller, false, IADM_ECHOCOLOR_ARG1, "\t-> ", IADM_ECHOCOLOR_ARG2, _logtype)
        end
        return
    end

    local recentlogcount = #logs
    local maxpage = math.ceil(recentlogcount/50)
    page = math.Clamp(page, 1, maxpage)

    local counter = 50*(page-1)
    local maxcount = math.min(50*page, recentlogcount)

    IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "Recent Server logs [", IADM_ECHOCOLOR_ARG3, logtype, IADM_ECHOCOLOR_LOGTEXT, "] (Page ", IADM_ECHOCOLOR_ARG1, page, IADM_ECHOCOLOR_LOGTEXT, " of ", IADM_ECHOCOLOR_ARG2, maxpage, IADM_ECHOCOLOR_LOGTEXT, ")")
    if maxcount == 0 then
        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "No entries to display!")
        return
    end
    IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "Entries ", IADM_ECHOCOLOR_ARG1, counter+1, IADM_ECHOCOLOR_LOGTEXT, "-", IADM_ECHOCOLOR_ARG2, maxcount, IADM_ECHOCOLOR_LOGTEXT, ", out of ", IADM_ECHOCOLOR_ARG3, recentlogcount)
    for i=1,maxcount-counter do
        local v = logs[recentlogcount+(i-maxcount)]

        if !v then break end

		local blah = v.count and v.count > 1 and {" ", IADM_ECHOCOLOR_TEXT, "(x", IADM_ECHOCOLOR_ARG3, v.count, IADM_ECHOCOLOR_TEXT, ")"} or {}
        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%H:%M:%S", v.time), " ", IADM_ECHOCOLOR_LOGTYPE, v.action or "unknown", IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, v.text, unpack(blah))
    end

end)
cmd.Name = "View recent logs"
cmd.Desc = "View recently logged events on the current session"
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, default="all", hint="logtype"})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=1, hint="page"})

local cmd = IADM:AddCommand("viewfulllogs", function(caller, logtype, page)
    local maxcount
    if logtype == "all" then
        maxcount = sql.QueryTyped("SELECT COUNT(*) FROM iadm_logs")[1]["COUNT(*)"]
    else
        maxcount = sql.QueryTyped("SELECT COUNT(*) FROM iadm_logs WHERE action=?", logtype)[1]["COUNT(*)"]
    end
    local maxpage = math.ceil(maxcount/50)
    page = math.Clamp(page, 1, maxpage)

	local c = (page-1)*50
    local count1 = math.max(1, 1+c)
    local count2 = math.min(maxcount, page*50)

    local logs
    if logtype == "all" then
        logs = sql.QueryTyped("SELECT * FROM iadm_logs ORDER BY id DESC LIMIT ?,50",
            count1-1
        )
    else
        logs = sql.QueryTyped("SELECT * FROM iadm_logs WHERE action=? ORDER BY id DESC LIMIT ?,50",
            logtype,
            count1-1
        )
    end

    if !logs or logtype == "list" then
        if logtype == "list" then
            IADM:Message(caller, true, IADM_ECHOCOLOR_ARG1, "Available log types (prints in console)")
        else
            IADM:Message(caller, true, IADM_ECHOCOLOR_ERROR, "Invalid log type! ", IADM_ECHOCOLOR_ERROR_REASON, "Available log types (prints in console)")
        end
        for _logtype,_ in SortedPairs(IADM.LogFunc) do
            IADM:Message(caller, false, IADM_ECHOCOLOR_ARG1, "\t-> ", IADM_ECHOCOLOR_ARG2, _logtype)
        end
        return
    end

    IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "Server logs [", IADM_ECHOCOLOR_ARG3, logtype, IADM_ECHOCOLOR_LOGTEXT, "] (Page ", IADM_ECHOCOLOR_ARG1, page, IADM_ECHOCOLOR_LOGTEXT, " of ", IADM_ECHOCOLOR_ARG2, maxpage, IADM_ECHOCOLOR_LOGTEXT, ")")
    if maxcount == 0 then
        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "No entries to display!")
        return
    end
    IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "Entries ", IADM_ECHOCOLOR_ARG1, count1, IADM_ECHOCOLOR_LOGTEXT, "-", IADM_ECHOCOLOR_ARG2, count2, IADM_ECHOCOLOR_LOGTEXT, ", out of ", IADM_ECHOCOLOR_ARG3, maxcount)
	
	local v
    for i=count2-c,count1-c,-1 do
		v = logs[i]
		if !v then continue end
		local blah = v.count and v.count > 1 and {" ", IADM_ECHOCOLOR_TEXT, "(x", IADM_ECHOCOLOR_ARG3, v.count, IADM_ECHOCOLOR_TEXT, ")"} or {}
        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%Y-%m-%d %H:%M:%S", v.time), " ", IADM_ECHOCOLOR_LOGTYPE, v.action or "unknown", IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, v.str, unpack(blah))
    end
end)
cmd.Name = "View logs"
cmd.Desc = "View a list of logged events on the server"
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, default="all", hint="logtype"})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=1, hint="page"})


local confirm
local cmd = IADM:AddCommand("deletelogs", function(caller, confirmtext)
    if confirmtext ~= "I wish." then
        IADM:Message(caller, true, Color(255,0,0), "WARNING: Deleting logs is something you don't want to do.")
        IADM:Message(caller, true, Color(255,0,0), "If you want to confirm this action anyway, put in arg #1 \"I wish.\" if you want to proceed.")
        return
    end

    local recententries = #IADM.RecentLogs
    local entries = sql.QueryTyped("SELECT COUNT(*) FROM iadm_logs")[1]["COUNT(*)"]

    local time = SysTime()
    table.Empty(IADM.RecentLogs)
    for logtype in pairs(IADM.RecentLogsByAction) do
        table.Empty(IADM.RecentLogsByAction[logtype])
    end
    sql.QueryTyped("DELETE FROM iadm_logs")
	IADM:LogCommandUse(caller, "#A has deleted the whole logs!", {silent=true})
    local completetime = SysTime()-time

    IADM:Message(caller, true, Color(255,0,0), string.format("Deleted all %d entries. Deleted %d recent entries. Took %s", entries, recententries, completetime > 1 and math.Round(completetime, 2).."s" or math.Round(completetime*1000).."ms"))
end)
cmd.Name = "Delete logs"
cmd.Desc = "Deletes logs. Something you don't want to do normally."
cmd.Dangerous = true
cmd.PowerLevelReq = IADM_GROUP_POWER_GODMODE
cmd:AddArgument({type=IADM_ARGTYPE_STR, optional=true, hint="confirm", varargs=true})


local confirm
local cmd = IADM:AddCommand("monitorlogs", function(caller, logtype, toggle)
    if caller == NULL or caller:IsListenServerHost() then
        IADM:Message(caller, true, "You are already monitoring all the server logs by default!")
        return
    end
    local tbl = IADM.MonitorLog[caller]

    if !tbl then
        tbl = {}
        IADM.MonitorLog[caller] = tbl
    end

    if logtype == "list" then
		IADM:Message(caller, true, IADM_ECHOCOLOR_TEXT, "List of log types that can be monitored: ", IADM_ECHOCOLOR_ARG1, "(Shows in console)")
		for id,_ in SortedPairs(IADM.LogFunc) do
			IADM:Message(caller, false, IADM_ECHOCOLOR_ARG2, "\t-> ", IADM_ECHOCOLOR_ARG1, id)
		end
		return
	elseif logtype == "current" then
		IADM:Message(caller, true, IADM_ECHOCOLOR_TEXT, "List of currently monitoring: ", IADM_ECHOCOLOR_ARG1, "(Shows in console)")
		for id,_ in SortedPairs(IADM.LogFunc) do
			IADM:Message(caller, false, IADM_ECHOCOLOR_ARG2, "\t-> ", IADM_ECHOCOLOR_ARG1, id)
		end
		return
	elseif logtype == "all" then
        IADM:MessageWPrefix(caller, true, IADM_ECHOCOLOR_ARG1, toggle and "Now" or "No longer", IADM_ECHOCOLOR_TEXT, " monitoring ", IADM_ECHOCOLOR_ARG2, "everything")
        if toggle then
            tbl = "all"
        else
            tbl = nil
        end
        IADM.MonitorLog[caller] = tbl
        return
    end

    if tbl == "all" then
        return
    end

    if !IADM.LogFunc[logtype] then
        IADM:Message(caller, true, IADM_ECHOCOLOR_ERROR, "Invalid logtype.")
        return
    end

    if toggle then
        if table.HasValue(tbl, logtype) then
            IADM:Message(caller, true, IADM_ECHOCOLOR_ERROR, "Logtype ", IADM_ECHOCOLOR_ERROR_ARGVAR, logtype, IADM_ECHOCOLOR_ERROR, " already enabled!")
            return
        end
        table.insert(tbl, logtype)
    else
        if !table.HasValue(tbl, logtype) then
            IADM:Message(caller, true, IADM_ECHOCOLOR_ERROR, "Logtype ", IADM_ECHOCOLOR_ERROR_ARGVAR, logtype, IADM_ECHOCOLOR_ERROR, " not enabled!")
            return
        end
        table.RemoveByValue(tbl, logtype)
    end

    IADM.MonitorLog[caller] = tbl
    IADM:MessageWPrefix(caller, true, IADM_ECHOCOLOR_ARG1, toggle and "Now" or "No longer", IADM_ECHOCOLOR_TEXT, " monitoring ", IADM_ECHOCOLOR_ARG2, logtype)
end)
cmd.Name = "Monitor logs"
cmd.Desc = "Monitors logs. Use \"list\" for the list, use \"current\" for currently monitored logs. Use \"all\" to monitor everything."
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="logtype"})
cmd:AddArgument({type=IADM_ARGTYPE_BOOL, default=true, hint="toggle"})
