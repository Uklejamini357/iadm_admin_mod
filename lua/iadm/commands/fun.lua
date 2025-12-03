local allplys = player.GetAll

local cmd = IADM:AddCommand("kill", function(caller, target)
    local col = Color(176, 237, 92)

    if target:Alive() then
        target:Kill()
        IADM:MessageWPrefix(allplys(), true, col, "Killed ", Color(255,0,0), target:Nick(), col, "!")
    end
end)
cmd.Name = "Kill"
cmd.Desc = "Kills the player."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLR})

local cmd = IADM:AddCommand("skill", function(caller, target)
    local col = Color(176, 237, 92)

    if target:Alive() then
        target:KillSilent()
        IADM:MessageWPrefix(allplys(), true, col, "Killed ", Color(255,0,0), target:Nick(), col, " silently!")
    end
end)
cmd.Name = "Silent Kill"
cmd.Desc = "Silently kills the player."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLR})


local cmd = IADM:AddCommand("hp", function(caller, targets, hp)
    for i=1,#targets do
        targets[i]:SetHealth(hp)
    end
end)
cmd.Name = "Hp"
cmd.Desc = "Sets the target a specified amount of health."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=300})

local cmd = IADM:AddCommand("ignite", function(caller, targets, dur)
    for i=1,#targets do
        targets[i]:Ignite(dur)
    end
end)
cmd.Name = "Ignite"
cmd.Desc = "Ignite a player for a specified amount of seconds."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=300})

local cmd = IADM:AddCommand("unignite", function(caller, targets, dur)
    for i=1,#targets do
        targets[i]:Extinguish()
    end
end)
cmd.Name = "Unignite"
cmd.Desc = "Extinguish specified entities."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=300})
