AddCSLuaFile()

pk_pills.register("me_parakeet",{
	parent="bird_pigeon",
	me="STEAM_0:1:18839805",
	visColorRandom=true,
	reload = function(ply,ent)
		local egg = ents.Create("prop_physics")
		egg:SetModel("models/props_phx/misc/egg.mdl")
		local ang = ply:EyeAngles()
		ang.p=0
		egg:SetPos(ply:EyePos()+ang:Forward()*30)
		egg:Spawn()
		local phys = egg:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ply:GetVelocity()+ply:EyeAngles():Forward()*800+(ply:IsOnGround()&&Vector(0,0,600)||Vector()))
		end
		egg:Fire("FadeAndRemove",nil,10)
	end,
	sounds={
		vocalize=pk_pills.helpers.makeList("ambient/levels/canals/swamp_bird#.wav",6)
	}
})