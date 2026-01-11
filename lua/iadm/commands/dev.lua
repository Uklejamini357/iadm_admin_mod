local col = Color(176, 237, 92)

local cmd = IADM:AddCommand("lua", function(caller, chat, code)
    RunString(code)
    IADM:LogCommandUse(caller, "#A ran lua #S", false, code)
end)
cmd.Name = "Lua"
cmd.Desc = "Runs a lua code. (Alias of lua_run)"
cmd.ChatArg = true
cmd.Dangerous = true
cmd.PowerLevelReq = IADM_GROUP_POWER_SUPERADMIN
cmd:AddArgument({type=IADM_ARGTYPE_STR, hint="code to run", varargs=true})

local cmd = IADM:AddCommand("entinfo", function(caller, chat, ent)
	ent = ent[1]
	if !IsValid(ent) then
		IADM:MessageWPrefix(caller, chat, col, "Entity is ", Color(255,0,0), "not valid", col, "!")
		return
	end

    IADM:MessageWPrefix(caller, chat, col, "Entity info for ", Color(255,0,0), tostring(ent), col, "!")
    IADM:Message(caller, chat, col, "Health: ", Color(255,0,0), ent:Health(), col, "/", Color(255,0,0), ent:GetMaxHealth())
	local wep = ent.GetActiveWeapon and ent:GetActiveWeapon()
	if wep and wep:IsValid() then
		IADM:Message(caller, chat, col, "Weapon: ", Color(255,0,0), wep:GetClass(), col, "(", Color(255,160,0), wep:EntIndex(), col, ")")
	end
end)
cmd.Name = "Ent info"
cmd.Desc = "Gets entity info (classname, hp/maxhp, weapon and ammo)"
cmd.ChatArg = true
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_ENTS, default="@"})

