require("pk_pills")
AddCSLuaFile()

if SERVER then
	resource.AddWorkshop("106427033")
	include("include/drivemodes.lua")
else
	game.AddParticles("particles/Vortigaunt_FX.pcf")
	PrecacheParticleSystem("vortigaunt_beam")
	PrecacheParticleSystem("vortigaunt_beam_b")
end

include("include/vox_lists.lua")

pk_pills.packStart("Half-Life 2","base","games/16/hl2.png")

include("include/pill_combine_soldiers.lua")
include("include/pill_combine_phys_small.lua")
include("include/pill_combine_phys_large.lua")
include("include/pill_combine_misc.lua")
include("include/pill_combine_new.lua")

include("include/pill_headcrabs.lua")
include("include/pill_zombies.lua")

include("include/pill_antlions.lua")
include("include/pill_wild.lua")

include("include/pill_resistance_heros.lua")
include("include/pill_resistance.lua")
include("include/pill_vorts.lua")

include("include/pill_birds.lua")

pk_pills.packStart("Fun Pills","fun","icon16/rainbow.png")

include("include/pill_fun.lua")
include("include/pill_fun2.lua")
include("include/pill_fun3.lua")
include("include/pill_360_noscope.lua")