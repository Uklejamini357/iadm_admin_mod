local allplys = player.GetAll

local cmd = IADM:AddCommand("kill", function(caller, targets)
    for i=1,#targets do
        local ply = targets[i]
        if !ply:Alive() then continue end

        ply:Kill()
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Killed ", Color(255,0,0), ply:Nick(), IADM_ECHOCOLOR_TEXT, "!")
    end
end)
cmd.Name = "Kill"
cmd.Desc = "Kills the player."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})

local cmd = IADM:AddCommand("explode", function(caller, targets, level)
    for i=1,#targets do
        local ply = targets[i]

        if ply:Alive() then
            local e = EffectData()
            local pos = ply:GetPos()

            ply:SetHealth(-9999)
            ply:Kill()
            local rag = ply:GetRagdollEntity()
            if rag and rag:IsValid() then
                rag:Remove()
            end

            if level > 10 then level = 10 end


            e:SetOrigin(pos)
            for i=1,level > 2 and 25 or level > 1 and 5 or 1 do util.Effect("Explosion", e) end
            for i=1,level > 4 and 5 or level > 3 and 1 or 0 do
                local explo = ents.Create("env_explosion")
                explo:SetPos(pos)
                explo:SetKeyValue("iMagnitude", math.min(2147483647, 500*(2^level-2)))
                explo:SetKeyValue("iRadiusOverride", math.min(10000, 500+100*(1.5^(level-2))))
                explo:Spawn()
                explo:Activate()
                explo:Input("explode")
            end

            IADM:MessageWPrefix(allplys(), true, Color(255,0,0), ply:Nick(), IADM_ECHOCOLOR_TEXT, " got blasted in a violent explosion!")
        end
    end
end)
cmd.Name = "Explode"
cmd.Desc = "Explodes the player violently."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, hint="[explosion level]", default=1})

local cmd = IADM:AddCommand("skill", function(caller, target)
    if target:Alive() then
        target:KillSilent()
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Killed ", Color(255,0,0), target:Nick(), IADM_ECHOCOLOR_TEXT, " silently!")
    end
end)
cmd.Name = "Silent Kill"
cmd.Desc = "Silently kills the player."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})

local cmd = IADM:AddCommand("strip", function(caller, target)
    if target:Alive() then
        target:StripWeapons()
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Stripped ", IADM_ECHOCOLOR_ARG1, target:Nick(), IADM_ECHOCOLOR_TEXT, "'s current weapons!")
    end
end)
cmd.Name = "Strip"
cmd.Desc = "Strips weapons away from the target."
cmd.PermsRequire = "admin"
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})


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
