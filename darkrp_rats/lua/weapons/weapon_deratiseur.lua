--[[
	Pulvérisateur de raticide - arme du dératiseur.
	Clic gauche : pulvériser du poison (tue les rats à courte portée)
	Clic droit  : détecteur, indique le nombre de rats proches
]]

AddCSLuaFile()

SWEP.PrintName = "Pulvérisateur de raticide"
SWEP.Author = "DarkRP Rats"
SWEP.Instructions = "Clic gauche : pulvériser\nClic droit : détecter les rats"
SWEP.Category = "DarkRP Rats"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Slot = 1
SWEP.SlotPos = 5
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/weapons/w_bugbait.mdl"
SWEP.UseHands = true
SWEP.ViewModelFOV = 60
SWEP.HoldType = "pistol"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"


function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + DRATS.Config.SprayDelay)

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	owner:SetAnimation(PLAYER_ATTACK1)

	if IsFirstTimePredicted() then
		if (self.NextSpraySound or 0) < CurTime() then
			self.NextSpraySound = CurTime() + 0.5
			self:EmitSound("player/sprayer.wav", 60, math.random(90, 110), 0.5)
		end
		if CLIENT then self:SprayEffect() end
	end

	if CLIENT then return end

	local shootPos = owner:GetShootPos()
	local aim = owner:GetAimVector()
	local range = DRATS.Config.SprayRange

	for _, rat in ipairs(ents.FindInSphere(shootPos + aim * range * 0.5, range * 0.6)) do
		if IsValid(rat) and rat:GetClass() == DRATS.RatClass then
			local target = rat:WorldSpaceCenter()
			local toRat = target - shootPos
			local dist = toRat:Length()
			toRat:Normalize()

			if dist <= range and aim:Dot(toRat) >= DRATS.Config.SprayConeDot then
				local tr = util.TraceLine({
					start = shootPos,
					endpos = target,
					filter = { owner, self },
					mask = MASK_SHOT,
				})

				if not tr.Hit or tr.Entity == rat then
					local dmg = DamageInfo()
					dmg:SetDamage(DRATS.Config.SprayDamage)
					dmg:SetDamageType(DMG_NERVEGAS)
					dmg:SetAttacker(owner)
					dmg:SetInflictor(self)
					dmg:SetDamagePosition(target)
					rat:TakeDamageInfo(dmg)
				end
			end
		end
	end
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 2)
	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local count, nearest, nearestDist = 0, nil, math.huge
	for _, rat in ipairs(ents.FindInSphere(owner:GetPos(), 1500)) do
		if rat:GetClass() == DRATS.RatClass then
			count = count + 1
			local d = owner:GetPos():DistToSqr(rat:GetPos())
			if d < nearestDist then nearest, nearestDist = rat, d end
		end
	end

	if count == 0 then
		DarkRP.notify(owner, 0, 3, "Aucun rat détecté dans les environs.")
		return
	end

	owner:EmitSound("buttons/blip1.wav", 50, 120)
	DarkRP.notify(owner, 0, 4, string.format("%d rat(s) détecté(s). Le plus proche est à %d mètres.",
		count, math.Round(math.sqrt(nearestDist) * 0.019)))
end

if CLIENT then
	function SWEP:SprayEffect()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local aim = owner:GetAimVector()
		local start = owner:GetShootPos() + aim * 16 + owner:GetRight() * 6 - owner:GetUp() * 6

		local emitter = ParticleEmitter(start)
		if not emitter then return end

		for _ = 1, 4 do
			local p = emitter:Add("particle/particle_smokegrenade", start)
			if p then
				p:SetVelocity((aim + VectorRand() * 0.12) * math.Rand(250, 400))
				p:SetDieTime(math.Rand(0.5, 0.8))
				p:SetStartAlpha(90)
				p:SetEndAlpha(0)
				p:SetStartSize(2)
				p:SetEndSize(math.Rand(14, 22))
				p:SetRoll(math.Rand(0, 360))
				p:SetRollDelta(math.Rand(-2, 2))
				p:SetColor(140, 200, 60)
				p:SetAirResistance(150)
				p:SetGravity(Vector(0, 0, -20))
				p:SetCollide(true)
			end
		end

		emitter:Finish()
	end
end
