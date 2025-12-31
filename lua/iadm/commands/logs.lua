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

        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%H:%M:%S", v.time), " ", IADM_ECHOCOLOR_LOGTYPE, v.action or "unknown", IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, v.text)
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

    local count1 = math.max(1, 1+(page-1)*50)
    local count2 = math.min(maxcount, page*50)

    local logs
    if logtype == "all" then
        logs = sql.QueryTyped("SELECT * FROM iadm_logs ORDER BY id DESC")
    else
        logs = sql.QueryTyped("SELECT * FROM iadm_logs WHERE action=? ORDER BY id DESC",
        logtype)
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
    for i=count2,count1,-1 do
        local v = logs[i]
        if !v then continue end
        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%Y-%m-%d %H:%M:%S", v.time), " ", IADM_ECHOCOLOR_LOGTYPE, v.action or "unknown", IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, v.str)
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
    local completetime = SysTime()-time

    IADM:Message(caller, true, Color(255,0,0), string.format("Deleted all %d entries. Deleted %d recent entries. Took %s", entries, recententries, completetime > 1 and math.Round(completetime, 2).."s" or math.Round(completetime*1000).."ms"))
end)
cmd.Name = "Delete logs"
cmd.Desc = "Deletes logs. Something you don't want to do normally."
cmd.Dangerous = true
cmd.PowerLevelReq = IADM_GROUP_POWER_GODMODE
cmd:AddArgument({type=IADM_ARGTYPE_STR, optional=true, hint="confirm", varargs=true})
