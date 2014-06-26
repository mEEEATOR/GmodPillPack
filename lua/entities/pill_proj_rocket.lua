AddCSLuaFile()

ENT.Type   = "anim"
ENT.PrintName = "Rocket"

function ENT:Initialize()
	if SERVER then
		if !self.noPhys then
			self:PhysicsInit(SOLID_VPHYSICS )
			self:SetMoveType(MOVETYPE_VPHYSICS)
			self:SetSolid(SOLID_VPHYSICS)
		end

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:Wake()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:SetDamping(0,0)
			phys:SetVelocity(self:GetAngles():Forward()*3000)
		end

		if self.sound then
			self.flySound = CreateSound(self,self.sound)
			self.flySound:Play()
		end

		if self.trail then
			util.SpriteTrail(self,0,self.tcolor or Color(255,255,255),false,40,10,5, 1/100,self.trail)
		end

		if self.particle then
			ParticleEffectAttach(self.particle,PATTACH_ABSORIGIN_FOLLOW,self,0)
		end
	end
end

if SERVER then
	function ENT:Think()
		local tr
		if self.noPhys then
			tr = util.QuickTrace(self:GetPos(),self:GetAngles():Forward()*20,{self,self.shooter})
		end

		if self:WaterLevel()>0 or tr and tr.Hit then
			if self.altExplode then
				ParticleEffect(self.altExplode.particle,self:GetPos(), Angle(0,0,0))
				self:EmitSound(self.altExplode.sound)
				util.BlastDamage(self,self:GetOwner(),self:GetPos(),100,100)
			else
				local explode = ents.Create("env_explosion")
				explode:SetPos(self:GetPos())
				//explode:SetOwner(ply)
				explode:Spawn()
				explode:SetKeyValue("iMagnitude","100")
				explode:Fire("Explode",0,0)
				explode:SetOwner(self:GetOwner())
			end

			self:Remove()
		end

		if tr then
			self:SetPos(self:GetPos()+self:GetAngles():Forward()*20)
		end

		self:NextThink(CurTime())
		return true
	end
end

function ENT:OnRemove()
	if SERVER and self.flySound then self.flySound:Stop() end
end

function ENT:PhysicsCollide( data, physobj )
	if self.altExplode then
		ParticleEffect(self.altExplode.particle,self:GetPos(), Angle(0,0,0))
		self:EmitSound(self.altExplode.sound)
		util.BlastDamage(self,self:GetOwner(),self:GetPos(),100,100)
	else
		local explode = ents.Create("env_explosion")
		explode:SetPos(self:GetPos())
		//explode:SetOwner(ply)
		explode:Spawn()
		explode:SetKeyValue("iMagnitude","100")
		explode:Fire("Explode",0,0)
		explode:SetOwner(self:GetOwner())
	end

	self:Remove()
end