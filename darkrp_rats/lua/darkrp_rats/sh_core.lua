--[[
	Fonctions partagées (client + serveur).
]]

local cfg = DRATS.Config

DRATS.RatClass = "darkrp_rat"
DRATS.NestClass = "rat_nest"

-- Le joueur peut-il gérer les nids ?
function DRATS.IsAdmin(ply)
	if not IsValid(ply) then return false end
	if ply:IsSuperAdmin() then return true end
	return cfg.AdminGroups[ply:GetUserGroup()] == true
end

-- Le joueur est-il dératiseur ?
function DRATS.IsExterminator(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	local jobName = team.GetName(ply:Team())
	if jobName == cfg.JobName then return true end
	return cfg.ExtraExterminatorJobs[jobName] == true
end

-- Liste des dératiseurs connectés
function DRATS.GetExterminators()
	local list = {}
	for _, ply in ipairs(player.GetAll()) do
		if DRATS.IsExterminator(ply) then
			list[#list + 1] = ply
		end
	end
	return list
end

------------------------------------------------------------------------
-- Création du métier DarkRP
------------------------------------------------------------------------
hook.Add("loadCustomDarkRPItems", "DRATS_CreateJob", function()
	if not cfg.CreateJob then return end

	TEAM_DERATISEUR = DarkRP.createJob(cfg.JobName, {
		color = Color(120, 160, 60, 255),
		model = cfg.JobModels,
		description = [[Vous êtes dératiseur.
Les rats envahissent les propriétés de la ville :
trouvez-les et éliminez-les avec votre pulvérisateur de raticide.
Chaque rat tué vous rapporte de l'argent !]],
		weapons = { "weapon_deratiseur" },
		command = cfg.JobCommand,
		max = cfg.JobMax,
		salary = cfg.JobSalary,
		admin = 0,
		vote = false,
		hasLicense = false,
		category = cfg.JobCategory,
	})
end)

------------------------------------------------------------------------
-- Protection des entités : seuls les admins les manipulent
------------------------------------------------------------------------
local function isProtected(ent)
	if not IsValid(ent) then return false end
	local class = ent:GetClass()
	return class == DRATS.NestClass or class == DRATS.RatClass
end

hook.Add("PhysgunPickup", "DRATS_Protect", function(ply, ent)
	if isProtected(ent) and not DRATS.IsAdmin(ply) then return false end
end)

hook.Add("CanTool", "DRATS_Protect", function(ply, tr, tool)
	if tool == "rat_nest" and not DRATS.IsAdmin(ply) then return false end
	if isProtected(tr.Entity) and not DRATS.IsAdmin(ply) then return false end
end)

hook.Add("CanProperty", "DRATS_Protect", function(ply, property, ent)
	if isProtected(ent) and not DRATS.IsAdmin(ply) then return false end
end)

