AddCSLuaFile()

ENT.Type   = "anim"

function ENT:Initialize()
	self:AddCallback("BuildBonePositions",self.BoneItUp)

	if SERVER then
		self:AddEffects(bit.bor(EF_BONEMERGE,EF_BONEMERGE_FASTCULL)) --fastcull seems to fix laggy bullshit garbage
	end
end

function ENT:BoneItUp(boneCount)
	local boneId = self:LookupBone("ValveBiped.Bip01_Head1")
	if !boneId then return end
	local matrix = self:GetBoneMatrix(boneId)
	if !matrix then return end
	matrix:Scale(Vector(.01,.01,.01))
	self:SetBoneMatrix(boneId,matrix)
end