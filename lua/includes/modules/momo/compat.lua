AddCSLuaFile()

  ////////////////////////////////////////////////
 // MOMO COMPATIBILITY PART 1: HOOK OVERRIDES! //
////////////////////////////////////////////////

//Forces our code to run before other hooks, since many coders don't use some hooks (CalcView) correctly.
//Should work with the GM+ hook "fix"
//Fuck GM+

local momo_hooks={}

//Ulib implements a different hook system. It is totally incompatible with our fix, but solves our problem for us!
if file.IsDir("ulib","LUA") then
	hook.Add("Initialize","momo_ulibhookfix",function()
		for k,v in pairs(momo_hooks) do
			hook.Add(k,"momo_compat_"..k,v,19)
		end
	end)
else
	local old_hook_call=hook.Call
	function hook.Call(name,gm,...)
		local a,b,c,d,e,f
		if momo_hooks[name] then
			a,b,c,d,e,f = momo_hooks[name](...)
			if a!=nil then
				return a,b,c,d,e,f
			end
		end
		a,b,c,d,e,f = old_hook_call(name,gm,...)
		return a,b,c,d,e,f
	end
end

function momo_hooks.CalcView(ply,pos,ang,fov,nearZ,farZ)
	local ent = pk_pills.getMappedEnt(LocalPlayer())
	if (IsValid(ent) and ply:GetViewEntity()==ent) then
		local startpos
		if ent.formTable.type=="phys" then
			startpos = ent:LocalToWorld(ent.formTable.camera&&ent.formTable.camera.offset||Vector(0,0,0))
		else
			startpos=pos
		end

		if momo.convars.cl_thirdperson:GetBool() then
			local dist
			if ent.formTable.type=="phys"&&ent.formTable.camera&&ent.formTable.camera.distFromSize then
				dist = ent:BoundingRadius()*5
			else
				dist = ent.formTable.camera&&ent.formTable.camera.dist||100
			end

			local underslung = ent.formTable.camera&&ent.formTable.camera.underslung

			local offset = LocalToWorld(Vector(-dist,0,underslung and -dist/5 or dist/5),Angle(0,0,0),Vector(0,0,0),ang)
			local tr = util.TraceHull({
				start=startpos,
				endpos=startpos+offset,
				filter=ent.camTraceFilter,
				mins=Vector(-5,-5,-5),
				maxs=Vector(5,5,5),
				mask=MASK_VISIBLE
			})
			//PrintTable(ent.camTraceFilter)
			local view = {}
			view.origin = tr.HitPos
			view.angles = ang//(ent.GoodEyeTrace&&(pillEnt:GoodEyeTrace().HitPos-tr.HitPos):Angle())||angles
			view.fov = fov
			return view
		else
			local view = {}
			view.origin = startpos
			view.angles = ang
			view.fov = fov
			return view
		end
	end
end

function momo_hooks.CalcViewModelView(wep,vm,oldPos,oldAng,pos,ang)
	local ent = pk_pills.getMappedEnt(LocalPlayer())
	local ply = wep.Owner
	if (IsValid(ent) and ply:GetViewEntity()==ent and momo.convars.cl_thirdperson:GetBool()) then
		return oldPos+oldAng:Forward()*-500,ang
	end
end

  /////////////////////////////////////////////////
 // MOMO COMPATIBILITY PART 2: METATABLE HACKS! //
/////////////////////////////////////////////////

//Disable a ton of functions when morphed

local blocked_functions = {
	"SetHull","SetHullDuck",
	"SetWalkSpeed","SetRunSpeed","SetCrouchedWalkSpeed",
	"SetJumpPower","SetStepSize",
	"SetViewOffset","SetViewOffsetDucked"
}

local meta_player = FindMetaTable("Player")

for _,f in pairs(blocked_functions) do
	local old_func = meta_player[f]
	meta_player[f]= function(self,...)
		local ent = pk_pills.getMappedEnt(self)
		if !IsValid(ent) then
			old_func(self,...)
		end
	end
end

//Make GetViewEntity return the pill entity

local old_getviewentity = meta_player.GetViewEntity
local old_setviewentity = meta_player.SetViewEntity

function meta_player:GetViewEntity()
	local ent = old_getviewentity(self)
	local formEnt = pk_pills.getMappedEnt(self)

	if ent==self and IsValid(formEnt) then
		return formEnt
	end
	return ent
end

function meta_player:SetViewEntity(ent)
	if IsValid(ent) and (ent:GetClass()=="pill_ent_phys" or ent:GetClass()=="pill_ent_costume") then ent=self end
	old_setviewentity(self,ent)
end

if CLIENT then
	local old_g_getviewentity = _G.GetViewEntity

	_G.GetViewEntity = function()
		local ent = old_g_getviewentity()
		local formEnt = pk_pills.getMappedEnt(LocalPlayer())

		if ent==LocalPlayer() and IsValid(formEnt) then
			return formEnt
		end
		return ent
	end
end