include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	-- Animation fluide côté client
	self:FrameAdvance()
	self:SetNextClientThink(CurTime())
	return true
end
