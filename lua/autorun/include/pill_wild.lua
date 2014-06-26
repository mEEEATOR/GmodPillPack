AddCSLuaFile()

pk_pills.register("ichthyosaur",{
	printName="Ichthyosaur",
	side="wild",
	type="phys",
	model="models/Ichthyosaur.mdl",
	default_rp_cost=600,
	camera={
		dist=350
	},
	seqInit="swim",
	sphericalPhysics=30,
	driveType="swim",
	driveOptions={
		speed=10
	},
	aim={
		xPose="sidetoside",
		yPose="upanddown"
	},
	attack={
		mode="trigger",
		func=function(ply,ent)
			if ent:GetSequence()!=ent:LookupSequence("swim") then return end
			ent:PillAnim("attackstart",true)
			timer.Simple(.5,function()
				if !IsValid(ent) then return end

				local tr = util.TraceHull({
					start=ent:GetPos(),
					endpos=ent:GetPos()+ent:GetAngles():Forward()*200,
					filter={ent},
					mins=Vector(-5,-5,-5),
					maxs=Vector(5,5,5)
				})
				if IsValid(tr.Entity) then
					local dmg=DamageInfo()
					dmg:SetAttacker(ply)
					dmg:SetInflictor(ent)
					dmg:SetDamageType(DMG_SLASH)
					dmg:SetDamage(50)

					tr.Entity:TakeDamageInfo(dmg)
					
					ent:PillAnim("attackend",true)
					ent:PillSound("bite")
					timer.Simple(1.8,function()
						if !IsValid(ent) then return end
						ent:PillAnim("swim",true)
					end)
				else
					ent:PillAnim("attackmiss",true)
					timer.Simple(.5,function()
						if !IsValid(ent) then return end
						ent:PillAnim("swim",true)
					end)
				end
			end)
		end
	},
	attack2={
		mode="trigger",
		func=function(ply,ent)
			ent:PillSound("vocalize")
		end
	},
	health=400,
	sounds={
		loop_move="npc/ichthyosaur/water_breath.wav",
		vocalize=pk_pills.helpers.makeList("npc/ichthyosaur/attack_growl#.wav",3),
		bite="npc/ichthyosaur/snap.wav"
	}
})