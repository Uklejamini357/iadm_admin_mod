-- complex, but working code - might need to do the same for viewfulllogs (SQL)
local cmd = IADM:AddCommand("viewlogs", function(caller, page)
    local recentlogcount = #IADM.RecentLogs
    local maxpage = math.ceil(recentlogcount/50)

    page = math.Clamp(page, 1, maxpage)

    local counter = 50*(page-1)
    local maxcount = math.min(50*page, recentlogcount)

    IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "Recent logs (Page ", IADM_ECHOCOLOR_ARG1, page, IADM_ECHOCOLOR_LOGTEXT, " of ", IADM_ECHOCOLOR_ARG2, maxpage, IADM_ECHOCOLOR_LOGTEXT, ")")
    IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "Entries ", IADM_ECHOCOLOR_ARG1, counter+1, IADM_ECHOCOLOR_LOGTEXT, "-", IADM_ECHOCOLOR_ARG2, maxcount, IADM_ECHOCOLOR_LOGTEXT, ", out of ", IADM_ECHOCOLOR_ARG3, recentlogcount)
    for i=1,maxcount-counter do
        local v = IADM.RecentLogs[recentlogcount+(i-maxcount)]

        if !v then break end

        IADM:Message(caller, false, IADM_ECHOCOLOR_LOGTEXT, "[", IADM_ECHOCOLOR_TIMESTAMP, os.date("%H:%M:%S", v.time), " ", IADM_ECHOCOLOR_LOGTYPE, v.action or "unknown", IADM_ECHOCOLOR_LOGTEXT, "] ", IADM_ECHOCOLOR_TEXT, v.text)
    end

end)
cmd.Name = "View logs"
cmd.Desc = "View any recent logs on the current session"
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=1, hint="page"})
