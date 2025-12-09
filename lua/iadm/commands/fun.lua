local allplys = player.GetAll

local cmd = IADM:AddCommand("kill", function(caller, targets)
    for _,ply in ipairs(targets) do
        if !ply:Alive() then continue end

        ply:Kill()
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Killed ", Color(255,0,0), ply:Nick(), IADM_ECHOCOLOR_TEXT, "!")
    end
end)
cmd.Name = "Kill"
cmd.Desc = "Kills the player."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})

local cmd = IADM:AddCommand("explode", function(caller, targets, level)
    for _,ply in ipairs(targets) do
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
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, hint="[explosion level]", default=1})

local cmd = IADM:AddCommand("skill", function(caller, targets)
    for _,ply in ipairs(targets) do
        if ply:Alive() then
            ply:KillSilent()
            IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Killed ", Color(255,0,0), ply:Nick(), IADM_ECHOCOLOR_TEXT, " silently!")
        end
    end
end)
cmd.Name = "Silent Kill"
cmd.Desc = "Silently kills the player."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})

local cmd = IADM:AddCommand("strip", function(caller, targets)
    for _,ply in ipairs(targets) do
        if ply:Alive() then
            ply:StripWeapons()
            IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Stripped ", IADM_ECHOCOLOR_ARG1, ply:Nick(), IADM_ECHOCOLOR_TEXT, "'s current weapons!")
        end
    end
end)
cmd.Name = "Strip"
cmd.Desc = "Strips weapons away from the target."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})


local cmd = IADM:AddCommand("hp", function(caller, targets, hp)
    for _,ply in ipairs(targets) do
        ply:SetHealth(hp)
    end
end)
cmd.Name = "HP"
cmd.Desc = "Sets the target a specified amount of health."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=300})

local cmd = IADM:AddCommand("ignite", function(caller, targets, dur)
    for _,ply in ipairs(targets) do
        ply:Ignite(dur)
    end
end)
cmd.Name = "Ignite"
cmd.Desc = "Ignite a player for a specified amount of seconds."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=300})

local cmd = IADM:AddCommand("unignite", function(caller, targets, dur)
    for _,ply in ipairs(targets) do
        ply:Extinguish()
    end
end)
cmd.Name = "Unignite"
cmd.Desc = "Extinguish specified entities."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=300})
