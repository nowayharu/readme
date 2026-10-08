--[[
	Logique serveur : sauvegarde des nids, récompenses, notifications.
]]

local cfg = DRATS.Config

------------------------------------------------------------------------
-- Comptage des rats
------------------------------------------------------------------------
function DRATS.CountRats()
	return #ents.FindByClass(DRATS.RatClass)
end

------------------------------------------------------------------------
-- Dégâts / récompense
------------------------------------------------------------------------
function DRATS.CanDamageRat(attacker)
	if not cfg.OnlyExterminatorCanKill then return true end
	return DRATS.IsExterminator(attacker)
end

local warnedAt = {}
function DRATS.WarnNotExterminator(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if (warnedAt[ply] or 0) > CurTime() then return end
	warnedAt[ply] = CurTime() + 5
	DarkRP.notify(ply, 1, 4, cfg.Lang.NotExterminator)
end

function DRATS.RewardKill(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if cfg.KillReward <= 0 or not ply.addMoney then return end
	if cfg.OnlyExterminatorCanKill and not DRATS.IsExterminator(ply) then return end

	ply:addMoney(cfg.KillReward)
	DarkRP.notify(ply, 0, 3, string.format(cfg.Lang.RatKilled, DarkRP.formatMoney(cfg.KillReward)))
	hook.Run("DRATS_RatKilled", ply)
end

------------------------------------------------------------------------
-- Propriétés DarkRP
------------------------------------------------------------------------
-- Retourne les portes possédées proches d'une position
function DRATS.GetOwnedDoorsNear(pos, radius)
	local doors = {}
	for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
		if IsValid(ent) and ent.isDoor and ent:isDoor() and ent.isKeysOwned and ent:isKeysOwned() then
			doors[#doors + 1] = ent
		end
	end
	return doors
end

function DRATS.NotifyInfestation(nest)
	if not cfg.NotifyOwner and not cfg.NotifyExterminators then return end
	if (nest.NextNotify or 0) > CurTime() then return end
	nest.NextNotify = CurTime() + cfg.NotifyCooldown

	if cfg.NotifyOwner then
		local notified = {}
		for _, door in ipairs(DRATS.GetOwnedDoorsNear(nest:GetPos(), cfg.PropertyDoorRadius)) do
			local owner = door:getDoorOwner()
			if IsValid(owner) and not notified[owner] then
				notified[owner] = true
				DarkRP.notify(owner, 1, 6, cfg.Lang.OwnerWarning)
			end
		end
	end

	if cfg.NotifyExterminators then
		for _, ply in ipairs(DRATS.GetExterminators()) do
			DarkRP.notify(ply, 0, 6, cfg.Lang.ExterminatorWarning)
		end
	end
end

------------------------------------------------------------------------
-- Sauvegarde des nids
------------------------------------------------------------------------
local DATA_DIR = "darkrp_rats"

local function dataFile()
	return DATA_DIR .. "/" .. game.GetMap() .. ".json"
end

DRATS.Loading = false
DRATS.ShuttingDown = false

function DRATS.SaveNests()
	if not cfg.SaveNests or DRATS.Loading or DRATS.ShuttingDown then return end

	local data = {}
	for _, nest in ipairs(ents.FindByClass(DRATS.NestClass)) do
		if IsValid(nest) and not nest.DRATS_Removing then
			local pos, ang = nest:GetPos(), nest:GetAngles()
			data[#data + 1] = {
				pos = { pos.x, pos.y, pos.z },
				ang = { ang.p, ang.y, ang.r },
				maxRats = nest:GetMaxRats(),
				interval = nest:GetSpawnInterval(),
				radius = nest:GetWanderRadius(),
			}
		end
	end

	file.CreateDir(DATA_DIR)
	file.Write(dataFile(), util.TableToJSON(data, true))
end

function DRATS.LoadNests()
	if not cfg.SaveNests then return end

	local raw = file.Read(dataFile(), "DATA")
	if not raw then return end
	local data = util.JSONToTable(raw)
	if not data then return end

	DRATS.Loading = true
	for _, nest in ipairs(ents.FindByClass(DRATS.NestClass)) do
		nest:Remove()
	end

	for _, info in ipairs(data) do
		local nest = ents.Create(DRATS.NestClass)
		if IsValid(nest) then
			nest:SetPos(Vector(info.pos[1], info.pos[2], info.pos[3]))
			nest:SetAngles(Angle(info.ang[1], info.ang[2], info.ang[3]))
			nest:SetMaxRats(info.maxRats or cfg.DefaultMaxRats)
			nest:SetSpawnInterval(info.interval or cfg.DefaultInterval)
			nest:SetWanderRadius(info.radius or cfg.DefaultRadius)
			nest:Spawn()
		end
	end
	DRATS.Loading = false
end

hook.Add("InitPostEntity", "DRATS_LoadNests", function()
	timer.Simple(2, DRATS.LoadNests)
end)

hook.Add("PreCleanupMap", "DRATS_PreCleanup", function()
	DRATS.Loading = true
end)

hook.Add("PostCleanupMap", "DRATS_PostCleanup", function()
	DRATS.Loading = false
	DRATS.LoadNests()
end)

hook.Add("ShutDown", "DRATS_ShutDown", function()
	DRATS.ShuttingDown = true
end)

------------------------------------------------------------------------
-- Commandes admin
------------------------------------------------------------------------
concommand.Add("drats_killall", function(ply)
	if IsValid(ply) and not DRATS.IsAdmin(ply) then return end
	for _, rat in ipairs(ents.FindByClass(DRATS.RatClass)) do
		rat:Remove()
	end
end)

concommand.Add("drats_reload", function(ply)
	if IsValid(ply) and not DRATS.IsAdmin(ply) then return end
	DRATS.LoadNests()
end)
