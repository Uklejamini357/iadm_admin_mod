local cmd = IADM:AddCommand("groupadd", function(caller, targets)

end)
cmd.Name = "Add group"
cmd.Desc = "Adds a new usergroup."
cmd.Dangerous = true
cmd.PermsRequire = "superadmin"
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="usergroupname"})
