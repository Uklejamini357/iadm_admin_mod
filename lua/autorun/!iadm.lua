if not (PRE_HOOK and PRE_HOOK_RETURN and HOOK_MONITOR_LOW and HOOK_LOW and HOOK_NORMAL and HOOK_HIGH and HOOK_MONITOR_HIGH and POST_HOOK_RETURN and POST_HOOK) then
    ErrorNoHaltWithStack("Srlion's hook library is not installed, IADM will not start!")
    return
end


AddCSLuaFile("iadm/globals.lua")
include("iadm/globals.lua")

AddCSLuaFile("iadm/init.lua")
include("iadm/init.lua")

AddCSLuaFile("iadm/translate.lua")
include("iadm/translate.lua")

local files = file.Find("iadm/languages/*.lua", "LUA", "sortasc")
for _,name in ipairs(files) do
    AddCSLuaFile("iadm/languages/"..name)
    include("iadm/languages/"..name)
end

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


files = file.Find("iadm/modules/*.lua", "LUA", "sortasc")
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
