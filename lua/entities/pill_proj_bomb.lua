AddCSLuaFile()

ENT.Type   = "anim"
ENT.PrintName = "Bomb"

function ENT:Initialize()
	if SERVER then
		if self.sphere then
			self:PhysicsInitSphere(self.sphere)
		else
			self:PhysicsInit(SOLID_VPHYSICS )
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableDrag(false)
			phys:SetDamping(0,0)
			phys:SetVelocity(self:GetAngles():Forward()*(self.speed or 1000))
		end
		
		timer.Simple(3||self.fuse,function()
			if IsValid(self) then
				self:Remove()
			end
		end)
	end
end

function ENT:OnRemove()
	if SERVER then
		if self.tf2 then
			ParticleEffect("ExplosionCore_MidAir",self:GetPos(), Angle(0,0,0))
			self:EmitSound("weapons/explode1.wav")
			util.BlastDamage(self,self:GetOwner(),self:GetPos(),100,100)
		else
			local explode = ents.Create("env_explosion")
			explode:SetPos(self:GetPos())
			explode:Spawn()
			explode:SetKeyValue("iMagnitude","100")
			explode:Fire("Explode",0,0)
			explode:SetOwner(self:GetOwner())
		end
	end
end

function ENT:StartTouch(ent)
	if (ent:IsNPC() or ent:IsPlayer() or ent:GetClass()=="pill_ent_phys") then self:Remove() end
end