AddCSLuaFile("iadm/globals.lua")
include("iadm/globals.lua")

AddCSLuaFile("iadm/init.lua")
include("iadm/init.lua")


AddCSLuaFile("iadm/sh_meta.lua")
include("iadm/sh_meta.lua")
if SERVER then
    include("iadm/sv_init.lua")
    include("iadm/sv_hooks.lua")
    include("iadm/sv_net.lua")
end

AddCSLuaFile("iadm/cl_init.lua")
AddCSLuaFile("iadm/cl_net.lua")
if CLIENT then
    include("iadm/cl_init.lua")
    include("iadm/cl_net.lua")
end

local files = file.Find("iadm/modules/*.lua", "LUA", "sortasc")
for _,name in ipairs(files) do
    if string.StartsWith(name, "sv_") then continue end
    IADM_MODULE_SHOULDINCLUDE = true
    AddCSLuaFile("iadm/modules/"..name)
    local MODULE = include("iadm/modules/"..name)
    if MODULE then
        MODULE.ID = string.sub(name, 1, -5)
        MODULE.Included = tobool(IADM_MODULE_SHOULDINCLUDE)
    end
    if SERVER and file.Exists("iadm/modules/sv_"..name, "LUA") then
        include("iadm/modules/sv_"..name)
    end
    IADM_MODULE_SHOULDINCLUDE = nil
end

files = file.Find("iadm/commands/*.lua", "LUA", "sortasc")
for _,file in ipairs(files) do
    AddCSLuaFile("iadm/commands/"..file)
    include("iadm/commands/"..file)
end
