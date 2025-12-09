local cmd = IADM:AddCommand("groupadd", function(caller, chat, name, powerlevel)
    local success, reason = IADM:AddGroup(name, powerlevel, caller)

    if !success then
        IADM:Message(caller, chat, IADM_ECHOCOLOR_TEXT, "Created a group ", IADM_ECHOCOLOR_ARG1, name, IADM_ECHOCOLOR_TEXT, " with ", IADM_ECHOCOLOR_ARG2, "powerlevel ", IADM_ECHOCOLOR_ARG1, powerlevel, IADM_ECHOCOLOR_TEXT, "!")
    else
        IADM:Message(caller, chat, IADM_ECHOCOLOR_ERROR, "Failed to make a new usergroup! (", IADM_ECHOCOLOR_ERROR_REASON, name, IADM_ECHOCOLOR_ERROR, ")")
    end
end)
cmd.Name = "Add group"
cmd.Desc = "Adds a new usergroup."
cmd.Dangerous = true
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="usergroupname"})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, hint="powerlevel"})
