--[[
	DarkRP - Rats & Dératiseur
	Chargeur principal de l'addon.
]]

DRATS = DRATS or {}

AddCSLuaFile("darkrp_rats/sh_config.lua")
AddCSLuaFile("darkrp_rats/sh_core.lua")
AddCSLuaFile("darkrp_rats/cl_core.lua")

include("darkrp_rats/sh_config.lua")
include("darkrp_rats/sh_core.lua")

if SERVER then
	include("darkrp_rats/sv_core.lua")
else
	include("darkrp_rats/cl_core.lua")
end
