local cmd = IADM:AddCommand("groupadd", function(caller, chat, name, powerlevel)
    local success, reason = IADM:AddGroup(name, powerlevel, caller)

    if success then
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Created ", IADM_ECHOCOLOR_ARG1, name, IADM_ECHOCOLOR_TEXT, " usergroup with ", IADM_ECHOCOLOR_ARG2, "powerlevel ", IADM_ECHOCOLOR_ARG1, powerlevel, IADM_ECHOCOLOR_TEXT, "!")
    else
        IADM:Message(caller, chat, IADM_ECHOCOLOR_ERROR, "Failed to make a new usergroup! (", IADM_ECHOCOLOR_ERROR_REASON, reason, IADM_ECHOCOLOR_ERROR, ")")
    end
end)
cmd.Name = "Add group"
cmd.Desc = "Adds a new usergroup."
cmd.Dangerous = true
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="usergroupname"})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, hint="powerlevel"})


local cmd = IADM:AddCommand("groupdel", function(caller, chat, name)
    local success, reason = IADM:RemoveGroup(name, caller)

    if success then
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Removed ", IADM_ECHOCOLOR_ARG1, name, IADM_ECHOCOLOR_TEXT, " usergroup!")
    else
        IADM:Message(caller, chat, IADM_ECHOCOLOR_ERROR, "Failed to delete an usergroup! (", IADM_ECHOCOLOR_ERROR_REASON, reason, IADM_ECHOCOLOR_ERROR, ")")
    end
end)
cmd.Name = "Delete group"
cmd.Desc = "Deletes usergroup."
cmd.Dangerous = true
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="usergroupname"})

local cmd = IADM:AddCommand("groupmodify", function(caller, chat, name, arg, value)
    local success, reason = IADM:ModifyGroup(name, key, value, caller)

    if success then
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Modified ", IADM_ECHOCOLOR_ARG1, name, IADM_ECHOCOLOR_TEXT, " usergroup!")
    else
        IADM:Message(caller, chat, IADM_ECHOCOLOR_ERROR, "Failed to modify an usergroup! (", IADM_ECHOCOLOR_ERROR_REASON, reason, IADM_ECHOCOLOR_ERROR, ")")
    end
end)
cmd.Name = "Modify group"
cmd.Desc = "Modifies usergroup variables."
cmd.Dangerous = true
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="usergroupname"})


local cmd = IADM:AddCommand("setgroup", function(caller, chat, target, group)
    local success, reason = IADM:AddUserToGroup(target:SteamID64(), group, caller:SteamID64())

    if success then
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Set ", IADM_ECHOCOLOR_ARG1, target, IADM_ECHOCOLOR_TEXT, "'s usergroup to ", IADM_ECHOCOLOR_ARG2, group, IADM_ECHOCOLOR_TEXT,  "!")
    else
        IADM:Message(caller, chat, IADM_ECHOCOLOR_ERROR, "Failed to set user's group! (", IADM_ECHOCOLOR_ERROR_REASON, reason, IADM_ECHOCOLOR_ERROR, ")")
    end
end)
cmd.Name = "Set user group"
cmd.Desc = "Gives a new rank to selected target(s)."
cmd.Dangerous = true
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLR})
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="usergroupname"})
