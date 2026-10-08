--[[
	Outil : Nid de rats
	Clic gauche : placer un nid
	Clic droit  : supprimer le nid visé
	Recharger   : appliquer les réglages actuels au nid visé
]]

TOOL.Category = "DarkRP"
TOOL.Name = "#tool.rat_nest.name"

TOOL.ClientConVar = {
	maxrats = "5",
	interval = "60",
	radius = "300",
}

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" },
}

if CLIENT then
	language.Add("tool.rat_nest.name", "Nid de rats")
	language.Add("tool.rat_nest.desc", "Place des points d'apparition de rats dans les propriétés")
	language.Add("tool.rat_nest.left", "Placer un nid de rats")
	language.Add("tool.rat_nest.right", "Supprimer le nid visé")
	language.Add("tool.rat_nest.reload", "Appliquer les réglages au nid visé")
	language.Add("Undone_rat_nest", "Nid de rats supprimé")
end

local function isNest(ent)
	return IsValid(ent) and ent:GetClass() == "rat_nest"
end

function TOOL:GetSettings()
	return math.Clamp(self:GetClientNumber("maxrats", 5), 1, 30),
		math.Clamp(self:GetClientNumber("interval", 60), 5, 3600),
		math.Clamp(self:GetClientNumber("radius", 300), 50, 2000)
end

function TOOL:LeftClick(tr)
	if not tr.Hit then return false end
	if not DRATS.IsAdmin(self:GetOwner()) then return false end
	if CLIENT then return true end

	local ply = self:GetOwner()
	local maxRats, interval, radius = self:GetSettings()

	local nest = ents.Create("rat_nest")
	if not IsValid(nest) then return false end
	nest:SetPos(tr.HitPos + tr.HitNormal * 2)
	nest:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
	nest:SetMaxRats(maxRats)
	nest:SetSpawnInterval(interval)
	nest:SetWanderRadius(radius)
	nest:Spawn()

	-- Poser le nid sur le sol
	local mins = nest:OBBMins()
	nest:SetPos(tr.HitPos - tr.HitNormal * mins.z)

	undo.Create("rat_nest")
		undo.AddEntity(nest)
		undo.SetPlayer(ply)
	undo.Finish()

	DRATS.SaveNests()
	DarkRP.notify(ply, 0, 3, DRATS.Config.Lang.NestPlaced)
	return true
end

function TOOL:RightClick(tr)
	if not isNest(tr.Entity) then return false end
	if not DRATS.IsAdmin(self:GetOwner()) then return false end
	if CLIENT then return true end

	tr.Entity:Remove()
	DarkRP.notify(self:GetOwner(), 0, 3, DRATS.Config.Lang.NestRemoved)
	return true
end

function TOOL:Reload(tr)
	if not isNest(tr.Entity) then return false end
	if not DRATS.IsAdmin(self:GetOwner()) then return false end
	if CLIENT then return true end

	local maxRats, interval, radius = self:GetSettings()
	tr.Entity:SetMaxRats(maxRats)
	tr.Entity:SetSpawnInterval(interval)
	tr.Entity:SetWanderRadius(radius)

	DRATS.SaveNests()
	DarkRP.notify(self:GetOwner(), 0, 3, DRATS.Config.Lang.NestUpdated)
	return true
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", { Description = "#tool.rat_nest.desc" })

	panel:NumSlider("Rats maximum par nid", "rat_nest_maxrats", 1, 30, 0)
	panel:NumSlider("Intervalle d'apparition (s)", "rat_nest_interval", 5, 600, 0)
	panel:NumSlider("Rayon de déplacement", "rat_nest_radius", 50, 2000, 0)

	panel:Help("Les nids sont sauvegardés automatiquement pour cette map.")
	panel:Button("Supprimer tous les rats", "drats_killall")
	panel:Button("Recharger les nids sauvegardés", "drats_reload")
end
