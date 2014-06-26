AddCSLuaFile()

/*
code for derprp testing
hook.Add("Initialize","pk_pill_tryloaddickbutt",function()
	TEAM_PET = AddExtraTeam("Pet", {
		color = Color(0, 0, 0, 255),
		model = "models/Lamarr.mdl",
		description = [[You are pet be a good one or you might be put down or given away]],
		weapons = {"weapon_fists"},
		command = "pet",
		max = 2,
		salary = 15,
		admin = 0,
		vote = false,
		hasLicense = false
	})
end)

*/
/*AddCSLuaFile()

DEFINE_BASECLASS( "player_default" )

local PLAYER = {} 

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
--[[PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 400


function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()
	
	self.Player:GiveAmmo( 256,	"Pistol", 		true )
	self.Player:Give( "weapon_pistol" )

end]]

function PLAYER:CalcView( view )
	local ent = pk_pills.getMappedEnt(LocalPlayer())
	if (IsValid(ent) and LocalPlayer():GetViewEntity()==LocalPlayer()) then
		//print("v")
		local startpos
		if ent.formTable.type=="phys" then
			startpos = ent:LocalToWorld(ent.formTable.camera&&ent.formTable.camera.offset||Vector(0,0,0))
		else
			startpos=view.origin
		end

		if pk_pills.var_thirdperson:GetBool() then
			local dist
			if ent.formTable.type=="phys"&&ent.formTable.camera&&ent.formTable.camera.distFromSize then
				dist = ent:BoundingRadius()*5
			else
				dist = ent.formTable.camera&&ent.formTable.camera.dist||100
			end

			local offset = LocalToWorld(Vector(-dist,0,dist/5),Angle(0,0,0),Vector(0,0,0),view.angles)
			local tr = util.TraceHull({
				start=startpos,
				endpos=startpos+offset,
				filter=ent.camTraceFilter,
				mins=Vector(-5,-5,-5),
				maxs=Vector(5,5,5),
				mask=MASK_VISIBLE
			})
			//PrintTable(ent.camTraceFilter)
			//local view = {}
			view.origin = tr.HitPos
			//view.angles = //angles//(ent.GoodEyeTrace&&(pillEnt:GoodEyeTrace().HitPos-tr.HitPos):Angle())||angles
			//view.fov = fov
			view.vm_origin = view.origin+view.angles:Forward()*-500
			return view
		else
			//local view = {}
			view.origin = startpos
			//view.angles = angles
			//view.fov = fov
			return view
		end
	end
	//PrintTable(view)
end

player_manager.RegisterClass("player_pill", PLAYER, "player_default")*/