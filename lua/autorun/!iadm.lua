AddCSLuaFile("iadm/init.lua")
include("iadm/init.lua")

AddCSLuaFile("iadm/sh_meta.lua")
include("iadm/sh_meta.lua")
if SERVER then
    include("iadm/sv_hooks.lua")
end

AddCSLuaFile("iadm/cl_net.lua")
if CLIENT then
    include("iadm/cl_net.lua")
end

