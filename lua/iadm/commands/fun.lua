local allplys = player.GetAll

local cmd = IADM:AddCommand("kill", function(caller, targets)
    for _,ply in ipairs(targets) do
        if !ply:Alive() then continue end

        ply:Kill()
        IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Killed ", ply, IADM_ECHOCOLOR_TEXT, "!")
    end
end)
cmd.Name = "Kill"
cmd.Desc = "Kills the player."
cmd.Aliases = {"slay"}
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

            IADM:MessageWPrefix(allplys(), true, ply, IADM_ECHOCOLOR_TEXT, " got blasted in a violent explosion!")
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
            IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Killed ", ply, IADM_ECHOCOLOR_TEXT, " silently!")
        end
    end
end)
cmd.Name = "Silent Kill"
cmd.Desc = "Silently kills the player."
cmd.Aliases = {"sslay"}
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})

local cmd = IADM:AddCommand("strip", function(caller, targets)
    for _,ply in ipairs(targets) do
        if ply:Alive() then
            ply:StripWeapons()
            IADM:MessageWPrefix(allplys(), true, IADM_ECHOCOLOR_TEXT, "Stripped ", ply, IADM_ECHOCOLOR_TEXT, "'s current weapons!")
        end
    end
end)
cmd.Name = "Strip"
cmd.Desc = "Strips weapons away from the target."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLRS})


local cmd = IADM:AddCommand("hp", function(caller, targets, hp, mhp)
    for _,ply in ipairs(targets) do
        local hp = hp
        if !hp then hp = ply:GetMaxHealth() end

        if hp ~= 0 then
            ply:SetHealth(hp)
        end
        if mhp and mhp ~= 0 then
            ply:SetMaxHealth(mhp)
        end
    end
end)
cmd.Name = "HP"
cmd.Desc = "Sets the target a specified amount of health."
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_ENTS})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, optional=true})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, optional=true})

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


IADM.InfAmmoPlayers = IADM.InfAmmoPlayers or {}
local infammos = IADM.InfAmmoPlayers
local cmd = IADM:AddCommand("infammo", function(caller, target, mode)

    local handler = "IADM.InfAmmo."..tostring(target)
    if mode > 0 then
        IADM:MessageWPrefix(caller, true, IADM_ECHOCOLOR_TEXT, "Enabled infammo for ", target, IADM_ECHOCOLOR_TEXT, "!")
        infammos[target] = mode

        hook.Add("Think", handler, function()
            if !target:IsValid() or !infammos[target] then
                infammos[target] = nil
                hook.Remove("Think", handler)
            end

            local wep = target:GetActiveWeapon()
            if wep and wep:IsValid() then
                local maxclip1 = wep:GetMaxClip1()
                local maxclip2 = wep:GetMaxClip2()
                local ammotype1 = wep:GetPrimaryAmmoType()
                local ammotype2 = wep:GetSecondaryAmmoType()

                if mode > 1 then
                    if wep:Clip1() < maxclip1 then
                        wep:SetClip1(maxclip1)
                    end

                    if wep:Clip2() < maxclip2 then
                        wep:SetClip2(maxclip2)
                    end
                end


                if target:GetAmmoCount(ammotype1) < maxclip1 then
                    target:SetAmmo(maxclip1, ammotype1)
                end
                if target:GetAmmoCount(ammotype2) < math.max(1, maxclip2) then
                    target:SetAmmo(math.max(1, maxclip2), ammotype2)
                end
            end
        end)
    else
        infammos[target] = nil
        hook.Remove("Think", handler)
    end
end)
cmd.Name = "Infammo"
cmd.Desc = "Gives the player infinite ammo.\nModes: 0 - disable, 1 - infinite reserve ammo, 2 - infinite reserve + clip ammo"
cmd.PowerLevelReq = IADM_GROUP_POWER_ADMIN
cmd:AddArgument({type=IADM_ARGTYPE_PLR})
cmd:AddArgument({type=IADM_ARGTYPE_NUM, default=1})
