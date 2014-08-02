AddCSLuaFile()

pk_pills.register("parakeet",{
	parent="bird_pigeon",
	printName="Parakeet",
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

local dragon_attacks = {
	function(ply,pos)
		local thing = ents.Create("pill_proj_prop")
		thing:SetModel(table.Random{
			"models/props_lab/monitor02.mdl",
			"models/props_junk/CinderBlock01a.mdl",
			"models/props_junk/sawblade001a.mdl",
			"models/props_junk/harpoon002a.mdl",
			"models/props_junk/watermelon01.mdl",
			"models/props_c17/FurnitureWashingmachine001a.mdl",
			"models/props_c17/FurnitureFridge001a.mdl",
			"models/props_c17/FurnitureBathtub001a.mdl",
			"models/props_wasteland/prison_toilet01.mdl",
			"models/props_vehicles/carparts_tire01a.mdl"
		})
		thing:SetPos(pos)
		thing:SetAngles(ply:EyeAngles())
		thing:Spawn()
		thing:SetPhysicsAttacker(ply)
	end,
	function(ply,pos)
		local thing = ents.Create("prop_physics")
		thing:SetModel(table.Random{
			"models/props_c17/oildrum001_explosive.mdl",
			"models/props_junk/propane_tank001a.mdl",
			"models/props_junk/gascan001a.mdl"
		})
		thing:SetPos(pos)
		thing:SetAngles(ply:EyeAngles())
		thing:Spawn()
		thing:SetPhysicsAttacker(ply)
		thing:Ignite(100)
		local phys = thing:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:SetDamping(0,0)
			phys:SetVelocity(ply:EyeAngles():Forward()*3000)
		end
	end,
	function(ply,pos)
		local thing = ents.Create("pill_proj_energy_grenade")
		thing:SetPos(pos)
		thing:SetAngles(ply:EyeAngles()+Angle(-50+math.Rand(-10,10),math.Rand(-10,10),math.Rand(-10,10)))
		thing:Spawn()
		thing:SetOwner(ply)
	end,
	function(ply,pos)
		local rocket = ents.Create("rpg_missile")
		rocket:SetPos(pos)
		rocket:SetAngles(ply:EyeAngles())
		rocket:SetSaveValue( "m_flDamage", 200 )
		rocket:SetOwner(ply)
		rocket:SetVelocity(ply:EyeAngles():Forward()*1500)
		rocket:Spawn()
	end,
	function(ply,pos)
		local bomb = ents.Create("grenade_helicopter")
		bomb:SetPos(pos)
		bomb:SetAngles(Angle(math.Rand(-180,180),math.Rand(-180,180),math.Rand(-180,180)))
		bomb:Spawn()
		
		bomb:SetPhysicsAttacker(ply)
		
		bomb:GetPhysicsObject():AddVelocity(ply:EyeAngles():Forward()*3000)
	end,
	function(ply,pos)
		local nade = ents.Create("npc_grenade_frag")
		nade:SetPos(pos)
		nade:SetAngles(ply:EyeAngles())
		nade:Spawn()
		nade:SetOwner(ply)
		nade:Fire("SetTimer",3,0)

		nade:GetPhysicsObject():SetVelocity((ply:EyeAngles():Forward()+Vector(0,0,.2))*3000)
	end,
	function(ply,pos)
		local ball = ents.Create( "prop_combine_ball" )

		ball:SetPos(pos)
		ball:SetAngles(ply:EyeAngles())
		ball:Spawn()
		ball:SetOwner(ply)

		ball:SetSaveValue('m_flRadius',12)
		ball:SetSaveValue("m_nState",3)

		ball:GetPhysicsObject():SetVelocity(ply:EyeAngles():Forward()*3000)
	end
}

pk_pills.register("dagent",{
	printName="Dragon Agent",
	side="harmless",
	type="ply",
	default_rp_cost=800,
	visColorRandom=true,
	model="models/player/combine_super_soldier.mdl",
	aim={
		xPose="aim_yaw",
		yPose="aim_pitch"
	},
	anims={
		default={
			idle="idle_magic",
			walk="walk_magic",
			run="run_magic",
			crouch="cidle_magic",
			crouch_walk="cwalk_magic",
			glide="jump_magic",
			jump="jump_magic",
			swim="swimming_magic"
		}
	},
	attack={
		mode="auto",
		delay=.2,
		func=function(ply,ent)
			ent:PillSound("attack",true)
			table.Random(dragon_attacks)(ply,ply:GetShootPos()+ply:EyeAngles():Forward()*100)
		end
	},
	moveSpeed={
		walk=60,
		run=600,
		ducked=60
	},
	sounds={
		attack="weapons/gauss/fire1.wav"
	},
	jumpPower=800,
	movePoseMode="xy",
	health=10000
})