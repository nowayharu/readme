AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:Initialize()
	self:SetModel(DRATS.Config.NestModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	-- Ne bloque pas les joueurs, mais reste visable au toolgun
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	if self:GetMaxRats() <= 0 then self:SetMaxRats(DRATS.Config.DefaultMaxRats) end
	if self:GetSpawnInterval() <= 0 then self:SetSpawnInterval(DRATS.Config.DefaultInterval) end
	if self:GetWanderRadius() <= 0 then self:SetWanderRadius(DRATS.Config.DefaultRadius) end

	self.Rats = {}
	self.NextSpawn = CurTime() + math.Rand(5, 15)
end

function ENT:CleanRatList()
	for i = #self.Rats, 1, -1 do
		if not IsValid(self.Rats[i]) then
			table.remove(self.Rats, i)
		end
	end
	self:SetRatCount(#self.Rats)
end

function ENT:CanSpawnRat()
	if #self.Rats >= self:GetMaxRats() then return false end
	if DRATS.CountRats() >= DRATS.Config.GlobalMaxRats then return false end
	if DRATS.Config.RequireExterminatorOnline and #DRATS.GetExterminators() == 0 then return false end
	if DRATS.Config.RequireOwnedProperty and #DRATS.GetOwnedDoorsNear(self:GetPos(), DRATS.Config.PropertyDoorRadius) == 0 then return false end
	return hook.Run("DRATS_CanSpawnRat", self) ~= false
end

function ENT:SpawnRat()
	local base = self:GetPos()
	local ang = math.Rand(0, math.pi * 2)
	local offset = Vector(math.cos(ang), math.sin(ang), 0) * math.Rand(10, 40)

	local tr = util.TraceLine({
		start = base + offset + Vector(0, 0, 30),
		endpos = base + offset - Vector(0, 0, 100),
		filter = function(ent) return ent ~= self and ent:GetClass() ~= DRATS.RatClass end,
		mask = MASK_NPCSOLID,
	})
	if not tr.Hit or tr.StartSolid then return end

	local rat = ents.Create(DRATS.RatClass)
	if not IsValid(rat) then return end
	rat:SetPos(tr.HitPos)
	rat:SetAngles(Angle(0, math.random(0, 360), 0))
	rat:SetNest(self)
	rat.SpawnPos = tr.HitPos
	rat:Spawn()

	self.Rats[#self.Rats + 1] = rat
	self:SetRatCount(#self.Rats)

	DRATS.NotifyInfestation(self)
	return rat
end

function ENT:Think()
	self:CleanRatList()

	if CurTime() >= self.NextSpawn then
		self.NextSpawn = CurTime() + self:GetSpawnInterval()
		if self:CanSpawnRat() then
			self:SpawnRat()
		end
	end

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnTakeDamage()
	-- Le nid est indestructible
end

function ENT:OnRemove()
	self.DRATS_Removing = true

	for _, rat in ipairs(self.Rats or {}) do
		if IsValid(rat) then rat:Remove() end
	end

	if not DRATS.Loading and not DRATS.ShuttingDown then
		timer.Simple(0, function() DRATS.SaveNests() end)
	end
end
