ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Nid de rats"
ENT.Author = "DarkRP Rats"
ENT.Category = "DarkRP Rats"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "MaxRats")
	self:NetworkVar("Int", 1, "SpawnInterval")
	self:NetworkVar("Int", 2, "WanderRadius")
	self:NetworkVar("Int", 3, "RatCount")
end
