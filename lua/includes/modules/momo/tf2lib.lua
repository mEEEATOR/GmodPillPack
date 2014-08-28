AddCSLuaFile()

//Speed modifications done by tf2 weapons, effects, etc.
hook.Add("SetupMove","momo_tf2_movemod", function(ply,mv,cmd)
	local speedmod = 1
	
	//Check weapons
	for _,wep in pairs(ply:GetWeapons()) do
		if wep.momo_speedMod then
			local thismod = wep:momo_speedMod()
			if thismod then speedmod=speedmod*thismod end
		end
	end

	//Change the speed
	if speedmod!=1 then
		local basevel = mv:GetVelocity()
		basevel.x = basevel.x*speedmod
		basevel.y = basevel.y*speedmod
		mv:SetVelocity(basevel)
	end
end)