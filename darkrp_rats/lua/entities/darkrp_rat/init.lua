AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


local HULL_MINS = Vector(-5, -5, 0)
local HULL_MAXS = Vector(5, 5, 6)
local STEP_HEIGHT = 14
local MAX_DROP = 40

local squeaks = {
	"ambient/creatures/rats1.wav",
	"ambient/creatures/rats2.wav",
	"ambient/creatures/rats3.wav",
	"ambient/creatures/rats4.wav",
}

local function traceFilter(ent)
	local class = ent:GetClass()
	return class ~= DRATS.RatClass and class ~= DRATS.NestClass and not ent:IsPlayer()
end

function ENT:Initialize()
	self:SetModel(DRATS.Config.RatModel)
	self:SetModelScale(DRATS.Config.RatScale, 0)

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionBounds(Vector(-7, -7, 0), Vector(7, 7, 8))
	-- Les balles et le pulvérisateur les touchent, mais les joueurs passent au travers
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	self:SetMaxHealth(DRATS.Config.RatHealth)
	self:SetHealth(DRATS.Config.RatHealth)

	self.Speed = math.Rand(DRATS.Config.RatSpeedMin, DRATS.Config.RatSpeedMax)
	self.LastThink = CurTime()
	self.NextSqueak = CurTime() + math.Rand(3, 15)
	self.FleeUntil = 0
	self.WaitUntil = 0

	if DRATS.Config.RatLifetime > 0 then
		self.DieAt = CurTime() + DRATS.Config.RatLifetime
	end

	self:PlayAnim(DRATS.Config.RatIdleSequence)
	self:PickNewGoal()
end

function ENT:SetNest(nest)
	self.Nest = nest
end

function ENT:PlayAnim(name)
	if self.CurrentAnim == name then return end
	local seq = self:LookupSequence(name)
	if seq and seq >= 0 then
		self:ResetSequence(seq)
		self.CurrentAnim = name
	end
end

function ENT:GetWanderCenter()
	if IsValid(self.Nest) then return self.Nest:GetPos(), self.Nest:GetWanderRadius() end
	return self.SpawnPos or self:GetPos(), DRATS.Config.DefaultRadius
end

function ENT:PickNewGoal(awayFrom)
	local center, radius = self:GetWanderCenter()

	if awayFrom then
		-- Fuir dans la direction opposée
		local dir = self:GetPos() - awayFrom
		dir.z = 0
		dir:Normalize()
		dir:Rotate(Angle(0, math.Rand(-40, 40), 0))
		self.Goal = self:GetPos() + dir * math.Rand(150, 300)
		return
	end

	local ang = math.Rand(0, math.pi * 2)
	local dist = math.Rand(0, radius)
	self.Goal = center + Vector(math.cos(ang) * dist, math.sin(ang) * dist, 0)
end

function ENT:Think()
	local now = CurTime()
	local dt = math.min(now - self.LastThink, 0.2)
	self.LastThink = now

	if self.DieAt and now > self.DieAt then
		self:Remove()
		return
	end

	if now > self.NextSqueak then
		self.NextSqueak = now + math.Rand(8, 25)
		self:EmitSound(squeaks[math.random(#squeaks)], 60, math.random(110, 130), 0.6)
	end

	-- Pause
	if now < self.WaitUntil then
		self:PlayAnim(DRATS.Config.RatIdleSequence)
		self:NextThink(now + 0.1)
		return true
	end

	local fleeing = now < self.FleeUntil
	local speed = fleeing and DRATS.Config.RatFleeSpeed or self.Speed

	local pos = self:GetPos()
	local dir = self.Goal - pos
	dir.z = 0

	if dir:Length() < 10 then
		if not fleeing then
			self.WaitUntil = now + math.Rand(0.5, 4)
		end
		self:PickNewGoal()
		self:NextThink(now)
		return true
	end

	dir:Normalize()
	local newPos = pos + dir * speed * dt

	-- Obstacle devant ?
	local up = Vector(0, 0, STEP_HEIGHT)
	local wall = util.TraceHull({
		start = pos + up,
		endpos = newPos + up,
		mins = HULL_MINS,
		maxs = HULL_MAXS,
		filter = traceFilter,
		mask = MASK_NPCSOLID,
	})

	-- Sol sous la nouvelle position ?
	local ground = util.TraceLine({
		start = newPos + up,
		endpos = newPos - Vector(0, 0, MAX_DROP),
		filter = traceFilter,
		mask = MASK_NPCSOLID,
	})

	if wall.Hit or wall.StartSolid or not ground.Hit or ground.StartSolid then
		self:PickNewGoal()
		self:NextThink(now)
		return true
	end

	self:SetPos(ground.HitPos)
	self:SetAngles(Angle(0, dir:Angle().y, 0))
	self:PlayAnim(DRATS.Config.RatRunSequence)
	self:SetPlaybackRate(fleeing and 1.6 or 1)

	self:NextThink(now)
	return true
end

function ENT:OnTakeDamage(dmg)
	if self.Dead then return end

	local attacker = dmg:GetAttacker()
	if not DRATS.CanDamageRat(attacker) then
		DRATS.WarnNotExterminator(attacker)
		-- Le rat s'enfuit quand même
		self.FleeUntil = CurTime() + 2
		self.WaitUntil = 0
		self:PickNewGoal(dmg:GetDamagePosition())
		return
	end

	self:SetHealth(self:Health() - dmg:GetDamage())

	if self:Health() <= 0 then
		self:Die(attacker)
		return
	end

	self.FleeUntil = CurTime() + 3
	self.WaitUntil = 0
	self:PickNewGoal(IsValid(attacker) and attacker:GetPos() or dmg:GetDamagePosition())
	self:EmitSound(squeaks[math.random(#squeaks)], 70, math.random(140, 160))
end

function ENT:Die(attacker)
	self.Dead = true

	local effect = EffectData()
	effect:SetOrigin(self:GetPos() + Vector(0, 0, 4))
	util.Effect("BloodImpact", effect, true, true)
	self:EmitSound("npc/headcrab/die" .. math.random(1, 2) .. ".wav", 65, math.random(130, 150))

	DRATS.RewardKill(attacker)
	self:Remove()
end
